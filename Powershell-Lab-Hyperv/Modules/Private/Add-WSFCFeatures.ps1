function Add-WSFCFeatures {
    <#
    .SYNOPSIS
        Add the FailoverClusters roles and features.
    .DESCRIPTION
        This function will add the server roles,features, and management tools required by a windows server failover cluster.
        This function will also automatically supply the reboot parameter if a reboot is required after installing the features.
        Use this with caution as a reboot will happen automatically if needed.
    .EXAMPLE
        Add-WSFCFeatures -ComputerName 'Server1','Server2' -Confirm:$true
    .EXAMPLE
        Add-WSFCFeatures -ComputerName 'Server1','Server2' -Confirm:$true -LogPath c:\yourloglocation\yourlogname.log
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
                Write-Log -Message 'Running Install-WindosFeature for Failover-Clustering including managementtools' -Path $LogPath -Level 'Info'
                Install-WindowsFeature -ComputerName $i -Name 'Failover-Clustering' -IncludeManagementTools -Restart -ErrorAction 'Stop'
            } Catch {
                Write-Log -Message 'Unable to add WindowsFeatures' -Path $LogPath -Level 'Error'
                throw $PSItem.Exception.Message
            }
        }
    }
}