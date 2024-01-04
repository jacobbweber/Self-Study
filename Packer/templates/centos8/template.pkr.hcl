packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
  }
}

variable "disk_size" {
  type    = string
  default = ""
}

variable "iso_checksum" {
  type    = string
  default = ""
}

variable "iso_checksum_type" {
  type    = string
  default = ""
}

variable "iso_url" {
  type    = string
  default = ""
}

variable "output_directory" {
  type    = string
  default = ""
}

variable "secondary_iso_image" {
  type    = string
  default = ""
}

variable "switch_name" {
  type    = string
  default = ""
}

variable "sysprep_unattended" {
  type    = string
  default = ""
}

variable "upgrade_timeout" {
  type    = string
  default = ""
}

variable "vlan_id" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}

variable "temp_path" {
  type    = string
  default = ""
}

source "hyperv-iso" "vm" {
boot_command = ["<up><tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"]
  boot_wait             = "5s"
  communicator          = "ssh"
  cpus                  = 2
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 1
  guest_additions_mode  = "disable"
  http_directory       = "http"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  memory                = 4096
  output_directory      = "${var.output_directory}${var.vm_name}"
  shutdown_timeout      = "30m"
  shutdown_command     = "echo 'packer' | sudo -S -E shutdown -P now"
  keep_registered       = true
  skip_export           = true
  switch_name           = "${var.switch_name}"
  temp_path             = "${var.temp_path}"
  vlan_id               = "${var.vlan_id}"
  vm_name               = "${var.vm_name}"
  ssh_password         = "packer"
  ssh_timeout          = "4h"
  ssh_username         = "packer"
}

build {
  sources = ["source.hyperv-iso.vm"]

}
