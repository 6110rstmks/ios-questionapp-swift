//
//  LoginView.swift
//  smartphone-notification-app
//
//  Created by sora.sakamoto on 2026/07/17.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.indigo, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.white)
                        }
                        
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("ログインして始める")
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    
                    // Main Card
                    VStack(spacing: 24) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.gray)
                            
                            HStack {
                                Image(systemName: "person")
                                    .foregroundStyle(.gray)
                                
                                TextField("Enter your username", text: $username)
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.gray)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundStyle(.gray)
                                
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                        .textContentType(.password)
                                        .foregroundStyle(.white)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                        .textContentType(.password)
                                        .foregroundStyle(.white)
                                }
                                
                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // Error Message
                        if let errorMessage = authService.errorMessage {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        // Submit Button
                        Button {
                            Task {
                                await handleLogin()
                            }
                        } label: {
                            HStack {
                                if authService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Signing in...")
                                } else {
                                    Image(systemName: "arrow.right")
                                    Text("Sign in")
                                }
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.indigo, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(username.isEmpty || password.isEmpty || authService.isLoading)
                        .opacity((username.isEmpty || password.isEmpty || authService.isLoading) ? 0.5 : 1.0)
                    }
                    .padding(32)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Footer
                    Text("Secure login with modern encryption")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .padding(.top, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .onSubmit {
            if !username.isEmpty && !password.isEmpty {
                Task {
                    await handleLogin()
                }
            }
        }
    }
    
    private func handleLogin() async {
        let success = await authService.login(username: username, password: password)
        if success {
            // ログイン成功 - AuthServiceのisAuthenticatedがtrueになる
            print("✅ ログイン成功")
        }
    }
}

#Preview {
    LoginView()
}
