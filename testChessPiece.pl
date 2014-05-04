#!/ramdisk/bin/perl -w

use strict;
use ChessPiece;

my $piece = new ChessPiece( "e4", "white", "rook" );
print $piece->toString() . "\n";
$piece->setSANPosition( "f5" );
print $piece->toString() . "\n";
$piece->setPosition( 65 );
print $piece->toString() . "\n";
