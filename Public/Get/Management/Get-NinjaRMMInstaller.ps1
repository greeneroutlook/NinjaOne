#Requires -Version 7
function Get-NinjaRMMInstaller {
    <#
        .SYNOPSIS
            Gets agent installer URL from the NinjaRMM API.
        .DESCRIPTION
            Retrieves agent installer URL from the NinjaRMM v2 API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Organisation ID
        [Parameter(Mandatory = $True)]
        [Alias('organizationID')]
        [Int]$organisationID,
        # Location ID
        [Parameter(Mandatory = $True)]
        [Int]$locationID,
        # Installer type/platform.
        [Parameter(Mandatory = $True)]
        [ValidateSet(
            'WINDOWS_MSI',
            'MAC_DMG',
            'MAC_PKG',
            'LINUX_DEB',
            'LINUX_RPM'
        )]
        [String]$installerType
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'organisationid=' parameter by removing it from the set parameters.
    if ($organisationID) {
        $Parameters.Remove('organisationID') | Out-Null
    }
    # Workaround to prevent the query string processor from adding a 'locationid=' parameter by removing it from the set parameters.
    if ($locationID) {
        $Parameters.Remove('locationID') | Out-Null
    }
    # Workaround to prevent the query string processor from adding an 'installertype=' parameter by removing it from the set parameters.
    if ($installerType) {
        $Parameters.Remove('installerType') | Out-Null
    }
    try {
        $QSCollection = New-NinjaRMMQuery -CommandName $CommandName -Parameters $Parameters
        if ($organisationID -and $locationID) {
            Write-Verbose 'Getting device from NinjaRMM API.'
            $Organisation = Get-NinjaRMMOrganisations -organisationID $organisationID
            $Location = Get-NinjaRMMLocations -organisationID $organisationID | Where-Object { $_.id -eq $locationID }
            if ($Organisation -and $Location) {
                Write-Verbose "Retrieving installer for $($Organisation.Name) - $($Location.Name) `($installerType`)."
                $Resource = "v2/organization/$($organisationID)/location/$($locationID)/installer/$($installerType)"
            }
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            QSCollection = $QSCollection
        }
        $AgentInstallerResults = New-NinjaRMMGETRequest @RequestParams
        Return $AgentInstallerResults
    } catch {
        $ErrorRecord = @{
            ExceptionType = 'System.Exception'
            ErrorRecord = $_
            ErrorCategory = 'ReadError'
            BubbleUpDetails = $True
            CommandName = $CommandName
        }
        New-NinjaRMMError @ErrorRecord
    }
}