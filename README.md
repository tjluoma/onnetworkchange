# OnNetworkChange

## What is this? ##

A shell script and `launchd` plist for running commands whenever a Mac's network location information is updated.

## What is included? ##

### onnetworkchange-basic.sh

This is a very basic script for you to start with to create your own actions "on network change".

***Note!*** The .plist file (see below) will only run a program called `onnetworkchange.sh` so once you have made your own, be sure to rename it appropriately.

### onnetworkchange.sh

This is a slightly more complicated file, showing some of the more advanced things that you can do with this.

### com.tjluoma.onnetworkchange.plist

This is a `launchd` plist file which tells `launchd` to the run the `onnetworkchange.sh` command any time the folder "/Library/Preferences/SystemConfiguration/" changes (which happens whenever the network settings are changed).

## Installation #

In order for this to work, you must move *two* files to the correct location.

1. A script called **`onnetworkchange.sh`** has to be somewhere in launchd's PATH. To see what `launchd`'s path is, use 

			launchctl getenv PATH

2. Next, the **com.tjluoma.onnetworkchange.plist** file has to be moved to **~/Library/LaunchAgents/**. Once it is in place, tell `launchd` to load it:

		launchctl load ~/Library/LaunchAgents/com.tjluoma.onnetworkchange.plist




