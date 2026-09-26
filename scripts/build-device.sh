#!/bin/bash
set -euo pipefail
mkdir -p build/logs
xcodebuild -resolvePackageDependencies -project PikoIOS.xcodeproj -scheme PikoIOS \
  2>&1 | tee build/logs/dependencies.log
xcodebuild -project PikoIOS.xcodeproj -scheme PikoIOS -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath build/DerivedData \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY='' DEVELOPMENT_TEAM='' build 2>&1 | tee build/logs/compile.log
test -f build/DerivedData/Build/Products/Release-iphoneos/PikoIOS.app/PikoIOS
