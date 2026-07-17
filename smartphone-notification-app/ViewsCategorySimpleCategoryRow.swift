//
//  SimpleCategoryRow.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

/// カテゴリリスト用のシンプルな行ビュー（問題数などを表示しない軽量版）
struct SimpleCategoryRow: View {
    let category: SimplifiedCategory
    
    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "folder.fill")
                    .foregroundStyle(.blue)
            }
            
            // カテゴリ名
            Text(category.name)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            // 矢印
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        SimpleCategoryRow(
            category: SimplifiedCategory(
                id: 1,
                name: "サンプルカテゴリ",
                userId: 1
            )
        )
    }
}
