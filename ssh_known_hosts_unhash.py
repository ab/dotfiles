#!/usr/bin/env python3

import os
import re
import subprocess
import sys

from subprocess import check_call, check_output

def usage():
    sys.stderr.write('usage: ' + os.path.basename(sys.argv[0]) + ''' HOST

Locate HOST in ~/.ssh/known_hosts. If found and the existing known_hosts entry
is hashed, replace it with an unhashed version.
''')

KNOWN_HOSTS_FILE = os.path.realpath(os.path.expanduser("~/.ssh/known_hosts"))
open(KNOWN_HOSTS_FILE, 'r') # ensure readable

def main(args):
    if not args:
        usage()
        return 1

    for host in args:
        res = unhash(host)
        if res:
            return res

    return 0

def unhash(host):
    try:
        output = check_output(['ssh-keygen', '-F', host])
    except subprocess.CalledProcessError:
        sys.stderr.write('host not found: %r\n' % host)
        return 2

    lines = output.strip().split('\n')

    assert len(lines) == 2, 'More than two lines of output: %r' % output

    assert 'found: line ' in lines[0], ('Malformed line: %r' % output)

    if not lines[1].startswith('|1|'):
        sys.stderr.write('host not hashed: %r\n' % host)
        return


    match = re.search('^# Host \S+ found: line (\d+)\s*$', lines[0])
    assert match, 'Failed to find match on %r' % lines[0]

    line = int(match.group(1))

    cmd = ['sed', '-i~', '-r', r'%ds/\|1\|\S+ /%s /' % (line, host),
           KNOWN_HOSTS_FILE]
    sys.stderr.write('+ ' + ' '.join(cmd) + '\n')
    check_call(cmd)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
