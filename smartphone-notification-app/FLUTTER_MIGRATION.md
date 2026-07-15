# Flutterへの移植について

このiOSアプリをAndroidでも動作させたい場合、Flutterで再実装することをお勧めします。

## Flutterとは

- Googleが開発したクロスプラットフォームフレームワーク
- iOS、Android、Web、デスクトップアプリを1つのコードベースで開発可能
- 宣言的UI（SwiftUIに似ている）
- 言語: Dart（Swiftに似た文法）

## このアプリのFlutter実装イメージ

### 必要なパッケージ

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_local_notifications: ^17.0.0  # ローカル通知
  shared_preferences: ^2.2.0            # データ永続化
  provider: ^6.1.0                      # 状態管理
```

### ファイル構成（MVVMと同じ）

```
lib/
├── main.dart                      # エントリーポイント
├── models/
│   └── timer_notification.dart    # データモデル
├── viewmodels/
│   └── timer_viewmodel.dart       # ビジネスロジック
├── services/
│   └── notification_manager.dart  # 通知管理
└── views/
    └── timer_screen.dart          # UI
```

### コード例（簡略版）

#### モデル（timer_notification.dart）
```dart
class TimerNotification {
  final String id;
  final int hour;
  final int minute;
  final DateTime createdAt;

  TimerNotification({
    required this.id,
    required this.hour,
    required this.minute,
    required this.createdAt,
  });

  String get timeString => 
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TimerNotification.fromJson(Map<String, dynamic> json) => 
    TimerNotification(
      id: json['id'],
      hour: json['hour'],
      minute: json['minute'],
      createdAt: DateTime.parse(json['createdAt']),
    );
}
```

#### UI（timer_screen.dart - 簡略版）
```dart
import 'package:flutter/material.dart';

class TimerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('タイマー通知'),
      ),
      body: Column(
        children: [
          // 時刻選択セクション
          _buildTimePicker(),
          
          Divider(),
          
          // タイマー一覧
          _buildTimerList(),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('時刻を設定', style: TextStyle(fontSize: 18)),
          
          // 時刻ピッカー（ホイール式）
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 時のピッカー
              _buildNumberPicker(0, 23, '時'),
              
              Text(':', style: TextStyle(fontSize: 32)),
              
              // 分のピッカー
              _buildNumberPicker(0, 59, '分'),
            ],
          ),
          
          ElevatedButton(
            onPressed: () {/* タイマー追加 */},
            child: Text('セット'),
          ),
        ],
      ),
    );
  }
}
```

## Android版APKの作成手順

### 1. Flutterプロジェクトをビルド

```bash
flutter build apk --release
```

### 2. APKファイルの場所

```
build/app/outputs/flutter-apk/app-release.apk
```

### 3. Google Driveにアップロード

- このAPKファイルをGoogle Driveにアップロード
- 共有リンクを作成
- 友達に送る

### 4. 友達がインストール

1. Google Driveのリンクを開く
2. APKをダウンロード
3. 「提供元不明のアプリ」を許可（初回のみ）
4. インストール

**本当に簡単！**

## iOS/Androidの違い

| 項目 | iOS | Android（Flutter） |
|------|-----|-------------------|
| 配布方法 | TestFlight必須 | APKをGoogle Driveで送るだけ |
| コスト | 99ドル/年 | 無料 |
| 簡単さ | 複雑 | 簡単 |
| 開発環境 | Mac必須 | Mac/Windows/Linux |

## 移植の工数

このアプリは比較的シンプルなので、Flutterでの再実装は：

- **経験者**: 2〜3時間
- **Flutter初心者**: 1〜2日
- **プログラミング初心者**: 1週間程度

## 参考リンク

- Flutter公式: https://flutter.dev/
- Flutter通知プラグイン: https://pub.dev/packages/flutter_local_notifications
- Flutter入門（日本語）: https://flutter.dev/docs/get-started/install

---

## 次のステップ

もしAndroid対応に興味があれば：

1. **Flutterの環境構築**を手伝います
2. **このアプリのFlutter版を一緒に実装**できます
3. **APKビルドと配布方法**を詳しく説明します

どうしますか？
