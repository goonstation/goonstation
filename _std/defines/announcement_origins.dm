#define ALERT_WATCHFUL_EYE "Watchful-Eye Sensor Array Update" //Weather(if not oshan) + Headrev tracker
#define ALERT_EGERIA_PROVIDENCE "Egeria Providence Array Broadcast" //Viva la revolution!

#if defined(MAP_OVERRIDE_OSHAN) || defined(MAP_OVERRIDE_NEON)
	#define ALERT_ANOMALY "Ersetu Trench Anomaly Detection"
	#define ALERT_WEATHER "Abzu Treaty Weather Station Alert"
#else
	#define ALERT_ANOMALY "LRAD Anomaly Detector Alert"
	#define ALERT_WEATHER ALERT_WATCHFUL_EYE
#endif
#define ALERT_GENERAL "Frontier Authority Update"
#define ALERT_STATION "Automated Mainframe Alert"

// used to style player-made announcements; the titles don't actually show in-game
#define ALERT_DEPARTMENT "Department Announcement"
#define ALERT_COMMAND "Command Announcement"
#define ALERT_CLOWN "Clownuncement"
#define ALERT_SYNDICATE "Syndicate Announcement"

#define ALERT_GENERAL_CLASS "ageneral"
#define ALERT_ANOMALY_CLASS "aanomaly"
#define ALERT_WEATHER_CLASS "aweather"
#define ALERT_STATION_CLASS "astation"
#define ALERT_WATCHFUL_EYE_CLASS "awatchful"
#define ALERT_EGERIA_CLASS "aegeria"
#define ALERT_DEPARTMENT_CLASS "adept"
#define ALERT_COMMAND_CLASS "acomm"
#define ALERT_CLOWN_CLASS "aclown"
#define ALERT_SYNDICATE_CLASS "asyn"
