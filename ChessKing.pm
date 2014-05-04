package ChessKing;

use strict;
use ChessPiece;
our @ISA = qw( ChessPiece );

# Constructor
sub new
{
	my $class = shift @_;
	my @paramList = @_;
	
	$paramList[2] = ChessPiece::King;

	my $self = ChessPiece->new( @paramList );
	return bless $self, $class;
}

# Extend the canLegallyMove method
sub canLegallyMove
{
	my ( $self, $newSquare ) = @_;

	# Is the new square different than the current square?
	if ( $self->getPosition() == $newSquare ) { return 0; }

	# is the new square horizontal, vertical, or diagonal from me?
	my $queenwise =
	(
		$self->canLegallyMoveRookwise( $newSquare ) ||
		$self->canLegallyMoveDiagonally( $newSquare )
	);
	if ( ! $queenwise ) { return 0; }

	# is the new square exactly 1 square away?
	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( int( $newSquare / 10 ), $newSquare % 10 );

	return ( ( abs($curFile-$newFile) < 2 ) && ( abs($curRank-$newRank) < 2 ) );
}

1;
