Write-Output "Cleaning/zeroing/compacting"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Clean WU downloads
try {
    Stop-Service -Name wuauserv -Force -Verbose -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
    Stop-Service -Name cryptsvc -Force -Verbose -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 10
    if (Test-Path -Path "$env:systemroot\SoftwareDistribution\Download" ) {
        Write-Output "Cleaning updates.."
        Remove-Item "$env:systemroot\SoftwareDistribution\Download\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
    if (Test-Path -Path "$env:systemroot\Prefetch") {
        Write-Output "Cleaning prefetch.."
        Remove-Item "$env:systemroot\Prefetch\*.*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Output "Cleaning failed.."
}

# Disable Windows Error Reporting
Disable-WindowsErrorReporting -ErrorAction SilentlyContinue
# remove logs
wevtutil el | Foreach-Object {wevtutil cl "$_"}

# resetbase/thin winsxs
dism /online /cleanup-image /StartComponentCleanup /ResetBase
dism /online /cleanup-Image /SPSuperseded

# Remove leftovers from deploy
if ((Test-Path -Path "$env:systemroot\Temp") -and ("$env:systemroot")) {
    Write-Output "Cleaning TEMP"
    Remove-Item $env:systemroot\Temp\* -Exclude "packer-*","script-*" -Recurse -Force -ErrorAction SilentlyContinue
}

# optimize disk
Write-Output "Defragging.."
if (Get-Command Optimize-Volume -ErrorAction SilentlyContinue) {
    Optimize-Volume -DriveLetter C -Defrag -verbose
    } else {
    Defrag.exe c: /H
}

Write-Output "Zeroing out empty space..."
 $startDTM = (Get-Date)
 $FilePath="c:\zero.tmp"
 $Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
 $ArraySize= 4096kb
 $SpaceToLeave= $Volume.Size * 0.001
 $FileSize= $Volume.FreeSpace - $SpacetoLeave
 $ZeroArray= new-object byte[]($ArraySize)

 $Stream= [io.File]::OpenWrite($FilePath)
 try {
    $CurFileSize = 0
     while($CurFileSize -lt $FileSize) {
         $Stream.Write($ZeroArray,0, $ZeroArray.Length)
         $CurFileSize +=$ZeroArray.Length
     }
 }
 finally {
     if($Stream) {
         $Stream.Close()
     }
 }
 Remove-Item $FilePath -Recurse -Force -ErrorAction SilentlyContinue
 $endDTM = (Get-Date)
 Write-Output "Zeroing took: $(($endDTM-$startDTM).totalseconds) seconds"

Write-Output "[END]"
exit 0