/datum/targetable/critter/stomach_retreat
	name = "Retreat to Stomach"
	desc = "Turn yourself inside out for shelter! Must be inside a disposal chute."
	icon_state = "mimic_stomach_retreat"
	cooldown = 120 SECONDS
	cooldown_after_action = TRUE
	needs_turf = FALSE
	var/inside = FALSE
	var/obj/machinery/disposal/current_chute = null
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
					if (!T.z || isrestrictedz(T.z))
						boutput(holder.owner, SPAN_ALERT("You are forbidden from using that here!"))
						return TRUE
					// Attempt entry via disposal machinery OR a disconnected disposal pipe
					if (!istype(holder.owner.loc, /obj/machinery/disposal))
						boutput(holder.owner, SPAN_ALERT("There isn't anything to climb into here!"))
						return TRUE
					current_chute = holder.owner.loc
					current_chute.present_mimic = holder.owner
					activate()
				if ("No.")
					return TRUE

	proc/activate()
		var/mob/living/critter/mimic/antag_spawn/mimic = holder.owner
		var/datum/targetable/critter/stomach_retreat/abil = mimic.getAbility(/datum/targetable/critter/stomach_retreat)
		abil.inside = TRUE
		boutput(holder.owner, SPAN_ALERT("<b>[holder.owner] turns themself inside out!</b>"))
		current_chute = holder.owner.loc
		mimic.set_loc(mimic.stomachHolder.center)
		last_appearance = mimic.appearance
		mimic.appearance = /obj/mimicdummy
		mimic.UpdateIcon()

	proc/deactivate()
		var/mob/living/critter/mimic/antag_spawn/mimic = holder.owner
		var/datum/targetable/critter/stomach_retreat/abil = mimic.getAbility(/datum/targetable/critter/stomach_retreat)
		abil.inside = FALSE
		abil.afterAction()
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] turns themself outside in!</b>"))
		mimic.set_loc(current_chute)
		current_chute.present_mimic = null
		current_chute = null
		mimic.appearance = last_appearance
		last_appearance = null
		mimic.UpdateIcon()


