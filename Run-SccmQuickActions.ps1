<#
    .SYNOPSIS

    Quickly complete routine SCCM administrative actions.

    .DESCRIPTION
    
    Quickly complete routine SCCM administrative actions. 

    .EXAMPLE
    
    .\Run-SCCMQuickActions.ps1 -ComputerName COM1 -Delete

    .EXAMPLE

    .\Run-SCCMQuickActions.ps1 -CollectionName "Test1" -Delete


#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$true, 
    ParameterSetName="Computer",
    HelpMessage="Accepts a single computer name or multiple computer name seperated by a ','")]
    [Alias("CN","MachineName")]
    [ValidateNotNull()]
    [String[]]$ComputerName,

    [Parameter(Mandatory=$false, 
    ParameterSetName="CollectionName")]
    [ValidateNotNull()]
    [String[]]$CollectionName,

    [Parameter(Mandatory=$false)]
    [Switch]$Delete, 

    [Parameter(Mandatory=$false)]
    [Switch]$Add

)    

function Delete-Computer {
    param(
        [Parameter(Mandatory=$true)]
        [String[]]$ComputerName
    )

    $ComputerName | ForEach-Object {
        # exists
        if(Get-CMDevice -Name $_) {
            Write-Information -MessageData "$($_) exists in SCCM, Queued for removal" -InformationAction Continue
            
            # Removal
            try {
                Remove-CMDevice -Name $_ -Force
            } catch {
                Write-Warning "Could not removed $($_). Details $($_.Exception.Message)"
            }

            Write-Information -MessageData " Validation of removal for $($_)..." -InformationAction Continue

            # validation
            try {
                if(Get-CMDevice -Name $_) {
                    Write-Warning "$($_) was NOT removed from SCCM."
                } else {
                    Write-Host "$($_) was successfully removed from SCCM." -ForegroundColor Green
                }
            } catch {
                Write-Warning "$($_) could not be removed. Exception Detail $($_.Exception.Message)"
            }
        
        # no exist
        } else {
            Write-Warning "$($_) could not be found."
        }
    }
}

function Delete-Collection {
    param(
        [Parameter(Mandatory=$true,
         HelpMessage="The * wildcard character is accpeted.")]
        [String[]]$CMCollectionName
    )

    # Removal
    $CMCollectionName | ForEach-Object {
        if(Get-CMCollection -Name $CMCollectionName) {
            Write-Information -MessageData "The collection $($_.Name) exists in SCCM, Queued for removal" -InformationAction Continue
            try {
                Remove-CMCollection -Name $_ -Force
            } catch {
                Write-Warning "Collection $($_) could not be removed. Exception Detail $($_.Exception.Message)"
            }
            Write-Information -MessageData " Validation of removal for collection $($_)..." -InformationAction Continue
            try {
                if(Get-CMCollection -Name $_) {
                    Write-Warning "Collection $($_) was NOT removed from SCCM."
                } else {
                    Write-Host "Collection $($_) was successfully removed from SCCM." -ForegroundColor Green
                } 
            } catch {
                Write-Warning "Collection $($_) could not be removed. Exception Detail $($_.Exception.Message)"
            }
        # no exists
        } else {
            Write-Warning "Collection $($_) could not be found"   
        }
      }
}

<#
    remove default errors from showing. 
    This will allow for readable custom error use.
#>
$debug = $true # set to false for prod usage. 
if(!($debug)) {
    $ErrorActionPreference = "SilentlyContinue"
}

#region SCCM connection information
try {
    # Uncomment the line below if running in an environment where script signing is 
    # required.
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

    # Site configuration
    $SiteCode = "NEB" # Site code 
    $ProviderMachineName = "sccm01.stone.ne.gov" # SMS Provider machine name

    # Customizations
    $initParams = @{}
    #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
    #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

    # Do not change anything below this line

    # Import the ConfigurationManager.psd1 module 
    if((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    # Connect to the site's drive if it is not already present
    if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams
} catch {
    Write-Error "Unable to connect to SCCM. Details $($_.Exception.Message)"
}

function Create-CMCollection {


}

#endregion

# region MAIN

# Delete actions
if($Delete.IsPresent) {

    if($ComputerName) {
        Delete-Computer -ComputerName $ComputerName
    }

    if($CollectionName) {
        Delete-Collection -CMCollectionName $CollectionName
    }
}

#endregion MAIN


<# 
    sets location back to the script directory, 
    so that the NEB path is not left on the console.
#>
Set-Location -Path $PSScriptRoot