//Keelin: Just butchering #define s a bit here, don't mind me.
#define CONCALL(OBJ, TYPE, CALL, VARNAME) var##TYPE/##VARNAME=OBJ;if(istype(##VARNAME)) ##VARNAME.##CALL

// comment this line to disable or enable spawn debugging. it's pretty cheap and safe for the live servers though.
// #define ENABLE_SPAWN_DEBUG
// #define ENABLE_SPAWN_DEBUG_2

// for this to work, use SPAWN_DBG() instead of spawn(). thank you for loving pupkin. -singh
#ifdef ENABLE_SPAWN_DEBUG
var/list/global_spawn_dbg = list()
#define SPAWN_DBG(x) global_spawn_dbg["spawn at [__FILE__]:[__LINE__]"]++; spawn(x)
#elif defined(ENABLE_SPAWN_DEBUG_2)
var/list/detailed_spawn_dbg = list()
#define SPAWN_DBG(x) detailed_spawn_dbg += list(list("[__FILE__]:[__LINE__]", TIME, TIME + x)); spawn(x)
#else
#define SPAWN_DBG(x) spawn(x)
#endif

#define isclient(x) istype(x, /client)
#define ismind(x) istype(x, /datum/mind)

#define ishellbanned(x) x?.client?.hellbanned

#define isalcoholresistant(x) ((x.bioHolder && x.bioHolder.HasEffect("resist_alcohol")) || (x.traitHolder && x.traitHolder.hasTrait("training_drinker")))

// hi here's some flockdrone BS - cirr
#define isfeathertile(x) (istype(x, /turf/simulated/floor/feather) || istype(x, /turf/simulated/wall/auto/feather))
#define isflock(x) (istype(x, /mob/living/intangible/flock) || istype(x, /mob/living/critter/flock))
#define isflockstructure(x) (istype(x, /obj/flock_structure))

// pick strings from cache-- code/procs/string_cache.dm
#define pick_string(filename, key) pick(strings(filename, key))

#define DEBUG_MESSAGE(x) if (debug_messages) message_coders(x)
#define DEBUG_MESSAGE_VARDBG(x,d) if (debug_messages) message_coders_vardbg(x,d)
#define __red(x) text("<span class='alert'>[]</span>", x)  //deprecated for some reason
#define __blue(x) text("<span class='notice'>[]</span>", x) //deprecated for some reason

#define TimeOfHour world.timeofday % 36000
//#endif

#define CLEAN(w) html_encode("[w]")

// get_step() with a dir of 0 just gets the turf an atom is on, through any number of nested layers.
// See: http://www.byond.com/forum/?post=2110095
#define get_turf(x) get_step(x, 0)
#define get_area(x) (isarea(x) ? x : get_step(x, 0)?.loc)
#define issimulatedturf(x) istype(x, /turf/simulated)
#define isfloor(x) (istype(x, /turf/simulated/floor) || istype(x, /turf/unsimulated/floor))
#define isrwall(x) (istype(x,/turf/simulated/wall/r_wall)||istype(x,/turf/simulated/wall/auto/reinforced)||istype(x,/turf/unsimulated/wall/auto/reinforced)||istype(x,/turf/simulated/wall/false_wall/reinforced))

#define GET_MANHATTAN_DIST(A, B) ((!(A) || !(B)) ? 0 : abs((A).x - (B).x) + abs((A).y - (B).y))
#define IN_RANGE(A, B, range) (get_dist(A, B) <= (range) && get_step(A, 0).z == get_step(B, 0).z)

#define return_if_overlay_or_effect(x) if (istype(x, /obj/overlay) || istype(x, /obj/effects)) return

// because fuck remembering what stat means every single time
#define isalive(x) (ismob(x) && x.stat == 0)
#define isunconscious(x) (ismob(x) && x.stat == 1)
#define isdead(x) (ismob(x) && x.stat == 2)
#define setalive(x) if (ismob(x)) x.stat = 0
#define setunconscious(x) if (ismob(x)) x.stat = 1
#define setdead(x) if (ismob(x)) x.stat = 2

#define isgrab(x) (istype(x, /obj/item/grab/))

#define RANDOM_HUMAN_VOICE pick(1,2,3)

#define admin_only if(!src.holder) {boutput(src, "Only administrators may use this command."); return}
#define mentor_only if(!src.mentor) {boutput(src, "Only mentors may use this command."); return}
#define usr_admin_only if(usr && usr.client && !usr.client.holder) {boutput(usr, "Only administrators may use this command."); return}

#define GLOBAL_PROC "THIS_IS_A_GLOBAL_PROC_CALLBACK" //used instead of null because clients can be callback targets and then go null from disconnect before invoked, and we need to be able to differentiate when that happens or when it's just a global proc.
#define CALLBACK new /datum/callback //not a macro to make it 510 compatible

#ifdef SPACEMAN_DMM // just don't ask
#define START_TRACKING
#define STOP_TRACKING
#else
// sometimes we want to have all objects of a certain type stored (bibles, staffs of cthulhu, ...)
// to do that add START_TRACKING to New (or unpooled) and STOP_TRACKING to disposing, then use by_type[/obj/item/storage/bible] to access the list of things
#define START_TRACKING do { var/_type = text2path(replacetext("[.disposing]", "/disposing", "")); if(!by_type[_type]) { by_type[_type] = list(src) } else { by_type[_type].Add(src) } } while (FALSE)
#define STOP_TRACKING do { var/_type = text2path(replacetext("[.disposing]", "/disposing", "")); by_type[_type].Remove(src) } while (FALSE)
#endif

// replacement for world.timeofday that shouldn't break around midnight, please use this
#define TIME ((world.timeofday - server_start_time + 24 HOURS) % (24 HOURS))

// cooldown stuff
// assumes that COOLDOWN_OWNER has an (initialized) associative list `cooldowns` (it will store the timestamp when the thing goes off cooldown next)
// returns time left on the cooldown with id ID, and if it was 0 it sets it to DELAY
#define ON_COOLDOWN(COOLDOWN_OWNER, ID, DELAY) (max(COOLDOWN_OWNER.cooldowns[ID] - TIME, 0) || (COOLDOWN_OWNER.cooldowns[ID] = TIME + DELAY) && 0)
// the same thing but uses src as the cooldown owner and generates the ID based on the current proc's / verb's path
#define PROC_ON_COOLDOWN(DELAY) ON_COOLDOWN(src, "[....]", DELAY)
/* Example use:
/mob/verb/spam_chat()
	if(PROC_ON_COOLDOWN(1 MINUTE))
		boutput(src, "Verb on cooldown for [time_to_text(PROC_ON_COOLDOWN(0))].")
		return
	actually_spam_the_chat()
*/

//used for pods
#define BOARD_DIST_ALLOWED(M,V) ( ((V.bound_width > world.icon_size || V.bound_height > world.icon_size) && (M.x > V.x || M.y > V.y) && (get_dist(M, V) <= 2) ) || (get_dist(M, V) <= 1) )


// num2hex, hex2num
#define num2hex(X, len) num2text(X, len, 16)

#define hex2num(X) text2num(X, 16)

#define reset_anchored(M) do{\
if(istype(M, /mob/living/carbon/human)){\
	var/mob/living/carbon/human/HumToDeanchor = M;\
	if(HumToDeanchor.shoes?.magnetic || HumToDeanchor.mutantrace?.anchor_to_floor){\
		HumToDeanchor.anchored = 1;}\
	else{\
		HumToDeanchor.anchored = 0}}\
else{\
	M.anchored = 0;}}\
while(FALSE)


#define ADD_STATUS_LIMIT(target, group, value)\
	do { \
		if (length(target.statusLimits)) { \
			target.statusLimits[group] = value; \
		} else { \
			target.statusLimits = list(group = value);\
		} \
	} while (0)

#define REMOVE_STATUS_LIMIT(target, group)\
	do { \
		target.statusLimits -= group;\
	} while (0)


/// isnum() returns TRUE for NaN. Also, NaN != NaN. Checkmate, BYOND.
#define isnan(x) ( (x) != (x) )

#define isinf(x) (isnum((x)) && (((x) == text2num("inf")) || ((x) == text2num("-inf"))))

/// NaN isn't a number, damn it. Infinity is a problem too.
#define isnum_safe(x) ( isnum((x)) && !isnan((x)) && !isinf((x)) ) //By ike709


var/global/list/addr_padding = list("00000", "0000", "000", "00", "0", "")
#define BUILD_ADDR(TYPE_ID, NUM) "\[0x[TYPE_ID][addr_padding[length(num2text(NUM, 0, 16))]][num2text(NUM, 0, 16)]\]"