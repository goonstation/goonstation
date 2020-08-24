
#define MAP_SPAWN_SHUTTLE 1
#define MAP_SPAWN_CRYO 2
#define MAP_SPAWN_MISSILE 3

#define MAP_NAME_RANDOM 1

var/global/map_setting = null
var/global/datum/map_settings/map_settings = null

//id corresponds to the name of the /obj/landmark/map
//playerPickable defines whether the map can be chosen by players when voting on a new map. Setting to ASS_JAM should allow it on the 13th only, and not on RP.
var/global/list/mapNames = list(
	"Clarion" = 		list("id" = "CLARION", 		"settings" = "destiny/clarion", "playerPickable" = 1,				"MaxPlayersAllowed" = 80),
#ifdef RP_MODE
	"Cogmap 1" = 		list("id" = "COGMAP", 		"settings" = "cogmap", 			"playerPickable" = 1, 	"MinPlayersAllowed" = 14),
#else
	"Cogmap 1" = 		list("id" = "COGMAP", 		"settings" = "cogmap", 			"playerPickable" = 1,				"MaxPlayersAllowed" = 80),
#endif
	//"Construction" = list("id" = "CONSTRUCTION", "settings" = "construction"),
	"Cogmap 1 (Old)" = 	list("id" = "COGMAP_OLD", 	"settings" = "cogmap_old"),
	"Cogmap 2" = 		list("id" = "COGMAP2", 		"settings" = "cogmap2", 		"playerPickable" = 1, 	"MinPlayersAllowed" = 40),
	"Destiny" = 		list("id" = "DESTINY", 		"settings" = "destiny", 		"playerPickable" = 1,				"MaxPlayersAllowed" = 80),
	"Donut 2" = 		list("id" = "DONUT2", 		"settings" = "donut2",			"playerPickable" = ASS_JAM),
	"Donut 3" = 		list("id" = "DONUT3", 		"settings" = "donut3",			"playerPickable" = 1, 	"MinPlayersAllowed" = 40),
	"Horizon" = 		list("id" = "HORIZON", 		"settings" = "horizon", 		"playerPickable" = 1),
	"Linemap" = 		list("id" = "LINEMAP", 		"settings" = "linemap",			"playerPickable" = ASS_JAM),
	"Mushroom" =		list("id" = "MUSHROOM", 	"settings" = "mushroom",		"playerPickable" = ASS_JAM),
	"Trunkmap" = 		list("id" = "TRUNKMAP", 	"settings" = "trunkmap",		"playerPickable" = ASS_JAM),
	"Oshan Laboratory"= list("id" = "OSHAN", 	"settings" = "oshan", 			"playerPickable" = 1),
	"Samedi" = 			list("id" = "SAMEDI", 		"settings" = "samedi", 			"playerPickable" = ASS_JAM),
	"1 pamgoC" = 		list("id" = "PAMGOC", 		"settings" = "pamgoc", 			"playerPickable" = ASS_JAM),
	"Kondaru" = 		list("id" = "KONDARU", "settings" = "kondaru", 				"playerPickable" = 1,				"MaxPlayersAllowed" = 80),
	"Bellerophon Fleet" = list("id" = "FLEET", "settings" = "fleet", "playerPickable" = ASS_JAM),
	"Icarus" = 			list("id" = "ICARUS",		"settings" = "icarus",				"playerPickable" = ASS_JAM),
	"Density" = 		list("id" = "DENSITY", 	"settings" = "density", 			"playerPickable" = ASS_JAM,				"MaxPlayersAllowed" = 30),
	"Atlas" = 			list("id" = "ATLAS", 		"settings" = "atlas", 				"playerPickable" = 1,				"MaxPlayersAllowed" = 30),
	"Manta" = 			list("id" = "MANTA", 		"settings" = "manta", 				"playerPickable" = 1,				"MaxPlayersAllowed" = 80),
	"Wrestlemap" = 			list("id" = "WRESTLEMAP", 	"settings" = "wrestlemap", 		"playerPickable" = ASS_JAM)
)

/obj/landmark/map
	name = "map_setting"
	icon_state = "x3"
	invisibility = 101

	New()
		if (src.name != "map_setting")
			map_setting = src.name

			//find config in mapNames above
			for (var/map in mapNames)
				var/mapID = mapNames[map]["id"]

				if (mapID == map_setting)
					var/path = text2path("/datum/map_settings/" + mapNames[map]["settings"])
					map_settings = new path
					break

			//Fallback for an unfound map. Should never occur!!
			if (!map_settings)
				map_settings = new /datum/map_settings
				CRASH("A mapName entry for '[src.name]' wasn't found!")

		qdel(src)

//Setting maps to be underwater is handled in the map config file, aka [mapname].dm

/datum/map_settings
	var/name = "MAP"
	var/display_name = MAP_NAME_RANDOM
	var/style = "station"
	var/default_gamemode = "secret"
	var/goonhub_map = "https://goonhub.com/maps/cogmap"
	var/arrivals_type = MAP_SPAWN_SHUTTLE
	var/dir_fore = null

	var/walls = /turf/simulated/wall
	var/rwalls = /turf/simulated/wall/r_wall
	var/auto_walls = 0

	var/windows = /obj/window
	var/windows_thin = /obj/window
	var/rwindows = /obj/window/reinforced
	var/rwindows_thin = /obj/window/reinforced
	var/windows_crystal = /obj/window/crystal
	var/windows_rcrystal = /obj/window/crystal/reinforced
	var/window_layer_full = null
	var/window_layer_north = null // cog2 panel windows need to go under stuff because ~perspective~
	var/window_layer_south = null
	var/auto_windows = 0

	var/ext_airlocks = /obj/machinery/door/airlock/external
	var/airlock_style = "gannets"

	var/escape_centcom = /area/shuttle/escape/centcom
	var/escape_transit = /area/shuttle/escape/transit
	var/escape_station = /area/shuttle/escape/station
	var/escape_dir = SOUTH
	var/shuttle_map_turf = /turf/space

	var/merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom
	var/merchant_left_station = /area/shuttle/merchant_shuttle/left_station
	var/merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom
	var/merchant_right_station = /area/shuttle/merchant_shuttle/right_station

	var/list/valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the engineering control room" = list(/area/station/engine/engineering, /area/station/engine/power),
		"the central warehouse" = list(/area/station/storage/warehouse),
		"the courtroom" = list(/area/station/crew_quarters/courtroom, /area/station/crew_quarters/juryroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery, /area/station/medical/medbay/lobby),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the robotics lab" = list(/area/station/medical/robotics))
//		"the public pool" = list(/area/station/crew_quarters/pool))

/datum/map_settings/donut2
	name = "DONUT2"
	goonhub_map = "https://goonhub.com/maps/donut2"
	escape_centcom = /area/shuttle/escape/centcom/donut2
	escape_transit = /area/shuttle/escape/transit/donut2
	escape_station = /area/shuttle/escape/station/donut2
	escape_dir = WEST // FUCK YOU DONUT2 I WAS NEARLY DONE AND THEN YOU THROW THIS AT ME AND NOW I HAVE TO ADD YOUR GODDAMN WEST-FACING SHUTTLE TO THE MAP ARGH *SCREAM *SCREAM *SCREAM

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/donut2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/donut2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/donut2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/donut2

/datum/map_settings/donut3
	name = "DONUT3"
	goonhub_map = "https://cdn.discordapp.com/attachments/469379618168897538/729919886524153916/donut3-30-FINAL4-the-unlucky-number.png"
	airlock_style = "pyro"
	walls = /turf/simulated/wall/auto/jen
	rwalls = /turf/simulated/wall/auto/reinforced/jen

	escape_centcom = /area/shuttle/escape/centcom/donut3
	escape_transit = /area/shuttle/escape/transit/donut3
	escape_station = /area/shuttle/escape/station/donut3
	escape_dir = NORTH
	auto_windows = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"inner engineering (surrounding the singularity, not in it)" = list(/area/station/engine/inner),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the inner hall of the medbay" = list(/area/station/medical/medbay),
		"the main hallway in research" = list(/area/station/science),
		"the chapel" = list(/area/station/chapel/main),
		"the escape hallway" = list(/area/station/hallway/secondary/exit),
		"the Research Director's office" = list(/area/station/crew_quarters/hor),
		"the Chief Engineer's office" = list(/area/station/engine/engineering/ce),
		"the kitchen" = list(/area/station/crew_quarters/kitchen))

/datum/map_settings/cogmap_old
	name = "COGMAP_OLD"
	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/cogmap
	name = "COGMAP"
	goonhub_map = "https://goonhub.com/maps/cogmap"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/cogmap2
	name = "COGMAP2"
	goonhub_map = "https://goonhub.com/maps/cogmap2"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap2

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the net cafe" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the genetics lab" = list(/area/station/medical/research))

/datum/map_settings/destiny
	name = "DESTINY"
	display_name = "NSS Destiny"
	style = "ship"
	default_gamemode = "extended"
	goonhub_map = "https://goonhub.com/maps/destiny"
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = NORTH

	walls = /turf/simulated/wall/auto/gannets
	rwalls = /turf/simulated/wall/auto/reinforced/gannets
	auto_walls = 1

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/mining/refinery),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the robotics lab" = list(/area/station/medical/robotics))

/datum/map_settings/destiny/clarion
	name = "CLARION"
	display_name = "NSS Clarion"
	goonhub_map = "https://goonhub.com/maps/clarion"

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/lobby),
		"the bar" = list(/area/station/crew_quarters/bar),
		"the EVA storage" = list(/area/station/ai_monitored/storage/eva),
		"the artifact lab" = list(/area/station/science/artifact),
		"the robotics lab" = list(/area/station/medical/robotics))

/datum/map_settings/horizon
	name = "HORIZON"
	display_name = "NSS Horizon"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/horizon"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the courtroom" = list(/area/station/crew_quarters/courtroom),
		"the chapel" = list(/area/station/chapel/main),
		"the main security room" = list(/area/station/security/main),
		"the Quartermaster's Store (QM)" = list(/area/station/quartermaster),
		"the Engineering control room" = list(/area/station/engine/power),
		"that snazzy-lookin' sports bar up front" = list(/area/station/crew_quarters/fitness),
		"the main medical bay room" = list(/area/station/medical/medbay),
		"the research artifact lounge" = list(/area/station/science/artifact))

/datum/map_settings/manta
	name = "MANTA"
	display_name = "NSS Manta"
	goonhub_map = "https://goonhub.com/maps/manta"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1
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
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"
	shuttle_map_turf = /turf/space/fluid/manta

	escape_centcom = /area/shuttle/escape/centcom/manta
	escape_transit = /area/shuttle/escape/transit/manta
	escape_station = /area/shuttle/escape/station/manta
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap/manta
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap/manta

	valid_nuke_targets = list("the fitness room" = list(/area/station/crew_quarters/fitness),
		"the cargo bay" = list(/area/station/quartermaster/cargobay),
		"the bridge" = list(/area/station/bridge),
		"the medbay lobby" = list(/area/station/medical/medbay/lobby),
		"the engineering power room" = list(/area/station/engine/power),
		"the chapel" = list(/area/station/chapel/main),
		"the communications office" = list(/area/station/communications))

/datum/map_settings/mushroom
	name = "MUSHROOM"
	goonhub_map = "https://goonhub.com/maps/mushroom"

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1
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
	auto_windows = 1

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

/datum/map_settings/trunkmap
	name = "TRUNKMAP"
	goonhub_map = "https://goonhub.com/maps/trunkmap"
	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

/datum/map_settings/linemap
	name = "LINEMAP"
	arrivals_type = MAP_SPAWN_CRYO
	goonhub_map = "https://goonhub.com/maps/linemap"

	walls = /turf/simulated/wall/auto/gannets
	rwalls = /turf/simulated/wall/auto/reinforced/gannets
	auto_walls = 1

	escape_centcom = /area/shuttle/escape/centcom/donut2
	escape_transit = /area/shuttle/escape/transit/donut2
	escape_station = /area/shuttle/escape/station/donut2
	escape_dir = WEST

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
	auto_walls = 1
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the cargo bay (QM)" = list(/area/station/quartermaster/),
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
	auto_walls = 1

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
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
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
		"the janitor's office" = list(/area/station/janitor))

/datum/map_settings/fleet
	name = "FLEET"
	display_name = "Bellerophon Fleet"
	style = "ship"
	goonhub_map = "https://goonhub.com/maps/bellerophon fleet"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1
	arrivals_type = MAP_SPAWN_CRYO
	dir_fore = WEST

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

	valid_nuke_targets = list("the Demeter primary zone" = list(/area/station/aviary),
		"the Tenebrae primary zone" = list(/area/station/science),
		"the Asclepius primary zone" = list(/area/station/medical/medbay),
		"the Meridian primary zone" = list(/area/station/crew_quarters/captain),
		"the Dionysus primary zone" = list(/area/station/crew_quarters/cafeteria),
		"the Maru primary zone" = list(/area/station/engine/engineering),
		"the Hammer primary zone" = list(/area/station/security/main))

/datum/map_settings/icarus
	name = "ICARUS"
	display_name = "Icarus"
	style = "ship"
	goonhub_map = "https://i.imgur.com/SiI3RC9.png"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1
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
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
	escape_dir = NORTH

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/destiny
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/destiny
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/destiny
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/destiny

	valid_nuke_targets = list("the gymnasium" = list(/area/station/crew_quarters/fitness),
		"the vessel's power core" = list(/area/station/engine/engineering),
		"the monkey dome" = list(/area/station/medical/dome),
		"the jazz lounge" = list(/area/station/crew_quarters/jazz),
		"the quartermasters front office" = list(/area/station/quartermaster/office))

/datum/map_settings/density // I just copied cog2 for now, ok????
	name = "density"
	goonhub_map = "https://goonhub.com/maps/density"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap2
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap2
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap2
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap2

	valid_nuke_targets = list("the main security room" = list(/area/station/security/main),
		"the central research sector hub" = list(/area/station/science),
		"the cargo bay (QM)" = list(/area/station/quartermaster/office),
		"the thermo-electric generator room" = list(/area/station/engine/core),
		"the refinery (arc smelter)" = list(/area/station/quartermaster/refinery),
		"the medbay" = list(/area/station/medical/medbay, /area/station/medical/medbay/surgery),
		"the station's cafeteria" = list(/area/station/crew_quarters/cafeteria),
		"the net cafe" = list(/area/station/crew_quarters/info),
		"the artifact lab" = list(/area/station/science/artifact),
		"the genetics lab" = list(/area/station/medical/research))

/datum/map_settings/samedi
	name = "SAMEDI"
	goonhub_map = "https://goonhub.com/maps/samedi"

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap2
	escape_transit = /area/shuttle/escape/transit/cogmap2
	escape_station = /area/shuttle/escape/station/cogmap2
	escape_dir = EAST

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/pamgoc
	name = "PAMGOC"
	goonhub_map = "https://goonhub.com/maps/cogmap"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/cogmap
	escape_transit = /area/shuttle/escape/transit/cogmap
	escape_station = /area/shuttle/escape/station/cogmap

	merchant_left_centcom = /area/shuttle/merchant_shuttle/left_centcom/cogmap
	merchant_left_station = /area/shuttle/merchant_shuttle/left_station/cogmap
	merchant_right_centcom = /area/shuttle/merchant_shuttle/right_centcom/cogmap
	merchant_right_station = /area/shuttle/merchant_shuttle/right_station/cogmap

/datum/map_settings/oshan
	name = "OSHAN"
	goonhub_map = "https://goonhub.com/maps/oshan"

	arrivals_type = MAP_SPAWN_MISSILE

	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

	windows = /obj/window/auto
	windows_thin = /obj/window/pyro
	rwindows = /obj/window/auto/reinforced
	rwindows_thin = /obj/window/reinforced/pyro
	windows_crystal = /obj/window/auto/crystal
	windows_rcrystal = /obj/window/auto/crystal/reinforced
	window_layer_full = COG2_WINDOW_LAYER
	window_layer_north = GRILLE_LAYER+0.1
	window_layer_south = FLY_LAYER+1
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/sealab
	escape_transit = /area/shuttle/escape/transit/sealab
	escape_station = /area/shuttle/escape/station/sealab
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
		"the chapel" = list(/area/station/chapel/main))
		//"the radio lab" = list(/area/station/crew_quarters/radio))

/datum/map_settings/wrestlemap
	name = "WRESTLEMAP"
	walls = /turf/simulated/wall/auto/supernorn
	rwalls = /turf/simulated/wall/auto/reinforced/supernorn
	auto_walls = 1

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
	auto_windows = 1

	ext_airlocks = /obj/machinery/door/airlock/pyro/external
	airlock_style = "pyro"

	escape_centcom = /area/shuttle/escape/centcom/destiny
	escape_transit = /area/shuttle/escape/transit/destiny
	escape_station = /area/shuttle/escape/station/destiny
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
		"the security lobby" = list(/area/station/chapel/main),
		"the chapel" = list(/area/station/security/secwing),
		"the south crew quarters" = list(/area/station/crew_quarters/quarters_south))



/area/shuttle/escape/centcom
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
	donut3
		icon_state = "shuttle_escape-dnt3"
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
	manta
		icon_state = "shuttle_escape-manta"
		filler_turf = "/turf/space/fluid/manta"
	donut3
		icon_state = "shuttle_escape-dnt3"

/area/shuttle/escape/station
	#ifdef UNDERWATER_MAP
	ambient_light = OCEAN_LIGHT
	#endif
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
	donut3
		icon_state = "shuttle_escape-dnt3"
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
	manta
		icon_state = "shuttle_escape-manta"

/area/shuttle/escape/transit
	icon_state = "shuttle_escape"
	donut2
		icon_state = "shuttle_escape-dnt2"
		warp_dir = WEST
	donut3
		icon_state = "shuttle_escape-dnt3"
		warp_dir = NORTH
	cogmap
		icon_state = "shuttle_escape-cog1"
	cogmap2
		icon_state = "shuttle_escape-cog2"
		warp_dir = EAST
	destiny
		icon_state = "shuttle_escape-dest"
	sealab
		icon_state = "shuttle_escape-sealab"
		warp_dir = EAST
	battle_shuttle
		icon_state = "shuttle_escape-battle-shuttle"
		warp_dir = EAST
	manta
		icon_state = "shuttle_escape-manta"
		warp_dir = NORTH

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
