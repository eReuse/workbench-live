sudo dmesg -n 1 # Do not report *useless* system messages to the terminal
if ping 10.13.37.2 -c 1 -W 1 > /dev/null ; then # Can we connect to a box?
# Workbench Server mode
    sudo erwb --benchmark --server http://10.13.37.2:8091 --json c.json
else
    sudo erwb --benchmark --smart Short --stress 1 --json computer.json --submit http://user@dhub.com:1234@devicehub-teal.ereuse.net
fi
