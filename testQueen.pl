#!/ramdisk/bin/perl -w

use strict;
use ChessQueen;
use ChessPiece;

# Get parameters
( @ARGV == 2 ) or die "usage: testQueen.pl position color...\n\n";
my ( $position, $color ) = @ARGV;
my $queen = new ChessQueen( $position, $color );


print "unit testing for $color queen at $position...\n";

# Run through the property support methods
print "Property Support Methods\n";
print "\tgetPosition() : " . $queen->getPosition() . "\n";
print "\tgetColor()    : " . $queen->getColor() . "\n";
print "\tgetPieceType(): " . $queen->getPieceType() . "\n";
print "\ttoString()    : " . $queen->toString() . "\n";

print "\nMovement and Path Methods\n";
my @squareList = ();

# Add every square
foreach my $file ( 1 .. 8 )
{
	foreach my $rank ( 1 .. 8 ) {	push @squareList, $file * 10 + $rank; }
}

foreach my $square ( @squareList )
{
	if ( $queen->canLegallyMove( $square ) )
	{
		print "\tcan legally move to " . chr( int( $square/ 10 ) + 96 ) .
			$square % 10 . "($square) -- ";
		print "\tpath is +";
		print $queen->getPathToMove( $square );
		print "+\n\n";
	}
}

# Add an enemy piece, and assign it every square on the board to see if it
# can be captured.
my $enemyQueen = new ChessQueen();
$enemyQueen->setColor( ( $color eq "white" ) ? "black" : "white" );

foreach my $square ( @squareList )
{
	$enemyQueen->setPosition( $square );
	if ( $queen->canLegallyCapture( $enemyQueen ) )
	{
		print "\tcan legally capture " . $enemyQueen->toString() . " -- "; 
		print "\tpath is +";
		print $queen->getPathToCapture( $enemyQueen );
		print "+\n\n";
	}
}

