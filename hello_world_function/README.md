## Building Docker Image

```
docker build --platform linux/arm64 -t docker-image:hello-world .
```

## Debugging in local
```
docker run --platform linux/arm64 -p 9000:8080 docker-image:hello-world
```

- call API 
````
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
````

※ コードを変更した場合、build & runをしてから反映される

## Deploy to ECS

