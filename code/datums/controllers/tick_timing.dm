/// Used to measure wall-clock time between server ticks
#define TICK_TIMING_TIMER "tick_timing"
/// Converts deciseconds to microseconds
#define DS_TO_US(ds) ((ds) / (1 MICRO SECOND))
/// Reset the timer after this many microseconds - (f32 memes, 1<<24 minus some headroom)
#define TICK_TIMING_RESET_US DS_TO_US(10 SECONDS)
/// Fraction of the difference [global.tick_length_ratio] moves each tick when ticks get longer
#define TICK_TIMING_RISE (1/8)
/// Fraction it moves when ticks get shorter. Higher than RISE because a glide still running when the next step arrives snaps forward
#define TICK_TIMING_FALL (1/4)
/// A tick counts as at most this many times the current estimate, so one lag spike doesn't slow every glide after it
#define TICK_TIMING_SPIKE_CAP 1.5
/// Lower bound on one tick's measured ratio, so timing jitter or a bad timer read can't drag the estimate down
#define TICK_TIMING_MIN_RATIO 0.5

/// How long server ticks are really taking compared to world.tick_lag. 1 is on time, 1.5 is ticks taking 50% longer
var/global/tick_length_ratio = 1
/// Multiply glide sizes by this so a glide lasts as long as a tick actually takes.
/// 1 when ticks are on time, below 1 when they overrun
var/global/glide_size_multiplier = 1

/world/Tick()
	/// When the last tick started, in microseconds
	var/static/last_start_us = null
	var/elapsed_us = rustg_time_microseconds(TICK_TIMING_TIMER)
	// How far into this tick we already are, in microseconds.
	// Tick() runs after sleeping procs, so that point moves around from tick to tick.
	var/usage_us = DS_TO_US(world.tick_usage / 100 * world.tick_lag)
	if (!isnull(last_start_us))
		var/ratio = clamp(
			// This tick's start is elapsed_us - usage_us. Minus the last start, that's how long the last tick really took.
			// Dividing by tick_lag relativizes it to tick_lag: 1 is on time, 2 is twice as long.
			(elapsed_us - usage_us - last_start_us) / DS_TO_US(world.tick_lag),
			TICK_TIMING_MIN_RATIO, // jitter or a bad timer read can't drag it under this
			global.tick_length_ratio * TICK_TIMING_SPIKE_CAP) // a spike counts as at most 1.5x the current estimate
		// Move the estimate part of the way toward this tick - faster on the way down than up
		global.tick_length_ratio += (ratio - global.tick_length_ratio) * (ratio > global.tick_length_ratio ? TICK_TIMING_RISE : TICK_TIMING_FALL)
		global.glide_size_multiplier = min(1, 1 / global.tick_length_ratio) // Longer ticks mean slower glides.
	// Every ~10 s, restart the timer from zero before we hit float memes
	if (elapsed_us > TICK_TIMING_RESET_US)
		rustg_time_reset(TICK_TIMING_TIMER)
		elapsed_us = 0
	// Remember when this tick started for the next Tick().
	// After a reset this is measured from the new zero (so it's negative), which keeps the next subtraction lined up
	last_start_us = elapsed_us - usage_us

#undef TICK_TIMING_TIMER
#undef DS_TO_US
#undef TICK_TIMING_RESET_US
#undef TICK_TIMING_RISE
#undef TICK_TIMING_FALL
#undef TICK_TIMING_SPIKE_CAP
#undef TICK_TIMING_MIN_RATIO
