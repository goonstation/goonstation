//AI HOLOGRAMS

#define HOLOGRAM_PICTURE 1
#define HOLOGRAM_TEXT 2

/datum/ai_hologram_data
	var/image_expansion
	var/holograms = 0
	var/const/max_holograms = 8
	var/list/text_expansion = list()
	var/text_holograms = 0
	var/const/max_text_holograms = 3

	proc/reserve(obj/hologram/H)
		if(!istype(H))
			return
		switch(H.hologram_type)
			if(HOLOGRAM_PICTURE)
				src.holograms += H.hologram_value
			if(HOLOGRAM_TEXT)
				src.text_holograms += H.hologram_value

	proc/free(obj/hologram/H)
		if(!istype(H))
			return
		switch(H.hologram_type)
			if(HOLOGRAM_PICTURE)
				src.holograms = max(src.holograms - H.hologram_value, 0)
			if(HOLOGRAM_TEXT)
				src.text_holograms = max(src.text_holograms - H.hologram_value, 0)

	proc/check(holotype_string, mob/living/intangible/aieye/E)
		. = TRUE
		if(!istype(E))
			. = FALSE
		switch(holotype_string)
			if("write")
				if (src.text_holograms >= src.max_text_holograms)
					boutput(E, "Not enough T-RAM to project more text holograms. Delete others to make room.")
					. = FALSE
			else
				if (src.holograms >= src.max_holograms)
					boutput(E, "Not enough V-RAM to project more holograms. Delete others to make room.")
					. = FALSE

/mob/living/silicon/ai
	contextLayout = new /datum/contextLayout/experimentalcircle(36)

	proc/create_hologram()
		if (!deployed_to_eyecam)
			boutput(src, "Deploy to an AI Eye first to create a hologram.")
			return

		var/turf/T = get_turf(src.eyecam)
		src.show_hologram_context(T)

	proc/create_hologram_at_turf(turf/T, holo_type)
		if (!deployed_to_eyecam)
			boutput(src, "Deploy to an AI Eye first to create a hologram.")
			return

		if (!istype(T) || length(T?.camera_coverage_emitters) == 0)
			boutput(eyecam, "No camera available to project a hologram from.")
			return

		if(!src.holoHolder.check(holo_type, eyecam))
			return

		if(holo_type == "write")
			var/list/holo_sentences = list()
			var/list/holo_actions = list()
			var/list/holo_nouns = list()
			holo_sentences += strings("hologram.txt", "sentences")
			if(src.holoHolder.text_expansion)
				for(var/te in src.holoHolder.text_expansion)
					holo_sentences += strings("hologram.txt", "sentences_[te]")
			holo_sentences = sortList(holo_sentences, /proc/cmp_text_asc)
			var/text = tgui_input_list(usr, "Select a word:", "Hologram Text", holo_sentences, allowIllegal=TRUE)
			if(!text)
				return

			switch(text)
				if("Remember to ...", "Employees must ...")
					holo_actions += strings("hologram.txt", "verbs")
					if(src.holoHolder.text_expansion)
						for(var/te in src.holoHolder.text_expansion)
							holo_actions += strings("hologram.txt", "verbs_[te]")
					holo_actions = sortList(holo_actions, /proc/cmp_text_asc)
					var/selection = tgui_input_list(usr, "Select a word:", text, holo_actions, allowIllegal=TRUE)
					text = replacetext(text, "...", selection)
				else
					holo_nouns = strings("hologram.txt", "nouns")
					if(src.holoHolder.text_expansion)
						for(var/te in src.holoHolder.text_expansion)
							holo_nouns += strings("hologram.txt", "nouns_[te]")
					holo_nouns = sortList(holo_nouns, /proc/cmp_text_asc)
					var/blank_found = findtext(text,"...")
					while(blank_found)
						var/selection = tgui_input_list(usr, "Select a word:", text, holo_nouns, allowIllegal=TRUE)
						text = replacetext(text, "...", selection, blank_found, blank_found+3)
						blank_found = findtext(text,"...")

			text = uppertext(text)
			new /obj/hologram/text(T, owner=src,msg=text)
		else
			new /obj/hologram(T, owner=src, holo_type=holo_type)

	proc/show_hologram_context(var/turf/T)
		src.eyecam.showContextActions(hologramContextActions, T, contextLayout)

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

	up_arrow
		name = "up_arrow"
		icon_state = "up_arrow"
		holo_type = "up_arrow"
	beepsky
		name = "beepsky"
		icon_state = "beepsky"
		holo_type = "beepsky"
	o2
		name = "o2"
		icon_state = "o2"
		holo_type = "o2"
	caution
		name = "Caution"
		icon_state = "caution"
		holo_type = "caution"
	write
		name = "write"
		icon_state = "write"
		holo_type = "write"
	angry_face
		name = "angry_face"
		icon_state = "angry_face"
		holo_type = "angry_face"
	sad_face
		name = "sad_face"
		icon_state = "sad_face"
		holo_type = "sad_face"
	neutral_face
		name = "neutral_face"
		icon_state = "neutral_face"
		holo_type = "neutral_face"
	happy_face
		name = "happy_face"
		icon_state = "happy_face"
		holo_type = "happy_face"
	right_arrow
		name = "right_arrow"
		icon_state = "right_arrow"
		holo_type = "right_arrow"
	left_arrow
		name = "left_arrow"
		icon_state = "left_arrow"
		holo_type = "left_arrow"
	down_arrow
		name = "down_arrow"
		icon_state = "down_arrow"
		holo_type = "down_arrow"

/obj/hologram
	name = "hologram"
	desc = "A hologram projected by an AI. Usually lasts about 30 seconds."
	icon = 'icons/misc/holograms.dmi'
	icon_state = "caution"
	anchored = ANCHORED
	density = 0
	alpha = 0		//animates to 180 in New
	// plane = PLANE_HUD
	var/duration = 30 SECONDS
	var/mob/living/silicon/ai/owner
	var/hologram_value = 1
	var/hologram_type = HOLOGRAM_PICTURE


	New(var/mob/living/silicon/ai/owner, var/holo_type)
		animate(src, alpha = 180, time = 10, easing = SINE_EASING)
		if (istype(owner))
			src.owner = owner
			src.color = owner.faceColor
			src.owner.holoHolder.reserve(src)

		name = "[replacetext(holo_type, "_", " ")] hologram"
		icon_state = holo_type
		src.flags |= UNCRUSHABLE
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

		SPAWN(duration)
			qdel(src)
		..()

	attack_ai(mob/user as mob)
		..()
		var/mob/living/intangible/aieye/eye = user
		if (owner == user || (istype(eye) && eye.mainframe == owner))
			boutput(src, "<span class='notice'>You stop projecting [src].</span>")
			qdel(src)
		else
			boutput(src, "<span class='notice'>It would be pretty rude for you to mess with another AI's hologram.</span>")

	disposing()
		if (owner)
			owner.holoHolder.free(src)
			owner = null
		..()


/obj/effect/distort/hologram
	icon = 'icons/misc/holograms.dmi' // move to effects?
	icon_state = "d_slow"
	var/distort_size = 2

	glitch
		icon_state = "d_glitch1"

		New()
			..()
			if(prob(33))
				icon_state = pick("d_glitch2", "d_glitch3")
				distort_size = 10

#define MAX_TILES_PER_HOLOGRAM_HORIZONTAL 3
#define MAX_TILES_PER_HOLOGRAM_VERTICAL 2
/obj/hologram/text
	var/message
	var/original_color
	var/hsv
	var/obj/effect/distort/hologram/E
	hologram_type = HOLOGRAM_TEXT

	New(loc, owner, msg)
		..(owner, null)
		if(msg)
			phrase_log.log_phrase("holograms", msg)
			message = copytext(adminscrub(msg), 1)

		var/original_color = src.color ? src.color : "#fff"
		var/rgb = hex_to_rgb_list(original_color)
		src.hsv = rgb2hsv(rgb[1], rgb[2], rgb[3])

		maptext_width = MAX_TILES_PER_HOLOGRAM_HORIZONTAL * 32
		maptext_height = MAX_TILES_PER_HOLOGRAM_VERTICAL * 32
		maptext_x = -(maptext_width / 2) + 16

		maptext = {"<a href="#"><span class='vm c ps2p sh' style='color:white;text-shadow: silver;'>[message]</span></a>"}

		// Add displacement filter for scanline/glitch
		SPAWN(1 DECI SECOND) //delayed to resolve issue where color didn't settle yet
			E = new
			if(length(msg) > 11)
				E.icon_state = "d_fast"
			src.vis_contents += E
			src.filters += filter(type="displace", size=E.distort_size, render_source = E.render_target)

#undef MAX_TILES_PER_HOLOGRAM_HORIZONTAL
#undef MAX_TILES_PER_HOLOGRAM_VERTICAL

///Turns the atom into a transparent, blueish, flickering hologram
///if you want to ignore lighting you also have to render above EVERYTHING ELSE so use with caution
/atom/movable/proc/hologram_effect(over_lighting = FALSE)
	src.color = list(
		1.5, 0, 1, 0,
		0, 1.5, 1, 0,
		0, 0, 1.5, 0,
		0, 0, 0, 0.65,
		0, 0, 0, 0
	)
	if (over_lighting)
		src.plane = PLANE_ABOVE_LIGHTING
	var/obj/effect/distort/hologram/E = new
	E.icon_state = "d_fast"
	src.vis_contents += E
	src.filters += filter(type="displace", size=E.distort_size, render_source = E.render_target)
