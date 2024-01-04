function Confirm-WSFCPSModule {
    <#
    .SYNOPSIS
        Determine if the FailoverClusters Powershell module is available
    .DESCRIPTION
        This Function will determine if the FailoverClusters Powershell module is available. 
        It will first check if the module is installed. If it is not, it will throw a terminating error.
        If it is It will then check if it is imported. If it is not, it will attempt to import it.
        If it is unable to import it, it will throw a terminating error
    .EXAMPLE
        Confirm-WSFCPSModule -LogPath c:\yourloglocation\yourlogname.log
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogPath
    )

    process {
        if (-Not(Get-Module -ListAvailable -Name 'FailoverClusters')) {
            Write-Log -Message 'Unable to find the Unable to find the FailoverClusters module, Please install the windows failover cluster tools from roles and features.' -Path $LogPath -Level 'Error'
            throw $PSItem.Exception.Message
        } else {
            if (-Not(Get-Module -Name 'FailoverClusters')) {
                try {
                    Write-Log -Message 'Found the FailoverClusters module, running Import-Module FailoverClusters' -Path $LogPath -Level 'Info'
                    Import-Module -Name 'FailoverClusters' -ErrorAction 'Stop'
                } catch {
                    Write-Log -Message 'There was an error running Importing-Module' -Path $LogPath -Level 'Error'
                    throw $PSItem.Exception.Message
                }
            } else {
                Write-Log -Message 'The module is already imported' -Path $LogPath -Level 'Info'
            }
        }
    }
}