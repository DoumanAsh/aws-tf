output "arn" {
  description = "Resource ARN of the ALB"
  value       = data.aws_lb.this.arn
}

output "dns_name" {
  description = "DNS Name of the ALB"
  value       = data.aws_lb.this.dns_name
}

output "zone_id" {
  description = "Zone ID of the ALB"
  value       = data.aws_lb.this.zone_id
}
