#!/ramdisk/bin/perl -w

use strict;
use ChessBishop;
use ChessPiece;

# Get parameters
( @ARGV == 2 ) or die "usage: testBishop.pl position color...\n\n";
my ( $position, $color ) = @ARGV;
my $bishop = new ChessBishop( $position, $color );


print "unit testing for $color bishop at $position...\n";

# Run through the property support methods
print "Property Support Methods\n";
print "\tgetPosition() : " . $bishop->getPosition() . "\n";
print "\tgetColor()    : " . $bishop->getColor() . "\n";
print "\tgetPieceType(): " . $bishop->getPieceType() . "\n";
print "\ttoString()    : " . $bishop->toString() . "\n";

print "\nMovement and Path Methods\n";
my @squareList = ();

# Add every square
foreach my $file ( 1 .. 8 )
{
	foreach my $rank ( 1 .. 8 ) {	push @squareList, $file * 10 + $rank; }
}

foreach my $square ( @squareList )
{
	if ( $bishop->canLegallyMove( $square ) )
	{
		print "\tcan legally move to " . chr( int( $square/ 10 ) + 96 ) .
			$square % 10 . "($square) -- ";
		print "\tpath is +";
		print $bishop->getPathToMove( $square );
		print "+\n\n";
	}
}

# Add an enemy piece, and assign it every square on the board to see if it
# can be captured.
my $enemyBishop = new ChessBishop();
$enemyBishop->setColor( ( $color eq "white" ) ? "black" : "white" );

foreach my $square ( @squareList )
{
	$enemyBishop->setPosition( $square );
	if ( $bishop->canLegallyCapture( $enemyBishop ) )
	{
		print "\tcan legally capture " . $enemyBishop->toString() . " -- "; 
		print "\tpath is +";
		print $bishop->getPathToCapture( $enemyBishop );
		print "+\n\n";
	}
}

