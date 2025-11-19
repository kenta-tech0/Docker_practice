/** @type {import('next').NextConfig} */
const nextConfig = {
  // Docker環境での開発に適した設定
  output: 'standalone',
  // ホットリロードの設定（Docker環境での動作を改善）
  webpack: (config, { isServer }) => {
    // ファイル変更の監視設定（Dockerでのホットリロード用）
    config.watchOptions = {
      poll: 1000, // 1秒ごとにファイル変更をチェック
      aggregateTimeout: 300, // 変更検出後の待機時間
    }
    return config
  },
}

module.exports = nextConfig
