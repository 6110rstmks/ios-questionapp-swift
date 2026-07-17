# 🔧 ビルドエラー修正完了

## ❌ 発生していたエラー

### 1. Question モデルの初期化エラー
```
error: Incorrect argument labels in call 
(have 'id:problem:answer:memo:isCorrect:createdAt:subcategoryId:', 
expected 'id:problem:answer:memo:isCorrect:answerCount:lastAnsweredDate:')
```

**原因**: `RandomProblemView.swift` のプレビューで使用していた `Question` のイニシャライザが、実際のモデル定義と一致していませんでした。

### 2. StatusBadge ファイルの欠落
```
error: Cannot find 'StatusBadge' in scope
```

**原因**: `ViewsComponentsStatusBadge.swift` ファイルが正しく作成されていませんでした。

## ✅ 実施した修正

### 1. RandomProblemView.swift のプレビュー修正

**修正前**:
```swift
Question(
    id: 1,
    problem: "サンプル問題",
    answer: ["回答1", "回答2"],
    memo: "メモ",
    isCorrect: .incorrect,
    createdAt: "2026-07-17",      // ❌ 存在しないプロパティ
    subcategoryId: 1               // ❌ 存在しないプロパティ
)
```

**修正後**:
```swift
Question(
    id: 1,
    problem: "サンプル問題",
    answer: ["回答1", "回答2"],
    memo: "メモ",
    isCorrect: .incorrect,
    answerCount: 0,                // ✅ 正しいプロパティ
    lastAnsweredDate: "2026-07-17" // ✅ 正しいプロパティ
)
```

### 2. StatusBadge.swift の再作成

`ViewsComponentsStatusBadge.swift` を正しく作成しました。

## 📋 Question モデルの正しい定義

参考のため、`Question` モデルの実際の定義を記載します：

```swift
struct Question: Codable, Identifiable {
    let id: Int
    let problem: String
    let answer: [String]
    let memo: String?
    let isCorrect: SolutionStatus
    let answerCount: Int           // ✅ 必須
    let lastAnsweredDate: String?  // ✅ 必須
    
    enum CodingKeys: String, CodingKey {
        case id
        case problem
        case answer
        case memo
        case isCorrect = "is_correct"
        case answerCount = "answer_count"
        case lastAnsweredDate = "last_answered_date"
    }
}
```

## 🔍 修正箇所まとめ

| ファイル | 変更内容 | ステータス |
|---------|---------|-----------|
| ViewsQuestionRandomProblemView.swift | プレビューの Question 初期化を修正 | ✅ 完了 |
| ViewsComponentsStatusBadge.swift | ファイルを再作成 | ✅ 完了 |

## 🎯 ビルド確認手順

1. **クリーンビルド**
   ```
   Xcode メニュー > Product > Clean Build Folder
   または Shift + Cmd + K
   ```

2. **ビルド実行**
   ```
   Cmd + B
   ```

3. **エラーがないことを確認**
   - ビルドが成功すること
   - 警告が最小限であること

4. **アプリの実行**
   ```
   Cmd + R
   ```

## 🐛 今後のエラー予防

### プレビューを書くときの注意点

1. **モデルの定義を確認**
   - イニシャライザのパラメータ名を確認
   - 必須プロパティとオプショナルを区別

2. **型を確認**
   - `Int` と `String` を混同しない
   - `SolutionStatus` は enum（`.correct`, `.temporary`, `.incorrect`）

3. **コピー&ペーストの活用**
   - 既存の正しいコードからコピーする
   - モデル定義からプロパティ名をコピー

### 推奨: テスト用のファクトリメソッド

将来的には、以下のようなファクトリメソッドを追加すると便利です：

```swift
extension Question {
    /// テストやプレビュー用のサンプルデータ
    static func sample(
        id: Int = 1,
        problem: String = "サンプル問題",
        answer: [String] = ["回答1", "回答2"],
        memo: String? = "メモ",
        isCorrect: SolutionStatus = .incorrect,
        answerCount: Int = 0,
        lastAnsweredDate: String? = "2026-07-17"
    ) -> Question {
        Question(
            id: id,
            problem: problem,
            answer: answer,
            memo: memo,
            isCorrect: isCorrect,
            answerCount: answerCount,
            lastAnsweredDate: lastAnsweredDate
        )
    }
}
```

使用例：
```swift
#Preview {
    RandomProblemView(
        problem: .sample(),  // ✨ 簡単！
        problemService: problemService,
        currentIndex: $currentIndex,
        isPresented: $isPresented
    )
}
```

## ✅ ビルド成功後の確認項目

- [ ] アプリが起動する
- [ ] ホーム画面が表示される
- [ ] カテゴリ一覧が表示される
- [ ] 問題に挑戦ボタンが動作する
- [ ] すべての画面遷移が正常

---

**修正日**: 2026年7月18日  
**ステータス**: ✅ ビルドエラー修正完了
