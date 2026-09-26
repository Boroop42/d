#!/bin/bash
set -euo pipefail
mkdir -p build/logs
device_id=$(xcrun simctl list devices available --json | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
choices = [(runtime, device) for runtime, values in devices.items() if ".iOS-" in runtime
           for device in values if device.get("isAvailable") and device["name"].startswith("iPhone")]
if not choices:
    raise SystemExit("No installed iPhone simulator is available for XCTest")
choices.sort(key=lambda item: tuple(int(part) for part in item[0].split("iOS-")[-1].split("-")), reverse=True)
print(choices[0][1]["udid"])
')
xcodebuild -project PikoIOS.xcodeproj -scheme PikoIOS -configuration Debug \
  -destination "platform=iOS Simulator,id=$device_id" -destination-timeout 120 \
  -parallel-testing-enabled NO -derivedDataPath build/TestDerivedData \
  -resultBundlePath build/Tests.xcresult CODE_SIGNING_ALLOWED=NO test \
  2>&1 | tee build/logs/xctest.log
