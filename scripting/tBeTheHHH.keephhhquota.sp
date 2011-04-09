#pragma semicolon 1
#include <sourcemod>
#include <tbethehhh>
#include <tf2>

#define VERSION 		"0.0.1"

new Handle:g_hCvarEnabled = INVALID_HANDLE;
new Handle:g_hCvarQuota = INVALID_HANDLE;
new Handle:g_hCvarMinimal = INVALID_HANDLE;
new Handle:g_hCvarMaximal = INVALID_HANDLE;

new bool:g_bEnabled;
new Float:g_fQuota;
new g_iMin;
new g_iMax;

public Plugin:myinfo =
{
	name 		= "tBeTheHHH - Keep Quota",
	author 		= "Thrawn",
	description = "Set the amount of HHHs based on playercount",
	version 	= VERSION,
};

public OnPluginStart() {
	CreateConVar("sm_tbethehhh_keepquota_version", VERSION, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_hCvarEnabled = CreateConVar("sm_tbethehhh_keepquota_enable", "1", "Set the amount of HHHs based on playercount", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarQuota = CreateConVar("sm_tbethehhh_keepquota_quota", "6.0", "Amount of players / this value = HHH count", FCVAR_PLUGIN, true, 1.0, true, MAXPLAYERS * 1.0);
	g_hCvarMinimal = CreateConVar("sm_tbethehhh_keepquota_min", "0", "Minimal amount of HHHs", FCVAR_PLUGIN, true, 0.0, true, MAXPLAYERS * 1.0);
	g_hCvarMaximal = CreateConVar("sm_tbethehhh_keepquota_max", "32", "Maximum amount of HHHs", FCVAR_PLUGIN, true, 0.0, true, MAXPLAYERS * 1.0);
	HookConVarChange(g_hCvarEnabled, Cvar_Changed);
	HookConVarChange(g_hCvarQuota, Cvar_Changed);
	HookConVarChange(g_hCvarMinimal, Cvar_Changed);
	HookConVarChange(g_hCvarMaximal, Cvar_Changed);

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public Cvar_Changed(Handle:convar, const String:oldValue[], const String:newValue[]) {
	OnConfigsExecuted();
}

public OnConfigsExecuted() {
	g_bEnabled = GetConVarBool(g_hCvarEnabled);
	g_fQuota = GetConVarFloat(g_hCvarQuota);
	g_iMin = GetConVarInt(g_hCvarMinimal);
	g_iMax = GetConVarInt(g_hCvarMaximal);
}

public HHH_OverrideDisableOnDeath(&bool:bDisableOnDeath) {
	if(g_bEnabled) {
		// We handle death of HHHs ourselves
		bDisableOnDeath = false;
	}
}

public Action:HHH_OnManualCommand(iClient, args) {
	if(g_bEnabled) {
		// Block manual commands
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public HHH_OnStart(iClient) {
	if(g_bEnabled) {
		// We might want to announce HHH changes
	}
}

public HHH_OnStop(iClient) {
	if(g_bEnabled) {
		// We might want to announce HHH changes
	}
}

public bool:HHH_RequiredForQuota() {
	if(HHH_HellmanCount() < g_iMin)return true;
	if(HHH_HellmanCount() >= g_iMax)return false;
	if(HHH_HellmanCount() >= RoundToFloor(GetClientCount() / g_fQuota))return false;
	else return true;
}

stock MakeRandomHHH(iExcept = 0) {
	new iCount = 0;
	new iPlayers[MAXPLAYERS];
	for(new iClient = 1; iClient <= MaxClients; iClient++) {
		if(IsClientInGame(iClient) && !IsClientObserver(iClient) && iClient != iExcept && !HHH_IsHHH(iClient)) {
			iPlayers[iCount] = iClient;
			iCount++;
		}
	}

	if(iCount > 0) {
		HHH_ToggleHHH(iPlayers[GetRandomInt(0,iCount)], true);
	}
}

public Action:Event_PlayerDeath(Handle:hEvent, String:strName[], bool:bDontBroadcast) {
	if(!g_bEnabled)return Plugin_Continue;
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	new iAttacker = GetClientOfUserId(GetEventInt(hEvent, "attacker"));

	if(HHH_IsBecomingHHH(iClient)) {
		bDontBroadcast = true;
		return Plugin_Changed;
	}

	if(HHH_IsHHH(iClient)) {
		// Death always means stop being a HHH
		HHH_ToggleHHH(iClient, false);

		// Calculate quota (how many HHH are required)
		// and only replace if necessary
		if(!HHH_RequiredForQuota())return Plugin_Continue;

		if(iAttacker == 0 || iAttacker == iClient || HHH_IsHHH(iAttacker)) {
			//HHH killed himself or by world or by another HHH
			MakeRandomHHH(iAttacker);
		} else if(iAttacker > 0 && iAttacker <= MaxClients && IsClientInGame(iAttacker)) {
			HHH_ToggleHHH(iAttacker, true);

			if(!IsPlayerAlive(iAttacker)) {
				TF2_RespawnPlayer(iAttacker);
			}
		}

	}

	return Plugin_Continue;
}

public Event_PlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast) {
	if(!g_bEnabled)return;
	if(!HHH_RequiredForQuota())return;
	MakeRandomHHH();

	return;
}
