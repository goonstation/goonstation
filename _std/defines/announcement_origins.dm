#define ALERT_WATCHFUL_EYE "Watchful-Eye Sensor Array Update" //Weather(if not oshan) + Headrev tracker
#define ALERT_EGERIA_PROVIDENCE "Egeria Providence Array Broadcast" //Viva la revolution!

#ifdef MAP_OVERRIDE_OSHAN
	#define ALERT_ANOMALY "Ersetu Trench Anomaly Detection"
	#define ALERT_WEATHER "Abzu Treaty Weather Station Alert"
#else
	#define ALERT_ANOMALY "LRAD Anomaly Detector Alert"
	#define ALERT_WEATHER ALERT_WATCHFUL_EYE
#endif
#define ALERT_GENERAL "Frontier Authority Update"
#define ALERT_STATION "Automated Mainframe Alert"
