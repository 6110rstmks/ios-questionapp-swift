//
//  TimerNotification.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/14.
//

import Foundation

struct TimerNotification: Identifiable, Codable {
    let id: String
    let hour: Int
    let minute: Int
    let createdAt: Date
    
    init(hour: Int, minute: Int) {
        self.id = UUID().uuidString
        self.hour = hour
        self.minute = minute
        self.createdAt = Date()
    }
    
    /// 時刻を文字列で表示（例: "14:30"）
    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    /// 次の通知時刻を計算
    var nextNotificationDate: Date {
        let calendar = Calendar.current
        let now = Date()
        
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        guard var date = calendar.date(from: components) else {
            return now
        }
        
        // 設定時刻が現在時刻より前の場合は翌日にする
        if date <= now {
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return date
    }
    
    /// 次の通知までの時間を人間が読める形式で返す
    var timeUntilNotification: String {
        let interval = nextNotificationDate.timeIntervalSince(Date())
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)時間\(minutes)分後"
        } else {
            return "\(minutes)分後"
        }
    }
}
