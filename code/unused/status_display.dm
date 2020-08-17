// // Status display
// // (formerly Countdown timer display)

// // Use to show shuttle ETA/ETD times
// // Alert status
// // And arbitrary messages set by comms computer

// var/list/status_display_text_images = list()

// /obj/machinery/status_display
// 	icon = 'icons/obj/status_display.dmi'
// 	icon_state = "frame"
// 	name = "status display"
// 	anchored = 1
// 	density = 0
// 	mats = 14
// 	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
// //
// 	var/mode = 1	// 0 = Blank
// 					// 1 = Shuttle timer
// 					// 2 = Arbitrary message(s)
// 					// 3 = alert picture
// 					// 4 = Supply shuttle timer
// 					// 5 = Research station destruct timer
// 					// 6 = Mining Ore Score Tracking

// 	var/picture_state	// icon_state of alert picture
// 	var/message1 = ""	// message line 1
// 	var/message2 = ""	// message line 2
// 	var/index1			// display index for scrolling messages or 0 if non-scrolling
// 	var/index2

// 	var/lastdisplayline1 = ""		// the cached last displays
// 	var/lastdisplayline2 = ""

// 	var/frequency = 1435		// radio frequency

// 	var/display_type = 0		// bitmask of messages types to display: 0=normal  1=supply shuttle  2=reseach stn destruct

// 	var/repeat_update = 0		// true if we are going to update again this ptick

// 	var/image/text_image = null
// 	var/image/temp_image = null

// 	var/list/image/text_ticker = list()
// 	var/ticker_index = 1

// 	// new display
// 	// register for radio system
// 	New()
// 		..()
// 		SPAWN_DBG(0.5 SECONDS)	// must wait for map loading to finish
// 			//if(radio_controller)
// 			//	radio_controller.add_object(src, "[frequency]")
// 			del(src) //lol

// 	// timed process

// 	process()
// 		//Wire: Breaking status displays intentionally because holy fuck do they cause a lot of lag.
// 		//qdel(src)
// 		//return

// 		if(status & NOPOWER)
// 			ClearAllOverlays()
// 			return

// 		use_power(200)

// 		update()


// 	// set what is displayed

// 	proc/update()

// 		switch(mode)
// 			if(0)
// 				ClearAllOverlays()
// 				return

// 			// drsingh commented these for now because they lag
// 			if(1)	// shuttle timer
// 				if(emergency_shuttle.online)
// 					var/displayloc
// 					if(emergency_shuttle.location == SHUTTLE_LOC_STATION)
// 						displayloc = "ETD "
// 					else
// 						displayloc = "ETA "

// 					var/displaytime = get_shuttle_timer()
// 					if(length(displaytime) > 5)
// 						displaytime = "**~**"

// 					update_display_lines(displayloc, displaytime)
// 					return
// 				else
// 					ClearAllOverlays()
// 					return
// 			/*
// 			if(mode==4)		// supply shuttle timer
// 				var/disp1
// 				var/disp2
// 				if(supply_shuttle_moving)
// 					disp1 = get_supply_shuttle_timer()
// 					if(length(disp1) > 5)
// 						disp1 = "**~**"
// 					disp2 = null

// 				else
// 					if(supply_shuttle_at_station)
// 						disp1 = "SPPLY"
// 						disp2 = "STATN"
// 					else
// 						disp1 = "SPPLY"
// 						disp2 = "DOCK"

// 				update_display(disp1, disp2)
// 			*/
// 			if(2)
// 				/*
// 				var/line1
// 				var/line2

// 				if(!index1)
// 					line1 = message1
// 				else
// 					line1 = copytext(message1+message1, index1, index1+5)
// 					if(index1++ > (length(message1)))
// 						index1 = 1

// 				if(!index2)
// 					line2 = message2
// 				else
// 					line2 = copytext(message2+message2, index2, index2+5)
// 					if(index2++ > (length(message2)))
// 						index2 = 1

// 				update_display(line1, line2)

// 				// the following allows 2 updates per process, giving faster scrolling
// 				if((index1 || index2) && repeat_update)	// if either line is scrolling
// 														// and we haven't forced an update yet

// 					SPAWN_DBG(0.5 SECONDS)
// 						repeat_update = 0
// 						update()		// set to update again in 5 ticks
// 						repeat_update = 1
// 				*/
// 				if(text_ticker.len)
// 					DEBUG_MESSAGE("Updating text display index: [ticker_index], len: [text_ticker.len]")
// 					update_display_lines(,,text_ticker[ticker_index])
// 					ticker_index = ((ticker_index + 1) % text_ticker.len)
// 			else
// 				return

// 	proc/set_message(var/m1, var/m2)
// 		if(m1)
// 			index1 = (length(m1) > 5)
// 			message1 = uppertext(m1)
// 		else
// 			message1 = ""
// 			index1 = 0

// 		if(m2)
// 			index2 = (length(m2) > 5)
// 			message2 = uppertext(m2)
// 		else
// 			message2 = null
// 			index2 = 0
// 		repeat_update = 1
// 		desc = "[message1] [message2]"

// 		calculate_message_images()


// #define MAX_LEN 5

// 	proc/calculate_message_images()
// 		text_ticker.len = 0

// 		var/target = max(length(message1), length(message2))

// 		//No sense repeatedly concatenating the message
// 		var/dmessage1 = ""
// 		if(length(message1)>MAX_LEN)
// 			dmessage1 = message1+message1

// 		var/dmessage2 = ""
// 		if(length(message2)>MAX_LEN)
// 			dmessage2 = message2+message2

// 		for(var/I = 1; I <= target; I++)
// 			var/line1
// 			var/line2
// 			var/image/temp = image('icons/obj/status_display.dmi')
// 			if(dmessage1)	//If there is a double message then line1 > MAX_LEN
// 				var/len = length(message1)
// 				line1 = copytext(dmessage1, (I % len)+1 , ((I % len) + MAX_LEN ) + 1)
// 			else
// 				line1 = message1

// 			if(dmessage2) //If there is a double message then line1 > MAX_LEN
// 				var/len = length(message2)
// 				line2 = copytext(dmessage2, (I % len)+1 , ((I + MAX_LEN) % len) + 1)
// 			else //Otherwise show entire message
// 				line2 = message2

// 			if(!line2)		// single line display
// 				temp.overlays += texticon(line1, 23, -13)
// 			else					// dual line display
// 				temp.overlays += texticon(line1, 23, -9)
// 				temp.overlays += texticon(line2, 23, -17)

// 			DEBUG_MESSAGE("Line 1: [line1], Line 2: [line2]")

// 			text_ticker += temp

// 			if(!dmessage1 && !dmessage2) //Both lines are static, do not calculate scroll
// 				return

// 		/*
// 		if(!index1)
// 			line1 = message1
// 		else
// 			line1 = copytext(message1+message1, index1, index1+5)
// 			if(index1++ > (length(message1)))
// 				index1 = 1

// 		if(!index2)
// 			line2 = message2
// 		else
// 			line2 = copytext(message2+message2, index2, index2+5)
// 			if(index2++ > (length(message2)))
// 				index2 = 1
// 		*/

// #undef MAX_LEN

// 	proc/set_picture(var/state)
// 		picture_state = state
// 		UpdateOverlays(image('icons/obj/status_display.dmi', icon_state=picture_state), "picture")

// 	proc/set_picture_overlay(var/state, var/overlay)
// 		picture_state = state+overlay
// 		UpdateOverlays(image('icons/obj/status_display.dmi', icon_state=state), "state_image")
// 		UpdateOverlays(image('icons/obj/status_display.dmi', icon_state=overlay), "overlay_image")


// 	proc/update_display_lines(var/line1, var/line2, var/image/override = null)

// 		if(override) //Ok, we're gonna use our own image entirely, sidestepping the image building process
// 			DEBUG_MESSAGE("[UpdateOverlays(override, "text") ? "Success" : "Failure"]")
// 			return

// 		if(line1 == lastdisplayline1 && line2 == lastdisplayline2)
// 			return			// no change, no need to update

// 		lastdisplayline1 = line1
// 		lastdisplayline2 = line2
// 		if(!text_image)
// 			text_image = image('icons/obj/status_display.dmi')

// 		text_image.overlays.Cut()

// 		if(line2 == null)		// single line display
// 			text_image.overlays += texticon(line1, 23, -13)
// 		else					// dual line display
// 			text_image.overlays += texticon(line1, 23, -9)
// 			text_image.overlays += texticon(line2, 23, -17)

// 		UpdateOverlays(text_image, "text", 1) //Force this update

// 	// return shuttle timer as text

// 	proc/get_shuttle_timer()
// 		var/timeleft = emergency_shuttle.timeleft()
// 		if(timeleft)
// 			return "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
// 			// note ~ translates into a blinking :
// 		return ""

// 	proc/get_supply_shuttle_timer()
// 		if(supply_shuttle_moving)
// 			var/timeleft = round((supply_shuttle_time - world.timeofday) / 10,1)
// 			return "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
// 			// note ~ translates into a blinking :
// 		return ""




// 	// applies overlay images to form a time text string (tn)
// 	// valid characters are 0-9 and :
// 	// px, py are pixel offsets
// 	proc/texticon(var/tn, var/px = 0, var/py = 0)
// 		if(!temp_image) temp_image = image('icons/obj/status_display.dmi', "blank")

// 		var/len = length(tn)

// 		temp_image.overlays.Cut()
// 		for(var/d = 1 to len)


// 			var/char = copytext(tn, len-d+1, len-d+2)

// 			if(char == " ")
// 				continue

// 			var/image/ID = status_display_text_images[char]
// 			if (!ID)
// 				status_display_text_images[char] = image('icons/obj/status_display.dmi', icon_state=char)
// 				ID = status_display_text_images[char]

// 			ID.pixel_x = -(d-1)*5 + px
// 			ID.pixel_y = py

// 			temp_image.overlays += ID

// 		return temp_image






// 	receive_signal(datum/signal/signal)

// 		switch(signal.data["command"])
// 			if("blank")
// 				mode = 0

// 			if("shuttle")
// 				mode = 1

// 			if("message")
// 				mode = 2
// 				set_message(signal.data["msg1"], signal.data["msg2"])

// 			if("alert")
// 				mode = 3
// 				set_picture(signal.data["picture_state"])

// 			if("supply")
// 				if(display_type & 1)
// 					mode = 4

// 			if("destruct")
// 				if(display_type & 2)
// 					mode = 5
// 					var/timeleft = signal.data["time"]
// 					if(text2num(timeleft) <= 30)
// 						set_picture_overlay("destruct_small", "d[timeleft]")
// 					else
// 						set_picture("destruct")



// /obj/machinery/status_display/supply_shuttle
// 	name = "status display"
// 	display_type = 1

// /obj/machinery/status_display/research
// 	name = "status display"
// 	display_type = 2

// /obj/machinery/status_display/mining
// 	name = "mining display"
// 	mode = 6

// /obj/machinery/ai_status_display
// 	icon = 'icons/obj/status_display.dmi'
// 	icon_state = "ai_frame"
// 	name = "\improper AI display"
// 	anchored = 1
// 	density = 0
// 	mats = 14
// 	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL

// 	machine_registry_idx = MACHINES_STATUSDISPLAYS
// 	var/mode = 0	// 0 = Blank
// 					// 1 = AI emoticon
// 					// 2 = Blue screen of death

// 	var/picture_state	// icon_state of ai picture
// 	var/image/pic_image = null

// 	var/emotion = "ai_happy"
// 	var/message = null

// 	New()
// 		..()
// 		pic_image = image('icons/obj/status_display.dmi', icon_state = picture_state)

// 	process()
// 		if (status & NOPOWER)
// 			UpdateOverlays(null, "emotion_img")
// 			picture_state = null
// 			return

// 		use_power(200)

// 		update()

// 	proc/update()
// 		if (mode == 0) //Blank
// 			UpdateOverlays(null, "emotion_img")
// 			picture_state = null
// 			return

// 		if (mode == 1)	// AI emoticon
// 			if (src.emotion)
// 				src.set_picture(src.emotion)
// 			return

// 		if (mode == 2)	// BSOD
// 			set_picture("ai_bsod")
// 			return

// 	proc/set_picture(var/state)
// 		if (!state || state == picture_state)
// 			return //Hoooly balls why was this not here before argh
// 		picture_state = state
// 		pic_image.icon_state = picture_state
// 		UpdateOverlays(pic_image, "emotion_img")

// 	get_desc()
// 		..()
// 		if (status & NOPOWER)
// 			return
// 		if (src.message)
// 			. += "<br>It says: \"[src.message]\""

// I blame Flourish
/obj/machinery/ai_status_display
	New()
		qdel(src)
