#!/usr/bin/perl

use LWP::Simple;
use POSIX;
use strict;

# Normal mode is to make this a question and answer game, so that nothing
# "unencrypted" is stored on disk.

print "This is the recovery code obfuscator.\n";
print "Please input your codes, as many as you like. When you have no\n";
print "more codes to enter, leave the entry blank. Spaces are taken out\n";
print "in any inputs you make, as are dashes.\n";

my @codes;
while (1) {
    print " Code ".($#codes + 2).": ";
    my $c = <STDIN>;
    $c =~ s/[\s\-]//g;
    if ($c ne "") {
	push @codes, $c;
    } else {
	last;
    }
}

print "You entered ".($#codes + 1)." recovery codes.\n";
for (my $i = 0; $i <= $#codes; $i++) {
    print " Code ".($i + 1).": ".$codes[$i]."\n";
}

print "Analysing codes...\n";
my $hasdigits = 0;
my $hasletters = 0;
my $hascase = 0;
my $hashex = 0;

for (my $i = 0; $i <= $#codes; $i++) {
    if ($codes[$i] =~ m/\d/) {
	$hasdigits = 1;
    }
    if ($codes[$i] =~ m/\D/) {
	$hasletters = 1;
	$hashex = 1;
    }
    if ((lc($codes[$i]) ne $codes[$i]) ||
	(uc($codes[$i]) ne $codes[$i])) {
	$hascase = 1;
    }
    # Check for hex-only letters.
    if ($codes[$i] =~ m/[g-zG-Z]/) {
	$hashex = 0;
    }
}

if ($hashex == 1) {
    # We make everything lower case.
    $hascase = 0;
    for (my $i = 0; $i <= $#codes; $i++) {
	$codes[$i] = lc($codes[$i]);
    }
}

if ($hasdigits == 1) {
    print " Recovery codes contain digits.\n";
}
if ($hasletters == 1) {
    if ($hascase == 1) {
	print " Recovery codes contain case-sensitive letters.\n";
    } else {
	print " Recovery codes contain case-insensitive letters.\n";
    }
    if ($hashex == 1) {
	print "  Recovery codes appear to only contain hexadecimal letters.\n";
    }
}

# Ask for the number to encode with.
my $encode_number = "";

print "Please enter a number with at least ".($#codes + 1)." digits: ";
my $en = <STDIN>;
if ($en ne "") {
    $encode_number = $en;
}
# Remove any decimals.
$encode_number =~ s/\.//g;
# And make it a list of numbers.
my @encoders = split(//, $encode_number);

my $front_padding = 0;
my $end_padding = 0;
print "How many random characters should be added before the code? ";
my $fp = <STDIN>;
print "How many random characters should be added after the code? ";
my $ep = <STDIN>;
if ($fp ne "") {
    $front_padding = POSIX::floor($fp * 1);
}
if ($ep ne "") {
    $end_padding = POSIX::floor($ep * 1);
}

# Now we figure out how many random characters we need.
my $n_req = $front_padding;
for (my $i = 0; $i <= $#codes; $i++) {
    if ($#encoders >= $i) {
	$n_req += $encoders[$i] * 1;
    }
    $n_req += length($codes[$i]);
}
$n_req += $end_padding;

print "The obfuscated code requires ".$n_req." random characters.\n";

# Get the random numbers from random.org.
my $min_number = 0;
my $max_number = 9;
if ($hasletters == 1) {
    if ($hashex == 0) {
	$max_number = 35;
	if ($hascase == 1) {
	    $max_number = 51;
	}
    } else {
	$max_number = 15;
    }
}
if ($hasdigits == 0) {
    $min_number = 10;
}
my $url = sprintf ("https://www.random.org/integers/?num=%d&min=%d&max=%d&col=%d&base=10&format=plain&rnd=new",
		   $n_req, $min_number, $max_number, $n_req);
chomp(my $content = get $url);

# Now split up the returned numbers.
my @randoms = split(/\s+/, $content);

# Replace certain numbers with letters.
my $replacement_string = "abcdefghijlkmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
my @replacements = split(//, $replacement_string);
for (my $i = 0; $i <= $#randoms; $i++) {
    if ($randoms[$i] > 9) {
	$randoms[$i] = $replacements[$randoms[$i] - 10];
    }
}

# Now make the changes in the right places.
my $p = $front_padding;
my @code_positions_start;
my @code_positions_end;
for (my $i = 0; $i <= $#codes; $i++) {
    if ($#encoders >= $i) {
	$p += $encoders[$i] * 1;
    }
    my @codesplit = split(//, $codes[$i]);
    push @code_positions_start, $p + 1;
    for (my $j = 0; $j <= $#codesplit; $j++) {
	$randoms[$p] = $codesplit[$j];
	$p++;
    }
    push @code_positions_end, $p;
}

print "\n\n";
print "Codes appear at positions:\n";
for (my $i = 0; $i <= $#codes; $i++) {
    print "  ".$i.": ".$code_positions_start[$i]." - ".$code_positions_end[$i]."\n";
}
print "\n\nOBFUSCATED CODE BLOCK FOLLOWS\n\n";

# Output with 40 character wide strings. (Needs to be less than 100).
my $linewidth = 40;
my $front_length = POSIX::ceil(log(($#randoms + 1)) / log(10));
printf( "%".$front_length."s | ", " ");
for (my $i = 1; $i <= $linewidth; $i++) {
    printf POSIX::floor($i / 10);
}
print "\n";
printf( "%".$front_length."s | ", " ");
for (my $i = 1; $i <= $linewidth; $i++) {
    print $i % 10;
}
print "\n";
for (my $i = 0; $i < ($front_length + $linewidth + 3); $i++) {
    print "-";
}
print "\n";
for (my $i = 0; $i <= $#randoms; $i++) {
    printf "%0".$front_length."d | ", $i;
    for (my $j = 1; $j <= $linewidth; $j++) {
	print $randoms[$i];
	$i++;
    }
    print "\n";
    $i--; # Because the loop will skip one otherwise.
}
