variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  description = "Default project tags"
  type        = map(string)
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "name" {
  type        = string
  description = "Name for an Amplify app"
}

variable "repository" {
  type        = string
  description = "Repository for an Amplify app"
}

variable "access_token_name" {
  type        = string
  description = "Name of repository access token stored in Secrets Manager"
}

variable "branches" {
  type = list(object({
    name  = string,
    stage = string
  }))
  description = "Branches that trigger webhooks"
}

variable "app_framework" {
  type        = string
  description = "Framework for the app"
}
