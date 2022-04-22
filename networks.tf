data "aws_availability_zones" "available" {}

resource "aws_vpc" "nonprod_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name =  "nonprod-${local.prefix}"
    Environment = "nonprod"
  })
}

resource "aws_vpc" "prod_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name =  "prod-${local.prefix}"
    Environment = "prod"
  })
}

resource "aws_security_group" "nonprod_sg" {
  
  depends_on  = [aws_vpc.nonprod_vpc]
  vpc_id      = aws_vpc.nonprod_vpc.id
  name        = "nonprod-${local.prefix}"
  description = "Default security group to allow inbound/outbound from the VPC"

  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = [443, 3306]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
    tags = merge(var.tags, {
        Name =  "nonprod-${local.prefix}"
        Environment = "nonprod"
  })
}

resource "aws_security_group" "prod_sg" {
  
  depends_on  = [aws_vpc.prod_vpc]
  vpc_id      = aws_vpc.prod_vpc.id
  name        = "prod-${local.prefix}"
  description = "Default security group to allow inbound/outbound from the VPC"

  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = [443, 3306]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
    tags = merge(var.tags, {
        Name =  "prod-${local.prefix}"
        Environment = "prod"
  })
}

resource "aws_subnet" "nonprod_public_subnet" {
  vpc_id = "${aws_vpc.nonprod_vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr_block, 10, 0)}" 
  availability_zone= "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name =  "nonprod-public-${local.prefix}-${data.aws_availability_zones.available.names[0]}"
    Environment = "nonprod"
  })
}

resource "aws_subnet" "prod_public_subnet" {
  vpc_id = "${aws_vpc.prod_vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr_block, 10, 0)}" 
  availability_zone= "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name =  "prod-public-${local.prefix}-${data.aws_availability_zones.available.names[0]}"
    Environment = "prod"
  })
}

resource "aws_subnet" "nonprod_private_subnets" {
  depends_on = [aws_subnet.nonprod_public_subnet]
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.nonprod_vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr_block, 3, count.index + 1)}" 
  availability_zone= "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name =  "nonprod-private-${local.prefix}-${data.aws_availability_zones.available.names[count.index]}"
    Environment = "nonprod"
  })
}

resource "aws_subnet" "prod_private_subnets" {
  depends_on = [aws_subnet.prod_public_subnet]
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.prod_vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc_cidr_block, 3, count.index + 1)}" 
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name =  "prod-private-${local.prefix}-${data.aws_availability_zones.available.names[count.index]}"
    Environment = "prod"
  })
}

resource "aws_internet_gateway" "nonprod_igw" {
  vpc_id = aws_vpc.nonprod_vpc.id
   tags = merge(var.tags, {
     Name =  "nonprod-igw-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id
   tags = merge(var.tags, {
     Name =  "prod-igw-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_eip" "nonprod_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.nonprod_igw]
  tags = merge(var.tags, {
     Name =  "nonprod-eip-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_eip" "prod_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.prod_igw]
  tags = merge(var.tags, {
     Name =  "prod-eip-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_nat_gateway" "nonprod_ngw" {
  allocation_id = aws_eip.nonprod_eip.id
  subnet_id     = aws_subnet.nonprod_public_subnet.id
  depends_on    = [aws_internet_gateway.nonprod_igw]
  tags = merge(var.tags, {
     Name =  "nonprod-ngw-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_nat_gateway" "prod_ngw" {
  allocation_id = aws_eip.prod_eip.id
  subnet_id     = aws_subnet.prod_public_subnet.id
  depends_on    = [aws_internet_gateway.prod_igw]
  tags = merge(var.tags, {
     Name =  "prod-ngw-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_route_table" "nonprod_private_rt" {
  vpc_id = aws_vpc.nonprod_vpc.id
  tags = merge(var.tags, {
     Name =  "nonprod-private-rt-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_route_table" "prod_private_rt" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = merge(var.tags, {
     Name =  "prod-private-rt-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_route_table" "nonprod_public_rt" {
  vpc_id = aws_vpc.nonprod_vpc.id
  tags = merge(var.tags, {
     Name =  "nonprod-public-rt-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_route_table" "prod_public_rt" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = merge(var.tags, {
     Name =  "prod-public-rt-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_route_table" "nonprod_igw_rt" {
  vpc_id = aws_vpc.nonprod_vpc.id
  tags = merge(var.tags, {
     Name =  "nonprod-igw-rt-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_route_table" "prod_igw_rt" {
    
  vpc_id = aws_vpc.prod_vpc.id
  tags = merge(var.tags, {
     Name =  "prod-igw-rt-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_route_table_association" "nonprod_private_rta" {

  depends_on     = [aws_subnet.nonprod_private_subnets]
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${aws_subnet.nonprod_private_subnets[count.index].id}" 
  route_table_id = aws_route_table.nonprod_private_rt.id
}

resource "aws_route_table_association" "prod_private_rta" {

  depends_on     = [aws_subnet.prod_private_subnets]
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${aws_subnet.prod_private_subnets[count.index].id}" 
  route_table_id = aws_route_table.prod_private_rt.id
}

resource "aws_route_table_association" "nonprod_public_rta" {

  depends_on     = [aws_subnet.nonprod_public_subnet]
  subnet_id      = aws_subnet.nonprod_public_subnet.id
  route_table_id = aws_route_table.nonprod_public_rt.id
}

resource "aws_route_table_association" "prod_public_rta" {

  depends_on     = [aws_subnet.prod_public_subnet]
  subnet_id      = aws_subnet.prod_public_subnet.id
  route_table_id = aws_route_table.prod_public_rt.id
}

resource "aws_route" "nonprod_private_ngw" {
  route_table_id         = aws_route_table.nonprod_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nonprod_ngw.id
}

resource "aws_route" "nonprod_public_igw" {
  route_table_id         = aws_route_table.nonprod_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.nonprod_igw.id
}

resource "aws_route" "prod_private_ngw" {
  route_table_id         = aws_route_table.prod_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.prod_ngw.id
}

resource "aws_route" "prod_public_igw" {
  route_table_id         = aws_route_table.prod_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prod_igw.id
}

resource "aws_vpc_endpoint" "nonprod_s3" {
  vpc_id       = aws_vpc.nonprod_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.nonprod_private_rt.id]

  tags = merge(var.tags, {
     Name =  "nonprod-vpce-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_vpc_endpoint" "prod_s3" {
  vpc_id       = aws_vpc.prod_vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.prod_private_rt.id]

  tags = merge(var.tags, {
     Name =  "prod-vpce-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_vpc_endpoint" "nonprod_sts" {
  vpc_id       = aws_vpc.nonprod_vpc.id
  service_name = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type = "Interface"
  subnet_ids = "${aws_subnet.nonprod_private_subnets.*.id}" 
  security_group_ids = [
    aws_security_group.nonprod_sg.id,
  ]

  private_dns_enabled = true
  tags = merge(var.tags, {
     Name =  "nonprod-vpce-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_vpc_endpoint" "prod_sts" {
  vpc_id       = aws_vpc.prod_vpc.id
  service_name = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type = "Interface"
  subnet_ids = "${aws_subnet.prod_private_subnets.*.id}" 
  security_group_ids = [
    aws_security_group.prod_sg.id,
  ]

  private_dns_enabled = true
  tags = merge(var.tags, {
     Name =  "prod-vpce-${local.prefix}"
     Environment = "prod"
  })
}

resource "aws_vpc_endpoint" "nonprod_kinesis" {
  vpc_id       = aws_vpc.nonprod_vpc.id
  service_name = "com.amazonaws.${var.region}.kinesis-streams"
  vpc_endpoint_type = "Interface"
  subnet_ids = "${aws_subnet.nonprod_private_subnets.*.id}" 
  security_group_ids = [
    aws_security_group.nonprod_sg.id,
  ]

  private_dns_enabled = true
  tags = merge(var.tags, {
     Name =  "nonprod-vpce-${local.prefix}"
     Environment = "nonprod"
  })
}

resource "aws_vpc_endpoint" "prod_kinesis" {
  vpc_id       = aws_vpc.prod_vpc.id
  service_name = "com.amazonaws.${var.region}.kinesis-streams"
  vpc_endpoint_type = "Interface"
  subnet_ids = "${aws_subnet.prod_private_subnets.*.id}" 
  security_group_ids = [
    aws_security_group.prod_sg.id,
  ]

  private_dns_enabled = true
  tags = merge(var.tags, {
     Name =  "prod-vpce-${local.prefix}"
     Environment = "prod"
  })
}
