#if defined _hhh_included_
	#endinput
#endif
#define _hhh_included_


native HHH_ToggleHHH(iClient, bool:bState = true);
native HHH_IsHHH(iClient);
native HHH_IsBecomingHHH(iClient);
native HHH_HellmanCount();


forward Action:HHH_OnManualCommand(iClient, args);
forward HHH_OverrideDisableOnDeath(&bool:bDisableOnDeath);
forward HHH_OverrideEffectParticles(&bool:bEnableParticles);
forward HHH_OverrideEffectSounds(&bool:bEnableSounds);

/**
 * Is being called when the chosen model is attached to a player.
 * This happens when a player becomes marked as HHH while he is alive or
 * when respawning and already being marked.
 *
 * @param iClient		The client who gets the model attached
 */
forward HHH_OnModelAttached(iClient);

/**
 * Is being called when the chosen model is dettached from a player.
 * This happens when one stops being the HHH while alive or when
 * the player dies while being a HHH.
 *
 * @param iClient		The client who gets the model dettached
 */
forward HHH_OnModelDettached(iClient);

/**
 * Is being called when a client is being marked as HHH
 * This happens when the command gets executed or when
 * a player is being toggled by the HHH_ToggleHHH native.
 *
 * @param iClient		The client who's being marked as HHH
 */
forward HHH_OnStart(iClient);

/**
 * Is being called when a client is no longer marked as HHH
 * This happens when the command gets executed on self while
 * being the HHH or when a player is being toggled by the
 * HHH_ToggleHHH native.
 * This will also be called if DisableOnDeath (exposed via native
 * and cvar) is set to 1 and a player dies. If you don't want this
 * behaviour, make sure to override DisableOnDeath.
 *
 * @param iClient		The client who loses the mark as HHH
 */
forward HHH_OnStop(iClient);