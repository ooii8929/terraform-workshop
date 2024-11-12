resource "google_storage_bucket" "test" {
  name          = "alvin-123456789"
  location      = "asia-east1"
  force_destroy = true
  project       = "shopeetwbi"
}
