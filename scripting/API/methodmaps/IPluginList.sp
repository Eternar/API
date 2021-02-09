methodmap IPluginList < StringMap
{
    public IPluginList()
    {
        return view_as<IPluginList>(new StringMap());
    }

    /**
    * Refresh plugin list.
    *
    * @noreturn
    **/
    public static void Refresh()
    {
        ServerCommand("sm_rcon sm plugins refresh");
    }
}