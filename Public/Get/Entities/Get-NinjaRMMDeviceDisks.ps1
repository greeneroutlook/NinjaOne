#Requires -Version 7
function Get-NinjaRMMDeviceDisks {
    <#
        .SYNOPSIS
            Gets device disks from the NinjaRMM API.
        .DESCRIPTION
            Retrieves device disks from the NinjaRMM v2 API.
        .OUTPUTS
            A powershell object containing the response.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Uses dynamic parameter parsing.')]
    Param(
        # Device ID
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [Alias('id')]
        [Int]$deviceID
    )
    $CommandName = $MyInvocation.InvocationName
    $Parameters = (Get-Command -Name $CommandName).Parameters
    # Workaround to prevent the query string processor from adding an 'deviceid=' parameter by removing it from the set parameters.
    if ($deviceID) {
        $Parameters.Remove('deviceID') | Out-Null
    }
    try {
        $QSCollection = New-NinjaRMMQuery -CommandName $CommandName -Parameters $Parameters
        if ($deviceID) {
            Write-Verbose 'Getting device from NinjaRMM API.'
            $Device = Get-NinjaRMMDevices -deviceID $deviceID
            if ($Device) {
                Write-Verbose "Retrieving disk drives for $($Device.SystemName)."
                $Resource = "v2/device/$($deviceID)/disks"
            }
        }
        $RequestParams = @{
            Method = 'GET'
            Resource = $Resource
            QSCollection = $QSCollection
        }
        $DeviceDiskResults = New-NinjaRMMGETRequest @RequestParams
        Return $DeviceDiskResults
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