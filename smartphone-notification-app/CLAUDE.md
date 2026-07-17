# smartphone-notification-app

## プロジェクト構成

### メインファイル

- **smartphone_notification_appApp.swift**
  - アプリケーションのエントリーポイント
  - `@main`属性を持つApp構造体
  - `WindowGroup`内で`ContentView`を表示

- **ContentView.swift**
  - アプリケーションのメインビュー
  - タイマー設定UIと一覧表示
  - 時・分のホイールピッカー
  - タイマーリストの表示と削除機能

- **TimerViewModel.swift**
  - ViewModelレイヤー（MVVM）
  - タイマーの追加・削除ロジック
  - 通知権限の管理
  - UserDefaultsによるデータ永続化

- **NotificationManager.swift**
  - 通知機能の専用管理クラス（シングルトン）
  - UNUserNotificationCenterのラッパー
  - 通知のスケジューリング、キャンセル、権限管理
  - @MainActorで安全な状態管理

- **TimerNotification.swift**
  - タイマーのデータモデル
  - Identifiable、Codableプロトコルに準拠
  - 時刻計算や表示用ユーティリティメソッド

- **TimerRowView.swift**
  - タイマー一覧の各行を表示するビュー
  - ContentView内で定義

### テスト

- **smartphone_notification_appTests.swift**
  - Swift Testingフレームワークを使用したユニットテスト
  - TimerNotificationモデルのテスト
  - 時刻文字列のフォーマット確認
  - 次回通知時刻の計算テスト

- **smartphone_notification_appUITests.swift**
  - UIテスト用ファイル

- **smartphone_notification_appUITestsLaunchTests.swift**
  - アプリ起動時のUIテスト

## 技術スタック

- **言語**: Swift
- **UIフレームワーク**: SwiftUI
- **最小対応OS**: iOS（バージョンはプロジェクト設定による）
- **テストフレームワーク**: Swift Testing（新しいマクロベースのテストフレームワーク）
- **非同期処理**: Swift Concurrency (async/await, @MainActor)
- **通知フレームワーク**: UserNotifications (UNUserNotificationCenter)
- **データ永続化**: UserDefaults + Codable
- **アーキテクチャパターン**: MVVM (Model-View-ViewModel)

## ビルド状態

✅ プロジェクトは正常にビルド可能です。コンパイルエラーはありません。

## 実装済み機能

### タイマー通知機能

指定した時刻に通知が鳴るタイマー機能を実装しています。

**主な機能:**

1. **時刻設定UI**
   - ホイールピッカーで時・分を選択
   - 直感的な時刻入力インターフェース

2. **ローカル通知**
   - 指定時刻に音付き通知を配信
   - UNUserNotificationCenterを使用

3. **権限管理**
   - アプリ起動時に通知権限を自動リクエスト
   - 権限状態の確認と適切なエラーハンドリング

4. **タイマー管理**
   - 設定済みタイマーの一覧表示
   - スワイプで削除機能
   - 次の通知までの残り時間表示
   - UserDefaultsによる永続化

### アーキテクチャ

**MVVMパターン**を採用し、責務を明確に分離:

- **Model**: `TimerNotification` - タイマーデータモデル
- **View**: `ContentView`, `TimerRowView` - UI表示
- **ViewModel**: `TimerViewModel` - ビジネスロジックと状態管理
- **Manager**: `NotificationManager` - 通知機能の専用クラス（シングルトン）

## 使用方法

1. **アプリを起動**
   - 初回起動時に通知権限のリクエストが表示されます
   - 「許可」を選択してください

2. **タイマーを設定**
   - ホイールピッカーで時と分を選択
   - 「セット」ボタンをタップ
   - 確認メッセージが表示されます

3. **タイマーの確認**
   - 設定済みタイマーが一覧表示されます
   - 各タイマーには次の通知までの残り時間が表示されます

4. **タイマーの削除**
   - タイマーを左にスワイプ
   - 「削除」ボタンをタップ
   - または、左スワイプしたまま削除

## コード設計の特徴

### 責務の分離

- **NotificationManager**: 通知機能のみに特化
- **TimerViewModel**: ビジネスロジックと状態管理
- **ContentView**: UI表示のみ
- **TimerNotification**: データモデル

### Swift Concurrencyの活用

- `async/await`による非同期処理
- `@MainActor`によるメインスレッド保証
- データ競合の防止

### 型安全性

- `Identifiable`による一意性保証
- `Codable`による安全なシリアライゼーション
- SwiftUIの型システムとの統合

## 今後の開発方向性

プロジェクトの拡張として、以下のような機能追加が考えられます:

1. **通知機能の拡張**
   - リピート通知（毎日、毎週など）
   - カスタム通知音の選択
   - 通知メッセージのカスタマイズ
   - スヌーズ機能

2. **ユーザーインターフェースの改善**
   - タイマー編集機能
   - タイマーのオン/オフ切り替え
   - タイマーのグループ化・カテゴリ分類
   - ダークモード対応の最適化

3. **追加機能**
   - ウィジェット対応（次のタイマー表示）
   - Apple Watchアプリ
   - 通知履歴の確認
   - 統計情報（通知回数、使用頻度など）
   - iCloudによるデバイス間同期

## 開発時の注意点

### 通知権限

- アプリ初回起動時に自動的に通知権限をリクエスト
- ユーザーが権限を拒否した場合、設定アプリへの誘導が必要
- 権限状態は`NotificationManager`で管理

### 通知のスケジューリング

- `UNCalendarNotificationTrigger`を使用した時刻指定
- 通知は一度のみ（repeats: false）
- 過去の時刻を指定した場合、翌日に通知される

### データの永続化

- `UserDefaults`でタイマーリストを保存
- `Codable`プロトコルによるシリアライゼーション
- アプリ起動時に保存データを読み込み

### アーキテクチャ

**実装済みのMVVMパターン:**

- **Model (TimerNotification)**: ビジネスデータとロジック
- **View (ContentView, TimerRowView)**: UI表示
- **ViewModel (TimerViewModel)**: ViewとModelの橋渡し、状態管理
- **Manager (NotificationManager)**: 通知機能の専用レイヤー

**Swift Concurrencyの活用:**
- 非同期処理には`async/await`を使用
- `@MainActor`でメインスレッド実行を保証
- データ競合を防止

**状態管理:**
- `@StateObject`と`@Published`による反応的UI
- SwiftUIの宣言的な状態管理

## 次のステップ

実装済みの基本機能を基に、以下の拡張が可能です:

1. リピート通知機能の追加
2. タイマー編集機能の実装
3. 通知音のカスタマイズ
4. ウィジェット対応
5. Apple Watch対応
6. iCloud同期機能
7. 通知履歴の表示
8. より詳細な統計情報

## トラブルシューティング

### 通知が届かない場合

1. 設定アプリで通知権限を確認
2. デバイスのおやすみモード/集中モードを確認
3. タイマーが正しく保存されているか確認（一覧に表示されているか）

### ビルドエラーが発生する場合

1. Xcodeのバージョンを確認（iOS 15以上推奨）
2. Clean Build Folder（Cmd + Shift + K）
3. Derived Dataの削除

## 参考資料

- [Apple公式ドキュメント - User Notifications](https://developer.apple.com/documentation/usernotifications)
- [SwiftUI公式ドキュメント](https://developer.apple.com/documentation/swiftui)
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [Swift Concurrency](https://developer.apple.com/documentation/swift/swift-standard-library/concurrency)
---

## 実装完了チェックリスト

- ✅ NotificationManager（通知管理クラス）の実装
- ✅ TimerNotification（データモデル）の実装
- ✅ TimerViewModel（ビジネスロジック）の実装
- ✅ ContentView（UI）の実装
- ✅ 時刻選択UI（ホイールピッカー）
- ✅ タイマー一覧表示
- ✅ タイマー削除機能（スワイプ）
- ✅ 通知権限のリクエスト
- ✅ ローカル通知のスケジューリング
- ✅ データの永続化（UserDefaults）
- ✅ ユニットテストの追加
- ✅ MVVMアーキテクチャの採用
- ✅ Swift Concurrency（async/await）の使用
- ✅ ビルド確認完了

