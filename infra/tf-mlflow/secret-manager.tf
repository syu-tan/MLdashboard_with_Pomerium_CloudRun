# pomeriumのconfigをsecretに登録
resource "google_secret_manager_secret" "pomerium_config" {
  secret_id = var.auth_name

  labels = {
    label = "pomerium-config"
  }

  replication {
    user_managed {
      replicas {
        location = "asia-east1"
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret_version_pomerium_config" {
  secret = google_secret_manager_secret.pomerium_config.id

  secret_data = templatefile("pomerium-config/config.yaml",
    { URL           = replace(google_cloud_run_service.mlflow_cloudrun.status[0].url, var.dashboard_name, var.auth_name),
      SHARED_SECRET = base64encode(random_string.random1.result),
      COOKIE_SECRET = base64encode(random_string.random2.result),
      IDP_CLIENT_ID = var.idp_client_id,
  IDP_CLIENT_SECRET = var.idp_client_secret })
}

data "google_iam_policy" "secret_admin" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "secret_policy" {
  project     = google_secret_manager_secret.pomerium_config.project
  secret_id   = google_secret_manager_secret.pomerium_config.secret_id
  policy_data = data.google_iam_policy.secret_admin.policy_data
}