#!perl -w

use strict;

use Test::More tests => 16;
use Test::Exception;
use List::Util qw(max);

use Array::GroupBy qw(igroup_by str_row_equal);

#
# One-dimensional array
#

# String array

my $a1 = [ 'alpha' x 5 ];
my $a2 = [ 'beta' x 7 ];
my $a3 = [ 'charlie' x 2 ];
my $a4 = [ 'alpha' x 3 ];

my $data = [ @$a1, @$a2, @$a3, @$a4 ];

# result
my @r = ( $a1, $a2, $a3, $a4 );

my $iter = igroup_by(
                    data    => $data,
                    compare => sub { $_[0] eq $_[1] },
);

my $i = 0;
while (my $v = $iter->()) {
  is_deeply($v, shift @r, "text array test $i");
  $i++;
}

# Numeric array

my $n1 = [ 1, 1, 1.0     ];
my $n2 = [ 4.5, 4.50     ];
my $n3 = [ 0.2, .2, .200 ];
my $n4 = [ 1, 1.000, 1.0 ];

$data = [ @$n1, @$n2, @$n3, @$n4 ];

# results
@r = ( $n1, $n2, $n3, $n4 );

$iter = igroup_by(
                data    => $data,
                compare => sub { $_[0] == $_[1] },
);

$i = 0;
while (my $v = $iter->()) {
  is_deeply($v, shift @r, "numeric array test $i");
  $i++;
}

#
# call errors
#

throws_ok {
igroup_by( compare => sub { $_[0] == $_[1] });
          } qr/Mandatory parameter 'data' missing in call to/,
            '"data => ..." argument missing in igroup_by() call';

throws_ok {
igroup_by( data => $data );
          } qr/Mandatory parameter 'compare' missing in call to/,
            '"compare => ..." argument missing in igroup_by() call';

throws_ok {
igroup_by( xx_data    => $data, compare => sub { $_[0] == $_[1] });
          } qr/validation options: xx_data/,
            'name of argument wrong in igroup_by() call';

throws_ok {
igroup_by( data => $data, compare => 'axolotl' );
          } qr/The 'compare' parameter.*was a 'scalar'.*types: coderef/,
            'compare => not a coderef in igroup_by() call';

throws_ok {
igroup_by( data => $data, compare => sub {}, extra => 0 );
          } qr/The.*parameter.*not listed.*: extra/,
            'extra parameter in igroup_by() call';

throws_ok {
igroup_by( data => [], compare => sub {}, );
          } qr/The array passed to igroup_by.*is empty/,
            'empty array passed to igroup_by()';

throws_ok {
igroup_by( data => undef, compare => sub {}, );
          } qr/The 'data' parameter.*was an 'undef'/,
            "undef 'data' parameter";

throws_ok {
igroup_by( data => $data, compare => undef );
          } qr/The 'compare' parameter.*was an 'undef'/,
            "undef 'compare' parameter";
