sub INT_handler {
    print("Don't Interrupt!\n");
}

$SIG{'INT'} = 'INT_handler';

for ($x = 0; $x < 100; $x++) {
    print("$x\n");
    sleep 1;
}

