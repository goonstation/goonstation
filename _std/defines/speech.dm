#define NEWSPEECH 1 //turns on the new speech system for all things - undef to disable

// Bitflags and defines related to say()
//channel defines
#define SAY_CHANNEL_OUTLOUD "outloud"
#define SAY_CHANNEL_EQUIPPED "equipped"
#define SAY_CHANNEL_DEAD "deadchat"
#define SAY_CHANNEL_RADIO_PREFIX "radio_" // to use like SAY_CHANNEL_RADIO_PREFIX + "135.7"
#define SAY_CHANNEL_GHOST "ghost"
#define SAY_CHANNEL_BLOB "blob"

// say_message flags
// bitflags for different singing modifiers, used so that effects can be combined if desired
#define SAYFLAG_SINGING 1
#define SAYFLAG_LOUD_SINGING 2
#define SAYFLAG_SOFT_SINGING 4
#define SAYFLAG_BAD_SINGING 8
#define SAYFLAG_RADIO_SENT 16 //message has already been transmitted over radio

//REMOVE THESE
#define LOUD_SINGING SAYFLAG_LOUD_SINGING
#define SOFT_SINGING SAYFLAG_SOFT_SINGING
#define BAD_SINGING SAYFLAG_BAD_SINGING
