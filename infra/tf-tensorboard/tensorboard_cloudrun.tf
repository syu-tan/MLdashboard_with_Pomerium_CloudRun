resource "google_cloud_run_service" "tensorboard_cloudrun" {
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
          name  = "EVENT_FILE_PATH"
          value = var.event_filepath
        }
        env {
          name  = "RELOAD_INTERVAL"
          value = var.tensorboard_reroadtime
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = var.autoscaling_max_num
        "run.googleapis.com/client-name"   = "terraform"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
  autogenerate_revision_name = true
}

data "google_iam_policy" "noauth_tensorboard_cloudrun" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth_tensorboard_cloudrun" {
  location    = google_cloud_run_service.tensorboard_cloudrun.location
  project     = google_cloud_run_service.tensorboard_cloudrun.project
  service     = google_cloud_run_service.tensorboard_cloudrun.name
  policy_data = data.google_iam_policy.noauth_tensorboard_cloudrun.policy_data
}
