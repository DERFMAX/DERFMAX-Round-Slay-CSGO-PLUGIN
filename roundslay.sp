#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "DERFMAX"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

int g_iRoundsToSlay[MAXPLAYERS + 1] =  { 0, ... };

public Plugin myinfo = 
{
	name = "Round Slay",
	author = PLUGIN_AUTHOR,
	description = "Slays given player for x round.",
	version = PLUGIN_VERSION,
};

public void OnPluginStart()
{
	RegAdminCmd("sm_rslay", Command_RSlay, ADMFLAG_SLAY);
	RegAdminCmd("sm_cancelrslay", Command_CancelRSlay, ADMFLAG_SLAY);	
	
	HookEvent("round_start", Event_RoundStart);
}

public Action Command_RSlay(int client, int args)
{
	if (!client)return;
	
	if (args < 2) {
		ReplyToCommand(client, "[SM] Usage: !rslay <target> <round(s)>");
		return;
	}
	
	char sArg1[32], sArg2[32];
	GetCmdArg(1, sArg1, sizeof(sArg1));
	GetCmdArg(2, sArg2, sizeof(sArg2));
	
	int iTarget = FindTarget(client, sArg1, false, true);

	if (iTarget == -1) {
		ReplyToCommand(client, "[SM] Invalid target.");
		return;
	}
	
	int iRounds = StringToInt(sArg2);
	
	if (iRounds <= 0) {
		ReplyToCommand(client, "[SM] Round(s) should be bigger than zero.");
		return;
	}
	
	g_iRoundsToSlay[iTarget] = iRounds;
	PrintToChatAll("[SM] %N: %N will be slayed for %d rounds.", client, iTarget, iRounds);
}

public Action Command_CancelRSlay(int client, int args)
{
	if (!client)return;
	
	if (args < 1) {
		ReplyToCommand(client, "[SM] Usage: !cancelrslay <target>");
		return;
	}
	
	char sArg1[32];
	GetCmdArg(1, sArg1, sizeof(sArg1));
	
	int iTarget = FindTarget(client, sArg1, false, true);

	if (iTarget == -1 || g_iRoundsToSlay[iTarget] == 0) {
		ReplyToCommand(client, "[SM] Invalid target or target already won't be slayed.");
		return;
	}

	g_iRoundsToSlay[iTarget] = 0;
	PrintToChatAll("[SM] %N removed slay action of %N.", client, iTarget);
}

public void Event_RoundStart(Event event, const char[] name, bool dB)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (g_iRoundsToSlay[i] > 0)
			{
				ForcePlayerSuicide(i); 
				g_iRoundsToSlay[i]--;
			}
		}
	}
}