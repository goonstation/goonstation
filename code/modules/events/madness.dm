//Lovingly Adapted from sleeper agent code
/datum/random_event/major/antag/madness
	name = "Mass Madness"
#ifdef MAP_OVERRIDE_NEON
	disabled = FALSE
#else
	disabled = TRUE
#endif
	customization_available = TRUE
	var/num_victims = 0

	admin_call(source)
		. = ..()
		src.num_victims = input(usr, "How many minds to break?", src.name, 0) as num|null
		if (isnull(src.num_victims))
			return
		else if (src.num_victims < 1)
			return
		else
			src.num_victims = round(src.num_victims)
		src.event_effect(source)

	event_effect(source)
		set waitfor = FALSE
		. = ..()

		src.sound_event()

		sleep(5 SECONDS)

		//try to keep it mostly central over the station but with some randomness
		var/atom/movable/seamonster_overlay/monster = new(locate(100, rand(130, 190), Z_LEVEL_STATION))
		monster.alpha = 0
		animate(monster, 10 SECONDS, alpha = 255)
		//so I went through a full 4 arc hero's journey story for this snippet of code
		//parallax was too jumpy, animate caused flickering issues because it only renders at either end of the animation
		//a Move/glide loop seems like the goldilocks solution for moving large objects (mostly) smoothly across long distances
		SPAWN(0)
			for (var/i in 1 to 100)
				if (QDELETED(monster))
					break
				monster.glide_size = 32/(3 SECONDS) * world.tick_lag
				monster.set_loc(get_step(monster, EAST))
				sleep(3 SECONDS)

		src.shake_event()

		sleep(rand(3, 7) SECONDS)

		var/distance = pick(300, 500, 750, 1500) //meters
		var/speed = rand(5, 15) //m/s
		var/displacement = pick(500, 2000, 3000, 10000) //tons
		//https://pixabay.com/sound-effects/alarm-301729/
		command_alert("An untracked object has been detected on an approach vector to Neon Deepwater Research Facility.<br>Current depth: [distance] meters above seafloor, closing at [speed]m/s.<br>Estimated displacement: [displacement] tons.", "Automated proximity alert", 'sound/machines/proximity_alarm.ogg', alert_origin = "Abzu Sonar Monitoring Array")

		sleep(rand(10, 20) SECONDS)

		src.sound_event()

		if (prob(80)) //sometimes all the paranoia was for nothing...
			src.cause_madness()

		var/start_time = TIME
		while (TIME - start_time < 4 MINUTES)
			sleep(rand(20, 60) SECONDS)
			src.sound_event()
		animate(monster, alpha = 0, time = 10 SECONDS)
		sleep(10 SECONDS)
		qdel(monster)

	proc/cause_madness()
		var/list/potential_victims = list()
		for (var/mob/living/carbon/human/H in global.mobs)
			if (H.client && !H.mind?.is_antagonist() && !isVRghost(H) && H.client.preferences.be_misc && isalive(H)) //using "misc" prefs for now
				potential_victims += H
		if (src.num_victims <= 0)
			if (length(potential_victims) <= 10) //some concession for not making everything completely insane on lowpop
				src.num_victims = rand(2, 3)
			else
				src.num_victims = rand(4, 8)
		src.num_victims = min(src.num_victims, length(potential_victims))
		//frick u static
		/datum/antagonist/broken::shared_objective_text = null
		for (var/i in 1 to src.num_victims)
			var/mob/living/carbon/human/victim = pick(potential_victims)
			victim.mind.add_antagonist(ROLE_BROKEN)
			potential_victims -= victim

	proc/shake_event()
		for (var/mob/M in mobs)
			if (M.client)
				shake_camera(M, 2 SECONDS, 20)
			else if (isnpcmonkey(M))
				SPAWN(rand(1, 3) SECONDS)
					M.emote("scream")

	proc/sound_event()
		set waitfor = FALSE
		var/chosen_spook = rand(1,5)
		switch(chosen_spook)
			if (1)
				var/beats = rand(2,5)
				var/delay = rand(1,3) SECONDS
				for (var/i in 1 to beats)
					//https://pixabay.com/sound-effects/monster-footstep-162883/ - TODO: put these in final PR
					var/chosen_boom = pick(list('sound/effects/seamonster/beats/boom1.ogg', 'sound/effects/seamonster/beats/boom2.ogg', 'sound/effects/seamonster/beats/boom3.ogg', 'sound/effects/seamonster/beats/boom4.ogg'))
					src.play_to_station(chosen_boom, 65, 1)
					sleep(delay)
			if (2)
				//https://pixabay.com/sound-effects/horror-sound-lurking-horror-monster-189948/
				src.play_to_station('sound/effects/seamonster/groan1.ogg', 40, 1)
				if (prob(50))
					sleep(3 SECONDS)
					src.shake_event()
			if (3)
				//https://pixabay.com/sound-effects/horror-sound-monster-breath-189934/
				src.play_to_station('sound/effects/seamonster/breathe1.ogg', 30, 1)
			if (4)
				//https://pixabay.com/sound-effects/creepy-whale-song-323612/
				src.play_to_station('sound/effects/seamonster/whale1.ogg', 50, 1)
			if (5)
				//https://pixabay.com/sound-effects/haunting-whale-song-323611/
				src.play_to_station('sound/effects/seamonster/whale2.ogg', 50, 1)


	proc/play_to_station(soundin, vol, vary)
		for (var/client/C in global.clients)
			if (get_z(C.mob) == Z_LEVEL_STATION)
				C.mob.playsound_local_not_inworld(soundin, vol, vary)

	cleanup()
		src.num_victims = 0

/atom/movable/seamonster_overlay
	icon = 'icons/misc/1024x1024.dmi'
	icon_state = "seamonster1"
	plane = PLANE_ABOVE_FOREGROUND_PARALLAX
	anchored = TRUE
	mouse_opacity = FALSE

	New()
		. = ..()
		//TODO: more/better seamonster shadows?
		src.icon_state = "seamonster[rand(1,2)]"
		src.Scale(2,2)
