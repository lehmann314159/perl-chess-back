#!/ramdisk/bin/perl -w

use strict;
use ChessGame;

# This move list moves and captures with each piece type
my @moveList =
(
	"e2", "e4", "d7", "d5",
	"e4", "d5", "c7", "c6",
	"d1", "f3", "d8", "d5",
	"f1", "c4", "d5", "d2",
	"e1", "d2", "e8", "d8",
	"g1", "e2", "c8", "e6",
	"e2", "d4", "e6", "c4",
	"d4", "c6", "b7", "c6",
	"h1", "e1", "c4", "f1",
	"e1", "f1"
);

my $errorString;
my $game = new ChessGame();
while ( @moveList && ! $errorString )
{
	print "moving from $moveList[0] to $moveList[1]\n";
	$errorString = $game->makeMove( shift @moveList, shift @moveList );
	if ( $errorString ) { print "error! $errorString\n"; }
}

print $game->getWhiteArmy()->toString();
print $game->getBlackArmy()->toString();
print $game->generateFenFromArmies();
print " --- FEN string should be...\nrn1k1bnr/p3pppp/2p5/8/8/5Q2/PPPK1PPP/RNB2R2\n";
