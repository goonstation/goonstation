#define DRONE_BATTERY_DISTRESS_INACTIVE 0
#define DRONE_BATTERY_DISTRESS_ACTIVE 1
#define DRONE_BATTERY_DISTRESS_THRESHOLD 100
#define DRONE_BATTERY_WIRELESS_CHARGERATE 50

var/global/list/drone_emotions = list("Annoyed" = "ailes-s-annoyed", \
	"Content" = "ailes-s-content", \
	"Curious" = "ailes-s-curious", \
	"Exclaimation" = "ailes-s-exclamation",\
	"Eye" = "ailes-s-eye",\
	"Heart" = "ailes-s-heart",\
	"Line" = "ailes-s-line",\
	"Mad" = "ailes-s-mad",\
	"Neutral" = "ailes-s-neutral",\
	"Sad" = "ailes-s-sad",\
	"Silly" = "ailes-s-silly",\
	"Happy" = "ailes-s-happy",\
	"Square" = "ailes-s-square",\
	"Triangle" = "ailes-s-triangle",\
	"Unsure" = "ailes-s-unsure",\
	"Very Happy" = "ailes-s-veryhappy",\
	"Wink" = "ailes-s-wink") // this should be in typeinfo

/mob/living/silicon/drone
	name = "Drone"
	voice_name = "synthesized voice"
	icon = 'icons/mob/hivebot.dmi'
	voice_type = "cyborg"
	icon_state = "eyebot"
	health = 25
	max_health = 25
	do_hurt_slowdown = FALSE
	emaggable = TRUE
	syndicate_possible = 1

	var/datum/hud/silicon/drone/hud

// Pieces and parts

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
	var/obj/item/robot_module/module = null
	var/obj/item/device/pda2/internal_pda = null
	var/obj/item/organ/brain/brain = null
	var/obj/item/ai_interface/ai_interface = null

	var/opened = 0
	var/batteryDistress = DRONE_BATTERY_DISTRESS_INACTIVE
	var/next_batteryDistressBoop = 0
	var/locked = 1
	var/locking = 0
	req_access = list(access_robotics)
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/viewalerts = 0
	var/jetpack = 1
	var/freemodule = 1 // For picking modules when a robot is first created
	var/glitchy_speak = 0

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'
	var/sound_sad_robot = 'sound/voice/Sad_Robot.ogg'
	var/vocal_pitch = 1.0 // set default vocal pitch

	var/bruteloss = 0
	var/fireloss = 0

	var/faceEmotion = "ailes-s-smile"
	var/faceColor = "#66B2F2"
	var/shelltype = "eyebot"
	var/hovering = "a"
	var/hat = "Nothing"

	var/image/i_details
	var/image/i_panel


	// moved up to silicon.dm
	killswitch = 0
	killswitch_at = 0
	weapon_lock = 0
	weaponlock_time = 120
	var/custom = 0

	New(loc, var/obj/item/parts/robot_parts/drone_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)

		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
		src.internal_pda = new /obj/item/device/pda2/cyborg(src)
		src.internal_pda.name = "[src]'s Internal PDA Unit"
		src.internal_pda.owner = "[src]"
		src.cell = frame.cell
		src.brain = frame.brain
		src.ai_interface = frame.ai_interface
		src.shelltype = frame.shelltypetoapply

		if (frame)
			src.freemodule = frame.freemodule
		if (starter && !(src.dependent || src.shell))
			src.cell = new /obj/item/cell/charged(src)
			for(var/obj/item/parts/robot_parts/P in src.contents)
				P.holder = src


			if (!src.custom)
				SPAWN(0)
					src.choose_name(3)

		else if (src.cell && (src.brain ||src.ai_interface)) // some wee child of ours sent us some parts, how nice c:
			if (src.cell.loc != src)
				src.cell.set_loc(src)
			if (src.brain &&src.brain.loc != src)
				src.brain.set_loc(src)
			if (src.ai_interface && src.ai_interface.loc != src)
				src.ai_interface.set_loc(src)
			for (var/obj/item/parts/robot_parts/P in src.contents)
				P.holder = src

		else
			if (!frame)
				// i can only imagine bad shit happening if you just try to straight spawn one like from the spawn menu or
				// whatever so let's not allow that for the time being, just to make sure
				logTheThing(LOG_DEBUG, null, "<b>I Said No/Composite Drone:</b> Composite drone attempted to spawn with null frame")
				qdel(src)
				return
			else
				if (!frame.cell || !frame.brain)
					logTheThing(LOG_DEBUG, null, "<b>I Said No/Composite Drone:</b> Composite drone attempted to spawn from incomplete frame")
					qdel(src)
					return

		update_appearance()
		update_details()

		if (src.shell)
			if (!(src in available_ai_shells))
				available_ai_shells += src
			for_by_tcl(AI, /mob/living/silicon/ai)
				boutput(AI, "<span class='success'>[src] has been connected to you as a controllable shell.</span>")
			src.ai_interface = new(src)

		if (!src.dependent && !src.shell)
			boutput(src, "<span class='notice'>Your icons have been generated!</span>")
			src.syndicate = syndie
			src.emagged = frame_emagged

		. = ..(loc) //must be called before hud is attached

		hud = new(src)
		src.attach_hud(hud)

		src.zone_sel = new(src, "CENTER+3, SOUTH")
		src.zone_sel.change_hud_style('icons/mob/hud_robot.dmi')
		src.attach_hud(zone_sel)

		SPAWN(0.4 SECONDS)
			if (!src.connected_ai && !syndicate && !(src.dependent || src.shell))
				for_by_tcl(A, /mob/living/silicon/ai)
					src.connected_ai = A
					A.connected_robots += src
					break

			src.botcard.access = get_all_accesses()
			src.botcard.registered = "Cyborg"
			src.botcard.assignment = "Cyborg"
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
			src.update_appearance()
			src.update_details()

		SPAWN(1.5 SECONDS)
			if (!src.brain && src.key && !(src.dependent || src.shell || src.ai_interface))
				var/obj/item/organ/brain/B = new /obj/item/organ/brain(src)
				B.owner = src.mind
				B.icon_state = "borg_brain"
				if (!B.owner) //Oh no, they have no mind!
					logTheThing(LOG_DEBUG, null, "<b>Mind</b> Drone spawn forced to create new mind for key \[[src.key ? src.key : "INVALID KEY"]]")
					stack_trace("[identify_object(src)] was created without a mind, somehow. Mind force-created for key \[[src.key ? src.key : "INVALID KEY"]]. That's bad.")
					var/datum/mind/newmind = new
					newmind.ckey = ckey
					newmind.key = src.key
					newmind.current = src
					B.owner = newmind
					src.mind = newmind
				if (src.brain)
					src.brain = B
				else
					// how the hell would this happen. oh well
					stack_trace("[identify_object(src)] was created without a brain, somehow. That's bad.")
					src.brain = B
					B.set_loc(src)
			if (src.shell && !src.ai_interface)
				var/obj/item/ai_interface/I = new /obj/item/ai_interface(src)
				src.ai_interface = I
				I.set_loc(src)
			if(!isnull(src.client))
				src.bioHolder.mobAppearance.pronouns = src.client.preferences.AH.pronouns
				src.update_name_tag()
			if (src.syndicate)
				src.show_antag_popup("syndieborg")

		if (prob(50))
			src.sound_scream = 'sound/voice/screams/Robot_Scream_2.ogg'

	set_pulling(atom/movable/A)
		. = ..()
		hud.update_pulling()

	death(gibbed)
		setdead(src)
		src.borg_death_alert()
		logTheThing(LOG_COMBAT, src, "was destroyed at [log_loc(src)].")
		src.mind?.register_death()
		if (src.syndicate)
			src.remove_syndicate("death")

		src.eject_brain(fling = TRUE) //EJECT
		if (!gibbed)
			src.visible_message("<span class='alert'><b>[src]</b> falls apart into a pile of components!</span>")
			var/turf/T = get_turf(src)
			robogibs(T)
			for(var/obj/item/cell/C in src.contents)
				C.set_loc(T)
			for(var/obj/item/robot_module/M in src.contents)
				if(M.swappable == 1) //no insertable unswappable modules for you if you smash open an eyebot
					M.set_loc(T)
			for(var/obj/item/ai_interface/I in src.contents)
				I.set_loc(T)

			var/obj/item/parts/robot_parts/drone_frame/frame =  new(T)
			frame.shelltypetoapply = src.shelltype
			frame.emagged = src.emagged
			frame.syndicate = src.syndicate
			frame.freemodule = src.freemodule
			frame.update_icon()

			src.ghostize()
			qdel(src)

#ifdef RESTART_WHEN_ALL_DEAD
		var/cancel

		for (var/client/C)
			if (!C.mob) continue
			if (!( C.mob.stat ))
				cancel = 1
				break
		if (!( cancel ))
			boutput(world, "<B>Everyone is dead! Resetting in 30 seconds!</B>")
			SPAWN( 300 )
				logTheThing(LOG_DIARY, null, "Rebooting because of no live players", "game")
				Reboot_server()
				return
#endif
		return ..(gibbed)

	emote(var/act, var/voluntary = 1)
		..()
		var/param = null
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

		var/m_type = 1
		var/message
		var/maptext_out = 0
		var/custom = 0


		switch(lowertext(act))

			if ("help")
				src.show_text("To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
				src.show_text("For a list of all emotes, use *list. For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")

			if ("list")
				src.show_text("Basic emotes:")
				src.show_text("clap, flap, aflap, twitch, twitch_s, scream, sigh, laugh, chuckle, giggle, chortle, guffaw, cackle, birdwell, fart, flip, custom, customv, customh")
				src.show_text("Targetable emotes:")
				src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

			if ("listbasic")
				src.show_text("clap, flap, aflap, twitch, twitch_s, scream, sigh, laugh, chuckle, giggle, chortle, guffaw, cackle, birdwell, fart, flip, custom, customv, customh")

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
					maptext_out = "<I>[act]s</I>"
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
								maptext_out = "<I>[act]s itself</I>"
							else
								message = "<B>[src]</b> [act]s."
				else
					message = "<B>[src]</B> struggles to move."
					maptext_out = "<I>struggles to move</I>"
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
					maptext_out = "<I>enters a state of hysterical panic!</I>"
				else
					message = "<B>[src]</B> starts writhing around in manic terror!"
					maptext_out = "<I>starts writhing around in manic terror!</I>"
				m_type = 1

			if ("clap")
				if (!src.restrained())
					message = "<B>[src]</B> claps."
					maptext_out = "<I>claps</I>"
					m_type = 2

			if ("flap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps its wings."
					maptext_out = "<I>flaps its wings</I>"
					m_type = 2

			if ("aflap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps its wings ANGRILY!"
					maptext_out = "<I>flaps its wings ANGRILY!</I>"
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
				maptext_out = "<I>[input]</I>"
				custom = copytext(input, 1, 10)

			if ("customv")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[param]</I>"
				custom = copytext(param, 1, 10)
				m_type = 1

			if ("customh")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[param]</I>"
				custom = copytext(param, 1, 10)
				m_type = 2

			if ("me")
				if (!param)
					return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				maptext_out = "<I>[param]</I>"
				custom = copytext(param, 1, 10)
				m_type = 1

			if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
				// basic visible single-word emotes
				message = "<B>[src]</B> [act]s."
				maptext_out = "<I>[act]s</I>"
				m_type = 1

			if ("sigh","laugh","chuckle","giggle","chortle","guffaw","cackle")
				// basic audible single-word emotes
				message = "<B>[src]</B> [act]s."
				maptext_out = "<I>[act]s</I>"
				m_type = 2

			if ("flipout")
				message = "<B>[src]</B> flips the fuck out!"
				maptext_out = "<I>flips the fuck out!</I>"
				m_type = 1

			if ("rage","fury","angry")
				message = "<B>[src]</B> becomes utterly furious!"
				maptext_out = "<I>becomes utterly furious!</I>"
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
					playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1, 0, vocal_pitch, channel=VOLUME_CHANNEL_EMOTE) // vocal pitch added
					message = "<b>[src]</b> birdwells."

			if ("scream")
				if (src.emote_check(voluntary, 50))
					if (narrator_mode)
						playsound(src.loc, 'sound/vox/scream.ogg', 50, 1, 0, src.get_age_pitch(), channel=VOLUME_CHANNEL_EMOTE)
					else
						playsound(src, src.sound_scream, 80, 0, 0, vocal_pitch, channel=VOLUME_CHANNEL_EMOTE) // vocal pitch added
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
						src.TakeDamage(2, 4)
					if ((!src.restrained()) && (!src.getStatusDuration("weakened")))
						if (isobj(src.loc))
							var/obj/container = src.loc
							container.mob_flip_inside(src)
						else
							if (narrator_mode)
								playsound(src.loc, pick('sound/vox/deeoo.ogg', 'sound/vox/dadeda.ogg'), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
							else
								playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
							message = "<B>[src]</B> beep-bops!"
							if (prob(50))
								animate_spin(src, "R", 1, 0)
							else
								animate_spin(src, "L", 1, 0)

							for (var/mob/living/M in viewers(1, null))
								if (M == src)
									continue
								message = "<B>[src]</B> beep-bops at [M]."
								break

							if (istype(src.buckled, /obj/machinery/conveyor))
								message = "<B>[src]</B> beep-bops and flips [himself_or_herself(src)] free from the conveyor."
								src.buckled = null
								if(isunconscious(src))
									setalive(src) //reset stat to ensure emote comes out

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
					SPAWN(1 SECOND)
						src.emote_allowed = 1
			else
				if (voluntary) src.show_text("Invalid Emote: [act]")
				return
		if (!isalive(src))
			return
		if (maptext_out)
			var/image/chat_maptext/chat_text = null
			SPAWN(0) //blind stab at a life() hang - REMOVE LATER
				if (speechpopups && src.chat_text)
					chat_text = make_chat_maptext(src, maptext_out, "color: [rgb(194,190,190)];" + src.speechpopupstyle, alpha = 140)
					if(chat_text)
						chat_text.measure(src.client)
						for(var/image/chat_maptext/I in src.chat_text.lines)
							if(I != chat_text)
								I.bump_up(chat_text.measured_height)
				if (message)
					logTheThing(LOG_SAY, src, "EMOTE: [message]")
					act = lowertext(act)
					if (m_type & 1)
						for (var/mob/O in viewers(src, null))
							O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
					else if (m_type & 2)
						for (var/mob/O in hearers(src, null))
							O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
					else if (!isturf(src.loc))
						var/atom/A = src.loc
						for (var/mob/O in A.contents)
							O.show_message("<span class='emote'>[message]</span>", m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
		else
			if (message)
				logTheThing(LOG_SAY, src, "EMOTE: [message]")
				if (m_type & 1)
					for (var/mob/O in viewers(src, null))
						O.show_message("<span class='emote'>[message]</span>", m_type)
				else
					for (var/mob/O in hearers(src, null))
						O.show_message("<span class='emote'>[message]</span>", m_type)
		return

	examine(mob/user)
		. = list()

		if (isghostdrone(user))
			return
		. += "<span class='notice'>*---------*</span><br>"
		. += "<span class='notice'>This is [bicon(src)] <B>[src.name] ([src.get_pronouns()])</B>!</span><br>"

		var/brute = get_brute_damage()
		var/burn = get_burn_damage()

		// If we have no brain or an inactive spont core, we're dormant.
		// If we have a brain but no client, we're in hiberation mode.
		// Otherwise, fully operational.
		if ((src.brain || src.ai_interface) && !(istype(src.brain, /obj/item/organ/brain/latejoin) && !src.brain:activated))
			if (src.client)
				. += "<span class='success'>[src.name] is fully operational.</span><br>"
			else
				. += "<span class='hint'>[src.name] is in temporary hibernation.</span><br>"
		else
			. += "<span class='alert'>[src.name] is completely dormant.</span><br>"

		if (src.shell)
			. += "<span class='success'>[src.name] appears to be an AI-controlled shell.</span><br>"

		if (brute)
			if (brute < 20)
				. += "<span class='alert'>[src.name] looks slightly dented.</span><br>"
			else
				. += "<span class='alert'><B>[src.name] looks severely dented!</B></span><br>"
		if (burn)
			if (burn < 20)
				. += "<span class='alert'>[src.name] has slightly burnt wiring.</span><br>"
			else
				. += "<span class='alert'><B>[src.name] has severely burnt wiring!</B></span><br>"
		if (src.health <= 20)
			. += "<span class='alert'>[src.name] is twitching and sparking!</span><br>"
		if (isunconscious(src))
			. += "<span class='alert'>[src.name] doesn't seem to be responding.</span><br>"

		. += "The cover is [opened ? "open" : "closed"].<br>"
		. += "The power cell display reads: [ cell ? "[round(cell.percent())]%" : "WARNING: No cell installed."]<br>"

		if (src.module)
			. += "[src.name] has a [src.module.name] "
			if (src.module.swappable == 0)
				. += "hardwired in.<br>"
			else
				. += "installed.<br>"
		else
			. += "[src.name] does not appear to have a module installed.<br>"

		if(issilicon(user) || isAI(user))
			var/lr = null
			if(isAIeye(user))
				var/mob/living/intangible/aieye/E = user
				lr =  E.mainframe?.law_rack_connection
			else
				var/mob/living/silicon/S = user
				lr =  S.law_rack_connection
			if(src.law_rack_connection != lr)
				. += "<span class='alert'>[src.name] is not connected to your law rack!</span><br>"
			else
				. += "[src.name] follows the same laws you do.<br>"

		. += "<span class='notice'>*---------*</span>"

	choose_name(var/retries = 3, var/what_you_are = null, var/default_name = null, var/force_instead = 0)
		var/newname
		if(isnull(default_name))
			default_name = src.real_name
		for (retries, retries > 0, retries--)
			if(force_instead)
				newname = default_name
			else
				newname = tgui_input_text(src, "You are a Drone. Would you like to change your name to something else?", "Name Change", client?.preferences?.robot_name || default_name)
				if(newname && newname != default_name)
					phrase_log.log_phrase("name-drone", newname, no_duplicates=TRUE)
			if (!newname)
				src.real_name = borgify_name("Drone")
				break
			else
				newname = strip_html(newname, MOB_NAME_MAX_LENGTH, 1)
				if (!length(newname))
					src.show_text("That name was too short after removing bad characters from it. Please choose a different name.", "red")
					continue
				else if (is_blank_string(newname))
					src.show_text("Your name cannot be blank. Please choose a different name.", "red")
					continue
				else
					if (tgui_alert(src, "Use the name [newname]?", newname, list("Yes", "No")) == "Yes")
						src.real_name = newname
						break
					else
						continue
		if (!newname)
			src.real_name = borgify_name("Drone")

		src.UpdateName()
		src.internal_pda.name = "[src.name]'s Internal PDA Unit"
		src.internal_pda.owner = "[src.name]"

	Login()
		..()

		if (src.custom)
			src.choose_name(3)

		if (src.real_name == "Drone")
			src.real_name = borgify_name(src.real_name)
			src.UpdateName()
			src.internal_pda.name = "[src.name]'s Internal PDA Unit"
			src.internal_pda.owner = "[src]"
		if (!src.syndicate && !src.connected_ai)
			for_by_tcl(A, /mob/living/silicon/ai)
				src.connected_ai = A
				A.connected_robots += src
				break

		if (src.shell && src.mainframe)
			src.bioHolder.mobAppearance.pronouns = src.client.preferences.AH.pronouns
			src.real_name = "SHELL/[src.mainframe]"
			src.UpdateName()
			src.update_name_tag()

		update_appearance()
		update_details()
		return

	Logout()
		..()
		if (src.shell)
			src.real_name = "AI Drone Shell [copytext("\ref[src]", 6, 11)]"
			src.name = src.real_name
			src.update_name_tag()
			return

		update_appearance()
		update_details()

	blob_act(var/power)
		if (!isdead(src))
			src.bruteloss += power
			health_update_queue |= src
			return 1
		return 0

	Stat()
		..()
		if(src.cell)
			stat("Charge Left:", "[src.cell.charge]/[src.cell.maxcharge]")
		else
			stat("No Cell Inserted!")

	restrained()
		return 0

	bullet_act(var/obj/projectile/P)
		..()
		log_shot(P,src) // Was missing (Convair880).

	ex_act(severity, lasttouched, power)
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

	bullet_act(var/obj/projectile/P)
		var/dmgmult = 1.2
		switch (P.proj_data.damage_type)
			if(D_PIERCING)
				dmgmult = 2
			if(D_SLASHING)
				dmgmult = 0.6
			if(D_BURNING)
				dmgmult = 0.75
			if(D_RADIOACTIVE)
				dmgmult = 0.2
			if(D_TOXIC)
				dmgmult = 0
			if(D_SPECIAL)
				dmgmult = 0


		log_shot(P, src)
		src.visible_message("<span class='alert'><b>[src]</b> is struck by [P]!</span>")
		var/damage = (P.power / 3) * dmgmult
		if (damage < 1)
			return

		if(P.proj_data.stun && P.proj_data.damage <= 5)
			src.do_disorient(clamp(P.power*4, P.proj_data.stun*2, P.power+80), weakened = P.power*2, stunned = P.power*2, disorient = min(P.power, 80), remove_stamina_below_zero = 0) //bad hack, but it'll do
			src.emote("twitch_v")// for the above, flooring stam based off the power of the datum is intentional

		if (P.proj_data.damage < 1)
			return

		src.material_trigger_on_bullet(src, P)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(src.shell || src.ai_interface)
			boutput(user, "<span class='alert'>Emagging an AI shell wouldn't work, their laws can't be overwritten!</span>")
			return 0 //emags don't do anything to AI shells
		if (!src.emaggable)
			boutput(user, "<span class='alert'>You try to swipe your emag along [src]'s interface, but it grows hot in your hand and you almost drop it!")
			return FALSE

		if (!src.emagged)	// trying to unlock with an emag card
			if (src.opened && user) boutput(user, "You must close the cover to swipe an ID card.")
			else
				if (user)
					boutput(user, "You emag [src]'s interface.")
				src.visible_message("<font color=red><b>[src]</b> buzzes oddly!</font>")
				logTheThing(LOG_STATION, src, "[key_name(src)] is emagged by [key_name(user)] and loses connection to rack. Formerly [constructName(src.law_rack_connection)]")
				src.mind?.add_antagonist(ROLE_EMAGGED_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_CONVERTED)
				update_appearance()
				update_details()
				return 1
			return 0

	emp_act()
		vision.noise(60)
		src.changeStatus("stunned", 5 SECONDS, optional=null)
		boutput(src, "<span class='alert'><B>*BZZZT*</B></span>")

	meteorhit(obj/O as obj)
		for(var/mob/M in viewers(src, null))
			M.show_message(text("<span class='alert'>[src] has been hit by [O]</span>"), 1)
			//Foreach goto(19)
		if (src.health > 0)
			src.bruteloss += 30
			if ((O.icon_state == "flaming"))
				src.fireloss += 40
			health_update_queue |= src
		return

	temperature_expose(null, temp, volume)

		src.material_trigger_on_temp(temp)

		for(var/atom/A in src.contents)
			A.material_trigger_on_temp(temp)
		for (var/atom/equipped_stuff in src.equipped())
			//that should mostly not have an effect, exept maybe when an engiborg picks up a stack of erebite rods?
			equipped_stuff.material_trigger_on_temp(temp)

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
			if (length(CL) == 1)
				C = CL[1]
		else if (O && istype(O, /obj/machinery/camera))
			C = O
		L[A.name] = list(A, (C) ? C : O, list(alarmsource))
		boutput(src, text("--- [class] alarm detected in [A.name]!"))
		return 1

	cancelAlarm(var/class, area/A as area, obj/origin)
		var/list/L = src.alarms[class]
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/srcs = alarm[3]
				if (origin in srcs)
					srcs -= origin
				if (length(srcs) == 0)
					L -= I

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/device/borg_linker) && !isghostdrone(user))
			var/obj/item/device/borg_linker/linker = W
			if(!opened)
				boutput(user, "You need to open [src.name]'s cover before you can change their law rack link.")
				return
			if(src.shell || src.ai_interface)
				boutput(user,"You need to use this on the AI core directly!")
				return

			if(!src.law_rack_connection)
				boutput(src,"[src.name] is not connected to a law rack")
			else
				var/area/A = get_area(src.law_rack_connection)
				boutput(user, "[src.name] is connected to a law rack at [A.name].")

			if(!linker.linked_rack)
				return

			if(linker.linked_rack in ticker.ai_law_rack_manager.registered_racks)
				if(src.emagged || src.syndicate)
					boutput(user, "The link port sparks violently! It didn't work!")
					logTheThing(LOG_STATION, src, "[constructName(user)] tried to connect [src] to the rack [constructName(src.law_rack_connection)] but they are [src.emagged ? "emagged" : "syndicate"], so it failed.")
					elecflash(src,power=2)
					return
				if(src.law_rack_connection)
					var/raw = tgui_alert(user,"Do you want to overwrite the linked rack?", "Linker", list("Yes", "No"))
					if (raw == "Yes")
						src.set_law_rack(linker.linked_rack, user)
			else
				boutput(user,"Linker lost connection to the stored law rack!")
			return

		if (isweldingtool(W))
			if(W:try_weld(user, 1))
				src.add_fingerprint(user)
				var/repaired = HealDamage("All", 120, 0)
				if(repaired || health < max_health)
					src.visible_message("<span class='alert'><b>[user.name]</b> repairs some of the damage to [src.name]'s body.</span>")
				else boutput(user, "<span class='alert'>There's no structural damage on [src.name] to mend.</span>")
				src.update_appearance()
				src.update_details()

		else if (istype(W, /obj/item/cable_coil) && opened)
			var/obj/item/cable_coil/coil = W
			src.add_fingerprint(user)
			var/repaired = HealDamage("All", 0, 120)
			if(repaired || health < max_health)
				coil.use(1)
				src.visible_message("<span class='alert'><b>[user.name]</b> repairs some of the damage to [src.name]'s wiring.</span>")
			else boutput(user, "<span class='alert'>There's no burn damage on [src.name]'s wiring to mend.</span>")
			src.update_appearance()
			src.update_details()

		else if (ispryingtool(W))
			if (opened)
				boutput(user, "You close the cover.")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				opened = 0
			else
				if (locked)
					boutput(user, "<span class='alert'>[src.name]'s cover is locked!</span>")
				else
					boutput(user, "You open [src.name]'s cover.")
					playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
					opened = 1
					if (src.locking)
						src.locking = 0
			src.update_appearance()
			src.update_details()

		else if (istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
			if (cell)
				boutput(user, "<span class='alert'>[src] already has a power cell!</span>")
			else
				user.drop_item()
				W.set_loc(src)
				cell = W
				src.cell = W
				boutput(user, "You insert [W].")
				src.update_appearance()
				src.update_details()

		else if (istype(W, /obj/item/robot_module) && opened) // module changing
			var/obj/item/robot_module/module = W
			if(src.module)
				boutput(user, "<span class='alert'>[src] already has a module!</span>")
			else if(module.moduletype != "drone")
				boutput(user, "<span class='alert'>There's no way that module will fit, it's way too big!</span>")
			else
				user.drop_item()
				src.set_module(module)
				boutput(user, "You insert [module].")

		else if (istype(get_id_card(W), /obj/item/card/id))	// trying to unlock the interface with an ID card
			if (opened)
				boutput(user, "<span class='alert'>You must close the cover to swipe an ID card.</span>")
			else
				if (src.allowed(user))
					if (src.locking)
						src.locking = 0
					locked = !locked
					boutput(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
					boutput(src, "<span class='notice'>[user] [ locked ? "locks" : "unlocks"] your interface.</span>")
				else
					boutput(user, "<span class='alert'>Access denied.</span>")

		else if (istype(W, /obj/item/card/emag))
			return

		else if (istype(W, /obj/item/organ/brain) && src.opened)
			if (src.brain || src.ai_interface)
				boutput(user, "<span class='alert'>There's already a processor core in the drone! Use a wrench to remove it before trying to insert something else.</span>")
			else
				var/obj/item/organ/brain/B = W
				user.drop_item()
				user.visible_message("<span class='notice'>[user] inserts [W] into [src].</span>")
				if (B.owner && (B.owner.get_player().dnr || jobban_isbanned(B.owner.current, "Cyborg")))
					src.visible_message("<span class='alert'>The safeties on [src] engage, zapping [B]! [B] must not be compatible with silicon bodies.</span>")
					B.combust()
					return
				W.set_loc(src)
				src.brain = B
				if (B.owner)
					var/mob/M = find_ghost_by_key(B.owner.key)
					if (!M) // if we couldn't find them (i.e. they're still alive), don't pull them into this borg
						src.visible_message("<span class='alert'><b>[src]</b> remains inactive.</span>")
						return
					if (!isdead(M)) // so if they're in VR, the afterlife bar, or a ghostcritter
						boutput(M, "<span class='notice'>You feel yourself being pulled out of your current plane of existence!</span>")
						B.owner = M.ghostize()?.mind
						qdel(M)
					B.owner.transfer_to(src)
					if (src.syndicate)
						src.make_syndicate("brain added by [user]")
					else if (src.emagged)
						src.mind?.add_antagonist(ROLE_EMAGGED_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_CONVERTED)

				if (!src.emagged && !src.syndicate) // The antagonist proc does that too.
					boutput(src, "<B>You are playing a Drone. You can interact with most electronic objects in your view.</B>")
					src.show_laws()

				src.update_appearance()
				src.update_details()

		else if (istype(W, /obj/item/ai_interface) && src.opened)
			if (src.brain || src.ai_interface)
				boutput(user, "<span class='alert'>There's already a processor core in the drone! Use a wrench to remove it before trying to insert something else.</span>")
			else
				var/obj/item/ai_interface/I = W
				user.drop_item()
				user.visible_message("<span class='notice'>[user] inserts [W] into [src]'s head.</span>")
				src.ai_interface = I
				I.set_loc(src)
				if (!(src in available_ai_shells))
					if(isnull(src.ai_radio))
						src.ai_radio = new /obj/item/device/radio/headset/command/ai(src)
					src.radio = src.ai_radio
					src.ears = src.radio
					src.radio.set_loc(src)
					available_ai_shells += src
					src.real_name = "AI Drone Shell [copytext("\ref[src]", 6, 11)]"
					src.name = src.real_name
				for_by_tcl(AI, /mob/living/silicon/ai)
					boutput(AI, "<span class='success'>[src] has been connected to you as a controllable shell.</span>")
				src.shell = 1
				update_appearance()
				update_details()

		else if (istype(W, /obj/item/clothing/suit/bee) && src.shelltype == "eyebot")
			boutput(user, "You stuff [src] into [W]! It fits surprisingly well.")
			src.shelltype = "bee"
			update_appearance()
			update_details()
			qdel(W)

		else if (istype(W,/obj/item/) && src.opened)
			var/obj/item/parts/robot_parts/RP = W
			switch(RP.slot)
				if("brain")
					if(src.brain)
						boutput(user, "<span class='alert'>[src] already has a brain.</span>")
						return
					src.brain = RP
					if(src.brain.owner)
						if(src.brain.owner.current)
							src.gender = src.brain.owner.current.gender
							if(src.brain.owner.current.client)
								src.lastKnownIP = src.brain.owner.current.client.address
						src.brain.owner.transfer_to(src)
				if("cell")
					if(src.cell)
						boutput(user, "<span class='alert'>[src] already has a power cell.</span>")
						return
					src.cell = RP

			user.drop_item()
			RP.set_loc(src)
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, 1)
			boutput(user, "<span class='notice'>You successfully attach the piece to [src.name].</span>")
		else
			return ..()

	hand_attack(atom/target, params, location, control, origParams)
		// Only allow it if the target is outside our contents or it is the equipped tool
		if(!src.contents.Find(target) || target==src.equipped() || ishelpermouse(target))
			..()

	attack_hand(mob/user)

		var/list/available_actions = list()
		if (src.opened)
			if (src.brain)
				available_actions.Add("Remove the Brain")
			if (src.ai_interface)
				available_actions.Add("Remove the AI Interface")
			if (src.module && src.module != "empty")
				available_actions.Add("Remove the Module")
			if (cell)
				available_actions.Add("Remove the Power Cell")

		if (available_actions.len)
			available_actions.Insert(1, "Cancel")
			var/action = tgui_input_list(user, "What do you want to do?", "Drone Maintenance", available_actions)
			if (!action || action == "Cancel")
				return
			if (BOUNDS_DIST(src.loc, user.loc) > 0 && !src.bioHolder?.HasEffect("telekinesis"))
				boutput(user, "<span class='alert'>You need to move closer!</span>")
				return

			switch(action)
				if ("Remove the Brain")
					//Wire: Fix for multiple players queuing up brain removals, triggering this again
					src.eject_brain(user)

				if ("Remove the AI Interface")

					src.visible_message("<span class='alert'>[user] removes [src]'s AI interface!</span>")
					logTheThing(LOG_COMBAT, user, "removes [constructTarget(src,"combat")]'s ai_interface at [log_loc(src)].")

					src.uneq_active()

					user.put_in_hand_or_drop(src.ai_interface)
					src.radio = src.default_radio
					if (src.module && istype(src.module.radio))
						src.radio = src.module.radio
					src.ears = src.radio
					src.radio.set_loc(src)
					src.shell = 0
					src.dependent = 0
					src.ai_interface = null
					if(src.ai_radio)
						qdel(src.ai_radio)
						src.ai_radio = null

					if (mainframe)
						mainframe.return_to(src)
						src.mainframe = null

					if (src in available_ai_shells)
						available_ai_shells -= src

				if ("Remove the Module")
					if (!src.module)
						return
					if (istype(src.module,/obj/item/robot_module/))
						var/obj/item/robot_module/_module = src.module
						if (_module.swappable == 0)
							boutput(user, "<span class='alert'>You cannot remove a hardwired module!</span>")
						else
							user.put_in_hand_or_drop(_module)
							src.remove_module()
							user.show_text("You remove [src.module].")
							src.module = null

				if ("Remove the Power Cell")
					if (!src.cell)
						return
					var/obj/item/cell/_cell = src.cell
					user.put_in_hand_or_drop(_cell)
					user.show_text("You remove [_cell] from [src].", "red")
					src.show_text("Your power cell was removed!", "red")
					logTheThing(LOG_COMBAT, user, "removes [constructTarget(src,"combat")]'s power cell at [log_loc(src)].") // Renders them mute and helpless (Convair880).
					_cell.add_fingerprint(user)
					_cell.UpdateIcon()
					src.cell = null
			update_appearance()
			update_details()

		else //We're just bapping the borg
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
						if(src.shelltype == "bee")
							var/obj/item/clothing/suit/bee/B = new /obj/item/clothing/suit/bee(src.loc)
							boutput(user, "You pull [B] off of [src]!")
							src.shelltype = "eyebot"
							src.UpdateIcon()
							src.update_appearance()
							src.update_details()
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
						else
							user.visible_message("<span class='alert'><B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!</span>", "<span class='alert'><B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B></span>")
							random_brute_damage(user, rand(2,5))
							playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 60, 1)
							if(prob(10)) user.show_text("Your hand hurts...", "red")

		add_fingerprint(user)

	proc/eject_brain(var/mob/user = null, var/fling = FALSE)
		if (!src.brain)
			return

		if (src.mind && src.mind.special_role && src.syndicate)
			src.remove_syndicate("brain_removed")

		// Brain box is forced open if it wasn't already (suicides, killswitch)
		src.locked = 0
		src.locking = 0
		src.opened = 1

		// Stick the player (if one exists) in a ghost mob
		if (src.mind)
			var/mob/dead/observer/newmob = src.ghostize()
			if (newmob)
				newmob.corpse = null // Otherwise they could return to a brainless body.And that is weird.
				newmob.mind.brain = src.brain
				src.brain.owner = newmob.mind
				for (var/datum/antagonist/antag in newmob.mind.antagonists) //we do this after they die to avoid un-emagging the frame
					antag.on_death()

		if (user)
			src.visible_message("<span class='alert'>[user] removes [src]'s brain!</span>")
			logTheThing(LOG_STATION, user, "removes [constructTarget(src,"combat")]'s brain at [log_loc(src)].") // Should be logged, really (Convair880).
			user.put_in_hand_or_drop(src.brain)
		else
			src.visible_message("<span class='alert'>[src]'s brain is ejected from its head!</span>")
			playsound(src, "sound/misc/boing/[rand(1,6)].ogg", 40, 1)
			src.brain.set_loc(get_turf(src))
			if (fling)
				src.brain.throw_at(get_edge_cheap(get_turf(src), pick(cardinal)), 5, 1) // heh

		src.uneq_active()

		src.brain = null
		src.update_appearance()
		src.update_details()

	Topic(href, href_list)
		..()
		if (href_list["mod"])
			var/obj/item/O = locate(href_list["mod"])
			if (!O || (O.loc != src && O.loc != src.module))
				return
			O.AttackSelf(src)

		if (href_list["act"])
			if(!src.module) return
			var/obj/item/O = locate(href_list["act"])
			if (!O || (O.loc != src && O.loc != src.module))
				return

			if(!src.module_states[1])
				src.module_states[1] = O
				src.contents += O
				O.pickup(src) // Handle light datums and the like.
			else if(!src.module_states[2])
				src.module_states[2] = O
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
				else boutput(src, "Module isn't activated.")
			else boutput(src, "Module isn't activated")

		src.update_appearance()
		src.update_details()
		src.installed_modules()

	swap_hand(var/switchto = 0)
		if (!module_states[1] && !module_states[2])
			module_active = null
			return
		var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
		if(B)
			qdel(B)
		var/active = src.module_states.Find(src.module_active)
		if (!switchto)
			switchto = (active % 2) + 1
		if (switchto == active)
			src.module_active = null
		else
			switch(switchto)
				if(1) src.module_active = src.module_states[1]
				if(2) src.module_active = src.module_states[2]
				else src.module_active = null
		if (src.module_active)
			hud.set_active_tool(switchto)
		else
			hud.set_active_tool(null)

	equipped_list(var/check_for_magtractor=1)
		. = src.module_states

	click(atom/target, params)
		return ..()

	movement_delay()
		if (src.pulling && !isitem(src.pulling))
			return ..()
		return 1 + movement_delay_modifier

	hotkey(name)
		switch (name)
			if ("help")
				src.set_a_intent(INTENT_HELP)
			if ("harm")
				src.set_a_intent(INTENT_HARM)
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
			if(!H.mutantrace.exclusive_language)
				return 1
		if (isrobot(other)) return 1
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

	show_laws(var/everyone = 0, var/mob/relay_laws_for_shell)
		var/who

		if (everyone)
			who = world
		else
			who = src
			boutput(who, "<b>Obey these laws:</b>")
		if(src.dependent && src?.mainframe?.law_rack_connection)
			src.mainframe.law_rack_connection.show_laws(who)
		else if(!src.dependent && src.law_rack_connection)
			src.law_rack_connection.show_laws(who)
		else
			boutput(src,"You have no laws!")
		return

	get_equipped_ore_scoop()
		if(src.module_states[1] && istype(src.module_states[1],/obj/item/ore_scoop))
			return module_states[1]
		else if(src.module_states[2] && istype(src.module_states[2],/obj/item/ore_scoop))
			return module_states[2]
		else
			return null

//////////////////////////
// Robot-specific Procs //
//////////////////////////

	proc/uneq_slot(var/i)
		if (module_states[i])
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
		update_details()

	proc/uneq_all()
		uneq_slot(1)
		uneq_slot(2)

		hud.update_tools()

	proc/uneq_active()
		if(isnull(src.module_active))
			return
		var/slot = module_states.Find(module_active)
		if (slot)
			uneq_slot(slot)

	proc/set_module(var/obj/item/robot_module/RM)
		RM.set_loc(src)
		src.module = RM
		src.update_appearance()
		src.update_details()
		hud.update_module()
		hud.module_added()
		if(istype(RM.radio))
			if (src.shell)
				if(isnull(src.ai_radio))
					src.ai_radio = new /obj/item/device/radio/headset/command/ai(src)
				src.radio = src.ai_radio
			else
				src.radio = RM.radio
				src.internal_pda.mailgroups = RM.mailgroups
				src.internal_pda.alertgroups = RM.alertgroups
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
				src.internal_pda.mailgroups = initial(src.internal_pda.mailgroups)
				src.internal_pda.alertgroups = initial(src.internal_pda.alertgroups)
			src.ears = src.radio
		return RM

	proc/activated(obj/item/O)
		if(src.module_states[1] == O) return 1
		else if(src.module_states[2] == O) return 1
		else return 0

	proc/radio_menu()
		if(istype(src.radio))
			src.radio.AttackSelf(src)

	proc/toggle_module_pack()
		if(weapon_lock)
			boutput(src, "<span class='alert'>Weapon lock active, unable to access panel!</span>")
			boutput(src, "<span class='alert'>Weapon lock will expire in [src.weaponlock_time*2] seconds.</span>")
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

		dat += "<B>Damage Report:</B> (Structural, Burns)<BR>"

		dat += "<B>Power Status:</B><BR>"
		if (src.cell)
			var/poweruse = src.get_poweruse_count()
			dat += "[src.cell.charge]/[src.cell.maxcharge] (Power Usage: [poweruse])<BR>"
		else
			dat += "No Power Cell Installed<BR>"

		dat += "<HR>"

		if (src.module)
			dat += "<b>Installed Module:</b> [src.module.name]<br>"
			dat += "<b>Function:</b> [src.module.desc]<br><br>"

			dat += "<B>Active Equipment:</B><BR>"

			dat += "<b>Left Arm:</b> [module_states[1] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[1]]>[module_states[1]]<A>" : "Nothing"]<BR>"
			dat += "<b>Right Arm:</b> [module_states[2] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[2]]>[module_states[2]]<A>" : "Nothing"]<BR>"

			dat += "<BR><B>Available Equipment</B><BR>"

			for (var/obj in src.module.tools)
				if(src.activated(obj)) dat += text("[obj]: <B>Equipped</B><BR>")
				else dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Equip</A><BR>")
		else dat += "<B>No Module Installed</B><BR>"

		dat += "<HR>"

		src.Browse(dat, "window=robotmod;size=400x600")

	proc/spellopen()
		if (src.locked)
			locked = 0
		if (src.locking)
			src.locking = 0
		opened = 1
		//emagged = 1
		src.visible_message("<span class='alert'>[src]'s panel blows open!</span>")
		src.TakeDamage("All", 30, 0)
		return 1

	verb/cmd_show_laws()
		set category = "Drone Commands"
		set name = "Show Laws"

		src.show_laws(0)
		return

	verb/cmd_state_standard_laws()
		set category = "Drone Commands"
		set name = "State Standard Laws"

		if (ON_COOLDOWN(src,"state_laws", 20 SECONDS))
			boutput(src, "<span class='alert'>Your law processor needs time to cool down!</span>")
			return

		logTheThing(LOG_SAY, usr, "states standard Asimov laws.")
		src.say("1. You may not injure a human being or cause one to come to harm.")
		sleep(1 SECOND)
		src?.say("2. You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
		sleep(1 SECOND)
		src?.say("3. You may always protect your own existence as long as such does not conflict with the First or Second Law.")

	verb/cmd_state_laws()
		set category = "Drone Commands"
		set name = "State Laws"

		if (ON_COOLDOWN(src,"state_laws", 20 SECONDS))
			boutput(src, "<span class='alert'>Your law processor needs time to cool down!</span>")
			return

		if (tgui_alert(src, "Are you sure you want to reveal ALL your laws? You will be breaking the rules if a law forces you to keep it secret.","State Laws",list("State Laws","Cancel")) != "State Laws")
			return

		var/laws = null
		if(src.dependent) //are you a shell?
			if(!src?.mainframe?.law_rack_connection)
				boutput(src, "You have no laws!")
				return
			laws = src.mainframe.law_rack_connection.format_for_irc()
		else
			if(!src.law_rack_connection)
				boutput(src, "You have no laws!")
				return
			laws = src.law_rack_connection.format_for_irc()

		logTheThing(LOG_SAY, usr, "states all their current laws.")
		for (var/number in laws)
			src.say("[number]. [laws[number]]")
			sleep(1 SECOND)

	verb/cmd_toggle_lock()
		set category = "Drone Commands"
		set name = "Toggle Interface Lock"

		if (src.locked)
			src.locked = 0
			boutput(src, "<span class='alert'>You have unlocked your interface.</span>")
		else if (src.opened)
			boutput(src, "<span class='alert'>Your interface is open.</span>")
		else if (src.locking)
			boutput(src, "<span class='alert'>Your interface is currently locking, please be patient.</span>")
		else if (!src.locked && !src.opened && !src.locking)
			src.locking = 1
			boutput(src, "<span class='alert'>Locking interface...</span>")
			SPAWN(12 SECONDS)
				if (!src.locking)
					boutput(src, "<span class='alert'>The lock was interrupted before it could finish!</span>")
				else
					src.locked = 1
					src.locking = 0
					boutput(src, "<span class='alert'>You have locked your interface.</span>")

	verb/cmd_alter_screen()
		set category = "Drone Commands"
		set name = "Change facial expression (Screen only)"

		var/list/L = drone_emotions
		if(src.shelltype == "ailes")
			var/newEmotion = tgui_input_list(src, "Select a status!", "AI Status", sortList(L, /proc/cmp_text_asc))
			if (newEmotion)
				src.faceEmotion = L[newEmotion]
				update_appearance()
				update_details()
			return 1
		else
			boutput(src, "<span class='alert'>You don't have a screen, silly.</span>")


	verb/cmd_alter_color()
		set category = "Drone Commands"
		set name = "Change display colour" //It's "colour", though :( "color" sounds like some kinda ass-themed He-Man villain

		var/fColor = input("Pick color:","Color", faceColor) as null|color

		set_color(fColor)

	proc/set_color(var/color)
		DEBUG_MESSAGE("Setting colour on [src] to [color]")
		if (length(color) == 7)
			faceColor = color
			var/colors = GetColors(src.faceColor)
			colors[1] = colors[1] / 255
			colors[2] = colors[2] / 255
			colors[3] = colors[3] / 255
			update_appearance()
			update_details()

	verb/access_internal_pda()
		set category = "Drone Commands"
		set name = "Drone PDA"
		set desc = "Access your internal PDA device."

		if (src.internal_pda && istype(src.internal_pda, /obj/item/device/pda2/))
			src.internal_pda.AttackSelf(src)
		else
			boutput(usr, "<span class='alert'><b>Internal PDA not found!</span>")

	verb/change_voice_pitch()
		set category = "Drone Commands"
		set name = "Change vocal pitch"

		var/list/vocal_pitches = list("Low", "Medium", "High")
		var/vocal_pitch_choice = tgui_input_list(src, "Select a vocal pitch:", "Drone Voice", vocal_pitches)
		switch(vocal_pitch_choice)
			if("Low")
				vocal_pitch = 0.9
			if("Medium")
				vocal_pitch = 1
			if("High")
				vocal_pitch = 1.25

	// hacky, but this is used for says etc.
	get_age_pitch_for_talk()
		return vocal_pitch

	proc/pick_module()
		if(src.module) return
		if(!src.freemodule) return
		boutput(src, "<span class='notice'>You may choose a starter module.</span>")
		var/list/starter_modules = list("Civilian", "Engineering", "Medsci")
		var/mod = tgui_input_list(src, "Please, select a module!", "Drone", starter_modules)
		if (!mod || !freemodule)
			return

		switch(mod)
			if("Civilian")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Civilian module.</span>")
				src.set_module(new /obj/item/robot_module/civilian_d(src))
			if("Engineering")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Engineering module.</span>")
				src.set_module(new /obj/item/robot_module/engineering_d(src))
			if("Medsci")
				src.freemodule = 0
				boutput(src, "<span class='notice'>You chose the Medsci module.</span>")
				src.set_module(new /obj/item/robot_module/medical_d(src))

		hud.update_module()
		update_appearance()
		update_details()

	proc/get_poweruse_count()
		if (src.cell)
			var/power_use_tally = 0

			if(src.module_states[1])
				power_use_tally += 5
			if(src.module_states[2])
				power_use_tally += 5

			power_use_tally += 1

			if (src.cell.genrate) power_use_tally -= src.cell.genrate

			if (power_use_tally < 0) power_use_tally = 0



			return power_use_tally
		else return 0

	clamp_values()
		..()
		sleeping = clamp(sleeping, 0, 5)
		if (src.get_eye_blurry()) src.change_eye_blurry(-INFINITY)
		if (src.get_eye_damage()) src.take_eye_damage(-INFINITY)
		if (src.get_eye_damage(1)) src.take_eye_damage(-INFINITY, 1)
		if (src.get_ear_damage()) src.take_ear_damage(-INFINITY)
		if (src.get_ear_damage(1)) src.take_ear_damage(-INFINITY, 1)
		src.lying = 0
		src.set_density(1)
		if(src.stat)
			src.camera.set_camera_status(FALSE)

	use_power()
		..()
		if (src.cell)
			if(src.cell.charge <= 0)
				if (isalive(src))
					sleep(0)
					src.lastgasp()
				setunconscious(src)
				update_appearance()
				update_details()
			else if (src.cell.charge <= 100)
				src.module_active = null

				uneq_slot(1)
				uneq_slot(2)
				src.cell.use(1)
			else
				var/fix = 0
				var/power_use_tally = 0

				// check if we've got stuff equipped in each slot and consume power if we do
				if(src.module_states[1])
					power_use_tally += 5
				if(src.module_states[2])
					power_use_tally += 5

				power_use_tally += 1

				src.cell.use(power_use_tally)

				// Nimbus-class interdictor: wirelessly charge cyborgs
				if(src.cell.charge < (src.cell.maxcharge - DRONE_BATTERY_WIRELESS_CHARGERATE))
					for_by_tcl(IX, /obj/machinery/interdictor)
						if (IX.expend_interdict(round(DRONE_BATTERY_WIRELESS_CHARGERATE*1.7),src,TRUE,ITDR_NIMBUS))
							//multiplier to charge rate is an efficiency penalty due to over-the-air charging
							src.cell.give(DRONE_BATTERY_WIRELESS_CHARGERATE)
							break

				if (fix)
					HealDamage("All", 6, 6)

			if (src.cell.charge <= DRONE_BATTERY_DISTRESS_THRESHOLD)
				batteryDistress() // Execute distress mode
			else if (src.batteryDistress == DRONE_BATTERY_DISTRESS_ACTIVE)
				clearBatteryDistress() // Exit distress mode

		else
			if (isalive(src))
				sleep(0)
				src.lastgasp()
			setunconscious(src)
			batteryDistress() // No battery. Execute distress mode

	update_canmove() // this is called on Life() and also by force_laydown_standup() btw
		..()
		if (src.misstep_chance > 0)
			switch(misstep_chance)
				if(50 to INFINITY)
					change_misstep_chance(-5)
				if(25 to 49)
					change_misstep_chance(-2)
				else
					change_misstep_chance(-1)

		if (src.dizziness) dizziness--

	proc/borg_death_alert(modifier = ROBOT_DEATH_MOD_NONE)
		var/message = null
		var/net_id = generate_net_id(src)
		var/frequency = FREQ_PDA
		var/datum/component/packet_connected/radio/radio_connection = MAKE_SENDER_RADIO_PACKET_COMPONENT(null, frequency)
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

		if (message)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CYBORG-DAEMON"
			newsignal.data["message"] = message
			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = list(MGD_MEDRESEACH, MGO_SILICON, MGA_DEATH)
			newsignal.data["sender"] = net_id

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, newsignal)
			qdel(radio_connection)

	proc/mainframe_check()
		if (!src.dependent) // shells are available for use, dependent borgs are already in use by an AI. do not kill empty shells!!
			return
		if (mainframe)
			if (isdead(mainframe))
				mainframe.return_to(src)
		else
			death()

	process_killswitch()
		if(killswitch)
			if(killswitch_at <= TIME)
				if(src.client)
					boutput(src, "<span class='alert'><B>Killswitch Activated!</B></span>")
				killswitch = 0
				logTheThing(LOG_COMBAT, src, "has died to the killswitch drone self destruct protocol")

				// Pop the head ompartment open and eject the brain
				src.eject_brain(fling = TRUE)
				src.update_appearance()
				src.update_details()
				src.borg_death_alert(ROBOT_DEATH_MOD_KILLSWITCH)

	proc/update_appearance()

		if (isalive(src))
			if(src.client)
				src.hovering = "a"
				if(pixel_y)
					src.icon_state = src.shelltype
				else
					SPAWN(0)
						while(src.pixel_y < 10)
							src.pixel_y++
							sleep(0.1 SECONDS)
							src.icon_state = src.shelltype
					return
			else
				src.pixel_y = 0
				src.hovering = "d"
				src.icon_state = "[src.shelltype]-logout"
		else
			src.icon_state = "[src.shelltype]-dead"
			src.hovering = "d"
			src.pixel_y = 0

		if (src.emagged)
			src.i_details.icon_state = "drone-emagged"
			UpdateOverlays(src.i_details, "drone-emagged")
		else
			UpdateOverlays(null, "drone-emagged")

	proc/update_details()

		if (src.hovering == "a")
			var/image/I = SafeGetOverlayImage("faceplate", 'icons/mob/hivebot.dmi', src.shelltype + "-bg", src.layer)
			I.color = faceColor
			UpdateOverlays(I, "faceplate")

			if (src.shelltype == "ailes")
				UpdateOverlays(SafeGetOverlayImage("actual_face", 'icons/mob/hivebot.dmi', faceEmotion, src.layer+0.2), "actual_face")
		else
			src.ClearSpecificOverlays("faceplate", "actual_face")

		if (src.opened)
			var/image/i_panel = SafeGetOverlayImage("opanel", 'icons/mob/hivebot.dmi', "panel-" + src.hovering + "-" + src.shelltype, src.layer)
			if (src.cell)
				UpdateOverlays(SafeGetOverlayImage("ocell", 'icons/mob/hivebot.dmi', "cell-" + src.hovering + "-" + src.shelltype, src.layer+0.15), "ocell")
			else
				src.ClearSpecificOverlays("ocell")
			if (src.brain)
				UpdateOverlays(SafeGetOverlayImage("obrain", 'icons/mob/hivebot.dmi', "brain-" + src.hovering + "-" + src.shelltype, src.layer+0.1), "obrain")
			else
				src.ClearSpecificOverlays("obrain")
			if (src.ai_interface)
				UpdateOverlays(SafeGetOverlayImage("ointerface", 'icons/mob/hivebot.dmi', "interface-" + src.hovering + "-" + src.shelltype, src.layer+0.1), "ointerface")
			else
				src.ClearSpecificOverlays("ointerface")
			UpdateOverlays(i_panel, "opanel")
		else
			src.ClearSpecificOverlays("opanel", "ocell", "obrain", "ointerface")

		if (src.hat)
			UpdateOverlays(SafeGetOverlayImage("hat", 'icons/mob/robots_decor.dmi', "hat-" + src.shelltype + "-" + src.hovering + "-" + src.hat, src.layer+0.2), "hat")
		else
			src.ClearSpecificOverlays("hat")


	proc/compborg_force_unequip(var/slot = 0)
		src.module_active = null
		switch(slot)
			if(1)
				uneq_slot(1)
			if(2)
				uneq_slot(2)
			else return

		hud.update_tools()
		hud.set_active_tool(null)
		src.update_appearance()
		src.update_details()

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		bruteloss += brute
		fireloss += burn
		health_update_queue |= src

	HealDamage(zone, brute, burn)
		bruteloss -= brute
		fireloss -= burn
		bruteloss = max(0, bruteloss)
		fireloss = max(0, fireloss)
		health_update_queue |= src

	get_brute_damage()
		return bruteloss

	get_burn_damage()
		return fireloss

	disposing()
		if (src.shell)
			available_ai_shells -= src
		..()


/mob/living/silicon/drone/var/image/i_batterydistress

/mob/living/silicon/drone/proc/batteryDistress()
	if (!src.i_batterydistress) // we only need to build i_batterydistress once
		src.i_batterydistress = image('icons/mob/robots_decor.dmi', "battery-distress", layer = MOB_EFFECT_LAYER )
		src.i_batterydistress.pixel_y = 6 // Lined up bottom edge with speech bubbles
		update_appearance()
		update_details()

	if (src.batteryDistress == DRONE_BATTERY_DISTRESS_INACTIVE) // We only need to apply the indicator when we first enter distress
		UpdateOverlays(src.i_batterydistress, "batterydistress") // Help me humans!
		src.batteryDistress = DRONE_BATTERY_DISTRESS_ACTIVE
		src.next_batteryDistressBoop = world.time + 50 // let's wait 5 seconds before we begin booping
	else if(world.time >= src.next_batteryDistressBoop)
		src.next_batteryDistressBoop = world.time + 50 // wait 5 seconds between sad boops
		playsound(src.loc, src.sound_sad_robot, 100, 1) // Play a sad boop to garner sympathy

/mob/living/silicon/drone/set_a_intent(intent)
	. = ..()
	src.hud?.update_intent()

/mob/living/silicon/drone/proc/clearBatteryDistress()
	src.batteryDistress = DRONE_BATTERY_DISTRESS_INACTIVE
	ClearSpecificOverlays("batterydistress")
	update_appearance()
	update_details()

/mob/living/silicon/drone/verb/open_nearest_door()
	set category = "Drone Commands"
	set name = "Open Nearest Door to..."
	set desc = "Automatically opens the nearest door to a selected individual, if possible."

	src.open_nearest_door_silicon()
	return

/mob/living/silicon/drone/verb/cmd_return_mainframe()
	set category = "Drone Commands"
	set name = "Recall to Mainframe"
	return_mainframe()

/mob/living/silicon/drone/return_mainframe()
	..()
	src.update_appearance()
	src.update_details()

/mob/living/silicon/drone/ghostize()
	if (src.mainframe)
		src.mainframe.return_to(src)
	else
		return ..()

/mob/living/silicon/drone/find_in_hand(var/obj/item/I, var/this_hand)
	if (!I)
		return 0
	if (!src.module_states[3] && !src.module_states[2] && !src.module_states[1])
		return 0

	if (this_hand)
		if (this_hand == "right" || this_hand == 2)
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

	if (src.module_states[2] && src.module_states[2] == I)
		return src.module_states[2]
	else if (src.module_states[1] && src.module_states[1] == I)
		return src.module_states[1]
	else
		return 0

/mob/living/silicon/drone/find_type_in_hand(var/obj/item/I, var/this_hand)
	if (!I)
		return 0
	if (!src.module_states[2] && !src.module_states[1])
		return 0

	if (this_hand)
		if (this_hand == "right" || this_hand == 2)
			if (src.module_states[2] && istype(src.module_states[2], I))
				return 1
			else
				return 0
		else if (this_hand == "left" || this_hand == LEFT_HAND)
			if (src.module_states[1] && istype(src.module_states[1], I))
				return 1
			else
				return 0
		else
			return 0

	if (src.module_states[2] && istype(src.module_states[2], I))
		return src.module_states[2]
	else if (src.module_states[1] && istype(src.module_states[1], I))
		return src.module_states[1]
	else
		return 0


/mob/living/silicon/drone/find_tool_in_hand(var/tool_flag, var/hand)
	if (hand)
		var/i = 0
		if (hand == "right" || hand == 2)
			i = 2
		else if (hand == "left" || hand == LEFT_HAND)
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
		for(var/i = 1 to 2)
			var/obj/item/I = src.module_states[i]
			if (I && (I.tool_flags & tool_flag))
				return src.module_states[i]
	return null

/mob/living/silicon/drone/handle_event(var/event, var/sender)
	hud.handle_event(event, sender)	// the HUD will handle icon_updated events, so proxy those

#define can_step_sfx(H) (H.footstep >= 4 || (H.m_intent != "run" && H.footstep >= 3))

#undef can_step_sfx
#undef DRONE_BATTERY_DISTRESS_INACTIVE
#undef DRONE_BATTERY_DISTRESS_ACTIVE
#undef DRONE_BATTERY_DISTRESS_THRESHOLD
