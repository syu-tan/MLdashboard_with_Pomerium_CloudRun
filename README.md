# Cloud Run 認証付き実験管理ダッシュボード


## 使い方

１． 自分のgithubレポジトリにまるっとコピーする。
２． 認証付きダッシュボードの設定を更新する。
３． github actionsのワークフローを起動するために、github secretsのアップデート
４． terraformの変数をアップデートしてpull requestしてmergeする。
５． GCP上で立ち上がる。

## 1. 認証付きダッシュボード

### 1-1. tensorboard
```
cd tensorboard-cloudrun
gcloud builds submit --tag asia.gcr.io/(YOUR_PROJECT)/tensorboard-cloudrun --project (YOUR_PROJECT)
```
でgcrコンテナに登録しておきます。(asiaは、データセンターの位置が物理的に近いのでアップロードなどが速いらしい。)

認証用コンテナの設定には、まだ立ち上がってない認証用コンテナのURLやtensorboardのURLが必要になります。
なので、一度Cloud Runでアプリを立ち上げてみます。
```
gcloud run deploy tensorboard-cloudrun \
    --image=asia.gcr.io/(YOUR_PROJECT)/tensorboard-cloudrun \
    --region asia-northeast1 \
    --memory 512Mi \
    --cpu 1000m \
    --platform managed \
    --update-env-vars EVENT_FILE_PATH=gs://(YOUR)/(PATH)/(TO)/(TENSORBOARD),RELOAD_INTERVAL=600
```
デプロイしたものはアクセスが自由にできるのであとで必ず消しましょう。
このときに以下のコマンドを入力することで、ダッシュボードのURLがわかります。
```
gcloud run services describe tensorboard-cloudrun \
    --platform managed \
    --region asia-northeast1 \
    --format 'value(status.address.url)'
```

`https://tensorboard-cloudrun-(YOUR_URL)`
ここでの（YOUR_URL)は、リージョンとアカウントによって違うようです（あいまい）。
認証用のコンテナのURL、は上記のURLの`tensorboard-cloudrun`の部分だけが異なるので、控えておきます。（この部分は運用上あまり良くないので変えたい）

<b>この確認が終わったらサービスを消去しておきます。</b>
terraformでデプロイをするときにエラーになるので必ず消しておきましょう。

```
gcloud run services delete tensorboard-cloudrun \
    --platform managed \
    --region asia-northeast1
```
消えてるのか確認します。
```
gcloud run services list
```
これで`tensorboard-cloudrun`が出力されなければ無事に消えています。

### 1-2. 認証用コンテナ設定
[pomerium](https://github.com/pomerium/pomerium)をcloud run上にデプロイして認証を行っています。
GCP側のOauth認証の設定などは[GCPのOauth認証作成手順](https://cloud.google.com/run/docs/authenticating/end-users?hl=ja#google-sign-in)や[pomeriumのデプロイ手順](https://www.pomerium.com/guides/cloud-run.html#deploy)を参考にしてください。

GCPに登録するOatuth2.0のクライアントID（APIとサービス／認証情報／Oauth2.0 クライアントID）の承認済リダイレクトURIに先ほど立ち上げたtensorboardのURLをつかって、
```
https://pomerium-cloudrun-(YOUR_URL)/callback
https://pomerium-cloudrun-(YOUR_URL)/oauth2/callback
```
を追加しておいてください。

pomeriumのデプロイ手順通りに薦めると、GCP secretsに設定の登録が必要ですが、`config.yaml`については、

```
authenticate_service_url: https://pomerium-cloudrun-(YOUR_URL)/
```
と記載して、あとは上記のサイトの通りにGCP secretsに設定の登録をします。

pomeriumのリダイレクトするURLを記載しておく`policy.yaml`も
```
# policy.template.yaml
# see https://www.pomerium.com/reference/#policy
- from: https://pomerium-cloudrun-(YOUR_URL)
  to: https://tensorboard-cloudrun-(YOUR_URL)
  allowed_domains:
    - example.com
  enable_google_cloud_serverless_authentication: true
- from: https://pomerium-cloudrun-(YOUR_URL)
  to: https://httpbin.org
  pass_identity_headers: true
  allowed_domains:
    - example.com
```
としておきます。
<b> `policy.yaml`でのメールアドレスやドメインを指定することで、認証のスコープを変えることができます。</b>

ここまでできれば、`infra/tf/sandbox.tfvars`を書き換えてください

```
#provider
project = "(YOUR_PROJECT)"
region  = "asia-northeast1"
zone    = "asia-northeast1-a"
env     = "sandbox"

# cloud run 
dashboard_name         = "tensorboard-cloudrun"
dashboard_cpu          = "1000"
dashboard_memory       = "512"
event_filepath         = "gs://(YOUR)/(PATH)/(TO)/(TENSORBOARD)"
tensorboard_reroadtime = "600"
autoscaling_max_num    = "2"

# auth cloud run 
auth_name      = "pomerium-cloudrun"
auth_cpu       = "1000"
auth_memory    = "512"
encoded_policy = "(YOUR_POMERIUM_POLISY_ENCODE_BY_BASE64)"

```
`(YOUR_POMERIUM_POLISY_ENCODE_BY_BASE64)`については先程書いた`policy.yaml`をbase64でエンコードして貼り付けてください。


## 2． github actionsの設定
github actionsをつかってCI/CD化しています。
github secretの以下のパラメータをアップデートしてください。


| パラメータ| 説明 |
| ------------- | ------------- |
| GCLOUD_PROJECT_ID | GCPのプロジェクト名  |
| GCLOUD_SERVICE_KEY | base64でエンコードしたprojectのservice account key のcredential |


詳しくは[公式](https://github.com/google-github-actions/setup-gcloud)を参考にしてください。

## 3. github actionsを動かす
terraformが書き換わっているので、pull request→mergeすると、github actionsが動いてGCP上にデプロイされます。

## A.(Optional)Terraformをローカルで動かす場合

ローカル PC から Terraform を実行して GCP の Sandbox 環境を構築する手順を記載します。
GitHub Actions 経由でした Terraform を実行できない様になっています。

### A-1. gcloud sdk のインストール

#### MacOS へのインストール

```shell
# gcloud sdkをDLする．
$ curl https://sdk.cloud.google.com | bash

# インストール スクリプトを実行して、Cloud SDK ツールをパスに追加
$ ./google-cloud-sdk/install.sh

# shell を再起動します。
$ exec -l $SHELL

# GCPにログインする
$ gcloud auth login

# gcloud 環境を初期化します。
$ gcloud init

# クレデンシャルを作成する。
gcloud auth application-default login

# クレデンシャルが作成されたかを確認する。
$ cat ~/.config/gcloud/application_default_credentials.json
```

#### Windows へのインストール

1. [google-cloud-sdk.zip](https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip?hl=ja) をダウンロードしてその内容を抽出します（ダウンロードしたファイルを右クリックして [すべて展開] を選択します.）

2. `google-cloud-sdk\install.bat` スクリプトを起動して、インストールの指示に沿って操作します.

3. インストールが完了したら、コマンド プロンプト（`cmd.exe`）を再起動します.

4. gcloud 環境を初期化します。

```shell
C:\> gcloud init
```

### A-2. GCP プロジェクト設定の追加

```shell
# GCPプロジェクトの設定をする．
$ gcloud config configurations create (YOUR_PROJECT)
$ gcloud config set project (YOUR_PROJECT)
$ gcloud config set account (YOUR_EMAIL)@example.com

# 登録したGCPプロジェクト設定の確認
# 例． IS_ACTIVATEが[true]になっているのが有効化されているプロジェクト
$ gcloud config configurations list

NAME              IS_ACTIVE  ACCOUNT                 PROJECT           COMPUTE_DEFAULT_ZONE  COMPUTE_DEFAULT_REGION
default           False      (YOUR_EMAIL)@example.com  (YOUR_PROJECT_ID)  asia-northeast1-a     asia-northeast1
(YOUR_PROJECT)    True       (YOUR_EMAIL)@example.com  (YOUR_PROJECT_ID)

# GCPプロジェクト設定の有効化
$ gcloud config configurations activate (YOUR_PROJECT)
```

### A-3. Terraform のインストール

#### MacOS へのインストール

```shell
# Terraformのバージョン管理ツールtfenvをインストール
$ brew install tfenv

# tfenvでバージョンを指定してterraformをインストール (必ず0.13.5をインストールしてください)
$ tfenv install 0.13.5

# 利用するバージョンを切り替える
$ tfenv use 0.13.5

# 現在インストールしているバージョンを確認する．
$ tfenv list

# TFLintをインストール
$ brew tap wata727/tflint
$ brew install tflint
```

#### Windows へのインストール

1. 次のダウンロードサイトから、環境に合わせてファイルをダウンロード. (必ず 0.13.5 をインストールしてください)

- [Terraform ダウンロードサイト](https://www.terraform.io/downloads.html)

2. ダウンロードした terraform.exe を PATH の通っているフォルダに配置.

3. Terraform 0.13.5 がインストールされたことを確認.

```shell
C:\> terraform --version
```




### Done
- [x] CloudRunによる認証付きダッシュボード(tensorboard)の作成 
- [x] 認証機構とダッシュボードのterraform化
- [x] 認証機構とダッシュボードのCI/CD化

### ToDo
上の方から順番に行う。
- [ ] MLFlowへの対応。
- [ ] URLやpomeriumの秘匿情報をgithub　Actionsでまとめる。
- [ ] 認証機構のpolicyをbase64でエンコードしているが、ここもterraformで自動化する。