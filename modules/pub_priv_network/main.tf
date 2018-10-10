locals {
  # cache the length of AZ list
  azc = "${length(var.azs)}"	
}


# Create a VPC
resource "aws_vpc" "this" {

  cidr_block                    = "${var.cidr}"
  enable_dns_hostnames          = true
  enable_dns_support   		= true

  tags {
    Name = "${var.name}"
  }
}


# Puboic subnets (one per AZ)
resource "aws_subnet" "public" {

  count				= "${local.azc}"

  vpc_id                  	= "${aws_vpc.this.id}"
  cidr_block              	= "${cidrsubnet(var.cidr, 8, 1 + count.index)}"

  availability_zone       	= "${element(var.azs, count.index)}"
  map_public_ip_on_launch 	= false

  tags {
    Name                          = "${var.name}-public-${count.index + 1}"
  }

}

# Private subnets (one per AZ)
resource "aws_subnet" "private" {

  count                         = "${local.azc}"

  vpc_id                        = "${aws_vpc.this.id}"
  cidr_block                    = "${cidrsubnet(var.cidr, 8, 10 + count.index)}"
  availability_zone             = "${element(var.azs, count.index)}"

  tags {
    Name                          = "${var.name}-private-${count.index + 1}"
  }


}

# Add internet gateway and associate it to public subnet
resource "aws_internet_gateway" "internet_gateway" {

  vpc_id 			= "${aws_vpc.this.id}"

  tags {
    Name                        = "${var.name}-igw"
  }

}

resource "aws_route_table" "public_routetable" {


  vpc_id 			= "${aws_vpc.this.id}"
  route {
    cidr_block 			= "0.0.0.0/0"
    gateway_id 			= "${aws_internet_gateway.internet_gateway.id}"
  }

  tags {
    Name                        = "${var.name}-rt"
  }

}

resource "aws_route_table_association" "public" {

  count				= "${local.azc}"

  subnet_id      		= "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id 		= "${aws_route_table.public_routetable.id}"
}


# Allow private subnets to access Internet 
resource "aws_eip" "gw" {

  count      			= "${local.azc}"
  vpc        			= true
  depends_on 			= ["aws_internet_gateway.internet_gateway"]

  tags {
    Name                        = "${var.name}-eip"
  }
}

resource "aws_nat_gateway" "gw" {

  count         	= "${local.azc}"
  subnet_id     	= "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id 	= "${element(aws_eip.gw.*.id, count.index)}"

}

# Route the non local traffic to internet
resource "aws_route_table" "private" {

  count  		= "${local.azc}"
  vpc_id 		= "${aws_vpc.this.id}"

  route {
    cidr_block 		= "0.0.0.0/0"
    nat_gateway_id 	= "${element(aws_nat_gateway.gw.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "private" {

  count          	= "${local.azc}"
  subnet_id      	= "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id 	= "${element(aws_route_table.private.*.id, count.index)}"

}

