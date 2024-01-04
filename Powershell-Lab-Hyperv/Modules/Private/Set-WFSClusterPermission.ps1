function Set-WFSClusterPermission {
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
        [string[]]
        $Listeners,

        [parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogPath
    )

    process {
        try {
            Write-Log -Message "Running Get-Acl on $ClusterName" -Path $LogPath -Level 'Info'
            ###set cluster virtual computer object permissions on listener device(s)###
            $ACL = Get-Acl "ad:CN=$ClusterName,OU=Comp Service Accounts,DC=willywonka,DC=com"
            $ACL.Access | Out-Null #to get access right of the object
            $Computer = Get-ADComputer -Identity "$ClusterName"
            $SID = [System.Security.Principal.SecurityIdentifier]$Computer.SID
            ###Create a new access control entry to allow access to the object

            $Identity = [System.Security.Principal.IdentityReference]$SID
            $ADRights = [System.DirectoryServices.ActiveDirectoryRights] 'GenericAll'
            $Type = [System.Security.AccessControl.AccessControlType] 'Allow'
            $InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] 'All'
            $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $Identity, $ADRights, $Type, $InheritanceType

            foreach ($i in $Listeners) {
                ##check for new listerner computer. This is for troubleshooting and should not be needed long term.
                ##there is an issue where Set-Acl below is unable to find the computer object, sometimes even after
                ##this is successful, so a delay doesnt seem responsible just yet.
                try {
                    Get-ADComputer -Identity $i -ErrorAction 'stop'
                } catch {
                    Start-Sleep 60
                }

                ###Add the ACE to the ACL, then set the ACL to save the changes
                try {
                    $ACL.AddAccessRule($ACE)
                    Set-Acl -AclObject $ACL "ad:CN=$i, OU=Comp Service Accounts, DC=willywonka, DC=com" -ErrorAction 'Stop'
                } catch {
                    Write-Warning -Message 'Unable to Set ACL on listener'
                }
            }

        } catch {
            Write-Log -Message 'There was an error running Set-Acl' -Path $LogPath -Level 'Info'
            throw $PSItem.Exception.Message
        }
    }

}