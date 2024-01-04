Set-Location 'D:\Tech\git\homelab\hyper-v\terraform'
terraform.exe destroy -auto-approve

Start-Sleep 60

Set-Location 'D:\Tech\git\homelab\hyper-v\terraform-clone-vmdk'
terraform.exe destroy -auto-approve
