//Contains:
//-Status display
//-AI status display

// // Status display
// // (formerly Countdown timer display)

// // Use to show shuttle ETA/ETD times
// // Alert status
// // And arbitrary messages set by comms computer

#define MAX_LEN 5
/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = 1
	density = 0
	mats = 14
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/glow_in_dark_screen = TRUE
	var/image/screen_image

	var/mode = 1	// 0 = Blank
					// 1 = Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Supply shuttle timer  -- NO LONGER SUPPORTED
					// 5 = Research station destruct timer
					// 6 = Mining Ore Score Tracking -- NO LONGER SUPPORTED

	var/picture_state	// icon_state of alert picture
	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2
	var/use_maptext = TRUE

	var/lastdisplayline1 = ""		// the cached last displays
	var/lastdisplayline2 = ""

	var/net_id = null
	var/frequency = FREQ_STATUS_DISPLAY		// radio frequency

	var/display_type = 0		// bitmask of messages types to display: 0=normal  1=supply shuttle  2=reseach stn destruct

	var/repeat_update = FALSE	// true if we are going to update again this ptick

	var/image/crt_image = null

	// new display
	// register for radio system
	New()
		..()
		src.layer -= 0.2
		crt_image = SafeGetOverlayImage("crt", src.icon, "crt")
		crt_image.layer = src.layer + 0.1
		crt_image.plane = PLANE_DEFAULT
		crt_image.appearance_flags = NO_CLIENT_COLOR | RESET_ALPHA | KEEP_APART
		crt_image.alpha = 255
		crt_image.mouse_opacity = 0
		UpdateOverlays(crt_image, "crt")

		src.AddComponent( \
			/datum/component/packet_connected/radio, \
			null, \
			src.frequency, \
			src.net_id, \
			"receive_signal", \
			FALSE, \
			"STATDISPLAY", \
			FALSE \
		)

		if(glow_in_dark_screen)
			src.screen_image = image('icons/obj/status_display.dmi', src.icon_state, -1)
			screen_image.plane = PLANE_LIGHTING
			screen_image.blend_mode = BLEND_ADD
			screen_image.layer = LIGHTING_LAYER_BASE
			screen_image.color = list(0.66,0.66,0.66, 0.66,0.66,0.66, 0.66,0.66,0.66)
			src.UpdateOverlays(screen_image, "screen_image")

		if(!src.net_id)
			src.net_id = generate_net_id(src)

	// timed process
	process()
		if(status & NOPOWER)
			ClearAllOverlays()
			return

		use_power(200)

		update()


	// set what is displayed
	proc/update()

		switch(mode)
			if(0)
				maptext = ""
				ClearAllOverlays()

			if(1)	// shuttle timer
				if(emergency_shuttle.online)
					var/displayloc
					if(emergency_shuttle.location == SHUTTLE_LOC_STATION)
						displayloc = "ETD "
					else
						displayloc = "ETA "

					var/displaytime = get_shuttle_timer()
					if(length(displaytime) > MAX_LEN)
						displaytime = "**~**"

					update_display_lines(displayloc, displaytime)

					if(repeat_update)
						var/delay = src.base_tick_spacing * PROCESSING_TIER_MULTI(src)
						SPAWN(0.5 SECONDS)
							repeat_update = FALSE
							var/iterations = round(delay/5)
							for(var/i in 1 to iterations)
								if(mode != 1 || repeat_update) // kill early if message or mode changed
									break
								update()
								if(i != iterations)
									sleep(0.5 SECONDS) // set to update again in 5 ticks
							repeat_update = TRUE
				else
					set_picture("default")

			if(2)
				var/line1
				var/line2
				var/line_len = use_maptext ? 4 : 5

				if(!index1)
					line1 = message1
				else
					line1 = copytext(message1+message1, index1, index1+line_len)
					if(index1++ > (length(message1)))
						index1 = 1

				if(!index2)
					line2 = message2
				else
					line2 = copytext(message2+message2, index2, index2+line_len)
					if(index2++ > (length(message2)))
						index2 = 1

				// the following allows 2 updates per process, giving faster scrolling
				if((index1 || index2) && repeat_update)	// if either line is scrolling
														// and we haven't forced an update yet
					var/delay = src.base_tick_spacing * PROCESSING_TIER_MULTI(src)
					SPAWN(0.5 SECONDS)
						repeat_update = FALSE
						var/iterations = round(delay/5)
						for(var/i in 1 to iterations)
							if(mode != 2 || repeat_update) // kill early if message or mode changed
								break
							update()
							if(i != iterations)
								sleep(0.5 SECONDS) // set to update again in 5 ticks
						repeat_update = TRUE

				update_display_lines(line1,line2)

		if(glow_in_dark_screen) // should re-add the glow if power is restored
			screen_image.plane = PLANE_LIGHTING
			screen_image.blend_mode = BLEND_ADD
			screen_image.layer = LIGHTING_LAYER_BASE
			screen_image.color = list(0.66,0.66,0.66, 0.66,0.66,0.66, 0.66,0.66,0.66)
			src.UpdateOverlays(screen_image, "screen_image")


	proc/set_message(var/m1, var/m2)
		if(m1)
			index1 = (length(m1) > MAX_LEN)
			message1 = uppertext(m1)
		else
			message1 = ""
			index1 = 0

		if(m2)
			index2 = (length(m2) > MAX_LEN)
			message2 = uppertext(m2)
		else
			message2 = null
			index2 = 0
		repeat_update = TRUE
		desc = "[message1]<br>[message2]" // multiline messages
		lastdisplayline1 = null
		lastdisplayline2 = null

#undef MAX_LEN

	proc/set_maptext(var/line1, var/line2)
		if(!line2)
			src.maptext = {"<span class='vm c' style="font-family: StatusDisp; font-size: 6px;  color: #09f">[line1]</span>"}
		else
			src.maptext = {"<span class='vm c' style="font-family: StatusDisp; font-size: 6px;  color: #09f">[line1]<BR/>[line2]</span>"}

	proc/set_picture(var/state)
		var/image/previous = GetOverlayImage("picture")
		if(previous?.icon_state == state)
			return
		src.maptext = ""
		picture_state = state
		UpdateOverlays(image('icons/obj/status_display.dmi', icon_state=picture_state), "picture")
		UpdateOverlays(null, "overlay_image")
		UpdateOverlays(crt_image, "crt")

	proc/set_picture_overlay(var/state, var/overlay)
		var/image/previous_state = GetOverlayImage("picture")
		var/image/previous_overlay = GetOverlayImage("overlay_image")
		if(previous_state?.icon_state == state && previous_overlay?.icon_state == overlay)
			return
		src.maptext = ""
		picture_state = state+overlay
		UpdateOverlays(image('icons/obj/status_display.dmi', icon_state=state), "picture")
		UpdateOverlays(image('icons/obj/status_display.dmi', icon_state=overlay), "overlay_image")
		UpdateOverlays(crt_image, "crt")

	proc/update_display_lines(var/line1, var/line2, var/image/override = null)
		if(line1 == lastdisplayline1 && line2 == lastdisplayline2)
			return			// no change, no need to update

		lastdisplayline1 = line1
		lastdisplayline2 = line2

		set_maptext(line1, line2)

		if(GetOverlayImage("picture") || GetOverlayImage("overlay_image") || !GetOverlayImage("crt"))
			UpdateOverlays(null, "picture")
			UpdateOverlays(null, "overlay_image")
			UpdateOverlays(crt_image, "crt")

	// return shuttle timer as text
	proc/get_shuttle_timer()
		var/timeleft = emergency_shuttle.timeleft()
		if(timeleft)
			return "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
			// note ~ translates into a smaller :
		return ""

	receive_signal(datum/signal/signal)
		if (!signal || (!signal.data["address_tag"] && !signal.data["address_1"]))
			return

		if (signal.data["address_tag"] != "STATDISPLAY" && signal.data["address_1"] != src.net_id)
			return

		switch(signal.data["command"])
			if("blank")
				mode = 0

			if("shuttle")
				mode = 1
				repeat_update = TRUE

			if("message")
				mode = 2
				set_message(strip_html(signal.data["msg1"]), strip_html(signal.data["msg2"]))

			if("alert")
				mode = 3
				set_picture(signal.data["picture_state"])

			if("destruct")
				if(display_type & 2)
					mode = 5
					var/timeleft = signal.data["time"]
					if(text2num(timeleft) <= 30)
						set_picture_overlay("destruct_small", "d[timeleft]")
					else
						set_picture("destruct")



/obj/machinery/status_display/supply_shuttle
	name = "status display"


/obj/machinery/status_display/research
	name = "status display"
	display_type = 2

/obj/machinery/status_display/mining
	name = "mining display"
	mode = 6

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "ai_frame"
	name = "\improper AI display"
	anchored = 1
	density = 0
	mats = list("MET-1"=2, "CON-1"=6, "CRY-1"=6)
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL

	machine_registry_idx = MACHINES_STATUSDISPLAYS
	var/is_on = FALSE //Distinct from being powered

	var/image/face_image = null //AI expression, optionally the entire screen for the red & BSOD faces
	var/image/back_image = null //The bit that gets coloured
	var/image/glow_image = null //glowy lines
	var/mob/living/silicon/ai/owner //Let's have AIs play tug-of-war with status screens

	//Variables of our current state, these get checked against variables in the AI to check if anything needs updating
	var/emotion = null //an icon state
	var/message = null //displays on examine
	var/face_color = null

	var/datum/light/screen_glow

	New()
		..()
		face_image = image('icons/obj/status_display.dmi', icon_state = "", layer = FLOAT_LAYER)
		glow_image = image('icons/obj/status_display.dmi', icon_state = "ai_glow", layer = FLOAT_LAYER - 1)
		back_image = image('icons/obj/status_display.dmi', icon_state = "ai_white", layer = FLOAT_LAYER - 2)


		if(pixel_y == 0 && pixel_x == 0)
			if (map_settings.walls ==/turf/simulated/wall/auto/jen)
				pixel_y = 32
			else
				pixel_y = 29

		screen_glow = new /datum/light/point
		screen_glow.set_brightness(0.45)
		screen_glow.set_height(0.75)
		screen_glow.attach(src)

	disposing()
		if (screen_glow)
			screen_glow.dispose()
		..()

	process()
		if (status & NOPOWER || !is_on || !owner)
			UpdateOverlays(null, "emotion_img")
			UpdateOverlays(null, "back_img")
			UpdateOverlays(null, "glow_img")
			screen_glow.disable()
			return
		update()
		use_power(200)

	proc/update()
		//Update backing colour
		if (face_color != owner.faceColor)
			face_color = owner.faceColor
			back_image.color = face_color
			UpdateOverlays(back_image, "back_img")
			//display light
			var/colors = GetColors(face_color)
			screen_glow.set_color(colors[1] / 255, colors[2] / 255, colors[3] / 255)

		//Update expression
		if (src.emotion != owner.faceEmotion)
			UpdateOverlays(owner.faceEmotion != "ai-tetris" ? glow_image : null, "glow_img")
			face_image.icon_state = owner.faceEmotion
			UpdateOverlays(face_image, "emotion_img")
			emotion = owner.faceEmotion

		//Re-enable all the stuff if we are powering on again
		if (!screen_glow.enabled)
			screen_glow.enable()
			UpdateOverlays(face_image, "emotion_img")
			UpdateOverlays(back_image, "back_img")
			UpdateOverlays(owner.faceEmotion != "ai-tetris" ? glow_image : null, "glow_img")

		message = owner.status_message
		name = initial(name) + " ([owner.name])"


	get_desc()
		..()
		if (status & NOPOWER)
			return
		if (src.message)
			. += "<br>[owner.name] says: \"[src.message]\""

	attack_ai(mob/user as mob) //Captain said it's my turn on the status display
		if (!isAI(user))
			boutput(user, "<span class='alert'>Only an AI can claim this.</span>")
			return
		var/mob/living/silicon/ai/A = user
		if (isAIeye(user))
			var/mob/living/intangible/aieye/AE = user
			A = AE.mainframe
		if (owner == A) //no free updates for you
			return
		boutput(user, "<span class='notice'>You tune the display to your core.</span>")
		owner = A
		is_on = TRUE
		if (!(status & NOPOWER))
			update()
