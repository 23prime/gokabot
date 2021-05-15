# terraform

## 準備

### tfstate 用 S3 バケット作成

```console
$ aws s3 mb s3://tfstate-gokabot
$ aws s3api put-bucket-versioning --bucket tfstate-gokabot --versioning-configuration Status=Enabled
```

### AWS CLI にログイン

```console
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************KTIG shared-credentials-file    
secret_key     ****************geNU shared-credentials-file    
    region           ap-northeast-1      config-file    ~/.aws/config
```

## Terraform 関連コマンド

初期化

```console
$ terraform init
```

フォーマット

```console
$ terraform fmt -recursive -diff -write=true
```

ドライ・ラン

```console
$ terraform plan
```

リソース作成

```console
$ terraform destroy
```

リソース削除

```console
$ terraform destroy
```

### 既存リソースを Terraform の管理下に置く

インポート用のファイルに空のリソースを記述する。

```terraform
$ echo 'resource "aws_iam_policy" "GokabotSecretAccess" {}' >| import.tf
```

インポートする。

```console
$ terraform import aws_iam_policy.GokabotSecretAccess arn:aws:iam::678084882233:policy/GokabotSecretAccess
```

ファイルに書き出す。

```console
$ terraform state show aws_iam_policy.GokabotSecretAccess >> modules/iam/main.tf
```

## 手動対応しないといけないヤツ

### CodeCommit のリポジトリ作成

混ぜることも不可能ではないが、Terraform のソース自体も置いているので、別で作っておくのが無難な気がする。

### KMS 系

デフォルトの名前のものを使うので。

### ドメイン・証明書の取得

簡単に削除したり作り直したりできるわけではないので。
ただし、DNS は Terraform で管理する。

### Secrets Manager のリソース削除

AWS CLI で強制削除オプション付きで削除しないと、即座に削除できない。

```console
$ aws secretsmanager delete-secret --secret-id dockerhub-login --force-delete-without-recovery
```
