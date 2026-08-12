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

/// Gets the value of a gas on that turf.
#define goonmos_get_gas(T, index) call_ext(GOONMOS, "byond:get_gas")(index, T.x, T.y, T.z)

/// Sets the value of a gas on that turf.
#define goonmos_set_gas(T, index, value) call_ext(GOONMOS, "byond:set_gas")(index, value, T.x, T.y, T.z)

/// Adjusts the value of a gas on that turf.
#define goonmos_adjust_gas(T, index, value) call_ext(GOONMOS, "byond:adjust_gas")(index, value, T.x, T.y, T.z)

/// Gets the value of a gas on that turf.
#define goonmos_get_temperature(T) call_ext(GOONMOS, "byond:get_temperature")(T.x, T.y, T.z)

/// Sets the value of a gas on that turf.
#define goonmos_set_temperature(T, value) call_ext(GOONMOS, "byond:set_temperature")(value, T.x, T.y, T.z)

/// Adjusts the value of a gas on that turf.
#define goonmos_adjust_temperature(T, value) call_ext(GOONMOS, "byond:adjust_temperature")(value, T.x, T.y, T.z)

/// Gets the heat capacity on a turf.
#define goonmos_get_heat_capacity(T) call_ext(GOONMOS, "byond:get_heat_capacity")(T.x, T.y, T.z)

/// Gets the thermal energy on a turf.
#define goonmos_get_energy(T) call_ext(GOONMOS, "byond:get_energy")(T.x, T.y, T.z)

/// Sets the thermal energy on a turf.
#define goonmos_set_energy(T, value) call_ext(GOONMOS, "byond:set_energy")(value, T.x, T.y, T.z)

/// Adjusts the thermal energy on a turf.
#define goonmos_adjust_energy(T, value) call_ext(GOONMOS, "byond:adjust_energy")(value, T.x, T.y, T.z)

/// Gets the pressure on a turf.
#define goonmos_get_pressure(T) call_ext(GOONMOS, "byond:get_pressure")(T.x, T.y, T.z)

/// Gets the total moles on a turf.
#define goonmos_get_total_moles(T) call_ext(GOONMOS, "byond:get_total_moles")(T.x, T.y, T.z)

/// Simulates heat transfer with a turf, returns the heat that would transfer. Positive is heat from turf to exposed.
#define goonmos_mimic_temperature_exchange(T, temperature, heat_capacity, coeff) call_ext(GOONMOS, "byond:mimic_temperature_exchange")(temperature, heat_capacity, coeff, T.x, T.y, T.z)
