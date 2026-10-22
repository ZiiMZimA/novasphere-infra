terraform {
  backend "s3" {
    bucket       = "novasphere-tfstate-gna"
    key          = "novasphere/prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
