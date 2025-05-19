/datum/targetable/critter/stomach_retreat
	name = "Retreat to Stomach"
	desc = "Turn yourself inside out for shelter! Must be inside a disposal chute."
	icon_state = "mimic"
	cooldown = 0 SECONDS
	needs_turf = FALSE
	var/inside = FALSE
	var/current_chute = null
	var/last_appearance = null

	cast(atom/target) // code snatched from disposal_travel
		. = ..()
		if (inside)
			deactivate()
		else
			var/turf/T = get_turf(holder.owner)

			if (!T.z || isrestrictedz(T.z))
				boutput(holder.owner, SPAN_ALERT("You are forbidden from using that here!"))
				return TRUE
			// Attempt entry via disposal machinery OR a disconnected disposal pipe
			if (!istype(holder.owner.loc, /obj/machinery/disposal))
				boutput(holder.owner, SPAN_ALERT("There isn't anything to climb into here!"))
				return TRUE
			else
				current_chute = holder.owner.loc

			boutput(holder.owner, SPAN_ALERT("<b>[holder.owner] turns themself inside out!</b>"))
			activate()

	proc/activate()
		inside = TRUE
		var/mob/living/critter/mimic/antag_spawn/mimic = holder.owner
		mimic.set_loc(mimic.stomachHolder.center)
		last_appearance = mimic.appearance
		mimic.appearance = /obj/mimicdummy
		mimic.UpdateIcon()

	proc/deactivate()
		var/mob/living/critter/mimic/antag_spawn/mimic = holder.owner
		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] turns themself outside in!</b>"))
		mimic.set_loc(get_turf(current_chute))
		mimic.appearance = last_appearance
		last_appearance = null
		mimic.UpdateIcon()

		inside = FALSE
