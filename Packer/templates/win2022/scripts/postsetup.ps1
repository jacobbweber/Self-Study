# Phase 1 - Mandatory generic stuff
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Import-Module ServerManager

# Terminal services and sysprep registry entries
try {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-Name 'fDenyTSConnections' -Value 0 -Verbose -Force
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 0 -Verbose -Force
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 -Verbose -Force
    Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Status\SysprepStatus' -Name 'GeneralizationState' -Value 7 -Verbose -Force
} catch {
    Write-Output 'setting registry went wrong'
}

try {
    Write-Output 'Installing Nuget'
    Get-PackageProvider -Name 'Nuget' -ForceBootstrap -Verbose -ErrorAction Stop
} catch {
    Write-Output 'Installation of nuget failed, exiting'
}

# # workaround for lastest PSWindowsUpdate
# try {
#     Write-Output 'Installing PSWindowsUpdate'
#     Install-Module PSWindowsUpdate -Force -Confirm:$false -Verbose -ErrorAction Stop
#     Import-Module PSWindowsUpdate
#     Get-WUServiceManager
# } catch {
#     Write-Output 'Installation of PSWindowsUpdate failed, exiting'
#     exit (1)
# }
# try {
#     Write-Output 'Updates pass started'
#     Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
#     #Get-WUHistory
#     Write-Output 'Updates pass completed'
# } catch {
#     Write-Output 'Updates pass failed, not critical'
#     exit (0)
# }
