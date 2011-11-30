#!/usr/bin/perl -w
# telnet.pl - a program to telnet to a machine
# and do some stuff
use strict;
use Net::Telnet;

my $host = shift || 'server.telent.com';
my $user = shift || $ENV{USER};
die "no user!" unless $user;
my($pass, $command);
print 'Enter password: ';
system 'stty -echo';
chop($pass = );
system 'stty echo';
print "\n";
my $tn = new Net::Telnet(Host => $host)
	or die "connect failed: $!";
$tn->login($user, $pass)
	or die "login failed: $!";
	print 'Hostname: ';
	print $tn->cmd('/bin/hostname'), "\n";
	my @who =  $tn->cmd('/usr/bin/who');
	print "Here's who:\n", @who, "\n";
	print "\nWhat is your command: ";
	chop($command = );
	print $tn->cmd($command), "\n";
	$tn->close or die "close fail: $!";

