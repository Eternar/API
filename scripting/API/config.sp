void Initialize()
{
    char szDirectories[3][] =
    {
        "addons/sourcemod/logs/Eternar",
        "addons/sourcemod/configs/Eternar",
        "cfg/sourcemod/Eternar"
    };

    for(int i = 0; i < 3; i++)
    {
        if(!DirExists(szDirectories[i]))
        {
            LogMsg(Debug, "Creating directory %s...", szDirectories[i]);
            if(!CreateDirectory(szDirectories[i], 777))
            {
                LogMsg(Critical, "Failed to create directory %s!", szDirectories[i]);
                SetFailState("Unable to create a directory at %s", szDirectories[i]);
            }
        }
    }

    char szTime[128];
    FormatTime(szTime, sizeof(szTime), LOG_TIMEFORMAT, GetTime());
    BuildPath(Path_SM, g_szLogFile, sizeof(g_szLogFile), LOG_FILEFORMAT, szTime);
    LogMsg(Debug, "Started initializing session..");

    RegAdminCmd("sm_eternar", Command_Eternar, ADMFLAG_ROOT);
}

void CreateVariables()
{
    LogMsg(Debug, "Creating variables..");
    Variables[ConVar_Manifest]      = CreateConVar("eternar_api_manifest", "main", "API manifest version. 'main' for the latest one.");
    Variables[ConVar_PluginTimeout] = CreateConVar("eternar_api_plugin_timeout", "10", "In seconds, maximum time before a plugin timing out.");
    AutoExecConfig(true, "Eternar", "sourcemod/Eternar");
    LogMsg(Debug, "Done!");
}

void LoadPhrases()
{
    LogMsg(Debug, "Loading phrases..");
	LoadTranslations("common.phrases");
	LoadTranslations("core.phrases");
    LogMsg(Debug, "Done!");
}