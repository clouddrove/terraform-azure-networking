#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-azure-virtual-network"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

variable "enable" {
  type        = bool
  default     = true
  description = "Flag to control the module creation"
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "The name of an existing resource group to be imported."
}

variable "location" {
  type        = string
  default     = ""
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}

variable "address_space" {
  type        = string
  default     = ""
  description = "The address space that is used by the virtual network."
}

variable "address_spaces" {
  type        = list(string)
  default     = []
  description = "The list of the address spaces that is used by the virtual network."
}

# If no values specified, this defaults to Azure DNS
variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "The DNS servers to be used with vNet."
}

variable "subnet_prefixes" {
  type        = list(string)
  default     = []
  description = "The address prefix to use for the subnet."
}

variable "subnet_names" {
  type        = list(string)
  default     = []
  description = "A list of public subnets inside the vNet."
}

variable "subnet_enforce_private_link_endpoint_network_policies" {
  type        = map(bool)
  default     = {}
  description = "A map with key (string) `subnet name`, value (bool) `true` or `false` to indicate enable or disable network policies for the private link endpoint on the subnet. Default value is false."
}

variable "subnet_service_endpoints" {
  type        = map(list(string))
  default     = {}
  description = "A map with key (string) `subnet name`, value (list(string)) to indicate enabled service endpoints on the subnet. Default value is []."
}

variable "enable_ddos_pp" {
  type        = bool
  default     = false
  description = "Flag to control the resource creation"
}


variable "delegations" {
  type        = any
  default     = []
  description = "Block of services that has to be delegated."
}

variable "network_watcher" {
  type        = bool
  default     = false
  description = "Controls if Network Watcher resources should be created for the Azure subscription"
}

#route_table variable
variable "route_table_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the module creation"
}

variable "route_table" {
  type        = list(map(string))
  default     = []
  description = "List of objects representing routes. Each object accepts the arguments documented below."
}

variable "disable_bgp_route_propagation" {
  type        = bool
  default     = false
  description = "Boolean flag which controls propagation of routes learned by BGP on that route table. True means disable."
}

variable "enabled_nsg" {
  type        = bool
  default     = true
  description = "Flag to enable to associcate subnet with nsg."
}

variable "address_prefixes" {
  type        = list(any)
  default     = []
  description = "List of address prefixes for the subnet."
}

variable "network_security_group_id" {
  type        = string
  default     = ""
  description = "The ID of the Network Security Group which should be associated with the Subnet."
}
