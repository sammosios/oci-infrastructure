variable "compartment_ocid" {
  description = "The OCID of the compartment."
}

variable "ssh_public_key_path" {
  description = "The path to the SSH public key file."
  default     = "./ssh-pub.key"
}

variable "amd_shape" {
  description = "The shape of the AMD VM."
  default     = "VM.Standard.E2.1.Micro"
}

variable "arm_shape" {
  description = "The shape of the ARM VM."
  default     = "VM.Standard.A1.Flex"
}

variable "architecture" {
  description = "The architecture of the VM (amd or arm)."
  default     = "amd"
}

variable "ubuntu_arm_image_id" {
  description = "The OCID of the Ubuntu 24.04 ARM image."
  default     = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaahcgqm7zgztt4ud4koxepqfobmmtk2cgcu6br2tgmhis3uypkfmtq"
}

variable "ubuntu_amd_image_id" {
  description = "The OCID of the Ubuntu 24.04 AMD image."
  default     = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaam6t7hfwppnu4ki6eej4kfytqfapcsrtuyu5r2rqybidhtr6k54ja"
}

variable "worker_token" {
  description = "The k0s worker join token."
  type        = string
  sensitive   = true
}