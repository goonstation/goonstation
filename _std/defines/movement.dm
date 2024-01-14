//various sprint flags go here
#define SPRINT_NORMAL 0
#define SPRINT_BAT 1
#define SPRINT_BAT_CLOAKED 2
#define SPRINT_FIRE 4

#define DISORIENT_MISSTEP_CHANCE 40

#define attempt_move(mob) mob.internal_process_move(mob.client ? mob.client.key_state : 0)
