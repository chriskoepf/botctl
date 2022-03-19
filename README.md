Botctl consists of a pair of bash scripts that I wrote to start and auto launch my Pycryptobot crypto trading bots.

For now, this is the quick version of the Readme file what is just a duplicate of the Notes and settings variables in the top of each script file.  If there is enough interest and I can find the time, I will attempt to update this file to be a little more detailed.

I provide no warranties for these scripts and they currently require SystemCtl in Linux.  They will NOT work with Init.d or any other system launch apps in Linux or other operating systems.  If someone would like to modify them to work with another launch app, feel free to fork this project.  Conrtibutions are welcomed as well.

See file instructions below.

### launchbots.sh - help text and settings ###

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


### botctl.sh help text and settings ###

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

