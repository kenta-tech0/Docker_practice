# 🚨 API 400エラーの修正手順

## クイックフィックス（最速の解決方法）

### ステップ1: 診断を実行

```bash
./diagnose_all.sh
```

すべてのステップの結果を確認してください。

---

### ステップ2: 修正を適用

診断結果に関わらず、以下の手順で高確率で問題が解決します：

#### 方法A: 修正済みスキーマファイルを使用（推奨）

```bash
# 修正済みファイルを適用
cp backend/schemas_fixed.py backend/schemas.py

# バックエンドを再起動
docker-compose restart backend

# テストを実行
./test_api_simple.sh
```

---

#### 方法B: 手動で修正

`backend/schemas.py` を以下のように変更：

```python
from pydantic import BaseModel, field_validator
from datetime import datetime
from typing import Optional
import re


class UserBase(BaseModel):
    """ユーザーの基本情報"""
    name: str
    email: str

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        """メールアドレスのバリデーション"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(pattern, v):
            raise ValueError('有効なメールアドレスを入力してください')
        return v.lower()


class UserCreate(UserBase):
    """ユーザー作成用のスキーマ"""
    pass


class UserResponse(UserBase):
    """ユーザー情報のレスポンス用スキーマ"""
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
```

保存後：
```bash
docker-compose restart backend
./test_api_simple.sh
```

---

### ステップ3: 動作確認

#### 1. コマンドラインでテスト

```bash
curl -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

**期待される結果:**
```json
{
  "id": 1,
  "name": "Test User",
  "email": "test@example.com",
  "created_at": "2025-11-19T...",
  "updated_at": null
}
```

#### 2. フロントエンドでテスト

ブラウザで http://localhost:3000 を開いて、ユーザーを登録してみてください。

#### 3. API ドキュメントでテスト

http://localhost:8000/docs を開いて、Swagger UIから直接テストできます。

---

## それでも解決しない場合

### オプション1: 完全クリーンビルド

```bash
# すべて削除
docker-compose down -v

# キャッシュクリア
docker system prune -a --volumes -f

# 再ビルド
docker-compose up --build
```

---

### オプション2: requirements.txtを更新

`backend/requirements.txt` を以下のように変更：

```txt
fastapi==0.110.0
uvicorn==0.27.0
sqlalchemy==2.0.25
psycopg2-binary==2.9.9
pydantic==2.6.0
pydantic-settings==2.1.0
# email-validator は削除（使用しないため）
```

再ビルド：
```bash
docker-compose down
docker-compose build --no-cache backend
docker-compose up
```

---

## トラブルシューティング

### Q1: 修正後も400エラーが出る

**A:** コンテナが古いコードを実行している可能性があります。

```bash
# 強制的に再起動
docker-compose down
docker-compose up
```

---

### Q2: Dockerのビルドでエラーが出る

**A:** キャッシュの問題です。

```bash
docker-compose build --no-cache backend
```

---

### Q3: データベース接続エラーが出る

**A:** データベースの初期化を待つ必要があります。

```bash
# 30秒待ってから再度テスト
sleep 30
./test_api_simple.sh
```

---

## 検証チェックリスト

修正後、以下を確認してください：

- [ ] `./test_api_simple.sh` が成功する
- [ ] ブラウザ（http://localhost:3000）からユーザー登録ができる
- [ ] 登録したユーザーがリストに表示される
- [ ] ユーザーの削除ができる
- [ ] 無効なメールアドレスでエラーメッセージが表示される

すべてチェックできたら、修正完了です！

---

## 修正の説明

### なぜEmailStrを使わないのか？

1. **互換性の問題**: Pydantic v2 と email-validator の統合に問題がある
2. **シンプルさ**: 学習用プロジェクトでは、依存関係を減らす方が良い
3. **カスタマイズ性**: 独自のバリデーションルールを実装できる

### 独自バリデーションの利点

- ✅ 依存関係の問題を回避
- ✅ エラーメッセージをカスタマイズ可能
- ✅ 日本語のエラーメッセージを表示できる
- ✅ 学習効果が高い（バリデーションロジックを理解できる）

---

## さらなる改善

より厳密なメールバリデーションが必要な場合：

```python
@field_validator('email')
@classmethod
def validate_email(cls, v: str) -> str:
    # RFC 5322準拠のより厳密なパターン
    pattern = r'^[a-zA-Z0-9][a-zA-Z0-9._%+-]*@[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$'

    # ドメインの検証も追加
    if not re.match(pattern, v):
        raise ValueError('有効なメールアドレスを入力してください')

    local, domain = v.split('@')

    # ローカル部の長さチェック（最大64文字）
    if len(local) > 64:
        raise ValueError('メールアドレスのローカル部が長すぎます')

    # ドメイン部の長さチェック（最大255文字）
    if len(domain) > 255:
        raise ValueError('ドメイン名が長すぎます')

    return v.lower()
```

---

問題が解決したら、このファイルは削除してもOKです。
