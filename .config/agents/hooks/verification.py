"""Pure decisions and repository evidence helpers shared by hook and hold CLI."""
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import subprocess


def hold_reason(record, owner, now):
    if not isinstance(record, dict) or record.get('version') != 1:
        return 'legacy or invalid hold'
    if not owner or record.get('owner') != owner:
        return 'foreign or unknown hold owner'
    if not record.get('task') or not record.get('reason'):
        return 'incomplete hold'
    try:
        age = (now - datetime.fromisoformat(record['created_at'])).total_seconds()
    except (KeyError, ValueError, TypeError):
        return 'invalid hold timestamp'
    if age < 0 or age >= 86400:
        return 'expired or future-dated hold'
    return None


def result_status(exit_status, output, unchanged):
    if exit_status != 0:
        return 'fail'
    if not unchanged or any(line.lstrip().startswith('SKIPPED:') for line in output.splitlines()):
        return 'unverified'
    return 'pass'


def response(status, blocks, message):
    if status == 'pass':
        return {'continue': True, **({'systemMessage': message} if message else {})}
    if blocks > 3:
        return {'continue': True, 'systemMessage': message + '; stopping is permitted, completion is not verified.'}
    return {'decision': 'block', 'reason': message}


def git(root, *args):
    return subprocess.check_output(['git', '-C', str(root), *args], stderr=subprocess.DEVNULL)


def repository(path):
    return Path(git(path, 'rev-parse', '--show-toplevel').decode().strip()).resolve()


def hold_path(root):
    value = Path(git(root, 'rev-parse', '--git-path', 'agents-hold').decode().strip())
    return value if value.is_absolute() else root / value


def read_json(path):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return None


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + f'.{os.getpid()}.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n')
    temporary.replace(path)


def state_paths(root):
    state = Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state'))) / 'agents/verify-on-stop'
    key = hashlib.sha256(os.fsencode(root)).hexdigest()[:16]
    return state, key


def run_environment(script, root):
    return subprocess.run([str(script)], cwd=root, capture_output=True, timeout=10)


def identity(root, environment_runner=run_environment):
    """Hash revision, index/worktree, file modes, untracked data, and gate."""
    digest = hashlib.sha256()
    for source in ['verification.py', 'verify-on-stop.py']:
        digest.update((Path(__file__).parent / source).read_bytes())
    try:
        head = git(root, 'rev-parse', 'HEAD').decode().strip()
    except subprocess.CalledProcessError:
        head = 'unborn'
    digest.update(head.encode())
    digest.update(git(root, 'diff', '--binary', 'HEAD') if head != 'unborn' else git(root, 'diff', '--binary', '--cached'))
    digest.update(git(root, 'diff', '--binary', '--cached'))
    # Include all worktree files tracked or untracked (not ignored), including modes.
    has_submodule = False
    for name in sorted(set(git(root, 'ls-files', '-z', '--cached', '--others', '--exclude-standard').split(b'\0')) - {b''}):
        path = root / os.fsdecode(name)
        digest.update(name + b'\0')
        if path.is_symlink():
            digest.update(b'link:' + os.fsencode(os.readlink(path)))
        elif path.is_file():
            digest.update(str(path.stat().st_mode & 0o777).encode() + b':')
            digest.update(path.read_bytes())
        elif path.is_dir():
            # Include nested content in evidence, but do not cache across submodule environments.
            has_submodule = True
            digest.update(b'submodule:' + identity(path, environment_runner)[1].encode())
        else:
            digest.update(b'missing')
    check = root / '.agents/check'
    if check.is_file():
        digest.update(check.read_bytes())
        digest.update(str(check.stat().st_mode & 0o777).encode())
    env_script = root / '.agents/check-environment'
    env_identity = None
    if env_script.is_file() and os.access(env_script, os.X_OK):
        digest.update(env_script.read_bytes())
        try:
            result = environment_runner(env_script, root)
        except (OSError, subprocess.TimeoutExpired):
            result = None
        if result is not None and result.returncode == 0 and result.stdout.strip():
            # Persist only the digest, never the declared identity itself.
            env_identity = hashlib.sha256(result.stdout).hexdigest()
            digest.update(env_identity.encode())
    return head, digest.hexdigest(), None if has_submodule else env_identity


def utc_now():
    return datetime.now(timezone.utc)
