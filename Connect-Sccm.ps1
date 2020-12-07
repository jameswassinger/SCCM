fuction Connect-Sccm {
    <#
    .SYNOPSIS
        Establishes a connection to Configuration Manager. 

    .DESCRIPTION
        Establishes a connection to Configuration Manager.

    .PARAMETER SiteCode
        Represents identification and status data for a Configuration Manager site installation.

    .PARAMETER ProviderMachineName
        SMS Provider machine name, server name hosting Configuration Manager instance. 

    .EXAMPLE
        .\Connect-Sccm -SiteCode XYZ -ProviderMachineName "SER01.contoso.com"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$SiteCode,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ProviderMachineName
    )

    # Uncomment the line below if running in an environment where script signing is 
    # required.
    #Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

    # Customizations
    $initParams = @{}
    #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
    #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

    # Do not change anything below this line

    # Import the ConfigurationManager.psd1 module 
    if ((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
    }

    # Connect to the site's drive if it is not already present
    if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Set the current location to be the site code.
    Set-Location "$($SiteCode):\" @initParams

}



