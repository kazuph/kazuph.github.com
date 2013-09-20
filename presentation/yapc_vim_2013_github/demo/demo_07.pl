#!/usr/bin/env perl
use strict;
use warnings;
my $sum = 0;
for (1..999) {
    $sum += $_ if $_ % 3 == 0 or $_ % 5 == 0;
}
print $sum;
