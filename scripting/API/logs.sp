stock void LogMsg(const LogLevel logLevel = Debug, const char[] szMessage, any ...)
{
    if(view_as<int>(logLevel) < g_iLogLevel)
        return;

	static char szBuffer[512];
	VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);

	static char levelFormat[12];
	LevelString(logLevel, levelFormat, sizeof(levelFormat));
	Format(szBuffer, sizeof(szBuffer), "[%s] %s", levelFormat, szBuffer);
	LogToFile(g_szLogFile, szBuffer);
}

static stock void LevelString(const LogLevel level, char[] output, int size)
{
	switch(level)
	{
		case Debug:		strcopy(output, size, "DEBUG");
		case Info:		strcopy(output, size, "INFO");
		case Warning:	strcopy(output, size, "WARNING");
		case Error:		strcopy(output, size, "ERROR");
		case Critical:	strcopy(output, size, "CRITICAL");
	}
}