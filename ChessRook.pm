package ChessRook;

use strict;
use ChessPiece;
our @ISA = qw( ChessPiece );

# Constructor
sub new
{
	my $class = shift @_;
	my @paramList = @_;
	
	$paramList[2] = ChessPiece::Rook;

	my $self = ChessPiece->new( @paramList );
	return bless $self, $class;
}

# Extend the canLegallyMove method
sub canLegallyMove
{
	my $self = shift;
	return $self->canLegallyMoveRookwise( @_ );
}

1;
