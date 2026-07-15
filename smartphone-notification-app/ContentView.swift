//
//  ContentView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/14.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // タイマー設定セクション
                timerSetupSection
                
                Divider()
                
                // タイマー一覧セクション
                timerListSection
            }
            .navigationTitle("タイマー通知")
            .task {
                // アプリ起動時に通知権限をリクエスト
                await viewModel.requestNotificationPermission()
                // 既存のタイマーと通知を同期
                await viewModel.syncTimersWithNotifications()
            }
            .alert("通知", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .alert("通知権限が必要です", isPresented: $viewModel.showSettingsAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("設定を開く") {
                    viewModel.openSettings()
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
    
    // MARK: - タイマー設定セクション
    
    private var timerSetupSection: some View {
        VStack(spacing: 15) {
            Text("時刻を設定")
                .font(.headline)
            
            HStack(spacing: 20) {
                // 時の選択
                VStack {
                    Text("時")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("時", selection: $viewModel.selectedHour) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .clipped()
                }
                
                Text(":")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                // 分の選択
                VStack {
                    Text("分")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("分", selection: $viewModel.selectedMinute) {
                        ForEach(0..<60) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                    .clipped()
                }
            }
            
            Button {
                Task {
                    await viewModel.addTimer()
                }
            } label: {
                Text("セット")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    // MARK: - タイマー一覧セクション
    
    private var timerListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("設定済みタイマー")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.timers.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "timer")
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary)
                    Text("タイマーが設定されていません")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                List {
                    ForEach(viewModel.timers) { timer in
                        TimerRowView(timer: timer)
                    }
                    .onDelete(perform: viewModel.deleteTimers)
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - タイマー行のビュー

struct TimerRowView: View {
    let timer: TimerNotification
    
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundStyle(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(timer.timeString)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(timer.timeUntilNotification)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
