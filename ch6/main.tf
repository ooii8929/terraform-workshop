provider "google" {
  project = "< Your Project Name >"
  region  = "< Your Region >"
}

resource "google_storage_bucket" "bucket" {
  name     = "< Your Name >-123456789"
  location = "< Your Region >"
}

resource "null_resource" "zip" {
  triggers = {
    code_hash = "${join(",", [for f in fileset("./code", "**") : filemd5("./code/${f}")])}",
  }

  provisioner "local-exec" {
    working_dir = "./code"
    command     = <<-EOT
      zip -r ../index.zip .
    EOT
  }
}


resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./index.zip"

  # 確保在上傳之前已經完成打包
  depends_on = [null_resource.zip]
}


resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "secret"

  replication {
    auto {}
  }
}

resource "google_cloudfunctions_function" "function" {
  name        = "function-test"
  description = "Python HTTP Function"
  runtime     = "python312" # 使用 Python 3.12

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "hello_http" # 對應到 Python 函數名稱
  environment_variables = {
    MYSQL_IP = "127.0.0.1"
  }
  secret_environment_variables {
    key     = "MYSQL_PASSWORD"
    secret  = google_secret_manager_secret.secret-basic.secret_id
    version = "latest"
  }

}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
