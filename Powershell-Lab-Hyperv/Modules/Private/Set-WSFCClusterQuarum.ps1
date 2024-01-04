function Set-WSFClusterQuorum {
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
        [string]
        $ClusterName,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $WitnessPath,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogPath
    )

    process {
        try {
            Write-Log -Message 'Running Set-ClusterQuorum' -Path $LogPath -Level 'Info'
            FailoverClusters\Set-ClusterQuorum -Cluster $ClusterName -FileShareWitness $WitnessPath -ErrorAction 'Stop'
        } catch {
            Write-Log -Message 'There was an error running Set-ClusterQuorum' -Path $LogPath -Level 'Info'
            throw $PSItem.Exception.Message
        }
    }
}