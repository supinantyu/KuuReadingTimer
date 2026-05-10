# Kuu Reading Timer SwiftData版

クーと一緒に読書時間と感想を記録する、シンプルな読書タイマーアプリです。  
この版では SwiftData を使って、本と感想ログをアプリ内に永続保存します。

## 必要環境

- Xcode 15以降
- iOS 17以降
- SwiftUI
- SwiftData

## Features

- 読書タイマー
- 本ごとの感想記録
- 本棚画面
- 本ごとの合計読書時間 / 合計ページ数 / 感想件数
- 待機中 / 読書中 / 記録中でクーの画像が切り替わる
- SwiftDataで記録を保存
- 本と感想ログの削除対応

## Asset Names

以下の画像を `Assets.xcassets` に追加済みです。

- `kuu_waiting`
- `kuu_reading`
- `kuu_recording`

## 使い方

1. Xcodeで新規 iOS App プロジェクトを作成
2. このフォルダ内の `KuuReadingTimer` 配下のSwiftファイルと `Assets.xcassets` をプロジェクトへ追加
3. Deployment Targetを iOS 17.0 以上に設定
4. 実行

## 保存について

本データと感想ログは SwiftData のローカルストアに保存されます。  
アプリを閉じても記録は残ります。

ただし、アプリをアンインストールした場合はローカルデータも削除されます。  
将来的に端末変更やバックアップまで考える場合は、iCloud連携を追加してください。
