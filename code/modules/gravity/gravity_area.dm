/// Minimum gravity for the area.
/area/var/gforce_minimum = 100
/// Total G-Force added by Gravity Tethers.
/area/var/gforce_tether = 0
/// Turfs check against this rev number when updating gravity
/area/var/gforce_rev = 1

/// Updating an area's gforce minimum; e.g. docked traders and shuttles
/area/proc/set_gforce_minimum(new_gforce)
	src.gforce_minimum = new_gforce
	gforce_rev += 1

/area/proc/change_gforce_tether(gforce_diff)
	src.gforce_tether += gforce_diff
	gforce_rev += 1

// static area minimums
// NOTE: gravity initialization also zeros out any gravity tether-linked areas before the game starts!

/area/space/gforce_minimum = 0
/area/noGenerate/gforce_minimum = 0
/area/allowGenerate/gforce_minimum = 0
/area/abandonedship/gforce_minimum = 0
/area/abandonedmedicalship/gforce_minimum = 0
/area/abandonedmedicalship/robot_trader/gforce_minimum = 100 // TODO: Move D.O.C. area to an ISS subtype
/area/fermid_hive/gforce_minimum = 0
