output "container_resource_map" {
  description = <<-EOT
    Map of container names to their recommended CPU and memory resources.
    The keys are the container names, and the values are objects containing
    the CPU and memory allocations for each container.
  EOT
  value       = local.container_resource_map
}

output "task_cpu" {
  description = "Recommended CPU for the Fargate task."
  value       = var.batch_mode ? local.recommended_cpu / 1024 : local.recommended_cpu
}

output "task_memory" {
  description = "Recommended memory for the Fargate task."
  value       = local.recommended_mem
}
