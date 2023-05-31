#define NEWSPEECH 1 //turns on the new speech system for all things - undef to disable

// Bitflags and defines related to say()
//channel defines
#define SAY_CHANNEL_OUTLOUD "outloud"
#define SAY_CHANNEL_EQUIPPED "equipped"

// to use like SAY_CHANNEL_RADIO_PREFIX + "135.7"
#define SAY_CHANNEL_RADIO_PREFIX "radio_"
#define SAY_CHANNEL_GHOST "ghost"
#define SAY_CHANNEL_BLOB "blob"

// say_message flags
// bitflags for different singing modifiers, used so that effects can be combined if desired
#define NORMAL_SINGING 1
#define LOUD_SINGING 2
#define SOFT_SINGING 4
#define BAD_SINGING 8
#define RADIO_SENT 16 //message has already been transmitted over radio
