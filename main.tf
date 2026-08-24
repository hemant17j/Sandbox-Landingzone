terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}

###################################################
# Resource Groups - Central India
###################################################

resource "azurerm_resource_group" "github_app" {
  name     = "rg-github-dev-inc-01"
  location = "Central India"
}

resource "azurerm_resource_group" "github_net" {
  name     = "rg-githubnet-dev-inc-01"
  location = "Central India"
}

###################################################
# Resource Groups - South India
###################################################

resource "azurerm_resource_group" "k8s_app" {
  name     = "rg-k8sapp-dev-sa-01"
  location = "South India"
}

resource "azurerm_resource_group" "k8s_net" {
  name     = "rg-k8sappnet-dev-sa-01"
  location = "South India"
}

###################################################
# GitHub VNET
###################################################

resource "azurerm_virtual_network" "github" {
  name                = "vnet-github-dev-inc-01"
  location            = azurerm_resource_group.github_net.location
  resource_group_name = azurerm_resource_group.github_net.name

  address_space = ["10.10.0.0/22"]
}

resource "azurerm_subnet" "github" {
  name                 = "snet-github-dev-inc-01"
  resource_group_name  = azurerm_resource_group.github_net.name
  virtual_network_name = azurerm_virtual_network.github.name

  address_prefixes = ["10.10.0.0/27"]
}

resource "azurerm_network_security_group" "github" {
  name                = "nsg-github-dev-inc-01"
  location            = azurerm_resource_group.github_net.location
  resource_group_name = azurerm_resource_group.github_net.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "github" {
  subnet_id                 = azurerm_subnet.github.id
  network_security_group_id = azurerm_network_security_group.github.id
}

###################################################
# K8S APP VNET
###################################################

resource "azurerm_virtual_network" "k8sapp" {
  name                = "vnet-k8sapp-dev-sa-01"
  location            = azurerm_resource_group.k8s_net.location
  resource_group_name = azurerm_resource_group.k8s_net.name

  address_space = ["10.20.0.0/22"]
}

resource "azurerm_subnet" "k8sapp" {
  name                 = "snet-k8sapp-dev-sa-01"
  resource_group_name  = azurerm_resource_group.k8s_net.name
  virtual_network_name = azurerm_virtual_network.k8sapp.name

  address_prefixes = ["10.20.0.0/27"]
}

resource "azurerm_network_security_group" "k8sapp" {
  name                = "nsg-k8sapp-dev-sa-01"
  location            = azurerm_resource_group.k8s_net.location
  resource_group_name = azurerm_resource_group.k8s_net.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "k8sapp" {
  subnet_id                 = azurerm_subnet.k8sapp.id
  network_security_group_id = azurerm_network_security_group.k8sapp.id
}
``
