"""Package only the isolated smoke target; verify physical-device Mach-O."""
import hashlib
import plistlib
import re
import subprocess
import zipfile
from pathlib import Path

name = 'PikoWebViewSmokeTest'
app = Path(f'build/SmokeDerivedData/Build/Products/Release-iphoneos/{name}.app')
info = plistlib.loads((app / 'Info.plist').read_bytes())
assert info['CFBundleSupportedPlatforms'] == ['iPhoneOS']
assert info['CFBundleIdentifier'] == 'com.local.pikowebviewsmoketest'
assert info['CFBundleExecutable'] == name
assert info['MinimumOSVersion'] == '17.0'
binary = str(app / name)
assert subprocess.check_output(['lipo', '-archs', binary], text=True).strip() == 'arm64'
platform = subprocess.check_output(['xcrun', 'vtool', '-show-build', binary], text=True)
assert re.search(r'platform\s+IOS\b', platform) and 'IOSSIMULATOR' not in platform
assert not (app / 'embedded.mobileprovision').exists()
out = Path('build/smoke')
payload = out / 'Payload'
payload.mkdir(parents=True, exist_ok=True)
subprocess.run(['ditto', str(app), str(payload / app.name)], check=True)
ipa = out / f'{name}.ipa'
subprocess.run(['ditto', '-c', '-k', '--keepParent', str(payload), str(ipa)], check=True)
with zipfile.ZipFile(ipa) as archive:
    assert archive.testzip() is None
    assert f'Payload/{name}.app/{name}' in archive.namelist()
digest = hashlib.sha256(ipa.read_bytes()).hexdigest()
(out / 'SHA256SUMS.txt').write_text(f'{digest}  {ipa.name}\n')
print(f'Verified {ipa}: iPhoneOS arm64, {ipa.stat().st_size} bytes, SHA256 {digest}')
