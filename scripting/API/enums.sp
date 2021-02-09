enum Forwards
{
    Forward_OnUnloaded = 0,
    Forward_OnLoaded,
    Forward_PluginStarted,
    Forward_PluginStopped,
    Forward_Count
}

enum ConsoleVariables
{
    ConVar_Manifest,
    ConVar_PluginTimeout,
    ConVar_Count
}

/* Menu */
enum iMainMenuAction
{
    Action_AvailablePackages = 0,
    Action_InstalledPackages,
    Action_Developers
}

enum iPluginAction
{
    Action_Unload = 0,
    Action_Reload,
    Action_Update,
    Action_Delete,
    Action_Load
}

enum iPluginContextAction
{
    Action_Install = 0,
    Action_Source,
    Action_License,
    Action_Manage
}