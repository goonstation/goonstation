/datum/targetable/throw/werewolf
	name = "Throw"
	desc = "Spin a grabbed opponent around and throw them."
	icon = 'icons/mob/werewolf_ui.dmi'
	icon_state = "throw"
	preferred_holder_type = /datum/abilityHolder/werewolf
	cooldown = 30 SECONDS

	castcheck()
		. = ..()
		var/mob/living/carbon/human/user = src.holder.owner

		if (!ishuman(user)) // Only humans use mutantrace datums.
			boutput(user, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return FALSE

		if (!iswerewolf(user))
			boutput(user, "<span class='alert'>You must be in your wolf form to use this ability.</span>")
			return FALSE



