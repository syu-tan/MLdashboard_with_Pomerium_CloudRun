#provider
variable "project" {}
variable "region" {}
variable "zone" {}
variable "env" {}

# dashboard cloud run
variable "dashboard_name" {}
variable "dashboard_cpu" {
  default = "1000"
}
variable "dashboard_memory" {
  default = "512"
}
variable "tensorboard_reroadtime" {}
variable "event_filepath" {}
variable "autoscaling_max_num" {}

# authorization cloud run
variable "auth_name" {}
variable "auth_cpu" {
  default = "1000"
}
variable "auth_memory" {
  default = "512"
}
variable "encoded_policy" {}
