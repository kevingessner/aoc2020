#!/usr/bin/env perl

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
}
print "max: $max\n";
