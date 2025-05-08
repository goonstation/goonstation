//various mob_flags go here
// God Ecaps

#define SEE_THRU_CAMERAS (1 << 3)	//for ai eye
#define IS_BONEY (1 << 4)			//for skeletals
#define UNUSED_32 (1 << 5)
#define UNUSED_64 (1 << 6)
#define UNUSED_128 (1 << 7)
#define UNUSED_256 (1 << 8)
#define UNUSED_512 (1 << 9)

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

//hand values
#define LEFT_HAND 1
#define RIGHT_HAND 0

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
#define BURNING_LV2 30 SECONDS
/// Burning Lv3 starts at this duration.
#define BURNING_LV3 60 SECONDS

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
#define SKIPPED_STAMINA_MOBS (1 << 2)

// decomp_stage defines
#define DECOMP_STAGE_NO_ROT 0
#define DECOMP_STAGE_BLOATED 1
#define DECOMP_STAGE_DECAYED 2
#define DECOMP_STAGE_HIGHLY_DECAYED 3
#define DECOMP_STAGE_SKELETONIZED 4

// Stat defines
#define STAT_ALIVE 0
#define STAT_UNCONSCIOUS 1
#define STAT_DEAD 2

// Butchering defines
#define BUTCHER_NOT_ALLOWED 0
#define BUTCHER_ALLOWED 1
/// Extra "WHAT A MONSTER" message on butchering
#define BUTCHER_YOU_MONSTER 2

//idk where else to put this
#define DEFAULT_MIRANDA "You have the right to remain silent. Anything you say can and will be used against you in a NanoTrasen court of Space Law. You have the right to a rent-an-attorney. If you cannot afford one, a monkey in a suit and funny hat will be appointed to you."
