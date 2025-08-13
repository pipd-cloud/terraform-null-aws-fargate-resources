# Terraform AWS Fargate Resources Calculator

This Terraform module calculates optimal CPU and memory allocations for AWS Fargate tasks based on container requirements. It determines the smallest valid Fargate configuration that meets specified container resources, then distributes excess capacity according to configurable weights. The module supports AWS Batch mode with automatic CPU value adjustments and provides both task-level and container-level resource recommendations as outputs.

## Usage

```hcl
module "fargate_resources" {
  source = "cloudposse/aws-fargate-resources/null"
  # version = "x.x.x"

  container_resource_map = {
    app = {
      cpu    = 256
      memory = 512
      weight = 1
    }
    sidecar = {
      cpu    = 128
      memory = 256
      weight = 0
    }
  }

  batch_mode = false
}

output "task_resources" {
  value = {
    cpu    = module.fargate_resources.task_cpu
    memory = module.fargate_resources.task_memory
  }
}

output "container_resources" {
  value = module.fargate_resources.container_resource_map
}
```

### Example Output

For the input above, the module would produce an output similar to this:

```hcl
task_resources = {
  "cpu" = 512
  "memory" = 1024
}

container_resources = {
  "app" = {
    "cpu" = 384
    "memory" = 768
    "weight" = 1
  }
  "sidecar" = {
    "cpu" = 128
    "memory" = 256
    "weight" = 0
  }
}
```

This output shows:

1. The module selected a Fargate task size of 512 CPU units and 1024 MB memory, which is the smallest valid Fargate configuration that can accommodate the combined container requirements (384 CPU units and 768 MB memory).

2. Since the sidecar container has weight 0, all of the excess resources (128 CPU units and 256 MB memory) were allocated to the app container based on the weight distribution.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_batch_mode"></a> [batch\_mode](#input\_batch\_mode) | Flag to indicate if the resources need to be calculated for AWS Batch. | `bool` | `false` | no |
| <a name="input_container_resource_map"></a> [container\_resource\_map](#input\_container\_resource\_map) | Map of container names to their required CPU and memory resources. | <pre>map(object({<br/>    cpu    = number<br/>    memory = number<br/>    weight = optional(number, 1)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_resource_map"></a> [container\_resource\_map](#output\_container\_resource\_map) | Map of container names to their recommended CPU and memory resources.<br/>The keys are the container names, and the values are objects containing<br/>the CPU and memory allocations for each container. |
| <a name="output_task_cpu"></a> [task\_cpu](#output\_task\_cpu) | Recommended CPU for the Fargate task. |
| <a name="output_task_memory"></a> [task\_memory](#output\_task\_memory) | Recommended memory for the Fargate task. |
<!-- END_TF_DOCS -->
