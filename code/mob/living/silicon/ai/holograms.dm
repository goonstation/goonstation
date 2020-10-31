//AI HOLOGRAMS
/mob/living/silicon/ai/proc/create_hologram()
	if (!deployed_to_eyecam)
		boutput(src, "Deploy to an AI Eye first to create a hologram.")
		return
	if (length(holograms)>= max_holograms)
		boutput(eyecam, "Not enough RAM to project more holograms. Delete others to make room.")
		return
	//select from list of icon_state in holograms.dmi
	var/input = input("Select a type of hologram to display.","Hologram") as null|anything in list("caution","o2","beepsky","up_arrow","down_arrow","left_arrow","right_arrow","happy_face","neutral_face","sad_face","angry_face")
	if (input)
		if (!deployed_to_eyecam)
			boutput(src, "Deploy to an AI Eye first to create a hologram.")
			return
		if (length(holograms)>= max_holograms)
			boutput(eyecam, "Not enough RAM to project more holograms. Delete others to make room.")
			return
		var/turf/T = get_turf(src.eyecam)
		if (!istype(T) || !istype(T.cameras) || T.cameras.len == 0)
			boutput(eyecam, "No camera available to project a hologram from.")
			return

		new /obj/hologram(T, owner=src, holo_type=input)

/obj/hologram
	name = "hologram"
	desc = "A hologram projected by an AI. Usually lasts about 30 seconds."
	icon = 'icons/misc/holograms.dmi'
	icon_state = "caution"
	anchored = 1
	density = 0
	alpha = 0		//animates to 180 in New
	// plane = PLANE_HUD
	var/duration = 30 SECONDS
	var/mob/living/silicon/ai/owner


	New(var/mob/living/silicon/ai/owner, var/holo_type)
		animate(src, alpha = 180, time = 10, easing = SINE_EASING)
		if (istype(owner))
			src.owner = owner
			src.color = owner.faceColor
			if (islist(owner.holograms))
				owner.holograms += src

		name = "[replacetext(holo_type, "_", " ")] hologram"
		icon_state = holo_type
		//might still want to use this, idk yet. For like descriptions or names or something...
		// switch(holo_type)
		// 	if ("caution")
		// 	if ("o2")
		// 	if ("beepsky")
		// 	if ("up_arrow")
		// 	if ("down_arrow")
		// 	if ("left_arrow")
		// 	if ("right_arrow")
		// 	if ("happy_face")
		// 	if ("neutral_face")
		// 	if ("sad_face")
		// 	if ("angry_face")

		SPAWN_DBG(duration)
			qdel(src)
		..()

	attack_ai(mob/user as mob)
		..()
		var/mob/dead/aieye/eye = user
		if (owner == user || (istype(eye) && eye.mainframe == owner))
			boutput(src, "<span class='notice'>You stop projecting [src].</span>")
			qdel(src)
		else
			boutput(src, "<span class='notice'>It would be pretty rude for you to mess with another AI's hologram.</span>")

	disposing()
		if (owner)
			owner.holograms -= src
			owner = null
		..()


