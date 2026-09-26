"""Package a device .app in Payload for subsequent AltStore/Sideloadly signing."""
import hashlib
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def package():
    app = ROOT / 'build/DerivedData/Build/Products/Release-iphoneos/PikoIOS.app'
    if not (app / 'PikoIOS').is_file():
        raise FileNotFoundError('Release-iphoneos/PikoIOS.app/PikoIOS is missing')
    stage = ROOT / 'build/ipa-stage'
    if stage.exists():
        shutil.rmtree(stage)
    payload = stage / 'Payload'
    payload.mkdir(parents=True)
    destination = payload / 'PikoIOS.app'
    shutil.copytree(app, destination, symlinks=True)
    for profile in destination.rglob('embedded.mobileprovision'):
        profile.unlink()
    for signature in list(destination.rglob('_CodeSignature')):
        if signature.is_dir():
            shutil.rmtree(signature)
    export = ROOT / 'build/export'
    export.mkdir(parents=True, exist_ok=True)
    ipa = export / 'PikoIOS.ipa'
    ipa.unlink(missing_ok=True)
    subprocess.run(['ditto', '-c', '-k', '--keepParent', '--norsrc', str(payload), str(ipa)], check=True)
    if not ipa.is_file() or ipa.stat().st_size == 0:
        raise RuntimeError('IPA packaging did not produce a non-empty file')
    digest = hashlib.sha256(ipa.read_bytes()).hexdigest()
    (export / 'SHA256SUMS.txt').write_text(f'{digest}  PikoIOS.ipa\n', encoding='utf-8')
    (export / 'INSTALL.txt').write_text(
        'PikoIOS.ipa is a physical-device iOS 17+ app for re-signing.\n'
        'It is not signed for direct installation.\n'
        'Use AltStore Classic/AltServer or Sideloadly on Windows with your own free Apple ID.\n'
        'Refresh before the free 7-day signing period expires.\n'
        'Instructions: https://github.com/Boroop42/d/blob/main/docs/IPHONE_INSTALL.md\n', encoding='utf-8')

if __name__ == '__main__':
    package()
