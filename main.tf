provider "azurerm" {
  features {}
}

# Configurações
variable "resource_group_name" {
  default = "RG-VIDEO-AULA"
}

variable "location" {
  default = "East US"
}

variable "aks_cluster_name" {
  default = "videoaula"
}

variable "node_count" {
  default = 3
}

variable "node_size" {
  default = "Standard_DS2_v2"
}

# Criação do Grupo de Recursos
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Criação da Rede Virtual
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aksVnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Criação da Sub-rede
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Criação do Cluster AKS
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aksdns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}
