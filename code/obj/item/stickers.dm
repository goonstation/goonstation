
/obj/item/sticker
	name = "sticker"
	desc = "You stick it on something, then that thing is even better, because it has a little sparkly unicorn stuck to it, or whatever."
	flags = FPRINT | TABLEPASS | CLICK_DELAY_IN_CONTENTS | USEDELAY | NOSPLASH
	event_handler_flags = HANDLE_STICKER | USE_FLUID_ENTER
	icon = 'icons/misc/stickers.dmi'
	icon_state = "bounds"
	w_class = W_CLASS_TINY
	force = 0
	throwforce = 0
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	var/dont_make_an_overlay = 0
	var/active = 0
	var/overlay_key
	var/atom/attached
	var/list/random_icons = list()

	New()
		..()
		if (islist(src.random_icons) && length(src.random_icons))
			src.icon_state = pick(src.random_icons)
		pixel_y = rand(-8, 8)
		pixel_x = rand(-8, 8)

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		if (!A)
			return
		if (isarea(A) || istype(A, /obj/item/item_box) || istype(A, /atom/movable/screen) || istype(A, /obj/ability_button))
			return
		user.tri_message(A, "<b>[user]</b> sticks [src] to [A]!",\
			"You stick [src] to [user == A ? "yourself" : "[A]"]!",\
			"[user == A ? "You stick" : "<b>[user]</b> sticks"] [src] to you[user == A ? "rself" : null]!")
		var/pox = src.pixel_x
		var/poy = src.pixel_y
		DEBUG_MESSAGE("pox [pox] poy [poy]")
		if (params)
			if (islist(params) && params["icon-y"] && params["icon-x"])
				pox = text2num(params["icon-x"]) - 16 //round(A.bound_width/2)
				poy = text2num(params["icon-y"]) - 16 //round(A.bound_height/2)
				DEBUG_MESSAGE("pox [pox] poy [poy]")
		src.stick_to(A, pox, poy, user)
		user.u_equip(src)
		return 1

	proc/stick_to(var/atom/A, var/pox, var/poy, user)
		if (!dont_make_an_overlay)
			var/image/sticker = image('icons/misc/stickers.dmi', src.icon_state)
			//sticker.layer = //EFFECTS_LAYER_BASE // I swear to fuckin god stop being under CLOTHES you SHIT
			sticker.layer = A.layer + 1 //Do this instead so the stickers don't show over bushes and stuff.
			sticker.icon_state = src.icon_state
			sticker.appearance_flags = RESET_COLOR

			//pox = clamp(-round(A.bound_width/2), pox, round(A.bound_width/2))
			//poy = clamp(-round(A.bound_height/2), pox, round(A.bound_height/2))
			sticker.pixel_x = pox
			sticker.pixel_y = poy
			overlay_key = "sticker[world.timeofday]"
			A.UpdateOverlays(sticker, overlay_key)
			//	qdel(src) //Don't delete stickers when applied - remove them later through fire or acetone!
			src.invisibility = INVIS_ALWAYS

		else
			src.pixel_x = pox
			src.pixel_y = poy

		src.attached = A
		src.active = 1
		src.set_loc(A)

		playsound(src, 'sound/items/sticker.ogg', 50, 1)
		add_fingerprint(user)
		logTheThing(LOG_STATION, user, "puts a [src]:[src.icon_state] sticker on [A] at [log_loc(A)]")

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		if (prob(50))
			A.visible_message("<span class='alert'>[src] lands on [A] sticky side down!</span>")
			src.stick_to(A,rand(-5,5),rand(-8,8))

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if((temperature > T0C+120) && active)
			qdel(src)

	//Coded this for acetone, but then I realized that it would let people check if they were stuck with a spysticker or not.
	//Going to leave this here just in case, but it's not used for anything right now.
	proc/fall_off()
		if (!active) return
		if (istype(attached,/turf))
			src.set_loc(attached)
		else
			src.set_loc(attached.loc)
		if (!dont_make_an_overlay)
			attached.ClearSpecificOverlays(overlay_key)
			overlay_key = 0
		active = 0
		src.invisibility = INVIS_NONE
		src.pixel_x = initial(pixel_x)
		src.pixel_y = initial(pixel_y)
		attached.visible_message("<span class='alert'><b>[src]</b> un-sticks from [attached] and falls to the floor!</span>")
		attached = 0

	disposing()
		if (attached)
			if (!dont_make_an_overlay && active)
				attached.ClearSpecificOverlays(overlay_key)
			attached.visible_message("<span class='alert'><b>[src]</b> is destroyed!</span>")
		..()

/obj/item/sticker/postit
	// this used to be some paper shit, then it was a cleanable/writing, now it's a sticker
	// since it's a sticky note
	// i am so sorry for all of this. it is probably terrible.
	name = "sticky note"
	desc = "A piece of paper for taking notes, and then sticking those notes to things."
	icon = 'icons/obj/writing.dmi'
	icon_state = "postit"
	dont_make_an_overlay = 1
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	var/words = ""
	var/max_message = 128

	get_desc()
		. = "<br><span class='notice'>It says:</span><br><blockquote style='margin: 0 0 0 1em;'>[words]</blockquote>"

	attack_hand(mob/user)
		user.lastattacked = user
		if (src.attached)
			if (user.a_intent == INTENT_HELP)
				boutput(user, "You peel \the [src] off of \the [src.attached].")
				src.remove_from_attached()
				src.add_fingerprint(user)
				user.put_in_hand_or_drop(src)
			else
				src.attached.Attackhand(user)
				user.lastattacked = user
		else
			return ..()

	attackby(obj/item/W, mob/living/user)
		user.lastattacked = user
		if (istype(W, /obj/item/stamp))

			var/obj/item/stamp/S = W
			switch (S.current_mode)
				if ("Approved")
					src.icon_state = "postit-approved"
				if ("Rejected")
					src.icon_state = "postit-rejected"
				if ("Void")
					src.icon_state = "postit-void"
				if ("X")
					src.icon_state = "postit-x"
				else
					boutput(user, "It doesn't look like that kind of stamp fits here...")
					return

			// words here, info there, result is same: SCREEAAAAAAAMMMMMMMMMMMMMMMMMMM
			src.words += "[src.words ? "<br>" : ""]<b>\[[S.current_mode]\]</b>"
			tooltip_rebuild = 1
			boutput(user, "<span class='notice'>You stamp \the [src].</span>")
			return

		else if (istype(W, /obj/item/pen))
			if(!user.literate)
				boutput(user, "<span class='alert'>You don't know how to write.</span>")
				return ..()
			var/obj/item/pen/pen = W
			pen.in_use = 1
			var/t = input(user, "What do you want to write?", null, null) as null|text
			if (!t)
				pen.in_use = 0
				return
			if ((length(src.words) + length(t)) > src.max_message)
				user.show_text("All that won't fit on [src]!", "red")
				pen.in_use = 0
				return
			logTheThing(LOG_STATION, user, "writes on [src] with [pen] at [log_loc(src)]: [t]")
			t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
			if (src.icon_state == initial(src.icon_state))
				var/search_t = lowertext(t)
				if (copytext(search_t, -1) == "?")
					src.icon_state = "postit-quest"
				else if (copytext(search_t, -1) == "!")
					src.icon_state = "postit-excl"
				else
					src.icon_state = "postit-writing"
			src.words += "[src.words ? "<br>" : ""][t]"
			tooltip_rebuild = 1
			pen.in_use = 0
			src.add_fingerprint(user)
			return

		if (src.attached)
			src.attached.Attackby(W, user)
			user.lastattacked = user
		else
			..()


	stick_to(var/atom/A, var/pox, var/poy)
		..()

		if (istype(src.attached, /mob) || istype(src.attached, /obj))
			var/atom/movable/F = src.attached
			src.layer = F.layer + 0.1
			src.plane = F.plane
			F.vis_contents += src
		else if (istype(src.attached, /turf))
			var/turf/F = src.attached
			src.layer = F.layer + 0.1
			src.plane = F.plane
			F.vis_contents += src

	proc/remove_from_attached()
		if (!src.attached)
			return
		if (istype(src.attached, /atom/movable))
			var/atom/movable/F = src.attached
			F.vis_contents -= src
		else if (istype(src.attached, /turf))
			var/turf/F = src.attached
			F.vis_contents -= src

		src.set_loc(src.attached.loc)
		src.layer = initial(src.layer)
		src.plane = initial(src.plane)
		src.pixel_x = initial(src.pixel_x)
		src.pixel_y = initial(src.pixel_y)
		src.attached = null

	fall_off()
		src.remove_from_attached()
		..()

	disposing()
		src.remove_from_attached()
		..()

/obj/item/sticker/gold_star
	name = "gold star sticker"
	desc = "For when you wanna show someone that they've really accomplished something great."
	icon_state = "gold_star"

/obj/item/sticker/banana
	name = "banana sticker"
	desc = "Wait, can't you just buy your own?"
	icon_state = "banana"
	random_icons = list("banana", "bananas")

/obj/item/sticker/clover
	name = "clover sticker"
	icon_state = "clover"

/obj/item/sticker/umbrella
	name = "umbrella sticker"
	icon_state = "umbrella"

/obj/item/sticker/skull
	name = "skull sticker"
	icon_state = "skull"

/obj/item/sticker/no
	name = "\"no\" sticker"
	icon_state = "no"

/obj/item/sticker/left_arrow
	name = "left arrow sticker"
	icon_state = "Larrow"

/obj/item/sticker/right_arrow
	name = "right arrow sticker"
	icon_state = "Rarrow"

/obj/item/sticker/heart
	name = "heart sticker"
	icon_state = "heart"
	random_icons = list("heart", "rheart")

/obj/item/sticker/moon
	name = "moon sticker"
	icon_state = "moon"

/obj/item/sticker/smile
	name = "smile sticker"
	icon_state = "smile"
	random_icons = list("smile", "smile2")

/obj/item/sticker/frown
	name = "frown sticker"
	icon_state = "frown"
	random_icons = list("frown", "frown2")

/obj/item/sticker/balloon
	name = "red balloon sticker"
	icon_state = "balloon"

/obj/item/sticker/rainbow
	name = "rainbow sticker"
	icon_state = "rainbow"

/obj/item/sticker/horseshoe
	name = "horseshoe sticker"
	icon_state = "horseshoe"

/obj/item/sticker/bee
	name = "bee sticker"
	icon_state = "bee"

/obj/item/sticker/robuddy
	name = "robuddy sticker"
	icon_state = "robuddy"

/obj/item/sticker/xmas_ornament
	name = "ornament"
	desc = "A Spacemas ornament!"
	icon_state = "ornament1"

/obj/item/sticker/xmas_ornament/green
	icon_state = "ornament2"

/obj/item/sticker/xmas_ornament/snowflake
	name = "snowflake ornament"
	icon_state = "snowflake"

/obj/item/sticker/xmas_ornament/holly
	name = "holly ornament"
	icon_state = "holly"

/obj/item/sticker/googly_eye
	name = "googly eye sticker"
	icon_state = "googly1"
	random_icons = list("googly1", "googly2")

	angry
		name = "angry googly eye sticker"
		random_icons = list("googly_angerL", "googly_angerR")

/obj/item/sticker/ribbon
	name = "award ribbon"
	desc = "You're an award winner! You came in, uh... Well it looks like this doesn't say what place you came in, or what it's for. That's weird. But hey, it's an award for something! Maybe it was for being the #1 Farter, or maybe the #8 Ukelele Soloist. Truly, with an award as vague as this, you could be anything!"
	icon_state = "no_place"
	var/placement = "Award-Winning"

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob)
		..()
		if (!A)
			return
		if (!src.placement)
			return
		A.name_prefix(src.placement)
		A.UpdateName()

	first_place
		name = "\improper 1st place award ribbon"
		desc = "You're an award winner! First place! For what? Doesn't matter! You're #1! Woo!"
		icon_state = "1st_place"
		placement = "1st-Place"

	second_place
		name = "\improper 2nd place award ribbon"
		desc = "It's like you intend to be a disappointment and a failure. Were you even trying at all?"
		icon_state = "2nd_place"
		placement = "2nd-Place"

	third_place
		name = "\improper 3rd place award ribbon"
		desc = "Not best, not second best, but still worth mentioning, kinda. That's you! Congrats!"
		icon_state = "3rd_place"
		placement = "3rd-Place"

	participant
		name = "participation ribbon"
		desc = "You showed up, which is really the hardest part. With accreditations like this award ribbon, you've proven you can do anything."
		placement = "Participant"

	voter
		name = "\improper 'I voted' sticker"
		desc = "You voted! That means whatever terrible outcome your vote leads to is <em>your</em> fault. But hey, at least you got a sticker for it!"
		icon_state = "gold_star"
		placement = "Voter"

//	-----------------------------------
//			v Spy Sticker Stuff v
//  -----------------------------------

/obj/item/sticker/spy
	name = "gold star sticker"
	icon_state = "gold_star"
	desc = "This sticker contains a tiny radio transmitter that handles audio and video. Closer inspection reveals an interface on the back with camera, radio, and visual options."
	open_to_sound = 1

	var/has_radio = 1 // just in case you wanted video-only ones, I guess?
	var/obj/item/device/radio/spy/radio = null
	var/radio_path = null

	var/has_camera = 1 // the detective's stickers don't get a camera
	var/obj/machinery/camera/camera = null
	var/camera_tag = "sticker"
	var/camera_network = "stickers"
	var/tv_network = "Zeta"
	var/sec_network = "SS13"

	var/has_selectable_skin = 1 //
	var/list/skins = list("gold_star" = "gold star", "banana", "umbrella", "heart", "clover", "skull", "Larrow" = "left arrow",
	"Rarrow" = "right arrow", "no" = "\"no\"", "moon", "smile", "rainbow", "frown", "balloon", "horseshoe", "bee")

	var/pinpointer_category = TR_CAT_SPY_STICKERS_REGULAR

	var/HTML = null

	New()
		..()
		if (islist(src.skins))
			var/new_skin = pick(src.skins)
			var/new_name = istext(src.skins[new_skin]) ? src.skins[new_skin] : null
			src.set_type(new_skin, new_name)
		if (!src.has_selectable_skin)
			src.verbs -= /obj/item/sticker/spy/verb/set_sticker_type

		if (has_camera)
			src.camera = new /obj/machinery/camera (src)
			src.camera.c_tag = src.camera_tag
			src.camera.network = src.camera_network
			src.camera.set_camera_status(FALSE)
			src.camera_tag = src.name

		if (src.has_radio)
			if (ispath(src.radio_path))
				src.radio = new src.radio_path (src)
			else
				src.radio = new /obj/item/device/radio/spy (src)
			SPAWN(1 DECI SECOND)
				src.radio.broadcasting = 0
				//src.radio.listening = 0

	attack_self(mob/user as mob)
		var/choice = "Set radio"
		if (src.has_camera)
			choice = tgui_alert(user, "What would you like to do with [src]?", "Configure sticker", list("Set radio", "Set camera"))
		if (!choice)
			return
		if (choice == "Set radio")
			src.set_internal_radio(user)
		else
			src.set_internal_camera(user)

	fall_off()
		if (src.radio)
			src.loc.open_to_sound = 0
		if (src.camera)
			src.camera.set_camera_status(FALSE)
			src.camera.c_tag = src.camera_tag
		if(!isnull(pinpointer_category))
			STOP_TRACKING_CAT(pinpointer_category)
		..()

	disposing()
		if ((active) && (attached != null))
			attached.open_to_sound = 0
			if(!isnull(pinpointer_category))
				START_TRACKING_CAT(pinpointer_category)
		if (src.camera)
			qdel(src.camera)
		if (src.radio)
			qdel(src.radio)
		..()

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		if (src.camera)
			src.camera.c_tag = "[src.camera_tag] ([A.name])"
			src.camera.set_camera_status(TRUE)
		if (src.radio)
			src.radio.invisibility = INVIS_ALWAYS
		logTheThing(LOG_COMBAT, user, "places a spy sticker on [constructTarget(A,"combat")] at [log_loc(user)].")

		..()

		if (istype(A, /turf/simulated/wall) || istype(A, /turf/unsimulated/wall))
			src.set_loc(get_turf(user)) //If sticking to a wall, just set the loc to the user loc. Otherwise the spycam would be able to see through walls.

		if (src.radio)
			src.loc.open_to_sound = 1

		if(!isnull(pinpointer_category))
			START_TRACKING_CAT(pinpointer_category)

	proc/generate_html()
		src.HTML = {"<TT>Camera Broadcast Network:<BR>
		[src.camera.network == src.camera_network ? "Spy Monitor (ACTIVE)" : "<A href='byond://?src=\ref[src];change_setting=spynetwork'>Spy Monitor</A>"]<BR>
		[src.camera.network == src.sec_network ? "Security (ACTIVE)" : "<A href='byond://?src=\ref[src];change_setting=secnetwork'>Security</A>"]<BR>
		[src.camera.network == src.tv_network ? "Public Television Broadcast (ACTIVE)" : "<A href='byond://?src=\ref[src];change_setting=tvnetwork'>Public Television Broadcast</A>"]<BR>"}

	proc/set_internal_radio(mob/user as mob)
		if (!ishuman(user) || !src.radio)
			return
		src.radio.attack_self(user)

	proc/set_internal_camera()
		if (!ishuman(usr) || !src.camera)
			return
		src.camera.add_dialog(usr)
		if (!src.HTML)
			src.generate_html()
		usr.Browse(src.HTML, "window=sticker_internal_camera;title=Sticker Internal Camera")
		return

	Topic(href, href_list)
		if (!usr || usr.stat)
			return

		if ((BOUNDS_DIST(src, usr) == 0) || (usr.loc == src.loc))
			src.add_dialog(usr)
			switch (href_list["change_setting"])
				if ("spynetwork")
					if (src.camera)
						src.camera.network = src.camera_network
						src.generate_html()
						src.set_internal_camera(usr)
				if ("secnetwork")
					if (src.camera)
						src.camera.network = src.sec_network
						src.generate_html()
						src.set_internal_camera(usr)
				if ("tvnetwork")
					if (src.camera)
						src.camera.network = src.tv_network
						src.generate_html()
						src.set_internal_camera(usr)

		else
			usr.Browse(null, "window=radio")
			usr.Browse(null, "window=sticker_internal_camera")

	verb/set_sticker_type()
		if (!ishuman(usr) || !islist(src.skins))
			return
		var/new_skin = input(usr,"Select Sticker Type:","Spy Sticker",null) as null|anything in src.skins
		if (!new_skin)
			return
		var/new_name = istext(src.skins[new_skin]) ? src.skins[new_skin] : null
		src.set_type(new_skin, new_name)

	proc/set_type(var/new_skin, var/new_name)
		if (!new_skin)
			return
		src.icon_state = new_skin
		if (new_name)
			src.name = "[new_name] sticker"
		else
			src.name = "[new_skin] sticker"

/obj/item/sticker/spy/radio_only
	desc = "This sticker contains a tiny radio transmitter that handles audio. Closer inspection reveals an interface on the back with radio options."
	has_camera = 0
	has_selectable_skin = 0

/obj/item/sticker/spy/radio_only/det_only
	desc = "This sticker contains a tiny radio transmitter that handles audio. Closer inspection reveals that the frequency is locked to the Security channel."
	radio_path = /obj/item/device/radio/spy/det_only
	pinpointer_category = TR_CAT_SPY_STICKERS_DET

/obj/item/device/camera_viewer/sticker
	name = "camera monitor"
	desc = "A portable video monitor connected to a network of spy cameras."
	icon_state = "monitor"
	item_state = "electronic"
	w_class = W_CLASS_SMALL
	network = "stickers"

/obj/item/storage/box/spy_sticker_kit
	name = "spy sticker kit"
	desc = "Includes everything you need to spy on your unsuspecting co-workers!"
	slots = 8
	spawn_contents = list(/obj/item/sticker/spy = 5,
	/obj/item/device/camera_viewer/sticker,
	/obj/item/device/radio/headset,
	/obj/item/pinpointer/category/spysticker)

/obj/item/storage/box/spy_sticker_kit/radio_only
	spawn_contents = list(/obj/item/sticker/spy/radio_only = 5,
	/obj/item/device/radio/headset)

/obj/item/storage/box/spy_sticker_kit/radio_only/detective
	spawn_contents = list(/obj/item/sticker/spy/radio_only/det_only = 6,
	/obj/item/device/radio/headset/detective,
	/obj/item/pinpointer/category/spysticker/det)

/obj/item/device/radio/spy
	name = "spy radio"
	desc = "Spy radio housed in a sticker. Wait, how are you reading this?"
	listening = 0
	hardened = 0

/obj/item/device/radio/spy/det_only
	locked_frequency = 1
	frequency = R_FREQ_DETECTIVE
	chat_class = RADIOCL_DETECTIVE

ABSTRACT_TYPE(/obj/item/sticker/glow)
/obj/item/sticker/glow
	name = "glow sticker"
	desc = "A sticker that has been engineered to self-illuminate when stuck to things."
	dont_make_an_overlay = TRUE
	icon_state = "glow"
	var/datum/component/loctargeting/simple_light/light_c
	var/col_r = 0
	var/col_g = 0
	var/col_b = 0
	var/brightness = 0.6

	New()
		. = ..()
		color = rgb(col_r*255, col_g*255, col_b*255)
		light_c = src.AddComponent(/datum/component/loctargeting/simple_light, col_r*255, col_g*255, col_b*255, brightness*255)
		light_c.update(0)

	attack_hand(mob/user)
		user.lastattacked = user
		if (src.attached)
			if (user.a_intent == INTENT_HELP)
				boutput(user, "You peel \the [src] off of \the [src.attached].")
				src.remove_from_attached()
				src.add_fingerprint(user)
				user.put_in_hand_or_drop(src)
			else
				src.attached.Attackhand(user)
				user.lastattacked = user
		else
			return ..()

	stick_to(var/atom/A, var/pox, var/poy)
		..()
		if (istype(src.attached, /mob) || istype(src.attached, /obj))
			var/atom/movable/F = src.attached
			src.layer = F.layer + 0.1
			src.plane = F.plane
			F.vis_contents += src
		else if (istype(src.attached, /turf))
			var/turf/F = src.attached
			src.layer = F.layer + 0.1
			src.plane = F.plane
			F.vis_contents += src
		light_c.update(1)

	proc/remove_from_attached()
		if (!src.attached)
			return
		if (istype(src.attached, /atom/movable))
			var/atom/movable/F = src.attached
			F.vis_contents -= src
		else if (istype(src.attached, /turf))
			var/turf/F = src.attached
			F.vis_contents -= src

		src.set_loc(src.attached.loc)
		src.layer = initial(src.layer)
		src.plane = initial(src.plane)
		src.pixel_x = initial(src.pixel_x)
		src.pixel_y = initial(src.pixel_y)
		src.attached = null
		light_c.update(0)

	green
		col_r = 0.0
		col_g = 0.9
		col_b = 0.1
	white
		col_r = 0.9
		col_g = 0.9
		col_b = 0.9
	yellow
		col_r = 0.9
		col_g = 0.8
		col_b = 0.1
	blue
		col_r = 0.1
		col_g = 0.1
		col_b = 0.9
	purple
		col_r = 0.6
		col_g = 0.1
		col_b = 0.9
	pink
		col_r = 0.9
		col_g = 0.5
		col_b = 0.9
	cyan
		col_r = 0.1
		col_g = 0.9
		col_b = 0.9
	oranange
		col_r = 0.9
		col_g = 0.6
		col_b = 0.1
	red
		col_r = 0.9
		col_g = 0.1
		col_b = 0.0

// Contraband stickers etc

/obj/item/sticker/contraband
	name = "localized contraband modification sticker"
	var/contraband_value = 0

	attack_self(mob/user)
		. = ..()
		var/new_value = text2num(tgui_input_text(user, "Choose a contraband value to apply:", "Contraband Value", src.contraband_value))
		if(!isnull(new_value))
			src.contraband_value = clamp(new_value, 0, 10)

	get_desc()
		. = ..()
		. += "<br>It's currently set to [contraband_value ? "apply a contraband value of [contraband_value] to" : "remove the contraband value from"] the attached item."

	stick_to(atom/A)
		. = ..()
		APPLY_ATOM_PROPERTY(A, PROP_ITEM_CONTRABAND_OVERRIDE, src, contraband_value)

	disposing()
		REMOVE_ATOM_PROPERTY(src.attached, PROP_ITEM_CONTRABAND_OVERRIDE, src)
		..()

	fall_off()
		REMOVE_ATOM_PROPERTY(src.attached, PROP_ITEM_CONTRABAND_OVERRIDE, src)
		. = ..()
