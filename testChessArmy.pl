#!/ramdisk/bin/perl -w

use strict;
use ChessArmy;

my $whiteArmy = new ChessArmy( "white" );
my $blackArmy = new ChessArmy( "black" );

$whiteArmy->setStartingPosition();
$whiteArmy->movePiece( "e2", "e4" );
$blackArmy->movePiece( "e7", "e5" );
$whiteArmy->movePiece( "e4", "d5" );

print $whiteArmy->toString();
