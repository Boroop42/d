"""Verify the IPA contains an arm64 iPhoneOS binary, not a simulator .app."""
import os
import plistlib
import re
import subprocess
import tempfile
import zipfile
from pathlib import Path

def validate_info(info, env):
    for key, name in [('CFBundleIdentifier', 'IOS_BUNDLE_ID'),
                      ('CFBundleVersion', 'CURRENT_PROJECT_VERSION'),
                      ('CFBundleShortVersionString', 'MARKETING_VERSION')]:
        if info.get(key) != env[name]:
            raise ValueError(f'Packaged {key} differs from build settings')
    if info.get('CFBundleSupportedPlatforms') != ['iPhoneOS']:
        raise ValueError('IPA must be built for iPhoneOS, not iPhoneSimulator')
    if info.get('DTPlatformName') != 'iphoneos':
        raise ValueError('Unexpected SDK platform')
    if info.get('CFBundleExecutable') != 'PikoIOS':
        raise ValueError('Unexpected app executable')
    if int(info.get('MinimumOSVersion', '0').split('.')[0]) < 17:
        raise ValueError('Unexpected deployment target')

def verify():
    with zipfile.ZipFile('build/export/PikoIOS.ipa') as archive:
        names = archive.namelist()
        if 'Payload/PikoIOS.app/Info.plist' not in names:
            raise ValueError('IPA must contain Payload/PikoIOS.app')
        if any(name.startswith('/') or '..' in Path(name).parts for name in names):
            raise ValueError('Unexpected path in IPA')
        if any(name.endswith('embedded.mobileprovision') or '/PlugIns/' in name for name in names):
            raise ValueError('IPA unexpectedly contains a provisioning profile or app extension')
        info = plistlib.loads(archive.read('Payload/PikoIOS.app/Info.plist'))
        validate_info(info, os.environ)
        if 'Payload/PikoIOS.app/PrivacyInfo.xcprivacy' not in names:
            raise ValueError('Privacy manifest missing from IPA')
        with tempfile.TemporaryDirectory(prefix='piko-verify-', dir=os.environ.get('RUNNER_TEMP')) as temp:
            binary = Path(temp) / 'PikoIOS'
            binary.write_bytes(archive.read('Payload/PikoIOS.app/PikoIOS'))
            architectures = subprocess.check_output(['lipo', '-archs', str(binary)], text=True).split()
            if architectures != ['arm64']:
                raise ValueError('Expected only physical-device arm64 architecture')
            build = subprocess.check_output(['xcrun', 'vtool', '-show-build', str(binary)], text=True)
            if not re.search(r'platform\s+IOS\b', build) or 'IOSSIMULATOR' in build:
                raise ValueError('Mach-O platform is not iOS device')
    print('Verified PikoIOS.ipa: Payload structure, iPhoneOS arm64 Mach-O, versions, and minimal resources.')

if __name__ == '__main__':
    verify()
