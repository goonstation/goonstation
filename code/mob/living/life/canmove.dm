
/datum/lifeprocess/canmove
	process()
		//rescue lost mobs??
		/*
		if(QDELETED(owner.loc) && !QDELETED(owner) && !isdead(owner))
			message_admins("[key_name(owner)] was stranded in nullspace, and sent to arrivals.")
			owner.set_loc(pick_landmark(LANDMARK_LATEJOIN, locate(150, 150, 1)))
*/

		//check_if_buckled()
		if (owner.buckled)
			if (owner.buckled.loc != owner.loc)
				if(istype(owner.buckled, /obj/stool))
					owner.buckled.unbuckle()
					owner.buckled.buckled_guy = null
				owner.buckled = null
				return ..()
			owner.set_density(initial(owner.density))
		else
			if (!owner.lying)
				owner.set_density(initial(owner.density))
			else
				owner.set_density(0)

		//update_canmove

		if (HAS_ATOM_PROPERTY(owner, PROP_MOB_CANTMOVE))
			owner.canmove = 0
			return ..()

		if (owner.buckled && owner.buckled.anchored)
			if (istype(owner.buckled, /obj/stool/chair)) //this check so we can still rotate the chairs on their slower delay even if we are anchored
				var/obj/stool/chair/chair = owner.buckled
				if (!chair.rotatable)
					owner.canmove = 0
					return ..()
			else
				owner.canmove = 0
				return ..()

		if (owner.throwing & (THROW_CHAIRFLIP | THROW_GUNIMPACT | THROW_SLIP))
			owner.canmove = 0
			return ..()

		owner.canmove = 1

		..()
