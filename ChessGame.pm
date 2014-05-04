package ChessGame;

use strict;
use ChessArmy;


# Constructor
sub new
{
	my $class          = shift @_;
	my $_WhiteArmy     = new ChessArmy( "white" );
	my $_BlackArmy     = new ChessArmy( "black" );
	my $_ActiveColor   = "white";
	my $_HalfMoveCount = 0;
	my $_FullMoveCount = 1;

	$_WhiteArmy->setStartingPosition();
	$_BlackArmy->setStartingPosition();

	return bless
	{
		_WhiteArmy   => $_WhiteArmy,
		_BlackArmy   => $_BlackArmy,
		_ActiveColor => $_ActiveColor,   # toggled via switchSides()
		_HalfMove    => $_HalfMoveCount, # toggled via makeMove()
		_Fullmove    => $_FullMoveCount  # toggled via switchSides()
	}, $class;
}

###########################################################
# METHODS
###########################################################
#
# property state methods

# Active Color
sub getActiveColor { $_[0]->{_ActiveColor} }
sub switchActiveColor
{
	my $self = shift;
	$self->{_ActiveColor} =
		( $self->getActiveColor() eq "white" ) ? "black" : "white";
}


# Armies
sub getWhiteArmy { $_[0]->{_WhiteArmy} }
sub getBlackArmy { $_[0]->{_BlackArmy} }

sub getPieceAtPosition
{
	my ( $self, $inPosition ) = @_;
	$inPosition = ChessPiece::normalize( $inPosition );
	return
		( $self->getWhiteArmy()->getPieceAtPosition( $inPosition ) ) ?
		( $self->getWhiteArmy()->getPieceAtPosition( $inPosition ) ) :
		( $self->getBlackArmy()->getPieceAtPosition( $inPosition ) );
}

sub getActiveArmy
{
	return ( $_[0]->getActiveColor() eq "white" )
		? $_[0]->getWhiteArmy() : $_[0]->getBlackArmy();
}

sub getInactiveArmy
{
	return ( $_[0]->getActiveColor() eq "white" )
		? $_[0]->getBlackArmy() : $_[0]->getWhiteArmy();
}


# Halfmove count (number of half-moves since last pawn move or capture)
sub getHalfMoveCount       { $_[0]->{_HalfMoveCount} }
sub incrementHalfMoveCount { $_[0]->{_HalfMoveCount} += 1; }
sub resetHalfMoveCount     { $_[0]->{_HalfMoveCount} = 0; }


# Fullmove count (traditinal "move number")
sub getFullMoveCount       { $_[0]->{_FullMoveCount} }
sub incrementFullMoveCount { $_[0]->{_FullMoveCount} += 1; }
sub resetFullMoveCount     { $_[0]->{_FullMoveCount} = 0; }


# switchSides -- Things to do at the end of a turn
sub switchSides
{
	my $self = shift;
	if ( $self->getActiveColor() eq "black" )
		{ $self->incrementFullMoveCount(); }
	$self->switchActiveColor();
}


# Detect if a given square can be captured by a given side
sub isVulnerableSquare
{
	my ( $self, $inSquare, $inArmy, $mustAvoidCheck ) = @_;
	$inSquare = ChessPiece::normalize( $inSquare );
	my $dummyPiece = new ChessQueen(
		$inSquare, ( $inArmy->getColor() eq "white" ) ? "black" : "white" );

	# loop through each piece of the army
	# if a given piece can capture on that square, then return true
	foreach my $aPiece ( $inArmy->getPieceList() )
	{
		if ( $aPiece->canLegallyCapture( $dummyPiece ) )
		{
			if ( ! $mustAvoidCheck ) { return 1; }
			my $oldSquare = $aPiece->getPosition();
			# More work goes here
		}
	}
	return 0;
}


# Detect if  given piece can be captured by a given side
sub isVulnerablePiece
{
	my ( $self, $inPiece, $inArmy, $mustAvoidCheck ) = @_;
	return $self->isVulnerableSquare(
		$inPiece->getPosition(), $inArmy, $mustAvoidCheck );
}


# makeMove -- moves a piece, handling capture and halfmove count
sub makeMove
{
	my ( $self, $pos1, $pos2 ) = @_;

	# Grab pieces (if extent) at pos1 and pos2
	$pos1 = ChessPiece::normalize( $pos1 );
	$pos2 = ChessPiece::normalize( $pos2 );
	my $piece1 = $self->getPieceAtPosition( $pos1 );
	my $piece2 = $self->getPieceAtPosition( $pos2 );

	# make sure that pos1 is occupied
	if ( ! $piece1 ) { return "no piece at " . ChessPiece::sanitize( $pos1 ); }

	# make sure it's our turn to move
	if ( $piece1->getColor() ne $self->getActiveColor() )
		{ return "it is not " . $self->getActiveColor() . "'s turn."; }

	# make sure pos2 can be legally reached
	if ( $piece2 )
	{
		if ( ! $piece1->canLegallyCapture( $piece2 ) )
		{
			return "The piece on " . ChessPiece::sanitize( $pos1 )
				. " cannot smash " . ChessPiece::sanitize( $pos2 );
		}
	}
	else
	{
		if ( ! $piece1->canLegallyMove( $pos2 ) )
		{
			return "The piece on " . ChessPiece::sanitize( $pos1 )
				. " cannot reach " . ChessPiece::sanitize( $pos2 );
		}
	}


	# make sure pos2 is empty or enemy-controlled
	#if ( $piece2 && $piece2->getColor() eq $self->getActiveColor() ) )
	if ( $self->getActiveArmy()->getPieceAtPosition( $pos2 ) )
	{
		return ChessPiece::sanitize( $pos2 )
			. " holds piece of same color as "
			. ChessPiece::sanitize( $pos1 );
	}

	# make sure the path is clear to pos2
	my @squareList = ( $piece2 ) ?  $piece1->getPathToCapture( $piece2 )
		: $piece1->getPathToMove( $pos2 );
	foreach my $square ( @squareList )
	{
		if ( $self->getPieceAtPosition( $square ) )
		{
			return "A piece blocks the move at "
				. ChessPiece::sanitize( $square );
		}
	}

	# if there is a piece at pos2, remove it and increment the halfmove
	if ( $piece2 )
	{
		$self->getInactiveArmy()->removePieceAtPosition( $pos2 );
		$self->resetHalfMoveCount();
	}

	# move piece1, switch sides
	$self->getActiveArmy()->movePiece( $pos1, $pos2 );
	$self->switchSides();
	return 0;
}


############################################################################
# Forsyth-Edwards Notation Documentation
############################################################################
# A FEN record defines a particular game position
# There are fields, with a space as a delimiter
#
# 1. Piece placement (from white POV)
# 2. Active color
# 3. Castling availability
# 4. En passant target square
# 5. Halfmove clock
# 6. Fullmove number
#
#######################################
# Detailed Explanation for each section
#######################################
#
# 1. Piece placement (from white POV)
# Each rank is described from 8 to 1
# Within each rank, each file is described from a to h
# pieces are identified according to SAN
# Upper case for white, lower case for black
# A stretch of 1 or more blank spaces is represented by the number of spaces
# / indicates the end of a rank

# 2. Active color
# w for white, b for black

# 3. Castling availability
# One or more characters... { KQkq } "-" for none

# 4. En passant target square
# in algebraic notation... "=" for none

# 5. Halfmove clock
# number of halfmoves since the last pawn advance or capture
# This is used for the "50 move rule"

# 6. Fullmove number
# Starts at 1, and is incremented when black moves
############################################################################

sub generateFenFromArmies
{
	my $self = shift @_;
	my $FENstring = "";
	my @FILE = ( "junk", "a", "b", "c", "d", "e", "f", "g", "h" );

	# Step 1
	foreach my $tank ( 1 .. 8 )
	{
		my $rank = 9 - $tank;
		my $numBlanks = 0;
		foreach my $file ( 1 .. 8 )
		{
			my $position = $FILE[$file] . $rank;
			my $piece = $self->getPieceAtPosition( $position );

			if ( ! $piece )
				{ $numBlanks++; }
			else
			{
				if ( $numBlanks > 0 )
				{
					$FENstring .= $numBlanks;
					$numBlanks = 0;
				}
				my $pieceType = $piece->getPieceType();
				if ( $piece->getColor() eq "white" )
					{ $pieceType = uc( $pieceType ) }
				else
					{ $pieceType = lc( $pieceType ) }
				$FENstring .= $pieceType;
			}
		}
		if ( $numBlanks > 0 ) { $FENstring .= $numBlanks; }
		$FENstring .= "/";
	}
	$FENstring .= " ";

	# Step 2
	$FENstring .= ( $self->getWhiteArmy()->getIsMyTurn() ) ? "w " : "b ";

	# Step 3
	my $castle = "";
	if ( $self->getWhiteArmy()->getCanCastleShort() ) { $castle .= "K"; }
	if ( $self->getWhiteArmy()->getCanCastleLong() )  { $castle .= "Q"; }
	if ( $self->getBlackArmy()->getCanCastleShort() ) { $castle .= "k"; }
	if ( $self->getBlackArmy()->getCanCastleLong() )  { $castle .= "q"; }
	if ( $castle eq "" ) { $castle = "-"; }
	$FENstring .= "$castle ";

	# Step 4 -- Cheating
	$FENstring .= "- ";

	# Step 5 -- Cheating;
	$FENstring .= "0 ";

	# Step 6 -- Cheating;
	$FENstring .= "1 ";

	return $FENstring;
}

1;
