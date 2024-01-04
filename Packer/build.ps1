# Get-VM -Name 'packer-windows2022-g2' | Remove-VM -Force -ErrorAction SilentlyContinue
# $Seconds = (New-TimeSpan -Start (Get-Date) -End (Get-Date -Hour 23 -Minute 30 -Second 00)).totalseconds
# Start-Sleep $seconds

<#
Get-WindowsImage -ImagePath d:\\Tech\Labs\installers\temp\sources\install.wim

ImageIndex       : 1
ImageName        : Windows Server 2012 Standard (Server Core Installation)
ImageDescription : This option (recommended) reduces management and servicing by installing only what is needed to run
                   most server roles and applications.It does not include a GUI, but you can fully manage the server
                   locally or remotely with Windows PowerShell or other tools. You can switch to a different
                   installation option later. See "Windows Server Installation Options."
ImageSize        : 7,178,226,690 bytes

ImageIndex       : 2
ImageName        : Windows Server 2012 Standard (Server with a GUI)
ImageDescription : This option is useful when a GUI is required—for example, to provide backward compatibility for an
                   application that cannot be run on a Server Core installation. All server roles and features are
                   supported. You can switch to a different installation option later. See "Windows Server
                   Installation Options."
ImageSize        : 11,999,889,351 bytes

ImageIndex       : 3
ImageName        : Windows Server 2012 Datacenter (Server Core Installation)
ImageDescription : This option (recommended) reduces management and servicing by installing only what is needed to run
                   most server roles and applications.It does not include a GUI, but you can fully manage the server
                   locally or remotely with Windows PowerShell or other tools. You can switch to a different
                   installation option later. See "Windows Server Installation Options."
ImageSize        : 7,172,264,095 bytes

ImageIndex       : 4
ImageName        : Windows Server 2012 Datacenter (Server with a GUI)
ImageDescription : This option is useful when a GUI is required—for example, to provide backward compatibility for an
                   application that cannot be run on a Server Core installation. All server roles and features are
                   supported. You can switch to a different installation option later. See "Windows Server
                   Installation Options."
ImageSize        : 11,995,265,169 bytes
#>


# Variables
$template_file = '.\template.pkr.hcl'
$var_file = '.\variables.pkvars.hcl'

packer init $template_file

packer validate -var-file="$var_file" "$template_file"

packer build -force -var-file="$var_file" "$template_file" -machine-readable