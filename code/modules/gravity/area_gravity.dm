/// Minimum gravity for the area.
/// Used
/area/var/gforce_minimum = 1
/// Total G-Force added by Gravity Tethers.
/area/var/gforce_tether = 0
/// G-Force added by z-level gravity
/area/var/gforce_zlevel = 0

/// Updating an area's gforce minimum; e.g. docked traders and shuttles
/area/proc/set_gforce_minimum(new_gforce)
	if (src.gforce_minimum == new_gforce)
		return
	src.gforce_minimum = new_gforce
	if (!src.z) // null areas :s
		return
	var/total_gforce = max(new_gforce, global.zlevels[src.z].gforce + src.gforce_tether)
	for (var/turf/T in src)
		T.gforce_current = round(max(0, total_gforce + T.gforce_inherent), 0.01)

// static area minimums
// NOTE: initialize_gravity() zeros out any tether-linked gravity areas on init

/area/space/gforce_minimum = 0
/area/noGenerate/gforce_minimum = 0
/area/allowGenerate/gforce_minimum = 0
/area/abandonedship/gforce_minimum = 0
/area/abandonedmedicalship/gforce_minimum = 0
/area/abandonedmedicalship/robot_trader/gforce_minimum = 1 // TODO: Move D.O.C. area to an ISS subtype
/area/fermid_hive/gforce_minimum = 0
