# Terraform Workshop for GCP

這是提供給初學 Terraform 的 Workshop，期待你們能藉由 IaC 的快樂進而愛上雲端架構的設計開發。此篇以 GCP 作為主要平台。

## 前置作業

### 1. 安裝 Terraform
確認您有安裝 Terraform，可以在終端機執行以下指令：
```bash
$ terraform --version
Terraform v1.9.8
on darwin_arm64
```
若是 mac，應該可以使用 brew install terraform
### 2. 確認有在本地擁有 gcloud 使用權限
```
$ gcloud auth login
```

## Ch.1 Terraform 的好，動手看看就知道
1. 你今天被交派任務，要建立一個 Storage 存放檔案，請在 Console 上操作看看。以下是你會遇到要設定的東西。
- create bucket
  - naming: < Your Name > + 12345678
  - location: asia-east1
  - class: autoclass
  - control access: enforce public + uniform
  - data protection(version): soft delete policy(default retention)
2. 請試著向你身邊的同事交接你剛剛的動作，很困難，對吧？要講很多細節，同時還要確保3年5年後的自己記得這些事。所以我們需要 Terraform ，他能將你剛剛做的事情 As Code，想知道設定什麼？自己看 Code!
- 建立 main.tf，貼上下面的 code。你可以直接進行操作，我會在 Ch.2 分享我們做了什麼
    ```
    $ cd ch1
    $ cat << 'EOF' > main.tf
    resource "google_storage_bucket" "test" {
      name          = "< Your Name >-123456789"
      location      = "asia-east1"
      force_destroy = true
      project       =  "< Your GCP Project Name >"
    }
    EOF
    ```
- < Your Name > 請改為自己名字
- < Your Project Name > 請參考你的 GCP 專案名稱
- 執行以下命令
    ```
    terraform init
    terraform plan
    ```
你會看到以下 Terraform 的提醒，TF 將會在 GCP 上面建立一個 bucket
  ```
    # google_storage_bucket.test will be created
    + resource "google_storage_bucket" "test" {
        + effective_labels            = {
            + "goog-terraform-provisioned" = "true"
          }
        + force_destroy               = true
        + id                          = (known after apply)
        + location                    = "ASIA-EAST1"
        + name                        = "alvin-123456789"
        + project                     = "shopeetwbi"
        + project_number              = (known after apply)
        + public_access_prevention    = (known after apply)
        + rpo                         = (known after apply)
        + self_link                   = (known after apply)
        + storage_class               = "STANDARD"
        + terraform_labels            = {
            + "goog-terraform-provisioned" = "true"
          }
        + uniform_bucket_level_access = (known after apply)
        + url                         = (known after apply)

        + soft_delete_policy (known after apply)

        + versioning (known after apply)

        + website (known after apply)
      }
  ```
然後執行 apply，再次確認後輸入 yes。Terraform 就會幫你建立符合你想像的 bucket 了！
```
$ terraform apply

> yes
```
前往 Console 確認是否有看到。完成後，我們練習好習慣會將建立的 resource 刪除，所以
```
$ terraform destroy
```
他會再次跑一次 plan，並且問你 Yes or No。

## Ch.2 建起來很酷，但剛剛發生什麼？
1. 剛剛我們建立了 main.tf。**.tf** 是 terraform 專用檔名，在你執行 terraform 指令時，當前路徑的 .tf 都會被抓到
2. 我們在 main.tf 放了一個 resource，他的架構是 resource + 你的 Terraform Provider 定義的名稱( TF Provider 下個章節解釋)。再加上自定義的名稱，我們這邊是 "test"。{}裡面的是有關於這個 resource 要如何被設定的參數。(下個章節解釋)
    ```
    resource "google_storage_bucket" "test" {
      name          = "<Your Name>-123456789"
      location      = "asia-east1"
      force_destroy = true
      project       =  "< Your GCP Project Name >"
    }

    ```
3. 你下了 terraform init，terraform 會根據你的 code 的需求，幫你安裝需要的套件，並且放在 .terraform 的 folder 內。並且產出一個 .terraform.lock.hcl。這個相當於 package.lock，用來鎖定依賴的版本，確保不同機器運行有相同依賴。
4. 你接下來下了 terraform plan，他告訴了你 terraform 會幫你做什麼。terraform plan 的概念在整個 terraform 超重要，它關係到你會不會不小心刪掉重要的雲端資源。每次 apply 前養成好習慣先看一下 plan 做了什麼
5. 你下了 terraform apply，他背後再次跑了一次 terraform plan，並且向你確認是否執行。在你還沒輸入 yes 前，他已經產出了一份 terraform.tfstate file。 Terraform 所有對雲端的更改都是根據這份 file！
6. 點開 terraform.tfstate，你會看到我們部署的 terraform 版本以及部署的 resources

## Ch.3 試著將你的檔案上傳到 S3 上
1. 蛤？啊我要下什麼？請善用 google "terraform + 你預計對資源做的事情"。 e.g. terraform upload object to gcp storage。並找到 https://registry.terraform.io/ 這個 terraform 的官方網站。你現在會看到 google_storage_bucket_object 這個關鍵字，就是藉由 terraform 完成這項任務的方式。
2. 知道了 Resource 名稱，再來要決定帶什麼參數。從官網 https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object，你會找到 Argument Reference ，這邊會有你可以帶入的參數，包含 required 跟 Optional。我們可以看到要用 terraform 實作上傳 object，要告訴 terraform 
    - 你要上傳的 bucket name
    - 檔案上傳後的名稱 name 
    - 上傳檔案的 source
3. 這邊的 bucket 你可以有兩種寫法，直接用 text ""< Your Name >-123456789"" 或是用引用的 "< resource name >.<自定義 resource name>.< Attribute Reference >。這邊的 Attribute Reference 請參考官網 resource 的最下面 https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object。但 Terraform GCP 的部分文檔我覺得沒有很完整，你也可以試著學習 output 的用法。
4. output 的用途是你希望在跑 terraform apply 後，可以印出一些 log，這邊的 log 就是你剛剛建立的資源的 detail。我們先來試試看 output 這個資源可以用的 Attribute Reference，並且 output 剛剛建立的 bucket name
    ```
    output "resource_attributes" {
      value = google_storage_bucket.test # 会显示这个资源的所有可用属性
    }
    ```
5. 執行 terraform apply，會看到以下資訊
    ```
    resource_attributes = {
      "id" = "alvin-123456789"
      "name" = "alvin-123456789"
      "url" = "gs://alvin-123456789"
      ...
    }
    ```
6. 我們想印出 bucket name，所以將 output 改成
    ```
    output "resource_attributes" {
      value = google_storage_bucket.test.name
    }
    ```
7. 我們繼續完成 terraform upload object 的任務，這邊我們沿用剛剛 Ch.1 的 code。可以注意到，雲端的資源很多都有先後性，像是這個 case 來說，應該會先有 bucket，才上傳物件，所以我們會在 resource 補上 depend_on。以下是最終版
    ```
    resource "google_storage_bucket_object" "test" {
      name   = "main.py"
      source = "main.py"
      bucket = google_storage_bucket.test.url

      depends_on = [ google_storage_bucket.test ] // 補上這個
    }
    ```

## Ch.4 一些非必要，但如果你知道後 TF 人生會很快樂的細節
1. 為什麼 Terraform 可以幫忙建立雲端資源？通常時候我們要在雲端建立資源，除了 console 按以外，我們會打 CLI，像是 gcloud create bucket <bucket name> 等方式。Terraform 其實是寫 provider，包裝對接雲端資源的 API，讓我們可以用簡單的 terraform 的 code 來建置雲端資源。所以會有 gcp 的 provider，也會有 aws 的 provider。既然我們是透過 provider 來 call 雲端資源，他就可以事先定義基本想 call 雲端資源的設定，像是 project id or region。就不需要每個 resource 都定義一次。
    ```
    provider "google" {
      project =   "< Your GCP Project Name >"
      region  =  "< Your Region >"
    }
    ```
2. terraform 有個好處就是我們可以快速一致性我們的 Resources，這點也可用我們上面提到的 Provider 來實踐。方法就是添加 label。我自己的習慣是測試會加上 owner: alvin。如果是正式環境則加上 project，另外會加上 terraform: true，代表這是管理中的資源。
    ```
    provider "google" {
      project =  "< Your GCP Project Name >"
      region  =  "< Your Region >"

      default_labels = {
        owner     = "Alvin"
        project   = "< Your Project Name >"
        terraform = "true"
        env       = var.environment
      }
    }

    ```
3. terraform apply 執行後，其實會在跑一次 terraform plan，這樣我們中間跑一次 terraform plan 看起來就有點多餘了。其實正常狀況，我們是會將 terraform plan 的結果變成檔案，然後讓 terraform apply 直接去採用此檔案。如此就可以確保 plan 看到的跟 apply 是一樣的狀況
    ```
    terraform plan -out tf.plan 
    terraform apply tf.plan
    ```
4. terrafrom apply 後，我們會得到當前狀態檔案(state file)，其實 terraform 會先將我們上一次的 State file 改成 terraform.tfstate.backup。如果我們要退版，可以直接使用此 backup 進行部署
    ```
    terraform apply -file terraform.tfstate.backup
    ```

## Ch.1 - Ch.3 你已經學會
1. 定義自己要對雲端操作的行為
2. 如何根據行為查 terraform 對應 resource
3. 如何將 resource 寫進 .tf file
4. 從 terraform init 到 terraform apply 的操作
5. 成功地用 terraform file 建立雲端資源
6. output & depends_on 的用法

## Ch.5 藉由 Cloud Run Function 來實戰
1. 快速介紹 Cloud Run Function，相當於 AWS lambda，不存在於任何 VPC 內(後續章節會提到)跟 Serverless 服務。白話文就是你可以直接將你的程式部署在 Cloud Run Function 上，不用管主機怎麼設定維護或是外部 endpoint 怎麼 Call，可說是小白上手最佳夥伴，同時也是很多公司很喜愛的工具(低維護成本。當然，先不管你建立一大堆 Cloud Function 搞死自己的狀況)。
2. 我們的目標是建立一支會回傳 Hello World 的程式，並讓他成功在網路上運行。這個 code 來自於 GCP 官網，強烈建議要用 Cloud Function 直接參考此 example，可以少走很多冤枉路(格式或是 lib 之類的)(https://cloud.google.com/functions/docs/samples/functions-helloworld-http?hl=en#functions_helloworld_http-python)
3. 根據前面章節的學習，我們先查 terraform gcp build cloud function，得到此網站 https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function.html。我們看到 Example Usage - Public Function，直接複製貼上，並且查看他推薦我們什麼。
    ```
    resource "google_storage_bucket" "bucket" {
      name     = "test-bucket"
      location = "US"
    }

    resource "google_storage_bucket_object" "archive" {
      name   = "index.zip"
      bucket = google_storage_bucket.bucket.name
      source = "./path/to/zip/file/which/contains/code"
    }

    resource "google_cloudfunctions_function" "function" {
      name        = "function-test"
      description = "My function"
      runtime     = "nodejs16"

      available_memory_mb   = 128
      source_archive_bucket = google_storage_bucket.bucket.name
      source_archive_object = google_storage_bucket_object.archive.name
      trigger_http          = true
      entry_point           = "helloGET"
    }

    # IAM entry for all users to invoke the function
    resource "google_cloudfunctions_function_iam_member" "invoker" {
      project        = google_cloudfunctions_function.function.project
      region         = google_cloudfunctions_function.function.region
      cloud_function = google_cloudfunctions_function.function.name

      role   = "roles/cloudfunctions.invoker"
      member = "allUsers"
    }
    ```
4. 針對以上 code，我們來一一介紹
- bucket & object upload -> Cloud Function 要 Run code 有兩種方式，使用壓縮 Zip 或是直接掛載 image。這邊我們會先嘗試用壓縮 Zip，推到 storage 上給 Cloud Function 做使用。但因為要打包 code，我們學著使用 null resource。這可以在 terraform 執行期間 run 命令。通常狀況不會用到，因為額外的前後端會有 CICD 打包到 image。因為要確保先打包，所以要為 google_storage_bucket_object 加上 depend on。
  - null resource 其實是調用 null provider(像是 google provider or aws provider)。我們有提過 provider 相當於是包裝好的 lib，因為之前 tf 內沒有 null provider，所以我們要下 terraform init -upgrade
  - terraform init 跟 terraform init -upgrade 差別？ terraform init 會參照 .lock.hcl(除了第一次)。-upgrade 會直接重新確認版本以及更新.lock.hcl
- Cloud function
  - runtime 支援的版本可以參考 GCP 官方 https://cloud.google.com/functions/docs/concepts/execution-environment#go
  - entry_point 非常重要，要跟程式碼內呼叫的 func name 一樣
- google_cloudfunctions_function_iam_member 是誰可以來觸發這個 Cloud Function，你會看到兩個重點
  - role "roles/cloudfunctions.invoker" -> 誰擁有觸發 Cloud Function 的權限
  - member -> allUsers 所有人

### 延伸分享 1
實務上選型的參考，因為 Cloud Function 在 GCP 上有新迭代(這個的更新要靠自己去追 GCP Resource 的 Release 資訊)，他們現在改叫 Cloud Run Function( Cloud Functions (2nd gen) )，對應的 terraform resource(官網：https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function)，所以我會傾向改用新版本(考量的點很多，像是這是新專案，早點用新的未來 1st gen 被淘汰可以少一點工)。

### 延伸挑戰 2
改為 2nd gen。這關係到新的 provider 引用，我們有提過 resource 自所以可以 Call 雲端 resource，是因為有對應的 provider。而 GCP 在 provider 的開發上較新的資源會對應到 google-beta 這個新的 provider。可以試著引用看看。

## Ch.6 引用變數 & Secret Manager
這篇要先學習雲端資源 Cloud Run Function 的概念，在 Cloud Run Function 中，我們是可以額外帶入變數讓他成為環境變數的。我們先將 code 改成會抓環境變數的 code。這邊會在 Code 新增抓 mysql ip。
```
mysql_ip = os.environ.get('mysql_ip', 'not set')  # 如果沒有設置，返回 'not set'
```
然後我們要在 terraform 內進行建置 environment_variables
```
  environment_variables = {
    MYSQL_IP = "127.0.0.1"
  }
```
但如果是 Mysql 的密碼這類敏感資訊，就不適合直接這樣操作，比較適合的方式會是用 secret manager。他在讀取前會再多一層 gcp 的權限驗證，同時支持 version, replication 管理。確保高可用跟災難回復。一樣，我們先用 terraform secret manager resource 來建立。
```
resource "google_secret_manager_secret" "secret-basic" {
  secret_id = "secret"

  replication {
    auto {}
  }
}
```
然後在 cloud function 補上變數設定
```
  environment_variables = {
    MYSQL_IP = "127.0.0.1"
  }
  secret_environment_variables {
    key     = "MYSQL_PASSWORD"
    secret  = google_secret_manager_secret.secret-basic.secret_id
    version = "latest"
  }
```
***這邊你會發現 secret_environment_variables 跟 environment_variables 呼叫方式不一樣，一個是 ={} 一個是直接{}。你可以根據文檔看他是不是 Structure is documented below.***

完成後開始執行 terraform apply。這時你會發現它卡住了！請前往 console 查看 logs。你會發現它抓不到 secret!這是因為我們還沒有為 secret 設定參數。

關於 secret 設定參數其實會有一個 IaC 的難處，也就是通常我們不會將密碼放在 terraform 裡面，因為這樣也是不安全的。所以當我們建立完 secret manager 之後，我們會先用手動的方式塞入密碼
```
echo -n "my-secret-password" | gcloud secrets versions add secret --data-file=-
```
當你部署後，你可能還會遇到另一個 error。在部署 infra 的時候，出現 error 是家常便飯，你得要開始習慣它。
    ```
    │ Error: Error while updating cloudfunction configuration: Error waiting for Updating CloudFunctions Function: Error code 13, message: Function deployment failed due to a health check failure. This usually indicates that your code was built successfully but failed during a test execution. Examine the logs to determine the cause. Try deploying again in a few minutes if it appears to be transient. This deployment uses Secrets. Ensure that the runtime service account 'shopeetwbi@appspot.gserviceaccount.com' has the permission 'roles/secretmanager.secretAccessor' on the project or secrets.
    │ 
    │   with google_cloudfunctions_function.function,
    │   on main.tf line 45, in resource "google_cloudfunctions_function" "function":
    │   45: resource "google_cloudfunctions_function" "function" {
    │ 
    ```
是因為沒有正確地給予權限，我們有提到 secret manager 會多管理一層誰可以取用。我們可以想像 cloud function 需要有一個身分證明他可以取用。在 GCP 就是 **service account**，我們來試著給予看看
```
# 創建新的 service account
resource "google_service_account" "function_sa" {
  project      = "your-project-id" # 請替換為您的專案 ID
  account_id   = "cloud-function-sa"
  display_name = "Cloud Functions Service Account"
  description  = "Service account for Cloud Functions with Secret Manager access"
}

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

  project =  "< Your Project Name >"
  role    = each.key
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

```
請從 console 點選 test 看看是否有如預期的 output。

到了目前為止，我們已經有辦法上線服務了，但你會發現 terraform 也開始更雜了，像是有些 resourse 會強制要求你要設定 project，但這個通常都會是一樣的。這時候我們就會用 variables 的方式來管理
    ```
    cat << 'EOF' > variables.tf
    variable "project" {
      description = "The GCP project ID where resources will be deployed"
      type        = string
      default     = "shopeetwbi"
    }
    EOF
    ```
然後找到有 project 的部分，將設定改為
```
project = var.project
```

## Ch.7 拆分不同環境
你已經成功建立了 cloud run function，但大多時候我們會有多個環境需要運行，我們會希望可以將資源變成特定環境的。你有想到什麼好方式嗎？最簡單的一種就是同一種 resource 建立兩個，然後更改名稱
```
resource "google_cloudfunctions_function" "function_test" {
  name        = "function-test-test"
}
resource "google_cloudfunctions_function" "function_prod" {
  name        = "function-test-prod"
}
```
但這樣建立也太麻煩，所以我們會改用 tf file 的方式搭配變數來更改。首先建立變數
```
variable "environment" {
  description = "The GCP project to deploy resources"
  default     = "test"
}

resource "google_storage_bucket" "bucket" {
  name     = "${var.environment}-alvin-123456789"
  location = "< Your region >"
}
```
然後建立 tf 變數 file
```
mkdir env

cat << 'EOF' > test.tfvars
environment = "test"
EOF

cat << 'EOF' > prod.tfvars
environment = "prod"
EOF
```
然後在執行 plan 跟 apply 的時候帶入變數檔
```
terraform plan -var-file=env/test.tfvars
terraform apply -var-file=env/test.tfvars 
```
但你會發現一個問題，當你執行 terraform apply -var-file=env/test.tfvars 後，State file 會建立 function-test-test 的資源。但當你執行 terraform apply -var-file=env/prod.tfvars 的時候，你的資源其實是從 function-test-test 移除改為 function-test-prod。這是因為他們用的是同一份 state file。

為了解決這個問題，我們要學習的是 **terraform workspace**。當你今天建立好 terraform init 之後，你可以使用 workspace 來切換 state file 的路徑。初次使用的時候，他會幫你建立 terraform.tfstate.d 的 folder
```
terraform workspace new test
terraform workspace list
```
這時候你再執行一次 terraform apply -var-file=env/test.tfvars ，你就會看到你的 state file 被存到對應的 folder 內。
```
terraform apply -var-file=env/test.tfvars
```
同理，執行 Prod 的環境
```
terraform workspace new prod
terraform apply -var-file=env/prod.tfvars
```
如此你就可以針對不同環境建立 IaC 的設定。


## Ch.8 跟同事 Co-Work
到目前為止，我們已經能建立不同環境的資源，且這個資源也可以 Work。但你會發現 State file 都還是在你的本地端，假設你的同事沒有拿到你的 state file，他們是很難管理這些雲端上被 terraform 建立的資源的。你可以試試看在 ch8 中執行一次建立 bucket，然後把 terraform.tfstate 改名字。再 Build 一次一模一樣的 terraform code 看看。
```
cd ch8
$ mv terraform.tfstate terraform.tfstate.old
$ terraform apply -var-file=env/prod.tfvars
```
```
│ Error: googleapi: Error 409: Your previous request to create the named bucket succeeded and you already own it., conflict
│ 
│   with google_storage_bucket.bucket,
│   on main.tf line 8, in resource "google_storage_bucket" "bucket":
│    8: resource "google_storage_bucket" "bucket" {
│ 
╵
```
那到底要怎麼管理 tf state file 呢？最簡單的方法就是丟上雲端。在 terraform 內我們稱為 backend。方法是我們先建立一個 bucket，專門是給 terraform backend 存放的 bucket
```
$ cd terraform-backend
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_name}-tf-state"
  location      = "< Your Region >"
  force_destroy = false

  versioning {
    enabled = true
  }
}
```
執行完後，在上一層的 main.tf 新增 terraform provider
```
terraform {

  backend "gcs" {
    bucket = "< 剛剛建立的 bucket backend name>"
    prefix = "terraform/state"
  }
}
```
然後我們分別切換 terraform workspace 部署。再前往 bucket 查看，就可以看到被分隔開來的 state file 儲存在 storage 上。