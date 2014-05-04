#!/ramdisk/bin/perl -w

use strict;
use ChessPiece;

my $position = "e2";
my $norm = ChessPiece::normalize( $position );
my $normnorm = ChessPiece::normalize( $norm );
$position = ChessPiece::sanitize( $norm );
print "$position -- $norm -- $normnorm\n";
