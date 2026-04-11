#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-SSHConfigManagerGUI}"
BUNDLE_ID="${BUNDLE_ID:-dev.sshconfigmanager.gui}"
VERSION="${VERSION:-0.1.0}"
MIN_MACOS_VERSION="${MIN_MACOS_VERSION:-14.0}"
DIST_DIR="${DIST_DIR:-dist}"
PRODUCT_NAME="${PRODUCT_NAME:-$APP_NAME}"
DMG_NAME="${DMG_NAME:-${PRODUCT_NAME}-${VERSION}.dmg}"

SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"
SIGNING_CERT_BASE64="${SIGNING_CERT_BASE64:-}"
SIGNING_CERT_PASSWORD="${SIGNING_CERT_PASSWORD:-}"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-codex-temp-keychain-password}"

NOTARIZE="${NOTARIZE:-false}"
APPLE_ID="${APPLE_ID:-}"
APPLE_TEAM_ID="${APPLE_TEAM_ID:-}"
APPLE_APP_SPECIFIC_PASSWORD="${APPLE_APP_SPECIFIC_PASSWORD:-}"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: This script must run on macOS (Darwin)." >&2
  exit 1
fi

decode_base64_to_file() {
  local encoded="$1"
  local output_file="$2"

  if printf "%s" "$encoded" | base64 --decode >"$output_file" 2>/dev/null; then
    return 0
  fi
  if printf "%s" "$encoded" | base64 -d >"$output_file" 2>/dev/null; then
    return 0
  fi
  if printf "%s" "$encoded" | base64 -D >"$output_file" 2>/dev/null; then
    return 0
  fi

  echo "ERROR: Failed to decode base64 certificate content." >&2
  return 1
}

cleanup() {
  if [[ -n "${TMP_CERT_FILE:-}" && -f "$TMP_CERT_FILE" ]]; then
    rm -f "$TMP_CERT_FILE"
  fi
  if [[ -n "${TMP_KEYCHAIN:-}" ]]; then
    security delete-keychain "$TMP_KEYCHAIN" >/dev/null 2>&1 || true
  fi
  if [[ -n "${DMG_STAGING_DIR:-}" && -d "$DMG_STAGING_DIR" ]]; then
    rm -rf "$DMG_STAGING_DIR"
  fi
}
trap cleanup EXIT

echo "==> Building release product: ${APP_NAME}"
swift build -c release --product "$APP_NAME"

BIN_PATH="$(find .build -type f -name "$APP_NAME" | grep '/release/' | head -n 1 || true)"
if [[ -z "$BIN_PATH" ]]; then
  echo "ERROR: Could not locate release binary for $APP_NAME" >&2
  exit 1
fi

APP_DIR="$DIST_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RES_DIR="$CONTENTS_DIR/Resources"

rm -rf "$DIST_DIR"
mkdir -p "$MACOS_DIR" "$RES_DIR"
cp "$BIN_PATH" "$MACOS_DIR/$APP_NAME"

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key><string>en</string>
  <key>CFBundleExecutable</key><string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key><string>${BUNDLE_ID}</string>
  <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
  <key>CFBundleName</key><string>${PRODUCT_NAME}</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>${VERSION}</string>
  <key>CFBundleVersion</key><string>${VERSION}</string>
  <key>LSMinimumSystemVersion</key><string>${MIN_MACOS_VERSION}</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
PLIST

if [[ -n "$SIGNING_IDENTITY" ]]; then
  if [[ -z "$SIGNING_CERT_BASE64" || -z "$SIGNING_CERT_PASSWORD" ]]; then
    echo "ERROR: SIGNING_IDENTITY is set, but SIGNING_CERT_BASE64 / SIGNING_CERT_PASSWORD is missing" >&2
    exit 1
  fi

  echo "==> Importing signing certificate"
  TMP_CERT_FILE="$(mktemp /tmp/signing-cert-XXXXXX.p12)"
  decode_base64_to_file "$SIGNING_CERT_BASE64" "$TMP_CERT_FILE"

  TMP_KEYCHAIN="build-signing.keychain-db"
  security create-keychain -p "$KEYCHAIN_PASSWORD" "$TMP_KEYCHAIN"
  security set-keychain-settings -lut 21600 "$TMP_KEYCHAIN"
  security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$TMP_KEYCHAIN"
  security import "$TMP_CERT_FILE" -k "$TMP_KEYCHAIN" -P "$SIGNING_CERT_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security
  security list-keychains -d user -s "$TMP_KEYCHAIN"
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$TMP_KEYCHAIN"

  echo "==> Signing app bundle"
  codesign --force --deep --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP_DIR"
  codesign --verify --deep --strict "$APP_DIR"
else
  echo "==> No Developer ID signing configured; applying ad-hoc signature"
  codesign --force --deep --sign - "$APP_DIR"
fi

mkdir -p "$DIST_DIR"
DMG_PATH="$DIST_DIR/$DMG_NAME"
DMG_STAGING_DIR="$DIST_DIR/.dmg-root"

echo "==> Creating DMG: $DMG_PATH"
rm -rf "$DMG_STAGING_DIR"
mkdir -p "$DMG_STAGING_DIR"
cp -R "$APP_DIR" "$DMG_STAGING_DIR/"
ln -s /Applications "$DMG_STAGING_DIR/Applications"
hdiutil create -volname "$PRODUCT_NAME" -srcfolder "$DMG_STAGING_DIR" -ov -format UDZO "$DMG_PATH"

if [[ -n "$SIGNING_IDENTITY" ]]; then
  echo "==> Signing DMG"
  codesign --force --timestamp --sign "$SIGNING_IDENTITY" "$DMG_PATH"
  codesign --verify --strict "$DMG_PATH"
fi

if [[ "$NOTARIZE" == "true" ]]; then
  if [[ -z "$APPLE_ID" || -z "$APPLE_TEAM_ID" || -z "$APPLE_APP_SPECIFIC_PASSWORD" ]]; then
    echo "ERROR: NOTARIZE=true but APPLE_ID / APPLE_TEAM_ID / APPLE_APP_SPECIFIC_PASSWORD is missing" >&2
    exit 1
  fi
  if [[ -z "$SIGNING_IDENTITY" ]]; then
    echo "ERROR: NOTARIZE=true requires SIGNING_IDENTITY" >&2
    exit 1
  fi

  echo "==> Submitting DMG for notarization"
  xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$APPLE_APP_SPECIFIC_PASSWORD" \
    --wait

  echo "==> Stapling notarization ticket"
  xcrun stapler staple "$DMG_PATH"
fi

echo "==> Done"
echo "APP_PATH=$APP_DIR"
echo "DMG_PATH=$DMG_PATH"
