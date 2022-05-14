//various mob_flags go here
/// For mobs who can hear everything (mainly observer ghossts)
#define MOB_HEARS_ALL 1
// God Ecaps
#define SPEECH_REVERSE (1 << 1)
#define SPEECH_BLOB (1 << 2)		//yes
#define SEE_THRU_CAMERAS (1 << 3)	//for ai eye
#define IS_BONEY (1 << 4)			//for skeletals
#define UNUSED_32 (1 << 5)
#define UNUSED_64 (1 << 6)
#define UNUSED_128 (1 << 7)
#define UNUSED_256 (1 << 8)
#define UNUSED_512 (1 << 9)
#define AT_GUNPOINT (1 << 10) 	//quick check for guns holding me at gunpoint
#define IGNORE_SHIFT_CLICK_MODIFIER (1 << 11) //shift+click doesn't retrigger a SHIFT keypress - use for mobs that sprint on shift and not on mobs that use shfit for bolting doors etc
#define LIGHTWEIGHT_AI_MOB (1 << 12)		//not a part of the normal 'mobs' list so it wont show up in searches for observe admin etc, has its own slowed update rate on Life() etc
#define USR_DIALOG_UPDATES_RANGE (1 << 13)	//updateusrdialog will consider this mob as being able to 'attack_ai' and update its ui at range
#define UNUSED_16384 (1 << 14)
#define SHOULD_HAVE_A_TAIL (1 << 15) //Would we miss our tail if it comes off?
#define HEAVYWEIGHT_AI_MOB (1 << 16) //ai gets ticked every 0.2 seconds instead of the usual 1 seconds - gotta go fast

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

//skipped_mobs_list flags
#define SKIPPED_MOBS_LIST (1 << 0)
#define SKIPPED_AI_MOBS_LIST (1 << 1)
