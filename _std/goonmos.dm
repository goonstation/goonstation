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

/// When GOONMOS panics, where to dump the log?
/// Returns nothing.
#define goonmos_set_panic_location(path) call_ext(GOONMOS, "byond:set_panic_location")(path)

/// Initializes GOONMOS to the passed sizes. If GOONMOS had previously experienced a panic, this will also completely wipe clean GOONMOS.
/// Returns nothing.
#define goonmos_initialize(maxx, maxy, maxz) call_ext(GOONMOS, "byond:initialize")(maxx, maxy, maxz)

/// Initializes all zlevels to the world.
/// Returns nothing.
#define goonmos_initialize_all_zlevels(...) call_ext(GOONMOS, "byond:initialize_all_zlevels")()

/// Initializes a specific zlevel.
/// Returns nothing.
#define goonmos_initialize_zlevel(z) call_ext(GOONMOS, "byond:initialize_zlevel_to_map")(z)

/// Did GOONMOS experience a panic and become poisoned?
/// Returns true if yes, else no.
#define goonmos_is_fucked(...) call_ext(GOONMOS, "byond:is_goonmos_fucked")()

/// Tick that zlevel once.
/// Returns nothing.
#define goonmos_tick_zlevel(z) call_ext(GOONMOS, "byond:tick_zlevel")(z)

/// Initializes a specific block.
/// Returns nothing.
#define goonmos_initialize_block(low_x, low_y, high_x, high_y, z) call_ext(GOONMOS, "byond:initialize_block_to_map")(low_x, low_y, high_x, high_y, z)

/// Returns a list of the current air at a turf.
#define goonmos_get_tile_info(T) call_ext(GOONMOS, "byond:get_tile_info")(T.x, T.y, T.z)

/// Merges the given gas list into that turf.
#define goonmos_assume_air(T, gas) call_ext(GOONMOS, "byond:assume_air")(gas, T.x, T.y, T.z)

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
