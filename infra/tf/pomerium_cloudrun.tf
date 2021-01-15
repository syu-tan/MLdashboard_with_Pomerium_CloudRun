resource "google_cloud_run_service" "pomerium_cloudrun" {
  name     = var.auth_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/pomerium-io/pomerium:latest-cloudrun"
        resources {
          limits = { "memory" : "${var.auth_memory}Mi", "cpu" : "${var.auth_cpu}m" }
        }
        env {
          name  = "VALS_FILES"
          value = "/pomerium/config.yaml:ref+gcpsecrets://${data.google_project.project.number}/pomerium-config"
        }
        env {
          name  = "POLICY"
          value = var.encoded_policy
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

data "google_iam_policy" "noauth_pomerium_cloudrun" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth_pomerium_cloudrun" {
  location    = google_cloud_run_service.pomerium_cloudrun.location
  project     = google_cloud_run_service.pomerium_cloudrun.project
  service     = google_cloud_run_service.pomerium_cloudrun.name
  policy_data = data.google_iam_policy.noauth_pomerium_cloudrun.policy_data
}
