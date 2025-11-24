# 🐳 Docker Practice - 学習用プロジェクト

Dockerの基礎を実践的に学ぶための学習用プロジェクトです。

このプロジェクトでは、フロントエンド（Next.js）、バックエンド（FastAPI）、データベース（PostgreSQL）の3層アーキテクチャをDockerで構築し、実際の開発環境に近い形でDockerの使い方を学べます。

## 🎯 このプロジェクトで学べること

- ✅ Dockerの基本的な概念（イメージ、コンテナ、ボリューム、ネットワーク）
- ✅ Dockerfileの書き方
- ✅ Docker Composeを使った複数コンテナの管理
- ✅ フロントエンド・バックエンド・データベースの連携
- ✅ ホットリロードを使った開発環境の構築
- ✅ データの永続化
- ✅ コンテナ間のネットワーク通信

## 📁 プロジェクト構成

```
Docker_practice/
├── backend/              # FastAPI バックエンド
│   ├── Dockerfile       # バックエンド用Dockerイメージ定義
│   ├── main.py          # FastAPIアプリケーション
│   ├── database.py      # データベース接続設定
│   ├── models.py        # データベースモデル
│   ├── schemas.py       # Pydanticスキーマ
│   └── requirements.txt # Python依存関係
│
├── frontend/            # Next.js フロントエンド
│   ├── Dockerfile      # フロントエンド用Dockerイメージ定義
│   ├── package.json    # Node.js依存関係
│   └── src/
│       └── app/
│           ├── page.tsx      # メインページ
│           ├── layout.tsx    # レイアウト
│           └── globals.css   # スタイル
│
├── docs/               # ドキュメント
│   ├── 01_getting_started.md     # 初心者向け手順書
│   ├── 02_docker_explained.md    # Docker解説書
│   └── 03_troubleshooting.md     # トラブルシューティング
│
├── docker-compose.yml  # Docker Compose設定
├── .env.example        # 環境変数のサンプル
└── README.md           # このファイル
```

## 🚀 クイックスタート

### 前提条件

- Docker Desktop がインストールされていること
- Git がインストールされていること

### 5分で始める

```bash
# 1. リポジトリをクローン
git clone https://github.com/kenta-tech0/Docker_practice.git
cd Docker_practice

# 2. 環境変数ファイルを作成
cp .env.example .env

# 3. コンテナを起動（初回は数分かかります）
docker-compose up --build

# 4. ブラウザでアクセス
# フロントエンド: http://localhost:3000
# バックエンドAPI: http://localhost:8000
# API ドキュメント: http://localhost:8000/docs
```

### 停止方法

```bash
# Ctrl+C で停止、またはバックグラウンドで起動している場合
docker-compose down
```

## 🎓 学習の進め方

### ステップ1: 環境構築（30分）

まずは[初心者向け手順書](./docs/01_getting_started.md)を読んで、環境を構築しましょう。

- Docker Desktopのインストール
- プロジェクトのセットアップ
- コンテナの起動と動作確認

### ステップ2: Dockerの理解（60分）

[Docker解説書](./docs/02_docker_explained.md)で、Dockerの仕組みを学びましょう。

- Dockerの基本概念
- Dockerfileの書き方
- docker-compose.ymlの理解
- ネットワークとボリューム

### ステップ3: API接続テスト（10分）

コンテナ起動後、APIが正しく動作しているか確認しましょう：

```bash
# APIテストスクリプトを実行
./test_api_simple.sh
```

このスクリプトは以下をテストします：
- ✅ バックエンドAPIの起動確認
- ✅ ヘルスチェックエンドポイント
- ✅ ユーザーの作成・取得・削除

### ステップ4: 実践（自由に）

以下のような実践的な課題に挑戦してみましょう：

1. **コードの変更を体験**
   - フロントエンドのUIを変更してみる
   - バックエンドに新しいAPIエンドポイントを追加
   - ホットリロードが効いていることを確認

2. **データベース操作**
   - ユーザーを作成してデータベースに保存
   - コンテナを再起動してもデータが残ることを確認
   - データベースに直接接続してSQLを実行

3. **トラブルシューティング**
   - わざとエラーを起こしてログを確認
   - コンテナを停止・削除して再起動
   - [トラブルシューティングガイド](./docs/03_troubleshooting.md)を参照

## 📚 ドキュメント

| ドキュメント | 内容 | 対象 |
|------------|------|------|
| [01_getting_started.md](./docs/01_getting_started.md) | 環境構築の手順、基本的な使い方 | 初心者 |
| [02_docker_explained.md](./docs/02_docker_explained.md) | Dockerの概念、仕組みの詳しい解説 | 全員 |
| [03_troubleshooting.md](./docs/03_troubleshooting.md) | よくある問題と解決方法 | 全員 |

## 🛠️ 技術スタック

### フロントエンド
- **Next.js 14** - Reactフレームワーク
- **TypeScript** - 型安全な開発
- **Tailwind CSS** - ユーティリティファーストCSS

### バックエンド
- **FastAPI** - モダンなPython Webフレームワーク
- **SQLAlchemy** - ORM（Object-Relational Mapping）
- **Pydantic** - データバリデーション

### データベース
- **PostgreSQL 16** - リレーショナルデータベース

### インフラ
- **Docker** - コンテナ化
- **Docker Compose** - マルチコンテナ管理

## 📖 主要なコマンド

### コンテナの管理

```bash
# コンテナを起動
docker-compose up

# バックグラウンドで起動
docker-compose up -d

# イメージを再ビルドして起動
docker-compose up --build

# コンテナを停止
docker-compose stop

# コンテナを停止して削除
docker-compose down

# ボリュームも削除（データが消えます！）
docker-compose down -v
```

### ログの確認

```bash
# すべてのサービスのログ
docker-compose logs

# リアルタイムでログを表示
docker-compose logs -f

# 特定のサービスのログ
docker-compose logs -f backend
```

### コンテナ内でコマンド実行

```bash
# データベースに接続
docker-compose exec db psql -U postgres -d docker_practice

# バックエンドのシェルに入る
docker-compose exec backend bash

# フロントエンドでnpmコマンド実行
docker-compose exec frontend npm install <パッケージ名>
```

## 🔍 各サービスへのアクセス

| サービス | URL | 説明 |
|---------|-----|------|
| フロントエンド | http://localhost:3000 | Next.js UI |
| バックエンドAPI | http://localhost:8000 | FastAPI エンドポイント |
| API ドキュメント | http://localhost:8000/docs | Swagger UI |
| データベース | localhost:5432 | PostgreSQL |

## 🎯 実践課題

### 初級

- [ ] コンテナを起動して、フロントエンドにアクセスできることを確認
- [ ] ユーザーを作成して、データベースに保存
- [ ] API ドキュメント（http://localhost:8000/docs）でAPIをテスト
- [ ] データベースに直接接続してデータを確認

### 中級

- [ ] フロントエンドのUIを変更してホットリロードを確認
- [ ] バックエンドに新しいエンドポイントを追加
- [ ] 環境変数を変更してコンテナを再起動
- [ ] ログを確認してエラーを解決

### 上級

- [ ] 新しいテーブルとAPIエンドポイントを追加
- [ ] Dockerfileを最適化してビルド時間を短縮
- [ ] マルチステージビルドで本番用イメージを作成
- [ ] docker-compose.prod.ymlを作成して本番環境を構築

## 🐛 トラブルシューティング

問題が発生した場合は、[トラブルシューティングガイド](./docs/03_troubleshooting.md)を参照してください。

よくある問題：
- ポートがすでに使用されている → 別のポートを使用
- コンテナが起動しない → ログを確認
- データベースに接続できない → ヘルスチェックを確認
- ホットリロードが効かない → ボリュームマウントを確認

## 🤝 チーム開発のヒント

### 環境の統一

Dockerを使うことで、チーム全員が同じ環境で開発できます：

```bash
# チームメンバーAのPC
docker-compose up  # → 同じ環境

# チームメンバーBのPC
docker-compose up  # → 同じ環境

# 本番サーバー
docker-compose up  # → 同じ環境
```

### .envファイルの管理

`.env`ファイルは**Gitにコミットしない**でください：

```bash
# .gitignoreに記載済み
.env
```

チームで共有する場合は、`.env.example`を更新してください。

## 📝 次のステップ

このプロジェクトでDockerの基礎を学んだら、以下にチャレンジしてみましょう：

1. **本番環境の構築**
   - マルチステージビルド
   - nginx によるリバースプロキシ
   - SSL/TLS 証明書の設定

2. **CI/CDの導入**
   - GitHub Actions でイメージをビルド
   - Docker Hub へのプッシュ
   - 自動デプロイ

3. **オーケストレーション**
   - Kubernetes の学習
   - Docker Swarm の試用

## 📄 ライセンス

このプロジェクトは学習目的で作成されています。自由に使用・改変してください。

## 💬 質問・フィードバック

質問や問題がある場合は、チーム内で共有しましょう！

---

**Happy Docker Learning! 🐳**
