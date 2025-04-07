# AWS Fargate ECS Module

This module creates an AWS Fargate ECS deployment environment, including an ECS cluster, task definitions and services.

AWS Fargate is a serverless compute engine for containers that works with ECS.
Fargate removes the need to provision and manage servers, lets you specify and pay for resources per application, and improves security through application isolation by design.

This module simplifies the process of deploying containerized applications to AWS Fargate by handling the complex configuration and providing sensible defaults.

## Implementation Guidelines

- Each service requires a unique name within your cluster
- For production workloads, consider setting up autoscaling using AWS Application Auto Scaling
- Long-running applications should be deployed as services
- One-time tasks like database migrations should not be services
- Use the module's support for CloudWatch logging to capture container logs
- When connecting to a load balancer, ensure your container exposes a health check endpoint
- Consider using ECR for storing your container images

## Example usage

```terraform
module "fargate" {
  source = "./module"

  aws_region  = data.aws_region.current.name
  name        = "myapp"
  environment = "staging"

  enable_container_insights = true

  services = [
    {
      name                            = "myapp"
      is_service                      = true
      container_name                  = "myapp"
      container_image                 = "${aws_ecr_repository.myapp.repository_url}:latest"
      container_port                  = 8000
      task_role_arn                   = aws_iam_role.task.arn
      task_cpu                        = "256"
      task_memory                     = "512"
      log_retention_days              = 30
      desired_count                   = 2
      assign_public_ip                = true
      subnet_ids                      = data.aws_subnets.private.ids
      security_group_id               = aws_security_group.fargate.id
      target_group_arn                = aws_lb_target_group.fargate.arn

      enable_circuit_breaker          = true
      enable_circuit_breaker_rollback = true
      deployment_controller_type      = "ECS"
      environment_variables = [
        {
          name  = "ENVIRONMENT"
          value = "staging"
        }
      ]
    }
  ]

  tags = {
    ManagedBy = "terraform"
  }
}
```

## Running One-Time Tasks

For one-time tasks like database migrations, you define them in the module but they're not created as services.
To run such a task, use the AWS CLI or SDK. Here's an example with AWS CLI:

```bash
aws ecs run-task \
  --cluster my-cluster-name \
  --task-definition my-project-staging-migrations:1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=DISABLED}"
```

## Deploy new version of service

For long-running services, you can deploy a new version by AWS CLI `update-service` command:

```bash
aws ecs update-service \
  --cluster <cluster-name> \
  --service <service-name> \
  --force-new-deployment \
  --region <aws-region>
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | ARN of an existing ECS cluster (if create\_cluster is false) | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster (defaults to '{name}-{environment}-ecs-cluster') | `string` | `""` | no |
| <a name="input_create_cluster"></a> [create\_cluster](#input\_create\_cluster) | Whether to create a new ECS cluster or use an existing one | `bool` | `true` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Whether to enable CloudWatch Container Insights for the ECS cluster | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the app (used in resource naming and tagging) | `string` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | List of task definitions to deploy as ECS tasks/services | <pre>list(object({<br/>    name                            = string<br/>    is_service                      = bool<br/>    container_name                  = string<br/>    container_image                 = string<br/>    container_port                  = optional(number)<br/>    task_cpu                        = string<br/>    task_memory                     = string<br/>    environment_variables           = list(map(string))<br/>    log_retention_days              = number<br/>    desired_count                   = optional(number)<br/>    subnet_ids                      = optional(list(string))<br/>    security_group_id               = optional(string)<br/>    assign_public_ip                = optional(bool)<br/>    target_group_arn                = optional(string)<br/>    enable_circuit_breaker          = optional(bool)<br/>    enable_circuit_breaker_rollback = optional(bool)<br/>    deployment_controller_type      = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_groups"></a> [cloudwatch\_log\_groups](#output\_cloudwatch\_log\_groups) | Map of CloudWatch Log Group ARNs by service name |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the ECS cluster |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the ECS cluster |
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | The ARN of the IAM role used for ECS task execution |
| <a name="output_service_ids"></a> [service\_ids](#output\_service\_ids) | Map of service IDs by service name |
| <a name="output_task_definitions"></a> [task\_definitions](#output\_task\_definitions) | Map of task definition ARNs by service name |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | The ARN of the IAM role used by the ECS tasks |
