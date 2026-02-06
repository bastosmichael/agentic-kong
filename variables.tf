# Terraform Variables for Kong Deployment

# Current Date and Time (UTC)
variable "current_date_time" {
  description = "The current date and time in UTC"
  type        = string
  default     = "2026-02-06 14:25:02"
}

# Current User's Login
variable "current_user_login" {
  description = "The current user's login"
  type        = string
  default     = "bastosmichael"
}