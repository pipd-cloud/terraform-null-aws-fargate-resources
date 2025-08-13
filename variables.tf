variable "container_resource_map" {
  description = "Map of container names to their required CPU and memory resources."
  type = map(object({
    cpu    = number
    memory = number
    weight = optional(number, 1)
  }))
}

variable "batch_mode" {
  description = "Flag to indicate if the resources need to be calculated for AWS Batch."
  type        = bool
  default     = false
}
