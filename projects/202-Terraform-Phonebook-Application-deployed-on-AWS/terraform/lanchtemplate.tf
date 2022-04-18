resource "aws_launch_template" "web_ser_LT" {
  name = "web_ser_LT"

  }
  image_id = data.aws_ami.my_ami.id
  instance_type = var.instance_type
  key_name = var.key_name

  network_interfaces {
    associate_public_ip_address = true
  }
  vpc_security_group_ids = ["web_ser_sg"]

  tag_specifications {
    resource_type = "instance"

  user_data = file ("./userdata.sh")
  