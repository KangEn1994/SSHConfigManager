# SSH Config Manager

一个面向 macOS 14+ 的本地 SSH 配置可视化管理工具，专注于安全管理 `~/.ssh/config`。

英文文档请查看 [README.md](README.md)。

## 功能特性

- 本地 SSH 主机可视化管理
- 手动分组与标签（通过 `sshcm` 元数据注释保存）
- 跳板链路支持：`ProxyJump`（单跳/多跳）
- 显式识别和编辑 `ProxyCommand`
- 端口转发编辑：`LocalForward` / `RemoteForward` / `DynamicForward`
- 使用 `~/.ssh/config.d/*.conf` 进行分片托管
- 原子写入 + 自动备份（`~/.ssh/backup`）
- 连接导向 CLI（`sshcm`）
- 密钥工具：生成/导入、权限修复、可选加入 agent/Keychain

## 环境要求

- macOS 14+
- Xcode 15+（或 Swift 5.10 工具链）

## 项目结构

- `Sources/SSHCMCore`：核心共享库（解析、格式化、存储、密钥管理）
- `Sources/sshcm`：CLI 入口
- `Sources/SSHConfigManagerGUI`：SwiftUI 图形界面
- `Tests/SSHCMCoreTests`：核心测试

## 构建

```bash
swift build
```

## 运行

运行 CLI：

```bash
swift run sshcm --help
```

运行 GUI：

```bash
swift run SSHConfigManagerGUI
```

运行测试：

```bash
swift test
```

## CI/CD：点击触发 DMG 打包

仓库已内置一个支持自动和手动触发的 GitHub Actions 工作流：

- 工作流文件：`.github/workflows/package-dmg.yml`
- 触发方式：
  - `push` 到 `main` 自动构建
  - `workflow_dispatch` 手动触发

### 配置 Secrets

在 `GitHub 仓库 -> Settings -> Secrets and variables -> Actions` 中配置：

- Developer ID 签名必需：
  - `SIGNING_IDENTITY`（示例：`Developer ID Application: Your Name (TEAMID)`）
  - `SIGNING_CERT_BASE64`（`.p12` 证书的 base64 内容）
  - `SIGNING_CERT_PASSWORD`（`.p12` 证书密码）
- 仅在开启公证（notarize）时必需：
  - `APPLE_ID`
  - `APPLE_TEAM_ID`
  - `APPLE_APP_SPECIFIC_PASSWORD`
- 可选：
  - `KEYCHAIN_PASSWORD`（CI 临时 keychain 密码；未配置时使用脚本默认值）

### 触发步骤

1. 推送到 `main` 会自动构建，或在 GitHub `Actions` 手动运行。
2. 任务完成后，在该次运行页面下载产物（`dist/*.dmg` 和 `dist/*.app`）。

### 说明

- 未配置签名 secrets 时，工作流仍可运行，会使用 ad-hoc 签名（适合内部测试）。
- 若 `notarize=true` 但缺少 Apple secrets，工作流会快速失败并给出明确报错。
- 打包脚本位于 `scripts/package_macos_dmg.sh`（也支持在本地 macOS 手动执行）。
- DMG 已改为拖拽安装布局（`SSHConfigManagerGUI.app` + `Applications` 软链接）。

## 首次接管与迁移行为

当你在 GUI 点击保存（或后续 CLI 增加保存流程）时，工具会以托管模式接管本地 SSH 配置：

1. 先把已有 `~/.ssh/config` 备份到 `~/.ssh/backup`。
2. 将 `~/.ssh/config` 重写为稳定入口文件：

```text
# Managed by SSH Config Manager (sshcm)
# This file is rewritten by the tool.
Include ~/.ssh/config.d/*.conf
```

3. 按分组把主机配置写入 `~/.ssh/config.d/*.conf`。

说明：工具会做规范化重写，不保证保留原始空格和排版。

## 元数据格式

每个托管 Host 块前会写入注释元数据：

```text
# sshcm:begin
# sshcm: {"group":"prod","tags":["db","cn"],"managed":true}
# sshcm:end
Host prod-db
    HostName 10.0.0.10
    User ubuntu
    ProxyJump bastion1,bastion2
```

## GUI 使用说明

### 连接管理页签

1. 点击 `Add Host` 新建主机。
2. 填写以下字段：
   - `Alias`（支持空格分隔多个别名）
   - `HostName`
   - `User`、`Port`、`IdentityFile`（`IdentityFile` 为下拉选择，来源于当前密钥列表）
   - `ProxyJump`（单主机或逗号分隔跳板链）
   - `ProxyCommand`（例如：`ssh proxy -W %h:%p 2>/dev/null`）
   - `Group` 与 `Tags`（标签用逗号分隔）
3. 用 `+ Local`、`+ Remote`、`+ Dynamic` 增加端口转发。
4. 点击 `保存连接变更`，将草稿修改应用到当前连接。
5. 再点击工具栏 `保存到 SSH 配置`，把已提交的连接修改写入磁盘。

### 密钥管理页签

在 `Key Management` 区域：

- 生成密钥：输入 key 名称与类型（默认 `ed25519`），点击 `Generate`
- 导入密钥：输入私钥文件路径，点击 `Import`
- 可选开关：
  - `Add to ssh-agent`
  - `Use macOS Keychain`
- 点击 `Doctor Keys` 修复权限并检查 agent 状态
- `当前密钥` 列表会展示 `~/.ssh` 下检测到的密钥（私钥/公钥路径，以及可用时的指纹）
- UI 只展示并使用文件名以 `id_` 开头的密钥

## CLI 使用说明

### 命令列表

```text
sshcm list [--group <name>] [--tag <tag>]
sshcm connect <host-or-tag>
sshcm jump <target> --via <bastion-chain>
sshcm forward <target> [--L spec] [--R spec] [--D spec]
sshcm doctor-keys
sshcm keygen <name> [--type ed25519] [--add-agent] [--use-keychain]
sshcm import-key <path> [--name key_name] [--add-agent] [--use-keychain]
```

### 示例

列出全部主机：

```bash
swift run sshcm list
```

按分组筛选：

```bash
swift run sshcm list --group prod
```

按标签筛选：

```bash
swift run sshcm list --tag db
```

按别名连接：

```bash
swift run sshcm connect prod-db
```

按标签连接（匹配多个时会给出提示并连接第一个匹配项）：

```bash
swift run sshcm connect db
```

临时跳板连接：

```bash
swift run sshcm jump internal-host --via bastion1,bastion2
```

临时本地转发：

```bash
swift run sshcm forward prod-db --L 127.0.0.1:5432:127.0.0.1:5432
```

生成密钥并加入 agent + Keychain：

```bash
swift run sshcm keygen id_ed25519_prod --add-agent --use-keychain
```

导入密钥并加入 agent：

```bash
swift run sshcm import-key /path/to/id_ed25519 --add-agent
```

执行密钥巡检：

```bash
swift run sshcm doctor-keys
```

## 安全说明

- 保存流程使用原子替换，降低配置损坏风险。
- 重写主配置前会先创建备份文件。
- 私钥权限会规范为 `0600`，公钥为 `0644`，`~/.ssh` 目录为 `0700`。
- 默认不执行远程连通性验证（不会主动连接远端主机）。

## 常见问题

### 看不到主机

- 确认 `~/.ssh/config` 存在且可读。
- 如果主配置只包含 `Include`，确认被引用文件存在。

### 权限报错

- 确认当前用户有 `~/.ssh` 的读写权限。
- 可执行：

```bash
swift run sshcm doctor-keys
```

### `connect` 用标签连到了非预期主机

- 标签可能匹配多个主机；要精确连接建议使用别名。

## 许可证

MIT（当前代码按 MIT 风格使用；建议后续补充正式 `LICENSE` 文件）。
