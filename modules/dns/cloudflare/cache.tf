resource "cloudflare_ruleset" "cache_rules" {
    zone_id = data.cloudflare_zone.main.id
    name    = "Cache Ruleset"
    kind    = "zone"
    phase   = "http_request_cache_settings"

    rules = [ 
     {
        action = "set_cache_settings"
        action_parameters {
        cache = true
        edge_ttl {
            mode    = "override_origin"
            default = 86400  # 24h for static assets
        }
        browser_ttl {
            mode    = "override_origin"
            default = 3600
        }
        }
        expression  = "(http.host in {${join(" ", [for d in var.corp_domains : "\"${d}\""])}}) and (http.request.uri.path matches \"\\.(css|js|png|jpg|svg|woff2)$\")"
        description = "Cache corp static assets"
        enabled     = true
    },
    # Ephemeral cluster traffic — always bypass cache
    {
      action = "set_cache_settings"
      action_parameters = {
      cache = false
     }
      expression  = "http.host matches \".*\\.ephemeral\\.salientapps\\.com\""
      description = "Bypass cache for ephemeral cluster traffic"
      enabled     = true
   } 
 ]
}