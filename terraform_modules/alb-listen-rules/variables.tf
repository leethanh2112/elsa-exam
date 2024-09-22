variable "listener_arn" {
  type        = string
  description = "(Required, Forces New Resource) The ARN of the listener to which to attach the rule."
}

variable "action" {
  type        = any
  description = "(Required) Configuration block for default actions."
}

variable "conditions" {
  type        = any
  description = "(Required) A Condition block. Multiple condition blocks of different types can be set and all must be satisfied for the rule to match."
}

variable "authenticate_cognito" {
  type        = any
  description = "(Optional) Information for creating an authenticate action using Cognito."
  default     = null
}

variable "authenticate_oidc" {
  type        = string
  description = "(Optional) Information for creating an authenticate action using OIDC. Required if type is authenticate-oidc"
  default     = ""
}

variable "priority" {
  description = "(Optional) The priority for the rule between 1 and 50000. Leaving it unset will automatically set the rule with next available priority after currently existing highest rule. A listener can't have multiple rules with the same priority."
  type        = number
  default     = null
}

variable "tags" {
  description = "(Optional) A map of tags to apply to the 'aws_lb_listener' resource. Default is {}."
  type        = map(string)
  default     = {}
}

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not."
  default     = true
}

variable "module_tags" {
  type        = map(string)
  description = "(Optional) A map of tags that will be applied to all created resources that accept tags. Tags defined with 'module_tags' can be overwritten by resource-specific tags."
  default     = {}
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on."
  default     = []
}