/// How many mobs can fit in the carrier by default.
#define DEFAULT_MAX_CAPACITY 1
/// Probability that a mob can break out of the carrier with *flip, from 0 to 100.
#define BREAK_OUT_PROB 10
/// Number of mobs named explicitly on examine() before switching to "there's a lot of mobs in here wow".
#define EXPLICIT_NAME_LIMIT 3

// Actionbar action defines
#define RELEASE_MOB 0
#define TRAP_MOB 1

/**
 * # Pet carriers.
 * Code by DisturbHerb, icons by Azwald/Sunkiisu.
 *
 * A handheld item which can hold some mob instances inside with support for visually displaying its occupants with vis_contents.
 * This was created without access to the pre-existing chicken carrier code so it could be pretty bad.
 *
 * The given mobs that a carrier is allowed to hold is determined by var/mob/allowed_mobs which should be overridden by any child types of the
 * carrier. The maximum capacity is determined by var/carrier_max_capacity which can also be overridden.
 *
 * Whether a mob can break out or not is determined by var/can_break_out, and if FALSE, any occupant cannot escape the carrier on their own.
 *
 * There is support for spawning with an animal already inside by overriding var/mob/default_mob with a valid path.
 *
 * The icon for the carrier is constructed using a base where an overlay of the front of the carrier and two /obj/dummys are layered on top.
 * These dummy objects are held in the carrier's vis_contents and each of them hold the mobs and the door of the carrier. The reason why the
 * vis_contents of vis_contents_proxy hold the mobs rather than the carrier doing so directly is so that an alpha mask can prevent parts of the
 * occupants from rendering outside of the inside of the carrier.
 *
 * For any mobs inside, the atmosphere they'll attempt to breathe from is taken from the current turf that the carrier occupies, even if the carrier
 * is being held in someone's hand.
 */
/obj/item/pet_carrier
	name = "pet carrier"
	desc = "A surprisingly roomy carrier for transporting small animals."
	icon = 'icons/obj/items/pet_carrier.dmi'
	icon_state = "carrier-full"
	item_state = "carrier-open"
	w_class = W_CLASS_BULKY

	/// Please override this in child types to specify what can actually fit in.
	var/mob/allowed_mobs = /mob/living/critter/small_animal
	/// If FALSE, an occupant cannot escape the carrier on their own.
	var/can_break_out = TRUE
	/// How many mobs can fit inside the crate. Usually not overridden by anything, this is to let the system be permissive for var-editing.
	var/carrier_max_capacity = DEFAULT_MAX_CAPACITY
	/// If not null, the pet carrier will spawn with one of this mob on New().
	var/mob/default_mob = null

	/// The icon_state for the src.TRAP_MOB() actionbar.
	var/trap_mob_icon_state = "carrier-full"
	/// The icon_state for the src.RELEASE_MOB() actionbar.
	var/release_mob_icon_state = "carrier-full-open"
	// Alpha mask icon state for cutting out the mob on non-transparent pixels.
	var/carrier_alpha_mask = "carrier-mask"

	// Empty carrier icon state name.
	var/empty_carrier_icon_state = "carrier"

	// Grate icon state names.
	var/grate_open_icon_state = "grate-open"
	var/grate_closed_icon_state = "grate-closed"

	// Carrier item state names.
	var/carrier_open_item_state = "carrier-open"
	var/carrier_closed_item_state = "carrier-closed"

	/// Carrier-related (grate_proxy, vis_contents_proxy) vis_flags.
	var/carrier_vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	/// Mob-specific vis_flags.
	var/mob_vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE

	/// Grate object to be held in src.vis_contents
	var/obj/dummy/grate_proxy
	/// Proxy object for storing the vis_contents of each occupant, which itself is contained in the vis_contents of the parent carrier.
	var/obj/dummy/vis_contents_proxy
	/// A list of the current occupants inside the carrier.
	var/list/mob/carrier_occupants = list()

	New()
		..()
		// Build the icon with all its overlays and funny containers.
		src.icon_state = "[src.empty_carrier_icon_state]"

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

		if (src.default_mob)
			if (!ispath(src.default_mob, src.allowed_mobs))
				return
			var/mob/spawned_mob = new src.default_mob
			if (spawned_mob)
				src.add_mob(spawned_mob)

	disposing()
		if (length(src.carrier_occupants))
			for (var/occupant in src.carrier_occupants)
				src.eject_mob(occupant)
		src.carrier_occupants = null
		src.overlays = null
		..()

	examine()
		. = ..()
		var/carrier_occupants_length = length(src.carrier_occupants)
		if (carrier_occupants_length)
			if (carrier_occupants_length > EXPLICIT_NAME_LIMIT)
				. += "There's a whole zoo inside!"
				return
			. += "It's carrying [english_list(src.carrier_occupants)]."

	update_icon()
		..()
		if (length(src.carrier_occupants))
			src.grate_proxy.icon_state = "[src.grate_closed_icon_state]"
			src.item_state = "[src.carrier_closed_item_state]"
		else
			src.grate_proxy.icon_state = "[src.grate_open_icon_state]"
			src.item_state = "[src.carrier_open_item_state]"

	attack(mob/M, mob/user)
		if (user.a_intent == INTENT_HARM)
			return ..()
		if (ismob(M))
			if (!src.return_other_hand_empty(user))
				boutput(user, "<span class='alert'>You need a free hand to scoop up [M]!</span>")
				return ..()
			if (!istype(M, src.allowed_mobs))
				boutput(user, "<span class='alert'>[M] can't quite fit inside [src]!</span>")
				return ..()
			if (src.carrier_max_capacity <= length(src.carrier_occupants))
				boutput(user, "<span class='alert'>[src] is too crowded to fit one more!</span>")
				return ..()
			var/mob/target_mob = M
			actions.start(new /datum/action/bar/icon/pet_carrier(target_mob, src, src.icon, src.trap_mob_icon_state, TRAP_MOB), user)
			return
		..()

	attack_self(mob/user)
		if (!src.return_other_hand_empty(user))
			boutput(user, "<span class='alert'>You need a free hand to do anything with [src]!</span>")
			return ..()
		if (length(src.carrier_occupants) && ismob(src.carrier_occupants[1]))
			var/mob/mob_to_remove = src.carrier_occupants[1]
			actions.start(new /datum/action/bar/icon/pet_carrier(mob_to_remove, src, src.icon, src.release_mob_icon_state, RELEASE_MOB), user)
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

	mob_flip_inside(mob/user)
		..(user)

		if (!src.can_break_out)
			boutput(src, "<span class='alert'>It's no use! You can't leave [src]!</span>")
			return
		if (prob(BREAK_OUT_PROB))
			if (length(src.carrier_occupants) > 1)
				for (var/occupant in src.carrier_occupants)
					src.eject_mob(occupant)
				src.visible_message("<span class='alert'>[user] kicks the door of [src] open and OH GOD THEY'RE ALL ESCAPING!</span>")
				return
			src.eject_mob(user)
			src.visible_message("<span class='alert'>[user] kicks the door of [src] open and crawls right out!</span>")
			return
		boutput(user, "<span class='alert'>Maybe this door could give out if you put up some more effort!</span>")

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		..()
		if (src.carrier_occupants)
			for (var/mob/occupant in src.carrier_occupants)
				occupant.throw_impact(hit_atom, thr)

	/// Called when a given mob/user steals a mob after an actionbar.
	proc/trap_mob(mob/mob_to_trap, mob/user)
		if (!mob_to_trap)
			return
		if (mob_to_trap == user)
			user.drop_item(src)
		src.add_mob(mob_to_trap)
		user.update_inhands()

	/// Called when a given mob/user releases an mob after an actionbar.
	proc/release_mob(mob/mob_to_release, mob/user)
		if (mob_to_release)
			src.eject_mob(mob_to_release)
			user.update_inhands()
			return
		boutput(user, "<span class='alert'>Unable to release anyone from [src]!</span>")

	/// Directly adds a target mob to the carrier.
	proc/add_mob(mob/mob_to_add)
		if (!mob_to_add)
			return
		mob_to_add.remove_pulling()
		mob_to_add.set_loc(src)
		mob_to_add.vis_flags |= src.mob_vis_flags
		src.carrier_occupants.Add(mob_to_add)
		src.vis_contents_proxy.vis_contents.Add(mob_to_add)
		src.UpdateIcon()

	/// Directly ejects a target mob from the carrier.
	proc/eject_mob(mob/mob_to_eject)
		if (!mob_to_eject)
			return
		MOVE_OUT_TO_TURF_SAFE(mob_to_eject, src)
		mob_to_eject.vis_flags &= ~(src.mob_vis_flags)
		src.carrier_occupants.Remove(mob_to_eject)
		src.vis_contents_proxy.vis_contents.Remove(mob_to_eject)
		src.UpdateIcon()

	// There has to be a better way of checking that the other hand is empty. Please.
	proc/return_other_hand_empty(mob/living/carbon/human/mob_to_check)
		if (!ishuman(mob_to_check))
			return FALSE
		if (mob_to_check.hand && !mob_to_check.r_hand)
			return TRUE
		else if (!mob_to_check.l_hand)
			return TRUE
		else return FALSE

	/// Calls src.AttackSelf(user) with a context action. Yeah, I know.
	verb/release_occupant_verb(mob/user)
		set name = "Release occupant"
		set category = "Local"
		set src in oview(1)

		if (can_act(user))
			return

		src.AttackSelf(user)

/obj/item/pet_carrier/admin_crimes
	name = "pet carrier (ADMIN CRIMES EDITION)"
	desc = "A surprisingly roomy carrier for transporting living things. All of them."
	allowed_mobs = /mob
	can_break_out = FALSE
	carrier_max_capacity = INFINITY

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
		if (BOUNDS_DIST(mob_owner, target) > 0 || !target || !mob_owner || (src.action == TRAP_MOB && mob_owner.equipped() != carrier) || !carrier.return_other_hand_empty(mob_owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		switch (src.action)
			if (RELEASE_MOB)
				src.mob_owner.visible_message("<span class='notice'>[src.mob_owner] opens [src.carrier] and tries to coax [src.target] out of it!</span>")
			if (TRAP_MOB)
				src.mob_owner.visible_message("<span class='alert'>[src.mob_owner] opens [src.carrier] and tries to coax [src.target] into it!</span>")
		..()

	onUpdate()
		..()
		if (BOUNDS_DIST(mob_owner, target) > 0 || !target || !mob_owner || (src.action == TRAP_MOB && mob_owner.equipped() != carrier) || !carrier.return_other_hand_empty(mob_owner))
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if (BOUNDS_DIST(mob_owner, target) > 0 || !target || !mob_owner || (src.action == TRAP_MOB && mob_owner.equipped() != carrier) || !carrier.return_other_hand_empty(mob_owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		switch (src.action)
			if (RELEASE_MOB)
				carrier.release_mob(target, mob_owner)
				src.mob_owner.visible_message("<span class='notice'>[src.mob_owner] coaxes [target] out of [src.carrier]!</span>")
			if (TRAP_MOB)
				carrier.trap_mob(target, mob_owner)
				src.mob_owner.visible_message("<span class='alert'>[src.mob_owner] coaxes [target] into [src.carrier]!</span>")

#undef DEFAULT_MAX_CAPACITY
#undef BREAK_OUT_PROB
#undef EXPLICIT_NAME_LIMIT
#undef RELEASE_MOB
#undef TRAP_MOB
