#!/bin/bash


#################### Instructions ####################

# Command to launch single pair:   sudo sh /{folder}/botctl.sh start|stop|restart|remove|update {BASE}-{QUOTE}-{2ltExch}
# Example for start:   sudo sh botctl.sh start ADA-USDT

# Command to launch multiple pairs from a text file:   sudo sh /{folder}/botctl.sh start|stop|restart|remove|update {pairsfilename}
# Example for start:   sudo sh /home/bots/botctl.sh start pairs.txt

# start will check files (create if needed) and launch bot, stop will stop running bot, restart will stop and start bot
# remove will stop and remove SystemD file for bot, update will update start script with any changes made (eg. cli options)

# This script will NOT touch your config files or anything in the pycryptobot directory.
# It is only desgined to create and enable a SystemD startup script for the bot you specify
# and then you can use it to start and stop a bot by just specifying the pair which
# is a little less than using the SystemD commands

# You can still use systemctl to start, stop, enable and disable as normal for any script created

# Recommended pair filename configuration used for config and systemd: BASE-QUOTE   -or-    ADA-USDT
# The pair filename will be used as the market started and to search for a custom config.json file (base-quote.json)
# To start a single pair use the below command:
# 	 sudo sh botctl.sh start ADA-USDT

# text file with pairs should only have 1 pair per line and any additional command line parameters.
# when sharing the main config.json in pycryptobot folder, you HAVE to specify the exchange option
# Examples:
# ADA-USDT --buymaxsize 100 --sellatloss 1
# ADA-USD --exchange coinbasepro --api_key_file /path/filename
# ETH-GBP

# If you do not have a config file named as described, this script will use the default config.json in the path you specify
# below.  If no custom config.json or default file exists, it will throw an error.

### *** NOTE *** ###
# If your OS is Ubuntu, to use this script you will need to make a change to DASH shell.
# Run this command:  sudo dpkg-reconfigure dash
# When asked whether to link "sh" to "dash", choose "no"

#################################################################
# Edit Required variables below
#################################################################

## Pycryptobot settings ##

# specify quote currency below to launch with just the base:  botctl.sh start ADA
# Script will append the two automatically.
# ***ONLY do this if running single exchange with botctl.sh or you have multiple botctl.sh files
# If you use multiple quote currencies, just leave quote blank:  quote=""
quote=""
# pause is the number of seconds to use between launch of multiple bots
pause=3 # recommended
# folder for custom config files if desired
cfgfolder="/home/{user}/bots/cfgs"
# base filename for custom config file - eg. enter ".json" part of this:  {pair}.json
cfgbasename=".json"
# pycryptobot install folder - location of main script
pycryptobotfolder="/home/(user)/bots/pycryptobot"
# default config file in pycryptobot folder - can use this for any bot that does NOT have custom file above
# does NOT have to be config.json, but does have to have .json extension
defaultcfg="config.json"

## SystemD settings ##

# path to SystemD scripts
systemdfolder="/etc/systemd/system"
# SystemD script filename, will add pair (base and quote) to the front.
# Can be just ".service"
svcfile=".service"
# run script as user and group
runasuser="{user}"
runasgroup="{group}"
# using an evironment path?  If not, leave empty quotes - environmentpath=""
#environmentpath="PATH=/home/(folder)/.venvs/bin/python3"
# not required, more for advanced users
environmentpath=""
# main execution command - can be as simple as    "python3 /path/pycryptobot.py"
# config file added automatically as a command line argument.
# Additional arguments can be added when calling botctl.sh or in mypairs.txt file
#execstartcmd="/home/(folder)/.venvs/bin/python3 pycryptobot.py"
execstartcmd="/usr/bin/python3 pycryptobot.py"


#################################################################
# Stop editting variables
#################################################################

## Script starts here, only edit below if you know what you are doing.

# make sure system is using SystemD before continuing
if [ ! -d /run/systemd/system ]; then
	echo "Currently this script only works with SystemD, which is not installed on your system.  Sorry."
	exit
fi

# Create the main function
runpair() {

	# setup config filenames
	cfgfile="$cfgfolder/$pair$cfgbasename"
	defaultcfgfile="$pycryptobotfolder/$defaultcfg"

	# does config file exist or is there a default config?
	if [ -f "$cfgfile" ]; then
		args="--config $cfgfile --market $pair$cmdvars"
	elif [ -f "$defaultcfgfile" ]; then
	    args="--market $pair$cmdvars"
	else
	    echo "No default config or custom config file for $pair does not exist."
	    return
	fi

	## if SystemD script doesn't exist, create it
	sysdfilename="$pair$svcfile"
	systemdfile="$systemdfolder/$sysdfilename"
    if [[ $environmentpath != "" ]]; then
        envvar="Environment=\"$environmentpath\""
    else
        envvar=""
    fi

	## Create and Setup SystemD script
if [ ! -f "$systemdfile" ] && ([ $cmd == 'start' ] || [ $cmd == 'restart' ]); then
	createsysd
	sleep 1
fi

	## start/restart/stop/enable/disable/remove the bots
	if [ $cmd = "start" ]; then
		echo "starting $sysdfilename"
		systemctl start "$sysdfilename"
	elif [ $cmd = "stop" ]; then
		echo "stopping $sysdfilename"
		systemctl stop "$sysdfilename"
	elif [ $cmd = "restart" ]; then
		echo "restarting $sysdfilename"
		systemctl restart "$sysdfilename"
	elif [ $cmd = "remove" ]; then
		echo "removing $sysdfilename"
		systemctl stop "$sysdfilename"
		rm -f "$systemdfile"
		systemctl daemon-reload
	elif [ $cmd = "update" ]; then
		echo "updating $sysdfilename"
		systemctl stop "$sysdfilename"
		echo "removing previous $sysdfilename"
		rm -f "$systemdfile"
		createsysd
		echo "restarting $sysdfilename"
		systemctl start "$sysdfilename"
	else
		echo "No command or incorrect command variable entered. $1 was entered"
	fi
}

createsysd() {
		echo "Creating SystemD script: $systemdfile"

        echo "[Unit]
Description=PyCryptobot - $pair
After=network.target

[Service]
User=$runasuser
Group=$runasgroup
WorkingDirectory=$pycryptobotfolder
$envvar
ExecStart=$execstartcmd $args
Restart=always

[Install]
WantedBy=multi-user.target" >> $systemdfile

	systemctl daemon-reload
	sleep 1

}

# let's do some checks and then call function based on results

# make sure a command was passed
if [ $1 != 'start' ]  && [ $1 != 'stop' ] && [ $1 != 'restart' ] && [ $1 != 'remove' ] && [ $1 != 'update' ]; then
        echo "First option needs to be a command - start | stop | restart | remove | update"
        exit
fi

cmd="$1"

if [[ $quote != "" ]]; then
	quote="-$quote"
fi

# check for pairs file or a single pair
if [ -f "$2" ]; then
	readarray -t filearr<$2
	for i in "${filearr[@]}"
	do
		c=1
		cmdvars=""
		IFS=' '
		read -a line<<<"$i" 
		for d in "${line[@]}"
		do
			if [ $c = 1 ]; then
				pair="$d$quote"
			else
				cmdvars+=" $d"
			fi
			c=$((c+1))
		done
		echo "$pair$cmdvars"
		runpair
		sleep "$pause"
	done
	exit

else
	# single pair
	pair="$2$quote"
	cmdvars=""
	c=1
	for i in $@ 
		do
			if [ $c -gt 2 ]; then
				cmdvars="$cmdvars $i"
			fi
		    c=$((c+1))
	done
	echo "$pair$cmdvars"
	runpair
fi

exit