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

	cast(atom/target)
		. = ..()
		if (inside)
			switch(tgui_alert(holder.owner, "Leave yourself?", "Retreat to Stomach", list("Yes.", "No.")))
				if ("Yes.")
					deactivate()
					return TRUE
				if ("No.")
					return TRUE
		var/obj/target_container = holder.owner.loc
		if (!isobj(target_container))
			boutput(holder.owner, SPAN_ALERT("There isn't anything to climb into here!"))
			return TRUE

		var/datum/component/mimic_stomach/component = target_container.GetComponent(/datum/component/mimic_stomach)
		if (component)
			boutput(holder.owner, SPAN_ALERT("There's already a mimic in here!"))
			return TRUE

		switch(tgui_alert(holder.owner, "Retreat into yourself to heal?", "Retreat to Stomach", list("Yes.", "No.")))
			if ("Yes.")
				activate(target_container)
			if ("No.")
				return TRUE

	proc/activate(obj/target)
		var/mob/living/critter/parent = holder.owner
		var/datum/component/mimic_stomach/component = parent.GetComponent(/datum/component/mimic_stomach)
		var/datum/targetable/critter/stomach_retreat/abil = parent.getAbility(/datum/targetable/critter/stomach_retreat)
		abil.inside = TRUE
		component.mimic_move(parent, target)
		last_appearance = parent.appearance
		parent.appearance = /obj/mimicdummy
		parent.UpdateIcon()

	proc/deactivate()
		var/mob/living/critter/parent = holder.owner
		var/datum/component/mimic_stomach/component = parent.GetComponent(/datum/component/mimic_stomach)
		var/datum/targetable/critter/stomach_retreat/abil = parent.getAbility(/datum/targetable/critter/stomach_retreat)
		abil.inside = FALSE
		abil.afterAction()
		component.mimic_move(exit=TRUE)
		parent.appearance = last_appearance
		last_appearance = null
		parent.UpdateIcon()
