/datum/component/reagent_dipped

/datum/component/reagent_dipped/Initialize()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ITEM_HIT_MOB), .proc/stab_transfer)

/datum/component/reagent_dipped/proc/stab_transfer(var/obj/item/I, var/mob/M, var/mob/user, var/damage)
	if (I.reagents && I.reagents.total_volume)
		logTheThing("combat", user, M, "used [I] on %target% (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(I)]")
		I.reagents.trans_to(M, damage)
		boutput(world, "[I.type], [M.type], [user.type], [damage]")


