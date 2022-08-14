variable "dns_name" {
  type        = string
  description = "The domain name to use for the server."
}

variable "dns_managed_zone" {
  type        = string
  description = "The DNS managed zone of the dns_name."
}

variable "name" {
  type        = string
  description = "The name to use when creating resources."

  validation {
    condition     = length(var.name) != 0
    error_message = "The \"name\" variable is required and expected to be a string."
  }
}

variable "allowed_actions" {
  type        = list(string)
  description = "The AWS IAM Policy actions to allow for the Origin Access Identity."
  default     = ["s3:GetObject"]
}

variable "cors_rule" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  description = "The CORS rules to apply to the S3 Bucket."
  default = [{
    allowed_headers = []
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 0
  }]
}

variable "allowed_methods" {
  type        = list(string)
  description = "The HTTP methods to allow for the CloudFront Distributions Origin."
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  type        = list(string)
  description = "The HTTP methods to cache for the CloudFront Distributions Origin."
  default     = ["GET", "HEAD"]
}

variable "cache_policy_id" {
  type        = string
  description = "The cache policy for the CloudFront Distribution."
  default     = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
}

variable "origin_request_policy_id" {
  type        = string
  description = "The origin request policy for the CloudFront Distribution."
  default     = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
}

variable "root_object" {
  type        = string
  description = "The default root object for the CloudFront Distribution."
  default     = "index.html"
}

variable "custom_error_response" {
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number,
    response_code         = number,
    response_page_path    = string,
  }))
  description = "The custom error responses for the CloudFront Distribution."
  default = [
    {
      error_caching_min_ttl = 0,
      error_code            = 401,
      response_code         = 404,
      response_page_path    = "",
    },
    {
      error_caching_min_ttl = 0,
      error_code            = 404,
      response_code         = 404,
      response_page_path    = "",
    }
  ]
}
