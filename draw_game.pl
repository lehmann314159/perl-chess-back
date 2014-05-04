#!/ramdisk/bin/perl -w

BEGIN
{
	my $homedir = ( getpwuid($>) )[7];
	my @user_include;
	foreach my $path (@INC) {
		if ( -d $homedir . '/perl' . $path ) {
		push @user_include, $homedir . '/perl' . $path;
		}
	}
	unshift @INC, @user_include;
}

# given a FEN string draws up a chess game

# Precedents
use strict;
use GD;
use CGI;

# Housekeeping
my $borderSize = 50;
my $squareSize = 50;
my $boardSize = $squareSize * 8 + $borderSize * 2;

# Finds the x-coordinate of a particular position
sub xCoord
{
    my %FTN =
    (
        "a", 1, "b", 2, "c", 3, "d", 4, "e", 5, "f", 6, "g", 7, "h", 8,
        "A", 1, "B", 2, "C", 3, "D", 4, "E", 5, "F", 6, "G", 7, "H", 8
    );

    # Assumes a position is passed in, e.g. "a1"
    # Slurp our guy
    my $file = shift @_;
    $file = substr( $file, 0, 1 );

    # Border Size + Each Square up to our guy, minus a half square
    my $coord = $borderSize;
    $coord += $squareSize * $FTN{$file};
    $coord -= $squareSize / 2;
    return $coord;
}

# Finds the y-coordinate of a particular position
sub yCoord
{
    # Assumes a position is passed in, e.g. "a1"
    # Throw your hands in the air
    my $rank = shift @_;
    $rank = substr( $rank, 1, 1 );

    # Border Size + Each Square up to our guy, minus a half square
    # Except we have to go backwards, because (0,0) is top left.
    my $coord = $borderSize;
    $coord += $squareSize * ( 9 - $rank );
    $coord -= $squareSize / 2;
    return $coord;
}

sub drawPiece
{
    my ( $image, $position, $piece, $color, $fontColor ) = @_;
    my $grey = $image->colorAllocate( 192, 192, 192 );

    $image->filledEllipse( xCoord( $position ), yCoord( $position ),
        $squareSize * .75, $squareSize * .75, $grey );
    $image->filledEllipse( xCoord( $position ), yCoord( $position ),
        $squareSize * .75 - 5, $squareSize * .75 - 5, $color );
    $image->string( gdGiantFont, xCoord( $position ) - 3,
        yCoord( $position ) - 8, $piece, $fontColor );
}

# Allocate board
my $board = new GD::Image( $boardSize, $boardSize );

# Allocate colors
my $white = $board->colorAllocate( 255, 255, 255 );
my $black = $board->colorAllocate(   0,   0,   0 );
my $red   = $board->colorAllocate( 255,   0,   0 );
my $blue  = $board->colorAllocate(   0,   0, 255 );
my $brown = $board->colorAllocate( 139,  69,  19 );
my $brushColor;

# Draw our OMB border
$board->filledRectangle( 0, 0, $boardSize -1, $boardSize, $brown );

# Draw squares
foreach my $rank ( 0 .. 7 )
{
    foreach my $file ( 0 .. 7 )
    {
        # Determine extent
        my $x1 = $file * $squareSize + $borderSize;
        my $y1 = $rank * $squareSize + $borderSize;
        my $x2 = $x1 + $squareSize - 1;
        my $y2 = $y1 + $squareSize - 1;

        # Determine color
        if ( ( $rank + $file ) % 2 )
            { $brushColor = $black; }
        else
            { $brushColor = $white; }

        # Draw the square
        $board->filledRectangle( $x1, $y1, $x2, $y2, $brushColor );
    }
}

# Draw the ranks and files
my $rankX = xCoord( "a8" ) - 3 - $squareSize;
$board->string( gdGiantFont, $rankX, yCoord( "a8" ) - 8, "8", $black );
$board->string( gdGiantFont, $rankX, yCoord( "a7" ) - 8, "7", $black );
$board->string( gdGiantFont, $rankX, yCoord( "a6" ) - 8, "6", $black );
$board->string( gdGiantFont, $rankX, yCoord( "a5" ) - 8, "5", $black );
$board->string( gdGiantFont, $rankX, yCoord( "a4" ) - 8, "4", $black );
$board->string( gdGiantFont, $rankX, yCoord( "a3" ) - 8, "3", $black );
$board->string( gdGiantFont, $rankX, yCoord( "a2" ) - 8, "2", $black );
$board->string( gdGiantFont, $rankX, yCoord( "a1" ) - 8, "1", $black );

my $fileY = yCoord( "a1" ) - 8 + $squareSize;
$board->string( gdGiantFont, xCoord( "a1" ) - 3, $fileY, "A", $black );
$board->string( gdGiantFont, xCoord( "b1" ) - 3, $fileY, "B", $black );
$board->string( gdGiantFont, xCoord( "c1" ) - 3, $fileY, "C", $black );
$board->string( gdGiantFont, xCoord( "d1" ) - 3, $fileY, "D", $black );
$board->string( gdGiantFont, xCoord( "e1" ) - 3, $fileY, "E", $black );
$board->string( gdGiantFont, xCoord( "f1" ) - 3, $fileY, "F", $black );
$board->string( gdGiantFont, xCoord( "g1" ) - 3, $fileY, "G", $black );
$board->string( gdGiantFont, xCoord( "h1" ) - 3, $fileY, "H", $black );

# get the FEN string
my $cgi = new CGI;
my $fenstring = $cgi->param( "fenstring" );
#my $fenString = "rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR/ w KQk...";
my @setup;
(
	$setup[0], $setup[1], $setup[2], $setup[3],
	$setup[4], $setup[5], $setup[6], $setup[7]
) = split( /\//, $fenstring );

my @FILE = ( "junk", "a", "b", "c", "d", "e", "f", "g", "h" );

# pull apart and render the pieces
foreach my $tank ( 1 .. 8 )
{
	my $rank = 9 - $tank;
	my $row = shift @setup;
	my $file = 1;
	while ( $file < 9 )
	{
		my $char = substr( $row, 0, 1 );
		$row = substr( $row, 1 );
		if ( $char =~ /\d/ ) { $file += $char; next; }

		my $pieceColor = ( $char eq ( uc( $char ) ) ) ? $white : $black;
		drawPiece( $board, $FILE[$file] . $rank, uc( $char ), $pieceColor, $red );
		$file++;
	}
}

#drawPiece( $board, "a1", "R", $white, $red );

# Make the picture
binmode STDOUT;
print $cgi->header( "image/png" );
print $board->png;
