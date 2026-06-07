# Security headers for corp site
resource "cloudflare_ruleset" "security_headers" {
  zone_id = data.cloudflare_zone.main.id
  name    = "Security headers"
  kind    = "zone"
  phase   = "http_response_headers_transform"

  rules = [ 
    {
        action = "rewrite"
        action_parameters {
            headers {
                name      = "Strict-Transport-Security"
                operation = "set"
                value     = "max-age=31536000; includeSubDomains; preload"
            }
            headers {
                name      = "X-Frame-Options"
                operation = "set"
                value     = "DENY"
            }
            headers {
                name      = "X-Content-Type-Options"
                operation = "set"
                value     = "nosniff"
            }
            headers {
                name      = "Referrer-Policy"
                operation = "set"
                value     = "strict-origin-when-cross-origin"
            }
        }
        expression  = "(http.host in {${join(" ", [for d in var.corp_domains : "\"${d}\""])}})"
        description = "Security headers on corp domains"
        enabled     = true
    } 
 ]
}

# Authenticated origin pulls — forces Cloudflare mTLS to your AWS origin
resource "cloudflare_zone_settings_override" "security" {
  zone_id = data.cloudflare_zone.main.id
  settings {
    ssl                      = "strict"           # full end-to-end TLS
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    tls_client_auth          = "on"               # authenticated origin pulls
  }
}