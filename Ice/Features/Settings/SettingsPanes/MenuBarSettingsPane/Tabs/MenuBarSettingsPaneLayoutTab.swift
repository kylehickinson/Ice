//
//  MenuBarSettingsPaneLayoutTab.swift
//  Ice
//

import SwiftUI

struct MenuBarSettingsPaneLayoutTab: View {
    @AppStorage(Defaults.usesLayoutBarDecorations) var usesLayoutBarDecorations = true
    @EnvironmentObject var appState: AppState
    @State private var visibleItems = [LayoutBarItem]()
    @State private var hiddenItems = [LayoutBarItem]()
    @State private var alwaysHiddenItems = [LayoutBarItem]()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerText
                layoutViews
                Spacer()
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            handleAppear()
        }
        .onDisappear {
            handleDisappear()
        }
        .onChange(of: appState.itemManager.visibleItems) { _, items in
            updateVisibleItems(items)
        }
        .onChange(of: appState.itemManager.hiddenItems) { _, items in
            updateHiddenItems(items)
        }
        .onChange(of: appState.itemManager.alwaysHiddenItems) { _, items in
            updateAlwaysHiddenItems(items)
        }
    }

    @ViewBuilder
    private var headerText: some View {
        Text("Drag to arrange your menu bar items")
            .font(.title2)
            .annotation {
                Text("Tip: you can also arrange items by ⌘ (Command) + dragging them in the menu bar.")
            }
    }

    @ViewBuilder
    private var layoutViews: some View {
        Form {
            Section("Always Visible") {
                LayoutBar(
                    menuBar: appState.menuBar,
                    layoutItems: $visibleItems
                )
                .annotation {
                    Text("Drag menu bar items to this section if you want them to always be visible.")
                }
            }

            Spacer()
                .frame(maxHeight: 25)

            Section("Hidden") {
                LayoutBar(
                    menuBar: appState.menuBar,
                    layoutItems: $hiddenItems
                )
                .annotation {
                    Text("Drag menu bar items to this section if you want to hide them.")
                }
            }

            Spacer()
                .frame(maxHeight: 25)

            Section("Always Hidden") {
                LayoutBar(
                    menuBar: appState.menuBar,
                    layoutItems: $alwaysHiddenItems
                )
                .annotation {
                    Text("Drag menu bar items to this section if you want them to always be hidden.")
                }
            }
        }
    }

    private func handleAppear() {
        appState.menuBar.publishesAverageColor = usesLayoutBarDecorations
        updateVisibleItems(appState.itemManager.visibleItems)
        updateHiddenItems(appState.itemManager.hiddenItems)
        updateAlwaysHiddenItems(appState.itemManager.alwaysHiddenItems)
    }

    private func handleDisappear() {
        appState.menuBar.publishesAverageColor = false
    }

    private func updateVisibleItems(_ items: [MenuBarItem]) {
        let disabledDisplayNames = [
            "Clock",
            "Siri",
            "Control Center",
        ]
        visibleItems = items.map { item in
            LayoutBarItem(
                image: item.image,
                size: item.frame.size,
                toolTip: item.displayName,
                isEnabled: !disabledDisplayNames.contains(item.displayName)
            )
        }
    }

    private func updateHiddenItems(_ items: [MenuBarItem]) {
        hiddenItems = items.map { item in
            LayoutBarItem(
                image: item.image,
                size: item.frame.size,
                toolTip: item.displayName,
                isEnabled: true
            )
        }
    }

    private func updateAlwaysHiddenItems(_ items: [MenuBarItem]) {
        alwaysHiddenItems = items.map { item in
            LayoutBarItem(
                image: item.image,
                size: item.frame.size,
                toolTip: item.displayName,
                isEnabled: true
            )
        }
    }
}

#Preview {
    MenuBarSettingsPaneLayoutTab()
        .fixedSize()
        .environmentObject(AppState.shared)
}
