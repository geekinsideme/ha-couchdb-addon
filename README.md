# Home Assistant CouchDB Add-on

Apache CouchDBをHome Assistantアドオンとして実行するためのリポジトリです。

## 特徴

- Apache CouchDB 3.5.0
- Web UI (Fauxton) によるデータベース管理
- RESTful HTTP API
- 永続的なデータストレージ

## インストール

1. Home Assistantの「設定」→「アドオン」→「アドオンストア」を開く
2. 右上の「...」メニューから「リポジトリの追加」を選択
3. このリポジトリのURL `https://github.com/geekinsideme/ha-couchdb-addon` を追加
4. CouchDBアドオンをインストール

## 設定

### 必須設定
- **couchdb_user**: 管理者ユーザー名（デフォルト: admin）
- **couchdb_password**: 管理者パスワード（必須）

### 設定例
```yaml
couchdb_user: admin
couchdb_password: your_secure_password
```

## WebUI (Fauxton) へのアクセス

CouchDBのWeb管理インターフェース「Fauxton」にアクセスできます：

1. **アクセスURL**: `http://[YOUR_HA_IP]:5984/_utils/`
2. **ログイン情報**:
   - ユーザー名: 設定した `couchdb_user`
   - パスワード: 設定した `couchdb_password`

### Fauxtonでできること
- データベースの作成・削除・管理
- ドキュメントの作成・編集・削除
- インデックスの管理
- レプリケーションの設定
- システム状態の監視

## API使用方法

### 基本的なAPIエンドポイント
- **サーバー情報**: `GET http://[YOUR_HA_IP]:5984/`
- **データベース一覧**: `GET http://[YOUR_HA_IP]:5984/_all_dbs`
- **データベース作成**: `PUT http://[YOUR_HA_IP]:5984/database_name`
- **ドキュメント作成**: `POST http://[YOUR_HA_IP]:5984/database_name`

### 認証
Basic認証を使用します：
```bash
curl -X GET http://admin:password@[YOUR_HA_IP]:5984/_all_dbs
```

## データの永続化

データは `/data/couchdb` ディレクトリに保存され、Home Assistantの `data` フォルダにマップされています。アドオンを再起動してもデータは保持されます。

## ポート

- **5984**: CouchDB HTTP API とWeb UI (Fauxton)

## サポート

問題やバグ報告は [GitHub Issues](https://github.com/geekinsideme/ha-couchdb-addon/issues) までお寄せください。