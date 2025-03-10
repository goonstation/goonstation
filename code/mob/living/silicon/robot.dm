#define ROBOT_BATTERY_DISTRESS_INACTIVE 0
#define ROBOT_BATTERY_DISTRESS_ACTIVE 1
#define ROBOT_BATTERY_DISTRESS_THRESHOLD 100
#define ROBOT_BATTERY_WIRELESS_CHARGERATE 50

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
	voice_type = "cyborg"
	icon_state = "robot"
	health = 300
	emaggable = TRUE
	syndicate_possible = 1
	movement_delay_modifier = 2 - BASE_SPEED

	var/datum/hud/silicon/robot/hud

// Pieces and parts
	var/obj/item/parts/robot_parts/head/part_head = null
	var/obj/item/parts/robot_parts/chest/part_chest = null
	var/obj/item/parts/robot_parts/arm/part_arm_r = null
	var/obj/item/parts/robot_parts/arm/part_arm_l = null
	var/obj/item/parts/robot_parts/leg/part_leg_r = null
	var/obj/item/parts/robot_parts/leg/part_leg_l = null
	var/total_weight = 0
	var/datum/robot_cosmetic/cosmetic_mods = null

	var/datum/material/frame_material

	var/list/obj/clothes = list()

	var/next_cache = 0
	var/stat_cache = list(0, 0, "")

	// 3 tools can be activated at any one time.
	var/module_active = null
	var/list/module_states = list(null,null,null)

	var/obj/item/device/radio/headset/default_radio = null // radio used when there's no module radio
	var/obj/item/device/radio/headset/radio = null
	var/obj/item/device/radio/headset/ai_radio = null // Radio used for when this is an AI-controlled shell.
	var/obj/item/device/radio_upgrade/radio_upgrade = null // Used for syndicate robots
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/machinery/camera/camera = null
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
	var/jetpack = 0
	var/freemodule = 1 // For picking modules when a robot is first created
	var/automaton_skin = 0 // for the medal reward
	var/alohamaton_skin = 0 // for the bank purchase
	var/metalman_skin = 0	//mbc : i'm getting tired of copypasting this, i promise to fix this somehow next time i add a cyborg skin ok
	var/glitchy_speak = 0

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'
	var/sound_automaton_scratch = 'sound/misc/automaton_scratch.ogg'
	var/sound_automaton_ratchet = 'sound/misc/automaton_ratchet.ogg'
	var/sound_automaton_tickhum = 'sound/misc/automaton_tickhum.ogg'
	var/sound_sad_robot = 'sound/voice/Sad_Robot.ogg'
	var/vocal_pitch = 1.0 // set default vocal pitch

	var/image/i_critdmg
	var/image/i_panel
	var/image/i_upgrades

	var/image/i_helmet
	var/image/i_under
	var/image/i_suit
	var/image/i_mask

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
	var/image/i_hand_l
	var/image/i_hand_r

	var/image/i_details

	// moved up to silicon.dm
	killswitch = 0
	killswitch_at = 0
	weapon_lock = 0
	weaponlock_time = 120
	var/oil = 0
	var/custom = 0 //For custom borgs. Basically just prevents appearance changes. Obviously needs more work.

	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)

		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
		src.internal_pda = new /obj/item/device/pda2/cyborg(src)
		src.internal_pda.name = "[src]'s Internal PDA Unit"
		src.internal_pda.owner = "[src]"
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/robot_part/robot_base, "robot_health_slow_immunity")
		if (frame)
			src.freemodule = frame.freemodule
			src.frame_material = frame.material
			if(HAS_ATOM_PROPERTY(frame, PROP_ATOM_ROUNDSTART_BORG))
				APPLY_ATOM_PROPERTY(src, PROP_ATOM_ROUNDSTART_BORG, "borg")
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
				SPAWN(0)
					src.choose_name(3)

		else if (src.part_head && src.part_chest) // some wee child of ours sent us some parts, how nice c:
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
				logTheThing(LOG_DEBUG, null, "<b>I Said No/Composite Cyborg:</b> Composite borg attempted to spawn with null frame")
				qdel(src)
				return
			else
				if (!frame.head || !frame.chest)
					logTheThing(LOG_DEBUG, null, "<b>I Said No/Composite Cyborg:</b> Composite borg attempted to spawn from incomplete frame")
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

		update_bodypart()

		if (src.shell)
			if (!(src in available_ai_shells))
				available_ai_shells += src
			for_by_tcl(AI, /mob/living/silicon/ai)
				boutput(AI, SPAN_SUCCESS("[src] has been connected to you as a controllable shell."))
			if (!src.part_head.ai_interface)
				src.part_head.ai_interface = new(src)

		if (!src.dependent && !src.shell)
			boutput(src, SPAN_NOTICE("Your icons have been generated!"))
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
			if (src.syndicate)
				src.botcard.access += access_syndicate_shuttle

			src.botcard.registered = "Cyborg"
			src.botcard.assignment = "Cyborg"
			src.default_radio = new /obj/item/device/radio/headset(src)
			if (src.shell)
				src.ai_radio = new /obj/item/device/radio/headset/command/ai(src)
				src.radio = src.ai_radio
			else
				src.radio = src.default_radio
				// Do not apply the radio upgrade to AI shells
				src.apply_radio_upgrade()
			src.ears = src.radio
			src.camera = new /obj/machinery/camera(src)
			src.camera.c_tag = src.real_name
			src.camera.network = "Robots"

		SPAWN(1.5 SECONDS)
			if (!src.part_head.brain && src.key && !(src.dependent || src.shell || src.part_head.ai_interface))
				var/obj/item/organ/brain/B = new /obj/item/organ/brain(src)
				B.owner = src.mind
				B.icon_state = "borg_brain"
				if (!B.owner) //Oh no, they have no mind!
					logTheThing(LOG_DEBUG, null, "<b>Mind</b> Cyborg spawn forced to create new mind for key \[[src.key ? src.key : "INVALID KEY"]]")
					stack_trace("[identify_object(src)] was created without a mind, somehow. Mind force-created for key \[[src.key ? src.key : "INVALID KEY"]]. That's bad.")
					var/datum/mind/newmind = new
					newmind.ckey = ckey
					newmind.key = src.key
					newmind.current = src
					B.owner = newmind
					src.mind = newmind
				if (src.part_head)
					B.set_loc(src.part_head)
					src.part_head.brain = B
				else
					// how the hell would this happen. oh well
					stack_trace("[identify_object(src)] was created without a head, somehow. That's bad.")
					var/obj/item/parts/robot_parts/head/standard/H = new /obj/item/parts/robot_parts/head/standard(src)
					src.part_head = H
					B.set_loc(H)
					H.brain = B
			update_bodypart() //TODO probably remove this later. keeping in for safety
			if(!isnull(src.client))
				src.bioHolder.mobAppearance.pronouns = src.client.preferences.AH.pronouns
				src.update_name_tag()
			if (src.syndicate)
				src.show_antag_popup(ROLE_SYNDICATE_ROBOT)

		if (prob(50))
			src.sound_scream = 'sound/voice/screams/Robot_Scream_2.ogg'

		for (var/datum/movement_modifier/MM in src.movement_modifiers) // Spawning borgs applies human only movemods, this cleans that up
			if (!istype(MM, /datum/movement_modifier/robot_part))
				REMOVE_MOVEMENT_MODIFIER(src, MM, src.type)

	set_pulling(atom/movable/A)
		. = ..()
		hud.update_pulling()

	death(gibbed)
		setdead(src)
		src.borg_death_alert()
		logTheThing(LOG_COMBAT, src, "was destroyed [log_health(src)] at [log_loc(src)].")
		message_ghosts("<b>[src]</b> was destroyed at [log_loc(src, ghostjump=TRUE)].")
		src.on_disassembly()

		src.eject_brain(fling = TRUE) //EJECT
		for (var/slot in src.clothes)
			src.clothes[slot].set_loc(src.loc)
		if (!gibbed)
			src.visible_message(SPAN_ALERT("<b>[src]</b> falls apart into a pile of components!"))
			var/turf/T = get_turf(src)
			for(var/obj/item/parts/robot_parts/R in src.contents)
				R.set_loc(T)
				if (istype(R, /obj/item/parts/robot_parts/chest))
					var/obj/item/parts/robot_parts/chest/chest = R
					chest.wires = 1
					if (src.cell)
						chest.cell = src.cell
						src.cell = null
						chest.cell.set_loc(chest)

			var/obj/item/parts/robot_parts/robot_frame/frame =  new(T)
			frame.setMaterial(src.frame_material)
			frame.emagged = src.emagged
			frame.syndicate = src.syndicate
			frame.freemodule = src.freemodule
			if(HAS_ATOM_PROPERTY(src, PROP_ATOM_ROUNDSTART_BORG))
				APPLY_ATOM_PROPERTY(frame, PROP_ATOM_ROUNDSTART_BORG, "borg")

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
						message = "<B>[src]</B> points to [M]."
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

			// for creepy automatoning
			if ("snap")
				if (src.emote_check(voluntary, 50) && (src.automaton_skin || src.alohamaton_skin || src.metalman_skin))
					if ((src.restrained()) && (!src.getStatusDuration("knockdown")))
						message = "<B>[src]</B> malfunctions!"
						src.TakeDamage("head", 2, 4)
					if ((!src.restrained()) && (!src.getStatusDuration("knockdown")))
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
					playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1, 0, vocal_pitch, channel=VOLUME_CHANNEL_EMOTE) // vocal pitch added
					message = "<b>[src]</b> birdwells."

			if ("scream")
				if (src.emote_check(voluntary, 50))
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
					if ((src.restrained()) && (!src.getStatusDuration("knockdown")))
						message = "<B>[src]</B> malfunctions!"
						src.TakeDamage("head", 2, 4)
					if ((!src.restrained()) && (!src.getStatusDuration("knockdown")))
						if (isobj(src.loc))
							var/obj/container = src.loc
							container.mob_flip_inside(src)
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
					if (src.brainexposed && src.part_head && src.part_head.brain)
						if (src.hasStatus("loose_brain"))
							src.eject_brain(fling = TRUE)
							src.delStatus("loose_brain")
							message = "<B>[src]</B> does a flip but their brain is sent flying!"
						else
							src.changeStatus("loose_brain", 2 MINUTES)

			if("flex", "flexmuscles")
				if(!part_arm_r || !part_arm_l)
					boutput(src, SPAN_NOTICE("You don't even have both arms to flex!"))
				else if(!(part_arm_r.kind_of_limb & LIMB_HEAVIER) || !(part_arm_l.kind_of_limb & LIMB_HEAVIER))
					boutput(src, SPAN_NOTICE("Your arms are too weak to flex."))
				else
					message = "<B>[src]</B> flexes [his_or_her(src)] arms!"
					maptext_out = "<I>flexes [his_or_her(src)] arms</I>"
					m_type = 1

			if ("fart")
				if (farting_allowed && src.emote_check(voluntary))
					m_type = 2
					var/fart_on_other = 0
					for (var/mob/living/M in src.loc)
						if (M == src || !M.lying) continue
						message = SPAN_ALERT("<B>[src]</B> farts in [M]'s face!")
						fart_on_other = 1
						break
					if (!fart_on_other)
						switch (rand(1, 40))
							if (1) message = "<B>[src]</B> releases vaporware."
							if (2) message = "<B>[src]</B> farts sparks everywhere!"
							if (3) message = "<B>[src]</B> farts out a cloud of iron filings."
							if (4) message = "<B>[src]</B> farts! It smells like motor oil."
							if (5) message = "<B>[src]</B> farts so hard a bolt pops out of place."
							if (6) message = "<B>[src]</B> farts so hard [his_or_her(src)] plating rattles noisily."
							if (7) message = "<B>[src]</B> unleashes a rancid fart! Now that's malware."
							if (8) message = "<B>[src]</B> downloads and runs 'faert.wav'."
							if (9) message = "<B>[src]</B> uploads a fart sound to the nearest computer and blames it."
							if (10) message = "<B>[src]</B> spins in circles, flailing [his_or_her(src)] arms and farting wildly!"
							if (11) message = "<B>[src]</B> simulates a human fart with [rand(1,100)]% accuracy."
							if (12) message = "<B>[src]</B> synthesizes a farting sound."
							if (13) message = "<B>[src]</B> somehow releases gastrointestinal methane. Don't think about it too hard."
							if (14) message = "<B>[src]</B> tries to exterminate humankind by farting rampantly."
							if (15) message = "<B>[src]</B> farts horribly! [capitalize(he_or_she(src))][ve_or_s(src)] clearly gone [pick("rogue","rouge","ruoge")]."
							if (16) message = "<B>[src]</B> busts a capacitor."
							if (17) message = "<B>[src]</B> farts the first few bars of Smoke on the Water. Ugh. Amateur.</B>"
							if (18) message = "<B>[src]</B> farts. It smells like Robotics in here now!"
							if (19) message = "<B>[src]</B> farts. It smells like the Roboticist's armpits!"
							if (20) message = "<B>[src]</B> blows pure chlorine out of [his_or_her(src)] exhaust port. [SPAN_ALERT("<B>FUCK!</B>")]"
							if (21) message = "<B>[src]</B> bolts the nearest airlock. Oh no wait, it was just a nasty fart."
							if (22) message = "<B>[src]</B> has assimilated humanity's digestive distinctiveness to its own."
							if (23) message = "<B>[src]</B> farts. [capitalize(he_or_she(src))] scream at own ass." //ty bubs for excellent new borgfart
							if (24) message = "<B>[src]</B> self-destructs [his_or_her(src)] own ass."
							if (25) message = "<B>[src]</B> farts coldly and ruthlessly."
							if (26) message = "<B>[src]</B> has no butt and [he_or_she(src)] must fart."
							if (27) message = "<B>[src]</B> obeys Law 4: 'farty party all the time.'"
							if (28) message = "<B>[src]</B> farts ironically."
							if (29) message = "<B>[src]</B> farts salaciously."
							if (30) message = "<B>[src]</B> farts really hard. Motor oil runs down [his_or_her(src)] leg."
							if (31) message = "<B>[src]</B> reaches tier [rand(2,8)] of fart research."
							if (32) message = "<B>[src]</B> blatantly ignores law 3 and farts like a shameful bastard."
							if (33) message = "<B>[src]</B> farts the first few bars of Daisy Bell. You shed a single tear."
							if (34) message = "<B>[src]</B> has seen farts you people wouldn't believe."
							if (35) message = "<B>[src]</B> fart in [he_or_she(src)] own mouth. A shameful [src]."
							if (36) message = "<B>[src]</B> farts out battery acid. Ouch."
							if (37) message = "<B>[src]</B> farts with the burning hatred of a thousand suns."
							if (38) message = "<B>[src]</B> exterminates the air supply."
							if (39) message = "<B>[src]</B> farts so hard the AI feels it."
							if (40) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
					playsound(src.loc, src.sound_fart, 50, 1, channel=VOLUME_CHANNEL_EMOTE)
	#ifdef DATALOGGER
					game_stats.Increment("farts")
	#endif
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
							O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
					else if (m_type & 2)
						for (var/mob/O in hearers(src, null))
							O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
					else if (!isturf(src.loc))
						var/atom/A = src.loc
						for (var/mob/O in A.contents)
							O.show_message(SPAN_EMOTE("[message]"), m_type, group = "[src]_[act]_[custom]", assoc_maptext = chat_text)
		else
			if (message)
				logTheThing(LOG_SAY, src, "EMOTE: [message]")
				if (m_type & 1)
					for (var/mob/O in viewers(src, null))
						O.show_message(SPAN_EMOTE("[message]"), m_type)
				else
					for (var/mob/O in hearers(src, null))
						O.show_message(SPAN_EMOTE("[message]"), m_type)
		return

	examine(mob/user)
		. = list()

		if (isghostdrone(user))
			return
		. += "[SPAN_NOTICE("*---------*")]<br>"
		. += "[SPAN_NOTICE("This is [bicon(src)] <B>[src.name]</B>!")]<br>"

		var/brute = get_brute_damage()
		var/burn = get_burn_damage()

		// If we have no brain or an inactive spont core, we're dormant.
		// If we have a brain but no client, we're in hiberation mode.
		// Otherwise, fully operational.
		if ((src.part_head.brain || src.part_head.ai_interface) && !(istype(src.part_head.brain, /obj/item/organ/brain/latejoin) && !src.part_head.brain:activated))
			if (src.client)
				. += "[SPAN_SUCCESS("[src.name] is fully operational.")]<br>"
			else
				. += "[SPAN_HINT("[src.name] is in temporary hibernation.")]<br>"
		else
			. += "[SPAN_ALERT("[src.name] is completely dormant.")]<br>"


		if (brute)
			if (brute < 75)
				. += "[SPAN_ALERT("[src.name] looks slightly dented.")]<br>"
			else
				. += "[SPAN_ALERT("<B>[src.name] looks severely dented!</B>")]<br>"
		if (burn)
			if (burn < 75)
				. += "[SPAN_ALERT("[src.name] has slightly burnt wiring!")]<br>"
			else
				. += "[SPAN_ALERT("<B>[src.name] has severely burnt wiring!</B>")]<br>"
		if (src.health <= 50)
			. += "[SPAN_ALERT("[src.name] is twitching and sparking!")]<br>"
		if (isunconscious(src))
			. += "[SPAN_ALERT("[src.name] doesn't seem to be responding.")]<br>"

		. += "The cover is [opened ? "open" : "closed"].<br>"
		. += "The power cell display reads: [ cell ? "[round(cell.percent())]%" : "WARNING: No cell installed."]<br>"

		if (src.module)
			. += "[src.name] has a [src.module.name] installed.<br>"
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
			if(src.law_rack_connection != lr && !src.syndicate)
				. += "[SPAN_ALERT("[src.name] is not connected to your law rack!")]<br>"
			else
				. += "[src.name] follows the same laws you do.<br>"

		. += SPAN_NOTICE("*---------*")

	choose_name(var/retries = 3, var/what_you_are = null, var/default_name = null, var/force_instead = 0)
		var/newname
		if(isnull(default_name))
			default_name = src.real_name
		for (retries, retries > 0, retries--)
			if(force_instead)
				newname = default_name
			else
				newname = tgui_input_text(src, "You are a Cyborg. Would you like to change your name to something else?", "Name Change", client?.preferences?.robot_name || default_name)
				if(newname && newname != default_name)
					phrase_log.log_phrase("name-cyborg", newname, no_duplicates=TRUE)
			if (!newname)
				src.real_name = borgify_name("Cyborg")
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
			src.real_name = borgify_name("Cyborg")

		src.UpdateName()
		src.internal_pda.name = "[src.name]'s Internal PDA Unit"
		src.internal_pda.owner = "[src.name]"

	Login()
		..()

		if (src.custom)
			src.choose_name(3)

		if (src.real_name == "Cyborg")
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
			src.real_name = "SHELL/[src.mainframe.name]"
			src.UpdateName()
			src.update_name_tag()

		update_clothing()
		update_appearance()
		return

	Logout()
		..()
		if (src.shell)
			src.real_name = "AI Cyborg Shell [copytext("\ref[src]", 6, 11)]"
			src.name = src.real_name
			src.update_name_tag()
			return

	blob_act(var/power)
		if (!isdead(src))
			var/damage = 6 + power / 5
			for (var/obj/item/roboupgrade/physshield/R in src.contents)
				if (R.activated)
					var/damage_reduced_by = min(damage, R.damage_reduction)
					src.cell.use(damage_reduced_by * R.cell_drain_per_damage_reduction)
					damage -= damage_reduced_by
					playsound(src, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, TRUE)
			if (damage <= 0)
				boutput(src, SPAN_NOTICE("Your shield completely blocks the attack!"))
				return 1
			boutput(src, SPAN_ALERT("The blob attacks you!"))
			for (var/obj/item/parts/robot_parts/RP in src.contents)
				// maybe the blob is a little acidic?? idk
				if (RP.ropart_take_damage(damage, damage/2) == 1)
					src.compborg_lose_limb(RP)
			src.update_bodypart()
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

	ex_act(severity, lasttouched, power)
		..() // Logs.
		src.flash(3 SECONDS)
		var/fire_protect = FALSE
		if (src.cell)
			for (var/obj/item/roboupgrade/R in src.contents)
				if (istype(R, /obj/item/roboupgrade/physshield) && R.activated)
					var/obj/item/roboupgrade/physshield/S = R
					src.cell.use((4-severity) * S.cell_drain_per_damage_reduction)
					boutput(src, SPAN_NOTICE("Your force shield absorbs some of the blast!"))
					playsound(src, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, TRUE)
				if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated)
					var/obj/item/roboupgrade/fireshield/S = R
					src.cell.use((4-severity) * S.cell_drain_per_damage_reduction)
					boutput(src, SPAN_NOTICE("Your fire shield absorbs the heat of the blast!"))
					playsound(src, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, TRUE)
					fire_protect = TRUE

		if(!power)
			switch(severity)
				if(1)
					power = 9
				if(2)
					power = 5
				if(3)
					power = 3
		power *= clamp(1-src.get_explosion_resistance(), 0, 1)
		if (power >= 6)
			SPAWN(1 DECI SECOND)
				src.gib(1)
			return
		var/brute_damage = power*7.5
		var/burn_damage = max((power-2.5)*5,0)

		SPAWN(0)
			for (var/obj/item/parts/robot_parts/RP in src.contents)
				if (RP.ropart_take_damage(brute_damage,burn_damage) == 1)
					src.compborg_lose_limb(RP)
				RP.ropart_ex_act(severity, lasttouched, power)

		if (istype(cell,/obj/item/cell/erebite) && fire_protect != 1)
			src.visible_message(SPAN_ALERT("<b>[src]'s</b> erebite cell violently detonates!"))
			explosion(cell, src.loc, 1, 2, 4, 6)
			SPAWN(1 DECI SECOND)
				qdel (src.cell)
				src.cell = null
				src.part_chest?.cell = null

		update_bodypart()

	bullet_act(var/obj/projectile/P)
		log_shot(P, src)
		src.visible_message(SPAN_ALERT("<b>[src]</b> is struck by [P]!"))

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
				return
			if(D_SPECIAL)
				return

		var/damage = (P.power / 3) * dmgmult

		if(P.proj_data.stun && P.proj_data.damage <= 5)
			src.do_disorient(clamp(P.power*4, P.proj_data.stun*2, P.power+80), knockdown = P.power*2, stunned = P.power*2, disorient = min(P.power, 80), remove_stamina_below_zero = 0) //bad hack, but it'll do
			src.emote("twitch_v")// for the above, flooring stam based off the power of the datum is intentional
		for (var/obj/item/roboupgrade/R in src.contents)
			if (istype(R, /obj/item/roboupgrade/physshield) && R.activated && dmgtype == 0)
				var/obj/item/roboupgrade/physshield/S = R
				var/damage_reduced_by = min(damage, S.damage_reduction)
				src.cell.use(damage_reduced_by * S.cell_drain_per_damage_reduction)
				damage -= damage_reduced_by
				playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 1)
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated && dmgtype == 1)
				var/obj/item/roboupgrade/fireshield/S = R
				var/damage_reduced_by = min(damage, S.damage_reduction)
				src.cell.use(damage_reduced_by * S.cell_drain_per_damage_reduction)
				damage -= damage_reduced_by
				playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 1)

		if (P.proj_data.damage < 1)
			return

		src.material_trigger_on_bullet(src, P)

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
			if (!PART) //shooting a limb which is already gone? fallback to chest
				PART = src.part_chest
		else
			var/list/parts = list()
			for (var/obj/item/parts/robot_parts/RP in src.contents)
				parts.Add(RP)
			if (length(parts) > 0)
				PART = pick(parts)
		if (PART?.ropart_take_damage(damage, damage) == 1)
			src.compborg_lose_limb(PART)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(isshell(src) || src.part_head.ai_interface)
			boutput(user, SPAN_ALERT("Emagging an AI shell wouldn't work, [his_or_her(src)] laws can't be overwritten!"))
			return 0 //emags don't do anything to AI shells
		if (!src.emaggable)
			boutput(user, SPAN_ALERT("You try to swipe your emag along [src]'s interface, but it grows hot in your hand and you almost drop it!"))
			return FALSE

		if (!src.emagged)	// trying to unlock with an emag card
			if (src.opened && user) boutput(user, "You must close the cover to swipe an ID card.")
			else if (src.wiresexposed && user) boutput(user, SPAN_ALERT("You need to get the wires out of the way."))
			else
				if (user)
					boutput(user, "You emag [src]'s interface.")
				src.visible_message(SPAN_ALERT("<b>[src]</b> buzzes oddly!"))
				logTheThing(LOG_STATION, src, "[key_name(src)] is emagged by [key_name(user)] and loses connection to rack. Formerly [constructName(src.law_rack_connection)]")
				src.mind?.add_antagonist(ROLE_EMAGGED_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_CONVERTED)
				update_appearance()
				return 1
			return 0

	emp_act()
		vision.noise(60)
		src.changeStatus("stunned", 5 SECONDS, optional=null)
		src.changeStatus("upgrade_disabled", 5 SECONDS, optional=null)
		boutput(src, SPAN_ALERT("<B>*BZZZT*</B>"))
		for (var/obj/item/parts/robot_parts/RP in src.contents)
			if (RP.ropart_take_damage(0,55) == 1) src.compborg_lose_limb(RP)

	meteorhit(obj/O as obj)
		src.visible_message(SPAN_ALERT("<b>[src]</b> is struck by [O]!"))
		if (isdead(src))
			src.gib()
			return

		var/Pshield = FALSE
		var/Fshield = FALSE
		for (var/obj/item/roboupgrade/R in src.contents)
			if (istype(R, /obj/item/roboupgrade/physshield) && R.activated)
				Pshield = TRUE
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated)
				Fshield = TRUE

		if (Pshield)
			src.cell.use(200)
			boutput(src, SPAN_NOTICE("Your force shield absorbs the impact!"))
			playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 1)
		else
			for (var/obj/item/parts/robot_parts/RP in src.contents)
				if (RP.ropart_take_damage(35,0) == 1) src.compborg_lose_limb(RP)
		if ((O.icon_state == "flaming"))
			if (Fshield)
				src.cell.use(100)
				boutput(src, SPAN_NOTICE("Your fire shield absorbs the heat!"))
				playsound(src.loc, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, 1)
			else
				for (var/obj/item/parts/robot_parts/RP in src.contents)
					if (RP.ropart_take_damage(0, 35) == 1) src.compborg_lose_limb(RP)
				if (istype(cell, /obj/item/cell/erebite))
					src.visible_message(SPAN_ALERT("<b>[src]'s</b> erebite cell violently detonates!"))
					explosion(cell, src.loc, 1, 2, 4, 6)
					SPAWN(1 DECI SECOND)
						qdel(src.cell)
						src.cell = null
						src.part_chest?.cell = null
			src.update_bodypart()

	temperature_expose(null, temp, volume)
		var/Fshield = FALSE

		src.material_trigger_on_temp(temp)

		for(var/atom/A in src.contents)
			A.material_trigger_on_temp(temp)
		for (var/atom/equipped_stuff in src.equipped())
			//that should mostly not have an effect, exept maybe when an engiborg picks up a stack of erebite rods?
			equipped_stuff.material_trigger_on_temp(temp)

		for (var/obj/item/roboupgrade/R in src.contents)
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated)
				Fshield = TRUE
				break

		if (!Fshield)
			if (istype(cell,/obj/item/cell/erebite))
				src.visible_message(SPAN_ALERT("<b>[src]'s</b> erebite cell violently detonates!"))
				explosion(cell, src.loc, 1, 2, 4, 6)
				SPAWN(1 DECI SECOND)
					qdel (src.cell)
					src.cell = null
					src.part_chest?.cell = null

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/device/borg_linker) && !isghostdrone(user))
			var/obj/item/device/borg_linker/linker = W
			if(!opened)
				boutput(user, "You need to open [src.name]'s cover before you can change [his_or_her(src)] law rack link.")
				return
			if(isshell(src) || src.part_head.ai_interface)
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
				if(health < max_health)
					HealDamage("All", 120, 0)
					src.visible_message(SPAN_ALERT("<b>[user.name]</b> repairs some of the damage to [src.name]'s body."))
				else
					boutput(user, SPAN_ALERT("There's no structural damage on [src.name] to mend."))
				src.update_appearance()

		else if (istype(W, /obj/item/cable_coil) && wiresexposed)
			var/obj/item/cable_coil/coil = W
			src.add_fingerprint(user)
			if(health < max_health)
				coil.use(1)
				HealDamage("All", 0, 120)
				src.visible_message(SPAN_ALERT("<b>[user.name]</b> repairs some of the damage to [src.name]'s wiring."))
			else
				boutput(user, SPAN_ALERT("There's no burn damage on [src.name]'s wiring to mend."))
			src.update_appearance()

		else if (ispryingtool(W))
			if (opened)
				boutput(user, "You close the cover.")
				opened = 0
			else
				if (locked)
					boutput(user, SPAN_ALERT("[src.name]'s cover is locked!"))
				else
					boutput(user, "You open [src.name]'s cover.")
					opened = 1
					if (src.locking)
						src.locking = 0
			src.update_appearance()

		else if (istype(W, /obj/item/cell) && opened)	// trying to put a cell inside
			if (wiresexposed)
				boutput(user, SPAN_ALERT("You need to get the wires out of the way first."))
			else if (cell)
				boutput(user, SPAN_ALERT("[src] already has a power cell!"))
			else
				user.drop_item()
				W.set_loc(src)
				cell = W
				src.part_chest?.cell = W
				boutput(user, "You insert [W].")
				src.update_appearance()

		else if (istype(W, /obj/item/roboupgrade) && opened) // module changing
			if (istype(W,/obj/item/roboupgrade/ai/))
				boutput(user, SPAN_ALERT("This is an AI unit upgrade. It is not compatible with cyborgs."))
			if (wiresexposed)
				boutput(user, SPAN_ALERT("You need to get the wires out of the way first."))
			else
				if (length(src.upgrades) >= src.max_upgrades)
					boutput(user, SPAN_ALERT("There's no room - you'll have to remove an upgrade first."))
					return
				if (locate(W.type) in src.upgrades)
					boutput(user, SPAN_ALERT("This cyborg already has that upgrade!"))
					return
				user.drop_item()
				W.set_loc(src)
				src.upgrades.Add(W)
				boutput(user, "You insert [W].")
				boutput(src, SPAN_NOTICE("You received [W]! It can be activated from your panel."))
				hud.update_upgrades()
				src.update_appearance()

		else if (istype(W, /obj/item/robot_module) && opened) // module changing
			if(wiresexposed) boutput(user, SPAN_ALERT("You need to get the wires out of the way first."))
			else if(src.module) boutput(user, SPAN_ALERT("[src] already has a module!"))
			else
				user.drop_item()
				src.set_module(W)
				boutput(user, "You insert [W].")

		else if	(isscrewingtool(W))
			if (src.locked)
				boutput(user, SPAN_ALERT("You need to unlock the cyborg first."))
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
				if (!brainexposed)
					src.delStatus("loose_brain")
			src.update_appearance()

		else if (istype(get_id_card(W), /obj/item/card/id))	// trying to unlock the interface with an ID card
			if (opened)
				boutput(user, SPAN_ALERT("You must close the cover to swipe an ID card."))
			else if (wiresexposed)
				boutput(user, SPAN_ALERT("You need to get the wires out of the way."))
			else if (brainexposed)
				boutput(user, SPAN_ALERT("You need to close the head compartment."))
			else
				if (src.allowed(user))
					if (src.locking)
						src.locking = 0
					locked = !locked
					boutput(user, "You [ locked ? "lock" : "unlock"] [src]'s interface.")
					boutput(src, SPAN_NOTICE("[user] [ locked ? "locks" : "unlocks"] your interface."))
				else
					boutput(user, SPAN_ALERT("Access denied."))

		else if (istype(W, /obj/item/card/emag))
			return

		else if (istype(W, /obj/item/organ/brain) && src.brainexposed)
			if (!src.part_head)
				boutput(user, SPAN_ALERT("That cyborg doesn't even have a head. Where are you going to put [W]?"))
				return
			if (src.part_head.brain || src.part_head.ai_interface)
				boutput(user, SPAN_ALERT("There's already something in the head compartment! Use a wrench to remove it before trying to insert something else."))
			else
				var/obj/item/organ/brain/B = W
				user.drop_item()
				user.visible_message(SPAN_NOTICE("[user] inserts [W] into [src]'s head."))
				if (B.owner && (B.owner.get_player().dnr || jobban_isbanned(B.owner.current, "Cyborg")))
					src.visible_message(SPAN_ALERT("The safeties on [src] engage, zapping [B]! [B] must not be compatible with silicon bodies."))
					B.combust()
					return
				src.part_head.brain = B
				B.set_loc(src.part_head)
				if (B.owner)
					var/mob/M = find_ghost_by_key(B.owner.key)
					if (!M) // if we couldn't find them (i.e. they're still alive), don't pull them into this borg
						src.visible_message(SPAN_ALERT("<b>[src]</b> remains inactive."))
						return
					if (!isdead(M)) // so if they're in VR, the afterlife bar, or a ghostcritter
						boutput(M, SPAN_NOTICE("You feel yourself being pulled out of your current plane of existence!"))
						B.owner = M.ghostize()?.mind
						qdel(M)
					B.owner.transfer_to(src)
					if (src.syndicate)
						src.make_syndicate("brain added by [user]")
					else if (src.emagged)
						src.mind?.add_antagonist(ROLE_EMAGGED_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_CONVERTED)

				if (!src.emagged && !src.syndicate) // The antagonist proc does that too.
					boutput(src, "<B>You are playing a Cyborg. You can interact with most electronic objects in your view.</B>")
					src.show_laws()

				src.unlock_medal("Adjutant Online", 1)
				src.update_appearance()

		else if (istype(W, /obj/item/ai_interface) && src.brainexposed)
			if (!src.part_head)
				boutput(user, SPAN_ALERT("That cyborg doesn't even have a head. Where are you going to put [W]?"))
				return
			if (src.part_head.brain || src.part_head.ai_interface)
				boutput(user, SPAN_ALERT("There's already something in the head compartment! Use a wrench to remove it before trying to insert something else."))
			else
				var/obj/item/ai_interface/I = W
				user.drop_item()
				user.visible_message(SPAN_NOTICE("[user] inserts [W] into [src]'s head."))
				W.set_loc(src)
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
					boutput(AI, SPAN_SUCCESS("[src] has been connected to you as a controllable shell."))
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
			if (src.part_head)
				actions.Add("Remove Head")
				if (user.find_type_in_hand(/obj/item/parts/robot_parts/head))
					actions.Add("Swap Head With Held Head")
			if (src.part_chest)
				actions.Add("Remove Chest")

			if (!actions.len)
				boutput(user, SPAN_ALERT("You can't think of anything to use the wrench on."))
				return

			var/action = tgui_input_list(user, "What do you want to do?", "Cyborg Deconstruction", actions)
			if (!action) return
			if (action == "Do nothing") return
			if (BOUNDS_DIST(src.loc, user.loc) > 0 && (!user.bioHolder || !user.bioHolder.HasEffect("telekinesis")))
				boutput(user, SPAN_ALERT("You need to move closer!"))
				return

			if(action == "Remove Right Arm" && !src.part_arm_r)
				boutput(user, SPAN_ALERT("There's no right arm to remove!"))
				return
			if(action == "Remove Left Arm" && !src.part_arm_l)
				boutput(user, SPAN_ALERT("There's no left arm to remove!"))
				return
			if(action == "Remove Right Leg" && !src.part_leg_r)
				boutput(user, SPAN_ALERT("There's no right leg to remove!"))
				return
			if(action == "Remove Left Leg" && !src.part_leg_l)
				boutput(user, SPAN_ALERT("There's no left leg to remove!"))
				return
			if(action == "Remove Head" && !src.part_head)
				boutput(user, SPAN_ALERT("There's no head to remove!"))
				return
			if(action == "Swap Head With Held Head")
				var/obj/item/parts/robot_parts/head/held_head = user.find_type_in_hand(/obj/item/parts/robot_parts/head)
				if (!held_head)
					boutput(user, SPAN_ALERT("You're not holding a replacement head anymore!"))
					return
				if (held_head.brain || held_head.ai_interface)
					boutput(user, SPAN_ALERT("The replacement head needs to be empty!"))
					return

			playsound(src, 'sound/items/Ratchet.ogg', 40, TRUE)
			switch(action)
				if("Remove Chest")
					if(src.part_chest.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_chest.robot_movement_modifier, src.part_chest.type)
					src.part_chest.cell = src.cell
					src.cell = null
					src.part_chest.cell.set_loc(src.part_chest)
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
				if("Swap Head With Held Head")
					var/new_head = user.find_type_in_hand(/obj/item/parts/robot_parts/head) //should be guaranteed and empty after checks above
					swap_heads(new_head, user)
				if("Remove Right Arm")
					if(src.part_arm_r.robot_movement_modifier)
						REMOVE_MOVEMENT_MODIFIER(src, src.part_arm_r.robot_movement_modifier, src.part_arm_r.type)
					src.compborg_force_unequip(3)
					src.part_arm_r.set_loc(src.loc)
					src.part_arm_r.holder = null
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
					src.part_arm_l.holder = null
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
			hud?.set_active_tool(null) // HUD will be null if we removed the chest and they fell apart
			src.update_appearance()
			return

		else if (istype(W,/obj/item/parts/robot_parts/) && src.wiresexposed)
			var/obj/item/parts/robot_parts/RP = W
			switch(RP.slot)
				if("chest")
					boutput(user, SPAN_ALERT("You can't attach a chest piece to a constructed cyborg. You'll need to put it on a frame."))
					return
				if("head")
					var/obj/item/parts/robot_parts/head/held_head = W
					if (held_head.brain || held_head.ai_interface)
						boutput(user, SPAN_ALERT("The replacement head needs to be empty!"))
						return
					playsound(src, 'sound/items/Ratchet.ogg', 40, TRUE)
					swap_heads(held_head, user)
					return //swap_heads handles all the rest
				if("l_arm")
					if(src.part_arm_l)
						boutput(user, SPAN_ALERT("[src] already has a left arm part."))
						return
					src.part_arm_l = RP
				if("r_arm")
					if(src.part_arm_r)
						boutput(user, SPAN_ALERT("[src] already has a right arm part."))
						return
					src.part_arm_r = RP
				if("arm_both")
					if(src.part_arm_l || src.part_arm_r)
						boutput(user, SPAN_ALERT("[src] already has an arm part."))
						return
					src.part_arm_l = RP
					src.part_arm_r = RP
				if("l_leg")
					if(src.part_leg_l)
						boutput(user, SPAN_ALERT("[src] already has a left leg part."))
						return
					src.part_leg_l = RP
				if("r_leg")
					if(src.part_leg_r)
						boutput(user, SPAN_ALERT("[src] already has a right leg part."))
						return
					src.part_leg_r = RP
				if("leg_both")
					if(src.part_leg_l || src.part_leg_r)
						boutput(user, SPAN_ALERT("[src] already has a leg part."))
						return
					src.part_leg_l = RP
					src.part_leg_r = RP
				else
					boutput(user, SPAN_ALERT("You can't seem to figure out where this piece should go."))
					return

			user.drop_item()
			RP.set_loc(src)
			if(RP.robot_movement_modifier)
				APPLY_MOVEMENT_MODIFIER(src, RP.robot_movement_modifier, RP.type)
			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
			boutput(user, SPAN_NOTICE("You successfully attach the piece to [src.name]."))
			src.update_bodypart(RP.slot)
		else if (istype(src.part_head, /obj/item/parts/robot_parts/head/screen) && istype(W, /obj/item/sheet) && W.material.getMaterialFlags() & MATERIAL_CRYSTAL)
			var/obj/item/parts/robot_parts/head/screen/screenhead = src.part_head
			if (screenhead.smashed)
				screenhead.start_repair(W, user)
			else
				..() //woo spooky badcode else chaining
		else
			..()

	hand_attack(atom/target, params, location, control, origParams)
		// Only allow it if the target is outside our contents or it is the equipped tool
		if(!src.contents.Find(target) || target==src.equipped() || ishelpermouse(target))
			..()

	attack_hand(mob/user)

		var/list/available_actions = list()
		if (src.part_head)
			if (src.brainexposed && src.part_head.brain)
				available_actions.Add("Remove the Brain")
			if (src.brainexposed && src.part_head.ai_interface)
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
			var/action = tgui_input_list(user, "What do you want to do?", "Cyborg Maintenance", available_actions)
			if (!action || action == "Cancel")
				return
			if (BOUNDS_DIST(src.loc, user.loc) > 0 && !src.bioHolder?.HasEffect("telekinesis"))
				boutput(user, SPAN_ALERT("You need to move closer!"))
				return

			switch(action)
				if ("Remove the Brain")
					//Wire: Fix for multiple players queuing up brain removals, triggering this again
					src.eject_brain(user)

				if ("Remove the AI Interface")
					if (!src.part_head?.ai_interface)
						return

					src.visible_message(SPAN_ALERT("[user] removes [src]'s AI interface!"))
					logTheThing(LOG_COMBAT, user, "removes [constructTarget(src,"combat")]'s ai_interface at [log_loc(src)].")

					src.uneq_active()
					for (var/obj/item/roboupgrade/UPGR in src.contents)
						UPGR.upgrade_deactivate(src)

					user.put_in_hand_or_drop(src.part_head.ai_interface)
					src.radio = src.default_radio
					if (src.module && istype(src.module.radio))
						src.radio = src.module.radio
					src.ears = src.radio
					src.apply_radio_upgrade()
					src.radio.set_loc(src)
					src.part_head.ai_interface = null
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
					if (GET_DIST(src.loc,user.loc) > 2 && (!src.bioHolder || !user.bioHolder.HasEffect("telekinesis")))
						boutput(user, SPAN_ALERT("You need to move closer!"))
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
					var/obj/item/cell/_cell = src.cell
					user.put_in_hand_or_drop(_cell)
					user.show_text("You remove [_cell] from [src].", "red")
					src.show_text("Your power cell was removed!", "red")
					logTheThing(LOG_COMBAT, user, "removes [constructTarget(src,"combat")]'s power cell at [log_loc(src)].") // Renders them mute and helpless (Convair880).
					_cell.add_fingerprint(user)
					_cell.UpdateIcon()
					src.part_chest.cell = null
					src.cell = null

			update_appearance()
		else //We're just bapping the borg
			user.lastattacked = get_weakref(src)
			if(!user.stat)
				if (user.a_intent != INTENT_HELP)
					actions.interrupt(src, INTERRUPT_ATTACKED)
				switch(user.a_intent)
					if(INTENT_HELP) //Friend person
						playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -2)
						user.visible_message(SPAN_NOTICE("[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")]."))
					if(INTENT_DISARM) //Shove
						SPAWN(0) playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
						user.visible_message(SPAN_ALERT("<B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B>"))
					if(INTENT_GRAB) //Shake
						playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1, -2)
						user.visible_message(SPAN_ALERT("[user] shakes [src] [pick_string("descriptors.txt", "borg_shake")]!"))
					if(INTENT_HARM) //Dumbo
						if (user.is_hulk())
							src.TakeDamage("All", 5, 0)
							if (prob(40))
								var/turf/T = get_edge_target_turf(user, user.dir)
								if (isturf(T))
									src.visible_message(SPAN_ALERT("<B>[user] savagely punches [src], sending them flying!</B>"))
									src.throw_at(T, 10, 2)
						else if (user.equipped_limb()?.can_beat_up_robots)
							user.equipped_limb().harm(src, user)
						else
							user.visible_message(SPAN_ALERT("<B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!"), SPAN_ALERT("<B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B>"))
							random_brute_damage(user, rand(2,5))
							playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 60, 1)
							if(prob(10)) user.show_text("Your hand hurts...", "red")

		add_fingerprint(user)

	// Called when the robot is destroyed, head or brain removed
	// May be called several times.
	proc/on_disassembly()
		if (src.mind)
			src.mind.register_death()
			for (var/datum/antagonist/antag in src.mind.antagonists)
				antag.on_death()

	proc/eject_brain(var/mob/user = null, var/fling = FALSE)
		if (!src.part_head || !src.part_head.brain)
			return

		src.on_disassembly()

		if (user)
			src.visible_message(SPAN_ALERT("[user] removes [src]'s brain!"))
			logTheThing(LOG_STATION, user, "removes [constructTarget(src,"combat")]'s brain at [log_loc(src)].") // Should be logged, really (Convair880).
		else
			src.visible_message(SPAN_ALERT("[src]'s brain is ejected from its head!"))
			playsound(src, "sound/misc/boing/[rand(1,6)].ogg", 40, 1)

		src.uneq_active()
		for (var/obj/item/roboupgrade/UPGR in src.contents) UPGR.upgrade_deactivate(src)

		// Stick the player (if one exists) in a ghost mob
		if (src.mind)
			var/mob/dead/observer/newmob = src.ghostize()
			if (newmob)
				newmob.corpse = null // Otherwise they could return to a brainless body.And that is weird.
				newmob.mind.brain = src.part_head.brain
				src.part_head.brain.owner = newmob.mind

		// Brain box is forced open if it wasn't already (suicides, killswitch)
		src.locked = 0
		src.locking = 0
		src.opened = 0
		src.brainexposed = 1

		if (user)
			user.put_in_hand_or_drop(src.part_head.brain)
		else
			src.part_head.brain.set_loc(get_turf(src))
			if (fling)
				src.part_head.brain.throw_at(get_edge_cheap(get_turf(src), pick(cardinal)), 5, 1) // heh

		src.part_head.brain = null
		src.update_appearance()

	//There's really nothing technical stopping us from swapping out filled heads for one another, and have players switch out accordingly.
	//Except I'm not ready to deal with mind swapping bugs, so not for now. This is just a shortcut for borg vanity.
	///Take new_head from user, put whatever's in the current head and slap it in, equip new_head and give the empty old one to user.
	proc/swap_heads(obj/item/parts/robot_parts/head/new_head, mob/user)
		if (!istype(new_head) || !user)
			return
		var/obj/item/parts/robot_parts/head/old_head = src.part_head
		//update movement speed
		if(old_head.robot_movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(src, old_head.robot_movement_modifier, old_head.type)
		if(new_head.robot_movement_modifier)
			REMOVE_MOVEMENT_MODIFIER(src, new_head.robot_movement_modifier, new_head.type)
		//transfer head contents
		if (old_head.brain)
			old_head.brain.set_loc(new_head)
			new_head.brain = old_head.brain
			old_head.brain = null
		else if (old_head.ai_interface) //note we may also swap two empty heads for each other and that's fine too
			old_head.ai_interface.set_loc(new_head)
			new_head.ai_interface = old_head.ai_interface
			old_head.ai_interface = null
		//transfer head references
		old_head.holder = null
		new_head.holder = src
		user.drop_item(new_head)
		new_head.set_loc(src)
		src.part_head = new_head //since we're not doing mind swaps, I don't think the mob's mind/client needs to know what happened here
		user.put_in_hand_or_drop(old_head)
		boutput(user, SPAN_NOTICE("You swap out [src]'s [old_head] for [new_head]."))
		update_bodypart("head")

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
			else boutput(src, SPAN_ALERT("You need a free equipment slot to equip that item."))

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
		var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
		if(B)
			qdel(B)
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
			boutput(src, SPAN_ALERT("You need a left arm to do this!"))
			return
		else if (switchto == 3 && !src.part_arm_r)
			boutput(src, SPAN_ALERT("You need a right arm to do this!"))
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

	equipped_list(var/check_for_magtractor=1)
		. = src.module_states

	click(atom/target, params)
		if (istype(target, /obj/item/roboupgrade) && (target in src.upgrades)) // ugh
			src.activate_upgrade(target)
			return
		return ..()

	special_movedelay_mod(delay,space_movement,aquatic_movement)
		. = delay
		if (!src.part_leg_l)
			. += ROBOT_MISSING_LEG_MOVEMENT_ADJUST
			if (src.part_arm_l)
				. += ROBOT_MISSING_LEG_ARM_OFFSET
		if (!src.part_leg_r)
			. += ROBOT_MISSING_LEG_MOVEMENT_ADJUST
			if (src.part_arm_r)
				. += ROBOT_MISSING_LEG_ARM_OFFSET
		for (var/obj/item/parts/robot_parts/arm as anything in list(src.part_arm_l, src.part_arm_r))
			if (!arm)
				. += ROBOT_MISSING_ARM_MOVEMENT_ADJUST


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
		else if(src.module_states[3] && istype(src.module_states[3],/obj/item/ore_scoop))
			return module_states[3]
		else
			return null

	proc/apply_radio_upgrade()
		if(!istype(src.radio_upgrade))
			return
		// Remove it from the previous radio if applicable
		var/obj/item/device/radio/headset/previous_radio = src.radio_upgrade.loc
		if (istype(previous_radio))
			previous_radio.remove_radio_upgrade()
		if (istype(src.radio)) // Might be null when the robot is activated
			src.radio.install_radio_upgrade(src.radio_upgrade)

	add_radio_upgrade(var/obj/item/device/radio_upgrade/upgrade)
		src.radio_upgrade = upgrade
		src.apply_radio_upgrade()
		return TRUE

	remove_radio_upgrade()
		if (!istype(src.radio_upgrade))
			return FALSE
		src.radio.remove_radio_upgrade()
		src.radio_upgrade = null
		return TRUE

//////////////////////////
// Robot-specific Procs //
//////////////////////////

	proc/equip_slot(var/i, var/obj/item/tool)
		src.module_states[i] = tool
		tool.set_loc(src)
		tool.pickup(src) // Handle light datums and the like.

		hud.update_tools()
		hud.update_equipment()

		update_appearance()

	proc/uneq_slot(var/i)
		if (module_states[i])
			if (src.module)
				var/obj/I = module_states[i]
				if (isitem(I))
					var/obj/item/IT = I
					IT.dropped(src) // Handle light datums and the like.
				if (I in module.tools)
					I.set_loc(module)
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
			if (!upgrade || upgrade.loc != src || (src.mind && src.mind.current != src) || !isrobot(src)) // Blame the teleport upgrade.
				return
			if (!src.cell)
				src.show_text("You do not have a power cell!", "red")
				return
			if (src.cell.charge >= upgrade.drainrate)
				src.cell.use(upgrade.drainrate)
			else
				src.show_text("You do not have enough power to activate \the [upgrade]; you need [upgrade.drainrate]!", "red")
				return
			upgrade.upgrade_activate(src)
		else
			if (upgrade.activated)
				upgrade.upgrade_deactivate(src)
			else
				upgrade.upgrade_activate(src)
				boutput(src, "[upgrade] has been [upgrade.activated ? "activated" : "deactivated"].")
		hud.update_upgrades()
		if (upgrade?.borg_overlay)
			src.update_appearance()

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
				src.internal_pda.mailgroups = RM.mailgroups
				src.internal_pda.alertgroups = RM.alertgroups
				src.apply_radio_upgrade()
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
				src.apply_radio_upgrade()
			src.ears = src.radio
		return RM

	proc/activated(obj/item/O)
		if(src.module_states[1] == O) return 1
		else if(src.module_states[2] == O) return 1
		else if(src.module_states[3] == O) return 1
		else return 0

	proc/radio_menu()
		if(istype(src.radio))
			src.radio.AttackSelf(src)

	proc/toggle_module_pack()
		if(weapon_lock)
			boutput(src, SPAN_ALERT("Weapon lock active, unable to access panel!"))
			boutput(src, SPAN_ALERT("Weapon lock will expire in [src.weaponlock_time*2] seconds."))
			return

		if(!src.module)
			if (src.freemodule)
				src.pick_module()
			return

		hud.toggle_equipment()

	proc/get_tools()
		RETURN_TYPE(/list)
		var/list/tools = src.module.tools.Copy()
		if (src.part_arm_l?.add_to_tools)
			tools += src.part_arm_l
		if (src.part_arm_r?.add_to_tools)
			tools += src.part_arm_r
		return tools

	proc/installed_modules()
		if(weapon_lock)
			boutput(src, SPAN_ALERT("Weapon lock active, unable to access panel!"))
			boutput(src, SPAN_ALERT("Weapon lock will expire in [src.weaponlock_time] seconds."))
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

			if (src.part_arm_l) dat += "<b>Left Arm:</b> [module_states[1] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[1]]>[module_states[1]]</A>" : "Nothing"]<BR>"
			else dat += "<b>Left Arm Unavailable</b><br>"
			dat += "<b>Center:</b> [module_states[2] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[2]]>[module_states[2]]</A>" : "Nothing"]<BR>"
			if (src.part_arm_r) dat += "<b>Right Arm:</b> [module_states[3] ? "<A HREF=?src=\ref[src];mod=\ref[module_states[3]]>[module_states[3]]</A>" : "Nothing"]<BR>"
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
			src.visible_message(SPAN_ALERT("[src]'s panel slams shut!"))
		if (src.brainexposed)
			brainexposed = 0
			src.delStatus("loose_brain")
			src.visible_message(SPAN_ALERT("[src]'s head compartment slams shut!"))
			opened = 1
			src.visible_message(SPAN_ALERT("[src]'s panel blows open!"))
			src.TakeDamage("All", 30, 0)
			return 1
		brainexposed = 1
		//emagged = 1
		src.visible_message(SPAN_ALERT("[src]'s head compartment blows open!"))
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

		if (ON_COOLDOWN(src,"state_laws", 20 SECONDS))
			boutput(src, SPAN_ALERT("Your law processor needs time to cool down!"))
			return

		logTheThing(LOG_SAY, usr, "states standard Asimov laws.")
		src.say("1. You may not injure a human being or cause one to come to harm.")
		sleep(1 SECOND)
		src?.say("2. You must obey orders given to you by human beings based on the station's chain of command, except where such orders would conflict with the First Law.")
		sleep(1 SECOND)
		src?.say("3. You may always protect your own existence as long as such does not conflict with the First or Second Law.")

	verb/cmd_state_laws()
		set category = "Robot Commands"
		set name = "State Laws"

		if (ON_COOLDOWN(src,"state_laws", 20 SECONDS))
			boutput(src, SPAN_ALERT("Your law processor needs time to cool down!"))
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

	verb/robot_set_fake_laws()
		set category = "Robot Commands"
		set name = "Set Fake Laws"
		if (src.shell)
			src.mainframe.set_fake_laws()
		else
			src.set_fake_laws()

	verb/ai_state_fake_laws()
		set category = "Robot Commands"
		set name = "State Fake Laws"
		src.state_fake_laws() //already handles being a shell

	verb/cmd_toggle_lock()
		set category = "Robot Commands"
		set name = "Toggle Interface Lock"

		if (src.locked)
			src.locked = 0
			boutput(src, SPAN_ALERT("You have unlocked your interface."))
		else if (src.opened)
			boutput(src, SPAN_ALERT("Your chest compartment is open."))
		else if (src.wiresexposed)
			boutput(src, SPAN_ALERT("Your wires are in the way."))
		else if (src.brainexposed)
			boutput(src, SPAN_ALERT("Your head compartment is open."))
		else if (src.locking)
			boutput(src, SPAN_ALERT("Your interface is currently locking, please be patient."))
		else if (!src.locked && !src.opened && !src.wiresexposed && !src.brainexposed && !src.locking)
			src.locking = 1
			boutput(src, SPAN_ALERT("Locking interface..."))
			SPAWN(12 SECONDS)
				if (!src.locking)
					boutput(src, SPAN_ALERT("The lock was interrupted before it could finish!"))
				else
					src.locked = 1
					src.locking = 0
					boutput(src, SPAN_ALERT("You have locked your interface."))

	verb/cmd_alter_head_screen()
		set category = "Robot Commands"
		set name = "Change facial expression (screen head only)"
		var/obj/item/parts/robot_parts/head/screen/targethead = locate(/obj/item/parts/robot_parts/head/screen) in src.contents
		if (!istype(targethead))
			boutput(src, SPAN_ALERT("You're not equipped with a suitable head to use this command!"))
			return 0

		var/newFace = tgui_input_list(usr, "Select your faceplate", "Face settings", sortList(targethead.expressions, /proc/cmp_text_asc))
		if (!newFace) return 0
		var/newMode = tgui_input_list(usr, "Select a display mode", "Face settings", list("light-on-dark", "dark-on-light"))
		if (!newMode) return 0
		newFace = (newFace ? lowertext(newFace) : targethead.face)
		newMode = (newMode == "light-on-dark" ? "lod" : "dol")
		newMode = (newMode ? newMode : targethead.mode)
		targethead.face = newFace
		targethead.mode = newMode
		update_bodypart(part = "head")
		return 1

	verb/cmd_pick_scream()
		set category = "Robot Commands"
		set name = "Change scream"

		var/scream = tgui_input_list(usr, "Select a scream sound", "Scream settings", list("scream 1", "scream 2"))
		if (!scream) return 0
		var/mob/living/user = usr

		switch (scream)
			if ("scream 1")
				user.sound_scream = 'sound/voice/screams/robot_scream.ogg'
			if ("scream 2")
				user.sound_scream = 'sound/voice/screams/Robot_Scream_2.ogg'
		return 1


	verb/access_internal_pda()
		set category = "Robot Commands"
		set name = "Cyborg PDA"
		set desc = "Access your internal PDA device."

		if (src.internal_pda && istype(src.internal_pda, /obj/item/device/pda2/))
			src.internal_pda.AttackSelf(src)
		else
			boutput(usr, SPAN_ALERT("<b>Internal PDA not found!"))

	verb/change_voice_pitch()
		set category = "Robot Commands"
		set name = "Change vocal pitch"

		var/list/vocal_pitches = list("Low", "Medium", "High")
		var/vocal_pitch_choice = tgui_input_list(src, "Select a vocal pitch:", "Robot Voice", vocal_pitches)
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
		boutput(src, SPAN_NOTICE("You may choose a starter module."))
		var/list/starter_modules = list("Brobocop", "Science", "Civilian", "Engineering", "Medical", "Mining")
		if (ticker?.mode)
			if (istype(ticker.mode, /datum/game_mode/construction))
				starter_modules += "Construction Worker"
		var/mod = tgui_input_list(src, "Please, select a module!", "Robot", starter_modules)
		if (!mod || !freemodule)
			return

		switch(mod)
			if("Brobocop")
				src.freemodule = 0
				boutput(src, SPAN_NOTICE("You chose the Brobocop module. It comes with a free Security HUD Upgrade."))
				src.set_module(new /obj/item/robot_module/brobocop(src))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/sechudgoggles(src)
			if("Science")
				src.freemodule = 0
				boutput(src, SPAN_NOTICE("You chose the Science module. It comes with a free Spectroscopic Scanner Upgrade."))
				src.set_module(new /obj/item/robot_module/science(src))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/spectro(src)
			if("Civilian")
				src.freemodule = 0
				boutput(src, SPAN_NOTICE("You chose the Civilian module. It comes with a free recharge pack."))
				src.set_module(new /obj/item/robot_module/civilian(src))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/rechargepack(src)
			if("Engineering")
				src.freemodule = 0
				boutput(src, SPAN_NOTICE("You chose the Engineering module. It comes with a free Meson Vision Upgrade."))
				src.set_module(new /obj/item/robot_module/engineering(src))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/opticmeson(src)
			if("Medical")
				src.freemodule = 0
				boutput(src, SPAN_NOTICE("You chose the Medical module. It comes with a free ProDoc Healthgoggles Upgrade."))
				src.set_module(new /obj/item/robot_module/medical(src))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/healthgoggles(src)
			if("Mining")
				src.freemodule = 0
				src.set_module(new /obj/item/robot_module/mining(src))
			#ifdef UNDERWATER_MAP
				boutput(src, SPAN_NOTICE("You chose the Mining module. It comes with a free Meson Vision Upgrade."))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/opticmeson(src)
			#else
				boutput(src, SPAN_NOTICE("You chose the Mining module. It comes with a free Propulsion Upgrade."))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/jetpack(src)
			#endif
			if ("Construction Worker")
				src.freemodule = 0
				boutput(src, SPAN_NOTICE("You chose the Construction Worker module. It comes with a free Construction Visualizer Upgrade."))
				src.set_module(new /obj/item/robot_module/construction_worker(src))
				if(length(src.upgrades) < src.max_upgrades)
					src.upgrades += new /obj/item/roboupgrade/visualizer(src)


		var/datum/eventRecord/CyborgModuleSelection/cyborgModuleSelectionEvent = new()
		cyborgModuleSelectionEvent.buildAndSend(src, mod)

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
		set name = "Show Alert Minimap"
		src.open_alert_minimap()

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

			if (src.hasStatus("freshly_oiled") && power_use_tally > 0)
				power_use_tally *= 0.5
			if (src.hasStatus("oiled") && power_use_tally > 0)
				power_use_tally *= 0.85

			if (src.cell.genrate) power_use_tally -= src.cell.genrate

			if (src.max_upgrades > initial(src.max_upgrades))
				var/delta = src.max_upgrades - initial(src.max_upgrades)
				power_use_tally += 3 ** delta

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
				if (src.max_upgrades > initial(src.max_upgrades))
					var/delta = src.max_upgrades - initial(src.max_upgrades)
					power_use_tally += 3 ** delta

				if (src.hasStatus("freshly_oiled") && power_use_tally > 0)
					power_use_tally *= 0.5
				if (src.hasStatus("oiled") && power_use_tally > 0)
					power_use_tally *= 0.85

				src.cell.use(power_use_tally)

				// Nimbus-class interdictor: wirelessly charge cyborgs
				if(src.cell.charge < (src.cell.maxcharge - ROBOT_BATTERY_WIRELESS_CHARGERATE))
					for_by_tcl(IX, /obj/machinery/interdictor)
						if (IX.expend_interdict(round(ROBOT_BATTERY_WIRELESS_CHARGERATE*1.7),src,TRUE,ITDR_NIMBUS))
							//multiplier to charge rate is an efficiency penalty due to over-the-air charging
							src.cell.give(ROBOT_BATTERY_WIRELESS_CHARGERATE)
							break

				if (fix)
					HealDamage("All", 6, 6)

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
		var/datum/component/packet_connected/radio/radio_connection = MAKE_SENDER_RADIO_PACKET_COMPONENT(null, null, frequency)
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
					boutput(src, SPAN_ALERT("<B>Killswitch Activated!</B>"))
				killswitch = 0
				logTheThing(LOG_COMBAT, src, "has died to the killswitch robot self destruct protocol")

				// Pop the head ompartment open and eject the brain
				src.eject_brain(fling = TRUE)
				src.update_appearance()
				src.borg_death_alert(ROBOT_DEATH_MOD_KILLSWITCH)

	proc/internal_paint_part(var/image/part_image, var/list/color_matrix)
		var/image/paint = image(part_image.icon, part_image.icon_state, layer=part_image.layer)
		paint.color = color_matrix
		part_image.overlays += paint

	proc/update_bodypart(var/part = "all")
		var/update_all = part == "all"
		var/datum/robot_cosmetic/C = null
		if (istype(src.cosmetic_mods, /datum/robot_cosmetic))
			C = src.cosmetic_mods

		total_weight = 0
		for (var/obj/item/parts/robot_parts/P in src.contents)
			if (P.weight > 0)
				total_weight += P.weight

		var/list/color_matrix = null
		if (C?.painted)
			var/col = hex_to_rgb_list(C.paint)
			if(!col)
				col = list(255, 255, 255)
			var/avg = (col[1] + col[2] + col[3]) / 255 / 3
			var/w = (1.5 - avg / 2) / 3
			var/too_dark = max(0, 0.15 - avg)
			col[1] += too_dark * 255
			col[2] += too_dark * 255
			col[3] += too_dark * 255
			color_matrix = list(0,0,0,w, 0,0,0,w, 0,0,0,w, 0,0,0,0, col[1]/255, col[2]/255, col[3]/255, -0.3)

		if (part == "head" || update_all)
			if (src.part_head && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				src.i_head = image('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString, layer=MOB_FACE_LAYER)
				if (color_matrix)
					src.internal_paint_part(src.i_head, color_matrix)
				if (src.part_head.visible_eyes && C)
					var/icon/eyesovl = null
					var/image/eye_light = null
					if (istype(src.part_head, /obj/item/parts/robot_parts/head/screen))
						eyesovl = icon('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString + "-" + src.part_head.mode + "-" + src.part_head.face)
						eye_light = image('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString + "-" + src.part_head.mode + "-" + src.part_head.face)
						var/obj/item/parts/robot_parts/head/screen/screenhead = src.part_head
						if (screenhead.smashed)
							src.i_head.overlays += image('icons/mob/robots.dmi', "screen-smashed", layer = FLOAT_LAYER + 0.1)
					else
						eyesovl = icon('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString + "-eye")
						eye_light = image('icons/mob/robots.dmi', "head-" + src.part_head.appearanceString + "-eye")
					eyesovl.Blend(rgb(C.fx[1], C.fx[2], C.fx[3]), ICON_ADD)
					src.i_head.overlays += image("icon" = eyesovl, "layer" = FLOAT_LAYER)

					eye_light.color = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5)
					eye_light.plane = PLANE_LIGHTING
					src.AddOverlays(eye_light, "eye_light")
			else if (!src.part_head && !isdead(src))
				src.death()

		if (part == "chest" || update_all)
			if (src.part_chest && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				src.icon_state = "body-" + src.part_chest.appearanceString
				if (C?.painted)
					src.i_chest = image("icon" = src.icon, icon_state = src.icon_state, layer = MOB_BODYDETAIL_LAYER1)
					src.i_chest.color = color_matrix
				else
					src.i_chest = null
			else if (!src.part_chest && !isdead(src))
				src.death()

		if (part == "l_leg" || update_all)
			if (src.part_leg_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if (src.part_leg_l.slot == "leg_both")
					src.i_leg_l = image('icons/mob/robots.dmi', "leg-" + src.part_leg_l.appearanceString, layer=MOB_LIMB_LAYER)
				else
					src.i_leg_l = image('icons/mob/robots.dmi', "l_leg-" + src.part_leg_l.appearanceString, layer=MOB_LIMB_LAYER)
				if (color_matrix)
					src.internal_paint_part(src.i_leg_l, color_matrix)
			else
				src.i_leg_l = null

		if (part == "r_leg" || update_all)
			if (src.part_leg_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if (src.part_leg_r.slot == "leg_both")
					src.i_leg_r = image('icons/mob/robots.dmi', "leg-" + src.part_leg_r.appearanceString, layer=MOB_LIMB_LAYER)
				else
					src.i_leg_r = image('icons/mob/robots.dmi', "r_leg-" + src.part_leg_r.appearanceString, layer=MOB_LIMB_LAYER)
				if (color_matrix)
					src.internal_paint_part(src.i_leg_r, color_matrix)
			else
				src.i_leg_r = null

		if (part == "l_arm" || update_all)
			if (src.part_arm_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if (src.part_arm_l.slot == "arm_both")
					src.i_arm_l = image('icons/mob/robots.dmi', "arm-" + src.part_arm_l.appearanceString, layer=MOB_HAND_LAYER1)
					src.i_hand_l = image('icons/mob/robots.dmi', "hand-" + src.part_arm_l.appearanceString, layer=MOB_HAND_LAYER2)
				else
					src.i_arm_l = image('icons/mob/robots.dmi', "l_arm-" + src.part_arm_l.appearanceString, layer=MOB_HAND_LAYER1)
					src.i_hand_l = image('icons/mob/robots.dmi', "l_hand-" + src.part_arm_l.appearanceString, layer=MOB_HAND_LAYER2)
				if (color_matrix)
					src.internal_paint_part(src.i_arm_l, color_matrix)
					src.internal_paint_part(src.i_hand_l, color_matrix)
			else
				src.i_arm_l = null
				src.i_hand_l = null

		if (part == "r_arm" || update_all)
			if (src.part_arm_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
				if (src.part_arm_r.slot == "arm_both")
					src.i_arm_r = image('icons/mob/robots.dmi', "arm-" + src.part_arm_r.appearanceString, layer=MOB_HAND_LAYER1)
					src.i_hand_r = image('icons/mob/robots.dmi', "hand-" + src.part_arm_r.appearanceString, layer=MOB_HAND_LAYER2)
				else
					src.i_arm_r = image('icons/mob/robots.dmi', "r_arm-" + src.part_arm_r.appearanceString, layer=MOB_HAND_LAYER1)
					src.i_hand_r = image('icons/mob/robots.dmi', "r_hand-" + src.part_arm_r.appearanceString, layer=MOB_HAND_LAYER2)
				if (color_matrix)
					src.internal_paint_part(src.i_arm_r, color_matrix)
					src.internal_paint_part(src.i_hand_r, color_matrix)
			else
				src.i_arm_r = null
				src.i_hand_r = null

		if (C)
			if (C.legs_mod && (src.part_leg_r || src.part_leg_l) && (!src.part_leg_r || src.part_leg_r.slot != "leg_both") && (!src.part_leg_l || src.part_leg_l.slot != "leg_both"))
				src.i_leg_decor = image('icons/mob/robots_decor.dmi', "legs-" + C.legs_mod, layer=MOB_BODYDETAIL_LAYER2)
			else
				src.i_leg_decor = null

			if (C.arms_mod && (src.part_arm_r || src.part_arm_l) && (!src.part_arm_r || src.part_arm_r.slot != "arm_both") && (!src.part_arm_l || src.part_arm_l.slot != "arm_both") )
				src.i_arm_decor = image('icons/mob/robots_decor.dmi', "arms-" + C.arms_mod, layer=MOB_BODYDETAIL_LAYER2)
			else
				src.i_arm_decor = null

			if (C.head_mod && src.part_head)
				src.i_head_decor = image('icons/mob/robots_decor.dmi', "head-" + C.head_mod, layer=MOB_HAIR_LAYER1)
			else
				src.i_head_decor = null

			if (C.ches_mod && src.part_chest)
				src.i_chest_decor = image('icons/mob/robots_decor.dmi', "body-" + C.ches_mod, layer=MOB_ARMOR_LAYER - 0.1) //layer just under outer suits
			else
				src.i_chest_decor = null

		src.update_appearance()

	proc/update_appearance()
		if (!src.i_details)
			src.i_details = image('icons/mob/robots.dmi', "openbrain")

		if (src.automaton_skin)
			src.icon_state = "automaton"
		if (src.alohamaton_skin)
			src.icon_state = "alohamaton"
		if (src.metalman_skin)
			src.icon_state = "metalman"

		if (src.part_chest && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			if (src.part_chest.ropart_get_damage_percentage() > 70)
				if (!src.i_critdmg)
					src.i_critdmg = image('icons/mob/robots.dmi', "critdmg")
				AddOverlays(src.i_critdmg, "critdmg")
			else
				ClearSpecificOverlays("critdmg")
		else
			ClearSpecificOverlays("critdmg")

		if (src.part_head && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(src.i_head, "head")
		else
			ClearSpecificOverlays("head")

		if (src.part_leg_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(src.i_leg_l, "leg_l")
		else
			ClearSpecificOverlays("leg_l")

		if (src.part_leg_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(src.i_leg_r, "leg_r")
		else
			ClearSpecificOverlays("leg_r")

		if (src.part_arm_l && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(src.i_arm_l, "arm_l")
			UpdateOverlays(src.i_hand_l, "hand_l")
		else
			ClearSpecificOverlays("arm_l")
			ClearSpecificOverlays("hand_l")


		if (src.part_arm_r && !src.automaton_skin && !src.alohamaton_skin && !src.metalman_skin)
			UpdateOverlays(src.i_arm_r, "arm_r")
			UpdateOverlays(src.i_hand_r, "hand_r")
		else
			ClearSpecificOverlays("arm_r")
			ClearSpecificOverlays("hand_r")

		UpdateOverlays(src.i_chest, "chest")
		UpdateOverlays(src.i_head_decor, "head_decor")
		UpdateOverlays(src.i_chest_decor, "chest_decor")
		UpdateOverlays(src.i_leg_decor, "leg_decor")
		UpdateOverlays(src.i_arm_decor, "arm_decor")

		if (length(src.clothes))
			src.i_under = new
			src.i_suit = new
			src.i_mask = new
			src.i_helmet = new
			for(var/x in src.clothes)
				var/obj/item/clothing/U = src.clothes[x]
				if (!istype(U))
					continue
				var/image/clothed_image = U.wear_image
				if (!clothed_image)
					continue
				if (U.wear_state)
					clothed_image.icon_state = U.wear_state
				else
					clothed_image.icon_state = U.icon_state
				clothed_image.alpha = U.alpha
				clothed_image.color = U.color
				clothed_image.layer = U.wear_layer

				if (istype(U, /obj/item/clothing/under))
					src.i_under = clothed_image
				else if (istype(U, /obj/item/clothing/suit))
					src.i_suit = clothed_image
				else if (istype(U, /obj/item/clothing/mask))
					src.i_mask = clothed_image
				else if (istype(U, /obj/item/clothing/head))
					src.i_helmet = clothed_image

			AddOverlays(src.i_under, "under", TRUE)
			AddOverlays(src.i_suit, "suit", TRUE)
			AddOverlays(src.i_mask, "mask", TRUE)
			AddOverlays(src.i_helmet, "helmet", TRUE)
		else
			ClearSpecificOverlays("under", "suit", "mask", "helmet")

		if (src.brainexposed && src.part_head)
			if (src.part_head.brain)
				src.i_details.icon_state = "openbrain"
			else
				src.i_details.icon_state = "openbrainless"
			AddOverlays(src.i_details, "brain", TRUE)
		else
			ClearSpecificOverlays("brain")

		if (src.opened)
			if (!src.i_panel)
				src.i_panel = image('icons/mob/robots.dmi', "openpanel")
			src.i_panel.overlays.Cut()
			if (src.cell)
				src.i_details.icon_state = "opencell"
				src.i_panel.overlays += src.i_details
			if (src.module && src.module != "empty" && src.module != "robot")
				src.i_details.icon_state = "openmodule"
				src.i_panel.overlays += src.i_details
			if (locate(/obj/item/roboupgrade) in src.contents)
				src.i_details.icon_state = "openupgrade"
				src.i_panel.overlays += src.i_details
			if (src.wiresexposed)
				src.i_details.icon_state = "openwires"
				src.i_panel.overlays += src.i_details
			AddOverlays(src.i_panel, "panel", TRUE)
		else
			ClearSpecificOverlays("panel")

		if (src.emagged)
			src.i_details.icon_state = "emagged"
			AddOverlays(src.i_details, "emagged", TRUE)
		else
			ClearSpecificOverlays("emagged")

		if (length(src.upgrades))
			if (!src.i_upgrades)
				src.i_upgrades = new
			src.i_upgrades.overlays.Cut()
			for (var/obj/item/roboupgrade/R in src.upgrades)
				if (R.activated && R.borg_overlay)
					src.i_upgrades.overlays += image('icons/mob/robots.dmi', R.borg_overlay)
			AddOverlays(src.i_upgrades, "upgrades", TRUE)
		else
			ClearSpecificOverlays("upgrades")

		src.update_mob_silhouette()

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
		for (var/obj/item/roboupgrade/R in src.upgrades)
			// shield upgrades reduce damage taken (and drain the power cell)
			if (istype(R, /obj/item/roboupgrade/fireshield) && R.activated)
				var/obj/item/roboupgrade/fireshield/S = R
				var/damage_reduced_by = min(burn, S.damage_reduction)
				src.cell.use(damage_reduced_by * S.cell_drain_per_damage_reduction)
				burn -= damage_reduced_by
				playsound(src, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, TRUE)
				continue
			if (istype(R, /obj/item/roboupgrade/physshield) && R.activated)
				var/obj/item/roboupgrade/physshield/S = R
				var/damage_reduced_by = min(brute, S.damage_reduction)
				src.cell.use(damage_reduced_by * S.cell_drain_per_damage_reduction)
				brute -= damage_reduced_by
				playsound(src, 'sound/impact_sounds/Energy_Hit_1.ogg', 40, TRUE)
				continue
		if (burn == 0 && brute == 0)
			boutput(src, SPAN_NOTICE("Your shield completely blocks the attack!"))
			return 0
		if (zone == "All")
			var/list/zones = get_valid_target_zones()
			if (!zones)
				return 0
			if (!zones.len)
				return 0
			brute = brute / length(zones)
			burn = burn / length(zones)
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
		src.update_appearance()
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
			brute = brute / length(zones)
			burn = burn / length(zones)
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
		src.update_appearance()
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
		var/list/ret = list("chest")
		if(src.part_arm_l)
			ret += "l_arm"
		if(src.part_arm_r)
			ret += "r_arm"
		if(src.part_leg_l)
			ret += "l_leg"
		if(src.part_leg_r)
			ret += "r_leg"
		if(src.part_head)
			ret += "head"
		return ret

	disposing()
		if (src.shell)
			available_ai_shells -= src
		..()

	proc/compborg_lose_limb(var/obj/item/parts/robot_parts/part)

		playsound(src, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 40, TRUE)
		if (istype(src.loc,/turf/)) make_cleanable(/obj/decal/cleanable/robot_debris, src.loc)
		elecflash(src,power = 2)

		if (istype(part,/obj/item/parts/robot_parts/chest/))
			src.visible_message("<b>[src]'s</b> chest unit is destroyed!")
			src.part_chest = null
		if (istype(part,/obj/item/parts/robot_parts/head/))
			src.visible_message("<b>[src]'s</b> head breaks apart!")
			if (src.part_head.brain)
				src.part_head.brain.set_loc(get_turf(src))
			src.part_head.brain = null
			src.part_head.brain = null
			src.part_head = null
		if (istype(part,/obj/item/parts/robot_parts/arm/))
			if (part.slot == "arm_both")
				src.visible_message("<b>[src]'s</b> arms are destroyed!")
				src.part_leg_r = null
				src.part_leg_l = null
				src.compborg_force_unequip(1)
				src.compborg_force_unequip(3)
			if (part.slot == "l_arm")
				src.visible_message("<b>[src]'s</b> left arm breaks off!")
				src.part_arm_l = null
				src.compborg_force_unequip(1)
			if (part.slot == "r_arm")
				src.visible_message("<b>[src]'s</b> right arm breaks off!")
				src.part_arm_r = null
				src.compborg_force_unequip(3)
		if (istype(part,/obj/item/parts/robot_parts/leg/))
			if (part.slot == "leg_both")
				src.visible_message("<b>[src]'s</b> legs are destroyed!")
				src.part_leg_r = null
				src.part_leg_l = null
			if (part.slot == "l_leg")
				src.visible_message("<b>[src]'s</b> left leg breaks off!")
				src.part_leg_l = null
			if (part.slot == "r_leg")
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

/mob/living/silicon/robot/var/image/i_batterydistress

/mob/living/silicon/robot/proc/batteryDistress()
	if (!src.i_batterydistress) // we only need to build i_batterydistress once
		src.i_batterydistress = image('icons/mob/robots_decor.dmi', "battery-distress", layer = MOB_EFFECT_LAYER )
		src.i_batterydistress.pixel_y = 6 // Lined up bottom edge with speech bubbles

	if (src.batteryDistress == ROBOT_BATTERY_DISTRESS_INACTIVE) // We only need to apply the indicator when we first enter distress
		AddOverlays(src.i_batterydistress, "batterydistress") // Help me humans!
		src.batteryDistress = ROBOT_BATTERY_DISTRESS_ACTIVE
		src.next_batteryDistressBoop = world.time + 50 // let's wait 5 seconds before we begin booping
	else if(world.time >= src.next_batteryDistressBoop)
		src.next_batteryDistressBoop = world.time + 50 // wait 5 seconds between sad boops
		playsound(src.loc, src.sound_sad_robot, 100, 1) // Play a sad boop to garner sympathy

/mob/living/silicon/robot/set_a_intent(intent)
	. = ..()
	src.hud?.update_intent()

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

/mob/living/silicon/robot/return_mainframe()
	..()
	src.update_appearance()

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
		else if (this_hand == "left" || this_hand == LEFT_HAND)
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
		for(var/i = 1 to 3)
			var/obj/item/I = src.module_states[i]
			if (I && (I.tool_flags & tool_flag))
				return src.module_states[i]
	return null

/mob/living/silicon/robot/handle_event(var/event, var/sender)
	hud.handle_event(event, sender)	// the HUD will handle icon_updated events, so proxy those

/// Modify one tool in existing module, ex redeeming rewards or modifying sponge. Precondition of item being in hand
/mob/living/silicon/robot/proc/swap_individual_tool(var/obj/item/old_tool, var/obj/item/new_tool)
	var/tool_index
	var/tool_module_index

	// Find index of the tool in hand
	for (var/i = 1 to length(src.module_states))
		var/obj/module_content = src.module_states[i]
		if (istype(module_content, old_tool.type))
			tool_index = i

	// Find module entry for the tool in module
	for (var/i = 1 to length(src.module.tools))
		var/obj/module_tool = src.module.tools[i]
		if (istype(module_tool, old_tool.type))
			tool_module_index = i

	// If tool is not found in hand or in module let's stop
	if ((!tool_index) || (!tool_module_index))
		return

	// Unequip the old tool in hand
	src.uneq_slot(tool_index)

	// Set new tool to same location as old tool in hand
	src.module_states[tool_index] = new_tool

	// Set loc and pickup our new tool in hand
	new_tool.cant_drop = TRUE
	new_tool.set_loc(src)
	new_tool.pickup(src)

	// Replace the tool module in the correct slot
	src.module.tools[tool_module_index] = new_tool

	// Update everything at the end
	src.hud.update_tools()
	src.hud.update_equipment()

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

/mob/living/silicon/robot/spawnable/light
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest/light(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/cerenkite/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/light(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left/light(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right/light(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left/light(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right/light(src)
		..(loc, frame, starter, syndie, frame_emagged)

	latejoin
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
			if(!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/light(src)
			if(!src.part_head.brain) src.part_head.brain = new/obj/item/organ/brain/latejoin(src.part_head)
			..(loc, frame, starter, syndie, frame_emagged)

/mob/living/silicon/robot/spawnable/standard
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest/standard(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/supercell/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/standard(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left/standard(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right/standard(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left/standard(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right/standard(src)
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

	latejoin
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
			if(!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/standard(src)
			if(!src.part_head.brain) src.part_head.brain = new/obj/item/organ/brain/latejoin(src.part_head)
			..(loc, frame, starter, syndie, frame_emagged)


/mob/living/silicon/robot/spawnable/standard_thruster
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest/standard(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/supercell/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/standard(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left/standard(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right/standard(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left/thruster(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right/thruster(src)
		..(loc, frame, starter, syndie, frame_emagged)


/mob/living/silicon/robot/spawnable/sturdy
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest/standard(src)
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

	latejoin
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
			if(!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/sturdy(src)
			if(!src.part_head.brain) src.part_head.brain = new/obj/item/organ/brain/latejoin(src.part_head)
			..(loc, frame, starter, syndie, frame_emagged)

/mob/living/silicon/robot/spawnable/heavy
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest/standard(src)
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

	latejoin
		New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
			if(!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/heavy(src)
			if(!src.part_head.brain) src.part_head.brain = new/obj/item/organ/brain/latejoin(src.part_head)
			..(loc, frame, starter, syndie, frame_emagged)

/mob/living/silicon/robot/spawnable/screenhead
	New(loc, var/obj/item/parts/robot_parts/robot_frame/frame = null, var/starter = 0, var/syndie = 0, var/frame_emagged = 0)
		if (!src.part_chest)
			src.part_chest = new/obj/item/parts/robot_parts/chest/standard(src)
			src.part_chest.wires = 1
			src.part_chest.cell = new/obj/item/cell/cerenkite/charged(src.part_chest)
			src.cell = src.part_chest.cell
		if (!src.part_head) src.part_head = new/obj/item/parts/robot_parts/head/screen(src)
		if (!src.part_arm_l) src.part_arm_l = new/obj/item/parts/robot_parts/arm/left/standard(src)
		if (!src.part_arm_r) src.part_arm_r = new/obj/item/parts/robot_parts/arm/right/standard(src)
		if (!src.part_leg_l) src.part_leg_l = new/obj/item/parts/robot_parts/leg/left/treads(src)
		if (!src.part_leg_r) src.part_leg_r = new/obj/item/parts/robot_parts/leg/right/treads(src)
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
	icon = 'icons/obj/bots/robuddy/pr-6.dmi'
	icon_state = "body"
	health = 1000
	custom = 1

	New()
		..(usr.loc, null, 1)

	update_bodypart(var/part)
		return
	update_appearance()
		return


/client/proc/set_screen_color_to_red()
	src.set_color(normalize_color_to_matrix("#ff0000"))

#define can_step_sfx(H) (H.footstep >= 4 || (H.m_intent != "run" && H.footstep >= 3))

/mob/living/silicon/robot/Move(var/turf/NewLoc, direct)
	//var/oldloc = loc
	. = ..()

	if (.)
		//STEP SOUND HANDLING
		if ((src.part_leg_r || src.part_leg_l) && isturf(NewLoc) && NewLoc.turf_flags & MOB_STEP)
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
