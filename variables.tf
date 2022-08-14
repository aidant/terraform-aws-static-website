variable "dns_name" {
  type = string
}

variable "dns_managed_zone" {
  type = string
}

variable "name" {
  type = string
}

variable "allowed_actions" {
  type    = list(string)
  default = ["s3:GetObject"]
}

variable "cors_rule" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = [{
    allowed_headers = []
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 0
  }]
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "cache_policy_id" {
  type    = string
  default = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
}

variable "origin_request_policy_id" {
  type    = string
  default = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
}

variable "root_object" {
  type    = string
  default = "index.html"
}

variable "custom_error_response" {
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number,
    response_code         = number,
    response_page_path    = string,
  }))
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
