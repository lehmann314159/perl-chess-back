package ChessKnight;

use strict;
use ChessPiece;
our @ISA = ( "ChessPiece" );

# Constructor
sub new
{
	my $class = shift @_;
	my @paramList = @_;
	
	$paramList[2] = ChessPiece::Knight;

	my $self = ChessPiece->new( @paramList );
	return bless $self, $class;
}

# Extend the canLegallyMove method
sub canLegallyMove
{
	my ( $self, $newSquare ) = @_;
	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( int( $newSquare / 10 ), $newSquare % 10 );

	# get vertical and horizontal distance
	my $fileDist = abs( $curFile - $newFile );
	my $rankDist = abs( $curRank - $newRank );

	# Many happy returns
	if ( ( $fileDist == 1 ) && ( $rankDist == 2 ) ) { return 1; }
	if ( ( $fileDist == 2 ) && ( $rankDist == 1 ) ) { return 1; }
	return 0;
}


# Extend pathToMove
# A knight cannot be blocked, so return no path
sub getPathToMove
{
	my ($self, $newSquare ) = @_;
	if ( ! $self->canLegallyMove( $newSquare ) ) { return undef; }
	return ();
}

1;
