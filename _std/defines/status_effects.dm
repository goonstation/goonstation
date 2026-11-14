
/// For status effects. This is just for clarity. Null-duration statuses are defined as infinite duration.
#define INFINITE_STATUS null

// Qualities
/// Effect is good (stamina/health buffs, stat buffs)
#define STATUS_QUALITY_POSITIVE 1

/// Effect is bad (stamina/health debuffs, stat debuffs)
#define STATUS_QUALITY_NEGATIVE 2

/// Misc stuff which isn't inherently good or bad
#define STATUS_QUALITY_NEUTRAL 3

/// This contains of part_strings where a corresponding numb-status effect exists
var/global/list/numb_body_part_list =  list("r_arm" = "numb_r_arm", "l_arm" = "numb_l_arm", "l_leg" = "numb_l_leg", "r_leg" = "numb_r_leg",)
