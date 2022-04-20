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
  extra_tags = {
    Application = "CloudDrove"
  }
}
module "resource_group" {
  source  = "clouddrove/resource-group/azure"
  version = "1.0.0"

  environment = "test"
  label_order = ["name", "environment", ]

  name     = "example-resource-groupn"
  location = "North Europe"
}

module "vnet" {
  source = "../"
  # By default, this module will not create a resource group, proivde the name here
  # to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = true`. Location will be same as existing RG.
  resource_group_name            = module.resource_group.resource_group_name
  vnetwork_name                  = "vnet-shared-hub-westeurope-002"
  location                       = module.resource_group.resource_group_location
  vnet_address_space             = ["10.1.0.0/16"]
  firewall_subnet_address_prefix = ["10.1.0.0/26"]
  gateway_subnet_address_prefix  = ["10.1.1.0/27"]
  create_network_watcher         = false
  name = "routetable"
  # Adding Standard DDoS Plan, and custom DNS servers (Optional)
  create_ddos_plan = false
  routes = [
    { name = "route1", address_prefix = "10.0.1.0/24", next_hop_type = "VirtualAppliance", next_hop_in_ip_address = "10.0.0.4" },
    { name = "route3", address_prefix = "0.0.0.0/0", next_hop_type = "Internet" }
  ]
  # Multiple Subnets, Service delegation, Service Endpoints, Network security groups
  # These are default subnets with required configuration, check README.md for more details
  # NSG association to be added automatically for all subnets listed here.
  # First two address ranges from VNet Address space reserved for Gateway And Firewall Subnets.
  # ex.: For 10.1.0.0/16 address space, usable address range start from 10.1.2.0/24 for all subnets.
  # subnet name will be set as per Azure naming convention by defaut. expected value here is: <App or project name>
  subnets = {
    mgnt_subnet = {
      subnet_name           = "snet-management"
      subnet_address_prefix = ["10.1.2.0/24"]
      delegation = {
        name = "testdelegation"
        service_delegation = {
          name    = "Microsoft.ContainerInstance/containerGroups"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
      }

      nsg_inbound_rules = [
        # [name, priority, direction, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        # To use defaults, use "" without adding any values.
        ["weballow", "100", "Inbound", "Allow", "Tcp", "80", "*", "0.0.0.0/0"],
        ["weballow1", "101", "Inbound", "Allow", "", "443", "*", ""],
        ["weballow2", "102", "Inbound", "Allow", "Tcp", "8080-8090", "*", ""],
      ]

      nsg_outbound_rules = [
        # [name, priority, direction, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        # To use defaults, use "" without adding any values.
        ["ntp_out", "103", "Outbound", "Allow", "Udp", "123", "", "0.0.0.0/0"],
      ]
    }

    dmz_subnet = {
      subnet_name           = "snet-appgateway"
      subnet_address_prefix = ["10.1.3.0/24"]
      service_endpoints     = ["Microsoft.Storage"]

      nsg_inbound_rules = [
        # [name, priority, direction, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        # To use defaults, use "" without adding any values.
        ["weballow", "200", "Inbound", "Allow", "Tcp", "80", "*", ""],
        ["weballow1", "201", "Inbound", "Allow", "Tcp", "443", "AzureLoadBalancer", ""],
        ["weballow2", "202", "Inbound", "Allow", "Tcp", "9090", "VirtualNetwork", ""],
      ]

      nsg_outbound_rules = [
        # [name, priority, direction, access, protocol, destination_port_range, source_address_prefix, destination_address_prefix]
        # To use defaults, use "" without adding any values.
      ]
    }
  }

  # Adding TAG's to your Azure resources (Required)
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
}