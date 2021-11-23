variable "registry_name" {
    type = string
}

variable "registry_managed_identity_name" {
    type = string
}

variable "registry_key_vault_name" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
}

variable "location_secondary" {
    type = string
}

variable "tags" {
    type = map(string)
}
