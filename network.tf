
#-------------------NAT Gateways with Elastic IPs----------------------

resource "aws_eip" "nat" {
  count = length([for cidr in var.private_subnet_cidrs: cidr])
  vpc = true
  tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-nat-gw-eip-${count.index + 1}"})
}

resource "aws_nat_gateway" "nat" {
  count = length([for cidr in var.private_subnet_cidrs: cidr])
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = element(var.public_subnets_ids_to_private, count.index)
  tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-nat-gw-${count.index + 1}"})
}


#-------------------Private Subnets and Routing-------------------------

resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnet_cidrs
  vpc_id = var.vpc_id
  cidr_block = each.key
  availability_zone = each.value
  tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-private-subnet-${each.key}"})
}

resource "aws_route_table" "private_subnets" {
  count = length([for cidr in var.private_subnet_cidrs: cidr])
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-route-private-subnet-${element(keys(var.private_subnet_cidrs), count.index)}"})
}

resource "aws_route_table_association" "private_subnets" {
  count = length([for cidr in var.private_subnet_cidrs: cidr])
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id = element([for network in aws_subnet.private_subnets: network.id], count.index)
}
#-------------------Subnet Group----------------------

resource "aws_db_subnet_group" "default" {
  name       = "rds_${var.app_name}_subnet_group"
  subnet_ids = [for network in aws_subnet.private_subnets: network.id]

  tags = merge(var.shared_tags, { Name = "${lookup(var.shared_tags, "Env", "")}-rds-subnet-group-${var.app_name}"})
}

#-------------------Security Group---------------------

resource "aws_db_security_group" "default" {
  name = "rds_${var.app_name}_sg"

  ingress {
      cidr = var.rds_sg_allowed_cidr
    }
  }

