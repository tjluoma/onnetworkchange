#!/usr/bin/env zsh -f
# perform different tasks when network settings are modified
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2013-05-16

NAME="$0:t:r"


if (( $+commands[growlnotify] ))
then

growlnotify  \
--appIcon "Terminal"  \
--identifier "$NAME"  \
--message "$NAME running at `date`"  \
--title "$NAME"

fi





####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#
#	Do you have an AirPort Extreme or AirPort Express with a hard drive attached?
#
#	If yes, put the names here
#	If not, leave blank

	# You can see the name in AirPort Utility.
	# be sure to change any spaces to -
	# For example if yours is called "AirPort Extreme" then use:
	# 	AIRPORT_BASE_NAME='AirPort-Extreme'
	# Do NOT include the .local here. It will be added where needed
HOME_AIRPORT_BASE_NAME='AirPort-Extreme'

	# What is the drive name? This is the part that shows up in Finder under /Volumes/
# AIRDISK_NAME="DiskName"
HOME_AIRDISK_NAME=''


WORD_AIRPORT_BASE_NAME='Office-Extreme'

HOME_AIRDISK_NAME='WorkDisk'

# @todo - add automount unmount for work and home

#
#	If you enter values for these, then this script will try to mount/unmount the disk automatically when you are home / at work
#

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#	Do you want some apps to launch when you are at work?
#	Do you want some apps to launch when you are at home?
#	Put them in the appropriate list below.
# 	If the app name has spaces, put the whole name in "quotes" such as
#
#	HOME_APPS=(iTunes Twitterrific "Google Chrome")

	# leave the 'typeset' line alone
typeset -a WORK_APPS HOME_APPS

	# These are apps you use at work
WORK_APPS=(OmniFocus MailMate Reeder Safari)

	# These are apps you use at home
HOME_APPS=(iTunes Twitterrific "Google Chrome")

# Note: when you at set to "at work" this script will close your "home" apps, and vice versa. If you want to run them again, just re-launch them.
#
#
####|####|####|####|####|####|####|####|####|####|####|####|####|####|####


#
#	I only want Bluetooth on when I am at the office
#	Note that you will have to install the `blueutil` yourself.
# 	I recommend Homebrew: http://mxcl.github.com/homebrew/

bluetooth_off () {

	if (( $+commands[blueutil] ))
	then
			# https://github.com/toy/blueutil
			# turn bluetooth off
		blueutil power 0

	fi
}

bluetooth_on () {

	if (( $+commands[blueutil] ))
	then
			# https://github.com/toy/blueutil
			# turn bluetooth on
		blueutil power 1
	fi
}

mount_home () {

		# Mount my AirPort Extreme Drive
	open -g -a Finder "afp://$AIRPORT_BASE_NAME.local./$AIRDISK_NAME"
}

unmount_home () {

	while [ -d "/Volumes/$AIRDISK_NAME" ]
	do
				diskutil unmount "/Volumes/$AIRDISK_NAME"
				sleep 10
	done
}

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####

quit_apps () {

for APP_TO_QUIT in "$@"
do

# Check to see if the app is running
ps cx | grep -qiE " ${APP_TO_QUIT}$"

EXIT="$?"

if [ "$EXIT" = "0" ]
then

# if we get here, it is running

/usr/bin/osascript <<EOT
tell application "$APP_TO_QUIT" to quit
EOT

else

echo "	$NAME: $APP_TO_QUIT is not running"

fi

done

}

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####

run_apps () {

for APP_TO_RUN in "$@"
do

# Check to see if the app is running
ps cx | grep -qiE " ${APP_TO_RUN}$"

EXIT="$?"

if [ "$EXIT" = "0" ]
then

		echo "	$NAME: $APP_TO_RUN is already running"
else

		open -g -a ${APP_TO_RUN}
fi

done

}

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
####|####|####|####|####|####|####|####|####|####|####|####|####|####|####



####|####|####|####|####|####|####|####|####|####|####|####|####|####|####



PPID_NAME=$(/bin/ps -cp ${PPID} | awk '{print $NF}')

case "$PPID_NAME" in
	*launchd*)
				LAUNCHD=yes

					# launchd calls this script twice in about 10 seconds.
					# rather than do this all twice, let's hang out

				COUNT=$(ps auxwww | fgrep "$NAME" | fgrep -v "fgrep" | wc -l | tr -dc '[0-9]')

				if [ "$COUNT" -gt "1" ]
				then
							# another copy of this script is already running, let's exit
						exit 0
				else
							# Sometimes this script gets called 2x in about 10-15 seconds
							# so let's pause to a) give the network a chance to get up to speed
							# and b) a second copy, if it run from launchd, will see this one
							# and self-terminate.
						sleep 60
				fi
	;;

	*)
				LAUNCHD=no
	;;

esac

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####

if (( $+commands[ssid.sh] ))
then

SSID=$(ssid.sh)

if [[ "$SSID" == "AirPort: Off" ]]
then

		echo "	$NAME: AirPort (Wi-Fi) is turned off"

elif [[ "$SSID" == "" ]]
then
		echo "	$NAME: AirPort (Wi-Fi) is turned on but this computer is not connected to a Wi-Fi network"

else


		case "$SSID" in

				# Different SSIDs which = "I am at home"
				# Match partials by adding a "*" to front or end

			MyHomeSSID|MyHomeAwayFromHome|ATrustedNetwork)
							bluetooth_on

							mount_home

							quit_apps ${WORK_APPS}

							run_apps ${HOME_APPS}

							(( $+commands[brightness] )) && brightness .5

			;;

				# Different SSIDs which = "I am at work"

			MyWorkSSID|WorkSSID*)
							bluetooth_on

							unmount_home

							run_apps ${WORK_APPS}

							quit_apps ${HOME_APPS}


							(( $+commands[brightness] )) && brightness 1
			;;

			CoffeeHouse)
							bluetooth_off

							unmount_home

							(( $+commands[brightness] )) && brightness .75


			;;

		esac

fi # if an SSID is found


fi # if ssid.sh is found



####|####|####|####|####|####|####|####|####|####|####|####|####|####|####



fini 2>/dev/null || exit
#
#EOF
