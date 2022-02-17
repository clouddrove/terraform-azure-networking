locals {
  ddos_pp_id = var.enable_ddos_pp ? azurerm_network_ddos_protection_plan.example[0].id : ""
}

module "labels" {

  source  = "clouddrove/labels/azure"
  version = "1.0.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.enable == true ? 1 : 0
  name                = "${var.name}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = length(var.address_spaces) == 0 ? [var.address_space] : var.address_spaces
  dns_servers         = var.dns_servers
  dynamic "ddos_protection_plan" {
    for_each = local.ddos_pp_id != "" ? ["ddos_protection_plan"] : []
    content {
      id     = local.ddos_pp_id
      enable = true
    }
  }
  tags = module.labels.tags
}

resource "azurerm_network_ddos_protection_plan" "example" {
  count               = var.enable_ddos_pp && var.enable == true ? 1 : 0
  name                = "${var.name}-ddospp"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = module.labels.tags
}

resource "azurerm_subnet" "subnet" {
  count                                          = var.enable == true ? length(var.subnet_names) : 0
  name                                           = "${var.name}-${var.subnet_names[count.index]}"
  resource_group_name                            = var.resource_group_name
  address_prefixes                               = [var.subnet_prefixes[count.index]]
  virtual_network_name                           = join("", azurerm_virtual_network.vnet.*.name)
  enforce_private_link_endpoint_network_policies = lookup(var.subnet_enforce_private_link_endpoint_network_policies, var.subnet_names[count.index], false)
  service_endpoints                              = lookup(var.subnet_service_endpoints, var.subnet_names[count.index], [])
}