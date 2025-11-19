#!/bin/bash

# 包括的な診断スクリプト - エラーの根本原因を特定

echo "🔍 Docker Practice - 包括的診断"
echo "================================================"
echo ""

# カラーコード
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}■ ステップ1: コンテナの状態確認${NC}"
echo "------------------------------------------------"
docker-compose ps
echo ""

echo -e "${BLUE}■ ステップ2: バックエンドコンテナ内のファイル確認${NC}"
echo "------------------------------------------------"
echo "コンテナ内のschemas.pyの内容（最初の15行）:"
docker-compose exec backend head -15 /app/schemas.py
echo ""

echo -e "${BLUE}■ ステップ3: email-validatorのインストール確認${NC}"
echo "------------------------------------------------"
docker-compose exec backend python -c "import email_validator; print('email-validator version:', email_validator.__version__)" 2>&1
echo ""

echo -e "${BLUE}■ ステップ4: Pydanticの動作確認${NC}"
echo "------------------------------------------------"
docker-compose exec backend python << 'PYEOF'
from pydantic import BaseModel
import sys

print("Pydantic version check...")
try:
    import pydantic
    print(f"✓ Pydantic version: {pydantic.__version__}")
except Exception as e:
    print(f"✗ Pydantic import error: {e}")
    sys.exit(1)

print("\nTesting str email field...")
class TestStr(BaseModel):
    email: str

try:
    result = TestStr(email="test@example.com")
    print(f"✓ str email works: {result.email}")
except Exception as e:
    print(f"✗ str email failed: {e}")

print("\nTesting EmailStr field...")
try:
    from pydantic import EmailStr

    class TestEmailStr(BaseModel):
        email: EmailStr

    result = TestEmailStr(email="test@example.com")
    print(f"✓ EmailStr works: {result.email}")
except Exception as e:
    print(f"✗ EmailStr failed: {e}")
PYEOF
echo ""

echo -e "${BLUE}■ ステップ5: 実際のスキーマクラスのインポート確認${NC}"
echo "------------------------------------------------"
docker-compose exec backend python << 'PYEOF'
import sys
sys.path.insert(0, '/app')

print("Importing schemas module...")
try:
    import schemas
    print("✓ schemas module imported successfully")
    print(f"  UserBase fields: {schemas.UserBase.model_fields.keys()}")

    # 実際にインスタンス化してみる
    print("\nTesting UserCreate instantiation...")
    user = schemas.UserCreate(name="Test", email="test@example.com")
    print(f"✓ UserCreate works: name={user.name}, email={user.email}")

except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
PYEOF
echo ""

echo -e "${BLUE}■ ステップ6: curlでAPIテスト${NC}"
echo "------------------------------------------------"
echo "Testing POST /users..."
response=$(curl -s -w "\n%{http_code}" -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Diagnostic Test","email":"diagnostic@example.com"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 201 ]; then
    echo -e "${GREEN}✓ Success (HTTP $http_code)${NC}"
    echo "Response: $body"
else
    echo -e "${RED}✗ Failed (HTTP $http_code)${NC}"
    echo "Response: $body"
fi
echo ""

echo -e "${BLUE}■ ステップ7: バックエンドログの最後の30行${NC}"
echo "------------------------------------------------"
docker-compose logs backend --tail=30
echo ""

echo "================================================"
echo -e "${YELLOW}診断完了${NC}"
echo ""
echo "次のアクション:"
echo "1. 上記の結果を確認してください"
echo "2. エラーが出ているステップを特定してください"
echo "3. 特にステップ4-5のPythonテスト結果が重要です"
