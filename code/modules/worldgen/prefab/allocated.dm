TYPEINFO(/datum/mapPrefab/allocated)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/allocated)
/datum/mapPrefab/allocated

	proc/load()
		RETURN_TYPE(/datum/allocated_region)
		var/datum/allocated_region/region = global.region_allocator.allocate(src.prefabSizeX, src.prefabSizeY)
		src.applyTo(region.bottom_left, overwrite_args = DMM_OVERWRITE_OBJS | DMM_OVERWRITE_MOBS | DMM_BESPOKE_AREAS)
		return region

/datum/mapPrefab/allocated/blob_tutorial
	prefabPath = "assets/maps/allocated/blob_tutorial.dmm"
	prefabSizeX = 17
	prefabSizeY = 18

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
