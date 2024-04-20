provider aws {
    region = var.region
}

variable region {
  type        = string
  default     = "us-east-2"
  description = "Provide region"
}


resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

variable bucket_name {
  default = "subdomain"  # provide subdomain as a bucket name
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

resource "aws_s3_object" "object1" {
  depends_on = [ aws_s3_bucket_acl.example]
  bucket = aws_s3_bucket.example.id
  key    = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "object2" {
  depends_on = [ aws_s3_bucket_acl.example]
  bucket = aws_s3_bucket.example.id
  key    = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "example" {
  depends_on = [aws_s3_bucket_acl.example]
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }


}


resource "aws_route53_record" "web" {
  zone_id = ""    # Provide hosted zone ID
  name    = var.bucket_name
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_s3_bucket.example.bucket}.s3-website.${var.region}.amazonaws.com"]
}
