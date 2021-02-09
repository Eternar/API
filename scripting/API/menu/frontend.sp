public void MainMenu(int client)
{
    Menu menu = new Menu(MainMenuHandler);
    menu.SetTitle("Eternar Projects\nPlugin Manager | Version: %s\n \nMain Menu", API_VERSION);
    
    char szTemp[128];
    Format(szTemp, sizeof(szTemp), "Available Plugins (x%i)", ESPluginContexts.Size);
    menu.AddItem("0", szTemp, ESPluginContexts.Size == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    Format(szTemp, sizeof(szTemp), "Installed Plugins (x%i)\n ", ESPlugins.Size);
    menu.AddItem("1", szTemp, ESPlugins.Size == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    menu.AddItem("2", "Developers & Contributors");
    menu.Display(client, MENU_TIME_FOREVER);
}

public void DevelopersMenu(int client)
{
    Menu menu = new Menu(DevelopersMenuHandler);
    menu.SetTitle("Eternar Projects\nPlugin Manager | Version: %s\n \nDevelopers", API_VERSION);
    menu.AddItem("Eternar", "Organization (Eternar)\n ");
    menu.AddItem("KillStr3aK", "KillStr3aK (Nexd)");
    menu.AddItem("Demenytomi", "Demenytomi (DemT)");
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public void InstalledPluginList(int client)
{
    Menu menu = new Menu(InstalledPluginListHandler);
    menu.SetTitle("Eternar Projects\nPlugin Manager | Version: %s\n \nInstalled Plugins", API_VERSION);
    
    StringMapSnapshot Keys = ESPlugins.Snapshot();
    char szBuffer[MAX_PLUGIN_FILEPATH_LENGTH];
    for(int i = 0; i < Keys.Length; i++)
    {
        Keys.GetKey(i, szBuffer, sizeof(szBuffer));

        ESPlugin PluginContext;
        if(ESPlugins.GetArray(szBuffer, PluginContext, sizeof(PluginContext)))
        {
            menu.AddItem(PluginContext.FileName, PluginContext.Name);
        }
    }

    if(menu.ItemCount == 0)
        menu.AddItem(NULL_STRING, "No plugin installed", ITEMDRAW_DISABLED);

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    delete Keys;
}

public void PluginInfoMenu(int client, /*const */ESPlugin plugin)
{
    Menu menu = new Menu(PluginInfoMenuHandler);
    menu.SetTitle("Eternar Projects\nPlugin Manager | Version: %s\n \nPlugin Info: %s\nFile Name: %s\nDescription: %s\nAuthor: %s\nVersion: %s\n ", API_VERSION, plugin.Name, plugin.FileName, plugin.Description, plugin.Author, plugin.Version);

    if(plugin.Exists())
    {
        if(plugin.IsValid())
        {
            menu.AddItem("0", "Unload");
            menu.AddItem("1", "Reload\n ");
        } else menu.AddItem("4", "Load\n ");

        menu.AddItem("2", "Update");
        menu.AddItem("3", "Delete");
    } else menu.AddItem(NULL_STRING, "File not found", ITEMDRAW_DISABLED);
    
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public void LoadingMenu(int client, const char[] msg)
{
    Menu menu = new Menu(NullMenuHandler);
    menu.SetTitle("Eternar Projects\nPlugin Manager | Version: %s\n \n%s", API_VERSION, msg);
    menu.AddItem(NULL_STRING, NULL_STRING, ITEMDRAW_SPACER);
    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}

public void AvailablePluginsMenu(int client)
{
    StringMapSnapshot Keys = ESPluginContexts.Snapshot();
    Menu menu = new Menu(AvailablePluginsMenuHandler);
    menu.SetTitle("Eternar Projects\nPlugin Manager | Version: %s\n \nAvailable Plugins", API_VERSION);

    char szBuffer[MAX_PLUGIN_FILEPATH_LENGTH];
    for(int i = 0; i < Keys.Length; i++)
    {
        Keys.GetKey(i, szBuffer, sizeof(szBuffer));

        ESPluginContext context;
        if(ESPluginContexts.GetArray(szBuffer, context, sizeof(context)))
        {
            menu.AddItem(context.FileName, context.Name);
        }
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
    delete Keys;
}

public void PluginContextInfoMenu(int client, /*const */ESPluginContext PluginContext)
{
    Menu menu = new Menu(PluginContextInfoMenuHandler);
    menu.SetTitle("Eternar Projects\nPlugin Manager | Version: %s\n \nPlugin Info: %s\nRepository: %s\nDescription: %s\nAuthor: %s\nVersion: %s\n ", API_VERSION, PluginContext.Name, PluginContext.Repository, PluginContext.Description, PluginContext.Author, PluginContext.Version);

    bool bInstalled = PluginContext.Exists();

    if(!bInstalled)
    {
        char szTemp[128];
        Format(szTemp, sizeof(szTemp), "Dependencies:\n");

        bool bHasDependencies = true;

        if(PluginContext.Dependencies != INVALID_HANDLE)
        {
            StringMapSnapshot Keys = PluginContext.Dependencies.Snapshot();
            int installedDependencies = 0;

            for(int i = 0; i < Keys.Length; i++)
            {
                static char szBuffer[MAX_PLUGIN_NAME_LENTGH];
                Keys.GetKey(i, szBuffer, sizeof(szBuffer));

                static char szPath[PLATFORM_MAX_PATH];
                PluginContext.Dependencies.GetString(szBuffer, szPath, sizeof(szPath));

                bool bDependencyInstalled = FileExists(szPath);
                if(bDependencyInstalled)
                    ++installedDependencies;

                Format(szTemp, sizeof(szTemp), "%s- %s [%s]%s\n", szTemp, szBuffer, bDependencyInstalled ? "✓" : "X", i == Keys.Length - 1 ? "\n " : NULL_STRING);
            }

            if(installedDependencies != Keys.Length)
                bHasDependencies = false;

            delete Keys;
        } else Format(szTemp, sizeof(szTemp), "%sThis plugin has no dependencies!\n ", szTemp);

        menu.AddItem(NULL_STRING, szTemp, ITEMDRAW_DISABLED);
        menu.AddItem("0", "Install", bHasDependencies ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    } else menu.AddItem("3", "Manage");

    if(!bInstalled)
    {
        menu.AddItem("1", "Source files");
        menu.AddItem("2", "License\n \n ");
        menu.AddItem(NULL_STRING, "*By installing this plugin you accept\nthe license agreement conditions", ITEMDRAW_DISABLED);
    }

    menu.ExitBackButton = true;
    menu.Display(client, MENU_TIME_FOREVER);
}