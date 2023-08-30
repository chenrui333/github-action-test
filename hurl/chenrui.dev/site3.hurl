GET https://chenrui.dev
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36
Cache-Control: no-cache, no-store, must-revalidate
Pragma: no-cache
Expires: 0
DNT: 1
Connection: close
Accept-Encoding: identity

[Options]
location: true

HTTP/2 200
cache-control: max-age=0, private, must-revalidate

[Asserts]
header "vary" == "X-Requested-With, X-PJAX-Container, Turbo-Frame, Turbo-Visit, Accept-Encoding, Accept, X-Requested-With"
header "etag" exists
header "x-github-request-id" exists
cookie "_gh_sess" exists
cookie "_octo" exists
cookie "logged_in" == "no"
