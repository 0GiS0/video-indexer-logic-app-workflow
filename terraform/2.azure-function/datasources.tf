#Data from API Connections

data "terraform_remote_state" "api_connections" {
  backend = "azurerm"
  config = {
    storage_account_name = "statestf"
    container_name       = "video-indexer-flow"
    key                  = "api-connections.tfstate"
    access_key           = var.remote_states_access_key
  }
}