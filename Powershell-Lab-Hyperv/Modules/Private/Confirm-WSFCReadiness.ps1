function Confirm-WSFCRediness {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ComputerName,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogPath

    )

    process {
        foreach ($i in $ComputerName) {
            try {
                Write-Log -Message "Running Test-Cluster on $i" -Path $LogPath -Level 'Info'
                FailoverClusters\Test-Cluster -Node $i -ErrorAction 'Stop'
            } catch {
                Write-Log -Message 'There was an error running Test-Cluster' -Path $LogPath -Level 'Error'
                throw $PSItem.Exception.Message
            }
        }
    }
}