# API
This API is the base of our plugins.

Using this manager, you can **automatically** install, and manage (update/delete/load/unload/reload) any of our plugins with one-click.

## Dependencies
[SteamWorks](https://github.com/KyleSanderson/SteamWorks) by [KyleSanderson](https://github.com/KyleSanderson)

## Installation
- Download and install the dependencies.
- Download the [latest release](github.com/Eternar/API/releases/latest) and install it in the usual way, even the empty folders! If they're missing, the plugin will try to create them, but if it lacks on permission the plugin will be unable to start.
- Use command **!eternar** to open up the menu

---

## Package Configuration (Beginning of the developers section)
~~If you plan on writing a plugin that is using our API, and want to list it in the package manager you must ..~~ -> Currently unavailable for the public, it will be available in **1.0.3**

By default, every stable plugin package is located in the [**main** manifest file](https://github.com/Eternar/API/blob/main/plugin_list.cfg)

The manifest file can be changed with ConVar **eternar_api_manifest**

Available manifest files:
  - 'main' | Stable plugins
  - 'preview' or '84e1a89fe20baed1a4959516f496108225f22ee5' | Dev builds, may be unstable or uncompleted

## Plugin package template

```
"Plugins"
{
	"Example Plugin"
	{
		"FileName"	"Eternar/plugin.smx"
		"Version"	"1.0.0"
		"VersionInt"	"100000"
    
		"Description"	"Example Description"
		"Author"	"Author"
		"Repository"	"Repository"
    
		"Files"
		{
			Key: 	Will be replaced with downloadurl
			Value:	Place where the file should be placed
			"1"	"file.extension"
			"2"	"file.extension"
		}
    
		"Dependencies"
		{
			"Dependency Name"	"File Path"
		}
	}
}
```

## Example plugin
A base template for a plugin that can be used in the system ([Documentation](https://github.com/Eternar/API/blob/main/scripting/include/Eternar.inc))

```C++
#include <sourcemod>
#include <Eternar>

#pragma tabsize 0;
#pragma newdecls required;
#pragma semicolon 1;

public Plugin myinfo = 
{
	name = "Test Plugin",
	author = "Eternar",
	description = "Testing API Natives",
	version = "1.0.0",
	url = "https://github.com/Eternar"
};

public void OnPluginStart()
{
	if(Eternar_Available() && Eternar_GetVersion() >= 100000)
	{
		Eternar_StartPlugin(OnPluginStarted);
	}
}

public void Eternar_OnLoaded()
{
	OnPluginStart(); // late load
}

public void OnPluginEnd()
{
	if(Eternar_Available())
		Eternar_StopPlugin();
}

public void OnPluginStarted()
{
	PrintToChatAll("OnPluginStarted();"); //beginning of your plugin
}
```

## TODO
- Add support for databases in the package manager.
- Add native functions for the logsystem
- Auto create folder inside the plugins folder
- Version check before forcing an update
- Skip configuration files on update
