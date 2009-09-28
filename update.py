#!/usr/bin/env python
import os
import sys
from subprocess import call

home = os.getenv('HOME')
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
    
    def pre_run(self):
        pass
    
    def post_run(self):
        pass
    
    def action(self, conf, dest):
        raise NotImplementedError("No copy action defined for this class")
    
    def run(self):
        self.pre_run()
        
        for conf, (basedir, fname) in self.config_map.iteritems():
            self.action(conf, os.path.join(basedir, fname))
        
        self.post_run()

class CopyRunner(Runner):
    def action(self, conf, dest):
        opts = '-v' if self.verbose else ''
        call(['cp', '-a', opts, conf, dest])

class LinkRunner(Runner):
    def action(self, conf, dest):
        opts = '-v' if self.verbose else ''
        call(['ln', opts, '-s', conf, dest])

class RsyncRunner(Runner):
    def action(self, conf, dest):
        opts = '-v' if self.verbose else ''
        call(['rsync', '-a', opts, conf, dest])

class RsyncDryRunner(RsyncRunner):
    def action(self, conf, dest):
        opts = '-vn' if self.verbose else '-n'
        call(['rsync', '-a', opts, conf, dest])

if __name__ == '__main__':
    filelist = read_file_list()
    
    verbose = True
    runner = None

    if '-q' in sys.argv:
        verbose = False
    if '-n' in sys.argv:
        runner = RsyncDryRunner(filelist, verbose)

    if not runner:
        runner = RsyncRunner(filelist, verbose)

    runner.run()

