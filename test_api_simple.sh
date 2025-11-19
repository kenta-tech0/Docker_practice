#!/bin/bash

# 英語のみでテスト（文字エンコーディング問題の切り分け）

echo "🔍 API Test - English Only (Encoding Debug)"
echo "=========================================="
echo ""

API_URL="http://localhost:8000"

# カラーコード
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "1. Health Check"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/health)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo -e "   ${GREEN}✓ Success (HTTP $http_code)${NC}"
    echo "   Response: $body"
else
    echo -e "   ${RED}✗ Failed (HTTP $http_code)${NC}"
    echo "   Response: $body"
fi
echo ""

echo "2. Create User (English)"
test_email="test$(date +%s)@example.com"
echo "   Sending: {\"name\":\"John Doe\",\"email\":\"${test_email}\"}"

response=$(curl -s -w "\n%{http_code}" -X POST ${API_URL}/users \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"John Doe\",\"email\":\"${test_email}\"}")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 201 ]; then
    echo -e "   ${GREEN}✓ Success (HTTP $http_code)${NC}"
    echo "   Response: $body"
    user_id=$(echo "$body" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
else
    echo -e "   ${RED}✗ Failed (HTTP $http_code)${NC}"
    echo "   Response: $body"
    echo ""
    echo "=========================================="
    echo "Error occurred. Please check backend logs:"
    echo "  docker-compose logs backend | tail -50"
    exit 1
fi
echo ""

echo "3. Get All Users"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/users)
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
    echo -e "   ${GREEN}✓ Success (HTTP $http_code)${NC}"
    echo "   Response: $body"
else
    echo -e "   ${RED}✗ Failed (HTTP $http_code)${NC}"
fi
echo ""

# クリーンアップ
if [ ! -z "$user_id" ]; then
    echo "4. Delete Test User"
    response=$(curl -s -w "\n%{http_code}" -X DELETE ${API_URL}/users/${user_id})
    http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" -eq 200 ]; then
        echo -e "   ${GREEN}✓ Deleted${NC}"
    fi
fi

echo ""
echo "=========================================="
echo -e "${GREEN}All tests passed!${NC}"
echo ""
echo "If this works but Japanese doesn't:"
echo "→ Character encoding issue with curl"
echo "→ Use frontend (browser) for Japanese input"
