int                 g_iLogLevel = view_as<int>(LOG_LEVEL);

char                g_szLogFile[PLATFORM_MAX_PATH];
char                g_szPluginCache[MAXPLAYERS + 1][MAX_PLUGIN_FILEPATH_LENGTH];

IPluginList         ESPlugins;
IPluginContextList  ESPluginContexts;

GlobalForward       APIForward[Forward_Count];
ConVar              Variables[ConVar_Count];