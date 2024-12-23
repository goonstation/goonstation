#define Z_LEVEL_NULL 0 		//! Nullspace/Z0/The Darkness
#define Z_LEVEL_STATION 1	//! The station Z-level.
#define Z_LEVEL_ADVENTURE 2	//! The Z-level used for Adventure Zones.
#define Z_LEVEL_DEBRIS 3	//! The debris Z-level. Blank on underwater maps.
#define Z_LEVEL_SECRET 4	//! The Z-level used for secret things.
#define Z_LEVEL_MINING 5	//! The mining Z-level. Trench on underwater maps
#define Z_LEVEL_DYNAMIC 6	//! The Z-level used for dynamically loaded maps. See: region_allocator

///Map generation defines
#define PERLIN_LAYER_HEIGHT "perlin_height"
#define PERLIN_LAYER_HUMIDITY "perlin_humidity"
#define PERLIN_LAYER_HEAT "perlin_heat"

#define BIOME_LOW_HEAT "low_heat"
#define BIOME_LOWMEDIUM_HEAT "lowmedium_heat"
#define BIOME_HIGHMEDIUM_HEAT "highmedium_heat"
#define BIOME_HIGH_HEAT "high_heat"

#define BIOME_LOW_HUMIDITY "low_humidity"
#define BIOME_LOWMEDIUM_HUMIDITY "lowmedium_humidity"
#define BIOME_HIGHMEDIUM_HUMIDITY "highmedium_humidity"
#define BIOME_HIGH_HUMIDITY "high_humidity"

#define MAPGEN_IGNORE_FLORA (1 << 0)
#define MAPGEN_IGNORE_FAUNA (1 << 1)
#define MAPGEN_IGNORE_BUILDABLE (1 << 2)
#define MAPGEN_ALLOW_VEHICLES (1 << 3)
#define MAPGEN_FLOOR_ONLY	(1 << 4)

#define MAPGEN_TURF_ONLY ( MAPGEN_IGNORE_FLORA | MAPGEN_IGNORE_FAUNA )

// map region allocator defines

/**
 * Lets you iterate over things in an allocated region.
 *
 * Example:
 * ```
 * for(var/mob/M in REGION_TILES(src.region))
 * 	M.gib()
 * ```
 */

#define REGION_TILES(REG) range(REG.get_center(), "[REG.width]x[REG.height]")

/**
 * Provides a list of all turfs in allocated region.
 */
#define REGION_TURFS(REG) block(locate(REG.bottom_left.x, REG.bottom_left.y, REG.bottom_left.z), locate(REG.bottom_left.x+REG.width-1, REG.bottom_left.y+REG.height-1, REG.bottom_left.z))

/// Returns a random turf on a non-restricted z-level.
proc/random_nonrestrictedz_turf()
	RETURN_TYPE(/turf)
	var/list/non_restricted_zs = list()
	for (var/z in 1 to world.maxz)
		if (!isrestrictedz(z))
			non_restricted_zs += z
	return locate(rand(1, world.maxx), rand(1, world.maxy), pick(non_restricted_zs))

/// Tries to return a random space turf. Tries a given number of times and if it fails it returns null instead.
proc/random_space_turf(z=null, max_tries=20)
	RETURN_TYPE(/turf/space)
	var/list/non_restricted_zs
	if (isnull(z))
		non_restricted_zs = list()
		for (var/az in 1 to world.maxz)
			if (!isrestrictedz(az))
				non_restricted_zs += az

	for (var/i in 1 to max_tries)
		var/cur_z = z || pick(non_restricted_zs)
		var/turf/T = locate(rand(1, world.maxx), rand(1, world.maxy), cur_z)
		if (istype(T, /turf/space))
			return T
	return null




//Let's clarify something. I don't know if it needs clarifying, but here I go anyways.

//The UNDERWATER_MAP define is for things that should only be changed if the map is an underwater one.
//Things like fluid turfs that would break on a normal map.

//The map_currently_underwater global var is a variable to change how fluids and other objects interact with the current map.
//This allows you to put ANY map 'underwater'. However, since underwater-specific maps are always underwater I set that here.

#ifdef UNDERWATER_MAP
var/global/map_currently_underwater = 1
#else
var/global/map_currently_underwater = 0
#endif
