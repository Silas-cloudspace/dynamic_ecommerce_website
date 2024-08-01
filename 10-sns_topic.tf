# create an sns topic
# terraform aws create sns topic
resource "aws_sns_topic" "user_updates" {
  name = "dev-sns-topic"
}

# create an sns topic subscription
# terraform aws sns topic subscription
resource "aws_sns_topic_subscription" "notification_topic" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = "choose a email to where notifications will be sent"
}

# Remember to go to your email and confirm subscription