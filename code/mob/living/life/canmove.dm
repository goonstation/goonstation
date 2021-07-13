
/datum/lifeprocess/canmove
	process()
		//check_if_buckled()
		if (owner.buckled)
			if (owner.buckled.loc != owner.loc)
				owner.buckled.buckled_guy = null
				owner.buckled = null
				return ..()
			owner.lying = istype(owner.buckled, /obj/stool/bed) || istype(owner.buckled, /obj/machinery/conveyor)
			if (owner.lying)
				owner.drop_item()
			owner.set_density(initial(owner.density))
		else
			if (!owner.lying)
				owner.set_density(initial(owner.density))
			else
				owner.set_density(0)

		//update_canmove

		if (HAS_MOB_PROPERTY(owner, PROP_CANTMOVE))
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
