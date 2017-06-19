#!/usr/bin/perl
#-------------------------------------------------------------------------------
# Question 1: 𝗙(𝗻) == 𝗙(𝗻-1) + 𝗙(𝗻-2) where 𝗙(1) == 1 and 𝗙(0) == 0
# Philip R Brenan at gmail dot com, Appa Apps Ltd, 2017
#-------------------------------------------------------------------------------

=pod

We are asked to find:

 𝗙(8181)

where 𝗙(𝗻) is defined by the recurrence relation:

 𝗙(𝗻) == 𝗙(𝗻-1) + 𝗙(𝗻-2)
 𝗙(1) == 1
 𝗙(0) == 0

The sequence is summed using strings to represent the numbers in question as
binary arithmetic overflows beyond 𝗙(93) on a 64 bit computer.

Binary arithmetic is used in 𝗳(𝗻) to compute the first few values until binary
arithmetic overflow prevents further progress. These test results are used to
validate the the hand calculated examples and some of the results from 𝗙(𝗻)
which is then used to calculate the actual number in question.

𝗙(8181) is computed below as:

  239001090710360059034248200673803309562195124933438825088385870209105768309267224930066773271004303009695857056812050426322722227488483596969330539198412751609689113829755775066752844437629935556689908621747058520170917953833076673228939285877150494526386620300621280749499924952199516712960736433814553231958282333619656314497995824452475174641352224677997408976231194557854106641619031011172157654286916061043356523159334857136487352779804235483277506977454306460042287968212874761824582897118739286429568840003151050106146828835563160817912048376040050029809912293013734791567749471727392937824065261113177259783202662957881148637632338195187490758787735996699022778723575367214258563034452504094360966531897568256418608645465915444745840473934322871426418866598642747848660145342643755366760919516317387477526541252807114293921792114970905075434450564838742451198888345673434700068960962172644679947794329807611771708249033661865248799511661306285140477533559743999464574932871122125066107105911374614630965320293086278694399936369060752395531165804412176996135810584035128447884802662630006754418904791563798389799016017336123177492245220148295507234160487497059285034564989541608419857951981398972834439558266427410836592525389894745439937417033358839088886819050208294080514041113275997534122520735761635971975621605403703050984275628628811283403426936742851082726036123336764016240562071825096262121405587203818756266733130406345518134166312225673215071500009165695469591411166981267241101113735558997083171850461315680070428706983814819412637005375477590183910679020180492817106735246177201410250973608332090435177967936901320342366183865669056306257798108871942566285065496557591483743343454453933506

That is:

  23900109071036005903424820067380330956219512493343
  88250883858702091057683092672249300667732710043030
  09695857056812050426322722227488483596969330539198
  41275160968911382975577506675284443762993555668990
  86217470585201709179538330766732289392858771504945
  26386620300621280749499924952199516712960736433814
  55323195828233361965631449799582445247517464135222
  46779974089762311945578541066416190310111721576542
  86916061043356523159334857136487352779804235483277
  50697745430646004228796821287476182458289711873928
  64295688400031510501061468288355631608179120483760
  40050029809912293013734791567749471727392937824065
  26111317725978320266295788114863763233819518749075
  87877359966990227787235753672142585630344525040943
  60966531897568256418608645465915444745840473934322
  87142641886659864274784866014534264375536676091951
  63173874775265412528071142939217921149709050754344
  50564838742451198888345673434700068960962172644679
  94779432980761177170824903366186524879951166130628
  51404775335597439994645749328711221250661071059113
  74614630965320293086278694399936369060752395531165
  80441217699613581058403512844788480266263000675441
  89047915637983897990160173361231774922452201482955
  07234160487497059285034564989541608419857951981398
  97283443955826642741083659252538989474543993741703
  33588390888868190502082940805140411132759975341225
  20735761635971975621605403703050984275628628811283
  40342693674285108272603612333676401624056207182509
  62621214055872038187562667331304063455181341663122
  25673215071500009165695469591411166981267241101113
  73555899708317185046131568007042870698381481941263
  70053754775901839106790201804928171067352461772014
  10250973608332090435177967936901320342366183865669
  05630625779810887194256628506549655759148374334345
  4453933506

The length of the above number is 1710 in base 10

This Perl code should work immediately on any modern computer as there are no
dependencies other than Perl itself. Perl comes ready installed on all modern
systems these days; even Windows has Linux services available and so finally:
Windows has Perl too. Thus you should be able to enter:

 perl Q1-Brenan-Philip-R.pl

at the command line and get:

 Normal finish

upon successful completion or else an error message id something unexpected
happens. Or if you supply a parameter:

 perl Q1-Brenan-Philip-R.pl --test

then additional tests will be run to improve confidence in the results above.

=cut

use warnings FATAL => qw(all);                                                  # Strict!
use strict;

#==============================
my $theNumberOfInterest = 8181;                                                 # The number for which we want 𝗙(𝗻) - that is the question!
#==============================
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
 {my ($N) = @_;
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


# Binary arithmetic version
sub f                                                                           # Compute 𝗙(𝗻) using binary arithmetic
 {my ($n) = @_;
  return 0 if $n <= 0;                                                          # Easy cases
  return 1 if $n <= 1;
  my $a = 0;
  my $b = 1;
  my $sum = 0;
  for(2..$n)                                                                    # Succeeding values
   {$sum = $b + $a;
    $a = $b; $b = $sum;
   }
  $sum                                                                          # Return result of binary arithmetic computation
 }

# String arithmetic version
sub F                                                                           # Compute 𝗙(𝗻) using string arithmetic
 {my ($n) = @_;
  return 0 if $n <= 0;                                                          # Easy cases
  return 1 if $n <= 1;
  my $a = 0;
  my $b = 1;
  my $s = 0;
  for(2..$n)                                                                    # Succeeding values
   {$s = add($a, $b);
    $a = $b; $b = $s;
   }
  $s                                                                            # Return result of string arithmetic computation
 }

=pod

Compute the number in question!

=cut

if (1)
 {say STDERR "𝗙($theNumberOfInterest) is:";
  my $r = F($theNumberOfInterest);                                              # The supplied number
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
  $r eq "239001090710360059034248200673803309562195124933438825088385870209105768309267224930066773271004303009695857056812050426322722227488483596969330539198412751609689113829755775066752844437629935556689908621747058520170917953833076673228939285877150494526386620300621280749499924952199516712960736433814553231958282333619656314497995824452475174641352224677997408976231194557854106641619031011172157654286916061043356523159334857136487352779804235483277506977454306460042287968212874761824582897118739286429568840003151050106146828835563160817912048376040050029809912293013734791567749471727392937824065261113177259783202662957881148637632338195187490758787735996699022778723575367214258563034452504094360966531897568256418608645465915444745840473934322871426418866598642747848660145342643755366760919516317387477526541252807114293921792114970905075434450564838742451198888345673434700068960962172644679947794329807611771708249033661865248799511661306285140477533559743999464574932871122125066107105911374614630965320293086278694399936369060752395531165804412176996135810584035128447884802662630006754418904791563798389799016017336123177492245220148295507234160487497059285034564989541608419857951981398972834439558266427410836592525389894745439937417033358839088886819050208294080514041113275997534122520735761635971975621605403703050984275628628811283403426936742851082726036123336764016240562071825096262121405587203818756266733130406345518134166312225673215071500009165695469591411166981267241101113735558997083171850461315680070428706983814819412637005375477590183910679020180492817106735246177201410250973608332090435177967936901320342366183865669056306257798108871942566285065496557591483743343454453933506"
    or die "Wrong result";                                                      # Compare using 𝗲𝗾 as == will fail on such a large number

  length($r) == 1710 or die "Wrong length";
 }

=pod

Interestingly, 𝗙(2202) is the first number to contain '7'x7:

  69390310093872439672134102723573849345598246054145
  16983667413327162679650430996347857120830131966673
  73187039675474445077533440882290235539672584487204
  19987773180320919440580596401435096589744650772847
  08150412695089656310064057777777365014001541044775
  25219866113622022776948159751748351237800000045478
  58046976946166069255360315321688005311894731902270
  61872079300348872064192676122327755047641410845663
  83210128373058008914954829565841179027778790956126
  7003609976

Find 𝗙(𝗻) with the longest run of consecutive equal digits
with 𝗻 in the specified range

=cut

if (0)
 {say STDERR formatALongString(F(2202), 50, 2);
 }

if (0)                                                                          # Search for the longest run of identical digits
 {my $N = 1e4;
  my $bestDigit;
  my $bestLength;
  my $bestInput;
  say STDERR "Input  Digit  Length    F(Input)";
  for my $i(1..$N)
   {my $result = F($i);
    for my $d(0..9)
     {next if index($result, $d) < 0;
      my $s = $result =~ s/$d/D/gsr =~ s/[0-9]/ /gsr;
      my @s = sort {length($b) <=> length($a)} split /\s+/, $s;
      my $b = length($s[0]);
      if (!$bestLength or $b > $bestLength)
       {$bestDigit  = $d;
        $bestLength = $b;
        $bestInput  = $i;
       }
     }
    say STDERR sprintf("%6d    %2d      %2d    ", $i, $bestDigit, $bestLength); # Print best result so far
   }
 }

=pod

Test string arithmetic

=cut

sub title($) {my $L = 64; print STDERR substr($_[0].(' ' x $L), 0, $L)}         # Print the title of a test
sub confirm  {say STDERR " - Success"}                                          # Confirm test completed successfully

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

Test simple values

=cut

title "Test precomputed small values";

F(0) eq 0 or die;                                                               # Hand computed tests to validate results
F(1) eq 1 or die;
F(2) eq 1 or die;
F(3) eq 2 or die;
F(4) eq 3 or die;
F(5) eq 5 or die;

F(93) eq 12200160415121876738 or die;
length(F(93)) == 20 or die;                                                     # 20 decimal digits approximately 3.3 * 20 = 66 bits +-3 bits so failure expected near here using binary arithmetic on a 64 bit computer

F(16) eq 987        or die;                                                     # Test 𝗙(𝗻) using some values computed by 𝗳(𝗻)
F(20) eq 6765       or die;
F(23) eq 28657      or die;
F(24) eq 46368      or die;
F(25) eq 75025      or die;
F(47) eq 2971215073 or die;

confirm;

=pod

Compare binary arithmetic with string arithmetic

=cut

title "Test binary arithmetic versus string arithmetic";

for(0..93)                                                                      # Test cases that can be computed in binary arithmetic to confirm that string arithemtic works well
 {F($_) eq f($_) or die "Failed on $_";                                         # Compare results of each method
 }

confirm;

=pod

Test format a long string - necessary because otherwise one's hard work above
could be misrepresented upon output and "Thus the native hue of resolution is
sickled o'er with the pale cast of thought" - Hamlet.

=cut

if ($performTests)
 {title "Test formatALongString()";
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
  confirm
 }

=pod

Test values computed earlier by 𝗙(𝗻) and believed to be correct: useful for
testing enhancements

𝗡𝗕: always use string 𝗲𝗾 to compare results computed with string arithmetic
rather than using == because == will fail to compare large numbers and yet fail
to report the failure. "And enterprises, of great pith and moment, in this
regard, their currents turn awry and lose the name of action" - Hamlet.

=cut

if (0)                                                                          # Compute values of 𝗙 used below
 {for(1..20)
   {my $i = 100*$_;
    my $n = F($i);
    say STDERR "F($i) eq \"$n\" or die;";
   }
 }

if ($performTests)
 {title "Test precomputed larger values                 ";

  F( 100) eq "354224848179261915075" or die;
  F( 200) eq "280571172992510140037611932413038677189525" or die;
  F( 300) eq "222232244629420445529739893461909967206666939096499764990979600" or die;
  F( 400) eq "176023680645013966468226945392411250770384383304492191886725992896575345044216019675" or die;
  F( 500) eq "139423224561697880139724382870407283950070256587697307264108962948325571622863290691557658876222521294125" or die;
  F( 600) eq "110433070572952242346432246767718285942590237357555606380008891875277701705731473925618404421867819924194229142447517901959200" or die;
  F( 700) eq "87470814955752846203978413017571327342367240967697381074230432592527501911290377655628227150878427331693193369109193672330777527943718169105124275" or die;
  F( 800) eq "69283081864224717136290077681328518273399124385204820718966040597691435587278383112277161967532530675374170857404743017623467220361778016172106855838975759985190398725" or die;
  F( 900) eq "54877108839480000051413673948383714443800519309123592724494953427039811201064341234954387521525390615504949092187441218246679104731442473022013980160407007017175697317900483275246652938800" or die;
  F(1000) eq "43466557686937456435688527675040625802564660517371780402481729089536555417949051890403879840079255169295922593080322634775209689623239873322471161642996440906533187938298969649928516003704476137795166849228875" or die;
  F(1100) eq "34428592852410271940083613070919630635781894724017874396545964292826864597491403229723364359749415183436491553996529359881593653825629442519718308678951540824183325844045884746598230684751416672062124540392876245684047939604503325" or die;
  F(1200) eq "27269884455406270157991615313642198705000779992917725821180502894974726476373026809482509284562310031170172380127627214493597616743856443016039972205847405917634660750474914561879656763268658528092195715626073248224067794253809132219056382939163918400" or die;
  F(1300) eq "21599680283161715807847052066540433422883515772119658063766498972503219104278316186542706552263614678844605521205471865945806520838603391933189946547621953603163789045147079719349493433360218263689302235202664706161893962580201172846238976101277970849319269574650368333475" or die;
  F(1400) eq "17108476902340227241249719513231821477382749898026920041550883749834348017250935801359315038923367841494936038231522506358371361016671790887791259870264957823133253627917432203111969704623229384763490617075388642696139893354058660570399927047816296952516330636633851111646387885472698683607925" or die;
  F(1500) eq "13551125668563101951636936867148408377786010712418497242133543153221487310873528750612259354035717265300373778814347320257699257082356550045349914102924249595997483982228699287527241931811325095099642447621242200209254439920196960465321438498305345893378932585393381539093549479296194800838145996187122583354898000" or die;
  F(1600) eq "10733451489189611103121609043038710477166925241925645413424099370355605456852169736033991876014762808340865848447476173426115162172818890323837138136782951865054538417494035229785971002587932638902311416018904156170269354720460896363558168129004231138415225204738582550720791061581463934092726107458349298577292984375276210232582438075" or die;
  F(1700) eq "8501653935514177120246392248625833924052052390491381030300605977750345588982825628424071479174753549360050542305550855066813804919653208931716726270523366654632196914963456017388482153512031453762253405647846054195256306803128353238958271508645704380482264873664932470684902865035316770576841658424488971423774980675657727215724203704712303499875347712525" or die;
  F(1800) eq "6733912172802933472606353001846945074658287378884326089477601632746080275952604203199580265153593862390858117766432295498560989719530281829452850286454536277301941625978000791367655413469297462257623927534855511388238610890658838439857922737938956952361558179389004339772497124977152035343580348215676156404424782380266118900316342135562815217465023272599528784782167145877600" or die;
  F(1900) eq "5333735470177196739708654380013216364182711606231750028692155598599810955874132791398352277818697705852238294681640540003099177608752396895596802978549351480795061056237106714875097510390814693260599058125376898729211167801038969363574832655129782312934864836052394362613749572576206467264763038030296298813969690740057870184219763032388920988134497081981723092930599196773940722440994526411542675" or die;
  F(2000) eq "4224696333392304878706725602341482782579852840250681098010280137314308584370130707224123599639141511088446087538909603607640194711643596029271983312598737326253555802606991585915229492453904998722256795316982874482472992263901833716778060607011615497886719879858311468870876264597369086722884023654422295243347964480139515349562972087652656069529806499841977448720155612802665404554171717881930324025204312082516817125" or die;
  say STDERR " - Success";
 }

=pod

Confirm that F(𝗻*100) is divisible by  5 for a range of values
Confirm that F(𝗻*300) is divisible by 10 for a range of values

=cut

if ($performTests)
 {print STDERR "Test divisibility by  5 ";
  for my $i(1..40)
   {substr(F(100*$i), -1) =~ /0|5/ or die;
    print STDERR '.';
   }
  confirm;

  print STDERR "Test divisibility by 10 ";
  for my $i(1..10)
   {substr(F(300*$i), -1) =~ /0/   or die;
    print STDERR '....';
   }
  confirm
 }

=pod

Check that each digit occurs approximately the same number of times on a range
of inputs matching the expected result that the digits are distributed randomly.

The code below prints:

 Digit       Count     Variance%
     0       10474       -0.0095
     1       10696        2.1098
     2       10495        0.1909
     3       10476        0.0095
     4       10431       -0.4200
     5       10516        0.3914
     6       10433       -0.4010
     7       10576        0.9642
     8       10350       -1.1933
     9       10303       -1.6420

=cut

if ($performTests)                                                              # Check digit distribution
 {print STDERR "Test digit distribution ";

  my $N = 1e3;                                                                  # Number of tests
  my %d;                                                                        # Digit counts
  for my $i(1..$N)                                                              # Each test
   {$d{$_}++ for split //, F($i);                                               # Each digit in each test
    print STDERR '.' unless $i % 25;
   }

  my $digits = 0; $digits +=  $_ for values %d;                                 # Total number of digits
  my $average = $digits / base;
  $_ > 0.975 * $average and $_ < 1.025 * $average or die for values %d;         # Check number of occurrences of each digit lies in the expected range

  confirm;

  say STDERR "Digit       Count     Variance%";                                               # Table of results
  for(sort keys %d)
   {say STDERR sprintf("%5d  %10d    %10.4f", $_, $d{$_}, 100*($d{$_} / $average - 1));
   }
 }

say STDERR "Normal finish";
