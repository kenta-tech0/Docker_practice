'use client'

import { useState, useEffect } from 'react'

interface User {
  id: number
  name: string
  email: string
  created_at: string
}

export default function Home() {
  const [users, setUsers] = useState<User[]>([])
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [apiStatus, setApiStatus] = useState<'checking' | 'connected' | 'error'>('checking')

  const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

  // APIの接続確認
  useEffect(() => {
    checkApiConnection()
  }, [])

  const checkApiConnection = async () => {
    try {
      const response = await fetch(`${API_URL}/health`)
      if (response.ok) {
        setApiStatus('connected')
        fetchUsers()
      } else {
        setApiStatus('error')
      }
    } catch (err) {
      setApiStatus('error')
      console.error('API接続エラー:', err)
    }
  }

  // ユーザー一覧を取得
  const fetchUsers = async () => {
    try {
      const response = await fetch(`${API_URL}/users`)
      if (!response.ok) throw new Error('ユーザーの取得に失敗しました')
      const data = await response.json()
      setUsers(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : '不明なエラー')
    }
  }

  // ユーザーを作成
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const response = await fetch(`${API_URL}/users`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name, email }),
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.detail || 'ユーザーの作成に失敗しました')
      }

      setName('')
      setEmail('')
      fetchUsers()
    } catch (err) {
      setError(err instanceof Error ? err.message : '不明なエラー')
    } finally {
      setLoading(false)
    }
  }

  // ユーザーを削除
  const handleDelete = async (userId: number) => {
    try {
      const response = await fetch(`${API_URL}/users/${userId}`, {
        method: 'DELETE',
      })
      if (!response.ok) throw new Error('ユーザーの削除に失敗しました')
      fetchUsers()
    } catch (err) {
      setError(err instanceof Error ? err.message : '不明なエラー')
    }
  }

  return (
    <main className="min-h-screen p-8 max-w-4xl mx-auto">
      <div className="mb-8">
        <h1 className="text-4xl font-bold mb-4">
          🐳 Docker Practice - ユーザー管理
        </h1>
        <div className="flex items-center gap-2">
          <span className="text-sm">API状態:</span>
          {apiStatus === 'checking' && (
            <span className="text-yellow-600">確認中...</span>
          )}
          {apiStatus === 'connected' && (
            <span className="text-green-600 font-semibold">✓ 接続済み</span>
          )}
          {apiStatus === 'error' && (
            <span className="text-red-600 font-semibold">✗ 接続エラー</span>
          )}
        </div>
      </div>

      {/* ユーザー作成フォーム */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-8">
        <h2 className="text-2xl font-semibold mb-4">新規ユーザー登録</h2>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="name" className="block text-sm font-medium mb-1">
              名前
            </label>
            <input
              id="name"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>
          <div>
            <label htmlFor="email" className="block text-sm font-medium mb-1">
              メールアドレス
            </label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>
          {error && (
            <div className="text-red-600 text-sm">{error}</div>
          )}
          <button
            type="submit"
            disabled={loading || apiStatus !== 'connected'}
            className="w-full bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors"
          >
            {loading ? '登録中...' : 'ユーザーを登録'}
          </button>
        </form>
      </div>

      {/* ユーザー一覧 */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-2xl font-semibold mb-4">ユーザー一覧</h2>
        {users.length === 0 ? (
          <p className="text-gray-500">ユーザーがまだ登録されていません</p>
        ) : (
          <div className="space-y-3">
            {users.map((user) => (
              <div
                key={user.id}
                className="flex items-center justify-between p-4 border border-gray-200 rounded-md hover:bg-gray-50 transition-colors"
              >
                <div>
                  <p className="font-semibold">{user.name}</p>
                  <p className="text-sm text-gray-600">{user.email}</p>
                  <p className="text-xs text-gray-400">
                    登録日: {new Date(user.created_at).toLocaleString('ja-JP')}
                  </p>
                </div>
                <button
                  onClick={() => handleDelete(user.id)}
                  className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 transition-colors"
                >
                  削除
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* 学習用の説明 */}
      <div className="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-6">
        <h3 className="text-lg font-semibold mb-2 text-blue-900">
          📚 学習のポイント
        </h3>
        <ul className="list-disc list-inside space-y-1 text-blue-800 text-sm">
          <li>このアプリは3つのコンテナ（Next.js、FastAPI、PostgreSQL）で構成されています</li>
          <li>フロントエンドからバックエンドAPIへのリクエストを確認できます</li>
          <li>データベースへの保存・取得が正しく動作することを確認しましょう</li>
          <li>各コンテナのログを確認して、どのように連携しているか理解しましょう</li>
        </ul>
      </div>
    </main>
  )
}
