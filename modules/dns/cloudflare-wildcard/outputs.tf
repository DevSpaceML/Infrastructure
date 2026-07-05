output "main_dns_record_id" {
  value = cloudflare_dns_record.main.id
}

output "main_dns_record_name" {
  value = cloudflare_dns_record.main.name
}