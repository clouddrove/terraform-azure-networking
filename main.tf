## Managed By : CloudDrove
## Copyright @ CloudDrove. All Right Reserved.

module "labels" {

  source  = "clouddrove/labels/azure"
  version = "1.0.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

# #Module      : RESOURCE GROUP
#Description : Terraform resource for resource group.
resource "azurerm_resource_group" "default" {
  # count    = var.enabled ? 1 : 0
  name     = format("%s-%s-resource-group", var.name, var.environment)
  location = var.location
  tags     = module.labels.tags

  timeouts {
    create = var.create
    read   = var.read
    update = var.update
    delete = var.delete
  }
}

## Vritual Network and Subnet Creation

locals {
  ddos_pp_id = var.enable_ddos_pp ? azurerm_network_ddos_protection_plan.example[0].id : ""
}

resource "azurerm_virtual_network" "vnet" {
  # count               = var.enable == true ? 1 : 0
  name                = "${var.name}-vnet"
  resource_group_name = azurerm_resource_group.default.name
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

resource "azurerm_subnet" "snet" {
  for_each                                       = var.subnets
  name                                           = each.value.subnet_name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value.subnet_address_prefix
  service_endpoints                              = lookup(each.value, "service_endpoints", [])
  enforce_private_link_endpoint_network_policies = lookup(each.value, "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies  = lookup(each.value, "enforce_private_link_service_network_policies", null)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}

resource "azurerm_route_table" "rtables" {
  name                = var.r_name
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value.r_name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  tags                          = module.labels.tags
}
