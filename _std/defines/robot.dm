
// Borg death alert message modifiers for use in borg_death_alert()

#define ROBOT_DEATH_MOD_NONE 0 //standard death alert
#define ROBOT_DEATH_MOD_SUICIDE 1 //suicide death alert
#define ROBOT_DEATH_MOD_KILLSWITCH 2 //killswitch death alert


// Special-case limb movement modifiers
/// Additive slowdown added dur to a missing leg
#define ROBOT_MISSING_LEG_MOVEMENT_ADJUST 3.5
/// Amount an arm on the same side as a missing leg will offset the missing leg penalty
#define ROBOT_MISSING_LEG_ARM_OFFSET -1
/// Amount a missing arm will speed you up (as long as you have legs)
#define ROBOT_MISSING_ARM_MOVEMENT_ADJUST -0.1

/// Cell power remaining before the low power distress effect occurs
#define ROBOT_BATTERY_DISTRESS_THRESHOLD 100
