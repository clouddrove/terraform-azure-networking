provider "azurerm" {
  features {}
}

module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.0"

  environment = "test"
  label_order = ["name", "environment", ]

  name     = "example-resource-group"
  location = "North Europe"
}

module "vnet" {
  source = "../"

  environment = "test"
  name        = "example"
  label_order = ["name", "environment"]

  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
  subnet_names        = ["subnet1"]
  subnet_prefixes     = ["10.0.1.0/24"]
  enable_ddos_pp      = true
  network_watcher     = false

  delegations = [
    {
      name                       = "Test-1"
      service_delegation_name    = "Microsoft.ContainerInstance/containerGroups"
      service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  ]

  #route-table
  route_table_enabled = true

  route_table = [
    { name = "Route-01", address_prefix = "10.10.0.0/16", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.0.0.12" },
    { name = "Route-02", address_prefix = "10.20.0.0/16", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.0.0.16" },
    { name = "Route-03", address_prefix = "0.0.0.0/0", next_hop_type = "Internet" }
  ]
  disable_bgp_route_propagation = false

  enabled_nsg = true
   network_security_group_id = {}

}
