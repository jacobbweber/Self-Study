terraform {
  required_providers {
    hyperv = {
      version = "1.0.4"
      source  = "registry.terraform.io/taliesins/hyperv"
    }
  }
}

provider "hyperv" {
  user            = var.user_name
  password        = var.user_password
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
  timeout         = "30s"
}