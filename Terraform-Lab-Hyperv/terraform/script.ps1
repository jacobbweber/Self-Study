$IP = 10.0.0.10
$Gateway = 10.0.0.1
$dns1 = 10.0.0.2
$dns1 = 10.0.0.3
$vm = 'ad1'

[CmdletBinding()]
param (
    [Parameter()]
    [TypeName]
    $ParameterName
)

$null = Invoke-Command -VMName $VM -Credential $Cred -ScriptBlock {
    param ($IP, $Gateway, $DNS1, $DNS2)
    $InterfaceIndex = Get-NetIPInterface -Dhcp Enabled | Select-Object -First 1
    New-NetIPAddress -InterfaceIndex $InterfaceIndex.ifIndex -IPAddress $ip -PrefixLength 24 -DefaultGateway $Gateway
    if ($env:COMPUTERNAME -eq 'st1-labdc1') {
        Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex.ifIndex -ServerAddresses ($DNS2, $DNS1)
    } else {
        Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex.ifIndex -ServerAddresses ("$($DNS1)", "$($DNS2)")
    }
    Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
    write-output -inputobject "$env:ComputerName"
    "${var.user_name}" | Out-File 'C:\windows\temp\test.txt' -Force
} -ArgumentList $ip, $Gateway, $dns1, $dns2