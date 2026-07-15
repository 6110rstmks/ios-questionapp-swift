//
//  smartphone_notification_appTests.swift
//  smartphone-notification-appTests
//
//  Created by sora.sakamoto on 2026/07/14.
//

import Testing
@testable import smartphone_notification_app

struct smartphone_notification_appTests {

    @Test func timerNotificationCreation() async throws {
        let timer = TimerNotification(hour: 14, minute: 30)
        
        #expect(timer.hour == 14)
        #expect(timer.minute == 30)
        #expect(timer.timeString == "14:30")
        #expect(!timer.id.isEmpty)
    }
    
    @Test func timerTimeString() async throws {
        let timer1 = TimerNotification(hour: 9, minute: 5)
        #expect(timer1.timeString == "09:05")
        
        let timer2 = TimerNotification(hour: 23, minute: 59)
        #expect(timer2.timeString == "23:59")
    }
    
    @Test func nextNotificationDateCalculation() async throws {
        let timer = TimerNotification(hour: 12, minute: 0)
        let nextDate = timer.nextNotificationDate
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: nextDate)
        
        #expect(components.hour == 12)
        #expect(components.minute == 0)
    }

}
