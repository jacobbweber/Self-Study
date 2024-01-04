terraform {
  required_providers {
    hyperv = {
      version = "1.0.4"
      source  = "registry.terraform.io/taliesins/hyperv"
    }
  }
}

provider "hyperv" {
  user            = "ansible"
  password        = "Titl@pn!"
  host            = "127.0.0.1"
  port            = 5985
  https           = false
  insecure        = true
  use_ntlm        = true
  tls_server_name = ""
  cacert_path     = ""
  cert_path       = ""
  key_path        = ""
  script_path     = "C:/Temp/terraform_%RAND%.cmd"
}


resource "hyperv_vhd" "main_vhd" {
  path     = "E:\\test\\ad.vhdx"
  source   = "D:\\Tech\\Labs\\hyper-v\\packer-windows2022-g2\\Virtual Hard Disks\\packer-windows2022-g2.vhdx"
  timeouts {
    create = "400s"
    update = "400s"
    delete = "400s"
    read   = "400s"
  }
}


resource "hyperv_machine_instance" "vm" {
  name                 = "ad"
  dynamic_memory       = true
  memory_maximum_bytes = 8589934592
  memory_minimum_bytes = 2147483648
  memory_startup_bytes = 4294967296

  network_adaptors {
    name        = "wan"
    switch_name = "vSwitch"
  }

  hard_disk_drives {
    path                = hyperv_vhd.main_vhd.path
    controller_number   = "0"
    controller_location = "0"
  }

  integration_services = {
    VSS = true
  }

  provisioner "local-exec" {
    command = "wsl bash -c 'ansible-playbook create_win_domain.yml --limit ${var.vm_name}${count.index + 1}'"

    interpreter = ["PowerShell", "-File"]
  }

}

