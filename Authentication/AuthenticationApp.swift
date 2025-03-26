//
//  AuthenticationApp.swift
//  Authentication
//
//  Created by vivek vadnala on 24/03/25.
//

import SwiftUI

@main
struct AuthenticationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
