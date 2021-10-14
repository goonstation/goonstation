

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
			user.u_equip(I)
			var/new_object = new type_to_break_into(get_turf(user))
			if(stay_in_hand)
				if(isitem(new_object))
					var/obj/item/new_item = new_object
					user.put_in_hand_or_drop(new_item)
			qdel(I)


/datum/component/fragile_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	. = ..()
