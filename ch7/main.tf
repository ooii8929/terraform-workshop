provider "google" {
  project = "shopeetwbi"
  region  = "asia-east1"

}


resource "google_storage_bucket" "bucket" {
  name     = "${var.environment}-alvin-123456789"
  location = "ASIA-EAST1"
}
