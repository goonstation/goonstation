/datum/component/reagent_dipped
	var/trans_amt = 5

/datum/component/reagent_dipped/Initialize(var/trans_amt)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	if(trans_amt)
		src.trans_amt=trans_amt
	RegisterSignal(parent, list(COMSIG_ITEM_HIT_MOB), .proc/stab_transfer)

/datum/component/reagent_dipped/proc/stab_transfer(var/obj/item/I, var/mob/M, var/mob/user, var/damage, var/armor_mod)
	if (I.reagents && I.reagents.total_volume)
		logTheThing("combat", user, M, "used [I] on %target% (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(I)]")
		I.reagents.trans_to(M, max(src.trans_amt / 4, (damage + armor_mod == 0 ? 0 : src.trans_amt * ((damage) / (damage + armor_mod))))) //pierce low amounts of armor


