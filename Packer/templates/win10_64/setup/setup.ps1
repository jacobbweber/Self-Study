$ErrorActionPreference = 'Stop'

# Switch network connection to private mode
# Required for WinRM firewall rules
$Profile = Get-NetConnectionProfile
Set-NetConnectionProfile -Name $Profile.Name -NetworkCategory Private

# Enable WinRM service

Function Enable-WinRM {
    Write-Host 'Enable WinRM'
    netsh advfirewall firewall set rule group="remote administration" new enable=yes
    netsh advfirewall firewall add rule name="WinRM open Port 5985" dir=in action=allow protocol=TCP localport=5985

    winrm quickconfig -q
    winrm quickconfig -transport:http
    winrm set winrm/config '@{MaxTimeoutms="7200000"}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
    winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
    winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'

    net stop winrm
    sc.exe config winrm start= auto
    net start winrm

}

Enable-WinRM

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0