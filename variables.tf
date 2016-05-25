# specify customer and environment
variable "customer" {
    default = "pm"
}

variable "environment" {
    default = "patrick"
}

# specify stack user
variable "user_name" {
    default = "patrick.mans"
}

# set password as 'export TF_VAR_password=<password>'
variable "password" {}

# generate your own key
variable "ssh_key_file" {
    default = "~/.ssh/id_rsa.patrick"
}

############### adjust as needed ###############
variable "db_vol_gb" {
    default = 10
}

variable "nfs_vol_gb" {
    default = 10
}

variable "es_vol_gb" {
    default = 10
}


############### leave unchanged for naturalis openstack ###################
variable "tenant_name" {
    default = "rely"
}

variable "auth_url" {
    default = "https://stack.naturalis.nl:5000"
}

variable "region" {
    default = "RegionOne"
}

variable "external_gateway" {
    default = "8e314b96-ae2b-41ac-bed0-5944816f56d8"
}

variable "pool" {
    default = "external"
}

variable "image_deb" {
    default = "debian-7-amd64"
}

variable "image_ub" {
    default = "Ubuntu 14.04 LTS"
}

variable "image_win" {
    default = "Windows Server 2012 R2 Std Eval"
}

variable "flavor_appl" {
    default = "ha_localdisk.4c.16r.60h"
}

variable "flavor_db" {
    default = "ha_localdisk.4c.16r.60h"
}

variable "flavor_mon" {
    default = "ha_localdisk.2c.4r.60h"
}

variable "flavor_win" {
    default = "ha_localdisk.2c.4r.60h"
}

variable "flavor_lb" {
    default = "ha_localdisk.1c.1r.20h"
}
