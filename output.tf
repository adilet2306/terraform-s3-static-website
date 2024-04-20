output endpoint {
    value = "http://${aws_s3_bucket.example.bucket}.s3-website.${var.region}.amazonaws.com"
}
