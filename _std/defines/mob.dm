//various mob_flags go here
/// For mobs who can hear everything (mainly observer ghossts)
#define MOB_HEARS_ALL 1
// God Ecaps
#define SPEECH_REVERSE 2
#define SPEECH_BLOB 4		//yes
#define SEE_THRU_CAMERAS 8	//for ai eye
#define IS_BONER 16			//for skeletals
#define UNUSED_32 32
#define UNUSED_64 64
#define UNUSED_128 128
#define UNUSED_256 256
#define UNUSED_512 512
#define AT_GUNPOINT 1024 	//quick check for guns holding me at gunpoint
#define IGNORE_SHIFT_CLICK_MODIFIER 2048 //shift+click doesn't retrigger a SHIFT keypress - use for mobs that sprint on shift and not on mobs that use shfit for bolting doors etc
#define LIGHTWEIGHT_AI_MOB 4096		//not a part of the normal 'mobs' list so it wont show up in searches for observe admin etc, has its own slowed update rate on Life() etc
#define USR_DIALOG_UPDATES_RANGE 8192	//updateusrdialog will consider this mob as being able to 'attack_ai' and update its ui at range
#define MAT_TRIGGER_LIFE 16384 //do some extra shit in life to trigger mats onlife
#define SHOULD_HAVE_A_TAIL 32768 //Would we miss our tail if it comes off?

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

// ---- mob damage ----

/**
	* How many rads after resistances before it actually does anything.
	*
	* Example: This is set to 3, someone takes rad damage that is reduced to 2 by resistances. Nothing happens as its below the min. of 3.
	*/
#define MIN_EFFECTIVE_RAD 3
/// Higher values result in more external fire damage to the skin
#define FIRE_DAMAGE_MODIFIER 0.0215
/// More means less damage from hot air scalding lungs, less = more damage.
#define AIR_DAMAGE_MODIFIER 2.025

/// Burning Lv1 starts at this duration.
#define BURNING_LV1 0
/// Burning Lv2 starts at this duration.
#define BURNING_LV2 200
/// Burning Lv3 starts at this duration.
#define BURNING_LV3 400

//hearing
#define HEARING_NORMAL 0
#define HEARING_BLOCKED 1
/// cures deafness when worn
#define HEARING_ANTIDEAF -1 // w h a t the fuck is an anti deaf

//cooldowns
#define REST_TOGGLE_COOLDOWN 0.1 SECONDS
#define EAT_COOLDOWN 0.5 SECONDS
