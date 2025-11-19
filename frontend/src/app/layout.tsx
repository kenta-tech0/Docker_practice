import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Docker Practice - Next.js Frontend',
  description: 'Docker学習用のサンプルアプリケーション',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  )
}
