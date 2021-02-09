typeset LoadingCallback
{
    function void (int client);
    function void (int client, ESPlugin esp);
    function void (int client, ESPluginContext espc);
    function void (int client, ESPlugin esp, ESPluginContext espc);
}

public Action Command_Eternar(int client, int args)
{
    if(IsValidClient(client))
        MainMenu(client);

    return Plugin_Handled;
}

public int OnFileDownloaded(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, DataPack pack)
{
    pack.Reset();
    char szPath[PLATFORM_MAX_PATH];
    pack.ReadString(szPath, sizeof(szPath));
    int client = pack.ReadCell();
    bool lastFile = view_as<bool>(pack.ReadCell());
    delete pack;

    if (bFailure || !bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
	{
		LogMsg(Error, "Failed to download a file!\n\t[0] File: %s\n\t[1] Error code: %d", szPath, eStatusCode);
        SetupLoadingMenu(client, "Failed to download the plugin files!\nCheck error logs for more information!");
		delete hRequest;
		return;
	}

    SteamWorks_WriteHTTPResponseBodyToFile(hRequest, szPath);
    delete hRequest;

    if(lastFile)
    {
        if(PluginExists(g_szPluginCache[client]))
        {
            LogMsg(Debug, "Starting plugin %s...", g_szPluginCache[client]);
            SetupLoadingMenu(client, "Starting plugin...");
            CreateTimer(1.0, AwaitOnPlugin, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
        } else {
            LogMsg(Error, "The plugin does not exists on disk.\n\t[0] File: %s\n\t[1] Downloaded from: %s", g_szPluginCache[client], szPath);
            SetupLoadingMenu(client, "Unable to start the plugin...");
        }
    }
}

public Action AwaitOnPlugin(Handle timer, int userid)
{
    static int loopCount = 0;
    int client = GetClientOfUserId(userid);

    ESPluginContext context;
    if(g_szPluginCache[client][0] && ESPluginContexts.GetArray(g_szPluginCache[client], context, sizeof(context)))
    {
        if(loopCount < Variables[ConVar_PluginTimeout].IntValue)
        {
            IPluginList.Refresh();

            ESPlugin plugin;
            if(!ESPlugins.GetArray(context.FileName, plugin, sizeof(plugin)))
                context.ToPlugin(plugin);

            plugin.Load();

            if(!plugin.IsValid())
            {
                ++loopCount;
                static char szTemp[24];
                Format(szTemp, sizeof(szTemp), "Starting plugin...%i", loopCount);
                SetupLoadingMenu(client, szTemp);
                return Plugin_Continue;
            } else {
                LogMsg(Info, "Plugin %s has been started!", plugin.Name);
                loopCount = 0;
                SetupLoadingMenu(client, "Done!", DelayedPluginFrame, PluginInfoMenu);
                return Plugin_Stop;
            }
        } else {
            loopCount = 0;
            LogMsg(Error, "Plugin %s has timed out!", g_szPluginCache[client]);
            SetupLoadingMenu(client, "Plugin has timed out!");
            return Plugin_Stop;
        }
    }

    loopCount = 0;
    LogMsg(Error, "Failed to start plugin %s!", g_szPluginCache[client]);
    SetupLoadingMenu(client, "Failed to start the plugin!");
    return Plugin_Stop;
}

public int OnTransferCompleted(Handle hRequest, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, any data)
{
	if (bFailure || !bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
	{
		LogMsg(Error, "Github HTTP Response failed! Error code: %d", eStatusCode);
		delete hRequest;
		return;
	}

    SteamWorks_WriteHTTPResponseBodyToFile(hRequest, ETERNAR_PACKAGES_FILE);
	delete hRequest;

	KeyValues keyValues = new KeyValues("Plugins");
	if (!keyValues.ImportFromFile(ETERNAR_PACKAGES_FILE))
	{
		LogMsg(Error, "Couldn't import packages file.");
        DeleteFile(ETERNAR_PACKAGES_FILE);
		delete keyValues;
		return;
	}

	if (!keyValues.GotoFirstSubKey())
	{
		LogMsg(Error, "Packages file is empty, or corrupted");
        DeleteFile(ETERNAR_PACKAGES_FILE);
		delete keyValues;
		return;
	}

    if(ESPluginContexts.Size > 0)
    {
        StringMapSnapshot Keys = ESPluginContexts.Snapshot();
        char szTemp[MAX_PLUGIN_NAME_LENTGH];
        
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szTemp, sizeof(szTemp));

            ESPluginContext context;
            ESPluginContexts.GetArray(szTemp, context, sizeof(context));
            context.Dispose();
        }

        delete Keys;
        ESPluginContexts.Clear();
    }

    LogMsg(Debug, "Reading package list...");
    do {
        ESPluginContext context;
        keyValues.GetSectionName(context.Name, sizeof(ESPluginContext::Name));
        context.VersionInt = keyValues.GetNum("VersionInt", 100000);

        keyValues.GetString("FileName", context.FileName, sizeof(ESPluginContext::FileName), "Unknown");
        keyValues.GetString("Version", context.Version, sizeof(ESPluginContext::Version), "Unknown");
        keyValues.GetString("Author", context.Author, sizeof(ESPluginContext::Author), "Unknown");
        keyValues.GetString("Description", context.Description, sizeof(ESPluginContext::Description), "Unknown");
        keyValues.GetString("Repository", context.Repository, sizeof(ESPluginContext::Repository), "Unknown");
    
        TraverseSection(keyValues, "Files", context.Files);
        TraverseSection(keyValues, "Dependencies", context.Dependencies);

        ESPluginContexts.SetArray(context.FileName, context, sizeof(context));
    } while(keyValues.GotoNextKey(true));

    LogMsg(Debug, "Package list has been fetched!");
    DeleteFile(ETERNAR_PACKAGES_FILE);
	delete keyValues;
}

void TraverseSection(KeyValues kv, const char[] section, StringMap& map)
{
    if(kv.JumpToKey(section, false))
    {
        if(kv.GotoFirstSubKey(false))
        {
            map = new StringMap();

            do {
                char szKey[PLATFORM_MAX_PATH];
                kv.GetSectionName(szKey, sizeof(szKey));

                char szValue[PLATFORM_MAX_PATH];
                kv.GetString(NULL_STRING, szValue, sizeof(szValue));

                map.SetString(szKey, szValue);
            } while(kv.GotoNextKey(false));

            kv.GoBack();
        }

        kv.GoBack();
    }
}

void SetupLoadingMenu(int client, const char[] message = "Loading...", Timer timer = INVALID_FUNCTION, LoadingCallback callback = INVALID_FUNCTION, float time = 0.2)
{
    LoadingMenu(client, message);

    if(timer != INVALID_FUNCTION)
    {
        DataPack pack = new DataPack();
        pack.WriteCell(client);
        pack.WriteFunction(callback);
        CreateTimer(time, timer, pack);
    }
}

public Action DelayedPluginFrame(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = pack.ReadCell();
    LoadingCallback cb = view_as<LoadingCallback>(pack.ReadFunction());
    delete pack;

    if(cb != INVALID_FUNCTION)
    {
        Call_StartFunction(INVALID_HANDLE, cb);
        Call_PushCell(client);
        ESPlugin plugin;
        if(g_szPluginCache[client][0] && ESPlugins.GetArray(g_szPluginCache[client], plugin, sizeof(plugin)))
            Call_PushArray(plugin, sizeof(plugin));
        Call_Finish();
    }
}

public Action DelayedPluginContextFrame(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = pack.ReadCell();
    LoadingCallback cb = view_as<LoadingCallback>(pack.ReadFunction());
    delete pack;

    if(cb != INVALID_FUNCTION)
    {
        Call_StartFunction(INVALID_HANDLE, cb);
        Call_PushCell(client);
        ESPluginContext PluginContext;
        if(g_szPluginCache[client][0] && ESPluginContexts.GetArray(g_szPluginCache[client], PluginContext, sizeof(PluginContext)))
            Call_PushArray(PluginContext, sizeof(PluginContext));
        Call_Finish();
    }
}

public Action DelayedPluginContextFrameEx(Handle timer, DataPack pack)
{
    pack.Reset();
    int client = pack.ReadCell();
    LoadingCallback cb = view_as<LoadingCallback>(pack.ReadFunction());
    delete pack;

    if(cb != INVALID_FUNCTION)
    {
        Call_StartFunction(INVALID_HANDLE, cb);
        Call_PushCell(client);
        ESPlugin plugin;
        if(g_szPluginCache[client][0] && ESPlugins.GetArray(g_szPluginCache[client], plugin, sizeof(plugin)))
            Call_PushArray(plugin, sizeof(plugin));

        ESPluginContext PluginContext;
        if(ESPluginContexts.GetArray(plugin.FileName, PluginContext, sizeof(PluginContext)))
            Call_PushArray(PluginContext, sizeof(PluginContext));
        Call_Finish();
    }
}

public void CheckUpdate(int client, ESPlugin plugin, ESPluginContext PluginContext)
{
    LogMsg(Debug, "Downloading plugin files...");
    SetupLoadingMenu(client, "Downloading plugin files...");
    plugin.Unload();
    PluginContext.Download(client);
}