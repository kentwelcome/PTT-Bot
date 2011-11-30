#! /bin/perl -w

$file = `ls BotQueue | awk '{print \$1}'`;
print $file;
open FILE , "< BotQueue/$file";
chomp( $a = <FILE> );
print $a."\n";
close FILE;

