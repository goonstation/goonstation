//AI HOLOGRAMS
/mob/living/silicon/ai
	contextLayout = new /datum/contextLayout/experimentalcircle(36)

	proc/create_hologram()
		if (!deployed_to_eyecam)
			boutput(src, "Deploy to an AI Eye first to create a hologram.")
			return
		if (length(holograms)>= max_holograms)
			boutput(eyecam, "Not enough RAM to project more holograms. Delete others to make room.")
			return

		var/turf/T = get_turf(src.eyecam)
		src.show_hologram_context(T)

	proc/create_hologram_at_turf(var/turf/T, var/holo_type)
		if (!deployed_to_eyecam)
			boutput(src, "Deploy to an AI Eye first to create a hologram.")
			return
		if (length(holograms)>= max_holograms)
			boutput(eyecam, "Not enough RAM to project more holograms. Delete others to make room.")
			return
		if (!istype(T) || !istype(T.cameras) || T.cameras.len == 0)
			boutput(eyecam, "No camera available to project a hologram from.")
			return

		new /obj/hologram(T, owner=src, holo_type=holo_type)

	proc/show_hologram_context(var/turf/T)
		showContextActions(hologramContextActions, T, contextLayout)

/datum/contextAction/ai_hologram
	var/mob/living/silicon/ai/mainframe
	var/holo_type

	New(var/mob/mainframe)
		..()
		src.mainframe = mainframe

	checkRequirements(atom/target, mob/user)
		return 1

	execute(var/atom/target, var/mob/user)
		mainframe.create_hologram_at_turf(target, holo_type)

		..()

	caution
		name = "Caution"
		icon_state = "caution"
		holo_type = "caution"
	o2
		name = "o2"
		icon_state = "o2"
		holo_type = "o2"
	beepsky
		name = "beepsky"
		icon_state = "beepsky"
		holo_type = "beepsky"
	up_arrow
		name = "up_arrow"
		icon_state = "up_arrow"
		holo_type = "up_arrow"
	down_arrow
		name = "down_arrow"
		icon_state = "down_arrow"
		holo_type = "down_arrow"
	left_arrow
		name = "left_arrow"
		icon_state = "left_arrow"
		holo_type = "left_arrow"
	right_arrow
		name = "right_arrow"
		icon_state = "right_arrow"
		holo_type = "right_arrow"
	happy_face
		name = "happy_face"
		icon_state = "happy_face"
		holo_type = "happy_face"
	neutral_face
		name = "neutral_face"
		icon_state = "neutral_face"
		holo_type = "neutral_face"
	sad_face
		name = "sad_face"
		icon_state = "sad_face"
		holo_type = "sad_face"
	angry_face
		name = "angry_face"
		icon_state = "angry_face"
		holo_type = "angry_face"

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


