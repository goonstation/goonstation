#define COMBAT_BLOCK_DELAY (2)
#define COMBAT_CLICK_DELAY 10

//attack message flags
#define SUPPRESS_BASE_MESSAGE 1
#define SUPPRESS_SOUND 2
#define SUPPRESS_VISIBLE_MESSAGES 4
#define SUPPRESS_SHOWN_MESSAGES 8
#define SUPPRESS_LOGS 16

// used by limbs which make a special kind of melee attack happen
#define SUPPRESS_MELEE_LIMB 15

/// Regular old grab to pull someone
#define GRAB_PASSIVE 0
/// Special case grab for limbs which grab aggressively immediately, but don't want to pull the person to their tile like a neck grab would.
/// Most mobs skip this step entirely; only limbs which use it as a base use it at all.
#define GRAB_AGGRESSIVE 1
/// What's normally known as an 'aggressive' grab. Basically carrying someone.
#define GRAB_NECK 2
/// Choking someone.
#define GRAB_KILL 3
/// Pinned someone.
#define GRAB_PIN 4

// Ranged weapon melee damage values

#define MELEE_DMG_PISTOL 6
#define MELEE_DMG_REVOLVER 8
#define MELEE_DMG_SMG 8
#define MELEE_DMG_RIFLE 12
#define MELEE_DMG_LARGE 15
