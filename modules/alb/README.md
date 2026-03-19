# alb

Setup AWS load balancer as external load balancer for your kubernetes services in EKS.

This module will create kubernetes ingress with class name `alb` which configures AWS ALB via annotations

## Dependencies

Requires to create [IngressClass](https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-alb.html)

[alb-ingressclass](../alb-ingressclass) can be used to set it up

## Required parameters

| Parameter               | Description |
|-------------------------|-------------|
| `name`                  | Unique name to be used for creation of resources by this module |
| `hostname`              | Hostname for public endpoint to use |
| `route53_zone_id`       | Route53 zone ID managing the hostname |
| `routes`                | List of routes to create under this ALB. Wildcard can be placed at the end to match all possible paths with common base. |

### Route parameters

| Parameter      | Description |
|----------------|-------------|
| `service_name` | Target service name |
| `path`         | Path to match against incoming request. Can include wildcard to match everything under common prefix. Supports gRPC `/{service}/{method}` format when `protocol_version` is set to gRPC |
| `port`         | Service port. |


## Optional parameters

| Parameter              | Description |
|------------------------|-------------|
| `tags`                 | List of tags to attach to the resources |
| `class_name`           | Ingress class name to be used. If not provided, MUST create default IngressClass |
| `protocol_version`     | Application protocol on destination pods. Defaults to HTTP1. Possible values: HTTP1, HTTP2, GRPC |
| `ssl_policy`           | Specifies security policy to use for TLS handshake. [Reference](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html#tls-security-policies) |
| `target_type`          | Describes type of services you're targetting. Use 'ip' for direct network routing to the pod via ClustIP service. Use 'instance' to target NodePort services. Defaults to 'ip' |
| `health_check_path`    | Specifies path to health check endpoint for all routes. If not set, defaults to AWS's defaults |
| `health_check_port`    | Specifies port to use if health_check_path is specified. Defaults to 80 |
| `security_group_id`    | Security group to attach to the ALB. If not created, AWS shall create security group automatically |
| `idle_timeout_seconds` | Ingress Idle timeout value in seconds. Valid value should be in range of 1..=4_000. Defaults to 30s |
| `keep_alive_time_seconds` | Ingress Keep alive time for client. I.e. how long allow connection to persist. Defaults to 7200s(2 hours) |
