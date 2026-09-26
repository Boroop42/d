import plistlib
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from release_config import configuration
from verify_ipa import validate_info

class ReleaseTests(unittest.TestCase):
    def info(self):
        return {'CFBundleIdentifier': 'com.local.pikoios', 'CFBundleVersion': '23.1',
                'CFBundleShortVersionString': '1.0', 'CFBundleSupportedPlatforms': ['iPhoneOS'],
                'DTPlatformName': 'iphoneos', 'CFBundleExecutable': 'PikoIOS', 'MinimumOSVersion': '17.0'}
    def env(self):
        return configuration({'GITHUB_RUN_NUMBER': '23', 'GITHUB_RUN_ATTEMPT': '1'})
    def test_device_bundle_accepted(self):
        validate_info(self.info(), self.env())
    def test_simulator_bundle_and_wrong_identity_rejected(self):
        for key, value in [('CFBundleSupportedPlatforms', ['iPhoneSimulator']),
                           ('DTPlatformName', 'iphonesimulator'), ('CFBundleIdentifier', 'wrong.id'),
                           ('CFBundleVersion', 'old'), ('CFBundleExecutable', 'Other')]:
            info = self.info()
            info[key] = value
            with self.assertRaises(ValueError):
                validate_info(info, self.env())
    def test_versions_and_retry(self):
        self.assertEqual(self.env()['CURRENT_PROJECT_VERSION'], '23.1')
        self.assertEqual(configuration({'GITHUB_RUN_NUMBER': '23', 'GITHUB_RUN_ATTEMPT': '2'})['CURRENT_PROJECT_VERSION'], '23.2')
        self.assertEqual(configuration({'CURRENT_PROJECT_VERSION': '42'})['CURRENT_PROJECT_VERSION'], '42')
    def test_invalid_inputs_rejected(self):
        for key, value in [('IOS_BUNDLE_ID', 'com.app\nBAD=1'), ('MARKETING_VERSION', '1; command'),
                           ('CURRENT_PROJECT_VERSION', '0'), ('CURRENT_PROJECT_VERSION', '10000')]:
            with self.assertRaises(ValueError):
                configuration({key: value})
    def test_privacy_manifest_and_version_settings(self):
        info = plistlib.loads((ROOT / 'Resources/Info.plist').read_bytes())
        self.assertEqual(info['CFBundleVersion'], '$(CURRENT_PROJECT_VERSION)')
        manifest = plistlib.loads((ROOT / 'Resources/PrivacyInfo.xcprivacy').read_bytes())
        self.assertEqual(manifest['NSPrivacyAccessedAPITypes'][0]['NSPrivacyAccessedAPITypeReasons'], ['CA92.1'])

if __name__ == '__main__':
    unittest.main()
