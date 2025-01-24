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
	for(var/datum/random_event/event in random_events.major_events)
		if(istype(event, /datum/random_event/major/law_rack_corruption))
			event.disabled = TRUE

/datum/game_mode/extended/announce()
	boutput(world, "<B>The current game mode is - Extended!</B>")
	boutput(world, "<B>Just have fun!</B>")

/datum/game_mode/extended/post_setup()
	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()
