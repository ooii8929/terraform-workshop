variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "das-llm-developer-infra"
}

# provider.tf
provider "google" {
  project = "shopeetwbi"
  region  = "asia-east1"
}

# storage.tf
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_name}-tf-state"
  location      = "asia-east1"
  force_destroy = false

  versioning {
    enabled = true
  }
}

output "backend_name" {
  value = google_storage_bucket.terraform_state.name
}
