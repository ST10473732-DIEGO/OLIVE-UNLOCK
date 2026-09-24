//
//  AppEnvironment.swift
//  OliveUnlock
//
//  Owns app-wide, long-lived controllers so Settings pages share one instance instead of racing duplicates.
//

import Foundation
import Observation

@Observable
@MainActor
final class AppEnvironment {
    let pocController = POCController()
    let faceLabController = FaceLabController()
    let faceUnlockCoordinator: FaceUnlockCoordinator
    /// Held, not just constructed — owns a repeating timer that would silently stop enforcing auto-lock if deallocated.
    let sessionAutoLocker: SessionAutoLocker

    /// Revealed by tapping the app icon 5 times on the About page. Plain in-memory `var` so it resets on every relaunch.
    var isDebugSectionRevealed = false

    init() {
        // Before anything reads the session state: brings back a session that was unlocked when the Mac last shut down
        // (see "Keep unlocked after restart"). Runs ahead of `SessionAutoLocker`, whose first `evaluate()` then re-locks
        // it if the idle limit passed while the Mac was off.
        SecureCredentialManager.restorePersistedSession()
        faceUnlockCoordinator = FaceUnlockCoordinator(pocController: pocController)
        sessionAutoLocker = SessionAutoLocker(pocController: pocController)
        // `pocController` captured the session state before the restore above.
        pocController.refreshCredentialStatus()
    }
}
