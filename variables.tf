variable "region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "torus"
}

variable "PROJECT" {
  default = "Monitoring"
}

variable "ENVIROMENT" {
  default = "dev"
}

variable "OWNER" {
  default = "erick.yataco.s@gmail.com"
}

variable "REGION" {
  default = "us-east-1"
}

variable "PATH_TO_PUBLIC_KEY" {
  default=""
}

variable "PATH_TO_PRIVATE_KEY" {
  default=""
}

variable "SHARD_COUNT" {
  default="1"
}

variable "RETENTION_PERIOD" {
  default="24"
}

variable "SUBSCRIPTION_FILTER_PATTERN" {  
  default ="[report_name=\"REPORT\", request_id_name=\"RequestId*\", request_id_value, duration_name=\"Duration*\", duration_value, duration_unit=\"ms\", billed_duration_name_1=\"Billed\", bill_duration_name_2=\"Duration*\", billed_duration_value, billed_duration_unit=\"ms\", memory_size_name_1=\"Memory\", memory_size_name_2=\"Size*\", memory_size_value, memory_size_unit=\"MB\", max_memory_used_name_1=\"Max\", max_memory_used_name_2=\"Memory\", max_memory_used_name_3=\"Used*\", max_memory_used_value, max_memory_used_unit=\"MB\"]"
}

variable "INFLUXDB_ORG" {
  default = "torus"
}

variable "INFLUXDB_BUCKET" {
  default = "lambda"
}

variable "INFLUXDB_USER" {
  default = "ErickYataco"
}

variable "INFLUXDB_PASSWORD" {
  default = "something"
}

variable "INFLUXDB_TOKEN" {
  default = "something"
}


variable "LAMBDA_FUNCTION_NAME" {
  default = "logsConsumer"
} 

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
    eu-west-1 = "ami-844e0bf7"
    ca-central-1 = "ami-cb5ae7af"
  }
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "INSTANCES_NUMBER" {
  default = 1
}

variable "SUBNET_PUBLIC" {  
  default = ""
}