/// Areas on the station Z that are outside the station
///
/// The station gravity tether will not apply to these areas.
var/global/list/z_level_station_outside_area_types = list(
	// areas that are space
	/area/supply,
	/area/mining/magnet, // TODO: This area shouldn't be used on maps :S

	// common near-station areas
	/area/station/turret_protected/armory_outside,
	/area/station/turret_protected/AIbaseoutside,
	/area/station/solar,
	/area/station/catwalk,
	/area/station/com_dish,
	/area/station/shield_zone,

	// generally unconnected to station
	/area/station/science/testchamber/bombchamber,
)

/// Base gravity to apply to an area. By default, all areas have Earth gravity
/area/var/base_gravity = 1
/// Current amount of gravity in the area (in G)
/area/var/gravity_force = 1

/area/space/base_gravity = 0

// z3 derliects
/area/abandonedship/base_gravity = 0
/area/abandonedmedicalship/base_gravity = 0
/area/abandonedmedicalship/robot_trader/base_gravity = 1 // for D.O.C., who is in the ISS and not the abandoned medical ship
/area/fermid_hive/base_gravity = 0

/area/New()
	. = ..()
	src.gravity_force = src.base_gravity

/// Update the gravity of a given area. Returns the newly calculated gravity value.
/area/proc/update_gravity()
	. = src.base_gravity

	for (var/obj/machinery/gravity_tether/tether in by_cat[TR_CAT_GRAVITY_TETHERS])
		for (var/area/A in tether.target_area_refs)
			if (src == A)
				. += tether.intensity

	if (. != src.gravity_force)
		src.gravity_force = .
		src.set_turf_gravity(src.gravity_force)

/// Set the gravity of all turfs in a given area to the given value
/area/proc/set_turf_gravity(gforce)
	for (var/turf/T in get_area_turfs(src))
		T.set_gravity(gforce)

/// Recalculate gravity in an area
/area/proc/recalculate_gravity(apply=FALSE)
	var/new_gravity = src.base_gravity
	for (var/obj/machinery/gravity_tether/tether in src.registered_tethers)
		if (tether.is_disabled())
			continue
		new_gravity += tether.intensity
	if (apply && (new_gravity != src.gravity_force))
		src.set_turf_gravity(src.gravity_force)
	return src.gravity_force

/area/var/list/obj/machinery/gravity_tether/registered_tethers = list()

/area/proc/register_tether(obj/machinery/gravity_tether/tether)
	src.registered_tethers.Add(tether)
	src.recalculate_gravity()

/area/proc/unregister_tether(obj/machinery/gravity_tether/tether)
	src.registered_tethers.Remove(tether)
	src.recalculate_gravity()

// TODO: Shuttle Controller should control these

/area/shuttle/escape/station/base_gravity = 0
/area/shuttle/escape/transit/base_gravity = 0

// TODO: Shuttle computers should control these

/area/shuttle/research/station/base_gravity = 0

/area/shuttle/asylum/medbay/base_gravity = 0
/area/shuttle/asylum/pathology/base_gravity = 0

/area/shuttle/mining/station/base_gravity = 0
/area/shuttle/mining/outpost/base_gravity = 0

/area/shuttle/john/grillnasium/base_gravity = 0
/area/shuttle/john/diner/base_gravity = 0
