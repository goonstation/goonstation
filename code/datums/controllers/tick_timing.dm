/// Used to measure wall-clock time between server ticks
#define TICK_TIMING_TIMER "tick_timing"
/// Reset the timer after this many microseconds (10 s) - (f32 memes, 1<<24 minus some headroom)
#define TICK_TIMING_RESET_US 10000000
/// Fraction of the difference [global.tick_length_ratio] moves each tick when ticks get longer
#define TICK_TIMING_RISE (1/8)
/// Fraction it moves when ticks get shorter. Higher than RISE because a glide still running when the next step arrives snaps forward
#define TICK_TIMING_FALL (1/4)
/// A tick counts as at most this many times the current estimate, so one lag spike doesn't slow every glide after it
#define TICK_TIMING_SPIKE_CAP 1.5
/// Lower bound on one tick's measured ratio, so timing jitter or a bad timer read can't drag the estimate down
#define TICK_TIMING_MIN_RATIO 0.5

/// Smoothed wall-clock length of a server tick, as a multiple of world.tick_lag (1 = on time)
var/global/tick_length_ratio = 1
/// Multiply glide sizes by this so a glide lasts as long as a tick actually takes.
/// 1 when ticks are on time, below 1 when they overrun
var/global/glide_size_multiplier = 1

/world/Tick()
	/// When the last tick started, in microseconds
	var/static/last_start_us = null
	var/elapsed_us = rustg_time_microseconds(TICK_TIMING_TIMER)
	// world.tick_usage is the percent of tick_lag already spent this tick, so subtract it to get when this tick started. The tick's length is the gap between two starts.
	var/usage_us = world.tick_usage * world.tick_lag * 1000
	if (!isnull(last_start_us))
		var/ratio = clamp((elapsed_us - usage_us - last_start_us) / (world.tick_lag * 100000), TICK_TIMING_MIN_RATIO, global.tick_length_ratio * TICK_TIMING_SPIKE_CAP)
		global.tick_length_ratio += (ratio - global.tick_length_ratio) * (ratio > global.tick_length_ratio ? TICK_TIMING_RISE : TICK_TIMING_FALL)
		global.glide_size_multiplier = min(1, 1 / global.tick_length_ratio)
	if (elapsed_us > TICK_TIMING_RESET_US)
		rustg_time_reset(TICK_TIMING_TIMER)
		elapsed_us = 0
	// After a reset this tick's start is measured from the new zero, so the next tick's math still lines up
	last_start_us = elapsed_us - usage_us

#undef TICK_TIMING_TIMER
#undef TICK_TIMING_RESET_US
#undef TICK_TIMING_RISE
#undef TICK_TIMING_FALL
#undef TICK_TIMING_SPIKE_CAP
#undef TICK_TIMING_MIN_RATIO
