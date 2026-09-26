# PikoIOS Release Status

Source Code: ✅ Phase 1–2 retained
CI Configuration: ✅ Executed on GitHub macos-latest
Swift/DOM/Configuration Tests: ✅ 23 tests passed in CI (8 Swift, 10 JavaScript, 5 Python)
GitHub Push: ✅ Complete
Xcode Project Generation: ✅ XcodeGen 2.46.0
Physical iOS Release Compile: ✅ Xcode 26.6 / iPhoneOS SDK 26.5 / arm64
IPA Generated: ✅ PikoIOS.ipa
GitHub IPA Artifact: ✅ Uploaded and downloaded for verification
Apple signing in CI: Not required
Free Apple ID Re-signing: User action through AltStore/Sideloadly
iPhone Installation: Previous IPA installed by user; new navigation-fix build needs device re-test

## Verified build evidence

- Successful run: [36237921272](https://github.com/Boroop42/d/actions/runs/36237921272)
- Download: [PikoIOS-ipa artifact](https://github.com/Boroop42/d/actions/runs/36237921272/artifacts/10904499432)
- Built source commit: `21c5412310fe4c35646b9ac3ec6e5311b87d4798`
- Version/build: `1.0 (6.1)`
- Bundle ID: `com.local.pikoios`
- Minimum iOS: `17.0`
- IPA size: `2886034` bytes
- IPA SHA-256: `6678ae8eafd376ce3147c5f43e0056de344c7375e0f75284600acdc1edf70728`

Verified independently after downloading: ZIP integrity, SHA-256, Payload/PikoIOS.app,
Info.plist, executable permissions, arm64 Mach-O, IOS device platform (not Simulator),
and absence of an embedded provisioning profile. Swift warnings are treated as errors;
the final Swift compile had no warnings. Xcode emitted only an AppIntents metadata notice
because this app does not use AppIntents.

The requested CI-artifact completion condition is satisfied. The remaining user step is
free Apple ID re-signing and installation using [AltStore Classic or Sideloadly](docs/IPHONE_INSTALL.md).
Actual launch/login on the user's physical iPhone has not been tested here.

Later documentation-only commits do not change the source in this verified IPA.
