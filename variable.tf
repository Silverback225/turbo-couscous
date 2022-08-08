variable "starter" {
    type = object({
        access_key = string
        secret_key = string
    }) 
}

variable "vpc" {
  type = object({
      cidr_block = string
  })
}

variable "pocnet" {
  type = object({
      cidr_block = string
  })
}

variable "fw_rg" {
  type = object ({
    capacity             = number
    name                 = string
    type                 = string
    rules_string         = string
  })
}

variable "fw_fp" {
  type = object({
    name                                = string
  })
}