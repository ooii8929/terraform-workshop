resource "google_storage_bucket" "test" {
  name          = "< Your Name >-123456789"
  location      = "asia-east1"
  force_destroy = true
  project       = "< Your Project Name >"
}
