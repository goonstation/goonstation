
// i think its slightly faster to do this with compiler macros instead of procs. i might be a moron, not sure - drsingh
// it is. no comment on the moron bit. -- marq
#define ismob(x) istype(x, /mob)
#define isobserver(x) istype(x, /mob/dead)
#define isadminghost(x) x.client && x.client.holder && rank_to_level(x.client.holder.rank) >= LEVEL_MOD && (istype(x, /mob/dead/observer) || istype(x, /mob/dead/target_observer)) // For antag overlays.

#define isliving(x) istype(x, /mob/living)

#define iscarbon(x) istype(x, /mob/living/carbon)
#define ismonkey(x) (istype(x, /mob/living/carbon/human) && istype(x:mutantrace, /datum/mutantrace/monkey))
#define ishuman(x) istype(x, /mob/living/carbon/human)
#define iscritter(x) istype(x, /obj/critter)
#define isintangible(x) istype(x, /mob/living/intangible)
#define ismobcritter(x) istype(x, /mob/living/critter)

#define issilicon(x) istype(x, /mob/living/silicon)
#define isrobot(x) istype(x, /mob/living/silicon/robot)
#define ishivebot(x) istype(x, /mob/living/silicon/hivebot)
#define ismainframe(x) istype(x, /mob/living/silicon/hive_mainframe)
#define isAI(x) (istype(x, /mob/living/silicon/ai) || istype (x, /mob/dead/aieye))
#define isAIeye(x) istype (x, /mob/dead/aieye)
#define isshell(x) istype(x, /mob/living/silicon/hivebot/eyebot)//istype(x, /mob/living/silicon/shell)
#define isdrone(x) istype(x, /mob/living/silicon/hivebot/drone)
#define isghostdrone(x) istype(x, /mob/living/silicon/ghostdrone)

#define iscube(x) (istype(x, /mob/living/carbon/cube))
#define isvirtual(x) istype(x, /mob/living/carbon/human/virtual)
#define isVRghost(x) (istype(x, /mob/living/carbon/human/virtual) && x:isghost)
#define issmallanimal(x) istype(x, /mob/living/critter/small_animal)
#define isghostcritter(x) (istype(x, /mob/living/critter) && x:ghost_spawned)
#define ishelpermouse(x) (istype(x, /mob/living/critter/small_animal/mouse/weak/mentor))//mentor and admin mice
