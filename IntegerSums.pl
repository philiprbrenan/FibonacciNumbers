#!/usr/bin/perl
#-------------------------------------------------------------------------------
# Count the sums that add up to N with each summand less than 7
# Philip R Brenan at gmail dot com, Appa Apps Ltd, 2017
#-------------------------------------------------------------------------------

=pod

Plausibly 𝗙(3,2) == 3 is the number of sums which add up to 3 with the integers
being summed drawn from the range 1 to 2 as can be seen below:

 3 = 1 + 1 + 1           111
 3 = 2 + 1               011
 3 = 1 + 2               101

Using induction:

 𝗙(4,2) = 𝗙(3,2) + 𝗙(2,2)

because we may add 1 to any of the sums in 𝗙(3,2) and 2 to any of the sums in
𝗙(2,2) to get sums that add up to 4.

As can be seen from the column above on the right, each sum can also be
represented by a binary number, such a number must have a 1 in column 3 and not
contain 2 or more consecutive 0's.  This gives an easy way of computing some
test values for 𝗙(𝗦,𝗻), however, as this method depends on checking 2**(𝗦-1)
sums, this is not practical for large values of 𝗦.

In the file below, we compute 𝗳(𝗦,𝗻) the number of ways to sum to 𝗦 using
numbers in the range 1 to 𝗻 by the method of counting binary numbers. These
results are then used to validate the computations of 𝗙(𝗦,𝗻) which uses the
inductive method to obtain the same results. Some hand computed examples are
listed at the end of this file where they are used to test both methods.

In particular, we are asked to find 𝗙(610,6), computed below as:

  14527490260516100855695859704819627818108010882741117227956927412305738742399171256642436462028811566617818991926058940988565927870172608545709804976244851391054850231415387973537361

That is:

  14527490260516100855695859704819627818108010882741
  11722795692741230573874239917125664243646202881156
  66178189919260589409885659278701726085457098049762
  44851391054850231415387973537361

The length of the above number is 182 in base 10

As the values of 𝗙(𝗦,𝗻) quickly exceed 64 bits, we have to use string
arithmetic rather than binary arithmetic to avoid binary arithmetic overflow
when computing 𝗙(𝗦,𝗻). There are many libraries available for doing string
arithmetic; there are also doubtlessly many libraries that compute 𝗙(𝗦,𝗻)
directly. However, as this is a test, I have written a suitable string
arithmetic library from scratch.

Intermediate results are cached to avoid the expense of recomputing them which
improves performance significantly and avoids the difficulty of dealing with
the "deep recursion" problem as long as we load the cache with smaller
results first.

This Perl program can be run immediately on any modern computer as it has no
special dependencies other than Perl itself. Perl comes ready installed on all
modern systems; even Windows; these days; has Linux services installed and so,
finally: Windows has Perl too. Thus you should be able to enter:

 perl F610.pl

at the command line and get:

 Normal finish

upon successful completion or else an error message id something unexpected
happens. Or if you supply a parameter:

 perl F610.pl --test

then additional tests will be run to improve confidence in the results above.

=cut

use warnings FATAL => qw(all);                                                  # Strict!
use strict;

#===============================
my $theNumberOfInterest   = 610;                                                # The desired sum - that is the question!
my $maximumSummandAllowed =   6;                                                # The sum will be comprise of numbers in the range 1 to 𝗺𝗮𝘅𝗶𝗺𝘂𝗺𝗘𝗹𝗲𝗺𝗲𝗻𝘁𝗔𝗹𝗹𝗼𝘄𝗲𝗱
#===============================
my $performTests = $ARGV[0];                                                    # Run the tests as well if any parameter is supplied

# String arithmetic
sub base() {10}                                                                 # Compute in this base, however you cannot change this to something else and expect things to continue to work normally

my %add;                                                                        # Addition result table for two decimal digits
my %carry;                                                                      # Addition carry  table for two decimal digits

for   my $i(0..base-1)                                                          # Load addition results and carry tables for all combinations of digits
 {for my $j(0..base-1)
   {my $s = $i + $j;                                                            # Add
    $carry{$i}{$j} = $s >= base ?         1 : 0;                                # Carry if results is greater than 10
    $add  {$i}{$j} = $s >= base ? $s - base : $s;                               # Result of addition
   }
 }

sub swapStringNumber($)                                                         # Swap between the string and binary representations of a number - fortunately this is a self inverting operation
 {my ($N) = @_;                                                                 # Number or string to be swapped
  join '', reverse split //, $N;
 }

sub add($$)                                                                     # Add two numbers and return their sum using string arithmetic
 {my ($A, $B) = @_;                                                             # First number, second number to add

  my $a = swapStringNumber $A;
  my $b = swapStringNumber $B;
  my $na = length($a);                                                          # Pad the shorter number with zeros to match the length of the longer number. We could improve performance by optimising around 0+n == n
  my $nb = length($b);

  if ($na > $nb)                                                                # Pad with zeroes to equalise the lengths of the numbers to be added
   {my $l = $na - $nb;
    substr($b, $nb, $l) = '0'x$l;                                               # Pad 𝗯 to the length of 𝗮
   }
  elsif ($nb > $na)
   {my $l = $nb - $na;
    substr($a, $na, $l) = '0'x$l;                                               # Pad 𝗮 to the length of 𝗯
   }

  length($a) == length($b) or die;                                              # Confirm that we have equal length numbers

  my $carry = 0;                                                                # Whether we currently have a carry or not
  my $sum   = '';                                                               # The sum so far
  for my $i(0..length($a)-1)                                                    # Add each pair of digits starting with the least significant pair
   {my $A = substr($a, $i, 1);                                                  # Digit from 𝗮
    my $B = substr($b, $i, 1);                                                  # Digit from 𝗯
    my $r = $add  {$A}{$B};                                                     # Result of addition
    my $c = $carry{$A}{$B};                                                     # Carry required
    $r++ if $carry;                                                             # Add carry
    substr($sum, $i, 1) = $r >= base ? $r - base : $r;                          # Add to 𝘀𝘂𝗺
    $carry = $c || $r >= base;                                                  # The worst case is 9+9+1 == 19 so the carry is never more than 1
   }

  $sum .= 1 if $carry;                                                          # Push final carry if present
  swapStringNumber $sum                                                         # Return sum
 }

sub formatALongString($$$)                                                      # Format a long string to fit it legibly upon a page
 {my ($string, $width, $indent) = @_;                                           # String to be formatted, width of output, indentation
  my $l = ' ' x $indent;                                                        # Indent with spaces
  my $s = $l;                                                                   # Formatted results
  my $i = 0;                                                                    # Position in input string
  for(split //, $string)                                                        # Each character of the input string
   {$s .= $_;                                                                   # Save character
    $s .= "\n$l" if ++$i % $width == 0;                                         # Add a new line and indebt if necessary
   }
  $s =~ s/\s*\Z//gsr                                                            # Remove any trailing white space to normalise the string
 }

# By counting binary numbers
sub f($$)                                                                       # Find the number of possible sums by counting binary numbers
 {my ($sum, $max) = @_;                                                         # The total to sum to, the maximum number that can be included in the sum.
  my $S = $sum - 1;                                                             # Width if the numbers to count excluding the final column which is always '1'
  my $N = 2 ** $S;                                                              # Number of sums to check
  my $z = '0' x $max;                                                           # Exclude numbers that have this many consecutive '0's
  my $c = 0;                                                                    # Count the number of sums
  for(0..$N-1)                                                                  # Check each binary number
   {my $s = sprintf("%0.*b", $S, $_);                                           # Format the number in binary
    ++$c if index($s, $z) < 0;                                                  # Include the number if it does not have too many consecutive '0's
   }
  $c                                                                            # Return number of sums
 }

# By induction
my %f;                                                                          # Cache prior results to greatly speed up the computation and avoid "deep recursion"
sub F($$);                                                                      # Forward declare signature as this routine is recursive

sub F($$)                                                                       # Find the number of possible sums using induction
 {my ($sum, $max) = @_;                                                         # The total to sum to, the maximum number that can be included in the sum.
  return $f{$sum}{$max} = 0 if $sum  < 0;                                       # Easy cases
  return $f{$sum}{$max} = 1 if $sum == 0;                                       # The induction starts at this value by inspection
  return $f{$sum}{$max} if defined $f{$sum}{$max};                              # Return previously computed result
  my $c = 0;                                                                    # Count of the number of possible sums
  for my $begin(1..$max)                                                        # Sum the possible sums
   {$c = add($c, F($sum - $begin, $max));                                       # Update total - we rely on the cache for prior values to avoid deep recursion
   }
  $f{$sum}{$max} = $c                                                           # Cache the result and return it
 }

sub numberOfSums($$)                                                            # Compute the number of possible sums
 {my ($sum, $max) = @_;                                                         # The total sum required, the summands 1..𝗺𝗮𝘅 allowed to contribute to the total
  F($_, $max) for 1..$sum;                                                      # Compute all the smaller results to load the cache
  F($sum, $max)                                                                 # Return the desired result
 }

=pod

Compute the number of interest

=cut

if (1)                                                                          # Compute the number of interest
 {say STDERR <<END;
The number of sums that add up to $theNumberOfInterest using numbers selected from 1..$maximumSummandAllowed is:
END
  my $r = numberOfSums($theNumberOfInterest, $maximumSummandAllowed);           # The supplied numbers
  my $R = formatALongString($r, 50, 2);                                         # Format the string so it is legible
  my $b = base;                                                                 # Arithmetic base we are using
  my $l = length($r);                                                           # Length of the result
  say STDERR <<END;

  $r

That is:

$R

The length of the above number is $l in base $b
END

# Check result
  $r eq "14527490260516100855695859704819627818108010882741117227956927412305738742399171256642436462028811566617818991926058940988565927870172608545709804976244851391054850231415387973537361"
    or die "Wrong result";                                                      # Compare using 𝗲𝗾 as == will fail on such a large number

  length($r) == 182 or die "Wrong length";

 }

=pod

Test hand computed cases using 𝗳(𝗻)

=cut

sub title($) {my $L = 64; print STDERR substr($_[0].(' ' x $L), 0, $L)}         # Print the title of a test
sub confirm  {say STDERR " - Success"}                                          # Confirm test completed successfully

title "Test on manually computed values";

f(1, 1) eq 1 or die; # 1 = 1
f(2, 1) eq 1 or die; # 2 = 1 + 1
f(3, 1) eq 1 or die; # 3 = 1 + 1 + 1
f(4, 1) eq 1 or die; # 4 = 1 + 1 + 1 + 1
f(1, 2) eq 1 or die; # 1 = 1 + 1
f(2, 2) eq 2 or die; # 2 = 1 + 1; 2
f(3, 2) eq 3 or die; # 3 = 1 + 1 + 1; 1 + 2; 2 + 1
f(4, 2) eq 5 or die; # 4 = 1 + 1 + 1 + 1; 2 + 1 + 1; 1 + 2 + 1; 1 + 1 + 2; 2 + 2
f(1, 3) eq 1 or die;
f(2, 3) eq 2 or die;
f(3, 3) eq 4 or die; # 3 = 1 + 1 + 1; 2 + 1; 1 + 2; 3
f(4, 3) eq 7 or die; # 4 = 1 + 1 + 1 + 1; 2 + 1 + 1; 1 + 2 + 1; 1 + 1 + 2; 2 + 2; 3 + 1; 1 + 3
f(4, 4) eq 8 or die;

confirm;

=pod

Check that 𝗙(𝗦,𝗻) == 𝗳(𝗦,𝗻) for small 𝗦

=cut

if ($performTests)
 {print STDERR "Test induction versus counting";
  for my $s(1..17)
   {for my $n(1..$s)
     {f($s, $n) == F($s, $n) or die "s=$s n=$n";
     }
    print STDERR '..';
   }
  confirm;
 }

=pod

Test string arithmetic

=cut

if ($performTests)                                                              # Test string arithmetic
 {title "Test string arithmetic";
  for   my $i(0..100)
   {for my $j(0..100)
     {$i + $j eq add($i, $j) or die "i=$i j=$j";
     }
   }
  confirm
 }

=pod

Test format a long string - necessary because otherwise one's hard work above
could be misrepresented upon output and thereby "lose the name of action" -
Hamlet.

=cut

title "Test formatALongString()";

formatALongString("", 1, 1) eq "" or die;

formatALongString("123", 1, 0) eq <<END =~ s/\n\Z//gsr or die;
1
2
3
END

formatALongString("1122334", 2, 2) eq <<END =~ s/\n\Z//gsr or die;
  11
  22
  33
  4
END

formatALongString("11223344", 2, 2) eq <<END =~ s/\n\Z//gsr or die;
  11
  22
  33
  44
END

confirm;

=pod

Confirm that 𝗙(𝗻,𝗻-1) is odd and that 𝗙(𝗻, 𝗻) is even as expected for a range
of values

=cut

if ($performTests)
 {print STDERR "Test odd/even ";

  my $N = 1e2;                                                                  # Number of tests
  for my $i(2..$N)                                                              # Each test
   {my $m = numberOfSums($i, $i-1);
    my $n = numberOfSums($i, $i);
    substr($m, -1) =~ /[13579]/ or die;
    substr($n, -1) =~ /[02468]/ or die;
    print STDERR '.' unless $i % 2;
   }
  confirm
 }

say STDERR "Normal finish";
