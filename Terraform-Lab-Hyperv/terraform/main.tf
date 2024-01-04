resource "hyperv_machine_instance" "vm" {
  count = 2

  name                 = "${var.vm_name}${count.index + 1}"
  dynamic_memory       = true
  memory_maximum_bytes = 8589934592
  memory_minimum_bytes = 2147483648
  memory_startup_bytes = 4294967296

  network_adaptors {
    name        = "wan"
    switch_name = data.hyperv_network_switch.vm_switch.name
  }

  hard_disk_drives {
    path                = "${var.vm_vmdk_path}${var.vm_name}${count.index + 1}.vhdx"
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

# resource "hyperv_vhd" "main_vhd" {
#   for_each = var.master_nodes

#   path = "D:\\Tech\\Labs\\hyper-v\\${each.value}.vhdx"
#   source = "D:\\Tech\\Labs\\hyper-v\\packer-windows2022-g2\\Virtual Hard Disks\\packer-windows2022-g2.vhdx"
# }

data "hyperv_network_switch" "vm_switch" {
  name = var.switch_name
}
