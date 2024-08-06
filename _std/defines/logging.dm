/// Thresholds for admin logs & other log stuff.
#define LOG_FLUSHING_THRESHOLD 1000

// logTheThing defines
#define LOG_ACCESS "access"			//! Diary only
#define LOG_ADMIN "admin"			//! Admin actions
#define LOG_AHELP "ahelp"			//! Ahelps and admin responses
#define LOG_AUDIT "audit"			//! Admin auditing stuff
#define LOG_BOMBING "bombing"		//! Explosions
#define LOG_COMBAT "combat"			//! People fighting or smashing shit
#define LOG_DEBUG "debug"			//! Debug information
#define LOG_DIARY "diary"			//! Diary
#define LOG_GAME "game"				//! Diary only
#define LOG_MHELP "mhelp"			//! Used for diary too
#define LOG_OOC "ooc"				//! OOC
#define LOG_PDAMSG "pdamsg"			//! PDA messaging
#define LOG_SAY "say"				//! IC Speech
#define LOG_SPEECH "speech"			//! Ingame logs only, say + whisper
#define LOG_SIGNALERS "signalers"	//! Remote signallers
#define LOG_STATION "station"		//! Interactions with/between inanimate objects, as well as the station as a whole
#define LOG_TELEPATHY "telepathy"	//! Telepathy gene messages
#define LOG_VEHICLE "vehicle"		//! Vehicle stuff
#define LOG_WHISPER "whisper"		//! Whisper messages
#define LOG_TOPIC "topic"			//! Topic() logs
#define LOG_GAMEMODE "gamemode"		//! Core gamemode stuff like game mode selection, blob starts, flock planting, etc
#define LOG_CHEMISTRY "chemistry" 	//! Non-combat chemistry interactions
#define LOG_TGUI "tgui" 			//! TGUI interactions

//#undef Z_LOG_DEBUG
//#define Z_LOG_DEBUG(WHAT, X) do{if(config){logTheThing(LOG_DEBUG, null, "Z_LOG_DEBUG: [WHAT] - [X]")}}while(FALSE)
