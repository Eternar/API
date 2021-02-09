public void OnConfigsExecuted()
{
    char szBuffer[64];
    Variables[ConVar_Manifest].GetString(szBuffer, sizeof(szBuffer));
    Format(g_szManifestData, sizeof(g_szManifestData), ETERNAR_PACKAGES, szBuffer);
    Call_StartForward(APIForward[Forward_OnLoaded]);
    Call_Finish();
}

public void OnPluginEnd()
{
    LogMsg(Debug, "Started shutting down session..");
    Call_StartForward(APIForward[Forward_OnUnloaded]);
    Call_Finish();
    LogMsg(Debug, "Shutting down session finished!");
}

public void Eternar_OnLoaded()
{
    LogMsg(Debug, "Fetching package list...");
    IPluginContextList.Update();
}