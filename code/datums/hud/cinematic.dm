/datum/hud/cinematic
	click_check = 0
	var/atom/movable/screen/hud/background
	var/atom/movable/screen/hud/animation

	proc/create_background()
		src.background = create_screen("bg", "", 'icons/mob/hud_common.dmi', "cinematic_bg", "1, 1 to NORTH, EAST", 98)
		src.objects += src.background

	proc/play(name)
		src.create_background()

/datum/hud/cinematic/all_clients
	var/excluded_mob_types //A list of mob types this global cinematic won't affect, e.g. list(/mob/living/carbon/human/tutorial)

	play()
		for (var/client/C in global.clients)
			if (src.excluded_mob_types && istypes(C.mob, src.excluded_mob_types))
				continue
			src.add_client(C)
		. = ..()

/datum/hud/cinematic/all_clients/nuclear_bomb
	var/intro_state = "start_nuke"
	var/loss_state = "loss_nuke"

	play()
		. = ..()
		src.animation = create_screen("cinematic", "", 'icons/effects/station_explosion.dmi', src.intro_state, "1:6, 1:50", 99)
		src.objects += src.animation
		SPAWN(3.5 SECONDS)
			src.animation.icon_state = "explode"
			sleep(1 SECOND)
			playsound_global(clients, 'sound/effects/kaboom.ogg', vol=100)
			sleep(8 SECONDS)
			src.animation.icon_state = src.loss_state

/datum/hud/cinematic/all_clients/nuclear_bomb/malf_ai
	intro_state = "start_malf"
	loss_state = "loss_malf"

/datum/hud/cinematic/all_clients/sadbuddy
	excluded_mob_types = list(/mob/living/carbon/human/tutorial)

	play()
		. = ..()
		src.animation = create_screen("cinematic", "", 'icons/effects/160x160.dmi', "sadbuddy", "CENTER-2,CENTER-2", 99)
		src.objects += src.animation
		playsound_global(clients, 'sound/misc/sad_server_death.ogg', vol=100)
		SPAWN(5 SECONDS)
			qdel(src)

