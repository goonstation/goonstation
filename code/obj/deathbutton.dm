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

	ex_act()
		return

	attack_hand(mob/user as mob)
		if (!user.stat)
			//Yaaaaaaaaaaaaaaaay!!
			user.AddComponent(/datum/component/death_confetti)

			user.death()
			if(!user || isdead(user)) //User gibbed or actually dead.
				numkills++
				if (numkills == 100)
					name = "blue ribbon [src.name]"
					src.overlays += new /image {icon = 'icons/misc/stickers.dmi'; icon_state = "1st_place"; pixel_x = 3; pixel_y = -2} ()

			var/datum/component/C = user.GetComponent(/datum/component/death_confetti)
			C?.RemoveComponent()
		return
