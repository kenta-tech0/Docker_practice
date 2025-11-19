#!/bin/bash

# コンテナ状態の緊急診断スクリプト

echo "🚨 緊急診断 - コンテナ接続問題"
echo "========================================"
echo ""

# カラーコード
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "1. Docker Composeの状態確認"
echo "----------------------------------------"
docker-compose ps
echo ""

echo "2. バックエンドコンテナが起動しているか"
echo "----------------------------------------"
if docker-compose ps | grep -q "docker_practice_backend.*Up"; then
    echo -e "${GREEN}✓ バックエンドコンテナは起動しています${NC}"
else
    echo -e "${RED}✗ バックエンドコンテナが起動していません${NC}"
    echo ""
    echo "バックエンドを起動してください:"
    echo "  docker-compose up -d backend"
    exit 1
fi
echo ""

echo "3. ポート8000が公開されているか"
echo "----------------------------------------"
docker-compose ps backend | grep "8000"
echo ""

echo "4. バックエンドのログ（最新20行）"
echo "----------------------------------------"
docker-compose logs backend --tail=20
echo ""

echo "5. localhost:8000 への接続テスト"
echo "----------------------------------------"
if command -v nc &> /dev/null; then
    if nc -z localhost 8000 2>/dev/null; then
        echo -e "${GREEN}✓ ポート8000に接続できます${NC}"
    else
        echo -e "${RED}✗ ポート8000に接続できません${NC}"
        echo "バックエンドが起動していないか、ポートマッピングに問題があります"
    fi
else
    echo "nc コマンドが利用できないため、curlでテスト..."
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/ 2>&1)
    if [ "$response" != "000" ]; then
        echo -e "${GREEN}✓ バックエンドに接続できます (HTTP $response)${NC}"
    else
        echo -e "${RED}✗ バックエンドに接続できません${NC}"
    fi
fi
echo ""

echo "6. エラーチェック"
echo "----------------------------------------"
if docker-compose logs backend --tail=50 | grep -i "error\|exception\|failed"; then
    echo -e "${RED}エラーが見つかりました（上記参照）${NC}"
else
    echo -e "${GREEN}明確なエラーは見つかりませんでした${NC}"
fi
echo ""

echo "========================================"
echo "推奨アクション:"
echo ""
echo "バックエンドが起動していない場合:"
echo "  docker-compose up -d backend"
echo ""
echo "バックエンドがクラッシュしている場合:"
echo "  docker-compose restart backend"
echo "  docker-compose logs -f backend"
echo ""
echo "すべてのコンテナを再起動する場合:"
echo "  docker-compose restart"
echo ""
