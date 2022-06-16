output "vnet_id" {
  value       = azurerm_virtual_network.vnet.*.id
  description = "The id of the newly created vNet"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.*.name
  description = "The name of the newly created vNet"
}

output "vnet_location" {
  value       = azurerm_virtual_network.vnet.*.location
  description = "The location of the newly created vNet"
}

output "vnet_address_space" {
  value       = azurerm_virtual_network.vnet.*.address_space
  description = "The address space of the newly created vNet"
}

output "vnet_subnets" {
  value       = azurerm_subnet.subnet.*.id
  description = "The ids of subnets created inside the newly created vNet"
}

