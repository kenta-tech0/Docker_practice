"""
FastAPI バックエンドアプリケーション
Docker学習用のサンプルAPI
"""
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import models
import schemas
from database import engine, get_db

# データベーステーブルの作成
models.Base.metadata.create_all(bind=engine)

# FastAPIアプリケーションの初期化
app = FastAPI(
    title="Docker Practice API",
    description="Docker学習用のサンプルバックエンドAPI",
    version="1.0.0"
)

# CORS設定（フロントエンドからのアクセスを許可）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Next.jsのデフォルトポート
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    """
    ルートエンドポイント
    APIが正常に動作しているか確認するためのエンドポイント
    """
    return {
        "message": "Docker Practice API へようこそ!",
        "status": "running",
        "docs": "/docs"
    }


@app.get("/health")
def health_check():
    """
    ヘルスチェック用エンドポイント
    コンテナの状態を確認するために使用
    """
    return {"status": "healthy"}


@app.get("/users", response_model=List[schemas.UserResponse])
def get_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    ユーザー一覧を取得

    Parameters:
    - skip: スキップする件数
    - limit: 取得する最大件数
    """
    users = db.query(models.User).offset(skip).limit(limit).all()
    return users


@app.get("/users/{user_id}", response_model=schemas.UserResponse)
def get_user(user_id: int, db: Session = Depends(get_db)):
    """
    特定のユーザーを取得

    Parameters:
    - user_id: ユーザーID
    """
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="ユーザーが見つかりません")
    return user


@app.post("/users", response_model=schemas.UserResponse, status_code=201)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """
    新しいユーザーを作成

    Parameters:
    - user: ユーザー情報
    """
    # メールアドレスの重複チェック
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="このメールアドレスは既に登録されています")

    # ユーザーの作成
    new_user = models.User(name=user.name, email=user.email)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    """
    ユーザーを削除

    Parameters:
    - user_id: ユーザーID
    """
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="ユーザーが見つかりません")

    db.delete(user)
    db.commit()
    return {"message": "ユーザーを削除しました"}
