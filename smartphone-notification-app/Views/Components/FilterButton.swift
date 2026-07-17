//
//  FilterButton.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

/// フィルタリング用のボタンコンポーネント
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.gray.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    HStack {
        FilterButton(title: "All", isSelected: true, color: .gray) {}
        FilterButton(title: "未正解", isSelected: false, color: .red) {}
        FilterButton(title: "保留", isSelected: false, color: .orange) {}
    }
    .padding()
}
