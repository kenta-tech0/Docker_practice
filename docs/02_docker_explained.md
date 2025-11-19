# 🐳 Docker解説書 - 仕組みを理解する

このドキュメントでは、Dockerの基本的な概念と仕組みを詳しく解説します。

## 📋 目次

1. [Dockerとは](#dockerとは)
2. [Dockerの主要な概念](#dockerの主要な概念)
3. [Dockerfileの解説](#dockerfileの解説)
4. [docker-compose.ymlの解説](#docker-composeymlの解説)
5. [ネットワークとボリューム](#ネットワークとボリューム)
6. [実践的な使い方](#実践的な使い方)

---

## Dockerとは

### 概要

Dockerは、**コンテナ型の仮想化技術**を使ってアプリケーションを実行する環境を提供するツールです。

### 従来の開発環境の課題

```
開発者A のPC          開発者B のPC          本番サーバー
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ macOS       │    │ Windows     │    │ Linux       │
│ Python 3.9  │    │ Python 3.11 │    │ Python 3.10 │
│ Node 16     │    │ Node 18     │    │ Node 20     │
└─────────────┘    └─────────────┘    └─────────────┘
     ❌               ❌               ❌
  「私の環境では動くのに...」という問題が発生
```

### Dockerを使った場合

```
開発者A のPC          開発者B のPC          本番サーバー
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  🐳 Docker  │    │  🐳 Docker  │    │  🐳 Docker  │
│ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │
│ │同じ環境 │ │    │ │同じ環境 │ │    │ │同じ環境 │ │
│ └─────────┘ │    │ └─────────┘ │    │ └─────────┘ │
└─────────────┘    └─────────────┘    └─────────────┘
     ✅               ✅               ✅
     どこでも同じように動く！
```

---

## Dockerの主要な概念

### 1. イメージ (Image)

**イメージ**は、アプリケーションを実行するために必要なすべてを含んだ**設計図**です。

```
イメージの構成要素:
┌─────────────────────────────┐
│ アプリケーションコード      │
│ ライブラリ・依存関係        │
│ OS (軽量版)                 │
│ 環境変数の設定              │
│ 起動コマンド                │
└─────────────────────────────┘
```

#### イメージの確認

```bash
# ローカルにあるイメージ一覧
docker images

# イメージの詳細情報
docker image inspect <イメージ名>
```

### 2. コンテナ (Container)

**コンテナ**は、イメージから作成された**実際に動作するインスタンス**です。

```
イメージとコンテナの関係:

    イメージ (設計図)
         │
         ├──→ コンテナA (実行中)
         ├──→ コンテナB (実行中)
         └──→ コンテナC (停止中)

※ 1つのイメージから複数のコンテナを作成可能
```

#### コンテナの確認

```bash
# 実行中のコンテナ一覧
docker ps

# すべてのコンテナ一覧（停止中含む）
docker ps -a

# コンテナの詳細情報
docker inspect <コンテナ名>
```

### 3. Dockerfile

**Dockerfile**は、イメージをどのように作成するかを記述した**レシピ**です。

### 4. Docker Compose

**Docker Compose**は、複数のコンテナを一括で管理するための**オーケストレーションツール**です。

---

## Dockerfileの解説

### バックエンドのDockerfile

`backend/Dockerfile`を見てみましょう：

```dockerfile
# ベースイメージの指定
FROM python:3.11-slim

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係ファイルをコピー
COPY requirements.txt .

# 依存関係をインストール
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションコードをコピー
COPY . .

# ポート8000を公開
EXPOSE 8000

# アプリケーションを起動
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

#### 各命令の説明

| 命令 | 説明 | 例 |
|------|------|-----|
| `FROM` | ベースとなるイメージを指定 | `FROM python:3.11-slim` |
| `WORKDIR` | 作業ディレクトリを設定 | `WORKDIR /app` |
| `COPY` | ホストからコンテナにファイルをコピー | `COPY . .` |
| `RUN` | イメージビルド時にコマンドを実行 | `RUN pip install -r requirements.txt` |
| `EXPOSE` | コンテナが使用するポートを宣言 | `EXPOSE 8000` |
| `CMD` | コンテナ起動時に実行するコマンド | `CMD ["python", "app.py"]` |
| `ENV` | 環境変数を設定 | `ENV NODE_ENV=production` |

#### イメージのレイヤー構造

Dockerイメージは**レイヤー構造**になっています：

```
┌─────────────────────────────┐
│ CMD ["uvicorn", ...]        │ ← Layer 5
├─────────────────────────────┤
│ COPY . .                    │ ← Layer 4
├─────────────────────────────┤
│ RUN pip install ...         │ ← Layer 3
├─────────────────────────────┤
│ COPY requirements.txt       │ ← Layer 2
├─────────────────────────────┤
│ FROM python:3.11-slim       │ ← Layer 1 (Base)
└─────────────────────────────┘
```

> 💡 **重要なポイント**:
> - 各レイヤーはキャッシュされる
> - 変更されたレイヤーより下のレイヤーのみ再ビルドされる
> - 変更が少ないものを上に配置すると、ビルドが高速化される

### フロントエンドのDockerfile

`frontend/Dockerfile`の構造も同様です：

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]
```

---

## docker-compose.ymlの解説

`docker-compose.yml`は複数のサービスを定義し、一括管理します。

### 全体構造

```yaml
version: '3.8'

services:        # ← サービス（コンテナ）の定義
  db:           # ← データベースサービス
  backend:      # ← バックエンドサービス
  frontend:     # ← フロントエンドサービス

networks:        # ← ネットワークの定義
volumes:         # ← ボリュームの定義
```

### データベースサービスの解説

```yaml
db:
  image: postgres:16-alpine              # 使用するイメージ
  container_name: docker_practice_db     # コンテナ名
  environment:                           # 環境変数
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    POSTGRES_DB: docker_practice
  ports:                                 # ポートマッピング
    - "5432:5432"                        # ホスト:コンテナ
  volumes:                               # ボリュームマウント
    - postgres_data:/var/lib/postgresql/data
  healthcheck:                           # ヘルスチェック
    test: ["CMD-SHELL", "pg_isready -U postgres"]
    interval: 10s
    timeout: 5s
    retries: 5
  networks:                              # 接続するネットワーク
    - app-network
```

#### 環境変数 (environment)

コンテナ内で使用する環境変数を設定します。

```yaml
environment:
  POSTGRES_USER: postgres           # ユーザー名
  POSTGRES_PASSWORD: postgres       # パスワード
  POSTGRES_DB: docker_practice      # データベース名
```

#### ポートマッピング (ports)

ホストとコンテナのポートを紐付けます。

```
ホスト側    コンテナ側
  :5432  →   :5432
     ↑          ↑
  外部から   コンテナ内の
 アクセス可能   ポート
```

```yaml
ports:
  - "5432:5432"  # ホスト:コンテナ
```

#### ボリューム (volumes)

データを永続化するための仕組みです。

```
コンテナを削除しても...

❌ 通常の場合:
   コンテナ削除 → データも消える

✅ ボリュームを使用:
   コンテナ削除 → データは残る
```

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
    └─ボリューム名  └─コンテナ内のパス
```

### バックエンドサービスの解説

```yaml
backend:
  build:                               # イメージをビルド
    context: ./backend
    dockerfile: Dockerfile
  container_name: docker_practice_backend
  environment:
    DATABASE_URL: postgresql://postgres:postgres@db:5432/docker_practice
  ports:
    - "8000:8000"
  volumes:
    - ./backend:/app                   # ホットリロード用
  depends_on:                          # 依存関係
    db:
      condition: service_healthy       # dbが正常になってから起動
  networks:
    - app-network
```

#### build vs image

| 項目 | 説明 | 使用例 |
|------|------|--------|
| `image` | 既存のイメージを使用 | `image: postgres:16-alpine` |
| `build` | Dockerfileからイメージをビルド | `build: ./backend` |

#### depends_on（依存関係）

サービスの起動順序を制御します。

```
起動順序:

1. db サービス起動
2. db のヘルスチェックが成功
3. backend サービス起動
4. frontend サービス起動
```

```yaml
depends_on:
  db:
    condition: service_healthy    # dbが健全になるまで待機
```

### フロントエンドサービスの解説

```yaml
frontend:
  build:
    context: ./frontend
    dockerfile: Dockerfile
  container_name: docker_practice_frontend
  environment:
    NEXT_PUBLIC_API_URL: http://localhost:8000
  ports:
    - "3000:3000"
  volumes:
    - ./frontend:/app
    - /app/node_modules              # node_modulesは除外
    - /app/.next                     # .nextは除外
  depends_on:
    - backend
  networks:
    - app-network
```

#### 特殊なボリュームマウント

```yaml
volumes:
  - ./frontend:/app        # ソースコードを同期
  - /app/node_modules      # ただしnode_modulesは除外
  - /app/.next             # .nextディレクトリも除外
```

> 💡 **なぜ除外するのか？**:
> - `node_modules`はコンテナ内でインストールしたものを使用
> - ホスト側のnode_modulesと競合を避けるため

---

## ネットワークとボリューム

### ネットワーク

コンテナ間の通信を可能にします。

```
app-network (bridge)
┌──────────────────────────────────────┐
│                                      │
│  ┌──────────┐  ┌──────────┐         │
│  │ frontend │→ │ backend  │         │
│  │ :3000    │  │ :8000    │         │
│  └──────────┘  └──────────┘         │
│                      ↓               │
│                ┌──────────┐          │
│                │    db    │          │
│                │  :5432   │          │
│                └──────────┘          │
└──────────────────────────────────────┘
```

#### コンテナ名で通信

同じネットワーク内では、**コンテナ名でアクセス**できます：

```python
# backend/database.py
DATABASE_URL = "postgresql://postgres:postgres@db:5432/docker_practice"
#                                              ↑
#                                         コンテナ名
```

```typescript
// frontend/src/app/page.tsx
const API_URL = 'http://backend:8000'
//                      ↑
//                  コンテナ名
```

### ボリューム

データの永続化には名前付きボリュームを使用します。

```yaml
volumes:
  postgres_data:    # 名前付きボリューム
```

#### ボリュームの確認

```bash
# ボリューム一覧
docker volume ls

# ボリュームの詳細
docker volume inspect docker_practice_postgres_data

# ボリュームの削除
docker volume rm docker_practice_postgres_data
```

---

## 実践的な使い方

### コンテナ内でコマンドを実行

#### 1. execコマンド

実行中のコンテナ内でコマンドを実行：

```bash
# データベースに接続
docker-compose exec db psql -U postgres -d docker_practice

# バックエンドのシェルに入る
docker-compose exec backend bash

# フロントエンドでnpmコマンドを実行
docker-compose exec frontend npm install <パッケージ名>
```

#### 2. runコマンド

新しいコンテナを起動してコマンドを実行：

```bash
# 一時的にPythonを実行
docker-compose run backend python -c "print('Hello')"

# マイグレーションを実行
docker-compose run backend alembic upgrade head
```

### ログの確認

```bash
# すべてのサービスのログ
docker-compose logs

# リアルタイムでログを表示
docker-compose logs -f

# 特定のサービスのログ
docker-compose logs -f backend

# 最新100行のみ表示
docker-compose logs --tail=100 backend
```

### コンテナの再起動

```bash
# すべてのサービスを再起動
docker-compose restart

# 特定のサービスのみ再起動
docker-compose restart backend

# コードを変更したら自動的に再起動（ホットリロード）
# → Dockerfileで--reloadオプションを指定している場合は自動
```

### イメージの再ビルド

コードを変更した場合：

```bash
# イメージを再ビルドして起動
docker-compose up --build

# 特定のサービスのみ再ビルド
docker-compose build backend
docker-compose up -d backend
```

### リソースのクリーンアップ

```bash
# 停止中のコンテナを削除
docker container prune

# 使用していないイメージを削除
docker image prune

# 使用していないボリュームを削除
docker volume prune

# すべてを一括削除（注意！）
docker system prune -a --volumes
```

---

## まとめ

### Dockerの主要コマンド

| コマンド | 説明 |
|---------|------|
| `docker-compose up` | サービスを起動 |
| `docker-compose down` | サービスを停止・削除 |
| `docker-compose build` | イメージをビルド |
| `docker-compose logs` | ログを表示 |
| `docker-compose exec` | コンテナ内でコマンド実行 |
| `docker-compose ps` | サービスの状態確認 |

### 学習のポイント

✅ **イメージ**: アプリケーションの設計図
✅ **コンテナ**: イメージから作成された実行環境
✅ **Dockerfile**: イメージの作成方法を定義
✅ **docker-compose.yml**: 複数のコンテナを管理
✅ **ネットワーク**: コンテナ間の通信
✅ **ボリューム**: データの永続化

---

## 次のステップ

- [トラブルシューティング](./03_troubleshooting.md) でよくある問題を学ぶ
- 実際にコードを変更して、ホットリロードを体験する
- データベースのデータを確認し、永続化の仕組みを理解する
