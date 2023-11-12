# What`s this
- awsの料金をline notifyで通知するためのスクリプトです。
- rubyで書かれています。

# 開発
- serverless frameworkでインフラを設定しております。
- sls deploy後に、LINE_TOKENの環境変数の設定を行なってください。
- ローカルでの実行は考慮してません。

# コマンド
```
sls deploy
```

# todo
- ローカルでデバックができるようにする
- コンテナ環境でsls deployを実行できるようにする