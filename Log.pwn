//Log Filterscript by [Bios]Marcel
//If you need any help at working on this script you can message me on forum.sa-mp.com (http://forum.sa-mp.com/member.php?u=172637)
#define FILTERSCRIPT

//INCLUDES
#include <a_samp>
#include <Directory>
#include <Dini>
#include <a_http>
#include <zcmd>
#include <sscanf2>

//DEFINES
#define LOGMENU 1
#define LOGCONFIG 2
#define SAVEMODE2_CHOOSEPLAYER 3
#define SAVEMODE3_CLEAN 4
#define SAVEMODE4_CHOOSE 5
#define S4_CLEAN_POSITION 6
#define S4_CLEAN_CHAT 7
#define S4_CLEAN_COMMAND 8
#define S4_CLEAN_SHOOTING 9
#define S4_CLEAN_DEATH 10
#define S4_CLEAN_CONNECT 11
#define S4_CLEAN_DISCONNECT 12
#define S4_CLEAN_INTERIOR 13
#define S4_CLEAN_RCONLOGIN 14
#define S4_CLEAN_CARENTER 15
#define S4_CLEAN_CAREXIT 16
#define S4_CLEAN_RCONCOMMAND 17
#define POSLOGINT 18
#define SAVEMODE1_CHOOSEPLAYER 19
#define SAVEMODE1_CHOOSELOG 20
#define SETPOSLOGINTERVAL 21

#define CULPRIT 1
#define VICTIM 2

#define CONFIG_FILE "Logs/Config.cfg"
#define ERROR_LOG_FILE "Logs/ErrorLog.log"

#define BYTES_PER_CELL 4


//PUBLIC VARIABLES
new saveTime = 0;
new positionLogging;
new chatLogging;
new commandLogging;
new shootingLogging;
new deathLogging;
new connectLogging;
new disconnectLogging;
new interiorLogging;
new rconLoginLogging;
new carEnterLogging;
new carExitLogging;
new rconCommandLogging;
new saveMode;
new timer[MAX_PLAYERS];

//PUBLICS (default)
public OnFilterScriptInit()
{
	print("[Logging System] Log Filterscript loaded.");
	checkVersion();
	DirCreate("Logs");
	
	if(!fexist(ERROR_LOG_FILE))
	{
	    dini_Create(ERROR_LOG_FILE);
	}
	
	//Before the config was called "config.cfg" it was called "LogConfig.cfg" , since i dont want to ruin your settigns i am checking for the old file to transfer it
	if(fexist("Logs/LogConfig.cfg"))
	{
		if(!fexist(CONFIG_FILE))
		{
			dini_Create(CONFIG_FILE);
			dini_IntSet(CONFIG_FILE, "PositionLogging", dini_Int("Logs/LogConfig.cfg", "PositionLogging"));
			dini_IntSet(CONFIG_FILE, "ChatLogging", dini_Int("Logs/LogConfig.cfg", "ChatLogging"));
			dini_IntSet(CONFIG_FILE, "CommandLogging", dini_Int("Logs/LogConfig.cfg", "CommandLogging"));
			dini_IntSet(CONFIG_FILE, "ShootingLogging", dini_Int("Logs/LogConfig.cfg", "ShootingLogging"));
			dini_IntSet(CONFIG_FILE, "DeathLogging", dini_Int("Logs/LogConfig.cfg", "DeathLogging"));
			dini_IntSet(CONFIG_FILE, "ConnectLogging", dini_Int("Logs/LogConfig.cfg", "ConnectLogging"));
			dini_IntSet(CONFIG_FILE, "DisconnectLogging", dini_Int("Logs/LogConfig.cfg", "DisconnectLogging"));
			dini_IntSet(CONFIG_FILE, "InteriorLogging", dini_Int("Logs/LogConfig.cfg", "InteriorLogging"));
			dini_IntSet(CONFIG_FILE, "RconLoginLogging", dini_Int("Logs/LogConfig.cfg", "RconLoginLogging"));
			dini_IntSet(CONFIG_FILE, "CarEnterLogging", dini_Int("Logs/LogConfig.cfg", "CarEnterLogging"));
			dini_IntSet(CONFIG_FILE, "CarExitLogging", dini_Int("Logs/LogConfig.cfg", "CarExitLogging"));
			dini_IntSet(CONFIG_FILE, "RconCommandLogging", dini_Int("Logs/LogConfig.cfg", "RconCommandLogging"));
			dini_IntSet(CONFIG_FILE, "SaveMode", dini_Int("Logs/LogConfig.cfg", "SaveMode"));
			dini_Set(CONFIG_FILE, "LogFilesPerX", "no");
			dini_IntSet(CONFIG_FILE, "PositionLogInterval", dini_Int("Logs/LogConfig.cfg", "PositionLogInterval"));
		}
	}
	if(dini_Create(CONFIG_FILE))
	{
		dini_IntSet(CONFIG_FILE, "PositionLogging", 1);
		dini_IntSet(CONFIG_FILE, "ChatLogging", 1);
		dini_IntSet(CONFIG_FILE, "CommandLogging", 1);
		dini_IntSet(CONFIG_FILE, "ShootingLogging", 1);
		dini_IntSet(CONFIG_FILE, "DeathLogging", 1);
		dini_IntSet(CONFIG_FILE, "ConnectLogging", 1);
		dini_IntSet(CONFIG_FILE, "DisconnectLogging", 1);
		dini_IntSet(CONFIG_FILE, "InteriorLogging", 1);
		dini_IntSet(CONFIG_FILE, "RconLoginLogging", 1);
		dini_IntSet(CONFIG_FILE, "CarEnterLogging", 1);
		dini_IntSet(CONFIG_FILE, "CarExitLogging", 1);
		dini_IntSet(CONFIG_FILE, "RconCommandLogging", 1);
		dini_IntSet(CONFIG_FILE, "SaveMode", 1);
		dini_Set(CONFIG_FILE, "LogFilesPerX", "no");
		dini_IntSet(CONFIG_FILE, "PositionLogInterval", 1500);
	}
	loadConfig();
	if((saveMode > 4) || (saveMode < 1))
	{
		dini_IntSet(CONFIG_FILE, "saveMode", 1);
		print("[Logging System]The savemode was automatically set to 1 since it wasn't in range of 1 and 4.");
	}
	if(saveMode == 4)
	{
		dini_Create("Logs/Chat.log");
		dini_Create("Logs/Command.log");
		dini_Create("Logs/Connect.log");
		dini_Create("Logs/Death.log");
		dini_Create("Logs/Disconnect.log");
		dini_Create("Logs/Interior.log");
		dini_Create("Logs/CarEnter.log");
		dini_Create("Logs/CarExit.log");
		dini_Create("Logs/Shooting.log");
		dini_Create("Logs/RconLogin.log");
		dini_Create("Logs/Position.log");
	}
	if(rconCommandLogging)
	{
		if(saveMode != 3)
		{
			dini_Create("Logs/RconCommand.log");
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	if(rconLoginLogging)
	{
		new IP[16];
		for(new i=0; i<MAX_PLAYERS; i++)
		{
			GetPlayerIp(i, IP, 16);
			if(!strcmp(ip, IP, true))
			{
				logRconLogin(i, success ? true : false, ip, password);
				break;
			}
		}
	}
	return 1;
}

public OnRconCommand(cmd[])
{
	printf("RCON: %s", cmd);
	logRconCommand(cmd);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(positionLogging)
	{
		//Killing the Timer to prevent any bugs
	    KillTimer(timer[playerid]);
		timer[playerid] = SetTimerEx("LogLoc", dini_Int(CONFIG_FILE, "PosiotionLogInterval"), true, "i", playerid);
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(shootingLogging)
	{
		logShooting(playerid, issuerid, amount, weaponid, CULPRIT);
		logShooting(issuerid, playerid, amount, weaponid, VICTIM);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(saveMode == 1)
	{
		new path[40];
		format(path, 40, "Logs/%s", getName(playerid));
		DirCreate(path);
	}
	else if(saveMode == 2)
	{
		new path[44];
		format(path, 44, "Logs/%s.log", getName(playerid));
		dini_Create(path);
	}
	if(connectLogging)
	{
		logConnect(playerid);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(timer[playerid]);
	if(disconnectLogging)
	{
	    logDisconnect(playerid, reason);
	}
 	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	KillTimer(timer[playerid]);
	if(deathLogging)
	{
		if(killerid != INVALID_PLAYER_ID)
		{
			logDeath(playerid, killerid, reason, VICTIM);
			logDeath(killerid, playerid, reason, CULPRIT);
		}
		else
		{
		    logDeath(playerid, -1, reason, 0);
		}
	}

}

public OnPlayerText(playerid, text[])
{
	if(chatLogging)
	{
		logChat(playerid, text);
	}
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[])
{
	if(commandLogging)
	{
		logCommand(playerid, cmdtext);
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(carEnterLogging)
	{
		SetTimerEx("LogCar", 3000, false, "i", playerid);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(carExitLogging)
	{
		logExitingVehicle(playerid, GetPlayerVehicleSeat(playerid), vehicleid, GetVehicleModel(vehicleid));
	}
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if(interiorLogging)
	{
		logInteriorChange(playerid, newinteriorid, oldinteriorid);
	}
	return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new gPath[70];
	switch(dialogid)
	{
		case LOGMENU:
		{
			if(response)
			{
				if(listitem == 0)
				{
					updateAndShowLogConfigDialog(playerid);
				}
				else
				{
					if(saveTime == 0)
					{
						showLogCleanDialog(playerid);
					}
					else
					{
						SendClientMessage(playerid, -1, "[Logging System] You can't use this function since you are using the function to save logfiles hourly/daily/monthly/yearly.CreateActor (Will be added in alter patches)");
					}
				}
			}
		}
		case SAVEMODE1_CHOOSEPLAYER:
		{
			if(response)
			{
				new path[70];
				format(path, 70, "Logs/%s", inputtext);
				if(CheckPath(path))
				{
					gPath = path;
					ShowPlayerDialog(playerid, SAVEMODE1_CHOOSELOG, DIALOG_STYLE_LIST, "Log clean (Step 2)", "Position log\nChat log\nCommand log\nShooting log\nDeath log\nConnect log\nDisconnect log\nInterior log\n Rcon login log\nCarEnter log\nCarExit log", "Confirm", "Back");
				}
			}
			else
			{
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
		}
		case SAVEMODE1_CHOOSELOG:
		{
			if(response)
			{
				new path[75];
				switch(listitem)
				{
					case 0:
					{
						format(path, 75, "%s/Position.log", gPath);
					}
					case 1:
					{
						format(path, 75, "%s/Chat.log", gPath);
					}
					case 2:
					{
						format(path, 75, "%s/Command.log", gPath);
					}
					case 3:
					{
						format(path, 75, "%s/Shooting.log", gPath);
					}
					case 4:
					{
						format(path, 75, "%s/Death.log", gPath);
					}
					case 5:
					{
						format(path, 75, "%s/Connect.log", gPath);
					}
					case 6:
					{
						format(path, 75, "%s/Disconnecct.log", gPath);
					}
					case 7:
					{
						format(path, 75, "%s/Interior.log", gPath);
					}
					case 8:
					{
						format(path, 75, "%s/RconLogin.log", gPath);
					}
					case 9:
					{
						format(path, 75, "%s/CarEnter.log", gPath);
					}
					case 10:
					{
						format(path, 75, "%s/CarExit.log", gPath);
					}
				}
				eraseFile(path);
			}
			else
			{
				ShowPlayerDialog(playerid, SAVEMODE1_CHOOSEPLAYER, DIALOG_STYLE_INPUT, "Log clean", "Choose a player to delete his logfiles(You will choose the specific log afterwards)", "Confirm", "Back");
			}
		 }
		case SAVEMODE2_CHOOSEPLAYER:
		{
			if(response)
			{
				new path[70];
				format(path, 70, "Logs/%s.log", inputtext);
				if(!fexist(path))
				{
					ShowPlayerDialog(playerid, SAVEMODE2_CHOOSEPLAYER, DIALOG_STYLE_INPUT, "Log clean", "Which Player File should be cleaned?\n(The Full Playername not PlayerID)", "Confirm", "Back");
					GameTextForPlayer(playerid, "Invalid Playername! (Watch out for case sensitive)", 3000, 5);
				}
				else
				{
					eraseFile(path);
					new successMessage[70];
					format(successMessage, 70, "%s's Log was cleaned successful.", inputtext);
					GameTextForPlayer(playerid, successMessage, 3000, 5);
					ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
				}
			}
			else
			{
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
		}
		case SAVEMODE3_CLEAN:
		{
			if(response)
			{
				eraseFile("Logs/Log.log");
				GameTextForPlayer(playerid, "log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
		}
		case S4_CLEAN_CHAT:
		{
			if(response)
			{
				eraseFile("Logs/Chat.log");
				GameTextForPlayer(playerid, "Chat log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_COMMAND:
		{
			if(response)
			{
				eraseFile("Logs/Command.log");
				GameTextForPlayer(playerid, "Command log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_SHOOTING:
		{
			if(response)
			{
				eraseFile("Logs/Shooting.log");
				GameTextForPlayer(playerid, "Shooting log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_DEATH:
		{
			if(response)
			{
				eraseFile("Logs/Death.log");
				GameTextForPlayer(playerid, "Death log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_CONNECT:
		{
			if(response)
			{
				eraseFile("Logs/Connect.log");
				GameTextForPlayer(playerid, "Connect log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_DISCONNECT:
		{
			if(response)
			{
				eraseFile("Logs/Disconnect.log");
				GameTextForPlayer(playerid, "Disconnect log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_POSITION:
		{
			if(response)
			{
				eraseFile("Logs/Position.log");
				GameTextForPlayer(playerid, "Position log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_INTERIOR:
		{
			if(response)
			{
				eraseFile("Logs/Interior.log");
				GameTextForPlayer(playerid, "Interior log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_RCONLOGIN:
		{
			if(response)
			{
				eraseFile("Logs/RconLogin.log");
				GameTextForPlayer(playerid, "RconLogin log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_CARENTER:
		{
			if(response)
			{
				eraseFile("Logs/CarEnter.log");
				GameTextForPlayer(playerid, "CarEnter log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_CAREXIT:
		{
			if(response)
			{
				eraseFile("Logs/CarExit.log");
				GameTextForPlayer(playerid, "CarExit log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case S4_CLEAN_RCONCOMMAND:
		{
			if(response)
			{
				eraseFile("Logs/RconCommand.log");
				GameTextForPlayer(playerid, "RconCommand log cleaned successful.", 3000, 5);
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
			else
			{
				getLogSizes(playerid);
			}
		}
		case SAVEMODE4_CHOOSE:
		{
			if(response)
			{
				cleanLog(playerid, listitem);
			}
			else
			{
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
		}
		case LOGCONFIG:
		{
			if(response)
			{
				switch(listitem)
				{
				    case 0:
					{
						positionLogging = !positionLogging;
						dini_IntSet(CONFIG_FILE, "PositionLogging", !positionLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 1:
					{
						chatLogging = !chatLogging;
						dini_IntSet(CONFIG_FILE, "ChatLogging", !chatLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 2:
					{
						commandLogging = !commandLogging;
						dini_IntSet(CONFIG_FILE, "CommandLogging", !commandLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 3:
					{
						shootingLogging = !shootingLogging;
						dini_IntSet(CONFIG_FILE, "ShootingLogging", !shootingLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 4:
					{
						deathLogging = !deathLogging;
						dini_IntSet(CONFIG_FILE, "DeathLogging", !deathLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 5:
					{
						connectLogging = !connectLogging;
						dini_IntSet(CONFIG_FILE, "ConnectLogging", !connectLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 6:
					{
						disconnectLogging = !disconnectLogging;
						dini_IntSet(CONFIG_FILE, "DisconnectLogging", !disconnectLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 7:
					{
						interiorLogging = !interiorLogging;
						dini_IntSet(CONFIG_FILE, "InteriorLogging", !interiorLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 8:
					{
						rconLoginLogging = !rconLoginLogging;
						dini_IntSet(CONFIG_FILE, "RconLoginLogging", !rconLoginLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 9:
					{
						carEnterLogging = !carEnterLogging;
						dini_IntSet(CONFIG_FILE, "CarEnterLogging", !carEnterLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 10:
					{
						carExitLogging = !carExitLogging;
						dini_IntSet(CONFIG_FILE, "CarExitLogging", !carExitLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 11:
					{
						rconCommandLogging = !rconCommandLogging;
						dini_IntSet(CONFIG_FILE, "RconCommandLogging", !rconCommandLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 12:
					{
						saveMode++;
						if(saveMode >= 5)
						{
							saveMode = 1;
						}
						dini_IntSet(CONFIG_FILE, "SaveMode", saveMode);
						updateAndShowLogConfigDialog(playerid);
					}
					case 13:
					{
						saveTime++;
						if(saveTime >= 5)
						{
							saveTime = 0;
						}
						dini_IntSet(CONFIG_FILE, "LogFilesPerX", saveTime);
						updateAndShowLogConfigDialog(playerid);
					}
					case 14:
					{
	    				ShowPlayerDialog(playerid, POSLOGINT, DIALOG_STYLE_INPUT, "Position Log Interval", "Enter a Interval for the player position logging.\nIf u enter a too low interval it may cause problems.\nThe format is milliseconds.", "Select", "Back");
					}
					//CASE 15 existiert nicht da dort eine Leere Spalte ist welche keine Funktion haben soll.
					/*case 15:
					{
					}*/
					case 16:
					{
						positionLogging = 0;
						dini_IntSet(CONFIG_FILE, "PositionLogging", 0);
						chatLogging = 0;
						dini_IntSet(CONFIG_FILE, "ChatLogging", 0);
						connectLogging = 0;
						dini_IntSet(CONFIG_FILE, "ConnectLogging", 0);
						disconnectLogging = 0;
						dini_IntSet(CONFIG_FILE, "DisconnectLogging", 0);
						shootingLogging = 0;
						dini_IntSet(CONFIG_FILE, "ShootingLogging", 0);
						deathLogging = 0;
						dini_IntSet(CONFIG_FILE, "DeathLogging", 0);
						rconLoginLogging = 0;
						dini_IntSet(CONFIG_FILE, "RconLoginLogging", 0);
						interiorLogging = 0;
						dini_IntSet(CONFIG_FILE, "InteriorLogging", 0);
						carEnterLogging = 0;
						dini_IntSet(CONFIG_FILE, "CarEnterLogging", 0);
						carExitLogging = 0;
						dini_IntSet(CONFIG_FILE, "CarExitLogging", 0);
						commandLogging = 0;
						dini_IntSet(CONFIG_FILE, "CommandLogging", 0);
						rconCommandLogging = 0;
						dini_IntSet(CONFIG_FILE, "RconCommandLogging", 0);
						updateAndShowLogConfigDialog(playerid);
					}
					case 17:
					{
						positionLogging = 1;
						dini_IntSet(CONFIG_FILE, "PositionLogging", 1);
						chatLogging = 1;
						dini_IntSet(CONFIG_FILE, "ChatLogging", 1);
						connectLogging = 1;
						dini_IntSet(CONFIG_FILE, "ConnectLogging", 1);
						disconnectLogging = 1;
						dini_IntSet(CONFIG_FILE, "DisconnectLogging", 1);
						shootingLogging = 1;
						dini_IntSet(CONFIG_FILE, "ShootingLogging", 1);
						deathLogging = 1;
						dini_IntSet(CONFIG_FILE, "DeathLogging", 1);
						rconLoginLogging = 1;
						dini_IntSet(CONFIG_FILE, "RconLoginLogging", 1);
						interiorLogging = 1;
						dini_IntSet(CONFIG_FILE, "InteriorLogging", 1);
						carEnterLogging = 1;
						dini_IntSet(CONFIG_FILE, "CarEnterLogging", 1);
						carExitLogging = 1;
						dini_IntSet(CONFIG_FILE, "CarExitLogging", 1);
						commandLogging = 1;
						dini_IntSet(CONFIG_FILE, "CommandLogging", 1);
						rconCommandLogging = 1;
						dini_IntSet(CONFIG_FILE, "RconCommandLogging", 1);
						updateAndShowLogConfigDialog(playerid);
					}
				}
			}
			else
			{
				ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
			}
		}
		case POSLOGINT:
		{
			if(response)
			{
				if(isNumeric(inputtext))
				{
					dini_IntSet(CONFIG_FILE, "PositionLogInterval", strval(inputtext));
				}
				else
				{
					ShowPlayerDialog(playerid, POSLOGINT, DIALOG_STYLE_INPUT, "Position Log Interval", "The text that u entered was no number.\n\nEnter a Interval for the player position logging.\nIf u enter a too low interval it may cause problems.\nThe format is milliseconds.", "Select", "Back");
				}
			}
			else
			{
				updateAndShowLogConfigDialog(playerid);
			}
		}
	}
	return 1;
}

//FUNCTIONS

SendClientMessageFormatted(playerid, color, fstring[], {Float, _}:...)
{
    static const STATIC_ARGS = 3;
    new n = (numargs() - STATIC_ARGS) * BYTES_PER_CELL;
    if(n)
    {
        new message[144], arg_start, arg_end;
        #emit CONST.alt        fstring
        #emit LCTRL          5
        #emit ADD
        #emit STOR.S.pri        arg_start

        #emit LOAD.S.alt        n
        #emit ADD
        #emit STOR.S.pri        arg_end
        do
        {
            #emit LOAD.I
            #emit PUSH.pri
            arg_end -= BYTES_PER_CELL;
            #emit LOAD.S.pri      arg_end
        }
        while(arg_end > arg_start);

        #emit PUSH.S          fstring
        #emit PUSH.C          144
        #emit PUSH.ADR         message

        n += BYTES_PER_CELL * 3;
        #emit PUSH.S          n
        #emit SYSREQ.C         format

        n += BYTES_PER_CELL;
        #emit LCTRL          4
        #emit LOAD.S.alt        n
        #emit ADD
        #emit SCTRL          4

        if(playerid == INVALID_PLAYER_ID)
        {
            #pragma unused playerid
            return SendClientMessageToAll(color, message);
        } else {
            return SendClientMessage(playerid, color, message);
        }
    } else {
        if(playerid == INVALID_PLAYER_ID)
        {
            #pragma unused playerid
            return SendClientMessageToAll(color, fstring);
        } else {
            return SendClientMessage(playerid, color, fstring);
        }
    }
}

/**
 * Enabled / disables the given log
 *
 * playerid playerid that receives the message
 * logId the log that is to deactivate/activate
 * status status on or off (1 or 0)
**/
setLogStatus(playerid, logId, status)
{
	new message[9];
	if(status)
	{
		message = "enabled";
	}
	else
	{
	    message = "disabled";
	}
	switch(logId)
	{
		case 1:
		{
			rconCommandLogging = status;
			dini_IntSet(CONFIG_FILE, "RconCommandLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Rcon command logging %s.", message);
		}
		case 2:
		{
			chatLogging = status;
			dini_IntSet(CONFIG_FILE, "ChatLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Chat logging %s.", message);
		}
		case 3:
		{
			commandLogging = status;
			dini_IntSet(CONFIG_FILE, "CommandLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Command logging %s.", message);
		}
		case 4:
		{
			shootingLogging = status;
			dini_IntSet(CONFIG_FILE, "ShootingLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Shooting command logging disabled.");
		}
		case 5:
		{
			positionLogging = status;
			dini_IntSet(CONFIG_FILE, "PositionLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Position command logging %s.", message);
		}
		case 6:
		{
			rconLoginLogging = status;
			dini_IntSet(CONFIG_FILE, "RconLoginLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Rcon login logging %s.", message);
		}
		case 7:
		{
			deathLogging = status;
			dini_IntSet(CONFIG_FILE, "DeathLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Death logging %s.", message);
		}
		case 8:
		{
			connectLogging = status;
			dini_IntSet(CONFIG_FILE, "ConnectLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Connect command logging %s.", message);
		}
		case 9:
		{
			disconnectLogging = status;
			dini_IntSet(CONFIG_FILE, "DisconnectLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Disconnect command logging %s.", message);
		}
		case 10:
		{
			interiorLogging = status;
			dini_IntSet(CONFIG_FILE, "InteriorLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Interior logging %s.", message);
		}
		case 11:
		{
			carEnterLogging = status;
			dini_IntSet(CONFIG_FILE, "CarEnterLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Car enter logging %s.", message);
		}
		case 12:
		{
			carExitLogging = status;
			dini_IntSet(CONFIG_FILE, "CarExitLogging", status);
			SendClientMessageFormatted(playerid, -1, "[Logging System] Car exit logging %s.", message);
		}
		default:
		{
			SendClientMessage(playerid, -1, "[Logging System] Your input was incorrect, try again.");
		}
	}
}

/**
 * Deletes a file and creates it afterwards
 *
 * fileName The string of the file name that you want to be recreated
**/
eraseFile(fileName[])
{
	fremove(fileName);
	dini_Create(fileName);
	return 1;
}

/**
 * Send a HTTP request to get the latest version number and pass it to the response method
 *
**/
checkVersion()
{
	print("Checking Version");
	HTTP(1337, HTTP_GET, "https://github.com/Bios-Marcel/SA-MP_Log/raw/master/version.info", "", "versionCheckResponse");
	return 1;
}

/**
 * Loads the settings from the file into the variables
**/
loadConfig()
{
	positionLogging = dini_Int(CONFIG_FILE, "PositionLogging");
	chatLogging = dini_Int(CONFIG_FILE, "ChatLogging");
	commandLogging = dini_Int(CONFIG_FILE, "CommandLogging");
	shootingLogging = dini_Int(CONFIG_FILE, "ShootingLogging");
	deathLogging = dini_Int(CONFIG_FILE, "DeathLogging");
	connectLogging = dini_Int(CONFIG_FILE, "ConnectLogging");
	disconnectLogging = dini_Int(CONFIG_FILE, "DisconnectLogging");
	interiorLogging = dini_Int(CONFIG_FILE, "InteriorLogging");
	rconLoginLogging = dini_Int(CONFIG_FILE, "RconLoginLogging");
	carEnterLogging = dini_Int(CONFIG_FILE, "CarEnterLogging");
	carExitLogging = dini_Int(CONFIG_FILE, "CarExitLogging");
	rconCommandLogging = dini_Int(CONFIG_FILE, "RconCommandLogging");
	saveMode = dini_Int(CONFIG_FILE, "SaveMode");
	saveTime = dini_Int(CONFIG_FILE, "LogFilesPerX");
	return 1;
}

/**
 * Returns the full time and date (Day,Month,Year,Hour,Minute,Second)
**/
getDateAndTime()
{
	new year;
	new month;
	new day;
	getdate(year, month, day);
	new hour;
	new minute;
	new second;
	gettime(hour, minute, second);
	new date[23];
	format(date, 23, "[%02d/%02d/%04d %02d:%02d:%02d]", day, month, year, hour, minute, second);
	return date;
}

/**
 * Returns the time and date, depending on how much of it is needed
**/
getTimeInfo()
{
	new year;
	new month;
	new day;
	getdate(year, month, day);
	new hour;
	gettime(hour);
	new date[16];
	switch(saveTime)
	{
		case 0:
		{
			date = "";
		}
		case 1:
		{
			format(date, 16, "-%02d-%02d-%04d_%02d", day, month, year, hour);
		}
		case 2:
		{
			format(date, 16, "-%02d-%02d-%04d", day, month, year);
		}
		case 3:
		{
			format(date, 16, "-%02d-%04d", month, year);
		}
		case 4:
		{
			format(date, 16, "-%04d", year);
		}
	}
	return date;
}

/**
 * Checks if the given string is numeric
 *
 * string the string that is to check
 * returns 1 if it is numeric and 0 if it isn't
**/
isNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0')
		{
			return 0;
		}
	}
	return 1;
}

/**
 * Returns a players name
 *
 * playerid the players id that you want to get the name from
 * returns the players name
**/
getName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}

writeDataIfPossible(path[], logData[])
{
	new File:logFile = fopen(path, io_append);
	if(logFile)
	{
	    fwrite(logFile, logData);
		fclose(logFile);
		return 1;
	}
	else
	{
	    new errorData[100];
		format(errorData, 100, "%s Couldn't log data to %s \r\n\n", getDateAndTime(), path);
		logError(errorData);
	    return 0;
	}
}

logError(errorData[])
{
	new File:logFile = fopen(ERROR_LOG_FILE, io_append);
	if(logFile)
	{
	    fwrite(logFile, errorData);
		fclose(logFile);
		return 1;
	}
	else
	{
	    printf("Couldn't log Error: %s", errorData);
	}
	return 0;
}

logChat(playerid, text[])
{
	new path[62];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 62, "Logs/%s/Chat%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 62, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 62, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 62, "Logs/Chat%s.log", getTimeInfo());
		}
	}
	new logData[190];
	format(logData, 190, "%s %s: %s \r\n\n", getDateAndTime(), getName(playerid), text);
	writeDataIfPossible(path, logData);
	return 1;
}

logConnect(playerid)
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Connect%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/Connect%s.log", getTimeInfo());
		}
	}
	new ip[16];
	GetPlayerIp(playerid, ip, 16);
 	new logData[100];
	format(logData, 100, "%s %s connected with IP: %s \r\n\n", getDateAndTime(), getName(playerid), ip);
	writeDataIfPossible(path, logData);
	return 1;
}

logDisconnect(playerid, reason)
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Disconnect%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/Disconnect%s.log", getTimeInfo());
		}
	}
	new ip[16];
	GetPlayerIp(playerid, ip, 16);
	new reasonString[14];
	switch(reason)
	{
		case 0:
		{
			reasonString = "Timed out";
		}
		case 1:
		{
			reasonString = "Leaving";
		}
		case 2:
		{
			reasonString = "Kicked/Banned";
		}
	}
	new logData[100];
	format(logData, 100, "%s %s (IP:%s) disconnected, reason: %s \r\n\n", getDateAndTime(), getName(playerid), ip, reasonString);
	writeDataIfPossible(path, logData);
	return 1;
}

logCommand(playerid, cmdtext[])
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Command%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/Command%s.log", getTimeInfo());
		}
	}
	new logData[200];
	format(logData, 200, "%s %s: %s \r\n\n", getDateAndTime(), getName(playerid), cmdtext);
	writeDataIfPossible(path, logData);
	return 1;
}

logDeath(playerid, killerid, reason, victimcase)
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Death%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/Death%s.log", getTimeInfo());
		}
	}
	new logData[200];
	if(killerid != INVALID_PLAYER_ID)
	{
		if(victimcase == VICTIM)
		{
			format(logData, 200, "%s %s was killed by: %s, weapon: %s \r\n\n", getDateAndTime(), getName(playerid), getName(killerid), reason);
		}
		else if(victimcase == CULPRIT)
		{
			format(logData, 200, "%s %s has killed %s, weapon: %s \r\n\n", getDateAndTime(), getName(killerid), getName(playerid), reason);
		}
	}
	else
	{
		format(logData, 200, "%s %s died, reason: %s \r\n\n", getDateAndTime(), getName(playerid), reason);
	}
	writeDataIfPossible(path, logData);
	return 1;
}

logShooting(playerid, damagedid, Float:amount, weaponid, victimcase)
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Shooting%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/Shooting%s.log", getTimeInfo());
		}
	}
	new logData[200];
	if(victimcase == CULPRIT)
	{
		format(logData, 200, "%s %s ---> %s %f %i \r\n\n", getDateAndTime(), getName(playerid), getName(damagedid), Float:amount, weaponid);
	}
	else if(victimcase == VICTIM)
	{
		format(logData, 200, "%s %s ---> %s %f %i \r\n\n", getDateAndTime(), getName(damagedid), getName(playerid), Float:amount, weaponid);
	}
	writeDataIfPossible(path, logData);
	return 1;
}

logInteriorChange(playerid, int1, int2)
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Interior%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/Interior%s.log", getTimeInfo());
		}
	}
	new logData[200];
	format(logData, 200, "%s %s's new interior: %i, old interior: %i \r\n\n", getDateAndTime(), getName(playerid), int1, int2);
	writeDataIfPossible(path, logData);
	return 1;
}

logExitingVehicle(playerid, seat, vehicleid, modelid)
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/CarExit%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/CarExit%s.log", getTimeInfo());
		}
	}
	new seatName[10];
	switch(seat)
	{
		 case 0:
		 {
		 	seatName = "Driver";
		 }
		 default:
		 {
		 	seatName = "Passenger";
		 }
	}
	new logData[200];
	format(logData, 200, "%s %s left a vehicle, he/she was a %s, VehicleID: %i, ModelID: %i \r\n\n", getDateAndTime(), getName(playerid), seatName, vehicleid, modelid);
	writeDataIfPossible(path, logData);
	return 1;
}

logRconLogin(playerid, bool:success, ip[], password[])
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/RconLogin%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/RconLogin%s.log", getTimeInfo());
		}
	}
	new logData[200];
	if(!success)
	{
		format(logData, 200, "%s %s (IP:%s) has failed to login as RCON, password: %s\r\n\n", getDateAndTime(), getName(playerid), ip, password);
	}
	else
	{
		format(logData, 200, "%s %s (IP:%s) has logged in as RCON \r\n\n", getDateAndTime(), getName(playerid), ip);
	}
	writeDataIfPossible(path, logData);
	return 1;
}

/**
 * Only non default Rcon Commands are logged
**/
logRconCommand(cmd[])
{
	new path[80];
	if(saveMode == 3)
	{
		format(path, 80, "Logs/Log%s.log", getTimeInfo());
	}
	else
	{
		format(path, 80, "Logs/RconCommand%s.log", getTimeInfo());
	}
	new logData[200];
	format(logData, 200, "%s /rcon %s \r\n\n", getDateAndTime(), cmd);
	writeDataIfPossible(path, logData);
	return 1;
}

logEnteringVehicle(playerid, seat, vehicleid, modelid)
{
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/CarEnter%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/CarEnter%s.log", getTimeInfo());
		}
	}
	new seatName[10];
	switch(seat)
	{
		 case 0:
		 {
		 	seatName = "Driver";
		 }
		 default:
		 {
		 	seatName = "Passenger";
		 }
	}
	new logData[200];
	format(logData, 200, "%s %s entered a vehicle, he was a %s, VehicleID: %i, ModelID: %i \r\n\n", getDateAndTime(), getName(playerid), seatName, vehicleid, modelid);
	writeDataIfPossible(path, logData);
	return 1;
}

logPlayerLocation(playerid, Float:X, Float:Y, Float:Z)
{
	new path[80];
	switch(saveMode)
	{
		case 1:		{
			format(path, 80, "Logs/%s/Position%s.log", getName(playerid), getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", getName(playerid), getTimeInfo());
		}
		case 3:
		{
			format(path, 80, "Logs/Log%s.log", getTimeInfo());
		}
		case 4:
		{
			format(path, 80, "Logs/Position%s.log", getTimeInfo());
		}
	}
	new logData[150];
	format(logData, 150, "%s %s's Location X: %f | Y: %f | Z: %f\r\n\n", getDateAndTime(), getName(playerid), X, Y, Z);
	writeDataIfPossible(path, logData);
	return 1;
}

/**
 * Updates the menu dialog
 *
 * playerid the player who is supposed to see the updated dialog
**/
updateAndShowLogConfigDialog(playerid)
{
	new logPartString[14][38];
	switch(positionLogging)
	{
		case 0:
		{
			logPartString[0] = "PositionLogging[]";
		}
		case 1:
		{
			logPartString[0] = "PositionLogging[X]";
		}
	}
	switch(chatLogging)
	{
		case 0:
		{
			logPartString[1] = "ChatLogging[]";
		}
		case 1:
		{
			logPartString[1] = "ChatLogging[X]";
		}
	}
	switch(commandLogging)
	{
		case 0:
		{
			logPartString[2] = "CommandLogging[]";
		}
		case 1:
		{
			logPartString[2] = "CommandLogging[X]";
		}
	}
	switch(shootingLogging)
	{
		case 0:
		{
			logPartString[3] = "ShootingLogging[]";
		}
		case 1:
		{
			logPartString[3] = "ShootingLogging[X]";
 		}
	}
	switch(deathLogging)
	{
		case 0:
		{
			logPartString[4] = "DeathLogging[]";
		}
		case 1:
		{
			logPartString[4] = "DeathLogging[X]";
		}
	}
	switch(connectLogging)
	{
		case 0:
		{
			logPartString[5] = "ConnectLogging[]";
		}
		case 1:
		{
			logPartString[5] = "ConnectLogging[X]";
		}
	}
	switch(disconnectLogging)
	{
		case 0:
		{
			logPartString[6] = "DisconnectLogging[]";
		}
		case 1:
		{
			logPartString[6] = "DisconnectLogging[X]";
		}
	}
	switch(interiorLogging)
	{
		case 0:
		{
			logPartString[7] = "InteriorLogging[]";
		}
		case 1:
		{
			logPartString[7] = "InteriorLogging[X]";
		}
	}
	switch(rconLoginLogging)
	{
		case 0:
		{
			logPartString[8] = "RconLoginLogging[]";
		}
		case 1:
		{
			logPartString[8] = "RconLoginLogging[X]";
		}
	}
	switch(carEnterLogging)
	{
		case 0:
		{
			logPartString[9] = "CarEnterLogging[]";
		}
		case 1:
		{
			logPartString[9] = "CarEnterLogging[X]";
		}
	}
	switch(carExitLogging)
	{
		case 0:
		{
			logPartString[10] = "CarExitLogging[]";
		}
		case 1:
		{
			logPartString[10] = "CarExitLogging[X]";
		}
	}
	switch(rconCommandLogging)
	{
		case 0:
		{
			logPartString[11] = "RconCommandLogging[]";
		}
		case 1:
		{
			logPartString[11] = "RconCommandLogging[X]";
		}
	}
	switch(saveMode)
	{
		case 1:
		{
			logPartString[12] = "SaveMode 1[X] 2[ ] 3[ ] 4[ ]";
		}
		case 2:
		{
			logPartString[12] = "SaveMode 1[ ] 2[X] 3[ ] 4[ ]";
		}
		case 3:
		{
			logPartString[12] = "SaveMode 1[ ] 2[ ] 3[X] 4[ ]";
		}
		case 4:
		{
			logPartString[12] = "SaveMode 1[ ] 2[ ] 3[ ] 4[X]";
		}
	}
	switch(saveTime)
	{
		case 0:
		{
			logPartString[13] = "Save logfiles per (Function disabled)";
		}
		case 1:
		{
			logPartString[13] = "Save logfiles per hour";
		}
		case 2:
		{
			logPartString[13] = "Save logfiles per day";
		}
		case 3:
		{
			logPartString[13] = "Save logfiles per month";
		}
		case 4:
		{
			logPartString[13] = "Save logfiles per year";
		}
	}
	new string[370];
	format(string,370, "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\nPositionLogInterval\n \nDisable All\nEnable All",logPartString[0],logPartString[1],logPartString[2],logPartString[3],logPartString[4],logPartString[5],logPartString[6],logPartString[7],logPartString[8],logPartString[9],logPartString[10],logPartString[11],logPartString[12],logPartString[13]);
	ShowPlayerDialog(playerid, LOGCONFIG, DIALOG_STYLE_LIST, "Log Config", string, "Confirm", "Back");
	return 1;
}

/**
 * Shows the log clean dialog depending on the SaveMode that is set
 *
 * playerid the player who is supposed to see the dialog
**/
showLogCleanDialog(playerid)
{
	switch(saveMode)
	{
	    case 1:
	    {
			ShowPlayerDialog(playerid, SAVEMODE1_CHOOSEPLAYER, DIALOG_STYLE_INPUT, "Log clean", "Choose a player to delete his logfiles(You will choose the specific log afterwards)", "Confirm", "Back");
		}
	    case 2:
	    {
			ShowPlayerDialog(playerid, SAVEMODE2_CHOOSEPLAYER, DIALOG_STYLE_INPUT, "Log clean", "Which players file should be cleaned?\n(The full playername, not the player id)", "Confirm", "Back");
	    }
	    case 3:
		{
			new msg[120];
			format(msg, 120, "Are you sure that you want to clean the log file? (Size: %i)", getFileSize("Logs/Log.log"));
			ShowPlayerDialog(playerid, SAVEMODE3_CLEAN, DIALOG_STYLE_MSGBOX, "Log clean", msg, "Confirm", "Back");
		}
		default:
		{
			getLogSizes(playerid);
		}
	}
	return 1;
}



/**
 * Returns the filesize of a specific file
 *
 * filename the name of the file thats to check
**/
getFileSize(filename[])
{
	new File:sizetoget = fopen(filename, io_read);
	if(sizetoget)
	{
		new fileLength = flength(sizetoget);
		fclose(sizetoget);
		return fileLength;
	}
	return 0;
}

getLogSizes(playerid)
{
	new logPartSizeString[12][60];
	format(logPartSizeString[0],60, "PositionLog(Size:%i)", getFileSize("Logs/Position.log"));
	format(logPartSizeString[1],60, "ChatLog(Size:%i)", getFileSize("Logs/Chat.log"));
	format(logPartSizeString[2],60, "CommandLog(Size:%i)", getFileSize("Logs/Command.log"));
	format(logPartSizeString[3],60, "ShootingLog(Size:%i)", getFileSize("Logs/Shooting.log"));
	format(logPartSizeString[4],60, "DeathLog(Size:%i)", getFileSize("Logs/Death.log"));
	format(logPartSizeString[5],60, "ConnectLog(Size:%i)", getFileSize("Logs/Connect.log"));
	format(logPartSizeString[6],60, "DisconnectLog(Size:%i)", getFileSize("Logs/Disconnect.log"));
	format(logPartSizeString[7],60, "InteriorLog(Size:%i)", getFileSize("Logs/Interior.log"));
	format(logPartSizeString[8],60, "RconLoginLog(Size:%i)", getFileSize("Logs/RconLogin.log"));
	format(logPartSizeString[9],60, "CarEnterLog(Size:%i)", getFileSize("Logs/CarEnter.log"));
	format(logPartSizeString[10],60, "CarExitLog(Size:%i)", getFileSize("Logs/CarExit.log"));
	format(logPartSizeString[11],60, "RconCommandLog(Size:%i)", getFileSize("Logs/RconCommand.log"));
	new logSizes[1200];
	format(logSizes, 1200, "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", logPartSizeString[0], logPartSizeString[1], logPartSizeString[2], logPartSizeString[3], logPartSizeString[4], logPartSizeString[5], logPartSizeString[6], logPartSizeString[7], logPartSizeString[8], logPartSizeString[9], logPartSizeString[10], logPartSizeString[11]);
	ShowPlayerDialog(playerid, SAVEMODE4_CHOOSE, DIALOG_STYLE_LIST, "Log clean",logSizes, "Confirm", "Back");
	return 1;
}

cleanLog(playerid, logid)
{
	new logcl[125];
	switch(logid)
	{
		case 0:
		{
			format(logcl, 125, "Are you sure that you want to clean the Position Log file(Size:%i)", getFileSize("Logs/Position.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_POSITION, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 1:
		{
			format(logcl, 125, "Are you sure that you want to clean the Chat Log file(Size:%i)", getFileSize("Logs/Chat.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_CHAT, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 2:
		{
			format(logcl, 125, "Are you sure that you want to clean the Command Log file(Size:%i)", getFileSize("Logs/Command.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_COMMAND, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 3:
		{
			format(logcl, 125, "Are you sure that you want to clean the Shooting Log file(Size:%i)", getFileSize("Logs/Shooting.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_SHOOTING, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 4:
		{
			format(logcl, 125, "Are you sure that you want to clean the Death Log file(Size:%i)", getFileSize("Logs/Death.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_DEATH, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 5:
		{
			format(logcl, 125, "Are you sure that you want to clean the Connect Log file(Size:%i)", getFileSize("Logs/Connect.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_CONNECT, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 6:
		{
			format(logcl, 125, "Are you sure that you want to clean the Disconnect Log file(Size:%i)", getFileSize("Logs/Disconnect.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_DISCONNECT, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 7:
		{
			format(logcl, 125, "Are you sure that you want to clean the Interior Log file(Size:%i)", getFileSize("Logs/Interior.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_INTERIOR, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 8:
		{
			format(logcl, 125, "Are you sure that you want to clean the RconLogin Log file(Size:%i)", getFileSize("Logs/RconLogin.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_RCONLOGIN, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 9:
		{
			format(logcl, 125, "Are you sure that you want to clean the CarEnter Log file(Size:%i)", getFileSize("Logs/CarEnter.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_CARENTER, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 10:
		{
			format(logcl, 125, "Are you sure that you want to clean the CarExit Log file(Size:%i)", getFileSize("Logs/CarExit.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_CAREXIT, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
		case 11:
		{
			format(logcl, 125, "Are you sure that you want to clean the RconCommand Log file(Size:%i)", getFileSize("Logs/RconCommand.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_RCONCOMMAND, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
	}
	return 1;
}

//PUBLICS (non-default)
forward LogLoc(playerid);
public LogLoc(playerid)
{
	if(positionLogging)
	{
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		logPlayerLocation(playerid, X, Y, Z);
	}
	return 1;
}

forward LogCar(playerid);
public LogCar(playerid)
{
	logEnteringVehicle(playerid, GetPlayerVehicleSeat(playerid), GetPlayerVehicleID(playerid), GetVehicleModel(GetPlayerVehicleID(playerid)));
	return 1;
}

forward versionCheckResponse(index, response_code, data[]);
public versionCheckResponse(index, response_code, data[])
{
	new VERSION[9] = "1.3.3.1";
	if(strcmp(data, VERSION, true))
	{
		print("[Logging System] The Logging filterscript needs an update.");
		printf("[Logging System] Latest Version: %s", data);
		printf("[Logging System] Your Version: %s", VERSION);
		print("[Logging System] Downloadlink: https://github.com/Bios-Marcel/SA-MP_Log/releases/latest");
		print("[Logging System] Downloadlink(shortend): http://bit.ly/1TghSTT");
		print("Logging System] If the update notification keeps appearing you can ignore it.");
	}
	else
	{
		print("[Logging System] The Logging system is up to date.");
	}
	return 1;
}

//COMMANDS
CMD:logmenu(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		ShowPlayerDialog(playerid, LOGMENU, DIALOG_STYLE_LIST, "Logmenu", "Configure logs\nClean logs", "Confirm", "Back");
	}
	return 1;
}

CMD:logenable(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new log;
		if(sscanf(params, "i", log))
		{
			SendClientMessage(playerid, -1, "[Logging System] Usage: /logenable [log]");
			SendClientMessage(playerid, -1, "1 = RconCommandLogging");
			SendClientMessage(playerid, -1, "2 = ChatLogging");
			SendClientMessage(playerid, -1, "3 = CommandLogging");
			SendClientMessage(playerid, -1, "4 = ShootingLogging");
			SendClientMessage(playerid, -1, "5 = PositionLogging");
			SendClientMessage(playerid, -1, "6 = DeathLogging");
			SendClientMessage(playerid, -1, "7 = ConnectLogging");
			SendClientMessage(playerid, -1, "8 = DisconnectLogging");
			SendClientMessage(playerid, -1, "9 = RconLoginLogging");
			SendClientMessage(playerid, -1, "10 = InteriorLogging");
			SendClientMessage(playerid, -1, "11 = CarEnterLogging");
			SendClientMessage(playerid, -1, "12 = CarExitLogging");
			return 1;
		}
		setLogStatus(playerid, log , 1);
	}
	return 1;
}

CMD:logdisable(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new log;
		if(sscanf(params, "i", log))
		{
			SendClientMessage(playerid, -1, "[Logging System] Usage: /logdisable [log]");
			SendClientMessage(playerid, -1, "1 = RconCommandLogging");
			SendClientMessage(playerid, -1, "2 = ChatLogging");
			SendClientMessage(playerid, -1, "3 = CommandLogging");
			SendClientMessage(playerid, -1, "4 = ShootingLogging");
			SendClientMessage(playerid, -1, "5 = PositionLogging");
			SendClientMessage(playerid, -1, "6 = DeathLogging");
			SendClientMessage(playerid, -1, "7 = ConnectLogging");
			SendClientMessage(playerid, -1, "8 = DisconnectLogging");
			SendClientMessage(playerid, -1, "9 = RconLoginLogging");
			SendClientMessage(playerid, -1, "10 = InteriorLogging");
			SendClientMessage(playerid, -1, "11 = CarEnterLogging");
			SendClientMessage(playerid, -1, "12 = CarExitLogging");
			return 1;
		}
		setLogStatus(playerid, log , 0);
	}
	return 1;
}

CMD:loghelp(playerid, params[])
{
	SendClientMessage(playerid, -1, "-------------------[Logging System]-------------------");
	SendClientMessage(playerid, -1, "/loghelp: displays the helpmessages that u are looking at right now :P.");
	SendClientMessage(playerid, -1, "/logmenu: opens the configuration dialog list.");
	SendClientMessage(playerid, -1, "/logenable: enable a specific log.");
	SendClientMessage(playerid, -1, "/logdisable: disable a specific log.");
	SendClientMessage(playerid, -1, "/logsavemode: set the save mode.");
	SendClientMessage(playerid, -1, "/savemodeinfo: tells you what each of the save modes does.");
	SendClientMessage(playerid, -1, "/setpositionloginterval: set the position log interval for players.");
	return 1;
}

CMD:savemodeinfo(playerid, params[])
{
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 1 will create a folder for every player and a logfile for every category (Example: JohnCena/Chat.log).");
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 2 will save all information that has to be logged into per-player files (Example: JohnCena.log).");
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 3 will save all information that has to be logged into a global logfile called 'Log.log'.");
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 4 will save all information that has to be logged in seperate files foor every category (chat.log, rconcommand.log , ...).");
	return 1;
}

CMD:setpositionloginterval(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		ShowPlayerDialog(playerid, SETPOSLOGINTERVAL, DIALOG_STYLE_INPUT, "Set position logging interval", "Enter a number between 1 and 'infinite' (you should enter at lest 500), the format is milliseconds", "Confirm", "Backs");
	}
	return 1;
}

CMD:logsavemode(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new log;
		if(sscanf(params, "i", log))
		{
			return SendClientMessage(playerid, -1, "[Logging System] Usage: /logsavemode [1/2/3/4] \n[Logging System] For information about the diffrent savemodes type /savemodeinfo");
		}
		if((log >= 1) && (log <= 4))
		{
		    new message[46];
		    saveMode = log;
		    dini_IntSet(CONFIG_FILE, "SaveMode", log);
		    format(message, 46, "[Logging System] Savemode has been set to %i.", log);
		    SendClientMessage(playerid, -1, message);
		}
		SendClientMessage(playerid, -1, "[Logging System] For information about the diffrent savemodes use /savemodeinfo");
	}
	return 1;
}
