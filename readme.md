# What`s this
- awsの料金をline notifyで通知するためのスクリプトです。
- rubyで書かれています。

# 開発
- serverless frameworkでインフラを設定しております。

# ローカル開発用
```
cp sample.env .env
```

# コマンド
## コマンド実行環境のbuild
```
# build
docker compose build

# コンテナの起動
docker compose up -d

# slsコンテナにbashでログイン
docker compose exec sls bash --login
```

## slsコンテナ内でのコマンド
```
# アプリケーションが配置されているディレクトリに移動
cd /opt/app

# アプリケーションの初期化
sh init.sh

# ローカルでのlambda関数実行
sls invoke local --function notify

# 本番デプロイ
sls deploy --stage production
```
