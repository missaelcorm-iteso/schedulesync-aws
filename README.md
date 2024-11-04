# ScheduleSync on AWS

## Prerequisites

### Terraform S3 Backend

```shell
export BUCKET_NAME=schedulesync-terraform-state
export TABLE_NAME=terraform-state-lock
export REGION=us-west-2
```

1. Create a bucket for storing Terraform State Files (`.tfstate`).
```shell
aws s3api create-bucket --bucket $BUCKET_NAME --create-bucket-configuration LocationConstraint=$REGION
```

2. Enable Versioning on the S3 Bucket.

Enabling versioning on your S3 bucket ensures that you have a history of your Terraform state files, which can be useful for recovery and debugging.
```shell
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
```

3. Enable S3 Server side encryption

```shell
aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'
```

4. Create a DynamoDB Table for State Locking

Next, create a DynamoDB table to handle state locking. This prevents concurrent Terraform executions, which can lead to state corruption.

```shell
aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $REGION
```

5. Configure the Terraform Backend

Now update `./versions.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "schedulesync-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

Be sure that bucket, and dynomdb_table matches with the resources created.

6. Initialize the Terraform Backend

```shell
terraform init
```

7. Review the Terraform Backend

```shell
terraform plan
```

8. Apply the Terraform Backend

```shell
terraform apply
```

## Terraform

### tflint

```shell
tflint --recursive --config $(pwd)/.tflint.hcl 
```

### Terraform apply

```shell
terraform apply -var-file secrets.tfvars
```