/* Plugin Header Directives */
#define API_VERSION  "1.0.0"
#define ETERNAR_API_VERSION 100000

#define ETERNAR_PACKAGES "https://raw.githubusercontent.com/Eternar/API/%s/plugin_list.cfg"
#define ETERNAR_PACKAGES_FILE "addons/sourcemod/configs/Eternar/packages.list"

/* Debug Directives */
#define DEBUG_MODE      1

/* Log Directives */
#define LOG_TIMEFORMAT  "%Y-%m-%d" // %Y-%m-%d_%H-%M
#define LOG_FILEFORMAT  "logs/Eternar/system_%s.log" /* Insufficient permission may cause errors */

#if DEBUG_MODE 1
    #define LOG_LEVEL   Debug
#else
    #define LOG_LEVEL   Warning
#endif

/* Pragma Directives */

#pragma tabsize 0;
#pragma newdecls required;
#pragma semicolon 1;