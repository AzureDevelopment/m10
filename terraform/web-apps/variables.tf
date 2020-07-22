variable "db_user" {
    type = string
    description = "Database admin username"
    default = "e23w"
}

variable "location" {
    type = string
    description = "Location for the resources"
}

variable "resource_group_name" {
    type = string
}