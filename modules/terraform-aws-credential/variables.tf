variable "length" {
  default = 16
}

variable "type" {
  description = "Type for creds to be created"
  # Should be:
  #   * 'password' : Create random password for windows
  #   * 'ssh' : Create random ssh public and private key for linux
}

variable "special" {
  type        = bool
  default     = true
  description = "Enable special characters when generate password"
}

variable "override_special" {
  description = " set of special characters allowed in password"
  default     = "!()*-@^_"
}

variable "parameter_name" {
  description = "Name for parameter to be saved"
  default     = ""
}

variable "key_name" {
  description = "Name for keypair to be created in AWS"
  default     = ""
}

variable "tags" {
  description = "Tag for resources"
}