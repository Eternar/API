public APLRes AskPluginLoad2(Handle hPlugin, bool bLoad, char[] szError, int iMaxErr)
{
	RegPluginLibrary("Eternar API");

	CreateNative("Eternar_GetVersion", Native_Version);
    CreateNative("Eternar_StartPlugin", Native_StartPlugin);
	CreateNative("Eternar_StopPlugin", Native_StopPlugin);

	APIForward[Forward_OnUnloaded]		= new GlobalForward("Eternar_OnUnloaded",		ET_Ignore);
	APIForward[Forward_OnLoaded]		= new GlobalForward("Eternar_OnLoaded",			ET_Ignore);
	APIForward[Forward_PluginStarted]	= new GlobalForward("Eternar_OnPluginStarted",	ET_Ignore);
	APIForward[Forward_PluginStopped]	= new GlobalForward("Eternar_OnPluginStopped",	ET_Ignore);
	return APLRes_Success;
}

public int Native_Version(Handle plugin, int params)
{
	return ETERNAR_API_VERSION;
}

public int Native_StartPlugin(Handle plugin, int params)
{
	ESPlugin PluginContext;
	PluginContext.Init(plugin);
	if(!ESPlugins.SetArray(PluginContext.FileName, PluginContext, sizeof(PluginContext)/*, false*/))
	{
		LogMsg(Error, "Failed to start plugin '%s'", PluginContext.Name);
		PluginContext.Unload();
		return view_as<int>(Plugin_Failed);
	}
	
	PluginStartedCallback cb = view_as<PluginStartedCallback>(GetNativeFunction(1));
	if(cb != INVALID_FUNCTION)
	{
		Call_StartFunction(plugin, cb);
		Call_Finish();
	}

	LogMsg(Info, "Started plugin '%s'", PluginContext.Name);
	return view_as<int>(GetPluginStatus(plugin));
}

public int Native_StopPlugin(Handle plugin, int params)
{
	/*
	char szTemp[sizeof(ESPlugin::FileName)];
	GetPluginFilename(plugin, szTemp, sizeof(szTemp));
	ESPlugins.Remove(szTemp);
	*/
}