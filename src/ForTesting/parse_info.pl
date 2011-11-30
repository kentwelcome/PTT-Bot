#! /bin/perl -w

$filename = $ARGV[0];
open FILE , "< $filename";
while ($tmp = <FILE>){
	if ( $tmp =~ /《ＩＤ暱稱》(\w+) \((.+)\)/ ){
		print $1."\n";
		print $2."\n";
	}
	if ( $tmp =~ /《上次故鄉》(\d+\.\d+\.\d+\.\d+)/ ){
		print $1."\n";
	}
}
