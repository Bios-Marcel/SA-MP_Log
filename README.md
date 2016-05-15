Hello People,

[B]First of all, i am just renewing my old thread, i have changed a lot of things and kinda want a new thread, and also the thread name pisses me off.[/B]

Thanks to the people that created the dependencies that i use(sscanf, Directory plugin, 
dini(will be replaced with y_ini soon) and zcmd).

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

If you find any Bugs please create a textfile that includes the informations about the bug and upload it here: [Dropbox File Request Link](https://www.dropbox.com/request/9RriFzieyZ5uyTkTKNXF)(No account neccessary).

And if u want to, you can also send in ideas or requests.

filenameformat: log-bug-day-month-year / log-idea-day-month-year / log-request-day-month-year

## Problems:

Well, I kind of am afraid that my filterscript causes performance / memory problems since i a lot of files are being opened and closed very often, so i'd be pleased if the people who use this tell me if it causes problems, if it does i can create an extra version for u that has less possibilites but wont lower the performance (only the memory ^^) like hell.

## Future Plans:
[LIST]
[*]Better Documentation
[*]Improve Performance (Memory usage, cpu time)
[*]Replacing dini with y_ini
[/LIST]

## Download:

Note: The package does include all plugins expect the sscanf.so u gotta get that by yourself and the .dll that i put in there is still version 2.7 (added 2.8.2).If you don't want to download the package, you can still download here on GitHub.

[AMX & PWN & Includes & Plugin](https://dl.dropboxusercontent.com/u/89362253/Log.zip)

## Version:
1.3.0.15 (15.05.2016)

greetings Marcel
