// Cambot
// Cambot assembly

// Cobbled together from bits of the other bots, mostly cleanbots and firebots.
#define CAMBOT_MOVE_SPEED 8
/obj/machinery/bot/cambot
	name = "Cambot"
	desc = "A little camera robot! Smile!"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "cambot0"
	layer = 5.0 //TODO LAYER
	density = 0
	anchored = UNANCHORED
	on = 1
	health = 20
	locked = 1
	access_lookup = "Assistant"

	var/atom/target // Current target.
	var/list/targets_invalid = list() // Targets we weren't able to reach.
	var/clear_invalid_targets = 1 // In relation to world time. Clear list periodically.
	var/clear_invalid_targets_interval = 3 MINUTES // How frequently?

	var/idle = 1 // In relation to world time. In case there aren't any valid targets nearby.
	var/idle_delay = 10 SECONDS // For how long?
	/// Time we last took a picture
	var/last_shot
	/// Minimum time between photography
	var/shot_cooldown = 5 SECONDS

	var/obj/item/camera/camera = null
	var/photographing = 0 // Are we currently photographing something?
	var/list/photographed = list() // what we've already photographed

/obj/machinery/bot/cambot/New()
	..()
	src.clear_invalid_targets = TIME
	SPAWN(0.5 SECONDS)
		if (src)
			src.camera = new /obj/item/camera(src)
			src.icon_state = "cambot[src.on]"
			src.AddComponent(/datum/component/proximity)

/obj/machinery/bot/cambot/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if (!user && usr)
			user = usr
		if (user)
			user.show_text("You short out the flash control circuit on [src]!", "red")
			src.emagger = user
			src.add_fingerprint(user)
			logTheThing(LOG_STATION, src.emagger, "emagged a cambot[src.name != "Cambot" ? ", [src.name]," : null] at [log_loc(src)].")

		src.audible_message(SPAN_ALERT("<B>[src] buzzes oddly!</B>"))
		playsound(src, 'sound/weapons/flash.ogg', 50, TRUE)
		flick("cambot-spark", src)
		src.emagged = 1
		return 1
	return 0

/obj/machinery/bot/cambot/attackby(obj/item/W, mob/user) //guh
	. = ..()
	switch(W.hit_type)
		if (DAMAGE_BURN)
			src.health -= W.force * 0.75
		else
			src.health -= W.force * 0.5
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/cambot/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair [src]'s flash control circuit.", "blue")
	src.emagged = 0
	return 1

/obj/machinery/bot/cambot/emp_act()
	..()
	if (!src.emagged && prob(75))
		src.emag_act(usr && ismob(usr) ? usr : null, null)
	else
		src.explode()
	return

/obj/machinery/bot/cambot/ex_act(severity)
	switch (severity)
		if (1)
			src.explode()
			return
		if (2)
			src.health -= 15
			if (src.health <= 0)
				src.explode()
			return
	return

/obj/machinery/bot/cambot/meteorhit()
	src.explode()
	return

/obj/machinery/bot/cambot/blob_act(var/power)
	if (prob(25 * power / 20))
		src.explode()
	return

/obj/machinery/bot/cambot/gib()
	return src.explode()

/obj/machinery/bot/cambot/explode()
	if (!src)
		return

	if(src.exploding) return
	src.exploding = 1
	src.on = 0
	src.visible_message(SPAN_ALERT("<B>[src] blows apart!</B>"))
	playsound(src.loc, 'sound/impact_sounds/Machinery_Break_1.ogg', 40, 1)

	elecflash(src, radius=1, power=3, exclude_center = 0)

	var/turf/T = get_turf(src)
	if (T && isturf(T))
		new /obj/item/camera(T)
		new /obj/item/device/prox_sensor(T)
		if (prob(50))
			new /obj/item/parts/robot_parts/arm/left/standard(T)

	qdel(src)
	return

/obj/machinery/bot/cambot/proc/toggle_power(var/force_on = 0)
	if (!src)
		return

	if (force_on == 1)
		src.on = 1
	else
		src.on = !src.on

	src.anchored = UNANCHORED
	src.target = null
	src.icon_state = "cambot[src.on]"
	src.path = null
	src.targets_invalid = list() // Anything vs mob when emagged, so we gotta clear it.
	src.clear_invalid_targets = TIME

	if (src.on)
		add_simple_light("cambot", list(255,255,255,255 * (src.emagged ? 0.8 : 0.6)))
	else
		remove_simple_light("cambot")

	return

/obj/machinery/bot/cambot/process()
	. = ..()
	if (!src.on)
		return

	if (src.photographing)
		return

	// We're still idling.
	if (src.idle && TIME < src.idle + src.idle_delay)
		return

	// Invalid targets may not be unreachable anymore. Clear list periodically.
	if (src.clear_invalid_targets && TIME > src.clear_invalid_targets + src.clear_invalid_targets_interval)
		src.targets_invalid = null
		src.clear_invalid_targets = TIME

	// If we're having trouble reaching our target, add them to our list of invalid targets.
	if (src.frustration >= 8)
		src.KillPathAndGiveUp(1)

	if(src.last_shot && src.last_shot + src.shot_cooldown <= TIME)
		return

	if(QDELETED(src.target) || !IN_RANGE(src, src.target, 25))
		src.target = null

	// Let's find us something to photograph.
	if (!src.target)
		src.find_target()

	// Still couldn't find one? Abort and retry later.
	if (!src.target)
		src.idle = TIME
		return

	// Let's find us a path to the target.
	if (src.target && !length(src.path))
		src.navigate_to(get_turf(src.target), CAMBOT_MOVE_SPEED, 1, 20)

		if (!islist(src.path)) // Woops, couldn't find a path.
			LAZYLISTADDUNIQUE(src.targets_invalid, src.target)
			src.target = null
			return

	if (src.target)
		if (GET_DIST(src, get_turf(src.target)) <= 1)//src.loc == get_turf(src.target))
			photograph(src.target)
			return

	return

/// Gotta catch those driveby moments
/obj/machinery/bot/cambot/EnteredProximity(atom/movable/AM)
	if(!on || stunned || src.last_shot + src.shot_cooldown <= TIME || (src.idle && TIME < src.idle + src.idle_delay))
		return

	if ((AM in src.targets_invalid) || (AM in src.photographed))
		return
	else
		photograph(AM)

/obj/machinery/bot/cambot/proc/find_target()
	// Let's find us something to photograph.
	if (!src.target)
		var/list/mob_options = list()
		var/list/other_options = list()
		for (var/atom/movable/M in oview(7, src))
			if (M == src && prob(99)) // very tiny chance to take a ~selfie~
				continue
			if (!istext(M.name) || !length(M.name)) // don't take pictures of unnamed things
				continue
			if ((istype(M, /obj/item/photo) || istype(M, /obj/machinery/bot/cambot)) && prob(99)) // only a tiny chance to take a picture of a picture or another cambot
				continue
			if (M in src.targets_invalid)
				continue
			if ((M in src.photographed) && (prob(90) || (ismob(M) && src.emagged && prob(80)))) // chance to take a picture of something we already photographed
				continue

			if (ismob(M))
				if ((!isliving(M) || M.invisibility > INVIS_NONE) && prob(99)) // 1% chance to take a picture of a ghost or an invisible thing  :I
					continue
				mob_options += (M)
			else
				other_options += (M)

		if (mob_options.len && (prob(80) || (src.emagged && prob(90)) || !length(other_options))) // idk how other_options would be empty but y'know whatever, just in case
			src.target = pick(mob_options)
			return
		else if (other_options.len)
			src.target = pick(other_options)
			return
		else
			src.idle = TIME
			return

/obj/machinery/bot/cambot/proc/flash_blink(var/loops, var/delay)
	set waitfor = 0
	for (var/i=loops, i>0, i--)
		add_simple_light("cambot", list(255,255,255,255 * (src.emagged ? 0.8 : 0.6)))
		sleep(delay)
		remove_simple_light("cambot")
		sleep(delay)

/obj/machinery/bot/cambot/KillPathAndGiveUp(give_up)
	. = ..()
	if(give_up)
		if (src.target)
			if (!(src.target in src.targets_invalid))
				src.targets_invalid +=src.target
			src.frustration = 0
			src.target = null

/obj/machinery/bot/cambot/proc/photograph(var/atom/target)
	if (!src || !src.on || !target)
		return
	var/turf/T = get_turf(target)
	if (!T || !isturf(T))
		return

	src.anchored = ANCHORED
	src.icon_state = "cambot-c"
	src.visible_message(SPAN_ALERT("[src] aims at [target]."))
	src.photographing = 1
	src.flash_blink(3, 1)

	SPAWN(5 SECONDS)
		if (src.on)
			if (BOUNDS_DIST(src, target) == 0)
				src.flash_blink(1, 5)
				if (src.camera) // take the picture
					var/obj/item/photo/P = src.camera.create_photo(target, src.emagged)
					if (P)
						src.visible_message("[src] takes \a [target == src ? "selfie! How?" : P]!")
					playsound(src, "sound/items/polaroid[rand(1,2)].ogg", 75, 1, -3)

				if (src.emagged) // if emagged, flash the target too
					if (ismob(target))
						var/mob/M = target
						M.apply_flash(30, 8, 0, 0, 0, rand(0, 2), 0, 0, 100)
					playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)

			// don't sit there taking pictures of the same thing over and over
			if (!(target in src.photographed))
				src.photographed += target

		src.photographing = 0
		src.icon_state = "cambot[src.on]"
		src.anchored = UNANCHORED
		src.path = null
		src.target = null
		src.frustration = 0
		src.idle = TIME
	return

// Assembly

/obj/item/camera_arm_assembly
	name = "camera/robot arm assembly"
	desc = "A camera with a robot arm grafted to it."
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "camera_arm"
	w_class = W_CLASS_NORMAL
	flags = TABLEPASS
	var/build_step = 0
	var/created_name = "Cambot"

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/device/prox_sensor))
			var/obj/machinery/bot/cambot/B = new /obj/machinery/bot/cambot(get_turf(src))
			B.name = src.created_name
			user.u_equip(W)
			user.u_equip(src)
			boutput(user, "You add the sensor to the camera assembly! Beep bep!")
			qdel(W)
			qdel(src)
			return

		else if (istype(W, /obj/item/pen))
			var/t = input(user, "Enter new robot name", src.name, src.created_name) as null|text
			if (!t)
				return
			if(t && t != src.name && t != src.created_name)
				phrase_log.log_phrase("bot-camera", t)
			t = strip_html(replacetext(t, "'",""))
			t = copytext(t, 1, 45)
			if (!t)
				return
			if (!in_interact_range(src, user) && src.loc != user)
				return
			src.created_name = t

		else
			..()
		return
