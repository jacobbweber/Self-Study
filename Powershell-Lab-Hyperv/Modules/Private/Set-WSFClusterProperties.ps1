function Set-WSFClusterProperties {
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
        $LogPath
    )

    process {
        try {
            Write-Log -Message 'Running: (FailoverClusters\Get-Cluster $ClusterName).SameSubnetThreshold = 10' -Path $LogPath -Level 'Info'
            (FailoverClusters\Get-Cluster $ClusterName).SameSubnetThreshold = 10
            Write-Log -Message 'Running: (FailoverClusters\Get-Cluster $ClusterName).CrossSubnetThreshold = 20' -Path $LogPath -Level 'Info'
            (FailoverClusters\Get-Cluster $ClusterName).CrossSubnetThreshold = 20
            Write-Log -Message 'Running: (FailoverClusters\Get-Cluster $ClusterName).CrossSubnetDelay = 2000' -Path $LogPath -Level 'Info'
            (FailoverClusters\Get-Cluster $ClusterName).CrossSubnetDelay = 2000
            Write-Log -Message 'Running: (FailoverClusters\Get-Cluster $ClusterName).RouteHistoryLength = 20' -Path $LogPath -Level 'Info'
            (FailoverClusters\Get-Cluster $ClusterName).RouteHistoryLength = 20
        } catch {
            Write-Log -Message 'There was an error adding cluster properties' -Path $LogPath -Level 'Info'
            throw $PSItem.Exception.Message
        }
    }

}