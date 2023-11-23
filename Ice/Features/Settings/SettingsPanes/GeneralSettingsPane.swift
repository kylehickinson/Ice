//
//  GeneralSettingsPane.swift
//  Ice
//

import LaunchAtLogin
import SwiftUI

struct GeneralSettingsPane: View {
    @AppStorage(Defaults.secondaryActionModifier) var secondaryActionModifier = Hotkey.Modifiers.option
    @EnvironmentObject var appState: AppState
    @State private var isImportingCustomIceIcon = false
    @State private var isPresentingError = false
    @State private var presentedError: LocalizedErrorBox?

    private var menuBar: MenuBar {
        appState.menuBar
    }

    var body: some View {
        Form {
            Section {
                launchAtLogin
            }
            Section {
                alwaysHiddenOptions
            }
            Section {
                iceIconOptions
            }
            Section("Hotkeys") {
                hiddenRecorder
                alwaysHiddenRecorder
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxHeight: .infinity)
        .errorOverlay(RecordingFailure.self)
        .alert(isPresented: $isPresentingError, error: presentedError) {
            Button("OK") {
                presentedError = nil
                isPresentingError = false
            }
        }
        .bottomBar {
            HStack {
                Spacer()
                Button("Quit \(Constants.appName)") {
                    NSApp.terminate(nil)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var launchAtLogin: some View {
        LaunchAtLogin.Toggle()
    }

    @ViewBuilder
    private var alwaysHiddenOptions: some View {
        if let section = menuBar.section(withName: .alwaysHidden) {
            Toggle(isOn: section.bindings.isEnabled) {
                Text("Enable \"\(section.name.rawValue)\" section")
            }

            if section.isEnabled {
                Picker(selection: $secondaryActionModifier) {
                    ForEach(ControlItem.secondaryActionModifiers, id: \.self) { modifier in
                        Text("\(modifier.stringValue) \(modifier.label)").tag(modifier)
                    }
                } label: {
                    Text("Modifier")
                    Text("\(secondaryActionModifier.label) (\(secondaryActionModifier.stringValue)) + clicking either of \(Constants.appName)'s menu bar items will temporarily show this section")
                }
            }
        }
    }

    @ViewBuilder
    private func label(for imageSet: ControlItemImageSet) -> some View {
        Label {
            Text(imageSet.name.rawValue)
        } icon: {
            if let nsImage = imageSet.hidden.nsImage(for: menuBar) {
                Image(nsImage: nsImage)
            }
        }
        .tag(imageSet)
    }

    @ViewBuilder
    private var iceIconOptions: some View {
        LabeledContent("\(Constants.appName) Icon") {
            Menu {
                Picker("\(Constants.appName) Icon", selection: menuBar.bindings.iceIcon) {
                    ForEach(ControlItemImageSet.userSelectableImageSets) { imageSet in
                        label(for: imageSet)
                    }

                    if let lastCustomIceIcon = menuBar.lastCustomIceIcon {
                        label(for: lastCustomIceIcon)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()

                Button("Choose Image…") {
                    isImportingCustomIceIcon = true
                }
            } label: {
                label(for: menuBar.iceIcon)
            }
            .labelStyle(.titleAndIcon)
            .scaledToFit()
            .fixedSize()
        }
        .fileImporter(
            isPresented: $isImportingCustomIceIcon,
            allowedContentTypes: [.image]
        ) { result in
            do {
                let url = try result.get()
                if url.startAccessingSecurityScopedResource() {
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    let data = try Data(contentsOf: url)
                    menuBar.iceIcon = ControlItemImageSet(
                        name: .custom,
                        hidden: .data(data),
                        visible: .data(data)
                    )
                }
            } catch {
                presentedError = LocalizedErrorBox(error: error)
                isPresentingError = true
            }
        }

        if case .custom = menuBar.iceIcon.name {
            Toggle(isOn: menuBar.bindings.customIceIconIsTemplate) {
                Text("Use template image")
                if menuBar.customIceIconIsTemplate {
                    Text("The icon is displayed as a monochrome image matching the system appearance")
                } else {
                    Text("The icon is displayed with its original appearance")
                }
            }
        }
    }

    @ViewBuilder
    private func hotkeyRecorder(for section: MenuBarSection) -> some View {
        if section.isEnabled {
            HotkeyRecorder(section: section) {
                Text("Toggle the \"\(section.name.rawValue)\" menu bar section")
            }
        }
    }

    @ViewBuilder
    private var hiddenRecorder: some View {
        if let section = menuBar.section(withName: .hidden) {
            hotkeyRecorder(for: section)
        }
    }

    @ViewBuilder
    private var alwaysHiddenRecorder: some View {
        if let section = menuBar.section(withName: .alwaysHidden) {
            hotkeyRecorder(for: section)
        }
    }
}

#Preview {
    GeneralSettingsPane()
        .fixedSize()
        .buttonStyle(.custom)
        .environmentObject(AppState.shared)
}
