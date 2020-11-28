# Specify the path where the csv of collections names is stored. 
# Specify the date you would like the schedule to start. Ex. "09/27/2018 9:00 AM"
Param (
[string]$Path
)

#Load Configuration Manager PowerShell Module
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5)+ '\ConfigurationManager.psd1')

#Get SiteCode
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-location $SiteCode":"

# Read the collection names from the file. 
$CollectionNames = Get-Content -Path $Path

# Keeps count of processed collections
$count = 0

# Change the collection schedule. 
foreach($collection in $CollectionNames) {
    Write-Host "Applying new settings to $collection"
    $Date = Get-Date -Format g
    $Schedule = New-CMSchedule -Start $Date -RecurInterval Days -RecurCount 1  
    Set-CMDeviceCollection -Name $collection -RefreshType Periodic -RefreshSchedule $Schedule
    $count += 1      
}

# Write out how many collections the script disable the "use incremental updates for this collection" option for.
Write-Host "Set new schedule for $count device(s)" 
