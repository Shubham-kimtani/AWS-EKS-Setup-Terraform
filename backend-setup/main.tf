provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
    bucket = "tf-state-bucket-eks-cluster"
    
    versioning {
        enabled = true
    }

    lifecycle {
      prevent_destroy = true
    }

    server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks_for_eks" {
    name = "tf_lock_eks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}