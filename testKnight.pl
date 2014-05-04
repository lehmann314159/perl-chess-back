#!/ramdisk/bin/perl -w

use strict;
use ChessKnight;
use ChessPiece;

# Get parameters
( @ARGV == 2 ) or die "usage: testKnight.pl position color...\n\n";
my ( $position, $color ) = @ARGV;
my $king = new ChessKnight( $position, $color );


print "unit testing for $color king at $position...\n";

# Run through the property support methods
print "Property Support Methods\n";
print "\tgetPosition() : " . $king->getPosition() . "\n";
print "\tgetColor()    : " . $king->getColor() . "\n";
print "\tgetPieceType(): " . $king->getPieceType() . "\n";
print "\ttoString()    : " . $king->toString() . "\n";

print "\nMovement and Path Methods\n";
my @squareList = ();

# Add every square
foreach my $file ( 1 .. 8 )
{
	foreach my $rank ( 1 .. 8 ) {	push @squareList, $file * 10 + $rank; }
}

foreach my $square ( @squareList )
{
	if ( $king->canLegallyMove( $square ) )
	{
		print "\tcan legally move to " . chr( int( $square/ 10 ) + 96 ) .
			$square % 10 . "($square) -- ";
		print "\tpath is +";
		print $king->getPathToMove( $square );
		print "+\n\n";
	}
}

# Add an enemy piece, and assign it every square on the board to see if it
# can be captured.
my $enemyKnight = new ChessKnight();
$enemyKnight->setColor( ( $color eq "white" ) ? "black" : "white" );

foreach my $square ( @squareList )
{
	$enemyKnight->setPosition( $square );
	if ( $king->canLegallyCapture( $enemyKnight ) )
	{
		print "\tcan legally capture " . $enemyKnight->toString() . " -- "; 
		print "\tpath is +";
		print $king->getPathToCapture( $enemyKnight );
		print "+\n\n";
	}
}

