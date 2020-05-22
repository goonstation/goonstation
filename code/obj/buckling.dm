/obj/proc/buckle(mob/living/to_buckle, mob/living/user, force) // try to buckle a mob into this object
	if (force || can_buckle(to_buckle, user))
		buckle_mob(to_buckle, user)

/obj/proc/unbuckle(mob/living/to_unbuckle, mob/living/user, force) // try to unbuckle a mob from this object
	if (force || can_unbuckle(to_unbuckle, user))
		unbuckle_mob(to_unbuckle, user)

/obj/proc/buckle_mob(mob/living/to_buckle, mob/user = null) // Do the "technical" part of actual buckling. It will absolutely happen, no "but should we really?" checks here.
	if (buckled_mob)
		if (buckled_mob != to_buckle)
			unbuckle_mob(buckled_mob)
		else // trying to buckle the same person twice.
			return
	if (to_buckle.buckled && to_buckle.buckled != src)
		to_buckle.buckled.unbuckle_mob(to_buckle)
	buckled_mob = to_buckle

	mob_buckled(to_buckle, user)
	to_buckle.buckled(src)

/obj/proc/unbuckle_mob(mob/living/to_unbuckle, mob/user = null) // Do the technical bits of unbuckling. It will happen, no checks here.
	if (buckled_mob == to_unbuckle)
		buckled_mob = null
		mob_unbuckled(to_unbuckle, user)
		to_unbuckle.unbuckled(src)
	if (to_unbuckle.buckled == src)
		to_unbuckle.buckled = null

/obj/proc/can_buckle(mob/living/to_buckle, mob/living/user)
	if (to_buckle.buckled && to_buckle.buckled != src) // if the mob is already buckled to something, check if it can unbuckle
		return to_buckle.buckled.can_unbuckle(to_buckle, user)
	return TRUE

/obj/proc/can_unbuckle(mob/to_unbuckle, mob/user)
	return TRUE

/obj/proc/mob_buckled(mob/buckled_mob, mob/user) // object reacts to having a mob buckled to it here
	return

/obj/proc/mob_unbuckled(mob/unbuckled_mob, mob/user) // object reacts to having a mob unbuckled from it here
	return

/mob/living/proc/buckled(obj/buckled_obj, mob/user) // mob reacts to being buckled here
	APPLY_MOB_PROPERTY(src, PROP_CANTMOVE, "buckled")

/mob/living/proc/unbuckled(obj/buckled_obj, mob/user) // mob reacts to being unbuckled here
	REMOVE_MOB_PROPERTY(src, PROP_CANTMOVE, "buckled")
