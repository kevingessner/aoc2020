<?php

function do_loops($pubkey, $loops) {
    $quot = 20201227;
    $val = 1;
    for (; $loops > 0; $loops--) {
        $val *= $pubkey;
        $val %= $quot;
    }
    return $val;
}

function find_loops($pubkey) {
    $subj = 7;
    $calc = 1;
    $quot = 20201227;
    $val = 1;
    $loops = 0;

    while ($val != $pubkey) {
        $val *= $subj;
        $val %= $quot;
        $loops++;
    }
    print "found $val in $loops\n";
    return $loops;
}

$pk1 = $argv[1];
$l1 = find_loops($pk1);
$pk2 = $argv[2];
$l2 = find_loops($pk2);
$k1 = do_loops($pk1, $l2);
$k2 = do_loops($pk2, $l1);
print "$k1 $k2";
