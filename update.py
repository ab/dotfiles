#!/usr/bin/env python
import os
import sys
from subprocess import call

home = os.getenv('HOME')
cwd = os.getenv('PWD')
FILE_LIST = '_file_list'

dir_map = {'$HOME':os.getenv('HOME')}

def read_file_list():
    f = open(FILE_LIST, 'r')
    config_map = {}

    for i, line in enumerate(f):
        if line.startswith('#'):
            continue
        if not line.strip():
            continue

        try:
            conf, dir, dest = line.strip().split('\t')
        except ValueError:
            print "Failed to parse line %d: '%s'" % (i, line)

        if dir in dir_map:
            dir = dir_map[dir]

        config_map[conf] = (dir, dest)

    return config_map

class Runner(object):
    def __init__(self, conf_map, verbose=True):
        self.config_map = conf_map
        self.verbose = verbose
        self.dirs = ['~/bin', '~/.ssh', '~/.ssh/sockets']

    def __str__(self):
        print "Generic sync runner class with no action"

    def pre_run(self):
        pass

    def post_run(self):
        pass

    def setup_dirs(self):
        for d in self.dirs:
            path = os.path.expanduser(d)
            if not os.path.exists(path):
                os.mkdir(path)
                print "created directory `%s'" % path

    def action(self, conf, dest):
        raise NotImplementedError("No copy action defined for this class")

    def run(self):
        self.setup_dirs()
        self.pre_run()

        for conf, (basedir, fname) in self.config_map.iteritems():
            self.action(conf, os.path.join(basedir, fname))

        self.post_run()

class CopyRunner(Runner):
    def __str__(self):
        return "CopyRunner"
    def action(self, conf, dest):
        opts = '-v' if self.verbose else ''
        call(['cp', '-a', opts, conf, dest])

class LinkRunner(Runner):
    def __str__(self):
        return "LinkRunner"
    def action(self, conf, dest):
        opts = '-v' if self.verbose else ''
        call(['ln', opts, '-sf', os.path.join(cwd, conf), dest])

class DeleteRunner(Runner):
    def __str__(self):
        return "DeleteRunner"
    def action(self, conf, dest):
        opts = '-v' if self.verbose else ''
        call(['rm', opts, dest])

class RsyncRunner(Runner):
    def __str__(self):
        return "RsyncRunner"
    def action(self, conf, dest):
        v = 'v' if self.verbose else ''
        call(['rsync', '-ac' + v, conf, dest])

class RsyncDryRunner(RsyncRunner):
    def __str__(self):
        return "RsyncDryRunner"
    def action(self, conf, dest):
        v = 'v' if self.verbose else ''
        call(['rsync', '-acn' + v, conf, dest])
        call(['echo', 'rsync', '-acn' + v, conf, dest])

if __name__ == '__main__':
    filelist = read_file_list()

    verbose = True
    runner = None
    confirm = True

    if '-q' in sys.argv:
        verbose = False
    if '-n' in sys.argv:
        runner = RsyncDryRunner(filelist, verbose)
        confirm = False
    if '-y' in sys.argv:
        confirm = False

    if 'rsync' in sys.argv and not runner:
        runner = RsyncRunner(filelist, verbose)
    if 'rm' in sys.argv and not runner:
        runner = DeleteRunner(filelist, verbose)

    if not runner:
        runner = LinkRunner(filelist, verbose)

    if confirm:
        print "About to run " + str(runner) + ",",
        raw_input("press enter to continue. ")

    runner.run()

