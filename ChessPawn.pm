package ChessPawn;

# NOTE: En passant is not currently supported.  Soon, my lovelies, soon.

use strict;
use ChessPiece;
our @ISA = ( "ChessPiece" );

# Constructor
sub new
{
	my $class = shift @_;
	my @paramList = @_;
	
	$paramList[2] = ChessPiece::Pawn;

	my $self = ChessPiece->new( @paramList );
	return bless $self, $class;
}

# Extend the canLegallyMove method
sub canLegallyMove
{
	my ( $self, $newSquare ) = @_;
	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( int( $newSquare / 10 ), $newSquare % 10 );
	my @returnList = ();

	if ( $newFile != $curFile )
		{ return 0; } # pawn can't change file in regular move

	# White Case
	if ( $self->getColor() eq "white" )
	{
		if ( ( $newRank == $curRank + 2 ) && ( $curRank == 2 ) )
			{ return 1; }
		if ( $newRank == $curRank + 1 )
			{ return 1; }
		return 0;
	}

	# Black Case
	if ( $self->getColor() eq "black" )
	{
		if ( ( $newRank == $curRank - 2 ) && ( $curRank == 7 ) )
			{ return 1; }
		if ( $newRank == $curRank - 1 )
			{ return 1; }
		return 0;
	}

	# Any other color is a problem
	return 0;
}


# Extend the canLegallyCapture method
sub canLegallyCapture
{
	my ( $self, $enemy ) = @_;
	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( $enemy->getFile(), $enemy->getRank() );

	# Make sure it's an enemy piece
	if ( $self->getColor() eq $enemy->getColor() ) { return 0; }

	# Ensure rank changes by exactly 1
	if ( abs( $curFile - $newFile ) != 1 ) { return 0; }

	# White Case
	if ( $self->getColor() eq "white" )
		{ return ( $newRank == ( $curRank + 1 ) ); }

	# Black Case
	if ( $self->getColor() eq "black" )
		{ return ( $newRank == ( $curRank - 1 ) ); }

	# Fail case;
	return 0;
}

# Extend pathToMove
sub getPathToMove
{
	my ($self, $newSquare ) = @_;
	$newSquare = ChessPiece::normalize( $newSquare );
	if ( ! $self->canLegallyMove( $newSquare ) ) { return undef; }
	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( int( $newSquare / 10 ), $newSquare % 10 );
	my @returnList = ();

	# White case
	if ( ( $newRank == 4 ) && ( $curRank == 2 ) )
		{ push @returnList, int( $self->getPosition() ) + 1; }

	# Black case
	if ( ( $newRank == 5 ) && ( $curRank == 7 ) )
		{ push @returnList, $self->getPosition() - 1; }

	return @returnList;
}

# Extend pathToCapture
sub getPathToCapture { return (); }

1;
