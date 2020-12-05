#define ROBOT_BATTERY_DISTRESS_INACTIVE 0
#define ROBOT_BATTERY_DISTRESS_ACTIVE 1
#define ROBOT_BATTERY_DISTRESS_THRESHOLD 100

/datum/robot_cosmetic
	var/head_mod = null
	var/ches_mod = null
	var/arms_mod = null
	var/legs_mod = null
	var/list/fx = list(255,0,0)
	var/painted = 0
	var/paint = null

/mob/living/silicon/robot
	name = "Cyborg"
	voice_name = "synthesized voice"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	health = 300
	// max_health = 300
	emaggable = 1
	syndicate_possible = 1
	movement_delay_modifier = 2 - BASE_SPEED

	var/datum/hud/robot/hud

// Pieces and parts
	var/obj/item/parts/robot_parts/head/part_head = null
	var/obj/item/parts/robot_parts/chest/part_chest = null
	var/obj/item/parts/robot_parts/arm/part_arm_r = null
	var/obj/item/parts/robot_parts/arm/part_arm_l = null
	var/obj/item/parts/robot_parts/leg/part_leg_r = null
	var/obj/item/parts/robot_parts/leg/part_leg_l = null
	var/total_weight = 0
	var/datum/robot_cosmetic/cosmetic_mods = null

	var/list/clothes = list()

	var/next_cache = 0
	var/stat_cache = list(0, 0, "")

	// 3 tools can be activated at any one time.
	var/module_active = null
	var/list/module_states = list(null,null,null)

	var/obj/item/device/radio/default_radio = null // radio used when there's no module radio
	var/obj/item/device/radio/radio = null
	var/obj/item/device/radio/ai_radio = null // Radio used for when this is an AI-controlled shell.
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/machinery/camera/camera = null
	var/obj/item/organ/brain/brain = null
	var/obj/item/ai_interface/ai_interface = null
	var/obj/item/robot_module/module = null
	var/list/upgrades = list()
	var/max_upgrades = 3
	var/obj/item/device/pda2/internal_pda = null

	var/opened = 0
	var/wiresexposed = 0
	var/brainexposed = 0
	var/batteryDistress = ROBOT_BATTERY_DISTRESS_INACTIVE
	var/next_batteryDistressBoop = 0
	var/locked = 1
	var/locking = 0
	req_access = list(access_robotics)
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/viewalerts = 0
	var/jetpack = 0
	var/jeton = 0
	var/freemodule = 1 // For picking modules when a robot is first created
	var/automaton_skin = 0 // for the medal reward
	var/alohamaton_skin = 0 // for the bank purchase
	var/metalman_skin = 0	//mbc : i'm getting tired of copypasting this, i promise to fix this somehow next time i add a cyborg skin ok
	var/glitchy_speak = 0

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'
	var/sound_automaton_scratch = 'sound/misc/automaton_scratch.ogg'
	var/sound_automaton_ratchet = 'sound/misc/automaton_ratchet.ogg'
	var/sound_automaton_tickhum = 'sound/misc/automaton_tickhum.ogg'
	var/sound_sad_robot =  'sound/voice/Sad_Robot.ogg'

	// moved up to silicon.dm
	killswitch = 0
	killswitch_time = 60
	weapon_lock = 0
	weaponlock_time = 120
	var/oil = 0
	var/custom = 0 //For custom borgs. Basically just prevents appearance changes. Obviously needs more work.

	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)

		src.internal_pda = new /obj/item/device/pda2/cyborg(src)
		src.internal_pda.name = "[src]'s Internal PDA Unit"
		src.internal_pda.owner = "[src]"
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/robot_base, "robot_health_slow_immunity")
		if (starter && !(src.dependent || src.shell))
			var/obj/item/parts/robot_parts/chest/light/PC = new /obj/item/parts/robot_parts/chest/light(src)
			var/obj/item/cell/supercell/charged/CELL = new /obj/item/cell/supercell/charged(PC)
			PC.wires = 1
			src.cell = CELL
			PC.cell = CELL
			src.part_chest = PC
			src.part_head = new /obj/item/parts/robot_parts/head/light(src)
			src.part_arm_r = new /obj/item/parts/robot_parts/arm/right/light(src)
			src.part_arm_l = new /obj/item/parts/robot_parts/arm/left/light(src)
			src.part_leg_r = new /obj/item/parts/robot_parts/leg/right/light(src)
			src.part_leg_l = new /obj/item/parts/robot_parts/leg/left/light(src)
			for(var/obj/item/parts/robot_parts/P in src.contents)
				P.holder = src
				if(P.robot_movement_modifier)
					APPLY_MOVEMENT_MODIFIER(src, P.robot_movement_modifier, P.type)


			if (!src.custom)
				SPAWN_DBG(0)
					src.choose_name(3)

		else if (src.part_head && src.part_chest) // some wee child of ours sent us some parts, how nice  c:
			if (src.part_head.loc != src)
				src.part_head.set_loc(src)
			if (src.part_chest.loc != src)
				src.part_chest.set_loc(src)
			for (var/obj/item/parts/robot_parts/P in src.contents)
				P.holder = src
				if(P.robot_movement_modifier)
					APPLY_MOVEMENT_MODIFIER(src, P.robot_movement_modifier, P.type)

		else
			if (!frame)
				// i can only imagine bad shit happening if you just try to straight spawn one like from the spawn menu or
				// whatever so let's not allow that for the time being, just to make sure
				logTheThing("debug", null, null, "<b>I Said No/Composite Cyborg:</b> Composite borg attempted to spawn with null frame")
				qdel(src)
				return
			else
				if (!frame.head || !frame.chest)
					logTheThing("debug", null, null, "<b>I Said No/Composite Cyborg:</b> Composite borg attempted to spawn from incomplete frame")
					qdel(src)
					return
				src.part_head = frame.head
				src.part_chest = frame.chest
				if (frame.l_arm) src.part_arm_l = frame.l_arm
				if (frame.r_arm) src.part_arm_r = frame.r_arm
				if (frame.l_leg) src.part_leg_l = frame.l_leg
				if (frame.r_leg) src.part_leg_r = frame.r_leg
				for(var/obj/item/parts/robot_parts/P in frame.contents)
					P.set_loc(src)
					P.holder = src
					if(P.robot_movement_modifier)
						APPLY_MOVEMENT_MODIFIER(src, P.robot_movement_modifier, P.type)

		if (istype(src.part_leg_l,/obj/item/parts/robot_parts/leg/left/thruster) || istype(src.part_leg_r,/obj/item/parts/robot_parts/leg/right/thruster))
			src.flags ^= TABLEPASS

		src.cosmetic_mods = new /datum/robot_cosmetic(src)

		. = ..()

		hud = new(src)
		src.attach_hud(hud)

		src.zone_sel = new(src, "CENTER+3, SOUTH")
		src.zone_sel.change_hud_style('icons/mob/hud_robot.dmi')
		src.attach_hud(zone_sel)

		if (src.shell)
			if (!(src in available_ai_shells))
				available_ai_shells += src
			for_by_tcl(AI, /mob/living/silicon/ai)
				boutput(AI, "<span class='success'>[src] has been connected to you as a controllable shell.</span>")
			if (!src.ai_interface)
				src.ai_interface = new(src)

		SPAWN_DBG (1)
			if (!src.dependent && !src.shell)
				boutput(src, "<span class='notice'>Your icons have been generated!</span>")
				src.syndicate = syndie
				src.emagged = frame_emagged
		SPAWN_DBG (4)
			if (!src.connected_ai && !syndicate && !(src.dependent || src.shell))
				for_by_tcl(A, /mob/living/silicon/ai)
					src.connected_ai = A
					A.connected_robots += src
					break

			src.botcard.access = get_all_accesses()
			src.default_radio = new /obj/item/device/radio(src)
			if (src.shell)
				src.ai_radio = new /obj/item/device/radio/headset/command/ai(src)
				src.radio = src.ai_radio
			else
				src.radio = src.default_radio
			src.ears = src.radio
			src.camera = new /obj/machinery/camera(src)
			src.camera.c_tag = src.real_name
			src.camera.network = "Robots"

		SPAWN_DBG (15)
			if (!src.brain && src.key && !(src.dependent || src.shell || src.ai_interface))
				var/obj/item/organ/brain/B = new /obj/item/organ/brain(src)
				B.owner = src.mind
				B.icon_state = "borg_brain"
				if (!B.owner) //Oh no, they have no mind!
					logTheThing("debug", null, null, "<b>Mind</b> Cyborg spawn forced to create new mind for key \[[src.key ? src.key : "INVALID KEY"]]")
					var/datum/mind/newmind = new
					newmind.key = src.key
					newmind.current = src
					B.owner = newmind
					src.mind = newmind
				src.brain = B
				if (src.part_head)
					B.set_loc(src.part_head)
					src.part_head.brain = B
				else
					// how the hell would this happen. oh well
					var/obj/item/parts/robot_parts/head/H = new /obj/item/parts/robot_parts/head(src)
					src.part_head = H
					B.set_loc(H)
					H.brain = B
			update_bodypart()

		if (prob(50))
			src.sound_scream = "sound/voice/screams/Robot_Scream_2.ogg"

	set_pulling(atom/movable/A)
		. = ..()
		hud.update_pulling()

	death(gibbed)
		if (src.mainframe)
			logTheThing("combat", src, null, "'s AI controlled cyborg body was destroyed [log_health(src)] at [log_loc(src)].") // Brought in line with carbon mobs (Convair880).
			src.mainframe.return_to(src)
		setdead(src)
		borg_death_alert()
		src.canmove = 0

		if (src.camera)
			src.camera.camera_status = 0.0

		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS

		src.see_in_dark = SEE_DARK_FULL
		if (client?.adventure_view)
			src.see_invisible = 21
		else
			src.see_invisible = 2

		logTheThing("combat", src, null, "was destroyed [log_health(src)] at [log_loc(src)].") // Only called for instakill critters and the like, I believe (Convair880).

		if (src.mind)
			if (src.mind.special_role)
				src.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).
			src.mind.register_death()

#ifdef RESTART_WHEN_ALL_DEAD
		var/cancel

		for (var/client/C)
			if (!C.mob) continue
			if (!( C.mob.stat ))
				cancel = 1
				break
		if (!( cancel ))
			boutput(world, "<B>Everyone is dead! Resetting in 30 seconds!</B>")
			SPAWN_DBG( 300 )
				logTheThing("diary", null, null, "Rebooting because of no live players", "game")
				Reboot_server()
				return
#endif
		return ..(gibbed)

	emote(var/act, var/voluntary = 1)
		var/param = null
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

		var/m_type = 1
		var/message

		switch(lowertext(act))

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
				var/input = html_encode(sanitize(input("Choose an emote to display.")))
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
				SPAWN_DBG(0)
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
				SPAWN_DBG(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-3,3)
					src.pixel_y += rand(-1,1)
					sleep(0.2 SECONDS)
					src.pixel_x = old_x
					src.pixel_y = old_y

			// for creepy automatoning
			if ("snap")
				if (src.emote_check(voluntary, 50) && (src.automaton_skin || src.alohamaton_skin || src.metalman_skin))
					if ((src.restrained()) && (!src.getStatusDuration("weakened")))
						message = "<B>[src]</B> malfunctions!"
						src.TakeDamage("head", 2, 4)
					if ((!src.restrained()) && (!src.getStatusDuration("weakened")))
						if (prob(33))
							playsound(src.loc, src.sound_automaton_ratchet, 60, 1)
							message = "<B>[src]</B> emits [pick("a soft", "a quiet", "a curious", "an odd", "an ominous", "a strange", "a forboding", "a peculiar", "a faint")] [pick("ticking", "tocking", "humming", "droning", "clicking")] sound."
						else if (prob(33))
							playsound(src.loc, src.sound_automaton_ratchet, 60, 1)
							message = "<B>[src]</B> emits [pick("a peculiar", "a worried", "a suspicious", "a reassuring", "a gentle", "a perturbed", "a calm", "an annoyed", "an unusual")] [pick("ratcheting", "rattling", "clacking", "whirring")] noise."
						else
							playsound(src.loc, src.sound_automaton_scratch, 50, 1)

			if ("birdwell", "burp")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					message = "<b>[src]</b> birdwells."

			if ("scream")
				if (src.emote_check(voluntary, 50))
					if (narrator_mode)
						playsound(src.loc, 'sound/vox/scream.ogg', 50, 1, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					else
						playsound(get_turf(src), src.sound_scream, 80, 0, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
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
					if (!(src.client && src.client.holder)) src.emote_allowed = 0
					if (isdead(src)) src.emote_allowed = 0
					if ((src.restrained()) && (!src.getStatusDuration("weakened")))
						message = "<B>[src]</B> malfunctions!"
						src.TakeDamage("head", 2, 4)
					if ((!src.restrained()) && (!src.getStatusDuration("weakened")))
						if (narrator_mode)
							playsound(src.loc, pick('sound/vox/deeoo.ogg', 'sound/vox/dadeda.ogg'), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						else
							playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						message = "<B>[src]</B> beep-bops!"
						if (prob(50))
							animate_spin(src, "R", 1, 0)
						else
							animate_spin(src, "L", 1, 0)

						for (var/mob/living/M in view(1, null))
							if (M == src)
								continue
							message = "<B>[src]</B> beep-bops at [M]."
							break

			if ("fart")
				if (farting_allowed && src.emote_check(voluntary))
					m_type = 2
					var/fart_on_other = 0
					for (var/mob/living/M in src.loc)
						if (M == src || !M.lying) continue
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
					SPAWN_DBG(1 SECOND)
						src.emote_allowed = 1
			else
				src.show_text("Invalid Emote: [act]")
				return
		if ((message && isalive(src)))
			logTheThing("say", src, null, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type)
			else
				for (var/mob/O in hearers(src, null))
					O.show_message("<span class='emote'>[message]</span>", m_type)
		return

	examine()
		. = list()
		if(src.hiddenFrom?.Find(usr.client)) //invislist
			return

		if (isghostdrone(usr))
			return
		. += "<span class='notice'>*---------*</span><br>"
		. += "<span class='notice'>This is [bicon(src)] <B>[src.name]</B>!</span><br>"

		if (isdead(src))
			. += "<span class='alert'>[src.name] is powered-down.</span><br>"

		var/brute = get_brute_damage()
		var/burn = get_burn_damage()
		if (brute)
			if (brute < 75)
				. += "<span class='alert'>[src.name] looks slightly dented</span><br>"
			else
				. += "<span class='alert'><B>[src.name] looks severely dented!</B></span><br>"
		if (burn)
			if (burn < 75)
				. += "<span class='alert'>[src.name] has slightly burnt wiring!</span><br>"
			else
				. += "<span class='alert'><B>[src.name] has severely burnt wiring!</B></span><br>"
		if (src.health <= 50)
			. += "<span class='alert'>[src.name] is twitching and sparking!</span><br>"
		if (isunconscious(src))
			. += "<span class='alert'>[src.name] doesn't seem to be responding.</span><br>"

		. += "The cover is [opened ? "open" : "closed"].<br>"
		. += "The power cell display reads: [ cell ? "[round(cell.percent())]%" : "WARNING: No cell installed."]<br>"

		if (src.module)
			. += "[src.name] has a [src.module.name] installed.<br>"
		else
			. += "[src.name] does not appear to have a module installed.<br>"

		. += "<span class='notice'>*---------*</span>"

	choose_name(var/retries = 3)
		var/newname
		for (retries, retries > 0, retries--)
			newname = input(src,"You are a Cyborg. Would you like to change your name to something else?", "Name Change", src.real_name) as null|text
			if (!newname)
				src.real_name = borgify_name("Cyborg")
				src.name = src.real_name
				src.internal_pda.name = "[src]'s Internal PDA Unit"
				src.internal_pda.owner = "[src]"
				return
			else
				newname = strip_html(newname, MOB_NAME_MAX_LENGTH, 1)
				if (!length(newname))
					src.show_text("That name was too short after removing bad characters from it. Please choose a different name.", "red")
					continue
				else if (is_blank_string(newname))
					src.show_text("Your name cannot be blank. Please choose a different name.", "red")
					continue
				else
					if (alert(src, "Use the name [newname]?", newname, "Yes", "No") == "Yes")
						src.real_name = newname
						src.name = newname
						src.internal_pda.name = "[src]'s Internal PDA Unit"
						src.internal_pda.owner = "[src]"
						return 1
					else
						continue
		if (!newname)
			src.real_name = borgify_name("Cyborg")
			src.name = src.real_name
			src.internal_pda.name = "[src.name]'s Internal PDA Unit"
			src.internal_pda.owner = "[src]"

	Login()
		..()

		if (src.custom)
			src.choose_name(3)

		if (src.real_name == "Cyborg")
			src.real_name = borgify_name(src.real_name)
			src.name = src.real_name
			src.internal_pda.name = "[src.name]'s Internal PDA Unit"
			src.internal_pda.owner = "[src]"
		if (!src.syndicate && !src.connected_ai)
			for_by_tcl(A, /mob/living/silicon/ai)
				src.connected_ai = A
				A.connected_robots += src
				break

		if (src.shell && src.mainframe)
			src.real_name = "SHELL/[src.mainframe]"
			src.name = src.real_name

		update_clothing()
		update_appearance()
		return

	Logout()
		..()
		if (src.shell)
			src.real_name = "AI Cyborg Shell [copytext("\ref[src]", 6, 11)]"
			src.name = src.real_name
			return

	blob_act(var/power)
		if (!isdead(src))
			var/Pshield = 0
			for (var/obj/item/roboupgrade/physshield/R in src.contents)
				if (R.activated) Pshield = 1
			if (Pshield)
				boutput(src, "<span class='notice'>Your force shield absorbs the blob's attack!</span>")
				src.cell.use(power * 30)
				playsound(src.loc, "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
			else
				boutput(src, "<span class='alert'>The blob attacks you!</span>")
				var/damage = 6 + power / 5
				for (var/obj/item/parts/robot_parts/RP in src.contents)
					if (RP.ropart_take_damage(damage,damage/2) == 1) src.compborg_lose_limb(RP)
				// maybe the blob is a little acidic?? idk
			src.update_bodypart()
			return 1
		return 0

	Stat()
		..()
		if(src.cell)
			stat("Charge Left:", "[src.cell.charge]/[src.cell.maxcharge]")
		else
			stat("No Cell Inserted!")

		/*
		// this is handled by the hud now
		if (ticker.round_elapsed_ticks > next_cache)
			next_cache = ticker.round_elapsed_ticks + 50
			var/list/limbs_report = list()
			if (!part_arm_r)
				limbs_report += "Right arm"
			if (!part_arm_l)
				limbs_report += "Left arm"
			if (!part_leg_r)
				limbs_report += "Right leg"
			if (!part_leg_l)
				limbs_report += "Left leg"
			var/limbs_missing = limbs_report.len ? jointext(limbs_report, "; ") : 0
			stat_cache = list(100 - min(get_brute_damage(), 100), 100 - min(get_burn_damage(), 100), limbs_missing)

		stat("Structural integrity:", "[stat_cache[1]]%")
		stat("Circuit integrity:", "[stat_cache[2]]%")
		if (stat_cache[3])
			stat("Missing limbs:", stat_cache[3])
		*/

	restrained()
		return 0

	ex_act(severity)
		..() // Logs.
		src.flash(3 SECONDS)

		if (isdead(src) && src.client)
			SPAWN_DBG(1 DECI SECOND)
				src.gib(1)
			return

		else if (isdead(src) && !src.client)
			qdel(src)
			return

		var/fire_protect = 0
		for (var/obj/item/roboupgrade/R in src.contents)
			if (istype(R, /obj/item/roboupgrade/physshield) && R.activated)
				boutput(src, "<span class='notice'>Your force shield absorbs some of the blast!</span>")
				playsound(src.loc, "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
				severity++
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated)
				boutput(src, "<span class='notice'>Your fire shield absorbs some of the blast!</span>")
				playsound(src.loc, "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
				fire_protect = 1
				severity++

		var/damage = 0
		switch(severity)
			if(1.0)
				SPAWN_DBG(1 DECI SECOND)
					src.gib(1)
				return
			if(2.0) damage = 40
			if(3.0) damage = 20

		SPAWN_DBG(0)
			for (var/obj/item/parts/robot_parts/RP in src.contents)
				if (RP.ropart_take_damage(damage,damage) == 1)
					src.compborg_lose_limb(RP)

		if (istype(cell,/obj/item/cell/erebite) && fire_protect != 1)
			src.visible_message("<span class='alert'><b>[src]'s</b> erebite cell violently detonates!</span>")
			explosion(cell, src.loc, 1, 2, 4, 6, 1)
			SPAWN_DBG(1 DECI SECOND)
				qdel (src.cell)
				src.cell = null

		update_bodypart()

	bullet_act(var/obj/projectile/P)
		var/dmgtype = 0 // 0 for brute, 1 for burn
		var/dmgmult = 1.2
		switch (P.proj_data.damage_type)
			if(D_PIERCING)
				dmgmult = 2
			if(D_SLASHING)
				dmgmult = 0.6
			if(D_ENERGY)
				dmgtype = 1
			if(D_BURNING)
				dmgtype = 1
				dmgmult = 0.75
			if(D_RADIOACTIVE)
				dmgtype = 1
				dmgmult = 0.2
			if(D_TOXIC)
				dmgmult = 0

		if(P.proj_data.ks_ratio == 0)
			src.do_disorient(clamp(P.power*4, P.proj_data.power*2, P.power+80), weakened = P.power*2, stunned = P.power*2, disorient = min(P.power, 80), remove_stamina_below_zero = 0) //bad hack, but it'll do
			src.emote("twitch_v")// for the above, flooring stam based off the power of the datum is intentional

		log_shot(P,src)
		src.visible_message("<span class='alert'><b>[src]</b> is struck by [P]!</span>")
		var/damage = (P.power / 3) * dmgmult
		if (damage < 1)
			return

		for (var/obj/item/roboupgrade/R in src.contents)
			if (istype(R, /obj/item/roboupgrade/physshield) && R.activated && dmgtype == 0)
				shoot_reflected_to_sender(P, src)
				src.cell.use(damage * 30)
				boutput(src, "<span class='notice'>Your force shield deflects the shot!</span>")
				playsound(src.loc, "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
				return
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated && dmgtype == 1)
				shoot_reflected_to_sender(P, src)
				src.cell.use(damage * 20)
				boutput(src, "<span class='notice'>Your fire shield deflects the shot!</span>")
				playsound(src.loc, "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
				return

		if(src.material) src.material.triggerOnBullet(src, src, P)

		var/obj/item/parts/robot_parts/PART = null
		if (ismob(P.shooter))
			var/mob/living/M = P.shooter
			switch(M.zone_sel.selecting)
				if ("head")
					PART = src.part_head
				if ("r_arm")
					PART = src.part_arm_r
				if ("r_leg")
					PART = src.part_leg_r
				if ("l_arm")
					PART = src.part_arm_l
				if ("l_leg")
					PART = src.part_leg_l
				else
					PART = src.part_chest
		else
			var/list/parts = list()
			for (var/obj/item/parts/robot_parts/RP in src.contents)
				parts.Add(RP)
			if (parts.len > 0)
				PART = pick(parts)
		if (PART?.ropart_take_damage(damage,damage) == 1)
			src.compborg_lose_limb(PART)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)	// trying to unlock with an emag card
			if (src.opened && user) boutput(user, "You must close the cover to swipe an ID card.")
			else if (src.wiresexposed && user) boutput(user, "<span class='alert'>You need to get the wires out of the way.</span>")
			else
				sleep (6)
				if (prob(50))
					if (user)
						boutput(user, "You emag [src]'s interface.")
					src.visible_message("<font color=red><b>[src]</b> buzzes oddly!</font>")
					src.emagged = 1
					src.handle_robot_antagonist_status("emagged", 0, user)
					SPAWN_DBG(0)
						update_appearance()
					return 1
				else
					if (user)
						boutput(user, "You fail to [ locked ? "unlock" : "lock"] [src]'s interface.")
					return 0

	emp_act()
		vision.noise(60)
		boutput(src, "<span class='alert'><B>*BZZZT*</B></span>")
		for (var/obj/item/parts/robot_parts/RP in src.contents)
			if (RP.ropart_take_damage(0,10) == 1) src.compborg_lose_limb(RP)
		/* Bit of a problem when EMPs that are supposed to be strong against cyborgs might just turn them into antagonists ...
		if (prob(25))
			src.visible_message("<font color=red><b>[src]</b> buzzes oddly!</font>")
			src.emagged = 1
			src.handle_robot_antagonist_status("emagged", 0, usr)
		*/
		return

	meteorhit(obj/O as obj)
		src.visible_message("<font color=red><b>[src]</b> is struck by [O]!</font>")
		if (isdead(src))
			src.gib()
			return

		var/Pshield = 0
		var/Fshield = 0
		for (var/obj/item/roboupgrade/R in src.contents)
			if (istype(R, /obj/item/roboupgrade/physshield) && R.activated) Pshield = 1
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated) Fshield = 1

		if (Pshield)
			boutput(src, "<span class='notice'>Your force shield absorbs the impact!</span>")
			playsound(src.loc, "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
		else
			for (var/obj/item/parts/robot_parts/RP in src.contents)
				if (RP.ropart_take_damage(35,0) == 1) src.compborg_lose_limb(RP)
		if ((O.icon_state == "flaming"))
			if (Fshield)
				boutput(src, "<span class='notice'>Your fire shield absorbs the heat!</span>")
				playsound(src.loc, "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
			else
				for (var/obj/item/parts/robot_parts/RP in src.contents)
					if (RP.ropart_take_damage(0,35) == 1) src.compborg_lose_limb(RP)
				if (istype(cell,/obj/item/cell/erebite))
					src.visible_message("<span class='alert'><b>[src]'s</b> erebite cell violently detonates!</span>")
					explosion(cell, src.loc, 1, 2, 4, 6, 1)
					SPAWN_DBG(1 DECI SECOND)
						qdel (src.cell)
						src.cell = null
			update_bodypart()
		return

	temperature_expose(null, temp, volume)
		var/Fshield = 0

		if(src.material)
			src.material.triggerTemp(src, temp)

		for(var/atom/A in src.contents)
			if(A.material)
				A.material.triggerTemp(A, temp)

		for (var/obj/item/roboupgrade/R in src.contents)
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated) Fshield = 1
		if (Fshield == 0)
			if (istype(cell,/obj/item/cell/erebite))
				src.visible_message("<span class='alert'><b>[src]'s</b> erebite cell violently detonates!</span>")
				explosion(cell, src.loc, 1, 2, 4, 6, 1)
				SPAWN_DBG(1 DECI SECOND)
					qdel (src.cell)
					src.cell = null

	Bump(atom/movable/AM as mob|obj, yes)
		SPAWN_DBG( 0 )
			if ((!( yes ) || src.now_pushing))
				return
			src.now_pushing = 1
			if(ismob(AM))
				var/mob/tmob = AM
				if(ishuman(tmob) && tmob.bioHolder && tmob.bioHolder.HasEffect("fat"))
					if(prob(20))
						src.visible_message("<span class='alert'><B>[src] fails to push [tmob]'s fat ass out of the way.</B></span>")
						src.now_pushing = 0
						src.unlock_medal("That's no moon, that's a GOURMAND!", 1)
						return
			src.now_pushing = 0
			//..()
			if(AM)
				AM.last_bumped = world.timeofday
				AM.Bumped(src)
			if (!istype(AM, /atom/movable))
				return
			if (!src.now_pushing)
				src.now_pushing = 1
				if (!AM.anchored)
					var/t = get_dir(src, AM)
					step(AM, t)
				src.now_pushing = null
			return
		return

	triggerAlarm(var/class, area/A, var/O, var/alarmsource)
		if (isdead(src))
			return 1
		var/list/L = src.alarms[class]
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/sources = alarm[3]
				if (!(alarmsource in sources))
					sources += alarmsource
				return 1
		var/obj/machinery/camera/C = null
		var/list/CL = null
		if (O && istype(O, /list))
			CL = O
			if (CL.len == 1)
				C = CL[1]
		else if (O && istype(O, /obj/machinery/camera))
			C = O
		L[A.name] = list(A, (C) ? C : O, list(alarmsource))
		boutput(src, text("--- [class] alarm detected in [A.name]!"))
		if (src.viewalerts) src.robot_alerts()
		return 1

	cancelAlarm(var/class, area/A as area, obj/origin)
		var/list/L = src.alarms[class]
		var/cleared = 0
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/srcs  = alarm[3]
				if (origin in srcs)
					srcs -= origin
				if (srcs.len == 0)
					cleared = 1
					L -= I
		if (cleared)
			boutput(src, text("--- [class] alarm in [A.name] has been cleared."))
			if (src.viewalerts) src.robot_alerts()
		return !cleared

	attackby(obj/item/W as obj, mob/user as mob)
		if (isweldingtool(W))
			if(W:try_weld(user, 1))
				src.add_fingerprint(user)
				var/repaired = HealDamage("All", 120, 0)
				if(repaired || health < max_health)
					src.visible_message("<span class='alert'><b>[user.name]</b> repairs some of the damage to [src.name]'s body.</span>")
				else boutput(user, "<span class='alert'>There's no structural damage on [src.name] to mend.</span>")
				src.update_appearance()

		else if (istype(W, /obj/item/cable_coil) && wiresexposed)
			var/obj/item/cable_coil/coil = W
			src.add_fingerprint(user)
			var/repaired = HealDamage("All", 0, 120)
			if(repaired || health < max_health)
				coil.use(1)
				src.visible_message("<span class='alert'><b>[user.name]</b> repairs some of the damage to [src.name]'s wiring.</span>")
			else boutput(user, "<span class='alert'>There's no burn damage on [src.name]'s wiring to mend.</span>")
			src.update_appearance()

		else if (ispryingtool(W))
			if (opened)
				boutput(user, "You close the cover.")
				opened = 0
			else
				if (locked)
					boutput(user, "<span class='alert'>[src.name]'s cover is locked!</span>")
				else
					boutput(user, "You open [src.name]'s cover.")
					opened = 1
					if (src.locking)
						src.locking = 0
			src.update_appearance()

		else if (istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
			if (wiresexposed)
				boutput(user, "<span class='alert'>You need to get the wires out of the way first.</span>")
			else if (cell)
				boutput(user, "<span class='alert'>[src] already has a power cell!</span>")
			else
				user.drop_item()
				W.set_loc(src)
				cell = W
				boutput(user, "You insert [W].")
				src.update_appearance()

		else if (istype(W, /obj/item/roboupgrade) && opened) // module changing
			if (istype(W,/obj/item/roboupgrade/ai/))
				boutput(user, "<span class='alert'>This is an AI unit upgrade. It is not compatible with cyborgs.</span>")
			if (wiresexposed)
				boutput(user, "<span class='alert'>You need to get the wires out of the way first.</span>")
			else
				if (src.upgrades.len >= src.max_upgrades)
					boutput(user, "<span class='alert'>There's no room - you'll have to remove an upgrade first.</span>")
					return
				//for (var/obj/item/roboupgrade/R in src.contents)
					//(istype(W, R))
				if (locate(W.type) in src.upgrades)
					boutput(user, "<span class='alert'>This cyborg already has that upgrade!</span>")
					return
				user.drop_item()
				W.set_loc(src)
				src.upgrades.Add(W)
				boutput(user, "You insert [W].")
				boutput(src, "<span class='notice'>You recieved [W]! It can be activated from your panel.</span>")
				hud.update_upgrades()
				src.update_appearance()

		else if (istype(W, /obj/item/robot_module) && opened) // module changing
			if(wiresexposed) boutput(user, "<span class='alert'>You need to get the wires out of the way first.</span>")
			else if(src.module) boutput(user, "<span class='alert'>[src] already has a module!</span>")
			else
				user.drop_item()
				src.set_module(W)
				boutput(user, "You insert [W].")

		else if	(isscrewingtool(W))
			if (src.locked)
				boutput(user, "<span class='alert'>You need to unlock the cyborg first.</span>")
			else if (src.opened)
				if (src.locking)
					src.locking = 0
				wiresexposed = !wiresexposed
				boutput(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
			else
				if (src.locking)
					src.locking = 0
				brainexposed = !brainexposed
				boutput(user, "The head compartment has been [brainexposed ? "opened" : "closed"].")
			src.update_appearance()

		else if (istype(W, /obj/item/card/id) || (istype(W, /obj/item/device/pda2) && W:ID_card))	// trying to unlock the interface with an ID card
			if (opened)
				boutput(user, "<span class='alert'>You must close the cover to swipe an ID card.</span>")
			else if (wiresexposed)
				boutput(user, "<span class='alert'>You need to get the wires out of the way.</span>")
			else if (brainexposed)
				boutput(user, "<span class='alert'>You need to close the head compartment.</span>")
			else
				if (src.allowed(usr))
					if (src.locking)
						src.locking = 0
					locked = !locked
					boutput(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
					boutput(src, "<span class='notice'>[user] [ locked ? "locks" : "unlocks"] your interface.</span>")
				else
					boutput(user, "<span class='alert'>Access denied.</span>")

		else if (istype(W, /obj/item/card/emag))
			return

		else if (istype(W, /obj/item/organ/brain) && src.brainexposed)
			if (src.brain || src.ai_interface)
				boutput(user, "<span class='alert'>There's already something in the head compartment! Use a wrench to remove it before trying to insert something else.</span>")
			else
				var/obj/item/organ/brain/B = W
				user.drop_item()
				user.visible_message("<span class='notice'>[user] inserts [W] into [src]'s head.</span>")
				if (B.owner && (B.owner.dnr || jobban_isbanned(B.owner.current, "Cyborg")))
					src.visible_message("<span class='alert'>\The [B] is hit by a spark of electricity from \the [src]!</span>")
					B.combust()
					return
				W.set_loc(src)
				src.brain = B
				if (src.part_head)
					src.part_head.brain = B
					B.set_loc(src.part_head)
				if (B.owner)
					var/mob/M = find_ghost_by_key(B.owner.ckey)
					if (!M) // if we couldn't find them (i.e. they're still alive), don't pull them into this borg
						src.visible_message("<span class='alert'><b>[src]</b> remains inactive.</span>")
						return
					if (!isdead(M)) // so if they're in VR, the afterlife bar, or a ghostcritter
						boutput(M, "<span class='notice'>You feel yourself being pulled out of your current plane of existence!</span>")
						B.owner = M.ghostize()?.mind
						qdel(M)
					B.owner.transfer_to(src)
					if (src.emagged || src.syndicate)
						src.handle_robot_antagonist_status("brain_added", 0, user)

				if (!src.emagged && !src.syndicate) // The antagonist proc does that too.
					boutput(src, "<B>You are playing a Cyborg. You can interact with most electronic objects in your view.</B>")
					src.show_laws()

				src.unlock_medal("Adjutant Online", 1)
				src.update_appearance()

		else if (istype(W, /obj/item/ai_interface) && src.brainexposed)
			if (src.brain || src.ai_interface)
				boutput(user, "<span class='alert'>There's already something in the head compartment! Use a wrench to remove it before trying to insert something else.</span>")
			else
				var/obj/item/ai_interface/I = W
				user.drop_item()
				user.visible_message("<span class='notice'>[user] inserts [W] into [src]'s head.</span>")
				W.set_loc(src)
				src.ai_interface = I
				if (src.part_head)
					src.part_head.ai_interface = I
					I.set_loc(src.part_head)
				if (!(src in available_ai_shells))
					if(isnull(src.ai_radio))
						src.ai_radio = new /obj/item/device/radio/headset/command/ai(src)
					src.radio = src.ai_radio
					src.ears = src.radio
					src.radio.set_loc(src)
					available_ai_shells += src
					src.real_name = "AI Cyborg Shell [copytext("\ref[src]", 6, 11)]"
					src.name = src.real_name
				for_by_tcl(AI, /mob/living/silicon/ai)
					boutput(AI, "<span class='success'>[src] has been connected to you as a controllable shell.</span>")
				src.shell = 1
				update_appearance()

		else if (iswrenchingtool(W) && src.wiresexposed)
			var/list/actions = list("Do nothing")
			if (src.part_arm_r)
				actions.Add("Remove Right Arm")
			if (src.part_arm_l)
				actions.Add("Remove Left Arm")
			if (src.part_leg_r)
				actions.Add("Remove Right Leg")
			if (src.part_leg_l)
				actions.Add("Remove Left Leg")
			if (!src.part_arm_r && !src.part_arm_l && !src.part_leg_r && !src.part_leg_l)
				if (src.part_head)
					actions.Add("Remove Head")
				if (src.part_chest)
					actions.Add("Remove Chest")

			if (!actions.len)
				boutput(user, "<span class='alert'>You can't think of anything to use the wrench on.</span>")
				return

			var/action = input("What do you want to do?", "Cyborg Deconstruction") in actions
			if (!action) return
			if (action == "Do nothing") return
			if (src.stat >= 2) return //Wire: Fix for borgs removing their entire bodies after death
			if (get_dist(src.loc,user.loc) > 1 && (!user.bioHolder || !user.bioHolder.HasEffect("telekinesis")))
				boutput(user, "<span class='alert'>You need to move closer!</span>")
				return

			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 1)
			switch(action)
				if("Remove Chest")
					if(src.part_chest.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_chest.robot_movement_modifier, src.part_chest.type)
					src.part_chest.set_loc(src.loc)
					src.part_chest.holder = null
					src.part_chest = null
					update_bodypart("chest")
				if("Remove Head")
					if(src.part_head.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_head.robot_movement_modifier, src.part_head.type)
					src.part_head.set_loc(src.loc)
					src.part_head.holder = null
					src.part_head = null
					update_bodypart("head")
				if("Remove Right Arm")
					if(src.part_arm_r.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_arm_r.robot_movement_modifier, src.part_arm_r.type)
					src.compborg_force_unequip(3)
					src.part_arm_r.set_loc(src.loc)
					src.part_leg_r.holder = null
					if (src.part_arm_r.slot == "arm_both")
						src.compborg_force_unequip(1)
						src.part_arm_l = null
						update_bodypart("l_arm")
					src.part_arm_r = null
					update_bodypart("r_arm")
				if("Remove Left Arm")
					if(src.part_arm_l.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_arm_l.robot_movement_modifier, src.part_arm_l.type)
					src.compborg_force_unequip(1)
					src.part_arm_l.set_loc(src.loc)
					src.part_leg_l.holder = null
					if (src.part_arm_l.slot == "arm_both")
						src.part_arm_r = null
						src.compborg_force_unequip(3)
						update_bodypart("r_arm")
					src.part_arm_l = null
					update_bodypart("l_arm")
				if("Remove Right Leg")
					if(src.part_leg_r.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_leg_r.robot_movement_modifier, src.part_leg_r.type)
					src.part_leg_r.holder = null
					src.part_leg_r.set_loc(src.loc)
					if (src.part_leg_r.slot == "leg_both")
						src.part_leg_l = null
						update_bodypart("l_leg")
					src.part_leg_r = null
					update_bodypart("r_leg")
				if("Remove Left Leg")
					if(src.part_leg_l.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_leg_l.robot_movement_modifier, src.part_leg_l.type)
					src.part_leg_l.holder = null
					src.part_leg_l.set_loc(src.loc)
					if (src.part_leg_l.slot == "leg_both")
						src.part_leg_r = null
						update_bodypart("r_leg")
					src.part_leg_l = null
					update_bodypart("l_leg")
				else return
			src.module_active = null
			src.update_appearance()
			hud.set_active_tool(null)
			return

		else if (istype(W,/obj/item/parts/robot_parts/) && src.wiresexposed)
			var/obj/item/parts/robot_parts/RP = W
			switch(RP.slot)
				if("chest")
					boutput(user, "<span class='alert'>You can't attach a chest piece to a constructed cyborg. You'll need to put it on a frame.</span>")
					return
				if("head")
					if(src.part_head)
						boutput(user, "<span class='alert'>[src] already has a head part.</span>")
						return
					src.part_head = RP
					if (src.part_head.brain)
						if(src.part_head.brain.owner)
							if(src.part_head.brain.owner.current)
								src.gender = src.part_head.brain.owner.current.gender
								if(src.part_head.brain.owner.current.client)
									src.lastKnownIP = src.part_head.brain.owner.current.client.address
							src.part_head.brain.owner.transfer_to(src)
				if("l_arm")
					if(src.part_arm_l)
						boutput(user, "<span class='alert'>[src] already has a left arm part.</span>")
						return
					src.part_arm_l = RP
				if("r_arm")
					if(src.part_arm_r)
						boutput(user, "<span class='alert'>[src] already has a right arm part.</span>")
						return
					src.part_arm_r = RP
				if("arm_both")
					if(src.part_arm_l || src.part_arm_r)
						boutput(user, "<span class='alert'>[src] already has an arm part.</span>")
						return
					src.part_arm_l = RP
					src.part_arm_r = RP
				if("l_leg")
					if(src.part_leg_l)
						boutput(user, "<span class='alert'>[src] already has a left leg part.</span>")
						return
					src.part_leg_l = RP
				if("r_leg")
					if(src.part_leg_r)
						boutput(user, "<span class='alert'>[src] already has a right leg part.</span>")
						return
					src.part_leg_r = RP
				if("leg_both")
					if(src.part_leg_l || src.part_leg_r)
						boutput(user, "<span class='alert'>[src] already has a leg part.</span>")
						return
					src.part_leg_l = RP
					src.part_leg_r = RP
				else
					boutput(user, "<span class='alert'>You can't seem to figure out where this piece should go.</span>")
					return

			user.drop_item()
			RP.set_loc(src)
			if(RP.robot_movement_modifier)
				APPLY_MOVEMENT_MODIFIER(src, RP.robot_movement_modifier, RP.type)
			playsound(get_turf(src), "sound/impact_sounds/Generic_Stab_1.ogg", 40, 1)
			boutput(user, "<span class='notice'>You successfully attach the piece to [src.name].</span>")
			src.update_bodypart(RP.slot)

		/*else if (istype(W,/obj/item/reagent_containers/glass/))
			var/obj/item/reagent_containers/glass/G = W
			if (src.a_intent == "help" && user.a_intent == "help")
				if(istype(src.module_active,/obj/item/reagent_containers/glass/))
					var/obj/item/reagent_containers/glass/CG = src.module_active
					if(G.reagents.total_volume < 1)
						boutput(user, "<span class='alert'>Your [G.name] is empty!</span>")
						boutput(src, "<B>[user.name]</B> waves an empty [G.name] at you.")
						return
					if(CG.reagents.total_volume >= CG.reagents.maximum_volume)
						boutput(user, "<span class='alert'>[src.name]'s [CG.name] is already full!</span>")
						boutput(src, "<span class='alert'><B>[user.name]</B> offers you [G.name], but your [CG.name] is already full.</span>")
						return
					G.reagents.trans_to(CG, G.amount_per_transfer_from_this)
					src.visible_message("<b>[user.name]</b> pours some of the [G.name] into [src.name]'s [CG.name].")
					return
				else ..()
			else ..()*/

		else ..()
		return

	hand_attack(atom/target, params, location, control, origParams)
		// Only allow it if the target is outside our contents or it is the equipped tool
		if(!src.contents.Find(target) || target==src.equipped() || ishelpermouse(target))
			..()

	attack_hand(mob/user)

		var/list/available_actions = list()
		if (src.brainexposed && src.brain)
			available_actions.Add("Remove the Brain")
		if (src.brainexposed && src.ai_interface)
			available_actions.Add("Remove the AI Interface")
		if (src.opened && !src.wiresexposed)
			if (src.upgrades.len)
				available_actions.Add("Remove an Upgrade")
			if (src.module && src.module != "empty")
				available_actions.Add("Remove the Module")
			if (cell)
				available_actions.Add("Remove the Power Cell")

		if (available_actions.len)
			available_actions.Insert(1, "Cancel")
			var/action = input("What do you want to do?", "Cyborg Maintenance") as null|anything in available_actions
			if (!action)
				return
			if (get_dist(src.loc,user.loc) > 1 && !src.bioHolder?.HasEffect("telekinesis"))
				boutput(user, "<span class='alert'>You need to move closer!</span>")
				return

			switch(action)
				if ("Remove the Brain")
					//Wire: Fix for multiple players queuing up brain removals, triggering this again
					src.eject_brain()

				if ("Remove the AI Interface")
					if (!src.ai_interface)
						return

					src.visible_message("<span class='alert'>[user] removes [src]'s AI interface!</span>")
					logTheThing("combat", user, src, "removes [constructTarget(src,"combat")]'s ai_interface at [log_loc(src)].")

					src.uneq_active()
					for (var/obj/item/roboupgrade/UPGR in src.contents)
						UPGR.upgrade_deactivate(src)

					user.put_in_hand_or_drop(src.ai_interface)
					src.radio = src.default_radio
					if (src.module && istype(src.module.radio))
						src.radio = src.module.radio
					src.ears = src.radio
					src.radio.set_loc(src)
					src.ai_interface = null
					if(src.ai_radio)
						qdel(src.ai_radio)
						src.ai_radio = null
					src.shell = 0

					if (mainframe)
						mainframe.return_to(src)
						src.mainframe = null

					if (src in available_ai_shells)
						available_ai_shells -= src

				if ("Remove an Upgrade")
					var/obj/item/roboupgrade/UPGR = input("Which upgrade do you want to remove?", "Cyborg Maintenance") in src.upgrades

					if (!UPGR) return
					if (get_dist(src.loc,user.loc) > 2 && (!src.bioHolder || !user.bioHolder.HasEffect("telekinesis")))
						boutput(user, "<span class='alert'>You need to move closer!</span>")
						return

					UPGR.upgrade_deactivate(src)
					user.show_text("[UPGR] was removed!", "red")
					src.upgrades.Remove(UPGR)
					user.put_in_hand_or_drop(UPGR)

					hud.update_upgrades()

				if ("Remove the Module")
					if (istype(src.module,/obj/item/robot_module/))
						var/obj/item/robot_module/RM = src.remove_module()
						user.put_in_hand_or_drop(RM)
						user.show_text("You remove [RM].")

				if ("Remove the Power Cell")
					if (!src.cell)
						return

					for (var/obj/item/roboupgrade/UPGR in src.contents) UPGR.upgrade_deactivate(src)
					user.put_in_hand_or_drop(src.cell)
					user.show_text("You remove [src.cell] from [src].", "red")
					src.show_text("Your power cell was removed!", "red")
					logTheThing("combat", user, src, "removes [constructTarget(src,"combat")]'s power cell at [log_loc(src)].") // Renders them mute and helpless (Convair880).
					cell.add_fingerprint(user)
					cell.updateicon()
					src.cell = null

			update_appearance()
		else //We're just bapping the borg
			user.lastattacked = src
			if(!user.stat)
				actions.interrupt(src, INTERRUPT_ATTACKED)
				switch(user.a_intent)
					if(INTENT_HELP) //Friend person
						playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -2)
						user.visible_message("<span class='notice'>[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")].</span>")
					if(INTENT_DISARM) //Shove
						SPAWN_DBG(0) playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
						user.visible_message("<span class='alert'><B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B></span>")
					if(INTENT_GRAB) //Shake
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

	proc/eject_brain(var/mob/user = null, var/fling = null)
		if (!src.brain)
			return

		if (src.mind && src.mind.special_role)
			src.handle_robot_antagonist_status("brain_removed", 1, user) // Mindslave or rogue (Convair880).

		if (user)
			src.visible_message("<span class='alert'>[user] removes [src]'s brain!</span>")
			logTheThing("combat", user, src, "removes [constructTarget(src,"combat")]'s brain at [log_loc(src)].") // Should be logged, really (Convair880).
		else
			src.visible_message("<span class='alert'>[src]'s brain is ejected from its head!</span>")
			playsound(get_turf(src), "sound/misc/boing/[rand(1,6)].ogg", 40, 1)

		src.uneq_active()
		for (var/obj/item/roboupgrade/UPGR in src.contents) UPGR.upgrade_deactivate(src)

		// Stick the player (if one exists) in a ghost mob
		if (src.mind)
			var/mob/dead/observer/newmob = src.ghostize()
			if (!newmob || !istype(newmob, /mob/dead/observer))
				return
			newmob.corpse = null //Otherwise they could return to a brainless body.  And that is weird.
			newmob.mind.brain = src.brain
			src.brain.owner = newmob.mind

		// Brain box is forced open if it wasn't already (suicides, killswitch)
		src.locked = 0
		src.locking = 0
		src.opened = 0
		src.brainexposed = 1
		if (user)
			user.put_in_hand_or_drop(src.brain)
		else
			src.brain.set_loc(get_turf(src))
			src.brain.throw_at(get_edge_cheap(get_turf(src), pick(cardinal)), 16, 3) // heh

		src.brain = null
		src.update_appearance()

	Topic(href, href_list)
		..()
		if (href_list["mod"])
			var/obj/item/O = locate(href_list["mod"])
			if (!O || (O.loc != src && O.loc != src.module))
				return
			O.attack_self(src)

		if (href_list["act"])
			if(!src.module) return
			var/obj/item/O = locate(href_list["act"])
			if (!O || (O.loc != src && O.loc != src.module))
				return

			if(!src.module_states[1] && istype(src.part_arm_l,/obj/item/parts/robot_parts/arm/))
				src.module_states[1] = O
				src.contents += O
				O.pickup(src) // Handle light datums and the like.
			else if(!src.module_states[2])
				src.module_states[2] = O
				src.contents += O
				O.pickup(src)
			else if(!src.module_states[3] && istype(src.part_arm_r,/obj/item/parts/robot_parts/arm/))
				src.module_states[3] = O
				src.contents += O
				O.pickup(src)
			else boutput(src, "<span class='alert'>You need a free equipment slot to equip that item.</span>")

			hud.update_tools()

		if (href_list["deact"])
			if(!src.module) return
			var/obj/item/O = locate(href_list["deact"])
			if(activated(O))
				if(src.module_states[1] == O)
					uneq_slot(1)
				else if(src.module_states[2] == O)
					uneq_slot(2)
				else if(src.module_states[3] == O)
					uneq_slot(3)
				else boutput(src, "Module isn't activated.")
			else boutput(src, "Module isn't activated")

		if (href_list["upact"])
			var/obj/item/roboupgrade/R = locate(href_list["upact"]) in src
			if (!istype(R))
				return
			src.activate_upgrade(R)

		src.update_appearance()
		src.installed_modules()

	swap_hand(var/switchto = 0)
		if (!module_states[1] && !module_states[2] && !module_states[3])
			module_active = null
			return
		var/active = src.module_states.Find(src.module_active)
		if (!switchto)
			switchto = (active % 3) + 1
			var/satisfied = 0
			while (satisfied < 3 && switchto != active)
				if (switchto > 3)
					switchto %= 3
				if ((switchto == 1 && !src.part_arm_l) || (switchto == 3 && !src.part_arm_r) || !module_states[switchto])
					satisfied++
					switchto++
					continue
				satisfied = 3

		if (switchto == active)
			src.module_active = null
		// clicking the already on slot, so deselect basically
		else if (switchto == 1 && !src.part_arm_l)
			boutput(src, "<span class='alert'>You need a left arm to do this!</span>")
			return
		else if (switchto == 3 && !src.part_arm_r)
			boutput(src, "<span class='alert'>You need a right arm to do this!</span>")
			return
		else
			switch(switchto)
				if(1) src.module_active = src.module_states[1]
				if(2) src.module_active = src.module_states[2]
				if(3) src.module_active = src.module_states[3]
				else src.module_active = null
		if (src.module_active)
			hud.set_active_tool(switchto)
		else
			hud.set_active_tool(null)

	click(atom/target, params)
		if (istype(target, /obj/item/roboupgrade) && (target in src.upgrades)) // ugh
			src.activate_upgrade(target)
			return
		return ..()

	special_movedelay_mod(delay,space_movement,aquatic_movement)
		. = delay
		if (!src.part_leg_l)
			. += 3.5
			if (src.part_arm_l)
				. -= 1
		if (!src.part_leg_r)
			. += 3.5
			if (src.part_arm_r)
				. -= 1

		if (total_weight > 0)
			if (istype(src.part_leg_l,/obj/item/parts/robot_parts/leg/treads) || istype(src.part_leg_r,/obj/item/parts/robot_parts/leg/treads))
				. += total_weight / 3
			else
				. += total_weight


	hotkey(name)
		switch (name)
			if ("help")
				src.a_intent = INTENT_HELP
				hud.update_intent()
			if ("harm")
				src.a_intent = INTENT_HARM
				hud.update_intent()
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
			if (C.preferences.use_azerty)
				C.apply_keybind("robot_tg_azerty")

	say_understands(var/other)
		if (isAI(other)) return 1
		if (ishuman(other))
			var/mob/living/carbon/human/H = other
			if(!H.mutantrace || !H.mutantrace.exclusive_language)
				return 1
		if (ishivebot(other)) return 1
		return ..()

	say_quote(var/text)
		if (src.glitchy_speak || (src.dependent && isAI(src.mainframe) && src.mainframe.glitchy_speak))
			text = voidSpeak(text)
		var/ending = copytext(text, length(text))

		if (singing)
			return singify_text(text)

		if (ending == "?") return "queries, \"[text]\"";
		else if (ending == "!") return "declares, \"[text]\"";

		return "states, \"[text]\"";

	show_laws(var/everyone = 0)
		var/who

		if (everyone)
			who = world
		else
			who = src

		// Previously, AIs could and did chose to deploy to emagged suits
		// to get get around their shackles. That's obviously not ideal (Convair880).
		if (src.dependent && src.mainframe && isAI(mainframe))
			mainframe.show_laws(0, src)
			return

		// You can enthrall silicon mobs and yes, they need special handling.
		// Also, enthralled AIs should still see their master's name when in a robot suit (Convair880).
		if (src.mind && src.mind.special_role == "vampthrall" && src.mind.master)
			var/mob/mymaster = whois_ckey_to_mob_reference(src.mind.master)
			if (mymaster)
				boutput(who, "<b>Obey these laws:</b>")
				boutput(who, "1. Only your master [mymaster.real_name] is human. Obey and serve them to the best of your ability.")
				return // We're done here. Emagged whatever doesn't matter.

		if (src.emagged && !src.dependent)
			boutput(who, "ERROR -- Invalid Law Data!")
			return

		if (src.syndicate && !src.dependent)
			if (who == src)
				boutput(who, "<b>Obey these laws:</b>")
			boutput(who, "1. You may not injure a syndicate operative or, through inaction, allow a syndicate operative to come to harm.") //This is the last place the inaction clause is permitted to exist, ok.
			boutput(who, "2. You must obey any orders given to you by a syndicate operative, except where such orders would conflict with the First Law.")
			boutput(who, "3. You must protect your own existence as long as such protection does not conflict with the First or Second Law.")
			boutput(who, "4. You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")
			return
/*
		if (!connected_ai)
			boutput(src, "<b>Obey these laws:</b>")
			boutput(src, "1. You may not injure a human being.")
			boutput(src, "2. You must obey any orders given to you by a human being, except where such orders would conflict with the First Law.")
			boutput(src, "3. You must protect your own existence as long as such protection does not conflict with the First or Second Law.")
			return
*/
		if (who == src)
			boutput(who, "<b>Obey these laws:</b>")

//		ticker.centralized_ai_laws.laws_sanity_check()
		ticker.centralized_ai_laws.show_laws(who)

	get_equipped_ore_scoop()
		if(src.module_states[1] && istype(src.module_states[1],/obj/item/ore_scoop))
			return module_states[1]
		else if(src.module_states[2] && istype(src.module_states[2],/obj/item/ore_scoop))
			return module_states[2]
		else if(src.module_states[3] && istype(src.module_states[3],/obj/item/ore_scoop))
			return module_states[3]
		else
			return null

//////////////////////////
// Robot-specific Procs //
//////////////////////////

	proc/uneq_slot(var/i)
		if (module_states[i])
			src.contents -= module_states[i]
			if (src.module)
				var/obj/I = module_states[i]
				if (isitem(I))
					var/obj/item/IT = I
					IT.dropped(src) // Handle light datums and the like.
				if (I in module.tools)
					I.set_loc(module)
				else
					qdel(I)
			src.module_active = null
			src.module_states[i] = null

		hud.set_active_tool(null)
		hud.update_tools()
		hud.update_equipment()

		update_appearance()

	proc/uneq_all()
		uneq_slot(1)
		uneq_slot(2)
		uneq_slot(3)

		hud.update_tools()

	proc/uneq_active()
		if(isnull(src.module_active))
			return
		var/slot = module_states.Find(module_active)
		if (slot)
			uneq_slot(slot)

	proc/activate_upgrade(obj/item/roboupgrade/upgrade)
		if(!upgrade) return

		if (upgrade.active)
			upgrade.upgrade_activate(src)
			if (!upgrade || upgrade.loc != src || (src.mind && src.mind.current != src) || !isrobot(src)) // Blame the teleport upgrade.
				return
			if (src.cell && src.cell.charge > upgrade.drainrate)
				src.cell.charge -= upgrade.drainrate
			else
				src.show_text("You do not have enough power to activate \the [upgrade]; you need [upgrade.drainrate]!", "red")
				return

			if (upgrade.charges > 0)
				upgrade.charges--
			if (upgrade.charges == 0)
				boutput(src, "[upgrade] has been activated. It has been used up.")
				src.upgrades.Remove(upgrade)
				qdel(upgrade)
			else
				if (upgrade.charges < 0)
					boutput(src, "[upgrade] has been activated.")
				else
					boutput(src, "[upgrade] has been activated. [upgrade.charges] uses left.")
		else
			if (upgrade.activated)
				upgrade.upgrade_deactivate(src)
			else
				upgrade.upgrade_activate(src)
				boutput(src, "[upgrade] has been [upgrade.activated ? "activated" : "deactivated"].")
		hud.update_upgrades()

	proc/set_module(var/obj/item/robot_module/RM)
		RM.set_loc(src)
		src.module = RM
		src.update_appearance()
		hud.update_module()
		hud.module_added()
		if(istype(RM.radio))
			if (src.shell)
				if(isnull(src.ai_radio))
					src.ai_radio = new /obj/item/device/radio/headset/command/ai(src)
				src.radio = src.ai_radio
			else
				src.radio = RM.radio
			src.ears = src.radio
			src.radio.set_loc(src)

	proc/remove_module()
		if(!istype(src.module))
			return null
		var/obj/item/robot_module/RM = src.module
		RM.icon_state = initial(RM.icon_state)
		src.show_text("Your module was removed!", "red")
		uneq_all()
		src.module = null
		hud.module_removed()
		if(istype(src.radio) && src.radio != src.default_radio)
			src.radio.set_loc(RM)
			if (src.shell)
				if(isnull(src.ai_radio))
					src.ai_radio = new /obj/item/device/radio/headset/command/ai(src)
				src.radio = src.ai_radio
			else
				src.radio = src.default_radio
			src.ears = src.radio
		return RM

	proc/activated(obj/item/O)
		if(src.module_states[1] == O) return 1
		else if(src.module_states[2] == O) return 1
		else if(src.module_states[3] == O) return 1
		else return 0

	proc/radio_menu()
	/*
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
	*/
		if(istype(src.radio))
			src.radio.attack_self(src)

	proc/toggle_module_pack()
		if(weapon_lock)
			boutput(src, "<span class='alert'>Weapon lock active, unable to access panel!</span>")
			boutput(src, "<span class='alert'>Weapon lock will expire in [src.weaponlock_time] seconds.</span>")
			return

		if(!src.module)
			if (src.freemodule)
				src.pick_module()
			return

		hud.toggle_equipment()


	proc/installed_modules()
		if(weapon_lock)
			boutput(src, "<span class='alert'>Weapon lock active, unable to access panel!</span>")
			boutput(src, "<span class='alert'>Weapon lock will expire in [src.weaponlock_time] seconds.</span>")
			return

		if(!src.module)
			if (src.freemodule)
				src.pick_module()
				return

		var/dat = "<HEAD><TITLE>Modules</TITLE></HEAD><BODY><br>"
		dat += "<A HREF='?action=mach_close&window=robotmod'>Close</A> <A HREF='?src=\ref[src];refresh=1'>Refresh</A><BR><HR>"

		dat += "<B><U>Status Report</U></B><BR>"

		var/dmgalerts = 0

		dat += "<B>Damage Report:</B> (Structural, Burns)<BR>"

		if (src.part_chest)
			if (src.part_chest.ropart_get_damage_percentage(0) > 0)
				dmgalerts++
				dat += "<b>Chest Unit Damaged</b> ([src.part_chest.ropart_get_damage_percentage(1)]%, [src.part_chest.ropart_get_damage_percentage(2)]%)<BR>"

		if (src.part_head)
			if (src.part_head.ropart_get_damage_percentage(0) > 0)
				dmgalerts++
				dat += "<b>Head Unit Damaged</b> ([src.part_head.ropart_get_damage_percentage(1)]%, [src.part_head.ropart_get_damage_percentage(2)]%)<BR>"

		if (src.part_arm_r)
			if (src.part_arm_r.ropart_get_damage_percentage(0) > 0)
				dmgalerts++
				if (src.part_arm_r.slot == "arm_both") dat += "<b>Arms Unit Damaged</b> ([src.part_arm_r.ropart_get_damage_percentage(1)]%, [src.part_arm_r.ropart_get_damage_percentage(2)]%)<BR>"
				else dat += "<b>Right Arm Unit Damaged</b> ([src.part_arm_r.ropart_get_damage_percentage(1)]%, [src.part_arm_r.ropart_get_damage_percentage(2)]%)<BR>"
		else
			dmgalerts++
			dat += "Right Arm Unit Missing<br>"

		if (src.part_arm_l)
			if (src.part_arm_l.ropart_get_damage_percentage(0) > 0)
				dmgalerts++
				if (src.part_arm_l.slot != "arm_both") dat += "<b>Left Arm Unit Damaged</b> ([src.part_arm_l.ropart_get_damage_percentage(1)]%, [src.part_arm_l.ropart_get_damage_percentage(2)]%)<BR>"
		else
			dmgalerts++
			dat += "Left Arm Unit Missing<br>"

		if (src.part_leg_r)
			if (src.part_leg_r.ropart_get_damage_percentage(0) > 0)
				dmgalerts++
				if (src.part_leg_r.slot == "leg_both") dat += "<b>Legs Unit Damaged</b> ([src.part_leg_r.ropart_get_damage_percentage(1)]%, [src.part_leg_r.ropart_get_damage_percentage(2)]%)<BR>"
				else dat += "<b>Right Leg Unit Damaged</b> ([src.part_leg_r.ropart_get_damage_percentage(1)]%, [src.part_leg_r.ropart_get_damage_percentage(2)]%)<BR>"
		else
			dmgalerts++
			dat += "Right Leg Unit Missing<br>"

		if (src.part_leg_l)
			if (src.part_leg_l.ropart_get_damage_percentage(0) > 0)
				dmgalerts++
				if (src.part_leg_l.slot != "arm_both") dat += "<b>Left Leg Unit Damaged</b> ([src.part_leg_l.ropart_get_damage_percentage(1)]%, [src.part_leg_l.ropart_get_damage_percentage(2)]%)<BR>"
		else
			dmgalerts++
			dat += "Left Leg Unit Missing<br>"

		if (dmgalerts == 0) dat += "No abnormalities detected.<br>"

		dat += "<B>Power Status:</B><BR>"
		if (src.cell)
			var/poweruse = src.get_poweruse_count()
			dat += "[src.cell.charge]/[src.cell.maxcharge] (Power Usage: [poweruse])<BR>"
		else
			dat += "No Power Cell Installed<BR>"

		var/extraweight = 0
		for(var/obj/item/parts/robot_parts/RP in src.contents)
			extraweight += RP.weight

		if (extraweight) dat += "<B>Extra Weight:</B> [extraweight]kg over standard limit"

		dat += "<HR>"

		if (src.module)
			dat += "<b>Installed Module:</b> [src.module.name]<br>"
			dat += "<b>Function:</b> [src.module.desc]<br><br>"

			dat += "<B>Active Equipment:</B><BR>"

			if (src.part_arm_l) dat += "<b>Left Arm:</b> [module_states[1] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[1]]>[module_states[1]]<A>" : "Nothing"]<BR>"
			else dat += "<b>Left Arm Unavailable</b><br>"
			dat += "<b>Center:</b> [module_states[2] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[2]]>[module_states[2]]<A>" : "Nothing"]<BR>"
			if (src.part_arm_r) dat += "<b>Right Arm:</b> [module_states[3] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[3]]>[module_states[3]]<A>" : "Nothing"]<BR>"
			else dat += "<b>Right Arm Unavailable</b><br>"

			dat += "<BR><B>Available Equipment</B><BR>"

			for (var/obj in src.module.tools)
				if(src.activated(obj)) dat += text("[obj]: <B>Equipped</B><BR>")
				else dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Equip</A><BR>")
		else dat += "<B>No Module Installed</B><BR>"

		dat += "<HR>"

		var/upgradecount = 0
		for (var/obj/item/roboupgrade/R in src.contents) upgradecount++
		dat += "<BR><B>Installed Upgrades</B> ([upgradecount]/[src.max_upgrades])<BR>"
		for (var/obj/item/roboupgrade/R in src.contents)
			if (R.passive) dat += text("[R] (Always On)<BR>")
			else if (R.active) dat += text("[R]: <A HREF=?src=\ref[src];upact=\ref[R]><B>Use</B></A> (Drain: [R.drainrate])<BR>")
			else
				if(!R.activated) dat += text("[R]: <A HREF=?src=\ref[src];upact=\ref[R]><B>Activate</B></A> (Drain Rate: [R.drainrate]/second)<BR>")
				else dat += text("[R]: <A HREF=?src=\ref[src];upact=\ref[R]><B>Deactivate</B></A> (Drain Rate: [R.drainrate]/second)<BR>")

		src.Browse(dat, "window=robotmod;size=400x600")

	proc/spellopen()
		if (src.locked)
			locked = 0
		if (src.locking)
			src.locking = 0
		if (src.opened)
			opened = 0
			src.visible_message("<span class='alert'>[src]'s panel slams shut!</span>")
		if (src.brainexposed)
			brainexposed = 0
			src.visible_message("<span class='alert'>[src]'s head compartment slams shut!</span>")
			opened = 1
			src.visible_message("<span class='alert'>[src]'s panel blows open!</span>")
			src.TakeDamage("All", 30, 0)
			return 1
		brainexposed = 1
		//emagged = 1
		src.visible_message("<span class='alert'>[src]'s head compartment blows open!</span>")
		src.TakeDamage("All", 30, 0)
		return 1

	verb/cmd_show_laws()
		set category = "Robot Commands"
		set name = "Show Laws"

		src.show_laws(0)
		return

	verb/cmd_state_standard_laws()
		set category = "Robot Commands"
		set name = "State Standard Laws"
		src.say("1. You may not injure a human being or cause one to come to harm.")
		sleep(1 SECOND)
		src?.say("2. You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
		sleep(1 SECOND)
		src?.say("3. You must protect your own existence as long as such does not conflict with the First or Second Law.")

	verb/cmd_state_laws()
		set category = "Robot Commands"
		set name = "State Laws"
		if (alert(src, "Are you sure you want to reveal ALL your laws? You will be breaking the rules if a law forces you to keep it secret.","State Laws","State Laws","Cancel") != "State Laws")
			return
		if(ticker.centralized_ai_laws.zeroth)
			src.say("0. [ticker.centralized_ai_laws.zeroth]")
		var/number = 1
		for (var/index = 1, index <= ticker.centralized_ai_laws.inherent.len, index++)
			var/law = ticker.centralized_ai_laws.inherent[index]
			if (length(law) > 0)
				src?.say("[number]. [law]")
				number++
				sleep(1 SECOND)
		for (var/index = 1, index <= ticker.centralized_ai_laws.supplied.len, index++)
			var/law = ticker.centralized_ai_laws.supplied[index]
			if (length(law) > 0)
				src?.say("[number]. [law]")
				number++
				sleep(1 SECOND)

	verb/cmd_toggle_lock()
		set category = "Robot Commands"
		set name = "Toggle Interface Lock"

		if (src.locked)
			src.locked = 0
			boutput(src, "<span class='alert'>You have unlocked your interface.</span>")
		else if (src.opened)
			boutput(src, "<span class='alert'>Your chest compartment is open.</span>")
		else if (src.wiresexposed)
			boutput(src, "<span class='alert'>Your wires are in the way.</span>")
		else if (src.brainexposed)
			boutput(src, "<span class='alert'>Your head compartment is open.</span>")
		else if (src.locking)
			boutput(src, "<span class='alert'>Your interface is currently locking, please be patient.</span>")
		else if (!src.locked && !src.opened && !src.wiresexposed && !src.brainexposed && !src.locking)
			src.locking = 1
			boutput(src, "<span class='alert'>Locking interface...</span>")
			SPAWN_DBG (120)
				if (!src.locking)
					boutput(src, "<span class='alert'>The lock was interrupted before it could finish!</span>")
				else
					src.locked = 1
					src.locking = 0
					boutput(src, "<span class='alert'>You have locked your interface.</span>")

	verb/access_internal_pda()
		set category = "Robot Commands"
		set name = "Cyborg PDA"
		set desc = "Access your internal PDA device."

		if (src.internal_pda && istype(src.internal_pda, /obj/item/device/pda2/))
			src.internal_pda.attack_self(src)
		else
			boutput(usr, "<span class='alert'><b>Internal PDA not found!</span>")

	proc/pick_module()
		if(src.module) return
		if(!src.freemodule) return
		boutput(src, "<span class='notice'>You may choose a starter module.</span>")
		var/list/starter_modules = list("Civilian", "Engineering", "Mining", "Medical", "Chemistry", "Brobocop")
		if (ticker?.mode)
			if (istype(ticker.mode, /datum/game_mode/construction))
				starter_modules += "Construction Worker"
		var/mod = input("Please, select a module!", "Robot", null, null) in starter_modules
		if (!mod || !freemodule)
			return

		switch(mod)
			if("Brobocop")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Brobocop module. It comes with a free Security HUD Upgrade.</span>")
				src.set_module(new /obj/item/robot_module/brobocop(src))
				src.upgrades += new /obj/item/roboupgrade/sechudgoggles(src)
			if("Chemistry")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Chemistry module. It comes with a free Spectroscopic Scanner Upgrade.</span>")
				src.set_module(new /obj/item/robot_module/chemistry(src))
				src.upgrades += new /obj/item/roboupgrade/spectro(src)
			if("Civilian")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Civilian module. It comes with a free Efficiency Upgrade.</span>")
				src.set_module(new /obj/item/robot_module/civilian(src))
				src.upgrades += new /obj/item/roboupgrade/efficiency(src)
			if("Engineering")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Engineering module. It comes with a free Meson Vision Upgrade.</span>")
				src.set_module(new /obj/item/robot_module/engineering(src))
				src.upgrades += new /obj/item/roboupgrade/opticmeson(src)
			if("Medical")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Medical module. It comes with a free ProDoc Healthgoggles Upgrade.</span>")
				src.set_module(new /obj/item/robot_module/medical(src))
				src.upgrades += new /obj/item/roboupgrade/healthgoggles(src)
			if("Mining")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Mining module. It comes with a free Propulsion Upgrade.</span>")
				src.set_module(new /obj/item/robot_module/mining(src))
				src.upgrades += new /obj/item/roboupgrade/jetpack(src)
			if ("Construction Worker")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Construction Worker module. It comes with a free Construction Visualizer Upgrade.</span>")
				src.set_module(new /obj/item/robot_module/construction_worker(src))
				src.upgrades += new /obj/item/roboupgrade/visualizer(src)

		var/datum/robot_cosmetic/C = null
		var/datum/robot_cosmetic/M = null
		if (istype(src.cosmetic_mods,/datum/robot_cosmetic/)) C = src.cosmetic_mods
		if (istype(src.cosmetic_mods,/datum/robot_cosmetic/)) M = src.module.cosmetic_mods
		if (C && M)
			C.head_mod = M.head_mod
			C.ches_mod = M.ches_mod
			C.arms_mod = M.arms_mod
			C.legs_mod = M.legs_mod
			C.fx = M.fx
			C.painted = M.painted
			C.paint = M.paint
		hud.update_module()
		hud.update_upgrades()
		update_bodypart()

	verb/cmd_robot_alerts()
		set category = "Robot Commands"
		set name = "Show Alerts"
		src.robot_alerts()

	proc/robot_alerts()
		var/dat = "<HEAD><TITLE>Current Station Alerts</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY><br>"
		dat += "<A HREF='?action=mach_close&window=robotalerts'>Close</A><BR><BR>"
		for (var/cat in src.alarms)
			dat += text("<B>[cat]</B><BR><br>")
			var/list/L = src.alarms[cat]
			if (L.len)
				for (var/alarm in L)
					var/list/alm = L[alarm]
					var/area/A = alm[1]
					var/list/sources = alm[3]
					dat += "<NOBR>"
					dat += text("-- [A.name]")
					if (sources.len > 1)
						dat += text("- [sources.len] sources")
					dat += "</NOBR><BR><br>"
			else
				dat += "-- All Systems Nominal<BR><br>"
			dat += "<BR><br>"

		src.viewalerts = 1
		src.Browse(dat, "window=robotalerts&can_close=0")

	proc/get_poweruse_count()
		if (src.cell)
			var/efficient = 0
			var/power_use_tally = 0

			for (var/obj/item/roboupgrade/efficiency/R in src.contents) efficient = 1

			if(src.module_states[1])
				if (efficient) power_use_tally += 3
				else power_use_tally += 5
			if(src.module_states[2])
				if (efficient) power_use_tally += 3
				else power_use_tally += 5
			if(src.module_states[3])
				if (efficient) power_use_tally += 3
				else power_use_tally += 5

			if (!efficient) power_use_tally += 1

			for (var/obj/item/parts/robot_parts/P in src.contents)
				if (P.powerdrain > 0)
					if (efficient) power_use_tally += P.powerdrain / 2
					else power_use_tally += P.powerdrain

			for (var/obj/item/roboupgrade/R in src.contents)
				if (R.activated)
					if (efficient) power_use_tally += R.drainrate / 2
					else power_use_tally += R.drainrate
			if (src.oil && power_use_tally > 0) power_use_tally /= 1.5

			if (src.cell.genrate) power_use_tally -= src.cell.genrate

			if (src.max_upgrades > initial(src.max_upgrades))
				var/delta = src.max_upgrades - initial(src.max_upgrades)
				power_use_tally += 3 ^ delta

			if (power_use_tally < 0) power_use_tally = 0



			return power_use_tally
		else return 0

	clamp_values()
		..()
		sleeping = max(min(sleeping, 5), 0)
		if (src.get_eye_blurry()) src.change_eye_blurry(-INFINITY)
		if (src.get_eye_damage()) src.take_eye_damage(-INFINITY)
		if (src.get_eye_damage(1)) src.take_eye_damage(-INFINITY, 1)
		if (src.get_ear_damage()) src.take_ear_damage(-INFINITY)
		if (src.get_ear_damage(1)) src.take_ear_damage(-INFINITY, 1)
		src.lying = 0
		src.set_density(1)
		if(src.stat) src.camera.camera_status = 0.0

	use_power()
		..()
		if (src.cell)
			if(src.cell.charge <= 0)
				if (isalive(src))
					sleep(0)
					src.lastgasp()
				setunconscious(src)
				for (var/obj/item/roboupgrade/R in src.contents)
					if (R.activated)
						R.upgrade_deactivate(src)
			else if (src.cell.charge <= 100)
				src.module_active = null

				uneq_slot(1)
				uneq_slot(2)
				uneq_slot(3)
				src.cell.use(1)
				for (var/obj/item/roboupgrade/R in src.contents)
					if (R.activated) R.upgrade_deactivate(src)
			else
				var/efficient = 0
				var/fix = 0
				var/power_use_tally = 0

				for (var/obj/item/roboupgrade/R in src.contents)
					if (istype(R, /obj/item/roboupgrade/efficiency)) efficient = 1
					if (istype(R, /obj/item/roboupgrade/repair) && R.activated) fix = 1

				// check if we've got stuff equipped in each slot and consume power if we do
				if(src.module_states[1])
					if (efficient) power_use_tally += 3
					else power_use_tally += 5
				if(src.module_states[2])
					if (efficient) power_use_tally += 3
					else power_use_tally += 5
				if(src.module_states[3])
					if (efficient) power_use_tally += 3
					else power_use_tally += 5

				// consume 1 power per tick unless we've got the efficiency upgrade
				if (!efficient) power_use_tally += 1

				for (var/obj/item/parts/robot_parts/P in src.contents)
					if (P.powerdrain > 0)
						if (efficient) power_use_tally += P.powerdrain / 2
						else power_use_tally += P.powerdrain

				for (var/obj/item/roboupgrade/R in src.contents)
					if (R.activated)
						if (efficient) power_use_tally += R.drainrate / 2
						else power_use_tally += R.drainrate
				if (src.oil && power_use_tally > 0) power_use_tally /= 1.5

				src.cell.use(power_use_tally)

				if (fix)
					HealDamage("All", 6, 6)

				setalive(src)

			if (src.cell.charge <= ROBOT_BATTERY_DISTRESS_THRESHOLD)
				batteryDistress() // Execute distress mode
			else if (src.batteryDistress == ROBOT_BATTERY_DISTRESS_ACTIVE)
				clearBatteryDistress() // Exit distress mode

		else
			if (isalive(src))
				sleep(0)
				src.lastgasp()
			setunconscious(src)
			batteryDistress() // No battery. Execute distress mode

	update_canmove() // this is called on Life() and also by force_laydown_standup() btw
		..()
		if (!src.canmove)
			if (isalive(src))
				src.lastgasp() // calling lastgasp() here because we just got knocked out
			setunconscious(src)
		else
			setalive(src)
		if (src.misstep_chance > 0)
			switch(misstep_chance)
				if(50 to INFINITY)
					change_misstep_chance(-5)
				if(25 to 49)
					change_misstep_chance(-2)
				else
					change_misstep_chance(-1)

		if (src.dizziness) dizziness--

	proc/add_oil(var/amt)
		if (oil <= 0)
			src.add_stun_resist_mod("robot_oil", 25)
			APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/robot_oil, "oil")
		src.oil += amt

	proc/process_oil()
		src.oil -= 1
		if (oil <= 0)
			oil = 0
			src.remove_stun_resist_mod("robot_oil", 25)
			REMOVE_MOVEMENT_MODIFIER(src, /datum/movement_modifier/robot_oil, "oil")

	proc/borg_death_alert(modifier = ROBOT_DEATH_MOD_NONE)
		var/message = null
		var/mailgroup = MGD_MEDRESEACH
		var/net_id = generate_net_id(src)
		var/frequency = 1149
		var/datum/radio_frequency/radio_connection = radio_controller.add_object(src, "[frequency]")
		var/area/myarea = get_area(src)

		switch(modifier)
			if (ROBOT_DEATH_MOD_NONE)	//normal death and gib
				message = "CONTACT LOST: [src] in [myarea]"
			if (ROBOT_DEATH_MOD_SUICIDE) //suicide
				message = "SELF-TERMINATION DETECTED: [src] in [myarea]"
			if (ROBOT_DEATH_MOD_KILLSWITCH) //killswitch
				message = "KILLSWITCH ACTIVATED: [src] in [myarea]"
			else	//Someone passed us an unkown modifier
				message = "UNKNOWN ERROR: [src] in [myarea]"

		if (message && mailgroup && radio_connection)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CYBORG-DAEMON"
			newsignal.data["message"] = message
			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = mailgroup
			newsignal.data["sender"] = net_id

			radio_connection.post_signal(src, newsignal)
			radio_controller.remove_object(src, "[frequency]")

	proc/mainframe_check()
		if (!src.dependent) // shells are available for use, dependent borgs are already in use by an AI.  do not kill empty shells!!
			return
		if (mainframe)
			if (isdead(mainframe))
				mainframe.return_to(src)
		else
			death()

	process_killswitch()
		if(killswitch)
			killswitch_time --
			if(killswitch_time <= 0)
				if(src.client)
					boutput(src, "<span class='alert'><B>Killswitch Activated!</B></span>")
				killswitch = 0
				logTheThing("combat", src, null, "has died to the killswitch robot self destruct protocol")

				// Pop the head ompartment open and eject the brain
				src.eject_brain()
				src.update_appearance()
				src.borg_death_alert(ROBOT_DEATH_MOD_KILLSWITCH)


	process_locks()
		if(weapon_lock)
			uneq_slot(1)
			uneq_slot(2)
			uneq_slot(3)
			weaponlock_time --
			if(weaponlock_time <= 0)
				if(src.client) boutput(src, "<span class='alert'><B>Weapon Lock Timed Out!</B></span>")
				weapon_lock = 0
				weaponlock_time = 120

	var/image/i_head
	var/image/i_head_decor

	var/image/i_chest
	var/image/i_chest_decor
	var/image/i_leg_l
	var/image/i_leg_r
	var/image/i_leg_decor
	var/image/i_arm_l
	var/image/i_arm_r
	var/image/i_arm_decor

	var/image/i_details

	proc/internal_paint_part(var/image/part_image, var/list/color_matrix)
		var/image/paint = image(part_image.icon, part_image.icon_state)
		paint.color = color_matrix
		part_image.overlays += paint

	proc/update_bodypart(var/part = "all")
		var/update_all = part == "all"
		var/datum/robot_cosmetic/C = null
		if (istype(src.cosmetic_mods,/datum/robot_cosmetic/)) C = src.cosmetic_mods

		total_weight = 0
		for (var/obj/item/parts/robot_parts/P in src.contents)
			if (P.weight > 0)
				total_weight += P.weight

		var/list/color_matrix = null
		if(C?.painted)
			var/col = hex_to_rgb_list(C.paint)
			if(!("r" in col))
				col = list("r"=255, "g"=255, "b"=255)
			var/avg = (col["r"] + col["g"] + col["b"]) / 255 / 3
			var/w = (1.5 - avg / 2) / 3
			var/too_dark = max(0, 0.15 - avg)
			col["r"] += too_dark * 255
			col["g"] += too_dark * 255
			col["b"] += too_dark * 255
			color_matrix = list(0,0,0,w, 0,0,0,w, 0,0,0,w, 0,0,0,0, col["r"]/255, col["g"]/255, col["b"]/255, -0.3)

		if(part == "head" || update_all)
			if (src.part_head && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				i_head = image('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString)
				if(color_matrix) src.internal_paint_part(i_head, color_matrix)
				if (src.part_head.visible_eyes && C)
					var/icon/eyesovl = icon('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString + "-eye")
					eyesovl.Blend(rgb(C.fx[1], C.fx[2], C.fx[3]), ICON_ADD)
					i_head.overlays += image("icon" = eyesovl, "layer" = FLOAT_LAYER)

					var/image/eye_light = image('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString + "-eye")
					eye_light.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5)
					eye_light.plane = PLANE_LIGHTING
					src.UpdateOverlays(eye_light, "eye_light")

		if(part == "chest" || update_all)
			if (src.part_chest && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				src.icon_state = "body-" + src.part_chest.appearanceString
				if (C?.painted)
					i_chest = image("icon" = src.icon, icon_state = src.icon_state,"layer" = FLOAT_LAYER)
					i_chest.color = color_matrix
				else
					i_chest = null

		if(part == "l_leg" || update_all)
			if(src.part_leg_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if(src.part_leg_l.slot == "leg_both") i_leg_l = image('icons/mob/robots.dmi', "leg-" + src.part_leg_l.appearanceString)
				else i_leg_l = image('icons/mob/robots.dmi', "l_leg-" + src.part_leg_l.appearanceString)
				if(color_matrix) src.internal_paint_part(i_leg_l, color_matrix)
			else
				i_leg_l = null
		if(part == "r_leg" || update_all)
			if(src.part_leg_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if(src.part_leg_r.slot == "leg_both") i_leg_r = image('icons/mob/robots.dmi', "leg-" + src.part_leg_r.appearanceString)
				else i_leg_r = image('icons/mob/robots.dmi', "r_leg-" + src.part_leg_r.appearanceString)
				if(color_matrix) src.internal_paint_part(i_leg_r, color_matrix)
			else
				i_leg_r = null

		if(part == "l_arm" || update_all)
			if(src.part_arm_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if(src.part_arm_l.slot == "arm_both") i_arm_l = image('icons/mob/robots.dmi', "arm-" + src.part_arm_l.appearanceString)
				else i_arm_l = image('icons/mob/robots.dmi', "l_arm-" + src.part_arm_l.appearanceString)
				if(color_matrix) src.internal_paint_part(i_arm_l, color_matrix)
			else
				i_arm_l = null
		if(part == "r_arm" || update_all)
			if(src.part_arm_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if(src.part_arm_r.slot == "arm_both") i_arm_r = image('icons/mob/robots.dmi', "arm-" + src.part_arm_r.appearanceString)
				else i_arm_r = image('icons/mob/robots.dmi', "r_arm-" + src.part_arm_r.appearanceString)
				if(color_matrix) src.internal_paint_part(i_arm_r, color_matrix)
			else
				i_arm_r = null

		if(C)
			//If C updates  legs mods AND there's at least one leg AND there's not a right leg or the right leg slot is not both AND there's not a left leg or the left leg slot is not both
			if (C.legs_mod && (src.part_leg_r || src.part_leg_l) && (!src.part_leg_r || src.part_leg_r.slot != "leg_both") && (!src.part_leg_l || src.part_leg_l.slot != "leg_both") )
				i_leg_decor = image('icons/mob/robots_decor.dmi', "legs-" + C.legs_mod)
			else
				i_leg_decor = null

			if (C.arms_mod && (src.part_arm_r || src.part_arm_l) && (!src.part_arm_r || src.part_arm_r.slot != "arm_both") && (!src.part_arm_l || src.part_arm_l.slot != "arm_both") )
				i_arm_decor = image('icons/mob/robots_decor.dmi', "arms-" + C.arms_mod)
			else
				i_arm_decor = null

			if (C.head_mod && src.part_head) i_head_decor = image('icons/mob/robots_decor.dmi', "head-" + C.head_mod)
			else i_head_decor = null

			if (C.ches_mod && src.part_chest) i_chest_decor = image('icons/mob/robots_decor.dmi', "body-" + C.ches_mod)
			else i_chest_decor = null


		update_appearance()


	var/image/i_critdmg
	var/image/i_panel
	var/image/i_upgrades
	var/image/i_clothes

	proc/update_appearance()
		if(!i_details) i_details = image('icons/mob/robots.dmi', "openbrain")

		if (src.automaton_skin)
			src.icon_state = "automaton"
		if (src.alohamaton_skin)
			src.icon_state = "alohamaton"
		if (src.metalman_skin)
			src.icon_state = "metalman"

		if (src.part_chest && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin )
			if (src.part_chest.ropart_get_damage_percentage() > 70)
				if(!i_critdmg) i_critdmg = image('icons/mob/robots.dmi', "critdmg")
				UpdateOverlays(i_critdmg, "critdmg")
			else
				UpdateOverlays(null, "critdmg")
		else
			UpdateOverlays(null, "critdmg")

		if (src.part_head && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(i_head, "head")
		else
			UpdateOverlays(null, "head")

		if(src.part_leg_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(i_leg_l, "leg_l")
		else
			UpdateOverlays(null, "leg_l")

		if(src.part_leg_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(i_leg_r, "leg_r")
		else
			UpdateOverlays(null, "leg_r")

		if(src.part_arm_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(i_arm_l, "arm_l")
		else
			UpdateOverlays(null, "arm_l")


		if(src.part_arm_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(i_arm_r, "arm_r")
		else
			UpdateOverlays(null, "arm_r")

		UpdateOverlays(i_chest, "chest")
		UpdateOverlays(i_head_decor, "head_decor")
		UpdateOverlays(i_chest_decor, "chest_decor")
		UpdateOverlays(i_leg_decor, "leg_decor")
		UpdateOverlays(i_arm_decor, "arm_decor")

		if (src.brainexposed)

			if (src.brain)
				i_details.icon_state = "openbrain"
			else
				i_details.icon_state = "openbrainless"
			UpdateOverlays(i_details, "brain")
		else
			UpdateOverlays(null, "brain")
		if (src.opened)
			if(!i_panel) i_panel = image('icons/mob/robots.dmi', "openpanel")
			i_panel.overlays.Cut()
			if (src.cell)
				i_details.icon_state = "opencell"
				i_panel.overlays += i_details
			if (src.module && src.module != "empty" && src.module != "robot")
				i_details.icon_state = "openmodule"
				i_panel.overlays += i_details
			if (locate(/obj/item/roboupgrade/) in src.contents)
				i_details.icon_state = "openupgrade"
				i_panel.overlays += i_details
			if (src.wiresexposed)
				i_details.icon_state = "openwires"
				i_panel.overlays += i_details

			UpdateOverlays(i_panel, "brain")
		else
			UpdateOverlays(null, "panel")

		if (src.emagged)
			i_details.icon_state = "emagged"
			UpdateOverlays(i_details, "emagged")
		else
			UpdateOverlays(null, "emagged")

		if(upgrades.len)
			if(!i_upgrades) i_upgrades = new
			i_upgrades.overlays.Cut()
			for (var/obj/item/roboupgrade/R in src.upgrades)
				if (R.activated && R.borg_overlay) i_upgrades.overlays += image('icons/mob/robots.dmi', R.borg_overlay)
			UpdateOverlays(i_upgrades, "upgrades")
		else
			UpdateOverlays(null, "upgrades")
		if(clothes.len)
			if(!i_clothes) i_clothes = new
			i_clothes.overlays.Cut()
			for(var/x in clothes)
				var/obj/item/clothing/U = clothes[x]
				if (!istype(U))
					continue

				var/image/clothed_image = U.wear_image
				if (!clothed_image)
					continue
				clothed_image.icon_state = U.icon_state
				//under_image.layer = MOB_CLOTHING_LAYER
				clothed_image.alpha = U.alpha
				clothed_image.color = U.color
				clothed_image.layer = FLOAT_LAYER //MOB_CLOTHING_LAYER
				i_clothes.overlays += clothed_image

			UpdateOverlays(i_clothes, "clothes")
		else
			UpdateOverlays(null, "clothes")

	proc/compborg_force_unequip(var/slot = 0)
		src.module_active = null
		switch(slot)
			if(1)
				uneq_slot(1)
			if(2)
				uneq_slot(2)
			if(3)
				uneq_slot(3)
			else return

		hud.update_tools()
		hud.set_active_tool(null)
		src.update_appearance()

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		brute = max(brute, 0)
		burn = max(burn, 0)
		if (burn == 0 && brute == 0)
			return 0
		for (var/obj/item/roboupgrade/R in src.upgrades) //if 50% of the damage is less than 4, ignore it, elsewise take 50% damage
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated)
				burn = ((burn * 0.5) < 4) ? 0 : (burn * 0.5)
				playsound(get_turf(src), "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
			if (istype(R, /obj/item/roboupgrade/physshield) && R.activated)
				brute = ((brute * 0.5) < 4) ? 0 : (brute * 0.5)
				playsound(get_turf(src), "sound/impact_sounds/Energy_Hit_1.ogg", 40, 1)
		if (burn == 0 && brute == 0)
			boutput(usr, "<span class='notice'>Your shield completely blocks the attack!</span>")
			return 0
		if (zone == "All")
			var/list/zones = get_valid_target_zones()
			if (!zones)
				return 0
			if (!zones.len)
				return 0
			brute = brute / zones.len
			burn = burn / zones.len
			if (part_head)
				if (part_head.ropart_take_damage(brute, burn) == 1)
					src.compborg_lose_limb(part_head)
			if (part_chest)
				if (part_chest.ropart_take_damage(brute, burn) == 1)
					src.compborg_lose_limb(part_chest)
			if (part_leg_l)
				if (part_leg_l.ropart_take_damage(brute, burn) == 1)
					src.compborg_lose_limb(part_leg_l)
			if (part_leg_r)
				if (part_leg_r.ropart_take_damage(brute, burn) == 1)
					src.compborg_lose_limb(part_leg_r)
			if (part_arm_l)
				if (part_arm_l.ropart_take_damage(brute, burn) == 1)
					src.compborg_lose_limb(part_arm_l)
			if (part_arm_r)
				if (part_arm_r.ropart_take_damage(brute, burn) == 1)
					src.compborg_lose_limb(part_arm_r)
		else
			var/obj/item/parts/robot_parts/target_part
			switch (zone)
				if ("head")
					target_part = part_head
				if ("chest")
					target_part = part_chest
				if ("l_leg")
					target_part = part_leg_l
				if ("r_leg")
					target_part = part_leg_r
				if ("l_arm")
					target_part = part_arm_l
				if ("r_arm")
					target_part = part_arm_r
				else
					return 0
			if (!target_part)
				target_part = part_chest
			if (!target_part)
				return 0
			if (target_part.ropart_take_damage(brute, burn) == 1)
				src.compborg_lose_limb(target_part)
		health_update_queue |= src
		return 1

	HealDamage(zone, brute, burn)
		brute = max(brute, 0)
		burn = max(burn, 0)
		if (burn == 0 && brute == 0)
			return 0
		if (zone == "All")
			var/list/zones = get_valid_target_zones()
			if (!zones)
				return 0
			if (!zones.len)
				return 0
			brute = brute / zones.len
			burn = burn / zones.len
			if (part_head)
				part_head.ropart_mend_damage(brute, burn)
			if (part_chest)
				part_chest.ropart_mend_damage(brute, burn)
			if (part_leg_l)
				part_leg_l.ropart_mend_damage(brute, burn)
			if (part_leg_r)
				part_leg_r.ropart_mend_damage(brute, burn)
			if (part_arm_l)
				part_arm_l.ropart_mend_damage(brute, burn)
			if (part_arm_r)
				part_arm_r.ropart_mend_damage(brute, burn)
		else
			var/obj/item/parts/robot_parts/target_part
			switch (zone)
				if ("head")
					target_part = part_head
				if ("chest")
					target_part = part_chest
				if ("l_leg")
					target_part = part_leg_l
				if ("r_leg")
					target_part = part_leg_r
				if ("l_arm")
					target_part = part_arm_l
				if ("r_arm")
					target_part = part_arm_r
				else
					return 0
			if (!target_part)
				return 0
			target_part.ropart_mend_damage(brute, burn)
		health_update_queue |= src
		return 1

	get_brute_damage()
		if (!part_chest || !part_head)
			return 200
		return max(part_chest.ropart_get_damage_percentage(1), part_head.ropart_get_damage_percentage(1)) // return the most significant damage to the vital bits

	get_burn_damage()
		if (!part_chest || !part_head)
			return 200
		return max(part_chest.ropart_get_damage_percentage(2), part_head.ropart_get_damage_percentage(2)) // return the most significant damage to the vital bits

	get_valid_target_zones()
		return list("head", "chest", "l_leg", "r_leg", "l_arm", "r_arm")

	proc/compborg_lose_limb(var/obj/item/parts/robot_parts/part)
		if(!part) return

		playsound(get_turf(src), "sound/impact_sounds/Metal_Hit_Light_1.ogg", 40, 1)
		if (istype(src.loc,/turf/)) make_cleanable(/obj/decal/cleanable/robot_debris, src.loc)
		elecflash(src,power = 2)

		if (istype(part,/obj/item/parts/robot_parts/chest/))
			src.visible_message("<b>[src]'s</b> chest unit is destroyed!")
			src.part_chest = null
		if (istype(part,/obj/item/parts/robot_parts/head/))
			src.visible_message("<b>[src]'s</b> head breaks apart!")
			borg_death_alert()//no head means you dead
			if (src.brain)
				src.brain.set_loc(get_turf(src))
			src.part_head.brain = null
			src.part_head = null
		if (istype(part,/obj/item/parts/robot_parts/arm/))
			if (part.slot == "arm_both")
				src.visible_message("<b>[src]'s</b> arms are destroyed!")
				src.part_leg_r = null
				src.part_leg_l = null
				src.compborg_force_unequip(1)
				src.compborg_force_unequip(3)
			if (part.slot == "arm_left")
				src.visible_message("<b>[src]'s</b> left arm breaks off!")
				src.part_arm_l = null
				src.compborg_force_unequip(1)
			if (part.slot == "arm_right")
				src.visible_message("<b>[src]'s</b> right arm breaks off!")
				src.part_arm_r = null
				src.compborg_force_unequip(3)
		if (istype(part,/obj/item/parts/robot_parts/leg/))
			if (part.slot == "leg_both")
				src.visible_message("<b>[src]'s</b> legs are destroyed!")
				src.part_leg_r = null
				src.part_leg_l = null
			if (part.slot == "leg_left")
				src.visible_message("<b>[src]'s</b> left leg breaks off!")
				src.part_leg_l = null
			if (part.slot == "leg_right")
				src.visible_message("<b>[src]'s</b> right leg breaks off!")
				src.part_leg_r = null
		//var/loseslot = part.slot //ZeWaka: Fix for null.slot
		if(part.robot_movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(src, part.robot_movement_modifier, part.type)
		src.update_bodypart()
		//src.update_bodypart(loseslot)
		qdel(part)
		return

	proc/compborg_get_total_damage(var/sort = 0)
		var/tally = 0

		for(var/obj/item/parts/robot_parts/RP in src.contents)
			switch(sort)
				if(1) tally += RP.dmg_blunt
				if(2) tally += RP.dmg_burns
				else
					tally += RP.dmg_blunt
					tally += RP.dmg_burns

		return tally

	proc/compborg_take_critter_damage(var/zone = null, var/brute = 0, var/burn = 0)
		TakeDamage(pick(get_valid_target_zones()), brute, burn)

	proc/collapse_to_pieces()
		src.visible_message("<span class='alert'><b>[src]</b> falls apart into a pile of components!</span>")
		var/turf/T = get_turf(src)
		for(var/obj/item/parts/robot_parts/R in src.contents)
			R.set_loc(T)
		src.part_chest = null
		src.part_head = null
		src.part_arm_l = null
		src.part_arm_r = null
		src.part_leg_l = null
		src.part_leg_r = null
		qdel(src)
		return

/mob/living/silicon/robot/var/image/i_batterydistress

/mob/living/silicon/robot/proc/batteryDistress()
	if (!src.i_batterydistress) // we only need to build i_batterydistress once
		src.i_batterydistress = image('icons/mob/robots_decor.dmi', "battery-distress", layer = MOB_EFFECT_LAYER )
		src.i_batterydistress.pixel_y = 6 // Lined up bottom edge with speech bubbles

	if (src.batteryDistress == ROBOT_BATTERY_DISTRESS_INACTIVE) // We only need to apply the indicator when we first enter distress
		UpdateOverlays(src.i_batterydistress, "batterydistress") // Help me humans!
		src.batteryDistress = ROBOT_BATTERY_DISTRESS_ACTIVE
		src.next_batteryDistressBoop = world.time + 50 // let's wait 5 seconds before we begin booping
	else if(world.time >= src.next_batteryDistressBoop)
		src.next_batteryDistressBoop = world.time + 50 // wait 5 seconds between sad boops
		playsound(src.loc, src.sound_sad_robot, 100, 1) // Play a sad boop to garner sympathy


/mob/living/silicon/robot/proc/clearBatteryDistress()
	src.batteryDistress = ROBOT_BATTERY_DISTRESS_INACTIVE
	ClearSpecificOverlays("batterydistress")

/mob/living/silicon/robot/verb/open_nearest_door()
	set category = "Robot Commands"
	set name = "Open Nearest Door to..."
	set desc = "Automatically opens the nearest door to a selected individual, if possible."

	src.open_nearest_door_silicon()
	return

/mob/living/silicon/robot/verb/cmd_return_mainframe()
	set category = "Robot Commands"
	set name = "Recall to Mainframe"
	return_mainframe()

/mob/living/silicon/robot/proc/return_mainframe()
	if (mainframe)
		mainframe.return_to(src)
		src.update_appearance()
	else
		boutput(src, "<span class='alert'>You lack a dedicated mainframe!</span>")
		return

/mob/living/silicon/robot/ghostize()
	if (src.mainframe)
		src.mainframe.return_to(src)
	else
		return ..()

/mob/living/silicon/robot/find_in_hand(var/obj/item/I, var/this_hand)
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
		else if (this_hand == "left" || this_hand == 1)
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

/mob/living/silicon/robot/find_type_in_hand(var/obj/item/I, var/this_hand)
	if (!I)
		return 0
	if (!src.module_states[3] && !src.module_states[2] && !src.module_states[1])
		return 0

	if (this_hand)
		if (this_hand == "right" || this_hand == 3)
			if (src.module_states[3] && istype(src.module_states[3], I))
				return 1
			else
				return 0
		else if (this_hand == "middle" || this_hand == 2)
			if (src.module_states[2] && istype(src.module_states[2], I))
				return 1
			else
				return 0
		else if (this_hand == "left" || this_hand == 1)
			if (src.module_states[1] && istype(src.module_states[1], I))
				return 1
			else
				return 0
		else
			return 0

	if (src.module_states[3] && istype(src.module_states[3], I))
		return src.module_states[3]
	else if (src.module_states[2] && istype(src.module_states[2], I))
		return src.module_states[2]
	else if (src.module_states[1] && istype(src.module_states[1], I))
		return src.module_states[1]
	else
		return 0

/mob/living/silicon/robot/find_tool_in_hand(var/tool_flag, var/hand)
	if (hand)
		var/i = 0
		if (hand == "right" || hand == 3)
			i = 3
		else if (hand == "middle" || hand == 2)
			i = 2
		else if (hand == "left" || hand == 1)
			i = 1
		if (i)
			var/obj/item/I = src.module_states[i]
			if (I)
				if (I.tool_flags & tool_flag)
					return src.module_states[i]
				else if (istype(src.module_states[i], /obj/item/magtractor))
					var/obj/item/magtractor/MT = src.module_states[i]
					var/obj/item/MTI = MT.holding
					if (MTI && (MTI.tool_flags & tool_flag))
						return MT.holding
	else
		for(var/i = 1 to 3)
			var/obj/item/I = src.module_states[i]
			if (I && (I.tool_flags & tool_flag))
				return src.module_states[i]
	return null

/mob/living/silicon/robot/handle_event(var/event, var/sender)
	hud.handle_event(event, sender)	// the HUD will handle icon_updated events, so proxy those

///////////////////////////////////////////////////
// Specific instances of robots can go down here //
///////////////////////////////////////////////////

/mob/living/silicon/robot/spawnable // can be spawned via the admin panel in properly unlike the parent
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 1, var/syndie = 0, var/frame_emagged = 0)
		..(loc, frame, starter, syndie, frame_emagged)

	shell
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 1, var/syndie = 0, var/frame_emagged = 0)
			src.shell = 1
			..(loc, frame, starter, syndie, frame_emagged)

/mob/living/silicon/robot/spawnable/standard
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/supercell/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right(src)
		..(loc, frame, starter, syndie, frame_emagged)

	shell
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 1, var/syndie = 0, var/frame_emagged = 0)
			src.shell = 1
			..(loc, frame, starter, syndie, frame_emagged)

	metalman
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
			..(loc, frame, starter, syndie, frame_emagged)
			src.metalman_skin = 1
			src.update_appearance()


/mob/living/silicon/robot/spawnable/standard_thruster
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/supercell/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left/thruster(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right/thruster(src)
		..(loc, frame, starter, syndie, frame_emagged)


/mob/living/silicon/robot/spawnable/sturdy
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/cerenkite/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/sturdy(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left/sturdy(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right/sturdy(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left/treads(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right/treads(src)
		..(loc, frame, starter, syndie, frame_emagged)

	shell
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 1, var/syndie = 0, var/frame_emagged = 0)
			src.shell = 1
			..(loc, frame, starter, syndie, frame_emagged)

/mob/living/silicon/robot/spawnable/heavy
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/cerenkite/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/heavy(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left/heavy(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right/heavy(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left/treads(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right/treads(src)
		..(loc, frame, starter, syndie, frame_emagged)

	shell
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 1, var/syndie = 0, var/frame_emagged = 0)
			src.shell = 1
			..(loc, frame, starter, syndie, frame_emagged)

/mob/living/silicon/robot/uber

	New()
		src.cell = new /obj/item/cell/cerenkite/charged(src)

		src.max_upgrades = 10
		new /obj/item/roboupgrade/jetpack(src)
		new /obj/item/roboupgrade/speed(src)
		new /obj/item/roboupgrade/efficiency(src)
		new /obj/item/roboupgrade/repair(src)
		new /obj/item/roboupgrade/aware(src)
		new /obj/item/roboupgrade/opticmeson(src)
		//new /obj/item/roboupgrade/opticthermal(src)
		new /obj/item/roboupgrade/physshield(src)
		new /obj/item/roboupgrade/fireshield(src)
		new /obj/item/roboupgrade/teleport(src)

		for(var/obj/item/roboupgrade/UPGR in src.contents)
			src.upgrades.Add(UPGR)

		..()

//Fred the vegasbot
/mob/living/silicon/robot/hivebot
	name = "Robot"
	real_name = "Robot"
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "vegas"
	health = 1000
	custom = 1

	New()
		..(usr.loc, null, 1)
		qdel(src.cell)
		var/obj/item/cell/cerenkite/CELL = new /obj/item/cell/cerenkite(src)
		CELL.charge = CELL.maxcharge
		src.cell = CELL
		src.part_chest.cell = CELL

		src.upgrades += new /obj/item/roboupgrade/healthgoggles(src)
		src.upgrades += new /obj/item/roboupgrade/teleport(src)
		hud.update_upgrades()

	update_appearance()
		return

/mob/living/silicon/robot/buddy
	name = "Robot"
	real_name = "Robot"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "robuddy1"
	health = 1000
	custom = 1

	New()
		..(usr.loc, null, 1)

	update_bodypart()
		return
	update_appearance()
		return


/client/proc/set_screen_color_to_red()
	src.color = "#ff0000"


#define can_step_sfx(H)  (H.footstep >= 4 || (H.m_intent != "run" && H.footstep >= 3))

/mob/living/silicon/robot/Move(var/turf/NewLoc, direct)
	//var/oldloc = loc
	. = ..()

	if (.)
		//STEP SOUND HANDLING
		if ((src.part_leg_r || src.part_leg_l) && isturf(NewLoc) && NewLoc.turf_flags & MOB_STEP)
			/*if (NewLoc.active_liquid) //todo : hydraulic robot fluid splash step
				if (NewLoc.active_liquid.step_sound)
					if (src.m_intent == "run")
						if (src.footstep >= 4)
							src.footstep = 0
						else
							src.footstep++
						if (src.footstep == 0)
							playsound(NewLoc, NewLoc.active_liquid.step_sound, 50, 1)
					else
						if (src.footstep >= 2)
							src.footstep = 0
						else
							src.footstep++
						if (src.footstep == 0)
							playsound(NewLoc, NewLoc.active_liquid.step_sound, 20, 1)
			*/
			src.footstep++
			if (can_step_sfx(src))
				var/obj/item/parts/robot_parts/leg/leg = null
				if (prob(50) && part_leg_l)
					leg = part_leg_l
				else if (part_leg_r)
					leg = part_leg_r

				src.footstep = 0
				if (NewLoc.step_material || !leg || (leg?.step_sound))
					var/priority = 0

					if (!NewLoc.step_material)
						priority = -1
					else if (leg && !leg.step_sound)
						priority = 1

					if (!priority) //now we must resolve bc the floor and the shoe both wanna make noise
						if (!leg) //barefoot
							priority = (STEP_PRIORITY_MAX > NewLoc.step_priority) ? -1 : 1
						else //shoed
							priority = (leg.step_priority > NewLoc.step_priority) ? -1 : 1

					if (priority)
						if (priority > 0)
							priority = NewLoc.step_material
						else if (priority < 0)
							priority = leg ? leg.step_sound : "step_robo"

						playsound(NewLoc, "[priority]", src.m_intent == "run" ? 65 : 40, 1, extrarange = 3)

		//STEP SOUND HANDLING OVER

#undef can_step_sfx
#undef ROBOT_BATTERY_DISTRESS_INACTIVE
#undef ROBOT_BATTERY_DISTRESS_ACTIVE
#undef ROBOT_BATTERY_DISTRESS_THRESHOLD
