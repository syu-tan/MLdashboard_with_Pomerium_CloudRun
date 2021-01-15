terraform {
  required_version = "= 0.13.5"
  required_providers {
    google = {
      version = "= 3.42.0"
      source  = "hashicorp/google"
    }
    google-beta = {
      version = "= 3.42.0"
      source  = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}


data "google_project" "project" {
}