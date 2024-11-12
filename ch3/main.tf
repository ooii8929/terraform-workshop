resource "google_storage_bucket" "test" {
  name          = "alvin-123456789"
  location      = "asia-east1"
  force_destroy = true
  project       = "shopeetwbi"
}


resource "google_storage_bucket_object" "test" {
  name   = "main.py"
  source = "main.py"
  bucket = google_storage_bucket.test.name

  depends_on = [google_storage_bucket.test]
}

output "resource_attributes" {
  value = google_storage_bucket.test
}


output "resource_attributes_name" {
  value = google_storage_bucket.test.name
}
