#include <a_samp>
#include <izcmd>
#include <foreach>
#include <sscanf2>
#include <streamer>
#include <easyDialog>
#include <mapandreasNP>

//Weapon Holster
new OldWeapon[MAX_PLAYERS];
new HoldingWeapon[MAX_PLAYERS];
enum PlayerData
{
	Spawn
};
new PlayerInfo[MAX_PLAYERS][PlayerData];
new Float: LV_SPAWN[][3] =
{
	{2037.0,1343.0,500.0},
	{2163.0,1121.0,500.0},
	{1688.0,1615.0,500.0},
	{2503.0,2764.0,500.0},
	{1418.0,2733.0,500.0},
	{1377.0,2196.0,500.0}
};
new Float: LS_SPAWN[][3] =
{
	{2495.0,-1688.0,500.0},
	{1979.0,-2241.0,500.0},
	{2744.0,-2435.0,500.0},
	{1481.0,-1656.0,500.0},
	{1150.0,-2037.0,500.0},
	{425.0,-1815.0,500.0},
	{1240.0,-744.0,500.0},
	{679.0,-1070.0,500.0}
};
new Float: SF_SPAWN[][3] =
{
	{-1990.0,137.0,500.0},
	{-1528.0,-206.0,500.0},
	{-2709.0,198.0,500.0},
	{-2738.0,-295.0,500.0},
	{-1457.0,465.0,500.0},
	{-1853.0,1404.0,500.0},
	{-2620.0,1373.0,500.0}
};
new Float: DS_SPAWN[][3] =
{
	{416.0,2516.0,500.0},
	{81.0,1920.0,500.0},
	{-324.0,1516.0,500.0},
	{-640.0,2051.0,500.0},
	{-766.0,1545.0,500.0},
	{-1514.0,2597.0,500.0},
	{442.0,1427.0,500.0}
};
new Float: FC_SPAWN[][3] =
{
	{-849.0,-1940.0,500.0},
	{-1107.0,-1619.0,500.0},
	{-1049.0,-1199.0,500.0},
	{-1655.0,-2219.0,500.0},
	{-375.0,-1441.0,500.0},
	{-367.0,-1049.0,500.0},
 	{-494.0,-555.0,500.0}
};
#define WEAPON_TYPE_NONE 	(0)
#define WEAPON_TYPE_HEAVY   (1)
#define WEAPON_TYPE_LIGHT   (2)
#define WEAPON_TYPE_MELEE   (3)
#define SetPlayerHoldingObject(%1,%2,%3,%4,%5,%6,%7,%8,%9) SetPlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1,%2,%3,%4,%5,%6,%7,%8,%9)
#define StopPlayerHoldingObject(%1) RemovePlayerAttachedObject(%1,MAX_PLAYER_ATTACHED_OBJECTS-1)
#define IsPlayerHoldingObject(%1) IsPlayerAttachedObjectSlotUsed(%1,MAX_PLAYER_ATTACHED_OBJECTS-1)
new sb_string[144];

#define LevelCheck(%0); \
	if(! IsPlayerAdmin(%0)) \
	    return (format(sb_string, sizeof(sb_string), "{FFFFFF}[{db2b42}ERROR{FFFFFF}]: You must be RCON admin to use this command."), \
			SendClientMessage(%0, -1, sb_string));


//Delivery Mission
#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

new Float: DeliveryCP[][3] =
{
	{1894.2181,-2133.8342,15.4663},
    {1872.5140,-2133.4617,15.4820},
    {1851.8079,-2135.4785,15.3882},
    {1804.1733,-2124.5183,13.9424},
    {1802.0742,-2099.5574,14.0210},
    {1782.1294,-2126.1873,14.0679},
    {1781.5271,-2101.9512,14.0566},
    {1761.2472,-2124.9226,14.0566},
    {1762.4678,-2102.3833,13.8570},
    {1734.7061,-2129.8684,14.0210},
    {1711.6321,-2101.7390,14.0210},
    {1715.0366,-2124.7524,14.0566},
    {1684.7278,-2099.4089,13.8343},
    {1695.4994,-2125.3999,13.8101},
    {1673.7737,-2122.4600,14.1460},
    {1667.4948,-2107.5659,14.0723},
    {1851.8402,-2069.7188,15.4812},
    {1873.6151,-2070.1265,15.4971},
    {1895.4196,-2068.2354,15.6689},
    {1937.9296,-1911.5403,15.2568},
    {1928.5251,-1916.0890,15.2568},
    {1913.4252,-1913.0002,15.2568},
    {1891.9386,-1914.6025,15.2568},
    {1872.1877,-1912.6665,15.2568},
    {1854.1146,-1914.9354,15.2568},
    {1897.8868,-2037.9088,13.5469},
    {1898.4463,-2029.1753,13.5469},
    {1916.7900,-2029.1899,13.5469},
    {1916.8823,-2001.3242,13.5469},
    {1908.0764,-1982.5504,13.5469},
    {1877.7290,-1982.6965,13.5469},
    {1878.1976,-2000.8708,13.5469},
    {1868.0209,-2009.5092,13.5469},
    {1849.1951,-2037.8882,13.5469},
    {1849.4895,-2029.3500,13.5469},
    {1835.8282,-2006.0781,13.5469},
    {1817.5377,-2005.6517,13.5544}
};

new bool:InJob[MAX_PLAYERS];
new bool:DeliveryMan[MAX_PLAYERS];
new Unload_Timer[MAX_PLAYERS];

//Door
#define MAX_DOORS 100
new entertimer[MAX_PLAYERS];
enum dInfo
{
	dMi,
	dVe,
	dIe,
	Float:dAe,
	Float:dXe,
	Float:dYe,
	Float:dZe,
	Float:dXi,
	Float:dYi,
	Float:dZi,
	Float:dAi,
	dIi,
	dVi,
	dExit,
	dPicki,
	dPicke,
	dMap,
	Text3D:dText
}
new DoorInfo[MAX_DOORS][dInfo];

//----------------------------------------------------------

main()
{
	print("\n---------------------------------------");
	print(" Running Zombie Survival\n");
	print("---------------------------------------\n");
}

/*new ObjectNames[4][32] =
{
	"First Aid Kit", //11736
	"Pizza", //1582
	"Bean Can", //1666
	"Alice Backpack" //3026
};*/

new Objects [] ={11736, 1582, 1666 ,3026};

SpawnObjects()
{
    for(new i = 0; i <= 1000; i++)
    {
        new Float:X, Float:Y, Float:Z;

		new rand = random(sizeof(Objects));

        X = randomEx(-3000, 3000);
        Y = randomEx(-3000, 3000);

        GetPointZPos(X, Y, Z);

        if(Z >= 5.0 && Z < 30.0)
        {
            CreateObject(Objects[rand], X, Y, Z, 0.0, 0.0, 0.0, 200.0);
        }
    }
    return 1;
}

public OnGameModeInit()
{

	SetGameModeText("Zombie/Survival/Bots");
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetWeather(1);
	SetWorldTime(20);

	SpawnObjects ();
    ShowNameTags(0);
	//Spawn
	Create3DTextLabel("Press F to jump from plane", 0x33AA33FF, 2.43, 33.32 , 1199.59, 30.0, 0, 0);
 	//Server
	DisableInteriorEnterExits();
	UsePlayerPedAnims();
	//Delivery Mission
 	Create3DTextLabel("Los Santos International Airport\n Courier Depot\n Press Y to start", 0x33AA33FF, 1998.9209,-2212.8696,13.5469, 30.0, 0, 0);
    CreateObject(3630, 2001.76611, -2221.56958, 14.04580,   0.00000, 0.00000, 90.00000);
    CreateObject(19425, 1964.95703, -2176.78857, 12.56570,   0.00000, 0.00000, 0.00000);
    CreateObject(19425, 1961.65063, -2176.78857, 12.56570,   0.00000, 0.00000, 0.00000);
    CreateObject(19425, 1958.34729, -2176.78857, 12.56570,   0.00000, 0.00000, 0.00000);
    CreateObject(3576, 1996.87439, -2218.30664, 14.04240,   0.00000, 0.00000, 0.00000);
    CreateObject(3577, 1997.40527, -2221.84839, 13.30540,   0.00000, 0.00000, -90.00000);
    CreateObject(1685, 1998.73010, -2225.29907, 13.25740,   0.00000, 0.00000, 0.00000);
    CreateObject(1685, 1996.45435, -2225.28662, 13.25740,   0.00000, 0.00000, 0.00000);
	SetNameTagDrawDistance(200.0);
	//Door
	LoadDoors();
	//Zombie-Bus Vehicle
 	new busobjid;
	new busvid;
    busvid = CreateVehicle(437, 092.7317, -1196.5012, 18.0109, 166.9138,0,0,-1);

    busobjid = CreateDynamicObject(914,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 0.630, 5.450, 1.116, 10.000, -180.000, 0.000);
    busobjid = CreateDynamicObject(914,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 0.000, 0.000, 0.000, 0.000, 0.000, 0.000);
    busobjid = CreateDynamicObject(914,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -0.590, 5.450, 1.116, 10.000, 180.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, 4.110, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, 4.110, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, 3.129, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, 3.129, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, 2.140, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, 2.140, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, 1.169, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, 1.169, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, 0.180, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, 0.180, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, -0.819, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, -0.819, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, -1.799, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, -1.799, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, -2.789, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, -2.789, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, -3.739, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, -3.739, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.290, -4.709, 1.300, 90.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.290, -4.709, 1.300, 90.000, 90.000, 180.000);
    busobjid = CreateDynamicObject(19601,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", -13421773);
    AttachDynamicObjectToVehicle(busobjid, busvid, 0.000, 5.949, -0.520, 0.000, 0.000, 180.000);
    busobjid = CreateDynamicObject(2892,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", -13421773);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.279, 0.000, 0.670, 0.000, -90.000, 0.000);
    busobjid = CreateDynamicObject(2892,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", -13421773);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.279, 0.000, 0.670, 0.000, 90.000, 0.000);
    busobjid = CreateDynamicObject(19846,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.450, 3.950, -0.484, 455.000, 360.000, 90.000);
    busobjid = CreateDynamicObject(19846,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", 0);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.450, 3.950, -0.484, 95.000, 0.000, -90.000);
    busobjid = CreateDynamicObject(1593,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", -13421773);
    AttachDynamicObjectToVehicle(busobjid, busvid, -1.489, -3.379, -0.110, 0.000, -90.000, 0.000);
    busobjid = CreateDynamicObject(1593,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(busobjid, 0, 1560, "7_11_door", "CJ_CHROME2", -13421773);
    AttachDynamicObjectToVehicle(busobjid, busvid, 1.489, -3.379, -0.110, 0.000, 90.000, 0.000);

	//Zombie-Truck Vehicle
    new truckobjid;
	new truckvid;

	truckvid = CreateVehicle(403, 1292.5237, -1245.8466, 13.5469, 89.301, 158,-1,-1);

    truckobjid = CreateDynamicObject(1503,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, 5150, "wiresetc_las2", "ganggraf01_LA_m", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.000, 5.104, -0.818, 13.899, 0.000, 180.000);
    truckobjid = CreateDynamicObject(1503,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, 5150, "wiresetc_las2", "ganggraf01_LA_m", 0);
    SetDynamicObjectMaterial(truckobjid, 1, 1560, "7_11_door", "cj_sheetmetal2", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -0.510, 4.733, -0.731, 15.000, 0.000, 180.000);
    truckobjid = CreateDynamicObject(1503,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, 5150, "wiresetc_las2", "ganggraf01_LA_m", 0);
    SetDynamicObjectMaterial(truckobjid, 1, 1560, "7_11_door", "cj_sheetmetal2", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.510, 4.733, -0.731, 14.999, 0.000, 180.000);
    truckobjid = CreateDynamicObject(1897,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -1.067, 3.937, 0.000, 270.000, 0.000, -171.399);
    truckobjid = CreateDynamicObject(1897,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 1.067, 3.937, 0.000, -90.000, 0.000, 169.999);
    truckobjid = CreateDynamicObject(1025,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -1.361, 0.000, 0.560, 0.000, 0.000, 180.000);
    truckobjid = CreateDynamicObject(2993,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 1, 2047, "cj_ammo_posters", "cj_flag2", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -0.830, 2.212, 1.430, 0.000, 0.000, 270.000);
    truckobjid = CreateDynamicObject(2993,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 1, 2047, "cj_ammo_posters", "cj_flag2", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.830, 2.212, 1.430, 0.000, 0.000, -90.000);
    truckobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -0.410, 2.471, 0.860, 99.999, 0.000, 0.000);
    truckobjid = CreateDynamicObject(19843,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, 14584, "ab_abbatoir01", "ab_vent1", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.410, 2.471, 0.860, 100.199, 0.000, 0.000);
    truckobjid = CreateDynamicObject(920,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, -1, "none", "none", -26215);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.440, 3.020, 0.760, 0.000, 0.000, 270.000);
    truckobjid = CreateDynamicObject(19589,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, 8147, "vgsselecfence", "vgsSmetalgate01", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.060, -2.611, 2.060, 180.000, 0.000, 90.000);
    truckobjid = CreateDynamicObject(19868,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -1.191, -1.561, -1.140, 0.000, 0.000, 90.000);
    truckobjid = CreateDynamicObject(19868,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 1.191, -1.561, -1.140, 0.000, 0.000, -90.000);
    truckobjid = CreateDynamicObject(2985,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.000, -3.229, -0.490, 0.000, 0.000, 270.000);
    truckobjid = CreateDynamicObject(2395,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    SetDynamicObjectMaterial(truckobjid, 0, 1560, "7_11_door", "cj_sheetmetal2", 0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 1.390, -3.849, -0.100, -90.000, 0.000, 90.000);
    truckobjid = CreateDynamicObject(1593,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.000, -4.269, -1.120, 0.000, -90.000, 90.000);
    truckobjid = CreateDynamicObject(1593,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 1.368, -0.390, -0.980, 0.000, 90.000, 0.000);
    truckobjid = CreateDynamicObject(1593,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -1.368, -0.390, -0.980, 0.000, -90.000, 0.000);
    truckobjid = CreateDynamicObject(1327,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -0.190, -2.650, 2.039, 0.000, 90.000, 0.000);
    truckobjid = CreateDynamicObject(3015,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.650, -2.360, -0.050, 0.000, 0.000, 0.000);
    truckobjid = CreateDynamicObject(1042,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, -1.410, -2.890, -1.130, 0.000, 0.000, 0.000);
    truckobjid = CreateDynamicObject(1099,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 1.391, -2.880, -1.100, 0.000, 0.000, 0.000);
    truckobjid = CreateDynamicObject(2673,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0);
    AttachDynamicObjectToVehicle(truckobjid, truckvid, 0.230, -3.730, -0.030, 0.000, 0.000, 0.000);

    return 1;
}

public OnGameModeExit()
{
	//Weapon Holster
	for(new i=0;i<MAX_PLAYERS;i++)
 	if(IsPlayerConnected(i))
	RemovePlayerAttachedObject(i, 0);
 	//Delivery Mission
	foreach(new i: Player)
	{
	    DeliveryMan[i] = false;
	    InJob[i] = false;
	    DisablePlayerCheckpoint(i);
	    KillTimer(Unload_Timer[i]);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	//Weapon Holster
	OldWeapon[playerid]=0;
	HoldingWeapon[playerid]=0;

	RemoveBuildingForPlayer(playerid, 1302, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 1209, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 955, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 1775, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 1776, 0.0, 0.0, 0.0, 6000.0);

//	ConnectZombieBots(playerid, 50);
	//Delivery Mission
	InJob[playerid] = false;
	DeliveryMan[playerid] = false;
	/*
	new ClientVersion[32];
	GetPlayerVersion(playerid, ClientVersion, 32);
	printf("Player %d reports client version: %s", playerid, ClientVersion);*/
	//Player Clock
	TogglePlayerClock(playerid, true);
 	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	//Delivery Mission
	InJob[playerid] = false;
	DeliveryMan[playerid] = false;
	KillTimer(Unload_Timer[playerid]);
	return 1;
}
//----------------------------------------------------------
public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	TogglePlayerClock(playerid, 1);

	//Delivery Mission
    InJob[playerid] = false;
    DeliveryMan[playerid] = false;
    
	SetPlayerPos(playerid, 1.68, 23.67, 1199.54);
	SetPlayerInterior(playerid, 1);
	return 1;
}

//----------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
	//Delivery Mission
	InJob[playerid] = false;
	DeliveryMan[playerid] = false;
    return 1;
}
//----------------------------------------------------------------------------//
//Spawn
CMD:changespawn(playerid, params[])
{
	Dialog_Show(playerid, SPAWN, DIALOG_STYLE_LIST, "Change Spawn", \
	"Las Venturas\nLos Santos\nSan Fierro\nThe Desert\nFlint Country", "Select", "Back");
	return 1;
}
//----------------------------------------------------------------------------//
//Delivery Mission
CMD:stopwork(playerid,params[])
{
    if(DeliveryMan[playerid] == true)
    {
        DeliveryMan[playerid] = false;
        InJob[playerid] = false;
        DisablePlayerCheckpoint(playerid);
        GivePlayerMoney(playerid, -10);
        SendClientMessage(playerid, 0xFF0000FF, "[DELIVERY]: You've stopped the courier delivery and charged $10.");
    }
    return 1;
}

CMD:objective(playerid,params[])
{
    if(DeliveryMan[playerid] == true)
    {
        SendClientMessage(playerid, 0x76EEC6FF, "* Delivery urgent package to the checkpoint.");
  		SendClientMessage(playerid, 0x76EEC6FF, "* You'll be rewarded upon your delivery.");
  		SendClientMessage(playerid, 0x76EEC6FF, "* Use /stopwork to abandon your delivery.");
  		SendClientMessage(playerid, 0x76EEC6FF, "* You'll be charged $10 for abandoning your delivery!");
    }
    return 1;
}

//Entry/Exit
CMD:cdoor(playerid, params[])
{
	new string[128],type;
	LevelCheck(playerid);
	if(sscanf(params, "i", type)) return SendClientMessage(playerid,-1, "[Usage]: /cdoor [icon](6-63)");
	if(type >= 0 && type <= 5) return SendClientMessage(playerid,-1, "Invalid mapicon type.");
	for(new i=0; i<MAX_DOORS; i++)
	{
	    if(!DoorInfo[i][dMi])
	    {
		    GetPlayerPos(playerid, DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]);
            DoorInfo[i][dMi] = type;
			DoorInfo[i][dIe] = GetPlayerInterior(playerid);
			DoorInfo[i][dVe] = GetPlayerVirtualWorld(playerid);
			GetPlayerFacingAngle(playerid, DoorInfo[i][dAe]);
            DoorInfo[i][dPicke] = CreateDynamicPickup(19198, 1, DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]+0.2, DoorInfo[i][dVe], DoorInfo[i][dIe]);
            DoorInfo[i][dMap] = CreateDynamicMapIcon(DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe],DoorInfo[i][dMi],0);
			format(string, sizeof(string), "ID: %d", i);
 	 		DoorInfo[i][dText] = CreateDynamic3DTextLabel(string,-1,DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]+0.3, 15);
            format(string, sizeof(string), " You have set door ID %d to your coordinates. (Int: %d | VW: %d)", i, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
    		SendClientMessage(playerid,-1, string);
			i = MAX_DOORS;
		}
	}
	return 1;
}
CMD:cexit(playerid, params[])
{
	new i, string[200];
	LevelCheck(playerid);
	if(sscanf(params, "i", i)) return SendClientMessage(playerid,-1, "[Usage]: /cexit [doorid]");
	if(DoorInfo[i][dMi] == 0) return SendClientMessage(playerid,-1, "Invalid door id.");
	if(DoorInfo[i][dExit] == 1)
	{
	    DestroyDynamicPickup(DoorInfo[i][dPicki]);
	}
	DoorInfo[i][dIi] = GetPlayerInterior(playerid);
	DoorInfo[i][dVi] = GetPlayerVirtualWorld(playerid);
	GetPlayerFacingAngle(playerid, DoorInfo[i][dAi]);
	GetPlayerPos(playerid, DoorInfo[i][dXi], DoorInfo[i][dYi], DoorInfo[i][dZi]);
    DoorInfo[i][dPicki] = CreateDynamicPickup(19198, 1, DoorInfo[i][dXi], DoorInfo[i][dYi], DoorInfo[i][dZi]+0.2, DoorInfo[i][dVi], DoorInfo[i][dIi]);
    format(string, sizeof(string), " You have set door ID %d's interior to your coordinates. (Int: %d | VW: %d)", i, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
    SendClientMessage(playerid,-1, string);
    DoorInfo[i][dExit] = 1;
    return 1;
}
CMD:dinfo(playerid, params[])
{
 	new string[200];
	for(new i=0; i<MAX_DOORS; i++)
	{
	    if(DoorInfo[i][dMi])
	    {
			format(string, sizeof(string), "ID: %d | Marker: %d | Exit: %d | Int: %d | Vw: %d", i,
			DoorInfo[i][dMi],
			DoorInfo[i][dExit],
			DoorInfo[i][dIi],
			DoorInfo[i][dVi]);
			SendClientMessage(playerid,-1, string);
	    }
	}
	return 1;
}
CMD:deldoor(playerid,params[])
{
	new i, string[200];
	LevelCheck(playerid);
    if(sscanf(params, "i", i)) return SendClientMessage(playerid,-1, "[Usage]: /deldoor [doorid]");
	if(!DoorInfo[i][dMi]) return SendClientMessage(playerid,-1, "Invalid door id.");
 	format(string, sizeof(string),"You have deleted door id %d",i);
    SendClientMessage(playerid,-1,string);
	DoorInfo[i][dMi] = 0;
	DoorInfo[i][dVe] = 0;
	DoorInfo[i][dIe] = 0;
	DoorInfo[i][dAe] = 0;
	DoorInfo[i][dXe] = 0;
	DoorInfo[i][dYe] = 0;
	DoorInfo[i][dZe] = 0;
	DoorInfo[i][dXi] = 0;
	DoorInfo[i][dYi] = 0;
	DoorInfo[i][dZi] = 0;
	DoorInfo[i][dAi] = 0;
	DoorInfo[i][dIi] = 0;
	DoorInfo[i][dVi] = 0;
	DoorInfo[i][dExit] = 0;
	DestroyDynamicPickup(DoorInfo[i][dPicke]);
	DestroyDynamicMapIcon(DoorInfo[i][dMap]);
	DestroyDynamicPickup(DoorInfo[i][dPicki]);
    DestroyDynamic3DTextLabel(DoorInfo[i][dText]);
	return 1;
}
CMD:gotodoor(playerid, params[])
{
    new i, string[128];
    LevelCheck(playerid);
	if(sscanf(params, "i", i)) return SendClientMessage(playerid,-1, "[Usage]: /gotodoor [doorid]");
	if(!DoorInfo[i][dMi]) return SendClientMessage(playerid,-1, "Invalid door id.");
	SetPlayerInterior(playerid, DoorInfo[i][dIe]);
	SetPlayerVirtualWorld(playerid, DoorInfo[i][dVe]);
	SetPlayerPos(playerid, DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]);
	format(string, sizeof(string), " You have teleported to door ID %d.", i);
	SendClientMessage(playerid,-1, string);
	return 1;
}
CMD:saved(playerid,params[])
{
	LevelCheck(playerid);
	SaveDoors();
	SendClientMessage(playerid,-1,"Doors successfully saved");
	return 1;
}
CMD:doorhelp(playerid,params[])
{
	new string[200];
	LevelCheck(playerid);
	strcat(string, "\t\t{00C0FF}Commands List:\t\t\n\n");
	strcat(string, "/cdoor /cexit /deldoor /dinfo /gotodoor");
	ShowPlayerDialog(playerid, 1398, DIALOG_STYLE_MSGBOX, "Door Commands",string, "Close", "");
	return 1;
}
//----------------------------------------------------------------------------//

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;
    return 1;
}

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(IsPlayerNPC(playerid)) return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
	{
	    Kick(playerid);
	    return 0;
	}
	if(GetPlayerState(playerid)==PLAYER_STATE_ONFOOT)
	{
		new weaponid=GetPlayerWeapon(playerid),oldweapontype=GetWeaponType(OldWeapon[playerid]);
		new weapontype=GetWeaponType(weaponid);
		if(HoldingWeapon[playerid]==weaponid)
		    StopPlayerHoldingObject(playerid);

		if(OldWeapon[playerid]!=weaponid)
		{
		    new modelid=GetWeaponModel(OldWeapon[playerid]);
		    if(modelid!=0 && oldweapontype!=WEAPON_TYPE_NONE && oldweapontype!=weapontype)
		    {
		        HoldingWeapon[playerid]=OldWeapon[playerid];
		        switch(oldweapontype)
		        {
		            case WEAPON_TYPE_LIGHT:
						SetPlayerAttachedObject(playerid, 0,modelid, 8,0.0,-0.1,0.15, -100.0, 0.0, 0.0);

					case WEAPON_TYPE_MELEE:
					    SetPlayerAttachedObject(playerid, 0,modelid, 7,0.0,0.0,-0.18, 100.0, 45.0, 0.0);

					case WEAPON_TYPE_HEAVY:
					    SetPlayerAttachedObject(playerid, 0,modelid, 1, 0.2,-0.125,-0.1,0.0,25.0,180.0);
		        }
		    }
		}

		if(oldweapontype!=weapontype)
			OldWeapon[playerid]=weaponid;
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	//Weapon Holster
	if(oldstate==PLAYER_STATE_ONFOOT)
	{
		RemovePlayerAttachedObject(playerid, 0);
		OldWeapon[playerid]=0;
		HoldingWeapon[playerid]=0;
	}
	//Delivery Mission
    if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER)
    {
        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 482)
        {
            GameTextForPlayer(playerid, "~w~COURIER DELIVERY AVALIABLE ~n~PRESS ~y~Y", 5000, 3);
            SendClientMessage(playerid, 0x76EEC6FF, "* It seems that there are undelivered packages in your Burrito.");
        }
        return 1;
    }
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	//Delivery Mission
    if(PRESSED(KEY_YES))
    {
    	if(IsPlayerInRangeOfPoint(playerid, 7.0, 1998.9209, -2212.8696, 13.5469))
		{
			new rand = random(sizeof(DeliveryCP));
			if(InJob[playerid] == true) return SendClientMessage(playerid, 0xFF0000FF, "You're currently in a mission. Please finish it to start another delivery.");
			{
				InJob[playerid] = true;
				DeliveryMan[playerid] = true;
				SetPlayerCheckpoint(playerid, DeliveryCP[rand][0], DeliveryCP[rand][1], DeliveryCP[rand][2], 1.5);
				SendClientMessage(playerid, 0x76EEC6FF, "* Delivery mission started! Use /objective to see instructions.");
			}
		}
	}
	//Door
	if(newkeys == KEY_WALK)
    {
        for(new i=0; i<MAX_DOORS; i++)
        {
            if(IsPlayerInRangeOfPoint(playerid, 2, DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]) && GetPlayerVirtualWorld(playerid) == DoorInfo[i][dVe])
            {
                if(DoorInfo[i][dExit] != 1) return SendClientMessage(playerid,-1,"You cannot enter this door");
                entertimer[playerid] = SetTimerEx("enter",3000,false,"i",playerid);
                SetPlayerInterior(playerid, DoorInfo[i][dIi]);
                SetPlayerVirtualWorld(playerid, DoorInfo[i][dVi]);
                SetPlayerFacingAngle(playerid, DoorInfo[i][dAi]);
                SetCameraBehindPlayer(playerid);
                SetPlayerPos(playerid, DoorInfo[i][dXi], DoorInfo[i][dYi], DoorInfo[i][dZi]);
                TogglePlayerControllable(playerid,0);
                GameTextForPlayer(playerid,"OBJECT LOADING",3000,5);
            }
            else if(IsPlayerInRangeOfPoint(playerid, 2, DoorInfo[i][dXi], DoorInfo[i][dYi], DoorInfo[i][dZi]) && GetPlayerVirtualWorld(playerid) == DoorInfo[i][dVi])
            {
	        	SetPlayerInterior(playerid, DoorInfo[i][dIe]);
		        SetPlayerVirtualWorld(playerid, DoorInfo[i][dVe]);
		        SetPlayerFacingAngle(playerid, DoorInfo[i][dAe]);
		        SetCameraBehindPlayer(playerid);
		        SetPlayerPos(playerid, DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]);
			}
        }
		return 1;
    }
	if(newkeys == KEY_SECONDARY_ATTACK)
    {
    	if(IsPlayerInRangeOfPoint(playerid, 7.0, 2.43, 33.32 , 1199.59))
		{
			if(PlayerInfo[playerid][Spawn] == 0)
			{
				Dialog_Show(playerid, SPAWN, DIALOG_STYLE_LIST, "Set Spawn", \
				"Las Venturas\nLos Santos\nSan Fierro\nThe Desert\nFlint Country", "Select", "Back");
			}
			if(PlayerInfo[playerid][Spawn] == 1)
			{
				new rand = random(sizeof(LV_SPAWN));
				SetPlayerPos(playerid, LV_SPAWN[rand][0], LV_SPAWN[rand][1], LV_SPAWN[rand][2]);
				SetPlayerInterior(playerid, 0);
				SetPlayerTime(playerid, 20, 00);
				GivePlayerWeapon(playerid, 46, 1);
			}
			if(PlayerInfo[playerid][Spawn] == 2)
			{
				new rand = random(sizeof(LS_SPAWN));
				SetPlayerPos(playerid, LS_SPAWN[rand][0], LS_SPAWN[rand][1], LS_SPAWN[rand][2]);
				SetPlayerInterior(playerid, 0);
				SetPlayerTime(playerid, 20, 00);
				GivePlayerWeapon(playerid, 46, 1);
			}
			if(PlayerInfo[playerid][Spawn] == 3)
			{
				new rand = random(sizeof(SF_SPAWN));
				SetPlayerPos(playerid, SF_SPAWN[rand][0], SF_SPAWN[rand][1], SF_SPAWN[rand][2]);
				SetPlayerInterior(playerid, 0);
				SetPlayerTime(playerid, 20, 00);
				GivePlayerWeapon(playerid, 46, 1);
			}
			if(PlayerInfo[playerid][Spawn] == 4)
			{
				new rand = random(sizeof(DS_SPAWN));
				SetPlayerPos(playerid, DS_SPAWN[rand][0], DS_SPAWN[rand][1], DS_SPAWN[rand][2]);
				SetPlayerInterior(playerid, 0);
				SetPlayerTime(playerid, 20, 00);
				GivePlayerWeapon(playerid, 46, 1);
			}
			if(PlayerInfo[playerid][Spawn] == 5)
			{
				new rand = random(sizeof(FC_SPAWN));
				SetPlayerPos(playerid, FC_SPAWN[rand][0], FC_SPAWN[rand][1], FC_SPAWN[rand][2]);
				SetPlayerInterior(playerid, 0);
				SetPlayerTime(playerid, 20, 00);
				GivePlayerWeapon(playerid, 46, 1);
			}
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	new playerState = GetPlayerState(playerid);
    if(playerState == PLAYER_STATE_ONFOOT)
    {
		if(DeliveryMan[playerid] == true)
		{
		GameTextForPlayer(playerid, "~r~UNLOADING...", 4000, 3);
		Unload_Timer[playerid] = SetTimerEx("FinishJob", 5000, false, "i", playerid);
		TogglePlayerControllable(playerid,0);
		}
	}
	return 1;
}

//----------------------------------------------------------------------------//

//Holster
GetWeaponType(weaponid)
{
	switch(weaponid)
	{
	    case 22,23,24,26,28,32:
	        return WEAPON_TYPE_LIGHT;

		case 3,4,16,17,18,39,10,11,12,13,14,40,41:
		    return WEAPON_TYPE_MELEE;

		case 2,5,6,7,8,9,25,27,29,30,31,33,34,35,36,37,38:
		    return WEAPON_TYPE_HEAVY;
	}
	return WEAPON_TYPE_NONE;
}

stock GetWeaponModel(weaponid)
{
	switch(weaponid)
	{
	    case 1:
	        return 331;

		case 2..8:
		    return weaponid+331;

        case 9:
		    return 341;

		case 10..15:
			return weaponid+311;

		case 16..18:
		    return weaponid+326;

		case 22..29:
		    return weaponid+324;

		case 30,31:
		    return weaponid+325;

		case 32:
		    return 372;

		case 33..45:
		    return weaponid+324;

		case 46:
		    return 371;
	}
	return 0;
}

//Delivery Mission
forward FinishJob(playerid);
public FinishJob(playerid)
{
    new str[128], cash = RandomEx(10, 50);
    format(str, sizeof str, "~b~~h~~n~~n~~n~~n~~n~Package Delivered!");
    GameTextForPlayer(playerid, str, 6000, 3);
    GivePlayerMoney(playerid, cash);
    TogglePlayerControllable(playerid,1);
    DisablePlayerCheckpoint(playerid);
    InJob[playerid] = false;
}

RandomEx(min, max)
{
    return random(max - min) + min;
}

//Door
stock SaveDoors()
{
    new File:File,i,string[200];
    i = 0;
	while(i < MAX_DOORS)
	{
 		format(string, sizeof(string), "%d|%d|%d|%f|%f|%f|%f|%f|%f|%f|%f|%d|%d|%d|\r\n",
    	DoorInfo[i][dMi],
		DoorInfo[i][dVe],
		DoorInfo[i][dIe],
		DoorInfo[i][dAe],
		DoorInfo[i][dXe],
		DoorInfo[i][dYe],
		DoorInfo[i][dZe],
		DoorInfo[i][dXi],
		DoorInfo[i][dYi],
		DoorInfo[i][dZi],
		DoorInfo[i][dAi],
		DoorInfo[i][dIi],
		DoorInfo[i][dVi],
		DoorInfo[i][dExit]);
		if(i == 0)
	    {
	        File = fopen("Doors.ini",io_write);
	    }
	    else
	    {
	    	File = fopen("Doors.ini",io_append);
	    }
		fwrite(File,string);
		fclose(File);
		i++;
	}
	print("Doors saved successfully.");
}

stock LoadDoors()
{
	new dinfo[14][128];
	new string[200];
	new File:File = fopen("Doors.ini", io_read);
	if(File)
	{
	    new i = 0;
		while(i < MAX_DOORS)
		{
		    fread(File, string);
		    split(string,dinfo, '|');
		    DoorInfo[i][dMi] = strval(dinfo[0]);
			DoorInfo[i][dVe] = strval(dinfo[1]);
			DoorInfo[i][dIe] = strval(dinfo[2]);
			DoorInfo[i][dAe] = floatstr(dinfo[3]);
			DoorInfo[i][dXe] = floatstr(dinfo[4]);
			DoorInfo[i][dYe] = floatstr(dinfo[5]);
			DoorInfo[i][dZe] = floatstr(dinfo[6]);
			DoorInfo[i][dXi] = floatstr(dinfo[7]);
			DoorInfo[i][dYi] = floatstr(dinfo[8]);
			DoorInfo[i][dZi] = floatstr(dinfo[9]);
			DoorInfo[i][dAi] = floatstr(dinfo[10]);
			DoorInfo[i][dIi] = strval(dinfo[11]);
			DoorInfo[i][dVi] = strval(dinfo[12]);
			DoorInfo[i][dExit] = strval(dinfo[13]);
			if(DoorInfo[i][dMi])
			{
			    DoorInfo[i][dPicki] = CreateDynamicPickup(19198, 1, DoorInfo[i][dXi], DoorInfo[i][dYi], DoorInfo[i][dZi]+0.2, DoorInfo[i][dVi], DoorInfo[i][dIi]);
                DoorInfo[i][dPicke] = CreateDynamicPickup(19198, 1, DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]+0.2, DoorInfo[i][dVe], DoorInfo[i][dIe]);
	            DoorInfo[i][dMap] = CreateDynamicMapIcon(DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe],DoorInfo[i][dMi],0);
				format(string, sizeof(string), "ID: %d", i);
			 	DoorInfo[i][dText] = CreateDynamic3DTextLabel(string,-1,DoorInfo[i][dXe], DoorInfo[i][dYe], DoorInfo[i][dZe]+0.3, 15);
			}
			i++;
	    }
	}
	print("Doors loaded successfully.");
	return 1;
}

stock split(const strsrc[], strdest[][], delimiter)
{
    new i, li;
    new aNum;
    new len;
    while(i <= strlen(strsrc))
    {
        if(strsrc[i] == delimiter || i == strlen(strsrc))
        {
            len = strmid(strdest[aNum], strsrc, li, i, 128);
            strdest[aNum][len] = 0;
            li = i+1;
            aNum++;
        }
        i++;
    }
    return 1;
}

forward enter(playerid);
public enter(playerid)
{
	TogglePlayerControllable(playerid,1);
	KillTimer(entertimer[playerid]);
}

//Objects
stock randomEx (min, max)
{
    new rand = random (max-min) + min;
    return rand;
}

Dialog:SPAWN(playerid, response, listitem, inputtext[])
{
    if(!response)
    {
        cmd_changespawn(playerid, "");
    }
    else
    {
    	switch(listitem)
		{
			case 0:
			{
				PlayerInfo[playerid][Spawn] = 1;
				SendClientMessage(playerid, -1, "[SPAWN]: You'll now spawn in Las Venturas");
			}
			case 1:
			{
				PlayerInfo[playerid][Spawn] = 2;
				SendClientMessage(playerid, -1, "[SPAWN]: You'll now spawn in Los Santos");
			}
			case 2:
			{
				PlayerInfo[playerid][Spawn] = 3;
				SendClientMessage(playerid, -1, "[SPAWN]: You'll now spawn in San Fierro");
			}
			case 3:
			{
				PlayerInfo[playerid][Spawn] = 4;
				SendClientMessage(playerid, -1, "[SPAWN]: You'll now spawn in Desert");
			}
			case 4:
			{
				PlayerInfo[playerid][Spawn] = 5;
				SendClientMessage(playerid, -1, "[SPAWN]: You'll now spawn in Flint Country");
			}
		}
	}
    return 1;
}
