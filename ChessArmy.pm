package ChessArmy;

# This class holds all the pieces of a side, and holds data as to:
#  * whether that side can long castle
#  * whether that side can short castle
#  * if that is in check
#  * whether that side can make a move
#  * if that side is to make a move or is waiting
#

use strict;
use ChessPiece;
use ChessPawn;
use ChessRook;
use ChessKnight;
use ChessBishop;
use ChessQueen;
use ChessKing;

# Constructor
sub new
{
	my $class = shift @_;
	my $_Color = shift@_;
	my @_PieceList = ();
	my @_DeadPieceList = ();
	my $_CanCastleLong;
	my $_CanCastleShort;
	my $_IsInCheck;
	my $_CanMove;
	my $_IsMyTurn;

	return bless
	{
		_Color          => $_Color,
		_PieceList      => \@_PieceList,
		_DeadPieceList  => \@_DeadPieceList,
		_CanCastleLong  => $_CanCastleLong,
		_CanCastleShort => $_CanCastleShort,
		_IsInCheck      => $_IsInCheck,
		_CanMove        => $_CanMove,
		_IsMyTurn       => $_IsMyTurn
	}, $class;
	
}

# Property State
# Color
sub getColor { $_[0]->{_Color} }
sub setColor
{
	my ( $self, $inColor ) = @_;
	$self->{_Color} = $inColor if $inColor;
}


# PieceList is a list, so has nonstandard methods
# Add a piece
sub addPiece
{
	my ( $self, $inPiece ) = @_;
	my $ref = $self->{_PieceList};
	push @$ref, $inPiece;
}

# Move a piece to the Dead Piece List
sub removePieceAtPosition
{
	my ( $self, $inPosition ) = @_;
	$inPosition = ChessPiece::normalize( $inPosition );
	my $ref = $self->{_PieceList};
	my $deadRef = $self->{_DeadPieceList};
	my $last = @$ref - 1;
	foreach my $index ( 0 .. $last )
	{
		if ( $$ref[$index]->getPosition() eq $inPosition )
		{
			push @$deadRef, $$ref[$index];

			# I'm going to be careful here.  Using blind math with indices
			# might lead to a negative offset, and perl is crazy when it
			# comes to negative offsets.
			if ( $index == 0 ) { shift @$ref; return; }
			if ( $index == $last ) { pop @$ref; return; }
			foreach ( $index .. $last - 1 )
				{ $$ref[$_] = $$ref[$_ + 1]; }
			pop @$ref;
			return;
		}
	}
}

# get the piece (if any) at a given location
sub getPieceAtPosition
{
	my ( $self, $inPosition ) = @_;
	$inPosition = ChessPiece::normalize( $inPosition );
	my $ref = $self->{_PieceList};
	foreach my $index ( 0 .. @$ref - 1 )
	{
		if ( $inPosition && $$ref[$index]->getPosition() eq $inPosition)
			{ return $$ref[$index] }
	}
	return undef;
}

# Change a piece's position
sub movePiece
{
	my ( $self, $position1, $position2 ) = @_;
	$position1 = ChessPiece::normalize( $position1 );
	$position2 = ChessPiece::normalize( $position2 );

	my $piece = $self->getPieceAtPosition( $position1 );
	if ( $piece ) { $piece->setPosition( $position2 ); }
}

# get all pieces
sub getPieceList
{
	my $self = shift @_;
	my $ref = $self->{_PieceList};
	return @$ref;
}

# get all taken pieces
sub getDeadPieceList
{
	my $self = shift @_;
	my $ref = $self->{_DeadPieceList};
	return @$ref;
}


# The king is important enough to get his own accessor
sub getKing
{
	my $self = shift;
	foreach my $aPiece ( $self->getPieceList() )
	{
		if ( $aPiece->getPieceType() eq ChessPiece::King ) { return $aPiece; }
	}
}


# Standard Getters, Irish Setters
# CanCastleLong
sub getCanCastleLong { $_[0]->{_CanCastleLong} }
sub setCanCastleLong
{
	my ( $self, $inCanCastleLong ) = @_;
	$self->{_CanCastleLong} = $inCanCastleLong if $inCanCastleLong;
}


# CanCastleShort
sub getCanCastleShort { $_[0]->{_CanCastleShort} }
sub setCanCastleShort
{
	my ( $self, $inCanCastleShort ) = @_;
	$self->{_CanCastleShort} = $inCanCastleShort if $inCanCastleShort;
}


# IsInCheck
sub getIsInCheck { $_[0]->{_IsInCheck} }
sub setIsInCheck
{
	my ( $self, $inIsInCheck ) = @_;
	$self->{_IsInCheck} = $inIsInCheck if $inIsInCheck;
}


# CanMove
sub getCanMove { $_[0]->{_CanMove} }
sub setCanMove
{
	my ( $self, $inCanMove ) = @_;
	$self->{_CanMove} = $inCanMove if $inCanMove;
}


# IsMyTurn
sub getIsMyTurn { $_[0]->{_IsMyTurn} }
sub setIsMyTurn
{
	my ( $self, $inIsMyTurn ) = @_;
	$self->{_IsMyTurn} = $inIsMyTurn if $inIsMyTurn;
}

# Set up a default position
sub setStartingPosition
{
	my $self = shift @_;
	my @file = ( "a", "b", "c", "d", "e", "f", "g", "h" );

	# Do pawns first
	my $rank = ( $self->getColor() eq "white" ) ? "2" : "7";
	foreach my $file ( @file )
	{
		my $position = $file . $rank;
		$self->addPiece( new ChessPawn( $position, $self->getColor() ) );
	}

	# Now the major and minor pieces
	$rank = ( $self->getColor() eq "white" ) ? "1" : "8";
	$self->addPiece( new ChessRook(   "a".$rank, $self->getColor() ) );
	$self->addPiece( new ChessKnight( "b".$rank, $self->getColor() ) );
	$self->addPiece( new ChessBishop( "c".$rank, $self->getColor() ) );
	$self->addPiece( new ChessQueen(  "d".$rank, $self->getColor() ) );
	$self->addPiece( new ChessKing(   "e".$rank, $self->getColor() ) );
	$self->addPiece( new ChessBishop( "f".$rank, $self->getColor() ) );
	$self->addPiece( new ChessKnight( "g".$rank, $self->getColor() ) );
	$self->addPiece( new ChessRook(   "h".$rank, $self->getColor() ) );

	$self->setCanCastleLong( 1 );
	$self->setCanCastleShort( 1 );
	$self->setIsInCheck( 1 );
	$self->setCanMove( 1 );
	$self->setIsMyTurn( 1 );
}

# toString
sub toString
{
	my $self = shift @_;
	my $Color          = $self->getColor();
	my $canCastleLong  = $self->getCanCastleLong();
	my $canCastleShort = $self->getCanCastleShort();
	my $isInCheck      = $self->getIsInCheck();
	my $canMove        = $self->getCanMove();
	my $isMyTurn       = $self->getIsMyTurn();

	my $rString = "Chess Army:\n";
	$rString .= "\tColor           : $canCastleLong\n";
	$rString .= "\tCan Castle Long : $canCastleLong\n";
	$rString .= "\tCan Castle Short: $canCastleShort\n";
	$rString .= "\tIs In Check     : $isInCheck\n";
	$rString .= "\tCan Move        : $canMove\n";
	$rString .= "\tIs My Turn      : $isMyTurn\n";

	$rString .= "Board Pieces:\n";
	foreach my $piece ( $self->getPieceList() )
	{
		$rString .= "\t" . $piece->toString() . "\n";
	}

	$rString .= "Taken Pieces:\n";
	foreach my $piece ( $self->getDeadPieceList() )
	{
		$rString .= "\t" . $piece->toString() . "\n";
	}

	return $rString;
}

1;
