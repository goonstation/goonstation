/datum/targetable/vampire/vamp_cloak
	name = "Toggle cloak"
	desc = "Toggles your cloak of darkness, which is only effective in dark areas."
	icon_state = "darkcloak"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 0
	unlock_message = "You have gained cloak of darkness. It makes you invisible in dark areas and is a toggleable, permanent effect."
	interrupt_action_bars = FALSE
	do_logs = FALSE

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M)
			return 1

		if (!ishuman(M)) // Only humans use bioeffects at the moment.
			boutput(M, SPAN_ALERT("You can't use this ability in your current form."))
			return 1

		var/mob/living/carbon/human/MM = M
		if (!MM.bioHolder)
			boutput(MM, SPAN_ALERT("You can't use this ability in your current form."))
			return 1

		. = ..()
		if (MM.bioHolder.HasEffect("cloak_of_darkness"))
			MM.bioHolder.RemoveEffect("cloak_of_darkness")
			MM.set_body_icon_dirty() // Might help to get rid of those overlay issues.
		else
			var/datum/bioEffect/power/darkcloak/DC = MM.bioHolder.AddEffect("cloak_of_darkness")
			if (DC && istype(DC))
				DC.active = 1 // Important!
				MM.set_body_icon_dirty()

		return 0
