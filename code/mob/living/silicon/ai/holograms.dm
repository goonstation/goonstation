//AI HOLOGRAMS

#define CHARS_PER_HOLOGRAM_POINT 4
#define CHARS_PER_HOLOGRAM (CHARS_PER_HOLOGRAM_POINT*3)
/mob/living/silicon/ai
	contextLayout = new /datum/contextLayout/experimentalcircle(36)

	proc/create_hologram()
		if (!deployed_to_eyecam)
			boutput(src, "Deploy to an AI Eye first to create a hologram.")
			return
		if (holograms >= max_holograms)
			boutput(eyecam, "Not enough RAM to project more holograms. Delete others to make room.")
			return

		var/turf/T = get_turf(src.eyecam)
		src.show_hologram_context(T)

	proc/create_hologram_at_turf(var/turf/T, var/holo_type)
		if (!deployed_to_eyecam)
			boutput(src, "Deploy to an AI Eye first to create a hologram.")
			return
		if (src.holograms >= max_holograms)
			boutput(eyecam, "Not enough RAM to project more holograms. Delete others to make room.")
			return
		if (!istype(T) || !istype(T.cameras) || T.cameras.len == 0)
			boutput(eyecam, "No camera available to project a hologram from.")
			return

		if(holo_type=="write")
			var/t = input(usr, "What do you want to write?", "Hologram Text", null) as null|text
			var/hologram_value = round((length(t) + (CHARS_PER_HOLOGRAM_POINT-1)) / CHARS_PER_HOLOGRAM_POINT)
			if (!t)
				return
			if(length(t) > (CHARS_PER_HOLOGRAM))
				boutput(eyecam, "Too many characters for a single hologram. Limited to [CHARS_PER_HOLOGRAM].")
				return

			if (hologram_value > (max_holograms - src.holograms) )
				boutput(eyecam, "Not enough RAM to project that many characters. Delete others holograms to make room.")
				return

			new /obj/hologram/text(T, owner=src,msg=t)
		else
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
	write
		name = "write"
		icon_state = "write"
		holo_type = "write"

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
	var/hologram_value = 1


	New(var/mob/living/silicon/ai/owner, var/holo_type)
		animate(src, alpha = 180, time = 10, easing = SINE_EASING)
		if (istype(owner))
			src.owner = owner
			src.color = owner.faceColor
			owner.holograms += src.hologram_value

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
			owner.holograms = max(owner.holograms - hologram_value,0)
			owner = null
		..()


/obj/hologram/text
	var/message
	var/static/index = 0
	var/image/clickable_overlay

	New(loc, owner, msg)
		src.hologram_value = round((length(msg) + (CHARS_PER_HOLOGRAM_POINT-1)) / CHARS_PER_HOLOGRAM_POINT)
		..(owner, null)
		if(msg)
			message = copytext(adminscrub(msg), 1, src.owner?.max_holograms * CHARS_PER_HOLOGRAM_POINT)

		maptext_width = 96
		maptext_x = -(96 / 2) + 16
		maptext = {"<span class='vm c ps2p sh'>[message]</span>"}

		if(owner)
			var/matrix/M = matrix()
			M.Scale(max(length(msg)/4,1),1)
			src.clickable_overlay = image(src.icon, src, "write_ai_overlay", src.layer)
			clickable_overlay.transform = M

			usr << src.clickable_overlay

		SPAWN_DBG(rand(1 SECOND, 10 SECONDS))
			// Lame Glitch Text
			animate(src, pixel_x = 2, time = 5, easing = ELASTIC_EASING, loop=-1, flags=ANIMATION_PARALLEL)
			animate(pixel_x = 0, time = 20, easing = SINE_EASING)
			animate(time = rand(30,50))

			if(prob(50))
				// Hue Shift
				var/orig_color = src.color
				var/rgb = hex_to_rgb_list(orig_color)
				var/hsv = rgb2hsv(rgb[1], rgb[2], rgb[3])
				var/new_color = hsv2rgb( hsv[1]+rand(30,70)%360, hsv[2], hsv[3] )

				animate(src, color=new_color, alpha=140, time = 30, easing = LINEAR_EASING, loop=-1, flags=ANIMATION_PARALLEL)
				animate(color=orig_color, alpha=180, time = 10, easing = SINE_EASING)
				animate(time=rand(30,50))

			else
				// Oscilate alpha
				animate(src, alpha=120, time=50, easing = LINEAR_EASING, loop=-1, flags=ANIMATION_PARALLEL)
				animate(alpha=180, time=15, easing = CUBIC_EASING)
				animate(time=rand(10,30))

	disposing()
		del(clickable_overlay)
		. = ..()



