#!/usr/bin/perl

use strict;

# This script is here to help you work out where you put your codes.

print "This is the recovery code obfuscator position calculator.\n";
print "Please answer the following questions, and this script will tell\n";
print "you where your codes should be in your obfuscated block.\n";

print "\nHow many codes did you enter? ";
chomp(my $ncodes = <STDIN>);

print "\nHow long is each code? ";
chomp(my $codelength = <STDIN>);

print "\nWhat was your special number? ";
chomp(my $encodenumber = <STDIN>);

print "\nHow many random digits at the start? ";
chomp(my $randomstart = <STDIN>);

my $p = $randomstart * 1;
$encodenumber =~ s/\.//g;
my @encoders = split(//, $encodenumber);

print "\n\nCODE POSITIONS FOLLOW\n\n";
for (my $i = 0; $i < $ncodes; $i++) {
    if ($#encoders >= $i) {
	$p += $encoders[$i] * 1;
    }
    my $code_start = $p + 1;
    $p += $codelength;
    my $code_end = $p;
    print " Code ".($i + 1).": positions ".$code_start." - ".$code_end."\n";
}
