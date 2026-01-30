GET {{host}}/healthCheck

HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.healthy" == true
jsonpath "$.db" == true
