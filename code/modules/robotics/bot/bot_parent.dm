// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/bots/aibots.dmi'
	layer = MOB_LAYER
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	object_flags = CAN_REPROGRAM_ACCESS
	machine_registry_idx = MACHINES_BOTS
	var/obj/item/card/id/botcard // ID card that the bot "holds".
	var/access_lookup = "Captain" // For the get_access() proc. Defaults to all-access.
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
	var/text2speech = 0 // dectalk!
	var/obj/chat_maptext_holder/speech2text = new
	/// Bots get their processing tier changed based on what they're doing
	/// If they're offscreen and not doing anything interesting, they get processed less rapidly
	/// If they're onscreen and not in the middle of something major, they get processed rapidly
	/// If they're right in the middle of something like arresting someone, they get processed *ehhh* quick
	/// Low process rate for bots that we can't see
	var/PT_idle = PROCESSING_EIGHTH
	/// High process rate for bots looking for something to do
	var/PT_search = PROCESSING_FULL
	/// Middle process rate for bots currently trying to murder someone
	var/PT_active = PROCESSING_QUARTER
	var/hash_cooldown = (2 SECONDS)
	var/next_hash_check = 0
	/// If we're in the middle of something and don't want our tier to go wonky
	var/doing_something = 0
	/// Range that the bot checks for people
	/// Should be low for bots that don't interact with people that much, like skullbots
	/// Should be around 7ish for bots that interact with people, but tend to sit still
	/// Should be fairly high for patrolling "major character" bots, like Buddies
	var/hash_check_range = 2
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

	disposing()
		botcard = null
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
		if(src.doing_something && src.processing_tier != src.PT_active)
			src.processing_tier = src.PT_active
			src.SubscribeToProcess()
			boutput(world, "[src] set into [src.PT_active] tier!!!")
		else if(!src.doing_something && TIME >= (src.next_hash_check))
			src.next_hash_check = TIME + src.hash_cooldown
			if(src.CheckIfVisible())
				src.processing_tier = src.PT_search
				src.SubscribeToProcess()
				boutput(world, "[src] set into [src.PT_search] tier!!!")
			else
				src.processing_tier = src.PT_idle
				src.SubscribeToProcess()
				boutput(world, "[src] set into [src.PT_idle] tier!!!")
		. = ..()

	proc/CheckIfVisible()
		for (var/mob/M in GET_NEARBY(src, src.hash_check_range))
			var/client/C = M.client
			if (C)
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

	proc/speak(var/message)
		if (!src.on || !message || src.muted)
			return
		src.audible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"")
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
		return PROJ_OBJ_HIT_OTHER_OBJS | PROJ_ATOM_PASSTHROGH
