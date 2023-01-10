provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "bigmtn1113-terraform-up-and-running-state"
  
  # 실수로 S3 버킷을 삭제하는 것을 방지
  lifecycle {
    prevent_destroy = true
  }
  
  # 코드 이력을 관리하기 위해 상태 파일의 버전 관리 활성화
  # 버킷의 파일이 업데이트될 때마다 새 버전 생성. 언제든지 이전 버전으로 롤백 가능
  versioning {
    enabled = true
  }
  
  # 서버 측 암호화 활성화
  # S3에 데이터가 저장될 때 상태 파일이나 그 파일에 포함된 모든 시크릿 암호화
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}

#terraform {
#  backend "s3" {
#    # key는 Terraform 상태 파일을 저장할 S3 버킷 내의 파일 경로
#    bucket = "bigmtn1113-terraform-up-and-running-state"
#    key    = "global/s3/terraform.tfstate"
#    region = "us-east-2"

    # encrypt를 통해 Terraform 상태 파일이 S3 디스크에 저장될 때 암호화
#    dynamodb_table = "terraform-up-and-running-locks"
#    encrypt        = true
#  }
#}

resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}

# 이전에 생성한 S3 버킷 및 DynamoDB 테이블을 사용하여 백엔드 설정 구성
terraform {
  backend "s3" {
    bucket = "bigmtn1113-terraform-up-and-running-state"
    key    = "workspaces-example/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
