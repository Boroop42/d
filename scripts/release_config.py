"""Validate device-IPA build inputs and create an XcodeGen settings overlay."""
import json
import os
import re
from pathlib import Path


def configuration(env):
    bundle = env.get('IOS_BUNDLE_ID') or 'com.local.pikoios'
    version = env.get('MARKETING_VERSION') or '1.0'
    build = env.get('CURRENT_PROJECT_VERSION') or (
        f"{env.get('GITHUB_RUN_NUMBER', '1')}.{env.get('GITHUB_RUN_ATTEMPT', '1')}"
    )
    if not re.fullmatch(r'[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+', bundle):
        raise ValueError('IOS_BUNDLE_ID must be an explicit reverse-DNS identifier')
    if not re.fullmatch(r'\d+\.\d+(?:\.\d+)?', version):
        raise ValueError('MARKETING_VERSION must contain two or three numeric components')
    if not re.fullmatch(r'[1-9]\d{0,3}(?:\.\d{1,2}){0,2}', build):
        raise ValueError('CURRENT_PROJECT_VERSION must use at most 4.2.2 digits, e.g. 42 or 42.2')
    return {'IOS_BUNDLE_ID': bundle, 'MARKETING_VERSION': version, 'CURRENT_PROJECT_VERSION': build}


def main():
    values = configuration(os.environ)
    Path('build').mkdir(exist_ok=True)
    # Overlay resides in build, but project paths must resolve from the repository root.
    overlay = {'include': ['../project.yml'], 'settings': {'base': values}}
    Path('build/ci-project.json').write_text(json.dumps(overlay), encoding='utf-8')
    if os.environ.get('GITHUB_ENV'):
        with open(os.environ['GITHUB_ENV'], 'a', encoding='utf-8') as file:
            for key, value in values.items():
                file.write(f'{key}={value}\n')
    Path('build/version.json').write_text(json.dumps(values, indent=2), encoding='utf-8')


if __name__ == '__main__':
    main()
