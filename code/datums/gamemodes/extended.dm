/datum/game_mode/extended
	name = "Extended"
	config_tag = "extended"
	regular = FALSE
	do_antag_random_spawns = 0
	latejoin_antag_compatible = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/extended/pre_setup()
	. = ..()
#ifdef LIVE_SERVER
	if (!global.game_force_started && global.ticker.roundstart_player_count(FALSE) < 20)
		return FALSE
#endif
	for(var/datum/random_event/event in random_events.major_events)
		if(istype(event, /datum/random_event/major/law_rack_corruption))
			event.disabled = TRUE
	return TRUE

/datum/game_mode/extended/announce()
	boutput(world, "<B>The current game mode is - Extended!</B>")
	boutput(world, "<B>Just have fun!</B>")

/datum/game_mode/extended/post_setup()
	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()
	SPAWN(10 MINUTES)
		santa_flyover(2, 186, 1, 130)
	SPAWN(30 MINUTES)
		santa_flyover(299, 205, 3, 90, WEST)
	SPAWN(2 MINUTES)
		santa_flyover(1, 180, 4, 50, grinched = TRUE)

/obj/sleigh

/mob/dummy_pilot
	name = ""
	desc = ""
	icon = 'icons/effects/1240x420.dmi'
	icon_state = "santa"
	anchored = ANCHORED
	alpha = 0
	density = 0
	nodamage = 1
	layer = 104 // AAAAAAAAA
	plane = 6
	flags = KEEP_TOGETHER
	event_handler_flags = IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP

	New()
		..()
		SPAWN(1 SECONDS)
			while (src.loc)
				var/turf/targetT = src.loc
				var/Ty = targetT.y + 4
				var/Tx = targetT.x + 3
				if (src.dir != EAST)
					Tx = Tx + 20
				targetT = locate(Tx, Ty, 1)
				var/obj/item/a_gift/festive/X = new /obj/item/a_gift/festive(targetT)
				ThrowRandom(X, rand(1,8), throw_type=THROW_NO_CLIP)
				sleep(rand(3, 30))

/datum/game_mode/extended/proc/santa_flyover(var/x_input, var/y_input, var/speed = 1, var/alpha_input = 130, var/direction = EAST, var/grinched = FALSE)
	var/mob/dummy_pilot/pilot = new /mob/dummy_pilot (locate(x_input, y_input, 1))
	pilot.dir = direction
	animate(pilot, 2 SECONDS, alpha=alpha_input)
	while (pilot.loc)
		if (pilot.x >= 170 && grinched)
			break
		move_forward(pilot, direction, speed)
		sleep(speed)
	if (!grinched)
		qdel(pilot)
		return

	get_grinched(pilot, direction)

/datum/game_mode/extended/proc/get_grinched(var/mob/dummy_pilot/pilot, var/direction)
	animate(pilot, alpha = 0, time = 4 SECONDS)
	var/turf/T = get_turf(locate(179, 185, 1))
	playsound(locate(T), "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
	var/obj/effects/explosion/boom = /obj/effects/explosion
	new boom (T)
	SPAWN(0.6 SECONDS)
		playsound(locate(183, 183, 1), "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
		new boom (locate(183, 183, 1))
	SPAWN(1.1 SECONDS)
		playsound(locate(181, 183, 1), "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
		new boom (locate(181, 183, 1))
	SPAWN(2 SECONDS)
		playsound(locate(185, 173, 1), "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
		new boom (locate(185, 173, 1))
	SPAWN(3 SECONDS)
		playsound(locate(184, 179, 1), "sound/effects/Explosion[pick(1, 2)].ogg", 15, 1)
		new boom (locate(184, 179, 1))
	for (var/i=0,i<=2,i++)
		for(var/t=0,t<=2,t++)
			move_forward(pilot, SOUTHEAST, 4)
			sleep(4)
			move_forward(pilot, SOUTHEAST, 4)
			sleep(4)
		for(var/o=0,o<=2,o++)
			move_forward(pilot, SOUTHWEST, 4)
			sleep(4)
	SPAWN (3 SECONDS)
		qdel(pilot)

/datum/game_mode/extended/proc/move_forward(var/mob/dummy_pilot/pilot, var/direction, var/speed = 1)
	var/glide = 0
	glide = (32 / speed) * world.tick_lag
	pilot.glide_size = glide
	pilot.animate_movement = SLIDE_STEPS
	var/old_loc = pilot.loc
	pilot.set_loc(get_step(pilot, direction))
	pilot.dir = direction
	SEND_SIGNAL(pilot, COMSIG_MOVABLE_MOVED, old_loc, direction)
	pilot.glide_size = glide
	pilot.animate_movement = SLIDE_STEPS
