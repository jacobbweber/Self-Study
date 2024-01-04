function Start-LabCreation {
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
        $JsonFile
    )

    begin {
        #Vars
        $BluePrint = Get-Content $JsonFile | ConvertFrom-Json

        #$ApplicationName = $BluePrint.build.EnvironmentInformation.ApplicationName
        #$DRTier = $BluePrint.build.EnvironmentInformation.DRTier
        #$Subnet = $BluePrint.build.EnvironmentInformation.Subnet
        $Gateway = $BluePrint.build.EnvironmentInformation.Gateway
        $DNS1 = $BluePrint.build.EnvironmentInformation.DNS1
        $DNS2 = $BluePrint.build.EnvironmentInformation.DNS2
        #$Regions = $BluePrint.build.EnvironmentInformation.Regions

        $pass = 'Titl@pn!' | ConvertTo-SecureString -AsPlainText -Force
        $Cred = New-Object System.Management.Automation.PsCredential('admin', $pass)

        $domainCred = New-Object -TypeName System.Management.Automation.PSCredential `
            -ArgumentList "$($BluePrint.build.ActiveDirectory.DomainName)\admin", (ConvertTo-SecureString 'Titl@pn!' -AsPlainText -Force)

        $newdomainuserpass = 'Titl@pn!'
    }

    process {

        foreach ($Region in $BluePrint.build.EnvironmentInformation.Regions.psobject.Properties | Where-Object { $_.value -eq 'yes' }) {

            $Region = $Region.Name

            $Prefix = Get-RegionPrefix -Region $Region

            ##########################
            ##    SERVER BUILDS    ###
            ##########################

            $BluePrint.build.servers | ForEach-Object {

                $args = @{
                    VM                 = $Prefix + $_.VM
                    MemoryStartUpBytes = $_.MemoryStartUpBytes
                    MemoryMinimumBytes = $_.MemoryMinimumBytes
                    MemoryMaximumBytes = $_.MemoryMaximumBytes
                    NewVHDSizeBytes    = $_.NewVHDSizeBytes
                    ProcessorCount     = $_.ProcessorCount
                    # DC1                = $_.DC1
                    # DC1DMZ             = $_.DC1DMZ
                    # DC2                = $_.DC2
                    # DC2DMZ             = $_.DC2DMZ
                    # Role               = $_.Role
                    Region             = $Region
                    RootHyperVVMPath   = $BluePrint.build.GlobalDefaults.RootHyperVVMPath
                    ISOPath            = $BluePrint.build.GlobalDefaults.ISOPath
                }

                #$args | ft

                $null = New-Server @args

                #Write-Verbose -Message "Would run Start-ServerBuild -VM $($_.VM) -MemoryStartUpBytes $($_.OS) -mem $($_.mem) -DMZ $($_.DMZ) -SQL $($_.SQL)"
            }
        } #end region foreach loop


        ##########################
        ##    SERVER Waiting and IPing...ugh   ##
        ##########################

        foreach ($Region in $BluePrint.build.EnvironmentInformation.Regions.psobject.Properties | Where-Object { $_.value -eq 'yes' }) {

            $Region = $Region.Name

            $Prefix = Get-RegionPrefix -Region $Region

            $BluePrint.build.servers | ForEach-Object {
                $VM = $Prefix + $_.VM
                #Some kind of condition to proceed based on the results of server builds finished, and finished successfully before continuing
                do {
                    Start-Sleep 30
                    Write-Verbose -Message "Looping through provisioned VMS until they are available, doing $VM now"
                } until (Invoke-Command -VMName $VM -ScriptBlock { Get-Service w32time } -Credential $Cred -ErrorAction SilentlyContinue);

                Write-Verbose -Message "disconnecting iso on $VM"
                $null = Get-VM $VM | Get-VMDvdDrive | Set-VMDvdDrive -Path $null

                #Static IP Address Assignments
                Write-Verbose -Message "Setting Nic IP Address on $VM"
                $null = Invoke-Command -VMName $VM -Credential $Cred -ScriptBlock {
                    param ($IP, $Gateway, $DNS1, $DNS2)
                    $InterfaceIndex = Get-NetIPInterface -Dhcp Enabled | Select-Object -First 1
                    New-NetIPAddress -InterfaceIndex $InterfaceIndex.ifIndex -IPAddress $ip -PrefixLength 24 -DefaultGateway $Gateway
                    if ($env:COMPUTERNAME -eq 'sp1-labdc1') {
                        Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex.ifIndex -ServerAddresses ($DNS2, $DNS1)
                    } else {
                        Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex.ifIndex -ServerAddresses ("$($DNS1)", "$($DNS2)")
                    }
                    Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
                    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
                } -ArgumentList $_.ip, $Gateway, $dns1, $dns2
            } #end server loop
        } #end region loop

        ##########################
        ##    Active Directory  ##
        ##########################
        if ($BluePrint.build.ActiveDirectory.ActiveDirectoryAutomation -eq 'Yes') {
            $VM = 'sp1-labdc1'
            Write-Verbose -Message 'Imporing Active Directory module and installing features'
            try {
                $null = Invoke-Command -VMName $VM -ScriptBlock {
                    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
                    Import-Module ADDSDeployment
                } -Credential $Cred
            } catch {
                $_
            }

            $null = New-ActiveDirectory -ActiveDirectoryDefinition $BluePrint.build.ActiveDirectory -Credential $Cred
            #Install-ADDSDomainController -DomainName "lab.hinchley.net" -InstallDns:$true -Credential (Get-Credential) -Confirm:$false

            #Loop until new ad is up
            do {
                $VMStatus = Get-VM -VMName $VM | Select-Object Name, State, Status
                $VMIntegrationStatuHeartbeat = Get-VMIntegrationService -VMName $VM -Name Heartbeat
                $VMIntegrationStatuGuest = Get-VMIntegrationService -VMName $VM -Name 'Guest Service Interface'
                $VMIntegrationStatuKey = Get-VMIntegrationService -VMName $VM -Name 'Key-Value Pair Exchange'
                $VMIntegrationStatuShutdown = Get-VMIntegrationService -VMName $VM -Name Shutdown
                $VMIntegrationStatuTime = Get-VMIntegrationService -VMName $VM -Name 'Time Synchronization'
                $VMIntegrationStatuVSS = Get-VMIntegrationService -VMName $VM -Name VSS
                Start-Sleep 5
            } until (
                ($VMIntegrationStatuHeartbeat.OperationalStatus -eq 'Ok') -and
                ($VMIntegrationStatuGuest.OperationalStatus -eq 'Ok') -and
                ($VMIntegrationStatuKey.OperationalStatus -eq 'Ok') -and
                ($VMIntegrationStatuShutdown.OperationalStatus -eq 'Ok') -and
                ($VMIntegrationStatuTime.OperationalStatus -eq 'Ok') -and
                ($VMIntegrationStatuVSS.OperationalStatus -eq 'Ok') -and
                ($VMStatus.State -eq 'Running')
            )

            do {
                Start-Sleep 60
                Write-Verbose -Message "Looping through provisioned VMS until they are available, doing $VM now"
            } until (Invoke-Command -VMName $VM -ScriptBlock { get-aduser -filter * } -Credential $domainCred -ErrorAction SilentlyContinue)

            Write-Verbose -Message 'Do while Loop for get-aduser just finished'

            #configure some default domain OU and User Accounts
            $null = Invoke-Command -VMName $VM -ScriptBlock {
                @('User Accounts', 'Groups', 'Servers', 'Workstations', 'Administrator Accounts', 'Service Accounts') | ForEach-Object {
                    New-ADOrganizationalUnit -Name $_
                }

                $ADUserSplat = @{
                    Name                  = 'Labuser'
                    SamAccountName        = 'labuser'
                    DisplayName           = 'Lab User'
                    GivenName             = 'Lab'
                    Surname               = 'User'
                    Path                  = 'ou=User Accounts,dc=willywonka,dc=com'
                    UserPrincipalName     = 'labuser@willywonka.com'
                    AccountPassword       = (ConvertTo-SecureString -AsPlainText $using:newdomainuserpass -Force)
                    Enabled               = $true
                    ChangePasswordAtLogon = $false
                    PasswordNeverExpires  = $false
                }
                New-ADUser @ADUserSplat

                $ADUserSplat = @{
                    Name                  = 'Labadmin'
                    SamAccountName        = 'labadmin'
                    DisplayName           = 'Lab Admin (Admin)'
                    GivenName             = 'Lab'
                    Surname               = 'Admin'
                    Path                  = 'ou=Administrator Accounts,dc=willywonka,dc=com'
                    UserPrincipalName     = 'labadmin@willywonka.com'
                    AccountPassword       = (ConvertTo-SecureString -AsPlainText $using:newdomainuserpass -Force)
                    Enabled               = $true
                    ChangePasswordAtLogon = $false
                    PasswordNeverExpires  = $false
                }
                New-ADUser @ADUserSplat
                Start-Sleep 5

                Add-ADGroupMember -Identity 'Domain Admins' -Members 'LabAdmin'

            } -Credential $domainCred
        }

        #######################################
        ## Join other machines to the domain ##
        #######################################

        #Join other servers to domain and reboot them
        $BluePrint.build.servers.vm | Where-Object { $_ -ne 'labdc1' } | ForEach-Object {

            #Domain Join
            $null = Invoke-Command -VMName ('sp1-' + $_) -Credential $Cred -ScriptBlock {
                param ($Cred)
                Add-Computer -DomainName $Using:BluePrint.build.ActiveDirectory.DomainName -Credential $Cred -Restart
            } -ArgumentList $Cred
        }

        #Looping until servers have restarted and processed group policy ######################################################## fix region and prefix references in places
        ################ this loop breaks after domain joined. cred invalid?
        $BluePrint.build.servers.vm | Where-Object { $_ -ne 'labdc1' } | ForEach-Object {
            do {
                Start-Sleep 5
                Write-Verbose -Message "Looping through provisioned VMS until they are available, doing $_ now" -Verbose
            } until (Invoke-Command -VMName ('sp1-' + $_) -ScriptBlock { Get-Service w32time } -Credential $domainCred -ErrorAction SilentlyContinue );
        }

        ##########################
        ##    Cluster BUILDS    ##
        ##########################
        if ($BluePrint.build.WindowsCluster.WindowsClusterAutomation -eq 'Yes') {

            $BluePrint.build.WindowsCluster | ForEach-Object {

                $Nodes = $BluePrint.build.WindowsCluster.Nodes | ForEach-Object {
                    ($prefix + $_).ToUpper()
                }

                $arguments = @{
                    ClusterName = ($Prefix + $_.ClusterName).ToUpper()
                    Nodes       = $Nodes
                    Listeners   = ($Prefix + $_.Listeners).ToUpper()
                    WitnessPath = $_.WitnessPath
                }
                $arguments | Format-Table
            }
        }
        ##########################
        ##    App Catalog       ##
        ##########################
    }

}