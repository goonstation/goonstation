//various sprint flags go here
#define SPRINT_NORMAL 0
#define SPRINT_BAT 1
#define SPRINT_BAT_CLOAKED 2
#define SPRINT_SNIPER 4
#define SPRINT_FIRE 8
#define SPRINT_DESIGNATOR 16

#define DISORIENT_MISSTEP_CHANCE 40

#define attempt_move(mob) mob.internal_process_move(mob.client ? mob.client.key_state : 0)
