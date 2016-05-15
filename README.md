Hello People,

[B]First of all, i am just renewing my old thread, i have changed a lot of things and kinda want a new thread, and also the thread name pisses me off.[/B]

Thanks to the people that created the dependencies that i use(sscanf, Directory plugin, 
dini(will be replaced with y_ini soon) and zcmd).

<span style="text-decoration: underlined; color: red; font-size: 20px;">Description:</span>

This Filterscript is capable of logging:


- Death (playerid,killerid,reason)
- Shooting
<li>Chat</li>
<li>Commands</li>
<li>Enter/Exit Vehicle</li>
<li>PlayerTake(Deal)Damage</li>
<li>Interior Change(Oldinterior, NewInterior)</li>
<li>Connect/Disconnect(name,Ip,reason)</li>
<li>Rcon Login(If the Player enters a wrong password the password would be logged)</li>
<li>RconCommand(Only Logs the Command)</li>
<li>PlayerPositionLog(Every 1.5 seconds it logs your position(It has a configurable interval, but the 1.5 second is the default))</li>
</ul>

[COLOR="Red"][SIZE="7"][U]Installation:[/U][/SIZE][/COLOR]

[LIST=1]
[*]Download the package
[*]insert sscanf and the Directory plugin into your server.cfg
[code]
plugin sscanf Directory
[/code]
[*]insert Log into your server.cfg
[code]
filterscripts Log
[/code]
[/LIST]

[COLOR="Red"][SIZE="7"][U]Configuration:[/U][/SIZE][/COLOR]

You can change the configuration per config file which is "Logs\config.cfg" or per /logmenu (Dialog).
Single Commands for all settings are in developement (I am a bit lazy that's why it is still not done).

[COLOR="Red"][SIZE="7"][U]Bugs , Requests and Ideas:[/U][/SIZE][/COLOR]

Well, i found tons of bugs, i fixed a lot of them so pls always update the script.

If you find any Bugs please create a textfile that includes the informations about the bug and upload it here: [url]https://www.dropbox.com/request/9RriFzieyZ5uyTkTKNXF[/url]
(It is a dropboxfilerequest link , u do NOT NEED AN ACCOUNT)

or post it in this Thread / PM me.

And if u want to, you can also send in ideas or requests.

filenameformat: log-bug-day-month-year / log-idea-day-month-year / log-request-day-month-year

You are asking yourself why am i doing this? Simply cause i do sometimes not check the forum but always check my pc(dropbox).

[COLOR="Red"][SIZE="7"][U]Problems:[/U][/SIZE][/COLOR]

Well, I kind of am afraid that my filterscript causes performance / memory problems since i a lot of files are being opened and closed very often, so i'd be pleased if the people who use this tell me if it causes problems, if it does i can create an extra version for u that has less possibilites but wont lower the performance (only the memory ^^) like hell.

[COLOR="Red"][SIZE="7"][U]Future Plans:[/U][/SIZE][/COLOR]
[LIST]
[*]Better Documentation
[*]Improve Performance (Memory usage, cpu time)
[*]Replacing dini with y_ini
[/LIST]

[COLOR="Red"][SIZE="7"][U]Download:[/U][/SIZE][/COLOR]

Note: The package does include all plugins expect the sscanf.so u gotta get that by yourself and the .dll that i put in there is still version 2.7 (added 2.8.2).

[URL="https://dl.dropboxusercontent.com/u/89362253/Log.zip"][SIZE="5"]AMX & PWN & Includes & Plugin[/SIZE][/URL]

Pastebin:
[url]http://pastebin.com/jpZ3LZdy[/url]

[COLOR="Red"][SIZE="7"][U]Version:[/U][/SIZE][/COLOR]
1.3.0.15 (15.05.2016)

greetings Marcel
