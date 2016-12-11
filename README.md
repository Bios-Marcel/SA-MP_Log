Thanks to the creators of:
- zcmd
- sscanf
- dini
- Directory plugin
- SA-MP

## Description:

This Filterscript is capable of logging:

- Death (playerid,killerid,reason)
- Shooting
- Chat
- Commands
- Enter/Exit Vehicle
- PlayerTake/DealDamage
- Interior Change(Oldinterior, NewInterior)
- Connect/Disconnect(name,Ip,reason);
- Rcon Login(Wrong/successful)
- PlayerPosition(logs each players position every 3 seconds by default)

## Installation:

1. Download the package
2. Put sscanf and Directory into the plugins folder
3. Put Log.amx into your filterscripts folder
4. insert sscanf and the Directory plugin into your server.cfg `plugins sscanf Directory`
5. insert Log into your server.cfg `filterscripts Log`
6. Start your server

If any errors occur, just [ask for my help](marceloschr@googlemail.com).

## Configuration:

You can change the configuration per config file which is "Logs\config.cfg" or per /logmenu (Dialog).
Single Commands for all settings are in developement (I am a bit lazy that's why it is still not done).

## Bugs , Requests and Ideas:

You
- found Bugs
- have ideas for improvment
- want new features
Post them here: [GitHub Issues Page](https://github.com/Bios-Marcel/SA-MP_Log/issues).

## Problems:

This script might cause performance problems on bigger servers depending on the settings that you chose.

## Future Plans:

- Better documentation
- Functionallity to read logs ingame
- Control everything per commands
