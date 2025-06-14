// Actionbar action defines
#define RELEASE_MOB 0
#define TRAP_MOB 1
#define TRANSFER_MOB 2

/**
 * # Pet carriers.
 * Code by DisturbHerb, icons by Azwald/Sunkiisu.
 *
 * A handheld item which can hold some mob instances inside with support for visually displaying its occupants with vis_contents.
 * This was created without access to the pre-existing chicken carrier code so it could be pretty bad.
 *
 * The icon for the carrier is constructed using a base where two /obj/dummys are layered on top. These dummy objects are held in the carrier's
 * vis_contents and each of them hold the mobs and the door of the carrier. The reason why the vis_contents of vis_contents_proxy hold the mobs rather
 * than the carrier doing so directly is so that an alpha mask can prevent parts of the occupants from rendering outside of the inside of the carrier.
 */
/obj/item/pet_carrier
	name = "pet carrier"
	desc = "A surprisingly roomy carrier for transporting small animals."
	icon = 'icons/obj/items/pet_carrier.dmi'
	icon_state = "carrier-full"
	item_state = "carrier-open"
	w_class = W_CLASS_BULKY

	/// Please override this in child types to specify what can actually fit in.
	var/allowed_mob_types = list(/mob/living/critter/small_animal, /mob/living/critter/wraith/plaguerat, /obj/item/rocko)
	/// Time it takes for each action (eg. grabbing, releasing).
	var/actionbar_duration = 2 SECONDS
	/// If FALSE, an occupant cannot escape the carrier on their own.
	var/can_break_out = TRUE
	/// Causes the door to open and release its occupants when it reaches 0, subsequently resetting itself to the maximum.
	var/door_health
	var/door_health_max = 30
	/// The damage dealt to the door's health upon resisting.
	var/damage_per_resist = 6
	/// How many mobs can fit inside the crate. Usually not overridden by anything, this is to let the system be permissive for var-editing.
	var/carrier_max_capacity = 1
	/// Number of mobs named explicitly on examine() before switching to "there's a lot of mobs in here wow".
	var/explicit_name_limit = 3
	/// Type path, If not null, the pet carrier will spawn with one of this mob on New().
	var/default_mob_type = null

	/// The icon_state for the src.TRAP_MOB() actionbar.
	var/trap_mob_icon_state = "carrier-full"
	/// The icon_state for the src.RELEASE_MOB() actionbar.
	var/release_mob_icon_state = "carrier-full-open"
	/// Alpha mask icon state for cutting out the mob on non-transparent pixels.
	var/const/carrier_alpha_mask = "carrier-mask"

	/// Empty carrier icon state name.
	var/empty_carrier_icon_state = "carrier"

	/// Grate icon state names.
	var/const/grate_open_icon_state = "grate-open"
	var/const/grate_closed_icon_state = "grate-closed"

	/// Carrier item state names.
	var/carrier_open_item_state = "carrier-open"
	var/carrier_closed_item_state = "carrier-closed"

	/// For Noah's Shuttle medal
	var/gilded = FALSE

	/// Carrier-related (grate_proxy, vis_contents_proxy) vis_flags.
	var/const/carrier_vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	/// Mob-specific vis_flags.
	var/const/mob_vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

	/// Grate object to be held in src.vis_contents
	var/obj/dummy/grate_proxy
	/// Proxy object for storing the vis_contents of each occupant, which itself is contained in the vis_contents of the parent carrier.
	var/obj/dummy/vis_contents_proxy
	/// A list of the current occupants inside the carrier.
	var/list/carrier_occupants = list()

	New()
		..()
		src.door_health = src.door_health_max

		// Build the icon with all its funny containers.
		src.icon_state = src.empty_carrier_icon_state

		// Instantiate the vis_contents proxy.
		src.vis_contents_proxy = new()
		src.vis_contents_proxy.vis_flags |= src.carrier_vis_flags
		src.vis_contents_proxy.appearance_flags |= KEEP_TOGETHER
		src.vis_contents_proxy.add_filter("carrier-mask", 1, alpha_mask_filter(icon = icon(src.icon, src.carrier_alpha_mask)))
		src.vis_contents.Add(src.vis_contents_proxy)

		// Instantiate the grate.
		src.grate_proxy = new()
		src.grate_proxy.icon = src.icon
		src.grate_proxy.vis_flags |= src.carrier_vis_flags
		src.vis_contents.Add(src.grate_proxy)

		src.UpdateIcon()

		if (src.default_mob_type)
			if (!src.is_allowed_type(src.default_mob_type))
				return
			var/mob/spawned_mob = new src.default_mob_type
			if (spawned_mob)
				src.add_mob(spawned_mob)

	disposing()
		for (var/occupant in src.carrier_occupants)
			src.eject_mob(occupant)
		for (var/obj/item/stuff in src.contents)
			MOVE_OUT_TO_TURF_SAFE(stuff, src)
		src.vis_contents = null
		qdel(src.grate_proxy)
		src.grate_proxy = null
		qdel(src.vis_contents_proxy)
		src.vis_contents_proxy = null
		..()

	examine()
		. = ..()
		var/carrier_occupants_length = length(src.carrier_occupants)
		if (carrier_occupants_length)
			if (carrier_occupants_length > src.explicit_name_limit)
				. += "There's a whole zoo inside!"
				return
			. += "It's carrying [english_list(src.carrier_occupants)]."

	update_icon()
		..()
		if (length(src.carrier_occupants))
			src.grate_proxy.icon_state = src.grate_closed_icon_state
			src.item_state = src.carrier_closed_item_state
		else
			src.grate_proxy.icon_state = src.grate_open_icon_state
			src.item_state = src.carrier_open_item_state

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (user.a_intent == INTENT_HARM)
			return ..()
		if (istype(target))
			if (!src.is_allowed_type(target.type))
				boutput(user, SPAN_ALERT("[target] can't quite fit inside [src]!"))
				return ..()
			if (src.carrier_max_capacity <= length(src.carrier_occupants))
				boutput(user, SPAN_ALERT("[src] is too crowded to fit one more!"))
				return ..()
			actions.start(new /datum/action/bar/icon/pet_carrier(target, src, src.icon, src.trap_mob_icon_state, TRAP_MOB, src.actionbar_duration), user)
			return
		..()

	attack_self(mob/user)
		src.attempt_removal(user)
		..()

	// Ensure that things inside can actually breathe.
	remove_air(amount)
		var/turf/current_turf = get_turf(src)
		. = current_turf.remove_air(amount)

	return_air(direct = FALSE)
		if (!direct)
			var/turf/current_turf = get_turf(src)
			. = current_turf.return_air()

	mob_flip_inside(mob/user)
		..(user)
		src.mob_resist_inside(user)

	mob_resist_inside(mob/user)
		if (ON_COOLDOWN(src, "resist_damage", 3 SECONDS))
			return
		animate_storage_thump(src)
		if (!src.can_break_out)
			boutput(user, SPAN_ALERT("It's no use! You can't leave [src]!"))
			return
		boutput(user, SPAN_ALERT("You try to bust open the door of [src]!"))
		src.take_door_damage(src.damage_per_resist)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		..()
		if (length(src.carrier_occupants))
			animate_storage_thump(src)
		for (var/mob/occupant in src.carrier_occupants)
			occupant.throw_impact(hit_atom, thr)
		if (length(src.carrier_occupants))
			src.take_door_damage(src.damage_per_resist * length(src.carrier_occupants))

	Exited(Obj, newloc)
		if (Obj in src.carrier_occupants)
			src.eject_mob(Obj)
			if(istype(Obj, /obj/item/rocko))
				src.visible_message(SPAN_ALERT("[usr] removes [Obj] from [src]."))
			else if (istype(Obj, /mob))
				src.visible_message(SPAN_ALERT("[Obj] bursts out of [src]!"))
		..()

	Entered(atom/movable/AM, OldLoc)
		if(istype(AM, /obj/item/rocko))
			src.visible_message(SPAN_ALERT("[usr] places [AM] into [src]."))
		if (!(AM in src.carrier_occupants))
			if(src.is_allowed_type(AM.type))
				src.add_mob(AM)
			else
				AM.set_loc(get_turf(src))
		..()

	proc/is_allowed_type(type)
		for (var/allowed_type in src.allowed_mob_types)
			if (ispath(type, allowed_type))
				return TRUE
		return FALSE

	/// Called when a given mob/user steals a mob after an actionbar.
	proc/trap_mob(atom/movable/thing_to_trap, mob/user)
		if (!thing_to_trap)
			return
		if (thing_to_trap == user)
			user.drop_item(src)

		if (istype(thing_to_trap, /mob))
			var/mob/M = thing_to_trap
			M.remove_pulling()
		else
			thing_to_trap.pulled_by = null
			user.remove_pulling()
			user.drop_item(thing_to_trap)

		src.add_mob(thing_to_trap)
		user.update_inhands()

	/// Called when a given mob/user releases an mob after an actionbar.
	proc/release_mob(atom/movable/thing_to_release, mob/user)
		if (thing_to_release)
			src.eject_mob(thing_to_release)
			user.update_inhands()
			return
		boutput(user, SPAN_ALERT("Unable to release anyone from [src]!"))

	proc/attempt_removal(mob/user)
		if (length(src.carrier_occupants))
			var/atom/movable/thing_to_remove = src.carrier_occupants[1]
			if (istype(thing_to_remove, /obj/item/rocko))
				src.eject_mob(thing_to_remove)
			if (istype(thing_to_remove, /mob))
				var/mob/M = thing_to_remove
				actions.start(new /datum/action/bar/icon/pet_carrier(M, src, src.icon, src.release_mob_icon_state, RELEASE_MOB, src.actionbar_duration), user)
		else
			boutput(user, SPAN_ALERT("[src] is without any friends! Aww!"))

	/// Directly adds a target mob to the carrier.
	proc/add_mob(atom/movable/thing_to_add)
		if (!thing_to_add)
			return
		src.carrier_occupants.Add(thing_to_add)
		thing_to_add.set_loc(src)
		thing_to_add.vis_flags |= src.mob_vis_flags
		src.vis_contents_proxy.vis_contents.Add(thing_to_add)
		src.UpdateIcon()

	/// Directly ejects a target mob from the carrier.
	proc/eject_mob(atom/movable/thing_to_eject)
		if (!thing_to_eject)
			return
		MOVE_OUT_TO_TURF_SAFE(thing_to_eject, src)
		thing_to_eject.vis_flags &= ~src.mob_vis_flags
		src.carrier_occupants.Remove(thing_to_eject)
		src.vis_contents_proxy.vis_contents.Remove(thing_to_eject)

		// Get rid of all /obj/items inside as well.
		for (var/obj/item/stuff in src.contents)
			MOVE_OUT_TO_TURF_SAFE(stuff, src)

		src.UpdateIcon()

	proc/transfer_mob(mob/thing_to_eject, obj/destination)
		if(istype(destination, /obj/machinery/genetics_scanner))
			var/obj/machinery/genetics_scanner/GC = destination
			GC.go_in(thing_to_eject)
		else if(istype(destination, /obj/machinery/computer/genetics/portable))
			var/obj/machinery/computer/genetics/portable/PGC = destination
			PGC.go_in(thing_to_eject)

	/// Deals damage to the door. If the remaining health <= 0, release everyone and reset the carrier.
	proc/take_door_damage(damage)
		src.door_health -= damage
		if (src.door_health <= 0)
			for (var/occupant in src.carrier_occupants)
				src.eject_mob(occupant)
			src.visible_message(SPAN_ALERT("The door on [src] busts wide open, releasing its occupants!"))
			src.door_health = src.door_health_max
		else
			src.visible_message(SPAN_ALERT("The door on [src] rattles!"))

	verb/release_occupant_verb(mob/user)
		set name = "Release occupant"
		set category = "Local"
		set src in view(1)

		if (!can_act(user))
			return

		src.attempt_removal(user)

	afterattack(atom/target, mob/user , flag)
		. = ..()
		if (istype(target, /obj/item/rocko))
			src.trap_mob(target, user)
			return
		else if(istype(target, /obj/machinery/genetics_scanner) && length(src.carrier_occupants))
			var/mob/thing_to_remove = src.carrier_occupants[1]
			var/obj/machinery/genetics_scanner/GS = target
			if(GS.can_operate(user, thing_to_remove))
				actions.start(new /datum/action/bar/icon/pet_carrier(thing_to_remove, src, src.icon, src.release_mob_icon_state, TRANSFER_MOB, src.actionbar_duration, GS), user)
		else if(istype(target, /obj/machinery/computer/genetics/portable) && length(src.carrier_occupants))
			var/mob/thing_to_remove = src.carrier_occupants[1]
			var/obj/machinery/computer/genetics/portable/PGS = target
			if(PGS.can_operate(user, thing_to_remove))
				actions.start(new /datum/action/bar/icon/pet_carrier(thing_to_remove, src, src.icon, src.release_mob_icon_state, TRANSFER_MOB, src.actionbar_duration, PGS), user)

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/rocko))
			src.trap_mob(I, user)
			return
		..()

/obj/item/pet_carrier/admin_crimes
	name = "pet carrier (ADMIN CRIMES EDITION)"
	desc = "A surprisingly roomy carrier for transporting living things. All of them."
	allowed_mob_types = list(/mob)
	actionbar_duration = 0
	can_break_out = FALSE
	carrier_max_capacity = INFINITY
	door_health_max = INFINITY

/// Pertains to actions executed by the pet carrier.
/datum/action/bar/icon/pet_carrier
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/mob_owner
	var/mob/target
	var/obj/item/pet_carrier/carrier
	var/obj/transfer_location
	var/action

	New(mob/target, obj/item/pet_carrier/item, icon, icon_state, carrier_action, desired_duration, desired_location)
		src.duration = desired_duration
		..()
		src.target = target
		if (istype(item, /obj/item/pet_carrier))
			src.carrier = item
		else
			logTheThing(LOG_DEBUG, src, "/datum/action/bar/icon/pet_carrier called with invalid type [item?.type].")
		src.icon = icon
		src.icon_state = icon_state
		src.action = carrier_action
		src.transfer_location = desired_location

	onStart()
		if (!ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.mob_owner = owner
		if (src.interrupt_action())
			interrupt(INTERRUPT_ALWAYS)
			return
		switch (src.action)
			if (RELEASE_MOB)
				src.mob_owner.visible_message(SPAN_NOTICE("[src.mob_owner] opens [src.carrier] and tries to coax [src.target] out of it!"))
			if (TRAP_MOB)
				src.mob_owner.visible_message(SPAN_ALERT("[src.mob_owner] opens [src.carrier] and tries to coax [src.target] into it!"))
			if (TRANSFER_MOB)
				src.mob_owner.visible_message(SPAN_ALERT("[src.mob_owner] opens [src.carrier] and tries to coax [src.target] into [src.transfer_location]!"))
		..()

	onUpdate()
		..()
		if (src.interrupt_action())
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		if (src.interrupt_action())
			interrupt(INTERRUPT_ALWAYS)
			return
		switch (src.action)
			if (RELEASE_MOB)
				carrier.release_mob(target, mob_owner)
				src.mob_owner.visible_message(SPAN_NOTICE("[src.mob_owner] coaxes [target] out of [src.carrier]!"))
			if (TRAP_MOB)
				carrier.trap_mob(target, mob_owner)
				src.mob_owner.visible_message(SPAN_ALERT("[src.mob_owner] coaxes [target] into [src.carrier]!"))
			if (TRANSFER_MOB)
				carrier.release_mob(target, mob_owner)
				carrier.transfer_mob(target, src.transfer_location)
				src.mob_owner.visible_message(SPAN_NOTICE("[src.mob_owner] coaxes [target] out of [src.carrier] and into [src.transfer_location]!"))

	proc/interrupt_action()
		if (BOUNDS_DIST(src.mob_owner, src.target) > 0 || !istype(src.target) || !src.mob_owner || !src.carrier \
		|| (src.action == TRAP_MOB && src.mob_owner.equipped() != src.carrier) \
		|| (src.action == TRANSFER_MOB && BOUNDS_DIST(src.mob_owner, src.transfer_location) > 0) )
			return TRUE

#undef RELEASE_MOB
#undef TRAP_MOB
#undef TRANSFER_MOB
