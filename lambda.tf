resource "aws_iam_role" "lambda" {
  name = "${var.PROJECT}-lambda-role-${var.ENVIROMENT}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda_to_cloudwatch_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_to_cloudwatch_policy" {
  name   = "${var.PROJECT}-lambda_to_cloudwatch_policy-${var.ENVIROMENT}"
  role   = "${aws_iam_role.lambda.id}"
  policy = "${data.aws_iam_policy_document.lambda_to_cloudwatch_logs.json}"
}

resource "aws_iam_role_policy" "lambda_to_kinesis_policy" {
  name = "${var.PROJECT}-kinesis-policy-${var.ENVIROMENT}"

  //description = "Policy to allow reading from the ${var.stream_name} stream"
  role = "${aws_iam_role.lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kinesis:GetShardIterator",
        "kinesis:GetRecords",
        "kinesis:DescribeStream"
      ],
      "Resource": "${aws_kinesis_stream.kinesis_stream.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "kinesis:ListStreams",
      "Resource": "*"
    }
  ]
}
EOF
}
data "null_data_source" "lambda_file" {
  inputs = {
    filename = "/function/logsConsumer.js"
  }
}

data "null_data_source" "lambda_archive" {
  inputs = {
    filename = "${path.module}/function/logsConsumer.zip"
  }
} 

data "archive_file" "lambda_kinesis_stream_to_influxDB" {
  type        = "zip"
  # source_file = "${data.null_data_source.lambda_file.outputs.filename}"
  source_dir  = "${path.module}/function"
  output_path = "${data.null_data_source.lambda_archive.outputs.filename}"
}

resource "aws_cloudwatch_log_group" "lambda_function_logging_group" {
  name = "/aws/lambda/${var.LAMBDA_FUNCTION_NAME}"
}

resource "aws_lambda_function" "lambda_kinesis_stream_to_influxDB" {
  filename         = "${data.archive_file.lambda_kinesis_stream_to_influxDB.output_path}"
  function_name    = "${var.LAMBDA_FUNCTION_NAME}"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "logsConsumer.handler"
  source_code_hash = "${data.archive_file.lambda_kinesis_stream_to_influxDB.output_base64sha256}"
  runtime          = "nodejs10.x"
  timeout          = 60

  environment {
    variables = {
      INFLUXDB_IP     = "${aws_instance.influxdb.public_ip}"
      INFLUXDB_BUCKET = "${var.INFLUXDB_BUCKET}"
      INFLUXDB_ORG    = "${var.INFLUXDB_ORG}"
      INFLUXDB_TOKEN  = "${var.INFLUXDB_TOKEN}"
    }
  }

}

resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn  = "${aws_kinesis_stream.kinesis_stream.arn}"
  function_name     = "${aws_lambda_function.lambda_kinesis_stream_to_influxDB.arn}"
  starting_position = "LATEST"
}