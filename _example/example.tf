# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "labels" {
  source        = "clouddrove/labels/azure"
  version       = "1.0.0"
  name          = "labels"
  environment   = "test"
  label_order   = ["name", "environment"]
  business_unit = "Corp"
  attributes    = ["private"]
  extra_tags    = {
  Application   = "CloudDrove"
  }
}
module "resource_group" {
  source  = "../"
  environment = "test"
  label_order = ["name", "environment", ]

  name     = "example-resource-groupn"
  location = "North Europe"
    r_name         = "example-routetable"
}
module "vnet" {
  source = "../"

  environment = "test"
  label_order = ["name", "environment"]

  name                = "example"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
  r_name         = "example-routetable"
  enable_ddos_pp = true

  routes = [
    { r_name = "route1", address_prefix = "10.0.1.0/24", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.0.0.4" },
    { r_name = "route3", address_prefix = "0.0.0.0/0", next_hop_type = "Internet" }
  ]
  disable_bgp_route_propagation = false
  subnets = {
    mgnt_subnet = {
      subnet_name           = "snet-management"
      subnet_address_prefix = ["10.0.1.0/24"]
      delegation = {
        name = "testdelegation"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
      }}
  }
}
