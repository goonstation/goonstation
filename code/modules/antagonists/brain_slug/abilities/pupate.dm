/datum/targetable/brain_slug/pupate
	name = "Pupate"
	desc = "Use all the nutrients in a human body and evolve into your final, deadly form."
	icon_state = "pupate"
	cooldown = 10 SECONDS
	targeted = 0

	cast()
		if (!istype(holder.owner, /mob/living/carbon/human))
			boutput(holder.owner, "<span class='notice'>Only a human body has the necessary nutrients to evolve.</span>")
			return TRUE
		var/mob/living/carbon/human/H = holder.owner
		if (!H.slug)
			boutput(holder.owner, "<span class='notice'>You do not have a brain slug inside of you!</span>")
			return TRUE
		var/choice = tgui_alert(holder.owner, "Are you sure you wish to evolve?", "Evolution", list("Yes", "No"))
		if (!choice || choice == "No")
			return TRUE
		if (choice == "Yes")
			H.make_jittery(1000)
			H.emote("scream")
			H.visible_message("<span class='alert'>[H]'s flesh appears to contort and shift as if something was trying to come out of [him_or_her(H)]!</span>", "<span class='alert'>You begin to evolve into your final form.</span>")
			H.changeStatus("slowed", 8 SECONDS)
			SPAWN (8 SECONDS)
				if (!H || !H.slug)	return
				var/mob/living/critter/adult_brain_slug/new_slug = new /mob/living/critter/adult_brain_slug(H)
				H.mind.transfer_to(new_slug)
				new_slug.visible_message("<span class='alert'>A gigantic monster bursts out of [H]! [pick("GOOD LORD!", "GOD JESUS WHAT THE FUCK!", "You're going to be sick.")]!</span>", "<span class='alert'>You rise!</span>")
				var/mob/living/critter/brain_slug/old_slug = H.slug
				qdel(old_slug)
				H.gib()
