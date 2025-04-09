/proc/command_alert(var/text, var/title = "", var/sound_to_play = "", var/do_sanitize = 1, var/alert_origin=null)
	var/big_title = alert_origin ? alert_origin : "[ALERT_GENERAL]"
	var/out_text = "<h1 class='alert'>[big_title]</h1>"
	if (title && length(title) > 0)
		out_text += "<h2 class='alert'>[title]</h2>"

	out_text += "[SPAN_ALERT("[replacetext(text, "\n", "<br>\n")]")]<br><br>"
	boutput(world, out_text)
	if (sound_to_play && length(sound_to_play) > 0)
		playsound_global(world, sound_to_play, 100)

	if (alert_origin == ALERT_WATCHFUL_EYE)
		for_by_tcl(eye, /mob/living/critter/small_animal/floateye/watchful)
			eye.make_jittery(rand(10, 250))

/proc/command_announcement(var/text, var/title, var/sound_to_play = "", var/css_class = "alert", var/do_sanitize = 1, volume = 100) //Slightly less conspicuous, but requires a title.
	if(!title || !text) return

	boutput(world, "<h2 class='alert'>[title]</h2><span class='[css_class]'>[text]</span><br><br>")
	if (sound_to_play && length(sound_to_play) > 0)
		playsound_global(world, sound_to_play, volume)

/proc/advanced_command_alert(var/text, var/title="", var/sound_to_play = "")
	if(!text) return 0
	//var/list/mob/mob_list = list()

/*	for(var/mob/M in world)
		if(M.client)
			mob_list+=M
		LAGCHECK(LAG_LOW)
*/
	var/client/rand_client_single = pick(clients)
	var/mob/rand_mob_single
	if (rand_client_single.mob)
		rand_mob_single = rand_client_single.mob //A single randomly selected player

	//for(var/mob/M in mob_list)
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

				var/out_text = "<h1 class='alert'>[ALERT_GENERAL]</h1>"
				if(title != "") out_text += "<h2 class='alert'>[title]</h2>"
				out_text += "[SPAN_ALERT("[text]")]<br><br>"
				boutput(M, out_text)

	if (sound_to_play && length(sound_to_play) > 0)
		playsound_global(world, sound_to_play, 100)

	return 1

