variable "vm_name" {
  type        = string
  description = "The display name of the virtual machine"
}

variable "vm_vmdk_path" {
  type        = string
  description = "The full path where you want to store the virtual machine files"
}

variable "vm_vmdk_template_path" {
  type        = string
  description = "The full path to the template vhdx is located"
}

variable "user_name" {
  type        = string
  description = "The user with hyper-v admin rights"
}

variable "user_password" {
  type        = string
  description = "The password for the user with hyper-v admin rights"
}