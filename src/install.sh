sudo cp service/apm.service /lib/systemd/system/
systemctl daemon-reload
sudo systemctl enable apm.service
echo "APM:Copter app enabled"
