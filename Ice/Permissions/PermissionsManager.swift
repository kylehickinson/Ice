//
//  PermissionsManager.swift
//  Ice
//

import Combine

/// A type that manages the permissions of the app.
class PermissionsManager: ObservableObject {
    /// A Boolean value that indicates whether the app has been
    /// granted all permissions.
    @Published var hasPermission: Bool = false

    let accessibilityPermission = AccessibilityPermission.shared

    private(set) weak var appState: AppState?

    private var cancellables = Set<AnyCancellable>()

    init(appState: AppState) {
        self.appState = appState
        configureCancellables()
    }

    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        accessibilityPermission.$hasPermission
            .sink(receiveValue: { [weak self] hasPermission in
                self?.hasPermission = hasPermission
            })
            .store(in: &c)

        cancellables = c
    }

    /// Stops running all permissions checks.
    func stopAllChecks() {
        accessibilityPermission.stopCheck()
    }
}
