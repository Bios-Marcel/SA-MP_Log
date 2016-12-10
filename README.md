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
- PlayerTake(Deal)Damage
- Interior Change(Oldinterior, NewInterior)
- Connect/Disconnect(name,Ip,reason)
- Rcon Login(If the Player enters a wrong password the password would be logged)
- RconCommand(Only Logs the Command)
- PlayerPositionLog(Every 1.5 seconds it logs your position(It has a configurable interval, but the 1.5 second is the default))

## Installation:

1. Download the package
2. insert sscanf and the Directory plugin into your server.cfg `plugin sscanf Directory`
3. insert Log into your server.cfg `filterscripts Log`
4. Start your server

If any errors occur, just ask me for help.

## Configuration:

You can change the configuration per config file which is "Logs\config.cfg" or per /logmenu (Dialog).
Single Commands for all settings are in developement (I am a bit lazy that's why it is still not done).

## Bugs , Requests and Ideas:

If you find any bugs, have ideas for improvment or new features, psot them here: [GitHub Issues Page](https://github.com/Bios-Marcel/SA-MP_Log/issues).

## Problems:

Might cause performance problems on bigger servers depending on the settings that you chose.

## Future Plans:

- Better Documentation
- Functionallity to read logs ingame
- Control everything pee commands

## Version:
1.3.3.3 (10.12.2016)

greetings Marcel
