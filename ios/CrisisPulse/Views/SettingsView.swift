//
//  SettingsView.swift
//  CrisisPulse
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var app: AppState
    @StateObject private var notifications = NotificationService()

    @State private var email: String = ""
    @State private var subscribeStatus: SubscribeUIStatus = .idle

    enum SubscribeUIStatus: Equatable {
        case idle, loading, success, alreadySubscribed, error(String)
    }

    var body: some View {
        NavigationStack {
            Form {
                // ===== Language =====
                Section(T("settings.language", app.language)) {
                    Picker("", selection: $app.language) {
                        Text(T("settings.lang.en", app.language)).tag("en")
                        Text(T("settings.lang.zh", app.language)).tag("zh")
                    }
                    .pickerStyle(.segmented)
                }

                // ===== Notifications =====
                Section(T("settings.notifications", app.language)) {
                    Toggle(T("settings.notifyEscalation", app.language),
                           isOn: $app.notificationsEnabled)
                    .onChange(of: app.notificationsEnabled) { _, newValue in
                        if newValue {
                            Task { await notifications.requestAuthorization() }
                        }
                    }
                }

                // ===== Email subscribe =====
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(T("settings.subscribe.desc", app.language))
                            .font(.system(size: 13))
                            .foregroundStyle(Color.cpTextSecondary)
                        TextField(T("settings.subscribe.email", app.language), text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.send)
                            .onSubmit { submitSubscribe() }

                        Button {
                            submitSubscribe()
                        } label: {
                            HStack {
                                if subscribeStatus == .loading {
                                    ProgressView().tint(.white)
                                    Text(T("settings.subscribe.subscribing", app.language))
                                } else {
                                    Text(T("settings.subscribe.button", app.language))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.cpAccent, in: RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                        }
                        .buttonStyle(.plain)
                        .disabled(email.isEmpty || subscribeStatus == .loading)

                        statusLabel
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(T("settings.subscribe.title", app.language))
                }

                // ===== About =====
                Section(T("settings.about", app.language)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(T("settings.about.line1", app.language))
                            .font(.system(size: 14, weight: .semibold))
                        Text(T("settings.about.line2", app.language))
                            .font(.system(size: 12))
                            .foregroundStyle(Color.cpTextSecondary)
                        Link("crisispulse.org",
                             destination: URL(string: "https://crisispulse.org")!)
                            .font(.system(size: 12))
                            .padding(.top, 2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(T("settings.title", app.language))
        }
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch subscribeStatus {
        case .idle, .loading:
            EmptyView()
        case .success:
            Label(T("settings.subscribe.success", app.language), systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: 12))
        case .alreadySubscribed:
            Label(T("settings.subscribe.alreadySubscribed", app.language), systemImage: "info.circle.fill")
                .foregroundStyle(Color.cpAmber)
                .font(.system(size: 12))
        case .error(let msg):
            Label("\(T("settings.subscribe.error", app.language)) (\(msg))", systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
                .font(.system(size: 12))
        }
    }

    private func submitSubscribe() {
        guard isValidEmail(email) else { return }
        subscribeStatus = .loading
        Task {
            do {
                let result = try await app.api.subscribe(email: email, country: nil)
                await MainActor.run {
                    if result.message == "already_subscribed" {
                        subscribeStatus = .alreadySubscribed
                    } else if result.ok {
                        subscribeStatus = .success
                        email = ""
                    } else {
                        subscribeStatus = .error(result.error ?? "unknown")
                    }
                }
            } catch {
                await MainActor.run {
                    subscribeStatus = .error(error.localizedDescription)
                }
            }
        }
    }

    private func isValidEmail(_ s: String) -> Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
