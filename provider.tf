terraform {
  required_providers {
    google = {
      version = ">= 4.63.0"
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}
