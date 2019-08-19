sudo erwb --benchmark --server http://10.13.37.2:8091 --json computer.json
sudo erwb --benchmark --smart Short --stress 1 --json computer.json --submit http://user@dhub.com:1234@devicehub-teal.ereuse.net
sudo erwb --benchmark --json computer.json
sudo erwb --benchmark --server http://10.13.37.2:8091 --json computer.json
bash debug.sh
me
scp computer.json nad@192.168.1.131:/home/nad/eReuse/snapshot-.json
