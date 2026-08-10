#ifndef GOONMOS
/var/__goonmos

/proc/__detect_goonmos()
	if (world.system_type == UNIX)
		if (fexists("./libgoonmos.so"))
			// No need for LD_LIBRARY_PATH badness.
			return __rust_g = "./libgoonmos.so"
		return __rust_g = "libgoonmos.so"
	else
		return __rust_g = "goonmos"

#define GOONMOS (__goonmos || __detect_goonmos())
#endif

/// Initializes GOONMOS to the passed sizes. If GOONMOS experienced a panic, poisoning GOONMOS, this will also completely clear GOONMOS.
/// Returns nothing.
#define goonmos_initialize(maxx, maxy, maxz) call_ext(GOONMOS, "byond:initialize")(maxx, maxy, maxz)

/// Initializes all zlevels to the world.
/// Returns nothing.
#define goonmos_initialize_all_zlevels(...) call_ext(GOONMOS, "byond:initialize_all_zlevels")()

/// Initializes a specific zlevel.
/// Returns nothing.
#define goonmos_initialize_zlevel(z) call_ext(GOONMOS, "byond:initialize_zlevel_to_map")(z)

/// Initializes a specific block.
/// Returns nothing.
#define goonmos_initialize_block(low_x, low_y, high_x, high_y, z) call_ext(GOONMOS, "byond:initialize_block_to_map")(low_x, low_y, high_x, high_y, z)

/// Returns a list of the current air at a turf.
#define goonmos_get_tile_info(T) call_ext(GOONMOS, "byond:get_tile_info")(T.x, T.y, T.z)
