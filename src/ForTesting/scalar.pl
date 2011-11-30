#!/usr/bin/perl
use strict;
use warnings;

my $scalar = "This is a scalar";
my $scalar_ref = \$scalar;

print "Reference: " . $scalar_ref . "\n";
print "Dereferenced: " . ${$scalar_ref} . "\n";
