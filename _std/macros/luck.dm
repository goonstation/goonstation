var/global/global_luck = 0

#define LOCAL_LUCK(thing) (GET_ATOM_PROPERTY(thing, PROP_ATOM_LUCK) + GET_ATOM_PROPERTY(usr, PROP_ATOM_LUCK) + global.global_luck)

#define LUCK_CALC(x, probfunc) (probfunc(x) || probfunc(LOCAL_LUCK(local_object) * 10) && probfunc(x))
#define BAD_LUCK_CALC(x, probfunc) (probfunc(x) && !(probfunc(LOCAL_LUCK(local_object) * 10) && probfunc(100 - x)))

//couldn't figure out a way to build this entirely out of macros so we'll deal with the proc overhead for now
// #define luckprob(prob_value, local_object, mult...) !isnull(mult) ? LUCK_CALC(prob_value, probmult) : LUCK_CALC(prob_value, prob)

///Used when luck should make the chance MORE likely (ie you get candy if it succeeds)
/proc/luckprob(prob_value, atom/local_object = src, mult = null)
	if (!isnull(mult))
		return LUCK_CALC(prob_value, probmult)
	else
		return LUCK_CALC(prob_value, prob)

///Used when luck should make the chance LESS likely (ie you DIE INSTANTLY if it succeeds)
/proc/badluckprob(prob_value, atom/local_object = src, mult = null)
	if (!isnull(mult))
		return BAD_LUCK_CALC(prob_value, probmult)
	else
		return BAD_LUCK_CALC(prob_value, prob)

#undef LOCAL_LUCK
#undef LUCK_CALC
#undef BAD_LUCK_CALC


/datum/targetable/make_lucky
	name = "Make lucky"
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		. = ..()
		APPLY_ATOM_PROPERTY(target, PROP_ATOM_LUCK, usr, 10)
		target.color = "green"
