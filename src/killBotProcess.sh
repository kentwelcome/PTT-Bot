#! /bin/sh

PID=`ps ax | grep "perl PTT-Bot\.pl" | awk '{print \$1}'`;
kill -1 $PID;
