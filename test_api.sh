#!/bin/bash

# API接続テストスクリプト
# Docker起動後にこのスクリプトを実行して、APIが正しく動作しているか確認できます

echo "🐳 Docker Practice - API接続テスト"
echo "=================================="
echo ""

# バックエンドAPIのベースURL
API_URL="http://localhost:8000"

# カラーコード
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. ルートエンドポイントのテスト
echo "1. ルートエンドポイント (GET /)"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
else
    echo -e "   ${RED}✗ 失敗 (HTTP $http_code)${NC}"
fi
echo ""

# 2. ヘルスチェックエンドポイントのテスト
echo "2. ヘルスチェック (GET /health)"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/health)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
else
    echo -e "   ${RED}✗ 失敗 (HTTP $http_code)${NC}"
fi
echo ""

# 3. ユーザー一覧の取得
echo "3. ユーザー一覧取得 (GET /users)"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/users)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
else
    echo -e "   ${RED}✗ 失敗 (HTTP $http_code)${NC}"
fi
echo ""

# 4. ユーザー作成のテスト
echo "4. ユーザー作成 (POST /users)"
test_email="test_$(date +%s)@example.com"
response=$(curl -s -w "\n%{http_code}" -X POST ${API_URL}/users \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"テストユーザー\",\"email\":\"${test_email}\"}")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 201 ]; then
    echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
    # ユーザーIDを抽出（削除テスト用）
    user_id=$(echo "$body" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
else
    echo -e "   ${RED}✗ 失敗 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
fi
echo ""

# 5. 作成したユーザーの削除
if [ ! -z "$user_id" ]; then
    echo "5. ユーザー削除 (DELETE /users/${user_id})"
    response=$(curl -s -w "\n%{http_code}" -X DELETE ${API_URL}/users/${user_id})
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -eq 200 ]; then
        echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
        echo "   レスポンス: $body"
    else
        echo -e "   ${RED}✗ 失敗 (HTTP $http_code)${NC}"
    fi
    echo ""
fi

# 6. API ドキュメントの確認
echo "6. API ドキュメント"
echo -e "   ${YELLOW}ブラウザで以下のURLにアクセスしてください:${NC}"
echo "   ${API_URL}/docs"
echo ""

echo "=================================="
echo "テスト完了！"
echo ""
echo "次のステップ:"
echo "1. フロントエンドにアクセス: http://localhost:3000"
echo "2. API ドキュメントを確認: http://localhost:8000/docs"
echo "3. コンテナのログを確認: docker compose logs -f"
