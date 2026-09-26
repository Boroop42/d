# PikoIOS Release Status

Source Code: ✅ Phase 1–2 retained
CI Configuration: ✅ Executed on GitHub macos-latest
DOM/Configuration Tests: ✅ 14 tests passed locally and in CI
GitHub Push: ✅ Complete
Xcode Project Generation: ✅ XcodeGen 2.46.0
Physical iOS Release Compile: ✅ Xcode 26.6 / iPhoneOS SDK 26.5 / arm64
IPA Generated: ✅ PikoIOS.ipa
GitHub IPA Artifact: ✅ Uploaded and downloaded for verification
Apple signing in CI: Not required
Free Apple ID Re-signing: User action through AltStore/Sideloadly
iPhone Installation: ❌ Not verified on device

## Verified build evidence

- Successful run: [36235370149](https://github.com/Boroop42/d/actions/runs/36235370149)
- Download: [PikoIOS-ipa artifact](https://github.com/Boroop42/d/actions/runs/36235370149/artifacts/10903793524)
- Built source commit: `704e29c21f57c329f01389c26d65646a2a3e72a4`
- Version/build: `1.0 (3.1)`
- Bundle ID: `com.local.pikoios`
- Minimum iOS: `17.0`
- IPA size: `137677` bytes
- IPA SHA-256: `9bae9945315d881ffb83ce2c5d63cc14d85c2bf758b14c831b0002b7048ab7ae`

Verified independently after downloading: ZIP integrity, SHA-256, Payload/PikoIOS.app,
Info.plist, executable permissions, arm64 Mach-O, IOS device platform (not Simulator),
and absence of an embedded provisioning profile. Swift warnings are treated as errors;
the final Swift compile had no warnings. Xcode emitted only an AppIntents metadata notice
because this app does not use AppIntents.

The requested CI-artifact completion condition is satisfied. The remaining user step is
free Apple ID re-signing and installation using [AltStore Classic or Sideloadly](docs/IPHONE_INSTALL.md).
Actual launch/login on the user's physical iPhone has not been tested here.

Later documentation-only commits do not change the source in this verified IPA.
