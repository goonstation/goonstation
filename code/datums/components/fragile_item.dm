/**
  * Defines a "fragile item" component.
  *
  * An item with this component will be prone to breaking when it's used to attack or thrown and as a result being replaced by another object (i.e. a glass shard).
  *
  * The component defines default values but they can also be manually set when initializing the component.
  */
/datum/component/fragile_item
	/// The number of violent interactions (attacks with it, being thrown) this item can perform safely before rolling for chances to break.
	var/safe_hits
	/// When safe_hits run out, every further violent interaction has a prob(this_variable) to break.
	var/probability_of_breaking
	/// If set, the item will try to put itself back into the user's hand upon breaking (will only work for item types).
	var/stay_in_hand
	/// When the item breaks, it will be replaced by the type defined by this variable.
	var/type_to_break_into
	/// Sound played at the location of the item breaking.
	var/sound_to_play_on_breaking

TYPEINFO(/datum/component/fragile_item)
	initialization_args = list(
		ARG_INFO("safe_hits", DATA_INPUT_NUM, "Buffer of hits before rolling for breaking", 3),
		ARG_INFO("probability_of_breaking", DATA_INPUT_NUM, "Chance that the item will break once all safe hits are consumed", 40),
		ARG_INFO("stay_in_hand", DATA_INPUT_BOOL, "If the item left behind should stay in the user's hand", TRUE),
		ARG_INFO("type_to_break_into", DATA_INPUT_NULL, "Path of stuff to break into", /obj/item/raw_material/shard/glass),
		ARG_INFO("sound_to_play_on_breaking", DATA_INPUT_TEXT, "Sound effect that plays when the item breaks", 'sound/impact_sounds/Crystal_Shatter_1.ogg')
	)
/datum/component/fragile_item/Initialize(var/safe_hits = 3, var/probability_of_breaking = 40, var/stay_in_hand = 1, var/type_to_break_into = /obj/item/raw_material/shard/glass, var/sound_to_play_on_breaking = 'sound/impact_sounds/Crystal_Shatter_1.ogg')
	. = ..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.safe_hits = safe_hits
	src.probability_of_breaking = probability_of_breaking
	src.stay_in_hand = stay_in_hand
	src.type_to_break_into = type_to_break_into
	src.sound_to_play_on_breaking = sound_to_play_on_breaking

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_POST, .proc/on_after_attack)
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_END, .proc/on_after_throw)

/datum/component/fragile_item/proc/on_after_attack(var/obj/item/I, var/mob/M, var/mob/user, var/damage)
	potentially_break_melee_swinged(I, user)

/datum/component/fragile_item/proc/on_after_throw(var/obj/item/thrown_thing)
	potentially_break_thrown(thrown_thing)

/datum/component/fragile_item/proc/potentially_break_melee_swinged(var/obj/item/I, var/mob/user)
	if(safe_hits > 0)
		safe_hits--
		return
	else
		if(prob(probability_of_breaking))
			user.u_equip(I)
			if(!type_to_break_into)
				user.visible_message("<span class='alert'>As [user] swings with the [I], a shattering sound echoes, leaving behind nothing but dust!</span>")
			else
				var/new_object = new type_to_break_into(get_turf(user))
				if(stay_in_hand)
					if(isitem(new_object))
						var/obj/item/new_item = new_object
						user.put_in_hand_or_drop(new_item)
				user.visible_message("<span class='alert'>As [user] swings with the [I], a shattering sound echoes, leaving behind \a [new_object]!</span>")
			playsound(get_turf(user), sound_to_play_on_breaking, 80, 1)
			qdel(I)
			return

/datum/component/fragile_item/proc/potentially_break_thrown(var/obj/item/thrown_item)
	if(safe_hits > 0)
		safe_hits--
		return
	else
		if(prob(probability_of_breaking))
			SPAWN(0)
				if(!type_to_break_into)
					thrown_item.visible_message("<span class='alert'>As [thrown_item] stops, a shattering sound echoes, leaving nothing but dust!</span>")
				else
					var/new_object = new type_to_break_into(get_turf(thrown_item))
					thrown_item.visible_message("<span class='alert'>As [thrown_item] stops, a shattering sound echoes, leaving behind \a [new_object]!</span>")
				playsound(get_turf(thrown_item), sound_to_play_on_breaking, 80, 1)
				qdel(thrown_item)
				return

/datum/component/fragile_item/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	UnregisterSignal(parent, COMSIG_MOVABLE_THROW_END)
	. = ..()
