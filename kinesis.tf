resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "${var.PROJECT}-kinesis-stream-${var.ENVIROMENT}"
  shard_count      = "${var.SHARD_COUNT}"
  retention_period = "${var.RETENTION_PERIOD}"

#   shard_level_metrics = "${var.shard_level_metrics}"

  tags =  {
    Name        = "${var.PROJECT}-ec2-influx2-${var.ENVIROMENT}"
    Owner       = "${var.OWNER}"
    Enviroment  = "${var.ENVIROMENT}"
    Tool        = "Terraform"
  }
}

resource "aws_iam_role" "kinesis_role" {
  name = "${var.PROJECT}-kinesis-role-${var.ENVIROMENT}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "logs.us-east-1.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "read_policy" {
  name = "${var.PROJECT}-kinesis-policy-${var.ENVIROMENT}"
  
  role = "${aws_iam_role.kinesis_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "kinesis:PutRecord",
      "Resource": "${aws_kinesis_stream.kinesis_stream.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "${aws_iam_role.kinesis_role.arn}"
    }
  ]
}
EOF
}

resource "null_resource" "subscription"{

    provisioner "local-exec" {

    command = <<EOT
        for logGroup in $(aws logs describe-log-groups --log-group-name-prefix "/aws/lambda" --profile ${var.aws_profile} | jq -r '.logGroups[].logGroupName');do
            echo "Subscribe to $logGroup"
            aws logs put-subscription-filter --log-group-name "$logGroup" \
                --filter-name "parse-logs" --filter-pattern "${var.SUBSCRIPTION_FILTER_PATTERN}" \
                --destination-arn "${aws_kinesis_stream.kinesis_stream.arn}" \
                --role-arn "${aws_iam_role.kinesis_role.arn}" \
                --profile torus
        done
    EOT
  }

  depends_on = [aws_kinesis_stream.kinesis_stream]
    
}
