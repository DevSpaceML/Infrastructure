resource "cloudflare_ruleset" "waf" {
  zone_id = data.cloudflare_zone.main.id
  name    = "Corp WAF Ruleset"
  kind    = "zone"
  phase   = "http_request_firewall_managed"

  rules = [
    {
        action = "block"
        filter {
        expression = "(http.request.uri.path contains \"/.env\") or (http.request.uri.path contains \"/config.php\") or (http.request.uri.path contains \"/wp-config.php\") or (http.request.uri.path contains \"/.git\") or (http.request.uri.path contains \"/.htaccess\") or (http.request.uri.path contains \"/.aws/credentials\")"
        }
    }
  ]
}

resource "cloudflare_ruleset" "corp_rate_limit" {
  zone_id = data.cloudflare_zone.main.id
  name    = "corp_rate_limit_ruleset"
  kind    = "zone"
  phase   = "http_request_firewall_managed"

  rules =[
    {
      action = "challenge"
      filter {
        expression = "(http.request.uri.path contains \"/api/\") and (cf.threat_score gt 10)"
      }
    }
  ]
}

resource "cloudflare_ruleset" "ephemeral_access" {
  zone_id = data.cloudflare_zone.main.id
  name    = "Ephemeral Access Ruleset"
  kind    = "zone"
  phase   = "http_request_firewall_managed"

  rules = [
    {
      action = "challenge"
      filter {
      expression = "(http.request.uri.path contains \"/ephemeral/\") and (cf.threat_score gt 5)"
     }
    }
}