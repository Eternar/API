#include <sourcemod>
#include <SteamWorks>
#include <Eternar>

#include "API\directives.sp"
#include "API\header.sp"

#include "API\classes\ESPlugin.sp"
#include "API\classes\ESPluginContext.sp"

#include "API\methodmaps\IPluginList.sp"
#include "API\methodmaps\IPluginContextList.sp"

#include "API\enums.sp"
#include "API\globals.sp"
#include "API\logs.sp"
#include "API\utils.sp"

#include "API\config.sp"
#include "API\forwards.sp"
#include "API\callbacks.sp"
#include "API\natives.sp"

#include "API\menu\backend.sp"
#include "API\menu\frontend.sp"

public void OnPluginStart()
{
	Initialize(); {
		ESPlugins			= new IPluginList();
		ESPluginContexts	= new IPluginContextList();
		
		LoadPhrases();
		CreateVariables();
	} LogMsg(Debug, "Initialization session done! Version: %s", API_VERSION);
}