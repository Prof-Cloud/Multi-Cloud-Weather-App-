
#Default Tags Variable
variable "common_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    TeamMember  = "Prof Cloud"
    ManagedBy   = "Terraform"
    Environment = "Dev"
    Location    = "London"
  }
}

#Bucket name
variable "bucket_name" {
  default = "proj-cloud-weather-app"
}

#Domain name
variable "domain_name" {
  default = "getvanish.io"
}

