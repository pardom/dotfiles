#!/usr/bin/env python3
"""Create/resume owned, expiring holds without silently replacing foreign work."""
import argparse
import json
import sys
from verification import hold_path, read_json, repository, utc_now, write_json


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['create', 'resume', 'status'])
    parser.add_argument('--repo', default='.')
    parser.add_argument('--owner')
    parser.add_argument('--task')
    parser.add_argument('--reason')
    args = parser.parse_args()
    path = hold_path(repository(args.repo))
    if args.action == 'status':
        print(path.read_text() if path.exists() else 'No hold')
        return
    if not args.owner:
        parser.error('--owner requires the current harness session ID; do not invent one')
    existing = read_json(path)
    if path.exists() and (not isinstance(existing, dict) or existing.get('owner') != args.owner):
        parser.error('foreign/legacy hold: inspect and obtain explicit disposition before removing it')
    if args.action == 'resume':
        if path.exists():
            path.unlink()
    else:
        if not args.task or not args.reason:
            parser.error('create requires --task and --reason')
        write_json(path, {'version': 1, 'owner': args.owner, 'task': args.task,
                          'reason': args.reason, 'created_at': utc_now().isoformat()})

if __name__ == '__main__':
    main()
