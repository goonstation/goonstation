/mob/living/critter/mindeater
	name = "???"
	real_name = "mindeater"
	desc = "What sort of eldritch abomination is this thing???"
	icon = 'icons/mob/critter/nonhuman/intruder.dmi'
	icon_state = "intruder"

	hand_count = 1

	can_bleed = FALSE
	can_lie = FALSE
	can_implant = FALSE
	metabolizes = FALSE
	reagent_capacity = 0

	speechverb_say = "hums"
	speechverb_gasp = "hums"
	speechverb_stammer = "hums"
	speechverb_exclaim = "hums"
	speechverb_ask = "hums"

	/// shows whether this mindeater is visible to all or not
	var/image/mindeater_visibility_indicator/vis_indicator
	/// shows health of the mindeater
	var/image/mindeater_health_indicator/hp_indicator
	/// fake mindeaters created through associated ability
	var/list/fake_mindeaters = null
	/// items being levitated through associated ability
	var/list/levitated_items = list()
	/// if this mindeater is using a disguise
	var/disguised = FALSE

	New()
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_HEATPROT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_COLDPROT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NIGHTVISION, src)
		remove_lifeprocess(/datum/lifeprocess/radiation)
		remove_lifeprocess(/datum/lifeprocess/chems)
		remove_lifeprocess(/datum/lifeprocess/blood)
		remove_lifeprocess(/datum/lifeprocess/mutations)

		QDEL_NULL(src.organHolder)

		src.add_ability_holder(/datum/abilityHolder/mindeater)

		src.see_invisible = INVIS_INTRUDER

		src.vis_indicator = new (loc = src)

		src.hp_indicator = new (loc = src)

		src.demanifest()

		get_image_group(CLIENT_IMAGE_GROUP_INTRUSION_OVERLAYS).add_mob(src)

	disposing()
		..()
		QDEL_NULL(src.vis_indicator)
		QDEL_NULL(src.hp_indicator)
		src.remove_fake_mindeaters()

	Life()
		. = ..()
		if (src.is_intangible())
			return
		if (src.disguised)
			return
		if (src.on_bright_turf())
			src.delStatus("mindeater_cloaking")
			if (!src.hasStatus("mindeater_appearing") && !src.is_visible())
				src.setStatus("mindeater_appearing", 10 SECONDS)
		else
			src.delStatus("mindeater_appearing")
			if (!src.hasStatus("mindeater_cloaking") && src.is_visible())
				src.setStatus("mindeater_cloaking", 5 SECONDS)

	setup_healths()
		add_hh_flesh(100, 1)
		add_hh_flesh_burn(100, 1)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.name = "psionic-kinetic bolt"
		HH.limb = new /datum/limb/gun/kinetic/mindeater
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "psi_bolt"
		HH.limb_name = "psi bolt"
		HH.can_hold_items = FALSE
		HH.can_range_attack = TRUE

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		if (src.is_intangible())
			return
		..()
		src.hp_indicator.set_icon_state(round(src.get_health_percentage() * 100, 20))
		if (brute > 0 || burn > 0 || tox > 0)
			src.reveal()

	bump(atom/A)
		..()
		if (istype(A, /obj/window) || (A.density && (A.material?.getID() == "glass" || A.material?.getProperty("reflective") > 7)))
			src.set_loc(get_turf(A))
		else if (istype(A, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/airlock = A
			airlock.open()

	do_disorient(stamina_damage, knockdown, stunned, unconscious, disorient, remove_stamina_below_zero, target_type, stack_stuns)
		stamina_damage = 0
		src.reveal()
		..()

	apply_flash(animation_duration, knockdown, stun, misstep, eyes_blurry, eyes_damage, eye_tempblind, burn, uncloak_prob, stamina_damage, disorient_time)
		stamina_damage = 0
		src.reveal()
		..()

	is_heat_resistant()
		return TRUE

	is_cold_resistant()
		return TRUE

	is_spacefaring()
		return src.is_intangible()

	movement_delay()
		. = ..()
		if (src.is_intangible())
			return . / 3

	nauseate(stacks)
		return

	//say_understands(var/other)
	//	return 1

	//understands_language(langname)
	//	if (langname == src.say_language || langname == "feather" || langname == "english") // understands but can't speak flock
	//		return TRUE
	//	return FALSE

	shock(atom/origin, wattage, zone = "chest", stun_multiplier = 1, ignore_gloves = 0)
		if (src.is_intangible())
			return
		src.reveal()
		return ..()

	ex_act(severity)
		if (src.is_intangible())
			return
		src.reveal()
		return ..()

	/// returns if the turf is bright enough to reveal the mindeater
	proc/on_bright_turf()
		var/turf/T = get_turf(src)
		return T.is_lit()

	/// if the mindeater is effectively intangible
	proc/is_intangible()
		return src.event_handler_flags & MOVE_NOCLIP

	/// if the mindeater is visible to all humans
	proc/is_visible()
		return src.invisibility == INVIS_NONE

	/// reveal the mindeater's true form to all
	proc/reveal()
		src.vis_indicator.set_visible(TRUE)
		src.invisibility = INVIS_NONE
		src.delStatus("mindeater_appearing")
		src.delStatus("mindeater_cloaking")
		src.undisguise()

	/// set the mindeater invisible to humans
	proc/set_invisible()
		src.vis_indicator.set_visible(FALSE)
		src.invisibility = INVIS_INTRUDER
		src.delStatus("mindeater_appearing")
		src.delStatus("mindeater_cloaking")

	/// move from intangible to tangible state
	proc/manifest()
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/become_tangible)
		src.event_handler_flags &= ~(MOVE_NOCLIP | IMMUNE_MANTA_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP)
		src.flags &= ~UNCRUSHABLE
		src.density = TRUE
		src.set_invisible()
		src.alpha = 255
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_ACTING_INTANGIBLE, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/regenerate)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/brain_drain)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/telekinesis)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/metabolic_overload)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/create)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/shades)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/disguise)

	/// move from tangible to intangible state
	proc/demanifest()
		src.event_handler_flags |= (MOVE_NOCLIP | IMMUNE_MANTA_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP)
		src.flags |= UNCRUSHABLE
		src.density = FALSE
		src.set_invisible()
		src.alpha = 150
		APPLY_ATOM_PROPERTY(src, PROP_MOB_ACTING_INTANGIBLE, src)
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/regenerate)
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/brain_drain)
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/telekinesis)
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/metabolic_overload)
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/create)
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/shades)
		src.abilityHolder.removeAbility(/datum/targetable/critter/mindeater/disguise)
		src.abilityHolder.addAbility(/datum/targetable/critter/mindeater/become_tangible)

	/// create fake mindeaters for associated ability
	proc/setup_fake_mindeaters(list/fakes)
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(move_fake_mindeaters))
		src.fake_mindeaters = fakes
		SPAWN(10 SECONDS)
			src.remove_fake_mindeaters()

	/// remove fake mindeaters for associated ability
	proc/remove_fake_mindeaters()
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		for (var/obj/dummy/fake_mindeater/fake as anything in src.fake_mindeaters)
			qdel(fake)
			src.fake_mindeaters -= fake

	proc/move_fake_mindeaters(atom/thing, new_loc, direct)
		for (var/atom/movable/AM as anything in src.fake_mindeaters)
			AM.Move(get_step(AM, direct))

	/// levitate an item with associated ability
	proc/levitate_item(obj/item/I)
		src.levitated_items += I
		I.set_loc(src)
		src.vis_contents += I
		I.Scale(2 / 3, 2 / 3)
		if (prob(50))
			I.pixel_x = 12 + rand(-4, 4)
		else
			I.pixel_x = -12 + rand(-4, 4)
		I.pixel_y = rand(-8, 16)
		animate_levitate(I)

	/// drop a levitated item
	proc/drop_levitated_item(obj/item/I)
		if (!(I in src.levitated_items))
			return
		src.levitated_items -= I
		I.set_loc(get_turf(src))
		src.vis_contents -= I
		animate(I)
		I.Scale(3 / 2, 3 / 2)

	/// disguise as an entity
	proc/disguise()
		var/mob/living/carbon/human/H = new /mob/living/carbon/human/normal/assistant
		H.invisibility = INVIS_ALWAYS
		H.set_loc(get_turf(src)) // so that there's no zip up sound
		randomize_look(H, change_name = FALSE)
		var/icon/front = getFlatIcon(H, SOUTH)
		var/icon/back = getFlatIcon(H, NORTH)
		var/icon/left = getFlatIcon(H, WEST)
		var/icon/right = getFlatIcon(H, EAST)
		var/icon/guise = new
		guise.Insert(front, dir = SOUTH)
		guise.Insert(back, dir = NORTH)
		guise.Insert(left, dir = WEST)
		guise.Insert(right, dir = EAST)
		src.icon = guise
		src.name = H.real_name
		src.desc = H.get_desc(TRUE, TRUE)
		src.bioHolder.mobAppearance.gender = H.bioHolder.mobAppearance.gender
		src.update_name_tag(src.name)
		qdel(H)

		src.disguised = TRUE

	/// undisguise as disguised entity
	proc/undisguise()
		src.name = initial(src.name)
		src.desc = initial(src.desc)
		src.icon = initial(src.icon)
		src.icon_state = initial(src.icon_state)
		src.bioHolder.mobAppearance.gender = initial(src.gender)
		src.update_name_tag(src.name)

		src.disguised = FALSE

/obj/dummy/fake_mindeater
	name = "???"
	real_name = "mindeater"
	desc = "What sort of eldritch abomination is this thing???"
	icon = 'icons/mob/critter/nonhuman/intruder.dmi'
	icon_state = "intruder"
	flags = LONG_GLIDE
	density = FALSE
	anchored = UNANCHORED

	attack_hand(mob/user)
		..()
		src.reveal_fake()

	attackby(obj/item/I, mob/user)
		..()
		src.reveal_fake()

	proc/reveal_fake()
		animate_wave(src, 5)
		animate(src, 1 SECOND, flags = ANIMATION_PARALLEL, alpha = 0)
		SPAWN(1 SECOND)
			qdel(src)

	bump(atom/A)
		..()
		if (istype(A, /obj/window) || (A.density && (A.material?.getID() == "glass" || A.material?.getProperty("reflective") > 7)))
			src.set_loc(get_turf(A))
		else if (istype(A, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/airlock = A
			airlock.open()

	Crossed(atom/movable/AM)
		. = ..()
		var/obj/projectile/P = AM
		if (istype(P) && !istype(P.proj_data, /datum/projectile/special/psi_bolt))
			src.reveal_fake()

/image/mindeater_visibility_indicator
	icon = 'icons/mob/critter/nonhuman/intruder.dmi'
	icon_state = "invisible"
	plane = PLANE_HUD
	layer = HUD_LAYER_BASE
	appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR
	pixel_x = 16
	pixel_y = -16

	New(icon, loc, icon_state, layer, dir)
		..()
		get_image_group(CLIENT_IMAGE_GROUP_INTRUSION_OVERLAYS).add_image(src)

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_INTRUSION_OVERLAYS).remove_image(src)
		..()

	proc/set_visible(vis)
		src.icon_state = vis ? "visible" : "invisible"

/image/mindeater_health_indicator
	icon = 'icons/mob/critter/nonhuman/intruder.dmi'
	icon_state = "health-100"
	plane = PLANE_HUD
	layer = HUD_LAYER_BASE
	appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR
	pixel_x = 30
	pixel_y = -16

	New(icon, loc, icon_state, layer, dir)
		..()
		get_image_group(CLIENT_IMAGE_GROUP_INTRUSION_OVERLAYS).add_image(src)

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_INTRUSION_OVERLAYS).remove_image(src)
		..()

	proc/set_icon_state(pct)
		src.icon_state = "health-[pct]"

/image/mindeater_brain_drain_targeted
	icon = 'icons/mob/critter/nonhuman/intruder.dmi'
	icon_state = "brain_drain_targeted"
	plane = PLANE_HUD
	layer = HUD_LAYER_BASE
	appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR
	pixel_x = 0
	pixel_y = -20

	New(icon, loc, icon_state, layer, dir)
		..()
		get_image_group(CLIENT_IMAGE_GROUP_INTRUSION_OVERLAYS).add_image(src)

	disposing()
		get_image_group(CLIENT_IMAGE_GROUP_INTRUSION_OVERLAYS).remove_image(src)
		..()

/*
/obj/machinery/artifact/reality_breaker
	name = "artifact reality breaker"
	associated_datum = /datum/artifact/reality_breaker

/datum/artifact/reality_breaker
	associated_object = /obj/machinery/artifact/reality_breaker
	type_name = "Reality breaker"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 300
	min_triggers = 1
	max_triggers = 1
	validtypes = list("wizard", "precursor")
	fault_blacklist = list(ITEM_ONLY_FAULTS)
	react_xray = list(15, 90, 90, 11, "VARYING")
	var/radius
	var/kind
	var/broken_atoms = list()

	New()
		..()
		radius = rand(1, 4)
		kind = rand(1, 2)

	effect_process(obj/machinery/artifact/reality_breaker/O)
		..()
		if (ON_COOLDOWN(O, "reality_break", 5 SECONDS))
			return
		var/list/nearby_atoms = range(O, radius)
		for (var/atom/A as anything in broken_atoms)
			if (!HAS_ATOM_PROPERTY(A, PROP_ATOM_REALITY_BROKEN))
				continue
			if (!(A in nearby_atoms))
				animate(A, flags = ANIMATION_END_NOW)
				A.pixel_x = 0
				A.pixel_y = 0
				A.transform = initial(A.transform)
				REMOVE_ATOM_PROPERTY(A, PROP_ATOM_REALITY_BROKEN, src)
		src.broken_atoms = list()
		for (var/atom/A in range(O, radius))
			if (ismob(A))
				continue
			if (!isturf(A) && !isitem(A))
				continue
			if (HAS_ATOM_PROPERTY(A, PROP_ATOM_REALITY_BROKEN))
				continue
			src.broken_atoms += A
			APPLY_ATOM_PROPERTY(A, PROP_ATOM_REALITY_BROKEN, O)
			if (prob(75) && isturf(A))
				animate(A, rand(5, 10) / 10 SECONDS, easing = SINE_EASING, pixel_x = rand(-5, 5), pixel_y = rand(-5, 5))
				continue
			switch (kind)
				if (1)
					animate_float(A, floatspeed = (2 + rand(-5, 5) / 10) SECONDS, vertical = pick(TRUE, FALSE), halfway = pick(TRUE, FALSE))
				if (2)
					animate_orbit(A, rand(1, 5), rand(1, 5), rand(1, 3), time = rand(10, 80) / 10 SECONDS, clockwise = pick(TRUE, FALSE))
*/
