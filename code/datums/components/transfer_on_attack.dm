/datum/component/transfer_on_attack
	var/trans_amt = 5

/datum/component/transfer_on_attack/Initialize(var/trans_amt)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	if(trans_amt)
		src.trans_amt=trans_amt
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_POST), .proc/stab_transfer)

/datum/component/transfer_on_attack/proc/stab_transfer(var/obj/item/I, var/mob/M, var/mob/user, var/damage, var/armor_mod)
	if (I.reagents && I.reagents.total_volume)
		logTheThing("combat", user, M, "used [I] on %target% (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(I)]")
		I.reagents.trans_to(M, max(src.trans_amt / 4, (damage + armor_mod == 0 ? 0 : src.trans_amt * ((damage) / (damage + armor_mod))))) //pierce low amounts of armor

/datum/component/transfer_on_attack/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	. = ..()
