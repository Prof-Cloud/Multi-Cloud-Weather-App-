#Creating S3 bucket
resource "aws_s3_bucket" "S3_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "Proj_Cloud_S3_bucket"
  }
  #Allow terraform to delete the bucket even if files exist in the bucket
  force_destroy = true
}

#S3 Website Config
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.S3_bucket.id

  index_document {
    suffix = "index.html"
  }
}

#S3 Bucket Access (Everything is set as private)
resource "aws_s3_bucket_public_access_block" "S3_access" {
  bucket                  = aws_s3_bucket.S3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#S3 Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {

  # Dependency ensures the public access block is disabled before applying the policy
  depends_on = [aws_s3_bucket_public_access_block.S3_access]

  bucket = aws_s3_bucket.S3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.S3_bucket.id}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

#Upload website files to the S3 bucket
resource "aws_s3_object" "website_index" {
  bucket       = aws_s3_bucket.S3_bucket.id
  key          = "index.html"
  source       = "weather-tracker-app-main/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "website_style" {
  bucket       = aws_s3_bucket.S3_bucket.id
  key          = "styles.css"
  source       = "weather-tracker-app-main/styles.css"
  content_type = "text/css"
}

resource "aws_s3_object" "website_script" {
  bucket       = aws_s3_bucket.S3_bucket.id
  key          = "script.js"
  source       = "weather-tracker-app-main/script.js"
  content_type = "application/javascript"
}

#Upload images to the S3 bucket
resource "aws_s3_object" "website_assets" {
  for_each = fileset("weather-tracker-app-main/assets", "*")

  bucket = aws_s3_bucket.S3_bucket.id
  key    = "assets/${each.value}"

  # Added /assets/ to the source path
  source = "weather-tracker-app-main/assets/${each.value}"

  # To ensure the images actually display!
  content_type = lookup({
    "png"  = "image/png",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "gif"  = "image/gif",
    "svg"  = "image/svg+xml"
  }, lower(element(split(".", each.value), length(split(".", each.value)) - 1)), "application/octet-stream")
}

#Static Website URL Output
output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}

#This bucket is empty
#Use to redirect traffic for getvanish.io to wwww.getvanish.io
resource "aws_s3_bucket" "apex_redirect" {
  bucket        = var.domain_name # This MUST be getvanish.io
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "apex_redirect_config" {
  bucket = aws_s3_bucket.apex_redirect.id

  redirect_all_requests_to {
    host_name = "www.${var.domain_name}"
    protocol  = "https"
  }
}