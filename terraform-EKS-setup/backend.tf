terraform {
    backend "s3" {
        bucket = "tf-state-bucket-eks-cluster"
        key = "eks/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "tf_lock_eks"
    }
}