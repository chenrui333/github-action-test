GET https://google.com
User-Agent: hurl-mup/4.0.0

HTTP/2 301
Location: https://www.google.com/

[Asserts]
header "content-type" == "text/html; charset=UTF-8"
header "cache-control" == "public, max-age=2592000"
header "content-encoding" not exists
header "server" == "gws"
header "alt-svc" == "h3=\":443\"; ma=2592000,h3-29=\":443\"; ma=2592000"

GET https://google.com
User-Agent: hurl-mup/4.0.0

[Options]
location: true

HTTP/2 200

[Asserts]
header "content-type" == "text/html; charset=ISO-8859-1"
header "p3p" == "CP=\"This is not a P3P policy! See g.co/p3phelp for more info.\""
header "cache-control" == "private, max-age=0"
header "expires" exists
header "content-encoding" not exists
header "server" == "gws"
header "alt-svc" == "h3=\":443\"; ma=2592000,h3-29=\":443\"; ma=2592000"
