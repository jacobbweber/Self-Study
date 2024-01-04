function New-ACtiveDirectory {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION

https://blogs.technet.microsoft.com/uktechnet/2016/06/08/setting-up-active-directory-via-powershell/

Commands to Promote Server as Domain Controller
Now, you will need to need to promote your server to a domain controller as per your requirements - there are several commands that you can use to do this. I will provide a list and description so that you can figure out which one best suits your needs. However, for this article, we are going to use the Install-ADDSForest command.

Command	Description
Add-ADDSReadOnlyDomainControllerAccount	Install read only domain controller
Install-ADDSDomain	Install first domain controller in a child or tree domain
Install-ADDSDomainController	Install additional domain controller in domain
Install-ADDSForest	Install first domain controller in new forest
Test-ADDSDomainControllerInstallation	Verify prerequisites to install additional domain controller in domain
Test-ADDSDomainControllerUninstallation	Uninstall AD services from server
Test-ADDSDomainInstallation	Verify prerequisites to install first domain controller in a child or tree domain
Test-ADDSForestInstallation	Install first domain controller in new forest
Test-ADDSReadOnlyDomainControllAccountCreation	Verify prerequisites to install read only domain controller
Uninstall-ADDSDomainController	Uninstall the domain controller from server
    .EXAMPLE
        Example of how to use this cmdlet
    .EXAMPLE
        Another example of how to use this cmdlet
    #>

    [CmdletBinding()]
    param (
        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DatabasePath,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DomainMode,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DomainName,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $DomainNetbiosName,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ForestMode,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ADLogPath,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SysvolPath,

        [parameter(Mandatory = $True, ParameterSetName = 'Json')]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $ActiveDirectoryDefinition,

        [parameter(Mandatory = $True, ParameterSetName = 'Json')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential

    )


    process {

        if ($PSCMDlet.ParameterSetName -eq 'Json') {
            $DC1 = $ActiveDirectoryDefinition.DC1
            $DC2 = $ActiveDirectoryDefinition.DC2
            $DatabasePath = $ActiveDirectoryDefinition.DatabasePath
            $DomainMode = $ActiveDirectoryDefinition.DomainMode
            $DomainName = $ActiveDirectoryDefinition.DomainName
            $DomainNetbiosName = $ActiveDirectoryDefinition.DomainNetbiosName
            $ForestMode = $ActiveDirectoryDefinition.ForestMode
            $LogPath = $ActiveDirectoryDefinition.LogPath
            $SysvolPath = $ActiveDirectoryDefinition.SysvolPath
            $SafeModeAdministratorPassword = $ActiveDirectoryDefinition.SafeModeAdministratorPassword
        }

        $ADDSARGS = @{
            SkipPreChecks                 = $true
            SafeModeAdministratorPassword = $SafeModeAdministratorPassword | ConvertTo-SecureString -AsPlainText -Force
            CreateDnsDelegation           = $false
            DatabasePath                  = $DatabasePath
            DomainMode                    = $DomainMode
            DomainName                    = $DomainName
            DomainNetbiosName             = $DomainNetbiosName
            ForestMode                    = $ForestMode
            InstallDns                    = $true
            LogPath                       = $LogPath
            NoRebootOnCompletion          = $false
            SysvolPath                    = $SysvolPath
            Force                         = $true
        }

        Invoke-Command -VMName 'sp1-labdc1' -ScriptBlock {
            $null = Install-ADDSForest @Using:ADDSARGS
        } -Credential $Credential
        #$ADDSARGS
    }

    end {
        Exit-PSSession
    }
}