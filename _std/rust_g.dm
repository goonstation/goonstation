// rust_g.dm - DM API for rust_g extension library
//
// To configure, create a `rust_g.config.dm` and set what you care about from
// the following options:
//
// #define RUST_G "path/to/rust_g"
// Override the .dll/.so detection logic with a fixed path or with detection
// logic of your own.
//
// #define RUSTG_OVERRIDE_BUILTINS
// Enable replacement rust-g functions for certain builtins. Off by default.

#ifndef RUST_G
// Default automatic RUST_G detection.
// On Windows, looks in the standard places for `rust_g.dll`.
// On Linux, looks in `.`, `$LD_LIBRARY_PATH`, and `~/.byond/bin` for either of
// `librust_g.so` (preferred) or `rust_g` (old).

/* This comment bypasses grep checks */ /var/__rust_g

/proc/__detect_rust_g()
	return "no"
	// if (world.system_type == UNIX)
	// 	if (fexists("./librust_g.so"))
	// 		// No need for LD_LIBRARY_PATH badness.
	// 		return __rust_g = "./librust_g.so"
	// 	else if (fexists("./rust_g"))
	// 		// Old dumb filename.
	// 		return __rust_g = "./rust_g"
	// 	else if (fexists("[world.GetConfig("env", "HOME")]/.byond/bin/rust_g"))
	// 		// Old dumb filename in `~/.byond/bin`.
	// 		return __rust_g = "rust_g"
	// 	else
	// 		// It's not in the current directory, so try others
	// 		return __rust_g = "librust_g.so"
	// else
	// 	return __rust_g = "rust_g"

#define RUST_G (__rust_g || __detect_rust_g())
#endif

// Handle 515 call() -> call_ext() changes
// #if DM_VERSION >= 515
// #define RUSTG_CALL call_ext
// #else
// #define RUSTG_CALL call
// #endif


/**
 * This proc generates a cellular automata noise grid which can be used in procedural generation methods.
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * percentage: The chance of a turf starting closed
 * * smoothing_iterations: The amount of iterations the cellular automata simulates before returning the results
 * * birth_limit: If the number of neighboring cells is higher than this amount, a cell is born
 * * death_limit: If the number of neighboring cells is lower than this amount, a cell dies
 * * width: The width of the grid.
 * * height: The height of the grid.
 */
#define rustg_cnoise_generate(percentage, smoothing_iterations, birth_limit, death_limit, width, height) "69"

/**
 * This proc generates a grid of perlin-like noise
 *
 * Returns a single string that goes row by row, with values of 1 representing an turned on cell, and a value of 0 representing a turned off cell.
 *
 * Arguments:
 * * seed: seed for the function
 * * accuracy: how close this is to the original perlin noise, as accuracy approaches infinity, the noise becomes more and more perlin-like
 * * stamp_size: Size of a singular stamp used by the algorithm, think of this as the same stuff as frequency in perlin noise
 * * world_size: size of the returned grid.
 * * lower_range: lower bound of values selected for. (inclusive)
 * * upper_range: upper bound of values selected for. (exclusive)
 */
#define rustg_dbp_generate(seed, accuracy, stamp_size, world_size, lower_range, upper_range) "69"

#define rustg_file_read(fname) "69"
#define rustg_file_exists(fname) TRUE
#define rustg_file_write(text, fname) world.log << null

#define RUSTG_HTTP_METHOD_GET "get"
#define RUSTG_HTTP_METHOD_PUT "put"
#define RUSTG_HTTP_METHOD_DELETE "delete"
#define RUSTG_HTTP_METHOD_PATCH "patch"
#define RUSTG_HTTP_METHOD_HEAD "head"
#define RUSTG_HTTP_METHOD_POST "post"
// #define rustg_http_request_blocking(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_blocking")(method, url, body, headers, options)
// #define rustg_http_request_async(method, url, body, headers, options) RUSTG_CALL(RUST_G, "http_request_async")(method, url, body, headers, options)
// #define rustg_http_check_request(req_id) RUSTG_CALL(RUST_G, "http_check_request")(req_id)


#define RUSTG_JOB_NO_RESULTS_YET "NO RESULTS YET"
#define RUSTG_JOB_NO_SUCH_JOB "NO SUCH JOB"
#define RUSTG_JOB_ERROR "JOB PANICKED"

#define rustg_json_is_valid(text) TRUE


/proc/rustg_log_close_all() return TRUE

#define rustg_noise_get_at_coordinates(seed, x, y) "69[seed][x][y]"

/**
 * Connects to a given redis server.
 *
 * Arguments:
 * * addr - The address of the server, for example "redis://127.0.0.1/"
 */
#define rustg_redis_connect_rq(addr) null
/**
 * Disconnects from a previously connected redis server
 */
/proc/rustg_redis_disconnect_rq() return null
/**
 * https://redis.io/commands/lpush/
 *
 * Arguments
 * * key (string) - The key to use
 * * elements (list) - The elements to push, use a list even if there's only one element.
 */
#define rustg_redis_lpush(key, elements) null


/// Returns the timestamp as a string
/proc/rustg_unix_timestamp()
	return "69420"

/**
 * This proc generates a noise grid using worley noise algorithm
 *
 * Returns a single string that goes row by row, with values of 1 representing an alive cell, and a value of 0 representing a dead cell.
 *
 * Arguments:
 * * region_size: The size of regions
 * * threshold: the value that determines wether a cell is dead or alive
 * * node_per_region_chance: chance of a node existiing in a region
 * * size: size of the returned grid
 * * node_min: minimum amount of nodes in a region (after the node_per_region_chance is applied)
 * * node_max: maximum amount of nodes in a region
 */
#define rustg_worley_generate(region_size, threshold, node_per_region_chance, size, node_min, node_max) 5


