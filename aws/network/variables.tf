# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  description = "A human-readable name for the deployment."
  type        = string
  nullable    = false
}

variable "region" {
  description = "The AWS region for the deployment."
  type        = string
  nullable    = false
}

variable "az_count" {
  description = "The total number of availability zones required."
  type        = number
  nullable    = false
  default     = 99 # Default to all availability zones
}

# ==================================================< VPC >==================================================

# https://en.wikipedia.org/wiki/Classful_network
# https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
variable "vpc_cidrs" {
  description = "VPC CIDR for each AWS region."
  type = map(string)
  nullable = false
  default = {
    af-south-1     = "10.10.0.0/16"
    ap-east-1      = "10.11.0.0/16"
    ap-northeast-1 = "10.12.0.0/16"
    ap-northeast-2 = "10.13.0.0/16"
    ap-northeast-3 = "10.14.0.0/16"
    ap-south-1     = "10.15.0.0/16"
    ap-southeast-1 = "10.16.0.0/16"
    ap-southeast-2 = "10.17.0.0/16"
    ca-central-1   = "10.18.0.0/16"
    eu-central-1   = "10.19.0.0/16"
    eu-north-1     = "10.20.0.0/16"
    eu-south-1     = "10.21.0.0/16"
    eu-west-1      = "10.22.0.0/16"
    eu-west-2      = "10.23.0.0/16"
    eu-west-3      = "10.24.0.0/16"
    me-south-1     = "10.25.0.0/16"
    sa-east-1      = "10.26.0.0/16"
    us-east-1      = "10.27.0.0/16"
    us-east-2      = "10.28.0.0/16"
    us-west-1      = "10.29.0.0/16"
    us-west-2      = "10.30.0.0/16"
  }
}

variable "enable_vpc_logs" {
  description = "Whether or not to enable VPC flow logs."
  type        = bool
  nullable    = false
  default     = false
}

# ==================================================< SUBNETS >==================================================

variable "enable_public_subnets" {
  description = "Whether or not to deploy public subnets."
  type        = bool
  nullable    = false
  default     = true
}

variable "enable_private_subnets" {
  description = "Whether or not to deploy private subnets."
  type        = bool
  nullable    = false
  default     = true
}

# ==================================================< SUBNETS >==================================================

variable "outgoing_cidrs" {
  description = "A list of trusted CIDR blocks for vpc outgoing traffic."
  type        = list(string)
  nullable    = false
  default     = [ "0.0.0.0/0" ]
}

# ==================================================< TAGS >==================================================

variable "common_tags" {
  description = "A map of common tags for the deployment resources."
  type        = map(string)
  default     = null
}

variable "vpc_tags" {
  description = "A map of tags to be applied to VPC resource."
  type        = map(string)
  default     = null
}

variable "public_subnet_tags" {
  description = "A map of tags to be applied to public subnets."
  type        = map(string)
  default     = null
}

variable "private_subnet_tags" {
  description = "A map of tags to be applied to private subnets."
  type        = map(string)
  default     = null
}
