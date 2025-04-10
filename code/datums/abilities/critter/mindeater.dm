/datum/abilityHolder/mindeater
	usesPoints = TRUE
	var/max_points = 100

	var/brain_stored = 0

	onAbilityStat()
		..()
		. = list()
		.["Brain:"] = "[src.points]/[src.max_points]"

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
	/// reveals the mindeater on use
	var/reveals_on_use = FALSE

	cast(atom/target)
		..()
		if (src.reveals_on_use)
			var/mob/living/critter/mindeater/mindeater = src.holder.owner
			mindeater.reveal()

	proc/get_nearest_target(atom/target)
		if (isliving(target))
			return target
		for (var/mob/living/L in view(1, get_turf(target)))
			if (!(ishuman(L) || issilicon(L)))
				continue
			return L

/datum/targetable/critter/mindeater/become_tangible
	name = "Manifest"
	desc = "Merge yourself into reality, becoming tangible."
	icon_state = "manifest"

	cast(atom/target)
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		mindeater.manifest()

/datum/targetable/critter/mindeater/regenerate
	name = "Regenerate"
	desc = "Consume Brain to regenerate health."
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
	desc = "Drain 3 brain per second from a human in range."
	icon_state = "brain_drain"
	targeted = TRUE
	target_anything = TRUE
	max_range = 6

	tryCast(atom/target)
		target = src.get_nearest_target(target)
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(src.holder.owner, SPAN_ALERT("You can only target humans!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (H.get_brain_damage() > 100)
			boutput(src.holder.owner, SPAN_ALERT("This target has received too much brain damage!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		actions.start(new /datum/action/bar/private/mindeater_brain_drain(target), src.holder.owner)

/datum/targetable/critter/mindeater/telekinesis
	name = "Telekinesis"
	desc = "Pull a few items from a target location to you and steal them for a few seconds."
	icon_state = "telekinesis"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE
	reveals_on_use = TRUE
	max_range = 6

	cast(atom/target)
		. = ..()
		var/list/item_candidates = list()
		var/list/chosen_items = list()
		for (var/atom/A in view(1, get_turf(target)))
			if (istype(A, /obj/item))
				var/obj/item/I = A
				if (!I.anchored)
					item_candidates += A
			else if (istype(A, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = A
				if (H.l_hand)
					item_candidates |= H.l_hand
				if (H.r_hand)
					item_candidates |= H.r_hand
			else if (istype(A, /mob/living/critter))
				var/mob/living/critter/C = A
				for (var/datum/handHolder/handholder as anything in C.hands)
					if (handholder.item)
						item_candidates |= handholder.item

		shuffle_list(item_candidates)
		for (var/i in 1 to min(5, length(item_candidates)))
			chosen_items += item_candidates[i]

		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		for (var/obj/item/I as anything in chosen_items)
			animate(I, 1 SECOND, easing = LINEAR_EASING, alpha = 0)
			SPAWN(1 SECOND)
				animate(I, 0.5 SECONDS, alpha = 255)
				mindeater.levitate_item(I)
				sleep(10 SECONDS)
				mindeater.drop_levitated_item(I)

/datum/targetable/critter/mindeater/metabolic_overload
	name = "Metabolic Overload"
	desc = "Cause a target's chem metabolism to be set to near zero for a short duration."
	icon_state = "overload"
	targeted = TRUE
	target_anything = TRUE
	max_range = 6

	tryCast(atom/target)
		target = src.get_nearest_target(target)
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(src.holder.owner, SPAN_ALERT("You can only target humans!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		APPLY_ATOM_PROPERTY(target, PROP_MOB_METABOLIC_RATE, src, 0.1)
		SPAWN(100 SECONDS)
			REMOVE_ATOM_PROPERTY(target, PROP_MOB_METABOLIC_RATE, src)

/datum/targetable/critter/mindeater/create
	name = "Create"
	desc = "Create a fake Mindeater at the target location."
	icon_state = "create"
	cooldown = 60 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		. = ..()
		var/obj/dummy/fake_mindeater/fake = new /obj/dummy/fake_mindeater(get_turf(target))
		fake.set_dir(src.holder.owner.dir)

/datum/targetable/critter/mindeater/disguise
	name = "Disguise"
	desc = "Disguise yourself as a human."
	icon_state = "disguise"

	cast(atom/target)
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		if (mindeater.disguised)
			mindeater.undisguise()
		else
			mindeater.disguise()

/datum/targetable/critter/mindeater/confuse

/datum/targetable/critter/mindeater/shades
	name = "Shades"
	desc = "Create shades of yourself, swapping places with one, that move when you do."
	icon_state = "shades"
	cooldown = 0//60 SECONDS
	reveals_on_use = TRUE

	cast(atom/target)
		. = ..()
		var/list/adjacent_turfs = list()
		if (prob(50))
			adjacent_turfs += get_step(src.holder.owner, NORTH)
			adjacent_turfs += get_step(src.holder.owner, EAST)
			adjacent_turfs += get_step(src.holder.owner, WEST)
			adjacent_turfs += get_step(src.holder.owner, SOUTH)
		else
			adjacent_turfs += get_step(src.holder.owner, NORTHEAST)
			adjacent_turfs += get_step(src.holder.owner, NORTHWEST)
			adjacent_turfs += get_step(src.holder.owner, SOUTHEAST)
			adjacent_turfs += get_step(src.holder.owner, SOUTHWEST)

		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		var/list/fake_mindeaters = list()
		for (var/turf/T as anything in adjacent_turfs)
			var/obj/dummy/fake_mindeater/fake = new /obj/dummy/fake_mindeater(get_turf(src.holder.owner))
			fake.glide_size = src.holder.owner.glide_size
			fake_mindeaters += fake
		for (var/i in 1 to length(fake_mindeaters))
			var/obj/dummy/fake_mindeater/fake = fake_mindeaters[i]
			fake.set_loc(adjacent_turfs[i])
			fake.set_dir(src.holder.owner.dir)

		mindeater.setup_fake_mindeaters(fake_mindeaters)

		if (prob(80))
			shuffle_list(fake_mindeaters)
			var/turf/T1 = get_turf(fake_mindeaters[1])
			var/turf/T2 = get_turf(mindeater)
			mindeater.set_loc(T1)
			var/obj/dummy/fake_mindeater/fake = fake_mindeaters[1]
			fake.set_loc(T2)
			fake.set_dir(src.holder.owner.dir)

/datum/targetable/critter/mindeater/abduct

	cast(atom/target)
		. = ..()


/datum/action/bar/private/mindeater_regenerate
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_ACT
	duration = 1 SECONDS
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
		mindeater.HealDamage("All", 1, 1, 1)
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
	var/mob/living/carbon/human/target

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

		src.target.take_brain_damage(3)
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
		return GET_DIST(src.owner, src.target) > abil.max_range || src.target.get_brain_damage() > 100
