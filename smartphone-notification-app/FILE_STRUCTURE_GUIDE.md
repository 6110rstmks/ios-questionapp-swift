# プロジェクト構造整理ガイド

## 📁 推奨ディレクトリ構造

```
smartphone-notification-app/
├── Views/
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Category/
│   │   ├── CategoryListView.swift
│   │   ├── CategoryPageView.swift
│   │   └── SimpleCategoryRow.swift
│   ├── Subcategory/
│   │   └── SubcategoryPageView.swift
│   ├── Question/
│   │   ├── QuestionPageView.swift
│   │   ├── QuestionTestView.swift
│   │   └── RandomProblemView.swift
│   ├── DatePicker/
│   │   └── SimpleDatePickerView.swift
│   └── Components/
│       ├── HomeButtonView.swift
│       ├── StatusBadge.swift
│       └── FilterButton.swift
├── Services/
│   ├── AuthService.swift
│   ├── ProblemService.swift
│   ├── CategoryService.swift
│   ├── SubcategoryService.swift
│   └── CalendarService.swift
├── Models/
│   ├── AuthModels.swift
│   ├── Category.swift
│   └── Question.swift
└── App/
    └── smartphone_notification_appApp.swift
```

## 🔄 ファイル移動手順

Xcodeで以下の手順でファイルを整理してください：

### 1. グループ（フォルダ）を作成

1. プロジェクトナビゲーターで、プロジェクトのルートを右クリック
2. "New Group" を選択し、以下のグループを作成：
   - `Views`
   - `Services`
   - `Models`
   - `App`

3. `Views` グループ内に以下のサブグループを作成：
   - `Home`
   - `Category`
   - `Subcategory`
   - `Question`
   - `DatePicker`
   - `Components`

### 2. ファイルを適切なグループに移動

#### Views グループ

**Home/**
- `HomeView.swift` → `Views/Home/`

**Category/**
- `CategoryListView.swift` → `Views/Category/`
- `CategoryPageView.swift` → `Views/Category/`
- `SimpleCategoryRow.swift` → `Views/Category/` (新規作成済み)

**Subcategory/**
- `SubcategoryPageView.swift` → `Views/Subcategory/`

**Question/**
- `QuestionPageView.swift` → `Views/Question/`
- `QuestionTestView.swift` → `Views/Question/`
- `RandomProblemView.swift` → `Views/Question/` (新規作成済み)

**DatePicker/**
- `SimpleDatePickerView.swift` → `Views/DatePicker/`

**Components/**
- `HomeButtonView.swift` → `Views/Components/` (新規作成済み)
- `StatusBadge.swift` → `Views/Components/` (新規作成済み)
- `FilterButton.swift` → `Views/Components/` (新規作成済み)

#### Services グループ

- `AuthService.swift` → `Services/`
- `ProblemService.swift` → `Services/`
- `CategoryService.swift` → `Services/`
- `SubcategoryService.swift` → `Services/`
- `CalendarService.swift` → `Services/`

#### Models グループ

- `AuthModels.swift` → `Models/`
- `Category.swift` → `Models/`
- `Question.swift` → `Models/`

#### App グループ

- `smartphone_notification_appApp.swift` → `App/`

### 3. 作成済みの新規ファイル

以下のファイルは既に作成されています：

✅ `Views/Components/HomeButtonView.swift`
✅ `Views/Components/StatusBadge.swift`
✅ `Views/Components/FilterButton.swift`
✅ `Views/Question/RandomProblemView.swift`
✅ `Views/Category/SimpleCategoryRow.swift`

### 4. 既存ファイルから削除すべきコード

**HomeView.swift** から削除済み：
- ✅ `HomeButtonView` struct
- ✅ `RandomProblemView` struct

**CategoryListView.swift** から削除すべき：
- `SimpleCategoryRow` struct → 別ファイルに分離済み

**SimpleDatePickerView.swift** から削除すべき：
- `FilterButton` struct → 別ファイルに分離済み
- `StatusBadge` struct → 別ファイルに分離済み

### 5. インポート文の確認

各ファイルが正しく動作するよう、必要に応じて `import` 文を確認してください。
SwiftUIプロジェクトでは、同じターゲット内のファイルは自動的に参照できるため、
通常は追加のインポートは不要です。

### 6. ビルドとテスト

1. Xcode で `Cmd + B` でビルド
2. エラーがないことを確認
3. アプリを実行して動作確認

## 📝 整理のメリット

### コードの可読性向上
- ファイルの役割が明確になる
- 関連するコードが近くにある

### メンテナンス性向上
- 修正したいファイルをすぐに見つけられる
- チーム開発時の競合が減る

### 拡張性向上
- 新機能の追加場所が明確
- コンポーネントの再利用が容易

### パフォーマンス
- 小さいファイルはコンパイルが速い
- 差分ビルドが効率的

## 🎯 今後の開発のベストプラクティス

1. **Views** - UI関連のコード
   - 1画面 = 1ファイルを基本とする
   - 複数の画面で使う共通コンポーネントは `Components/` に配置

2. **Services** - ビジネスロジックとAPI通信
   - `ObservableObject` クラス
   - データ取得・更新のロジック

3. **Models** - データ構造の定義
   - `struct` や `enum` の定義
   - `Codable`, `Identifiable` への準拠

4. **ファイルサイズの目安**
   - 1ファイル 200-300行程度を目安に
   - それ以上になったら分割を検討

## ✨ 完了後の確認項目

- [ ] すべてのファイルが適切なグループに配置されている
- [ ] ビルドエラーがない
- [ ] アプリが正常に起動する
- [ ] すべての画面が正常に動作する
- [ ] 不要なファイルが削除されている
