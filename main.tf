locals {
  fargate_table = [
    {
      cpu    = 256
      memory = [for i in [0.5, 1, 2] : i * 1024]
    },
    {
      cpu    = 512
      memory = [for i in range(1, 5, 1) : i * 1024]
    },
    {
      cpu    = 1024
      memory = [for i in range(2, 9, 1) : i * 1024]
    },
    {
      cpu    = 2048
      memory = [for i in range(4, 17, 1) : i * 1024]
    },
    {
      cpu    = 4096
      memory = [for i in range(8, 31, 1) : i * 1024]
    },
    {
      cpu    = 8192
      memory = [for i in range(16, 61, 4) : i * 1024]
    },
    {
      cpu    = 16384
      memory = [for i in range(32, 121, 8) : i * 1024]
    }
  ]

  # Calculate the total CPU and memory requirements for all containers
  required_cpu    = sum(values(var.container_resource_map)[*].cpu)
  required_memory = sum(values(var.container_resource_map)[*].memory)
  total_weight    = sum(values(var.container_resource_map)[*].weight)
  names           = keys(var.container_resource_map)

  # Find the first valid CPU and memory configuration that meets the requirements
  valid_cpu = concat(flatten([for cpu in local.fargate_table[*].cpu : cpu >= local.required_cpu ? [cpu] : []]))
  cpu_idx   = index(local.fargate_table[*].cpu, coalesce(local.valid_cpu...))
  valid_mem = concat(flatten([for mem in local.fargate_table[local.cpu_idx].memory : mem >= local.required_memory ? [mem] : []]))
  mem_idx   = index(local.fargate_table[local.cpu_idx].memory, coalesce(local.valid_mem...))

  # Calculate the recommended CPU and memory for the task
  recommended_cpu = local.fargate_table[local.cpu_idx].cpu
  recommended_mem = local.fargate_table[local.cpu_idx].memory[local.mem_idx]

  # Rebalance CPU and memory
  unused_cpu     = (local.recommended_cpu - local.required_cpu)
  rebalanced_cpu = { for name, container in var.container_resource_map : name => floor(local.unused_cpu * container.weight / local.total_weight) }
  missing_cpu    = local.recommended_cpu - local.required_cpu - sum(values(local.rebalanced_cpu))
  unused_mem     = (local.recommended_mem - local.required_memory)
  rebalanced_mem = { for name, container in var.container_resource_map : name => floor(local.unused_mem * container.weight / local.total_weight) }
  missing_mem    = local.recommended_mem - local.required_memory - sum(values(local.rebalanced_mem))

  # Calculate the final CPU and memory for each container
  container_cpu    = { for name, container in var.container_resource_map : name => container.cpu + local.rebalanced_cpu[name] + (name == local.names[0] ? local.missing_cpu : 0) }
  container_memory = { for name, container in var.container_resource_map : name => container.memory + local.rebalanced_mem[name] + (name == local.names[0] ? local.missing_mem : 0) }
  container_resource_map = { for name, container in var.container_resource_map : name => {
    cpu    = var.batch_mode ? local.container_cpu[name] / 1024 : local.container_cpu[name]
    memory = local.container_memory[name]
    weight = container.weight
  } }
}
