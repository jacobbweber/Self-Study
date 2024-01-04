$JsonFile = '.\builddefinitions\My mini Hyper-V Lab.json'
#$JsonFile = '.\builddefinitions\My mini Hyper-V Lab-win1064.json'
#$JsonFile = '.\builddefinitions\My mini Hyper-V Lab-2008.json'
#$JsonFile = '.\builddefinitions\My mini Hyper-V Lab-2012.json'

Remove-Module "HomeLab-Hyperv"
Import-Module .\Modules\HomeLab-Hyperv.psm1

Start-LabCreation -JsonFile $JsonFile -Verbose

#Start-LabDestruction -JsonFile $JsonFile -Verbose

$JsonFile = '.\builddefinitions\My mini Hyper-V Lab-win1064.json'
Start-LabCreation -JsonFile $JsonFile -Verbose

$JsonFile = '.\builddefinitions\My mini Hyper-V Lab-win1164.json'
Start-LabCreation -JsonFile $JsonFile -Verbose


#Copy-VMFile "VMName" -SourcePath "F:\Test.txt" -DestinationPath "C:\Temp\Test.txt" -CreateFullPath -FileSource Host