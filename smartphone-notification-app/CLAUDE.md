# smartphone-notification-app

テストの実行はしなくていいです。手動でするので。

## プロジェクト概要

問題演習アプリ（iOS / SwiftUI）。ログイン後、カテゴリ・サブカテゴリを辿って問題を解いたり、ランダム出題やカレンダーから過去の問題を振り返ったりできる。

## プロジェクト構成

Xcode 16のフォルダ自動同期（`PBXFileSystemSynchronizedRootGroup`）を使用しているため、ディレクトリにファイルを置くだけでターゲットに追加される（`.pbxproj`の手動編集は不要）。

```
App/            エントリーポイント
Models/         データモデル
Services/       API通信（ObservableObject、@MainActor）
Views/          画面・コンポーネント
  Home/
  Category/
  Subcategory/
  Question/
  DatePicker/
  Components/
```

### App

- **smartphone_notification_appApp.swift**: `@main`。`WindowGroup`内で`RootView`を表示。

### Models

- **AuthModels.swift**: `LoginRequest` / `User` / `ErrorResponse`
- **Category.swift**: カテゴリ（snake_case JSONに対応する`CodingKeys`あり）
- **Subcategory.swift**: サブカテゴリ
- **Question.swift**: 問題データと`SolutionStatus`（正解/保留/未正解）

### Services

すべて `init(session: URLSession = .cookieEnabled)` の形でURLSessionを注入可能にしている（テストでモックに差し替えるため）。`CookieSession.swift`がCookie保存を有効にしたデフォルトセッションを提供する。

- **AuthService**: ログイン・認証チェック・ログアウト（`http://52.69.161.160/api/auth`）。`init()`でアプリ起動時に自動で認証チェックを行う。
- **CategoryService**: カテゴリ一覧のページネーション取得
- **SubcategoryService**: カテゴリIDに紐づくサブカテゴリ取得（検索ワード対応）
- **QuestionService**: サブカテゴリIDに紐づく問題取得
- **ProblemService**: ランダム/条件指定での問題取得（POST）
- **CalendarService**: カテゴリID＋日付での問題取得（カレンダー機能用）

### Views

画面遷移: `RootView` → (未ログイン: `LoginView` / ログイン済み: `HomeView`)

- **RootView**: `AuthService.isAuthenticated`に応じて`LoginView`/`HomeView`を切り替えるルート
- **LoginView**: ログイン画面
- **HomeView**: カテゴリ一覧への導線 + ランダム出題（`RandomProblemView`をシート表示）
- **Category/CategoryListView**: カテゴリ一覧（検索フィルタ付き）。`SimpleCategoryRow`で各行を表示
- **Category/CategoryPageView**: カテゴリ詳細（サブカテゴリ一覧、カレンダー機能への導線）
- **Subcategory/SubcategoryPageView**: サブカテゴリ内の問題一覧
- **Question/QuestionPageView**: 問題の詳細表示・ページ送り
- **Question/RandomProblemView**: ランダム出題された問題を1問ずつ解く（シート）
- **Question/QuestionTestView**: `QuestionService`の動作確認用デバッグ画面（`CategoryListView`からアクセス可）
- **DatePicker/SimpleDatePickerView**: 日付・カテゴリ指定で過去の問題を振り返る（`CalendarService`使用）
- **Components/**: `FilterButton`, `HomeButtonView`, `StatusBadge`（複数画面で使う共通パーツ）

### テスト

`smartphone-notification-appTests/`にMirror構成（`Models/`, `Services/`, `Support/`）。

- **Models/**: `Category`/`Subcategory`/`Question`/`AuthModels`のCodableデコード・エンコードや`SolutionStatus`のロジックを検証（ネットワーク不要）
- **Services/**: 各Serviceに`MockURLProtocol`で作ったスタブ`URLSession`を注入し、実サーバーにアクセスせずに成功/エラー/デコード失敗のパスを検証
- **Support/MockURLProtocol.swift**: テストごとに一意なセッションIDをリクエストヘッダーに載せて振り分けるURLProtocolモック。並列実行されるテスト同士でスタブが競合しない設計
- **smartphone-notification-appUITests/**: UIテスト（起動確認など）

## 技術スタック

- **言語**: Swift 5（`SWIFT_APPROACHABLE_CONCURRENCY = YES`）
- **UIフレームワーク**: SwiftUI
- **最小対応OS**: iOS 26.2
- **テストフレームワーク**: Swift Testing
- **非同期処理**: Swift Concurrency（async/await, `@MainActor`）
- **通信**: URLSession（Cookieベースのセッション認証、`http://52.69.161.160/api`）
- **アーキテクチャ**: Service層（`ObservableObject` + `@Published`）+ SwiftUI View。ViewModel層は現状なし（各Viewが対応するServiceを直接`@StateObject`/`@EnvironmentObject`で保持）

## 開発時の注意点

- ファイルを追加する際はXcodeでの操作でもFinderでの直接作成でも自動的にターゲットに含まれるため、同名ファイルの重複作成に注意（重複すると`invalid redeclaration`エラーになる）

## トラブルシューティング

### ビルドエラーが発生する場合

1. Clean Build Folder（Cmd + Shift + K）
2. Derived Dataの削除
3. 同名ファイルが複数存在していないか確認（`find smartphone-notification-app -name "*.swift" | xargs -n1 basename | sort | uniq -d`）

## 参考資料

- [SwiftUI公式ドキュメント](https://developer.apple.com/documentation/swiftui)
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [Swift Concurrency](https://developer.apple.com/documentation/swift/swift-standard-library/concurrency)
