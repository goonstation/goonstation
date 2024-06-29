#define DISORIENT_MISSTEP_CHANCE 40

#define attempt_move(mob) mob.internal_process_move(mob.client ? mob.client.key_state : 0)
