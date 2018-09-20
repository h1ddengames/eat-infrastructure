resource "aws_lb" "Load-Balancer"{
  name               = "Load-Balancer"
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = false

  subnets            = ["${aws_subnet.pubsubnet1.id}","${aws_subnet.pubsubnet2.id}","${aws_subnet.pubsubnet3.id}"]
}


/*
resource "aws_alb_listener" "HTTP-Listener"{
	load_balancer_arn = "${aws_lb.Load-Balancer.id}"
	port = 80
	default_action {
		type = "forward"
		target_group_arn = "${aws_alb_target_group.HTTP-Group.arn}"
	}
}

resource "aws_alb_target_group" "HTTP-Group" {
  name     = "WS-Group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}


Do this after certs are up.

resource "aws_alb_listener" "HTTPS-Listener"{
	load_balancer_arn = "${aws_lb.Load-Balancer.id}"
	port = 443
	ssl_policy = "ELBSecurityPolicy-2016-08"
	certificate_arn = "{aws_acm_certificate.cert.certificate_arn}"
	default_action {
		type = "forward"
		target_group_arn = "${aws_alb_target_group.TSL-Group.arn}"
	}
}



resource "aws_lb_target_group_attachment" "HTTP-attachment-1" {
  target_group_arn = "${aws_lb_target_group.HTTP-Group.arn}"
  target_id        = "${aws_instance.web.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTP-attachment-2" {
  target_group_arn = "${aws_lb_target_group.HTTP-Group.arn}"
  target_id        = "${aws_instance.web2.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTPS-attachment-1" {
  target_group_arn = "${aws_lb_target_group.HTTPS-Group.arn}"
  target_id        = "${aws_instance.web.id}"
  port             = 443
}

resource "aws_lb_target_group_attachment" "HTTPS-attachment-2" {
  target_group_arn = "${aws_lb_target_group.HTTPS-Group.arn}"
  target_id        = "${aws_instance.web2.id}"
  port             = 443

}

Do this when we get certs working:

resource "aws_alb_target_group" "TSL-Group" {
  name     = "TSL-Group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = "${aws_vpc.main.id}"
}
*/
	
resource "aws_acm_certificate" "cert" {
	domain_name = "fa480.club"
	subject_alternative_names = ["www.fa480.club", "blog.fa480.club"]
	validation_method = "DNS"
}

resource "aws_route53_zone" "main" {
  name         = "fa480.club"
}

resource "aws_route53_zone" "blog" {
  name         = "blog.fa480.club"
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "www.fa480.club"
  type    = "A"
  ttl     = "300"
  records = ["10.0.0.1"]
}


# Create a new instance of the latest Ubuntu Server on an
# t2.micro node with an AWS Tag naming it "Blog Server 2"

data "aws_ami" "ubuntu_server2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web2" {
  ami           = "ami-51537029"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.BlogSG.id}"]
  subnet_id = "${aws_subnet.privsubnet1.id}"
  tags {
    Name = "Blog Server 2"
  }
}


# Create a new instance of the latest Ubuntu Server on an
# t2.micro node with an AWS Tag naming it "Blog Server 1"


data "aws_ami" "ubuntu_server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "web" {
  ami           = "ami-51537029"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.BlogSG.id}"]
  subnet_id = "${aws_subnet.privsubnet1.id}"
  tags {
    Name = "Blog Server 1"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEArVp0Hlbm4c6YyqR++WIhaNTr32I+DGWP8uBvbyc38PNcfjYTYYywOn9fn5wJSHL4vJ5dexN/1SM7tNQI9kZ7Z7khz6FDdXDJ+SW9ZkAUx8oGjGIqyDsUU67YqVIZ8wlY03U+82NAYA6EmpfE1UuwSsMUKqoPW1M0QHGXkBhgNCiIv7Q08NI8314KFQwVml4bkE+D6eFYKYYizgnvIZqciMl8sOZMJEtZ/RzZ/LV0woFHY/YJkCMt0laAVnFHqJRGGYAJsc4PbyC29vTZz7jVs5zy9JCuWbRZ+k5fPyH3JqOUD5VEOcaX2WobeweixFsuXW44zaROJN7E65L85lbHSQ== rsa-key-20180918"
  }
