module "sql-db" {
  source           = "./postgresql"
  database_version = var.database_version
  region           = var.region
  name             = "${var.project}-${var.dashboard_name}"
  zone             = var.zone
  project_id       = var.project
}
