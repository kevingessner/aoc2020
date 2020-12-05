#!/usr/bin/env python3

import sys

def calc(s):
    x = 0
    trees = 0
    for line in s.splitlines():
        if line[x % len(line)] == '#':
            trees += 1
        x += 3
    return trees

if __name__ == '__main__':
    print(calc(sys.stdin.read()))

