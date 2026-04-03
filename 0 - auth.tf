terraform {
  required_version = ">=1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.67.0"
    }
  }
}

#AWS provider
provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = var.common_tags
  }
}

provider "aws"{
  alias = "us_east"
  region = "us-east-1"
}

#Azure provider

provider "azurerm" {
  features {}
}
