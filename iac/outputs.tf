output "tags" {
  value = local.tags
}

output "location" {
  value = local.location
}

output "prefix" {
  value = local.prefix
}

output "proj-rg-id" {
  value = data.azurerm_resource_group.project-rg.id
}

output "private_key" {
  value = tls_private_key.bootstrap_private_key.private_key_pem
}

output "vm_ip" {
  value = azurerm_public_ip.pip.ip_address 
}

output "vm_private_ip" {
  value = azurerm_network_interface.internal.private_ip_address 
}

output "vm_rg" {
  value = data.azurerm_resource_group.project-rg.name 
}

output "vm_name" {
  value = azurerm_virtual_machine.vm.name
}

output "vm_datadisk" {
  value = azurerm_virtual_machine.vm.storage_data_disk.0.name
}
