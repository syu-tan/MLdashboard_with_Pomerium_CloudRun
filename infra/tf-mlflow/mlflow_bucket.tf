resource "google_storage_bucket" "mlflow_artifact_store" {
  name          = "${var.project}-${var.mlflow_artifact_store_name}"
  location      = var.region
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 10
    }
  }
}

