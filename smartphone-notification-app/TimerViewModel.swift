//
//  TimerViewModel.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/14.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class TimerViewModel: ObservableObject {
    @Published var timers: [TimerNotification] = []
    @Published var selectedHour: Int = 12
    @Published var selectedMinute: Int = 0
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var showSettingsAlert: Bool = false
    
    private let notificationManager = NotificationManager.shared
    private let userDefaultsKey = "savedTimers"
    
    init() {
        loadTimers()
    }
    
    /// タイマーを追加
    func addTimer() async {
        // 通知権限の確認
        await notificationManager.checkAuthorizationStatus()
        
        guard notificationManager.authorizationStatus == .authorized else {
            alertMessage = "通知権限が許可されていません。設定から許可してください。"
            showSettingsAlert = true
            return
        }
        
        let timer = TimerNotification(hour: selectedHour, minute: selectedMinute)
        
        do {
            // 通知をスケジュール
            try await notificationManager.scheduleNotification(
                id: timer.id,
                hour: timer.hour,
                minute: timer.minute,
                title: "タイマー通知",
                body: "\(timer.timeString) のタイマーが鳴りました"
            )
            
            // タイマーリストに追加
            timers.append(timer)
            saveTimers()
            
            alertMessage = "\(timer.timeString) にタイマーをセットしました"
            showAlert = true
            
        } catch {
            alertMessage = "タイマーの設定に失敗しました: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    /// 設定アプリを開く
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    /// タイマーを削除
    func deleteTimer(_ timer: TimerNotification) {
        // 通知をキャンセル
        notificationManager.cancelNotification(id: timer.id)
        
        // リストから削除
        timers.removeAll { $0.id == timer.id }
        saveTimers()
    }
    
    /// タイマーを削除（IndexSet版 - List用）
    func deleteTimers(at offsets: IndexSet) {
        for index in offsets {
            let timer = timers[index]
            notificationManager.cancelNotification(id: timer.id)
        }
        timers.remove(atOffsets: offsets)
        saveTimers()
    }
    
    /// 通知権限をリクエスト
    func requestNotificationPermission() async {
        do {
            try await notificationManager.requestAuthorization()
            
            if notificationManager.authorizationStatus == .authorized {
                alertMessage = "通知権限が許可されました"
            } else {
                alertMessage = "通知権限が拒否されました。設定アプリから通知を許可してください。"
            }
            showAlert = true
            
        } catch {
            alertMessage = "通知権限のリクエストに失敗しました"
            showAlert = true
        }
    }
    
    // MARK: - Persistence
    
    private func saveTimers() {
        if let encoded = try? JSONEncoder().encode(timers) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadTimers() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode([TimerNotification].self, from: data) else {
            return
        }
        timers = decoded
    }
    
    /// アプリ起動時に既存のタイマーと通知を同期
    func syncTimersWithNotifications() async {
        let pendingNotifications = await notificationManager.getPendingNotifications()
        let pendingIds = Set(pendingNotifications.map { $0.identifier })
        
        // 通知がキャンセルされているタイマーを削除
        timers.removeAll { !pendingIds.contains($0.id) }
        saveTimers()
    }
}
