
#define MAP_SPAWN_SHUTTLE 1
#define MAP_SPAWN_CRYO 2
#define MAP_SPAWN_MISSILE 3

#define MAP_NAME_RANDOM 1

var/global/map_setting = null
var/global/datum/map_settings/map_settings = null

//id corresponds to the name of the /obj/landmark/map
//playerPickable defines whether the map can be chosen by players when voting on a new map.
var/global/list/mapNames = list(
	"Clarion" = 		list("id" = "CLARION", 		"settings" = "destiny/clarion", "playerPickable" = TRUE,		"MaxPlayersAllowed" = 80),
#ifdef RP_MODE
	"Cogmap 1" = 		list("id" = "COGMAP", 		"settings" = "cogmap", 			"playerPickable" = TRUE, 	"MinPlayersAllowed" = 14),
#else
	"Cogmap 1" = 		list("id" = "COGMAP", 		"settings" = "cogmap", 			"playerPickable" = TRUE,		"MaxPlayersAllowed" = 80),
#endif
	//"Construction" = list("id" = "CONSTRUCTION", "settings" = "construction"),
	"Cogmap 1 (Old)" = 	list("id" = "COGMAP_OLD", 	"settings" = "cogmap_old"),
	"Cogmap 2" = 		list("id" = "COGMAP2", 		"settings" = "cogmap2", 		"playerPickable" = TRUE, 	"MinPlayersAllowed" = 40),
	"Destiny" = 		list("id" = "DESTINY", 		"settings" = "destiny", 		"playerPickable" = TRUE,		"MaxPlayersAllowed" = 80),
	"Donut 2" = 		list("id" = "DONUT2", 		"settings" = "donut2",			"playerPickable" = TRUE,	"MaxPlayersAllowed" = 80),
	"Donut 3" = 		list("id" = "DONUT3", 		"settings" = "donut3",			"playerPickable" = TRUE, 	"MinPlayersAllowed" = 40),
	"Horizon" = 		list("id" = "HORIZON", 		"settings" = "horizon", 		"playerPickable" = FALSE),
	"Crash" = 			list("id" = "CRASH", 		"settings" = "horizon/crash", 		"playerPickable" = FALSE),
	"Mushroom" =		list("id" = "MUSHROOM", 	"settings" = "mushroom",		"playerPickable" = FALSE),
	"Trunkmap" = 		list("id" = "TRUNKMAP", 	"settings" = "trunkmap",		"playerPickable" = FALSE),
	"Oshan Laboratory"= list("id" = "OSHAN", 	"settings" = "oshan", 			"playerPickable" = TRUE),
	"1 pamgoC" = 		list("id" = "PAMGOC", 		"settings" = "pamgoc", 			"playerPickable" = FALSE),
	"Kondaru" = 		list("id" = "KONDARU", 		"settings" = "kondaru", 		"playerPickable" = TRUE,		"MaxPlayersAllowed" = 80),
	"Ozymandias" = 	list("id" = "OZYMANDIAS", "settings" = "ozymandias", 	"playerPickable" = FALSE, 	"MinPlayersAllowed" = 40),
	"Nadir" = 		list("id" = "NADIR", 		"settings" = "nadir", 		"playerPickable" = TRUE),
	"Bellerophon Fleet" = list("id" = "FLEET", "settings" = "fleet", "playerPickable" = FALSE),
	//"Density" = 		list("id" = "DENSITY", 	"settings" = "density", 			"playerPickable" = FALSE,	"MaxPlayersAllowed" = 30),
	"Atlas" = 			list("id" = "ATLAS", 		"settings" = "atlas", 				"playerPickable" = TRUE,				"MaxPlayersAllowed" = 30),
	"Manta" = 			list("id" = "MANTA", 		"settings" = "manta", 				"playerPickable" = FALSE,				"MaxPlayersAllowed" = 80),
	"Wrestlemap" = 			list("id" = "WRESTLEMAP", 	"settings" = "wrestlemap", 		"playerPickable" = FALSE),
	"pod_wars" = 			list("id" = "POD_WARS", 	"settings" = "pod_wars", 		"playerPickable" = FALSE),
	"Event" = 			list("id" = "EVENT", 		"settings" = "destiny/clarion", 		"playerPickable" = FALSE),
	"blank" = 			list("id" = "BLANK", "settings" = "", "playerPickable" = FALSE),
	"blank_underwater" =  list("id" = "BLANK_UNDERWATER", "settings" = "", "playerPickable" = FALSE)
)

/obj/landmark/map
	name = "map_setting"
	icon_state = "x3"
	add_to_landmarks = FALSE

	New()
		if (src.name != "map_setting")
			map_setting = src.name

			//find config in mapNames above
			for (var/map in mapNames)
				var/mapID = mapNames[map]["id"]

				if (mapID == map_setting)
					var/path = (mapNames[map]["settings"] == "") ? /datum/map_settings : text2path("/datum/map_settings/" + mapNames[map]["settings"])
					map_settings = new path
					break

			//Fallback for an unfound map. Should never occur!!
			if (!map_settings)
				map_settings = new /datum/map_settings
				CRASH("A mapName entry for '[src.name]' wasn't found!")
		..()

//Setting maps to be underwater is handled in the map config file, aka [mapname].dm

/datum/map_settings
	var/name = "MAP"
	var/display_name = MAP_NAME_RANDOM
	var/style = "station"
	var/default_gamemode = "secret"
	var/goonhub_map = "https://goonhub.com/maps/cogmap"
	var/arrivals_type = MAP_SPAWN_SHUTTLE
	var/dir_fore = null

	var/walls = /turf/simulated/wall/auto
	var/rwalls = /turf/simulated/wall/auto/reinforced
	var/auto_walls = TRUE

	var/windows = /obj/window
	var/windows_thin = /obj/window
	var/rwindows = /obj/window/reinforced
	var/rwindows_thin = /obj/window/reinforced
	var/windows_crystal = /obj/window/crystal
	var/windows_rcrystal = /obj/window/crystal/reinforced
	var/window_layer_full = null
	var/window_layer_north = null // cog2 panel windows need to go under stuff because ~perspective~
	var/window_layer_south = null
	var/auto_windows = FALSE

	var/ext_airlocks = /obj/machinery/door/airlock/external
	var/airlock_style = "gannets"

	var/escape_centcom = /area/shuttle/escape/centcom
	var/escape_transit = /area/shuttle/escape/transit
	var/escape_station = /area/shuttle/escape/station
	var/datum/allocated_region/transit_region
	var/escape_dir = SOUTH
	var/default_shuttle = null // null = auto, otherwise name of the dmm file without .dmm

	var/shuttle_map_turf = /turf/space
	var/space_turf_replacement = null

	var/has_hotspots = FALSE

	var/merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom
	var/merchant_left_station = /area/shuttle/merchant_shuttle/left_station
	var/merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom
	var/merchant_right_station = /area/shuttle/merchant_shuttle/right_station

	var/list/valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics))
//		"the public pool" = list(/area/station/crew_quarters/pool))

	var/job_limits_from_landmarks = FALSE /// if TRUE each job with a landmark will get as many slots as many landmarks there are (jobs without a landmark left on default)
	var/list/job_limits_override = list() /// assoc list of the form `job_type=limit` to override other job settings, works on gimmick jobs too

	proc/get_shuttle_path()
		var/dirname = dir_to_dirname(escape_dir)
		var/shuttle_name = src.default_shuttle || "[dirname]base"
		#ifdef UPSCALED_MAP
		. = "assets/maps/shuttles/[dirname]/[shuttle_name]_big.dmm"
		#else
		. = "assets/maps/shuttles/[dirname]/[shuttle_name].dmm"
		#endif

	proc/get_shuttle_transit_path()
		var/dirname = dir_to_dirname(escape_dir)
		var/shuttle_name = src.default_shuttle || "[dirname]base"
		#ifdef UPSCALED_MAP
		. = "assets/maps/transit/[dirname]/[shuttle_name]_big.dmm"
		#else
		. = "assets/maps/transit/[dirname]/[shuttle_name].dmm"
		#endif

	proc/init() /// Map-specific initialization, feel free to override for your map!
		// map limits
		if(job_limits_from_landmarks)
			for(var/datum/job/J in job_controls.staple_jobs)
				if(J.map_can_autooverride && (J.name in job_start_locations))
					J.limit = length(job_start_locations[J.name])

		for(var/datum/job/J in job_controls.staple_jobs + job_controls.special_jobs)
			if(J.type in src.job_limits_override)
				J.limit = src.job_limits_override[J.type]

		SPAWN(5 SECONDS)
			src.load_shuttle()

	proc/load_shuttle(path=null, transit_path=null, load_loc_override=null)
		if(isnull(path))
			path = src.get_shuttle_path()

		var/datum/mapPrefab/shuttle/shuttlePrefab = null
		if(istype(path, /datum/mapPrefab/shuttle))
			shuttlePrefab = path
		else
			shuttlePrefab = new(path, path, escape_dir, FALSE)

		if(isnull(transit_path))
			transit_path = src.get_shuttle_transit_path()

		var/turf/start = load_loc_override || pick_landmark(LANDMARK_SHUTTLE_CENTCOM)
		if(!start)
			return FALSE

		shuttlePrefab.applyTo(start, overwrite_args=DMM_OVERWRITE_OBJS)

		var/dmm_suite/dmm_suite = new
		src.transit_region = get_singleton(/datum/mapPrefab/allocated/shuttle_transit).load()
		logTheThing(LOG_DEBUG, usr, "<b>Shuttle Transit</b>: Got bottom left corner [log_loc(src.transit_region.bottom_left)]")
		var/turf/transit_start
		for(var/turf/T in landmarks[LANDMARK_SHUTTLE_TRANSIT])
			if(transit_region.turf_in_region(T))
				transit_start = T
				break
		if (!transit_start)
			CRASH("Unable to load escape transit landmark")
		dmm_suite.read_map(file2text(transit_path), transit_start.x, transit_start.y, transit_start.z)

		var/area/shuttle/escape/transit/transit_area = locate(/area/shuttle/escape/transit)
		transit_area.warp_dir = escape_dir
		return TRUE


/datum/map_settings/donut2
	name = "DONUT2"
	goonhub_map = "https://goonhub.com/maps/donut2"
	airlock_style = "pyro"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	escape_dir = WEST

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/donut2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/donut2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/donut2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/donut2

	valid_nuke_targets = list("the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the public market" = list(/area/station/crew_quarters/market),
		"the stock exchange" = list(/area/station/crew_quarters/stockex),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the bridge" = list(/area/station/bridge),
		"the crew lounge" = list(/area/station/crew_quarters/quarters),
		"the brig" = list(/area/station/security/processing, /area/station/security/brig),
		"the main station pod bay" = list(/area/station/hangar/main))

	job_limits_override = list(
		/datum/job/civilian/rancher = 2,
	)

/datum/map_settings/donut3
	name = "DONUT3"
	goonhub_map = "http://goonhub.com/maps/donut3"
	airlock_style = "pyro"
	walls = /turf/simulated/wall/auto/jen
	rwalls = /turf/simulated/wall/auto/reinforced/jen

	escape_dir = NORTH
	default_shuttle = "donut3"

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"inner engineering (surrounding the singularity, not in it)" = list(/area/station/engine/inner),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the inner hall of the medbay" = list(/area/station/medical/medbay),
		"the main hallway in research" = list(/area/station/science/lobby),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the escape hallway" = list(/area/station/hallway/secondary/exit),
		"the Research Director's office" = list(/area/station/crew_quarters/hor),
		"the Chief Engineer's office" = list(/area/station/engine/engineering/ce),
		"the kitchen" = list(/area/station/crew_quarters/kitchen),
		"the bridge" = list(/area/station/bridge),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the central room in security" = list(/area/station/security/main),
		"the hydroponics bay" = list(/area/station/hydroponics/bay))

	job_limits_override = list(
		/datum/job/civilian/rancher = 2,
	)

/datum/map_settings/cogmap_old
	name = "COGMAP_OLD"
	escape_dir = SOUTH
	walls = /turf/simulated/wall
	rwalls = /turf/simulated/wall/r_wall
	auto_walls = FALSE

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/cogmap
	name = "COGMAP"
	goonhub_map = "https://goonhub.com/maps/cogmap"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = SOUTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo office (QM)" = list(/area/station/quartermaster/office),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the bridge" = list(/area/station/bridge),
		"the stock exchange at the public market" = list(/area/station/crew_quarters/stockex),
		"the escape arm" = list(/area/station/hallway/secondary/exit),
		"the central room of the crew lounge" = list(/area/station/crew_quarters/quarters),
		"the chapel" = list(/area/station/chapel/sanctuary))

	job_limits_override = list(
		/datum/job/civilian/rancher = 2,
	)

/datum/map_settings/cogmap2
	name = "COGMAP2"
	goonhub_map = "https://goonhub.com/maps/cogmap2"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap2

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		//"the thermo-electric generator room" = list(/area/station/engine/core),
		"the engine control room" = list(/area/station/engine/power),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the net cafe" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the genetics lab" = list(/area/station/medical/research),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the mining staff room" = list(/area/station/mining/staff_room),
		"the bridge" = list(/area/station/bridge),
		"the central warehouse, next to the refinery" = list(/area/station/storage/warehouse))

	job_limits_override = list(
		/datum/job/civilian/rancher = 2,
	)

/datum/map_settings/destiny
	name = "DESTINY"
	display_name = "NSS Destiny"
	style = "ship"
	default_gamemode = "extended"
	goonhub_map = "https://goonhub.com/maps/destiny"
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		//"the refinery (arc smelter)" = list(/area/station/mining/refinery),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		//"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the escape shuttle dock" = list(/area/station/hallway/secondary/exit),
		"the kitchen" = list(/area/station/crew_quarters/kitchen))

/datum/map_settings/destiny/clarion
	name = "CLARION"
	display_name = "NSS Clarion"
	goonhub_map = "https://goonhub.com/maps/clarion"

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the quartermaster's office" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		//"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the bridge" = list(/area/station/bridge),
		"the community center (chapel)" = list(/area/station/chapel/sanctuary),
		"the aviary" = list(/area/station/garden/aviary),
		"the quartermaster's storage room" = list(/area/station/quartermaster/storage))
		//"the robotics lab" = list(/area/station/medical/robotics))

/datum/map_settings/horizon
	name = "HORIZON"
	display_name = "NSS Horizon"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/horizon"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the main security room" = list(/area/station/security/main),
		"the Quartermaster's Store (QM)" = list(/area/station/quartermaster/office),
		"the Engineering control room" = list(/area/station/engine/power),
		"that snazzy-lookin' sports bar up front" = list(/area/station/crew_quarters/fitness),
		"the main medical bay room" = list(/area/station/medical/medbay),
		"the research artifact lounge" = list(/area/station/science/artifact),
		"the cloning lab" = list(/area/station/medical/medbay/cloner),
		"the hot loop" = list(/area/station/engine/hotloop),
		"the mechanics' lab" = list(/area/station/engine/elect),
		"the mining staff room" = list(/area/station/mining/staff_room),
		"the robotics lab" = list(/area/station/medical/robotics),
		"the crew quarters on the south of the station" = list(/area/station/crew_quarters/quarters_south))

	job_limits_override = list(
		/datum/job/civilian/clown = 2,
		/datum/job/security/security_officer = 6,
		/datum/job/security/detective = 1,
		/datum/job/research/geneticist = 3,
		/datum/job/research/roboticist = 3,
		/datum/job/research/scientist = 6,
		/datum/job/research/medical_doctor = 7,
		/datum/job/engineering/mechanic = 4,
		/datum/job/engineering/miner = 4,
		/datum/job/engineering/engineer = 6,
		/datum/job/civilian/chef = 2,
		/datum/job/civilian/bartender = 2,
		/datum/job/civilian/janitor = 3,
		/datum/job/civilian/chaplain = 2,
		/datum/job/special/lawyer = 1,
		/datum/job/special/atmospheric_technician = 1
	)

/datum/map_settings/horizon/crash
	name = "CRASH"
	display_name = "Free Fall"

/datum/map_settings/manta
	name = "MANTA"
	display_name = "NSS Manta"
	goonhub_map = "https://goonhub.com/maps/manta"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	style = "ship"
	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"
	shuttle_map_turf = /turf/space/fluid/manta

	default_shuttle = "manta"
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap/manta
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap/manta

	valid_nuke_targets = list("the fitness room" = list(/area/station/crew_quarters/fitness),
		"the cargo bay" = list(/area/station/quartermaster/cargobay),
		"the bridge" = list(/area/station/bridge),
		"the medbay lobby" = list(/area/station/medical/medbay/lobby),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the communications office" = list(/area/station/communications/office),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the chemistry lab" = list(/area/station/science/chemistry),
		"the hydroponics bay" = list(/area/station/hydroponics/bay),
		"the Rising Tide bar" = list(/area/station/crew_quarters/cafeteria/the_rising_tide_bar))

/datum/map_settings/mushroom
	name = "MUSHROOM"
	goonhub_map = "https://goonhub.com/maps/mushroom"

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	airlock_style = "pyro"

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	escape_dir = EAST

/datum/map_settings/trunkmap
	name = "TRUNKMAP"
	goonhub_map = "https://goonhub.com/maps/trunkmap"
	escape_dir = NORTH
	walls = /turf/simulated/wall
	rwalls = /turf/simulated/wall/r_wall
	auto_walls = FALSE

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

/datum/map_settings/atlas
	name = "ATLAS"
	display_name = "NCS Atlas"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/atlas"
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1

	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office/),
		"the bridge" = list(/area/station/bridge/),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the telescience lab" = list(/area/station/science/teleporter),
		"the genetics lab" = list(/area/station/medical/research, /area/station/medical/medbay/cloner))

/datum/map_settings/kondaru
	name = "KONDARU"
	goonhub_map = "https://goonhub.com/maps/kondaru"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the quartermaster's front office" = list(/area/station/quartermaster/office),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/mining/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the artifact lab" = list(/area/station/science/artifact),
		"the janitor's office" = list(/area/station/janitor/office),
		"the telescience lab" = list(/area/station/science/teleporter),
		"the merchant docks" = list(/area/station/crew_quarters/market),
		"the nerd dungeon" = list(/area/station/crew_quarters/arcade/dungeon),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the fitness room" = list(/area/station/crew_quarters/fitness),
		"the news office" = list(/area/station/crew_quarters/radio/news_office),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the aviary" = list( /area/station/garden/aviary))

	job_limits_override = list(
		/datum/job/civilian/rancher = 2,
	)

/datum/map_settings/ozymandias
	name = "OZYMANDIAS"
	goonhub_map = "https://i.imgur.com/COYgNvN.jpg"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	job_limits_from_landmarks = TRUE
	job_limits_override = list(
		/datum/job/special/atmospheric_technician = 1,
		/datum/job/special/barber = 1,
		/datum/job/special/research_assistant = 2,
		/datum/job/special/medical_assistant = 2
	)

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the security equipment wing" = list(/area/station/security/equipment),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the quartermasters' office" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the basketball court" = list(/area/station/crew_quarters/fitness),
		"the medbay's central loop" = list(/area/station/medical/medbay),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the data center" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the chapel reception hall" = list(/area/station/crew_quarters/quarters))

/datum/map_settings/fleet
	name = "FLEET"
	display_name = "Bellerophon Fleet"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/bellerophon fleet"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external

	escape_dir = EAST

	merchant_left_centcom = null
	merchant_left_station = null
	merchant_right_centcom = null
	merchant_right_station = null

	valid_nuke_targets = list("the Demeter primary zone" = list(/area/station/garden/aviary),
		"the Tenebrae primary zone" = list(/area/station/science/lobby),
		"the Asclepius primary zone" = list(/area/station/medical/medbay),
		"the Meridian primary zone" = list(/area/station/crew_quarters/captain),
		"the Dionysus primary zone" = list(/area/station/crew_quarters/cafeteria),
		"the Maru primary zone" = list(/area/station/engine/engineering),
		"the Hammer primary zone" = list(/area/station/security/main))

/datum/map_settings/density // I just copied cog2 for now, ok????
	name = "density"
	goonhub_map = "https://goonhub.com/maps/density"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap2

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science/lobby),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the net cafe" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the genetics lab" = list(/area/station/medical/research))

/datum/map_settings/pamgoc
	name = "PAMGOC"
	goonhub_map = "https://goonhub.com/maps/cogmap"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = SOUTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	job_limits_override = list(
		/datum/job/civilian/clown = 2 // pamgoc can have a little clown, as a treat
	)

/datum/map_settings/oshan
	name = "OSHAN"
	display_name = "Oshan Laboratory, Abzu"
	goonhub_map = "https://goonhub.com/maps/oshan"

	arrivals_type = MAP_SPAWN_MISSILE

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = EAST
	default_shuttle = "oshan"
	shuttle_map_turf = /turf/space/fluid

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the fitness room" = list(/area/station/crew_quarters/fitness),
		"the quartermaster's office" = list(/area/station/quartermaster/office),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the nerd dungeon" = list(/area/station/crew_quarters/arcade/dungeon),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the main security room" = list(/area/station/security/main),
		"the main engineering room" = list(/area/station/engine/engineering, /area/station/hangar/engine),
		"the research lobby" = list(/area/station/science/lobby),
		"the crew quarters" = list(/area/station/crew_quarters/quartersA),
		"the mining staff room" = list(/area/station/mining/staff_room))
		//"the radio lab" = list(/area/station/crew_quarters/radio))

	job_limits_override = list(
		/datum/job/special/random/psychiatrist = 1
	)

/datum/map_settings/nadir
	name = "NADIR"
	display_name = "Nadir Extraction Site"
	goonhub_map = "https://goonhub.com/maps/nadir"

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = TRUE

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = EAST
	default_shuttle = "oshan"
	shuttle_map_turf = /turf/space/fluid/acid

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the quartermaster's office" = list(/area/station/quartermaster/office),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"security's central staff room" = list(/area/station/security/main),
		"the engineering staff room" = list(/area/station/engine/engineering),
		"the medical bay's central room" = list(/area/station/medical/medbay),
		"the east crew quarters" = list(/area/station/crew_quarters/quarters_east),
		"the nerd dungeon" = list(/area/station/crew_quarters/arcade/dungeon),
		"the chapel" = list(/area/station/chapel/sanctuary))

	job_limits_from_landmarks = TRUE
	job_limits_override = list(
		/datum/job/engineering/miner = 0 //eventually, assay technicians?
	)

/datum/map_settings/wrestlemap
	name = "WRESTLEMAP"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn

	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap


	valid_nuke_targets = list("The Ring (near the bar)" = list(/area/station/crew_quarters/quarters),
		"the monkeydome arena" = list(/area/station/medical/dome),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"outside the Ringularity" = list(/area/station/engine/inner),
		"the courtroom" = list(/area/station/storage/warehouse),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay),
		"the security lobby" = list(/area/station/security/secwing),
		"the chapel" = list(/area/station/chapel/sanctuary),
		"the south crew quarters" = list(/area/station/crew_quarters/quarters_south))

/datum/map_settings/pod_wars
	name = "POD_WARS"
	default_gamemode = "pod_wars"
	goonhub_map = "https://goonhub.com/maps/pod_wars"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	style = "spess"


	arrivals_type = MAP_SPAWN_CRYO

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = TRUE

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = null
	escape_transit = null
	escape_station = null
	escape_dir = NORTH

	merchant_left_centcom = null
	merchant_left_station = null
	merchant_right_centcom = null
	merchant_right_station = null

	valid_nuke_targets = list()


/area/shuttle/merchant_shuttle/left_centcom
	icon_state = "shuttle_merch_l"
	donut2
		icon_state = "shuttle_merch_l-dnt2"
	cogmap
		icon_state = "shuttle_merch_l-cog1"
	cogmap2
		icon_state = "shuttle_merch_l-cog2"
	destiny
		icon_state = "shuttle_merch_l-dest"
	sealab
		icon_state = "shuttle_merch_l-sealab"

/area/shuttle/merchant_shuttle/left_station
	#ifdef UNDERWATER_MAP
	ambient_light = OCEAN_LIGHT
	#endif
	icon_state = "shuttle_merch_l"
	donut2
		icon_state = "shuttle_merch_l-dnt2"
	cogmap
		icon_state = "shuttle_merch_l-cog1"
	cogmap2
		icon_state = "shuttle_merch_l-cog2"
	destiny
		icon_state = "shuttle_merch_l-dest"
	sealab
		icon_state = "shuttle_merch_l-sealab"

/area/shuttle/merchant_shuttle/right_centcom
	icon_state = "shuttle_merch_r"
	donut2
		icon_state = "shuttle_merch_r-dnt2"
	cogmap
		icon_state = "shuttle_merch_r-cog1"
	cogmap2
		icon_state = "shuttle_merch_r-cog2"
	destiny
		icon_state = "shuttle_merch_r-dest"
	sealab
		icon_state = "shuttle_merch_r-sealab"

/area/shuttle/merchant_shuttle/right_station
	#ifdef UNDERWATER_MAP
	ambient_light = OCEAN_LIGHT
	#endif
	icon_state = "shuttle_merch_r"
	donut2
		icon_state = "shuttle_merch_r-dnt2"
	cogmap
		icon_state = "shuttle_merch_r-cog1"
	cogmap2
		icon_state = "shuttle_merch_r-cog2"
	destiny
		icon_state = "shuttle_merch_r-dest"
	sealab
		icon_state = "shuttle_merch_r-sealab"

/proc/dir2nautical(var/req_dir, var/fore_dir = NORTH, var/side = 0)
	if (!isnum(req_dir) || !isnum(fore_dir))
		return "unknown[side ? " side" : null]"
	if (req_dir == fore_dir)
		return "north"
	else if (turn(fore_dir, 90) == req_dir)
		return "west[side ? " side" : null]"
	else if (turn(fore_dir, -90) == req_dir)
		return "east[side ? " side" : null]"
	else if (turn(fore_dir, 180) == req_dir)
		return "south"
	else // we're on some kind of diagonal idk
		if (turn(fore_dir, 45) == req_dir)
			return "north-west"
		else if (turn(fore_dir, -45) == req_dir)
			return "north-east"
		else if (turn(fore_dir, 135) == req_dir)
			return "south-west"
		else if (turn(fore_dir, -135) == req_dir)
			return "south-east"
	return "unknown[side ? " side" : null]"

/proc/getMapNameFromID(id)
	for (var/map in mapNames)
		if (id == mapNames[map]["id"])
			return map

	return 0
