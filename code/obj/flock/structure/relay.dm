/////////////////////////////////////////////////////////////////////////////////
// RELAY
/////////////////////////////////////////////////////////////////////////////////
/obj/flock_structure/relay
	icon = 'icons/misc/featherzone-160x160.dmi'
	icon_state = "structure-relay"
	anchored = 1
	density = 1
	name = "titanic polyhedron"
	desc = "The sight of the towering geodesic sphere fills you with dread. A thousand voices whisper to you."
	flock_id = "Signal Relay Broadcast Amplifier"
	build_time = 30
	health = 5000
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -64
	bound_x = -64
	bound_y = -64
	var/last_time_sound_played_in_seconds = 0
	var/sound_length_in_seconds = 27
	var/charge_time_length = 600 // also in seconds
	var/final_charge_time_length = 18
	var/col_r = 0.1
	var/col_g = 0.7
	var/col_b = 0.6
	var/datum/light/light
	var/brightness = 0.5

/obj/flock_structure/relay/New()
	..()
	// start playing sound
	play_sound()
	flock_speak(null, "RELAY CONSTRUCTED! DEFEND THE RELAY!!", src.flock)
	SPAWN_DBG(1 SECOND)
		radial_flock_conversion(src, 20)

/obj/flock_structure/relay/get_desc()
	var/time_remaining = round(src.charge_time_length - getTimeInSecondsSinceTime(src.time_started))
	if(time_remaining > 0)
		return "<br><span class='flocksay bold'>\[[time_remaining] second[s_es(time_remaining)] remaining until broadcast.\]</span>"

/obj/flock_structure/relay/building_specific_info()
	var/time_remaining = round(src.charge_time_length - getTimeInSecondsSinceTime(src.time_started))
	if(time_remaining > 0)
		return "<b>Approximately <span class='italic'>[time_remaining]</span> second[time_remaining == 1 ? "" : "s"] left until broadcast.</b>"
	else
		return "<b><i>BROADCASTING IN PROGRESS</i></b>"

/obj/flock_structure/relay/process()
	var/elapsed = getTimeInSecondsSinceTime(src.time_started)
	if(elapsed >= last_time_sound_played_in_seconds + sound_length_in_seconds)
		play_sound()
	if(elapsed >= charge_time_length/2)
		if(icon_state == "structure-relay")
			icon_state = "structure-relay-glow"
		// halfway point, start playing radio noises at people too
		for(var/mob/M in mobs)
			if(prob(20))
				M.playsound_local(M, "sound/effects/radio_sweep[rand(1,5)].ogg", 20, 1)
				if(prob(50))
					boutput(M, "<span class='flocksay italic'>... [radioGarbleText("the signal will set you free")] ...</span>")
	if(elapsed >= charge_time_length)
		// IT'S TIME, FINISH IT NOW
		unleash_the_signal()

/obj/flock_structure/relay/proc/play_sound()
	// reset the sound clock
	src.last_time_sound_played_in_seconds = getTimeInSecondsSinceTime(src.time_started)
	var/center_loc = get_turf(src)
	for(var/mob/M in mobs)
		M.playsound_local(M, "sound/ambience/spooky/Flock_Reactor.ogg", 35, 0, 2)
		boutput(M, "<span class='flocksay bold'>You hear something unworldly coming from the <i>[dir2text(get_dir(M, center_loc))]</i>!</span>")

/obj/flock_structure/relay/proc/unleash_the_signal()
	processing_items -= src
	var/turf/location = get_turf(src)
	overlays += "structure-relay-sparks"
	desc = "Your life is flashing before your eyes. Looks like this is the end."
	flock_speak(null, "!!! TRANSMITTING SIGNAL !!!", src.flock)
	src.visible_message("<span class='flocksay bold'>[src] begins sparking wildly! The air is charged with static!</span>")
	for(var/mob/M in mobs)
		M.playsound_local(M, "sound/misc/flockmind/flock_broadcast_charge.ogg", 60, 0, 2)
	sleep(final_charge_time_length * 10)
	// BOOOOOM
	for(var/mob/M in mobs)
		M.playsound_local(M, "sound/misc/flockmind/flock_broadcast_kaboom.ogg", 60, 0, 2)
		M.flash(30)
	SPAWN_DBG(1 SECOND)
		emergency_shuttle.incall()
		emergency_shuttle.can_recall = 0 // yeah centcom's coming no matter what
		boutput(world, "<span style=\"color:blue\"><B>Alert: The emergency shuttle has been called.</B></span>")
		boutput(world, "<span style=\"color:blue\">- - - <b>Reason:</b> Hostile transmission intercepted. Sending emergency shuttle.</span>")
		boutput(world, "<span style=\"color:blue\"><B>It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</B></span>")
	sleep(20)
	for(var/x = -2 to 2)
		for(var/y = -2 to 2)
			flockdronegibs(locate(location.x + x, location.y + y, location.z))
	explosion_new(src, location, 2000)
	gib(location)
