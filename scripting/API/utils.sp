stock bool IsValidClient(int client)
{
	if(client <= 0 || client > MaxClients) return false;
	if(!IsClientConnected(client) || IsFakeClient(client) || IsClientSourceTV(client)) return false;
	return IsClientInGame(client);
}

stock void PostCheckAll(bool validOnly = true)
{
	for(int i = 1; i <= MaxClients; i++)
    {
		if(validOnly && !IsValidClient(i))
			continue;
			
        OnClientPostAdminCheck(i);
    }
}

stock char IntToStr(const int num)
{
	char szTemp[10];
	IntToString(num, szTemp, sizeof(szTemp));
	return szTemp;
}

stock bool IsValidPlugin(Handle hPlugin)
{
    if(hPlugin == null)
        return false;

    Handle hIterator = GetPluginIterator();

    bool bPluginValid = false;
    while(MorePlugins(hIterator))
	{
        Handle hLoadedPlugin = ReadPlugin(hIterator);
        if(hLoadedPlugin == hPlugin)
		{
            bPluginValid = GetPluginStatus(hLoadedPlugin) == Plugin_Running;
            break;
        }
    }

    delete hIterator;
    return bPluginValid;
}

stock bool PluginExists(const char[] pluginName)
{
    char szBuffer[PLATFORM_MAX_PATH];
    Format(szBuffer, sizeof(szBuffer), "addons/sourcemod/plugins/%s", pluginName);
    return FileExists(szBuffer);
}

stock bool DeletePlugin(const char[] pluginName)
{
    char szBuffer[PLATFORM_MAX_PATH];
    Format(szBuffer, sizeof(szBuffer), "addons/sourcemod/plugins/%s", pluginName);
    return DeleteFile(szBuffer);
}

stock void ManagePlugin(const char[] pluginName, const char[] action)
{
    ServerCommand("sm_rcon sm plugins %s %s", action, pluginName);
}

stock void DownloadFile(const char[] url, const char[] path, int client, bool last = false)
{
	File file = OpenFile(path, "wb");
	if (file == INVALID_HANDLE)
	{
		LogMsg(Error, "No permission to write into '%s'", path);
		delete file;
	}

	Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);

    	DataPack pack = new DataPack();
    	pack.WriteString(path);
    	pack.WriteCell(client);
    	pack.WriteCell(last);
	if(!hRequest || !SteamWorks_SetHTTPRequestContextValue(hRequest, pack) || !SteamWorks_SetHTTPCallbacks(hRequest, OnFileDownloaded) || !SteamWorks_SendHTTPRequest(hRequest))
	{
        	LogMsg(Error, "Failed to CreateHTTPRequest ('%s')", path);
        	delete pack;
        	delete hRequest;
	}
}
