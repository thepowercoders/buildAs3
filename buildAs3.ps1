#-------------------------------------------------------------------------------------------------------------------
#   Script:     buildAs3.ps1 - V3 for CI/CD Pipelines (uses Azure tenants/BIG-IP tenants (partitions) in data folder structure)
#   Author:     Antony Millington
#   Comments:
#       Creates F5 BIG-IP AS3 API json declarations for a given device and partition.
#       Mandatory Parameters:   
#                       either: -Device        = The name of the device (as given in ./devicelist.json).
#                       or:     -DeviceGroup   = A group of devices you want to build configs for ;and 
#                               -Partition     = The tenant (BIG-IP partition) which AS3 config will be built for.
#       Optional Parameters:    -Detail        = Provides more output on what the script is processing.
#                               -NoGSLBPool    = Prevents adding GSLB pool config to declaration. Needed when loading /Common config for the
#                                                first time as the referenced virtual servers may not be yet built.
#                               -IncludeSchema = this includes the '$schema' property set to the latest AS3 schema. Only include this when you
#                                                want to validate the declaration in the VSC editor. When deploying, this property is not stored
#                                                in the running declaration causing Terraform to believe a change is needed to 're-add' it.
#
#       The script needs the following files:
#           1. A csv file in the /data/<azureTenant>/<partition>/ folder for each API Class. The header of the file needs to be the
#              replaceable parameter names which are in the templates. The csv file can be in a further subfolder for each bigip
#              resource e.g. ltm, dns, afm etc..
#           2. A parameterized template file for each API Class in /templates. Again, these can be in a subfolder based on the
#              resource they are for (ltm,dns..etc).
#           3. All referenced certificates needs to be in: /data/<partition>/certificates, irules in: /data/<partition>/irules,
#               dns zones in: /data/<partition>/dns-zone,
#              external monitor scripts in: /data/<partition>/external-monitors, and WAF declarations in: /data/<partition>/asm
#           4. A json file 'devicelist.json' which contains all valid devices, which Azure Tenant they are in, which group they belong to,
#              and the list of AS3 API classes which need to be added for the specific device name.
#-------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$false)][string]$Device,
    [Parameter(Mandatory=$false)][string]$DeviceGroup,
    [Parameter(Mandatory=$true)][string]$Partition,
    [Parameter(Mandatory=$false)][switch]$NoGSLBPool,
    [Parameter(Mandatory=$false)][switch]$IncludeSchema,
    [Parameter()][switch]$Detail
) #end param
if(!$Device -And !$DeviceGroup){Write-Error "You need to either specify a Device or a Device Group." -ErrorAction Stop}
if($Device -And $DeviceGroup){Write-Error "You need to specify only a Device or a Device Group, not both." -ErrorAction Stop}

# Make sure this matches the AS3 RPM package version:
$as3SchemaVersion="3.45.0"
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$persist="true"
$runID=Get-Random
# increase this delay if you are getting errors with files being left open by previous read/write actions (to 50 should do it):
$FileCloseDelay=0
# Get the repo branch if available to add to the declaration remark
$repoBranch=(git rev-parse --abbrev-ref HEAD) 2> $null
# Flag for No Data in Partition
$global:noDataForPartition=$true

$dirPath=(Get-Item $PSCommandPath ).DirectoryName
$templateDir="$dirPath\templates"
$snippetDir="$dirPath\.snippets"
$declareDir="$dirPath\declarations"
# If your build folder is being synced to One Drive the script may run slowly due to the high level of temporary read/writes
# to the .\.snippets folder. This option moves that to the user's temp folder on their PC - just uncomment the line below...
$snippetDir="C:\%userprofile%\AppData\Local\Temp\buildAs3_snippets"

# The snippets and declarations folders are in .gitignore so not synced so may need creating in a clone directory...
New-Item -ItemType Directory -path $snippetDir -Force | Out-Null 
New-Item -ItemType Directory -path $declareDir -Force | Out-Null 

function kvpSubTable([string]$keySubtable, [string]$keyField)
# This is used for subtables of key-value pair data. It just creates a key and value with the data matching the keyField.
{   
    $SubtableDataFile=Get-ChildItem -Name $dataDir -Filter "sub-$keySubtable.csv" -Recurse
    $deviceData = Import-Csv "$dataDir\$SubtableDataFile" -Delimiter "," | Where-Object{$_."$keySubtable" -eq "$keyField"}
    $headers = ($deviceData | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name')
    foreach($item in $deviceData)
    {
        if ($item -ne $deviceData[-1]) {
            Write-Output "                        `"$($item.name)`" : `"$($item.value)`","
        }else{
            Write-Output "                        `"$($item.name)`" : `"$($item.value)`""
        }
    }
}

function SubTableReplace([string]$keySubtable, [string]$keyField)
# This is used for subtables where there are multiple key-value strings in an array - example pool members for GSLB and LTM.
# The function effectively creates multiple copies of the subtable template within a loop which creates the necessary array
# elements. It needs a template file for the array element and a data file - note: there is no error check for existance of
# these files.
{   
    $SubtableDataFile=Get-ChildItem -Name $dataDir -Filter "sub-$keySubtable.csv" -Recurse
    $SubtableTemplateFile=Get-ChildItem -Name $templateDir -Filter "sub-$keySubtable.json" -Recurse
    $deviceData = Import-Csv "$dataDir\$SubtableDataFile" -Delimiter "," | Where-Object{$_."$keySubtable" -eq "$keyField"}
    $headers = ($deviceData | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name')
    foreach($item in $deviceData)
    {
        $keyArrayTemplate=Get-Content -Path $templateDir\$SubtableTemplateFile | Select-Object -SkipLast 1 
        foreach($header in $headers){
            if($item.$header -match '!DELETE!') {
                # we have !DELETE! values against keys in the subtable, so need to remove the unwanted lines...
                $itemLineInTemplate=($keyArrayTemplate | Select-String "$header").LineNumber
                if($itemLineInTemplate -eq $keyArrayTemplate.Count ) {
                    # the deleted key is on the last line.. we need to know this because when we delete it, we'll
                    # also have to remove the comma from the preceding key, or we'll get a json format error
                    $keyArrayTemplate=$keyArrayTemplate -split "`n" | Where-Object { $_ -notmatch "{{$header}}" }
                    $editedLastLine=($keyArrayTemplate -split "`n" | Where-Object { $_ -notmatch "{{$header}}" })[-1] -replace ','
                    $keyArrayTemplate[$itemLineInTemplate -2]=$editedLastLine
                }else{
                    # as the deleted key isn't on the last line, we can just simply edit the template string to remove the line
                    # containing the key we no longer require it
                    $keyArrayTemplate=$keyArrayTemplate -split "`n" | Where-Object { $_ -notmatch "{{$header}}" }
                }
            }elseif($header -match ':' -And $header.Split(':')[0] -match '^multi'){
                # MULTIPLE VALUES IN VARIABLE (ARRAY)
                # The array is pipe '|' delimited
                $multiLineArray = @()
                $multiLine=$keyArrayTemplate | Select-String  "{{$header}}"
                $keyDataArray=$item."$header" -split '\|'
                foreach($multiItem in $keyDataArray) {
                    $multiLineElement = $multiLine -replace("{{$header}}","$multiItem")
                    if ($multiItem -ne $keyDataArray[-1]) {
                        $multiLineArray = "$multiLineArray$multiLineElement,`n"
                    }else{
                        # this is the final line of the array, so no comma needed
                        $multiLineArray = "$multiLineArray$multiLineElement"
                    }
                }
                $keyArrayTemplate=$keyArrayTemplate | ForEach-Object {$_ -replace $multiLine,$multiLineArray}
            }elseif($header -eq 'dns:zonefile'){
                # This is special handling for local DNS so we can store all the values in a simple flat bed file.
                $zoneFile=$item."$header"
                $zoneEntries=Get-Content -Path $dataDir\dns-zone\$zoneFile
                $zoneEntryArray = @()
                $templateZoneLine=$keyArrayTemplate | Select-String  "{{$header}}"
                if ($zoneEntries.Count -eq 1) {
                    # Only one line in the file
                    $zoneEntryArray = $templateZoneLine -replace "{{$header}}", "$zoneEntries"
                } else {
                    foreach($zoneEntry in $zoneEntries) {
                        $zoneElement = $templateZoneLine -replace("{{$header}}","$zoneEntry")
                        if ($zoneEntry -ne $zoneEntries[-1]) {
                            $zoneEntryArray = "$zoneEntryArray$zoneElement,`n"
                        }else{
                            # this is the final line of the array, so no comma needed
                            $zoneEntryArray = "$zoneEntryArray$zoneElement"
                        }
                    }
                }
                $keyArrayTemplate=$keyArrayTemplate | ForEach-Object {$_ -replace $templateZoneLine,$zoneEntryArray}
                #$keyArrayTemplate=$keyArrayTemplate.Replace("{{$header}}",$zoneEntryArray)
            }else{
                # we do a simple replace in the subtable template to substitute the template parameter with the data value
                $keyArrayTemplate=$keyArrayTemplate.Replace("{{$header}}",$item.$header)
            }
        }
        $keyArrayTemplate
        # check to see if this is the last array item in the class, if so, don't add a comma
        if ($item -ne $deviceData[-1]) {
            Write-Output "                      },"
        }else{
            Write-Output "                      }"
        }
    }
}

function createConfigSnippit([string]$Device, [string]$APIClass, [object]$GroupIDs)
# This function takes each AS3 APIClass defined for the device (in devicelist.json) and creates a code snippet - this being
# a copy of the template file for the Class with all the parameters replaced with data from the necessary data file.
{
    # This is just an error check to ensure the APIClass given has a template and a data file associated with it:
    $validEntities = Get-ChildItem -Name $templateDir -Filter "as3-*" -Recurse | ForEach-Object {$_.split("-")[1]} | ForEach-Object {$_.split(".")[0]}
    if(! ($validEntities -contains $APIClass))
    {
        Write-Error -Message "Unknown API Class '$APIClass' in AS3. Should be one of: $validEntities"
        Return
    }elseif(!( Test-Path $dataDir\*\as3-$APIClass.csv))
    {
        # this used to be an error but now we just give a warning as the partition directory may just not have this
        # data file in it if there is no such data in the partition.
        Write-Warning "No data file in partition: \$Partition data directory for: as3-$APIClass.csv"
        Return
    }else{
        $templateFile=Get-ChildItem -Name $templateDir -Filter "as3-$APIClass.json" -Recurse
        $dataFile=Get-ChildItem -Name $dataDir -Filter "as3-$APIClass.csv" -Recurse
    }

    Write-Host "Loading Data from: .\data\$Partition\$dataFile against template: .\templates\$templateFile" -ForegroundColor Yellow
    $deviceData=@()
    $deviceData += (Import-Csv "$dataDir\$dataFile" -Delimiter ",") | Where-Object{$_.Device -eq $Device}
    write-debug "DEVICEDATA from $Device=$deviceData"
    # we also need to match any lines which specify any one of the device's group IDs in the 'device' column:
    foreach($GroupID in $GroupIDs){
        $deviceData += (Import-Csv "$dataDir\$dataFile" -Delimiter ",") | Where-Object{$_.Device -eq "group:$GroupID"}
    }

    if(-Not($deviceData)){
        Write-Warning "No entries found for Device: $Device (or it's group(s): $GroupIDs) under Partition:\$Partition in data file: $dataFile`n"
    }else{
        $global:noDataForPartition=$false
        # We will take the headers from the CSV file as these form the list of template parameters we need to replace
        $headers = ($deviceData | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name')

        Write-Host "Creating snippets for Class:$APIClass"
        Remove-Item $snippetDir\$Device*.$APIClass.json

        # repeat for each line of the dataFile array:
        foreach($item in $deviceData)
        {
            foreach($GroupID in $GroupIDs){
                if($item.device -eq "group:$GroupID"){
                    # group ID match - replace with current group device...
                    $item.device=$item.device -replace  "group:$GroupID",$Device
                }
            }

            if ($Detail) {
                $keyFieldName = ($item.psobject.members | Select-Object -Index 2).Name
                $keyFieldValue = ($item.psobject.members | Select-Object -Index 2).value
                Write-Host "   device:"$item.device" application:"$item.application" key: "$keyFieldName" value: "$keyFieldValue
            }

            # This creates the format of the output filename (which is put into ./.snippets folder). Each config file uses the given
            # API Class template to create an output file based on device, partition and application name:
            $outputFile=$item.device + ".as3." + $Partition + "." + $item.application + "." + $APIClass + ".json" 
            $outputFileTemp=$item.device + ".as3." + $Partition + "." + $item.application + "." + $APIClass + ".tmp" 

            # Now we take a copy of the template file which we store as a temporary file. This will be used to parse
            # for each key-value pair to find/replace with the relevant data from the ./data folder for the APIClass:
            Get-Content -Path $templateDir\$templateFile | Select-Object -SkipLast 1 | Out-File -Encoding "UTF8" $snippetDir\$outputFileTemp
            
            # repeat for each template parameter (header) in the list of headers in the data file:
            foreach($header in $headers)
            {

                if($item.$header -match '!DELETE!') {
                
                # DELETE CONFIG LINE (HAS TO BE ON A COMPLETE SINGLE LINE):
                #
                # this option is for when we have templates where for some snippets we don't want a particular option. AS3
                # doesn't like us leaving options/keys blank so by entering '!DELETE!' as the key value in the data file,
                # when we process the declaration we can just edit out the option. Note - this only works for options which
                # are on a single line in the config:
                if ($Detail) {Write-Host -ForegroundColor Cyan "   Note: $header has DELETE option specified, so this line will be removed from the declaration."}
                $CurrentFileCopy=(Get-Content -Path $snippetDir\$outputFileTemp)
                $CurrentFileCopy.Where({$_ -match "{{$header}}"},'Until') | Set-Content $snippetDir\$outputFileTemp
                $CurrentFileCopy.Where({$_ -match "{{$header}}"},'SkipUntil') | Select-Object -Skip 1 | Out-File $snippetDir\$outputFileTemp -Append -Encoding "UTF8"

                }elseif($header -match ':' -And $header.Split(':')[0] -match '^cert'){
                    # ADD CERTIFICATES:
                    #
                    # This is for references in the data file to certificates/keys (the header name is 'cert:<parmname>')
                    # This requires a PEM format cert file in ./data-certificates.
                    $certificateFile = $item.$header
                    if ($Detail) {Write-Host -ForegroundColor Cyan "   Inserting a Certificate from : $certDataDir/$certificateFile"}
                    if(-not(Test-Path -Path $certDataDir/$certificateFile -PathType Leaf)){
                        if(-not((Test-Path -Path $certDataDir/default.cer -PathType Leaf) -and (Test-Path -Path $certDataDir/default.key -PathType Leaf))){
                            Write-Error "Cannot Replace Parameter! No Certificate file found for: $certificateFile in directory: $certDataDir"
                        }else{
                            Write-Warning "No Certificate file found for: $certificateFile in directory: $certDataDir `nUsing Default certificate and key."
                            if("$header" -eq "cert:certificate"){$certificateFile = "default.cer"}
                            if("$header" -eq "cert:privateKey"){$certificateFile = "default.key"}
                        }
                    }
                    # For AS3 certificates, the format remains PEM but CRLF linefeeds are replaced (as json key-value has to be single line):
                    $PEMFile=[System.IO.File]::ReadAllText("$certDataDir\$certificateFile")
                    if($PEMFile -cmatch '\r\n') {
                        $PEMRecode = $PEMFile -creplace '\r\n','\n'
                    }else{
                        $PEMRecode = $PEMFile -creplace '\n','\n'
                    }
                    (Get-Content -Path $snippetDir\$outputFileTemp).Replace("{{$header}}",$PEMRecode) | Set-Content $snippetDir\$outputFileTemp

                }elseif($header -match ':' -And $header.Split(':')[0] -match '^waf'){
                    # ADD ASM (WAF) SECURITY PROFILE:
                    #
                    # This is for references in the data file to WAF profiles (the header name is 'waf:<parmname>')
                    # This requires a WAF json declaration text file in ./data-waf.
                    $wafFile = $item.$header
                    if ($Detail) {Write-Host -ForegroundColor Cyan "   Inserting a WAF Policy from : $wafDataDir/$wafFile"}
                    if(-not(Test-Path -Path $wafDataDir/$wafFile -PathType Leaf)){
                        Write-Warning "No WAF file found for: $wafFile in directory: $wafDataDir `n"
                    }
                    # For WAF policies in AS3, the format is Base64 so has to be re-encoded to this format:
                    $WAFData = Get-Content -Path $wafDataDir/$wafFile -Encoding UTF8 -Raw
                    $BStream = [System.Text.Encoding]::UTF8.GetBytes($WAFData)
                    $encText = [System.Convert]::ToBase64String($BStream)
                    (Get-Content -Path $snippetDir\$outputFileTemp).Replace("{{$header}}",$encText) | Set-Content $snippetDir\$outputFileTemp

                }elseif($header -match ':' -And $header.Split(':')[0] -match '^irule'){
                    # ADD IRULE:
                    #
                    # This is for references in the data file to IRULES  (the header name is 'irule:<parmname>')
                    # This requires an iRule in text file in ./data-irules.
                    $iRuleFile = $item.$header
                    if ($Detail) {Write-Host -ForegroundColor Cyan "   Inserting an iRule from : $iRuleDataDir/$iRuleFile"}
                    if(-not(Test-Path -Path $iRuleDataDir/$iRuleFile -PathType Leaf)){
                        Write-Error "No iRule file found for: $iRuleFile in directory: $iRuleDataDir `n"
                    }else{
                        # For iRules in AS3, the format is Base64 so has to be re-encoded to this format:
                        $WAFData = Get-Content -Path $iRuleDataDir/$iRuleFile -Encoding UTF8 -Raw
                        $BStream = [System.Text.Encoding]::UTF8.GetBytes($WAFData)
                        $encText = [System.Convert]::ToBase64String($BStream)
                        (Get-Content -Path $snippetDir\$outputFileTemp).Replace("{{$header}}",$encText) | Set-Content $snippetDir\$outputFileTemp
                    }

                }elseif($header -match ':' -And $header.Split(':')[0] -match '^multi'){
                    # MULTIPLE ARRAY VALUES
                    #
                    # This is a simple multi-value option which allows an array of values to be built within a variable
                    # The array is pipe '|' delimited and needs to be on a single line
                    if ($Detail) {Write-Host -ForegroundColor Cyan "   Note: Parameter $header is a multi-line array"}
                    $multiLineArray = @()
                    $multiLine=Get-Content -Path $snippetDir\$outputFileTemp | Select-String  "{{$header}}"
                    $keyDataArray=$item."$header" -split '\|'
                    foreach($multiItem in $keyDataArray) {
                        $multiLineElement = $multiLine -replace("{{$header}}","$multiItem")
                        if ($multiItem -ne $keyDataArray[-1]) {
                            $multiLineArray = "$multiLineArray$multiLineElement,`n"
                        }else{
                            # this is the final line of the array, so no comma needed
                            $multiLineArray = "$multiLineArray$multiLineElement"
                        }
                    }
                    (Get-Content -Path $snippetDir\$outputFileTemp) | ForEach-Object {$_ -replace $multiLine,$multiLineArray} | Set-Content $snippetDir\$outputFileTemp

                }elseif($header -match ':' -And $header.Split(':')[0] -match '^subtable') {
                    # INSERT DATA FROM ANOTHER 'DATA' FILE (SUBTABLE OF DATA) 
                    # 
                    # This option is used when the array elements in the AS3 are complex and multiple values,
                    # It calls the 'SubTableReplace' function which effectively builds an AS3 snippet of code from a template inside another
                    # snippet/template.

                    if("$APIClass" -eq "GSLB_Pool" -and $NoGSLBPool){
                        if ($Detail) {Write-Host -ForegroundColor Cyan "   Note: NoGSLBPool specified, so pool members will be removed from the declaration."}
                        $CurrentFileCopy=(Get-Content -Path $snippetDir\$outputFileTemp)
                        $CurrentFileCopy.Where({$_ -match "{{$header}}"},'Until') | Set-Content $snippetDir\$outputFileTemp
                        $CurrentFileCopy.Where({$_ -match "{{$header}}"},'SkipUntil') | Select-Object -Skip 1 | Out-File $snippetDir\$outputFileTemp -Append -Encoding "UTF8"
                    }else{
                        if ($Detail) {Write-Host -ForegroundColor Cyan "   Note: Parameter $header is a subtable of data referencing key: "$item.$header}
                        $CurrentFileCopy=(Get-Content -Path $snippetDir\$outputFileTemp)
                        $CurrentFileCopy.Where({$_ -match "{{$header}}"},'Until') | Set-Content $snippetDir\$outputFileTemp
                        Write-Host "Creating snippets for $header  Value:$($item.$header)"
                        SubTableReplace -keySubtable $header.Split(':')[1] -keyField $item.$header | Out-File -Append -Encoding "UTF8" $snippetDir\$outputFileTemp
                        $CurrentFileCopy.Where({$_ -match "{{$header}}"},'SkipUntil') | Select-Object -Skip 1 | Out-File -Append -Encoding "UTF8" $snippetDir\$outputFileTemp               
                    }
                }elseif($header -match ':' -And $header.Split(':')[0] -match '^kvtable') {
                    # INSERT KEY-VALUE PAIRS FROM ANOTHER 'DATA' FILE (SUBTABLE OF DATA CONTAINING KEY-VALUE PAIRS) 
                    # 
                    # This option is used when a property contains an array of key-value-pair elements where both KEY and VALUE need defining.
                    # It calls the 'kvpSubTable' function which effectively builds an AS3 snippet of code inside another snippet/template.
                    if ($Detail) {Write-Host -ForegroundColor Cyan "   Note: Parameter $header is a subtable of key-value pairs referencing key: "$item.$header}
                    $CurrentFileCopy=(Get-Content -Path $snippetDir\$outputFileTemp)
                    $CurrentFileCopy.Where({$_ -match "{{$header}}"},'Until') | Set-Content $snippetDir\$outputFileTemp
                    Write-Host "Creating kv-snippets for $header  Value:$($item.$header)"
                    kvpSubTable -keySubtable $header.Split(':')[1] -keyField $item.$header | Out-File -Append -Encoding "UTF8" $snippetDir\$outputFileTemp
                    $CurrentFileCopy.Where({$_ -match "{{$header}}"},'SkipUntil') | Select-Object -Skip 1 | Out-File -Append -Encoding "UTF8" $snippetDir\$outputFileTemp               
                } else {

                    # Finally, if there is no special processing needed, a simple find/replace on the parameters is performed:
                    Copy-Item  $snippetDir\$outputFileTemp -Destination  $snippetDir\$outputFileTemp".pre"
                    start-sleep -Milliseconds $FileCloseDelay
                    (Get-Content -Path $snippetDir\$outputFileTemp".pre").Replace("{{$header}}",$item.$header) | Set-Content $snippetDir\$outputFileTemp
                    Remove-Item $snippetDir\$outputFileTemp".pre"
                }
            }

            if ((get-Content -Path "$snippetDir\$outputFileTemp" -tail 1).EndsWith(',')){
                # bug-fix: if we are using !DELETE! with the last property in the template, we will not be aware of this when processing
                # the previous property so it will have a comma we need to remove (as it's now the last property in the class)
                $preContent=Get-Content -Path $snippetDir\$outputFileTemp -Head ($((Get-Content -Path $snippetDir\$outputFileTemp).Length) - 1)
                $postContent=(get-Content -Path $snippetDir\$outputFileTemp -tail 1).Replace(',','')
                $preContent,$postContent | Add-Content $snippetDir\$outputFile -Encoding UTF8
            }else{
                # The Declaration is appended with the json snippet just created...
                Get-Content -Path $snippetDir\$outputFileTemp | Add-Content $snippetDir\$outputFile -Encoding UTF8
            }
            Write-Output "`t`t`t`t}," | Out-File $snippetDir\$outputFile -Append -Encoding UTF8
        }
        Remove-Item $snippetDir\*.$APIClass.tmp
        Write-Host "Done.`n" -ForegroundColor Green
    }
}

function as3Declaration([string]$AzTenant, [string]$Device, [string]$Partition)
# builds a complete declaration using all the snippets created for each partition.
{
    $as3OutputFile="$declareDir\$AzTenant\$Device\$Device.as3.$Partition" + ".json"
    # The declaration folder needs a subfolder per device, create if it doesn't exist...
    if(!(Test-Path -Path "$declareDir\$AzTenant\$Device")){
        New-Item -ItemType Directory -path "$declareDir\$AzTenant\$Device" -Force | Out-Null 
    }else{
        # delete all previous declaration files for same device/partition to clean up from any previous runs
        Remove-Item $as3OutputFile -Force -ErrorAction SilentlyContinue
    }
    $ts=Get-Date -Format "dd-MM-yy_HH:mm"
    $Applications=Get-ChildItem -Name $snippetDir -Filter "*as3.$Partition*" | ForEach-Object {$_.split(".")[3]} | Sort-Object -Unique
    
    # We firstly write out the standard JSON content needed for every AS3 declaration which sets the schema, action and ID/Labels, and the partition
    if($IncludeSchema){
        Write-Output @"
{
    "`$schema": "https://raw.githubusercontent.com/F5Networks/f5-appsvcs-extension/master/schema/latest/as3-schema.json",
"@ | Out-File -Append -Encoding "UTF8" $as3OutputFile       
    }else{
        Write-Output @"
{
"@ | Out-File -Append -Encoding "UTF8" $as3OutputFile
    }
    $DecRemark="ID:$runID BR:$repoBranch Par:$Partition"
    if($DecRemark.Length -gt 64){
        $repoBranch = $repoBranch.Substring(0, $repoBranch.Length - ($DecRemark.Length-64))
        $DecRemark="ID:$runID BR:$repoBranch Par:$Partition"
    }
    $DecPrtRemark="ID:$runID BR:$repoBranch DATE:$ts"
    if($DecPrtRemark.Length -gt 64){
        $repoBranch = $repoBranch.Substring(0, $repoBranch.Length - ($DecPrtRemark.Length-64))
        $DecPrtRemark="ID:$runID BR:$repoBranch DATE:$ts"
    }
    Write-Output @"
    "class": "AS3",
    "action": "deploy",
    "persist": $persist,
    "declaration": {
        "class": "ADC",
        "schemaVersion": "$as3SchemaVersion",
        "remark": "$DecRemark",
        "$Partition": {
            "class": "Tenant",
            "remark": "$DecPrtRemark",
"@ | Out-File -Append -Encoding "UTF8" $as3OutputFile

    ForEach($Application in $Applications) {
        Write-Host "   Collating config snippets for Application: $Application" -ForegroundColor Yellow
        Write-Output @"
            "$Application": {
                "class": "Application",
"@  | Out-File -Append -Encoding "UTF8" $as3OutputFile
        if("$Application" -match "^Shared") {
            Write-Output '                "template": "shared",' | Out-File -Append -Encoding "UTF8" $as3OutputFile
        }
        $ConfigGroup=Get-ChildItem -Name $snippetDir -Filter "$Device.as3.$Partition.$Application.*.json" | Sort-Object
        ForEach($configFile in $ConfigGroup) {
            Write-Host "      adding : $configFile" -ForegroundColor DarkGray
            Get-Content -Path $snippetDir\$configFile | Select-Object -SkipLast 1 | Out-File -Append -Encoding "UTF8" $as3OutputFile
            if ($ConfigGroup.Count -gt 1 -And $configFile -ne $ConfigGroup[-1]) {
                Write-Output @"
                },
"@  | Out-File -Append -Encoding "UTF8" $as3OutputFile
            }else{
                Write-Output @"
                }
"@  | Out-File -Append -Encoding "UTF8" $as3OutputFile  
            }
        }
        if ($Applications.Count -gt 1 -and $Application -ne $Applications[-1]) {
            Write-Output @"
            },
"@  | Out-File -Append -Encoding "UTF8" $as3OutputFile
        }else{
            Write-Output @"
            }
"@  | Out-File -Append -Encoding "UTF8" $as3OutputFile  
        }
    }
    Write-Output @"
        }
    }
}
"@  | Out-File -Append -Encoding "UTF8" $as3OutputFile
    if($PSVersionTable.PSVersion.Major -lt 6 ){
        # default output for v5 psh is utf8-bom which upsets Terraform, so we need to rewrite the file as utf8:
        Write-Host -ForegroundColor Yellow "      (rewriting as3 to UTF-8)"
        $as3DecJson = Get-Content $as3OutputFile
        [IO.File]::WriteAllLines($as3OutputFile, $as3DecJson)
    }
    Write-Host "Done.`nAS3 Declaration output to: $as3OutputFile `n" -ForegroundColor Green
}

### MAIN ###
if($DeviceGroup) {
    # If we've specified a device group for build, we need to expand the device list to allow multiple builds for all devices in that group:
    $deviceList = ((Get-Content $dirPath\devicelist.json | ConvertFrom-Json).PSObject.Properties | Where-Object {$_.Value.deviceGroup -eq "$DeviceGroup"}).Name
    if(!$deviceList){ Write-Error -Category InvalidData -RecommendedAction "Check device group exists in .\devicelist.json" "No such devices in device group." -ErrorAction Stop}
    Write-Host "+ Device Group $DeviceGroup has the following devices: "$deviceList -ForegroundColor Blue
}else{
    # the device list is just a single device
    $deviceList = $Device
    Write-Debug "DEV"
    $chkdev=(Get-Content $dirPath\devicelist.json | ConvertFrom-Json).PSObject.Properties.Name
    if(!($chkdev | Where-Object {$_ -eq "$Device"})){ Write-Error -Category InvalidData "Device should be one of: $chkdev." -ErrorAction Stop}
}

ForEach($bigip in $deviceList) {
    # Get class details from the devicelist file and create the declarations:
    $deviceGroupOwnership = (Get-Content $dirPath\devicelist.json | ConvertFrom-Json)."$bigip".deviceGroup
    $deviceClassList = (Get-Content $dirPath\devicelist.json | ConvertFrom-Json)."$bigip".AS3ClassList
    if(!$deviceClassList){ Write-Error -Category InvalidData -RecommendedAction "Check device name exists in .\devicelist.json" "Unknown Device." -ErrorAction Stop}

    $deviceAzureTenant = (Get-Content $dirPath\devicelist.json | ConvertFrom-Json)."$bigip".azureTenant
    if(!$deviceAzureTenant){ Write-Error -Category InvalidData -RecommendedAction "Device property azureTenant missing. Check .\devicelist.json" "Unknown Azure Tenant." -ErrorAction Stop}
    # Set up Directory Paths for the device's tenant:
    $dataDir="data\$deviceAzureTenant\$Partition"
    $certDataDir="$dataDir\certificates"
    $wafDataDir="$dataDir\asm"
    $iRuleDataDir="$dataDir\irules"

    Write-Host "+ Creating AS3 Config Snippits for Device: $bigip in Azure Tenant: $deviceAzureTenant" -ForegroundColor Blue
    foreach($APIClass in $deviceClassList)
    {
        createConfigSnippit -Device $bigip -APIClass $APIClass -GroupIDs $deviceGroupOwnership
    }

    if($global:noDataForPartition){
        Write-Host -ForegroundColor Red "`n++ Error: No Data found for Device: $bigip in Azure Tenant: $deviceAzureTenant for Partition: $Partition`n" 

        # delete all created snippet files now we have valid declaration files
        $dirPath=(Get-Item $PSCommandPath ).DirectoryName
        Remove-Item $snippetDir\$bigip.*.json -Force
    }else{
        Write-Host ("++ Creating AS3 Declaration for Device: **$bigip** in Azure Tenant: **$deviceAzureTenant** for Partition: **$Partition**"  | ConvertFrom-MarkDown -AsVt100EncodedString).VT100EncodedString
        as3Declaration -Device $bigip -Partition $Partition -AzTenant $deviceAzureTenant

        # delete all created snippet files now we have valid declaration files
        $dirPath=(Get-Item $PSCommandPath ).DirectoryName
        Remove-Item $snippetDir\$bigip.*.json -Force
    }
}