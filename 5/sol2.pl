#!/usr/bin/env perl
'use strict';

sub decode {
    my $fb = shift(@_);
    $fb =~ y/FBLR/0101/;
    return oct("0b" . $fb);
}

my $max = 0;
while (<>) {
    $num = decode($_);
    print "$num\n";
    if ($num > $max) {
        $max = $num;
    }
    push @nums, $num;
}
print "max: $max\n";
@nums = sort {$a <=> $b} @nums;
$last = @nums[0];
foreach $num (@nums) {
    if ($num != $last + 1) {
        print "you are $last + 1\n";
    }
    $last = $num;
}
