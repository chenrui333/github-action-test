GET https://mobile.twitter.com
User-Agent: hurl-mup/4.0.0

[Options]
location: true
HTTP/2 400

[Asserts]
header "perf" exists
header "expiry" exists
header "pragma" == "no-cache"
header "server" == "cloudflare tsa_b"
header "x-powered-by" == "Express"
header "cache-control" == "no-cache, no-store, must-revalidate, pre-check=0, post-check=0"
header "last-modified" exists
header "x-response-time" exists
header "x-connection-hash" exists
