#!/bin/bash

echo "Velocidade das interfaces:"
for Int in `ls -1 /sys/class/net`
do
    if echo $Int|egrep '^e' 1>/dev/null
    then
        echo -e "\t$Int = `cat /sys/class/net/$Int/speed` Mb/s"
    fi
done
