# SSH Config Manager

A macOS 14+ local SSH configuration manager focused on safe, visual management of `~/.ssh/config`.

For Chinese documentation, see [README.zh-CN.md](README.zh-CN.md).

## Features

- Visual host management for local SSH config
- Manual groups and tags (`sshcm` metadata comments)
- Bastion chain support with `ProxyJump` (single-hop or multi-hop)
- Explicit `ProxyCommand` detection and editing
- Port-forward editor (`LocalForward`, `RemoteForward`, `DynamicForward`)
- Managed split output via `~/.ssh/config.d/*.conf`
- Atomic write and automatic backup to `~/.ssh/backup`
- Connection-first CLI (`sshcm`)
- Key tools: generate/import keys, permission doctor, optional agent/keychain add

## Requirements

- macOS 14+
- Xcode 15+ (or Swift 5.10 toolchain)

## Project Structure

- `Sources/SSHCMCore`: shared core library (parser, formatter, store, key manager)
- `Sources/sshcm`: CLI entrypoint
- `Sources/SSHConfigManagerGUI`: SwiftUI GUI app
- `Tests/SSHCMCoreTests`: core tests

## Build

```bash
swift build
```

## Run

Run CLI:

```bash
swift run sshcm --help
```

Run GUI:

```bash
swift run SSHConfigManagerGUI
```

Run tests:

```bash
swift test
```

## CI/CD: Click-to-Package DMG

This repository includes a manual GitHub Actions workflow:

- Workflow file: `.github/workflows/package-dmg.yml`
- Trigger mode: `workflow_dispatch` (click `Run workflow` in GitHub UI)

### Configure Secrets

In `GitHub Repo -> Settings -> Secrets and variables -> Actions`, configure:

- Required for Developer ID signing:
  - `SIGNING_IDENTITY` (example: `Developer ID Application: Your Name (TEAMID)`)
  - `SIGNING_CERT_BASE64` (base64 content of your `.p12` certificate)
  - `SIGNING_CERT_PASSWORD` (password for the `.p12`)
- Required only when notarization is enabled:
  - `APPLE_ID`
  - `APPLE_TEAM_ID`
  - `APPLE_APP_SPECIFIC_PASSWORD`
- Optional:
  - `KEYCHAIN_PASSWORD` (temporary keychain password used in CI; falls back to an internal default if omitted)

### How To Trigger

1. Open GitHub `Actions` tab and select `Package macOS DMG`.
2. Click `Run workflow`.
3. Fill inputs:
   - `version`: app version (used in `Info.plist` and artifact name)
   - `product_name`: display name / DMG volume name
   - `bundle_id`: app bundle identifier
   - `notarize`: set `true` only when Apple notarization secrets are configured
4. After the job completes, download artifacts from the run page (`dist/*.dmg` and `dist/*.app`).

### Notes

- If signing secrets are not configured, workflow still runs with ad-hoc signing (good for internal testing).
- If `notarize=true` but Apple secrets are missing, workflow will fail fast with a clear error.
- Packaging script: `scripts/package_macos_dmg.sh` (can also be run locally on macOS).

## First-time Migration Behavior

When you save from GUI (or future save workflow from CLI), the app takes over your local SSH config in managed mode:

1. Existing `~/.ssh/config` is backed up to `~/.ssh/backup`.
2. `~/.ssh/config` is rewritten to a stable entry file:

```text
# Managed by SSH Config Manager (sshcm)
# This file is rewritten by the tool.
Include ~/.ssh/config.d/*.conf
```

3. Managed host configs are written into `~/.ssh/config.d/*.conf` by group.

Note: formatting is normalized intentionally; original whitespace/layout is not preserved.

## Metadata Format

Each managed host block includes metadata comments:

```text
# sshcm:begin
# sshcm: {"group":"prod","tags":["db","cn"],"managed":true}
# sshcm:end
Host prod-db
    HostName 10.0.0.10
    User ubuntu
    ProxyJump bastion1,bastion2
```

## GUI Usage

### Connections Tab

1. Click `Add Host` to create a host entry.
2. Fill in:
   - `Alias` (supports multiple aliases separated by spaces)
   - `HostName`
  - `User`, `Port`, `IdentityFile` (`IdentityFile` is a dropdown sourced from current keys)
   - `ProxyJump` (single host or comma-separated chain)
   - `ProxyCommand` (for example: `ssh proxy -W %h:%p 2>/dev/null`)
   - `Group` and `Tags` (tags separated by commas)
3. Add forwards with `+ Local`, `+ Remote`, `+ Dynamic`.
4. Click `Save Connection Changes` to apply draft changes to the selected connection.
5. Click `Save To SSH Config` in the toolbar to write all committed changes to disk.

### Keys Tab

In the `Key Management` section:

- Generate: enter key name and type (default `ed25519`) then click `Generate`
- Import: enter private key file path then click `Import`
- Optional toggles:
  - `Add to ssh-agent`
  - `Use macOS Keychain`
- Run `Doctor Keys` to fix key permissions and check agent reachability
- `Current Keys` list shows detected local keys under `~/.ssh` (private/public path and fingerprint when available)
- Only keys with names starting with `id_` are shown/usable in the UI

## CLI Usage

### Command List

```text
sshcm list [--group <name>] [--tag <tag>]
sshcm connect <host-or-tag>
sshcm jump <target> --via <bastion-chain>
sshcm forward <target> [--L spec] [--R spec] [--D spec]
sshcm doctor-keys
sshcm keygen <name> [--type ed25519] [--add-agent] [--use-keychain]
sshcm import-key <path> [--name key_name] [--add-agent] [--use-keychain]
```

### Examples

List all hosts:

```bash
swift run sshcm list
```

List hosts in `prod` group:

```bash
swift run sshcm list --group prod
```

List hosts with tag `db`:

```bash
swift run sshcm list --tag db
```

Connect by alias:

```bash
swift run sshcm connect prod-db
```

Connect by tag (if multiple hosts match, first match is used and a warning is printed):

```bash
swift run sshcm connect db
```

Temporary jump connection:

```bash
swift run sshcm jump internal-host --via bastion1,bastion2
```

Temporary local forward:

```bash
swift run sshcm forward prod-db --L 127.0.0.1:5432:127.0.0.1:5432
```

Generate key and add to agent + Keychain:

```bash
swift run sshcm keygen id_ed25519_prod --add-agent --use-keychain
```

Import key and add to agent:

```bash
swift run sshcm import-key /path/to/id_ed25519 --add-agent
```

Run key doctor:

```bash
swift run sshcm doctor-keys
```

## Security Notes

- Save flow uses atomic replacement to reduce corruption risk.
- Backup file is created before rewriting main config.
- Private key files are normalized to `0600`; public keys to `0644`; `~/.ssh` to `0700`.
- This tool does not perform remote connectivity validation by default.

## Troubleshooting

### No hosts shown

- Check `~/.ssh/config` exists and is readable.
- If only `Include` is present, ensure referenced files exist.

### Permission errors

- Ensure your user has read/write permission for `~/.ssh`.
- Run:

```bash
swift run sshcm doctor-keys
```

### `connect` by tag chooses unexpected host

- `connect <tag>` may match multiple hosts; use alias for deterministic behavior.

## License

MIT (project code is currently prepared for MIT-style usage; adjust once you add a formal `LICENSE` file).
