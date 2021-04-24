broccoli.md
===

# Refresh templates

```
export REFRESH_TOKEN='U<jzn73@58EWtV48]voPf0QPm]9c`:=@K^WA[?@k]R9sZDEed<]sB4?qik<>RM4n'
export BROCCOLI_ADDR='http://lab02-broccoli.service.lab02.noroutine.me:9000'

curl -fvkH 'Content-Type: application/json' $BROCCOLI_ADDR/api/v1/templates/refresh  --data "{\"token\":\"$REFRESH_TOKEN\", \"returnTemplates\":false}"
```