#define DISORIENT_MISSTEP_CHANCE 40

#define attempt_move(mob) mob.internal_process_move(mob.client ? mob.client.key_state : 0)

/// Glide size (pixels per server tick) for moving one tile over `ticks` server ticks
#define TICKS_TO_GLIDE_SIZE(ticks) (world.icon_size / (ticks) * global.glide_size_multiplier)
/// Glide size (pixels per server tick) for moving one tile every `delay` ds, see [TICKS_TO_GLIDE_SIZE]
#define DELAY_TO_GLIDE_SIZE(delay) TICKS_TO_GLIDE_SIZE((delay) / world.tick_lag)
