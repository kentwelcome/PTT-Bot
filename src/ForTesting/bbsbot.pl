#!/bin/perl -w

use Net::Telnet ();
use Encode qw/encode decode/;
use Term::ReadKey;
use Data::Dumper;
use IO::Socket;
use IO::Select;
use Time::HiRes qw(usleep nanosleep);


ReadMode 3;

my $find_id = $ARGV[0];
my $ptt = new Net::Telnet ( Timeout => 0,
		Errmode => 'return');
my $target_host = "ptt.cc";
my $UserName = "islabbobo";
my $Passwd = "islab\@833";
my %BoardHashTable;

# Do something with geting the INT (ctrl + c) single
$SIG{'INT'} = 'INT_handler';
$SIG{'TERM'} = 'INT_handler';
$SIG{__DIE__}  = 'INT_handler';
$SIG{__WARN__}  = 'WARN_handler';
$SIG{'HUP'} = 'HUP_handler';


#################################################################
#								#
#  This function is use to handle the signal of HUP. When we 	#
#  get the interput from the web server. Bot will run this    	#
#  function.                                          		#
#								#
#  Parameters: None						#
#								#
#  Return Value: Node						#
#								#
#################################################################
sub HUP_handler{
	$file = `ls BotQueue | awk '{print \$1}'`;
	open QUEUE,"< BotQueue/$file";
	chomp( $find_id = <QUEUE>);
	close QUEUE;
	SearchUser($find_id);

}

#################################################################
#								#
#  This function is use to handle the signal of INT, TERM and	#
#  __DIE__. This function will set the ReadMode back to cooked	#
#  mode, close the telnet connection and exit program.		#
#								#
#  Parameters: None						#
#								#
#  Return Value: Node						#
#								#
#################################################################
sub INT_handler {
	ReadMode 1;
	print("\nClose program!\n");
	#printf("Buffer: %s\n",$ptt->buffer);
	$ptt->close;
	exit(0);
}

sub DIE_handler {
}

sub WARN_handler {
}




#################################################################
#								#
#  This function is use to read the keyboard values with non	#
#  blocking mode. If there is no keyboard hit, function will 	#
#  return not defined.						#
#								#
#  Parameters: None						#
#								#
#  Return Value: $char -> key value or not defined		#
#								#
#################################################################
sub ReadKeyMore {
	my $char = ReadKey(-1);
	if ( not defined ($char) ){
	} else {
		if ( ord($char) == ord("\x1b") ){
			while (not defined ($char = ReadKey(-1)) ) {}
			if ( ord($char) == ord("\x5b") ){
				while (not defined ($char = ReadKey(-1)) ) {}
				return $char;
			}
		} else {
			return $char;
		}
	}
	return $char;
}

#################################################################
#								#
#  This function is use to read the data form the telnet input	#
#  buffer with non blocking mode. If buffer is empty, this   	#
#  function will return immediately.				#
#								#
#  Parameters:	None						#
#								#
#  Return Value: 1 -> 	Always return 1				#
#								#
#################################################################
sub ReadInput {
	my $buf;
	my $ScreenBuffer = undef;
	while (1){
		$buf = encode("utf8",decode("big5",$ptt->get()));# or die();
		if (not defined $buf){
			return $ScreenBuffer;
		}
		print $buf;
		$ScreenBuffer = $ScreenBuffer.$buf;
	}
	return $ScreenBuffer;
}

sub InitBBSAgent{
	
}

sub LoginState{
	ReadInput();
	sleep(1);
	$ptt->put("$UserName\r");
	sleep(1);
	$ptt->put("$Passwd\r");
}

#################################################################
#								#
#  This function is use to search the information from the	#
#  target board in BBS. This function will log all the articles	#
#  and search with the key word.				#
#								#
#  Parameters:	$brd ->	Board Name				#
#		$master -> Board Master ID			#
#		$keyword -> Key word to search			#
#								#
#  Return Value: None						#
#								#
#################################################################
sub SearchBoard{ 
	my $brd = $_[0];
	my $master = $_[1];
	my $keyword = $_[2];
	my $match = "看板《$brd》";
	print $match."\n";
	open DUMP , "> $brd.dump";

	
	$ptt->put("0\r");
	my $tmp = ReadInput();
	while(1){
		#$ptt->put("\x1b\x4f\x43");
		$ptt->put("\r");
		$tmp = ReadInput();
		print DUMP $tmp;
		#find read complete
		usleep(300000);
		if ( $tmp =~ /$match/){
			last();
		}
		#dump the articles
	}
	close(DUMP);
}

sub SearchUser{
	my $ID = $_[0];
	open USERINFO , "> UserInfo/$ID.txt";
	# back to the main page;
	my $tmp = ReadInput();
	for ( $i = 0 ; $i < 10 ; $i++  ){
		$ptt->put("\x1b\x4f\x44");	
		$tmp = ReadInput();
		usleep(3000);
	}
	$ptt->put("t\rq\r$ID\r");
	sleep(1);
	$tmp = ReadInput();
	#print USERINFO $tmp;
	$ptt->put("\x60\x1b\x4f\x44\x1b\x4f\x44");
	
	#$tmp =~ /《ＩＤ暱稱》(\w+)\((.+)\)/;
	if ( $tmp =~ /《ＩＤ暱稱》(\w+) \((.+)\)/ ){
		print USERINFO $1."\n";
		print USERINFO $2."\n";
	}
	if ( $tmp =~ /《上次故鄉》(\d+\.\d+\.\d+\.\d+)/ ){
		print USERINFO $1."\n";
	}

	close USERINFO;
}

$ptt->open($target_host);
#$ptt->input_log("$target_host"."_in.log");
#$ptt->output_log("$target_host"."_out.log");
LoginState();

#start the main loop of bot
while (1){
	$cmd = ReadKeyMore;
	if ( not defined ($cmd) ){
	} else {
		if ( ord($cmd) == ord("\x41") ){	# UP
			$cmd = ("\x1b\x4f\x41");
		} elsif ( ord($cmd) == ord("\x42") ) {	#DOWN
			$cmd = ("\x1b\x4f\x42");
		} elsif ( ord($cmd) == ord("\x43") ) {	#RIGHT
			$cmd = ("\x1b\x4f\x43");
		} elsif ( ord($cmd) == ord("\x44") ) {	#LEFT
			$cmd = ("\x1b\x4f\x44");
		} elsif ( ord($cmd) == ord("\x60") ) {	#search user information
			SearchUser($find_id);
			next;
		}
		$ptt->put($cmd);
	}
	$tmp = ReadInput();

	# Special Case handle
	if ( $tmp =~ /按任意鍵繼續/ ){
		$ptt->put("\r");
	} elsif ( $tmp =~ /\[[y|Y]\/[n|N]\]/ ){
		$ptt->put("\r");
	} elsif ( $tmp =~ /看板《(\w+)》/){
		$NowAt = $1;
		open LOGFILE , ">>board.log";
		print LOGFILE $NowAt."\n";
		close LOGFILE;
		if (not defined $BoardHashTable{"$NowAt"}){
			#SearchBoard($NowAt,"kent","");
			$BoardHashTable{"$NowAt"} += 1;
		}
	}
	if ( not defined $tmp ){
	}else{
		open LOGFILE , ">>pttlog";
		print LOGFILE $tmp;
		close LOGFILE;
	}
	usleep(100000);
}

print("end\n");
ReadMode 1;
#die();



