data "azurerm_client_config" "current" {}
// Grupos de recursos, é interessante sempre ser definido primeiro.
resource "azurerm_resource_group" "resource_group" {
  name     = "dev"
  location = "East US"
  tags = {
    "Environment" = "DEV"
  }
}

// Network, subnetwork e ip publico que os recursos estão atrelados.

resource "azurerm_virtual_network" "virtual_network" {
  name                = "dev-test"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  address_space       = ["10.0.0.0/8"]
  depends_on = [
    azurerm_resource_group.resource_group,
  ]
  tags = {
    "Environment" = "DEV-test"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "dev"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.240.0.0/16"]
  depends_on = [
    azurerm_virtual_network.virtual_network,
  ]
  
}

// VM rodar prometheus federation


resource "azurerm_network_interface" "network_interface_prometheus" {
  name                = "prometheus-nic"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.prometheus-public-ip.id
  }
}

resource "azurerm_public_ip" "prometheus-public-ip" {
  name                = "myPublicIP"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}
resource "azurerm_linux_virtual_machine" "prometheus-federation" {
  name                = "prometheus-federation"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                  = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "devo-trocar"
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.network_interface_prometheus.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer                 = "0001-com-ubuntu-server-focal"
    publisher             = "Canonical"
    sku                   = "20_04-lts-gen2"
    version   = "latest"
  }
}

// Cluster AKS "Kubernetes"

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = "dev"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = "dev"
  kubernetes_version = "1.23.5"

  
  network_profile {
    network_plugin = "azure"
  }

  default_node_pool {
    name           = "dev"
    vm_size        = "Standard_D2_v3"
    vnet_subnet_id = azurerm_subnet.subnet.id
    node_count = 1
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }
  tags = {
    "Environment" = "DEV-test"
  }
  depends_on = [
    azurerm_resource_group.resource_group,
  ]
}
