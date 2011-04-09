#pragma semicolon 1
#include <sourcemod>
#include <tbethehhh>
#include <tf2_stocks>

#define VERSION 		"0.0.1"

#define CLASS_UNKNOWN       0
#define CLASS_SCOUT         1
#define CLASS_SNIPER        2
#define CLASS_SOLDIER       3
#define CLASS_DEMOMAN       4
#define CLASS_MEDIC         5
#define CLASS_HEAVY         6
#define CLASS_PYRO          7
#define CLASS_SPY           8
#define CLASS_ENGINEER      9

#define TEAM_RED            2
#define TEAM_BLU            3

new Handle:g_hCvarEnabled = INVALID_HANDLE;
new bool:g_bEnabled;

new Handle:g_hCvarRandom = INVALID_HANDLE;
new bool:g_bRandom;

new Handle:g_hCvarAllowScout = INVALID_HANDLE;
new Handle:g_hCvarAllowSoldier = INVALID_HANDLE;
new Handle:g_hCvarAllowHeavy = INVALID_HANDLE;
new Handle:g_hCvarAllowPyro = INVALID_HANDLE;
new Handle:g_hCvarAllowDemoman = INVALID_HANDLE;
new Handle:g_hCvarAllowEngineer = INVALID_HANDLE;
new Handle:g_hCvarAllowMedic = INVALID_HANDLE;
new Handle:g_hCvarAllowSpy = INVALID_HANDLE;
new Handle:g_hCvarAllowSniper = INVALID_HANDLE;
new bool:g_bAllowScout;
new bool:g_bAllowSoldier;
new bool:g_bAllowHeavy;
new bool:g_bAllowPyro;
new bool:g_bAllowDemoman;
new bool:g_bAllowEngineer;
new bool:g_bAllowMedic;
new bool:g_bAllowSniper;
new bool:g_bAllowSpy;

public Plugin:myinfo =
{
	name 		= "tBeTheHHH - HHH Class",
	author 		= "Thrawn",
	description = "This forces HHHs to be a specific class.",
	version 	= VERSION,
};

public OnPluginStart() {
	CreateConVar("sm_tbethehhh_hhhclass_version", VERSION, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_hCvarEnabled = CreateConVar("sm_tbethehhh_hhhclass_enable", "1", "Enforce class upon HHHs", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarRandom = CreateConVar("sm_tbethehhh_hhhclass_random", "1", "Choose class randomly", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	g_hCvarAllowScout = CreateConVar("sm_tbethehhh_hhhclass_scout", "1", "0 = HHHs cant play scout", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowSoldier = CreateConVar("sm_tbethehhh_hhhclass_soldier", "1", "0 = HHHs cant play soldier", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowHeavy = CreateConVar("sm_tbethehhh_hhhclass_heavy", "1", "0 = HHHs cant play heavy", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowPyro = CreateConVar("sm_tbethehhh_hhhclass_pyro", "1", "0 = HHHs cant play pyro", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowDemoman = CreateConVar("sm_tbethehhh_hhhclass_demoman", "1", "0 = HHHs cant play demoman", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowEngineer = CreateConVar("sm_tbethehhh_hhhclass_engineer", "0", "0 = HHHs cant play engineer", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowMedic = CreateConVar("sm_tbethehhh_hhhclass_medic", "0", "0 = HHHs cant play medic", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowSpy = CreateConVar("sm_tbethehhh_hhhclass_spy", "0", "0 = HHHs cant play spy", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	g_hCvarAllowSniper = CreateConVar("sm_tbethehhh_hhhclass_sniper", "0", "0 = HHHs cant play sniper", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	HookConVarChange(g_hCvarEnabled, Cvar_Changed);
	HookConVarChange(g_hCvarRandom, Cvar_Changed);

	HookConVarChange(g_hCvarAllowScout, Cvar_Changed);
	HookConVarChange(g_hCvarAllowSoldier, Cvar_Changed);
	HookConVarChange(g_hCvarAllowHeavy, Cvar_Changed);
	HookConVarChange(g_hCvarAllowPyro, Cvar_Changed);
	HookConVarChange(g_hCvarAllowDemoman, Cvar_Changed);
	HookConVarChange(g_hCvarAllowEngineer, Cvar_Changed);
	HookConVarChange(g_hCvarAllowMedic, Cvar_Changed);
	HookConVarChange(g_hCvarAllowSniper, Cvar_Changed);
	HookConVarChange(g_hCvarAllowSpy, Cvar_Changed);

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_changeclass", Event_PlayerClass, EventHookMode_Pre);
}

public OnConfigsExecuted() {
	g_bEnabled = GetConVarBool(g_hCvarEnabled);
	g_bRandom = GetConVarBool(g_hCvarRandom);

	g_bAllowScout = GetConVarBool(g_hCvarAllowScout);
	g_bAllowSoldier = GetConVarBool(g_hCvarAllowSoldier);
	g_bAllowHeavy = GetConVarBool(g_hCvarAllowHeavy);
	g_bAllowPyro = GetConVarBool(g_hCvarAllowPyro);
	g_bAllowDemoman = GetConVarBool(g_hCvarAllowDemoman);
	g_bAllowEngineer = GetConVarBool(g_hCvarAllowEngineer);
	g_bAllowMedic = GetConVarBool(g_hCvarAllowMedic);
	g_bAllowSniper = GetConVarBool(g_hCvarAllowSniper);
	g_bAllowSpy = GetConVarBool(g_hCvarAllowSpy);

}

public Cvar_Changed(Handle:convar, const String:oldValue[], const String:newValue[]) {
	OnConfigsExecuted();
}

public Event_PlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast) {
	if(!g_bEnabled)return;
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid")),
		iClass	= _:TF2_GetPlayerClass(iClient),
		iTeam   = GetClientTeam(iClient);

	if(IsBlocked(iClient, iClass)) {
		PickClass(iClient);

		if(!g_bRandom) {
			ShowVGUIPanel(iClient, iTeam == TEAM_BLU ? "class_blue" : "class_red");
		}
	}
}

public Action:Event_PlayerClass(Handle:event, const String:name[], bool:bDontBroadcast) {
	if(!g_bEnabled)return Plugin_Continue;

	new iClient = GetClientOfUserId(GetEventInt(event, "userid")),
		iClass  = GetEventInt(event, "class"),
		iOldClass	= _:TF2_GetPlayerClass(iClient),
		iTeam   = GetClientTeam(iClient);

	if(!HHH_IsHHH(iClient))return Plugin_Continue;

	if(g_bRandom) {
		TF2_SetPlayerClass(iClient, TFClassType:iOldClass);
		TF2_RespawnPlayer(iClient);
		TF2_RegeneratePlayer(iClient);
	} else {
		if(IsBlocked(iClient, iClass)) {
			PickClass(iClient);

			if(!g_bRandom) {
				ShowVGUIPanel(iClient, iTeam == TEAM_BLU ? "class_blue" : "class_red");
			}
		}
	}

	return Plugin_Continue;
}

public bool:IsBlocked(iClient, iClass) {
	if(!HHH_IsHHH(iClient) || !IsClientInGame(iClient) || iClass < CLASS_SCOUT)
		return false;

	if(iClass == CLASS_SCOUT && g_bAllowScout)return false;
	if(iClass == CLASS_SOLDIER && g_bAllowSoldier)return false;
	if(iClass == CLASS_HEAVY && g_bAllowHeavy)return false;
	if(iClass == CLASS_PYRO && g_bAllowPyro)return false;
	if(iClass == CLASS_DEMOMAN && g_bAllowDemoman)return false;
	if(iClass == CLASS_ENGINEER && g_bAllowEngineer)return false;
	if(iClass == CLASS_MEDIC && g_bAllowMedic)return false;
	if(iClass == CLASS_SNIPER && g_bAllowSniper)return false;
	if(iClass == CLASS_SPY && g_bAllowSpy)return false;

	return true;
}

public PickClass(iClient) {
	// Loop through all classes, starting at random class
	for(new i = GetRandomInt(CLASS_SCOUT, CLASS_ENGINEER), iClass = i;;)
	{
		// If player is allowed, set client's class
		if(!IsBlocked(iClient, i)) {
			TF2_SetPlayerClass(iClient, TFClassType:i);
			TF2_RespawnPlayer(iClient);
			TF2_RegeneratePlayer(iClient);

			break;
		}
		// If next class index is invalid, start at first class
		else if(++i > CLASS_ENGINEER)
			i = CLASS_SCOUT;
		// If loop has finished, stop searching
		else if(i == iClass)
			break;
	}
}