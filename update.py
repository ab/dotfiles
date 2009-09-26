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

def rsync(conf, dest, verbose):
    opts = '-v' if verbose else ''
    call(['rsync', '-a', opts, conf, dest])

def copy(conf, dest, verbose):
    opts = '-v' if verbose else ''
    call(['cp', '-a', opts, conf, dest])

def link(conf, dest, verbose):
    opts = '-v' if verbose else ''
    call(['ln', opts, '-s', conf, dest])


def run(action, verbose=True):
    config_map = read_file_list()
    for conf, (basedir, fname) in config_map.iteritems():
        action(conf, os.path.join(basedir, fname), verbose)

if __name__ == '__main__':
    action = rsync
    run(action)

