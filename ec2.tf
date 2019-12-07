
resource "aws_security_group" "influx-sg" {
  name        = "${var.PROJECT}-ec2-sg-${var.ENVIROMENT}"
  description = "security group for influxdb grafana instance"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  tags =  {
    Name        = "${var.PROJECT}-ec2-sg-${var.ENVIROMENT}"
    Owner       = "${var.OWNER}"
    Enviroment  = "${var.ENVIROMENT}"
    Tool        = "Terraform"
  }
}

data "template_file" "init" {
  template = "${file("./scripts/init.sh")}"
  vars = {
    region    = "${var.REGION}"
    project   = "${var.PROJECT}"    
  }
}
resource "aws_key_pair" "mykeypair" {
  key_name   = "${var.PROJECT}-key-influx-${var.ENVIROMENT}"
  public_key = "${file(var.PATH_TO_PUBLIC_KEY)}"
}


resource "aws_instance" "influxdb" {
  ami                   = "${var.AMIS[var.REGION]}"
  instance_type         = "${var.INSTANCE_TYPE}"
  key_name              = "${aws_key_pair.mykeypair.key_name}"    
  user_data             = "${data.template_file.init.rendered}"
  security_groups       = ["${aws_security_group.influx-sg.id}"]
  subnet_id             = "${var.SUBNET_PUBLIC}"
  
  # TODO aws_volume_attachment
  # root_block_device {
  #   volume_type           = "gp2"
  #   volume_size           = 30
  #   delete_on_termination = false
  # }

  tags =  {
    Name        = "${var.PROJECT}-ec2-influx2-${var.ENVIROMENT}"
    Owner       = "${var.OWNER}"
    Enviroment  = "${var.ENVIROMENT}"
    Tool        = "Terraform"
  }

  provisioner "remote-exec" {
    inline = [
      "influx setup -b ${var.INFLUXDB_BUCKET} -o ${var.INFLUXDB_ORG} -u ${var.INFLUXDB_USER} -p ${var.INFLUXDB_PASSWORD} -r -1 -t ${var.INFLUXDB_TOKEN} -f"
    ]
  }
  connection {
    host     = "${aws_instance.influxdb.public_ip}"
    type     = "ssh"
    user     = "ubuntu"
    # password = ""
    private_key = "${file(var.PATH_TO_PRIVATE_KEY)}"
  }

}

output "influxdb_ip" {
  value = "${aws_instance.influxdb.public_ip}"
}
