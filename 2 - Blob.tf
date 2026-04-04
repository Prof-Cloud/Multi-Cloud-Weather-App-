#Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-static-website"
  location = "UK South"
}

#Create Storage Account with Static Website
resource "azurerm_storage_account" "storage" {
  name                     = "projcloudweatherapp"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  #Ensure the data is encrypted and secure 
  https_traffic_only_enabled    = true
  public_network_access_enabled = true
}

#Create Static Website
resource "azurerm_storage_account_static_website" "website" {
  storage_account_id = azurerm_storage_account.storage.id
  index_document     = "index.html"
}

#Upload the files into Blob
resource "azurerm_storage_blob" "index_html" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web" #Azure always uses "$web" for static sites

  type         = "Block"
  content_type = "text/html"
  source       = "weather-tracker-app-main/index.html"

  # Ensure the website config is ready before uploading
  depends_on = [azurerm_storage_account_static_website.website]
}

resource "azurerm_storage_blob" "styles_css" {
  name                   = "styles.css"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "text/css"
  source                 = "weather-tracker-app-main/styles.css"

  depends_on = [azurerm_storage_account_static_website.website]
}

resource "azurerm_storage_blob" "script_js" {
  name                   = "script.js"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  content_type           = "application/javascript"
  source                 = "weather-tracker-app-main/script.js"

  depends_on = [azurerm_storage_account_static_website.website]
}

# Upload images to Azure
resource "azurerm_storage_blob" "assets" {
  for_each = fileset("weather-tracker-app-main/assets", "*")

  name                   = "assets/${each.value}"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "weather-tracker-app-main/assets/${each.value}"

  depends_on = [azurerm_storage_account_static_website.website]

}

#Static Website URL Output
output "azure_website_url" {
  value = azurerm_storage_account.storage.primary_web_endpoint
}