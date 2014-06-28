// Mavericks RolePlay

#include 										<a_samp>
#include 										"../include/a_mysql.inc"
#include 										"../include/a_mail.inc"
#include										"../include/streamer.inc"
#include 										"../include/dc_cmd.inc"
#include 										"../include/sscanf2.inc"

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

#define MAX_WEAPON_SLOT                         (10)

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
#define sKick(%0) 								SetTimerEx("OnPlayerKick", 100, false, "i", %0)

enum p_var
{
	p_name[MAX_PLAYER_NAME],
	p_password[16],
	p_email[32],
	p_sex,
	p_skin,
	p_money,
	p_level,
	p_exp,
}

new mysql;

new timer_player_weapons_update[MAX_PLAYERS];

new player[MAX_PLAYERS][p_var];
new player_weapons[MAX_PLAYERS][MAX_WEAPON_SLOT][2];

new player_skins[12] = {21, 58, 60, 72, 101, 170, 56, 65, 192, 193, 211, 226};

new Text: menu_createplayer[10];
new PlayerText: pmenu_createplayer[MAX_PLAYERS][2];

forward OnPlayerVerification(playerid);
forward OnPlayerLogin(playerid);
forward OnPlayerKick(playerid);
forward OnPlayerWeaponsLoad(playerid);
forward OnPlayerWeaponsUpdate(playerid);

/*
stock NameLastname(src[], name[], lastname[])
    sscanf(src, "p<_>s[24]s[24]", name, lastname);  */

sSavePlayer(playerid)
{
	new query[512];
	
    mysql_format(mysql, query, sizeof(query), "UPDATE `"BASE_PLAYERS"` SET `password`='%e', `email`='%e', `sex`='%i', `skin`='%i', `money`='%i', `level`='%i', `exp`='%i' WHERE `name`='%e'",
	player[playerid][p_password],
	player[playerid][p_email],
	player[playerid][p_sex],
	player[playerid][p_skin],
	player[playerid][p_money],
	player[playerid][p_level],
	player[playerid][p_exp],
	player[playerid][p_name]);
	mysql_query(mysql, query);
	
	mysql_format(mysql, query, sizeof(query), "UPDATE `"BASE_PLAYER_WEAPONS"` SET `weapon_1`='%i', `weapon_2`='%i', `weapon_3`='%i', `weapon_4`='%i', `weapon_5`='%i', `weapon_6`='%i', `weapon_7`='%i', `weapon_8`='%i', `weapon_9`='%i', `weapon_10`='%i', `ammo_1`='%i', `ammo_2`='%i', `ammo_3`='%i', `ammo_4`='%i', `ammo_5`='%i', `ammo_6`='%i', `ammo_7`='%i', `ammo_8`='%i', `ammo_9`='%i', `ammo_10`='%i' WHERE `name`='%s'",
    player_weapons[playerid][0][0],
    player_weapons[playerid][1][0],
    player_weapons[playerid][2][0],
    player_weapons[playerid][3][0],
    player_weapons[playerid][4][0],
    player_weapons[playerid][5][0],
	player_weapons[playerid][6][0],
    player_weapons[playerid][7][0],
    player_weapons[playerid][8][0],
    player_weapons[playerid][9][0],
    player_weapons[playerid][0][1],
    player_weapons[playerid][1][1],
    player_weapons[playerid][2][1],
    player_weapons[playerid][3][1],
    player_weapons[playerid][4][1],
    player_weapons[playerid][5][1],
	player_weapons[playerid][6][1],
    player_weapons[playerid][7][1],
    player_weapons[playerid][8][1],
    player_weapons[playerid][9][1],
   	player[playerid][p_name]);
   	mysql_query(mysql, query);

	return 1;
}

sGivePlayerMoney(playerid, money) 
{
	GivePlayerMoney(playerid, money);
	player[playerid][p_money] += money;
	
	return 1;
}

sSetPlayerMoney(playerid, money) 
{
    ResetPlayerMoney(playerid);
   	GivePlayerMoney(playerid, money);
	player[playerid][p_money] = money;
	
	return 1;
}

sGivePlayerLevel(playerid, level) 
{
	SetPlayerScore(playerid, player[playerid][p_level]+level);
	player[playerid][p_level] += level;
	
	return 1;
}

sSetPlayerLevel(playerid, level) 
{
	SetPlayerScore(playerid, level);
	player[playerid][p_level] = level;
	
	return 1;
}

sSetPlayerPos(playerid, Float:x, Float:y, Float:z, Float:r = 0.0) 
{
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);
	
	return 1;
}

sGivePlayerWeapon(playerid, weaponid, ammo) 
{
 	new slot = sGetWeaponSlot(weaponid);
 	player_weapons[playerid][slot][0] = weaponid;
	player_weapons[playerid][slot][1] += ammo;
	GivePlayerWeapon(playerid, weaponid, ammo);
	
	return 1;
}

sResetPlayerWeapons(playerid) 
{
	ResetPlayerWeapons(playerid);
	
	for(new i = 0; i < MAX_WEAPON_SLOT; i++) 
	{
	    player_weapons[playerid][i][0] = 0;
        player_weapons[playerid][i][1] = 0;
	}
	
	return 1;
}

sGetWeaponSlot(weaponid) 
{ 
    switch(weaponid) 
    { 
		case 0..1: return 0;
        case 2..9: return 1; 
        case 10..15: return 2; 
        case 22..24: return 3; 
        case 25..27: return 4; 
        case 28..29, 32: return 5; 
        case 30..31: return 6; 
        case 33..34: return 7; 
        case 41..43: return 8; 
        case 44..46: return 9; 
    } 
	return 0;
} 

main()
{
 	SetGameModeText(""MODE_NAME" "MODE_VERSION"");
   	EnableStuntBonusForAll(false); 
	DisableInteriorEnterExits(); 
	
	return 1;
}

public OnGameModeInit()
{
    mysql = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE, MYSQL_PASSWORD);
	
	print(""MODE_NAME" "MODE_VERSION"");
	
	CreateDynamicObject(19379, 1413.2099609, -1485.0791016, 98.6199799, 0.0000000, 90.0000000, 0.0000000); //object(wall027) (1)
	CreateDynamicObject(19379, 1418.0000000, -1482.7998047, 98.6199799, 0.0000000, 90.0000000, 136.6973877); //object(wall027) (2)
	CreateDynamicObject(19367, 1409.6190186, -1488.5200195, 100.5000153, 0.0000000, 0.0000000, 90.0000000); //object(wall015) (2)
	CreateDynamicObject(18001, 1421.2600098, -1486.8900146, 99.4069977, 0.0000000, 0.0000000, 226.5000000); //object(int_barbera07) (1)
	CreateDynamicObject(18001, 1421.2600098, -1486.8900146, 100.8300018, 0.0000000, 0.0000000, 226.4996338); //object(int_barbera07) (2)
	CreateDynamicObject(19440, 1411.1298828, -1489.2285156, 100.5000153, 0.0000000, 0.0000000, 0.0000000); //object(wall080) (1)
	CreateDynamicObject(18001, 1414.4000244, -1489.8399658, 100.8300018, 0.0000000, 0.0000000, 180.0000000); //object(int_barbera07) (4)
	CreateDynamicObject(18001, 1414.3984375, -1489.8398438, 99.4069977, 0.0000000, 0.0000000, 179.9945068); //object(int_barbera07) (6)
	CreateDynamicObject(3850, 1419.2500000, -1487.7900391, 99.2500000, 0.0000000, 0.0000000, 315.9997559); //object(carshowbann_sfsx) (1)
	CreateDynamicObject(3850, 1416.3590088, -1489.0000000, 99.2500000, 0.0000000, 0.0000000, 270.0000000); //object(carshowbann_sfsx) (2)
	CreateDynamicObject(3850, 1412.9394531, -1489.0000000, 99.2500000, 0.0000000, 0.0000000, 270.0000000); //object(carshowbann_sfsx) (3)
	CreateDynamicObject(19367, 1421.2500000, -1485.0000000, 100.5000153, 0.0000000, 0.0000000, 136.4996643); //object(wall015) (1)
	CreateDynamicObject(19440, 1420.6989746, -1486.5999756, 100.5000153, 0.0000000, 0.0000000, 45.9997559); //object(wall080) (2)
	CreateDynamicObject(19377, 1413.2099609, -1485.0781250, 101.6520004, 0.0000000, 90.0000000, 0.0000000); //object(wall025) (1)
	CreateDynamicObject(19377, 1418.0000000, -1482.7998047, 101.6500015, 0.0000000, 90.0000000, 136.4996643); //object(wall025) (2)
	CreateDynamicObject(19367, 1422.9439697, -1483.1939697, 100.5000153, 0.0000000, 0.0000000, 136.4996643); //object(wall015) (3)
	CreateDynamicObject(638, 1419.5996094, -1488.0000000, 99.2500000, 0.0000000, 0.0000000, 315.9997559); //object(kb_planter_bush) (1)
	CreateDynamicObject(638, 1416.2998047, -1489.3994141, 99.2500000, 0.0000000, 0.0000000, 269.9945068); //object(kb_planter_bush) (2)
	CreateDynamicObject(638, 1412.6459961, -1489.4279785, 99.2500000, 0.0000000, 0.0000000, 89.5000000); //object(kb_planter_bush) (3)

    menu_createplayer[0] = TextDrawCreate(397.0, 130.0, "menu:framework"); 
	TextDrawLetterSize(menu_createplayer[0], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[0], 256.0, 256.0);
	TextDrawAlignment(menu_createplayer[0], 1);
	TextDrawColor(menu_createplayer[0], -1);
	TextDrawSetShadow(menu_createplayer[0], 0);
	TextDrawSetOutline(menu_createplayer[0], 0);
	TextDrawFont(menu_createplayer[0], 4);
	
	menu_createplayer[1] = TextDrawCreate(467.0, 154.0, "CO€ѓA®…E ЊEPCO®A„A"); // Создание персонажа
	TextDrawBackgroundColor(menu_createplayer[1], 255);
	TextDrawFont(menu_createplayer[1], 2);
	TextDrawLetterSize(menu_createplayer[1], 0.25, 1.7);
	TextDrawColor(menu_createplayer[1], -1);
	TextDrawSetOutline(menu_createplayer[1], 0);
	TextDrawSetProportional(menu_createplayer[1], 1);
	TextDrawSetShadow(menu_createplayer[1], 0);
	TextDrawSetSelectable(menu_createplayer[1], 0);	
	
	menu_createplayer[2] = TextDrawCreate(454.0, 179.0, "menu:left");
	TextDrawLetterSize(menu_createplayer[2], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[2], 32.0, 32.0);
	TextDrawAlignment(menu_createplayer[2], 1);
	TextDrawColor(menu_createplayer[2], -1);
	TextDrawSetShadow(menu_createplayer[2], 0);
	TextDrawSetOutline(menu_createplayer[2], 0);
	TextDrawFont(menu_createplayer[2], 4);
	TextDrawSetSelectable(menu_createplayer[2], true);
	
	menu_createplayer[3] = TextDrawCreate(564.0, 179.0, "menu:right");
	TextDrawLetterSize(menu_createplayer[3], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[3], 32.0, 32.0);
	TextDrawAlignment(menu_createplayer[3], 1);
	TextDrawColor(menu_createplayer[3], -1);
	TextDrawSetShadow(menu_createplayer[3], 0);
	TextDrawSetOutline(menu_createplayer[3], 0);
	TextDrawFont(menu_createplayer[3], 4);
	TextDrawSetSelectable(menu_createplayer[3], true);
	
	menu_createplayer[4] = TextDrawCreate(454.0, 251.0, "menu:left");
	TextDrawLetterSize(menu_createplayer[4], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[4], 32.0, 32.0);
	TextDrawAlignment(menu_createplayer[4], 1);
	TextDrawColor(menu_createplayer[4], -1);
	TextDrawSetShadow(menu_createplayer[4], 0);
	TextDrawSetOutline(menu_createplayer[4], 0);
	TextDrawFont(menu_createplayer[4], 4);
	TextDrawSetSelectable(menu_createplayer[4], true);
	
	menu_createplayer[5] = TextDrawCreate(564.0, 251.0, "menu:right");
	TextDrawLetterSize(menu_createplayer[5], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[5], 32.0, 32.0);
	TextDrawAlignment(menu_createplayer[5], 1);
	TextDrawColor(menu_createplayer[5], -1);
	TextDrawSetShadow(menu_createplayer[5], 0);
	TextDrawSetOutline(menu_createplayer[5], 0);
	TextDrawFont(menu_createplayer[5], 4);
	TextDrawSetSelectable(menu_createplayer[5], true);	

	menu_createplayer[6] = TextDrawCreate(461.0, 131.0, "menu:box");
	TextDrawLetterSize(menu_createplayer[6], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[6], 128.0, 128.0);
	TextDrawAlignment(menu_createplayer[6], 1);
	TextDrawColor(menu_createplayer[6], -1);
	TextDrawSetShadow(menu_createplayer[6], 0);
	TextDrawSetOutline(menu_createplayer[6], 0);
	TextDrawFont(menu_createplayer[6], 4);
	
	menu_createplayer[7] = TextDrawCreate(461.0, 206.0, "menu:big_box");
	TextDrawLetterSize(menu_createplayer[7], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[7], 128.0, 128.0);
	TextDrawAlignment(menu_createplayer[7], 1);
	TextDrawColor(menu_createplayer[7], -1);
	TextDrawSetShadow(menu_createplayer[7], 0);
	TextDrawSetOutline(menu_createplayer[7], 0);
	TextDrawFont(menu_createplayer[7], 4);	

	menu_createplayer[8] = TextDrawCreate(493.0, 314.0, "menu:button");
	TextDrawLetterSize(menu_createplayer[8], 0.0, 0.0);
	TextDrawTextSize(menu_createplayer[8], 64.0, 64.0);
	TextDrawAlignment(menu_createplayer[8], 1);
	TextDrawColor(menu_createplayer[8], -1);
	TextDrawSetShadow(menu_createplayer[8], 0);
	TextDrawSetOutline(menu_createplayer[8], 0);
	TextDrawFont(menu_createplayer[8], 4);
	TextDrawSetSelectable(menu_createplayer[8], true);	
	
	menu_createplayer[9] = TextDrawCreate(505.0, 339.0, "‚O¦O‹O"); // Готово
	TextDrawBackgroundColor(menu_createplayer[9], 255);
	TextDrawFont(menu_createplayer[9], 2);
	TextDrawLetterSize(menu_createplayer[9], 0.27, 1.3);
	TextDrawColor(menu_createplayer[9], -1);
	TextDrawSetOutline(menu_createplayer[9], 0);
	TextDrawSetProportional(menu_createplayer[9], 1);
	TextDrawSetShadow(menu_createplayer[9], 0);

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
	
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `"BASE_PLAYERS"` WHERE `name` = '%e'", player[playerid][p_name]);
	mysql_function_query(mysql, query, true, "OnPlayerVerification", "i", playerid);

	return 1;
}

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, player[playerid][p_name], MAX_PLAYER_NAME);
    
	player[playerid][p_sex] = 0;
	player[playerid][p_skin] = 0;
	player[playerid][p_money] = 0;
	player[playerid][p_level] = 0;
	player[playerid][p_exp] = 0;
	
	sResetPlayerWeapons(playerid);
	
	pmenu_createplayer[playerid][0] = CreatePlayerTextDraw(playerid, 497.0, 190.0, "MY„Ќ…®A"); // Мужчина
	PlayerTextDrawLetterSize(playerid, pmenu_createplayer[playerid][0], 0.3, 1.0);
	PlayerTextDrawAlignment(playerid, pmenu_createplayer[playerid][0], 1);
	PlayerTextDrawColor(playerid, pmenu_createplayer[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, pmenu_createplayer[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, pmenu_createplayer[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, pmenu_createplayer[playerid][0], 255);
	PlayerTextDrawFont(playerid, pmenu_createplayer[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, pmenu_createplayer[playerid][0], 1);	

	pmenu_createplayer[playerid][1] = CreatePlayerTextDraw(playerid, 495.0, 226.0, "_");
	PlayerTextDrawLetterSize(playerid, pmenu_createplayer[playerid][1], 0.0, 0.0);
	PlayerTextDrawTextSize(playerid, pmenu_createplayer[playerid][1], 60.0, 90.0);
	PlayerTextDrawAlignment(playerid, pmenu_createplayer[playerid][1], 1);
	PlayerTextDrawColor(playerid, pmenu_createplayer[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, pmenu_createplayer[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, pmenu_createplayer[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, pmenu_createplayer[playerid][1], 0xFFFFFF00);
	PlayerTextDrawFont(playerid, pmenu_createplayer[playerid][1], 5);	
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(!GetPVarInt(playerid, "Logged")) return 1;
	
	sSavePlayer(playerid);
	KillTimer(timer_player_weapons_update[playerid]);
    
	return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!GetPVarInt(playerid, "Logged")) return Kick(playerid);

    if(player[playerid][p_sex] == -1 && player[playerid][p_skin] == -1)
    {
		player[playerid][p_sex] = 1;
		player[playerid][p_skin] = player_skins[0];
		
		SetPlayerSkin(playerid, player_skins[0]); 
		SetPlayerVirtualWorld(playerid, 100+playerid);
		
		TogglePlayerControllable(playerid, false);
		sSetPlayerPos(playerid, 1418.8008, -1487.4066, 99.7059, 49.6524);
  		SetPlayerCameraPos(playerid, 1416.6300, -1485.1952, 100.0);
		SetPlayerCameraLookAt(playerid, 1418.8008, -1487.4066, 99.7059);
		
		for(new i = 0; i < 10; i++) TextDrawShowForPlayer(playerid, menu_createplayer[i]);
		PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[0]);
		PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][0]);
        PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		SelectTextDraw(playerid, 0xAAAAAAFF);
		
        SetPVarInt(playerid, "CreatePlayer", 1);
	}
	
    new query[60+MAX_PLAYER_NAME];
	
	SetPlayerSkin(playerid, player[playerid][p_skin]);
	sSetPlayerMoney(playerid, player[playerid][p_money]);
	sSetPlayerLevel(playerid, player[playerid][p_level]);
	
 	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `player_weapons` WHERE `name` = '%e' ", player[playerid][p_name]),
	mysql_function_query(mysql, query, true, "OnPlayerWeaponsLoad", "i", playerid);
	
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
	return 0;
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

				strcopy(player[playerid][p_password], inputtext, 16);
				
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
				player[playerid][p_name]);

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

                strcopy(player[playerid][p_email], inputtext, 32);
                
                new string[170];
                
                SetPVarInt(playerid, "RegistrationСode", 1000 + random(9000));
                
                format(string, sizeof(string),"Ваш код: %i", GetPVarInt(playerid, "RegistrationСode"));
				SendClientMessage(playerid, -1, string);
                
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
				Введите четырехзначный код из письма\n\
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
				
	    		mysql_format(mysql, query, sizeof(query), "INSERT INTO `"BASE_PLAYERS"` (`name`, `password`, `email`) VALUES ('%e', '%e', '%e')", player[playerid][p_name], player[playerid][p_password], player[playerid][p_email]);
				mysql_query(mysql, query);
				mysql_format(mysql, query, sizeof(query), "INSERT INTO `"BASE_PLAYER_WEAPONS"` (`name`) VALUE ('%s')", player[playerid][p_name]);
				mysql_query(mysql, query);
				
				player[playerid][p_sex] = -1;
				player[playerid][p_skin] = -1;

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
				
	            mysql_format(mysql, query, sizeof(query), "SELECT * FROM `"BASE_PLAYERS"` WHERE `name` = '%e' AND `password` = '%e'", player[playerid][p_name], inputtext),
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
			 	player[playerid][p_name]);

		        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COLOR_GOLD"Авторизация", string, "OK", "");
			}
			else
			{
   				ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Ошибка", ""COLOR_WHITE"Вы были отключены от сервера\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
			    Kick(playerid);
			}
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) 
{
    if(_:clickedid == INVALID_TEXT_DRAW) 
	{
        if(GetPVarInt(playerid, "CreatePlayer")) return SelectTextDraw(playerid, 0xAAAAAAFF);
	}
	
	if(clickedid == menu_createplayer[2])
	{
		if(player[playerid][p_sex] == 1)
		{
			player[playerid][p_sex] = 2;
			player[playerid][p_skin] = player_skins[6];
			
			SetPlayerSkin(playerid, player_skins[6]);
			
			PlayerTextDrawSetString(playerid, pmenu_createplayer[playerid][0], "„E®Љ…®A"); // Женщина
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[6]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_sex] == 2)
		{
			player[playerid][p_sex] = 1;
			player[playerid][p_skin] = player_skins[0];
			
			SetPlayerSkin(playerid, player_skins[0]);
			
			PlayerTextDrawSetString(playerid, pmenu_createplayer[playerid][0], "MY„Ќ…®A"); // Мужчина
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[0]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 10.0);
	}
	
	if(clickedid == menu_createplayer[3])
	{
		if(player[playerid][p_sex] == 1)
		{
			player[playerid][p_sex] = 2;
			player[playerid][p_skin] = player_skins[6];
			
			SetPlayerSkin(playerid, player_skins[6]);
			
			PlayerTextDrawSetString(playerid, pmenu_createplayer[playerid][0], "„E®Љ…®A"); // Женщина
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[6]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_sex] == 2)
		{
			player[playerid][p_sex] = 1;
			player[playerid][p_skin] = player_skins[0];
			
			SetPlayerSkin(playerid, player_skins[0]);
			
			PlayerTextDrawSetString(playerid, pmenu_createplayer[playerid][0], "MY„Ќ…®A"); // Мужчина
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[0]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 10.0);
	}
	
	if(clickedid == menu_createplayer[4])
	{
		if(player[playerid][p_skin] == player_skins[0]) // Мужские
		{
			SetPlayerSkin(playerid, player_skins[5]);
			player[playerid][p_skin] = player_skins[5];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[5]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[5])
		{
			SetPlayerSkin(playerid, player_skins[4]);
			player[playerid][p_skin] = player_skins[4];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[4]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[4])
		{
			SetPlayerSkin(playerid, player_skins[3]);
			player[playerid][p_skin] = player_skins[3];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[3]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[3])
		{
			SetPlayerSkin(playerid, player_skins[2]);
			player[playerid][p_skin] = player_skins[2];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[2]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[2])
		{
			SetPlayerSkin(playerid, player_skins[1]);
			player[playerid][p_skin] = player_skins[1];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[1]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}		
		else if(player[playerid][p_skin] == player_skins[1])
		{
			SetPlayerSkin(playerid, player_skins[0]);
			player[playerid][p_skin] = player_skins[0];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[0]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}		
		else if(player[playerid][p_skin] == player_skins[6]) // Женские
		{
			SetPlayerSkin(playerid, player_skins[11]);
			player[playerid][p_skin] = player_skins[11];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[11]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}			
		else if(player[playerid][p_skin] == player_skins[11])
		{
			SetPlayerSkin(playerid, player_skins[10]);
			player[playerid][p_skin] = player_skins[10];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[10]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[10])
		{
			SetPlayerSkin(playerid, player_skins[9]);
			player[playerid][p_skin] = player_skins[9];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[9]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[9])
		{
			SetPlayerSkin(playerid, player_skins[8]);
			player[playerid][p_skin] = player_skins[8];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[8]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[8])
		{
			SetPlayerSkin(playerid, player_skins[7]);
			player[playerid][p_skin] = player_skins[7];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[7]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}		
		else if(player[playerid][p_skin] == player_skins[7])
		{
			SetPlayerSkin(playerid, player_skins[6]);
			player[playerid][p_skin] = player_skins[6];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[6]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 10.0);
	}
	
	if(clickedid == menu_createplayer[5])
	{
		if(player[playerid][p_skin] == player_skins[0]) // Мужские
		{
			SetPlayerSkin(playerid, player_skins[1]);
			player[playerid][p_skin] = player_skins[1];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[1]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[1])
		{
			SetPlayerSkin(playerid, player_skins[2]);
			player[playerid][p_skin] = player_skins[2];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[2]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[2])
		{
			SetPlayerSkin(playerid, player_skins[3]);
			player[playerid][p_skin] = player_skins[3];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[3]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[3])
		{
			SetPlayerSkin(playerid, player_skins[4]);
			player[playerid][p_skin] = player_skins[4];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[4]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[4])
		{
			SetPlayerSkin(playerid, player_skins[5]);
			player[playerid][p_skin] = player_skins[5];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[5]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}		
		else if(player[playerid][p_skin] == player_skins[5])
		{
			SetPlayerSkin(playerid, player_skins[0]);
			player[playerid][p_skin] = player_skins[0];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[0]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}		
		else if(player[playerid][p_skin] == player_skins[6]) // Женские
		{
			SetPlayerSkin(playerid, player_skins[7]);
			player[playerid][p_skin] = player_skins[7];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[7]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}			
		else if(player[playerid][p_skin] == player_skins[7])
		{
			SetPlayerSkin(playerid, player_skins[8]);
			player[playerid][p_skin] = player_skins[8];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[8]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[8])
		{
			SetPlayerSkin(playerid, player_skins[9]);
			player[playerid][p_skin] = player_skins[9];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[9]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[9])
		{
			SetPlayerSkin(playerid, player_skins[10]);
			player[playerid][p_skin] = player_skins[10];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[10]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		else if(player[playerid][p_skin] == player_skins[10])
		{
			SetPlayerSkin(playerid, player_skins[11]);
			player[playerid][p_skin] = player_skins[11];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[11]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}		
		else if(player[playerid][p_skin] == player_skins[11])
		{
			SetPlayerSkin(playerid, player_skins[6]);
			player[playerid][p_skin] = player_skins[6];
			
			PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
			PlayerTextDrawSetPreviewModel(playerid, pmenu_createplayer[playerid][1], player_skins[6]);
			PlayerTextDrawShow(playerid, pmenu_createplayer[playerid][1]);
		}
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 10.0);
	}
	
	if(clickedid == menu_createplayer[8])
	{
		for(new i = 0; i < 10; i++) TextDrawHideForPlayer(playerid, menu_createplayer[i]);
		PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][0]);
        PlayerTextDrawHide(playerid, pmenu_createplayer[playerid][1]);
		CancelSelectTextDraw(playerid);
		
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 10.0);
		
		player[playerid][p_money] = random(50)+20;
        player[playerid][p_level] = 1;
		
		DeletePVar(playerid, "CreatePlayer");
		SetPlayerVirtualWorld(playerid, 0);
        TogglePlayerControllable(playerid, true);
        SpawnPlayer(playerid);		
	}
	
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
		player[playerid][p_name]);

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
	 	player[playerid][p_name]);
		
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""COLOR_GOLD"Авторизация", string, "OK", "");
	}
	return 1;
}

public OnPlayerLogin(playerid)
{
	if(cache_get_row_count(mysql))
	{
        cache_get_field_content(0, "password", player[playerid][p_password], mysql, 16);
        cache_get_field_content(0, "email", player[playerid][p_email], mysql, 32);
	    player[playerid][p_sex] = cache_get_field_content_int(0, "sex", mysql);
	    player[playerid][p_skin] = cache_get_field_content_int(0, "skin", mysql);
	    player[playerid][p_money] = cache_get_field_content_int(0, "money", mysql);
	    player[playerid][p_level] = cache_get_field_content_int(0, "level", mysql);
	    player[playerid][p_exp] = cache_get_field_content_int(0, "exp", mysql);

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

public OnPlayerWeaponsLoad(playerid)
{
	player_weapons[playerid][0][0] = cache_get_field_content_int(0, "weapon_1", mysql);
	player_weapons[playerid][1][0] = cache_get_field_content_int(0, "weapon_2", mysql);
	player_weapons[playerid][2][0] = cache_get_field_content_int(0, "weapon_3", mysql);
	player_weapons[playerid][3][0] = cache_get_field_content_int(0, "weapon_4", mysql);
	player_weapons[playerid][4][0] = cache_get_field_content_int(0, "weapon_5", mysql);
	player_weapons[playerid][5][0] = cache_get_field_content_int(0, "weapon_6", mysql);
	player_weapons[playerid][6][0] = cache_get_field_content_int(0, "weapon_7", mysql);
	player_weapons[playerid][7][0] = cache_get_field_content_int(0, "weapon_8", mysql);
	player_weapons[playerid][8][0] = cache_get_field_content_int(0, "weapon_9", mysql);
	player_weapons[playerid][9][0] = cache_get_field_content_int(0, "weapon_10", mysql);
	player_weapons[playerid][0][1] = cache_get_field_content_int(0, "ammo_1", mysql);
	player_weapons[playerid][1][1] = cache_get_field_content_int(0, "ammo_2", mysql);
	player_weapons[playerid][2][1] = cache_get_field_content_int(0, "ammo_3", mysql);
	player_weapons[playerid][3][1] = cache_get_field_content_int(0, "ammo_4", mysql);
	player_weapons[playerid][4][1] = cache_get_field_content_int(0, "ammo_5", mysql);
	player_weapons[playerid][5][1] = cache_get_field_content_int(0, "ammo_6", mysql);
	player_weapons[playerid][6][1] = cache_get_field_content_int(0, "ammo_7", mysql);
	player_weapons[playerid][7][1] = cache_get_field_content_int(0, "ammo_8", mysql);
	player_weapons[playerid][8][1] = cache_get_field_content_int(0, "ammo_9", mysql);
	player_weapons[playerid][9][1] = cache_get_field_content_int(0, "ammo_10", mysql);
	
	for(new i; i < MAX_WEAPON_SLOT; i++) GivePlayerWeapon(playerid, player_weapons[playerid][i][0], player_weapons[playerid][i][1]);
	
	timer_player_weapons_update[playerid] = SetTimerEx("OnPlayerWeaponsUpdate", 1000, true, "i", playerid);
	
	return 1;
}

public OnPlayerWeaponsUpdate(playerid)
{
	new weapon = GetPlayerWeapon(playerid);
 	new ammo = GetPlayerAmmo(playerid);
 	new slot = sGetWeaponSlot(weapon);
	
	if(weapon == 16 || weapon == 17 || weapon == 18 || weapon == 35 || weapon == 36 || weapon == 37 || weapon == 38 || weapon == 39 || weapon == 40 || weapon == 44 ||weapon == 45)
	{
	    sResetPlayerWeapons(playerid);
	    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Анти-Чит", ""COLOR_WHITE"Вы были отключены от сервера\nв связи использования чит-программ\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
		sKick(playerid);

		return 1;	
	}
	
	if(weapon != player_weapons[playerid][slot][0]) 
	{
	    sResetPlayerWeapons(playerid);
	    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Анти-Чит", ""COLOR_WHITE"Вы были отключены от сервера\nв связи использования чит-программ\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
		sKick(playerid);

		return 1;
	}
	
	if(ammo <= player_weapons[playerid][slot][1]) player_weapons[playerid][slot][1] = ammo;	
	else
	{
	    sResetPlayerWeapons(playerid);
	    ShowPlayerDialog(playerid, DIALOG_NONE, DIALOG_STYLE_MSGBOX, ""COLOR_GOLD"Анти-Чит", ""COLOR_WHITE"Вы были отключены от сервера\nв связи использования чит-программ\nЧтобы выйти введите команду "COLOR_YELLOW"/q", "OK", "");
		sKick(playerid);
		return 1;
	}
	
	if(weapon !=0 && ammo == 0) player_weapons[playerid][slot][0] = 0;
	
	return 1;
}

CMD:giveweapon(playerid, params[])
{
	if(sscanf(params, "uii", params[0], params[1], params[2])) return SendClientMessage(playerid, -1,"Использование: /giveweapon [id] [weapon] [ammo]");
	sGivePlayerWeapon(params[0], params[1], params[2]);
	
	return 1;
}

CMD:givelevel(playerid, params[])
{
	if(sscanf(params, "ui", params[0], params[1])) return SendClientMessage(playerid, -1,"Использование: /givelevel [id] [level]");
	sGivePlayerLevel(params[0], params[1]);
	
	return 1;
}

CMD:givemoney(playerid, params[])
{
	if(sscanf(params, "ui", params[0], params[1])) return SendClientMessage(playerid, -1,"Использование: /givemoney [id] [money]");
	sGivePlayerMoney(params[0], params[1]);
	
	return 1;
}
