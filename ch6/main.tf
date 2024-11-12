provider "google" {
  project = "shopeetwbi"
  region  = "asia-east1"

}


resource "google_storage_bucket" "bucket" {
  name     = "alvin-123456789"
  location = "ASIA-EAST1"
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
  name        = "alvin-function-test"
  description = "Python HTTP Function"
  runtime     = "python312"

  # 指定使用新建立的 service account
  service_account_email = google_service_account.function_sa.email


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

# 創建新的 service account
resource "google_service_account" "function_sa" {
  account_id   = "alvin-cloud-function-sa"
  display_name = "Cloud Functions Service Account"
  description  = "Service account for Cloud Functions with Secret Manager access"
}

# # 為 service account 添加 Secret Manager 存取者角色
# resource "google_project_iam_member" "secret_accessor" {
#   project = "shopeetwbi"
#   role    = "roles/secretmanager.secretAccessor"
#   member  = "serviceAccount:${google_service_account.function_sa.email}"
# }

# 為 service account 添加必要的權限
resource "google_project_iam_member" "sa_permissions" {
  for_each = toset([
    # Secret Manager 存取權限
    "roles/secretmanager.secretAccessor",

    # Cloud Functions 必要權限
    "roles/cloudfunctions.developer",
    "roles/iam.serviceAccountUser",

    # 日誌寫入權限
    "roles/logging.logWriter",

    # Cloud Storage 存取權限（如果需要訪問 Storage）
    "roles/storage.objectViewer",

    # 監控指標寫入權限
    "roles/monitoring.metricWriter",

    # 追蹤寫入權限
    "roles/cloudtrace.agent"
  ])

  project = var.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}
