output "billing_alarm_arn" {
  description = "ARN of the billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alerts.arn
}
