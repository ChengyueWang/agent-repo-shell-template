#!/usr/bin/env python3
"""Read-only checks for the shell's declared mounts and skill discovery links."""
from pathlib import Path
import re
import subprocess
import sys


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    problems = []
    result = subprocess.run(['bash', str(root / 'setup.sh'), '--check'], cwd=root)
    if result.returncode:
        problems.append('configured mounts failed validation')
    for path in ('targets/.mount-check', 'scratch/.storage-check'):
        if subprocess.run(['git', 'check-ignore', '-q', '--', path], cwd=root).returncode:
            problems.append(f'{path.split("/")[0]}/ must be gitignored')

    skills = root / 'skills'
    canonical = set()
    for folder in sorted(skills.iterdir()):
        if not folder.is_dir() or folder.is_symlink():
            problems.append(f'skills/{folder.name}: expected a canonical directory')
            continue
        canonical.add(folder.name)
        entry = folder / 'SKILL.md'
        if not entry.is_file():
            problems.append(f'{entry.relative_to(root)}: missing')
            continue
        text = entry.read_text(encoding='utf-8')
        frontmatter = re.match(r'\A---\n(.*?)\n---(?:\n|$)', text, re.S)
        if not frontmatter:
            problems.append(f'{entry.relative_to(root)}: missing YAML frontmatter')
            continue
        # Check the template's simple scalar frontmatter without a YAML dependency.
        fields = {}
        for line in frontmatter.group(1).splitlines():
            if ':' in line and not line.startswith((' ', '\t', '#')):
                key, value = line.split(':', 1)
                fields[key] = value.strip().strip('\'"')
        if not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', folder.name) or len(folder.name) > 64:
            problems.append(f'{entry.relative_to(root)}: invalid skill name')
        if fields.get('name') != folder.name or not fields.get('description'):
            problems.append(f'{entry.relative_to(root)}: name must match directory and description must be nonempty')

    for agent in ('.agents', '.claude'):
        discovery = root / agent / 'skills'
        for name in sorted(canonical):
            link = discovery / name
            expected = Path('../../skills') / name
            if not link.is_symlink() or link.readlink() != expected or not link.is_dir():
                problems.append(f'{link.relative_to(root)}: expected working symlink to {expected}')
        if discovery.is_dir():
            for link in discovery.iterdir():
                if link.name not in canonical:
                    problems.append(f'{link.relative_to(root)}: no canonical skill')
    for problem in problems:
        print(f'[fail] {problem}', file=sys.stderr)
    if problems:
        return 1
    print(f'Workspace checks passed ({len(canonical)} skills).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
