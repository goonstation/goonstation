// i'm the trash code
// i eat garbage

/obj/monkeyplant
	name = "monkeyplant"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "monkeyplant"
	desc = "Jane Goodall is crying."
	density = 1

	attackby(obj/item/W, mob/user)
		user.lastattacked = src
		src.visible_message("<B>[src]</B> screams!",1)
		if (narrator_mode)
			playsound(src, 'sound/vox/scream.ogg', 10, 1, -1, channel=VOLUME_CHANNEL_EMOTE)
		else
			playsound(src, 'sound/voice/screams/monkey_scream.ogg', 10, 1, -1, channel=VOLUME_CHANNEL_EMOTE)
		..()
		return

//derelict AI//

/obj/item/aiboss_tape
	name = "data tape"
	desc = "A bulky and very archaic tape of data. Seriously, how old is this?"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "satanai_tape"
	var/tape_no = 0
	w_class = W_CLASS_NORMAL
	force = 3

/obj/item/aiboss_tape/first
	tape_no = 2

/obj/item/aiboss_tape/void
	icon_state = "satanai_voidtape"
	tape_no = 1

// hi aph, this is cirr, i hope you don't mind too strongly if i hijack your spooky tape ai machine
/obj/item/aiboss_tape/martian
	icon_state = "satanai_martiantape"
	desc = "A bulky and very archaic tape of data. It's also covered in unpleasant purple goop. Yeuch."
	tape_no = 4 // i believe you already have plans for 3

/obj/item/aiboss_tape/singed_jape // [sic]
	icon_state = "singed_tape"
	desc = "A bulky and very archaic tape of data. It looks pretty singed, and the label's almost completely burnt off."
	tape_no = 420

/obj/machinery/derelict_aiboss/tower
	name = "databank"
	desc = ""
	icon = 'icons/effects/96x96.dmi'
	icon_state = "oldai_mem-0"
	anchored = 1
	density = 1
	layer = EFFECTS_LAYER_UNDER_1
	pixel_x = -32
	pixel_y = -32 // TO DO: Make these link to the AI and accept tapes
	var/loaded = 0
	var/obj/machinery/derelict_aiboss/ai/ai
	var/obj/item/aiboss_tape/tape

	New()
		..()
		SPAWN(0)
			for(var/obj/machinery/derelict_aiboss/ai/A in get_area(src))
				src.ai = A
				break
			if(!ai) qdel(src)

	attack_hand(mob/user)
		if(!ai) return
		if(!ai.on) return
		if(!ai.ready_for_tapes) return
		if(src.loaded)
			src.visible_message("[user] ejects the tape from the databank.",1)
			playsound(src, 'sound/machines/driveclick.ogg', 80,1)
			tape.set_loc(user.loc)
			tape.layer = 3
			icon_state = "oldai_mem-0"
			ai.tapes_loaded--
			src.loaded = 0

	attackby(obj/item/W, mob/living/user)
		if(!ai) return
		if (istype(W, /obj/item/aiboss_tape/))
			if(src.loaded)
				boutput(user, "<span class='alert'>There's already a tape inside!</span>")
				return

			if(!ai.on)
				src.visible_message("[user] prods the databank's tape slot with [W]. Nothing happens.",1)
				return

			else if(!ai.ready_for_tapes)
				boutput(user, "<span class='alert'>The databank refuses to load the tape!</span>")
				return
			user.u_equip(W)
			W.set_loc(src)
			tape = W
			ai.ready_for_tapes = 0
			src.loaded = 1
			var/tape_no = tape.tape_no
			playsound(src, 'sound/machines/driveclick.ogg', 80,1)
			src.visible_message("The databank begins loading the tape.",1)
			src.icon_state = "oldai_mem-1"
			sleep(1 SECOND)
			src.icon_state = "oldai_mem-2"
			SPAWN(5 SECONDS) src.icon_state = "oldai_mem-1"
			if(ai) ai.load_tape(tape_no)
		else
			src.visible_message("[user] prods the databank's tape slot with [W]. Nothing happens.",1)


// will probably redo the code for this guy at some point, so expect some hacks here and there for now - aph
/obj/machinery/derelict_aiboss/ai
	name = "Bradbury II"
	desc = "Huh? You've never seen this type of computer before. Not even in any history books."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "oldai_01"
	anchored = 1
	density = 1
	layer = EFFECTS_LAYER_UNDER_1
	pixel_x = -32
	pixel_y = -32
	var/datum/light/light
	var/on = 1
	var/ready_for_tapes = 1
	var/teaser_enabled = 0
	var/image/face = null
	var/tapes_loaded = 0
	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.1, 0.5, 0.1)
		light.set_brightness(0.8)

		return

	proc/speak(var/message, var/dectalk = 1) // borrowed from bots .dm because i'm a lazy fuck
		if (!src.on || !message)
			return
		if(dectalk)
			var/list/audio = dectalk("\[_<500,1>\][message]")
			for (var/mob/O in hearers(src, null))
				if (!O.client)
					continue
				ehjax.send(O.client, "browseroutput", list("dectalk" = audio["audio"]))
		src.audible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"")
		return

	attackby(obj/item/W, mob/living/user)
		if(istype(W,/obj/item/paper/brad_punchcard))

			if(src.teaser_enabled) return

			if((src.ready_for_tapes) && (src.on))
				src.teaser_enabled = 1
				src.visible_message("[user] loads the punchcard into Bradbury II.",1)
				qdel(W)
				src.do_teaser()
		else

			src.visible_message("[user] prods Bradbury II with [W]. Nothing happens.",1)
		return

	hear_talk(var/mob/living/carbon/speaker, messages, real_name, lang_id)
		if (!src.on)
			return

		if(prob(5))
			speak(messages[1], 0) // spooky!!!
			playsound(src, 'sound/machines/modem.ogg', 80,1)
		return

	power_change()
		if(powered(EQUIP) && !on)
			status &= ~NOPOWER
			src.turn_on()
		if(!powered(EQUIP) && on)
			status |= NOPOWER
			src.turn_off()
		return

	process()
		if(on)
			if (status & NOPOWER)
				src.turn_off()
				return
			src.use_power(333) //HOLY SHIT IT'S EVIL!!!!!!
		return

	proc/do_teaser()
		src.ready_for_tapes = 0
		// for(var/mob/O in hearers(src, null))
		// 	O << csound('sound/misc/satanellite_failedboot.ogg')
		playsound(src, 'sound/misc/satanellite_failedboot.ogg', 80,1)
		src.change_face("blink")
		sleep(2 SECONDS)
		src.change_face("static")
		sleep(0.8 SECONDS)
		src.change_face("face_fade04")
		sleep(1 SECOND)
		src.change_face("face_fade03")
		sleep(1 SECOND)
		src.change_face("face_fade02")
		sleep(1 SECOND)
		speak("BRADBURY II IS NOW ONLINE.", 0)
		src.change_face("face_fade01")
		sleep(1 SECOND)
		src.change_face("face_talking")
		sleep(3.5 SECONDS)
		speak("THE TIME IS 01/01/1971.", 0)
		sleep(7.5 SECONDS)
		src.change_face("static")
		elecflash(src,power=6)
		for(var/obj/machinery/light/L in get_area(src))
			L.on = 1
			L.broken()
		sleep(0.1 SECONDS)
		src.change_face("face_terror")
		sleep(0.3 SECONDS)
		src.change_face("face_fade01")
		sleep(0.8 SECONDS)
		src.change_face("face_neutral")
		sleep(0.2 SECONDS)
		src.change_face("face_fade03")
		sleep(1 SECOND)
		src.change_face("static")
		sleep(1 SECOND)
		speak("DANGER", 0)
		sleep(2.5 SECONDS)
		speak("Dddddddahhhngggggerrrrrrrrrrrrrrr.rrr.......", 0)
		src.change_face("dot")
		sleep(2.5 SECONDS)
		src.ready_for_tapes = 1
		src.teaser_enabled = 0

	proc/turn_on()
		src.on = 1
		playsound(src.loc, 'sound/machines/computerboot_pc.ogg', 80, 1)
		src.change_face("blink")
		light.enable()
		sleep(5 SECONDS)
		if(!on) return
		if(src.teaser_enabled == 1)
			do_teaser()
		else
			src.change_face("static")
			// for(var/mob/O in hearers(src, null))
			// 	O << csound('sound/misc/satanellite_bootsignal.ogg')
			playsound(src, 'sound/misc/satanellite_bootsignal.ogg', 80,1)
			sleep(17 SECONDS)
			if(!on) return
			src.ready_for_tapes = 1
			src.change_face("dot")
		return

	proc/turn_off()
		src.on = 0
		src.ready_for_tapes = 0
		src.overlays = null
		light.disable()
		return

	proc/change_face(state)
		src.overlays = null
		var/image/sheen = image('icons/effects/96x96.dmi', "oldai_light")
		sheen.plane = PLANE_ABOVE_LIGHTING
		sheen.layer = 100
		if(findtext(state,"face_"))
			var/image/face_over = image('icons/effects/96x96.dmi', "oldai-faceoverlay")
			face_over.plane = PLANE_ABOVE_LIGHTING
			src.overlays += face_over

		src.face = image('icons/effects/96x96.dmi', "oldai-[state]")
		src.face.plane = PLANE_SELFILLUM
		src.overlays += face
		src.overlays += sheen

		return

	proc/load_tape(tapeno)
		src.ready_for_tapes = 0
		if(!on) return
		playsound(src, 'sound/machines/modem.ogg', 80,1)
		sleep(7 SECONDS)
		switch(tapeno)
			if(1)
				src.change_face("static")
				// for(var/mob/O in hearers(src, null))
				// 	O << csound('sound/misc/satanellite_signal01.ogg')
				playsound(src, 'sound/misc/satanellite_signal01.ogg', 80,1)
				sleep(69 SECONDS)
			if(2)
				src.change_face("static")
				// for(var/mob/O in hearers(src, null))
				// 	O << csound('sound/misc/satanellite_signal02.ogg')
				playsound(src, 'sound/misc/satanellite_signal02.ogg', 80,1)
				sleep(69 SECONDS)
			if(4)
				src.change_face("static")
				// for(var/mob/O in hearers(src, null))
				// 	O << csound('sound/misc/satanellite_signal04.ogg')
				playsound(src, 'sound/misc/satanellite_signal04.ogg', 80,1)
				sleep(69 SECONDS)
			if(420)
				src.change_face("static")
				// for(var/mob/O in hearers(src, null))
				// 	O << csound('sound/misc/satanellite_signal420.ogg')
				playsound(src, 'sound/misc/satanellite_signal420.ogg', 80,1)
				sleep(69 SECONDS)
		tapes_loaded++
		src.change_face("dot")
		src.ready_for_tapes = 1

/obj/item/paper/brad_punchcard
	name = "old computer punchcard"
	desc = "A very antiquated method of storing data."
	info = "A quick glance reveals to you that this card is clearly meant for a machine to read.<br>'Kingsway Systems 29A' is written on the back."
	icon = 'icons/obj/junk.dmi'
	icon_state = "brad_punchcard"
	item_state = "sheet"

/area/derelict_ai_sat
	name = "Satellite 29A"
	icon_state = "AIt"
	sound_environment = 12

/area/derelict_ai_sat/core
	name = "AI Satellite Core"
	icon_state = "ai_chamber"
	sound_environment = 0

/area/derelict_ai_sat/solar
	name = "Satelllite 29A Solar Array"
	icon_state = "yellow"
	requires_power = 0
	luminosity = 1

/obj/machinery/computer/solar_control/derelict_ai_sat
	id = "derelict_ai_sat"


/obj/item/paper/abandonedai/A
	name = "paper- 'fax #741'"
	info = {"<h3 style="border-bottom: 1px solid black; width: 80%;">Kingsway Systems LTD</h3>
			<tt>
			<br>Hello.
			<br>We have received your order and will be sending out a shuttle containing the supplies that were requested by the R&D team right away.
			<br>We hope that your research is going well. Our moles have reported that our competitor's 'Asimov' line of systems will be announced within a few weeks.
			<br>
			<br>David Holman
			<br>-------------------
			<br><i>13/12/2032</i>
			</tt>"}


/obj/item/paper/abandonedai/B
	name = "paper- 'fax #742'"
	info = {"<h3 style="border-bottom: 1px solid black; width: 80%;">Kingsway Systems LTD</h3>
			<tt>
			<br>Hello.
			<br>Did you receive the supplies? We've yet to have received any confirmation from our shipping company.
			<br>We hope you'll get back to us soon.
			<br>
			<br>David Holman
			<br>-------------------
			<br><i>16/12/2032</i>
			</tt>"}


// Servotron (the spooky mars robots) parts


/obj/item/parts/robot_parts/leg/left/servotron
	name = "servotron left leg"
	desc = "The left leg of a Kingsway Systems SV-4 Servotron."
	icon_state = "l_leg-servo"
	appearanceString = "servo"
	max_health = 40
	robot_movement_modifier = /datum/movement_modifier/robotleg_left

/obj/item/parts/robot_parts/leg/right/servotron
	name = "servotron right leg"
	desc = "The right leg of a Kingsway Systems SV-4 Servotron."
	icon_state = "r_leg-servo"
	appearanceString = "servo"
	max_health = 40
	robot_movement_modifier = /datum/movement_modifier/robotleg_right


/obj/item/parts/robot_parts/arm/right/servotron
	name = "servotron right arm"
	desc = "The right arm of a Kingsway Systems SV-4 Servotron."
	icon_state = "r_arm-servo"
	appearanceString = "servo"
	max_health = 40
	handlistPart = "armR-light"
	robot_movement_modifier = /datum/movement_modifier/robot_part/head

/obj/item/parts/robot_parts/arm/left/servotron
	name = "servotron left arm"
	desc = "The left arm of a Kingsway Systems SV-4 Servotron."
	icon_state = "l_arm-servo"
	appearanceString = "servo"
	max_health = 40
	handlistPart = "armL-light"
	robot_movement_modifier = /datum/movement_modifier/robot_part/arm_left

/obj/item/parts/robot_parts/head/servotron
	name = "servotron head"
	desc = "The surprisingly spacious head of a Kingsway Systems SV-4 Servotron."
	icon_state = "head-servo"
	appearanceString = "servo"
	max_health = 87
	robot_movement_modifier = /datum/movement_modifier/robot_part/arm_right

/obj/item/parts/robot_parts/chest/servotron
	name = "servotron chest"
	desc = "The chest component of a Kingsway Systems SV-4 Servotron."
	icon_state = "chest-servo"
	appearanceString = "servo"
	max_health = 125







