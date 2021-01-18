locals {
  # All variables used in this file should be 
  # added as locals here 
  prefix                = "${var.prefix}-0693"
  location              = var.location
  vault_name            = "${local.prefix}-vault"
  
  # Common tags should go here
  tags           = {
    created_by = "Terraform"
  }
}


resource "azurerm_key_vault" "vault" {
  name                  = replace(local.vault_name, "-", "")
  location              = local.location
  resource_group_name   = data.azurerm_resource_group.project-rg.name
  sku_name              = "standard"
  tenant_id             = data.azurerm_client_config.current.tenant_id
  tags                  = local.tags


  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get","list","create","delete","encrypt","decrypt","unwrapKey","wrapKey"
    ]

    secret_permissions = [
      "get","list","set","delete"
    ]

  }

}

# Create a Virtual Network within the Resource Group
resource "azurerm_virtual_network" "main" {
  name                = "${local.prefix}-Vnet"
  address_space       = ["10.100.0.0/16"]
  resource_group_name = data.azurerm_resource_group.project-rg.name
  location            = local.location 
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "${local.prefix}-snet-in"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  resource_group_name  = data.azurerm_resource_group.project-rg.name
  address_prefix       = "10.100.2.0/24"
}

# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "${local.prefix}-NSG"
  location            = local.location 
  resource_group_name = data.azurerm_resource_group.project-rg.name 

  security_rule {
    name                       = "allow_SSH"
    description                = "Allow SSH access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a network interface for VMs and attach the PIP and the NSG
resource "azurerm_network_interface" "main" {
  name                      = "${local.prefix}-myNIC"
  location                  = local.location 
  resource_group_name       = data.azurerm_resource_group.project-rg.name 
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${cidrhost("10.100.1.8/24", 4)}"
  }
}

# Create a new Virtual Machine based on the Golden Image
resource "azurerm_virtual_machine" "vm" {
  name                             = "${local.prefix}-DEVOPS01"
  location                         = local.location 
  resource_group_name              = data.azurerm_resource_group.project-rg.name 
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "Standard_DS12_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.fmc-img.id}"
  }

  storage_os_disk {
    name              = "${local.prefix}-DEVOPS01-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}

  os_profile {
    computer_name  = "APPVM"
    admin_username = "admin"
    admin_password = "admin#2021"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
