/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	do_antag_random_spawns = 0
	latejoin_antag_compatible = 0

/datum/game_mode/extended/pre_setup()
	. = ..()

	for(var/datum/random_event/event in random_events.events)
		if(istype(event, /datum/random_event/major/ion_storm))
			event.disabled = TRUE

/datum/game_mode/extended/announce()
	boutput(world, "<B>The current game mode is - Extended!</B>")
	boutput(world, "<B>Just have fun!</B>")
