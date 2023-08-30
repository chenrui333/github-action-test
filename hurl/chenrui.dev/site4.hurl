GET https://chenrui.dev
User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/116.0.5845.146 Mobile/15E148 Safari/604.1
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
