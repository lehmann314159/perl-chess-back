package ChessPiece;

# Written at speed by Mike Lehmann
# TODO: Do error checking and graceful degradation
# TODO: Better internal doc

use strict;
use constant Pawn   => 'P';
use constant Knight => 'N';
use constant Bishop => 'B';
use constant Rook   => 'R';
use constant Queen  => 'Q';
use constant King   => 'K';

# Constructor
sub new
{
	# Who am I?
	my $class = shift @_;

	# Declare propertes, filling if possible
	my ( $_Position, $_Color, $_PieceType ) = @_;

	# I'm semi-overloading the constructor by branching internally on the
	# "int"ness of the passed position.  If it's an int I do nothing,
	# otherwise I try to convert the file to an int.
	
	# I'm doing this so that I can have:
	# $file = int( $position / 10 )
	# $rank = $position % 10;
	#
	# convert the file into a digit
	# take the file of the position
	# convert to lower case
	# subtract from 'a' + 1
	# mutiply by 10 and add the file
	#if ( $_Position && $_Position =~  m/^\D\d$/ )
	#{
		#$_Position = ( ord( lc( ( substr( $_Position, 0, 1 ) ) ) ) - 96 ) * 10
			#+ substr( $_Position, 1, 1 );
	#}
	$_Position = ChessPiece::normalize( $_Position );

	# bless
	return bless
	{
		_Position  => $_Position,
		_Color     => $_Color,
		_PieceType => $_PieceType
	}, $class;
}

# Accessors and Mutators
# Position
sub getPosition { $_[0]->{_Position} }
sub getSANPosition { return chr( $_[0]->getFile() + 96 ) . $_[0]->getRank(); }

sub setPosition
{
	my ( $self, $inPosition ) = @_;
	if ( $inPosition && $inPosition =~  m/^\D\d$/ )
		{ $self->setSANPosition( $inPosition ); }
	else
		{ $self->{_Position} = $inPosition if $inPosition; }
}

sub setSANPosition
{
	my ( $self, $inSANPosition ) = @_;
	$self->{_Position} = ChessPiece::normalize( $inSANPosition );
		#( ord( lc( substr( $inSANPosition, 0, 1 ) ) ) - 96 ) * 10
		#+ substr( $inSANPosition, 1, 1 );
}

sub getFile { return int( $_[0]->getPosition() / 10 ); }
sub getRank { return $_[0]->getPosition() % 10; }

# Color
sub getColor { $_[0]->{_Color} }
sub setColor
{
	my ( $self, $inColor ) = @_;
	$self->{_Color} = $inColor if $inColor;
}

# Piece Type
sub getPieceType { $_[0]->{_PieceType} }
sub setPieceType
{
	my ( $self, $inPieceType ) = @_;
	$self->{_PieceType} = $inPieceType if $inPieceType;
}

# This requires a bit of explanation.
# When determining if a given piece can move to a particular square, we
# must consider a number of things, not all of which are known by the
# piece in question.
# 0. We have to be sure that there is a legal move that will move the piece
#    to the target square
# 1. We have to know what path would be taken by the piece to get to the
#    destination square (this path does not include the destination square
#    itself).
# 2. We have to determine if any of the squares along that path are blocked,
#    by either side.
# 3. We have to see if the given piece's king is subject to capture as a
#    result of the move.
#    There might be more, in which case I'll include them later.
#
# The piece to be moved knows about  0 and 1, but not about 2 or 3.  So the
# actual # determination as to whether the piece can be moved belongs in
# ChessGame, and the determination of the path is left up to the child class
# of ChessPiece.
#
# Note 1 -- The knight has an empty path, since it cannot be blocked.  The
# pawn has an empty path except (possibly) on its first move.
#
# Note 2 -- In general the capture path is the same as the move path, but for
# pawns they are different, since pawn move forward but capture diagonally.
sub canLegallyMove { return 0; }

sub canLegallyCapture
{
	my ( $self, $enemyPiece ) = @_;
	if ( $self->getColor() eq $enemyPiece->getColor() ) { return 0; }
	return $self->canLegallyMove( $enemyPiece->getPosition() );
}

sub getPathToCapture
{
	my ( $self, $enemyPiece ) = @_;
	if ( ! $enemyPiece ) { return (); }
	if ( $self->getColor() eq $enemyPiece->getColor() ) { return undef; }
	return $self->getPathToMove( $enemyPiece->getPosition() );
}


# Fundamental path methods
# Diagonal
sub canLegallyMoveDiagonally
{
	my ( $self, $newSquare ) = @_;
	#$newSquare = ChessPiece::normalize( $newSquare );
	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( int( $newSquare / 10 ), $newSquare % 10 );

	# Is the new square different than the current square?
	if ( $self->getPosition() == $newSquare ) { return 0; }

	# A bishop move is valid if the absolute value of the rank movement
	# is equal to the absolute value of the file movemnt.
	my $fileMovement = $curFile - $newFile;
	my $rankMovement = $curRank - $newRank;

	return ( abs( $fileMovement ) == abs( $rankMovement ) );
}

# Rookwise
sub canLegallyMoveRookwise
{
	my ( $self, $newSquare ) = @_;
	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( int( $newSquare / 10 ), $newSquare % 10 );

	# Is the new square different than the old square?
	if ( $self->getPosition() == $newSquare ) { return 0; }

	# If exactly one of rank and file has changed, then we have a rook move
	# but xor in perl is treacherous
	if ( ( $curFile != $newFile ) && ( $curRank == $newRank ) ) { return 1; }

	if ( ( $curFile == $newFile ) && ( $curRank != $newRank ) ) { return 1; }

	return 0;
}

# This works for diagonal as well as rookwise
sub getPathToMove
{
	my ($self, $newSquare ) = @_;
	$newSquare = ChessPiece::normalize( $newSquare );
	if ( ! $self->canLegallyMove( $newSquare ) ) { return undef; }

	my ( $curFile, $curRank ) = ( $self->getFile(), $self->getRank() );
	my ( $newFile, $newRank ) = ( int( $newSquare / 10 ), $newSquare % 10 );
	my @returnList = ();

	#Get file delta
	my $fileDelta;
	if ( $newFile == $curFile ) { $fileDelta = 0; }
	else { $fileDelta = ( $newFile > $curFile ) ? 1 : -1; }

	# Get rank delta
	my $rankDelta;
	if ( $newRank == $curRank ) { $rankDelta = 0; }
	else { $rankDelta = ( $newRank > $curRank ) ? 1 : -1; }

	# Get the number of steps
	my $numberOfSquaresInPath = ( $rankDelta != 0 )
		? abs( $curRank - $newRank ) - 1
		: abs( $curFile - $newFile ) - 1;

	# Get the positions in our path
	foreach my $step ( 1 .. $numberOfSquaresInPath )
	{
		my $newPosition = ( $curFile + $step * $fileDelta ) * 10
 			+ ( $curRank + $step * $rankDelta );
		push @returnList, $newPosition;
	}
	return @returnList;
}


# To String
sub toString
{
	my $self = shift @_;
	my $color = $self->getColor();
	my $pieceType = $self->getPieceType();
	my $position = $self->getSANPosition();
	my $rString = "chess Piece: $color $pieceType at $position";
	return $rString;
}

# Convert a position from SAN if needed
sub normalize
{
	# Don't care about the object, if any
	my $inPos = pop;
	if ( $inPos && $inPos =~  m/^\D\d$/ )
	{
		return ( ord( lc( ( substr( $inPos, 0, 1 ) ) ) ) - 96 ) * 10
			+ substr( $inPos, 1, 1 );
	}
	return $inPos;
}

# Convert a position to SAN if needed
sub sanitize
{
	# Don't care about the object, if any
	my $inPos = pop;
	if ( $inPos && $inPos =~  m/^\d\d$/ )
		{ return ( chr( int( $inPos / 10 ) + 96 ) . $inPos % 10 ); }
	return $inPos;
}
1;
