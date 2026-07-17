//
//  CookieSession.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/18.
//

import Foundation

extension URLSession {
    /// Cookieの保存・送信を有効にしたデフォルトのセッション
    static var cookieEnabled: URLSession {
        let config = URLSessionConfiguration.default
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        config.httpCookieStorage = HTTPCookieStorage.shared
        return URLSession(configuration: config)
    }
}
