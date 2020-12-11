#!/usr/bin/env python3

import sys

def calc(s, dx, dy):
    x = 0
    trees = 0
    for i, line in enumerate(s.splitlines()):
        if i % dy == 0:
            if line[x % len(line)] == '#':
                trees += 1
            x += dx
    return trees

if __name__ == '__main__':
    s = sys.stdin.read()
    prod = 1
    for dx, dy in ((1,1), (3,1), (5,1), (7,1), (1,2)):
    #for dx, dy in ((1,2),):
        trees = calc(s, dx, dy)
        prod *= trees
        print(trees)
    print(prod)

