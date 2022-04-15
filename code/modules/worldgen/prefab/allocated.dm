TYPEINFO(/datum/mapPrefab/allocated)
	stored_as_subtypes = TRUE

ABSTRACT_TYPE(/datum/mapPrefab/allocated)
/datum/mapPrefab/allocated

	proc/load()
		RETURN_TYPE(/datum/allocated_region)
		var/datum/allocated_region/region = global.region_allocator.allocate(src.prefabSizeX, src.prefabSizeY)
		src.applyTo(region.bottom_left, overwrite_args = DMM_OVERWRITE_OBJS | DMM_OVERWRITE_MOBS)
		return region

/datum/mapPrefab/allocated/blob_tutorial
	prefabPath = "assets/maps/allocated/blob_tutorial.dmm"
	prefabSizeX = 17
	prefabSizeY = 18
