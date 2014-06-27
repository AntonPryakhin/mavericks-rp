// Mavericks RolePlay

#include 										<a_samp>
#include 										"../include/a_mysql.inc"
#include 										"../include/a_mail.inc"
#include										"../include/streamer.inc"

#define MODE_NAME 								"Mavericks RP"
#define MODE_VERSION 							"Alpha 0.1"

#define MYSQL_HOST 								"127.0.0.1"
#define MYSQL_USER 								"root"
#define MYSQL_DATABASE 							"server"
#define MYSQL_PASSWORD 							""

#define BASE_PLAYERS                            "players"
#define BASE_PLAYER_WEAPONS                     "player_weapons"

#define DIALOG_NONE                             (0)
#define DIALOG_REGISTER                         (1)
#define DIALOG_LOGIN                            (8)
#define D_ENTERHOUSE                            (10)
#define D_BUYHOUSE                              (11)

#define MAX_WEAPON_SLOT                         (6)

#define COLOR_BLACK 							"{000000}"
#define COLOR_BLUE 								"{0000FF}"
#define COLOR_CHOCOLATE 						"{D2691E}"
#define COLOR_DARKRED 							"{8B0000}"
#define COLOR_DEEPSKYBLUE 						"{00BFFF}"
#define COLOR_GOLD 								"{FFD700}"
#define COLOR_GRAY 								"{808080}"
#define COLOR_GREEN 							'{008000}"
#define COLOR_LIGHTGRAY 						"{D3D3D3}"
#define COLOR_LIGHTGREEN 						"{90EE90}"
#define COLOR_LIGHTYELLOW 						"{FFFFE0}"
#define COLOR_LIME 								"{00FF00}"
#define COLOR_LIMEGREEN 						"{32CD32}"
#define COLOR_ORANGE 							"{FFA500}"
#define COLOR_ORANGERED 						"{FF4500}"
#define COLOR_PINK 								"{FFC0CB}"
#define COLOR_PURPLE 							"{800080}"
#define COLOR_RED 								"{FF0000}"
#define COLOR_SILVER 							"{C0C0C0}"
#define COLOR_SKYBLUE 							"{87CEEB}"
#define COLOR_TOMATO 							"{FF6347}"
#define COLOR_VIOLET 							"{EE82EE}"
#define COLOR_WHITE 							"{FFFFFF}"
#define COLOR_YELLOW 							"{FFFF00}"
#define COLOR_YELLOWGREEN 						"{9ACD32}"

#define strcopy(%0,%1,%2) 						strmid(%0, %1, 0, strlen(%1), %2)
#define fixKick(%0) 							SetTimerEx("OnPlayerKick", 100, false, "i", %0)
#define Kick(%0)								fixKick(%0)
#define SetPlayerPos(%0,%1,%2,%3,%4)			fixSetPlayerPos(%0, %1, %2, %3, %4)
#define MAX_HOUSES 100

enum houseinfo
{
	id,
	owner[24],
	price,
	interior,
	Float:hx,
	Float:hy,
	Float:hz,
	pickup,
	lock,
};
new house[MAX_HOUSES][houseinfo];

enum pvar
{
	pname[MAX_PLAYER_NAME],
	ppassword[16],
	pemail[32],
	psex,
	pskin,
	pmoney,
	plevel,
	pexp,
}

new mysql;

new player[MAX_PLAYERS][pvar];
new player_weapons[MAX_PLAYERS][MAX_WEAPON_SLOT][2];
new hIcon[MAX_HOUSES];
new hPickup[MAX_HOUSES];
new SellToWho[MAX_HOUSES];

forward OnPlayerVerification(playerid);
forward OnPlayerLogin(playerid);
forward OnPlayerKick(playerid);
forward OnPlayerLoadWeapons(playerid);
forward OnPlayerUpdateWeapons(playerid);
forward OnLoadHouse(houseid);
forward SellHouse(playerid);


public OnLoadHouse(houseid)
{
	if(cache_get_row_count(mysql))
	{
 		house[houseid][id] = cache_get_field_content_int(0, "id", mysql);
        cache_get_field_content(0, "owner", house[houseid][owner], mysql, 24);
        house[houseid][price] = cache_get_field_content_int(0, "price", mysql);
        house[houseid][interior] = cache_get_field_content_int(0, "interior", mysql);
        house[houseid][hx] = cache_get_field_content_float(0, "hx", mysql);
        house[houseid][hy] = cache_get_field_content_float(0, "hy", mysql);
        house[houseid][hz] = cache_get_field_content_float(0, "hz", mysql);
        house[houseid][pickup] = cache_get_field_content_int(0, "pickup", mysql);
        house[houseid][lock] = cache_get_field_content_int(0, "lock", mysql);
        hIcon[houseid] = CreateDynamicMapIcon(house[houseid][hx], house[houseid][hy], house[houseid][hz], 31, -1, 0 , 0, -1, 100.0);
		if(!strcmp(house[houseid][owner], "no-one"))
		{
  		hPickup[houseid] = CreateDynamicPickup(1242, 1,house[houseid][hx], house[houseid][hy], house[houseid][hz], -1);
		}
		else
		{
		hPickup[houseid] = CreateDynamicPickup(1243, 1,house[houseid][hx], house[houseid][hy], house[houseid][hz], -1);
		}
   	}
        
}

LoadHouses()
{
	for(new i; i < MAX_HOUSES; i++)
	{
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM houses WHERE id = '%i", i);
	mysql_function_query(mysql, query, true, "OnLoadHouse", "i", houseid);
	}
}


SavePlayer(playerid)
{
	new query[512];
	
    mysql_format(mysql, query, sizeof(query), "UPDATE `"BASE_PLAYERS"` SET `password`='%e', `email`='%e', `sex`='%i', `skin`='%i', `money`='%i', `level`='%i', `exp`='%i' WHERE `name`='%e'",
	player[playerid][ppassword],
	player[playerid][pemail],
	player[playerid][psex],
	player[playerid][pskin],
	player[playerid][pmoney],
	player[playerid][plevel],
	player[playerid][pexp],
	player[playerid][pname]);
	mysql_query(mysql, query);
	
	mysql_format(mysql, query, sizeof(query), "UPDATE `"BASE_PLAYER_WEAPONS"` SET `weapon_1`='%i', `weapon_2`='%i', `weapon_3`='%i', `weapon_4`='%i', `weapon_5`='%i', `weapon_6`='%i', `ammo_1`='%i', `ammo_2`='%i', `ammo_3`='%i', `ammo_4`='%i', `ammo_5`='%i', `ammo_6`='%i' WHERE `name`='%s'",
    player_weapons[playerid][0][0],
    player_weapons[playerid][1][0],
    player_weapons[playerid][2][0],
    player_weapons[playerid][3][0],
    player_weapons[playerid][4][0],
    player_weapons[playerid][5][0],
    player_weapons[playerid][0][1],
    player_weapons[playerid][1][1],
    player_weapons[playerid][2][1],
    player_weapons[playerid][3][1],
    player_weapons[playerid][4][1],
    player_weapons[playerid][5][1],
   	player[playerid][pname]);
   	mysql_query(mysql, query);

	return 1;
}

fixSetPlayerPos(playerid, Float:x, Float:y, Float:z, Float:r = 0.0)
{
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);
	return 1;
}

main()
{
 	SetGameModeText(""MODE_NAME" "MODE_VERSION"");

	return 1;
}

public OnGameModeInit()
{
    mysql = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE, MYSQL_PASSWORD);
	
	print(""MODE_NAME" "MODE_VERSION"");

	return 1;
}

public OnGameModeExit()
{
    mysql_close(mysql);
    
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	new query[50+24];
	
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `"BASE_PLAYERS"` WHERE `name` = '%e'", player[playerid][pname]);
	mysql_function_query(mysql, query, true, "OnPlayerVerification", "i", playerid);

	return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, player[playerid][pname], MAX_PLAYER_NAME);
    
	player[playerid][psex] = 0;
	player[playerid][pskin] = 0;
	player[playerid][pmoney] = 0;
	player[playerid][plevel] = 0;
	player[playerid][pexp] = 0;
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(GetPVarInt(playerid, "Logged")) return SavePlayer(playerid);
    
	return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!GetPVarInt(playerid, "Logged")) return Kick(playerid);
    
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/sellhouse", true))
	{
	    new query[250];
		mysql_format(mysql, query, sizeof(query), "SELECT `price`, `ID` FROM `houses` WHERE `owner` = '%s", 	player[playerid][pname]);
		mysql_function_query(mysql, query, true, "SellHouse", "i", playerid);
		return 1;
	}
return 0;
}
public SellHouse(playerid)
{
	new housesid = GetPlayerVirtualWorld(playerid);
	new query[250];
	if(housesid >=1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 10.0, house[housesid][hx], house[housesid][hy], house[housesid][hz]))
		{
		GivePlayerMoney(playerid, house[housesid][price]/2);
		mysql_format(mysql, query, sizeof(query), "UPDATE `houses` SET `owner` = 'no-one', `lock` = '1'");
		}
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	new housesid = GetPlayerVirtualWorld(playerid);
	if(housesid >=1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, house[housesid][hx], house[housesid][hy], house[housesid][hz]))
		{
			SetPlayerPos(playerid, house[housesid][hx], house[housesid][hy], house[housesid][hz]);
			SetCameraBehindPlayer(playerid);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			return 1;
		}
	}
		else
	{
		for(new h = 1; h < MAX_HOUSES; h++) if(IsPlayerInRangeOfPoint(playerid, 2.0, house[h][hx], house[h][hy], house[h][hz]))
	{
	if(!strcmp(house[h][owner], "no-one"))
	{
		new dialog[256];
		format(dialog, sizeof(dialog),"Íîìåð äîìà:\t\t\t%i\nÃîñ.ñòîèìîñòü:\t\t$%\n\nÂëàäåëåö:\t\t\t%s", h,house[h][price], house[h][hz],house[h][owner]);
		ShowPlayerDialog(playerid, D_BUYHOUSE, DIALOG_STYLE_MSGBOX, "Äîì ñâîáîäåí", dialog, "Êóïèòü", "Îòìåíà");
		return 1;
	}
		else
	{
		new dialog[256];
		format(dialog, sizeof(dialog),"Íîìåð äîìà:\t\t\t%i\nÃîñ.ñòîèìîñòü:\t\t$%\n\nÂëàäåëåö:\t\t\t%s", h,house[h][price], house[h][hz],house[h][owner]);
		ShowPlayerDialog(playerid, D_ENTERHOUSE, DIALOG_STYLE_MSGBOX, "Äîì çàíÿò", dialog, "Âîéòè", "Îòìåíà");
		return 1;
	}
	}
	}
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(response)
			{
				if(!strlen(inputtext))
				    return ShowPlayerDialog(playerid, DIALOG_REGISTER+1, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Ââåäèòå ïàðîëü!", "Ïîâòîðèòü", "");
	   			if(strlen(inputtext) < 6 || strlen(inputtext) > 16)
   					return ShowPlayerDialog(playerid, DIALOG_REGISTER+1, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Íåêîððåêòíûé ïàðîëü!", "Ïîâòîðèòü", "");

				strcopy(player[playerid][ppassword], inputtext, 16);
				
				new string[115];
				
				format(string, sizeof(string),
				""COLOR_WHITE"Ââåäèòå âàø email:\n\
				\n\
				"COLOR_LIMEGREEN"Ïðèìå÷àíèå: ââîäèòå òîëüêî ðàáî÷èé email,\n\
				íà íåãî ïðèéäåò êîä ïîäòâåðæäåíèÿ");
				
	   			ShowPlayerDialog(playerid, DIALOG_REGISTER+2, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Óñòàíîâêà email", string, "OK", "");
   			}
	   		else
	   		{
			    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
  		case DIALOG_REGISTER+1:
  		{
			if(response)
			{
			    new string[215+MAX_PLAYER_NAME];

			    format(string, sizeof(string),
				""COLOR_WHITE"Äîáðî ïîæàëîâàòü íà ñåðâåð "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
				"COLOR_WHITE"Äëÿ èãðû íåîáõîäèìî çàðåãèñòðèðîâàòüñÿ\n\
				\n\
				Âàø ëîãèí: "COLOR_YELLOW"%s\n\
				"COLOR_WHITE"Ââåäèòå ïàðîëü:\n\
				\n\
				"COLOR_LIMEGREEN"Ïðèìå÷àíèå: ïàðîëü äîëæåí ñîñòîÿòü\n\
				ìèíèìóì èç 6 ñèìâîëîâ",
				player[playerid][pname]);

				ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Óñòàíîâêà ïàðîëÿ", string, "ÎÊ", "");
			}
			else
			{
			    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+2:
		{
			if(response)
			{
				if(!strlen(inputtext))
				    return ShowPlayerDialog(playerid, DIALOG_REGISTER+3, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Ââåäèòå email!", "Ïîâòîðèòü", "");
				if(strfind(inputtext, "@", true) == -1 && strfind(inputtext, ".", true) == -1 || strlen(inputtext) > 32)
					return ShowPlayerDialog(playerid, DIALOG_REGISTER+3, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Íåêîððåêòíûé email!", "Ïîâòîðèòü", "");

                strcopy(player[playerid][pemail], inputtext, 32);
                
                new string[165];
                
                SetPVarInt(playerid, "RegistrationÑode", 100000 + random(900000));
                printf("ID:%i RegistrationCode:%i", playerid, GetPVarInt(playerid, "RegistrationÑode"));
                
                format(string, sizeof(string),
				"Âû íà÷àëè ðåãèñòðàöèþ íà ñåðâåðå "MODE_NAME"\n\
				Êîä ïîäòâåðæäåíèÿ: %i\n\
				Äëÿ ïðîäîëæåíèÿ ââåäèòå åãî â èãðå\n\
				\n\
				Ñ óâàæåíèåì, àäìèíèñòðàöèÿ "MODE_NAME"",
				GetPVarInt(playerid, "RegistrationÑode"));
				
				//SendMail(player[playerid][pemail], "support@mavericks-rp.ru", MODE_NAME, "Ïîäòâåðæäåíèå email", string);
				
				format(string, sizeof(string),
				""COLOR_WHITE"Íà email áûë îòïðàâëåí êîä ïîäòâåðæäåíèÿ\n\
				Ââåäèòå øåñòèçíà÷íûé êîä èç ïèñüìà\n\
                \n\
				"COLOR_LIMEGREEN"Ïîäñêàçêà: ÷òîáû ñâåðíóòü èãðó èñïîëüçóéòå\n\
				ñî÷åòàíèå êëàâèø Tab+Alt");
				
				ShowPlayerDialog(playerid, DIALOG_REGISTER+4, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Ïîäòâåðæäåíèå email", string, "ÎÊ", "");
                
			}
			else
			{
			    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+3:
		{
			if(response)
			{
				new string[115];

				format(string, sizeof(string),
				""COLOR_WHITE"Ââåäèòå âàø email:\n\
				\n\
				"COLOR_LIMEGREEN"Ïðèìå÷àíèå: ââîäèòå òîëüêî ðàáî÷èé email,\n\
				íà íåãî ïðèéäåò êîä ïîäòâåðæäåíèÿ");

	   			ShowPlayerDialog(playerid, DIALOG_REGISTER+2, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Óñòàíîâêà email", string, "OK", "");
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+4:
		{
			if(response)
			{
				if(!strlen(inputtext))
				    return ShowPlayerDialog(playerid, DIALOG_REGISTER+5, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Ââåäèòå êîä!", "Ïîâòîðèòü", "");
			    if(strval(inputtext) != GetPVarInt(playerid, "RegistrationÑode"))
                    return ShowPlayerDialog(playerid, DIALOG_REGISTER+5, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Íåâåðíûé êîä!", "Ïîâòîðèòü", "");

				new query[75+16+32+MAX_PLAYER_NAME];
				
	    		mysql_format(mysql, query, sizeof(query), "INSERT INTO `"BASE_PLAYERS"` (`name`, `password`, `email`) VALUES ('%e', '%e', '%e')", player[playerid][pname], player[playerid][ppassword], player[playerid][pemail]);
				mysql_query(mysql, query);
				mysql_format(mysql, query, sizeof(query), "INSERT INTO `"BASE_PLAYER_WEAPONS"` (`name`) VALUE ('%s')", player[playerid][pname]);
				mysql_query(mysql, query);
				
				player[playerid][psex] = -1;
				player[playerid][pskin] = -1;

                ShowPlayerDialog(playerid, DIALOG_REGISTER+6, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Çàêëþ÷åíèå", ""COLOR_WHITE"Ðåãèñòðàöèÿ óñïåøíî çàâåðøåíà", "Èãðàòü", "");

			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
  		case DIALOG_REGISTER+5:
  		{
			if(response)
			{
			    new string[165];
			
				format(string, sizeof(string),
				""COLOR_WHITE"Íà email áûë îòïðàâëåí êîä ïîäòâåðæäåíèÿ\n\
				Ââåäèòå øåñòèçíà÷íûé êîä èç ïèñüìà\n\
                \n\
				"COLOR_LIMEGREEN"Ïîäñêàçêà: ÷òîáû ñâåðíóòü èãðó èñïîëüçóéòå\n\
				ñî÷åòàíèå êëàâèø Tab+Alt");

				ShowPlayerDialog(playerid, DIALOG_REGISTER+4, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Ïîäòâåðæäåíèå email", string, "ÎÊ", "");
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+6: // 7
		{
			if(response)
			{
                SetPVarInt(playerid, "Logged", 1);
                SpawnPlayer(playerid);
			}
			else ShowPlayerDialog(playerid, DIALOG_REGISTER+6, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Çàêëþ÷åíèå", ""COLOR_WHITE"Ðåãèñòðàöèÿ óñïåøíî çàâåðøåíà", "Èãðàòü", "");
		}
		case DIALOG_LOGIN:
		{
			if(response)
			{
				new query[60+16+MAX_PLAYER_NAME];
				
	            mysql_format(mysql, query, sizeof(query), "SELECT * FROM `"BASE_PLAYERS"` WHERE `name` = '%e' AND `password` = '%e'", player[playerid][pname], inputtext),
				mysql_function_query(mysql, query, true, "OnPlayerLogin", "i", playerid);
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_LOGIN+1: // 9
		{
			if(response)
			{
 				new string[200+MAX_PLAYER_NAME];

				format(string, sizeof(string),
				""COLOR_WHITE"Äîáðî ïîæàëîâàòü íà ñåðâåð "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
				"COLOR_WHITE"Âû óæå çàðåãèñòðèðîâàíû\n\
		        \n\
				Ëîãèí: "COLOR_YELLOW"%s\n\
				"COLOR_WHITE"Ââåäèòå ïàðîëü:\n\
				\n\
				"COLOR_LIMEGREEN"Ïðèìå÷àíèå: íåàêòèâíûå áîëåå 30 äíåé\n\
				àêêàóíòû óäàëÿþòñÿ",
			 	player[playerid][pname]);

		        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COLOR_GOLD"Àâòîðèçàöèÿ", string, "OK", "");
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Âû áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
 		case(D_BUYHOUSE):
 		{

 		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerVerification(playerid)
{
	if(!cache_get_row_count(mysql))
	{
	    new string[215+MAX_PLAYER_NAME];
	    
	    format(string, sizeof(string),
		""COLOR_WHITE"Äîáðî ïîæàëîâàòü íà ñåðâåð "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
		"COLOR_WHITE"Äëÿ èãðû íåîáõîäèìî çàðåãèñòðèðîâàòüñÿ\n\
		\n\
		Âàø ëîãèí: "COLOR_YELLOW"%s\n\
		"COLOR_WHITE"Ââåäèòå ïàðîëü:\n\
		\n\
		"COLOR_LIMEGREEN"Ïðèìå÷àíèå: ïàðîëü äîëæåí ñîñòîÿòü\n\
		ìèíèìóì èç 6 ñèìâîëîâ",
		player[playerid][pname]);

		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Ðåãèñòðàöèÿ | Óñòàíîâêà ïàðîëÿ", string, "ÎÊ", "");
	}
	else
	{
		new string[200+MAX_PLAYER_NAME];
		
		format(string, sizeof(string),
		""COLOR_WHITE"Äîáðî ïîæàëîâàòü íà ñåðâåð "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
		"COLOR_WHITE"Âû óæå çàðåãèñòðèðîâàíû\n\
        \n\
		Ëîãèí: "COLOR_YELLOW"%s\n\
		"COLOR_WHITE"Ââåäèòå ïàðîëü:\n\
		\n\
		"COLOR_LIMEGREEN"Ïðèìå÷àíèå: íåàêòèâíûå áîëåå 30 äíåé\n\
		àêêàóíòû óäàëÿþòñÿ",
	 	player[playerid][pname]);
		
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COLOR_GOLD"Àâòîðèçàöèÿ", string, "OK", "");
	}
	return 1;
}

public OnPlayerLogin(playerid)
{
	if(cache_get_row_count(mysql))
	{
        cache_get_field_content(0, "password", player[playerid][ppassword], mysql, 16);
        cache_get_field_content(0, "email", player[playerid][pemail], mysql, 32);
	    player[playerid][psex] = cache_get_field_content_int(0, "sex", mysql);
	    player[playerid][pskin] = cache_get_field_content_int(0, "skin", mysql);
	    player[playerid][pmoney] = cache_get_field_content_int(0, "money", mysql);
	    player[playerid][plevel] = cache_get_field_content_int(0, "level", mysql);
	    player[playerid][pexp] = cache_get_field_content_int(0, "exp", mysql);

		SetPVarInt(playerid, "Logged", 1);
		SpawnPlayer(playerid);
	}
	else
	{
  		if(GetPVarInt(playerid, "WrongPassword") == 2)
 		{
		    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", ""COLOR_WHITE"Íåâåðíûé ïàðîëü!\nÂû îøèáëèñü áîëåå òðåõ ðàç\nè áûëè îòêëþ÷åíû îò ñåðâåðà\n×òîáû âûéòè ââåäèòå êîìàíäó "COLOR_YELLOW"/q", "OK", "");
		    Kick(playerid);
		}
		else
		{
		    new string[55];
		    
			SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword") + 1);
			
			format(string, sizeof(string), ""COLOR_WHITE"Íåâåðíûé ïàðîëü!\nÎñòàëîñü ïîïûòîê: "COLOR_GRAY"%i/3", 3-GetPVarInt(playerid, "WrongPassword"));
			ShowPlayerDialog(playerid, DIALOG_LOGIN+1, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Îøèáêà", string, "Ïîâòîðèòü", "");
		}
	}
	return 1;
}// Mavericks RolePlay

#include 										<a_samp>
#include 										"../include/a_mysql.inc"
#include 										"../include/a_mail.inc"
#include										"../include/streamer.inc"

#define MODE_NAME 								"Mavericks RP"
#define MODE_VERSION 							"Alpha 0.1"

#define MYSQL_HOST 								"127.0.0.1"
#define MYSQL_USER 								"root"
#define MYSQL_DATABASE 							"server"
#define MYSQL_PASSWORD 							""

#define BASE_PLAYERS                            "players"
#define BASE_PLAYER_WEAPONS                     "player_weapons"

#define DIALOG_NONE                             (0)
#define DIALOG_REGISTER                         (1)
#define DIALOG_LOGIN                            (8)
#define D_ENTERHOUSE                            (10)
#define D_BUYHOUSE                              (11)

#define MAX_WEAPON_SLOT                         (6)

#define COLOR_BLACK 							"{000000}"
#define COLOR_BLUE 								"{0000FF}"
#define COLOR_CHOCOLATE 						"{D2691E}"
#define COLOR_DARKRED 							"{8B0000}"
#define COLOR_DEEPSKYBLUE 						"{00BFFF}"
#define COLOR_GOLD 								"{FFD700}"
#define COLOR_GRAY 								"{808080}"
#define COLOR_GREEN 							'{008000}"
#define COLOR_LIGHTGRAY 						"{D3D3D3}"
#define COLOR_LIGHTGREEN 						"{90EE90}"
#define COLOR_LIGHTYELLOW 						"{FFFFE0}"
#define COLOR_LIME 								"{00FF00}"
#define COLOR_LIMEGREEN 						"{32CD32}"
#define COLOR_ORANGE 							"{FFA500}"
#define COLOR_ORANGERED 						"{FF4500}"
#define COLOR_PINK 								"{FFC0CB}"
#define COLOR_PURPLE 							"{800080}"
#define COLOR_RED 								"{FF0000}"
#define COLOR_SILVER 							"{C0C0C0}"
#define COLOR_SKYBLUE 							"{87CEEB}"
#define COLOR_TOMATO 							"{FF6347}"
#define COLOR_VIOLET 							"{EE82EE}"
#define COLOR_WHITE 							"{FFFFFF}"
#define COLOR_YELLOW 							"{FFFF00}"
#define COLOR_YELLOWGREEN 						"{9ACD32}"

#define strcopy(%0,%1,%2) 						strmid(%0, %1, 0, strlen(%1), %2)
#define fixKick(%0) 							SetTimerEx("OnPlayerKick", 100, false, "i", %0)
#define Kick(%0)								fixKick(%0)
#define SetPlayerPos(%0,%1,%2,%3,%4)			fixSetPlayerPos(%0, %1, %2, %3, %4)
#define MAX_HOUSES 100

enum houseinfo
{
	id,
	owner[24],
	price,
	interior,
	Float:hx,
	Float:hy,
	Float:hz,
	pickup,
	lock,
};
new house[MAX_HOUSES][houseinfo];

enum pvar
{
	pname[MAX_PLAYER_NAME],
	ppassword[16],
	pemail[32],
	psex,
	pskin,
	pmoney,
	plevel,
	pexp,
}

new mysql;

new player[MAX_PLAYERS][pvar];
new player_weapons[MAX_PLAYERS][MAX_WEAPON_SLOT][2];
new hIcon[MAX_HOUSES];
new hPickup[MAX_HOUSES];
new SellToWho[MAX_HOUSES];

forward OnPlayerVerification(playerid);
forward OnPlayerLogin(playerid);
forward OnPlayerKick(playerid);
forward OnPlayerLoadWeapons(playerid);
forward OnPlayerUpdateWeapons(playerid);
forward OnLoadHouse(houseid);
forward SellHouse(playerid);


public OnLoadHouse(houseid)
{
	if(cache_get_row_count(mysql))
	{
 		house[houseid][id] = cache_get_field_content_int(0, "id", mysql);
        cache_get_field_content(0, "owner", house[houseid][owner], mysql, 24);
        house[houseid][price] = cache_get_field_content_int(0, "price", mysql);
        house[houseid][interior] = cache_get_field_content_int(0, "interior", mysql);
        house[houseid][hx] = cache_get_field_content_float(0, "hx", mysql);
        house[houseid][hy] = cache_get_field_content_float(0, "hy", mysql);
        house[houseid][hz] = cache_get_field_content_float(0, "hz", mysql);
        house[houseid][pickup] = cache_get_field_content_int(0, "pickup", mysql);
        house[houseid][lock] = cache_get_field_content_int(0, "lock", mysql);
        hIcon[houseid] = CreateDynamicMapIcon(house[houseid][hx], house[houseid][hy], house[houseid][hz], 31, -1, 0 , 0, -1, 100.0);
		if(!strcmp(house[houseid][owner], "no-one"))
		{
  		hPickup[houseid] = CreateDynamicPickup(1242, 1,house[houseid][hx], house[houseid][hy], house[houseid][hz], -1);
		}
		else
		{
		hPickup[houseid] = CreateDynamicPickup(1243, 1,house[houseid][hx], house[houseid][hy], house[houseid][hz], -1);
		}
   	}
        
}

LoadHouses()
{
	for(new i; i < MAX_HOUSES; i++)
	{
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM houses WHERE id = '%i", i);
	mysql_function_query(mysql, query, true, "OnLoadHouse", "i", houseid);
	}
}


SavePlayer(playerid)
{
	new query[512];
	
    mysql_format(mysql, query, sizeof(query), "UPDATE `"BASE_PLAYERS"` SET `password`='%e', `email`='%e', `sex`='%i', `skin`='%i', `money`='%i', `level`='%i', `exp`='%i' WHERE `name`='%e'",
	player[playerid][ppassword],
	player[playerid][pemail],
	player[playerid][psex],
	player[playerid][pskin],
	player[playerid][pmoney],
	player[playerid][plevel],
	player[playerid][pexp],
	player[playerid][pname]);
	mysql_query(mysql, query);
	
	mysql_format(mysql, query, sizeof(query), "UPDATE `"BASE_PLAYER_WEAPONS"` SET `weapon_1`='%i', `weapon_2`='%i', `weapon_3`='%i', `weapon_4`='%i', `weapon_5`='%i', `weapon_6`='%i', `ammo_1`='%i', `ammo_2`='%i', `ammo_3`='%i', `ammo_4`='%i', `ammo_5`='%i', `ammo_6`='%i' WHERE `name`='%s'",
    player_weapons[playerid][0][0],
    player_weapons[playerid][1][0],
    player_weapons[playerid][2][0],
    player_weapons[playerid][3][0],
    player_weapons[playerid][4][0],
    player_weapons[playerid][5][0],
    player_weapons[playerid][0][1],
    player_weapons[playerid][1][1],
    player_weapons[playerid][2][1],
    player_weapons[playerid][3][1],
    player_weapons[playerid][4][1],
    player_weapons[playerid][5][1],
   	player[playerid][pname]);
   	mysql_query(mysql, query);

	return 1;
}

fixSetPlayerPos(playerid, Float:x, Float:y, Float:z, Float:r = 0.0)
{
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);
	return 1;
}

main()
{
 	SetGameModeText(""MODE_NAME" "MODE_VERSION"");

	return 1;
}

public OnGameModeInit()
{
    mysql = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE, MYSQL_PASSWORD);
	
	print(""MODE_NAME" "MODE_VERSION"");

	return 1;
}

public OnGameModeExit()
{
    mysql_close(mysql);
    
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	new query[50+24];
	
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `"BASE_PLAYERS"` WHERE `name` = '%e'", player[playerid][pname]);
	mysql_function_query(mysql, query, true, "OnPlayerVerification", "i", playerid);

	return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, player[playerid][pname], MAX_PLAYER_NAME);
    
	player[playerid][psex] = 0;
	player[playerid][pskin] = 0;
	player[playerid][pmoney] = 0;
	player[playerid][plevel] = 0;
	player[playerid][pexp] = 0;
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(GetPVarInt(playerid, "Logged")) return SavePlayer(playerid);
    
	return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!GetPVarInt(playerid, "Logged")) return Kick(playerid);
    
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/sellhouse", true))
	{
	    new query[250];
		mysql_format(mysql, query, sizeof(query), "SELECT `price`, `ID` FROM `houses` WHERE `owner` = '%s", 	player[playerid][pname]);
		mysql_function_query(mysql, query, true, "SellHouse", "i", playerid);
		return 1;
	}
return 0;
}
public SellHouse(playerid)
{
	new housesid = GetPlayerVirtualWorld(playerid);
	new query[250];
	if(housesid >=1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 10.0, house[housesid][hx], house[housesid][hy], house[housesid][hz]))
		{
		GivePlayerMoney(playerid, house[housesid][price]/2);
		mysql_format(mysql, query, sizeof(query), "UPDATE `houses` SET `owner` = 'no-one', `lock` = '1'");
		}
	}
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	new housesid = GetPlayerVirtualWorld(playerid);
	if(housesid >=1)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, house[housesid][hx], house[housesid][hy], house[housesid][hz]))
		{
			SetPlayerPos(playerid, house[housesid][hx], house[housesid][hy], house[housesid][hz]);
			SetCameraBehindPlayer(playerid);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			return 1;
		}
	}
		else
	{
		for(new h = 1; h < MAX_HOUSES; h++) if(IsPlayerInRangeOfPoint(playerid, 2.0, house[h][hx], house[h][hy], house[h][hz]))
	{
	if(!strcmp(house[h][owner], "no-one"))
	{
		new dialog[256];
		format(dialog, sizeof(dialog),"Номер дома:\t\t\t%i\nГос.стоимость:\t\t$%\n\nВладелец:\t\t\t%s", h,house[h][price], house[h][hz],house[h][owner]);
		ShowPlayerDialog(playerid, D_BUYHOUSE, DIALOG_STYLE_MSGBOX, "Дом свободен", dialog, "Купить", "Отмена");
		return 1;
	}
		else
	{
		new dialog[256];
		format(dialog, sizeof(dialog),"Номер дома:\t\t\t%i\nГос.стоимость:\t\t$%\n\nВладелец:\t\t\t%s", h,house[h][price], house[h][hz],house[h][owner]);
		ShowPlayerDialog(playerid, D_ENTERHOUSE, DIALOG_STYLE_MSGBOX, "Дом занят", dialog, "Войти", "Отмена");
		return 1;
	}
	}
	}
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(response)
			{
				if(!strlen(inputtext))
				    return ShowPlayerDialog(playerid, DIALOG_REGISTER+1, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Введите пароль!", "Повторить", "");
	   			if(strlen(inputtext) < 6 || strlen(inputtext) > 16)
   					return ShowPlayerDialog(playerid, DIALOG_REGISTER+1, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Некорректный пароль!", "Повторить", "");

				strcopy(player[playerid][ppassword], inputtext, 16);
				
				new string[115];
				
				format(string, sizeof(string),
				""COLOR_WHITE"Введите ваш email:\n\
				\n\
				"COLOR_LIMEGREEN"Примечание: вводите только рабочий email,\n\
				на него прийдет код подтверждения");
				
	   			ShowPlayerDialog(playerid, DIALOG_REGISTER+2, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Регистрация | Установка email", string, "OK", "");
   			}
	   		else
	   		{
			    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
  		case DIALOG_REGISTER+1:
  		{
			if(response)
			{
			    new string[215+MAX_PLAYER_NAME];

			    format(string, sizeof(string),
				""COLOR_WHITE"Добро пожаловать на сервер "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
				"COLOR_WHITE"Для игры необходимо зарегистрироваться\n\
				\n\
				Ваш логин: "COLOR_YELLOW"%s\n\
				"COLOR_WHITE"Введите пароль:\n\
				\n\
				"COLOR_LIMEGREEN"Примечание: пароль должен состоять\n\
				минимум из 6 символов",
				player[playerid][pname]);

				ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Регистрация | Установка пароля", string, "ОК", "");
			}
			else
			{
			    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+2:
		{
			if(response)
			{
				if(!strlen(inputtext))
				    return ShowPlayerDialog(playerid, DIALOG_REGISTER+3, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Введите email!", "Повторить", "");
				if(strfind(inputtext, "@", true) == -1 && strfind(inputtext, ".", true) == -1 || strlen(inputtext) > 32)
					return ShowPlayerDialog(playerid, DIALOG_REGISTER+3, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Некорректный email!", "Повторить", "");

                strcopy(player[playerid][pemail], inputtext, 32);
                
                new string[165];
                
                SetPVarInt(playerid, "RegistrationСode", 100000 + random(900000));
                printf("ID:%i RegistrationCode:%i", playerid, GetPVarInt(playerid, "RegistrationСode"));
                
                format(string, sizeof(string),
				"Вы начали регистрацию на сервере "MODE_NAME"\n\
				Код подтверждения: %i\n\
				Для продолжения введите его в игре\n\
				\n\
				С уважением, администрация "MODE_NAME"",
				GetPVarInt(playerid, "RegistrationСode"));
				
				//SendMail(player[playerid][pemail], "support@mavericks-rp.ru", MODE_NAME, "Подтверждение email", string);
				
				format(string, sizeof(string),
				""COLOR_WHITE"На email был отправлен код подтверждения\n\
				Введите шестизначный код из письма\n\
                \n\
				"COLOR_LIMEGREEN"Подсказка: чтобы свернуть игру используйте\n\
				сочетание клавиш Tab+Alt");
				
				ShowPlayerDialog(playerid, DIALOG_REGISTER+4, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Регистрация | Подтверждение email", string, "ОК", "");
                
			}
			else
			{
			    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+3:
		{
			if(response)
			{
				new string[115];

				format(string, sizeof(string),
				""COLOR_WHITE"Введите ваш email:\n\
				\n\
				"COLOR_LIMEGREEN"Примечание: вводите только рабочий email,\n\
				на него прийдет код подтверждения");

	   			ShowPlayerDialog(playerid, DIALOG_REGISTER+2, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Регистрация | Установка email", string, "OK", "");
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+4:
		{
			if(response)
			{
				if(!strlen(inputtext))
				    return ShowPlayerDialog(playerid, DIALOG_REGISTER+5, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Введите код!", "Повторить", "");
			    if(strval(inputtext) != GetPVarInt(playerid, "RegistrationСode"))
                    return ShowPlayerDialog(playerid, DIALOG_REGISTER+5, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Неверный код!", "Повторить", "");

				new query[75+16+32+MAX_PLAYER_NAME];
				
	    		mysql_format(mysql, query, sizeof(query), "INSERT INTO `"BASE_PLAYERS"` (`name`, `password`, `email`) VALUES ('%e', '%e', '%e')", player[playerid][pname], player[playerid][ppassword], player[playerid][pemail]);
				mysql_query(mysql, query);
				mysql_format(mysql, query, sizeof(query), "INSERT INTO `"BASE_PLAYER_WEAPONS"` (`name`) VALUE ('%s')", player[playerid][pname]);
				mysql_query(mysql, query);
				
				player[playerid][psex] = -1;
				player[playerid][pskin] = -1;

                ShowPlayerDialog(playerid, DIALOG_REGISTER+6, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Регистрация | Заключение", ""COLOR_WHITE"Регистрация успешно завершена", "Играть", "");

			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
  		case DIALOG_REGISTER+5:
  		{
			if(response)
			{
			    new string[165];
			
				format(string, sizeof(string),
				""COLOR_WHITE"На email был отправлен код подтверждения\n\
				Введите шестизначный код из письма\n\
                \n\
				"COLOR_LIMEGREEN"Подсказка: чтобы свернуть игру используйте\n\
				сочетание клавиш Tab+Alt");

				ShowPlayerDialog(playerid, DIALOG_REGISTER+4, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Регистрация | Подтверждение email", string, "ОК", "");
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_REGISTER+6: // 7
		{
			if(response)
			{
                SetPVarInt(playerid, "Logged", 1);
                SpawnPlayer(playerid);
			}
			else ShowPlayerDialog(playerid, DIALOG_REGISTER+6, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Регистрация | Заключение", ""COLOR_WHITE"Регистрация успешно завершена", "Играть", "");
		}
		case DIALOG_LOGIN:
		{
			if(response)
			{
				new query[60+16+MAX_PLAYER_NAME];
				
	            mysql_format(mysql, query, sizeof(query), "SELECT * FROM `"BASE_PLAYERS"` WHERE `name` = '%e' AND `password` = '%e'", player[playerid][pname], inputtext),
				mysql_function_query(mysql, query, true, "OnPlayerLogin", "i", playerid);
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
		case DIALOG_LOGIN+1: // 9
		{
			if(response)
			{
 				new string[200+MAX_PLAYER_NAME];

				format(string, sizeof(string),
				""COLOR_WHITE"Добро пожаловать на сервер "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
				"COLOR_WHITE"Вы уже зарегистрированы\n\
		        \n\
				Логин: "COLOR_YELLOW"%s\n\
				"COLOR_WHITE"Введите пароль:\n\
				\n\
				"COLOR_LIMEGREEN"Примечание: неактивные более 30 дней\n\
				аккаунты удаляются",
			 	player[playerid][pname]);

		        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COLOR_GOLD"Авторизация", string, "OK", "");
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
 		case(D_BUYHOUSE):
 		{

 		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerVerification(playerid)
{
	if(!cache_get_row_count(mysql))
	{
	    new string[215+MAX_PLAYER_NAME];
	    
	    format(string, sizeof(string),
		""COLOR_WHITE"Добро пожаловать на сервер "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
		"COLOR_WHITE"Для игры необходимо зарегистрироваться\n\
		\n\
		Ваш логин: "COLOR_YELLOW"%s\n\
		"COLOR_WHITE"Введите пароль:\n\
		\n\
		"COLOR_LIMEGREEN"Примечание: пароль должен состоять\n\
		минимум из 6 символов",
		player[playerid][pname]);

		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, ""COLOR_GOLD"Регистрация | Установка пароля", string, "ОК", "");
	}
	else
	{
		new string[200+MAX_PLAYER_NAME];
		
		format(string, sizeof(string),
		""COLOR_WHITE"Добро пожаловать на сервер "COLOR_DEEPSKYBLUE""MODE_NAME"\n\
		"COLOR_WHITE"Вы уже зарегистрированы\n\
        \n\
		Логин: "COLOR_YELLOW"%s\n\
		"COLOR_WHITE"Введите пароль:\n\
		\n\
		"COLOR_LIMEGREEN"Примечание: неактивные более 30 дней\n\
		аккаунты удаляются",
	 	player[playerid][pname]);
		
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COLOR_GOLD"Авторизация", string, "OK", "");
	}
	return 1;
}

public OnPlayerLogin(playerid)
{
	if(cache_get_row_count(mysql))
	{
        cache_get_field_content(0, "password", player[playerid][ppassword], mysql, 16);
        cache_get_field_content(0, "email", player[playerid][pemail], mysql, 32);
	    player[playerid][psex] = cache_get_field_content_int(0, "sex", mysql);
	    player[playerid][pskin] = cache_get_field_content_int(0, "skin", mysql);
	    player[playerid][pmoney] = cache_get_field_content_int(0, "money", mysql);
	    player[playerid][plevel] = cache_get_field_content_int(0, "level", mysql);
	    player[playerid][pexp] = cache_get_field_content_int(0, "exp", mysql);

		SetPVarInt(playerid, "Logged", 1);
		SpawnPlayer(playerid);
	}
	else
	{
  		if(GetPVarInt(playerid, "WrongPassword") == 2)
 		{
		    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Неверный пароль!\nВы ошиблись более трех раз\nи были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
		    Kick(playerid);
		}
		else
		{
		    new string[55];
		    
			SetPVarInt(playerid, "WrongPassword", GetPVarInt(playerid, "WrongPassword") + 1);
			
			format(string, sizeof(string), ""COLOR_WHITE"Неверный пароль!\nОсталось попыток: "COLOR_GRAY"%i/3", 3-GetPVarInt(playerid, "WrongPassword"));
			ShowPlayerDialog(playerid, DIALOG_LOGIN+1, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", string, "Повторить", "");
		}
	}
	return 1;
}
