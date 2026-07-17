# 🚨 StatusBadge 重複エラー解決ガイド

## 問題の概要

`StatusBadge` の定義が複数存在し、以下のエラーが発生：
- `Invalid redeclaration of 'StatusBadge'`
- `Ambiguous use of 'init(status:)'`

## ✅ 解決手順（順番に実行）

### ステップ1: すべての StatusBadge ファイルを確認

Xcodeのプロジェクトナビゲーターで確認：
```
❌ ViewsComponentsStatusBadge.swift
❌ ViewsComponentsStatusBadge 2.swift
❌ ViewsComponentsStatusBadge 3.swift (もしあれば)
```

### ステップ2: ターミナルで実際のファイルを確認

```bash
cd /Users/sora.sakamoto/Desktop/smartphone-notification-app/smartphone-notification-app
find . -name "*StatusBadge*"
```

出力例：
```
./ViewsComponentsStatusBadge.swift
./ViewsComponentsStatusBadge 2.swift
```

### ステップ3: 重複ファイルを削除

#### 方法A: Xcodeから削除（推奨）

1. プロジェクトナビゲーターで番号付きファイルを選択
2. 右クリック → Delete
3. **"Move to Trash"** を選択

#### 方法B: ターミナルから削除

```bash
cd /Users/sora.sakamoto/Desktop/smartphone-notification-app/smartphone-notification-app

# 番号付きファイルを削除
rm "ViewsComponentsStatusBadge 2.swift"
rm "ViewsComponentsStatusBadge 3.swift"  # もしあれば
```

### ステップ4: Derived Data を削除

#### 方法A: ターミナルから（最も確実）

```bash
# Xcodeを終了してから実行
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

#### 方法B: Xcodeから

1. Xcode → Settings... (Cmd + ,)
2. Locations タブ
3. Derived Data の右の矢印をクリック
4. Finderで開いたフォルダの中身をすべて削除

### ステップ5: Xcodeプロジェクトをクリーン

```
1. Xcodeを完全に終了
2. Xcodeを再起動
3. プロジェクトを開く
4. Shift + Cmd + K (Clean Build Folder)
```

### ステップ6: ビルド

```
Cmd + B
```

## 🔍 ステップ6で失敗した場合

### プロジェクトファイル (.pbxproj) を確認

重複参照が残っている可能性があります。

```bash
cd /Users/sora.sakamoto/Desktop/smartphone-notification-app
grep -n "StatusBadge" smartphone-notification-app.xcodeproj/project.pbxproj
```

複数の参照が見つかった場合、手動で編集が必要かもしれません。

### 最終手段: ファイルの完全再作成

1. **すべての StatusBadge ファイルを削除**
   ```bash
   cd /Users/sora.sakamoto/Desktop/smartphone-notification-app/smartphone-notification-app
   rm *StatusBadge*
   ```

2. **Xcodeで新しいファイルを作成**
   - File → New → File...
   - Swift File
   - 名前: `StatusBadge`
   - Save to: `Views/Components/` グループ（まだ作成していない場合はプロジェクトルート）

3. **以下のコードをコピー**

```swift
//
//  StatusBadge.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

/// 問題の解答ステータスを表示するバッジ
struct StatusBadge: View {
    let status: SolutionStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color)
        .clipShape(Capsule())
    }
    
    private var color: Color {
        switch status {
        case .correct: return .green
        case .temporary: return .orange
        case .incorrect: return .red
        }
    }
    
    private var label: String {
        switch status {
        case .correct: return "正解"
        case .temporary: return "保留"
        case .incorrect: return "未正解"
        }
    }
    
    private var icon: String {
        switch status {
        case .correct: return "checkmark.circle.fill"
        case .temporary: return "clock.fill"
        case .incorrect: return "xmark.circle.fill"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBadge(status: .correct)
        StatusBadge(status: .temporary)
        StatusBadge(status: .incorrect)
    }
    .padding()
}
```

4. **保存してビルド**

## 🎯 チェックリスト

実行前に確認：

- [ ] すべての重複 StatusBadge ファイルを削除
- [ ] ターミナルで実際のファイル数を確認
- [ ] Derived Data を削除
- [ ] Xcodeを再起動
- [ ] Clean Build Folder を実行
- [ ] ビルドが成功する

## 💡 今後の予防

### ファイル作成時のベストプラクティス

1. **File → New → File を使う**
   - 直接 Finder でファイルを作成しない

2. **作成後すぐに確認**
   - プロジェクトナビゲーターで重複がないか確認
   - 番号付きファイル (` 2`, ` 3`) がある場合はすぐに削除

3. **定期的にクリーン**
   - `Shift + Cmd + K` を定期的に実行
   - ビルドエラーが出たらまずクリーン

4. **Git を使用している場合**
   ```bash
   git status
   ```
   で意図しないファイルが追加されていないか確認

## 🔗 関連ファイル

- [BUILD_FIX.md](./BUILD_FIX.md) - その他のビルドエラー修正
- [FILE_STRUCTURE_GUIDE.md](./FILE_STRUCTURE_GUIDE.md) - プロジェクト構造ガイド

---

**作成日**: 2026年7月18日  
**問題**: StatusBadge の重複定義  
**ステータス**: 解決手順を提供
