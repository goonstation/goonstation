/////////////////////////////////////////////////////////////////////////////////
// RELAY
/////////////////////////////////////////////////////////////////////////////////

// Important: Reduce size of max_conv_radius if you are planning on viewing
// variables of the relay, otherwise it will take a long time to load

/obj/flock_structure/relay
	icon = 'icons/misc/featherzone-160x160.dmi'
	icon_state = "structure-relay"
	name = "titanic polyhedron"
	desc = "The sight of the towering geodesic sphere fills you with dread. A thousand voices whisper to you."
	flock_desc = "Your goal and purpose. Defend it until it can broadcast the Signal."
	flock_id = "Signal Relay Broadcast Amplifier"
	build_time = 30
	health = 600 //same as a nukie nuke * 4 because nuke has /4 damage resist
	uses_health_icon = FALSE
	resourcecost = 750
	bound_width = 160
	bound_height = 160
	pixel_x = -64
	pixel_y = -64
	bound_x = -64
	bound_y = -64
	hitTwitch = FALSE
	layer = EFFECTS_LAYER_BASE //big spooky thing needs to render over everything
	plane = PLANE_NOSHADOW_ABOVE
	var/conversion_radius = 1
	var/max_conv_radius = 15 // increase back to 100 later if possible
	var/list/turfs_to_convert = null
	var/last_time_sound_played_in_seconds = 0
	var/sound_length_in_seconds = 27
	var/charge_time_length = 360 // in seconds
	var/final_charge_time_length = 18
	var/finished = FALSE
	var/col_r = 0.1
	var/col_g = 0.7
	var/col_b = 0.6
	var/datum/light/light
	var/brightness = 0.5
	var/shuttle_departure_delayed = FALSE

/obj/flock_structure/relay/New()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src, 9)

	..()
	logTheThing(LOG_GAMEMODE, src, "Flock relay is constructed[src.flock ? " by flock [src.flock.name]" : ""] at [log_loc(src)].")
	src.info_tag.set_tag_offset(64, -4) // to account for 5x5 sprite
	src.info_tag.set_info_tag("Completion time: [round(src.charge_time_length - getTimeInSecondsSinceTime(src.time_started))] seconds")
	// no shuttle for you, either destroy the relay or flee when it unleashes
	if (emergency_shuttle.online)
		if (emergency_shuttle.direction == 1 && emergency_shuttle.location != SHUTTLE_LOC_STATION && emergency_shuttle.location != SHUTTLE_LOC_TRANSIT)
			emergency_shuttle.recall()
			command_alert("Emergency shuttle approach aborted due to anomalous radio signal interference. The shuttle has been returned to base as a precaution.")
			emergency_shuttle.disabled = SHUTTLE_CALL_MANUAL_CALL_DISABLED
		else if (emergency_shuttle.location == SHUTTLE_LOC_STATION)
			emergency_shuttle.settimeleft(src.charge_time_length + SHUTTLELEAVETIME)
			src.shuttle_departure_delayed = TRUE
			command_alert("Emergency shuttle departure delayed due to anomalous radio signal interference.")

	boutput(src.flock?.flockmind, "<span class='alert'><b>You pull together the collective force of your Flock to transmit the Signal. If the Relay is destroyed, you're dead!</b></span>")
	flock_speak(null, "RELAY CONSTRUCTED! DEFEND THE RELAY!!", src.flock)
	play_sound()
	SPAWN(10 SECONDS)
		var/msg = "Overwhelming anomalous power signatures detected on station. This is an existential threat to the station. All personnel must contain this event."
		msg = radioGarbleText(msg, 7)
		command_alert(msg, sound_to_play = 'sound/misc/announcement_1.ogg', alert_origin = ALERT_ANOMALY)

	turfs_to_convert = list()
	var/turf/center = get_turf(src)
	for (var/turf/T as anything in block(locate(max(center.x - src.max_conv_radius, 1), max(center.y - src.max_conv_radius, 1), center.z), locate(min(center.x + src.max_conv_radius, world.maxx), min(center.y + src.max_conv_radius, world.maxy), center.z)))
		LAGCHECK(LAG_LOW)
		if (!flockTurfAllowed(T))
			continue
		var/dist = round(GET_EUCLIDEAN_DIST(center, T))
		if (dist > src.max_conv_radius)
			continue
		if (!("[dist]" in turfs_to_convert))
			turfs_to_convert["[dist]"] = list()
		turfs_to_convert["[dist]"] |= T

/obj/flock_structure/relay/disposing()
	REMOVE_ATOM_PROPERTY(src, PROP_ATOM_TELEPORT_JAMMER, src)
	var/mob/living/intangible/flock/flockmind/F = src.flock?.flockmind
	logTheThing(LOG_GAMEMODE, src, "Flock relay[src.flock ? " belonging to flock [src.flock.name]" : ""] is destroyed at [log_loc(src)].")
	..()
	if (!src.finished)
		F?.death(relay_destroyed = TRUE)
	if (!src.shuttle_departure_delayed)
		emergency_shuttle.disabled = SHUTTLE_CALL_ENABLED

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
	if (src.conversion_radius <= length(src.turfs_to_convert))
		src.convert_turfs()
		src.conversion_radius++

	var/elapsed = getTimeInSecondsSinceTime(src.time_started)
	src.info_tag.set_info_tag("Completion time: [round(src.charge_time_length - elapsed)] seconds")
	if(elapsed >= last_time_sound_played_in_seconds + sound_length_in_seconds)
		play_sound()
	if(elapsed >= charge_time_length/2) // halfway point, start doing more
		if(icon_state == "structure-relay")
			icon_state = "structure-relay-glow"

		for(var/mob/M in mobs)
			if(prob(20))
				M.playsound_local(M, "sound/effects/radio_sweep[rand(1,5)].ogg", 20, 1)
				if(prob(50))
					boutput(M, "<span class='flocksay italic'>... [radioGarbleText("the signal will set you free")] ...</span>")
	if(elapsed >= charge_time_length)
		unleash_the_signal()

/obj/flock_structure/relay/proc/play_sound()
	src.last_time_sound_played_in_seconds = getTimeInSecondsSinceTime(src.time_started)
	var/center_loc = get_turf(src)
	for(var/mob/M in mobs)
		M.playsound_local(M, 'sound/ambience/spooky/Flock_Reactor.ogg', 35, 0, 2)
		boutput(M, "<span class='flocksay bold'>You hear something unworldly coming from the <i>[dir2text(get_dir(M, center_loc))]</i>!</span>")

/obj/flock_structure/relay/proc/convert_turfs()
	SPAWN(0)
		for (var/turf/T as anything in src?.turfs_to_convert["[src.conversion_radius]"])
			LAGCHECK(LAG_LOW)
			if (istype(T, /turf/simulated) && !isfeathertile(T))
				src?.flock?.claimTurf(flock_convert_turf(T))

/obj/flock_structure/relay/proc/unleash_the_signal()
	if(src.finished)
		return
	logTheThing(LOG_GAMEMODE, src, "Flock relay[src.flock ? " belonging to flock [src.flock.name]" : ""] unleashes the signal, exploding at [log_loc(src)].")
	src.finished = TRUE
	src.flock.relay_finished = TRUE
	processing_items -= src
	var/turf/location = get_turf(src)
	overlays += "structure-relay-sparks"
	desc = "Your life is flashing before your eyes. Looks like this is the end."
	flock_speak(null, "!!! TRANSMITTING SIGNAL !!!", src.flock)
	src.visible_message("<span class='flocksay bold'>[src] begins sparking wildly! The air is charged with static!</span>")
	for(var/mob/M in mobs)
		M.playsound_local(M, 'sound/misc/flockmind/flock_broadcast_charge.ogg', 30, 0)
	sleep(final_charge_time_length SECONDS)

	for(var/mob/M in mobs)
		M.playsound_local(M, 'sound/misc/flockmind/flock_broadcast_kaboom.ogg', 30, 0)
		M.flash(3 SECONDS)
	if (!src.shuttle_departure_delayed)
		SPAWN(1 SECOND)
			emergency_shuttle.disabled = SHUTTLE_CALL_ENABLED
			emergency_shuttle.incall()
			emergency_shuttle.can_recall = FALSE
			emergency_shuttle.settimeleft(60) // cut the time down to keep some sense of urgency
			boutput(world, "<span class='notice'><B>Alert: The emergency shuttle has been called.</B></span>")
			boutput(world, "<span class='notice'>- - - <b>Reason:</b> Hostile transmission intercepted. Sending rapid response emergency shuttle.</span>")
			boutput(world, "<span class='notice'><B>It will arrive in [round(emergency_shuttle.timeleft())] seconds.</B></span>")
	sleep(2 SECONDS)
	for(var/x = -2 to 2)
		for(var/y = -2 to 2)
			flockdronegibs(locate(location.x + x, location.y + y, location.z))
	explosion_new(src, location, 2000)
	gib(location)
	flock_signal_unleashed = TRUE
	sleep(2 SECONDS) //allow them to hear the explosion before their headsets scream and die
	destroy_radios()

///Brick every headset noisily
/obj/flock_structure/relay/proc/destroy_radios()
	// mid-tier jank, but it's a nice easy way to get the radio network
	var/obj/item/device/radio/headset/entrypoint = new()
	var/list/obj/radios = get_radio_connection_by_id(entrypoint, "main").network.analog_devices
	for (var/obj/item/device/radio/radio in radios)
		if (!istype(radio))
			continue
		if (prob(30)) //give it a slight cascading effect
			sleep(0.1 SECONDS)
		playsound(radio, "sound/effects/radio_sweep[rand(1,5)].ogg", 70, 1, pitch = 0.4)
		var/mob/wearer = radio.loc
		if (istype(wearer))
			wearer.show_text("A final scream of horrific static bursts from your radio, destroying it!", "red")
			wearer.apply_sonic_stun(3, 6, 60, 0, 0, rand(1, 3), rand(1, 3))
		radio.bricked = TRUE
		radio.frequency = rand(R_FREQ_MINIMUM, 10000)
		radio.secure_frequencies = list()
		radio.set_secure_frequencies()
	qdel(entrypoint)
