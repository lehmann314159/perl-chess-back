#!/ramdisk/bin/perl -w

use strict;
use ChessPawn;

# Get parameters
( @ARGV == 2 ) or die "usage: testPawn.pl position color...\n\n";
my ( $position, $color ) = @ARGV;
my $pawn = new ChessPawn( $position, $color );


print "unit testing for $color pawn at $position...\n";

# Run through the property support methods
print "Property Support Methods\n";
print "\tgetPosition() : " . $pawn->getPosition() . "\n";
print "\tgetColor()    : " . $pawn->getColor() . "\n";
print "\tgetPieceType(): " . $pawn->getPieceType() . "\n";
print "\ttoString()    : " . $pawn->toString() . "\n";

print "\nMovement and Path Methods\n";
my @squareList = ();

# Add every square
foreach my $file ( 1 .. 8 )
{
	foreach my $rank ( 1 .. 8 ) {	push @squareList, $file * 10 + $rank; }
}

foreach my $square ( @squareList )
{
	if ( $pawn->canLegallyMove( $square ) )
	{
		print "\tcan legally move to " . chr( int( $square/ 10 ) + 96 ) .
			$square % 10 . "($square)\n";
		print "\tpath is +";
		print $pawn->getPathToMove( $square );
		print "+\n\n";
	}
}

# Add an enemy piece, and assign it every square on the board to see if it
# can be captured.
my $enemyPawn = new ChessPawn();
$enemyPawn->setColor( ( $pawn->getColor() eq "white" ) ? "black" : "white" );

foreach my $square ( @squareList )
{
	$enemyPawn->setPosition( $square );
	if ( $pawn->canLegallyCapture( $enemyPawn ) )
	{
		print "\tcan legally capture " . $enemyPawn->toString() . "\n"; 
		print "\tpath is +";
		print $pawn->getPathToCapture( $enemyPawn );
		print "+\n\n";
	}
}

