#-------------------------------------------------------------------------------------------------------------------
#   Script:     afmFwCheckv2.ps1 - BIG-IP AFM firewall rule check
#   Version:    v2 27/11/2004 - script now uses declaration rather than data files.
#   Author:     Antony Millington
#   Comments:
#       Checks AFM firewall rules in buildAs3  for a given source/destination.
#       Mandatory Parameters:   -SourceIP; OR
#                               -SourceIP-List (a comma-separated string of IPs - produces multiple results); AND
#                               -DestinationIP; OR
#                               -DestIP-List (a comma-separated string of IPs - produces multiple results)
#
#                               -IncomingVlan (the source interface for the rule.)
#                               -Port (the destination IP port.)
#
#       Optional Parameters:    -AsCsv (output is a CSV string for collecting results for further processing).
#                               -IgnoreIPMDenyAll (ignore the deny-all rule in IPM Mode and continuing looking for rules.
#                               this is useful if you want to check rules exist but the IPM ruleset is part of the
#                               policy.)
#
#       The script needs the following files:
#           1. A csv file in the /data/<partition>/afm folder for each API Class handling the AFM:
#              Firewall_Address_List, Firewall_Port_List, Firewall_Policy, Firewall_Rule_List and the
#              rule list held in sub-firewall_rule.csv
#-------------------------------------------------------------------------------------------------------------------
param(
    [Parameter(Mandatory=$true)][string]$IncomingVlan,
    [Parameter(Mandatory=$false)][string]$SourceIP,
    [Parameter(Mandatory=$false)][string[]]$SourceIPList,
    [Parameter(Mandatory=$false)][string]$DestinationIP,
    [Parameter(Mandatory=$false)][string[]]$DestIPList,   
    [Parameter(Mandatory=$true)][string]$Port,
    [Parameter()][switch]$AsCSV,
    [Parameter()][switch]$IgnoreIPMDenyAll
) #end param

# IP Parameter Checks...
if($SourceIP -and $SourceIPList){Write-Error 'You can only specify either SourceIP OR SourceIPList.';Exit}
if($DestinationIP -and $DestIPList){Write-Error 'You can only specify either DestinationIP OR DestIPList.';Exit}
if(!($SourceIP -or $SourceIPList)){Write-Error 'You must specify either SourceIP OR SourceIPList.';Exit}
if(!($DestinationIP -or $DestIPList)){Write-Error 'You must specify either DestinationIP OR DestIPList.';Exit}
if($SourceIPList -and $SourceIPList -notmatch ','){Write-Error 'SourceIPList must be a comma delimited list.';Exit}
if($DestIPList -and $DestIPList -notmatch ','){Write-Error 'DestIPList must be a comma delimited list.';Exit}

# Check PS Version
if($PSVersionTable.PSVersion.Major -lt 7 ){Write-Error "This script requires PowerShell Core (v7 upwards)";Exit}

# Set up Directory Paths and File Locations
$dirPath=(Get-Item $PSCommandPath ).DirectoryName
$declareDir="$dirPath\declarations"

# SOURCE OF TRUTH VM NAME:
$referenceBigIP="con-prod-dm-uks-f5-001"

function IPv6InRange {
    [cmdletbinding()]
    [outputtype([System.Boolean])]
    param (
        [Parameter(Mandatory=$true)]
        [string]$IPv6Address,

        [Parameter(Mandatory=$true)]
        [string]$IPv6Range
    )

    # Helper function to convert IPv6 address to binary
    function ConvertTo-BinaryIPv6 {
        param (
            [string]$IPv6
        )

        $expandedIPv6 = ([System.Net.IPAddress]::Parse($IPv6)).GetAddressBytes()
        $binaryIPv6 = -join ($expandedIPv6 | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') })
        return $binaryIPv6
    }

    # Split the range into base address and prefix length
    $rangeParts = $IPv6Range -split "/"
    $rangeBase = $rangeParts[0]
    $prefixLength = [int]$rangeParts[1]

    # Convert the address and the base address of the range to binary
    $binaryIPv6Address = ConvertTo-BinaryIPv6 $IPv6Address
    $binaryRangeBase = ConvertTo-BinaryIPv6 $rangeBase

    # Compare the first $prefixLength bits of both binary values
    $isInRange = ($binaryIPv6Address.Substring(0, $prefixLength) -eq $binaryRangeBase.Substring(0, $prefixLength))

    return $isInRange
}


function IPInRange {
    [cmdletbinding()]
    [outputtype([System.Boolean])]
    param(
        # IP Address to find.
        [parameter(Mandatory,
                   Position=0)]
        [validatescript({ 
            ([System.Net.IPAddress]$_).AddressFamily -eq 'InterNetwork'
        })]
        [string]
        $IPAddress,

        # Range in which to search using CIDR notation. (ippaddr/bits)
        [parameter(Mandatory,
                   Position=1)]
        [validatescript({
            $IP   = ($_ -split '/')[0]
            $Bits = ($_ -split '/')[1]

            (([System.Net.IPAddress]($IP)).AddressFamily -eq 'InterNetwork')

            if (-not($Bits)) {
                throw 'Missing CIDR notiation.'
            } elseif (-not(0..32 -contains [int]$Bits)) {
                throw 'Invalid CIDR notation. The valid bit range is 0 to 32.'
            }
        })]
        [alias('CIDR')]
        [string]
        $Range
    )

    # Split range into the address and the CIDR notation
    [String]$CIDRAddress = $Range.Split('/')[0]
    [int]$CIDRBits       = $Range.Split('/')[1]

    # Address from range and the search address are converted to Int32 and the full mask is calculated from the CIDR notation.
    [int]$BaseAddress    = [System.BitConverter]::ToInt32((([System.Net.IPAddress]::Parse($CIDRAddress)).GetAddressBytes()), 0)
    [int]$Address        = [System.BitConverter]::ToInt32(([System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()), 0)
    [int]$Mask           = [System.Net.IPAddress]::HostToNetworkOrder(-1 -shl ( 32 - $CIDRBits))

    # Determine whether the address is in the range.
    if (($BaseAddress -band $Mask) -eq ($Address -band $Mask)) {
        $true
    } else {
        $false
    }
}

function getIPAddr ([string]$IPRef,[string]$lookup,[Boolean]$isSA) {
	$addressList=($json_as3.Common.Shared.PSObject.Properties |
		Where-Object { $_.Value.class -contains 'Firewall_Address_List' } |
		Where-Object { $_.Name -contains "$IPRef" }).Value
	if(!($addressList)){
        if(!($AsCsv)){Write-Warning "No reference found in Firewall_Address_List for: $IPRef"}
    }else{
        if($lookup.Contains('.')){
            Write-Debug "IP ADDRESS TYPE = IPV4"
            foreach($addrElement in $addressList.addresses){
                if(!($addrElement.Contains('.'))){
                    Write-Debug "Not checking rule: $addrElement as it is ipv6"
                }else{
                    if(!($addrElement.Contains('/'))){
                        $addrElement=$addrElement + '/32'
                    }
                    # check for a default rule 0.0.0.0/0 as this will match anything
                    if($addrElement -eq "0.0.0.0/0"){
                        # check if rulelist is the IPM rule list and if we want to ignore the deny-all here:
                        if($ruleListItem -match 'IPM_MODE') {
                            if(!($IgnoreIPMDenyAll)) {
                                Write-Debug "      ++ getIPAddr returns TRUE - $lookup is within subnet: $addrElement"
                                if($isSA){$global:match["sa"] = $addrElement}else{$global:match["da"] = $addrElement}
                                return $true
                            }
                        }else{
                            Write-Debug "      ++ getIPAddr returns TRUE - $lookup is within subnet: $addrElement"
                            if($isSA){$global:match["sa"] = $addrElement}else{$global:match["da"] = $addrElement}
                            return $true
                        }
                    } 
                    elseif(IPInRange $lookup $addrElement){
                        Write-Debug "      ++ getIPAddr returns TRUE - $lookup is within subnet: $addrElement"
                        if($isSA){$global:match["sa"] = $addrElement}else{$global:match["da"] = $addrElement}
                        return $true
                    }else{
                        Write-Debug "      ++ getIPAddr returns FALSE - $lookup is not within subnet: $addrElement"
                    }
                }
            }
        }elseif($lookup.Contains(':')){
            Write-Debug "IP ADDRESS TYPE = IPV6"
            foreach($addrElement in $addressList.addresses){
                if(!($addrElement.Contains(':'))){
                    Write-Debug "Not checking rule: $addrElement as it is ipv4"
                }else{                
                    if(!($addrElement.Contains('/'))){
                        $addrElement=$addrElement + '/128'
                    }
                    if(IPv6InRange -IPv6Address $lookup -IPv6Range $addrElement){
                        Write-Debug "      ++ getIPAddr returns TRUE - $lookup is within subnet: $addrElement"
                        if($isSA){$global:match["sa"] = $addrElement}else{$global:match["da"] = $addrElement}
                        return $true
                    }else{
                        Write-Debug "      ++ getIPAddr returns FALSE - $lookup is not within subnet: $addrElement"
                    }
                }
            }
        }else{
            Write-Error "Unknown Address Format for Source Address - must be dotted decimal (ipv4) or colon-separated (ipv6)."
            exit
        } 
    }
}

function getPort ([string]$PortRef,[string]$lookup) {
    $portList=($json_as3.Common.Shared.PSObject.Properties |
		Where-Object { $_.Value.class -contains 'Firewall_Port_List' } |
		Where-Object { $_.Name -contains "$PortRef" }).Value
    foreach($portElement in $($portList.ports)){
        if($portElement -eq $lookup){
            $global:match["port"] = $portElement
            return $true
        }
    }
}

function parseFirewallRules {
    foreach($rule in $rules){
        Write-Debug "`nChecking rule: $($rule.name)"
		foreach($origAL in $rule.source.addressLists.use){
            Write-Debug "   + Checking Source Address-List Name: $origAL for Source IP: $SourceIP"
            if(getIPAddr $origAL $SourceIP $true){
                $global:match["level"] = 1
                $global:match["saName"] = $origAL
                $global:matchedRule=$rule
                Write-Debug "   + Match on SOURCE ADDRESS"
                if($rule.source.vlans -eq $IncomingVlan){
                    Write-Debug "   + Match on INCOMING VLAN"
                    foreach($destAL in $rule.destination.addressLists.use){
                        Write-Debug "   + Checking Destination Address-List Name: $destAL"
                        if(getIPAddr $destAL $DestinationIP $false){
                            Write-Debug "   + Match on DESTINATION ADDRESS"
                            $global:match["daName"] = $destAL
                            if(!($rule.destination.portLists.use)){
                                Write-Debug "   + Destination Port is ANY"
                                $global:match["level"] = 4
                                $global:match["portName"] = 'ANY'
                                return
                            }
                            foreach($portName in $rule.destination.portLists.use){
                                Write-Debug "   + Checking Destination Port Name: $portName"
                                if(getPort $portName $Port){
                                    Write-Debug "   + Match on PORT: $portName"
                                    $global:match["level"] = 4
                                    $global:match["portName"] = $portName
                                    return
                                }else{
                                    $global:match["level"] = 3
                                }
                            }
                        }
                    }
                }else{
                    $global:match["level"] = 2
                }
            }
        }
    }
}

function ExecutePolicySearch {
    foreach($ruleListItem in  $activeRuleList){
        # There may be multiple rulesets against a policy, so we need to loop this in order
        if(!($AsCsv)){Write-Host "   Checking Rule List : $ruleListItem..."}
		$rules=$json_as3.Common.Shared.$ruleListItem.rules
        $global:match = @{}
        $global:match.level=0
        parseFirewallRules
        Write-Debug "Resultant Match value is: $($global:match.level)"
        if($global:match.level -eq 4){Break}
    }
}

function returnSearchResults {
    Switch ($global:match.level){
        0 {
            if(!($AsCsv)){
                Write-Host -ForegroundColor Red "`nNo Matching Rule was found for the Source/Destination.`n"
            }else{
                Write-Output "$SourceIP,$DestinationIP,$Port,nomatch-rule"
            }
        }
        1 {
            if(!($AsCsv)){
                Write-Host -ForegroundColor Red "`nNo Match."
                Write-Host -ForegroundColor Yellow "Nearest match was rule: $($global:matchedRule.name) - which matched the Source IP but not the Destination IP.`n"
            }else{
                Write-Output "$SourceIP,$DestinationIP,$Port,nomatch-destip,$($global:matchedRule.name),$($global:match.sa),nomatch-da"
            }
        }
        2 {
            if(!($AsCsv)){
                Write-Host -ForegroundColor Red "`nNo Match."
                Write-Host -ForegroundColor Yellow "Nearest match was rule: $($global:matchedRule.name) - which matched the Source IP but not the incoming Vlan.`n"
            }else{
                Write-Output "$SourceIP,$DestinationIP,$Port,nomatch-vlan"
            }
        }
        3 { 
            if(!($AsCsv)){
                Write-Host -ForegroundColor Red "`nNo Match."
                Write-Host -ForegroundColor Yellow "Nearest match was rule: $($global:matchedRule.name) - which matched the Source and Destination IP but not the Port.`n"
            }else{
                Write-Output "$SourceIP,$DestinationIP,$Port,nomatch-port,$($global:matchedRule.name),$($global:match.sa),$($global:match.da),nomatch-port"
            } 
        }
        4 {
            if(!($AsCsv)){
                Write-Host -ForegroundColor Green "`nMatch Found"
                Write-Host "- Rule List  : "$ruleListItem
                Write-Host "- Rule       : "$global:matchedRule.name
                if(!($global:matchedRule.source.vlans)){
                    Write-Host "   + I/face   : ANY"
                }else{
                    Write-Host "   + I/face   :"$global:matchedRule.source.vlans
                }
                Write-Host "   + Source   :"$global:match.sa"  ($($global:match.saName))"
                Write-Host "   + Dest     :"$global:match.da"  ($($global:match.daName))"
                Write-Host "   + Protocol :"$($global:matchedRule.protocol).ToUpper()
                Write-Host "   + Port     :"$global:match.port"  ($($global:match.portName))"
                Write-Host "- Action : $($global:matchedRule.action)`n"
            }else{
                if($global:matchedRule.name -eq "default-deny-all") {
                    # we have found a match, but only with the default deny-all rule! So we need to ensure we don't actually say this is a match
                    Write-Output "$SourceIP,$DestinationIP,$Port,default,$($global:matchedRule.name),$($global:match.sa),$($global:match.da),$($global:match.port),$($global:matchedRule.action)"
                }else{
                    Write-Output "$SourceIP,$DestinationIP,$Port,match,$($global:matchedRule.name),$($global:match.sa),$($global:match.da),$($global:match.port),$($global:matchedRule.action)"
                }
            }
        } 
    }
}

# get json declaration from VM001
$json_as3=(Get-Content $declareDir\$referenceBigIP\$referenceBigIP.as3.Common.json | ConvertFrom-Json).declaration

$global:match=0
$policy_name=($json_as3.Common.Shared.PSObject.Properties | Where-Object { $_.Value.class -contains 'Firewall_Policy' }).Name
$policy=($json_as3.Common.Shared.PSObject.Properties | Where-Object { $_.Value.class -contains 'Firewall_Policy' }).Value
Write-Debug POLICY=$policy_name
$activeRuleList=$policy.rules.use
if(!($AsCsv)){Write-Host "`nPolicy is    : $policy_name"}
if(!($AsCsv)){Write-Host "Policy RuleList is  : $activeRuleList"}

# get all Vlans across all rulelists to check input
$allRules=($json_as3.Common.Shared.PSObject.Properties | Where-Object { $_.Value.class -contains 'Firewall_Rule_List' }).Value
$allowedVlans=$allRules.rules.source.vlans | Sort-Object -Unique
Write-Debug "Allowed Vlans are: $allowedVlans"
if(!($allowedVlans -match $IncomingVlan)){
    Write-Host -ForegroundColor Red "Error: IncomingVlan must be one of: $allowedVlans`n"
    exit
}

if($SourceIPList){
    foreach($SourceIP in $SourceIPList -split(',')) {
        if($DestIPList){
            foreach($DestinationIP in $DestIPList -split(',')) {
                ExecutePolicySearch
                returnSearchResults
            }
        }else{
            ExecutePolicySearch
            returnSearchResults
        }
    }
}else{
    if($DestIPList){
        foreach($DestinationIP in $DestIPList -split(',')) {
            ExecutePolicySearch
            returnSearchResults
        }
    }else{
        ExecutePolicySearch
        returnSearchResults
    }
}