#define Z_LEVEL_NULL 0 		//! Nullspace/Z0/The Darkness
#define Z_LEVEL_STATION 1	//! The station Z-level.
#define Z_LEVEL_ADVENTURE 2	//! The Z-level used for Adventure Zones.
#define Z_LEVEL_DEBRIS 3	//! The debris Z-level. Blank on underwater maps.
#define Z_LEVEL_SECRET 4	//! The Z-level used for secret things.
#define Z_LEVEL_MINING 5	//! The mining Z-level. Trench on underwater maps
#define Z_LEVEL_DYNAMIC 6	//! The Z-level used for dynamically loaded maps. See: region_allocator

/// A list of each z-level define and it's associated parallax layer types. See `code\map\map_settings.dm` for station-level parallax layers.
var/list/z_level_parallax_settings = list(
	"[Z_LEVEL_NULL]" = list(),
	"[Z_LEVEL_ADVENTURE]" = list(),
	"[Z_LEVEL_DEBRIS]" = list(
		/atom/movable/screen/parallax_layer/space_1,
		/atom/movable/screen/parallax_layer/space_2,
		/atom/movable/screen/parallax_layer/asteroids_far,
		/atom/movable/screen/parallax_layer/asteroids_near,
		),
	"[Z_LEVEL_SECRET]" = list(),
	"[Z_LEVEL_MINING]" = list(
		/atom/movable/screen/parallax_layer/space_1,
		/atom/movable/screen/parallax_layer/space_2,
		/atom/movable/screen/parallax_layer/asteroids_far,
		/atom/movable/screen/parallax_layer/asteroids_near,
		),
	)

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
