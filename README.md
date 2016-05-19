Hello People,

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

## Configuration:

You can change the configuration per config file which is "Logs\config.cfg" or per /logmenu (Dialog).
Single Commands for all settings are in developement (I am a bit lazy that's why it is still not done).

## Bugs , Requests and Ideas:

Well, i found tons of bugs, i fixed a lot of them so pls always update the script.

If you find any Bugs please create a textfile that includes the informations about the bug and upload it here: [Dropbox File Request Link](https://www.dropbox.com/request/9RriFzieyZ5uyTkTKNXF)(No account neccessary) or here [GitHub Issues Page](https://github.com/Bios-Marcel/SA-MP_Log/issues).

And if u want to, you can also send in ideas or requests.

filenameformat: log-bug-day-month-year / log-idea-day-month-year / log-request-day-month-year

## Problems:

Well, I kind of am afraid that my filterscript causes performance / memory problems since i a lot of files are being opened and closed very often, so i'd be pleased if the people who use this tell me if it causes problems, if it does i can create an extra version for u that has less possibilites but wont lower the performance (only the memory ^^) like hell.

## Future Plans:

- Better Documentation
- Improve Performance

## Version:
1.3.1.0.1 (17.05.2016)

greetings Marcel
