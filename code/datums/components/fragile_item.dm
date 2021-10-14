

/datum/component/fragile_item
	var/safe_attacks // number of attacks this item can perform before having a chance to break
	var/probability_of_breaking
	var/stay_in_hand
	var/type_to_break_into // type that's spawned in place of this item when it breaks

/datum/component/fragile_item/Initialize(var/safe_attacks, var/probability_of_breaking, var/stay_in_hand, var/type_to_break_into)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.safe_attacks = number_of_safe_attacks
	src.probability_of_breaking = probability_of_breaking
	src.stay_in_hand = stay_in_hand
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_POST), .proc/potentially_break)

/datum/component/fragile_item/proc/potentially_break(var/obj/item/I, var/mob/M, var/mob/user, var/damage)
	if(safe_attacks > 0)
		safe_attacks--
		return
	else
		if(prob(probability_of_breaking))


/*
	if (I.reagents && I.reagents.total_volume)
		logTheThing("combat", user, M, "used [I] on [constructTarget(M,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(I)]")
		I.reagents.trans_to(M, trans_amt * damage / 10) //amount transferred is based on damage dealt
*/

/datum/component/fragile_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	. = ..()
