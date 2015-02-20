#!/bin/bash

#This script is launched automatically in Erle-Brain
#on every boot and loads everything that the board needs to
#act as an autopilot. The COPY_CAPES environment variable copies
#the capies on every boot if set to 1. The COMPANION flag helps
#setting up a companion computer.
#
# Victor Mayoral Vilches - Erle Robotics [victor@erlerobot.com]

# R/W file system
mount -o remount,rw  /

# Remove the lease file
rm /var/lib/misc/dnsmasq.leases 

# Start the wireless interfacew
#sudo service dnsmasq start
hostapd /etc/hostapd/hostapd.conf & 

# Cape source location
LOCATION="/home/ubuntu/ardupilot/Tools/Linux_HAL_Essentials"

# Copy capes
COPY_CAPES=0

# Companion computer
COMPANION=0

if (($COPY_CAPES == 1)); then 
	cp $LOCATION/BB-SPI0-PXF-01-00A0.dtbo /lib/firmware/
	cp $LOCATION/BB-SPI1-PXF-01-00A0.dtbo /lib/firmware/
	cp $LOCATION/BB-BONE-PRU-05-00A0.dtbo /lib/firmware/
	cp $LOCATION/rcinpru0 /lib/firmware
	cp $LOCATION/pwmpru1 /lib/firmware
fi 

if (($COMPANION == 1)); then 
	ifconfig eth0 up
	#ifconfig eth0 192.168.9.2
fi 

# Loading the capes
echo BB-BONE-PRU-05 > /sys/devices/bone_capemgr.*/slots
echo BB-SPI0-PXF-01 > /sys/devices/bone_capemgr.*/slots
echo BB-SPI1-PXF-01 > /sys/devices/bone_capemgr.*/slots
echo BB-UART5 > /sys/devices/bone_capemgr.*/slots
echo BB-UART4 > /sys/devices/bone_capemgr.*/slots
echo BB-UART2 > /sys/devices/bone_capemgr.*/slots
echo am33xx_pwm > /sys/devices/bone_capemgr.*/slots
echo bone_pwm_P8_36 > /sys/devices/bone_capemgr.*/slots
echo BB-ADC   > /sys/devices/bone_capemgr.*/slots

# Line for making PREEMPT_RT work
#echo 0:rcinpru0 > /sys/devices/ocp.3/4a300000.prurproc/load

# Logging
dmesg | grep "SPI"
dmesg | grep "PRU"
cat /sys/devices/bone_capemgr.*/slots

# Give the system time to load all the capes
#   experienced has proved that generally the buzzer needs some time
sleep 1

##################
# ROS
##################
# Load ROS environment
#source /opt/ros/hydro/setup.bash

# Launch ROS and wait for 5s while it initializes
#date >> ~/logs/roscore.log
#roscore & >> ~/logs/roscore.log 2>&1
#sleep 5

# Launch mavros
#date >> ~/logs/mavros.log
#rosrun mavros mavros_node _fcu_url:="udp://:6000@" & >> ~/logs/mavros.log 2>1&

# Set CPU at max speed
#cpufreq-set -g performance
cpufreq-set -f 1000MHz

# sleep 2 seconds and wait to set up freq. scaling
sleep 2

cd /apps/erle-apm-copter.erle/current/src
(
    date
    #init 3
    #killall -q udhcpd
    while :; do
	# Set CPU at max speed
	#cpufreq-set -g performance
	cpufreq-set -f 1000MHz
	# Start copter, modify if other vehicle is needed
	#./ArduCopter.elf -A /dev/ttyUSB0 -B /dev/ttyO5 -C udp:11.0.0.2:6000
	#./ArduCopter.elf -A udp:192.168.7.1:6000 -B /dev/ttyO5
	#./ArduCopter.elf -A udp:11.0.0.2:6000 -B /dev/ttyO5
	./ArduCopter.elf -A udp:10.0.0.2:6000 -B /dev/ttyO5
	#./ArduCopter.elf -A udp:11.0.0.2:6000 -B /dev/ttyO5 -C /dev/ttyO4
        #./ArduCopter.elf -A /dev/ttyO0 -B /dev/ttyO5
	#./ArduCopter.elf -A tcp:*:6000:wait -B /dev/ttyO5
	#./ArduCopter.elf -B /dev/ttyO5
	#./ArduCopter.elf -A udp:11.0.0.2:6000 -B /dev/ttyO5 -C udp:127.0.0.1:6000
	#./ArduCopter.elf -A udp:11.0.0.2:6000 -B /dev/ttyO5 -C udp:127.0.0.1:6000
    done
) 
# >> ~/logs/copter.log 2>&1

