// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/bots/aibots.dmi'
	layer = MOB_LAYER
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	flags = FPRINT | FLUID_SUBMERGE | TGUI_INTERACTIVE
	object_flags = CAN_REPROGRAM_ACCESS
	machine_registry_idx = MACHINES_BOTS
	var/obj/item/card/id/botcard // ID card that the bot "holds".
	var/access_lookup = "Assistant" // For the get_access() proc. Defaults to staff assistant.
	var/locked = null
	var/on = 1
	var/health = 25
	var/exploding = 0 //So we don't die like five times at once.
	var/muted = 0 // shut up omg shut up.
	var/no_camera = 0
	var/setup_camera_network = "Robots"
	var/obj/machinery/camera/cam = null
	var/emagged = 0
	var/mob/emagger = null
	/// The bot's net ID
	var/botnet_id = null
	/// What's it talk like?
	var/list/speakverbs = list("beeps", "boops")
	var/text2speech = 0 // dectalk!
	/// Should the bot's speech pop up over them?
	var/speech2text = 1
	/// What color is the bot's speech?
	var/bot_speech_color
	/// What does our bot's popup speech look like?
	var/bot_speech_style
	/// The noise that happens whenever the bot speaks
	var/bot_voice = 'sound/misc/talk/bottalk_1.ogg'
	/// The bot's speech bubble
	var/static/image/bot_speech_bubble = image('icons/mob/mob.dmi', "speech")
	var/use_speech_bubble = 1
	/// Is this bot *dynamic* enough to need a higher processing tier when being watched?
	/// Set to 0 for bots that don't typically directly interact with people, like ducks and floorbots
	var/dynamic_processing = 1
	/// Bots get their processing tier changed based on what they're doing
	/// If they're offscreen and not doing anything interesting, they get processed less rapidly
	/// If they're onscreen and not in the middle of something major, they get processed rapidly
	/// If they're right in the middle of something like arresting someone, they get processed *ehhh* quick
	/// Low process rate for bots that we can't see
	var/PT_idle = PROCESSING_SIXTEENTH
	/// High process rate for bots looking for something to do
	var/PT_search = PROCESSING_HALF
	/// Middle process rate for bots currently trying to murder someone
	var/PT_active = PROCESSING_QUARTER
	var/hash_cooldown = (2 SECONDS)
	var/next_hash_check = 0
	/// If we're in the middle of something and don't want our tier to go wonky
	var/doing_something = 0
	/// Range that the bot checks for clients
	var/hash_check_range = 6

	var/frustration = 0
	/// How slowly the bot moves by default -- higher is slower!
	var/bot_move_delay = 6
	var/list/path = null	// list of path turfs
	var/datum/robot_mover/bot_mover
	var/moving = 0 // Are we ON THE MOVE??
	var/stunned = 0 //It can be stunned by tasers. Delicate circuits.
	var/current_movepath = 0
	var/scanrate = 10 // How often do we check for stuff while we're ON THE MOVE. in deciseconds

	p_class = 2

	power_change()
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (istype(mover, /obj/projectile))
			return 0
		return ..()

	New()
		..()
		RegisterSignal(src, COMSIG_ATOM_HITBY_PROJ, .proc/hitbyproj)
		if(!no_camera)
			src.cam = new /obj/machinery/camera(src)
			src.cam.c_tag = src.name
			src.cam.network = setup_camera_network
		src.processing_tier = src.PT_idle
		src.SubscribeToProcess()
		if(!src.chat_text)
			src.chat_text = new
		src.vis_contents += src.chat_text
		SPAWN_DBG(0.5 SECONDS)
			src.botcard = new /obj/item/card/id(src)
			src.botcard.access = get_access(src.access_lookup)
			src.botnet_id = format_net_id("\ref[src]")

	disposing()
		botcard = null
		qdel(chat_text)
		chat_text = null
		if(cam)
			cam.dispose()
			cam = null
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		user.lastattacked = src
		attack_particle(user,src)
		hit_twitch(src)
		if (W.hitsound)
			playsound(src,W.hitsound,50,1)
		..()

	process(mult, var/force)
		if(src.dynamic_processing)
			if(src.doing_something && src.processing_tier != src.PT_active)
				src.processing_tier = src.PT_active
				src.SubscribeToProcess()
			else if(!src.doing_something && TIME >= (src.next_hash_check))
				src.next_hash_check = TIME + src.hash_cooldown
				if(src.CheckIfVisible())
					src.processing_tier = src.PT_search
					src.SubscribeToProcess()
				else
					src.processing_tier = src.PT_idle
					src.SubscribeToProcess()
			. = ..()

	proc/CheckIfVisible()
		for (var/mob/M in GET_NEARBY(src, src.hash_check_range))
			if(M.client)
				. = 1
				break

	// Generic default. Override for specific bots as needed.
	bullet_act(var/obj/projectile/P)
		if (!P || !istype(P))
			return
		hit_twitch(src)

		var/damage = 0
		damage = round(((P.power/4)*P.proj_data.ks_ratio), 1.0)

		if (P.proj_data.damage_type == D_KINETIC)
			src.health -= damage
		else if (P.proj_data.damage_type == D_PIERCING)
			src.health -= (damage*2)
		else if (P.proj_data.damage_type == D_ENERGY)
			src.health -= damage

		if (src.health <= 0)
			src.explode()
		return

	proc/explode()
		return

	proc/speak(var/message, var/sing, var/just_float)
		if (!src.on || !message || src.muted)
			return
		var/image/chat_maptext/chatbot_text = null
		if (src.speech2text && src.chat_text)
			if(src.use_speech_bubble)
				UpdateOverlays(bot_speech_bubble, "bot_speech_bubble")
				SPAWN_DBG(1.5 SECONDS)
					UpdateOverlays(null, "bot_speech_bubble")
			if(!src.bot_speech_color)
				var/num = hex2num(copytext(md5("[src.name][TIME]"), 1, 7))
				src.bot_speech_color = hsv2rgb(num % 360, (num / 360) % 10 / 100 + 0.18, num / 360 / 10 % 15 / 100 + 0.85)
			var/singing_italics = sing ? " font-style: italic;" : ""
			var/maptext_color
			if (sing)
				maptext_color ="#D8BFD8"
			else
				maptext_color = src.bot_speech_color
			chatbot_text = make_chat_maptext(src, message, "color: [maptext_color];" + src.bot_speech_style + singing_italics)
			if(chatbot_text)
				chatbot_text.measure(src)
				for(var/image/chat_maptext/I in src.chat_text.lines)
					if(I != chatbot_text)
						I.bump_up(chatbot_text.measured_height)

		src.audible_message("<span class='game say'><span class='name'>[src]</span> [pick(src.speakverbs)], \"[message]\"", just_maptext = just_float, assoc_maptext = chatbot_text)
		playsound(get_turf(src), src.bot_voice, 40, 1)
		if (src.text2speech)
			SPAWN_DBG(0)
				var/audio = dectalk("\[:nk\][message]")
				if (audio && audio["audio"])
					for (var/mob/O in hearers(src, null))
						if (!O.client)
							continue
						if (O.client.ignore_sound_flags & (SOUND_VOX | SOUND_ALL))
							continue
						ehjax.send(O.client, "browseroutput", list("dectalk" = audio["audio"]))

/obj/machinery/bot/examine()
	. = ..()
	var/healthpct = src.health / initial(src.health)
	if (healthpct <= 0.8)
		if (healthpct >= 0.4)
			. += "<span class='alert'>[src]'s parts look loose.</span>"
		else
			. += "<span class='alert'><B>[src]'s parts look very loose!</B></span>"

/obj/machinery/bot/proc/hitbyproj(source, obj/projectile/P)
	if((P.proj_data.damage_type & (D_KINETIC | D_ENERGY | D_SLASHING)) && P.proj_data.ks_ratio > 0)
		P.initial_power -= 10
		if(P.initial_power <= 0)
			P.die()
	if(!src.density)

		return PROJ_OBJ_HIT_OTHER_OBJS | PROJ_ATOM_PASSTHROUGH

/obj/machinery/bot/Bumped(M as mob|obj) // not sure what this is for, but it was in a bunch of the bots, so it's here just in case its vital
	var/turf/T = get_turf(src)
	if(ismovable(M))
		var/atom/movable/AM = M
		AM.set_loc(T)

/obj/machinery/bot/proc/DoWhileMoving()
	return

/obj/machinery/bot/proc/KillPathAndGiveUp(var/give_up)
	src.frustration = 0
	src.path = null
	qdel(src.bot_mover)
	if(give_up)
		src.doing_something = 0

/obj/machinery/bot/proc/point(var/atom/target, var/announce_it = 0) // I stole this from the medibot (and chefbot) <3 u marq ur a beter codr then me
	var/turf/T = get_turf(target)
	if(!T) return
	if(announce_it)
		visible_message("<b>[src]</b> points at [target]!")
	var/obj/decal/point/P = new(T)
	P.pixel_x = target.pixel_x
	P.pixel_y = target.pixel_y
	P.color = src.bot_speech_color
	SPAWN_DBG(2 SECONDS)
		P.invisibility = 101
		qdel(P)

/obj/machinery/bot/emp_act()
	src.emag_act()

	/// Takes a turf and spits out string of coordinates
/obj/machinery/bot/proc/turf2coordinates(var/turf/T)
	if(isturf(T))
		var/Tx = T.x
		var/Ty = T.y
		var/Tz = T.z
		return jointext(list(Tx, Ty, Tz), ",")


/obj/machinery/bot/proc/navigate_to(atom/the_target, var/move_delay = 10, var/adjacent = 0, max_dist=600)
	var/turf/target_turf = get_turf(the_target)
	if(!checkTurfPassable(target_turf))
		var/turf_is_impassable = 1
		for(var/dir_look in alldirs)
			var/turf/T = get_step(target_turf, dir_look)
			if(checkTurfPassable(T))
				target_turf = T
				turf_is_impassable = 0
				break
		if(turf_is_impassable)
			return


	src.KillPathAndGiveUp(0)
	src.current_movepath = world.time
	src.bot_mover = new /datum/robot_mover(src)

	if (!isnull(src.bot_mover)) // drsingh for cannot modify null.delay
		src.bot_mover.master_move(target_turf, current_movepath, adjacent, scanrate, max_dist)

	if (!isnull(src.bot_mover))	// drsingh again for the same thing further down in a moment.
		src.bot_mover.delay = move_delay	// Because master_move can delete the mover
	return 0

//movement control datum. Why yes, this is copied from secbot.dm. Which was copied from guardbot.dm
/datum/robot_mover
	var/obj/machinery/bot/master = null
	var/delay = 3

	New(var/newmaster)
		..()
		if(istype(newmaster, /obj/machinery/bot))
			src.master = newmaster
		return

	disposing()
		if(master.bot_mover == src)
			master.bot_mover = null
		master.moving = 0
		src.master = null
		..()

	proc/master_move(var/atom/the_target as obj|mob, var/current_movepath,var/adjacent=0, var/scanrate, max_dist=600)
		if(!master || !isturf(master.loc))
			src.master = null
			//dispose()
			return
		var/target_turf = null
		if(isturf(the_target))
			target_turf = the_target
		else
			target_turf = get_turf(the_target)
		var/compare_movepath = current_movepath
		master.path = AStar(get_turf(master), target_turf, /turf/proc/CardinalTurfsAndSpaceWithAccess, /turf/proc/Distance, max_dist, master.botcard)
		SPAWN_DBG(0)
			if (!master)
				qdel(src)
				return
			else if(master && (!master.path || !master.path.len || !the_target))
				master.KillPathAndGiveUp(0)
				return
			if(adjacent && master.path && master.path.len) //Make sure to check it isn't null!!
				master.path.len-- //Only go UP to the target, not the same tile.

			master?.moving = 1

			while(length(master?.path) && target_turf)
				if(compare_movepath != current_movepath) break
				if(!master.on)
					master.frustration = 0
					break

				if(master.DoWhileMoving())
					break	// We're here! Or something!

				if(master?.path)
					if(istype(get_turf(master), /turf/space)) // frick it, duckie toys get jetpacks
						var/obj/effects/ion_trails/I = unpool(/obj/effects/ion_trails)
						I.set_loc(get_turf(master))
						I.set_dir(master.dir)
						flick("ion_fade", I)
						I.icon_state = "blank"
						I.pixel_x = master.pixel_x
						I.pixel_y = master.pixel_y
						SPAWN_DBG( 20 )
							if (I && !I.disposed) pool(I)
					step_to(master, master.path[1])
					if(master.loc != master.path[1])
						master.frustration++
						sleep(delay)
						continue
					master?.path -= master?.path[1]
					sleep(delay)
				else
					break // i dunno, it runtimes

			if (master)
				master.moving = 0
				master.bot_mover = null
				master.process() // responsive, robust AI = calling process() a million zillion times
				master = null
