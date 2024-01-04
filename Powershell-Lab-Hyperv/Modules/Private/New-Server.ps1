function New-Server {
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
        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $VM,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Region,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $RootHyperVVMPath,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MemoryStartUpBytes,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MemoryMinimumBytes,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MemoryMaximumBytes,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewVHDSizeBytes,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ProcessorCount,

        [parameter(Mandatory = $True, ParameterSetName = 'Input')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ISOPath,

        [parameter(Mandatory = $True, ParameterSetName = 'Json')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServerDefinition
    )


    process {

        if ($PSCMDlet.ParameterSetName -eq 'Json') {
            $VM = $ServerDefinition.VM
            $HypervSwitch = $ServerDefinition.HypervSwitch
            $RootHyperVVMPath = $ServerDefinition.RootHyperVVMPath
            $MemoryStartUpBytes = $ServerDefinition.MemoryStartUpBytes
            $MemoryMinimumBytes = $ServerDefinition.MemoryMinimumBytes
            $MemoryMaximumBytes = $ServerDefinition.MemoryMaximumBytes
            $NewVHDSizeBytes = $ServerDefinition.NewVHDSizeBytes
            $ProcessorCount = $ServerDefinition.ProcessorCount
            $ISOPath = $ServerDefinition.ISOPath
        }
        $hypervswitch = Get-RegionNetwork -Region $Region

        $NewVMParam = @{
            Name               = $VM.ToUpper()
            MemoryStartUpBytes = [Int64]($MemoryStartUpBytes).Replace('GB', '') * 1GB
            Path               = $RootHyperVVMPath
            SwitchName         = $hypervswitch
            NewVHDPath         = (Join-Path -Path $RootHyperVVMPath -ChildPath "$VM\Virtual Hard Disks\$VM.vhdx")
            NewVHDSizeBytes    = [Int64]($NewVHDSizeBytes).Replace('GB', '') * 1GB
            ErrorAction        = 'Stop'
            Verbose            = $True
        }

        Write-Verbose -Message 'running New-VM to create the base vm'
        New-VM @NewVMParam


        $SetVMParam = @{
            ProcessorCount     = $ProcessorCount
            DynamicMemory      = $True
            MemoryMinimumBytes = [Int64]($MemoryMinimumBytes).Replace('GB', '') * 1GB
            MemoryMaximumBytes = [Int64]($MemoryMaximumBytes).Replace('GB', '') * 1GB
            ErrorAction        = 'Stop'
            PassThru           = $True
            Verbose            = $True
        }

        Write-Verbose -Message 'running Set-VM to configure resources'
        $VM | Set-VM @SetVMParam

        <#
    $NewVHDParam = @{
        Path = 'C:\Users\Public\Documents\Hyper-V\Virtual Hard  Disks\MS01B_Data.vhdx'
        Dynamic =  $True
        SizeBytes =  60GB
        ErrorAction =  'Stop'
        Verbose =  $True
    }

    $VHD = New-VHD @NewVHDParam


    $AddVMHDDParam = @{
        Path = 'C:\Users\Public\Documents\Hyper-V\Virtual Hard  Disks\MS01B_Data.vhdx'
        ControllerType =  'SCSI'
        ControllerLocation =  1
    }

    $VM | Add-VMHardDiskDrive @AddVMHDDParam
    #>
        Start-Sleep 3
        $VMDVDParam = @{
            VMName             = $VM
            ControllerLocation = 0
            ControllerNumber   = 1
            Path               = $ISOPath
            ErrorAction        = 'Stop'
        }

        Write-Verbose -Message 'Mounting the OS iso to the primary DVD drive for insallation'
        $null = Set-VMDvdDrive @VMDVDParam

        Write-Verbose -Message "Creating the unattended file at $((Join-Path -Path $RootHyperVVMPath -ChildPath "$VM\autounattend.xml"))"
        $null = New-UnattendFile -RootHyperVVMPath $RootHyperVVMPath -VM $VM

        Write-Verbose -Message 'Creating the ISO containing the unattended file'
        $source_dir = (Join-Path -Path $RootHyperVVMPath -ChildPath "$VM\autounattend.xml")
        $null = Get-ChildItem "$source_dir" | New-ISOFile -path (Join-Path -Path $RootHyperVVMPath -ChildPath "$VM\$VM-unattend.iso") -Force


        $VMAddDVDParam = @{
            VMName             = $VM
            ControllerLocation = 1
            ControllerNumber   = 1
        }

        Write-Verbose -Message 'Adding secondary DVD drive for the Unattended ISO'
        $null = Add-VMDvdDrive @VMAddDVDParam


        $VMDVDSetParam = @{
            VMName             = $VM
            ControllerLocation = 1
            ControllerNumber   = 1
            Path               = (Join-Path -Path $RootHyperVVMPath -ChildPath "$VM\$VM-unattend.iso")
            ErrorAction        = 'Stop'
        }

        Write-Verbose -Message 'Mounting the Unattended ISO'
        $null = Set-VMDvdDrive @VMDVDSetParam


        $AddVMNICParam = @{
            SwitchName = $hypervswitch
        }

        Write-Verbose -Message "Configuring the VM's network adapater"
        #$VM | Add-VMNetworkAdapter @AddVMNICParam

        Write-Verbose -Message "Adding VMIntegration Servivces that aren't already enabled"
        $null = Get-VMIntegrationService -VMName $VM | Where-Object { $_.Enabled -eq $false } | Enable-VMIntegrationService

        Write-Verbose -Message 'Starting VM'
        $null = $VM | Start-VM -Verbose

    }

}