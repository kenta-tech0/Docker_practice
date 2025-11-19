# Docker ビルドエラー解決ガイド

## エラー内容
```
failed to prepare extraction snapshot: parent snapshot does not exist: not found
```

このエラーはDockerのビルドキャッシュが破損している場合に発生します。

## 解決手順

以下のコマンドを順番に実行してください：

### 1. すべてのコンテナとイメージを削除

```powershell
# PowerShellの場合
docker-compose down -v
docker system prune -a --volumes

# 確認を求められたら「y」を入力
```

```bash
# Bashの場合
docker-compose down -v
docker system prune -a --volumes
```

### 2. キャッシュなしで再ビルド

```bash
docker-compose build --no-cache
```

### 3. コンテナを起動

```bash
docker-compose up
```

## より簡単な方法（推奨）

以下のワンライナーで一気に解決できます：

### Windows PowerShell
```powershell
docker-compose down -v; docker system prune -a --volumes -f; docker-compose up --build
```

### Mac/Linux Bash
```bash
docker-compose down -v && docker system prune -a --volumes -f && docker-compose up --build
```

## それでも解決しない場合

### Docker Desktopを使用している場合

1. Docker Desktopを開く
2. 設定（歯車アイコン）→ Troubleshoot
3. 「Clean / Purge data」をクリック
4. 「Reset to factory defaults」を実行（最終手段）

### 手動でクリーンアップ

```bash
# すべてのコンテナを停止・削除
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# すべてのイメージを削除
docker rmi $(docker images -q) -f

# すべてのボリュームを削除
docker volume rm $(docker volume ls -q)

# ネットワークをクリーンアップ
docker network prune -f

# 再度ビルド
docker-compose up --build
```

## 注意事項

⚠️ **警告**: これらのコマンドは、Docker内のすべてのデータ（他のプロジェクトも含む）を削除します。
重要なデータがある場合は、事前にバックアップを取ってください。

## このプロジェクトのみクリーンアップする場合

```bash
# このプロジェクトのコンテナとボリュームのみ削除
docker-compose down -v

# このプロジェクトのイメージのみ削除
docker rmi docker_practice-backend docker_practice-frontend

# 再ビルド
docker-compose up --build
```
