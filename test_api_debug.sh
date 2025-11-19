#!/bin/bash

# デバッグ用: より詳細なログでAPIをテスト

echo "🔍 Docker Practice - 詳細APIテスト（デバッグモード）"
echo "================================================"
echo ""

API_URL="http://localhost:8000"

# カラーコード
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. ヘルスチェック${NC}"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/health)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
else
    echo -e "   ${RED}✗ 失敗 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
fi
echo ""

echo -e "${BLUE}2. ユーザー作成テスト（正常系）${NC}"
test_email="test_$(date +%s)@example.com"
echo "   送信データ: {\"name\":\"テストユーザー\",\"email\":\"${test_email}\"}"

response=$(curl -s -w "\n%{http_code}" -X POST ${API_URL}/users \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"テストユーザー\",\"email\":\"${test_email}\"}")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 201 ]; then
    echo -e "   ${GREEN}✓ 成功 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
    user_id=$(echo "$body" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
else
    echo -e "   ${RED}✗ 失敗 (HTTP $http_code)${NC}"
    echo "   レスポンス: $body"
fi
echo ""

echo -e "${BLUE}3. エラーケーステスト: 無効なメールアドレス${NC}"
echo "   送信データ: {\"name\":\"テスト\",\"email\":\"invalid-email\"}"

response=$(curl -s -w "\n%{http_code}" -X POST ${API_URL}/users \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"テスト\",\"email\":\"invalid-email\"}")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo -e "   HTTP $http_code (400が期待される)"
echo "   レスポンス: $body"
echo ""

echo -e "${BLUE}4. エラーケーステスト: 必須フィールド欠落${NC}"
echo "   送信データ: {\"name\":\"テスト\"} (emailなし)"

response=$(curl -s -w "\n%{http_code}" -X POST ${API_URL}/users \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"テスト\"}")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

echo -e "   HTTP $http_code (422が期待される)"
echo "   レスポンス: $body"
echo ""

echo -e "${BLUE}5. エラーケーステスト: 重複メールアドレス${NC}"
if [ ! -z "$test_email" ]; then
    echo "   送信データ: {\"name\":\"重複テスト\",\"email\":\"${test_email}\"} (既に登録済み)"

    response=$(curl -s -w "\n%{http_code}" -X POST ${API_URL}/users \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"重複テスト\",\"email\":\"${test_email}\"}")
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    echo -e "   HTTP $http_code (400が期待される)"
    echo "   レスポンス: $body"
else
    echo "   スキップ（テストユーザーが作成されていません）"
fi
echo ""

# クリーンアップ
if [ ! -z "$user_id" ]; then
    echo -e "${BLUE}6. クリーンアップ: テストユーザーを削除${NC}"
    response=$(curl -s -w "\n%{http_code}" -X DELETE ${API_URL}/users/${user_id})
    http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" -eq 200 ]; then
        echo -e "   ${GREEN}✓ 削除成功${NC}"
    else
        echo -e "   ${YELLOW}⚠ 削除失敗またはスキップ${NC}"
    fi
fi

echo ""
echo "================================================"
echo -e "${YELLOW}デバッグのヒント:${NC}"
echo "1. バックエンドのログを確認:"
echo "   docker-compose logs -f backend"
echo ""
echo "2. フロントエンドのブラウザコンソールを確認:"
echo "   F12キー → Consoleタブ"
echo ""
echo "3. ネットワークタブでリクエスト内容を確認:"
echo "   F12キー → Networkタブ → XHR/Fetch"
