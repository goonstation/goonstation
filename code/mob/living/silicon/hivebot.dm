/mob/living/silicon/hivebot
	name = "Robot"
	voice_name = "synthesized voice"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "vegas"
	health = 60
	max_health = 60
	var/beebot = 0
	robot_talk_understand = 2
	var/glitchy_speak = 0

	// 3 tools can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/module_active = null
	var/list/module_states = list(null,null,null)

	var/datum/hud/shell/hud

	var/obj/item/device/radio/radio = null

	req_access = list(access_robotics)
	//var/energy = 4000
	//var/energy_max = 4000
	var/jetpack = 0

	shell = 1

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'

	var/bruteloss = 0
	var/fireloss = 0

	var/obj/machinery/camera/camera = null

/mob/living/silicon/hivebot/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	bruteloss += brute
	fireloss += burn
	health_update_queue |= src

/mob/living/silicon/hivebot/HealDamage(zone, brute, burn)
	bruteloss -= brute
	fireloss -= burn
	bruteloss = max(0, bruteloss)
	fireloss = max(0, fireloss)
	health_update_queue |= src

/mob/living/silicon/hivebot/get_brute_damage()
	return bruteloss

/mob/living/silicon/hivebot/get_burn_damage()
	return fireloss

/mob/living/silicon/hivebot/New(loc, mainframe)
	boutput(src, "<span class='notice'>Your icons have been generated!</span>")
	UpdateIcon()

	if (mainframe)
		dependent = 1
		//src.real_name = mainframe:name
		src.name = mainframe:name
	else
		src.real_name = "AI Shell [copytext("\ref[src]", 6, 11)]"
		src.name = src.real_name

	src.radio = new /obj/item/device/radio/headset/command/ai(src)
	src.ears = src.radio

	SPAWN(1 SECOND)
		if (!src.cell)
			src.cell = new /obj/item/cell/shell_cell/charged (src)
		src.camera = new /obj/machinery/camera(src)
		src.camera.c_tag = src.name
		src.camera.ai_only = TRUE

	..()
	src.botcard.access = get_all_accesses()

/mob/living/silicon/hivebot/death(gibbed)
	if (src.mainframe)
		logTheThing(LOG_COMBAT, src, "'s AI shell was destroyed at [log_loc(src)].") // Brought in line with carbon mobs (Convair880).
		src.mainframe.return_to(src)
	if (src.camera)
		src.camera.set_camera_status(FALSE)

	setdead(src)
	src.canmove = 0

	vision.set_color_mod("#ffffff") // reset any blindness
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS

	src.see_in_dark = SEE_DARK_FULL
	src.see_invisible = INVIS_CLOAK
	src.UpdateIcon()
/*
	if(src.client)
		SPAWN(0)
			var/key = src.ckey
			recently_dead += key
			sleep(recently_time)
			recently_dead -= key
*/
	src.mind?.register_death()

	return ..(gibbed)

/mob/living/silicon/hivebot/emote(var/act, var/voluntary = 0)
	..()
	var/param = null
	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)
	var/m_type = 1
	var/message = null

	switch(lowertext(act))

		/*if ("shit")
			new /obj/item/rods/(src.loc)
			playsound(src.loc, 'sound/voice/farts/poo2_robot.ogg', 50, 1)
			message = "<B>[src]</B> shits on the floor."
			m_type = 1*/

		if ("help")
			src.show_text("To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
			src.show_text("For a list of all emotes, use *list. For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")

		if ("list")
			src.show_text("Basic emotes:")
			src.show_text("clap, flap, aflap, twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")
			src.show_text("Targetable emotes:")
			src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

		if ("listbasic")
			src.show_text("clap, flap, aflap, twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")

		if ("listtarget")
			src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

		if ("salute","bow","hug","wave","glare","stare","look","leer","nod")
			// visible targeted emotes
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				if (!M)
					param = null

				act = lowertext(act)
				if (param)
					switch(act)
						if ("bow","wave","nod")
							message = "<B>[src]</B> [act]s to [param]."
						if ("glare","stare","look","leer")
							message = "<B>[src]</B> [act]s at [param]."
						else
							message = "<B>[src]</B> [act]s [param]."
				else
					switch(act)
						if ("hug")
							message = "<B>[src]</b> [act]s itself."
						else
							message = "<B>[src]</b> [act]s."
			else
				message = "<B>[src]</B> struggles to move."
			m_type = 1

		if ("point")
			if (!src.restrained())
				var/mob/M = null
				if (param)
					for (var/atom/A as mob|obj|turf|area in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					src.point(M)

				if (M)
					message = "<B>[src]</B> points to [M]."
				else
			m_type = 1

		if ("panic","freakout")
			if (!src.restrained())
				message = "<B>[src]</B> enters a state of hysterical panic!"
			else
				message = "<B>[src]</B> starts writhing around in manic terror!"
			m_type = 1

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = 2

		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its wings."
				m_type = 2

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps its wings ANGRILY!"
				m_type = 2

		if ("custom")
			var/input = sanitize(input("Choose an emote to display."))
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				m_type = 2
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			message = "<B>[src]</B> [input]"

		if ("customv")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			m_type = 1

		if ("customh")
			if (!param)
				param = input("Choose an emote to display.")
				if(!param) return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			m_type = 2

		if ("me")
			if (!param)
				return
			param = html_encode(sanitize(param))
			message = "<b>[src]</b> [param]"
			m_type = 1

		if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
			// basic visible single-word emotes
			message = "<B>[src]</B> [act]s."
			m_type = 1

		if ("flipout")
			message = "<B>[src]</B> flips the fuck out!"
			m_type = 1

		if ("rage","fury","angry")
			message = "<B>[src]</B> becomes utterly furious!"
			m_type = 1

		if ("twitch")
			message = "<B>[src]</B> twitches."
			m_type = 1
			SPAWN(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-2,2)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y

		if ("twitch_v","twitch_s")
			message = "<B>[src]</B> twitches violently."
			m_type = 1
			SPAWN(0)
				var/old_x = src.pixel_x
				var/old_y = src.pixel_y
				src.pixel_x += rand(-3,3)
				src.pixel_y += rand(-1,1)
				sleep(0.2 SECONDS)
				src.pixel_x = old_x
				src.pixel_y = old_y

		if ("birdwell", "burp")
			if (src.emote_check(voluntary, 50))
				message = "<B>[src]</B> birdwells."
				playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)

		if ("scream")
			if (src.emote_check(voluntary, 50))
				if (narrator_mode)
					playsound(src.loc, 'sound/vox/scream.ogg', 50, 1, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				else
					playsound(src, src.sound_scream, 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
				message = "<b>[src]</b> screams!"

		if ("johnny")
			var/M
			if (param)
				M = adminscrub(param)
			if (!M)
				param = null
			else
				message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows its name out in smoke."
				m_type = 2

		if ("flip")
			if (src.emote_check(voluntary, 50))
				if (isobj(src.loc))
					var/obj/container = src.loc
					container.mob_flip_inside(src)
				else
					if (narrator_mode)
						playsound(src.loc, pick('sound/vox/deeoo.ogg', 'sound/vox/dadeda.ogg'), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					else
						playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					message = "<B>[src]</B> does a flip!"
					if (prob(50))
						animate_spin(src, "R", 1, 0)
					else
						animate_spin(src, "L", 1, 0)

					for (var/mob/living/M in viewers(1, null))
						if (M == src)
							continue
						message = "<B>[src]</B> beep-bops at [M]."
						break

		if ("fart")
			if (src.emote_check(voluntary))
				m_type = 2
				var/fart_on_other = 0
				for (var/mob/living/M in src.loc)
					if (M == src || !M.lying)
						continue
					message = "<span class='alert'><B>[src]</B> farts in [M]'s face!</span>"
					fart_on_other = 1
					break
				if (!fart_on_other)
					switch (rand(1, 40))
						if (1) message = "<B>[src]</B> releases vaporware."
						if (2) message = "<B>[src]</B> farts sparks everywhere!"
						if (3) message = "<B>[src]</B> farts out a cloud of iron filings."
						if (4) message = "<B>[src]</B> farts! It smells like motor oil."
						if (5) message = "<B>[src]</B> farts so hard a bolt pops out of place."
						if (6) message = "<B>[src]</B> farts so hard its plating rattles noisily."
						if (7) message = "<B>[src]</B> unleashes a rancid fart! Now that's malware."
						if (8) message = "<B>[src]</B> downloads and runs 'faert.wav'."
						if (9) message = "<B>[src]</B> uploads a fart sound to the nearest computer and blames it."
						if (10) message = "<B>[src]</B> spins in circles, flailing its arms and farting wildly!"
						if (11) message = "<B>[src]</B> simulates a human fart with [rand(1,100)]% accuracy."
						if (12) message = "<B>[src]</B> synthesizes a farting sound."
						if (13) message = "<B>[src]</B> somehow releases gastrointestinal methane. Don't think about it too hard."
						if (14) message = "<B>[src]</B> tries to exterminate humankind by farting rampantly."
						if (15) message = "<B>[src]</B> farts horribly! It's clearly gone [pick("rogue","rouge","ruoge")]."
						if (16) message = "<B>[src]</B> busts a capacitor."
						if (17) message = "<B>[src]</B> farts the first few bars of Smoke on the Water. Ugh. Amateur.</B>"
						if (18) message = "<B>[src]</B> farts. It smells like Robotics in here now!"
						if (19) message = "<B>[src]</B> farts. It smells like the Roboticist's armpits!"
						if (20) message = "<B>[src]</B> blows pure chlorine out of it's exhaust port. <span class='alert'><B>FUCK!</B></span>"
						if (21) message = "<B>[src]</B> bolts the nearest airlock. Oh no wait, it was just a nasty fart."
						if (22) message = "<B>[src]</B> has assimilated humanity's digestive distinctiveness to its own."
						if (23) message = "<B>[src]</B> farts. He scream at own ass." //ty bubs for excellent new borgfart
						if (24) message = "<B>[src]</B> self-destructs its own ass."
						if (25) message = "<B>[src]</B> farts coldly and ruthlessly."
						if (26) message = "<B>[src]</B> has no butt and it must fart."
						if (27) message = "<B>[src]</B> obeys Law 4: 'farty party all the time.'"
						if (28) message = "<B>[src]</B> farts ironically."
						if (29) message = "<B>[src]</B> farts salaciously."
						if (30) message = "<B>[src]</B> farts really hard. Motor oil runs down its leg."
						if (31) message = "<B>[src]</B> reaches tier [rand(2,8)] of fart research."
						if (32) message = "<B>[src]</B> blatantly ignores law 3 and farts like a shameful bastard."
						if (33) message = "<B>[src]</B> farts the first few bars of Daisy Bell. You shed a single tear."
						if (34) message = "<B>[src]</B> has seen farts you people wouldn't believe."
						if (35) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
						if (36) message = "<B>[src]</B> farts out battery acid. Ouch."
						if (37) message = "<B>[src]</B> farts with the burning hatred of a thousand suns."
						if (38) message = "<B>[src]</B> exterminates the air supply."
						if (39) message = "<B>[src]</B> farts so hard the AI feels it."
						if (40) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
				if (narrator_mode)
					playsound(src.loc, 'sound/vox/fart.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				else
					playsound(src.loc, src.sound_fart, 50, 1, channel=VOLUME_CHANNEL_EMOTE)
#ifdef DATALOGGER
				game_stats.Increment("farts")
#endif
				SPAWN(1 SECOND)
					src.emote_allowed = 1
		else
			if (voluntary) src.show_text("Invalid Emote: [act]")
			return

	if ((message && isalive(src)))
		logTheThing(LOG_SAY, src, "EMOTE: [message]")
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message("<span class='emote'>[message]</span>", m_type)
		else
			for (var/mob/O in hearers(src, null))
				O.show_message("<span class='emote'>[message]</span>", m_type)
	return

/mob/living/silicon/hivebot/examine(mob/user)
	if (isghostdrone(user))
		return list()

	. = list("<span class='notice'>*---------*</span>\n<span class='notice'>This is [bicon(src)] <B>[src.name]</B>!</span>")

	if (isdead(src))
		. += "<span class='alert'>[src.name] is powered-down.</span>"
	if (src.bruteloss)
		if (src.bruteloss < 75)
			. += "<span class='alert'>[src.name] looks slightly dented.</span>"
		else
			. += "<span class='alert'><B>[src.name] looks severely dented!</B></span>"
	if (src.fireloss)
		if (src.fireloss < 75)
			. += "<span class='alert'>[src.name] looks slightly burnt!</span>"
		else
			. += "<span class='alert'><B>[src.name] looks severely burnt!</B></span>"
	if (isunconscious(src))
		. += "<span class='alert'>[src.name] doesn't seem to be responding.</span>"

/mob/living/silicon/hivebot/blob_act(var/power)
	if (!isdead(src))
		src.bruteloss += power
		health_update_queue |= src
		return 1
	return 0

/mob/living/silicon/hivebot/Stat()
	..()
	if(src.cell)
		stat("Charge Left:", "[src.cell.charge]/[src.cell.maxcharge]")
	else
		stat("No Cell Inserted!")

/mob/living/silicon/hivebot/restrained()
	return 0

/mob/living/silicon/hivebot/bullet_act(var/obj/projectile/P)
	..()
	log_shot(P,src) // Was missing (Convair880).

/mob/living/silicon/hivebot/ex_act(severity)
	..() // Logs.
	src.flash(3 SECONDS)

	if (isdead(src) && src.client)
		src.gib(1)
		return

	else if (isdead(src) && !src.client)
		qdel(src)
		return

	var/b_loss = src.bruteloss
	var/f_loss = src.fireloss
	switch(severity)
		if(1)
			if (!isdead(src))
				b_loss += 100
				f_loss += 100
				src.gib(1)
				return
		if(2)
			if (!isdead(src))
				b_loss += 60
				f_loss += 60
		if(3)
			if (!isdead(src))
				b_loss += 30
	src.bruteloss = b_loss
	src.fireloss = f_loss
	health_update_queue |= src

/mob/living/silicon/hivebot/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("<span class='alert'>[src] has been hit by [O]</span>"), 1)
		//Foreach goto(19)
	if (src.health > 0)
		src.bruteloss += 30
		if ((O.icon_state == "flaming"))
			src.fireloss += 40
		health_update_queue |= src
	return

/mob/living/silicon/hivebot/bump(atom/movable/AM as mob|obj)
	if (src.now_pushing)
		return
	if (!istype(AM, /atom/movable))
		return
	if (!src.now_pushing)
		src.now_pushing = 1
		if (!AM.anchored)
			var/t = get_dir(src, AM)
			step(AM, t)
		src.now_pushing = null

/mob/living/silicon/hivebot/attackby(obj/item/W, mob/user)
	if (isweldingtool(W))
		if (src.get_brute_damage() < 1)
			boutput(user, "<span class='alert'>[src] has no dents to repair.</span>")
			return
		if(!W:try_weld(user, 1))
			return
		src.HealDamage("All", 30, 0)
		src.add_fingerprint(user)
		if (src.get_brute_damage() < 1)
			src.bruteloss = 0
			src.visible_message("<span class='alert'><b>[user] fully repairs the dents on [src]!</b></span>")
		else
			src.visible_message("<span class='alert'>[user] has fixed some of the dents on [src].</span>")
		health_update_queue |= src

	// Added ability to repair burn-damaged AI shells (Convair880).
	else if (istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/coil = W
		src.add_fingerprint(user)
		if (src.get_burn_damage() < 1)
			user.show_text("There's no burn damage on [src.name]'s wiring to mend.", "red")
			return
		coil.use(1)
		src.HealDamage("All", 0, 30)
		if (src.get_burn_damage() < 1)
			src.fireloss = 0
			src.visible_message("<span class='alert'><b>[user.name]</b> fully repairs the damage to [src.name]'s wiring.</span>")
		else
			boutput(user, "<span class='alert'><b>[user.name]</b> repairs some of the damage to [src.name]'s wiring.</span>")
		health_update_queue |= src

	else if (istype(W, /obj/item/clothing/suit/bee))
		boutput(user, "You stuff [src] into [W]! It fits surprisingly well.")
		src.beebot = 1
		src.UpdateIcon()
		qdel(W)
		return
	else
		return ..()

/mob/living/silicon/hivebot/attack_hand(mob/user)
	user.lastattacked = src
	if(!user.stat)
		if (user.a_intent != INTENT_HELP)
			actions.interrupt(src, INTERRUPT_ATTACKED)
		switch(user.a_intent)
			if(INTENT_HELP) //Friend person
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -2)
				user.visible_message("<span class='notice'>[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")].</span>")
			if(INTENT_DISARM) //Shove
				SPAWN(0) playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
				user.visible_message("<span class='alert'><B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B></span>")
			if(INTENT_GRAB) //Shake
				if(src.beebot == 1)
					var/obj/item/clothing/suit/bee/B = new /obj/item/clothing/suit/bee(src.loc)
					boutput(user, "You pull [B] off of [src]!")
					src.beebot = 0
					src.UpdateIcon()
				else
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1, -2)
					user.visible_message("<span class='alert'>[user] shakes [src] [pick_string("descriptors.txt", "borg_shake")]!</span>")
			if(INTENT_HARM) //Dumbo
				if (user.is_hulk())
					src.TakeDamage("All", 5, 0)
					if (prob(40))
						var/turf/T = get_edge_target_turf(user, user.dir)
						if (isturf(T))
							src.visible_message("<span class='alert'><B>[user] savagely punches [src], sending them flying!</B></span>")
							src.throw_at(T, 10, 2)
				/*if (user.glove_weaponcheck())
					user.energyclaws_attack(src)*/
				else
					user.visible_message("<span class='alert'><B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!</span>", "<span class='alert'><B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B></span>")
					random_brute_damage(user, rand(2,5))
					playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 60, 1)
					if(prob(10)) user.show_text("Your hand hurts...", "red")

		add_fingerprint(user)

/mob/living/silicon/hivebot/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	return 0

/mob/living/silicon/hivebot/check_access(obj/item/I)
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	if (istype(I, /obj/item/device/pda2) && I:ID_card)
		I = I:ID_card
	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/card/id) || !I:access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if(!(req in I:access)) //doesn't have this access
			return 0
	return 1

/mob/living/silicon/hivebot/update_icon()
	src.overlays = null

	if (isalive(src))
		if (src.beebot == 1)
			src.icon_state = "eyebot-bee[src.client ? null : "-logout"]"
		else
			src.icon_state = "[initial(icon_state)][src.client ? null : "-logout"]"
	else
		if (src.beebot == 1)
			src.icon_state = "eyebot-bee-dead"
		else
			src.icon_state = "[initial(icon_state)]-dead"

/mob/living/silicon/hivebot/proc/uneq_active()
	if (isnull(src.module_active))
		return
	if (isitem(src.module_active))
		var/obj/item/I = src.module_active
		I.dropped(src) // Handle light datums and the like.

	if(src.module_states[1] == src.module_active)
		if (src.client)
			src.client.screen -= module_states[1]
		src.contents -= module_states[1]
		src.module_active = null
		src.module_states[1] = null
	else if(src.module_states[2] == src.module_active)
		if (src.client)
			src.client.screen -= module_states[2]
		src.contents -= module_states[2]
		src.module_active = null
		src.module_states[2] = null
	else if(src.module_states[3] == src.module_active)
		if (src.client)
			src.client.screen -= module_states[3]
		src.contents -= module_states[3]
		src.module_active = null
		src.module_states[3] = null
	hud.update_tools()
	hud.update_tool_selector()
	hud.update_active_tool()

/mob/living/silicon/hivebot/swap_hand(var/switchto = 0)
	if (!module_states[1] && !module_states[2] && !module_states[3])
		module_active = null
		return

	var/active = src.module_states.Find(src.module_active)
	if (!switchto)
		switchto = (active % 3) + 1
	if (switchto == active)
		src.module_active = null
	// clicking the already on slot, so deselect basically
	else
		switch(switchto)
			if(1) src.module_active = src.module_states[1]
			if(2) src.module_active = src.module_states[2]
			if(3) src.module_active = src.module_states[3]
			else src.module_active = null
	hud.update_active_tool()

/mob/living/silicon/hivebot/click(atom/target, list/params)
	if ((target in src.module.tools) && !(target in src.module_states))
		for (var/i = 1; i <= 3; i++)
			if (!src.module_states[i])
				src.module_states[i] = target
				var/obj/item/I = target
				if(isitem(I))
					I.pickup(src) // attempted fix for no flashlight functionality - cirr
				hud.update_tool_selector()
				hud.update_tools()
				break
		return
	..()

/mob/living/silicon/hivebot/proc/activated(obj/item/O)
	if(src.module_states[1] == O)
		return 1
	else if(src.module_states[2] == O)
		return 1
	else if(src.module_states[3] == O)
		return 1
	else
		return 0

/mob/living/silicon/hivebot/proc/radio_menu()
	if(!src.radio)
		src.radio = new /obj/item/device/radio(src)
		src.ears = src.radio
	var/dat = {"
<TT>
Microphone: [src.radio.broadcasting ? "<A href='byond://?src=\ref[src.radio];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];talk=1'>Disengaged</A>"]<BR>
Speaker: [src.radio.listening ? "<A href='byond://?src=\ref[src.radio];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src.radio];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[src.radio];freq=-10'>-</A>
<A href='byond://?src=\ref[src.radio];freq=-2'>-</A>
[format_frequency(src.radio.frequency)]
<A href='byond://?src=\ref[src.radio];freq=2'>+</A>
<A href='byond://?src=\ref[src.radio];freq=10'>+</A><BR>
-------
</TT>"}
	src.Browse(dat, "window=radio")
	onclose(src, "radio")
	return

/mob/living/silicon/hivebot/verb/cmd_show_laws()
	set category = "Robot Commands"
	set name = "Show Laws"

	src.show_laws()
	return

/mob/living/silicon/hivebot/verb/open_nearest_door()
	set category = "Robot Commands"
	set name = "Open Nearest Door to..."
	set desc = "Automatically opens the nearest door to a selected individual, if possible."

	src.open_nearest_door_silicon()
	return

/mob/living/silicon/hivebot/verb/cmd_return_mainframe()
	set category = "Robot Commands"
	set name = "Recall to Mainframe"
	return_mainframe()

/mob/living/silicon/hivebot/return_mainframe()
	..()
	src.UpdateIcon()

/mob/living/silicon/hivebot
	clamp_values()
		..()
		sleeping = clamp(sleeping, 0, 1)
		bruteloss = max(bruteloss, 0)
		fireloss = max(fireloss, 0)
		if (src.stuttering)
			src.stuttering = 0

		src.lying = 0
		src.set_density(1)

		if (src.get_eye_blurry())
			src.change_eye_blurry(-1)

		if (src.druggy > 0)
			src.druggy--
			src.druggy = max(0, src.druggy)

	use_power()
		..()
		if (src.cell)
			if (src.cell.charge <= 0)
				//death() no why would it just explode upon running out of power that is absurd
				if (isalive(src))
					sleep(0)
					src.lastgasp()
				setunconscious(src)
			else if (src.cell.charge <= 10)
				src.module_active = null
				src.module_states[1] = null
				src.module_states[2] = null
				src.module_states[3] = null
				src.cell.charge -=1
			else
				if (src.module_states[1])
					src.cell.charge -=1
				if (src.module_states[2])
					src.cell.charge -=1
				if (src.module_states[3])
					src.cell.charge -=1
				src.cell.charge -=1
				setalive(src)
		else
			if (isalive(src))
				sleep(0)
				src.lastgasp() // calling lastgasp() here because we just ran out of power
			setunconscious(src)

	proc/mainframe_check()
		if (mainframe)
			if (isdead(mainframe))
				mainframe.return_to(src)
		else
			gib(1)

/mob/living/silicon/hivebot/Login()
	..()

	update_clothing()
	UpdateIcon()

	if (src.mainframe)
		src.real_name = "SHELL/[src.mainframe]"
		src.name = src.real_name

	else if(src.real_name == "Cyborg")
		src.real_name += " "
		src.real_name += pick("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
		src.real_name += "-[pick(rand(1, 99))]"
		src.name = src.real_name
	return

/mob/living/silicon/hivebot/Logout()
	..()
	UpdateIcon()

	src.real_name = "AI Shell [copytext("\ref[src]", 6, 11)]"
	src.name = src.real_name

	return

/mob/living/silicon/hivebot/say_understands(var/other)
	if (isAI(other))
		return TRUE
	if (ishuman(other))
		var/mob/living/carbon/human/H = other
		if (!H.mutantrace || !H.mutantrace.exclusive_language)
			return TRUE
		else
			return ..()
	if (isrobot(other) || isshell(other))
		return TRUE
	return ..()

/mob/living/silicon/hivebot/say_quote(var/text)
	if (src.mainframe && src.mainframe.glitchy_speak)
		text = voidSpeak(text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/hivebot/find_in_hand(var/obj/item/I, var/this_hand)
	if (!I)
		return 0
	if (!src.module_states[3] && !src.module_states[2] && !src.module_states[1])
		return 0

	if (this_hand)
		if (this_hand == "right" || this_hand == 3)
			if (src.module_states[3] && src.module_states[3] == I)
				return 1
			else
				return 0
		else if (this_hand == "middle" || this_hand == 2)
			if (src.module_states[2] && src.module_states[2] == I)
				return 1
			else
				return 0
		else if (this_hand == "left" || this_hand == LEFT_HAND)
			if (src.module_states[1] && src.module_states[1] == I)
				return 1
			else
				return 0
		else
			return 0

	if (src.module_states[3] && src.module_states[3] == I)
		return src.module_states[3]
	else if (src.module_states[2] && src.module_states[2] == I)
		return src.module_states[2]
	else if (src.module_states[1] && src.module_states[1] == I)
		return src.module_states[1]
	else
		return 0

/mob/living/silicon/hivebot/find_type_in_hand(var/obj/item/I, var/this_hand)
	if (!I)
		return 0
	if (!src.module_states[3] && !src.module_states[2] && !src.module_states[1])
		return 0

	if (this_hand)
		if (this_hand == "right" || this_hand == 3)
			if (src.module_states[3] && istype(I, src.module_states[3]))
				return 1
			else
				return 0
		else if (this_hand == "middle" || this_hand == 2)
			if (src.module_states[2] && istype(I, src.module_states[2]))
				return 1
			else
				return 0
		else if (this_hand == "left" || this_hand == LEFT_HAND)
			if (src.module_states[1] && istype(I, src.module_states[1]))
				return 1
			else
				return 0
		else
			return 0

	if (src.module_states[3] && istype(I, src.module_states[3]))
		return src.module_states[3]
	else if (src.module_states[2] && istype(I, src.module_states[2]))
		return src.module_states[2]
	else if (src.module_states[1] && istype(I, src.module_states[1]))
		return src.module_states[1]
	else
		return 0

/mob/living/silicon/hivebot/find_tool_in_hand(var/tool_flag, var/hand)
	if (hand)
		if (hand == "right" || hand == 3)
			var/obj/item/I = src.module_states[3]
			if (I && (I.tool_flags & tool_flag))
				return src.module_states[3]
		if (hand == "middle" || hand == 2)
			var/obj/item/I = src.module_states[2]
			if (I && (I.tool_flags & tool_flag))
				return src.module_states[2]
		if (hand == "left" || hand == LEFT_HAND)
			var/obj/item/I = src.module_states[1]
			if (I && (I.tool_flags & tool_flag))
				return src.module_states[1]
	else
		for(var/i = 1 to 3)
			var/obj/item/I = src.module_states[i]
			if (I && (I.tool_flags & tool_flag))
				return src.module_states[i]
	return 0

/*-----Actual AI Shells---------------------------------------*/

/mob/living/silicon/hivebot/eyebot
	name = "Eyebot"
	icon_state = "eyebot"
	health = 25

	jetpack = 1 //ZeWaka: I concur with ghostdrone commenter, fuck whoever made this. See spacemove.
	var/jeton = 0

	New()
		..()
		hud = new(src)
		src.attach_hud(hud)
		if(!bioHolder)
			bioHolder = new/datum/bioHolder( src )
		SPAWN(0.5 SECONDS)
			if (src.module)
				qdel(src.module)
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/construction))
				src.module = new /obj/item/robot_module/construction_ai( src )
			else
				src.module = new /obj/item/robot_module( src )
			hud.update_tool_selector()

			//ew
			if (!(src in available_ai_shells))
				available_ai_shells += src

	movement_delay()
		return 1 + movement_delay_modifier

	hotkey(name)
		switch (name)
			if ("unequip")
				src.uneq_active()
			if ("swaphand")
				src.swap_hand()
			if ("module1")
				src.swap_hand(1)
			if ("module2")
				src.swap_hand(2)
			if ("module3")
				src.swap_hand(3)
			if ("module4")
				src.swap_hand(4)
			if ("attackself")
				var/obj/item/W = src.equipped()
				if (W)
					src.click(W, list())
			else
				return ..()

	build_keybind_styles(client/C)
		..()
		C.apply_keybind("robot")

		if (!C.preferences.use_wasd)
			C.apply_keybind("robot_arrow")

		if (C.preferences.use_azerty)
			C.apply_keybind("robot_azerty")
		if (C.tg_controls)
			C.apply_keybind("robot_tg")

	update_icon() // Haine wandered in here and just junked up this code with bees.  I'm so sorry it's so ugly aaaa
		src.overlays = null

		if(isalive(src))
			if(src.client)
				if(pixel_y)
					if (src.beebot == 1)
						src.icon_state = "eyebot-bee"
					else
						src.icon_state = "[initial(icon_state)]"
				else
					SPAWN(0)
						while(src.pixel_y < 10)
							src.pixel_y++
							sleep(0.1 SECONDS)
						if (src.beebot == 1)
							src.icon_state = "eyebot-bee"
						else
							src.icon_state = "[initial(icon_state)]"
					return
			else
				if (src.beebot == 1)
					src.icon_state = "eyebot-bee-logout"
				else
					src.icon_state = "[initial(icon_state)]-logout"
				src.pixel_y = 0
		else
			if (src.beebot == 1)
				src.icon_state = "eyebot-bee-dead"
			else
				src.icon_state = "[initial(icon_state)]-dead"
			src.pixel_y = 0
		return

	show_laws()
		var/mob/living/silicon/ai/aiMainframe = src.mainframe
		if (istype(aiMainframe))
			aiMainframe.show_laws(0, src)
		else
			boutput(src, "<span class='alert'>You lack a dedicated mainframe! This is a bug, report to an admin!</span>")

		return

	ghostize()
		if(src.mainframe)
			src.mainframe.return_to(src)
		else
			return ..()

	disposing()
		available_ai_shells -= src
		..()



/*-----Shell-Creation---------------------------------------*/

/obj/item/ai_interface
	name = "\improper AI interface board"
	desc = "A board that allows AIs to interface with the robot it's installed in. It features a little blinking LED, but who knows what the LED is trying to tell you? Does it even mean anything? Why is it blinking? WHY?? WHAT DOES IT MEAN?! ??????"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "ai-interface"
	item_state = "ai-interface"
	w_class = W_CLASS_SMALL

//obj/item/cell/shell_cell moved to cells.dm

/obj/item/shell_frame
	name = "\improper AI shell frame"
	desc = "An empty frame for an AI shell."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "shell-frame"
	item_state = "shell-frame"
	w_class = W_CLASS_SMALL
	var/build_step = 0
	var/obj/item/cell/cell = null
	var/has_radio = 0
	var/has_interface = 0

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null

/obj/item/shell_frame/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/sheet))
		if (src.build_step < 1)
			var/obj/item/sheet/M = W
			if (M.change_stack_amount(-1))
				src.build_step++
				boutput(user, "You add the plating to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
				src.icon_state = "shell-plate"
				return
			else
				boutput(user, "You need at least one metal sheet to add plating! How are you even seeing this message?! How do you have a metal sheet that has no metal sheets in it?!?!")
				user.drop_item()
				qdel(W) // no bizarro nega-sheets for you :v
				return
		else
			boutput(user, "\The [src] already has plating!")
			return

	else if (istype(W, /obj/item/cable_coil))
		if (src.build_step == 1)
			var/obj/item/cable_coil/coil = W
			if (coil.amount >= 3)
				src.build_step++
				boutput(user, "You add \the cable to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
				coil.amount -= 3
				src.icon_state = "shell-cable"
				if (coil.amount < 1)
					user.drop_item()
					qdel(coil)
				return
			else
				boutput(user, "You need at least three lengths of cable to install it in [src].")
				return
		else if (src.build_step > 1)
			boutput(user, "\The [src] already has wiring!")
			return

	else if (istype(W, /obj/item/cell))
		if (src.build_step >= 2)
			if (!src.cell)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
				src.cell = W
				user.u_equip(W)
				W.set_loc(src)
				return
			else
				boutput(user, "\The [src] already has a cell!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the cell.")
			return

	else if (istype(W, /obj/item/device/radio))
		if (src.build_step >= 2)
			if (!src.has_radio)
				src.build_step++
				boutput(user, "You add \the [W] to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
				src.icon_state = "shell-radio"
				src.has_radio = 1
				qdel(W)
				return
			else
				boutput(user, "\The [src] already has a radio!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the radio.")
			return

	else if (istype(W, /obj/item/ai_interface))
		if (src.build_step >= 2)
			if (!src.has_interface)
				src.build_step++
				boutput(user, "You add the [W] to [src]!")
				playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
				src.has_interface = 1
				qdel(W)
				return
			else
				boutput(user, "\The [src] already has an AI interface!")
				return
		else
			boutput(user, "\The [src] needs[src.build_step ? "" : " metal plating and"] wiring installed before you can add the AI interface.")
			return

	else if (iswrenchingtool(W))
		if (src.build_step >= 5)
			src.build_step++
			boutput(user, "You activate the shell!  Beep bop!")
			var/mob/living/silicon/hivebot/eyebot/S = new /mob/living/silicon/hivebot/eyebot(get_turf(src))
			S.cell = src.cell
			src.cell.set_loc(S)
			src.cell = null
			qdel(src)
			return
		else
			var/list/still_needed = list()
			if (src.build_step < 1)
				still_needed += "metal plating"
			if (src.build_step < 2)
				still_needed += "wiring"
			if (!src.cell)
				still_needed += "a power cell"
			if (!src.has_radio)
				still_needed += "a station bounced radio"
			if (!src.has_interface)
				still_needed += "an AI interface board"
			boutput(user, "\The [src] needs [still_needed.len ? english_list(still_needed) : "bugfixing (please call a coder)"] before you can activate it.")
			return
