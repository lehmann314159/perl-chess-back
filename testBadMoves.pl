#!/ramdisk/bin/perl -w

use strict;
use ChessGame;

# This move list tries to move all piece types badly.
# Each piece type will try to move through other pieces and illegally.
my @moveList =
(
	"e2", "e4", "d7", "d5",
	"e4", "d5", "c7", "c6",
	"d5", "c6", "a7", "a5",
	"c6", "b7", "a8", "a4",
	            "a8", "b4",
	            "b8", "b5",
	            "c8", "a6",
	            "c8", "c6",
	            "d8", "d1",
				"d8", "e3",
	            "e8", "e7",
				"e8", "c6"
);

my $errorString;
my $game = new ChessGame();
while ( @moveList )
{
	print "moving from $moveList[0] to $moveList[1]\n";
	$errorString = $game->makeMove( shift @moveList, shift @moveList );
	if ( $errorString ) { print "error! $errorString\n"; }
}
