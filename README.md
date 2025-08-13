# Terraform AWS Fargate Resources Calculator

This Terraform module calculates optimal CPU and memory resource allocations for AWS Fargate tasks based on container requirements. The module takes your container resource needs as input and determines the appropriate Fargate task size that satisfies these requirements according to AWS Fargate's supported CPU and memory configurations. It intelligently distributes any unused resources among containers based on configurable weight parameters, ensuring efficient resource utilization. The module outputs both the recommended task-level resources and a map of optimized container-level resources. It also supports AWS Batch mode, automatically adjusting CPU values to match AWS Batch's requirements. Use this module to simplify resource planning for Fargate workloads and avoid manual calculations of valid task configurations.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |

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
