//various mob_flags go here
#define MOB_HEARS_ALL 1 	//For mobs who can hear everything (mainly observer ghossts)
#define SPEECH_REVERSE 2 	//God Ecaps
#define SPEECH_BLOB 4		//yes
#define SEE_THRU_CAMERAS 8	//for ai eye
#define IS_BONER 16			//for skeletals
#define IS_RELIQUARY 32 //for Azungar's reliquary stuff
#define IS_RELIQUARY_SOLDIER 64 //for Azungar's reliquary stuff
#define IS_RELIQUARY_GUARDIAN 128 //for Azungar's reliquary stuff
#define IS_RELIQUARY_TECHNICIAN 256 //for Azungar's reliquary stuff
#define IS_RELIQUARY_CURATOR 512 //for Azungar's reliquary stuff
#define AT_GUNPOINT 1024 	//quick check for guns holding me at gunpoint
#define IGNORE_SHIFT_CLICK_MODIFIER 2048 //shift+click doesn't retrigger a SHIFT keypress - use for mobs that sprint on shift and not on mobs that use shfit for bolting doors etc
#define LIGHTWEIGHT_AI_MOB 4096		//not a part of the normal 'mobs' list so it wont show up in searches for observe admin etc, has its own slowed update rate on Life() etc
#define USR_DIALOG_UPDATES_RANGE 8192	//updateusrdialog will consider this mob as being able to 'attack_ai' and update its ui at range
#define MAT_TRIGGER_LIFE 16384 //do some extra shit in life to trigger mats onlife

//mob intent type defines
#define INTENT_HARM "harm"
#define INTENT_DISARM "disarm"
#define INTENT_HELP "help"
#define INTENT_GRAB "grab"

//missing limb flags
#define LIMB_LEFT_ARM 1
#define LIMB_RIGHT_ARM 2
#define LIMB_LEFT_LEG 4
#define LIMB_RIGHT_LEG 8

//mob damage
#define MIN_EFFECTIVE_RAD 3 //How many rads after resistances before it actually does anything. Example: This is set to 3, someone takes rad damage that is reduced to 2 by resistances. Nothing happens as its below the min. of 3.
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)

#define BURNING_LV1 0   //Lv1 starts at this duration.
#define BURNING_LV2 200 //Lv2 ^^
#define BURNING_LV3 400 //Lv3 ^^

//hearing
#define HEARING_NORMAL 0
#define HEARING_BLOCKED 1
#define HEARING_ANTIDEAF -1 //what the fuck is an anti deaf
