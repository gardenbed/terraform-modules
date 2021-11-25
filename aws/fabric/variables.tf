# https://www.terraform.io/docs/language/values/variables.html
# https://www.terraform.io/docs/language/expressions/type-constraints.html

variable "name" {
  type        = string
  description = "A human-readable name for the deployment."
}

variable "region" {
  type        = string
  description = "The AWS region for the deployment."
}

variable "az_count" {
  type        = number
  description = "The total number of availability zones required."
  default     = 99 # This is a hack to default to all availability zones
}

# https://en.wikipedia.org/wiki/Classful_network
# https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
variable "vpc_cidrs" {
  type        = map(string)
  description = "VPC CIDR for each AWS region."
  default = {
    af-south-1     = "10.10.0.0/16",
    ap-east-1      = "10.11.0.0/16",
    ap-northeast-1 = "10.12.0.0/16",
    ap-northeast-2 = "10.13.0.0/16",
    ap-northeast-3 = "10.14.0.0/16",
    ap-south-1     = "10.15.0.0/16",
    ap-southeast-1 = "10.16.0.0/16",
    ap-southeast-2 = "10.17.0.0/16",
    ca-central-1   = "10.18.0.0/16",
    eu-central-1   = "10.19.0.0/16",
    eu-north-1     = "10.20.0.0/16",
    eu-south-1     = "10.21.0.0/16"
    eu-west-1      = "10.22.0.0/16",
    eu-west-2      = "10.23.0.0/16",
    eu-west-3      = "10.24.0.0/16",
    me-south-1     = "10.25.0.0/16"
    sa-east-1      = "10.26.0.0/16",
    us-east-1      = "10.27.0.0/16",
    us-east-2      = "10.28.0.0/16",
    us-west-1      = "10.29.0.0/16",
    us-west-2      = "10.30.0.0/16"
  }
}

variable "enable_vpc_logs" {
  type        = bool
  description = "Whether or not to enable VPC flow logs."
  default     = false
}

variable "enable_public_subnets" {
  type        = bool
  description = "Whether or not to deploy public subnets."
  default     = true
}

variable "enable_private_subnets" {
  type        = bool
  description = "Whether or not to deploy private subnets."
  default     = true
}

variable "enable_bastion" {
  type        = bool
  description = "Whether or not to deploy bastion hosts."
  default     = true
}

variable "bastion_cidr_whitelist" {
  type        = set(string)
  description = "A set of trusted CIDR blocks for incoming traffic."
  default     = [ "0.0.0.0/0" ]
}

variable "bastion_public_key" {
  type        = string
  description = "The path to the public key for bastion hosts."
}

variable "metadata" {
  type        = map(string)
  description = "A map of common metadata for resource tags."
  default     = {}
}

variable "vpc_tags" {
  type        = map(string)
  description = "A map of tags to be applied to VPC resource."
  default     = {}
}

variable "public_subnet_tags" {
  type        = map(string)
  description = "A map of tags to be applied to public subnets."
  default     = {}
}

variable "private_subnet_tags" {
  type        = map(string)
  description = "A map of tags to be applied to private subnets."
  default     = {}
}
