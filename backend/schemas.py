"""
Pydanticスキーマ（APIのリクエスト/レスポンスの型定義）
"""
from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional


class UserBase(BaseModel):
    """ユーザーの基本情報"""
    name: str
    email: EmailStr


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
