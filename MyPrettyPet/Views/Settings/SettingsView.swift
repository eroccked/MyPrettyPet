//
//  SettingsView.swift
//  MyPrettyPet
//
//  Created by Taras Buhra on 08.01.2026.
//

import SwiftUI
import SwiftData
import CloudKit
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(AppSettings.ownerName) private var ownerName = ""
    @AppStorage(AppSettings.remindersEnabled) private var remindersEnabled = true
    @AppStorage(AppSettings.reminderDaysBefore) private var reminderDaysBefore = AppSettings.defaultReminderDaysBefore
    @AppStorage(AppSettings.reminderHour) private var reminderHour = AppSettings.defaultReminderHour

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var iCloudStatus: CKAccountStatus?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(title: "Налаштування")

                Form {
                    Section {
                        TextField("Ваше ім'я", text: $ownerName)
                            .textInputAutocapitalization(.words)
                    } header: {
                        Text("Профіль")
                    } footer: {
                        Text("Показується в записах годування.")
                    }

                    remindersSection

                    Section {
                        LabeledContent {
                            Text(iCloudStatusText)
                        } label: {
                            Label("iCloud", systemImage: iCloudStatus == .available ? "checkmark.icloud" : "exclamationmark.icloud")
                        }
                    } header: {
                        Text("Синхронізація")
                    } footer: {
                        Text(iCloudStatus == .available
                             ? "Дані зберігаються на пристрої та автоматично синхронізуються між вашими пристроями з тим самим Apple ID."
                             : "Дані зберігаються лише на цьому пристрої. Увійдіть в iCloud у Параметрах, щоб синхронізувати їх.")
                    }

                    Section("Про застосунок") {
                        LabeledContent("Версія", value: appVersion)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .background(Theme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .task { await refreshStatuses() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task { await refreshStatuses() }
                }
            }
            .onChange(of: remindersEnabled) { _, enabled in
                Task {
                    if enabled {
                        await NotificationManager.shared.requestAuthorization()
                        await refreshStatuses()
                    }
                    await NotificationManager.shared.rescheduleAll(in: context)
                }
            }
            .onChange(of: reminderDaysBefore) { rescheduleReminders() }
            .onChange(of: reminderHour) { rescheduleReminders() }
        }
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        Section {
            Toggle("Медичні нагадування", isOn: $remindersEnabled)

            if remindersEnabled {
                if notificationStatus == .denied {
                    Button("Дозволити сповіщення в Параметрах") {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            openURL(url)
                        }
                    }
                }

                Stepper(value: $reminderDaysBefore, in: 0...30) {
                    LabeledContent("Нагадати заздалегідь",
                                   value: reminderDaysBefore == 0 ? "лише в день" : "за \(reminderDaysBefore) дн.")
                }

                Picker("Час нагадування", selection: $reminderHour) {
                    ForEach(6..<23, id: \.self) { hour in
                        Text(String(format: "%02d:00", hour)).tag(hour)
                    }
                }
            }
        } header: {
            Text("Нагадування")
        } footer: {
            if remindersEnabled && notificationStatus == .denied {
                Text("Сповіщення вимкнені в системних параметрах, тому нагадування не прийдуть.")
            }
        }
    }

    private func rescheduleReminders() {
        Task { await NotificationManager.shared.rescheduleAll(in: context) }
    }

    // MARK: - Status

    private func refreshStatuses() async {
        notificationStatus = await NotificationManager.shared.authorizationStatus()
        iCloudStatus = try? await CKContainer(identifier: Persistence.cloudKitContainerID).accountStatus()
    }

    private var iCloudStatusText: String {
        switch iCloudStatus {
        case .available: "Підключено"
        case .noAccount: "Не виконано вхід"
        case .restricted: "Обмежено"
        case .temporarilyUnavailable: "Тимчасово недоступно"
        case .couldNotDetermine, .none: "Невідомо"
        @unknown default: "Невідомо"
        }
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .modelContainer(Persistence.preview)
}
