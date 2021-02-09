enum struct ESPluginContext
{
    int         VersionInt;
    char        FileName[MAX_PLUGIN_FILEPATH_LENGTH];
    char        Name[MAX_PLUGIN_NAME_LENTGH];
    char        Version[6];
    char        Description[MAX_DESCRIPTION_LENGTH];
    char        Author[MAX_AUTHOR_LENGTH];
    char        Repository[GITHUB_REPOSITORY_LENGTH];
    StringMap   Files;
    StringMap   Dependencies;

    /**
    * Release context handles.
    *
    * @noreturn
    **/
    void Dispose()
    {
        delete this.Files;
        delete this.Dependencies;
    }

    /**
    * Download the plugin files.
    *
    * @param client     Client index who started the download phase.
    *
    * @noreturn
    **/
    void Download(int client)
    {
        if(this.Files == INVALID_HANDLE)
            return;

        StringMapSnapshot Keys = this.Files.Snapshot();

        char szUrl[PLATFORM_MAX_PATH];
        char szPath[PLATFORM_MAX_PATH];
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szUrl, sizeof(szUrl));

            this.Files.GetString(szUrl, szPath, sizeof(szPath));
            DownloadFile(szUrl, szPath, client, i == Keys.Length - 1);
        }

        delete Keys;
    }

    /**
    * Delete the plugin files.
    *
    * @noreturn
    **/
    void Delete()
    {
        if(this.Files == INVALID_HANDLE)
            return;

        StringMapSnapshot Keys = this.Files.Snapshot();

        char szUrl[PLATFORM_MAX_PATH];
        char szPath[PLATFORM_MAX_PATH];
        for(int i = 0; i < Keys.Length; i++)
        {
            Keys.GetKey(i, szUrl, sizeof(szUrl));

            this.Files.GetString(szUrl, szPath, sizeof(szPath));

            if(FileExists(szPath))
                DeleteFile(szPath);
        }

        delete Keys;
    }

    /**
    * Create ESPlugin from ESPluginContext
    * ESPlugin 'instance' is not always a valid & running plugin.
    *
    * @param output     ESPlugin variable that will be edited.
    *
    * @noreturn
    **/
    void ToPlugin(ESPlugin output)
    {
        output.PluginHandle = INVALID_HANDLE;
        output.FileName = this.FileName;
        output.Name = this.Name;
        output.Description = this.Description;
        output.Author = this.Author;
        output.Version = this.Version;
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
}