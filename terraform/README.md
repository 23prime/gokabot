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
