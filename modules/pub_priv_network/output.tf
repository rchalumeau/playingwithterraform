output "vpc_id" {
	value = "${aws_vpc.this.id}"
}

output "public_cidrs" {
	value = [ "${aws_subnet.public.*.cidr_block}" ]
}

output "public_ids" {
	value = [ "${aws_subnet.public.*.id}" ]
}

output "private_cidrs" {
        value = [ "${aws_subnet.private.*.cidr_block}" ]
}

output "private_ids" {
        value = [ "${aws_subnet.private.*.id}" ]
}




