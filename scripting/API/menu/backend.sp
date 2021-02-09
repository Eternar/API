public int MainMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[2];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            switch(StringToInt(szInfo))
            {
                case Action_AvailablePackages:
                {
                    LogMsg(Debug, "Fetching package list...");
                    SetupLoadingMenu(param1, "Fetching package list...", DelayedPluginFrame, AvailablePluginsMenu, 0.5);
                    IPluginContextList.Update();
                }
                case Action_InstalledPackages: InstalledPluginList(param1);
                case Action_Developers: DevelopersMenu(param1);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int DevelopersMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[12];
            menu.GetItem(param2, szInfo, sizeof(szInfo));
            PrintToChat(param1, "https://github.com/%s", szInfo);
            DevelopersMenu(param1);
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                MainMenu(param1);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int InstalledPluginListHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            menu.GetItem(param2, g_szPluginCache[param1], sizeof(g_szPluginCache[]));

            ESPlugin plugin;
            ESPlugins.GetArray(g_szPluginCache[param1], plugin, sizeof(plugin));
            PluginInfoMenu(param1, plugin);
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                MainMenu(param1);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int PluginInfoMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[2];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            ESPlugin plugin;
            ESPlugins.GetArray(g_szPluginCache[param1], plugin, sizeof(plugin));

            if(plugin.Exists())
            {
                int selection = 0;
                switch((selection = StringToInt(szInfo)))
                {
                    case Action_Unload: plugin.Unload();
                    case Action_Reload: plugin.Reload();
                    case Action_Update:
                    {
                        ESPluginContext context;
                        if(ESPluginContexts.GetArray(plugin.FileName, context, sizeof(context)))
                        {
                            LogMsg(Debug, "Checking for update...");
                            SetupLoadingMenu(param1, "Checking for update...", DelayedPluginContextFrameEx, CheckUpdate, 1.0);
                        } else {
                            LogMsg(Error, "Failed to update plugin %s.\n\t[0] This plugin is not from the package manager.", plugin.Name);
                            SetupLoadingMenu(param1, "This plugin cannot be updated\nusing package manager.");
                        }
                    }
                    case Action_Delete:
                    {
                        ESPlugins.Remove(plugin.FileName);
                        if(plugin.IsValid())
                            plugin.Unload();

                        ESPluginContext context;
                        if(ESPluginContexts.GetArray(plugin.FileName, context, sizeof(context)))
                        {
                            context.Delete();
                        } else {
                            //If this is not a 'package' installation
                            plugin.Delete(); //We only delete the main smx file, cfg and other files won't be touched
                        }
                    }
                    case Action_Load: plugin.Load();
                }

                if(selection != 2)
                {
                    if(selection == 3) SetupLoadingMenu(param1, _, DelayedPluginFrame, InstalledPluginList);
                    else SetupLoadingMenu(param1, _, DelayedPluginFrame, PluginInfoMenu);
                }
            } else PrintToChat(param1, "The file does not exists.");
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                InstalledPluginList(param1);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int AvailablePluginsMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            menu.GetItem(param2, g_szPluginCache[param1], sizeof(g_szPluginCache[]));

            ESPluginContext context;
            ESPluginContexts.GetArray(g_szPluginCache[param1], context, sizeof(context));
            PluginContextInfoMenu(param1, context);
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                MainMenu(param1);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int PluginContextInfoMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Select:
        {
            char szInfo[2];
            menu.GetItem(param2, szInfo, sizeof(szInfo));

            ESPluginContext context;
            ESPluginContexts.GetArray(g_szPluginCache[param1], context, sizeof(context));

            switch(StringToInt(szInfo))
            {
                case Action_Install:
                {
                    LogMsg(Debug, "Downloading plugin files...");
                    SetupLoadingMenu(param1, "Downloading plugin files...");
                    context.Download(param1);
                }
                case Action_Source: PrintToChat(param1, " \x0Bhttps://github.com/%s", context.Repository);
                case Action_License: PrintToChat(param1, " \x04https://github.com/%s/blob/main/LICENSE", context.Repository);
                case Action_Manage: SetupLoadingMenu(param1, _, DelayedPluginFrame, PluginInfoMenu);
            }
        }

        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                AvailablePluginsMenu(param1);
            }
        }

        case MenuAction_End: delete menu;
    }
}

public int NullMenuHandler(Menu menu, MenuAction menuAction, int param1, int param2)
{
    switch(menuAction)
    {
        case MenuAction_Cancel:
        {
            if(param2 == MenuCancel_ExitBack)
            {
                MainMenu(param1);
            }
        }

        case MenuAction_End: delete menu;
    }
}