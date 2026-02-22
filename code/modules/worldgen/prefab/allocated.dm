TYPEINFO(/datum/mapPrefab/allocated)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/allocated)
/datum/mapPrefab/allocated

	proc/load()
		RETURN_TYPE(/datum/allocated_region)
		var/datum/allocated_region/region = global.region_allocator.allocate(src.prefabSizeX, src.prefabSizeY, name)
		src.applyTo(region.bottom_left, overwrite_args = DMM_OVERWRITE_OBJS | DMM_OVERWRITE_MOBS | DMM_BESPOKE_AREAS)
		return region

/datum/mapPrefab/allocated/newbee_tutorial
	prefabPath = "assets/maps/allocated/newbee_tutorial.dmm"
	prefabSizeX = 40
	prefabSizeY = 21

/datum/mapPrefab/allocated/blob_tutorial
	prefabPath = "assets/maps/allocated/blob_tutorial.dmm"
	prefabSizeX = 17
	prefabSizeY = 18

/datum/mapPrefab/allocated/flock_tutorial
	prefabPath = "assets/maps/allocated/flock_tutorial.dmm"
	prefabSizeX = 31
	prefabSizeY = 31

/datum/mapPrefab/allocated/flock_showcase
	prefabPath = "assets/maps/allocated/flock_showcase.dmm"
	prefabSizeX = 21
	prefabSizeY = 10

/datum/mapPrefab/allocated/cruiser_syndicate
	prefabPath = "assets/maps/allocated/cruiser_syndicate.dmm"
	prefabSizeX = 7
	prefabSizeY = 13

/datum/mapPrefab/allocated/cruiser_nanotrasen
	prefabPath = "assets/maps/allocated/cruiser_nanotrasen.dmm"
	prefabSizeX = 7
	prefabSizeY = 13

/datum/mapPrefab/allocated/shuttle_transit
	prefabPath = "assets/maps/allocated/shuttle_transit.dmm"
	prefabSizeX = 32
	prefabSizeY = 32

/datum/mapPrefab/allocated/football
	prefabPath = "assets/maps/allocated/football.dmm"
	prefabSizeX = 294
	prefabSizeY = 46

/datum/mapPrefab/allocated/artifact_stranded
	prefabPath = "assets/maps/allocated/artifact_stranded.dmm"
	prefabSizeX = 5
	prefabSizeY = 5

/datum/mapPrefab/allocated/artifact_fissure
	prefabPath = "assets/maps/allocated/artifact_fissure.dmm"
	prefabSizeX = 29
	prefabSizeY = 35

/datum/mapPrefab/allocated/pirate_ship
	prefabPath = "assets/maps/allocated/pirate_ship.dmm"
	prefabSizeX = 33
	prefabSizeY = 38

/datum/mapPrefab/allocated/jar
	prefabSizeX = 7
	prefabSizeY = 7
	prefabPath = "assets/maps/allocated/jar.dmm"

/datum/mapPrefab/allocated/htr_team
	prefabPath = "assets/maps/allocated/htr_team_ship.dmm"
	prefabSizeX = 25
	prefabSizeY = 25

	purge
		prefabPath = "assets/maps/allocated/htr_purge_ship.dmm"

/datum/mapPrefab/allocated/phoenix_nest
	prefabSizeX = 9
	prefabSizeY = 9
	prefabPath = "assets/maps/allocated/phoenix_nest.dmm"
