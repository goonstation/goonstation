
// i think its slightly faster to do this with compiler macros instead of procs. i might be a moron, not sure - drsingh
// it is. no comment on the moron bit. -- marq

//this is the home for checks of mob types

/// Returns true if the given x is an observer
#define isobserver(x) istype(x, /mob/dead)
/// Returns true if the given x is an observer and an admin
#define isadminghost(x) x.client && x.client.holder && rank_to_level(x.client.holder.rank) >= LEVEL_MOD && (istype(x, /mob/dead/observer) || istype(x, /mob/dead/target_observer)) // For antag overlays.

/// Returns true if the given x is a mob/living type
#define isliving(x) istype(x, /mob/living)

#define iscarbon(x) istype(x, /mob/living/carbon)
#define ismonkey(x) (istype(x, /mob/living/carbon/human) && istype(x:mutantrace, /datum/mutantrace/monkey))
#define isnpc(x) istype(x, /mob/living/carbon/human/npc)
#define isnpcmonkey(x) (istype(x,/mob/living/carbon/human/npc/monkey) && istype(x:mutantrace, /datum/mutantrace/monkey))
#define ishuman(x) istype(x, /mob/living/carbon/human)
#define iscow(x) (istype(x, /mob/living/carbon/human) && istype(x:mutantrace, /datum/mutantrace/cow))
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
#define ismegakrampus(x) (istype(x, /mob/living/carbon/cube/meat/krampus/telekinetic))
#define isvirtual(x) istype(x, /mob/living/carbon/human/virtual)
#define isVRghost(x) (istype(x, /mob/living/carbon/human/virtual) && x:isghost)
#define issmallanimal(x) istype(x, /mob/living/critter/small_animal)
#define isghostcritter(x) (istype(x, /mob/living/critter) && x:ghost_spawned)
#define ishelpermouse(x) (istype(x, /mob/living/critter/small_animal/mouse/weak/mentor))//mentor and admin mice

/// Returns true if x is a new player mob (what u r if ur in the lobby screen, usually)
#define isnewplayer(x) (istype(x, /mob/new_player))

/// Returns true if this mob immune to breathing in smoke?
#define issmokeimmune(x) (isobserver(x) || isintangible(x) || issilicon(x) || (ismob(x) && ((x?.wear_mask && (x.wear_mask.c_flags & BLOCKSMOKE || (x.wear_mask.c_flags & MASKINTERNALS && x.internal))) || ischangeling(x) || HAS_MOB_PROPERTY(x, PROP_REBREATHING) || HAS_MOB_PROPERTY(x, PROP_BREATHLESS) || isdead(x))))
