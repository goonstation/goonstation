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
	p_class = 2

	power_change()
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (istype(mover, /obj/projectile))
			return 0
		return ..()

	New()
		..()

		if(!no_camera)
			src.cam = new /obj/machinery/camera(src)
			src.cam.c_tag = src.name
			src.cam.network = setup_camera_network

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
					return 1
				else
					return 0

/obj/machinery/bot/examine()
	. = ..()
	var/healthpct = src.health / initial(src.health)
	if (healthpct <= 0.8)
		if (healthpct >= 0.4)
			. += "<span class='alert'>[src]'s parts look loose.</span>"
		else
			. += "<span class='alert'><B>[src]'s parts look very loose!</B></span>"
