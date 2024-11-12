provider "google" {
  project = "< Your Project Name >"
  region  = "< Your region >"

}


resource "google_storage_bucket" "bucket" {
  name     = "${var.environment}-alvin-123456789"
  location = "< Your region >"
}
