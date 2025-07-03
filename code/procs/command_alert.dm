/proc/command_alert(text, title = "", sound_to_play = "", do_sanitize = 1, alert_origin=null)
	var/big_title = alert_origin ? alert_origin : "[ALERT_GENERAL]"
	var/origin_class = alert_origin_class(alert_origin)

	var/out_text = {"
			<div class="command_alert [origin_class]">
				<h1 class="command_alert [origin_class]">[big_title]</h1>
				[length(title) ? {"<h2 class="command_alert [origin_class]">[title]</h2>"} : "" ]
				<p class="command_alert [origin_class]">[replacetext(text, "\n", "<br>\n")]</p>
			</div>
		"}

	boutput(world, out_text)
	if (sound_to_play && length(sound_to_play) > 0)
		playsound_global(world, sound_to_play, 100)

	if (alert_origin == ALERT_WATCHFUL_EYE)
		for_by_tcl(eye, /mob/living/critter/small_animal/floateye/watchful)
			eye.make_jittery(rand(10, 250))

 //Slightly less conspicuous, but requires a title.
/proc/command_announcement(text, title, sound_to_play = "", do_sanitize = 1, volume = 100, alert_origin=null)
	if(!title || !text) return

	var/origin_class = alert_origin_class(alert_origin)
	var/out_text = {"
		<div class="command_alert [origin_class]">
			[length(title) ? {"<h2 class="command_alert [origin_class]">[title]</h2>"} : "" ]
			<p class="command_alert [origin_class]">[replacetext(text, "\n", "<br>\n")]</p>
		</div>
	"}
	boutput(world, out_text)
	if (sound_to_play && length(sound_to_play) > 0)
		playsound_global(world, sound_to_play, volume)

/proc/advanced_command_alert(text, title="", sound_to_play = "", alert_origin=null)
	if(!text) return 0

	var/client/rand_client_single = pick(clients)
	var/mob/rand_mob_single
	if (rand_client_single.mob)
		rand_mob_single = rand_client_single.mob //A single randomly selected player

	var/big_title = alert_origin ? alert_origin : "[ALERT_GENERAL]"
	var/origin_class = alert_origin_class(alert_origin)

	for (var/client/C in clients)
		SPAWN(0)
			if(C.mob)//M.client)
				var/mob/M = C.mob
				var/client/rand_client_mult = pick(clients)
				var/mob/rand_mob_mult
				if (rand_client_mult?.mob) //ZeWaka: Fix for null.mob
					rand_mob_mult = rand_client_mult.mob //A randomly selected player that's different to each viewer

				var/atom/A = get_turf(M.loc)
				if(A) A = A.loc

				if(title != "")
					title = replacetext(title, "%name%", M.real_name)
					title = replacetext(title, "%key%", M.key)
					title = replacetext(title, "%job%", M.job ? M.job : "space hobo")
					title = replacetext(title, "%area_name%", A ? A.name : "some unknown place")
					title = replacetext(title, "%srand_name%", rand_mob_single.name)
					title = replacetext(title, "%srand_job%", rand_mob_single.job ? rand_mob_single.job : "space hobo" )
					title = replacetext(title, "%mrand_name%", rand_mob_mult.name)
					title = replacetext(title, "%mrand_job%", rand_mob_mult.job ? rand_mob_mult.job : "space hobo")

				text = replacetext(text, "%name%", M.real_name)
				text = replacetext(text, "%key%", M.key)
				text = replacetext(text, "%job%", M.job ? M.job : "space hobo")
				text = replacetext(text, "%area_name%", A ? A.name : "some unknown place")
				text = replacetext(text, "%srand_name%", rand_mob_single.name)
				text = replacetext(text, "%srand_job%", rand_mob_single.job ? rand_mob_single.job : "space hobo")
				text = replacetext(text, "%mrand_name%", rand_mob_mult.name)
				text = replacetext(text, "%mrand_job%", rand_mob_mult.job ? rand_mob_mult.job : "space hobo")

				var/out_text = {"
					<div class="command_alert [origin_class]">
						<h1 class="command_alert [origin_class]">[big_title]</h1>
						[length(title) ? {"<h2 class="command_alert [origin_class]">[title]</h2>"} : "" ]
						<p class="command_alert [origin_class]">[replacetext(text, "\n", "<br>\n")]</p>
					</div>
				"}

				boutput(M, out_text)

	if (sound_to_play && length(sound_to_play) > 0)
		playsound_global(world, sound_to_play, 100)

	return 1

proc/alert_origin_class(alert_origin)
	. = ALERT_GENERAL_CLASS
	switch(alert_origin)
		if(ALERT_GENERAL)
			return ALERT_GENERAL_CLASS
		if(ALERT_ANOMALY)
			return ALERT_ANOMALY_CLASS
		if(ALERT_WEATHER)
			return ALERT_WEATHER_CLASS
		if(ALERT_STATION)
			return ALERT_STATION_CLASS
		if(ALERT_WATCHFUL_EYE)
			return ALERT_WATCHFUL_EYE_CLASS
		if(ALERT_EGERIA_PROVIDENCE)
			return ALERT_EGERIA_CLASS
		if(ALERT_DEPARTMENT)
			return ALERT_DEPARTMENT_CLASS
		if(ALERT_COMMAND)
			return ALERT_COMMAND_CLASS
		if(ALERT_CLOWN)
			return ALERT_CLOWN_CLASS
		if(ALERT_SYNDICATE)
			return ALERT_SYNDICATE_CLASS
