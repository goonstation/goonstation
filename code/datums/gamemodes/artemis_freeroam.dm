/datum/game_mode/artemis_freeroam
	name = "free roam"
	config_tag = "freeroam"

/datum/game_mode/artemis_freeroam/announce()
	boutput(world, "<B>The current game mode is - Free Roam!</B>")
	boutput(world, "<B>Just have fun!</B>")

/datum/game_mode/artemis_freeroam/pre_setup()
	for (var/obj/artemis/ship in world)
		ship.my_galaxy = GALAXY
		ship.link_stars()
		ship.link_landmark()
		GALAXY.bodies += ship.background_ship_datum
	return 1