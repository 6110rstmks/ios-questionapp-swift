//
//  NotificationManager.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/14.
//

import Foundation
import Combine
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {}
    
    /// 通知権限をリクエスト
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        
        if granted {
            authorizationStatus = .authorized
        } else {
            authorizationStatus = .denied
        }
    }
    
    /// 現在の権限状態を確認
    func checkAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    /// 指定時刻に通知をスケジュール
    func scheduleNotification(id: String, hour: Int, minute: Int, title: String, body: String) async throws {
        let center = UNUserNotificationCenter.current()
        
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // 時刻指定のトリガーを作成
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // リクエストの作成と登録
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }
    
    /// 通知をキャンセル
    func cancelNotification(id: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    /// すべての保留中の通知を取得
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let center = UNUserNotificationCenter.current()
        return await center.pendingNotificationRequests()
    }
}
