/datum/map_correctness_check/decarabia_only
	check_name = "Decarabia-Only Objects"

/datum/map_correctness_check/decarabia_only/run_check()
	. = list()
	var/blacklist_types = list(
		/turf/simulated/wall/auto/walp,
		/turf/simulated/wall/auto/reinforced/walp,
		/obj/window/auto/walp,
		/obj/window/auto/reinforced/walp,
		/obj/window/auto/crystal/walp,
		/obj/window/auto/crystal/reinforced/walp,
		/obj/machinery/door/airlock/walp,
	)

	for (var/type as anything in blacklist_types)
		for (var/atom/A as anything in global.by_type[type])
			if ((A.z == Z_LEVEL_STATION) && istype(global.map_settings, /datum/map_settings/decarabia))
				continue

			. += src.format_position(A)


SET_UP_CI_TRACKING_TURF(/turf/simulated/wall/auto/walp)
SET_UP_CI_TRACKING_TURF(/turf/simulated/wall/auto/reinforced/walp)
SET_UP_CI_TRACKING(/obj/window/auto/walp)
SET_UP_CI_TRACKING(/obj/window/auto/reinforced/walp)
SET_UP_CI_TRACKING(/obj/window/auto/crystal/walp)
SET_UP_CI_TRACKING(/obj/window/auto/crystal/reinforced/walp)
SET_UP_CI_TRACKING(/obj/machinery/door/airlock/walp)
