#-------------------------------------------------------------------------------------------------------------------
#   Script:     makeDataFile.ps1
#   Author:     Antony Millington
#   Comments:
#       Creates the data file for an AS3 Class template snippet which is in the /templates folder.
#       Mandatory Parameters:   
#                              -FileName        = The name of the template file in /templates folder.
#
#       The script needs the following file:
#           1. A parameterized template file for the API Class in /templates. These can be in a subfolder based on the
#              resource they are for (ltm,dns..etc).
#
#   The script creates a csv file for the given API Class. The header of the file is created using the replaceable parameter
#   names which are in the templates. The file is created in the root folder, and can be moved to wherever it is needed
#   in the /data/<azure_partition>/<as3_partition> folder or subfolder.
#-------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$FileName
) #end param

$dirPath=(Get-Item $PSCommandPath ).DirectoryName
$templateDir="$dirPath\templates"
if($FileName.EndsWith('.json')){$FileName=$FileName.Split('.json')[0]}
if(!( Test-Path $templateDir\*\$FileName.json)){
    Write-Error -Message "Cannot find template file: $FileName.json in /templates."
    Exit 1
}

$template=Get-Content $templateDir\*\$FileName.json
$pattern = '{{(.*?)}}'
$replParms = [regex]::Matches($template, $pattern)
$parameterNames = $replParms | ForEach-Object { $_.Groups[1].Value }

if($FileName.StartsWith('as3-')){
    write-host "Creating AS3 Class Data File"
    $class=$parameterNames| Where-Object { $_ -match '^Class:' }
    $parameterNames = $parameterNames | Where-Object { $_ -notmatch '^Class:*' }
    $parmList= $parameterNames -join ','
    Write-Output "device,application,$class,$parmList" | Set-Content "$dirPath/$FileName.csv"
    Write-Host -ForegroundColor Green "Done.`nFile is: .\$FileName.csv - please move to relevant folder in \data directory to use."
    Write-Host -ForegroundColor Magenta "`nNote: Remember to add the class name to: .\devicelist.json for required devices.`n"
}elseif($FileName.StartsWith('sub-')){
    write-host "Creating AS3 Class Subtable Data File"
    $class=$FileName.Split('-')[1].Split('.')[0]
    $parmList= $parameterNames -join ','
    Write-Output "$class,$parmList" | Set-Content "$dirPath/$FileName.csv"
    Write-Host -ForegroundColor Green "Done.`nFile is: .\$FileName.csv - please move to relevant folder in \data directory to use."
    Write-Host -ForegroundColor Magenta "`nNote: You do not need to the name to: .\devicelist.json for subtables.`n"
}

