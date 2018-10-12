# auto determine subnets cidr ased on number of az.
# As locals cannot use count, therefore, twist template
data "template_file" "public_cidr" {

  count         = "${var.number_zones}"
  template      = "$${cidr}"

  vars {
    "cidr"      = "${cidrsubnet(var.cidr, 8, 1 + count.index)}"
  }
}

data "template_file" "private_cidr" {

  count         = "${var.number_zones}"
  template      = "$${cidr}"

  vars {
    cidr        = "${cidrsubnet(var.cidr, 8, 10 + count.index)}"
  }
}

# Determine the availability zones according to the expected number, as well as cidr of subnets (
data "aws_availability_zones" "available" {}

locals {
  az            = "${slice(data.aws_availability_zones.available.names, 0, var.number_zones)}"
  public        = [ "${data.template_file.public_cidr.*.rendered}" ]
  private       = [ "${data.template_file.private_cidr.*.rendered}" ]

  target_groups = "${list(
                        map("name", "${var.prefix}-frontend",
                            "backend_protocol", "HTTP",
                            "backend_port", 80,
                            "target_type", "ip",
                            "health_check_path", "/?q=1"
                        )
  )}"
}

# Policy for access log bucket

locals {
  bucket	= "${var.prefix}-bucket" 
}

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowToPutLoadBalancerLogsToS3Bucket"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket}"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}



