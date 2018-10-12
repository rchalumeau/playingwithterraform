provider "aws" {
  region     = "${var.region}"
  profile    = "terraform"
  version = "~> 1.39"
}

# Standard providers
provider "random"    { version = "~>  2.0" }
provider "template"  { version = "~> 1.0" }

