variable "prefix" {
  default = "dday-ws2"
}

variable "regionCenter" {
  default = "East US"
}

variable "region1" {
  default = "East US 2"
}

variable "region2" {
  default = "West US"
}

variable "sqlserver-username" {
  default = "myadminuser"
}

variable "sqlserver-password" {
  default = "4-3434sdar37-sdfsfs5w0rd"
}

resource "azurerm_resource_group" "rg-central" {
  name     = "rg-${var.prefix}-${replace(var.regionCenter, " ", "")}"
  location = "${var.regionCenter}"
}

resource "azurerm_resource_group" "rg-1" {
  name     = "rg-${var.prefix}-${replace(var.region1, " ", "")}"
  location = "${var.region1}"
}

resource "azurerm_resource_group" "rg-2" {
  name     = "rg-${var.prefix}-${replace(var.region2, " ", "")}"
  location = "${var.region2}"
}

resource "azurerm_app_service_plan" "asp-1" {
  name                = "asp-${replace(var.region1, " ", "")}"
  location            = "${azurerm_resource_group.rg-1.location}"
  resource_group_name = "${azurerm_resource_group.rg-1.name}"
  kind                = "linux"

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service_plan" "asp-2" {
  name                = "asp-${replace(var.region2, " ", "")}"
  location            = "${azurerm_resource_group.rg-2.location}"
  resource_group_name = "${azurerm_resource_group.rg-2.name}"
  kind                = "linux"

  sku {
    tier = "Free"
    size = "F1"
  }
}

# Create App Services
resource "azurerm_app_service" "as-1" {
  name                = "as-${replace(var.region1, " ", "")}"
  location            = "${azurerm_resource_group.rg-1.location}"
  resource_group_name = "${azurerm_resource_group.rg-1.name}"
  app_service_plan_id = "${azurerm_app_service_plan.asp-1.id}"
  

  app_settings {
    "host_name" = "as-${replace(var.region1, " ", "")}"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.sql-server.fully_qualified_domain_name},1433;Initial Catalog=${var.prefix}-sqldatabase; Persist Security Info=False; User Id=${var.sqlserver-username}; Password=${var.sqlserver-password}; MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

}

resource "azurerm_app_service" "as-2" {
  name                = "as-${replace(var.region2, " ", "")}"
  location            = "${azurerm_resource_group.rg-2.location}"
  resource_group_name = "${azurerm_resource_group.rg-2.name}"
  app_service_plan_id = "${azurerm_app_service_plan.asp-2.id}"

  
  app_settings {
    "host_name" = "as-${replace(var.region2, " ", "")}"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.sql-server.fully_qualified_domain_name},1433;Initial Catalog=${var.prefix}-sqldatabase; Persist Security Info=False; User Id=${var.sqlserver-username}; Password=${var.sqlserver-password}; MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }
}


resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "tm-central"
  resource_group_name    = "${azurerm_resource_group.rg-central.name}"
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "tm-central"
    ttl           = 300
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "tm-endpoint-ap-1" {
  name                = "as-${replace(var.region1, " ", "")}"
  resource_group_name = "${azurerm_resource_group.rg-central.name}"
  profile_name        = "${azurerm_traffic_manager_profile.tm.name}"
  type                = "azureEndpoints"
  target_resource_id  = "${azurerm_app_service.as-1.id}"
  endpoint_location   = "${azurerm_app_service.as-1.location}"
}

resource "azurerm_traffic_manager_endpoint" "tm-endpoint-ap-2" {
  name                = "as-${replace(var.region2, " ", "")}"
  resource_group_name = "${azurerm_resource_group.rg-central.name}"
  profile_name        = "${azurerm_traffic_manager_profile.tm.name}"
  type                = "azureEndpoints"
  target_resource_id  = "${azurerm_app_service.as-2.id}"
  endpoint_location   = "${azurerm_app_service.as-2.location}"
}

resource "azurerm_sql_server" "sql-server" {
  name                         = "${var.prefix}-sqlserver"
  resource_group_name          = "${azurerm_resource_group.rg-central.name}"
  location                     = "${azurerm_resource_group.rg-central.location}"
  version                      = "12.0"
  administrator_login          = "${var.sqlserver-username}"
  administrator_login_password = "${var.sqlserver-password}"
}

resource "azurerm_sql_database" "sql-db" {
  name                = "${var.prefix}-sqldatabase"
  resource_group_name = "${azurerm_resource_group.rg-central.name}"
  location            = "${azurerm_resource_group.rg-central.location}"
  server_name         = "${azurerm_sql_server.sql-server.name}"
}

output "fqdn" {
  value = "${azurerm_traffic_manager_profile.tm.fqdn}"
}
