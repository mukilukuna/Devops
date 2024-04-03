variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "CIR"
}
variable "location" {
  description = "value for location"
  type        = string
  default     = "westeurope"
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}euazurg"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.prefix}euazuvnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "${var.prefix}euazusubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "${var.prefix}euazuNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_virtual_desktop_host_pool" "example" {
  name                = "${var.prefix}euazuhp"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "example" {
  name                = "${var.prefix}euazuvd"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  type                = "RemoteApp"
  host_pool_id        = azurerm_virtual_desktop_host_pool.example.id
}
