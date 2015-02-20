sudo cp service/apm.service /lib/systemd/system/
systemctl daemon-reload
sudo systemctl start apm.service
echo "APM:Copter app started"
