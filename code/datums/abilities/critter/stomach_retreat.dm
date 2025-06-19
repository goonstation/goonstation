/datum/targetable/critter/stomach_retreat
	name = "Retreat to Stomach"
	desc = "Turn yourself inside out for shelter! Must be inside a disposal chute."
	icon_state = "mimic_stomach_retreat"
	cooldown = 120 SECONDS
	cooldown_after_action = TRUE
	needs_turf = FALSE
	var/inside = FALSE
	var/obj/current_container = null
	var/last_appearance = null


	New()
		..()
		if (!holder.owner.GetComponent(/datum/component/death_barf))
			holder.owner.AddComponent(/datum/component/death_barf)

	cast(atom/target)
		. = ..()
		if (inside)
			switch(tgui_alert(holder.owner, "Leave yourself?", "Retreat to Stomach", list("Yes", "No")))
				if ("Yes")
					deactivate()
					return TRUE
				if ("No")
					return TRUE
		var/obj/target_container = holder.owner.loc
		if (!isobj(target_container))
			boutput(holder.owner, SPAN_ALERT("You gotta be inside a chute or something to do that!"))
			return TRUE

		var/datum/component/mimic_stomach/component = target_container.GetComponent(/datum/component/mimic_stomach)
		if (component)
			boutput(holder.owner, SPAN_ALERT("There's already a mimic in here!"))
			return TRUE

		switch(tgui_alert(holder.owner, "Retreat into yourself to heal?", "Retreat to Stomach", list("Yes", "No")))
			if ("Yes")
				activate(target_container)
			if ("No")
				return TRUE

	proc/activate(obj/target)
		var/mob/parent = holder.owner
		var/datum/component/mimic_stomach/component = target.GetComponent(/datum/component/mimic_stomach)
		var/datum/targetable/critter/stomach_retreat/abil = parent.getAbility(/datum/targetable/critter/stomach_retreat)
		if (!component)
			component = target.AddComponent(/datum/component/mimic_stomach)
		if (istypes(target, component.trap_whitelist) && !istypes(target, component.trap_blacklist))
			component.mimic_move(parent, target)
		else
			boutput(holder.owner, SPAN_ALERT("You can't seem to get a grip in here!"))
			component.RemoveComponent(/datum/component/mimic_stomach)
			return
		abil.inside = TRUE
		src.current_container = target
		if (istype(parent, /mob/living/critter/mimic/antag_spawn))
			var/mob/living/critter/mimic/antag_spawn/mimic = parent
			src.last_appearance = mimic.type
			mimic.disguise_as(/obj/mimicdummy)
			mimic.base_form = FALSE
			mimic.UpdateIcon()

	proc/deactivate()
		var/mob/parent = holder.owner
		var/datum/component/mimic_stomach/component = src.current_container.GetComponent(/datum/component/mimic_stomach)
		var/datum/targetable/critter/stomach_retreat/abil = parent.getAbility(/datum/targetable/critter/stomach_retreat)
		abil.inside = FALSE
		abil.afterAction()
		component.mimic_move(exit=TRUE)
		component.RemoveComponent(/datum/component/mimic_stomach)
		if (!istype(parent, /mob/living/critter/mimic/antag_spawn))
			return
		var/mob/living/critter/mimic/antag_spawn/mimic = parent
		if (src.last_appearance == /mob/living/critter/mimic/antag_spawn) // istype doesn't work here
			mimic.disguise_as(base_return=TRUE)
		else
			mimic.disguise_as(src.last_appearance)
			src.last_appearance = null
