//Log Filterscript by [Bios]Marcel
//If you need any help at working on this script you can message me on forum.sa-mp.com
#define FILTERSCRIPT

//INCLUDES
#include <a_samp>
#include <Directory>
#include <Dini>
#include <a_http>
#include <zcmd>
#include <sscanf2>

//PUBLIC VARIABLES
new VERSION[9] = "1.3.0.16"; //DO NOT CHANGE THIS, IT TELLS U IF THERE IS A NEWER VERSION!
new savetime = 0;
new PositionLogging;
new ChatLogging;
new CommandLogging;
new ShootingLogging;
new	DeathLogging;
new	ConnectLogging;
new	DisconnectLogging;
new	InteriorLogging;
new	RconLoginLogging;
new	CarEnterLogging;
new	CarExitLogging;
new	RconCommandLogging;
new	SaveMode;
new	Timer[MAX_PLAYERS];
new	gPath[70];

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

#define FILE "Logs/Config.cfg"

//PUBLICS (default)
public OnFilterScriptInit()
{
	print("[Logging System] Log Filterscript loaded.");
 	checkVersion();
	DirCreate("Logs");
	if(fexist("Logs/LogConfig.cfg"))
	{
		dini_Create(FILE);
		dini_IntSet(FILE,"PositionLogging",dini_Int("Logs/LogConfig.cfg","PositionLogging"));
		dini_IntSet(FILE,"ChatLogging",dini_Int("Logs/LogConfig.cfg","ChatLogging"));
		dini_IntSet(FILE,"CommandLogging",dini_Int("Logs/LogConfig.cfg","CommandLogging"));
		dini_IntSet(FILE,"ShootingLogging",dini_Int("Logs/LogConfig.cfg","ShootingLogging"));
		dini_IntSet(FILE,"DeathLogging",dini_Int("Logs/LogConfig.cfg","DeathLogging"));
		dini_IntSet(FILE,"ConnectLogging",dini_Int("Logs/LogConfig.cfg","ConnectLogging"));
		dini_IntSet(FILE,"DisconnectLogging",dini_Int("Logs/LogConfig.cfg","DisconnectLogging"));
		dini_IntSet(FILE,"InteriorLogging",dini_Int("Logs/LogConfig.cfg","InteriorLogging"));
		dini_IntSet(FILE,"RconLoginLogging",dini_Int("Logs/LogConfig.cfg","RconLoginLogging"));
		dini_IntSet(FILE,"CarEnterLogging",dini_Int("Logs/LogConfig.cfg","CarEnterLogging"));
		dini_IntSet(FILE,"CarExitLogging",dini_Int("Logs/LogConfig.cfg","CarExitLogging"));
		dini_IntSet(FILE,"RconCommandLogging",dini_Int("Logs/LogConfig.cfg","RconCommandLogging"));
		dini_IntSet(FILE,"SaveMode",dini_Int("Logs/LogConfig.cfg","SaveMode"));
		dini_Set(FILE,"LogFilesPerX","no");
		dini_IntSet(FILE,"PositionLogInterval",dini_Int("Logs/LogConfig.cfg","PositionLogInterval"));
	}
	if(dini_Create(FILE))
	{
		dini_IntSet(FILE,"PositionLogging",1);
		dini_IntSet(FILE,"ChatLogging",1);
		dini_IntSet(FILE,"CommandLogging",1);
		dini_IntSet(FILE,"ShootingLogging",1);
		dini_IntSet(FILE,"DeathLogging",1);
		dini_IntSet(FILE,"ConnectLogging",1);
		dini_IntSet(FILE,"DisconnectLogging",1);
		dini_IntSet(FILE,"InteriorLogging",1);
		dini_IntSet(FILE,"RconLoginLogging",1);
		dini_IntSet(FILE,"CarEnterLogging",1);
		dini_IntSet(FILE,"CarExitLogging",1);
		dini_IntSet(FILE,"RconCommandLogging",1);
		dini_IntSet(FILE,"SaveMode",1);
		dini_Set(FILE,"LogFilesPerX","no");
		dini_IntSet(FILE,"PositionLogInterval",1500);
	}
	LoadCFG();
	if((SaveMode > 4) || (SaveMode < 1))
	{
		dini_IntSet(FILE,"SaveMode",1);
		print("[Logging System]The savemode was automatically set to 1 since it wasn't in range of 1 and 4.");
	}
	if(SaveMode == 4)
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
	if(RconCommandLogging)
	{
		if(SaveMode != 3)
		{
			dini_Create("Logs/RconCommand.log");
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	if(RconLoginLogging)
	{
	    print("Reached outer");
		new IP[16];
		for(new i=0; i<MAX_PLAYERS; i++)
		{
			GetPlayerIp(i, IP, 16);
			if(!strcmp(ip, IP, true))
			{
			    print("Reached inner");
				logRconLogin(i,success ? true : false,ip,password);
				break;
			}
		}
	}
	return 1;
}

public OnRconCommand(cmd[])
{
	logRconCommand(cmd);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(PositionLogging)
	{
		Timer[playerid] = SetTimerEx("LogLoc",dini_Int(FILE,"PosiotionLogInterval"),true,"i",playerid);
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(ShootingLogging)
	{
		logShooting(playerid,issuerid,amount,weaponid,CULPRIT);
		logShooting(issuerid,playerid,amount,weaponid,VICTIM);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(SaveMode == 1)
	{
		new path[80];
		format(path,80,"Logs/%s",getName(playerid));
		DirCreate(path);
	}
	else if(SaveMode == 2)
	{
		new path[80];
		format(path,80,"Logs/%s.log",getName(playerid));
		dini_Create(path);
	}
	if(ConnectLogging)
	{
		logConnect(playerid);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(DisconnectLogging)
	{
		logDisconnect(playerid, reason);
	}
	KillTimer(Timer[playerid]);
 	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(DeathLogging)
	{
		if(killerid != INVALID_PLAYER_ID)
		{
			logDeath(playerid,killerid,reason,VICTIM);
			logDeath(killerid,playerid,reason,CULPRIT);
		}
		else
		{
			logDeath(playerid,-1,reason,0);
		}
	}

}

public OnPlayerText(playerid, text[])
{
	if(ChatLogging)
	{
 		logChat(playerid, text);
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(CommandLogging)
	{
		logCommand(playerid, cmdtext);
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(CarEnterLogging)
	{
		SetTimerEx("LogCar",3000,false,"i",playerid);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(CarExitLogging)
	{
		logExitingVehicle(playerid,GetPlayerVehicleSeat(playerid),vehicleid,GetVehicleModel(vehicleid));
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case LOGMENU:
		{
			if(response)
			{
				if(listitem == 0)
				{
					Log_Config(playerid);
				}
				else
				{
					if(savetime != 0)
					{
						Log_Config(playerid);
					}
					else
					{
						SendClientMessage(playerid,-1,"[Logging System] You can't use this function since you are using the function to save logfiles hourly/daily/monthly/yearly.CreateActor (Will be added in alter patches)");
					}
				}
			}
		}
		case SAVEMODE1_CHOOSEPLAYER:
		{
			if(response)
			{
				new path[70];
				format(path,70,"Logs/%s",inputtext);
				if(CheckPath(path))
				{
					gPath = path;
					ShowPlayerDialog(playerid,SAVEMODE1_CHOOSELOG,DIALOG_STYLE_LIST,"Log clean (Step 2)","Position log\nChat log\nCommand log\nShooting log\nDeath log\nConnect log\nDisconnect log\nInterior log\n Rcon login log\nCarEnter log\nCarExit log","Confirm","Back");
				}
			}
			else
			{
				Log_Clean(playerid);
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
						format(path,75,"%s/Position.log",gPath);
					}
					case 1:
					{
						format(path,75,"%s/Chat.log",gPath);
					}
					case 2:
					{
						format(path,75,"%s/Command.log",gPath);
					}
					case 3:
					{
						format(path,75,"%s/Shooting.log",gPath);
					}
					case 4:
					{
						format(path,75,"%s/Death.log",gPath);
					}
					case 5:
					{
						format(path,75,"%s/Connect.log",gPath);
					}
					case 6:
					{
						format(path,75,"%s/Disconnecct.log",gPath);
					}
					case 7:
					{
						format(path,75,"%s/Interior.log",gPath);
					}
					case 8:
					{
						format(path,75,"%s/RconLogin.log",gPath);
					}
					case 9:
					{
						format(path,75,"%s/CarEnter.log",gPath);
					}
					case 10:
					{
						format(path,75,"%s/CarExit.log",gPath);
					}
				}
				eraseFile(path);
			}
			else
			{
				ShowPlayerDialog(playerid,SAVEMODE1_CHOOSEPLAYER,DIALOG_STYLE_INPUT,"Log clean","Choose a player to delete his logfiles(You will choose the specific log afterwards)","Confirm","Back");
			}
		 }
		case SAVEMODE2_CHOOSEPLAYER:
		{
			if(response)
			{
				new path[70];
				format(path,70,"Logs/%s.log",inputtext);
				if(!fexist(path))
				{
					ShowPlayerDialog(playerid,SAVEMODE2_CHOOSEPLAYER,DIALOG_STYLE_INPUT,"Log clean","Which Player File should be cleaned?\n(The Full Playername not PlayerID)","Confirm","Back");
					GameTextForPlayer(playerid,"Invalid Playername! (Watch out for case sensitive)",3000,5);
				}
				else
				{
					eraseFile(path);
					new successMessage[70];
					format(successMessage,70,"%s's Log was cleaned successful.",inputtext);
					GameTextForPlayer(playerid,successMessage,3000,5);
					ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
				}
			}
			else
			{
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
			}
		}
		case SAVEMODE3_CLEAN:
		{
			if(response)
			{
				eraseFile("Logs/Log.log");
				GameTextForPlayer(playerid,"log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
			}
			else
			{
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
			}
		}
		case S4_CLEAN_CHAT:
		{
			if(response)
			{
				eraseFile("Logs/Chat.log");
				GameTextForPlayer(playerid,"Chat log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"Command log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"Shooting log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"Death log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"Connect log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"Disconnect log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"Interior log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"Interior log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"RconLogin log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"CarEnter log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"CarExit log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				GameTextForPlayer(playerid,"RconCommand log cleaned successful.",3000,5);
				ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
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
				cleanLog(playerid,listitem);
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
						if(PositionLogging)
						{
							PositionLogging = 0;
							dini_IntSet(FILE,"PositionLogging",0);
							Log_Config(playerid);
						}
						else
						{
							PositionLogging = 1;
							dini_IntSet(FILE,"PositionLogging",1);
							Log_Config(playerid);
						}
					}
					case 1:
					{
					    if(ChatLogging)
						{
							ChatLogging = 0;
							dini_IntSet(FILE,"ChatLogging",0);
							Log_Config(playerid);
						}
						else
						{
							ChatLogging = 1;
							dini_IntSet(FILE,"ChatLogging",1);
							Log_Config(playerid);
						}
					}
					case 2:
					{
					   	if(CommandLogging)
						{
							CommandLogging = 0;
							dini_IntSet(FILE,"CommandLogging",0);
							Log_Config(playerid);
						}
						else
						{
							CommandLogging = 1;
							dini_IntSet(FILE,"CommandLogging",1);
							Log_Config(playerid);
						}
					}
					case 3:
					{
						if(ShootingLogging)
						{
							ShootingLogging = 0;
							dini_IntSet(FILE,"ShootingLogging",0);
							Log_Config(playerid);
						}
						else
						{
							ShootingLogging = 1;
							dini_IntSet(FILE,"ShootingLogging",1);
							Log_Config(playerid);
						}
					}
					case 4:
					{
					    if(DeathLogging)
						{
							DeathLogging = 0;
							dini_IntSet(FILE,"DeathLogging",0);
							Log_Config(playerid);
						}
						else
						{
							DeathLogging = 1;
							dini_IntSet(FILE,"DeathLogging",1);
							Log_Config(playerid);
						}
					}
					case 5:
					{
					    if(ConnectLogging)
						{
							ConnectLogging = 0;
							dini_IntSet(FILE,"ConnectLogging",0);
							Log_Config(playerid);
						}
						else
						{
							ConnectLogging = 1;
							dini_IntSet(FILE,"ConnectLogging",1);
							Log_Config(playerid);
						}
					}
					case 6:
					{
						if(DisconnectLogging)
						{
							DisconnectLogging = 0;
							dini_IntSet(FILE,"DisconnectLogging",0);
							Log_Config(playerid);
						}
						else
						{
							DisconnectLogging = 1;
							dini_IntSet(FILE,"DisconnectLogging",1);
							Log_Config(playerid);
						}
					}
					case 7:
					{
					    if(InteriorLogging)
						{
							InteriorLogging = 0;
							dini_IntSet(FILE,"InteriorLogging",0);
							Log_Config(playerid);
						}
						else
						{
							InteriorLogging = 1;
							dini_IntSet(FILE,"InteriorLogging",1);
							Log_Config(playerid);
						}
					}
					case 8:
					{
						if(RconLoginLogging)
						{
							RconLoginLogging = 0;
							dini_IntSet(FILE,"RconLoginLogging",0);
							Log_Config(playerid);
						}
						else
						{
							RconLoginLogging = 1;
							dini_IntSet(FILE,"RconLoginLogging",1);
							Log_Config(playerid);
						}
					}
					case 9:
					{
						if(CarEnterLogging)
						{
							CarEnterLogging = 0;
							dini_IntSet(FILE,"CarEnterLogging",0);
							Log_Config(playerid);
						}
						else
						{
							CarEnterLogging = 1;
							dini_IntSet(FILE,"CarEnterLogging",1);
							Log_Config(playerid);
						}
					}
					case 10:
					{
						if(CarExitLogging)
						{
							CarExitLogging = 0;
							dini_IntSet(FILE,"CarExitLogging",0);
							Log_Config(playerid);
						}
						else
						{
							CarExitLogging = 1;
							dini_IntSet(FILE,"CarExitLogging",1);
							Log_Config(playerid);
						}
					}
					case 11:
					{
						if(RconCommandLogging)
						{
							RconCommandLogging = 0;
							dini_IntSet(FILE,"RconCommandLogging",0);
							Log_Config(playerid);
						}
						else
						{
							RconCommandLogging = 1;
							dini_IntSet(FILE,"RconCommandLogging",1);
							Log_Config(playerid);
						}
					}
					case 12:
					{
						SaveMode++;
						if(SaveMode == 5)
						{
							SaveMode = 1;
						}
						dini_IntSet(FILE,"SaveMode",SaveMode);
						Log_Config(playerid);
					}
					case 13:
					{
						savetime++;
						if(savetime == 5)
						{
							savetime = 0;
						}
						dini_IntSet(FILE,"LogFilesPerX",savetime);
						Log_Config(playerid);
					}
					case 14:
					{
	    				ShowPlayerDialog(playerid,POSLOGINT,DIALOG_STYLE_INPUT,"Position Log Interval","Enter a Interval for the player position logging.\nIf u enter a too low interval it may cause problems.\nThe format is milliseconds.","Select","Back");
					}
					//CASE 15 existiert nicht da dort eine Leere Spalte ist welche keine Funktion haben soll.
					/*case 15:
					{
					}*/
					case 16:
					{
						PositionLogging = 0;
						dini_IntSet(FILE,"PositionLogging",0);
						ChatLogging = 0;
						dini_IntSet(FILE,"ChatLogging",0);
						ConnectLogging = 0;
						dini_IntSet(FILE,"ConnectLogging",0);
						DisconnectLogging = 0;
						dini_IntSet(FILE,"DisconnectLogging",0);
						ShootingLogging = 0;
						dini_IntSet(FILE,"ShootingLogging",0);
						DeathLogging = 0;
						dini_IntSet(FILE,"DeathLogging",0);
						RconLoginLogging = 0;
						dini_IntSet(FILE,"RconLoginLogging",0);
						InteriorLogging = 0;
						dini_IntSet(FILE,"InteriorLogging",0);
						CarEnterLogging = 0;
						dini_IntSet(FILE,"CarEnterLogging",0);
						CarExitLogging = 0;
						dini_IntSet(FILE,"CarExitLogging",0);
						CommandLogging = 0;
						dini_IntSet(FILE,"CommandLogging",0);
						RconCommandLogging = 0;
						dini_IntSet(FILE,"RconCommandLogging",0);
						Log_Config(playerid);
					}
					case 17:
					{
						PositionLogging = 1;
						dini_IntSet(FILE,"PositionLogging",1);
						ChatLogging = 1;
						dini_IntSet(FILE,"ChatLogging",1);
						ConnectLogging = 1;
						dini_IntSet(FILE,"ConnectLogging",1);
						DisconnectLogging = 1;
						dini_IntSet(FILE,"DisconnectLogging",1);
						ShootingLogging = 1;
						dini_IntSet(FILE,"ShootingLogging",1);
						DeathLogging = 1;
						dini_IntSet(FILE,"DeathLogging",1);
						RconLoginLogging = 1;
						dini_IntSet(FILE,"RconLoginLogging",1);
						InteriorLogging = 1;
						dini_IntSet(FILE,"InteriorLogging",1);
						CarEnterLogging = 1;
						dini_IntSet(FILE,"CarEnterLogging",1);
						CarExitLogging = 1;
						dini_IntSet(FILE,"CarExitLogging",1);
						CommandLogging = 1;
						dini_IntSet(FILE,"CommandLogging",1);
						RconCommandLogging = 1;
						dini_IntSet(FILE,"RconCommandLogging",1);
						Log_Config(playerid);
					}
				}
			}
		}
		case POSLOGINT:
		{
			if(response)
			{
				if(isNumeric(inputtext))
				{
					dini_IntSet(FILE,"PositionLogInterval",strval(inputtext));
				}
				else
				{
					ShowPlayerDialog(playerid,POSLOGINT,DIALOG_STYLE_INPUT,"Position Log Interval","The text that u entered was no number.\n\nEnter a Interval for the player position logging.\nIf u enter a too low interval it may cause problems.\nThe format is milliseconds.","Select","Back");
				}
			}
			else
			{
				Log_Config(playerid);
			}
		}
	}
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if(InteriorLogging)
	{
		logInteriorChange(playerid,newinteriorid,oldinteriorid);
	}
	return 1;
}

//STOCKS
/**
 * Deletes a file and creates it afterwards
 *
 * @param fileName The string of the file name that you want to be recreated
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
	HTTP(1337,HTTP_GET,"twistedeagles.bplaced.net/samplog/version.txt","","MyHttpResponse");
	return 1;
}

/**
 * Loads the settings from the file into the variables
**/
LoadCFG()
{
	PositionLogging = dini_Int(FILE,"PositionLogging");
	ChatLogging = dini_Int(FILE,"ChatLogging");
	CommandLogging = dini_Int(FILE,"CommandLogging");
	ShootingLogging = dini_Int(FILE,"ShootingLogging");
	DeathLogging = dini_Int(FILE,"DeathLogging");
	ConnectLogging = dini_Int(FILE,"ConnectLogging");
	DisconnectLogging = dini_Int(FILE,"DisconnectLogging");
	InteriorLogging = dini_Int(FILE,"InteriorLogging");
	RconLoginLogging = dini_Int(FILE,"RconLoginLogging");
	CarEnterLogging = dini_Int(FILE,"CarEnterLogging");
	CarExitLogging = dini_Int(FILE,"CarExitLogging");
	RconCommandLogging = dini_Int(FILE,"RconCommandLogging");
	SaveMode = dini_Int(FILE,"SaveMode");
	savetime = dini_Int(FILE,"LogFilesPerX");
	return 1;
}

/**
 * Returns the full time and date (Day,Month,Year,Hour,Minute,Second)
 *
 * @return time and date
**/
getDateAndTime()
{
	new fyear;
	new fmonth;
	new fday;
	getdate(fyear, fmonth, fday);
	new fhour;
	new fminute;
	new fsecond;
	gettime(fhour, fminute, fsecond);
	new date[32];
	format(date, 32,"[%02d/%02d/%04d %02d:%02d:%02d]", fday, fmonth, fyear, fhour, fminute, fsecond);
	return date;
}

/**
 * Returns the time and date, depending on how much of it is needed
 *
 * @return time and date
**/
getTimeInfo()
{
	new fyear;
	new fmonth;
	new fday;
	getdate(fyear, fmonth, fday);
	new fhour;
	gettime(fhour);
	new date[32];
	switch(savetime)
	{
		case 0:
		{
			date = "";
		}
		case 1:
		{
			format(date, 32,"-%02d-%02d-%04d_%02d", fday, fmonth, fyear, fhour);
		}
		case 2:
		{
			format(date, 32,"-%02d-%02d-%04d", fday, fmonth, fyear);
		}
		case 3:
		{
			format(date, 32,"-%02d-%04d", fmonth, fyear);
		}
		case 4:
		{
			format(date, 32,"-%04d", fyear);
		}
	}
	return date;
}

/**
 * Checks if the given string is numeric
 *
 * @param string the string that is to check
 * @return 1 if it is numeric and 0 if it isn't
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
 * @param playerid the players id that you want to get the name from
 * @return the players name
**/
getName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,MAX_PLAYER_NAME);
	return name;
}

logChat(playerid, text[])
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Chat%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Chat%s.log",getTimeInfo());
		}
	}
	new logData[220];
	format(logData, 220,"%s %s: %s \r\n", getDateAndTime(), getName(playerid), text);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logConnect(playerid)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Connect%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Connect%s.log",getTimeInfo());
		}
	}
	new ip[16];
	GetPlayerIp(playerid,ip,16);
 	new logData[100];
	format(logData, 100,"%s %s connected with IP: %s \r\n",getDateAndTime(), getName(playerid), ip);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logDisconnect(playerid, reason)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Disconnect%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Disconnect%s.log",getTimeInfo());
		}
	}
	new ip[16];
	GetPlayerIp(playerid,ip,16);
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
	format(logData, 100,"%s %s (IP:%s) disconnected, reason: %s \r\n", getDateAndTime(), getName(playerid), ip, reasonString);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logCommand(playerid, cmdtext[])
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Command%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Command%s.log",getTimeInfo());
		}
	}
	new logData[200];
	format(logData, 200,"%s %s: %s \r\n", getDateAndTime(), getName(playerid), cmdtext);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logDeath(playerid,killerid,reason,victimcase)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Death%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Death%s.log",getTimeInfo());
		}
	}
	new logData[200];
	if(killerid != INVALID_PLAYER_ID)
	{
		if(victimcase == VICTIM)
		{
			format(logData, 200,"%s %s was killed by: %s, weapon: %s \r\n", getDateAndTime(), getName(playerid), getName(killerid), reason);
		}
		else if(victimcase == CULPRIT)
		{
			format(logData, 200,"%s %s has killed %s, weapon: %s \r\n",getDateAndTime(), getName(killerid), getName(playerid), reason);
		}
	}
	else
	{
		format(logData, 200,"%s %s died, reason: %s \r\n", getDateAndTime(), getName(playerid), reason);
	}
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logShooting(playerid,damagedid,Float:amount,weaponid,victimcase)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Shooting%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Shooting%s.log",getTimeInfo());
		}
	}
	new logData[200];
	if(victimcase == CULPRIT)
	{
		format(logData, 200,"%s %s ---> %s %f %i \r\n", getDateAndTime(), getName(playerid), getName(damagedid), Float:amount, weaponid);
	}
	else if(victimcase == VICTIM)
	{
		format(logData, 200,"%s %s ---> %s %f %i \r\n", getDateAndTime(), getName(damagedid), getName(playerid), Float:amount, weaponid);
	}
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logInteriorChange(playerid,int1,int2)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Interior%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Interior%s.log",getTimeInfo());
		}
	}
	new logData[200];
	format(logData, 200,"%s %s's new interior: %i, old interior: %i \r\n", getDateAndTime(), getName(playerid), int1,int2);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logExitingVehicle(playerid, seat, vehicleid, modelid)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/CarExit%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/CarExit%s.log",getTimeInfo());
		}
	}
	new seatstr[10];
	switch(seat)
	{
		 case 0:
		 {
		 	seatstr = "Driver";
		 }
		 default:
		 {
		 	seatstr = "Passenger";
		 }
	}
	new logData[200];
	format(logData, 200,"%s %s exited a vehicle, he/she was a %s, VehicleID: %i, ModelID: %i \r\n", getDateAndTime(), getName(playerid), seatstr, vehicleid, modelid);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logRconLogin(playerid,bool:success, ip[],password[])
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/RconLogin%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/RconLogin%s.log",getTimeInfo());
		}
	}
	new logData[200];
	if(!success)
	{
		format(logData, 200,"%s %s (IP:%s) has failed to login as RCON, password: %s\r\n",getDateAndTime(), getName(playerid), ip, password);
	}
	else
	{
		format(logData, 200,"%s %s (IP:%s) has logged in as RCON \r\n", getDateAndTime(), getName(playerid), ip);
	}
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

/**
 * Only non default Rcon Commands are logged
**/
logRconCommand(cmd[])
{
	new path[21];
	if(SaveMode == 3)
	{
		format(path,80,"Logs/Log%s.log",getTimeInfo());
	}
	else
	{
		format(path,80,"Logs/RconCommand%s.log",getTimeInfo());
	}
	new logData[200];
	format(logData, 200,"%s /rcon %s \r\n",getDateAndTime(), cmd);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logEnteringVehicle(playerid, seat, vehicleid, modelid)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/CarEnter%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/CarEnter%s.log",getTimeInfo());
		}
	}
	new seatstr[10];
	switch(seat)
	{
		 case 0:
		 {
		 	seatstr = "Driver";
		 }
		 default:
		 {
		 	seatstr = "Passenger";
		 }
	}
	new logData[200];
	format(logData, 200,"%s %s entered a vehicle, he was a %s, VehicleID: %i, ModelID: %i \r\n",getDateAndTime(), getName(playerid), seatstr, vehicleid, modelid);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

logPlayerLocation(playerid,Float:X,Float:Y,Float:Z)
{
	new path[80];
	switch(SaveMode)
	{
		case 1:
		{
			format(path,80,"Logs/%s/Position%s.log",getName(playerid),getTimeInfo());
		}
		case 2:
		{
			format(path,80,"Logs/%s%s.log",getName(playerid),getTimeInfo());
		}
		case 3:
		{
			format(path,80,"Logs/Log%s.log",getTimeInfo());
		}
		case 4:
		{
			format(path,80,"Logs/Position%s.log",getTimeInfo());
		}
	}
	new logData[200];
	format(logData, 200,"%s %s's Location X: %f | Y: %f | Z: %f\r\n",getDateAndTime(), getName(playerid), X,Y,Z);
	new File:logFile = fopen(path, io_append);
	fwrite(logFile, logData);
	fclose(logFile);
	return 1;
}

/**
 * Updates the menu dialog
 *
 * @param playerid the player who is supposed to see the updated dialog
**/
Log_Config(playerid)
{
	new strlc[14][38];
	switch(PositionLogging)
	{
		case 0:
		{
			strlc[0]="PositionLogging[]";
		}
		case 1:
		{
			strlc[0]="PositionLogging[X]";
		}
	}
	switch(ChatLogging)
	{
		case 0:
		{
			strlc[1]="ChatLogging[]";
		}
		case 1:
		{
			strlc[1]="ChatLogging[X]";
		}
	}
	switch(CommandLogging)
	{
		case 0:
		{
			strlc[2]="CommandLogging[]";
		}
		case 1:
		{
			strlc[2]="CommandLogging[X]";
		}
	}
	switch(ShootingLogging)
	{
		case 0:
		{
			strlc[3]="ShootingLogging[]";
		}
		case 1:
		{
			strlc[3]="ShootingLogging[X]";
 		}
	}
	switch(DeathLogging)
	{
		case 0:
		{
			strlc[4]="DeathLogging[]";
		}
		case 1:
		{
			strlc[4]="DeathLogging[X]";
		}
	}
	switch(ConnectLogging)
	{
		case 0:
		{
			strlc[5]="ConnectLogging[]";
		}
		case 1:
		{
			strlc[5]="ConnectLogging[X]";
		}
	}
	switch(DisconnectLogging)
	{
		case 0:
		{
			strlc[6]="DisconnectLogging[]";
		}
		case 1:
		{
			strlc[6]="DisconnectLogging[X]";
		}
	}
	switch(InteriorLogging)
	{
		case 0:
		{
			strlc[7]="InteriorLogging[]";
		}
		case 1:
		{
			strlc[7]="InteriorLogging[X]";
		}
	}
	switch(RconLoginLogging)
	{
		case 0:
		{
			strlc[8]="RconLoginLogging[]";
		}
		case 1:
		{
			strlc[8]="RconLoginLogging[X]";
		}
	}
	switch(CarEnterLogging)
	{
		case 0:
		{
			strlc[9]="CarEnterLogging[]";
		}
		case 1:
		{
			strlc[9]="CarEnterLogging[X]";
		}
	}
	switch(CarExitLogging)
	{
		case 0:
		{
			strlc[10]="CarExitLogging[]";
		}
		case 1:
		{
			strlc[10]="CarExitLogging[X]";
		}
	}
	switch(RconCommandLogging)
	{
		case 0:
		{
			strlc[11]="RconCommandLogging[]";
		}
		case 1:
		{
			strlc[11]="RconCommandLogging[X]";
		}
	}
	switch(SaveMode)
	{
		case 1:
		{
			strlc[12]="SaveMode 1[X] 2[ ] 3[ ] 4[ ]";
		}
		case 2:
		{
			strlc[12]="SaveMode 1[ ] 2[X] 3[ ] 4[ ]";
		}
		case 3:
		{
			strlc[12]="SaveMode 1[ ] 2[ ] 3[X] 4[ ]";
		}
		case 4:
		{
			strlc[12]="SaveMode 1[ ] 2[ ] 3[ ] 4[X]";
		}
	}
	switch(savetime)
	{
		case 0:
		{
			strlc[13]="Save logfiles per (Function disabled)";
		}
		case 1:
		{
			strlc[13]="Save logfiles per hour";
		}
		case 2:
		{
			strlc[13]="Save logfiles per day";
		}
		case 3:
		{
			strlc[13]="Save logfiles per month";
		}
		case 4:
		{
			strlc[13]="Save logfiles per year";
		}
	}
	new string[370];
	format(string,370,"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\nPositionLogInterval\n \nDisable All\nEnable All",strlc[0],strlc[1],strlc[2],strlc[3],strlc[4],strlc[5],strlc[6],strlc[7],strlc[8],strlc[9],strlc[10],strlc[11],strlc[12],strlc[13]);
	ShowPlayerDialog(playerid,LOGCONFIG,DIALOG_STYLE_LIST,"Log Config",string,"Confirm","Back");
	return 1;
}

/**
 * Shows the log clean dialog depending on the SaveMode that is set
 *
 * @param playerid the player who is supposed to see the dialog
**/
Log_Clean(playerid)
{
	switch(SaveMode)
	{
	    case 1:
	    {
			ShowPlayerDialog(playerid,SAVEMODE1_CHOOSEPLAYER,DIALOG_STYLE_INPUT,"Log clean","Choose a player to delete his logfiles(You will choose the specific log afterwards)","Confirm","Back");
		}
	    case 2:
	    {
			ShowPlayerDialog(playerid,SAVEMODE2_CHOOSEPLAYER,DIALOG_STYLE_INPUT,"Log clean","Which players file should be cleaned?\n(The full playername, not the player id)","Confirm","Back");
	    }
	    case 3:
		{
			new msg[200];
			format(msg,200,"Are you sure that you want to clean the log file? (Size: %i)",getFileSize("Logs/Log.log"));
			ShowPlayerDialog(playerid,SAVEMODE3_CLEAN,DIALOG_STYLE_MSGBOX,"Log clean",msg,"Confirm","Back");
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
 * @param filename the name of the file thats to check
 *
 * @return the filesize
**/
getFileSize(filename[])
{
	new File:sizetoget = fopen(filename,io_read);
	new fileLength = flength(sizetoget);
	fclose(sizetoget);
	return fileLength;
}

getLogSizes(playerid)
{
	new alog[12][60];
	format(alog[0],60,"PositionLog(Size:%i)",getFileSize("Logs/Position.log"));
	format(alog[1],60,"ChatLog(Size:%i)",getFileSize("Logs/Chat.log"));
	format(alog[2],60,"CommandLog(Size:%i)",getFileSize("Logs/Command.log"));
	format(alog[3],60,"ShootingLog(Size:%i)",getFileSize("Logs/Shooting.log"));
	format(alog[4],60,"DeathLog(Size:%i)",getFileSize("Logs/Death.log"));
	format(alog[5],60,"ConnectLog(Size:%i)",getFileSize("Logs/Connect.log"));
	format(alog[6],60,"DisconnectLog(Size:%i)",getFileSize("Logs/Disconnect.log"));
	format(alog[7],60,"InteriorLog(Size:%i)",getFileSize("Logs/Interior.log"));
	format(alog[8],60,"RconLoginLog(Size:%i)",getFileSize("Logs/RconLogin.log"));
	format(alog[9],60,"CarEnterLog(Size:%i)",getFileSize("Logs/CarEnter.log"));
	format(alog[10],60,"CarExitLog(Size:%i)",getFileSize("Logs/CarExit.log"));
	format(alog[11],60,"RconCommandLog(Size:%i)",getFileSize("Logs/RconCommand.log"));
	new abig[1200];
	format(abig,1200,"%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s",alog[0],alog[1],alog[2],alog[3],alog[4],alog[5],alog[6],alog[7],alog[8],alog[9],alog[10],alog[11]);
	ShowPlayerDialog(playerid,SAVEMODE4_CHOOSE,DIALOG_STYLE_LIST,"Log clean",abig,"Confirm","Back");
	return 1;
}

cleanLog(playerid,logid)
{
	new logcl[125];
	switch(logid)
	{
		case 0:
		{
			format(logcl,125,"Are you sure that you want to clean the Position Log file(Size:%i)",getFileSize("Logs/Position.log"));
		}
		case 1:
		{
			format(logcl,125,"Are you sure that you want to clean the Chat Log file(Size:%i)",getFileSize("Logs/Chat.log"));
		}
		case 2:
		{
			format(logcl,125,"Are you sure that you want to clean the Command Log file(Size:%i)",getFileSize("Logs/Command.log"));
		}
		case 3:
		{
			format(logcl,125,"Are you sure that you want to clean the Shooting Log file(Size:%i)",getFileSize("Logs/Shooting.log"));
		}
		case 4:
		{
			format(logcl,125,"Are you sure that you want to clean the Death Log file(Size:%i)",getFileSize("Logs/Death.log"));
		}
		case 5:
		{
			format(logcl,125,"Are you sure that you want to clean the Connect Log file(Size:%i)",getFileSize("Logs/Connect.log"));
		}
		case 6:
		{
			format(logcl,125,"Are you sure that you want to clean the Disconnect Log file(Size:%i)",getFileSize("Logs/Disconnect.log"));
		}
		case 7:
		{
			format(logcl,125,"Are you sure that you want to clean the Interior Log file(Size:%i)",getFileSize("Logs/Interior.log"));
		}
		case 8:
		{
			format(logcl,125,"Are you sure that you want to clean the RconLogin Log file(Size:%i)",getFileSize("Logs/RconLogin.log"));
		}
		case 9:
		{
			format(logcl,125,"Are you sure that you want to clean the CarEnter Log file(Size:%i)",getFileSize("Logs/CarEnter.log"));
		}
		case 10:
		{
			format(logcl,125,"Are you sure that you want to clean the CarExit Log file(Size:%i)",getFileSize("Logs/CarExit.log"));
		}
		case 11:
		{
			format(logcl,125,"Are you sure that you want to clean the RconCommand Log file(Size:%i)",getFileSize("Logs/RconCommand.log"));
		}
	}
	ShowPlayerDialog(playerid,S4_CLEAN_CONNECT,DIALOG_STYLE_LIST,"Log clean",logcl,"Confirm","Back");
	return 1;
}

//PUBLICS (non-default)
forward LogLoc(playerid);
public LogLoc(playerid)
{
	new Float:X,Float:Y,Float:Z;
	GetPlayerPos(playerid,X,Y,Z);
	logPlayerLocation(playerid,X,Y,Z);
	return 1;
}

forward LogCar(playerid);
public LogCar(playerid)
{
	logEnteringVehicle(playerid,GetPlayerVehicleSeat(playerid),GetPlayerVehicleID(playerid),GetVehicleModel(GetPlayerVehicleID(playerid)));
	return 1;
}

forward MyHttpResponse(index, response_code, data[]);
public MyHttpResponse(index, response_code, data[])
{
	if(strcmp(data, VERSION, true))
	{
		print("[Logging System] The Logging filterscript needs an update.");
		printf("[Logging System] Latest Version: %s", data);
		printf("[Logging System] Your Version: %s", VERSION);
		print("[Logging System] Downloadlink: https://github.com/Bios-Marcel/SA-MP_Log/releases/latest");
		print("[Logging System] Downloadlink(shortend): http://bit.ly/1TghSTT");
	}
	else
	{
		print("[Logging System] The Logging system is up to date.");
	}
	return 1;
}

//COMMANDS
CMD:logmenu(playerid,params[])
{
	if(IsPlayerAdmin(playerid))
	{
		ShowPlayerDialog(playerid,LOGMENU,DIALOG_STYLE_LIST,"Logmenu","Configure logs\nClean logs","Confirm","Back");
	}
	return 1;
}

CMD:logenable(playerid,params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new log;
		if(sscanf(params,"i",log))
		{
			return SendClientMessage(playerid,-1,"[Logging System] Usage: /logenable [log] \n1 = RconCommandLogging\n2 = ChatLogging\n3 = CommandLogging\n4 = ShootingLogging\n5 = PositionLogging\n6 = DeathLogging\n7 = ConnectLogging\n8 = DisconnectLogging\n9 = RconLoginLogging\n10 = InteriorLogging\n11 = CarEnterLogging\n12 = CarExitLogging");
		}
		switch(log)
		{
			case 1:
			{
				RconCommandLogging = 1;
				dini_IntSet(FILE,"RconCommandLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Rcon command logging diabled.");
			}
			case 2:
			{
				ChatLogging = 1;
				dini_IntSet(FILE,"ChatLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Chat logging diabled.");
			}
			case 3:
			{
				CommandLogging = 1;
				dini_IntSet(FILE,"CommandLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Command logging diabled.");
			}
			case 4:
			{
				ShootingLogging = 1;
				dini_IntSet(FILE,"ShootingLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Shooting command logging diabled.");
			}
			case 5:
			{
				PositionLogging = 1;
				dini_IntSet(FILE,"PositionLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Position command logging diabled.");
			}
			case 6:
			{
				RconLoginLogging = 1;
				dini_IntSet(FILE,"RconLoginLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Rcon login logging diabled.");
			}
			case 7:
			{
				DeathLogging = 1;
				dini_IntSet(FILE,"DeathLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Death logging diabled.");
			}
			case 8:
			{
				ConnectLogging = 1;
				dini_IntSet(FILE,"ConnectLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Connect command logging diabled.");
			}
			case 9:
			{
				DisconnectLogging = 1;
				dini_IntSet(FILE,"DisconnectLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Disconnect command logging diabled.");
			}
			case 10:
			{
				InteriorLogging = 1;
				dini_IntSet(FILE,"InteriorLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Interior logging diabled.");
			}
			case 11:
			{
				CarEnterLogging = 1;
				dini_IntSet(FILE,"CarEnterLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Car enter logging diabled.");
			}
			case 12:
			{
				CarExitLogging = 1;
				dini_IntSet(FILE,"CarExitLogging",1);
				SendClientMessage(playerid,-1,"[Logging System] Car exit logging diabled.");
			}
			default:
			{
				SendClientMessage(playerid, -1, "[Logging System] Your input was incorrect, try again.");
			}
		}
	}
	return 1;
}

CMD:logdisable(playerid,params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new log;
		if(sscanf(params,"i",log))
		{
			return SendClientMessage(playerid,-1,"[Logging System] Usage: /logdisable [log] \n1 = RconCommandLogging\n2 = ChatLogging\n3 = CommandLogging\n4 = ShootingLogging\n5 = PositionLogging\n6 = DeathLogging\n7 = ConnectLogging\n8 = DisconnectLogging\n9 = RconLoginLogging\n10 = InteriorLogging\n11 = CarEnterLogging\n12 = CarExitLogging");
		}
		switch(log)
		{
			case 1:
			{
				RconCommandLogging = 0;
				dini_IntSet(FILE,"RconCommandLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Rcon command logging diabled.");
			}
			case 2:
			{
				ChatLogging = 0;
				dini_IntSet(FILE,"ChatLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Chat logging diabled.");
			}
			case 3:
			{
				CommandLogging = 0;
				dini_IntSet(FILE,"CommandLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Command logging diabled.");
			}
			case 4:
			{
				ShootingLogging = 0;
				dini_IntSet(FILE,"ShootingLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Shooting command logging diabled.");
			}
			case 5:
			{
				PositionLogging = 0;
				dini_IntSet(FILE,"PositionLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Position command logging diabled.");
			}
			case 6:
			{
				RconLoginLogging = 0;
				dini_IntSet(FILE,"RconLoginLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Rcon login logging diabled.");
			}
			case 7:
			{
				DeathLogging = 0;
				dini_IntSet(FILE,"DeathLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Death logging diabled.");
			}
			case 8:
			{
				ConnectLogging = 0;
				dini_IntSet(FILE,"ConnectLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Connect command logging diabled.");
			}
			case 9:
			{
				DisconnectLogging = 0;
				dini_IntSet(FILE,"DisconnectLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Disconnect command logging diabled.");
			}
			case 10:
			{
				InteriorLogging = 0;
				dini_IntSet(FILE,"InteriorLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Interior logging diabled.");
			}
			case 11:
			{
				CarEnterLogging = 0;
				dini_IntSet(FILE,"CarEnterLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Car enter logging diabled.");
			}
			case 12:
			{
				CarExitLogging = 0;
				dini_IntSet(FILE,"CarExitLogging",0);
				SendClientMessage(playerid,-1,"[Logging System] Car exit logging diabled.");
			}
			default:
			{
				SendClientMessage(playerid, -1, "[Logging System] Your input was incorrect, try again.");
			}
		}
	}
	return 1;
}

CMD:loghelp(playerid, params[])
{
	SendClientMessage(playerid, -1, "-------------------[Logging System]-------------------");
	SendClientMessage(playerid, -1, "/loghelp: displays the helpmessages that u are looking at right now :P.");
	SendClientMessage(playerid, -1, "/logenable: enable specific logs.");
	SendClientMessage(playerid, -1, "/logdisable: disable specific logs.");
	return 1;
}

CMD:savemodeinfo(playerid,params[])
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
		ShowPlayerDialog(playerid, SETPOSLOGINTERVAL, DIALOG_STYLE_INPUT, "Set position logging interval", "Enter a number between 1 and 'infinite' (you should enter at lest 500), the format is milliseconds","Confirm","Backs");
	}
	return 1;
}

CMD:logsavemode(playerid,params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new log;
		if(sscanf(params,"i",log))
		{
			return SendClientMessage(playerid,-1,"[Logging System] Usage: /logsavemode [1/2/3/4] \n[Logging System] For information about the diffrent savemodes type /savemodeinfo");
		}
		switch(log)
		{
			case 1:
			{
				SaveMode = 1;
				dini_IntSet(FILE,"SaveMode",1);
				SendClientMessage(playerid,-1,"[Logging System] Savemode has been set to 1.");
			}
			case 2:
			{
				SaveMode = 2;
				dini_IntSet(FILE,"SaveMode",2);
				SendClientMessage(playerid,-1,"[Logging System] Savemode has been set to 2.");
			}
			case 3:
			{
				SaveMode = 3;
				dini_IntSet(FILE,"SaveMode",3);
				SendClientMessage(playerid,-1,"[Logging System] Savemode has been set to 3.");
			}
			case 4:
			{
				SaveMode = 4;
				dini_IntSet(FILE,"SaveMode",4);
				SendClientMessage(playerid,-1,"[Logging System] Savemode has been set to 4.");
			}
			default:
			{
				SendClientMessage(playerid, -1, "[Logging System] Your input was incorrect, try again.");
			}
		}
		SendClientMessage(playerid, -1, "[Logging System] For information about the diffrent savemodes use /savemodeinfo");
	}
	return 1;
}
