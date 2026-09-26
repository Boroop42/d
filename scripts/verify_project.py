"""Validate effective Xcode settings, including XcodeGen's installed setting presets."""
import json
import os
import subprocess
from pathlib import Path

settings = json.loads(subprocess.check_output([
    'xcodebuild', '-project', 'PikoIOS.xcodeproj', '-scheme', 'PikoIOS',
    '-configuration', 'Release', '-sdk', 'iphoneos', '-showBuildSettings', '-json'
], text=True))
app = next(item['buildSettings'] for item in settings if item['target'] == 'PikoIOS')
expected = {'PRODUCT_NAME': 'PikoIOS', 'EXECUTABLE_NAME': 'PikoIOS',
            'WRAPPER_NAME': 'PikoIOS.app', 'PRODUCT_BUNDLE_IDENTIFIER': os.environ['IOS_BUNDLE_ID'],
            'PLATFORM_NAME': 'iphoneos', 'IPHONEOS_DEPLOYMENT_TARGET': '17.0'}
for key, value in expected.items():
    if app.get(key) != value:
        raise ValueError(f'Invalid effective Xcode setting: {key}')
if not (Path(app['SRCROOT']) / app['INFOPLIST_FILE']).is_file():
    raise ValueError('Effective Info.plist path does not exist')
print('Effective Xcode product name, device platform, bundle ID and deployment target verified.')
