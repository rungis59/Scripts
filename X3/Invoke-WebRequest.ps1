Invoke-WebRequest -ContentType "application/json" `
>>                   -Method PUT `
>>                   -Body '{"index":{"max_regex_length":1500}}' `
>>                   -Uri "http://192.168.255.70:9200/sage.x3.functions.fr-fr/_settings?pretty"
