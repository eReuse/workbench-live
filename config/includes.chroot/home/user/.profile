submit='https://hello@usody.com:usody@api.app.usody.com'
serverHost='10.13.37.2'
server="http://${serverHost}:8091"

stty -echo # Do not show what we type in terminal so it does not meddle with our nice output
setterm -blank 0  # Do not suspend monitor
sudo dmesg -n 1 # Do not report *useless* system messages to the terminal
if ping ${serverHost} -c 1 -W 1 > /dev/null ; then # Can we connect to a box?
# Workbench Server mode
    sudo erwb --benchmark --server ${server} --json c.json
else
    sudo erwb --benchmark --smart Short --stress 1 --json computer.json --submit ${submit}
fi
stty echo
