output "cf_dns_recordname" {
  value = cloudflare_dns_record.this.name
}

output "domain_names" {
  value = var.domain_names
}