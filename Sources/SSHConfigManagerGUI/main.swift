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
    case rolledBackToBackup
    case rollbackFailed
    case connectInTerminal
    case terminalApp
    case launchedTerminal
    case terminalLaunchFailed
    case appVersion
    case validateWarningsPrefix
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
        case .rolledBackToBackup: return zh ? "已回滚到备份" : "Rolled back to backup"
        case .rollbackFailed: return zh ? "回滚失败" : "Rollback failed"
        case .connectInTerminal: return zh ? "终端连接" : "Connect in Terminal"
        case .terminalApp: return zh ? "终端工具" : "Terminal App"
        case .launchedTerminal: return zh ? "已在终端发起连接" : "Launched connection in terminal"
        case .terminalLaunchFailed: return zh ? "终端连接失败" : "Failed to launch terminal connection"
        case .appVersion: return zh ? "版本" : "Version"
        case .validateWarningsPrefix: return zh ? "发现风险" : "Validation warnings"
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

            let command = """
            echo "=== SSH Config Manager ==="
            echo "Connecting: \(alias)"
            echo "Terminal: \(selectedTerminalApp.displayName)"
            echo
            /usr/bin/ssh \(shellQuote(alias))
            code=$?
            echo
            echo "ssh exited with status $code"
            """
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
                    create window with default profile
                end if
                tell current session of current window
                    write text "\(escaped)"
                end tell
            end tell
            """
        }
        _ = try processRunner.run(executable: "/usr/bin/osascript", arguments: ["-e", script])
    }

    private func shellQuote(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "'", with: "'\\''")
        return "'\(escaped)'"
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
                    Button(model.t(.reload)) { model.load() }
                    Button(model.t(.saveConfig)) { model.prepareSave() }
                    Button(model.t(.rollbackLatest)) { model.rollbackLatestBackup() }
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
                HStack {
                    Text(model.statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(model.t(.appVersion)) \(model.appVersionDisplay)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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

            HStack(spacing: 8) {
                Picker(model.t(.terminalApp), selection: $model.selectedTerminalApp) {
                    ForEach(TerminalApp.allCases) { app in
                        Text(app.displayName).tag(app)
                    }
                }
                .frame(width: 150)

                Button(model.t(.connectInTerminal)) {
                    model.connectSelectedInTerminal()
                }
                .disabled(model.selectedHost == nil)

                Button(model.t(.rollbackLatest)) {
                    model.rollbackLatestBackup()
                }

                Button(model.t(.saveConfig)) {
                    model.prepareSave()
                }

                Spacer()
                Text("\(model.t(.appVersion)) \(model.appVersionDisplay)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
            Text(model.statusMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(16)
        .onAppear {
            model.refreshKeys(silent: true)
        }
    }
}
