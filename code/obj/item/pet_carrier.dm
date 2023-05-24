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

	// Grate overlay image.
	var/image/grate_overlay = null
	// Alpha mask to cut out the animal on non-transparent pixels.
	var/carrier_alpha_mask = "carrier-mask"

	// Overlay and base icon state names.
	var/grate_open_icon_state = "grate-open"
	var/grate_closed_icon_state = "grate-closed"
	var/carrier_front_icon_state = "carrier-front"
	var/carrier_rear_icon_state = "carrier-rear"

	/// By default, the carrier can only fit small animals. Override this with FALSE to make it not so.
	var/small_animals_only = TRUE
	/// How many animals can fit inside the crate. Usually not overridden by anything, this is to let the system be permissive for var-editing.
	var/carrier_max_capacity = 1
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
		// Spawn a default animal inside if there is one.
		if (ismob(src.default_animal))
			if (!issmallanimal(src.default_animal) && src.small_animals_only)
				return
			src.carrier_occupants.Add(new src.default_animal)
		src.UpdateIcon()

	disposing()
		if (length(src.carrier_occupants))
			for (var/occupant in src.carrier_occupants)
				src.release_animal(occupant)
		src.carrier_occupants = null
		src.overlays = null
		..()

	examine()
		. = ..()
		if (length(src.carrier_occupants))
			// Since you'll basically never see this.
			if (length(src.carrier_occupants) > 1)
				. += "There's a whole zoo inside!"
				return
			else
				. += "It's carrying [src.carrier_occupants[1].name]."

	update_icon()
		..()
		// Update the grate overlay depending on whether or not there's anyone in the carrier.
		if (length(src.carrier_occupants))
			src.grate_overlay = new(src.icon, "[src.grate_closed_icon_state]")
			src.item_state = "carrier-closed"
		else
			src.grate_overlay = new(src.icon, "[src.grate_open_icon_state]")
			src.item_state = "carrier-open"
		src.grate_overlay.layer = src.layer + 0.001
		src.UpdateOverlays(src.grate_overlay, "grate")

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
			actions.start(new /datum/action/bar/icon/pet_carrier(animal_to_remove, src, src.icon, src.release_animal_icon_state, RELEASE_ANIMAL), user)
		..()

	proc/trap_animal(mob/living/animal_to_trap, mob/user)
		if (!animal_to_trap)
			return
		if (animal_to_trap = user)
			user.drop_item(src)
		animal_to_trap.remove_pulling()
		animal_to_trap.set_loc(src)
		animal_to_trap.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_DIR
		animal_to_trap.add_filter("carrier-mask", 20, alpha_mask_filter(icon = icon(src.icon, src.carrier_alpha_mask)))
		src.carrier_occupants.Add(animal_to_trap)
		src.vis_contents.Add(animal_to_trap)
		src.UpdateIcon()
		user.update_inhands()

	proc/release_animal(mob/living/animal_to_release, mob/user)
		// Check if the animal being released exists in the carrier's contents.
		var/animal_to_releaseExists = FALSE
		for (var/occupant in src.carrier_occupants)
			if (occupant == animal_to_release)
				animal_to_releaseExists = TRUE
		if (!animal_to_releaseExists)
			return
		MOVE_OUT_TO_TURF_SAFE(animal_to_release, src)
		animal_to_release.vis_flags &= ~(VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_DIR)
		animal_to_release.remove_filter("carrier-mask")
		src.carrier_occupants.Remove(animal_to_release)
		src.vis_contents.Remove(animal_to_release)
		src.UpdateIcon()
		user.update_inhands()

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
