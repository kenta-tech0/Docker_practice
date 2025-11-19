"""
Pydanticスキーマ（APIのリクエスト/レスポンスの型定義）
"""
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
        """
        メールアドレスのバリデーション
        RFC 5322の簡易版（学習用）
        """
        if not v or not isinstance(v, str):
            raise ValueError('メールアドレスを入力してください')

        # 基本的なメールアドレスのパターン
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

        if not re.match(pattern, v):
            raise ValueError('有効なメールアドレスの形式で入力してください')

        # メールアドレスの長さチェック
        if len(v) > 254:  # RFC 5321の制限
            raise ValueError('メールアドレスが長すぎます')

        return v.lower()  # 小文字に統一


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
