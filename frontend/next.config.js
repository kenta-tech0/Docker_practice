/** @type {import('next').NextConfig} */
const nextConfig = {
  // Docker環境での開発に適した設定
  output: 'standalone',
  // ホットリロードの設定（Docker環境での動作を改善）
  webpackDevMiddleware: config => {
    config.watchOptions = {
      poll: 1000,
      aggregateTimeout: 300,
    }
    return config
  },
}

module.exports = nextConfig
