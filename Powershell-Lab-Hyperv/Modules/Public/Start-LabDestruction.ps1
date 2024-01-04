function Start-LabDestruction {
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
        $JsonFile,

        [string]
        $RootHyperVVMPath = 'E:\Hyper-V\Virtual Machines\' #default
    )

    begin {
        $BluePrint = Get-Content $JsonFile | ConvertFrom-Json
    }

    process {
        ### playing with purging vms to start from scratch ###

        foreach ($Region in $BluePrint.build.EnvironmentInformation.Regions.psobject.Properties | Where-Object { $_.value -eq 'yes' }) {

            $Region = $Region.Name
            $Prefix = Get-RegionPrefix -Region $Region

            $BluePrint.build.servers | ForEach-Object {
                $VM = $Prefix + $_.VM
                Write-Verbose -Message 'shutting down the vm'
                $null = Stop-VM -Name $VM -TurnOff -Confirm:$false
                Write-Verbose -Message 'Disconnecting iso files from DVD drives'
                $null = Get-VM $VM | Get-VMDvdDrive | Set-VMDvdDrive -Path $null
                Write-Verbose -Message 'removing the vm from inventory in hyper-v'
                $null = Remove-VM -Name $VM -Confirm:$false -Force
                Write-Verbose -Message 'getting folder path of vm recursively and deleting the directory'
                $null = Get-ChildItem -Path $RootHyperVVMPath -Directory $VM | Remove-Item -Recurse -Force
            }
        }
    }
}