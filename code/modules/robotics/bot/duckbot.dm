// by request
#define DUCKBOT_MOVE_SPEED 8
#define DUCKBOT_QUACK_COOLDOWN "duckbotquackdelay"
#define DUCKBOT_AMUSEMENT_COOLDOWN "duckbotlovesongdelay"
#define DUCKBOT_ANNOY_TIMEOUT "duckbotnerdobsessionlength"
#define DUCKBOT_ANNOY_LOCKOUT_TIMEOUT "duckbotforgetannoyednerds"
#define DUCKBOT_ANNOY_PATHING_COOLDOWN "duckbotnospamastar"

/obj/machinery/bot/duckbot
	name = "Amusing Duck"
	desc = "Bump'n go action! Ages 3 and up."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "duckbot"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = 0
	on = 1 // ACTION
	health = 5
	bot_move_delay = DUCKBOT_MOVE_SPEED
	var/eggs = 0
	/// When it gets to 100, free egg!
	var/egg_process = 0
	/// Minimum time between gaggles and quacks
	var/quack_cooldown = 3 SECONDS
	/// To make sure MAKING NOISE IS TRUE is false
	var/amusement_cooldown = 10 SECONDS
	/// Pick someone, then mill around them making noise. If emagged is true.
	var/mob/annoy_target
	/// Though maybe pick someone else after a while
	var/annoy_timeout = 30 SECONDS
	/// And forget about who you annoyed after a while
	var/forget_annoyed_timeout = 3 MINUTES
	/// Don't spam that pathfinding
	var/annoy_path_cooldown = 5 SECONDS
	/// And don't just go back to pestering the same person
	var/list/annoyed_nerds = list()
	/// Location on the station where all these damn things migrate to for whatever reason
	var/static/area/duck_migration_target
	/// Someone set our migration path, let's go there instead of picking something
	var/static/migration_override
	no_camera = 1
	/// ha ha NO.
	dynamic_processing = 0

/obj/machinery/bot/duckbot/New()
	. = ..()
	if(radio_controller)
		radio_controller.add_object(src, FREQ_PDA)

/// Makes the duckbot mill around aimlessly, or chase people if emagged
/obj/machinery/bot/duckbot/proc/wakka_wakka()
	if(moving) return
	if(src.emagged)
		if(src.annoy_target)
			if(!ON_COOLDOWN(src, DUCKBOT_ANNOY_TIMEOUT, src.quack_cooldown))
				src.KillPathAndGiveUp(1)
			else if(!ON_COOLDOWN(src, DUCKBOT_ANNOY_PATHING_COOLDOWN, src.annoy_path_cooldown))
				var/turf/randwander = get_step_rand(get_turf(src.annoy_target))
				src.navigate_to(randwander, DUCKBOT_MOVE_SPEED, 1, 30)
		else
			for_by_tcl(M, /mob)
				if(IN_RANGE(src, M, 7))
					if(M in src.annoyed_nerds)
						if(!ON_COOLDOWN(src, "[DUCKBOT_ANNOY_LOCKOUT_TIMEOUT]-[M.name]", src.forget_annoyed_timeout))
							src.annoyed_nerds -= M
						else
							continue
					ON_COOLDOWN(src, DUCKBOT_ANNOY_TIMEOUT, src.quack_cooldown)
					ON_COOLDOWN(src, "[DUCKBOT_ANNOY_LOCKOUT_TIMEOUT]-[M.name]", src.forget_annoyed_timeout)
					src.annoy_target = M
					src.annoyed_nerds[M] = TRUE
					src.navigate_to(M, DUCKBOT_MOVE_SPEED, 1, 30)
					break
	else
		step_rand(src,1)

/// Sends all the duckbots to a random spot on the station
/obj/machinery/bot/duckbot/proc/migrate()
	var/list/stationAreas = get_accessible_station_areas()
	if(!isarea(src.duck_migration_target))
		var/A = pick(stationAreas)
		src.duck_migration_target = stationAreas[A]
	var/list/T = get_area_turfs(src.duck_migration_target, 1)
	if(length(T) >= 1)
		. = TRUE
		SPAWN_DBG(rand(0,10 SECONDS)) // give em some time to spread out a bit
			T = (pick(T))
			src.mystical_access()
			src.navigate_to(T, src.bot_move_delay, 0, 300)
			if(length(src.path) < 1)
				src.KillPathAndGiveUp(1)

/// Sends the duckbot to a random spot on the station
/obj/machinery/bot/duckbot/proc/mystical_journey()
	var/list/stationAreas = get_accessible_station_areas()
	var/area/AR = pick(stationAreas)
	var/list/T = get_area_turfs(stationAreas[AR], 1)
	if(length(T) >= 1)
		T = (pick(T))
		src.mystical_access()
		src.navigate_to(T, src.bot_move_delay, 0, 300)
		if(length(src.path) >= 1)
			return TRUE

/// Gives the duckbot all access while on its quest
/obj/machinery/bot/duckbot/proc/mystical_access()
	qdel(src.botcard)
	src.access_lookup = "Captain"
	src.botcard = new /obj/item/card/id(src)
	src.botcard.access = get_access(src.access_lookup)

/obj/machinery/bot/duckbot/process()
	. = ..()
	if(src.on == 1)
		if(!ON_COOLDOWN(src, DUCKBOT_QUACK_COOLDOWN, src.quack_cooldown) && prob(60))
			var/message = pick("wacka", "quack","quacky","gaggle")
			src.speak(message, 1, 0)
		if(!src.moving && prob(80))
			wakka_wakka()
		if(!ON_COOLDOWN(src, DUCKBOT_AMUSEMENT_COOLDOWN, src.amusement_cooldown) && prob(20))
			playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 0) // MUSIC
		else if(prob (7) && src.eggs >= 1)
			var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
			E.name = "duck egg"
			src.eggs--
			playsound(src.loc, "sound/misc/eggdrop.ogg", 50, 0)
	if(src.emagged == 1)
		var/message = pick("QUacK", "WHaCKA", "quURK", "bzzACK", "quock", "queck", "WOcka", "wacKY","GOggEL","gugel","goEGL","GeGGal")
		src.speak(message, 1, 1)
		wakka_wakka(TRUE) // Seek loser is TRUE
		if(prob(70))
			playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1) // MUSIC
		else if(prob (10) && src.eggs >= 1)
			var/obj/item/a_gift/easter/E = new /obj/item/a_gift/easter(src.loc)
			E.name = "duck egg"
			src.eggs--
			playsound(src.loc, "sound/misc/eggdrop.ogg", 50, 1)
	if(prob(80))
		src.egg_process++
	if(src.egg_process >= 100 && prob(20))
		src.eggs++
		src.egg_process = 0
	if(!src.moving)
		if(prob(1) && src.declare_migration())
			src.migrate()
			return
		if(prob(1) && src.mystical_journey()) // Time to go on a mystical journey
			return
	if(frustration >= 8)
		src.KillPathAndGiveUp(1)

/obj/machinery/bot/duckbot/Topic(href, href_list)
	if (!(usr in range(1)))
		return
	if (href_list["on"])
		on = !on
	attack_hand(usr)

/obj/machinery/bot/duckbot/attack_hand(mob/user as mob)
	var/dat
	dat += "<TT><B>AMUSING DUCK</B></TT><BR>"
	dat += "<B>toy series with strong sense for playing</B><BR><BR>"
	dat += "LAY EGG IS: <A href='?src=\ref[src];on=1'>[src.on ? "TRUE!!!" : "NOT TRUE!!!"]</A><BR><BR>"
	dat += "AS THE DUCK ADVANCING,FLICKING THE PLUMAGE AND YAWNING THE MOUTH GO WITH MUSIC & LIGHT.<BR>"
	dat += "THE DUCK STOP,IT SWAYING TAIL THEN THE DUCK LAY AN EGG AS OPEN IT'S BUTTOCKS,<BR>GO WITH THE DUCK'S CALL"

	user.Browse("<HEAD><TITLE>Amusing Duck</TITLE></HEAD>[dat]", "window=ducky")
	onclose(user, "ducky")
	return

/obj/machinery/bot/duckbot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if(user)
			boutput(user, "<span class='alert'>You short out the horn on [src].</span>")
		src.audible_message("<span class='alert'><B>[src] quacks loudly!</B></span>", 1)
		playsound(src.loc, "sound/misc/amusingduck.ogg", 50, 1)
		src.eggs += rand(3,9)
		src.emagged = 1
		src.processing_tier = src.PT_active
		src.SubscribeToProcess()
		return 1
	return 0

/obj/machinery/bot/duckbot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s horn. Thank God.", "blue")
	src.emagged = 0
	src.processing_tier = src.PT_idle
	src.SubscribeToProcess()
	return 1

/// Tells all the other bots that it's time to migrate... somewhere
/obj/machinery/bot/duckbot/proc/declare_migration(var/force)
	if(!ON_COOLDOWN(global, "duckbot_declare_migration", 25 MINUTES) || force) // is it winter yet
		if(!src.migration_override)
			var/list/stationAreas = get_accessible_station_areas()
			var/A = pick(stationAreas)
			src.duck_migration_target = stationAreas[A]

		var/datum/radio_frequency/frequency = radio_controller.return_frequency(FREQ_PDA)
		if(!frequency) return FALSE

		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["sender"] = src.botnet_id
		signal.data["command"] = "migrate"
		signal.data["sender_name"] = src
		signal.data["message"] = "BUMP N GO TO [src.duck_migration_target]."
		signal.transmission_method = TRANSMISSION_RADIO
		frequency.post_signal(src, signal)
		return TRUE

/obj/machinery/bot/duckbot/receive_signal(datum/signal/signal)
	if(!on)
		return
	// migrate is true?
	if(signal.data["command"] == "migrate")
		var/message_to_send = "quack"
		if(!ON_COOLDOWN(global, "duckbot_forced_migration", 5 MINUTES))
			src.migrate()
			message_to_send = "wacka"
		if(signal.data["sender"])
			src.send_confirm_signal(message_to_send, signal.data["sender"])
	// in case someone wants to trick a flock of plastic birds to break you into security or something
	if(signal.data["command"] == "set_migration_target")
		var/message_to_send = "quack"
		var/list/stationAreas = get_accessible_station_areas()
		if(signal.data["message"] in stationAreas)
			src.duck_migration_target = signal.data["message"]
			message_to_send = "wacka"
			src.migration_override = TRUE
		if(signal.data["sender"])
			src.send_confirm_signal(message_to_send, signal.data["sender"])

/obj/machinery/bot/duckbot/proc/send_confirm_signal(var/msg, var/target)
	if(!ON_COOLDOWN(global, "duckbot_antispam_[target]", 5 SECONDS))
		var/datum/radio_frequency/frequency = radio_controller.return_frequency(FREQ_PDA)
		if(!frequency) return FALSE
		var/datum/signal/sigsend = get_free_signal()
		sigsend.source = src
		sigsend.data["sender"] = src.botnet_id
		sigsend.data["command"] = "message"
		sigsend.data["sender_name"] = src
		sigsend.data["message"] = "[msg]"
		sigsend.data["address_1"] = target
		sigsend.transmission_method = TRANSMISSION_RADIO
		frequency.post_signal(src, sigsend)

/obj/machinery/bot/duckbot/KillPathAndGiveUp(give_up)
	. = ..()
	if(give_up)
		src.annoy_target = null
		src.cooldowns = list()
	if(src.access_lookup != initial(src.access_lookup))
		src.access_lookup = initial(src.access_lookup)
		qdel(src.botcard)
		src.botcard = new /obj/item/card/id(src)
		src.botcard.access = get_access(src.access_lookup)

/obj/machinery/bot/duckbot/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/card/emag))
		emag_act(user, W)
	else
		src.visible_message("<span class='alert'>[user] hits [src] with [W]!</span>")
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.explode()

/obj/machinery/bot/duckbot/gib()
	return src.explode()

/obj/machinery/bot/duckbot/explode()
	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message("<span class='alert'><B>[src] blows apart!</B></span>", 1)
	playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 40, 1)
	elecflash(src, radius=1, power=3, exclude_center = 0)
	qdel(src)
	return
