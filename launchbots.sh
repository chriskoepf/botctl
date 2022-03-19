#!/bin/bash

# This script is used at system boot to launch all pycryptobots with a small
# delay between each one. The delay is set in the main botctl.sh file.

# Setup and test botctl.sh first, before running this file.  Once that is
# complete, run this file once manually to create the main launch service
# file that will run at boot.

# Once the Systemd script has been created, this file can be editted to add
# or remove exchanges and/or the telgram_bot.py script.

# path to launchbots.sh & botctl.sh files - folder where this file is located
botctlpath="/home/{user}/bots"

# default filenames for botctl and pairs
# if not using pairs.txt, no bots will launch at boot
# you can still launch individual pairs manually via command line
defaultctl="botctl.sh"
defaultprstxt="pairs.txt"

# or set botctl.sh filename and pairs.txt for each exchange
# if not using separately per exchange, leave empty ""
binancectl=""
binanceprstxt=""

coinbaseproctl=""
coinbaseproprstxt=""

kucoinctl=""
kucoinprstxt=""

# Launch Telegram Bot?  1=yes, 0=no
launchtelegrambot=1

# path to SystemD scripts
systemdfolder="/etc/systemd/system"

# main SystemD script filename that will be created to launch this file at boot
sysdbootsvcfile="pycryptobot_launch.service"

# Telegram Bot Systemd script filename that will be created
tgbotfile="tgbot.service"

# pycryptobot path
pycryptobotfolder="/home/{user}/bots/pycryptobot"

#user and group to execute script as
runasuser="{user}"
runasgroup="{group}"

# using an evironment path?  If not, leave empty quotes - environmentpath=""
# Not typically needed, more for advnaced users
environmentpath=""
#environmentpath="PATH=/home/(folder)/.venvs/bin/python3"

# Telegram execution command - will use pycryptobot path above
execstartcmd="/usr/bin/python3 telegram_bot.py"
#execstartcmd='/home/(folder)/.venvs/bin/python3 telegram_bot.py'


############################################################
# Done with settings.  Only edit below if you know what
# you are doing.

# If the launch at boot service doesn't exist, this is the first run, create it
bootlaunchsvc="$systemdfolder/$sysdbootsvcfile"
if [ ! -f "$bootlaunchsvc" ]; then

   	echo "Creating and enabling Main SystemD script used to launch all bots.\n
       It will launch at next and every system boot."

    echo "[Unit]
Description= Pycryptobot - launch bots at boot
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=$botctlpath
ExecStart=sh $botctlpath/launchbots.sh

[Install]
WantedBy=multi-user.target" >> $bootlaunchsvc

  	systemctl daemon-reload
    systemctl enable "$sysdbootsvcfile"
fi  

# is Telegram Bot enabled
if [ $launchtelegrambot = 1 ]; then
    tgbotservice="$systemdfolder/$tgbotfile"
    
    if [ -f "$tgbotservice" ]; then
        systemctl start $tgbotfile

    # if the script doesn't exist, create it
    elif [ ! -f "$tgbotservice" ]; then
        if [ ! -z $environmentpath ]; then
            envvar="Environment=\"$environmentpath\""
        else
            envvar=""
        fi

    	echo "Creating and launching Telegram Bot SystemD script."

        echo "[Unit]
Description=Telegram Bot - Pycryptobot
After=network.target

[Service]
User=$runasuser
Group=$runasgroup
WorkingDirectory=$pycryptobotfolder
$envvar
ExecStart=$execstartcmd
Restart=on-failure

[Install]
WantedBy=multi-user.target" >> $tgbotservice

    	systemctl daemon-reload
        systemctl start "$tgbotfile"
    fi    
fi

# launch bots with default settings
if [ ! -z $defaultctl ] && [ ! -z $defaultprstxt ]; then
    sh $botctlpath/$defaultctl start $botctlpath/$defaultprstxt
fi

# If exchange is configured, launch the bots
if [ ! -z $binancectl ] && [ ! -z $binanceprstxt ]; then
    sh $botctlpath/$binancectl start $botctlpath/$binanceprstxt
fi

if [ ! -z $coinbaseproctl ] && [ ! -z $coinbaseproprstxt ]; then
    sh $botctlpath/$coinbaseproctl start $botctlpath/$coinbaseproprstxt
fi

if [ ! -z $kucoinctl ] && [ ! -z $kucoinprstxt ]; then
    sh $botctlpath/$kucoinctl start $botctlpath/$kucoinprstxt
fi

exit
