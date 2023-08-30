GET https://chenrui.dev
User-Agent: hurltest/4.0.0

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
