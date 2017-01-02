//Log Filterscript by [Bios]Marcel
//If you need any help at working on this script you can message me on forum.sa-mp.com (http://forum.sa-mp.com/member.php?u=172637)
#define FILTERSCRIPT

//INCLUDES
#include <a_samp>
#include <a_http>

#include <Dini>
#include <zcmd>

#include <Directory>
#include <sscanf2>



//DEFINES
//Name in settingsfile
#define POSITION_LOGGING "PositionLogging"
#define CHAT_LOGGING "ChatLogging"
#define COMMAND_LOGGING "CommandLogging"
#define SHOOTING_LOGGING "ShootingLogging"
#define DEATH_LOGGING "DeathLogging"
#define INCOMING_CONNECTION_LOGGING "IncomingConnectionLogging"
#define CONNECT_LOGGING "ConnectLogging"
#define DISCONNECT_LOGGING "DisconnectLogging"
#define INTERIOR_LOGGING "InteriorLogging"
#define RCON_LOGIN_LOGGING "RconLoginLogging"
#define CAR_ENTER_LOGGING "CarEnterLogging"
#define CAR_EXIT_LOGGING "CarExitLogging"
#define SAVE_MODE "SaveMode"
#define LOG_FILES_PER_X "LogFilesPerX"
#define POSITION_LOG_INTERVAL "PositionLogInterval"

//Default settings
#define POSITION_LOGGING_DEFAULT true
#define CHAT_LOGGING_DEFAULT true
#define COMMAND_LOGGING_DEFAULT true
#define SHOOTING_LOGGING_DEFAULT true
#define DEATH_LOGGING_DEFAULT true
#define INCOMING_CONNECTION_LOGGING_DEFAULT false
#define CONNECT_LOGGING_DEFAULT true
#define DISCONNECT_LOGGING_DEFAULT true
#define INTERIOR_LOGGING_DEFAULT true
#define RCON_LOGIN_LOGGING_DEFAULT true
#define CAR_ENTER_LOGGING_DEFAULT true
#define CAR_EXIT_LOGGING_DEFAULT true
#define SAVE_MODE_DEFAULT true
#define LOG_FILES_PER_X_DEFAULT "no"
#define POSITION_LOG_INTERVAL_DEFAULT 3000

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
#define S4_CLEAN_INCOMINGCONNECTION 17
#define POSLOGINT 18
#define SAVEMODE1_CHOOSEPLAYER 19
#define SAVEMODE1_CHOOSELOG 20
#define SETPOSLOGINTERVAL 21

#define CULPRIT 1
#define VICTIM 2

#define CONFIG_FILE "Logs/Config.cfg"
#define ERROR_LOG_FILE "Logs/ErrorLog.log"

#define BYTES_PER_CELL 4

//Default color to be used for all ingame messages
#define DEFAULT_MESSAGE_COLOR -1

//PUBLIC VARIABLES
new saveTime = 0;
new bool:positionLogging;
new bool:chatLogging;
new bool:commandLogging;
new bool:shootingLogging;
new bool:deathLogging;
new bool:incomingConnectionLogging;
new bool:connectLogging;
new bool:disconnectLogging;
new bool:interiorLogging;
new bool:rconLoginLogging;
new bool:carEnterLogging;
new bool:carExitLogging;
new saveMode;
new playerLocationLogTimer[MAX_PLAYERS];

//Forwarding
forward logPlayerLocation(playerid);
forward versionCheckResponse(index, response_code, data[]);

//PUBLICS (default)
/*
Description:
This callback is called when a filterscript is initialized (loaded). It is only called inside the filterscript which is starting.
*/
public OnFilterScriptInit()
{
	print("[Logging System] Log Filterscript loaded.");
	checkVersion();

	//Creates the directory if it not already exists, doesn't delete anything
	DirCreate("Logs");

	applyOldConfigIfExistant();
	
	createConfigIfNotExistant();
	
	loadConfig();

	if((saveMode > 4) || (saveMode < 1))
	{
		dini_IntSet(CONFIG_FILE, SAVE_MODE, 1);
		print("[Logging System]The savemode was automatically set to 1 since it wasn't in range of 1 and 4.");
	}

	return 1;
}

/*
Description:
This callback is called when someone attempts to log in to RCON in-game; successful or not.

Parameters:
ip[]		The IP of the player that tried to log in to RCON.
password[]	The password used to login with.
success		0 if the password was incorrect or 1 if it was correct.

Return Values:
This callback does not handle returns.
*/
public OnRconLoginAttempt(ip[], password[], success)
{
	if(rconLoginLogging)
	{
		new IP[16];
		for(new i=0; i < MAX_PLAYERS; i++)
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

/*
Description:
This callback is called when a player spawns.(i.e. after caling SpawnPlayer function)

Parameters:
playerid	The ID of the player that spawned.

Return Values:
Returning 0 in this callback will force the player back to class selection when they next spawn.
*/
public OnPlayerSpawn(playerid)
{
	if(positionLogging)
	{
  //Killing the Timer to prevent any bugs
	    KillTimer(playerLocationLogTimer[playerid]);
		playerLocationLogTimer[playerid] = SetTimerEx("logPlayerLocation", dini_Int(CONFIG_FILE, POSITION_LOG_INTERVAL), true, "i", playerid);
	}
	return 1;
}

/*
Description:
This callback is called when a player takes damage.

Parameters:
playerid	The ID of the player that took damage.
issuerid	The ID of the player that caused the damage. INVALID_PLAYER_ID if self-inflicted.
amount		The amount of damage the player took (health and armour combined).
weaponid	The ID of the weapon/reason for the damage.
bodypart	The body part that was hit. (NOTE: This parameter was added in 0.3z. Leave it out if using an older version!)

Return Values:
1 - Callback will not be called in other filterscripts.
0 - Allows this callback to be called in other filterscripts.
It is always called first in filterscripts so returning 1 there blocks other filterscripts from seeing it
*/
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(shootingLogging)
	{
		logShooting(playerid, issuerid, amount, weaponid, CULPRIT);
		logShooting(issuerid, playerid, amount, weaponid, VICTIM);
	}
}

/*
Description:
This callback is called when an IP address attempts a connection to the server. To block incoming connections, use BlockIpAddress.

Parameters:
playerid		The ID of the player attempting to connect
ip_address[]	The IP address of the player attempting to connect
port			The port of the attempted connection

Return Values:
This callback does not handle returns.
*/
public OnIncomingConnection(playerid, ip_address[], port)
{
	if(incomingConnectionLogging)
	{
	    logIncomingConnection(playerid, ip_address, port);
	}
    return 1;
}

/*
Description:
This callback is called when a player connects to the server.

Parameters:
playerid	The ID of the player that connected.

Return Values:
0 - Will prevent other filterscripts from receiving this callback.
1 - Indicates that this callback will be passed to the next filterscript.
*/
public OnPlayerConnect(playerid)
{
	if(connectLogging)
	{
		logConnect(playerid);
	}
	return 1;
}

/*
Description:
This callback is called when a player disconnects from the server.

Parameters:
playerid	The ID of the player that disconnected.
reason		The reason for the disconnection. See table below.

Return Values:
0 - Will prevent other filterscripts from receiving this callback.
1 - Indicates that this callback will be passed to the next filterscript.
*/
public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(playerLocationLogTimer[playerid]);
	if(disconnectLogging)
	{
	    logDisconnect(playerid, reason);
	}
 	return 1;
}

/*
Description:
This callback is called when a player dies, either by suicide or by being killed by another player.

Parameters:
playerid	The ID of the player that died.
killerid	The ID of the player that killed the player who died, or INVALID_PLAYER_ID if there was none.
reason		The ID of the reason for the player's death. See table below

Reasons:

Name				Definition				ID				Slot			Model			Notes

Fist				-						0				0				-
Brass Knuckles		WEAPON_BRASSKNUCKLE		1				0				331
Golf Club			WEAPON_GOLFCLUB			2				1				333
Nightstick			WEAPON_NITESTICK		3				1				334
Knife				WEAPON_KNIFE			4				1				335				Can de-sync players when their throat is cut (they appear dead to other players)
Baseball Bat		WEAPON_BAT				5				1				336
Shovel				WEAPON_SHOVEL			6				1				337
Pool Cue			WEAPON_POOLSTICK		7				1				338
Katana				WEAPON_KATANA			8				1				339				Can not decapitate players (like in single-player)
Chainsaw			WEAPON_CHAINSAW			9				1				341
Purple Dildo		WEAPON_DILDO			10				10				321
Dildo				WEAPON_DILDO2			11				10				322
Vibrator			WEAPON_VIBRATOR			12				10				323
Silver Vibrator		WEAPON_VIBRATOR2		13				10				324
Flowers 			WEAPON_FLOWER			14				10				325
Cane				WEAPON_CANE				15				10				326
Grenade				WEAPON_GRENADE			16				8				342				Does not produce fire
Tear Gas 			WEAPON_TEARGAS			17				8				343				The coughing effect is disabled in SA-MP
Molotov Cocktail	WEAPON_MOLTOV			18				8				344				Produces fire
9mm					WEAPON_COLT45			22				2				346				Skill can be set with SetPlayerSkillLevel
Silenced 9mm		WEAPON_SILENCED			23				2				347				Skill can be set with SetPlayerSkillLevel
Desert Eagle		WEAPON_DEAGLE			24				2				348				Skill can be set with SetPlayerSkillLevel
Shotgun 			WEAPON_SHOTGUN			25				3				349				Skill can be set with SetPlayerSkillLevel
Sawnoff Shotgun		WEAPON_SAWEDOFF			26				3				350				Skill can be set with SetPlayerSkillLevel
Combat Shotgun		WEAPON_SHOTGSPA			27				3				351				Skill can be set with SetPlayerSkillLevel
Micro SMG/Uzi 		WEAPON_UZI				28				4				352				Skill can be set with SetPlayerSkillLevel
MP5					WEAPON_MP5				29				4				353				Skill can be set with SetPlayerSkillLevel
AK-47	 			WEAPON_AK47				30				5				355				Skill can be set with SetPlayerSkillLevel
M4					WEAPON_M4				31				5				356				Skill can be set with SetPlayerSkillLevel
Tec-9				WEAPON_TEC9				32				4				372				Skill can be set with SetPlayerSkillLevel
Country Rifle		WEAPON_RIFLE			33				6				357				Skill can be set with SetPlayerSkillLevel
Sniper Rifle		WEAPON_SNIPER			34				6				358				Skill can be set with SetPlayerSkillLevel
RPG					WEAPON_ROCKETLAUNCHER	35				7				359
HS Rocket			WEAPON_HEATSEEKER		36				7				360				Lock-on is not synced
Flamethrower		WEAPON_FLAMETHROWER		37				7				361
Minigun				WEAPON_MINIGUN			38				7				362
Satchel Charge		WEAPON_SATCHEL			39				8				363				Only synced for players that were streamed-in when the satchels were thrown
Detonator			WEAPON_BOMB				40				12				364				Given automatically when players throw a satchel charge (omit from anti-cheat checks)
Spraycan			WEAPON_SPRAYCAN			41				9				365				Players that are sprayed choke
Fire Extinguisher	WEAPON_FIREEXTINGUISHER	42				9				366				Players that are sprayed choke
Camera				WEAPON_CAMERA			43				9				367				Saves photos to player's gallery if enabled via pause menu (My Documents\GTA San Andreas User Files\Gallery)
Night Vis Goggles	-						44				11				368				Visual effects show for all players (fix available)
Thermal Goggles		-						45				11				369				Visual effects show for all players (fix available
Parachute			WEAPON_PARACHUTE		46				11				371				Players will die if teleported while diving with a parachute (can be fixed using ResetPlayerWeapons). Parachutes are given when bailing out of aircraft. (omit from anti-cheat checks)
Cellphone			-						-				-				-				Cut from the game.
Jetpack				-						-				-				370				Doesn't work as a weapon. See SetPlayerSpecialAction.
Skateboard			-						-				-				-				Cut from the game.
Fake Pistol			-						47				N/A				N/A				?
Vehicle				WEAPON_VEHICLE			49				N/A				N/A				Only a death icon, can not be used in GivePlayerWeapon etc.
Helicopter Blades	-						50				N/A				N/A				Only a death icon, can not be used in GivePlayerWeapon etc.
Explosion			-						51				N/A				N/A				Only a death icon, can not be used in GivePlayerWeapon etc.
Drowned				WEAPON_DROWN			53				N/A				N/A				Only a death icon, can not be used in GivePlayerWeapon etc.
Splat 				WEAPON_COLLISION		54				N/A				N/A				Only a death icon, can not be used in GivePlayerWeapon etc.
Connect				-						200				N/A				N/A				Only usable in SendDeathMessage
Disconnect			-						201				N/A				N/A				Only usable in SendDeathMessage
Suicide 			-						255				N/A				N/A				Only a death icon, can not be used in GivePlayerWeapon etc.

Return Values:
This callback does not handle returns.
*/
public OnPlayerDeath(playerid, killerid, reason)
{
	if(deathLogging)
	{
		if(killerid != INVALID_PLAYER_ID)
		{
			logDeath(playerid, killerid, reason, VICTIM);
			logDeath(killerid, playerid, reason, CULPRIT);
		}
		else
		{
		    logDeath(playerid, DEFAULT_MESSAGE_COLOR, reason, 0);
		}
	}
}

/*
Description:
Called when a player sends a chat message.

Parameters:
playerid	The ID of the player who typed the text.
text[]		The text the player typed.

Return Values:
Returning 0 in this callback will stop the text from being sent to all players
*/
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

/*
Description:
This callback is called when a player starts to exit a vehicle.

Parameters:
playerid	The ID of the player that is exiting a vehicle.
vehicleid	The ID of the vehicle the player is exiting.

Return Values:
This callback does not handle returns.
*/
public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(carExitLogging)
	{
		logExitingVehicle(playerid, GetPlayerVehicleSeat(playerid), vehicleid, GetVehicleModel(vehicleid));
	}
	return 1;
}

/*
Description:
This callback is called when a player changes state. For example, when a player changes from being the driver of a vehicle to being on-foot.

Parameters:
playerid	The ID of the player that changed state.
newstate	The player's new state.
oldstate	The player's previous state.

Return Values:
This callback does not handle returns.
*/
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(carEnterLogging)
	{
		if(!(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) && (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER))
	    {
	        new vehicleid = GetPlayerVehicleID(playerid);
		    logEnteringVehicle(playerid, GetPlayerVehicleSeat(playerid), vehicleid, GetVehicleModel(vehicleid));
	    }
	}
	//To prevent the player location from being locked when it is not possible or would give invalid information
    if(newstate == PLAYER_STATE_WASTED || newstate == PLAYER_STATE_NONE || newstate == PLAYER_STATE_SPECTATING)
	{
	    KillTimer(playerLocationLogTimer[playerid]);
	}
}

/*
Description:
Called when a player changes interior. Can be triggered by SetPlayerInterior or when a player enter/exits a building.

Parameters:
(playerid, newinteriorid, oldinteriorid)
playerid		The playerid who changed interior.
newinteriorid	The interior the player is now in.
oldinteriorid	The interior the player was in before.

Return Values:
This callback does not handle returns.
*/
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if(interiorLogging)
	{
		logInteriorChange(playerid, newinteriorid, oldinteriorid);
	}
	return 1;
}

/*
Description:
This callback is called when a player responds to a dialog shown using ShowPlayerDialog by either clicking a button, pressing ENTER/ESC or double-clicking a list item (if using a list style dialog).

Parameters:
(playerid, dialogid, response, listitem, inputtext[])
playerid	The ID of the player that responded to the dialog.
dialogid	The ID of the dialog the player responded to, assigned in ShowPlayerDialog.
response	1 for left button and 0 for right button (if only one button shown, always 1)
listitem	The ID of the list item selected by the player (starts at 0) (only if using a list style dialog).
inputtext[]	The text entered into the input box by the player or the selected list item text.

Return Values:
Returning 0 in this callback will pass the dialog to another script in case no matching code were found in your gamemode's callback.
*/
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
						SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] You can't use this function since you are using the function to save logfiles hourly/daily/monthly/yearly.CreateActor (Will be added in alter patches)");
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
		case S4_CLEAN_INCOMINGCONNECTION:
		{
			if(response)
			{
				eraseFile("Logs/IncomingConnection.log");
				GameTextForPlayer(playerid, "IncomingConnection log cleaned successful.", 3000, 5);
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
						dini_IntSet(CONFIG_FILE, POSITION_LOGGING, positionLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 1:
					{
						chatLogging = !chatLogging;
						dini_IntSet(CONFIG_FILE, CHAT_LOGGING, chatLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 2:
					{
						commandLogging = !commandLogging;
						dini_IntSet(CONFIG_FILE, COMMAND_LOGGING, commandLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 3:
					{
						shootingLogging = !shootingLogging;
						dini_IntSet(CONFIG_FILE, SHOOTING_LOGGING, shootingLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 4:
					{
						deathLogging = !deathLogging;
						dini_IntSet(CONFIG_FILE, DEATH_LOGGING, deathLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 5:
					{
						connectLogging = !connectLogging;
						dini_IntSet(CONFIG_FILE, CONNECT_LOGGING, connectLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 6:
					{
						disconnectLogging = !disconnectLogging;
						dini_IntSet(CONFIG_FILE, DISCONNECT_LOGGING, disconnectLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 7:
					{
						interiorLogging = !interiorLogging;
						dini_IntSet(CONFIG_FILE, INTERIOR_LOGGING, interiorLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 8:
					{
						rconLoginLogging = !rconLoginLogging;
						dini_IntSet(CONFIG_FILE, RCON_LOGIN_LOGGING, rconLoginLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 9:
					{
						carEnterLogging = !carEnterLogging;
						dini_IntSet(CONFIG_FILE, CAR_ENTER_LOGGING, carEnterLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 10:
					{
						carExitLogging = !carExitLogging;
						dini_IntSet(CONFIG_FILE, CAR_EXIT_LOGGING, carExitLogging);
						updateAndShowLogConfigDialog(playerid);
					}
					case 11:
					{
						saveMode++;
						if(saveMode >= 5)
						{
							saveMode = 1;
						}
						dini_IntSet(CONFIG_FILE, SAVE_MODE, saveMode);
						updateAndShowLogConfigDialog(playerid);
					}
					case 12:
					{
						saveTime++;
						if(saveTime >= 5)
						{
							saveTime = 0;
						}
						dini_IntSet(CONFIG_FILE, LOG_FILES_PER_X, saveTime);
						updateAndShowLogConfigDialog(playerid);
					}
					case 13:
					{
	    				ShowPlayerDialog(playerid, POSLOGINT, DIALOG_STYLE_INPUT, "Position Log Interval", "Enter an interval for the player position logging.\nIf you enter an interval that is too low/too high, it may cause problems or be useless.\nThe format is milliseconds.", "Select", "Back");
					}
					//CASE 14 existiert nicht da dort eine Leere Spalte ist welche keine Funktion haben soll.
					/*case 14:
					{
					}*/
					case 15:
					{
						positionLogging = false;
						dini_IntSet(CONFIG_FILE, POSITION_LOGGING, false);
						chatLogging = false;
						dini_IntSet(CONFIG_FILE, CHAT_LOGGING, false);
						connectLogging = false;
						dini_IntSet(CONFIG_FILE, CONNECT_LOGGING, false);
						disconnectLogging = false;
						dini_IntSet(CONFIG_FILE, DISCONNECT_LOGGING, false);
						shootingLogging = false;
						dini_IntSet(CONFIG_FILE, SHOOTING_LOGGING, false);
						deathLogging = false;
						dini_IntSet(CONFIG_FILE, DEATH_LOGGING, false);
						rconLoginLogging = false;
						dini_IntSet(CONFIG_FILE, RCON_LOGIN_LOGGING, false);
						interiorLogging = false;
						dini_IntSet(CONFIG_FILE, INTERIOR_LOGGING, false);
						carEnterLogging = false;
						dini_IntSet(CONFIG_FILE, CAR_ENTER_LOGGING, false);
						carExitLogging = false;
						dini_IntSet(CONFIG_FILE, CAR_EXIT_LOGGING, false);
						commandLogging = false;
						dini_IntSet(CONFIG_FILE, COMMAND_LOGGING, false);
						updateAndShowLogConfigDialog(playerid);
					}
					case 16:
					{
						positionLogging = true;
						dini_IntSet(CONFIG_FILE, POSITION_LOGGING, true);
						chatLogging = true;
						dini_IntSet(CONFIG_FILE, CHAT_LOGGING, true);
						connectLogging = true;
						dini_IntSet(CONFIG_FILE, CONNECT_LOGGING, true);
						disconnectLogging = true;
						dini_IntSet(CONFIG_FILE, DISCONNECT_LOGGING, true);
						shootingLogging = true;
						dini_IntSet(CONFIG_FILE, SHOOTING_LOGGING, true);
						deathLogging = true;
						dini_IntSet(CONFIG_FILE, DEATH_LOGGING, true);
						rconLoginLogging = true;
						dini_IntSet(CONFIG_FILE, RCON_LOGIN_LOGGING, true);
						interiorLogging = true;
						dini_IntSet(CONFIG_FILE, INTERIOR_LOGGING, true);
						carEnterLogging = true;
						dini_IntSet(CONFIG_FILE, CAR_ENTER_LOGGING, true);
						carExitLogging = true;
						dini_IntSet(CONFIG_FILE, CAR_EXIT_LOGGING, true);
						commandLogging = true;
						dini_IntSet(CONFIG_FILE, COMMAND_LOGGING, true);
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
					dini_IntSet(CONFIG_FILE, POSITION_LOG_INTERVAL, strval(inputtext));
				}
				else
				{
					ShowPlayerDialog(playerid, POSLOGINT, DIALOG_STYLE_INPUT, "Position Log Interval", "Enter an interval for the player position logging.\nIf you enter an interval that is too low/too high, it may cause problems or be useless.\nThe format is milliseconds.", "Select", "Back");
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

createConfigIfNotExistant()
{
	if(dini_Create(CONFIG_FILE))
	{
		dini_IntSet(CONFIG_FILE, POSITION_LOGGING, POSITION_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, CHAT_LOGGING, CHAT_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, COMMAND_LOGGING, COMMAND_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, SHOOTING_LOGGING, SHOOTING_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, DEATH_LOGGING, DEATH_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, INCOMING_CONNECTION_LOGGING, INCOMING_CONNECTION_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, CONNECT_LOGGING, CONNECT_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, DISCONNECT_LOGGING, DISCONNECT_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, INTERIOR_LOGGING, INTERIOR_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, RCON_LOGIN_LOGGING, RCON_LOGIN_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, CAR_ENTER_LOGGING, CAR_ENTER_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, CAR_EXIT_LOGGING, CAR_EXIT_LOGGING_DEFAULT);
		dini_IntSet(CONFIG_FILE, SAVE_MODE, SAVE_MODE_DEFAULT);
		dini_Set(CONFIG_FILE, LOG_FILES_PER_X, LOG_FILES_PER_X_DEFAULT);
		dini_IntSet(CONFIG_FILE, POSITION_LOG_INTERVAL, POSITION_LOG_INTERVAL_DEFAULT);
	}
}

applyOldConfigIfExistant()
{
	//Before the config was called "config.cfg" it was called "LogConfig.cfg" , since i dont want to ruin your settigns i am checking for the old file to transfer it
	if(fexist("Logs/LogConfig.cfg"))
	{
		if(!fexist(CONFIG_FILE))
		{
			dini_Create(CONFIG_FILE);
			dini_IntSet(CONFIG_FILE, POSITION_LOGGING, dini_Int("Logs/LogConfig.cfg", POSITION_LOGGING));
			dini_IntSet(CONFIG_FILE, CHAT_LOGGING, dini_Int("Logs/LogConfig.cfg", CHAT_LOGGING));
			dini_IntSet(CONFIG_FILE, COMMAND_LOGGING, dini_Int("Logs/LogConfig.cfg", COMMAND_LOGGING));
			dini_IntSet(CONFIG_FILE, SHOOTING_LOGGING, dini_Int("Logs/LogConfig.cfg", SHOOTING_LOGGING));
			dini_IntSet(CONFIG_FILE, DEATH_LOGGING, dini_Int("Logs/LogConfig.cfg", DEATH_LOGGING));
			dini_IntSet(CONFIG_FILE, INCOMING_CONNECTION_LOGGING, dini_Int("Logs/LogConfig.cfg", INCOMING_CONNECTION_LOGGING));
			dini_IntSet(CONFIG_FILE, CONNECT_LOGGING, dini_Int("Logs/LogConfig.cfg", CONNECT_LOGGING));
			dini_IntSet(CONFIG_FILE, DISCONNECT_LOGGING, dini_Int("Logs/LogConfig.cfg", DISCONNECT_LOGGING));
			dini_IntSet(CONFIG_FILE, INTERIOR_LOGGING, dini_Int("Logs/LogConfig.cfg", INTERIOR_LOGGING));
			dini_IntSet(CONFIG_FILE, RCON_LOGIN_LOGGING, dini_Int("Logs/LogConfig.cfg", RCON_LOGIN_LOGGING));
			dini_IntSet(CONFIG_FILE, CAR_ENTER_LOGGING, dini_Int("Logs/LogConfig.cfg", CAR_ENTER_LOGGING));
			dini_IntSet(CONFIG_FILE, CAR_EXIT_LOGGING, dini_Int("Logs/LogConfig.cfg", CAR_EXIT_LOGGING));
			dini_IntSet(CONFIG_FILE, SAVE_MODE, dini_Int("Logs/LogConfig.cfg", SAVE_MODE));
			dini_Set(CONFIG_FILE, LOG_FILES_PER_X, "no");
			dini_IntSet(CONFIG_FILE, POSITION_LOG_INTERVAL, dini_Int("Logs/LogConfig.cfg", POSITION_LOG_INTERVAL));
		}
	}
}

/**
 * Enabled / disables the given log
 *
 * playerid	that receives the message
 * logId 	the log that is to deactivate/activate
 * status 	status on or off (1 or 0)
**/
setLogStatus(playerid, logId, bool:status)
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
			incomingConnectionLogging = status;
			dini_IntSet(CONFIG_FILE, INCOMING_CONNECTION_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Incoming connection logging %s.", message);
		}
		case 2:
		{
			chatLogging = status;
			dini_IntSet(CONFIG_FILE, CHAT_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Chat logging %s.", message);
		}
		case 3:
		{
			commandLogging = status;
			dini_IntSet(CONFIG_FILE, COMMAND_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Command logging %s.", message);
		}
		case 4:
		{
			shootingLogging = status;
			dini_IntSet(CONFIG_FILE, SHOOTING_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Shooting command logging disabled.");
		}
		case 5:
		{
			positionLogging = status;
			dini_IntSet(CONFIG_FILE, POSITION_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Position command logging %s.", message);
		}
		case 6:
		{
			rconLoginLogging = status;
			dini_IntSet(CONFIG_FILE, RCON_LOGIN_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Rcon login logging %s.", message);
		}
		case 7:
		{
			deathLogging = status;
			dini_IntSet(CONFIG_FILE, DEATH_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Death logging %s.", message);
		}
		case 8:
		{
			connectLogging = status;
			dini_IntSet(CONFIG_FILE, CONNECT_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Connect command logging %s.", message);
		}
		case 9:
		{
			disconnectLogging = status;
			dini_IntSet(CONFIG_FILE, DISCONNECT_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Disconnect command logging %s.", message);
		}
		case 10:
		{
			interiorLogging = status;
			dini_IntSet(CONFIG_FILE, INTERIOR_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Interior logging %s.", message);
		}
		case 11:
		{
			carEnterLogging = status;
			dini_IntSet(CONFIG_FILE, CAR_ENTER_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Car enter logging %s.", message);
		}
		case 12:
		{
			carExitLogging = status;
			dini_IntSet(CONFIG_FILE, CAR_EXIT_LOGGING, status);
			SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Car exit logging %s.", message);
		}
		default:
		{
			SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Your input was incorrect, try again.");
		}
	}
}

/**
 * "erases" a file by deleting and recreating it
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
	HTTP(1337, HTTP_GET, "loggingsystem.w4f.eu/version.txt", "", "versionCheckResponse");
	return 1;
}

intToBool(intToConvert, &boolToSet)
{
	if(intToConvert >= 1)
	{
	    boolToSet = true;
	}
	boolToSet = false;
}

/**
 * Loads the settings from the file into the variables
**/
loadConfig()
{
	intToBool(dini_Int(CONFIG_FILE, POSITION_LOGGING), positionLogging);
	intToBool(dini_Int(CONFIG_FILE, CHAT_LOGGING), chatLogging);
	intToBool(dini_Int(CONFIG_FILE, COMMAND_LOGGING), commandLogging);
	intToBool(dini_Int(CONFIG_FILE, SHOOTING_LOGGING), shootingLogging);
	intToBool(dini_Int(CONFIG_FILE, DEATH_LOGGING), deathLogging);
	intToBool(dini_Int(CONFIG_FILE, INCOMING_CONNECTION_LOGGING), incomingConnectionLogging);
	intToBool(dini_Int(CONFIG_FILE, CONNECT_LOGGING), connectLogging);
	intToBool(dini_Int(CONFIG_FILE, DISCONNECT_LOGGING), disconnectLogging);
	intToBool(dini_Int(CONFIG_FILE, INTERIOR_LOGGING), interiorLogging);
	intToBool(dini_Int(CONFIG_FILE, RCON_LOGIN_LOGGING), rconLoginLogging);
	intToBool(dini_Int(CONFIG_FILE, CAR_ENTER_LOGGING), carEnterLogging);
	intToBool(dini_Int(CONFIG_FILE, CAR_EXIT_LOGGING), carExitLogging);
	saveMode = dini_Int(CONFIG_FILE, SAVE_MODE);
	saveTime = dini_Int(CONFIG_FILE, LOG_FILES_PER_X);
	return 1;
}

/**
 * Returns the full time and date (Day, Month, Year, Hour, Minute, Second)
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
  		default:
  		{
  		    date = "";
		}
	}
	return date;
}

/**
 * Checks if the given string is numeric
 *
 * string 	the string that is to check
 * returns 	1 if it is numeric and 0 if it isn't
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
 * returns 	the players name
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
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[62];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 62, "Logs/%s/Chat%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 62, "Logs/%s%s.log", name, getTimeInfo());
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
	format(logData, 190, "%s %s: %s \r\n\n", getDateAndTime(), name, text);
	writeDataIfPossible(path, logData);
	return 1;
}

logIncomingConnection(playerid, ipAdress[], port)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	format(path, 80, "Logs/IncomingConnections%s.log", getTimeInfo());
 	new logData[100];
	format(logData, 100, "%s Incoming connection, playerid: %d Name(might be empty): %s IP: %s Port: %d %s \r\n\n", getDateAndTime(), playerid, name, ipAdress, port);
	writeDataIfPossible(path, logData);
	return 1;
}

logConnect(playerid)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Connect%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
	format(logData, 100, "%s %s connected with IP: %s \r\n\n", getDateAndTime(), name, ip);
	writeDataIfPossible(path, logData);
	return 1;
}

logDisconnect(playerid, reason)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Disconnect%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
	format(logData, 100, "%s %s (IP:%s) disconnected, reason: %s \r\n\n", getDateAndTime(), name, ip, reasonString);
	writeDataIfPossible(path, logData);
	return 1;
}

logCommand(playerid, cmdtext[])
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Command%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
	format(logData, 200, "%s %s: %s \r\n\n", getDateAndTime(), name, cmdtext);
	writeDataIfPossible(path, logData);
	return 1;
}

logDeath(playerid, killerid, reason, victimcase)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Death%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
			format(logData, 200, "%s %s was killed by: %s, weapon: %s \r\n\n", getDateAndTime(), name, getName(killerid), reason);
		}
		else if(victimcase == CULPRIT)
		{
			format(logData, 200, "%s %s has killed %s, weapon: %s \r\n\n", getDateAndTime(), getName(killerid), name, reason);
		}
	}
	else
	{
		format(logData, 200, "%s %s died, reason: %s \r\n\n", getDateAndTime(), name, reason);
	}
	writeDataIfPossible(path, logData);
	return 1;
}

logShooting(playerid, damagedid, Float:amount, weaponid, victimcase)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Shooting%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
		format(logData, 200, "%s %s ---> %s %f %i \r\n\n", getDateAndTime(), name, getName(damagedid), Float:amount, weaponid);
	}
	else if(victimcase == VICTIM)
	{
		format(logData, 200, "%s %s ---> %s %f %i \r\n\n", getDateAndTime(), getName(damagedid), name, Float:amount, weaponid);
	}
	writeDataIfPossible(path, logData);
	return 1;
}

logInteriorChange(playerid, int1, int2)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/Interior%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
	format(logData, 200, "%s %s's new interior: %i, old interior: %i \r\n\n", getDateAndTime(), name, int1, int2);
	writeDataIfPossible(path, logData);
	return 1;
}

logExitingVehicle(playerid, seat, vehicleid, modelid)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/CarExit%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
		 case 128:
		 {
		    //128 is an invalid seat
		    return 0;
		 }
		 default:
		 {
		 	seatName = "Passenger";
		 }
	}
	new logData[200];
	format(logData, 200, "%s %s left a vehicle, Seat: %s, VehicleID: %i, ModelID: %i \r\n\n", getDateAndTime(), name, seatName, vehicleid, modelid);
	writeDataIfPossible(path, logData);
	return 1;
}

logRconLogin(playerid, bool:success, ip[], password[])
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/RconLogin%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
		format(logData, 200, "%s %s (IP:%s) has failed to login as RCON, password: %s\r\n\n", getDateAndTime(), name, ip, password);
	}
	else
	{
		format(logData, 200, "%s %s (IP:%s) has logged in as RCON \r\n\n", getDateAndTime(), name, ip);
	}
	writeDataIfPossible(path, logData);
	return 1;
}

logEnteringVehicle(playerid, seat, vehicleid, modelid)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:
		{
			format(path, 80, "Logs/%s/CarEnter%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
		 case 128:
		 {
		    //128 is an invalid seat
		    return 0;
		 }
		 default:
		 {
		 	seatName = "Passenger";
		 }
	}
	new logData[200];
	format(logData, 200, "%s %s entered a vehicle, Seat: %s, VehicleID: %i, ModelID: %i \r\n\n", getDateAndTime(), name, seatName, vehicleid, modelid);
	writeDataIfPossible(path, logData);
	return 1;
}

public logPlayerLocation(playerid)
{
	new name[MAX_PLAYER_NAME];
	name = getName(playerid);
	new path[80];
	switch(saveMode)
	{
		case 1:		{
			format(path, 80, "Logs/%s/Position%s.log", name, getTimeInfo());
		}
		case 2:
		{
			format(path, 80, "Logs/%s%s.log", name, getTimeInfo());
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
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	new logData[150];
	format(logData, 150, "%s %s's Location X: %f | Y: %f | Z: %f\r\n\n", getDateAndTime(), name, X, Y, Z);
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
	switch(saveMode)
	{
		case 1:
		{
			logPartString[11] = "SaveMode 1[X] 2[ ] 3[ ] 4[ ]";
		}
		case 2:
		{
			logPartString[11] = "SaveMode 1[ ] 2[X] 3[ ] 4[ ]";
		}
		case 3:
		{
			logPartString[11] = "SaveMode 1[ ] 2[ ] 3[X] 4[ ]";
		}
		case 4:
		{
			logPartString[11] = "SaveMode 1[ ] 2[ ] 3[ ] 4[X]";
		}
	}
	switch(saveTime)
	{
		case 1:
		{
			logPartString[12] = "Save logfiles per hour";
		}
		case 2:
		{
			logPartString[12] = "Save logfiles per day";
		}
		case 3:
		{
			logPartString[12] = "Save logfiles per month";
		}
		case 4:
		{
			logPartString[12] = "Save logfiles per year";
		}
		default:
		{
			logPartString[12] = "Save logfiles per (Function disabled)";
		}
	}
	new string[370];
	format(string, 370, "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\nPositionLogInterval\n \nDisable All\nEnable All", logPartString[0], logPartString[1], logPartString[2], logPartString[3], logPartString[4], logPartString[5], logPartString[6], logPartString[7], logPartString[8], logPartString[9], logPartString[10], logPartString[11], logPartString[12]);
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
	format(logPartSizeString[0], 60, "PositionLog(Size:%i)", getFileSize("Logs/Position.log"));
	format(logPartSizeString[1], 60, "ChatLog(Size:%i)", getFileSize("Logs/Chat.log"));
	format(logPartSizeString[2], 60, "CommandLog(Size:%i)", getFileSize("Logs/Command.log"));
	format(logPartSizeString[3], 60, "ShootingLog(Size:%i)", getFileSize("Logs/Shooting.log"));
	format(logPartSizeString[4], 60, "DeathLog(Size:%i)", getFileSize("Logs/Death.log"));
	format(logPartSizeString[5], 60, "ConnectLog(Size:%i)", getFileSize("Logs/Connect.log"));
	format(logPartSizeString[6], 60, "DisconnectLog(Size:%i)", getFileSize("Logs/Disconnect.log"));
	format(logPartSizeString[7], 60, "InteriorLog(Size:%i)", getFileSize("Logs/Interior.log"));
	format(logPartSizeString[8], 60, "RconLoginLog(Size:%i)", getFileSize("Logs/RconLogin.log"));
	format(logPartSizeString[9], 60, "CarEnterLog(Size:%i)", getFileSize("Logs/CarEnter.log"));
	format(logPartSizeString[10], 60, "CarExitLog(Size:%i)", getFileSize("Logs/CarExit.log"));
	format(logPartSizeString[11], 60, "IncomingConnectionLog(Size:%i)", getFileSize("Logs/IncomingConnection.log"));
	new logSizes[800];
	format(logSizes, 800, "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", logPartSizeString[0], logPartSizeString[1],
	logPartSizeString[2], logPartSizeString[3], logPartSizeString[4], logPartSizeString[5], logPartSizeString[6],
	logPartSizeString[7], logPartSizeString[8], logPartSizeString[9], logPartSizeString[10], logPartSizeString[11]);
	ShowPlayerDialog(playerid, SAVEMODE4_CHOOSE, DIALOG_STYLE_LIST, "Log clean", logSizes, "Confirm", "Back");
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
			format(logcl, 125, "Are you sure that you want to clean the IncomingConnection Log file(Size:%i)", getFileSize("Logs/IncomingConnection.log"));
			ShowPlayerDialog(playerid, S4_CLEAN_INCOMINGCONNECTION, DIALOG_STYLE_LIST, "Log clean", logcl, "Confirm", "Back");
		}
	}
	return 1;
}

showLogIds(playerid)
{
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "1 = IncomingConnectionLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "2 = ChatLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "3 = CommandLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "4 = ShootingLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "5 = PositionLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "6 = DeathLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "7 = ConnectLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "8 = DisconnectLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "9 = RconLoginLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "10 = InteriorLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "11 = CarEnterLogging");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "12 = CarExitLogging");
}

public versionCheckResponse(index, response_code, data[])
{
	new VERSION = 140; //I suggest not to touch this ;D
	if(strval(data) > VERSION)
	{
		print("[Logging System] The Logging filterscript needs an update.");
		printf("[Logging System] Latest Version: %s", data);
		printf("[Logging System] Your Version: %s", VERSION);
		print("[Logging System] Downloadlink: https://github.com/Bios-Marcel/SA-MP_Log/releases/latest");
		print("[Logging System] Downloadlink(shortend): http://bit.ly/1TghSTT");
		print("Logging System] If the update notification still appears after the update, you can ignore it.");
	}
	else
	{
		print("[Logging System] The Logging system is up to date.");
	}
	return 1;
}

//COMMANDS (UNFINISHED)
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
			SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Usage: /logenable [log]");
			showLogIds(playerid);
			return 1;
		}
		setLogStatus(playerid, log , true);
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
			SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Usage: /logdisable [log]");
			showLogIds(playerid);
			return 1;
		}
		setLogStatus(playerid, log , false);
	}
	return 1;
}

CMD:loghelp(playerid, params[])
{
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "-------------------[Logging System]-------------------");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "/loghelp: displays the helpmessages that you are looking at right now :P.");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "/logmenu: opens the configuration dialog list.");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "/logenable: enable a specific log.");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "/logdisable: disable a specific log.");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "/logsavemode: set the save mode.");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "/savemodeinfo: tells you what each of the save modes does.");
	SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "/setpositionloginterval: set the position log interval for players.");
	return 1;
}

CMD:savemodeinfo(playerid, params[])
{
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 1 will create a folder for every player and a logfile for every category (Example: JohnCena/Chat.log).");
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 2 will save all information that has to be logged into per-player files (Example: JohnCena.log).");
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 3 will save all information that has to be logged into a global logfile called 'Log.log'.");
	SendClientMessage(playerid, -1 , "[Logging System] Savemode 4 will save all information that has to be logged in seperate files foor every category (chat.log, command.log, ...).");
	return 1;
}

CMD:setpositionloginterval(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		ShowPlayerDialog(playerid, SETPOSLOGINTERVAL, DIALOG_STYLE_INPUT, "Set position logging interval", "Enter a number between '1' and 'infinite' (you should enter at lest 500), the format is milliseconds", "Confirm", "Backs");
	}
	return 1;
}

CMD:logsavemode(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new newSaveMode;
		if(sscanf(params, "i", newSaveMode))
		{
			return SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Usage: /logsavemode [1/2/3/4] \n[Logging System] For information about the diffrent savemodes type /savemodeinfo");
		}
		if((newSaveMode >= 1) && (newSaveMode <= 4))
		{
		    saveMode = newSaveMode;
		    dini_IntSet(CONFIG_FILE, SAVE_MODE, newSaveMode);
		    SendClientMessageFormatted(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Savemode has been set to %i.", newSaveMode);
		}
		else
		{
		    SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] Usage: /logsavemode [1/2/3/4] \n[Logging System] For information about the diffrent savemodes type /savemodeinfo");
		}
		SendClientMessage(playerid, DEFAULT_MESSAGE_COLOR, "[Logging System] For information about the diffrent savemodes use /savemodeinfo");
	}
	return 1;
}
