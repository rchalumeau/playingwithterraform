# Generate certificate
resource "aws_acm_certificate" "cert" {

  domain_name       		= "${var.subdomain}.${var.domain}"
  validation_method 		= "DNS"

}

data "aws_route53_zone" "zone" {
  name         			= "${var.domain}."
  private_zone 			= false
}

resource "aws_route53_record" "cert_validation" {
  name    			= "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    			= "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id 			= "${data.aws_route53_zone.zone.id}"
  records 			= ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     			= 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         	= "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns 	= ["${aws_route53_record.cert_validation.fqdn}"]
}

# Subdomain pointing at lb
resource "aws_route53_record" "www" {
  zone_id 			= "${data.aws_route53_zone.zone.id}"
  name    			= "sreracha"
  type    			= "A"

  alias {
    name                   	= "${module.alb.dns_name}"
    zone_id                	= "${module.alb.load_balancer_zone_id}"
    evaluate_target_health 	= true
  }
}


