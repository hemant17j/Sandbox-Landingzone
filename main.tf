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
# Current Azure Client Configuration
###################################################

data "azurerm_client_config" "current" {}

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

###################################################
# GitHub Workload Subnet
###################################################

resource "azurerm_subnet" "github" {
  name                 = "snet-github-dev-inc-01"
  resource_group_name  = azurerm_resource_group.github_net.name
  virtual_network_name = azurerm_virtual_network.github.name

  address_prefixes = ["10.10.0.0/27"]
}

###################################################
# GitHub PaaS / Private Endpoint Subnet
###################################################

resource "azurerm_subnet" "github_paas" {
  name                 = "snet-paas-dev-inc-01"
  resource_group_name  = azurerm_resource_group.github_net.name
  virtual_network_name = azurerm_virtual_network.github.name

  # 10.10.0.0/27 is already used by the GitHub subnet.
  # Therefore, the next available /27 address range is used.
  address_prefixes = ["10.10.0.32/27"]
}

###################################################
# GitHub Network Security Group
###################################################

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
  security_rule {
    name                       = "Allow-SonarQube"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Nexus"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

###################################################
# GitHub Subnet NSG Associations
###################################################

resource "azurerm_subnet_network_security_group_association" "github" {
  subnet_id                 = azurerm_subnet.github.id
  network_security_group_id = azurerm_network_security_group.github.id
}

resource "azurerm_subnet_network_security_group_association" "github_paas" {
  subnet_id                 = azurerm_subnet.github_paas.id
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

###################################################
# K8S APP Subnet
###################################################

resource "azurerm_subnet" "k8sapp" {
  name                 = "snet-k8sapp-dev-sa-01"
  resource_group_name  = azurerm_resource_group.k8s_net.name
  virtual_network_name = azurerm_virtual_network.k8sapp.name

  address_prefixes = ["10.20.0.0/27"]
}

###################################################
# K8S APP Network Security Group
###################################################

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
  security_rule {
    name                       = "Allow-SonarQube"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Nexus"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

###################################################
# K8S APP Subnet NSG Association
###################################################

resource "azurerm_subnet_network_security_group_association" "k8sapp" {
  subnet_id                 = azurerm_subnet.k8sapp.id
  network_security_group_id = azurerm_network_security_group.k8sapp.id
}

###################################################
# VNET Peering
#
# Peering is created in both directions:
# 1. GitHub VNET to K8S APP VNET
# 2. K8S APP VNET to GitHub VNET
###################################################

resource "azurerm_virtual_network_peering" "github_to_k8sapp" {
  name                      = "peer-github-to-k8sapp"
  resource_group_name       = azurerm_resource_group.github_net.name
  virtual_network_name      = azurerm_virtual_network.github.name
  remote_virtual_network_id = azurerm_virtual_network.k8sapp.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "k8sapp_to_github" {
  name                      = "peer-k8sapp-to-github"
  resource_group_name       = azurerm_resource_group.k8s_net.name
  virtual_network_name      = azurerm_virtual_network.k8sapp.name
  remote_virtual_network_id = azurerm_virtual_network.github.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

###################################################
# Azure Key Vault
#
# The Key Vault remains in the application
# resource group, as requested.
###################################################

resource "azurerm_key_vault" "github" {
  name                = "kv-github-dev-inc-01"
  location            = azurerm_resource_group.github_app.location
  resource_group_name = azurerm_resource_group.github_app.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name             = "standard"

  enable_rbac_authorization       = true
  public_network_access_enabled   = false
  purge_protection_enabled        = false
  soft_delete_retention_days      = 7
}

###################################################
# Key Vault Private DNS Zone
#
# Networking-related resource is created in:
# rg-githubnet-dev-inc-01
###################################################

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.github_net.name
}

###################################################
# Private DNS Zone Link - GitHub VNET
###################################################

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_github" {
  name                  = "pdnslink-keyvault-github"
  resource_group_name   = azurerm_resource_group.github_net.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.github.id

  registration_enabled = false
}

###################################################
# Private DNS Zone Link - K8S APP VNET
#
# This allows resources in the peered K8S VNET to
# resolve the private Key Vault DNS name.
###################################################

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_k8sapp" {
  name                  = "pdnslink-keyvault-k8sapp"
  resource_group_name   = azurerm_resource_group.github_net.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.k8sapp.id

  registration_enabled = false
}

###################################################
# Key Vault Private Endpoint
#
# Private Endpoint networking resource is created in:
# rg-githubnet-dev-inc-01
#
# It is connected to:
# snet-paas-dev-inc-01
###################################################

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pep-kv-github-dec-inc-01"
  location            = azurerm_resource_group.github_net.location
  resource_group_name = azurerm_resource_group.github_net.name
  subnet_id           = azurerm_subnet.github_paas.id

  private_service_connection {
    name                           = "psc-kv-github-dec-inc-01"
    private_connection_resource_id = azurerm_key_vault.github.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "pdnszg-kv-github-dec-inc-01"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault.id
    ]
  }
}

###################################################
# GitHub App Secrets
###################################################

resource "azurerm_key_vault_secret" "github_client_id" {
  name         = "github-client-id"
  value        = "Iv23libuDCYzwklXQNT1"
  key_vault_id = azurerm_key_vault.github.id
}

resource "azurerm_key_vault_secret" "github_installation_id" {
  name         = "github-installation-id"
  value        = "12345678"
  key_vault_id = azurerm_key_vault.github.id
}

resource "azurerm_key_vault_secret" "github_private_key" {
  name         = "github-private-key"
  value        = file(pathexpand("~/repo/github-app.pem"))
  key_vault_id = azurerm_key_vault.github.id
}
