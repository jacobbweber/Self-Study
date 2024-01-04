resource "hyperv_vhd" "main_vhd" {
  count = 2

  path   = "${var.vm_vmdk_path}${var.vm_name}${count.index + 1}.vhdx"
  source = var.vm_vmdk_template_path
}
