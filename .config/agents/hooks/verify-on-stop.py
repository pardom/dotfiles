#!/usr/bin/env python3
"""Run the project gate, preserving verification separately from stop permission."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

from verification import (hold_path, hold_reason, identity, read_json, repository,
                          response, result_status, state_paths, utc_now, write_json)


def run_hook(payload):
    root = repository(payload.get('cwd') or '.')
    session = payload.get('session_id') or ''
    state, key = state_paths(root)
    state.mkdir(parents=True, exist_ok=True)
    result_path = state / f'{key}.result.json'
    check = root / '.agents/check'
    record = {'version': 1, 'repository': str(root), 'session': session,
              'time': utc_now().isoformat(), 'command': str(check),
              'status': 'unverified', 'exit_status': None, 'log': None}
    warnings = []
    hold = hold_path(root)
    if hold.exists():
        value = read_json(hold)
        invalid = hold_reason(value, session, utc_now())
        if invalid is None:
            record['reason'] = 'owned hold: ' + value['reason']
            # Retain last gate evidence separately when recording a pause.
            previous = read_json(result_path)
            if previous:
                record['previous_gate'] = previous.get('previous_gate') or {k: previous.get(k) for k in ('status', 'fingerprint', 'exit_status', 'log', 'time')}
            write_json(result_path, record)
            return {'continue': True, 'systemMessage': 'verify-on-stop: paused; unverified: ' + value['reason']}
        warnings.append('hold ignored (' + invalid + '); inspect and explicitly dispose of it')
    if not check.is_file() or not os.access(check, os.X_OK):
        record['reason'] = 'missing executable .agents/check'
        write_json(result_path, record)
        return {'continue': True, 'systemMessage': 'verify-on-stop: missing executable .agents/check; verification is unverified. ' + '; '.join(warnings)}
    head, fingerprint, environment = identity(root)
    record.update(head=head, fingerprint=fingerprint, environment_digest=environment)
    previous = read_json(result_path)
    if environment and not warnings and isinstance(previous, dict) and previous.get('status') == 'pass' and previous.get('fingerprint') == fingerprint:
        return {'continue': True}
    # Serialize a repository's checks; independent worktrees have distinct keys.
    import fcntl
    with (state / f'{key}.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        log = state / f'{key}.{utc_now().strftime("%Y%m%dT%H%M%S%f")}.log'
        with log.open('wb') as output:
            try:
                completed = subprocess.run([str(check)], cwd=root, stdout=output, stderr=subprocess.STDOUT)
            except OSError as error:
                output.write(('Could not launch .agents/check: ' + str(error) + '\n').encode())
                completed = subprocess.CompletedProcess([str(check)], 127)
        text = log.read_text(errors='replace')
        after = identity(root)
        status = result_status(completed.returncode, text, after[1] == fingerprint)
        record.update(status=status, exit_status=completed.returncode, log=str(log))
        if after[1] != fingerprint:
            warnings.append('tree/environment changed during check; rerun required')
        import hashlib
        session_key = hashlib.sha256(session.encode()).hexdigest()[:16]
        blocks_path = state / f'{key}.{session_key}.blocks.json'
        counts = read_json(blocks_path) or {}
        blocks = 0 if status == 'pass' else (counts.get('count', 0) + 1 if counts.get('fingerprint') == fingerprint else 1)
        write_json(blocks_path, {'fingerprint': fingerprint, 'count': blocks})
        record['blocks'] = blocks
        record['reason'] = '; '.join(warnings)
        write_json(result_path, record)
    if status == 'pass':
        return response(status, blocks, '; '.join(warnings))
    summary = f'verify-on-stop: .agents/check {"failed" if status == "fail" else "unverified"} (attempt {blocks}); evidence: {result_path}'
    if warnings:
        summary += '\n' + '; '.join(warnings)
    summary += '\nDo not weaken or skip required checks. Last 60 lines:\n' + '\n'.join(text.splitlines()[-60:])
    return response(status, blocks, summary)


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--status', metavar='REPOSITORY')
    mode.add_argument('--identity', metavar='REPOSITORY')
    args = parser.parse_args()
    if args.identity:
        root = repository(args.identity)
        head, fingerprint, environment = identity(root)
        print(json.dumps({'head': head, 'fingerprint': fingerprint, 'environment_digest': environment}, indent=2))
        return
    if args.status:
        root = repository(args.status)
        state, key = state_paths(root)
        print(json.dumps(read_json(state / f'{key}.result.json') or {'status': 'unverified', 'reason': 'no hook evidence'}, indent=2))
        return
    try:
        payload = json.load(sys.stdin)
        result = run_hook(payload)
    except subprocess.CalledProcessError:
        result = {'continue': True, 'systemMessage': 'verify-on-stop: no repository or git operation failed; verification unverified.'}
    except (OSError, ValueError, TypeError, subprocess.TimeoutExpired) as error:
        result = {'decision': 'block', 'reason': 'verify-on-stop could not establish verification: ' + str(error)}
    print(json.dumps(result))

if __name__ == '__main__':
    main()
