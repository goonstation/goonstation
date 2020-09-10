//A button that kills you if you press it.  Used to log out of VR. And definitely not rude varedit trickery.

//A button that kills you if you press it. That's pretty much the gist of it.
/obj/death_button
	name = "button that will kill you if you press it"
	desc = "A button.  One that kills you (if you press it)."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	layer = EFFECTS_LAYER_UNDER_1
	anchored = 1
	var/numkills = 0

	get_desc()
		if (numkills > 1)
			. = "Much like the last [get_english_num(numkills)] people who pressed it."
		else if (numkills > 0)
			. = "Like the last jerk that pressed it."

	attack_hand(mob/user as mob)
		var/dca = deathConfettiActive //Save the current state of death confetti
		if (!user.stat)
			deathConfettiActive = 1	//Yaaaaaaaaaaaaaaaay!!
			user.death()
			if(!user || isdead(user)) //User gibbed or actually dead.
				numkills++
				if (numkills == 100)
					name = "blue ribbon [src.name]"
					src.overlays += new /image {icon = 'icons/misc/stickers.dmi'; icon_state = "1st_place"; pixel_x = 3; pixel_y = -2} ()

			deathConfettiActive = dca	//Restore it.
		return

/obj/racist_button
	name = "button that will make you racist if you press it"
	desc = "A button.  One that makes you racist (if you press it)."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	layer = EFFECTS_LAYER_UNDER_1
	anchored = 1

	attack_hand(mob/user as mob)
		var/mob/living/carbon/human/H = user
		if (istype(H))

			if(H.bioHolder)
				H.visible_message("<span class='alert'><B>[H.name] is too racist!</B></span>", "<span class='alert'><B>That's too racist!</B></span>")
				H.owlgib()
