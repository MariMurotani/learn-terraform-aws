# instruction guide
https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/python-image.html#python-image-instructions

## Building Docker Image

```
docker build --platform linux/arm64 -t docker-image:hello-world .
docker buildx build --platform linux/arm64 -t docker-image:hello-world .
```

## Debugging in local
```
docker run --platform linux/arm64 -p 9000:8080 docker-image:hello-world
```

- call API 
````
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
````

```
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"key1": "aaaa", "key2": "bbb", "key3": "ccc"}'
```
※ コードを変更した場合、build & runをしてから反映される

## linux用のbuild
※ MACでbuildしたイメージは動作しないので、別のbuildをしてPushする必要がある
```
# 1回目
docker buildx create --name lambda_image_builder --use
# 2回目
docker buildx use lambda_image_builder
docker buildx build --platform linux/amd64 -t docker-image:hello-world .
docker push 891377377740.dkr.ecr.ap-northeast-1.amazonaws.com/hello-world:latest

# 環境をlocal用に戻す
docker buildx use default
```


## Deploy to ECS
※ ECSのリポジトリはterraformで作成済み

```
# docker imageとリポジトリの関連付け
docker tag docker-image:hello-world 891377377740.dkr.ecr.ap-northeast-1.amazonaws.com/hello-world:latest
```

※ 2回目以降
リポジトリにPushする
```
docker push 891377377740.dkr.ecr.ap-northeast-1.amazonaws.com/hello-world:latest
```

```
# テスト
aws lambda invoke --function-name hello-world-function response.json
```


### E to E テスト
curl "https://0xuwggty0f.execute-api.ap-northeast-1.amazonaws.com/prod/ebihara" -d '{"key1": "aaaa", "key2": "bbb", "key3": "ccc"}'
