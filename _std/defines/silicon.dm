// Cyborg death alert message modifiers for use in borg_death_alert()
#define ROBOT_DEATH_MOD_NONE 0 //!standard death alert
#define ROBOT_DEATH_MOD_SUICIDE 1 //!suicide death alert
#define ROBOT_DEATH_MOD_KILLSWITCH 2 //!killswitch death alert


// Special-case limb movement modifiers
/// Additive slowdown added dur to a missing leg
#define ROBOT_MISSING_LEG_MOVEMENT_ADJUST 3.5
/// Amount an arm on the same side as a missing leg will offset the missing leg penalty
#define ROBOT_MISSING_LEG_ARM_OFFSET -1
/// Amount a missing arm will speed you up (as long as you have legs)
#define ROBOT_MISSING_ARM_MOVEMENT_ADJUST -0.1

/// Amount of time between using a state laws command
#define STATE_LAW_COOLDOWN 20 SECONDS

/// Cell power remaining before the low power distress effect occurs
#define ROBOT_BATTERY_DISTRESS_THRESHOLD 100

/// Cyborg killswitch timer duration
#define ROBOT_KILLSWITCH_DURATION 1 MINUTE
/// AI killswitch timer duration
#define AI_KILLSWITCH_DURATION 3 MINUTES

/// Cyborg lockdown timer duration
#define ROBOT_LOCKDOWN_DURATION 2 MINUTES

/// Cannot use an upgrade because the robot is locked-down or otherwise disabled
#define ROBOT_UPGRADE_FAIL_DISABLED 1
/// Cannot use an upgrade because the robot is out of power
#define ROBOT_UPGRADE_FAIL_LOW_POWER 2
