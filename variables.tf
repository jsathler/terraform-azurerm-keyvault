variable "location" {
  description = "The region where the Data Factory will be created. This parameter is required"
  type        = string
  default     = "northeurope"
  nullable    = false
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created. This parameter is required"
  type        = string
  nullable    = false
}
variable "tags" {
  description = "Tags to be applied to resources."
  type        = map(string)
  default     = null
}

variable "name_sufix_append" {
  description = "Define if all resources names should be appended with sufixes according to https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations."
  type        = bool
  default     = true
  nullable    = false
}

variable "key_vault" {
  type = object({
    name                            = string
    tenant_id                       = string
    sku_name                        = optional(string, "standard")
    enable_rbac_authorization       = optional(bool, true)
    public_network_access_enabled   = optional(bool, true)
    soft_delete_retention_days      = optional(number, 31)
    purge_protection_enabled        = optional(bool, true)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_deployment          = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
  })

}

variable "network_acls" {
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(string, "AzureServices")
    ip_rules                   = optional(list(string), null)
    virtual_network_subnet_ids = optional(list(string), null)
  })
  default = null
}

variable "private_endpoint" {
  type = object({
    name                           = string
    subnet_id                      = string
    application_security_group_ids = optional(list(string))
    private_dns_zone_id            = string
  })

  default = null
}
