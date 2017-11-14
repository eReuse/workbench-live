sudo systemctl daemon-reload
sudo systemctl start workbench-usb.service
sudo systemctl start workbench-data.service
sudo erwb --settings /media/ereuse-data/config.ini --inventory /media/ereuse-data/inventory
cat .erwb-help
