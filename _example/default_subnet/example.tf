provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.0"

  name        = "app"
  environment = "test"
  label_order = ["environment", "name", ]
  location    = "North Europe"
}

module "vnet" {
  source = "../.."

  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
  enable_ddos_pp      = false

  #subnet
  default_name_subnet           = true
  subnet_names                  = ["subnet1", "subnet2"]
  subnet_prefixes               = ["10.0.1.0/24", "10.0.2.0/24"]
  disable_bgp_route_propagation = false

  # routes
  enabled_route_table = true
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}
