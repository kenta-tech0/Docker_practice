# 🔧 トラブルシューティングガイド

Dockerを使用していてよくある問題とその解決方法をまとめています。

## 📋 目次

1. [起動時の問題](#起動時の問題)
2. [ネットワーク・接続の問題](#ネットワーク接続の問題)
3. [ビルド・イメージの問題](#ビルドイメージの問題)
4. [データベースの問題](#データベースの問題)
5. [パフォーマンスの問題](#パフォーマンスの問題)
6. [その他のよくある問題](#その他のよくある問題)

---

## 起動時の問題

### ❌ ポートがすでに使用されている

**エラーメッセージ:**
```
Error: Bind for 0.0.0.0:3000 failed: port is already allocated
```

**原因:**
指定したポートが他のプロセスで使用されています。

**解決方法:**

#### 方法1: 使用しているプロセスを確認して停止

```bash
# ポート3000を使用しているプロセスを確認（macOS/Linux）
lsof -i :3000

# ポート3000を使用しているプロセスを確認（Windows）
netstat -ano | findstr :3000

# プロセスを停止
kill -9 <PID>
```

#### 方法2: 別のポートを使用

`docker-compose.yml`のポート設定を変更：

```yaml
frontend:
  ports:
    - "3001:3000"  # ホスト側を3001に変更
```

### ❌ コンテナが起動後すぐに停止する

**確認方法:**

```bash
# コンテナの状態を確認
docker-compose ps

# ログを確認
docker-compose logs backend
```

**よくある原因:**

1. **コマンドが間違っている**

   Dockerfileの`CMD`を確認：
   ```dockerfile
   # ❌ 間違い
   CMD ["uvicorn", "app:app"]  # app.pyがない

   # ✅ 正しい
   CMD ["uvicorn", "main:app"]  # main.pyのappを起動
   ```

2. **依存関係のインストールエラー**

   ```bash
   # イメージを再ビルド
   docker-compose build --no-cache backend
   docker-compose up backend
   ```

3. **環境変数が設定されていない**

   `.env`ファイルが存在するか確認：
   ```bash
   ls -la .env
   # なければ作成
   cp .env.example .env
   ```

### ❌ データベースへの接続待機でタイムアウト

**エラーメッセージ:**
```
sqlalchemy.exc.OperationalError: could not connect to server
```

**解決方法:**

1. **データベースの起動を確認**

   ```bash
   # データベースのログを確認
   docker-compose logs db

   # "database system is ready" というメッセージを探す
   ```

2. **ヘルスチェックの設定を確認**

   `docker-compose.yml`のヘルスチェック設定：
   ```yaml
   db:
     healthcheck:
       test: ["CMD-SHELL", "pg_isready -U postgres"]
       interval: 10s
       timeout: 5s
       retries: 5
   ```

3. **depends_onの設定を確認**

   ```yaml
   backend:
     depends_on:
       db:
         condition: service_healthy  # これが重要
   ```

---

## ネットワーク・接続の問題

### ❌ フロントエンドからバックエンドにアクセスできない

**症状:**
- ブラウザで「Failed to fetch」エラー
- API状態が「接続エラー」と表示される

**確認手順:**

1. **バックエンドが起動しているか確認**

   ```bash
   # コンテナの状態を確認
   docker-compose ps

   # バックエンドのログを確認
   docker-compose logs -f backend
   ```

2. **ブラウザから直接アクセス**

   ```
   http://localhost:8000
   ```

   JSONレスポンスが返ってくればバックエンドは正常。

3. **CORS設定を確認**

   `backend/main.py`のCORS設定：
   ```python
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["http://localhost:3000"],  # フロントエンドのURL
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

4. **環境変数を確認**

   フロントエンドの環境変数：
   ```bash
   # frontend/.env.local を作成
   NEXT_PUBLIC_API_URL=http://localhost:8000
   ```

### ❌ コンテナ間で通信できない

**症状:**
- バックエンドからデータベースに接続できない

**解決方法:**

1. **同じネットワークに接続しているか確認**

   ```bash
   # ネットワークを確認
   docker network ls

   # ネットワークの詳細を確認
   docker network inspect docker_practice_app-network
   ```

2. **接続文字列を確認**

   ```python
   # ❌ 間違い: localhostを使用
   DATABASE_URL = "postgresql://postgres:postgres@localhost:5432/docker_practice"

   # ✅ 正しい: コンテナ名を使用
   DATABASE_URL = "postgresql://postgres:postgres@db:5432/docker_practice"
   ```

3. **コンテナ内から疎通確認**

   ```bash
   # バックエンドコンテナに入る
   docker-compose exec backend bash

   # データベースに接続できるか確認
   ping db
   ```

---

## ビルド・イメージの問題

### ❌ イメージのビルドが失敗する

**エラーメッセージ:**
```
ERROR [internal] load metadata for docker.io/library/node:20-alpine
```

**解決方法:**

1. **インターネット接続を確認**

2. **Dockerのキャッシュをクリア**

   ```bash
   # キャッシュを使わずにビルド
   docker-compose build --no-cache
   ```

3. **古いイメージを削除**

   ```bash
   # 未使用のイメージを削除
   docker image prune -a
   ```

### ❌ 依存関係のインストールエラー

**Python (backend):**

```bash
# Dockerfileで指定されたPythonバージョンを確認
FROM python:3.11-slim

# requirements.txtの内容を確認
cat backend/requirements.txt

# ビルドログを確認
docker-compose build backend
```

**Node.js (frontend):**

```bash
# package.jsonの内容を確認
cat frontend/package.json

# node_modulesを削除して再ビルド
rm -rf frontend/node_modules
docker-compose build --no-cache frontend
```

### ❌ ディスク容量不足

**エラーメッセージ:**
```
no space left on device
```

**解決方法:**

```bash
# Dockerが使用しているディスク容量を確認
docker system df

# 未使用のコンテナ、イメージ、ボリュームを削除
docker system prune -a --volumes

# 確認してから削除
docker system prune -a --volumes --dry-run
```

---

## データベースの問題

### ❌ データベースに接続できない

**確認手順:**

1. **データベースコンテナの状態を確認**

   ```bash
   docker-compose ps db
   ```

2. **データベースのログを確認**

   ```bash
   docker-compose logs db
   ```

3. **直接データベースに接続してみる**

   ```bash
   docker-compose exec db psql -U postgres -d docker_practice
   ```

4. **環境変数を確認**

   ```bash
   # .envファイルの内容を確認
   cat .env
   ```

### ❌ テーブルが存在しない

**エラーメッセージ:**
```
relation "users" does not exist
```

**原因:**
データベースのマイグレーションが実行されていない。

**解決方法:**

このプロジェクトでは、アプリケーション起動時に自動でテーブルが作成されます：

```python
# backend/main.py
models.Base.metadata.create_all(bind=engine)
```

もし作成されない場合：

```bash
# バックエンドを再起動
docker-compose restart backend

# ログを確認
docker-compose logs backend
```

### ❌ データが消えた

**原因:**
`docker-compose down -v`でボリュームを削除した。

**解決方法:**

```bash
# ❌ ボリュームも削除（データが消える）
docker-compose down -v

# ✅ コンテナのみ削除（データは残る）
docker-compose down

# ボリュームを確認
docker volume ls
```

**データバックアップの方法:**

```bash
# データベースをダンプ
docker-compose exec db pg_dump -U postgres docker_practice > backup.sql

# リストア
docker-compose exec -T db psql -U postgres docker_practice < backup.sql
```

---

## パフォーマンスの問題

### ❌ ビルドが遅い

**解決方法:**

1. **マルチステージビルドを使用**（本番環境用）

2. **レイヤーキャッシュを活用**

   ```dockerfile
   # ✅ 良い例: 変更が少ないものを先に
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   COPY . .

   # ❌ 悪い例: すべて一緒にコピー
   COPY . .
   RUN pip install -r requirements.txt
   ```

3. **.dockerignoreを活用**

   不要なファイルをコピーしないように設定：
   ```
   node_modules
   .git
   __pycache__
   ```

### ❌ コンテナの起動が遅い

**原因と解決方法:**

1. **ホットリロードの設定**

   ボリュームマウントを確認：
   ```yaml
   volumes:
     - ./backend:/app  # コードの変更をリアルタイム反映
   ```

2. **不要なサービスを停止**

   ```bash
   # 必要なサービスのみ起動
   docker-compose up frontend backend
   ```

---

## その他のよくある問題

### ❌ ホットリロードが効かない

**症状:**
コードを変更しても、コンテナ内のアプリケーションが更新されない。

**解決方法:**

1. **ボリュームマウントを確認**

   ```yaml
   volumes:
     - ./backend:/app  # これがないとホットリロードされない
   ```

2. **開発サーバーの設定を確認**

   ```dockerfile
   # バックエンド
   CMD ["uvicorn", "main:app", "--reload"]  # --reloadが必要

   # フロントエンド
   CMD ["npm", "run", "dev"]  # devモードで起動
   ```

3. **Dockerの設定（macOS/Windows）**

   Docker Desktopの設定で「File Sharing」を確認。

### ❌ Permission denied エラー

**エラーメッセージ:**
```
Permission denied: '/app/node_modules'
```

**解決方法:**

```bash
# コンテナ内とホストのユーザーIDを合わせる
# または、ボリュームの権限を変更
docker-compose exec frontend chmod -R 777 /app/node_modules
```

### ❌ Docker Composeのバージョンエラー

**エラーメッセージ:**
```
version is obsolete
```

**解決方法:**

`docker-compose.yml`のバージョンを確認：

```yaml
version: '3.8'  # 使用しているDocker Composeに合わせる
```

または、バージョン指定を削除（Compose V2以降）：

```yaml
# version行を削除
services:
  db:
    ...
```

---

## デバッグのベストプラクティス

### 1. ログを確認する

```bash
# リアルタイムでログを確認
docker-compose logs -f

# 特定のサービスのログ
docker-compose logs -f backend

# エラーだけ表示
docker-compose logs backend | grep -i error
```

### 2. コンテナ内に入って調査

```bash
# bashシェルに入る
docker-compose exec backend bash

# コマンドを直接実行
docker-compose exec backend python -c "import sqlalchemy; print(sqlalchemy.__version__)"
```

### 3. ステップバイステップで確認

```bash
# 1. データベースのみ起動
docker-compose up db

# 2. バックエンドを追加
docker-compose up db backend

# 3. すべて起動
docker-compose up
```

### 4. クリーンな状態から再起動

```bash
# すべて停止・削除
docker-compose down

# イメージも削除
docker-compose down --rmi all

# ボリュームも削除（注意: データが消える）
docker-compose down -v

# 再ビルドして起動
docker-compose up --build
```

---

## ヘルプの入手方法

### 公式ドキュメント

- [Docker公式ドキュメント](https://docs.docker.com/)
- [Docker Compose公式ドキュメント](https://docs.docker.com/compose/)
- [FastAPI公式ドキュメント](https://fastapi.tiangolo.com/)
- [Next.js公式ドキュメント](https://nextjs.org/docs)

### コミュニティ

- [Stack Overflow](https://stackoverflow.com/questions/tagged/docker)
- [Docker Community Forums](https://forums.docker.com/)

### デバッグコマンドチートシート

```bash
# システム情報
docker info
docker version

# コンテナ情報
docker-compose ps
docker-compose logs
docker-compose top

# ネットワーク情報
docker network ls
docker network inspect <network_name>

# ボリューム情報
docker volume ls
docker volume inspect <volume_name>

# リソース使用状況
docker stats
docker system df

# クリーンアップ
docker system prune
docker volume prune
docker network prune
```

---

問題が解決しない場合は、チーム内で共有して一緒に解決しましょう！
