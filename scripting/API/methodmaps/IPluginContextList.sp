char g_szManifestData[PLATFORM_MAX_PATH];

methodmap IPluginContextList < StringMap
{
    public IPluginContextList()
    {
        return view_as<IPluginContextList>(new StringMap());
    }

    /**
    * Request packages file from the server.
    *
    * @noreturn
    **/
    public static void Update()
    {
        Handle hRequest = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, g_szManifestData);
        if(!hRequest || !SteamWorks_SetHTTPCallbacks(hRequest, OnTransferCompleted) || !SteamWorks_SendHTTPRequest(hRequest))
            delete hRequest;
    }
}