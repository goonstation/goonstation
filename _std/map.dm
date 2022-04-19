#define Z_LEVEL_NULL 0 				//Nullspace/Z0/The Darkness
#define Z_LEVEL_STATION 1           //The station Z-level.
#define Z_LEVEL_ADVENTURE 2         //The Z-level used for Adventure Zones.
#define Z_LEVEL_DEBRIS 3            //The debris Z-level. Blank on underwater maps.
#define Z_LEVEL_SECRET 4            //The Z-level used for secret things.
#define Z_LEVEL_MINING 5            //The mining Z-level.
#define Z_LEVEL_FOOTBALL 6          //The Z-level used for football.

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
