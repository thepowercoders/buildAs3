#-------------------------------------------------------------------------------------------------------------------
#   Script:     as3Markdown.ps1
#   Author:     Antony Millington
#   Date:       July 2023
#   Version:    6.0 (April 2024)
#   Comments:
#       Creates a markdown document from the same data used to generate AS3 config which can be added to a WIKI.
#       Also provides data file links*, links to the relevant API Schema Reference on F5 clouddocs, and a copy of the template file used*.
#       v4 Also prints data from subtables, dns zonefiles, and creates hyperlinks to certificates, irules, and WAF policy declarations.
#
#       * for this to work, you need to specify the path to the repo where build-as3 is running.
#
#       Optional Parameters:    -NoDeviceList : do not include the intial table showing the list of devices referenced in the
#                                               data files and used to generate the table data.
#                               -GitType      : either 'github' (default) or 'ado' for Azure DevOps.
#-------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(ParameterSetName = 'github', Mandatory=$true, Position = 0)]
    [switch]$OutputGithub,
    [Parameter(ParameterSetName = 'ado', Mandatory=$true, Position = 0)]
    [switch]$OutputADO,

    [Parameter(ParameterSetName = 'github', Mandatory=$true, Position = 1)]
    [string]$GitHubUsername,
    [Parameter(ParameterSetName = 'ado', Mandatory=$true, Position = 1)]
    [string]$Organisation,
    [Parameter(ParameterSetName = 'ado', Mandatory=$true, Position = 2)]
    [string]$Project,

    [Parameter(Mandatory=$true)][string]$Repo,
    [Parameter(Mandatory=$true)][string]$AzTenant,
    [Parameter()][switch]$NoDeviceList

) #end param

$dirPath=(Get-Item $PSCommandPath ).DirectoryName
$dataDir="$dirPath\data\$AzTenant"
# check the Azure Tenant data directory exists:
if (Test-Path -Path $dataDir -PathType Container) {
    Write-Output "Data directory set to Azure Tenant: $AzTenant"
} else {
    Write-Error "The data directory for the given Azure Tenant: $AzTenant does not exist."
    Exit 1
}
$templateDir="$dirPath\templates"
$declareDir="$dirPath\declarations\$AzTenant"
$deviceList="$dirPath\devicelist.json"

# Get current directory name (this will be the as3 partition name)
$buildDirectory = Split-Path -Path $dirPath -Leaf

if($OutputGithub){
    Write-Host "`nGit Type set to : Github"
    $gitRepoPath="https://github.com/$GitHubUsername/$Repo/blob/main"
}elseif($OutputADO){
    Write-Host "`nGit Type set to : Azure DevOps"
    $gitRepoPath="https://dev.azure.com/$Organisation/$Project/_git/$Repo?path=/$($buildDirectory)"
}
Write-Host "Generating Wiki.`nRepo Path is: $gitRepoPath, Build Directory (AS3 Partition) is: $buildDirectory"

function printHeaderText
{
    $dateNow = Get-Date -UFormat '%b %d %H:%M:%S'
    Write-Output "> :memo: **Note:** This wiki was generated using [as3Markdown.ps1]($gitRepoPath/as3Markdown.ps1) based on the AS3 configuration files on $dateNow.`n"
    # ADO uses the 'TOC' keyboard to write a table of contents, github autogenerates one.
    if($OutputADO){Write-Output "[[_TOC_]]`n`n"}
    $DeviceData=(Get-Content -Path $deviceList | ConvertFrom-Json)
    $devices=$DeviceData | Get-member -MemberType 'NoteProperty' | Select-Object -ExpandProperty 'Name'
    Write-Host "getting declaration information..."
    Write-Output "# Declarations`nThis LLD is aligned to the following declarations:`n|device|declaration|ID|Branch|Partition|Date Created|`n|---|---|---|---|---|---|"
    foreach ($device in $devices) {
        $declarations=Get-ChildItem -Name "$declareDir\$device" -Filter "*.as3.*.json"
        foreach ($declaration in $declarations) {
            $remarkIDs = Select-String -Path "$declareDir\$device\$declaration" -Pattern '"remark": "(ID:\d+ BR:[\w-]+ \w+:[\w-:]+)"' | Select-Object -ExpandProperty Matches
            if ($remarkIDs) {
                $IDdecl = $remarkIDS.Groups[1].Value
                $IDtenant = $remarkIDS.Groups[3].Value
                $id=(($remarkIDS.Groups[1].Value -split ' ')[0] -split ':')[1]
                $br=(($remarkIDS.Groups[1].Value -split ' ')[1] -split ':')[1]
                $par=(($remarkIDS.Groups[1].Value -split ' ')[2] -split ':')[1]
                $date=(($remarkIDS.Groups[3].Value -split ' ')[2] -split ':')[1,2]
                $fmdate=("$date").Replace(' ',':')
                Write-Output "|$device|$declaration|$id|$br|$par|$fmdate|"
            } else {
                Write-Host -ForegroundColor Red "ERROR: Remark IDs not found in the declaration: $declaration"
                Write-Output "|$device|$declaration|*unknown*|*unknown*|*unknown*|*unknown*|"
            }

        }
    }
    If (!($NoDeviceList)) {
        Write-Host "adding device list..."
        Write-Output "# Devices`nThe following devices are configured:`n|device|device group|AS3 Classes configured|`n|---|---|---|"
        foreach ($device in $devices) {
            $as3FileList=$DeviceData.$device.AS3ClassList
            if($as3FileList){
                foreach($as3File in $as3FileList){
                    Write-Debug "as3File=$as3File"
                    $sampleAs3File=Get-ChildItem -Name $dataDir -Recurse -Filter "*$as3File*.csv" | Select-Object -First 1
                    if($sampleAs3File) {
                        $as3Class=((Get-Content "$dataDir\$sampleAs3File" | Select-Object -First 1).Split(",")[2]).Split(":")[1].Replace("_","-") + ", "
                        if ($as3ClassList -notmatch " $as3Class, ") {$as3ClassList=$as3ClassList + $as3Class}
                    }
                }
            }else{$as3FileList="|*none*"}
            Write-Output "|$($device)|$($DeviceData.$device.deviceGroup)|$($as3ClassList.Substring(0, $as3ClassList.Length - 2))|"
            $as3ClassList=''
        }
    }
}

function GetDnsZoneData{
    $dnsZoneFile=Get-ChildItem -Name $dataDir -Filter "$table" -Recurse
    $dataFile = (Import-Csv "$dataDir\$dnsZoneFile" -Delimiter "," )
    $matchedValues = $dataFile.$($subHeader.Name)
    Write-Host "        creating dns zone content from: $dnsZoneFile"
    foreach($zone in $matchedValues){
        Write-Output "`n### $DNS Zone File: $zone`n"
        Write-Output "Data File Location: $gitRepoPath/data/$AzTenant/$Partition/dns-zone/$zone`n"
        Write-Output '```'
        Get-Content $dataDir\dns-zone\$zone
        Write-Output '```'
    }
}

function GetSubTableData([array]$Subtables) {
    foreach($table in $Subtables) {
        $subtableDataFile=Get-ChildItem -Name $dataDir -Filter "$table" -Recurse
        if(!$subtableDataFile){
            Write-host -ForegroundColor Red "ERROR Subtable: $table does not exist."
        }else{
            $dataFile = (Import-Csv "$dataDir\$subtableDataFile" -Delimiter "," | Where-Object {$_.device -notlike "#*"})
            $entries=$dataFile.Count
            if($entries -eq 0){
                Write-Host "    $subtableDataFile contains no data."
            }else{
                $subDataName = $table.Split('-')[1].Split('.')[0]
                Write-Host "    creating subtable content from: $subtableDataFile"
                $subHeaders = ($dataFile[0].psobject.properties | Select-Object 'Name')
                Write-Output "`n### $subDataName Subtable Data`n"
                Write-Output "### $apiRef Template`n"
                $TemplateFile=$subtableDataFile -replace '\.csv$','.json'
                $FileToUri=$TemplateFile.Replace('\','/')
                Write-Output "Template File Location: $gitRepoPath/templates/$FileToUri.json`n"
                Write-Output '```json'
                Get-Content $templateDir\$TemplateFile
                Write-Output '```'"`n### $apiRef Data`n"
                $FileToUri=$subtableDataFile.Replace('\','/')
                Write-Output "Data File Location: $gitRepoPath/data/$AzTenant/$Partition/$FileToUri`n"
                $subHeaderString = ""
                foreach($subHeader in $subHeaders) {
                    $subHeaderString = $subHeaderString + $subHeader.Name + "|"
                    if($subHeader.Name -match "dns:zonefile"){$getDNS = $true}
                }
                Write-Output "|$subHeaderString"
                $divString = ""
                1..$subHeaders.Count | ForEach-Object {$divString = $divString + "|---"}
                Write-Output "$divString|"
                $formattedContent = (Get-Content $dataDir\$subtableDataFile).Replace("|","<br>").Replace(",","|").Replace("!DELETE!","*not used*") | Select-Object -Skip 1
                # remove blank lines and comments (any line starting with '#')
                $formattedContent | Where-Object { $_.Trim().Length -gt 0 } | Select-String '^[^#]' | Select-Object -ExpandProperty Line
            }
            if($getDNS){
                # print dns zone data
                GetDnsZoneData
            }
        }
    }
}

function GetClassData([string]$Partition)  {
    Write-Output "# AS3 Configuration for Partition: $Partition`n"
    $dataDir="$dataDir\$Partition"
    $classFileList = Get-ChildItem -Name $dataDir -Filter "as3-*" -Recurse
    foreach ($classFile in $classFileList)
    {
        $dataFile = (Import-Csv $dataDir\$classFile -Delimiter "," | Where-Object {$_.device -notlike "#*"})
        $entries=$dataFile.Count
        if($entries -eq 0){
            Write-Host "$classFile contains no data."
        }else{
            Write-Debug "classFile=$classFile"
            Write-Host "creating content from: $classFile"
            $headers = ($dataFile[0].psobject.properties | Select-Object 'Name')
            $apiRef=$headers[2].Name.Split(":")[1].Replace("_","-")
            $apiToUri=$apiRef.ToLower()
            Write-Debug "apiToUri=$apiToUri"
            Write-Output "`n## Class: $apiRef`n"
            Write-Output "API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#$apiToUri`n"
            $APIClass = $classFile.Split(".")[0]
            Write-Output "### $apiRef Template`n"
            $FileToUri=$APIClass.Replace('\','/')
            Write-Debug "FileToUri=$FileToUri"
            Write-Output "Template File Location: $gitRepoPath/templates/$FileToUri.json`n"
            Write-Output '```json'
            Get-Content $templateDir\$APIClass.json
            Write-Output '```'"`n### $apiRef Data`n"
            $FileToUri=$classFile.Replace('\','/')
            Write-Output "Data File Location: $gitRepoPath/data/$AzTenant/$Partition/$FileToUri`n"
            $headerString = ""
            $hlinkPosArray = @()
            $subtableArray = @()
            # we want to extract the headers so we can create a table for the data
            foreach($header in $headers) {
                $headerString = $headerString + $header.Name + "|"
                # check for special data types which refer to other data (subtables, irules, dns zones, certificates)
                if($header.Name -match "^subtable:"){
                    $subtableArray += "sub-$($header.Name.Split(':')[1]).csv"
                }
                if($header.Name -match "^irule:" -or $header.Name -match "^cert:" -or $header.Name -match "^waf:"){
                    $hlinkPosArray += $headers.IndexOf($header)}
            }

            # Create a table header using the header values in the csv data file
            Write-Output "|$headerString"
            $divString = ""
            1..$headers.Count | ForEach-Object {$divString = $divString + "|---"}
            Write-Output "$divString|"

            # We'll now take the data file content and reformat it for markdown
            $formattedContent = (Get-Content $dataDir\$classFile).Replace("|","<br>").Replace(",","|").Replace("!DELETE!","*not used*") | Select-Object -Skip 1
            # remove blank lines and comments (any line starting with '#')
            $trimContent = $formattedContent | Where-Object { $_.Trim().Length -gt 0 } | Select-String '^[^#]' | Select-Object -ExpandProperty Line
            
            # If there is table data we want to replace with hyperlinks (to irules, certs or waf), we do this here...
            if($hlinkPosArray.Count -gt 0){ 
                $fileType=$header.Name.Split(':')[0]
                switch ($fileType) {
                    "irule" { $fileLoc = "irules" }
                    "cert" { $fileLoc = "certificates" }
                    "waf" { $fileLoc = "asm" }
                }
                foreach ($line in $trimContent) {
                    $splitLine = $line -split '\|'
                    foreach ($hlinkPos in $hlinkPosArray){
                        $hlink=$splitLine[$hlinkPos]
                        if($hlink -notmatch "not used") {$splitLine[$hlinkPos] = "[$hlink]($gitRepoPath/data/$AzTenant/$Partition/$fileLoc/$hlink)"}
                    }
                    $splitLine -join '|'
                }
            }else{
                # just write out the content as is...
                write-output $trimContent
            }
            
        }
        # If any columns contained subtable references, we will call a function to print that out too... 
        if($subtableArray.Count -gt 0){
            GetSubTableData -Subtables $subtableArray
        }
    }
}

$outFile="$dirPath\$($AzTenant)_as3.md"
printHeaderText | Out-File $outFile
$PartitionList=Get-ChildItem -Name $dataDir
foreach ($Prt in $PartitionList){
    Write-Host "`n+ creating content for partition: $Prt"
    GetClassData -Partition $Prt | Out-File -Append $outFile
}
Write-Host "Done.`nOutput file in $outFile" -ForegroundColor Green
