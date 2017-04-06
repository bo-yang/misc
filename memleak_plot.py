#!/usr/bin/env python

#
# This is a simple script to plot memory usage/allocation trends based on the periodical snapshots of
# /proc/meminfo and /proc/slabinfo.
#
# Usage:
#   memleak_plot.py -f <memory_monitor_output_file>
#
# For more details, please refer to:
#   http://www.bo-yang.net/2015/03/30/debug-kernel-space-memory-leak
#

import os
import sys
import os.path
import errno
import re
import glob
import time
import subprocess
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.legend_handler import HandlerLine2D

from getopt import getopt
from getopt import GetoptError

def run_system(cmd):
    """ Run bash commands and return the output """
    p = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,stdin=subprocess.PIPE)
    out,err = p.communicate()
    if len(out) > 0:
        return out.splitlines()
    else:
        return None

def draw_unreclaim(f):
    MemFree = run_system("grep MemFree %s | awk '{print $2}'" %f)
    MemFree = np.asarray(MemFree, dtype=int) / 1024 # MB
    SUnreclaim = run_system("grep SUnreclaim %s | awk '{print $2}'" %f)
    SUnreclaim = np.asarray(SUnreclaim, dtype=int) / 1024 # MB
    x=np.arange(1, 2*len(SUnreclaim)+1, 2)

    fig,ax1 = plt.subplots()
    ax1.plot(x, SUnreclaim, 'r', label='SUnreclaim')
    ax1.set_xlabel('uptime(hours)')
    # Make the y-axis label and tick labels match the line color.
    ax1.set_ylabel('SUnreclaim(MB)', color='r')
    for tl in ax1.get_yticklabels():
        tl.set_color('r')
    plt.legend()
    ax1.grid(True)

    ax2 = ax1.twinx() # draw two scales in one plot
    ax2.plot(x, MemFree, 'b', label='MemFree')
    ax2.set_ylabel('MemFree(MB)', color='b')
    for tl in ax2.get_yticklabels():
        tl.set_color('b')

    plt.legend()
    #plt.show()

def draw_kmalloc(f):
    kmalloc8192 = run_system("grep kmalloc-8192 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc8192 = np.asarray(kmalloc8192, dtype=int)
    kmalloc4096 = run_system("grep kmalloc-4096 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc4096 = np.asarray(kmalloc4096, dtype=int)
    kmalloc2048 = run_system("grep kmalloc-2048 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc2048 = np.asarray(kmalloc2048, dtype=int)
    kmalloc1024 = run_system("grep kmalloc-1024 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc1024 = np.asarray(kmalloc1024, dtype=int)
    kmalloc512 = run_system("grep kmalloc-512 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc512 = np.asarray(kmalloc512, dtype=int)
    kmalloc256 = run_system("grep kmalloc-256 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc256 = np.asarray(kmalloc256, dtype=int)
    kmalloc128 = run_system("grep kmalloc-128 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc128 = np.asarray(kmalloc128, dtype=int)
    kmalloc64 = run_system("grep kmalloc-64 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc64 = np.asarray(kmalloc64, dtype=int)
    kmalloc192 = run_system("grep kmalloc-192 %s | grep -v \"alloc_calls\"| awk '{print $2}'" %f)
    kmalloc192 = np.asarray(kmalloc192, dtype=int)
    x=np.arange(1, 2*len(kmalloc4096)+1, 2)

    fig,ax1 = plt.subplots()
    #ax1.plot(x, kmalloc4096, label="kmalloc-4096")
    ax1.plot(x, kmalloc256, label="kmalloc-256")
    ax1.plot(x, kmalloc128, label="kmalloc-128")
    ax1.plot(x, kmalloc64, label="kmalloc-64")
    ax1.set_xlabel('uptime')
    ax1.grid(True)
    plt.legend(loc='upper left')

    #plt.show()

def main(argv):
    """Main script entry point. """
    mon_file = None
    opts, args = getopt(argv[1:], "f:",["mon_file="])

    for option, value in opts:
        if option in ("-f", "--mon_file"):
            mon_file = value
        else:
            usage("Unsupported argument %s!" % option)

    draw_unreclaim(mon_file)
    draw_kmalloc(mon_file)

    plt.show()


if __name__ == '__main__':
    main(sys.argv)
