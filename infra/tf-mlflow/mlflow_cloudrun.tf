resource "google_cloud_run_service" "mlflow_cloudrun" {
  name     = var.dashboard_name
  location = var.region

  template {
    spec {
      containers {
        image = "asia.gcr.io/${var.project}/${var.dashboard_name}"
        resources {
          limits = { "memory" : "${var.dashboard_memory}Mi", "cpu" : "${var.dashboard_cpu}m" }
        }
        env {
          name  = "ARTIFACTE_URI"
          value = "gs://${google_storage_bucket.mlflow_artifact_store.name}"
        }
        env {
          name  = "STORE_URI"
          value = "postgresql+psycopg2://${module.sql-db.default_db_username}:${module.sql-db.generated_user_password}@${module.sql-db.default_db_name}/?host=/cloudsql/${module.sql-db.instance_connection_name}"
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = var.autoscaling_max_num
        "run.googleapis.com/cloudsql-instances" = "${var.project}:${var.region}:${module.sql-db.instance_name}"
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  autogenerate_revision_name = true
}

data "google_iam_policy" "noauth_mlflow_cloudrun" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
      "serviceAccount:${google_service_account.mlflow_invoker.email}",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth_mlflow_cloudrun" {
  location    = google_cloud_run_service.mlflow_cloudrun.location
  project     = google_cloud_run_service.mlflow_cloudrun.project
  service     = google_cloud_run_service.mlflow_cloudrun.name
  policy_data = data.google_iam_policy.noauth_mlflow_cloudrun.policy_data
}

resource "google_service_account" "mlflow_invoker" {
  account_id   = "${var.dashboard_name}-invoker"
  display_name = "${var.dashboard_name} invoker"
  description  = "For connect mlflow at cloudrun"
}

