/datum/component/fragile_item
	var/safe_hits // number of attacks this item can perform safely before having any chance to break
	var/probability_of_breaking // after we run out of safe_hits, every further hit has prob(this var) to break
	var/stay_in_hand // will try to put new broken into item back into user's hand if possible
	var/type_to_break_into // type that's spawned in place of this item when it breaks, i.e. of a glass shard
	var/sound_to_play_on_breaking

/datum/component/fragile_item/Initialize(var/safe_hits, var/probability_of_breaking, var/stay_in_hand, var/type_to_break_into = /obj/item/raw_material/shard/glass, var/sound_to_play_on_breaking = "sound/impact_sounds/Crystal_Shatter_1.ogg")
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.safe_hits = safe_hits
	src.probability_of_breaking = probability_of_breaking
	src.stay_in_hand = stay_in_hand
	src.type_to_break_into = type_to_break_into
	src.sound_to_play_on_breaking = sound_to_play_on_breaking

	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_POST), .proc/on_after_attack)
	RegisterSignal(parent, list(COMSIG_MOVABLE_THROW_END), .proc/on_after_throw)

/datum/component/fragile_item/proc/on_after_attack(var/obj/item/I, var/mob/M, var/mob/user, var/damage)
	potentially_break_melee_swing(I, user)

/datum/component/fragile_item/proc/on_after_throw(var/obj/item/thrown_thing)
	potentially_break_thrown(thrown_thing)

/datum/component/fragile_item/proc/potentially_break_melee_swing(var/obj/item/I, var/mob/user, var/thrown)
	if(safe_hits > 0)
		safe_hits--
		return
	else
		if(prob(probability_of_breaking))
			user.u_equip(I)
			var/new_object = new type_to_break_into(get_turf(user))
			if(stay_in_hand)
				if(isitem(new_object))
					var/obj/item/new_item = new_object
					user.put_in_hand_or_drop(new_item)
			user.visible_message("<span class='alert'>As [user] swings with the [I], a shattering sound echoes, leaving behind \a [new_object]</span>")
			playsound(get_turf(new_object), sound_to_play_on_breaking, 80, 1)
			qdel(I)
			return

/datum/component/fragile_item/proc/potentially_break_thrown(var/obj/item/thrown_item)
	if(safe_hits > 0)
		safe_hits--
		return
	else
		if(prob(probability_of_breaking))
			var/new_object = new type_to_break_into(get_turf(thrown_item))
			thrown_item.visible_message("<span class='alert'>As [thrown_item] stops, a shattering sound echoes, leaving behind \a [new_object]</span>")
			playsound(get_turf(thrown_item), sound_to_play_on_breaking, 80, 1)
			qdel(thrown_item)
			return

/datum/component/fragile_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	. = ..()


/obj/item/knife/butcher/fragile
	name = "bacon sword"

	New()
		. = ..()
		AddComponent(/datum/component/fragile_item, safe_hits = 3, probability_of_breaking = 100, stay_in_hand = 1, type_to_break_into = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon)
