import SwiftUI
import Foundation
import AppKit
import ApplicationServices
import SSHCMCore

enum AppTab: Hashable {
    case connections
    case keys
}

enum TerminalApp: String, CaseIterable, Identifiable {
    case terminal
    case iTerm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .terminal:
            return "Terminal"
        case .iTerm:
            return "iTerm"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case chinese

    var id: String { rawValue }
}

enum UIKey {
    case tabConnections
    case tabKeys
    case language
    case languageSystem
    case languageEnglish
    case languageChinese
    case reload
    case saveConfig
    case addHost
    case deleteHost
    case selectHost
    case hostConfig
    case alias
    case hostName
    case user
    case port
    case identityFile
    case proxyJump
    case proxyCommand
    case group
    case tags
    case forwards
    case addLocal
    case addRemote
    case addDynamic
    case remove
    case saveConnectionChanges
    case revertChanges
    case unsavedChanges
    case keyManagement
    case keyName
    case keyType
    case generate
    case importKeyPath
    case `import`
    case addToAgent
    case useKeychain
    case doctorKeys
    case refreshKeys
    case currentKeys
    case noKeys
    case privateKeyPath
    case publicKeyPath
    case fingerprint
    case none
    case customIdentity
    case draftMustSaveFirst
    case changesSavedInMemory
    case changesReverted
    case loadedHosts
    case loadFailed
    case savedHosts
    case saveFailed
    case addedHost
    case deletedHost
    case generatedKey
    case keyGenerationFailed
    case importedKey
    case importFailed
    case doctorDone
    case doctorFailed
    case keysLoadFailed
    case savePreview
    case savePreviewChanges
    case savePreviewWarnings
    case noChangesDetected
    case confirmSave
    case cancel
    case rollbackLatest
    case autoFixIncludes
    case rolledBackToBackup
    case rollbackFailed
    case autoFixDone
    case autoFixFailed
    case connectInTerminal
    case terminalApp
    case launchedTerminal
    case terminalLaunchFailed
    case appVersion
    case validateWarningsPrefix
    case logs
    case toolsMenu
    case usageGuide
    case guideOpened
    case guideOpenFailed
}

struct L10n {
    static func text(_ key: UIKey, language: AppLanguage) -> String {
        let zh = isChinese(language)
        switch key {
        case .tabConnections: return zh ? "连接管理" : "Connections"
        case .tabKeys: return zh ? "密钥管理" : "Keys"
        case .language: return zh ? "语言" : "Language"
        case .languageSystem: return zh ? "跟随系统" : "System"
        case .languageEnglish: return "English"
        case .languageChinese: return "中文"
        case .reload: return zh ? "重新加载" : "Reload"
        case .saveConfig: return zh ? "保存到 SSH 配置" : "Save To SSH Config"
        case .addHost: return zh ? "新增连接" : "Add Connection"
        case .deleteHost: return zh ? "删除连接" : "Delete Connection"
        case .selectHost: return zh ? "请选择一个连接进行编辑" : "Select a connection to edit"
        case .hostConfig: return zh ? "连接配置" : "Connection Configuration"
        case .alias: return "Alias"
        case .hostName: return "HostName"
        case .user: return "User"
        case .port: return "Port"
        case .identityFile: return "IdentityFile"
        case .proxyJump: return "ProxyJump"
        case .proxyCommand: return "ProxyCommand"
        case .group: return zh ? "分组" : "Group"
        case .tags: return "Tags"
        case .forwards: return zh ? "端口转发" : "Port Forwards"
        case .addLocal: return zh ? "+ 本地" : "+ Local"
        case .addRemote: return zh ? "+ 远程" : "+ Remote"
        case .addDynamic: return zh ? "+ 动态" : "+ Dynamic"
        case .remove: return zh ? "移除" : "Remove"
        case .saveConnectionChanges: return zh ? "保存连接变更" : "Save Connection Changes"
        case .revertChanges: return zh ? "撤销未保存修改" : "Revert Unsaved Changes"
        case .unsavedChanges: return zh ? "有未保存连接修改" : "Unsaved connection changes"
        case .keyManagement: return zh ? "密钥管理" : "Key Management"
        case .keyName: return zh ? "密钥名" : "Key name"
        case .keyType: return zh ? "类型" : "Type"
        case .generate: return zh ? "生成" : "Generate"
        case .importKeyPath: return zh ? "导入私钥路径" : "Import private key path"
        case .import: return zh ? "导入" : "Import"
        case .addToAgent: return zh ? "加入 ssh-agent" : "Add to ssh-agent"
        case .useKeychain: return zh ? "使用 macOS Keychain" : "Use macOS Keychain"
        case .doctorKeys: return zh ? "修复/巡检密钥" : "Doctor Keys"
        case .refreshKeys: return zh ? "刷新密钥列表" : "Refresh Keys"
        case .currentKeys: return zh ? "当前密钥" : "Current Keys"
        case .noKeys: return zh ? "未发现密钥" : "No keys found"
        case .privateKeyPath: return zh ? "私钥" : "Private"
        case .publicKeyPath: return zh ? "公钥" : "Public"
        case .fingerprint: return zh ? "指纹" : "Fingerprint"
        case .none: return zh ? "不设置" : "None"
        case .customIdentity: return zh ? "自定义路径" : "Custom Path"
        case .draftMustSaveFirst: return zh ? "请先点击“保存连接变更”，再保存到 SSH 配置" : "Save connection changes first, then save to SSH config"
        case .changesSavedInMemory: return zh ? "连接变更已保存（待写入 SSH 配置）" : "Connection changes saved (pending SSH config write)"
        case .changesReverted: return zh ? "已撤销未保存连接修改" : "Unsaved connection changes reverted"
        case .loadedHosts: return zh ? "已加载连接数" : "Loaded hosts"
        case .loadFailed: return zh ? "加载失败" : "Load failed"
        case .savedHosts: return zh ? "已保存连接数" : "Saved hosts"
        case .saveFailed: return zh ? "保存失败" : "Save failed"
        case .addedHost: return zh ? "已新增连接" : "Added connection"
        case .deletedHost: return zh ? "已删除连接" : "Deleted connection"
        case .generatedKey: return zh ? "已生成密钥" : "Generated key"
        case .keyGenerationFailed: return zh ? "密钥生成失败" : "Key generation failed"
        case .importedKey: return zh ? "已导入密钥" : "Imported key"
        case .importFailed: return zh ? "导入失败" : "Import failed"
        case .doctorDone: return zh ? "巡检完成" : "Doctor complete"
        case .doctorFailed: return zh ? "巡检失败" : "Doctor failed"
        case .keysLoadFailed: return zh ? "密钥列表刷新失败" : "Failed to refresh key list"
        case .savePreview: return zh ? "保存预览" : "Save Preview"
        case .savePreviewChanges: return zh ? "变更内容" : "Changes"
        case .savePreviewWarnings: return zh ? "风险提示" : "Warnings"
        case .noChangesDetected: return zh ? "未检测到配置变更" : "No config changes detected"
        case .confirmSave: return zh ? "确认保存" : "Confirm Save"
        case .cancel: return zh ? "取消" : "Cancel"
        case .rollbackLatest: return zh ? "回滚到最近备份" : "Rollback Latest Backup"
        case .autoFixIncludes: return zh ? "自动修复 Include 递归" : "Auto Fix Include Loop"
        case .rolledBackToBackup: return zh ? "已回滚到备份" : "Rolled back to backup"
        case .rollbackFailed: return zh ? "回滚失败" : "Rollback failed"
        case .autoFixDone: return zh ? "已自动修复 Include 递归" : "Include recursion auto-fixed"
        case .autoFixFailed: return zh ? "自动修复失败" : "Auto fix failed"
        case .connectInTerminal: return zh ? "终端连接" : "Connect in Terminal"
        case .terminalApp: return zh ? "终端工具" : "Terminal App"
        case .launchedTerminal: return zh ? "已在终端发起连接" : "Launched connection in terminal"
        case .terminalLaunchFailed: return zh ? "终端连接失败" : "Failed to launch terminal connection"
        case .appVersion: return zh ? "版本" : "Version"
        case .validateWarningsPrefix: return zh ? "发现风险" : "Validation warnings"
        case .logs: return zh ? "日志" : "Logs"
        case .toolsMenu: return zh ? "工具" : "Tools"
        case .usageGuide: return zh ? "使用说明" : "User Guide"
        case .guideOpened: return zh ? "已打开使用说明" : "User guide opened"
        case .guideOpenFailed: return zh ? "打开使用说明失败" : "Failed to open user guide"
        }
    }

    static func isChinese(_ language: AppLanguage) -> Bool {
        switch language {
        case .chinese:
            return true
        case .english:
            return false
        case .system:
            return Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") == true
        }
    }
}

struct DraftForward: Identifiable, Hashable {
    var id: UUID
    var type: ForwardType
    var spec: String

    init(id: UUID = UUID(), type: ForwardType, spec: String) {
        self.id = id
        self.type = type
        self.spec = spec
    }
}

struct IdentityOption: Identifiable, Hashable {
    var id: String { value }
    var label: String
    var value: String

    init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

struct SavePlan {
    var changes: [String]
    var warnings: [String]
    var previewText: String
}

struct HostDraft: Equatable {
    var aliasText: String
    var hostName: String
    var user: String
    var portText: String
    var identityFile: String
    var proxyJump: String
    var proxyCommand: String
    var group: String
    var tagsText: String
    var forwards: [DraftForward]

    static let empty = HostDraft(
        aliasText: "",
        hostName: "",
        user: "",
        portText: "",
        identityFile: "",
        proxyJump: "",
        proxyCommand: "",
        group: "ungrouped",
        tagsText: "",
        forwards: []
    )

    init(host: SSHHostEntry) {
        self.aliasText = host.aliases.joined(separator: " ")
        self.hostName = host.hostName
        self.user = host.user ?? ""
        self.portText = host.port.map(String.init) ?? ""
        self.identityFile = host.identityFile ?? ""
        self.proxyJump = host.proxyJump ?? ""
        self.proxyCommand = host.proxyCommand ?? ""
        self.group = host.metadata.group
        self.tagsText = host.metadata.tags.joined(separator: ",")
        self.forwards = host.forwards.map { DraftForward(type: $0.type, spec: $0.spec) }
    }

    private init(
        aliasText: String,
        hostName: String,
        user: String,
        portText: String,
        identityFile: String,
        proxyJump: String,
        proxyCommand: String,
        group: String,
        tagsText: String,
        forwards: [DraftForward]
    ) {
        self.aliasText = aliasText
        self.hostName = hostName
        self.user = user
        self.portText = portText
        self.identityFile = identityFile
        self.proxyJump = proxyJump
        self.proxyCommand = proxyCommand
        self.group = group
        self.tagsText = tagsText
        self.forwards = forwards
    }

    func apply(to source: SSHHostEntry) -> SSHHostEntry {
        var host = source
        let aliases = aliasText.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        host.aliases = aliases.isEmpty ? [source.primaryAlias.isEmpty ? "new-host" : source.primaryAlias] : aliases

        let normalizedHostName = hostName.trimmed
        host.hostName = normalizedHostName.isEmpty ? (host.aliases.first ?? "example.com") : normalizedHostName
        host.user = user.trimmed.nilIfEmpty
        host.port = Int(portText.trimmed)
        host.identityFile = identityFile.trimmed.nilIfEmpty
        host.proxyJump = proxyJump.trimmed.nilIfEmpty
        host.proxyCommand = proxyCommand.trimmed.nilIfEmpty
        host.metadata.group = group.trimmed.nilIfEmpty ?? "ungrouped"

        let tags = tagsText
            .split(separator: ",")
            .map { String($0).trimmed }
            .filter { !$0.isEmpty }
        host.metadata.tags = Array(Set(tags)).sorted()

        host.forwards = forwards
            .map { SSHPortForward(type: $0.type, spec: $0.spec.trimmed) }
            .filter { !$0.spec.isEmpty }

        return host
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

@main
struct SSHConfigManagerGUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("SSH Config Manager") {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 1080, minHeight: 680)
                .onAppear {
                    model.load()
                }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        ForegroundActivator.activate()
    }
}

enum ForegroundActivator {
    static func activate() {
        NSApp.setActivationPolicy(.regular)

        if NSApp.activationPolicy() != .regular {
            transformToForegroundApp()
            NSApp.setActivationPolicy(.regular)
        }

        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            if let key = NSApp.keyWindow {
                key.makeKeyAndOrderFront(nil)
            } else if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    private static func transformToForegroundApp() {
        var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
        _ = TransformProcessType(&psn, ProcessApplicationTransformState(kProcessTransformToForegroundApplication))
    }
}

@MainActor
final class AppModel: ObservableObject {
    @Published var selectedTab: AppTab = .connections
    @Published var language: AppLanguage = .system

    @Published var document = SSHConfigDocument()
    @Published var hosts: [SSHHostEntry] = []
    @Published var selectedID: UUID?
    @Published var baselineDraft: HostDraft?
    @Published var isDraftDirty = false
    @Published var statusMessage = ""

    @Published var keyItems: [SSHLocalKey] = []
    @Published var generateName = "id_ed25519_sshcm"
    @Published var generateType = "ed25519"
    @Published var importPath = ""
    @Published var addToAgent = true
    @Published var useKeychain = true
    @Published var selectedTerminalApp: TerminalApp = .terminal
    @Published var showSavePreview = false
    @Published var pendingSavePlan: SavePlan?

    private let store = SSHConfigStore()
    private let keyManager = SSHKeyManager()
    private let processRunner = ProcessRunner()
    private let fileManager = FileManager.default

    var groupedHosts: [(String, [SSHHostEntry])] {
        let grouped = Dictionary(grouping: hosts) { $0.metadata.group }
        return grouped.keys.sorted().map { key in
            let values = (grouped[key] ?? []).sorted { $0.primaryAlias.lowercased() < $1.primaryAlias.lowercased() }
            return (key, values)
        }
    }

    var selectedIndex: Int? {
        guard let id = selectedID else { return nil }
        return hosts.firstIndex { $0.id == id }
    }

    var selectedHost: SSHHostEntry? {
        guard let index = selectedIndex else { return nil }
        return hosts[index]
    }

    func t(_ key: UIKey) -> String {
        L10n.text(key, language: language)
    }

    func languageLabel(_ value: AppLanguage) -> String {
        switch value {
        case .system:
            return t(.languageSystem)
        case .english:
            return t(.languageEnglish)
        case .chinese:
            return t(.languageChinese)
        }
    }

    func load() {
        do {
            let loaded = try store.loadDocument()
            document = loaded
            hosts = loaded.hosts
            if selectedID == nil {
                selectedID = hosts.first?.id
            } else if !hosts.contains(where: { $0.id == selectedID }) {
                selectedID = hosts.first?.id
            }
            loadDraftForSelection()
            refreshKeys(silent: true)
            statusMessage = "\(t(.loadedHosts)): \(hosts.count)"
        } catch {
            statusMessage = "\(t(.loadFailed)): \(error.localizedDescription)"
        }
    }

    func saveConfig() {
        prepareSave()
    }

    var appVersionDisplay: String {
        let short = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)?.trimmed ?? ""
        let build = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)?.trimmed ?? ""
        if !short.isEmpty, !build.isEmpty {
            return "\(short) (\(build))"
        }
        if !short.isEmpty {
            return short
        }
        return "dev"
    }

    func prepareSave() {
        guard !isDraftDirty else {
            statusMessage = t(.draftMustSaveFirst)
            return
        }

        let plan = buildSavePlan(currentHosts: hosts, baselineHosts: document.hosts, globalDirectives: document.globalDirectives)
        pendingSavePlan = plan
        showSavePreview = true
    }

    func confirmSaveFromPreview() {
        guard !isDraftDirty else {
            statusMessage = t(.draftMustSaveFirst)
            return
        }

        do {
            document.hosts = hosts
            let result = try store.save(document: document)
            let backup = result.backupURL?.lastPathComponent ?? "none"
            let warningCount = pendingSavePlan?.warnings.count ?? 0
            if warningCount > 0 {
                statusMessage = "\(t(.savedHosts)): \(hosts.count), backup: \(backup), \(t(.validateWarningsPrefix)): \(warningCount)"
            } else {
                statusMessage = "\(t(.savedHosts)): \(hosts.count), backup: \(backup)"
            }
            showSavePreview = false
            pendingSavePlan = nil
        } catch {
            statusMessage = "\(t(.saveFailed)): \(error.localizedDescription)"
        }
    }

    func cancelSavePreview() {
        showSavePreview = false
        pendingSavePlan = nil
    }

    func loadDraftForSelection() {
        baselineDraft = selectedHost.map(HostDraft.init)
        isDraftDirty = false
    }

    func markDraftDirty(_ dirty: Bool) {
        isDraftDirty = dirty
    }

    func saveConnectionChanges(from draft: HostDraft) {
        guard let index = selectedIndex else { return }
        var nextHosts = hosts
        nextHosts[index] = draft.apply(to: nextHosts[index])
        hosts = nextHosts
        baselineDraft = HostDraft(host: nextHosts[index])
        isDraftDirty = false
        statusMessage = "\(t(.changesSavedInMemory)) [\(nextHosts[index].metadata.group)]"
    }

    func revertConnectionChanges() {
        isDraftDirty = false
        statusMessage = t(.changesReverted)
    }

    func addHost() {
        let host = SSHHostEntry(
            aliases: ["new-host"],
            hostName: "example.com",
            user: NSUserName(),
            port: 22,
            identityFile: "~/.ssh/id_ed25519",
            proxyJump: nil,
            proxyCommand: nil,
            forwards: [],
            metadata: SSHHostMetadata(group: "ungrouped", tags: [], managed: true),
            extraDirectives: []
        )
        hosts.append(host)
        selectedID = host.id
        loadDraftForSelection()
        statusMessage = "\(t(.addedHost)): \(host.primaryAlias)"
    }

    func deleteSelectedHost() {
        guard let index = selectedIndex else { return }
        let removed = hosts.remove(at: index)
        selectedID = hosts.first?.id
        loadDraftForSelection()
        statusMessage = "\(t(.deletedHost)): \(removed.primaryAlias)"
    }

    func refreshKeys(silent: Bool = false) {
        do {
            keyItems = try keyManager.listLocalKeys()
            if !silent {
                statusMessage = "\(t(.currentKeys)): \(keyItems.count)"
            }
        } catch {
            if !silent {
                statusMessage = "\(t(.keysLoadFailed)): \(error.localizedDescription)"
            }
        }
    }

    func generateKey() {
        do {
            let key = try keyManager.generateKeyPair(name: generateName, type: generateType)
            if addToAgent {
                _ = try keyManager.addKeyToAgent(key, useKeychain: useKeychain)
            }
            refreshKeys(silent: true)
            statusMessage = "\(t(.generatedKey)): \(key.path)"
        } catch {
            statusMessage = "\(t(.keyGenerationFailed)): \(error.localizedDescription)"
        }
    }

    func importKey() {
        do {
            let key = try keyManager.importPrivateKey(from: URL(fileURLWithPath: importPath))
            if addToAgent {
                _ = try keyManager.addKeyToAgent(key, useKeychain: useKeychain)
            }
            refreshKeys(silent: true)
            statusMessage = "\(t(.importedKey)): \(key.path)"
        } catch {
            statusMessage = "\(t(.importFailed)): \(error.localizedDescription)"
        }
    }

    func doctorKeys() {
        do {
            let result = try keyManager.doctorKeys()
            refreshKeys(silent: true)
            statusMessage = "\(t(.doctorDone)): fixed \(result.fixedPermissions.count), agent \(result.sshAgentReachable ? "ok" : "unreachable")"
        } catch {
            statusMessage = "\(t(.doctorFailed)): \(error.localizedDescription)"
        }
    }

    func rollbackLatestBackup() {
        do {
            guard let latest = try latestBackupURL() else {
                statusMessage = "\(t(.rollbackFailed)): no backup found"
                return
            }
            if fileManager.fileExists(atPath: store.configFileURL.path) {
                _ = try fileManager.replaceItemAt(store.configFileURL, withItemAt: latest)
            } else {
                try fileManager.copyItem(at: latest, to: store.configFileURL)
            }
            load()
            statusMessage = "\(t(.rolledBackToBackup)): \(latest.lastPathComponent)"
        } catch {
            statusMessage = "\(t(.rollbackFailed)): \(error.localizedDescription)"
        }
    }

    func autoFixRecursiveIncludes() {
        do {
            let backupDir = store.backupDirectoryURL
            if !fileManager.fileExists(atPath: backupDir.path) {
                try fileManager.createDirectory(at: backupDir, withIntermediateDirectories: true)
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd-HHmmss-SSS"
            let stamp = formatter.string(from: Date())
            var fixedFiles: [String] = []

            let managedMain = [
                "# Managed by SSH Config Manager (sshcm)",
                "# This file is rewritten by the tool.",
                "Include ~/.ssh/config.d/*.conf",
                ""
            ].joined(separator: "\n")

            let mainURL = store.configFileURL
            if fileManager.fileExists(atPath: mainURL.path) {
                let oldMain = try String(contentsOf: mainURL, encoding: .utf8)
                if oldMain != managedMain {
                    let backup = backupDir.appendingPathComponent("config.\(stamp)-autofix.bak")
                    try oldMain.write(to: backup, atomically: true, encoding: .utf8)
                    try managedMain.write(to: mainURL, atomically: true, encoding: .utf8)
                    fixedFiles.append(mainURL.lastPathComponent)
                }
            } else {
                try managedMain.write(to: mainURL, atomically: true, encoding: .utf8)
                fixedFiles.append(mainURL.lastPathComponent)
            }

            if fileManager.fileExists(atPath: store.configDirectoryURL.path) {
                let confFiles = try fileManager.contentsOfDirectory(at: store.configDirectoryURL, includingPropertiesForKeys: nil)
                    .filter { $0.pathExtension == "conf" }
                    .sorted { $0.lastPathComponent < $1.lastPathComponent }

                for conf in confFiles {
                    let old = try String(contentsOf: conf, encoding: .utf8)
                    let new = sanitizeRecursiveIncludeLines(in: old)
                    if new != old {
                        let backup = backupDir.appendingPathComponent("\(conf.lastPathComponent).\(stamp)-autofix.bak")
                        try old.write(to: backup, atomically: true, encoding: .utf8)
                        try new.write(to: conf, atomically: true, encoding: .utf8)
                        fixedFiles.append(conf.lastPathComponent)
                    }
                }
            }

            load()
            if fixedFiles.isEmpty {
                statusMessage = "\(t(.autoFixDone)): no changes needed"
            } else {
                statusMessage = "\(t(.autoFixDone)): \(fixedFiles.joined(separator: ", "))"
            }
        } catch {
            statusMessage = "\(t(.autoFixFailed)): \(error.localizedDescription)"
        }
    }

    func openUsageGuide() {
        do {
            let appSupportBase = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let appSupportDir = appSupportBase.appendingPathComponent("SSHConfigManager", isDirectory: true)
            if !fileManager.fileExists(atPath: appSupportDir.path) {
                try fileManager.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
            }
            let guideURL = appSupportDir.appendingPathComponent("usage-guide.html")
            let content = usageGuideHTML()
            try content.write(to: guideURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.open(guideURL)
            statusMessage = "\(t(.guideOpened)): \(guideURL.path)"
        } catch {
            statusMessage = "\(t(.guideOpenFailed)): \(error.localizedDescription)"
        }
    }

    func connectSelectedInTerminal() {
        guard let host = selectedHost else { return }
        do {
            let alias = host.primaryAlias.trimmed
            guard !alias.isEmpty else {
                statusMessage = "\(t(.terminalLaunchFailed)): empty host alias"
                return
            }

            // Validate host alias against local ssh config first, so we can fail fast in GUI.
            _ = try processRunner.run(executable: "/usr/bin/ssh", arguments: ["-G", alias], allowNonZeroExit: false)

            let command = "/usr/bin/ssh \(shellQuote(alias))"
            try launchTerminal(command: command, terminal: selectedTerminalApp)
            statusMessage = "\(t(.launchedTerminal)): \(alias) (\(selectedTerminalApp.displayName))"
        } catch {
            statusMessage = "\(t(.terminalLaunchFailed)): \(error.localizedDescription)"
        }
    }

    private func latestBackupURL() throws -> URL? {
        guard fileManager.fileExists(atPath: store.backupDirectoryURL.path) else { return nil }
        let files = try fileManager.contentsOfDirectory(
            at: store.backupDirectoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
            .filter { $0.lastPathComponent.hasPrefix("config.") && $0.pathExtension == "bak" }
            .sorted { lhs, rhs in
                let leftDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let rightDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                return leftDate > rightDate
            }
        return files.first
    }

    private func launchTerminal(command: String, terminal: TerminalApp) throws {
        let script: String
        let escaped = command.replacingOccurrences(of: "\"", with: "\\\"")
        switch terminal {
        case .terminal:
            script = """
            tell application "Terminal"
                activate
                do script "\(escaped)"
            end tell
            """
        case .iTerm:
            script = """
            tell application "iTerm"
                activate
                if (count of windows) = 0 then
                    set newWindow to (create window with default profile)
                    delay 0.1
                    tell current session of newWindow
                        write text "\(escaped)"
                    end tell
                else
                    tell current session of current window
                        write text "\(escaped)"
                    end tell
                end if
            end tell
            """
        }
        _ = try processRunner.run(executable: "/usr/bin/osascript", arguments: ["-e", script])
    }

    private func shellQuote(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "'", with: "'\\''")
        return "'\(escaped)'"
    }

    private func sanitizeRecursiveIncludeLines(in content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        let sanitized = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return true }
            guard !trimmed.hasPrefix("#") else { return true }
            guard trimmed.lowercased().hasPrefix("include ") else { return true }
            let value = trimmed.dropFirst("Include".count).trimmingCharacters(in: .whitespaces).lowercased()
            if value.contains("~/.ssh/config") || value.contains("/.ssh/config") {
                return false
            }
            if value.contains("config.d/*.conf") {
                return false
            }
            return true
        }
        return sanitized.joined(separator: "\n")
    }

    private func usageGuideHTML() -> String {
        """
        <!doctype html>
        <html lang="zh-CN">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>SSH Config Manager - User Guide</title>
          <style>
            :root { --bg:#f7f8fb; --card:#fff; --text:#20242c; --muted:#5f6775; --line:#e2e6ef; --accent:#2563eb; }
            * { box-sizing: border-box; }
            body { margin:0; font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif; background:var(--bg); color:var(--text); }
            .wrap { max-width: 1080px; margin: 24px auto; padding: 0 16px 48px; }
            .head { display:flex; gap:12px; align-items:center; justify-content:space-between; flex-wrap:wrap; margin-bottom:16px; }
            .title { margin:0; font-size:28px; }
            .lang { display:flex; gap:8px; }
            .lang button { border:1px solid var(--line); background:#fff; padding:8px 12px; border-radius:8px; cursor:pointer; }
            .lang button.active { border-color: var(--accent); color: var(--accent); font-weight:600; }
            .grid { display:grid; gap:14px; }
            .card { background:var(--card); border:1px solid var(--line); border-radius:12px; padding:14px 16px; }
            h2 { margin:0 0 10px; font-size:18px; }
            h3 { margin:10px 0 8px; font-size:15px; }
            p, li { line-height:1.55; }
            .muted { color:var(--muted); }
            table { width:100%; border-collapse: collapse; margin-top:8px; }
            th, td { border:1px solid var(--line); text-align:left; padding:8px 10px; vertical-align:top; }
            th { background:#f3f5fa; font-weight:600; }
            code { background:#f2f4f8; padding:1px 6px; border-radius:6px; }
            .lang-block { display:none; }
            .lang-block.active { display:block; }
          </style>
        </head>
        <body>
          <div class="wrap">
            <div class="head">
              <h1 class="title">SSH Config Manager</h1>
              <div class="lang">
                <button id="zhBtn" class="active" onclick="switchLang('zh')">中文</button>
                <button id="enBtn" onclick="switchLang('en')">English</button>
              </div>
            </div>

            <div id="zh" class="lang-block active grid">
              <section class="card">
                <h2>概览</h2>
                <p>本工具用于可视化管理本机 <code>~/.ssh/config</code>，并托管到 <code>~/.ssh/config.d/*.conf</code>。保存时会先备份，再原子写入。</p>
                <p class="muted">提示：连接流程是“两阶段”——先“保存连接变更”（写入内存），再“保存到 SSH 配置”（写入磁盘）。</p>
              </section>

              <section class="card">
                <h2>顶部按钮说明（连接管理页）</h2>
                <table>
                  <tr><th>按钮</th><th>作用</th></tr>
                  <tr><td>工具 ▾</td><td>下拉菜单，包含：重新加载、回滚到最近备份、自动修复 Include 递归、使用说明。</td></tr>
                  <tr><td>保存到 SSH 配置</td><td>把当前内存中的连接配置正式写入 <code>~/.ssh/config</code> 和 <code>~/.ssh/config.d/*.conf</code>。</td></tr>
                  <tr><td>新增连接</td><td>创建一个新 Host 草稿。</td></tr>
                  <tr><td>删除连接</td><td>删除当前选中的连接。</td></tr>
                  <tr><td>终端工具</td><td>选择用 Terminal 或 iTerm 发起连接。</td></tr>
                  <tr><td>终端连接</td><td>对当前选中 Host 发起 <code>ssh &lt;alias&gt;</code>。</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>工具菜单说明</h2>
                <table>
                  <tr><th>菜单项</th><th>作用</th></tr>
                  <tr><td>重新加载</td><td>从磁盘重新读取 SSH 配置。</td></tr>
                  <tr><td>回滚到最近备份</td><td>把最近一次备份恢复为当前主配置，然后自动刷新界面。</td></tr>
                  <tr><td>自动修复 Include 递归</td><td>自动修复 <code>Too many recursive configuration includes</code>。会改写主配置入口，并清理分片中的递归 Include，修复前会备份。</td></tr>
                  <tr><td>使用说明</td><td>打开本地 HTML 使用文档。</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>连接配置字段</h2>
                <table>
                  <tr><th>字段</th><th>说明</th></tr>
                  <tr><td>Alias</td><td>连接别名，可填多个（空格分隔）。</td></tr>
                  <tr><td>HostName</td><td>远端主机名或 IP。</td></tr>
                  <tr><td>User</td><td>SSH 登录用户。</td></tr>
                  <tr><td>Port</td><td>SSH 端口。</td></tr>
                  <tr><td>IdentityFile</td><td>私钥路径，下拉来源于密钥管理中的 <code>id_*</code> 密钥。</td></tr>
                  <tr><td>ProxyJump</td><td>跳板链，如 <code>bastion1,bastion2</code>。</td></tr>
                  <tr><td>ProxyCommand</td><td>代理命令，如 <code>ssh proxy -W %h:%p 2&gt;/dev/null</code>。</td></tr>
                  <tr><td>分组(Group)</td><td>用于归类和分片文件命名。</td></tr>
                  <tr><td>Tags</td><td>标签，逗号分隔。</td></tr>
                  <tr><td>端口转发</td><td>支持 Local/Remote/Dynamic 三类。</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>连接编辑按钮</h2>
                <table>
                  <tr><th>按钮</th><th>作用</th></tr>
                  <tr><td>保存连接变更</td><td>把当前编辑内容提交到内存中的连接列表（不落盘）。</td></tr>
                  <tr><td>撤销未保存修改</td><td>恢复到上一次“保存连接变更”后的状态。</td></tr>
                  <tr><td>+ 本地 / + 远程 / + 动态</td><td>新增端口转发行。</td></tr>
                  <tr><td>移除</td><td>删除当前端口转发规则。</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>保存预览弹窗</h2>
                <ul>
                  <li><b>变更内容(Changes)</b>：新增/删除/修改的主机摘要。</li>
                  <li><b>风险提示(Warnings)</b>：重复别名、空字段、ProxyJump 与 ProxyCommand 冲突等。</li>
                  <li><b>Config Preview</b>：保存后的关键配置预览。</li>
                </ul>
              </section>

              <section class="card">
                <h2>密钥管理页</h2>
                <table>
                  <tr><th>项</th><th>说明</th></tr>
                  <tr><td>密钥名 / 类型 / 生成</td><td>生成新密钥（默认 ed25519）。</td></tr>
                  <tr><td>导入私钥路径 / 导入</td><td>导入已有私钥到 <code>~/.ssh</code>。</td></tr>
                  <tr><td>加入 ssh-agent</td><td>连接后自动将密钥加入 agent。</td></tr>
                  <tr><td>使用 macOS Keychain</td><td>通过系统钥匙串保存口令。</td></tr>
                  <tr><td>修复/巡检密钥</td><td>修复权限并检测 agent 状态。</td></tr>
                  <tr><td>刷新密钥列表</td><td>重新扫描本地密钥（仅展示 <code>id_*</code>）。</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>日志面板</h2>
                <p>页面底部“日志”会显示最近一次操作结果。遇到问题时，先看日志里的错误详情，再决定是否执行“自动修复 Include 递归”或“回滚到最近备份”。</p>
              </section>
            </div>

            <div id="en" class="lang-block grid">
              <section class="card">
                <h2>Overview</h2>
                <p>This tool manages local <code>~/.ssh/config</code> visually and writes managed fragments into <code>~/.ssh/config.d/*.conf</code>. Saving uses backup + atomic write.</p>
                <p class="muted">Connection editing is two-stage: “Save Connection Changes” (in-memory) then “Save To SSH Config” (persist to disk).</p>
              </section>

              <section class="card">
                <h2>Top Toolbar (Connections Tab)</h2>
                <table>
                  <tr><th>Button</th><th>Purpose</th></tr>
                  <tr><td>Tools ▾</td><td>Dropdown with Reload, Rollback Latest Backup, Auto Fix Include Loop, User Guide.</td></tr>
                  <tr><td>Save To SSH Config</td><td>Persist current in-memory hosts to <code>~/.ssh/config</code> and <code>~/.ssh/config.d/*.conf</code>.</td></tr>
                  <tr><td>Add Connection</td><td>Create a new host draft.</td></tr>
                  <tr><td>Delete Connection</td><td>Delete selected host.</td></tr>
                  <tr><td>Terminal App</td><td>Choose Terminal or iTerm.</td></tr>
                  <tr><td>Connect in Terminal</td><td>Launch <code>ssh &lt;alias&gt;</code> for selected host.</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>Tools Menu</h2>
                <table>
                  <tr><th>Item</th><th>Purpose</th></tr>
                  <tr><td>Reload</td><td>Reload config from disk.</td></tr>
                  <tr><td>Rollback Latest Backup</td><td>Restore latest backup as main config and refresh UI.</td></tr>
                  <tr><td>Auto Fix Include Loop</td><td>Fix <code>Too many recursive configuration includes</code> by resetting main include entry and removing recursive includes in fragments (with backup).</td></tr>
                  <tr><td>User Guide</td><td>Open this local HTML guide.</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>Connection Fields</h2>
                <table>
                  <tr><th>Field</th><th>Description</th></tr>
                  <tr><td>Alias</td><td>Host aliases (space-separated).</td></tr>
                  <tr><td>HostName</td><td>Remote hostname or IP.</td></tr>
                  <tr><td>User</td><td>SSH username.</td></tr>
                  <tr><td>Port</td><td>SSH port.</td></tr>
                  <tr><td>IdentityFile</td><td>Private key path from key list (<code>id_*</code>).</td></tr>
                  <tr><td>ProxyJump</td><td>Bastion chain, e.g. <code>bastion1,bastion2</code>.</td></tr>
                  <tr><td>ProxyCommand</td><td>Custom proxy command.</td></tr>
                  <tr><td>Group</td><td>Manual grouping used for sharding.</td></tr>
                  <tr><td>Tags</td><td>Comma-separated tags.</td></tr>
                  <tr><td>Port Forwards</td><td>Local / Remote / Dynamic forward rules.</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>Editor Actions</h2>
                <table>
                  <tr><th>Button</th><th>Purpose</th></tr>
                  <tr><td>Save Connection Changes</td><td>Apply current edits into in-memory host list (not persisted yet).</td></tr>
                  <tr><td>Revert Unsaved Changes</td><td>Restore editor to last saved draft state.</td></tr>
                  <tr><td>+ Local / + Remote / + Dynamic</td><td>Add a new forward rule row.</td></tr>
                  <tr><td>Remove</td><td>Remove one forward rule.</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>Save Preview Dialog</h2>
                <ul>
                  <li><b>Changes</b>: host-level add/remove/update summary.</li>
                  <li><b>Warnings</b>: duplicate aliases, empty fields, jump/command conflicts, etc.</li>
                  <li><b>Config Preview</b>: preview snippet before write.</li>
                </ul>
              </section>

              <section class="card">
                <h2>Key Management Tab</h2>
                <table>
                  <tr><th>Item</th><th>Description</th></tr>
                  <tr><td>Key name / Type / Generate</td><td>Create a new key pair (default: ed25519).</td></tr>
                  <tr><td>Import private key path / Import</td><td>Import existing private key into <code>~/.ssh</code>.</td></tr>
                  <tr><td>Add to ssh-agent</td><td>Add key to running ssh-agent.</td></tr>
                  <tr><td>Use macOS Keychain</td><td>Use system keychain integration.</td></tr>
                  <tr><td>Doctor Keys</td><td>Fix permissions and check agent health.</td></tr>
                  <tr><td>Refresh Keys</td><td>Rescan local keys (only <code>id_*</code> shown).</td></tr>
                </table>
              </section>

              <section class="card">
                <h2>Logs Panel</h2>
                <p>The bottom “Logs” panel shows latest action result. Check it first when something fails, then decide whether to run Auto Fix Include Loop or Rollback Latest Backup.</p>
              </section>
            </div>
          </div>

          <script>
            function switchLang(lang) {
              const zh = document.getElementById('zh');
              const en = document.getElementById('en');
              const zhBtn = document.getElementById('zhBtn');
              const enBtn = document.getElementById('enBtn');
              const useZh = lang === 'zh';
              zh.classList.toggle('active', useZh);
              en.classList.toggle('active', !useZh);
              zhBtn.classList.toggle('active', useZh);
              enBtn.classList.toggle('active', !useZh);
              document.documentElement.lang = useZh ? 'zh-CN' : 'en';
            }
          </script>
        </body>
        </html>
        """
    }

    private func buildSavePlan(currentHosts: [SSHHostEntry], baselineHosts: [SSHHostEntry], globalDirectives: [SSHDirective]) -> SavePlan {
        var changes: [String] = []
        let baselineMap = Dictionary(uniqueKeysWithValues: baselineHosts.map { ($0.id, $0) })
        let currentMap = Dictionary(uniqueKeysWithValues: currentHosts.map { ($0.id, $0) })

        for host in currentHosts where baselineMap[host.id] == nil {
            changes.append("+ \(host.primaryAlias) [\(host.metadata.group)]")
        }
        for host in baselineHosts where currentMap[host.id] == nil {
            changes.append("- \(host.primaryAlias) [\(host.metadata.group)]")
        }
        for host in currentHosts {
            guard let old = baselineMap[host.id], old != host else { continue }
            changes.append("~ \(host.primaryAlias): \(diffSummary(old: old, new: host))")
        }
        if changes.isEmpty {
            changes = [t(.noChangesDetected)]
        }

        let warnings = validate(hosts: currentHosts, globalDirectives: globalDirectives)
        let preview = currentHosts
            .sorted { $0.primaryAlias.lowercased() < $1.primaryAlias.lowercased() }
            .map { host in
                """
                Host \(host.aliases.joined(separator: " "))
                  HostName \(host.hostName)
                  User \(host.user ?? "-")
                  Group \(host.metadata.group)
                  ProxyJump \(host.proxyJump ?? "-")
                  ProxyCommand \(host.proxyCommand ?? "-")
                """
            }
            .joined(separator: "\n\n")
        return SavePlan(changes: changes, warnings: warnings, previewText: preview)
    }

    private func diffSummary(old: SSHHostEntry, new: SSHHostEntry) -> String {
        var fields: [String] = []
        if old.hostName != new.hostName { fields.append("HostName") }
        if old.user != new.user { fields.append("User") }
        if old.port != new.port { fields.append("Port") }
        if old.identityFile != new.identityFile { fields.append("IdentityFile") }
        if old.proxyJump != new.proxyJump { fields.append("ProxyJump") }
        if old.proxyCommand != new.proxyCommand { fields.append("ProxyCommand") }
        if old.metadata.group != new.metadata.group { fields.append("Group") }
        if old.metadata.tags != new.metadata.tags { fields.append("Tags") }
        if old.forwards != new.forwards { fields.append("Forwards") }
        if old.aliases != new.aliases { fields.append("Aliases") }
        return fields.isEmpty ? "details updated" : fields.joined(separator: ", ")
    }

    private func validate(hosts: [SSHHostEntry], globalDirectives: [SSHDirective]) -> [String] {
        var warnings: [String] = []
        var aliasSet: Set<String> = []
        for host in hosts {
            if host.primaryAlias.trimmed.isEmpty {
                warnings.append("Host has empty alias")
            }
            if host.hostName.trimmed.isEmpty {
                warnings.append("Host \(host.primaryAlias) has empty HostName")
            }
            for alias in host.aliases {
                let lower = alias.lowercased()
                if aliasSet.contains(lower) {
                    warnings.append("Duplicate alias: \(alias)")
                } else {
                    aliasSet.insert(lower)
                }
            }
            if let jump = host.proxyJump, let command = host.proxyCommand, !jump.trimmed.isEmpty, !command.trimmed.isEmpty {
                warnings.append("Host \(host.primaryAlias) has both ProxyJump and ProxyCommand")
            }
        }

        let includeValues = globalDirectives
            .filter { $0.key.caseInsensitiveCompare("Include") == .orderedSame }
            .map { $0.value.lowercased() }
        if includeValues.contains(where: { $0.contains(".ssh/config") && !$0.contains("config.d/*.conf") }) {
            warnings.append("Global Include points to ~/.ssh/config and may cause recursive includes")
        }

        return Array(Set(warnings)).sorted()
    }
}

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            ConnectionsTabView()
                .tabItem { Text(model.t(.tabConnections)) }
                .tag(AppTab.connections)

            KeyToolsTabView()
                .tabItem { Text(model.t(.tabKeys)) }
                .tag(AppTab.keys)
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                languagePicker
            }

            if model.selectedTab == .connections {
                ToolbarItemGroup {
                    Menu(model.t(.toolsMenu)) {
                        Button(model.t(.reload)) { model.load() }
                        Button(model.t(.rollbackLatest)) { model.rollbackLatestBackup() }
                        Button(model.t(.autoFixIncludes)) { model.autoFixRecursiveIncludes() }
                        Divider()
                        Button(model.t(.usageGuide)) { model.openUsageGuide() }
                    }
                    Button(model.t(.saveConfig)) { model.prepareSave() }
                    Button(model.t(.addHost)) { model.addHost() }
                    Button(model.t(.deleteHost)) { model.deleteSelectedHost() }
                        .disabled(model.selectedHost == nil)
                }

                ToolbarItemGroup {
                    Picker(model.t(.terminalApp), selection: $model.selectedTerminalApp) {
                        ForEach(TerminalApp.allCases) { app in
                            Text(app.displayName).tag(app)
                        }
                    }
                    .pickerStyle(.menu)

                    Button(model.t(.connectInTerminal)) { model.connectSelectedInTerminal() }
                        .disabled(model.selectedHost == nil)
                }
            }

            ToolbarItem(placement: .status) {
                Text("\(model.t(.appVersion)) \(model.appVersionDisplay)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $model.showSavePreview) {
            SavePreviewSheet()
                .environmentObject(model)
                .frame(minWidth: 720, minHeight: 520)
        }
    }

    private var languagePicker: some View {
        Picker(model.t(.language), selection: $model.language) {
            ForEach(AppLanguage.allCases) { language in
                Text(model.languageLabel(language)).tag(language)
            }
        }
        .pickerStyle(.menu)
    }
}

struct SavePreviewSheet: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.t(.savePreview))
                .font(.headline)

            if let plan = model.pendingSavePlan {
                GroupBox(model.t(.savePreviewChanges)) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(plan.changes, id: \.self) { line in
                                Text(line)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 120)
                }

                GroupBox(model.t(.savePreviewWarnings)) {
                    if plan.warnings.isEmpty {
                        Text("None")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(plan.warnings, id: \.self) { warning in
                                    Text("• \(warning)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(minHeight: 90)
                    }
                }

                GroupBox("Config Preview") {
                    ScrollView {
                        Text(plan.previewText.isEmpty ? model.t(.noChangesDetected) : plan.previewText)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            HStack {
                Spacer()
                Button(model.t(.cancel)) {
                    model.cancelSavePreview()
                }
                Button(model.t(.confirmSave)) {
                    model.confirmSaveFromPreview()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
    }
}

struct ConnectionsTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            List(selection: $model.selectedID) {
                ForEach(model.groupedHosts, id: \.0) { group, hosts in
                    Section(group) {
                        ForEach(hosts) { host in
                            Text(host.primaryAlias)
                                .tag(host.id)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .onChange(of: model.selectedID) { _, _ in
                model.loadDraftForSelection()
            }
        } detail: {
            VStack(alignment: .leading, spacing: 12) {
                if model.baselineDraft != nil {
                    HostEditorView()
                } else {
                    Text(model.t(.selectHost))
                        .foregroundStyle(.secondary)
                }
                Divider()
                GroupBox(model.t(.logs)) {
                    HStack(alignment: .top) {
                        Text(model.statusMessage.isEmpty ? "-" : model.statusMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                        Text("\(model.t(.appVersion)) \(model.appVersionDisplay)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(16)
        }
    }
}

struct HostEditorView: View {
    @EnvironmentObject private var model: AppModel
    @State private var workingDraft = HostDraft.empty
    @State private var localDirty = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(model.t(.hostConfig))
                    .font(.headline)
                Spacer()
                if model.isDraftDirty {
                    Text(model.t(.unsavedChanges))
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
                Button(model.t(.revertChanges)) {
                    reloadFromModel()
                    model.revertConnectionChanges()
                }
                .disabled(!localDirty)

                Button(model.t(.saveConnectionChanges)) {
                    model.saveConnectionChanges(from: workingDraft)
                    reloadFromModel()
                }
                .disabled(!localDirty)
            }

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                row(model.t(.alias)) {
                    TextField(model.t(.alias), text: bind(\.aliasText))
                }
                row(model.t(.hostName)) {
                    TextField(model.t(.hostName), text: bind(\.hostName))
                }
                row(model.t(.user)) {
                    TextField(model.t(.user), text: bind(\.user))
                }
                row(model.t(.port)) {
                    TextField("22", text: bind(\.portText))
                        .frame(width: 140)
                }
                row(model.t(.identityFile)) {
                    Picker("", selection: identityBinding()) {
                        ForEach(identityOptions()) { option in
                            Text(option.label).tag(option.value)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                row(model.t(.proxyJump)) {
                    TextField("bastion1,bastion2", text: bind(\.proxyJump))
                }
                row(model.t(.proxyCommand)) {
                    TextField("ssh proxy -W %h:%p 2>/dev/null", text: bind(\.proxyCommand))
                }
                row(model.t(.group)) {
                    TextField("prod", text: bind(\.group))
                }
                row(model.t(.tags)) {
                    TextField("db,cn", text: bind(\.tagsText))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(model.t(.forwards))
                        .font(.subheadline)
                    Spacer()
                    Button(model.t(.addLocal)) {
                        mutateDraft { draft in
                            draft.forwards.append(DraftForward(type: .local, spec: "127.0.0.1:5432 127.0.0.1:5432"))
                        }
                    }
                    Button(model.t(.addRemote)) {
                        mutateDraft { draft in
                            draft.forwards.append(DraftForward(type: .remote, spec: "127.0.0.1:5432 127.0.0.1:5432"))
                        }
                    }
                    Button(model.t(.addDynamic)) {
                        mutateDraft { draft in
                            draft.forwards.append(DraftForward(type: .dynamic, spec: "1080"))
                        }
                    }
                }

                ForEach(workingDraft.forwards) { forward in
                    HStack {
                        Picker("Type", selection: Binding(
                            get: { forwardType(forward.id) },
                            set: { updateForwardType(forward.id, type: $0) }
                        )) {
                            ForEach(ForwardType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 120)
                        TextField("spec", text: Binding(
                            get: { forwardSpec(forward.id) },
                            set: { updateForwardSpec(forward.id, spec: $0) }
                        ))

                        Button(model.t(.remove)) {
                            mutateDraft { draft in
                                draft.forwards.removeAll { $0.id == forward.id }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            reloadFromModel()
        }
        .onChange(of: model.baselineDraft) { _, _ in
            reloadFromModel()
        }
    }

    private func bind(_ path: WritableKeyPath<HostDraft, String>) -> Binding<String> {
        Binding(
            get: { workingDraft[keyPath: path] },
            set: { value in
                mutateDraft { draft in
                    draft[keyPath: path] = value
                }
            }
        )
    }

    private func mutateDraft(_ mutate: (inout HostDraft) -> Void) {
        mutate(&workingDraft)
        recomputeDirty()
    }

    private func forwardType(_ id: UUID) -> ForwardType {
        workingDraft.forwards.first(where: { $0.id == id })?.type ?? .local
    }

    private func forwardSpec(_ id: UUID) -> String {
        workingDraft.forwards.first(where: { $0.id == id })?.spec ?? ""
    }

    private func updateForwardType(_ id: UUID, type: ForwardType) {
        mutateDraft { draft in
            guard let index = draft.forwards.firstIndex(where: { $0.id == id }) else { return }
            draft.forwards[index].type = type
        }
    }

    private func updateForwardSpec(_ id: UUID, spec: String) {
        mutateDraft { draft in
            guard let index = draft.forwards.firstIndex(where: { $0.id == id }) else { return }
            draft.forwards[index].spec = spec
        }
    }

    private func recomputeDirty() {
        let dirty = workingDraft != (model.baselineDraft ?? .empty)
        localDirty = dirty
        if dirty != model.isDraftDirty {
            model.markDraftDirty(dirty)
        }
    }

    private func identityBinding() -> Binding<String> {
        Binding(
            get: { workingDraft.identityFile },
            set: { value in
                mutateDraft { draft in
                    draft.identityFile = value
                }
            }
        )
    }

    private func identityOptions() -> [IdentityOption] {
        var options: [IdentityOption] = [IdentityOption(label: model.t(.none), value: "")]
        let keyOptions = model.keyItems
            .compactMap { key -> IdentityOption? in
                guard let privatePath = key.privateKeyPath else { return nil }
                let displayPath = toTildePath(privatePath)
                let label = "\(key.name) (\(displayPath))"
                return IdentityOption(label: label, value: displayPath)
            }
            .sorted { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
        options.append(contentsOf: keyOptions)

        let current = workingDraft.identityFile.trimmed
        if !current.isEmpty, !options.contains(where: { $0.value == current }) {
            options.append(IdentityOption(label: "\(model.t(.customIdentity)): \(current)", value: current))
        }

        return options
    }

    private func toTildePath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path == home { return "~" }
        if path.hasPrefix(home + "/") {
            return "~/" + String(path.dropFirst(home.count + 1))
        }
        return path
    }

    private func reloadFromModel() {
        if let baseline = model.baselineDraft {
            workingDraft = baseline
            localDirty = false
            if model.isDraftDirty {
                model.markDraftDirty(false)
            }
        } else {
            workingDraft = .empty
            localDirty = false
            if model.isDraftDirty {
                model.markDraftDirty(false)
            }
        }
    }

    @ViewBuilder
    private func row(_ label: String, @ViewBuilder field: () -> some View) -> some View {
        GridRow {
            Text(label)
                .frame(width: 120, alignment: .leading)
            field()
        }
    }
}

struct KeyToolsTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.t(.keyManagement))
                .font(.headline)

            HStack {
                TextField(model.t(.keyName), text: $model.generateName)
                TextField(model.t(.keyType), text: $model.generateType)
                    .frame(width: 140)
                Button(model.t(.generate)) { model.generateKey() }
            }

            HStack {
                TextField(model.t(.importKeyPath), text: $model.importPath)
                Button(model.t(.import)) { model.importKey() }
            }

            Toggle(model.t(.addToAgent), isOn: $model.addToAgent)
            Toggle(model.t(.useKeychain), isOn: $model.useKeychain)

            HStack {
                Button(model.t(.doctorKeys)) { model.doctorKeys() }
                Button(model.t(.refreshKeys)) { model.refreshKeys() }
                Spacer()
            }

            Divider()
            Text(model.t(.currentKeys))
                .font(.subheadline)

            if model.keyItems.isEmpty {
                Text(model.t(.noKeys))
                    .foregroundStyle(.secondary)
            } else {
                List(model.keyItems) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key.name)
                            .font(.headline)
                        if let privatePath = key.privateKeyPath {
                            Text("\(model.t(.privateKeyPath)): \(privatePath)")
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                        if let publicPath = key.publicKeyPath {
                            Text("\(model.t(.publicKeyPath)): \(publicPath)")
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                        if let fingerprint = key.fingerprint {
                            Text("\(model.t(.fingerprint)): \(fingerprint)")
                                .font(.caption)
                                .textSelection(.enabled)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .listStyle(.inset)
            }

            Divider()
            GroupBox(model.t(.logs)) {
                Text(model.statusMessage.isEmpty ? "-" : model.statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            Spacer()
        }
        .padding(16)
        .onAppear {
            model.refreshKeys(silent: true)
        }
    }
}
