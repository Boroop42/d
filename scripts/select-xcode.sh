#!/bin/bash
set -euo pipefail
# macos-latest's default stable Xcode; optionally pin an installed version via repository variable.
if [[ -n "${XCODE_VERSION:-}" ]]; then
  [[ "$XCODE_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]] || { echo 'Invalid XCODE_VERSION'; exit 1; }
  developer_dir="/Applications/Xcode_${XCODE_VERSION}.app/Contents/Developer"
else
  developer_dir="/Applications/Xcode.app/Contents/Developer"
fi
test -d "$developer_dir"
sudo xcode-select --switch "$developer_dir"
printf 'DEVELOPER_DIR=%s\n' "$developer_dir" >> "$GITHUB_ENV"
xcodebuild -version
xcodebuild -showsdks
