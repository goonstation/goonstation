#define RELEASE_ANIMAL 0
#define TRAP_ANIMAL 1

/// Can store mob/living/critter/small_animal inside.
/obj/item/pet_carrier
	name = "pet carrier"
	desc = "A surprisingly roomy carrier for small animals."
	icon = 'icons/obj/items/pet_carrier.dmi'
	icon_state = "carrier-full"
	item_state = "carrier-open"
	w_class = W_CLASS_BULKY
	two_handed = TRUE

	/// The icon_state for the src.trap_animal() actionbar.
	var/trap_animal_icon_state = "carrier-full"
	/// The icon_state for the src.release_animal() actionbar.
	var/release_animal_icon_state = "carrier-full-open"

	// Alpha mask to cut out the animal on non-transparent pixels.
	var/carrier_alpha_mask = "carrier-mask"
	/// Grate object to be held in src.vis_contents
	var/obj/dummy/grate_proxy
	/// Proxy object for storing the vis_contents of each occupant, which itself is contained in the vis_contents of the parent carrier.
	var/obj/dummy/vis_contents_proxy

	// Overlay and base icon state names.
	var/grate_open_icon_state = "grate-open"
	var/grate_closed_icon_state = "grate-closed"
	var/carrier_front_icon_state = "carrier-front"
	var/carrier_rear_icon_state = "carrier-rear"

	// Carrier item state names.
	var/carrier_open_item_state = "carrier-open"
	var/carrier_closed_item_state = "carrier-closed"

	/// Carrier-related (grate_proxy, vis_contents_proxy) vis_flags.
	var/carrier_vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	/// Animal-specific vis_flags.
	var/animal_vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

	/// By default, the carrier can only fit small animals. Override this with FALSE to make it not so.
	var/small_animals_only = TRUE
	/// If FALSE, an occupant cannot escape the carrier on their own.
	var/can_break_out = TRUE
	/// How many animals can fit inside the crate. Usually not overridden by anything, this is to let the system be permissive for var-editing.
	var/carrier_max_capacity = 1
	/// The probability that an occupant can break out per *flip, from 0 to 100.
	var/break_out_probability = 10
	/// A list of the current occupants inside the carrier. The mob overlay uses the first animal in the list.
	var/list/mob/living/carrier_occupants = list()
	/// If not null, the pet carrier will spawn with one of this mob on New().
	var/mob/living/default_animal = null

	New()
		..()
		// Replace the initial icon state with an empty version built with a base icon and overlays.
		src.icon_state = "[src.carrier_rear_icon_state]"
		var/image/carrier_front_overlay = new(src.icon, "[src.carrier_front_icon_state]")
		src.UpdateOverlays(carrier_front_overlay, "carrier_front")

		// Instantiate the vis_contents proxy for later.
		src.vis_contents_proxy = new()
		src.vis_contents_proxy.layer = OBJ_LAYER + 0.001
		src.vis_contents_proxy.vis_flags |= src.carrier_vis_flags
		src.vis_contents_proxy.appearance_flags |= KEEP_TOGETHER
		src.vis_contents_proxy.add_filter("carrier-mask", 1, alpha_mask_filter(icon = icon(src.icon, src.carrier_alpha_mask)))
		src.vis_contents.Add(src.vis_contents_proxy)

		// Instantiate the grate.
		src.grate_proxy = new()
		src.grate_proxy.icon = src.icon
		src.grate_proxy.layer = OBJ_LAYER + 0.002
		src.grate_proxy.vis_flags |= src.carrier_vis_flags
		src.vis_contents.Add(src.grate_proxy)

		src.UpdateIcon()

		// Spawn a default animal inside if there is one.
		if (src.default_animal)
			if (!ispath(src.default_animal, /mob/living/critter/small_animal) && src.small_animals_only)
				return
			var/mob/living/spawned_animal = new src.default_animal
			if (spawned_animal)
				src.add_animal(spawned_animal)

	disposing()
		if (length(src.carrier_occupants))
			for (var/occupant in src.carrier_occupants)
				src.eject_animal(occupant)
		src.carrier_occupants = null
		src.overlays = null
		..()

	examine()
		. = ..()
		var/carrier_occupants_length = length(src.carrier_occupants)
		if (carrier_occupants_length)
			// Since you'll basically never see this.
			if (carrier_occupants_length > 1)
				. += "There's a whole zoo inside!"
				return
			else
				. += "It's carrying [src.carrier_occupants[1].name]."

	update_icon()
		..()
		// Update the grate overlay depending on whether or not there's anyone in the carrier.
		if (length(src.carrier_occupants))
			src.grate_proxy.icon_state = "[src.grate_closed_icon_state]"
			src.item_state = "[src.carrier_closed_item_state]"
		else
			src.grate_proxy.icon_state = "[src.grate_open_icon_state]"
			src.item_state = "[src.carrier_open_item_state]"

	attack(mob/M, mob/user)
		if (user.a_intent == INTENT_HARM)
			. = ..()
		if (ismob(M))
			// Disallow mobs that aren't small_animal from fitting in the carrier.
			if (!issmallanimal(M) && src.small_animals_only)
				boutput(user, "<span class='alert'>[M] is a bit too big to fit in [src]!</span>")
				return
			// Disallow going over the carrier's maximum capacity.
			if (src.carrier_max_capacity <= length(src.carrier_occupants))
				boutput(user, "<span class='alert'>[src] is too crowded to fit one more!</span>")
				return
			var/mob/living/target_animal = M
			actions.start(new /datum/action/bar/icon/pet_carrier(target_animal, src, src.icon, src.trap_animal_icon_state, TRAP_ANIMAL), user)
			return
		..()

	attack_self(mob/user)
		if (length(src.carrier_occupants))
			// Remove the first animal in the list of occupants.
			var/mob/living/critter/small_animal/animal_to_remove = src.carrier_occupants[1]
			if (animal_to_remove)
				actions.start(new /datum/action/bar/icon/pet_carrier(animal_to_remove, src, src.icon, src.release_animal_icon_state, RELEASE_ANIMAL), user)
			else
				boutput(user, "<span class='alert'>[src] is without any friends! Aww!</span>")
		..()

	// Ensure that things inside can actually breathe.
	remove_air(amount)
		var/turf/current_turf = get_turf(src)
		. = current_turf.remove_air(amount)

	return_air()
		var/turf/current_turf = get_turf(src)
		. = current_turf.return_air()

	// If allowed, mobs that are inside can try to break out of the cage.
	mob_flip_inside(mob/user)
		..(user)

		if (!src.can_break_out)
			boutput(src, "<span class='alert'>It's no use! You can't leave [src]!</span>")
			return
		if (prob(src.break_out_probability))
			if (length(src.carrier_occupants) > 1)
				for (var/occupant in src.carrier_occupants)
					src.eject_animal(occupant)
				src.visible_message("<span class='alert'>[user] kicks the door of [src] open and OH GOD THEY'RE ALL ESCAPING!</span>")
				return
			src.eject_animal(user)
			src.visible_message("<span class='alert'>[user] kicks the door of [src] open and crawls right out!</span>")
			return
		boutput(user, "<span class='alert'>Maybe this door could give out if you put up some more effort!</span>")

	/// Called when a given mob/user steals an animal after an actionbar.
	proc/trap_animal(mob/living/animal_to_trap, mob/user)
		if (!animal_to_trap)
			return
		if (animal_to_trap == user)
			user.drop_item(src)
		src.add_animal(animal_to_trap)
		user.update_inhands()

	/// Called when a given mob/user releases an animal after an actionbar.
	proc/release_animal(mob/living/animal_to_release, mob/user)
		if (animal_to_release)
			src.eject_animal(animal_to_release)
			user.update_inhands()
			return
		boutput(user, "<span class='alert'>Unable to release anyone from [src]!</span>")

	/// Directly adds a target animal to the carrier.
	proc/add_animal(mob/living/animal_to_add)
		if (!animal_to_add)
			return
		animal_to_add.remove_pulling()
		animal_to_add.set_loc(src)
		animal_to_add.vis_flags |= src.animal_vis_flags
		src.carrier_occupants.Add(animal_to_add)
		src.vis_contents_proxy.vis_contents.Add(animal_to_add)
		src.UpdateIcon()

	/// Directly ejects a target animal from the carrier.
	proc/eject_animal(mob/living/animal_to_eject)
		if (!animal_to_eject)
			return
		MOVE_OUT_TO_TURF_SAFE(animal_to_eject, src)
		animal_to_eject.vis_flags &= ~(src.animal_vis_flags)
		src.carrier_occupants.Remove(animal_to_eject)
		src.vis_contents_proxy.vis_contents.Remove(animal_to_eject)
		src.UpdateIcon()

/obj/item/pet_carrier/jones
	default_animal = /mob/living/critter/small_animal/cat/jones

/// Pertains to actions executed by the pet carrier.
/datum/action/bar/icon/pet_carrier
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/mob_owner
	var/mob/target
	var/obj/item/pet_carrier/carrier
	var/action

	New(var/mob/target, var/item, var/icon, var/icon_state, var/carrier_action)
		..()
		src.target = target
		if (istype(item, /obj/item/pet_carrier))
			src.carrier = item
		else
			logTheThing(LOG_DEBUG, src, "/datum/action/bar/icon/pet_carrier called with invalid type [item].")
		src.icon = icon
		src.icon_state = icon_state
		src.action = carrier_action

	onStart()
		if (!ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.mob_owner = owner
		if (BOUNDS_DIST(mob_owner, target) > 0 || !target || !mob_owner || mob_owner.equipped() != carrier)
			interrupt(INTERRUPT_ALWAYS)
			return
		switch (src.action)
			if (RELEASE_ANIMAL)
				src.mob_owner.visible_message("<span class='notice'>[src.mob_owner] opens [src.carrier] and tries to coax [src.target] out of it!</span>")
			if (TRAP_ANIMAL)
				src.mob_owner.visible_message("<span class='alert'>[src.mob_owner] opens [src.carrier] and tries to coax [src.target] into it!</span>")
		..()

	onUpdate()
		..()
		if (BOUNDS_DIST(mob_owner, target) > 0 || !target || !mob_owner || mob_owner.equipped() != carrier)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if (BOUNDS_DIST(mob_owner, target) > 0 || !target || !mob_owner || mob_owner.equipped() != carrier)
			interrupt(INTERRUPT_ALWAYS)
			return
		switch (src.action)
			if (RELEASE_ANIMAL)
				carrier.release_animal(target, mob_owner)
				src.mob_owner.visible_message("<span class='notice'>[src.mob_owner] coaxes [target] out of [src.carrier]!</span>")
			if (TRAP_ANIMAL)
				carrier.trap_animal(target, mob_owner)
				src.mob_owner.visible_message("<span class='alert'>[src.mob_owner] coaxes [target] into [src.carrier]!</span>")

#undef RELEASE_ANIMAL
#undef TRAP_ANIMAL
