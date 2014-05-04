#!/ramdisk/bin/perl -w

use strict;
use ChessRook;
use ChessPiece;

# Get parameters
( @ARGV == 2 ) or die "usage: testRook.pl position color...\n\n";
my ( $position, $color ) = @ARGV;
my $rook = new ChessRook( $position, $color );


print "unit testing for $color rook at $position...\n";

# Run through the property support methods
print "Property Support Methods\n";
print "\tgetPosition() : " . $rook->getPosition() . "\n";
print "\tgetColor()    : " . $rook->getColor() . "\n";
print "\tgetPieceType(): " . $rook->getPieceType() . "\n";
print "\ttoString()    : " . $rook->toString() . "\n";

print "\nMovement and Path Methods\n";
my @squareList = ();

# Add every square
foreach my $file ( 1 .. 8 )
{
	foreach my $rank ( 1 .. 8 ) {	push @squareList, $file * 10 + $rank; }
}

foreach my $square ( @squareList )
{
	if ( $rook->canLegallyMove( $square ) )
	{
		print "\tcan legally move to " . chr( int( $square/ 10 ) + 96 ) .
			$square % 10 . "($square) -- ";
		print "\tpath is +";
		print $rook->getPathToMove( $square );
		print "+\n\n";
	}
}

# Add an enemy piece, and assign it every square on the board to see if it
# can be captured.
my $enemyRook = new ChessRook();
$enemyRook->setColor( ( $color eq "white" ) ? "black" : "white" );

foreach my $square ( @squareList )
{
	$enemyRook->setPosition( $square );
	if ( $rook->canLegallyCapture( $enemyRook ) )
	{
		print "\tcan legally capture " . $enemyRook->toString() . " -- "; 
		print "\tpath is +";
		print $rook->getPathToCapture( $enemyRook );
		print "+\n\n";
	}
}

