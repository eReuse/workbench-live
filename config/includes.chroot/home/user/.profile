# Unncoment to automount NFS
#sudo mount 192.168.1.88:/wbpxe /home/user
submit='https://hello@usody.com:usody@api.usody.com'

stty -echo # Do not show what we type in terminal so it does not meddle with our nice output
setterm -blank 0  # Do not suspend monitor
sudo dmesg -n 1 # Do not report *useless* system messages to the terminal
sudo erwb --debug --benchmark --smart Short --stress 1 --submit ${submit}
stty echo
