/datum/targetable/critter/stomach_retreat
	name = "Retreat to Stomach"
	desc = "Turn yourself inside out for shelter! Must be inside a disposal chute."
	icon_state = "mimic_stomach_retreat"
	cooldown = 120 SECONDS
	cooldown_after_action = TRUE
	needs_turf = FALSE
	var/inside = FALSE
	var/list/trap_whitelist = list(/obj/machinery/disposal, /obj/storage/)
	var/obj/current_container = null
	var/last_appearance = null

	cast(atom/target)
		. = ..()
		if (inside)
			switch(tgui_alert(holder.owner, "Leave yourself?", "Retreat to Stomach", list("Yes.", "No.")))
				if ("Yes.")
					deactivate()
				if ("No.")
					return TRUE
		else
			switch(tgui_alert(holder.owner, "Retreat into yourself to heal?", "Retreat to Stomach", list("Yes.", "No.")))
				if ("Yes.")
					var/turf/T = get_turf(holder.owner)
					var/obj/target_container = holder.owner.loc
					if (!T.z || isrestrictedz(T.z))
						boutput(holder.owner, SPAN_ALERT("You are forbidden from using that here!"))
						return TRUE
					// Attempt entry via disposal machinery OR a disconnected disposal pipe
					if (target_container.present_mimic)
						boutput(holder.owner, SPAN_ALERT("There's already a mimic in here!"))
						return TRUE
					if (istypes(target_container, trap_whitelist))
						current_container = target_container
						current_container.present_mimic = holder.owner
						activate()
					else
						boutput(holder.owner, SPAN_ALERT("There isn't anything to climb into here!"))
						return TRUE
				if ("No.")
					return TRUE

	proc/activate()
		var/mob/living/critter/parent = holder.owner
		if (!parent.stomachHolder)
			return
		var/datum/targetable/critter/stomach_retreat/abil = parent.getAbility(/datum/targetable/critter/stomach_retreat)
		abil.inside = TRUE
		boutput(parent, SPAN_ALERT("<b>[holder.owner] turns themself inside out!</b>"))
		current_container = holder.owner.loc
		current_container.present_mimic = mimic
		parent.set_loc(parent.stomachHolder.center)
		RegisterSignal(current_container, COMSIG_ATOM_ENTERED, PROC_REF(trap_chomp))
		last_appearance = parent.appearance
		parent.appearance = /obj/mimicdummy
		parent.UpdateIcon()

	proc/deactivate()
		var/mob/living/critter/parent = holder.owner
		var/datum/targetable/critter/stomach_retreat/abil = parent.getAbility(/datum/targetable/critter/stomach_retreat)
		abil.inside = FALSE
		abil.afterAction()
		parent.visible_message(SPAN_ALERT("<b>[parent] turns themself outside in!</b>"))
		parent.set_loc(current_container)
		UnregisterSignal(current_container, COMSIG_ATOM_ENTERED)
		current_container.present_mimic = null
		current_container = null
		parent.appearance = last_appearance
		last_appearance = null
		parent.UpdateIcon()

	proc/trap_chomp()
		var/mob/living/carbon/human/target = locate(/mob/living/carbon/human) in current_container
		if (!target)
			return
		if (GET_COOLDOWN(current_container, "mimicTrap"))
			boutput(target, SPAN_ALERT("<B>You narrowly avoid something biting at you inside the [current_container]!</B>"))
			return

		ON_COOLDOWN(current_container, "mimicTrap", 20 SECONDS)
		var/list/randLimbBase = list("r_arm", "r_leg", "l_arm", "l_leg")
		var/list/randLimb
		for (var/L in randLimbBase) // build a list of limbs the target actually has
			if (target.limbs.get_limb(L))
				LAZYLISTADD(randLimb, L)
		var/obj/item/parts/human_parts/targetLimb = target.limbs.get_limb(pick(randLimb))

		if (targetLimb)
			var/obj/item/limb = targetLimb.sever()
			boutput(target, SPAN_ALERT("Something in the [current_container] tears off [limb]!"))
			target.emote("scream")
			limb.set_loc(current_container.present_mimic.stomachHolder.limb_target_turf)
			current_container.present_mimic.stomachHolder.limb_target_turf = get_turf(pick(current_container.present_mimic.stomachHolder.non_walls))
			playsound(current_container, 'sound/voice/burp_alien.ogg', 60, 1)



