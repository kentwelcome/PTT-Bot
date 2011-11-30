use Term::ReadKey;
use Time::HiRes qw(usleep nanosleep);

$SIG{'INT'} = 'INT_handler';


sub INT_handler {
	print("Close program!\n");
	ReadMode 0;
	exit(0);
}

ReadMode 3;
while (1) {
	usleep(100000);
	my @value;
#while (not defined ($char = ReadKey(-1)) ) {}
	$char = ReadKey(-1);
	if ( not defined $char){
	}else{
		printf(" Hex: %x", ord($char));
		$value[0] = ord($char);
		if ( ord($char) == ord("\x1b") ){
			while (not defined ($char = ReadKey(-1)) ) {}
			printf(" %x", ord($char));
			$value[1] = ord($char);
			if ( ord($char) == ord("\x5b") ){
				while (not defined ($char = ReadKey(-1)) ) {}
				printf(" %x\n", ord($char));
				$value[2] = ord($char);
			} else {
				printf("\n");
			}
		} else {
			printf("\n");
		}
		if ( $value[2] == ord("\x41") ){
			printf("\t%x\n",$value[2]);
		}
	}
}
ReadMode 0; # Reset tty mode before exiting

