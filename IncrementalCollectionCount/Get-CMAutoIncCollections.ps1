# state the path and file name where you would like to store the output. 
# file is written to csv. 
Param ( [string]$Path )

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5)+ '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

# The following refresh types exist for ConfigMgr collections
# 6 = Incremental and Periodic Updates
# 4 = Incremental Updates Only
# 2 = Periodic Updates only
# 1 = Manual Update only

$refreshtypes = "4","6"

# Get the collections from sccm
$CollectionsWithIncrement = Get-CMDeviceCollection | Where-Object {$_.RefreshType -in $refreshtypes}

# Store the collections with the "use incremental updates for this collection" option enabled. 
$Collections = @()

# Add device collection names to the collections array. 
foreach ($collection in $CollectionsWithIncrement) {
    $object = New-Object -TypeName PSobject
    $object| Add-Member -Name CollectionName -value $collection.Name -MemberType NoteProperty
    #$object| Add-Member -Name CollectionID -value $collection.CollectionID -MemberType NoteProperty
    #$object| Add-Member -Name MemberCount -value $collection.LocalMemberCount -MemberType NoteProperty
    $collections += $object
}

# get total count found. 
$total = $Collections.Count

# immediately display the count of collections with the option enabled. 
Write-Host "`n`nFound $total Collections with the auto incremental checked.`n`n"

# Write the collections names to a file. 
$Collections | Export-Csv $Path -NoTypeInformation