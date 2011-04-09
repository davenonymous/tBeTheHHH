#pragma semicolon 1
#include <sourcemod>
#include <tbethehhh>
#include <tf2>

#define VERSION 		"0.0.1"

new Handle:g_hCvarEnabled = INVALID_HANDLE;
new bool:g_bEnabled;

new Handle:g_hCvarHHHTeam = INVALID_HANDLE;
new g_iHellmanTeam;
new g_iPeasantTeam;

new g_iOriginalUnbalanceLimit = -1;
new bool:g_bOriginalAutoTeamBalance = false;

public Plugin:myinfo =
{
	name 		= "tBeTheHHH - HHH Team",
	author 		= "Thrawn",
	description = "This forces HHHs to be on one team and the rest to be on the other.",
	version 	= VERSION,
};

public OnPluginStart() {
	CreateConVar("sm_tbethehhh_hhhteam_version", VERSION, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_hCvarEnabled = CreateConVar("sm_tbethehhh_hhhteam_enable", "1", "Split HHH and Normal Players into teams", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarHHHTeam = CreateConVar("sm_tbethehhh_hhhteam", "2", "2 = Red, 3 = Blue", FCVAR_PLUGIN, true, 2.0, true, 3.0);
	HookConVarChange(g_hCvarEnabled, Cvar_Changed);
	HookConVarChange(g_hCvarHHHTeam, Cvar_Changed);

	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
	HookEvent("player_spawn", Event_PlayerSpawn);

	AddCommandListener(CommandListener_JoinTeam, "jointeam");
}

public OnConfigsExecuted() {
	g_bEnabled = GetConVarBool(g_hCvarEnabled);
	g_iHellmanTeam = GetConVarInt(g_hCvarHHHTeam);
	g_iPeasantTeam = g_iHellmanTeam == 2 ? 3 : 2;

	FixCvarsForCompatibility(g_bEnabled);
}

public FixCvarsForCompatibility(bool:bEnableFix) {
	new Handle:hCvarUnbalanceLimit = FindConVar("mp_teams_unbalance_limit");
	new Handle:hCvarAutoTeamBalance = FindConVar("mp_autoteambalance");

	if(bEnableFix) {
		g_iOriginalUnbalanceLimit = GetConVarInt(hCvarUnbalanceLimit);
		g_bOriginalAutoTeamBalance = GetConVarBool(hCvarAutoTeamBalance);
		SetConVarInt(hCvarUnbalanceLimit, 0);
		SetConVarBool(hCvarAutoTeamBalance, false);
	} else {
		if(g_iOriginalUnbalanceLimit == -1)return;
		SetConVarInt(hCvarUnbalanceLimit, g_iOriginalUnbalanceLimit);
		SetConVarBool(hCvarAutoTeamBalance, g_bOriginalAutoTeamBalance);
	}
}

public Cvar_Changed(Handle:convar, const String:oldValue[], const String:newValue[]) {
	OnConfigsExecuted();

	//if(convar == g_hCvarEnabled) {
	//	FixCvarsForCompatibility(g_bEnabled);
	//}

	// TODO: If g_hCvarHHHTeam changes, we might want to switch all players to the other team
}

public OnClientPutInServer(iClient) {
	if(!g_bEnabled)return;

	ChangeClientTeam(iClient, g_iPeasantTeam);
	FakeClientCommand(iClient, "joinclass %s", "random");
}

public Event_PlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast) {
	if(!g_bEnabled)return;
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	new iTeam = GetClientTeam(iClient);

	if(HHH_IsHHH(iClient)) {
		if(g_iHellmanTeam != iTeam) {
			ChangeClientTeam(iClient, g_iHellmanTeam);
			TF2_RespawnPlayer(iClient);
		}
	} else {
		if(g_iPeasantTeam != iTeam) {
			ChangeClientTeam(iClient, g_iPeasantTeam);
			TF2_RespawnPlayer(iClient);
		}
	}
}


public HHH_OnStart(iClient) {
	if(g_bEnabled) {
		new iTeam = GetClientTeam(iClient);

		if(g_iHellmanTeam != iTeam) {
			//LogMessage("Switching player to HHH Team");
			ChangeClientTeam(iClient, g_iHellmanTeam);
			//LogMessage("Done switching player to HHH Team");
			//TF2_RespawnPlayer(iClient);
		}
	}
}

public HHH_OnStop(iClient) {
	if(g_bEnabled) {
		new iTeam = GetClientTeam(iClient);

		if(g_iPeasantTeam != iTeam) {
			//LogMessage("Switching player to Peasant Team");
			ChangeClientTeam(iClient, g_iPeasantTeam);
			//TF2_RespawnPlayer(iClient);
		}
	}
}

public Action:CommandListener_JoinTeam(client, const String:command[], argc) {
	if(!g_bEnabled)return Plugin_Continue;

	if (IsClientInGame(client))	{
		new team = GetClientTeam(client);

		if (team != g_iPeasantTeam && !HHH_IsHHH(client))
			ChangeClientTeam(client, g_iPeasantTeam);
	}

	return Plugin_Handled;
}

public Action:Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast) {
	if(!g_bEnabled)return Plugin_Continue;
	//new iClient = GetClientOfUserId(GetEventInt(event, "userid"));

	//if(HHH_IsHHH(iClient)) {
	if (!dontBroadcast)	{
		new Handle:hEvent = CreateEvent("player_team");
		new String:clientName[MAX_NAME_LENGTH + 1];
		new userId = GetEventInt(event, "userid");
		new client = GetClientOfUserId(userId);

		if (hEvent != INVALID_HANDLE) {
			GetClientName(client, clientName, sizeof(clientName));
			SetEventInt(hEvent, "userid", userId);
			SetEventInt(hEvent, "team", GetEventInt(event, "team"));
			SetEventInt(hEvent, "oldteam", GetEventInt(event, "oldteam"));
			SetEventBool(hEvent, "disconnect", GetEventBool(event, "disconnect"));
			SetEventBool(hEvent, "autoteam", GetEventBool(event, "autoteam"));
			SetEventBool(hEvent, "silent", GetEventBool(event, "silent"));
			SetEventString(hEvent, "name", clientName);
			FireEvent(hEvent, true);
		}

		return Plugin_Handled;
	}
	//}

	return Plugin_Continue;
}