#Requires -Version 5.1
<#
 .Synopsis
    Takes a list of computer names and auto generates a query to use with an sccm collection.

 .Description
    Auto generates a query that can be used with an sccm collection.

 .Parameter Path
    -Path
     Sets path to list of computer names.

.Parameter ComputerName
    Sets ComputerName to use in query

 .Example

   Format-SystemListQuery.ps1 -Path "C:\MyCollectionList.txt"

   Generated query to the console screen. You can copy all the text presented inbetween the START and END lines.

.Example
   Format-SystemListQuery.ps1 -ComputerName COM1,COM2,COM3 | Out-File C:\Temp\SystemNameQuery.txt

   Creates the query using the ComputerName provided and outputs the query to the txt path provided.

.Example
   Format-SystemListQuery.ps1 -Path C:\computers.txt | Out-File C:\GeneratedList.txt

   Creates the query using the ComputerName provided in the specified txt file and outputs the results to the provide txt file path.
#>
[CmdletBinding()]
Param(

    [Parameter()]
    [String]$Path,

    [Parameter()]
    [String[]]$ComputerName
)

function ConvertTo-Query {

<#
.SYNOPSIS
    Converts given formatted String data into query statement.

.DESCRIPTION
    Converts given formatted String data into query statement.

.PARAMETER formattedStr
    Sets the formated string array to be converted into a query string.

.EXAMPLE
    .\ConvertTo-Query -FormattedStr $ComputerName
#>

Param(
        [Parameter(Mandatory,
        ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $formattedStr
    )

    if(![String]::IsNullOrEmpty($formattedStr)) {

        $query = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,
                  SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_SYSTEM on SMS_G_System_SYSTEM.ResourceID = SMS_R_System.ResourceId where SMS_G_System_SYSTEM.Name
                  in ($([string]$formattedStr))"

    } else {
        Write-Host "The -FormattedString parameter cannot be NULL or EMPTY. Try Again!" -ForegroundColor Yellow
    }

    Write-Output $query

}


function Format-ComputerName {

<#
.SYNOPSIS
    Formats a given string array of data to special formatting.

.DESCRIPTION
    Formats a given string array of data to special formatting.

.PARAMETER ComputerName
    Sets the string array of data to be formatted

.EXAMPLE
    .\Format-ComputerName -ComputerName $StringArray
#>

   Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [String[]]
        $ComputerName
    )

    $format = @()

    if(!([String]::IsNullOrEmpty($ComputerName))) {

        $ComputerName | ForEach-Object {

            if($_ -ne $ComputerName[-1]) {

                $format += '"' + $_ + '",'
            } else {
                $format += '"' + $_ + '"'
            }
        }

    } else {
        Write-Host "The -ComputerName parameter cannot be NULL or EMPTY. Try Again!" -ForegroundColor Yellow
    }

    Write-Output $format
}

function Convert-FileContent {

<#
.SYNOPSIS
    Convert files content to string arrary after validation of path.

.DESCRIPTION
    Convert files content to string arrary after validation of path.

.PARAMETER Path
    Sets path of file to convert.

.EXAMPLE
    .\Convert-FileContent -Path C:\Temp\Sample.txt
#>
    Param(
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
        [String]
        $Path
    )


if((Test-Path -Path $Path)) {
    $list = Get-Content -Path $Path
} else {
    Write-Host "The path provided $Path does not exist."
}

    Write-Output $list
}

$formatted = $null
if($Path) {
    if ((Test-Path -Path $Path)) {
        $content = Convert-FileContent $Path
        $formatted = Format-ComputerName -ComputerName $content
    }
    else {
        Write-output "`nThe file path you provide to -Path contains an error or does not exist. Please recheck the file path." -ForegroundColor Red
    }
}

if($ComputerName) {
    $formatted = Format-ComputerName -ComputerName $ComputerName
}

if($null -ne $formatted) {
    $query = ConvertTo-Query -formattedStr $formatted
    $query
} else {
        Write-Output "No format string was provided."
}


