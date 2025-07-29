/datum/abilityHolder/mindeater
	usesPoints = TRUE
	var/max_points = MINDEATER_MAX_INTELLECT_THRESHOLD

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

	proc/get_nearest_human(atom/target)
		if (ishuman(target))
			return target
		for (var/mob/living/L in view(1, get_turf(target)))
			if (!ishuman(L))
				continue
			return L

	proc/get_nearest_human_or_silicon(atom/target)
		if (ishuman(target))
			return target
		for (var/mob/living/L in view(1, get_turf(target)))
			if (!(ishuman(L) || issilicon(L)))
				continue
			return L

	proc/get_nearest_living(atom/target)
		if (isliving(target))
			return target
		for (var/mob/living/L in view(1, get_turf(target)))
			if (!(ishuman(L) || issilicon(L) || (iscritter(L) && !istype(L, /mob/living/critter/mindeater))))
				continue
			return L

/datum/targetable/critter/mindeater/manifest
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

/datum/targetable/critter/mindeater/brain_drain
	name = "Brain Drain"
	desc = "Gain 6 Intellect per second from a target in range. Intellect gained is reduced by mind-shielding drugs. Reveals you on use."
	icon_state = "brain_drain"
	targeted = TRUE
	target_anything = TRUE
	max_range = 4
	reveals_on_use = TRUE

	tryCast(atom/target)
		if (actions.hasAction(src.holder.owner, /datum/action/bar/private/mindeater_brain_drain))
			actions.stopId(/datum/action/bar/private/mindeater_brain_drain, src.holder.owner)
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		target = src.get_nearest_human_or_silicon(target)
		var/mob/living/L = target
		if (!(istype(L, /mob/living/carbon/human) || istype(L, /mob/living/silicon)))
			boutput(src.holder.owner, SPAN_ALERT("You can only target humans and silicons!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (isdead(L))
			boutput(src.holder.owner, SPAN_ALERT("You can only use this ability on alive targets!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (L.hasStatus("mindeater_brain_draining"))
			boutput(src.holder.owner, SPAN_ALERT("This target is already being brain drained!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		actions.start(new /datum/action/bar/private/mindeater_brain_drain(target), src.holder.owner)

/datum/targetable/critter/mindeater/regenerate
	name = "Regenerate"
	desc = "Regenerate health over time."
	icon_state = "regenerate"

	tryCast()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		if (mindeater.get_health_percentage() >= 1)
			boutput(mindeater, SPAN_ALERT("You're already at full health!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast(atom/target)
		. = ..()
		if (actions.hasAction(src.holder.owner, /datum/action/bar/private/mindeater_regenerate))
			actions.stopId(/datum/action/bar/private/mindeater_regenerate, src.holder.owner)
		else
			actions.start(new /datum/action/bar/private/mindeater_regenerate(), src.holder.owner)

/datum/targetable/critter/mindeater/paralyze
	name = "Paralyze"
	desc = {"Casts on the target you are brain draining. Paralyzes them, making them unable to control their movement and reduces their vision.
			For each lack of 10 Intellect on them (out of 100), make them take 1 step towards you and receive a stab."}
	icon_state = "paralyze"
	cooldown = 20 SECONDS
	max_range = 5
	reveals_on_use = TRUE

	tryCast()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		if (!mindeater.drain_target)
			boutput(src.holder.owner, SPAN_ALERT("You don't have a Brain Drain target!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		if (GET_ATOM_PROPERTY(mindeater.drain_target, PROP_MOB_INTELLECT_COLLECTED) >= (MINDEATER_MAX_INTELLECT_THRESHOLD - 10))
			boutput(src.holder.owner, SPAN_ALERT("You have too much Intellect collected on this mob!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast()
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		var/mob/living/L = mindeater.drain_target

		playsound(get_turf(mindeater), 'sound/misc/intruder/paralyze.ogg', 35, TRUE)
		SPAWN(0)
			mindeater.casting_paralyze = TRUE
			APPLY_ATOM_PROPERTY(L, PROP_MOB_CANTMOVE, mindeater)
			APPLY_ATOM_PROPERTY(L, PROP_MOB_CANTTURN, mindeater)
			L.addOverlayComposition(/datum/overlayComposition/weldingmask)
			L.updateOverlaysClient(L.client)

			for (var/i in 1 to floor((MINDEATER_MAX_INTELLECT_THRESHOLD - GET_ATOM_PROPERTY(L, PROP_MOB_INTELLECT_COLLECTED)) / 10))
				sleep(0.75 SECONDS)
				L.Move(get_step(L, get_dir(L, mindeater)), get_dir(L, mindeater))
				take_bleeding_damage(L, null, 2.5, pick(DAMAGE_CUT, DAMAGE_STAB))
				playsound(get_turf(L), 'sound/impact_sounds/Flesh_Cut_1.ogg', 50, TRUE)
			mindeater.casting_paralyze = FALSE
			REMOVE_ATOM_PROPERTY(L, PROP_MOB_CANTMOVE, mindeater)
			REMOVE_ATOM_PROPERTY(L, PROP_MOB_CANTTURN, mindeater)
			L.removeOverlayComposition(/datum/overlayComposition/weldingmask)
			L.updateOverlaysClient(L.client)

/datum/targetable/critter/mindeater/pierce_the_veil
	name = "Pierce the Veil"
	desc = {"Channel on the mob you are brain draining using a 3 charge shield to send them to the border of the Intruder plane for 60 seconds, where
			they must survive in an arena. If the target has max Intellect collected on them, they will be sent faster."}
	icon_state = "pierce_the_veil"
	cooldown = 60 SECONDS
	max_range = 6
	pointCost = MINDEATER_MAX_INTELLECT_THRESHOLD
	reveals_on_use = TRUE

	tryCast(atom/target)
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		if (!mindeater.drain_target)
			boutput(src.holder.owner, SPAN_ALERT("You don't have a Brain Drain target!"))
			return CAST_ATTEMPT_FAIL_NO_COOLDOWN
		return ..()

	cast()
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		playsound(get_turf(mindeater), 'sound/misc/intruder/mindeater_abduct.ogg', 35, TRUE)
		actions.start(new /datum/action/bar/mindeater_pierce_the_veil(mindeater.drain_target), mindeater)

ABSTRACT_TYPE(/area/veil_border)
/area/veil_border
	name = "Veil border"
	teleport_blocked = 2
	allowed_restricted_z = TRUE
	sound_loop = 'sound/misc/intruder/veil_border_ambience.ogg'
	sound_group = "veil border"
	area_parallax_render_source_group = /datum/parallax_render_source_group/area/veil_border

	inner
		occlude_foreground_parallax_layers = TRUE

	outer
		occlude_foreground_parallax_layers = FALSE

/datum/targetable/critter/mindeater/set_disguise
	name = "Set Disguise"
	desc = "Set what you will disguise as. Human disguises have door access tied to the job disguised as. Critters may move through doors/tables, but take increased damage and have reduced stamina."
	icon_state = "set_disguise"
	pointCost = 0

	cast()
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		var/option = tgui_input_list(src.holder.owner, "What would you like to disguise as?", "Set Disguise", list(MINDEATER_DISGUISE_MOUSE, MINDEATER_DISGUISE_COCKROACH, MINDEATER_DISGUISE_HUMAN))

		if (!option)
			return
		mindeater.set_disguise = option
		if (option == MINDEATER_DISGUISE_HUMAN)
			mindeater.human_disguise_job = tgui_input_list(mindeater, "What job?", "Set Human Disguise Job", \
												list("Staff Assistant",
													 "Botanist",
													 "Engineer",
													 "Medical Doctor",
													 "Scientist")) || "Staff Assistant"

/datum/targetable/critter/mindeater/disguise
	name = "Disguise"
	desc = "Channel over 3 seconds to disguise yourself as a creature."
	icon_state = "disguise"
	pointCost = 0
	reveals_on_use = TRUE

	cast(atom/target)
		. = ..()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner

		if (mindeater.casting_disguise)
			actions.stopId(/datum/action/bar/private/mindeater_disguise, mindeater)
			return

		if (!mindeater.disguised)
			if (!mindeater.casting_disguise)
				actions.start(new /datum/action/bar/private/mindeater_disguise(src), mindeater)
		else
			mindeater.undisguise()

	proc/perform_disguise()
		var/mob/living/critter/mindeater/mindeater = src.holder.owner
		mindeater.disguise()

		src.name = "Clear Disguise"
		src.desc = "Clear your disguise."
		src.icon_state = "clear_disguise"
		src.updateObject()

	proc/reset()
		src.name = initial(src.name)
		src.desc = initial(src.desc)
		src.icon_state = initial(src.icon_state)
		src.updateObject()

/datum/action/bar/private/mindeater_regenerate
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_ATTACKED | INTERRUPT_ACT
	duration = 0.5 SECONDS
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
	interrupt_flags = INTERRUPT_STUNNED
	duration = 1 SECONDS
	resumable = FALSE
	color_success = "#4444FF"
	var/mob/living/target

	New(atom/target)
		..()
		src.target = target

	disposing()
		src.target = null
		..()

	onStart()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return
		src.target.setStatus("mindeater_brain_draining", INFINITE_STATUS)
		var/mob/living/critter/mindeater/mindeater = src.owner
		mindeater.drain_target = src.target

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
		mindeater.collect_intellect(src.target, 6)

		if (ishuman(src.target))
			src.target.setStatus("mindeater_mind_eating_human", INFINITE_STATUS, src.owner)
			var/mob/living/carbon/human/H = src.target

			if (GET_ATOM_PROPERTY(src.target, PROP_MOB_INTELLECT_COLLECTED) < MINDEATER_MAX_INTELLECT_THRESHOLD)
				if (H.get_brain_damage() <= MINDEATER_BRAIN_DMG_CAP)
					H.take_brain_damage(2)
				var/pick = rand(1, 3)
				switch (pick)
					if (1)
						H.TakeDamage("All", 2, hit_twitch = FALSE)
					if (2)
						H.TakeDamage("All", burn = 2, hit_twitch = FALSE)
					if (3)
						H.TakeDamage("All", tox = 2, hit_twitch = FALSE)

			if (H.reagents)
				var/amt = min(max(H.reagents.total_volume - H.reagents.get_reagent_amount("toxin"), 0), 1)
				if (amt > 0)
					H.reagents.remove_any_except(amt, "toxin")
					H.reagents.add_reagent("toxin", amt / 8)
		else
			if (istype(src.target, /mob/living/silicon/ai))
				src.target.TakeDamage("All", src.target.max_health / 20, damage_type = DAMAGE_CRUSH)
			else if (istype(src.target, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/cyborg = src.target
				src.target.TakeDamage("head", cyborg.part_head.max_health / 20, damage_type = DAMAGE_CRUSH)
			else
				src.target.TakeDamage("All", src.target.max_health / 20, damage_type = DAMAGE_CRUSH)
			src.target.setStatus("mindeater_mind_eating_silicon", 3 SECONDS, src.owner)

		src.onRestart()

	onInterrupt(flag)
		..()
		if (flag & INTERRUPT_ALWAYS)
			src.target.delStatus("mindeater_brain_draining")
			var/mob/living/critter/mindeater/mindeater = src.owner
			mindeater.drain_target = null

	proc/check_for_interrupt()
		var/mob/living/critter/mindeater/mindeater = src.owner
		var/datum/abilityHolder/abil_holder = mindeater.get_ability_holder(/datum/abilityHolder/mindeater)
		var/datum/targetable/critter/mindeater/brain_drain/abil = abil_holder.getAbility(/datum/targetable/critter/mindeater/brain_drain)
		return !(src.target in viewers(abil.max_range, get_turf(src.owner))) || isdead(src.target)

/datum/action/bar/mindeater_pierce_the_veil
	interrupt_flags = INTERRUPT_ACTION
	duration = 5 SECONDS
	resumable = FALSE
	color_success = "#4444FF"
	var/mob/living/target

	New(atom/target)
		if (GET_ATOM_PROPERTY(target, PROP_MOB_INTELLECT_COLLECTED) >= MINDEATER_MAX_INTELLECT_THRESHOLD)
			src.duration = 3 SECONDS
		..()
		src.target = target

	disposing()
		src.target = null
		..()

	onStart()
		..()
		if(src.check_for_interrupt())
			interrupt(INTERRUPT_ALWAYS)
			return
		src.owner.setStatus("pierce_the_veil_shield", INFINITE_STATUS)

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

		src.target.setStatus("mindeater_abducted", 60 SECONDS, list(get_turf(src.target), src.owner))

		src.owner.delStatus("pierce_the_veil_shield")

	onInterrupt()
		..()
		src.owner.delStatus("pierce_the_veil_shield")

	proc/check_for_interrupt()
		var/mob/living/critter/mindeater/mindeater = src.owner
		var/datum/abilityHolder/abil_holder = mindeater.get_ability_holder(/datum/abilityHolder/mindeater)
		var/datum/targetable/critter/mindeater/pierce_the_veil/abil = abil_holder.getAbility(/datum/targetable/critter/mindeater/pierce_the_veil)
		return isdead(src.target) || GET_DIST(src.target, mindeater) >= abil.max_range

/datum/action/bar/private/mindeater_disguise
	interrupt_flags = INTERRUPT_STUNNED
	duration = 3 SECONDS
	resumable = FALSE
	color_success = "#4444FF"
	var/datum/targetable/critter/mindeater/disguise/disguise_abil

	New(datum/targetable/critter/mindeater/disguise/abil)
		..()
		src.disguise_abil = abil

	disposing()
		src.disguise_abil = null
		..()

	onStart()
		..()
		var/mob/living/critter/mindeater/mindeater = src.owner
		mindeater.casting_disguise = TRUE

	onInterrupt()
		..()
		var/mob/living/critter/mindeater/mindeater = src.owner
		mindeater.casting_disguise = FALSE

	onEnd()
		..()
		src.disguise_abil.perform_disguise()
		var/mob/living/critter/mindeater/mindeater = src.owner
		mindeater.casting_disguise = FALSE
