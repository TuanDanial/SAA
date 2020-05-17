#include <a_samp>
#include <zcmd>
#include <fcnpc2>
#include <sscanf2>
#include <easydialog>
#include <MapAndreas1.2>
//#include <PathFinder>
#include <MapAndreasNP>
#include <dini>
#include <YSI\y_ini>
#include <YSI\y_timers>

#define ZPATH "/Zombie.ini"

enum ScriptData
{
	MAX_ZOMBIES,
	DRANGE,
	ZSKIN,
	ZHEALTH,
	ZCOLOR,

	ZAI,
	ZBLIP,
	ZHEADSHOT,
	ZRHEADSHOT,
	ZTP,
	PTZ,
	ZINFECTED,

	ANTI_MINIGUN,
	ZTCMD,
	ZPRINT,
};
new sData[ScriptData];

#define HOLDING(%0) ((newkeys & (%0)) == (%0))
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

new	CreationTimer,
	SpawnedZombies = 0,
	IsAZombie[MAX_PLAYERS],
	HumanFound[MAX_PLAYERS],
	Text3D:ZombieLabel[MAX_PLAYERS],
	InfectedTimer[MAX_PLAYERS],
	HealTimer[MAX_PLAYERS],
    Infected[MAX_PLAYERS],
    Cured[MAX_PLAYERS],
    BeingCured[MAX_PLAYERS],
	Spawned[MAX_PLAYERS];

forward CreateZombies(newkeys);
forward ZombieHealthLabel(npcid);
forward OnPlayerInfected(playerid);
forward MoveZombie(zombieid, newkeys, oldkeys);

CMD:zcmds(playerid,params[])
{
	if(sData[ZTCMD] == 1)
	{
		if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1,"{A13838}SERVER:{FFFFFF} You're not authorized to use this command!");
		Dialog_Show(playerid, ZOMBIE_CMDS, DIALOG_STYLE_MSGBOX, "Zombie Commands", "/zget \n/zgoto \n/zspawn \n/infected", "Close", "");
	} else return 1;
	return 1;
}

CMD:zget(playerid,params[])
{
	if(sData[ZTCMD] == 1)
	{
	    new targetid, Float:x, Float:y, Float:z, string[100];
	    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1,"{A13838}SERVER:{FFFFFF} You're not authorized to use this command!");
	    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, "SERVER: /zget <npc id>");
	    if(!IsPlayerNPC(targetid)) return SendClientMessage(playerid, -1, "SERVER: Target is not Zombie!");
		if(targetid == playerid) return SendClientMessage(playerid, -1, "SERVER: You cannot use this command to yourself.");
		if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "SERVER: Target ID of Zombie is not connected!");

	    GetPlayerPos(playerid, x, y, z);
	    FCNPC_SetPosition(targetid, x+5, y+5, z);
	   	format(string, sizeof(string), "{448E51}SERVER:{FFFFFF} You've teleported {%h}Zombie(%d){FFFFFF} to your location.", targetid);
		SendClientMessage(playerid, -1, string);
	} else return 1;
    return 1;
}
CMD:zgoto(playerid,params[])
{
	if(sData[ZTCMD] == 1)
	{
	    new targetid, Float:x, Float:y, Float:z, string[100];
	    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1,"{A13838}SERVER:{FFFFFF} You're not authorized to use this command!");
	    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, "SERVER: /zget <npc id>");
	    if(!IsPlayerNPC(targetid)) return SendClientMessage(playerid, -1, "SERVER: Target is not Zombie!");
		if(targetid == playerid) return SendClientMessage(playerid, -1, "SERVER: You cannot use this command to yourself.");
		if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "SERVER: Target ID of Zombie is not connected!");

    	FCNPC_GetPosition(targetid, x, y, z);
		SetPlayerPos(playerid, x+5, y+5, z);
	   	format(string, sizeof(string), "{448E51}SERVER:{FFFFFF} You've teleported to {%h}Zombie(%d){FFFFFF}'s location.", targetid);
		SendClientMessage(playerid, -1, string);
	} else return 1;
    return 1;
}
CMD:zspawn(playerid,params[])
{
	if(sData[ZTCMD] == 1)
	{
	    new targetid, string[50];
	    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1,"{A13838}SERVER:{FFFFFF} You're not authorized to use this command!");
	    if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, -1, "SERVER: /zspawn <npc id>");
	    if(!IsPlayerNPC(targetid)) return SendClientMessage(playerid, -1, "SERVER: Target is not Zombie!");
		if(targetid == playerid) return SendClientMessage(playerid, -1, "SERVER: You cannot use this command to yourself.");
		if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "SERVER: Target ID of Zombie is not connected!");

  		FCNPC_Respawn(targetid);
	   	format(string, sizeof(string), "{448E51}SERVER:{FFFFFF} You've spawned {%h}Zombie(%d){FFFFFF}.", targetid, GetPlayerColor(playerid) >>> 8);
		SendClientMessage(playerid, -1, string);
	} else return 1;
    return 1;
}

CMD:infected(playerid,params[])
{
	if(sData[ZTCMD] == 1)
	{
		Infected[playerid] = 1;
		SendClientMessage(playerid, -1, "SERVER: You're infected now");
	} else return 1;
	return 1;
}

CMD:cure(playerid,params[])
{
	if(BeingCured[playerid] == 1) return SendClientMessage(playerid, -1, "You're already being cured. Please wait for medicine to take effect.");
    switch(Infected[playerid])
    {
        case 0:
        {
			SendClientMessage(playerid, -1, "You're not infected.");
        }
		case 1:
		{
		    BeingCured[playerid] = 1;
			KillTimer(InfectedTimer[playerid]);
			SendClientMessage(playerid, -1, "You've cured your zombie infection! You'll feel better gradually.");
			HealTimer[playerid] = SetTimerEx("HealthIncrease", 3000, 1, "i", playerid);
		}
	}
	return 1;
}

public OnFilterScriptInit()
{
	LoadConfig();
	print("[ZOMBIE DATA]\n");
//	print("Base: Map Andreas");
//	print("Base: Col Andreas");
//	print("Base: Path Finder with Map Andreas");
	printf("Zombies Created: %d", sData[MAX_ZOMBIES]);
	printf("Zombie Range: %d", sData[MAX_ZOMBIES]);
	printf("Zombie Skin: %d", sData[ZSKIN]);
	printf("Zombie Max Health: %d", sData[ZHEALTH]);
	if(sData[ZAI] == 0) print("Zombie A.I: Disabled"); else print("Zombie Headshot: Enabled");
	if(sData[ZBLIP] == 0) print("Hide Radar Blip: Disabled"); else print("Zombie Headshot: Enabled");
	if(sData[ZHEADSHOT] == 0) print("Zombie Headshot: Disabled"); else print("Zombie Headshot: Enabled");
	if(sData[ZTP] == 0) print("Zombie Custom Damage: Disabled"); else print("Zombie Custom Damage: Enabled");
	if(sData[PTZ] == 0) print("Player Custom Damage: Disabled"); else print("Player Custom Damage: Enabled");
	if(sData[ZINFECTED] == 0) print("Zombie Infection: Disabled"); else print("Zombie Infection: Enabled");
	if(sData[ANTI_MINIGUN] == 0) print("Anti-Minigun Anticheat: Disabled"); else print("Anti-Minigun Anticheat: Enabled");
	if(sData[ZTCMD] == 0) print("Test Commands: Disabled\n"); else print("Test Commands: Enabled\n");
	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);
//	PathFinder_Init(MapAndreas_GetAddress());

	CreationTimer = SetTimer("CreateZombies", 50, true);
	switch(sData[ZBLIP])
	{
	    case 0:
	    {
	    	ShowPlayerMarkers(0);
	    }
	    case 1:
	    {
	        ShowPlayerMarkers(1);
	    }
	}
	return 1;
}

public OnFilterScriptExit()
{
    return 1;
}

public OnPlayerSpawn(playerid)
{
	Spawned[playerid] = 1;
	return 1;
}

public CreateZombies(newkeys)
{
	new string[50], zombie;
	if(SpawnedZombies < 200)
	{
		format(string,sizeof(string),"Zombie(%d)",MAX_PLAYERS-(SpawnedZombies));
		zombie = FCNPC_Create(string);

		ZombieLabel[zombie] = Create3DTextLabel("Zombie\n{FF0000}����������", sData[ZCOLOR], 30.0, 40.0, 50.0, 60.0, -1, 0);
		Attach3DTextLabelToPlayer(ZombieLabel[zombie], zombie, 0.0, 0.0, 0.4);

		new	Float:pos[3], x=random(4000)-2000, y=random(4000)-2000, Float:z;
		for(new a; a < 100; a++)
		{
			GetPointZPos(x, y, z);
			if(z >= 5.0 && z < 30.0)
			{
				pos[0] = x;
				pos[1] = y;
				pos[2] = z;
				FCNPC_Spawn(zombie, sData[ZSKIN], x, y, z);
				break;
			}
		}
  		new Rand = random(9);
	    switch(Rand)
	    {
		    case 0: FCNPC_SetWeapon(zombie, 1);
		    case 1: FCNPC_SetWeapon(zombie, 2);
		    case 2: FCNPC_SetWeapon(zombie, 3);
		    case 3: FCNPC_SetWeapon(zombie, 4);
		    case 4: FCNPC_SetWeapon(zombie, 5);
		    case 5: FCNPC_SetWeapon(zombie, 6);
		    case 6: FCNPC_SetWeapon(zombie, 7);
		    case 7: FCNPC_SetWeapon(zombie, 8);
		    case 8: FCNPC_SetWeapon(zombie, 15);
	    }
		FCNPC_SetHealth(zombie, sData[ZHEALTH]);

		SetTimerEx("MoveZombie", 100, 1, "i", zombie, newkeys);
		SetPlayerColor(zombie, sData[ZCOLOR]);
		IsAZombie[zombie] = 1;
		SpawnedZombies++;
	}
	else
	{
		KillTimer(CreationTimer);
		print("---------------------------------------\n");

		print("---------------------------------------\n");
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	Infected[playerid] = 0;
	return 1;
}

public FCNPC_OnDeath(npcid, killerid, reason)
{
	HumanFound[npcid] = 0;
    SendDeathMessage(killerid, npcid, reason);
 	FCNPC_ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0 , 1, 1, 1, 5000);
 	FCNPC_Respawn(npcid);
    new Float:X,
		Float:Y,
		Float:Z,
 		spawn = random(100)+50,
		spawn1 = random(100)+50;

    GetPlayerPos(killerid, X, Y, Z);
    FCNPC_SetPosition(npcid, X+spawn, Y+spawn1, Z);
	return 1;
}

public FCNPC_OnTakeDamage(npcid, issuerid, Float:amount, weaponid, bodypart)
{
	if(sData[PTZ] == 1)
	{
	    switch(weaponid)
	    {
	        case 24: //DesertEagle
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-31);
	        }
	        case 32: //Tec9
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-10);
			}
	        case 22: //Colt45
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-15);
	        }
	        case 28: //UZI
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-10);
	        }
	        case 23: //Silenced
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-25);
	        }
	        case 31: //M4
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-30);
	        }
	        case 30: //AK
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-30);
	        }
	        case 29: //MP5
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-18);
	        }
	        case 34: //Sniper
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-45);
	        }
			case 33: //Country Rifle
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-35);
				FCNPC_ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0 , 1, 1, 1, 5000);
	        }
	        case 25: //PumpShotGun
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-30);
				FCNPC_ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0 , 1, 1, 1, 5000);
	        }
	   		case 27: //Spaz12
	        {
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-35);
				FCNPC_ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0 , 1, 1, 1, 5000);
			}
			case 49: //Vehicle
			{
				FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-100);
			}
		}
	}
    switch(sData[ZHEADSHOT])
    {
        case 0:
        {
            return 1;
        }
		case 1:
		{
			if(weaponid >= 22 && weaponid <= 38 && bodypart == 9)
			{
				switch(sData[ZRHEADSHOT])
				{
				    case 0:
				    {
	   					FCNPC_SetHealth(npcid, 0);
	   					GameTextForPlayer(issuerid, "~r~HeadShot",3000,4);
				   	}
				    case 1:
				    {
					    new	headshot = random(2)+1;
					    switch(headshot)
		   				{
	   					    case 1:
		   				    {
			   					FCNPC_SetHealth(npcid, 0);
			   					GameTextForPlayer(issuerid, "~r~HeadShot",3000,4);
							}
							case 2:
							{
								FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-90);
								GameTextForPlayer(issuerid, "~r~Head Damaged",3000,4);
							}
						}
					}
				}
			}
		}
	}
	if(weaponid >= 22 && weaponid <= 38 && bodypart == 9)
	{
		FCNPC_ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0 , 1, 1, 1, 5000);
	}
	if(sData[ANTI_MINIGUN] == 1)
	{
		if(weaponid == 38 && !IsPlayerAdmin(issuerid))
		{
			Ban(issuerid);
		}
	}
    if(GetPlayerState(issuerid) == PLAYER_STATE_DRIVER)
    {
        FCNPC_ApplyAnimation(npcid, "PED", "BIKE_fall_off", 4.1, 0 , 0, 0, 1, 5000);
        FCNPC_SetHealth(npcid, FCNPC_GetHealth(npcid)-100);
    }
	ZombieHealthLabel(npcid);
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
	if(sData[ZTP] == 1)
	{
	    new Float:HP;
	    GetPlayerHealth(playerid, HP);
	    switch(weaponid)
	    {
	        case 0:
	        {
				SetPlayerHealth(playerid, HP-1);
	        }
	        case 1:
	        {
	            SetPlayerHealth(playerid, HP-7);
	        }
	        case 2:
	        {
	            SetPlayerHealth(playerid, HP-9);
	        }
	        case 3:
	        {
	        	SetPlayerHealth(playerid, HP-8);
	        }
	        case 4:
	        {
	        	SetPlayerHealth(playerid, HP-10);
	        }
	        case 5:
	        {
	        	SetPlayerHealth(playerid, HP-8);
	        }
	        case 6:
	        {
	        	SetPlayerHealth(playerid, HP-9);
	        }
	        case 7:
	        {
	        	SetPlayerHealth(playerid, HP-7);
	        }
	        case 8:
	        {
	        	SetPlayerHealth(playerid, HP-10);
	        }
	        case 15:
			{
				SetPlayerHealth(playerid, HP-5);
			}
		}
	}
    return 1;
}

public MoveZombie(zombieid, newkeys, oldkeys)
{
	if(FCNPC_IsDead(zombieid)) return 1;
    foreach(new playerid : Player)
	{
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		if(Spawned[playerid] == 1)
		{
	        if(IsPlayerInRangeOfPoint(zombieid, 2.0, X, Y, Z))
			{
				Infected[playerid] = 1;
				Cured[playerid] = 0;
				GameTextForPlayer(playerid, "~r~~h~Infected",3000,4);
				HumanFound[zombieid] = 2;
				//FCNPC_MeleeAttack(zombieid, 5000);
				InfectedTimer[playerid] = SetTimerEx("HealthDecrease", 30*1000, 1, "i", playerid);
				FCNPC_ApplyAnimation(zombieid, "FOOD", "EAT_Burger", 4.1, 0 , 0, 0, 0, 3000);
				break;
			}
			else if(IsPlayerInRangeOfPoint(zombieid, sData[DRANGE], X, Y, Z))
	  		{
				if(HumanFound[zombieid] == 2)
				{
					FCNPC_StopAttack(zombieid);
				}
	         	GetPointZPos(X, Y, Z);
		        if(Z >= 5.0 && Z < 30.0)
		        {
		            HumanFound[zombieid] = 1;
				}
				else
				{
					HumanFound[zombieid] = 0;
				}
				new Float:z;
//				PathFinder_MapAndreasLock(); //Block PathFinder...

				//Do MapAndreas command or smth else like RNPC (with MapAndreas class sharing)
				for(new i = 0; i < 1000; i++)
				{
					FCNPC_GoTo(zombieid, X, Y, z, FCNPC_MOVE_TYPE_AUTO);
				}
//				PathFinder_MapAndreasUnlock();
				break;
			}
			else if(IsPlayerInRangeOfPoint(zombieid, sData[DRANGE] / 4, X, Y, Z) || GetPlayerSpecialAction(zombieid) == SPECIAL_ACTION_DUCK)
	  		{
	  		    if(sData[ZAI] == 1)
	  		    {
					if(HumanFound[zombieid] == 2)
					{
						FCNPC_StopAttack(zombieid);
					}
		         	GetPointZPos(X, Y, Z);
			        if(Z >= 5.0 && Z < 30.0)
			        {
			            HumanFound[zombieid] = 1;
			        }
			        else
			        {
			            HumanFound[zombieid] = 0;
			        }
					new Float:z;
//					PathFinder_MapAndreasLock(); //Block PathFinder...

					//Do MapAndreas command or smth else like RNPC (with MapAndreas class sharing)
					for(new i = 0; i < 1000; i++)
					{
						FCNPC_GoTo(zombieid, X, Y, z, FCNPC_MOVE_TYPE_AUTO);
					}
//					PathFinder_MapAndreasUnlock();

					break;
				}
				else { return 1; }
			}
			else if(IsPlayerInRangeOfPoint(zombieid, sData[DRANGE] * 2 , X, Y, Z) || PRESSED(KEY_SPRINT))
			{
	  			if(sData[ZAI] == 1)
	  		    {
					if(HumanFound[zombieid] == 2)
					{
						FCNPC_Stop(zombieid);
						FCNPC_StopAttack(zombieid);
					}
					HumanFound[zombieid] = 1;
			        GetPointZPos(X, Y, Z);
			        if(Z >= 5.0 && Z < 30.0)
			        {
			            HumanFound[zombieid] = 1;
			        }
			        else
			        {
			            HumanFound[zombieid] = 0;
			        }
					new Float:z;
//					PathFinder_MapAndreasLock(); //Block PathFinder...

					//Do MapAndreas command or smth else like RNPC (with MapAndreas class sharing)
					for(new i = 0; i < 1000; i++)
					{
						FCNPC_GoTo(zombieid, X, Y, z, FCNPC_MOVE_TYPE_AUTO);
					}
//					PathFinder_MapAndreasUnlock();

					break;
				}
				else { return 1; }
			}
			else if(IsPlayerInRangeOfPoint(zombieid, sData[DRANGE] * 5, X, Y, Z))
			{
	  			if(sData[ZAI] == 1)
	  		    {
		        	if(HOLDING(KEY_FIRE))
		        	{
			        	if(GetPlayerWeapon(playerid) == 22 && GetPlayerWeapon(playerid) >= 23 && GetPlayerWeapon(playerid) <= 38)
			        	{
							if(HumanFound[zombieid] == 2)
							{
								FCNPC_Stop(zombieid);
								FCNPC_StopAttack(zombieid);
							}
							HumanFound[zombieid] = 1;
						}
					}
			        GetPointZPos(X, Y, Z);
			        if(Z >= 5.0 && Z < 30.0)
			        {
			            HumanFound[zombieid] = 1;
			        }
			        else
			        {
			            HumanFound[zombieid] = 0;
			        }
					new Float:z;
//					PathFinder_MapAndreasLock(); //Block PathFinder...

					//Do MapAndreas command or smth else like RNPC (with MapAndreas class sharing)
					for(new i = 0; i < 1000; i++)
					{
						FCNPC_GoTo(zombieid, X, Y, z, FCNPC_MOVE_TYPE_AUTO);
					}
//					PathFinder_MapAndreasUnlock();

					break;
				}
				else { return 1; }
			}
			else
			{
	  			HumanFound[zombieid] = 0;
				new Float:x, Float:y, Float:z;
				GetPlayerPos(zombieid, x, y, z);
				FCNPC_StopAttack(zombieid);
				if(HumanFound[zombieid] == 0)
				{
					new pos = random(6);
					if(pos == 0) { x = x + 100.0; }
					else if(pos == 1) { x = x - 100.0; }
					else if(pos == 2) { y = y + 100.0; }
					else if(pos == 3) { y = y - 100.0; }
	   				else if(pos == 4) { z = z + 100.0; }
					else if(pos == 5) { z = z - 100.0; }

					FCNPC_SetKeys(zombieid, 0, 0, 0);
					new Float:z1;
//					PathFinder_MapAndreasLock(); //Block PathFinder...

					//Do MapAndreas command or smth else like RNPC (with MapAndreas class sharing)
					for(new i = 0; i < 1000; i++)
					{
						FCNPC_GoTo(zombieid, X, Y, z1, FCNPC_MOVE_TYPE_AUTO);
					}
//					PathFinder_MapAndreasUnlock();

	            }
			}
		}
	}
	return 1;
}

public FCNPC_OnRespawn(npcid, killerid)
{
	new Rand = random(9);
    switch(Rand)
    {
	    case 0: FCNPC_SetWeapon(npcid, 1);
	    case 1: FCNPC_SetWeapon(npcid, 2);
	    case 2: FCNPC_SetWeapon(npcid, 3);
	    case 3: FCNPC_SetWeapon(npcid, 4);
	    case 4: FCNPC_SetWeapon(npcid, 5);
	    case 5: FCNPC_SetWeapon(npcid, 6);
	    case 6: FCNPC_SetWeapon(npcid, 7);
	    case 7: FCNPC_SetWeapon(npcid, 8);
	    case 8: FCNPC_SetWeapon(npcid, 15);
    }
	new	Float:pos[3], x=random(4000)-2000, y=random(4000)-2000, Float:z;
	for(new a; a < 100; a++)
	{
		GetPointZPos(x, y, z);
		if(z >= 5.0 && z < 30.0)
		{
			pos[0] = x;
			pos[1] = y;
			pos[2] = z;
			FCNPC_Spawn(npcid, sData[ZSKIN], x+900, y+900, z);
			break;
		}
	}
    ZombieHealthLabel(npcid);
	return 1;
}

public ZombieHealthLabel(npcid)
{
    new Float:HP = FCNPC_GetHealth(npcid), dots[64];
    if(HP >= 100)
        dots = "Zombie\n{FF0000}����������";
    else if(HP >= 90)
        dots = "Zombie\n{FF0000}���������{660000}�";
    else if(HP >= 80)
        dots = "Zombie\n{FF0000}��������{660000}��";
    else if(HP >= 70)
        dots = "Zombie\n{FF0000}�������{660000}���";
    else if(HP >= 60)
        dots = "Zombie\n{FF0000}������{660000}����";
    else if(HP >= 50)
        dots = "Zombie\n{FF0000}�����{660000}�����";
    else if(HP >= 40)
        dots = "Zombie\n{FF0000}����{660000}������";
    else if(HP >= 30)
        dots = "Zombie\n{FF0000}���{660000}�������";
    else if(HP >= 20)
        dots = "Zombie\n{FF0000}��{660000}��������";
    else if(HP >= 10)
        dots = "Zombie\n{FF0000}�{660000}���������";
    else if(HP >= 0)
        dots = "Zombie\n{660000}����������";
    Update3DTextLabelText(ZombieLabel[npcid], sData[ZCOLOR], dots);
    return 1;
}

forward HealthIncrease(playerid);
public HealthIncrease(playerid)
{
    new Float:HP;
    GetPlayerHealth(playerid, HP);
    SetPlayerHealth(playerid, HP+5);
    if (HP >= 100.0)
    {
        SetPlayerHealth(playerid, 100);
        KillTimer(HealTimer[playerid]);
        Cured[playerid] = 1;
    }
    return 1;
}

forward HealthDecrease(playerid);
public HealthDecrease(playerid)
{
    if (Infected[playerid] == 0)
    {
        KillTimer(InfectedTimer[playerid]);
    }
    else
    {
        new Float:HP;
        GetPlayerHealth(playerid, HP);
        SetPlayerHealth(playerid, HP-5);
        SendClientMessage(playerid, -1, "You're infected by zombie bite and loosing your health. Use /cure");
	}
    return 1;
}


forward ReloadFS();
public ReloadFS()
{
   SendRconCommand("reloadfs zombie");
   return 1;
}

stock LoadConfig()
{
	new str[40];
    format(str, sizeof(str), ZPATH);//formats the file path, with the biz ID
    INI_ParseFile(str, "loadconfig_%s", .bExtra = true);//This is very hard to explain, but it basically loads the info from the file(More in ****** y_ini tutorial.)
}

forward loadconfig_data(name[], value[]);
public loadconfig_data(name[], value[])
{
    INI_Int("MaxZombies", sData[MAX_ZOMBIES]);
	INI_Int("Detection", sData[DRANGE]);
	INI_Int("Skin", sData[ZSKIN]);
	INI_Int("MaxHealth", sData[ZHEALTH]);
	INI_Int("Color", sData[ZCOLOR]);

	INI_Int("AI", sData[ZAI]);
	INI_Int("BLIP", sData[ZBLIP]);
	INI_Int("HEADSHOT ", sData[ZHEADSHOT]);
	INI_Int("RHEADSHOT", sData[ZRHEADSHOT]);
	INI_Int("DAMPLAYER", sData[ZTP]);
	INI_Int("DAMZOMBIE", sData[PTZ]);
	INI_Int("INFECTED", sData[ZINFECTED]);

	INI_Int("MINIGUN", sData[ANTI_MINIGUN]);
	INI_Int("TCMD", sData[ZTCMD]);
	INI_Int("CMSG", sData[ZPRINT]);
    return 1;
}

stock SaveConfig()
{
    new file4[40];
    format(file4, sizeof(file4), ZPATH);
    new INI:File = INI_Open(file4);
    INI_SetTag(File,"ZOMBIE");

    INI_Int("MaxZombies", sData[MAX_ZOMBIES]);
	INI_Int("Detection", sData[DRANGE]);
	INI_Int("Skin", sData[ZSKIN]);
	INI_Int("MaxHealth", sData[ZHEALTH]);
	INI_Int("Color", sData[ZCOLOR]);

	INI_SetTag(File,"PLAYER");
	INI_Int("AI", sData[ZAI]);
	INI_Int("BLIP", sData[ZBLIP]);
	INI_Int("HEADSHOT ", sData[ZHEADSHOT]);
	INI_Int("RHEADSHOT", sData[ZRHEADSHOT]);
	INI_Int("DAMPLAYER", sData[ZTP]);
	INI_Int("DAMZOMBIE", sData[PTZ]);
	INI_Int("INFECTED", sData[ZINFECTED]);

	INI_SetTag(File,"SERVER");
	INI_Int("MINIGUN", sData[ANTI_MINIGUN]);
	INI_Int("TCMD", sData[ZTCMD]);
	INI_Int("CMSG", sData[ZPRINT]);
	INI_Close(File);
	return 1;
}
