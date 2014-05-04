package ChessQueen;

use strict;
use ChessPiece;
our @ISA = qw( ChessPiece );

# Constructor
sub new
{
	my $class = shift @_;
	my @paramList = @_;
	
	$paramList[2] = ChessPiece::Queen;

	my $self = ChessPiece->new( @paramList );
	return bless $self, $class;
}

# Extend the canLegallyMove method
sub canLegallyMove
{
	my $self = shift;
	return
	(
		$self->canLegallyMoveRookwise( @_ ) ||
		$self->canLegallyMoveDiagonally( @_ )
	);
}

1;
