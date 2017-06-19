#!/usr/bin/perl
#-------------------------------------------------------------------------------
# List a binary tree in level order
# Philip R Brenan at gmail dot com, Appa Apps Ltd, 2017
#-------------------------------------------------------------------------------

=pod

List the keys of a binary tree in level order.

In this program, several binary trees are constructed and their keys listed in
level order.  The possible keys are the integers from 1 to 𝗺𝗮𝘅𝗞𝗲𝘆. Duplicate
keys are allowed.

For example the tree, listed with its root on the left and its leaves on the
right:

        |       |       1
        |       2       .
        |       |       3
        4       .       .
        |       |       5
        |       6       .
        |       |       7

will be listed as:

 4 2 6 1 3 5 7

Two methods of listing the 𝗡 keys by level are compared, a slow but memory
efficient method with worst case computational complexity 𝗡² is compared to a
faster method with worst case computational complexity 𝗡*log(𝗡) that uses more
memory.

The difference between the two is most significant on degenerate trees where
the tree has become a linked list. This can be clearly seen in the following
table which shows the decay of the slow method vs the fast method:

  Performance of slow vs fast in seconds
  Height     Fast       Slow
     500        0          2
     600        0          3
     700        0          4
     800        0          7
     900        0         10
    1000        0         13

The full output of this program is reproduced below interspersed between the
tests that generate the output. Or you can run this code yourself immediately
on any modern computer, as there are no dependencies other than Perl itself
which is factory installed on most modern computers these days, even Windows,
via Linux Services for Windows.  So you should be able to enter:

 perl treeTops.pl

at the command line and get:

 Normal finish

upon successful completion or else an error message id something unexpected
happens. Or if you supply a parameter:

 perl treeTops.pl --test

then additional tests will be run to improve confidence in the results above.

=cut

use warnings FATAL => qw(all);                                                  # Strict!
use strict;

my $maxKey = 2**31-1;                                                           # Maximum key: if you change this you must write new tests!

sub Tree(@)                                                                     # Create a tree - supply a list of numbers with which to create the tree
 {package Tree;
  my $tree = bless [];                                                          # Create an empty tree
  $tree->put($_) for @_;                                                        # Insert each supplied key
  $tree                                                                         # Return the tree
 }

=pod

I cannot use recursive methods to construct the sample trees because I
particularly want to test large degenerate trees which will cause "deep
recursion" failures if recursion is used.

Consequently, the two methods below: 𝗽𝘂𝘁() and 𝘁𝗿𝗮𝘃𝗲𝗿𝘀𝗲() are both non
recursive and thus slightly more complex than might otherwise be expected.

Method 𝗧𝗿𝗮𝘃𝗲𝗿𝘀𝗲() is very versatile because it allows the caller to specify a
method to be called against each node of the tree. This approach simplifies the
construction of other methods that would otherwise to have to duplicate their
own tree traversal code as in method 𝗽𝗿𝗶𝗻𝘁() which scans the tree twice, once
to get the depth and maximum key width, then again to lay the tree out in away
that we can easily read in level order.

=cut

sub Tree::put($$)                                                               # Add a numeric key to the tree
 {my ($tree, $key) = @_;                                                        # Tree, key to add
  $key =~ /\A\d+\Z/ or die "Non numeric key: $key";                             # Check the key is a natural number
  $key < $maxKey    or die "Key too big: $key";                                 # Check the key is not too big

  if (@$tree)                                                                   # Insert the new key in a tree which already has entries
   {my ($position) = 0;                                                         # Start at the root
    for(1..@$tree)                                                              # Percolate through tree
     {my ($k, $l, $r) = @{$tree->[$position]};                                  # Current node of tree
      my ($dir, $loc) = $key < $k ? ($l, 1) : ($r, 2);                          # Numeric comparison!
      if ($dir)                                                                 # Go lower
       {$position = $dir;                                                       # New node
       }
      else                                                                      # Create a new node to hold the new key
       {$tree->[$position][$loc] = @$tree;                                      # Set the parent node to reference the new node
        push @$tree, [$key];                                                    # Add the key
        last;
       }
     }
   }
  else                                                                          # Insert the first key in an otherwise empty tree
   {push @$tree, [$key];
   }
 }

sub Tree::traverse($$)                                                          # Traverse the tree in in-order without using recursion which would fail with "deep recursion"
 {my ($tree, $sub) = @_;                                                        # Tree, 𝘀𝘂𝗯 to call at each node in order
  my @position;                                                                 # Use a stack to track position otherwise we will get deep recursion
  my @went;                                                                     # Whether we have explored to the right of this node
  my $position = 0;                                                             # Start at the root node
  for(1..@$tree)                                                                # Traverse
   {my ($key, $left, $right) = @{$tree->[$position]};                           # Current node
    if ($left)                                                                  # As deep as possible on left
     {push @position, $position; push @went, 0;                                 # Save position and the fact that we went left at this point
      $position = $left;                                                        # Go left
      next;
     }
    $sub->($key, @position);                                                    # Call 𝘀𝘂𝗯 to process node as we pass under it
    if ($right)                                                                 # Go right if possible
     {push @position, $position; push @went, 1;                                 # Save position and the fact that we went right at this point
      $position = $right;                                                       # Go right
      next;
     }
    else                                                                        # Back up the tree to an unexplored right hand node
     {for(1..@went)                                                             # Each possible node above us
       {$position = pop @position;                                              # Go up one node
        my $went  = pop @went;                                                  # Whether we have explored to the right from this node
        my ($key, $left, $right) = @{$tree->[$position]};                       # Details of this node
        $sub->($key, @position) if !$went;                                      # Call 𝘀𝘂𝗯 to process a node with no right sub tree as we go up to the right of it
        if ($right and !$went)                                                  # Found a node from which we have not explored to the right
         {push @position, $position; push @went, 1;                             # Save position and the fact that we went right at this point
          $position = $right;                                                   # Go right
          last;                                                                 # The search for the next node has been finished
         }
       }
     }
   }
 }

sub Tree::print($)                                                              # Print a tree so that it can be easily read in level order
 {my ($tree) = @_;                                                              # Tree
  my $depth  = 0;                                                               # Depth of tree
  my $width  = 0;                                                               # Maximum width of any key
  $tree->traverse(sub                                                           # Find depth of tree and maximum key width
   {my ($key, @position) = @_;
    my $d = scalar(@position);                                                  # Depth of this node
    my $w = length($key);                                                       # Width of this key
    $depth = $d if $d > $depth;                                                 # Maximum depth encountered
    $width = $w if $w > $width;                                                 # Maximum width encountered
   });

  my $spacer = '       ';                                                       # Horizontal spacer
  $tree->traverse(sub                                                           # Print the tree with the root on the left and the leaves on the right
   {my ($key, @position) = @_;
    my $d = scalar(@position);                                                  # Depth of this node
    my $s = join '', (($spacer.'|') x            $d), $spacer,                  # Coming down to the node the levels are separated by '|'
                      substr(('|'x$width).$key, -$width),                       # Right justify the key and pad with '|'
         $d < $depth          ?  substr((' '.$spacer.'.'), $width) : '',        # Allow for the width of the key if there are levels below this one
        ($depth - $d - 1) > 0 ? ($spacer.'.') x  ($depth - $d - 1) : '';        # Subsequent levels are separated by '.' if there are any
    say STDERR $s;                                                              # Print a line in the tree
   });
 }

=pod

Slow and fast methods for printing the tree in level order.  The slow method is
simpler to code and thus provides a useful test of the more complex fast
method.

In the worst case for a tree with 𝗡 modes, the slow method will have to
traverse the tree 𝗡 times finding one new level each time. As the tree has 𝗡
elements it will take order of 𝗡² steps to complete. As we are told that the
tree is a binary tree, the slow method can never reach its best performance of
order 𝗡 which occurs when all the nodes are at the same level, i.e. the tree is
an array.

The fast method records the depth and the 'in-order' position of each node by
traversing the tree just once to collect this information which gives rise to
its significantly better performance. The 'in-order' position has higher values
for nodes to the right than the left.  Thus when the nodes are sorted into
level order, the 'in-order' position can be used to ensure that nodes to the
right appear after nodes to the left at the same level in the output list.
Various test cases are coded below to confirm that this the case.

In a tree of 𝗡 nodes the single traverse by the fast method takes order of 𝗡
steps, the subsequent sort takes order of 𝗡*log(𝗡) steps. For large 𝗡: 𝗡*log(𝗡)
dominates 𝗡 and so the computational complexity is 𝗡*log(𝗡) for this method
regardless of the shape of the tree.

=cut

sub Tree::slowListByLevels($;$)                                                 # Space efficient but slow method of listing nodes by level in the tree
 {my ($tree) = @_;                                                              # Tree
  my @levels;
  for my $level(0..@$tree)                                                      # Visit each possible level in-order
   {$tree->traverse(sub                                                         # Traverse the tree
     {my ($key, @position) = @_;
      push @levels, $key if @position == $level;                                # Add this key if it is at the level currently being visited
     });
   }
  @levels                                                                       # Keys in level order
 }

sub Tree::fastListByLevels($;$)                                                 # Fast method of listing nodes by level in the tree
 {my ($tree) = @_;                                                              # Tree
  my @nodes;
  $tree->traverse(sub                                                           # Traverse the tree once gathering results
   {my ($key, @position) = @_;
    push @nodes, [$key, scalar(@position), scalar(@nodes)];                     # Record key, level, position within level
   });
  map {$_->[0]} sort                                                            # Sort results first by level, then by position within level
   {return $a->[2] <=> $b->[2] if $a->[1] == $b->[1];                           # Sort by position if we have two nodes on the same level
           $a->[1] <=> $b->[1]                                                  # Otherwise if the nodes are at different levels, sort just by level
   } @nodes;
 }

=pod

Tests!

Do some basic tests to confirm that the software works as expected on trivial
cases.

=cut

say STDERR "List a tree in level order";                                        # The title of the piece

# Basic tests
if (1)
 {eval{Tree("aaa")};     $@ =~ /Non numeric key: aaa/ or die $@;                # Test checking of input keys
  eval{Tree($maxKey+1)}; $@ =~ /Key too big:/         or die $@;
 }

# Manually computed tests

sub test($$)                                                                    # Construct a tree, lists its nodes by level and die if the expected results are not obtained or if the slow method produces results that differ with teh results from the fast method
 {my ($keys, $keysByLevels) = @_;                                               # Array of numeric keys, array of expected results

  my $tree = Tree(@$keys);                                                      # Construct tree

  my @slow = $tree->slowListByLevels;                                           # Test slow method
  "@slow" eq "@{$keysByLevels}" or die;

  my @fast = $tree->fastListByLevels;                                           # Test fast method
  "@fast" eq "@slow" or die;                                                    # Confirm that fast and slow methods produce the same result
 }

test([1..3], [1..3]);                                                           # Perform manually computed tests
test([qw(4 2 1 3 6 5 7)], [qw(4 2 6 1 3 5 7)]);

=pod

Confirm slow and fast methods produce the same results for a variety of trees

=cut

for([qw(4 2 1 3 6 5 7)], [1..8], [5..9, reverse 1..4],                          # Some sample trees
    [map {int rand(32)} 1..32])
 {my $tree = Tree(@$_);                                                         # Construct a tree
  say STDERR "\n\n";
  say STDERR "Input tree:   ", join ' ', @$_;                                   # Keys used to construct tree
  say STDERR "Slow listing: ", my $slow = join ' ', $tree->slowListByLevels;    # Tree in level order - slow method
  say STDERR "Fast Listing: ", my $fast = join ' ', $tree->fastListByLevels;    # Tree in level order - fast method
  $slow eq $fast or die;                                                        # Check that the results are identical whether we use the slow method or the fast method

  say STDERR ""; $tree->print;                                                  # Print the tree
 }

=pod

Prints:

 List a tree in level order
 Input tree:   4 2 1 3 6 5 7
 Slow listing: 4 2 6 1 3 5 7
 Fast Listing: 4 2 6 1 3 5 7

        |       |       1
        |       2       .
        |       |       3
        4       .       .
        |       |       5
        |       6       .
        |       |       7

 Input tree:   1 2 3 4 5 6 7 8
 Slow listing: 1 2 3 4 5 6 7 8
 Fast Listing: 1 2 3 4 5 6 7 8

        1       .       .       .       .       .       .       .
        |       2       .       .       .       .       .       .
        |       |       3       .       .       .       .       .
        |       |       |       4       .       .       .       .
        |       |       |       |       5       .       .       .
        |       |       |       |       |       6       .       .
        |       |       |       |       |       |       7       .
        |       |       |       |       |       |       |       8

 Input tree:   5 6 7 8 9 4 3 2 1
 Slow listing: 5 4 6 3 7 2 8 1 9
 Fast Listing: 5 4 6 3 7 2 8 1 9

        |       |       |       |       1
        |       |       |       2       .
        |       |       3       .       .
        |       4       .       .       .
        5       .       .       .       .
        |       6       .       .       .
        |       |       7       .       .
        |       |       |       8       .
        |       |       |       |       9

 Input tree:   11 26 10 7 24 9 23 2 2 10 3 25 14 3 14 8 18 19 17 21 24 5 8 17 25 6 26 9 8 6 15 7
 Slow listing: 11 10 26 7 10 24 26 2 9 23 25 2 8 9 14 24 25 3 7 8 14 3 8 18 5 17 19 6 15 17 21 6
 Fast Listing: 11 10 26 7 10 24 26 2 9 23 25 2 8 9 14 24 25 3 7 8 14 3 8 18 5 17 19 6 15 17 21 6

        |       |       |       |2      .       .       .       .       .       .
        |       |       |       |       |2      .       .       .       .       .
        |       |       |       |       |       |3      .       .       .       .
        |       |       |       |       |       |       |3      .       .       .
        |       |       |       |       |       |       |       |5      .       .
        |       |       |       |       |       |       |       |       |6      .
        |       |       |       |       |       |       |       |       |       |6
        |       |       |7      .       .       .       .       .       .       .
        |       |       |       |       |       |7      .       .       .       .
        |       |       |       |       |8      .       .       .       .       .
        |       |       |       |       |       |8      .       .       .       .
        |       |       |       |       |       |       |8      .       .       .
        |       |       |       |9      .       .       .       .       .       .
        |       |       |       |       |9      .       .       .       .       .
        |       10      .       .       .       .       .       .       .       .
        |       |       10      .       .       .       .       .       .       .
        11      .       .       .       .       .       .       .       .       .
        |       |       |       |       14      .       .       .       .       .
        |       |       |       |       |       14      .       .       .       .
        |       |       |       |       |       |       |       |       15      .
        |       |       |       |       |       |       |       17      .       .
        |       |       |       |       |       |       |       |       17      .
        |       |       |       |       |       |       18      .       .       .
        |       |       |       |       |       |       |       19      .       .
        |       |       |       |       |       |       |       |       21      .
        |       |       |       23      .       .       .       .       .       .
        |       |       24      .       .       .       .       .       .       .
        |       |       |       |       24      .       .       .       .       .
        |       |       |       25      .       .       .       .       .       .
        |       |       |       |       25      .       .       .       .       .
        |       26      .       .       .       .       .       .       .       .
        |       |       26      .       .       .       .       .       .       .

Compare slow and fast methods of listing nodes by levels for large degenerate
trees

=cut

say STDERR "\n\n\nPerformance of slow vs fast in seconds";
say STDERR "  Height     Fast       Slow";
for(3..16)
 {last if $_ >= 6 and !$ARGV[0];                                                # Skip longer tests unless testing requested
  my $N = 100 * $_;                                                             # Large tree size.
  my $tree = Tree(1..$N);                                                       # Create a large degenerate tree.
  my $t1 = time();
  my @slow = $tree->slowListByLevels;                                           # Slow listing
  my $t2 = time();                                                              # Time in seconds for slow listing
  my @fast = $tree->fastListByLevels;                                           # Fast listing
  my $t3 = time();                                                              # Time in seconds for fast listing
  "@fast" eq "@slow" or die;                                                    # Confirm that the two methods produce the same results
  say STDERR sprintf("  %6d   %6d     %6d", $N, $t3 - $t2, $t2 - $t1);          # Print timing information
 }

=pod

Prints:

 Performance of slow vs fast in seconds
  Height     Fast       Slow
     100        0          0
     200        0          0
     300        0          1
     400        0          1
     500        0          1
     600        0          2
     700        0          5
     800        0          7
     900        0         10
    1000        0         13
    1100        0         18
    1200        0         23
    1300        0         29
    1400        0         37
    1500        0         46
    1600        0         57

Tomorrow and tomorrow and tomorrow,
Creeps in this petty pace from day to day,
To the last syllable of recorded time.
Macbeth.

=cut

say STDERR "Normal finish";
