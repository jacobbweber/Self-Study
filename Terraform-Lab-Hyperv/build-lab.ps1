Set-Location '.\from_packer'
terraform.exe init
terraform.exe plan
terraform.exe apply -auto-approve --parallelism=1

Function Confirm-FileInUse {
    Param (
        [parameter(Mandatory = $true)]
        [string]$filePath
    )
    try {
        $x = [System.IO.File]::Open($filePath, 'Open', 'Read') # Open file
        $x.Close() # Opened so now I'm closing
        $x.Dispose() # Disposing object
        return $false # File not in use
    } catch [System.Management.Automation.MethodException] {
        return $true # Sorry, file in use
    }
}

$StartTime = Get-Date
$Paths = Get-ChildItem -Path 'E:\test' -Filter '*.vhdx'
if ($null -ne $Paths){
    foreach ($Path in $Paths.FullName) {
        do {
            Start-Sleep 60

            $Result = Confirm-FileInUse -filePath $Path

            $Runtime = New-TimeSpan -Start $StartTime -End (Get-Date)
            Write-Output -InputObject "File in Use: $Result still creating... [$($Runtime.Minutes)m elasped]"
        } until ($Result -eq $false)
    }
} else {
    Write-Error -Message "No .vhdx files found, not going to loop"
}


$ResultTime = New-TimeSpan -Start $StartTime -End (Get-Date)
Write-Output -InputObject "ElaspedTime for VHDX clone: $($ResultTime.Minutes)"

Set-Location 'D:\Tech\git\homelab\hyper-v\terraform'
terraform.exe init
terraform.exe plan
terraform.exe apply -auto-approve
