/datum/abilityHolder/mindeater
	usesPoints = TRUE
	var/max_points = INTRUDER_MAX_INTELLECT_THRESHOLD

	var/brain_stored = 0

	onAbilityStat()
		..()
		. = list()
		.["Intellect:"] = "[src.points]/[src.max_points]"

	addPoints(add_points, target_ah_type)
		..()
		src.points = min(src.points, src.max_points)
		src.updateText()

	deductPoints(cost, target_ah_type)
		..()
		src.points = max(src.points, 0)
		src.updateText()

ABSTRACT_TYPE(/datum/targetable/critter/mindeater)
/datum/targetable/critter/mindeater
	icon = 'icons/mob/critter/nonhuman/intruder.dmi'
	icon_state = "template"
	/// reveals the mindeater on use, but doesn't reveal disguise
	var/reveals_on_use = FALSE
	/// reveals mindeater and removes disguise
	var/full_reveal_on_use = FALSE

	cast(atom/target)
		..()
		if (src.reveals_on_use || src.full_reveal_on_use)
			var/mob/living/critter/mindeater/mindeater = src.holder.owner
			mindeater.reveal(src.full_reveal_on_use)

	proc/get_nearest_human_or_silicon(atom/target)
		if (isliving(target))
			return target
		for (var/mob/living/L in view(1, get_turf(target)))
			if (!(ishuman(L) || issilicon(L)))
				continue
			return L

	proc/get_nearest_mob_or_fake_mindeater(atom/target)
		if (isliving(target) || istype(target, /obj/dummy/fake_mindeater))
			return target
		for (var/atom/A in view(1, get_turf(target)))
			if (!(ishuman(A) || issilicon(A) || istype(target, /obj/dummy/fake_mindeater)))
				continue
			return A

	proc/get_nearest_living(atom/target)
		if (isliving(target))
			return target
		for (var/mob/living/L in view(1, get_turf(target)))
			if (!(ishuman(L) || issilicon(L) || (iscritter(L) && !istype(L, /mob/living/critter/mindeater))))
				continue
			return L

/datum/targetable/critter/mindeater/become_tangible
	name = "Manifest"
	desc = "Merge yourself into reality, becoming tangible."
	icon_state = "manifest"
	cooldown = 60 SECONDS

	tryCast()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		var/turf/T = get_turf(mindeater)
		if (T.density)
			boutput(mindeater, SPAN_ALERT("Something is blocking this turf!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		for (var/atom/A as anything in T)
			if (A.density)
				boutput(mindeater, SPAN_ALERT("Something is blocking this turf!"))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		mindeater.manifest()

/datum/targetable/critter/mindeater/regenerate
	name = "Regenerate"
	desc = "Use Intellect to regenerate health."
	icon_state = "regenerate"
	pointCost = 1

	tryCast()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		if (mindeater.get_health_percentage() >= 1)
			boutput(mindeater, SPAN_ALERT("You're already at full health!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		if (actions.hasAction(src.holder.owner, /datum/action/bar/private/mindeater_regenerate))
			actions.stop(/datum/action/bar/private/mindeater_regenerate, src.holder.owner)
		else
			actions.start(new /datum/action/bar/private/mindeater_regenerate(), src.holder.owner)

/datum/targetable/critter/mindeater/brain_drain
	name = "Brain Drain"
	desc = "Gain 3 Intellect per second from a target in range."
	icon_state = "brain_drain"
	targeted = TRUE
	target_anything = TRUE
	max_range = 6
	reveals_on_use = TRUE

	tryCast(atom/target)
		target = src.get_nearest_human_or_silicon(target)
		var/mob/living/L = target
		if (!(istype(L, /mob/living/carbon/human) || istype(L, /mob/living/silicon)))
			boutput(src.holder.owner, SPAN_ALERT("You can only target humans and silicons!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (istype(L, /mob/living/carbon/human))
			if (GET_ATOM_PROPERTY(L, PROP_MOB_INTELLECT_COLLECTED) > INTRUDER_MAX_INTELLECT_THRESHOLD)
				boutput(src.holder.owner, SPAN_ALERT("You can't get any more Intellect out of this target!"))
				return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (isdead(L))
			boutput(src.holder.owner, SPAN_ALERT("You can only use this ability on alive targets!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		actions.start(new /datum/action/bar/private/mindeater_brain_drain(target), src.holder.owner)

/datum/targetable/critter/mindeater/pierce_the_veil
	name = "Pierce the Veil"
	desc = "Take nearby mobs to a localized dimensional plane for 15 seconds."
	icon_state = "pierce_the_veil"
	cooldown = 60 SECONDS
	max_range = 5
	var/plane_width = 21
	pointCost = 25
	reveals_on_use = TRUE
	var/list/nearby_mobs = list()

	tryCast()
		src.nearby_mobs = list()
		for (var/mob/living/L in range(src.max_range, src.holder.owner))
			if (GET_DIST(L, src.holder.owner) > src.max_range)
				continue
			if (!(istype(L, /mob/living/carbon/human) || istype(L, /mob/living/silicon)))
				continue
			if (isdead(L))
				continue
			src.nearby_mobs += L
			break
		if (!length(src.nearby_mobs))
			boutput(src.holder.owner, SPAN_ALERT("There are no nearby mobs to take with you!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner

		var/datum/allocated_region/veil_border = global.region_allocator.allocate(src.plane_width, src.plane_width)
		veil_border.clean_up()

		var/turf/center = veil_border.get_center()

		var/dmm_suite/map_loader = new
		map_loader.read_map(file2text("assets/maps/allocated/intruder_veil_border.dmm"), center.x - 10, center.y - 10, center.z)
		playsound(get_turf(mindeater), 'sound/misc/intruder/mindeater_abduct.ogg', 25, TRUE)
		SPAWN(4 SECONDS)
			for (var/mob/living/L in src.nearby_mobs)
				if (QDELETED(L) || L.hasStatus("mindeater_abducted_invisible"))
					src.nearby_mobs -= L
				if (!length(src.nearby_mobs))
					return
			for (var/mob/living/L in (src.nearby_mobs + list(mindeater)))
				if (L == src.holder.owner)
					L.setStatus("mindeater_abducted_visible", 15 SECONDS, get_turf(L))
				else
					L.setStatus("mindeater_abducted_invisible", 15 SECONDS, get_turf(L))
				L.set_loc(locate(center.x + rand(-1, 1), center.y + rand(-1, 1), center.z))
			sleep(15.1 SECONDS)
			qdel(veil_border)

/area/veil_border
	name = "Veil border"
	teleport_blocked = 2
	allowed_restricted_z = TRUE

/datum/targetable/critter/mindeater/spatial_swap
	name = "Spatial Swap"
	desc = "Swap the location of yourself and another living creature or fake version of yourself."
	icon_state = "spatial_swap"
	cooldown = 20 SECONDS
	targeted = TRUE
	target_anything = TRUE
	max_range = 7
	pointCost = 15

	tryCast(atom/target)
		target = src.get_nearest_mob_or_fake_mindeater(target)
		if (!target)
			boutput(src.holder.owner, SPAN_ALERT("You can only target living creatures!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		var/atom/movable/AM = target
		var/turf/T1 = get_turf(src.holder.owner)
		var/turf/T2 = get_turf(AM)
		AM.set_loc(T1)
		src.holder.owner.set_loc(T2)

/datum/targetable/critter/mindeater/create
	name = "Create"
	desc = "Create a fake Mindeater at the target location."
	icon_state = "create"
	cooldown = 45 SECONDS
	targeted = TRUE
	target_anything = TRUE
	pointCost = 10

	cast(atom/target)
		. = ..()
		var/obj/dummy/fake_mindeater/fake = new /obj/dummy/fake_mindeater(get_turf(target))
		fake.set_dir(src.holder.owner.dir)

/datum/targetable/critter/mindeater/disguise
	name = "Disguise"
	desc = "Disguise yourself as a creature."
	icon_state = "disguise"
	pointCost = 0
	reveals_on_use = TRUE
	var/chosen_option

	tryCast(atom/target)
		src.chosen_option = null
		var/option = tgui_input_list(src.holder.owner, "What would you like to disguise as?", "Set Disguise", list("Mouse", "Cockroach", "Human"))
		if (!option)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		src.chosen_option = option
		return ..()

	cast(atom/target)
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		mindeater.disguise(src.chosen_option)

/datum/targetable/critter/mindeater/clear_disguise
	name = "Clear Disguise"
	desc = "Clear your disguise."
	icon_state = "clear_disguise"

	cast(atom/target)
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		mindeater.undisguise()

/datum/action/bar/private/mindeater_regenerate
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_ACT
	duration = 1 SECOND
	resumable = FALSE
	color_success = "#4444FF"

	onStart()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

	onUpdate()
		..()
		if (src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/living/critter/mindeater/mindeater = src.owner
		mindeater.HealDamage("All", 3, 3)
		var/datum/abilityHolder/abil_holder = mindeater.get_ability_holder(/datum/abilityHolder/mindeater)
		abil_holder.deductPoints(1)
		src.onRestart()

	proc/check_for_interrupt()
		var/mob/living/critter/mindeater/mindeater = src.owner
		var/datum/abilityHolder/abil_holder = mindeater.get_ability_holder(/datum/abilityHolder/mindeater)
		return !abil_holder.pointCheck(1, TRUE) || mindeater.get_health_percentage() >= 1

/datum/action/bar/private/mindeater_brain_drain
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED
	duration = 1 SECONDS
	resumable = FALSE
	color_success = "#4444FF"
	var/mob/living/target

	New(atom/target)
		..()
		src.target = target

	onStart()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return
		src.target.setStatus("mindeater_brain_draining", INFINITE_STATUS)

	onUpdate()
		..()
		if (src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return

		if (ishuman(src.target))
			src.target.take_brain_damage(1)
			var/mob/living/carbon/human/H = src.target
			APPLY_ATOM_PROPERTY(H, PROP_MOB_INTELLECT_COLLECTED, H, GET_ATOM_PROPERTY(H, PROP_MOB_INTELLECT_COLLECTED) + 3)
			src.target.setStatus("mindeater_mind_eating", INFINITE_STATUS)
			var/pct = GET_ATOM_PROPERTY(H, PROP_MOB_INTELLECT_COLLECTED)
			if (pct >= 100)
				APPLY_ATOM_PROPERTY(H, PROP_MOB_INTELLECT_COLLECTED, H, GET_ATOM_PROPERTY(H, PROP_MOB_INTELLECT_COLLECTED) - (pct - 100))
				H.brain_level.set_icon_state("complete")
			else
				H.brain_level.set_icon_state(min(round(pct, 10), INTRUDER_MAX_INTELLECT_THRESHOLD))
			var/pick = rand(1, 4)
			switch (pick)
				if (1)
					H.take_brain_damage(1)
				if (2)
					H.TakeDamage("All", 1, hit_twitch = FALSE)
				if (3)
					H.TakeDamage("All", burn = 1, hit_twitch = FALSE)
				if (4)
					H.TakeDamage("All", tox = 1, hit_twitch = FALSE)
		else if (istype(src.target, /mob/living/silicon/ai))
			src.target.TakeDamage("All", 15, damage_type = DAMAGE_CRUSH) // 15 - 20 seconds to kill
		else
			src.target.TakeDamage("head", 10, damage_type = DAMAGE_CRUSH) // ~15 seconds to kill a standard cyborg
		var/mob/living/critter/mindeater/mindeater = src.owner
		var/datum/abilityHolder/abil_holder = mindeater.get_ability_holder(/datum/abilityHolder/mindeater)
		abil_holder.addPoints(3)
		src.onRestart()

	onInterrupt(flag)
		..()
		if (flag & INTERRUPT_ALWAYS)
			src.target.delStatus("mindeater_brain_draining")

	proc/check_for_interrupt()
		var/mob/living/critter/mindeater/mindeater = src.owner
		var/datum/abilityHolder/abil_holder = mindeater.get_ability_holder(/datum/abilityHolder/mindeater)
		var/datum/targetable/critter/mindeater/brain_drain/abil = abil_holder.getAbility(/datum/targetable/critter/mindeater/brain_drain)
		return !(src.target in viewers(abil.max_range, get_turf(src.owner))) || \
				(istype(src.target, /mob/living/carbon/human) && src.target.get_brain_damage() > INTRUDER_MAX_INTELLECT_THRESHOLD) || isdead(src.target)
