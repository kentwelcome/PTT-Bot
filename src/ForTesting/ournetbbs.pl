#!/usr/bin/perl
# $File: //depot/libOurNet/BBS/eg/bbsget $ $Author: autrijus $
# $Revision: #1 $ $Change: 1 $ $DateTime: 2002/06/11 15:35:12 $

$VERSION = '0.01';

use strict;
use OurNet::BBS 1.64;

$OurNet::BBS::DEBUG = shift if $ARGV[0] eq '-d';

my ($site, $board, $login) = splice(@ARGV, 0, 3);

die "Usage: $0 [-d] bbsname boardname login[:password] [recno...]\n"
unless $site and $board;

my $BBS = OurNet::BBS->new({
		backend	=> 'BBSAgent',
		bbsroot	=> $site,
		login	=> $login,
		});

my $brd = $BBS->{boards}{$board}{articles};

foreach my $recno (@ARGV ? @ARGV : -1) {
	my $art = $brd->[$recno];

	foreach my $key (sort keys(%{$art->{header}})) {
		print "$key: $art->{header}{$key}\n";
	}

	print "-" x 80;
	print $art->{body};
}

