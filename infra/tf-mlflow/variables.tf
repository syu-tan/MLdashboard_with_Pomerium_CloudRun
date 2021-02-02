#provider
variable "project" {}
variable "region" {}
variable "zone" {}

# dashboard cloud run
variable "dashboard_name" {}
variable "dashboard_cpu" {
  default = "1000"
}
variable "dashboard_memory" {
  default = "512"
}
variable "autoscaling_max_num" {}
variable "mlflow_artifact_store_name" {}

# authorization cloud run
variable "auth_name" {
  description = "cloudrun container name & an identifier for Secret Manager secret resource."
}
variable "auth_cpu" {
  default = "1000"
}
variable "auth_memory" {
  default = "512"
}
variable "idp_client_id" {}
variable "idp_client_secret" {}

# database
variable "database_version" {
  default = "POSTGRES_12"
}
variable "db_name" {}