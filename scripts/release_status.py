import os
from pathlib import Path

def result(name):
    value = os.environ.get(name, '')
    return '✅ Verified' if value == 'success' else f'❌ {value or "Not attempted"}'

text = f'''# PikoIOS Release Status

Source Code: ✅ Checked out
Xcode Project Generation: {result('GENERATE_OUTCOME')}
Physical iOS Release Compile: {result('COMPILE_OUTCOME')}
IPA Generated and Verified: {result('IPA_OUTCOME')}
GitHub IPA Artifact: {result('ARTIFACT_OUTCOME')}
Apple signing in CI: Not required (IPA is for local re-signing)
Free Apple ID Re-signing: User action on Windows
iPhone Installation: Not verified on a physical device

Build: {os.environ.get('CURRENT_PROJECT_VERSION', 'not allocated')}
Run: {os.environ.get('GITHUB_SERVER_URL', '')}/{os.environ.get('GITHUB_REPOSITORY', '')}/actions/runs/{os.environ.get('GITHUB_RUN_ID', '')}
Artifact: {os.environ.get('ARTIFACT_URL', 'Not uploaded')}

Download PikoIOS.ipa from the artifact ZIP and use AltStore Classic or Sideloadly to re-sign and install.
The artifact cannot be installed directly by tapping it on an iPhone.
'''
Path('build').mkdir(exist_ok=True)
Path('build/RELEASE_STATUS.md').write_text(text, encoding='utf-8')
if os.environ.get('GITHUB_STEP_SUMMARY'):
    with open(os.environ['GITHUB_STEP_SUMMARY'], 'a', encoding='utf-8') as file:
        file.write(text)
