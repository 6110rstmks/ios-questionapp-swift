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
