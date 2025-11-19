# 🐳 Docker学習 - はじめての環境構築

このドキュメントでは、Dockerを使った開発環境の構築方法を段階的に学びます。

## 📋 目次

1. [事前準備](#事前準備)
2. [プロジェクトの概要](#プロジェクトの概要)
3. [環境構築の手順](#環境構築の手順)
4. [アプリケーションの起動](#アプリケーションの起動)
5. [動作確認](#動作確認)
6. [コンテナの停止と削除](#コンテナの停止と削除)

---

## 事前準備

### 必要なソフトウェア

- **Docker Desktop**: [公式サイト](https://www.docker.com/products/docker-desktop)からダウンロードしてインストール
- **Git**: バージョン管理ツール

### Dockerのインストール確認

以下のコマンドでDockerが正しくインストールされているか確認します：

```bash
docker --version
docker-compose --version
```

両方のコマンドでバージョン情報が表示されればOKです。

---

## プロジェクトの概要

このプロジェクトは、以下の3つのコンテナで構成されています：

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Frontend      │────▶│    Backend      │────▶│   Database      │
│   (Next.js)     │     │   (FastAPI)     │     │  (PostgreSQL)   │
│   Port: 3000    │     │   Port: 8000    │     │   Port: 5432    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

- **Frontend (Next.js)**: ユーザーインターフェース
- **Backend (FastAPI)**: APIサーバー
- **Database (PostgreSQL)**: データ保存

---

## 環境構築の手順

### ステップ1: プロジェクトをクローン

```bash
git clone https://github.com/kenta-tech0/Docker_practice.git
cd Docker_practice
```

### ステップ2: 環境変数ファイルの作成

`.env.example`をコピーして`.env`ファイルを作成します：

```bash
cp .env.example .env
```

`.env`ファイルの中身を確認してみましょう：

```bash
cat .env
```

以下のような内容が表示されます：

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=docker_practice
```

> 💡 **学習ポイント**:
> - `.env`ファイルには、パスワードなどの機密情報を記載します
> - このファイルは`.gitignore`に含まれているため、Gitにコミットされません

### ステップ3: プロジェクト構造を確認

```bash
tree -L 2 -I 'node_modules|__pycache__|.git'
```

以下のような構造になっています：

```
Docker_practice/
├── backend/              # FastAPIバックエンド
│   ├── Dockerfile       # バックエンドのDockerイメージ定義
│   ├── main.py          # FastAPIアプリケーション
│   ├── requirements.txt # Python依存関係
│   └── ...
├── frontend/            # Next.jsフロントエンド
│   ├── Dockerfile      # フロントエンドのDockerイメージ定義
│   ├── package.json    # Node.js依存関係
│   └── src/
├── docs/               # ドキュメント
├── docker-compose.yml  # 複数コンテナの管理設定
└── .env               # 環境変数
```

---

## アプリケーションの起動

### 方法1: すべてのコンテナを一度に起動（推奨）

```bash
docker-compose up --build
```

> 💡 **コマンドの説明**:
> - `docker-compose up`: docker-compose.ymlに定義されたすべてのコンテナを起動
> - `--build`: イメージを再ビルドしてから起動

初回起動時は、以下の処理が行われます：

1. 📦 **イメージのダウンロード**: PostgreSQL、Python、Node.jsのベースイメージ
2. 🔨 **イメージのビルド**: フロントエンドとバックエンドのDockerイメージ作成
3. 📚 **依存関係のインストール**: npm installやpip install
4. 🚀 **コンテナの起動**: 3つのコンテナが順番に起動

この処理には数分かかることがあります。コーヒーを淹れて待ちましょう☕

### 起動ログの確認

コンテナが起動すると、以下のようなログが表示されます：

```
docker_practice_db_1       | database system is ready to accept connections
docker_practice_backend_1  | INFO:     Application startup complete.
docker_practice_frontend_1 | ready - started server on 0.0.0.0:3000
```

> ✅ **起動成功のサイン**: 上記のようなメッセージが表示されたら起動完了です！

### バックグラウンドで起動する場合

ターミナルを占有したくない場合は、`-d`オプションを使います：

```bash
docker-compose up -d --build
```

ログを確認したい場合：

```bash
docker-compose logs -f
```

特定のサービスのログのみ確認：

```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

---

## 動作確認

### 1. フロントエンドにアクセス

ブラウザで以下のURLを開きます：

```
http://localhost:3000
```

ユーザー管理画面が表示されればOKです！

### 2. バックエンドAPIにアクセス

ブラウザまたはcurlで以下のURLを開きます：

```
http://localhost:8000
```

JSONレスポンスが返ってくればOKです：

```json
{
  "message": "Docker Practice API へようこそ!",
  "status": "running",
  "docs": "/docs"
}
```

### 3. API ドキュメントを確認

FastAPIは自動でAPIドキュメントを生成します：

```
http://localhost:8000/docs
```

> 💡 **学習ポイント**:
> - このページで各APIエンドポイントの仕様を確認できます
> - 「Try it out」ボタンでAPIを直接テストできます

### 4. データベースの確認

コンテナ内でPostgreSQLに接続してみましょう：

```bash
docker-compose exec db psql -U postgres -d docker_practice
```

データベースに接続できたら、以下のコマンドを試してみましょう：

```sql
-- テーブル一覧を表示
\dt

-- usersテーブルの構造を確認
\d users

-- データを確認
SELECT * FROM users;

-- 終了
\q
```

### 5. アプリケーションの動作テスト

1. フロントエンド (http://localhost:3000) でユーザーを作成
2. ユーザー一覧に表示されることを確認
3. データベースで実際にデータが保存されているか確認

```bash
docker-compose exec db psql -U postgres -d docker_practice -c "SELECT * FROM users;"
```

---

## コンテナの停止と削除

### コンテナの停止

```bash
docker-compose stop
```

> 💡 データは保持されます。再起動すると以前のデータが残っています。

### コンテナの停止と削除

```bash
docker-compose down
```

> ⚠️ コンテナは削除されますが、ボリュームのデータは保持されます。

### コンテナとボリュームをすべて削除（データも削除）

```bash
docker-compose down -v
```

> ⚠️ **注意**: データベースのデータもすべて削除されます！

---

## よく使うコマンド一覧

| コマンド | 説明 |
|---------|------|
| `docker-compose up` | コンテナを起動 |
| `docker-compose up -d` | バックグラウンドで起動 |
| `docker-compose up --build` | イメージを再ビルドして起動 |
| `docker-compose stop` | コンテナを停止 |
| `docker-compose down` | コンテナを停止して削除 |
| `docker-compose logs -f` | ログを表示 |
| `docker-compose ps` | 起動中のコンテナ一覧 |
| `docker-compose exec <service> <command>` | コンテナ内でコマンド実行 |
| `docker-compose restart <service>` | 特定のサービスを再起動 |

---

## 次のステップ

- [Docker解説書](./02_docker_explained.md) で、Dockerの仕組みを詳しく学ぶ
- [トラブルシューティング](./03_troubleshooting.md) でよくある問題の解決方法を確認

---

## 🎉 おめでとうございます！

Dockerを使った環境構築ができました！
次は、Dockerの仕組みについて詳しく学んでいきましょう。
