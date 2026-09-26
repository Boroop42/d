#!/bin/bash
set -euo pipefail
version=2.46.0
digest=4d9e34b62172d645eed6457cac13fc222569974098ef4ee9c3368bedf0196806
tool_dir="${RUNNER_TEMP:?}/piko-xcodegen"
mkdir -p "$tool_dir"
curl --fail --location --silent --show-error --retry 3 \
  "https://github.com/yonaskolb/XcodeGen/releases/download/$version/xcodegen.zip" \
  --output "$tool_dir/xcodegen.zip"
printf '%s  %s\n' "$digest" "$tool_dir/xcodegen.zip" | shasum -a 256 --check --status
unzip -q "$tool_dir/xcodegen.zip" -d "$tool_dir/unpacked"
binary=$(find "$tool_dir/unpacked" -type f -name xcodegen | head -n 1)
test -n "$binary"
mkdir -p "$tool_dir/bin"
cp "$binary" "$tool_dir/bin/xcodegen"
chmod +x "$tool_dir/bin/xcodegen"
"$tool_dir/bin/xcodegen" --version | grep -F "$version"
printf '%s\n' "$tool_dir/bin" >> "$GITHUB_PATH"
