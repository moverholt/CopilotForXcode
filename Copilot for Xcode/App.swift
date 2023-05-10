import Client
import SwiftUI
import UpdateChecker
import XPCShared
import HostApp

@main
struct CopilotForXcodeApp: App {
    var body: some Scene {
        WindowGroup {
            TabContainer()
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    UserDefaults.setupDefaultSettings()
                }
                .environment(\.updateChecker, UpdateChecker(hostBundle: Bundle.main))
        }
        .windowStyle(.hiddenTitleBar)
    }
}

var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
