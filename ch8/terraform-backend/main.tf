variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "< Custom Project Name >"
}

# provider.tf
provider "google" {
  project = "< Your Project Name >"
  region  = "< Your Region >"
}

resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_name}-tf-state"
  location      = "< Your Region >"
  force_destroy = false

  versioning {
    enabled = true
  }
}

output "backend_name" {
  value = google_storage_bucket.terraform_state.name
}
