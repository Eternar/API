enum struct ESPlugin
{
    Handle      PluginHandle;
    char        FileName[MAX_PLUGIN_FILEPATH_LENGTH];
    char        Name[MAX_PLUGIN_NAME_LENTGH];
    char        Description[MAX_DESCRIPTION_LENGTH];
    char        Author[MAX_AUTHOR_LENGTH];
    char        Url[GITHUB_REPOSITORY_LENGTH];
    char        Version[6];

    /**
    * Initialize this 'instance'.
    *
    * @param plugin     Plugin handle.
    *
    * @noreturn
    **/
    void Init(Handle plugin)
    {
        this.PluginHandle = plugin;
        GetPluginFilename(plugin,                   this.FileName,      sizeof(ESPlugin::FileName));
	    GetPluginInfo(plugin, PlInfo_Name, 			this.Name, 		    sizeof(ESPlugin::Name));
	    GetPluginInfo(plugin, PlInfo_Author, 		this.Author, 		sizeof(ESPlugin::Author));
	    GetPluginInfo(plugin, PlInfo_Description, 	this.Description, 	sizeof(ESPlugin::Description));
	    GetPluginInfo(plugin, PlInfo_Version, 		this.Version, 		sizeof(ESPlugin::Version));
	    GetPluginInfo(plugin, PlInfo_URL, 			this.Url, 			sizeof(ESPlugin::Url));
    }

    /**
    * Release handle.
    *
    * @noreturn
    **/
    void Dispose()
    {
        delete this.PluginHandle;
    }

    /* Wrapper Functions */

    /**
    * Delete plugin file.
    *
    * @return   True on success, false on failure or if file not immediately removed.
    **/
    bool Delete()
    {
        if(!this.FileName[0] || !this.Exists())
            return false;

        return DeletePlugin(this.FileName);
    }

    /**
    * Reload the plugin.
    *
    * @noreturn
    **/
    void Reload()
    {
        ManagePlugin(this.FileName, "reload");
    }

    /**
    * Unload the plugin.
    *
    * @noreturn
    **/
    void Unload()
    {
        this.Dispose();
        ManagePlugin(this.FileName, "unload");
    }

    /**
    * Load the plugin.
    *
    * @noreturn
    **/
    void Load()
    {
        ManagePlugin(this.FileName, "load");
    }

    /**
    * Checks whether the plugin is valid and running.
    *
    * @return   True if the plugin is valid and running, false otherwise
    **/
    bool IsValid()
    {
        return IsValidPlugin(this.PluginHandle);
    }

    /**
    * Checks whether the plugin file is exists or not.
    *
    * @return   True if the plugin is exists, false otherwise.
    **/
    bool Exists()
    {
        return PluginExists(this.FileName);
    }

    /**
    * Returns the current plugin status.
    *
    * @return   https://github.com/alliedmodders/sourcemod/blob/b14c18ee64fc822dd6b0f5baea87226d59707d5a/public/IPluginSys.h#L66-L106
    **/
    PluginStatus GetStatus()
    {
        return GetPluginStatus(this.PluginHandle);
    }
}