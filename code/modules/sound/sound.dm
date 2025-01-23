#define TOO_QUIET 0.9 //experimentally found to be 0.6 - raised due to lag, I don't care if it's super quiet because there's already shitloads of other sounds playing
#define SPACE_ATTEN_MIN 0.5
#define EARLY_RETURN_IF_QUIET(v) if (v < TOO_QUIET) return
#define EARLY_CONTINUE_IF_QUIET(v) if (v < TOO_QUIET) continue

#define SOURCE_ATTEN(A) do {\
	if (A <= SPACE_ATTEN_MIN){\
		vol *= SPACE_ATTEN_MIN;\
		extrarange = clamp(-MAX_SOUND_RANGE + MAX_SPACED_RANGE + extrarange, -32,-20);\
		spaced_source = 1;\
	}\
	else{\
		vol *= A\
	}\
} while(FALSE)

#define LISTENER_ATTEN(A) do {\
	if (A <= SPACE_ATTEN_MIN){\
		if (!spaced_source && dist >= MAX_SPACED_RANGE){\
			ourvolume = 0;\
		}\
		else{\
			spaced_env = 1;\
			ourvolume = clamp(ourvolume + 95, 25,200);\
		}\
	}\
	else{\
		ourvolume *= A\
	}\
} while(FALSE)

#define MAX_SPACED_RANGE 6 //diff range for when youre in a vaccuum
#define CLIENT_IGNORES_SOUND(C) (C?.ignore_sound_flags && ((ignore_flag && C.ignore_sound_flags & ignore_flag) || C.ignore_sound_flags & SOUND_ALL))

#define SOUNDIN_ID (istype(soundin, /sound) ? soundin:file : (islist(soundin) ? ref(soundin) : soundin))

/// returns 0 to 1 based on air pressure in turf
/proc/attenuate_for_location(var/atom/loc)
	var/attenuate = 1
	var/turf/T = get_turf(loc)

	if (T)
		if  (T.special_volume_override >= 0)
			return T.special_volume_override
			//if (istype(T, /turf/space/fluid))
			//	return 0.62 //todo : a cooler underwater effect if possible
			//if (istype(T, /turf/space))
			//	return 0 // in space nobody can hear you fart
		if (issimulatedturf(T)) //danger :)
			var/datum/gas_mixture/air = T.return_air()
			if (air)
				attenuate *= MIXTURE_PRESSURE(air) / ONE_ATMOSPHERE
				attenuate = clamp(attenuate, 0, 1)

	return attenuate

var/global/SPACED_ENV = list(100,0.52,0,-1600,-1500,0,2,2,-10000,0,200,0.01,0.165,0,0.25,0.01,-5,1000,20,10,53,100,0x3f)
var/global/SPACED_ECHO = list(-10000,0,-1450,0,0,1,0,1,10,10,0,1,0,10,10,10,10,7)
var/global/ECHO_AFAR = list(0,0,0,0,0,0,-10000,1.0,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
var/global/ECHO_CLOSE = list(0,0,0,0,0,0,0,0.25,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
var/global/list/falloff_cache = list()

//default volumes
var/global/list/default_channel_volumes = list(1, 1, 1, 0.5, 0.5, 1, 1)

//volumous hair with l'orial paris
/client/var/list/volumes
/client/var/list/sound_playing = new/list(1024, 2)

/// Returns a list of friendly names for available sound channels
/client/proc/getVolumeNames()
	return list("Game", "Ambient", "Radio", "Admin", "Emote", "Mentor PM")

/// Returns the default volume for a channel, unattenuated for the master channel (0-1)
/client/proc/getDefaultVolume(channel)
	return default_channel_volumes[channel + 1]

/// Returns a list of friendly descriptions for available sound channels
/client/proc/getVolumeDescriptions()
	return list("This will affect all sounds.", "Most in-game audio will use this channel.", "Ambient background music in various areas will use this channel.", "Any music played from the radio station", "Any music or sounds played by admins.", "Screams and farts.", "Mentor PM notification sound.")

/// Get the friendly description for a specific sound channel.
/client/proc/getVolumeChannelDescription(channel)
	// +1 since master channel is 0, while byond arrays start at 1
	return getVolumeDescriptions()[channel+1]

/// Returns the volume to set /sound/var/volume to for the given channel(so 0-100)
/client/proc/getVolume(id)
	return volumes[id + 1] * volumes[1] * 100

/// Returns the master volume (0-1)
/client/proc/getMasterVolume()
	return volumes[1]

/// Returns the true volume for a channel, unattenuated for the master channel (0-1)
/client/proc/getRealVolume(channel)
	return volumes[channel + 1]

/// Sets and applies the volume for a channel (0-1)
/client/proc/setVolume(channel, volume)
	var/original_volume = volumes[channel + 1]
	if(original_volume == 0)
		original_volume = 1 // let's be safe and try to avoid division by zero
	volume = clamp(volume, 0, 2)
	volumes[channel + 1] = volume

	src.player.cloudSaves.putData("audio_volume", json_encode(volumes))

	var/list/playing = src.SoundQuery()
	if( channel == VOLUME_CHANNEL_MASTER )
		for( var/sound/s in playing )
			s.status |= SOUND_UPDATE
			var/list/vol = sound_playing[ s.channel ]
			s.volume = vol[1] * volume * volumes[ vol[2] ]
			src << s
		src.chatOutput.adjustVolumeRaw( volume * getRealVolume(VOLUME_CHANNEL_ADMIN) )
	else
		for( var/sound/s in playing )
			if( sound_playing[s.channel][2] == channel )
				s.status |= SOUND_UPDATE
				s.volume = sound_playing[s.channel][1] * volume * volumes[1]
				src << s

	if( channel == VOLUME_CHANNEL_ADMIN )
		src.chatOutput.adjustVolumeRaw( getMasterVolume() * volume )

/proc/playsound(atom/source, soundin, vol, vary, extrarange, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
	if(isarea(source))
		CRASH("playsound(): source is an area [source.name], sound is [soundin]")

	var/turf/source_turf = get_turf(source)

	// don't play if the sound is happening nowhere
	if (isnull(source_turf))
		return

	// don't play if over the per-tick sound limit
	var/play_id = "[(source_turf.x / SOUND_LIMITER_GRID_SIZE)] [round(source_turf.y / SOUND_LIMITER_GRID_SIZE)] [source_turf.z] [SOUNDIN_ID]"
	if (!limiter || !limiter.canISpawn(/sound) || !limiter.canISpawn(play_id, 1))
		return

	EARLY_RETURN_IF_QUIET(vol)

	var/area/source_location = get_area(source)
	var/source_location_sound_group = null
	if (source_location)
		source_location_sound_group = source_location.sound_group

	var/spaced_source = 0
	var/spaced_env = 0
	var/atten_temp = attenuate_for_location(source_turf)
	SOURCE_ATTEN(atten_temp)
	//message_admins("volume: [vol]")
	EARLY_RETURN_IF_QUIET(vol)

	var/area/listener_location

	var/dist
	var/sound/S
	var/turf/Mloc
	var/ourvolume
	var/scaled_dist
	var/storedVolume

	// ugly but I can't really put this anywhere else
	if (ishuman(source) && channel == VOLUME_CHANNEL_EMOTE)
		var/mob/living/carbon/human/H = source
		// yes, these are all the conditions that make your force whisper. needs an atom prop, christ
		// if we meet any of them, halve volume of emotes
		if (H.oxyloss > 10 || H.losebreath >= 4 || H.hasStatus("muted") \
		    || (H.reagents?.has_reagent("capulettium_plus") && H.hasStatus("resting")) \
			|| H.stamina < STAMINA_WINDED_SPEAK_MIN)
			vol /= 2

	// at this multiple of the max range the sound will be below TOO_QUIET level, derived from falloff equation lower in the code
	var/rangemult = 0.18/(-(TOO_QUIET + 0.0542  * vol)/(TOO_QUIET - vol))**(10/17)
	for (var/client/C in GET_NEARBY(/datum/spatial_hashmap/clients, source_turf, rangemult * (MAX_SOUND_RANGE + extrarange)))
		var/mob/M = C.mob
		if (!C)
			continue

		if (CLIENT_IGNORES_SOUND(C))
			continue

		if (!(flags & SOUND_IGNORE_DEAF) && !M.hearing_check(FALSE, TRUE))
			continue
		Mloc = get_turf(M)

		if (!Mloc)
			continue

		//Hard attentuation
		dist = max(GET_MANHATTAN_DIST(Mloc, source_turf), 1)
		if (dist > MAX_SOUND_RANGE + extrarange)
			continue

		listener_location = Mloc.loc
		if(listener_location)

			if(source_location_sound_group && source_location_sound_group != listener_location.sound_group)
				//boutput(M, "You did not hear a [source] at [source_location] due to the sound_group ([source_location.sound_group]) not matching yours ([listener_location.sound_group])")
				continue

			//volume-related handling
			ourvolume = vol

			//Custom falloff handling, see: https://www.desmos.com/calculator/ybukxuu9l9
			if (dist > falloff_cache.len)
				falloff_cache.len = dist
			var/falloffmult
			if(extrarange == 0)
				falloffmult = falloff_cache[dist]
			if (falloffmult == null)
				scaled_dist = clamp(dist/(MAX_SOUND_RANGE+extrarange),0,1)
				falloffmult = (1 - ((1.0542 * (0.18**-1.7)) / ((scaled_dist**-1.7) + (0.18**-1.7))))
				if(extrarange == 0)
					falloff_cache[dist] = falloffmult

			ourvolume *= falloffmult

			EARLY_CONTINUE_IF_QUIET(ourvolume)

			//mbc : i'm making a call and removing this check's affect on volume bc it gets quite expensive and i dont care about the sound being quieter
			//if(M.ears_protected_from_sound()) //Bone conductivity, I guess?
			//	ourvolume *= 0.2

			atten_temp = attenuate_for_location(Mloc)
			LISTENER_ATTEN(atten_temp)

			storedVolume = ourvolume
			ourvolume *= C.getVolume(channel) / 100
			//boutput(world, "for client [C] updating volume [storedVolume] to [ourvolume] for channel [channel]")

			EARLY_CONTINUE_IF_QUIET(ourvolume)

			//sadly, we must generate
			if (!S) S = generate_sound(source, soundin, vol, vary, extrarange, pitch)
			if (!S) CRASH("Did not manage to generate sound \"[soundin]\" with source [source]. Likely that the filename is misnamed or does not exist.")
			C.sound_playing[ S.channel ][1] = storedVolume
			C.sound_playing[ S.channel ][2] = channel

			S.volume = ourvolume

			var/orig_freq = S.frequency
			S.frequency *= (HAS_ATOM_PROPERTY(C.mob, PROP_MOB_HEARD_PITCH) ? GET_ATOM_PROPERTY(C.mob, PROP_MOB_HEARD_PITCH) : 1)

			// play without spaced for stuff inside the source, for example pod sounds for people in the pod
			// we might at some point want to make this check multiple levels deep, but for now this is fine
			if (spaced_env && !(flags & SOUND_IGNORE_SPACE) && (isturf(source) || ismob(source) || !(M in source)))
				S.environment = SPACED_ENV
				S.echo = SPACED_ECHO
			else
				if(listener_location != source_location) // are they in a different area?
					//boutput(M, "You barely hear a [source] at [source_location]!")
					S.echo = ECHO_AFAR //Sound is occluded
				else
					//boutput(M, "You hear a [source] at [source_location]!")
					S.echo = ECHO_CLOSE

			S.x = source_turf.x - Mloc.x
			S.z = source_turf.y - Mloc.y //Since sound coordinates are 3D, z for sound falls on y for the map.  BYOND.
			S.y = 0

			C << S

			S.frequency = orig_freq


/mob/proc/playsound_local(atom/source, soundin, vol, vary, extrarange, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
	if(!src.client)
		return

	if (!(flags & SOUND_IGNORE_DEAF) && !src.hearing_check(FALSE, TRUE))
		return

	var/turf/source_turf = get_turf(source)

	// don't play if the sound is happening nowhere
	if (isnull(source_turf))
		return

	var/dist = max(GET_MANHATTAN_DIST(get_turf(src), source_turf), 1)
	if (dist > MAX_SOUND_RANGE + extrarange)
		return

	if (CLIENT_IGNORES_SOUND(src.client))
		return

	var/play_id = "\ref[src] [SOUNDIN_ID]"
	if (!limiter || !limiter.canISpawn(/sound) || !limiter.canISpawn(play_id, 1))
		return

	EARLY_RETURN_IF_QUIET(vol)

	//Custom falloff handling, see: https://www.desmos.com/calculator/ybukxuu9l9
	if (dist > falloff_cache.len)
		falloff_cache.len = dist
	var/falloffmult = falloff_cache[dist]
	if (falloffmult == null)
		var/scaled_dist = clamp(dist/(MAX_SOUND_RANGE+extrarange),0,1)
		falloffmult = (1 - ((1.0542 * (0.18**-1.7)) / ((scaled_dist**-1.7) + (0.18**-1.7))))
		falloff_cache[dist] = falloffmult

	vol *= falloffmult

	EARLY_RETURN_IF_QUIET(vol)

	var/spaced_source = 0
	var/spaced_env = 0
	var/atten_temp = attenuate_for_location(source)
	SOURCE_ATTEN(atten_temp)

	EARLY_RETURN_IF_QUIET(vol)

	var/ourvolume = vol
	atten_temp = attenuate_for_location(get_turf(src))
	LISTENER_ATTEN(atten_temp)

	var/sound/S = generate_sound(source, soundin, ourvolume, vary, extrarange, pitch)
	if (!S) CRASH("Did not manage to generate sound \"[soundin]\" with source [source]. Likely that the filename is misnamed or does not exist.")
	client.sound_playing[ S.channel ][1] = ourvolume
	client.sound_playing[ S.channel ][2] = channel

	if (S)
		if (spaced_env && !(flags & SOUND_IGNORE_SPACE) && (isturf(source) || ismob(source) || !(src in source)))
			S.environment = SPACED_ENV
			S.echo = SPACED_ECHO

		if (istype(source_turf))
			var/dx = source_turf.x - src.x
			S.pan = clamp(dx/8.0 * 100, -100, 100)

		S.frequency *= (HAS_ATOM_PROPERTY(src, PROP_MOB_HEARD_PITCH) ? GET_ATOM_PROPERTY(src, PROP_MOB_HEARD_PITCH) : 1)

		S.volume = ourvolume * client.getVolume(channel) / 100

		src << S

		if (length(src.observers) && !(flags & SOUND_SKIP_OBSERVERS))
			for (var/mob/M in src.observers)
				if (!M.client || CLIENT_IGNORES_SOUND(M.client))
					continue

				M.client.sound_playing[ S.channel ][1] = ourvolume
				M.client.sound_playing[ S.channel ][2] = channel

				S.volume = ourvolume * M.client.getVolume(channel) / 100

				M << S

/// like playsound_local but without a source atom, this just plays at a given volume
/mob/proc/playsound_local_not_inworld(soundin, vol, vary, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0, wait=FALSE)
	if(!src.client)
		return

	if (!(flags & SOUND_IGNORE_DEAF) && !src.hearing_check(FALSE, TRUE))
		return

	if (CLIENT_IGNORES_SOUND(src.client))
		return

	var/play_id = "\ref[src] [SOUNDIN_ID]"
	if (!limiter || !limiter.canISpawn(/sound) || !limiter.canISpawn(play_id, 1))
		return

	EARLY_RETURN_IF_QUIET(vol)

	var/sound/S = generate_sound(null, soundin, vol, vary, 0, pitch)
	if (!S) CRASH("Did not manage to generate sound \"[soundin]\". Likely that the filename is misnamed or does not exist.")
	client.sound_playing[ S.channel ][1] = vol
	client.sound_playing[ S.channel ][2] = channel
	if(wait)
		S.wait = TRUE

	S.frequency *= (HAS_ATOM_PROPERTY(src, PROP_MOB_HEARD_PITCH) ? GET_ATOM_PROPERTY(src, PROP_MOB_HEARD_PITCH) : 1)

	S.volume = vol * client.getVolume(channel) / 100

	src << S

	if (length(src.observers) && !(flags & SOUND_SKIP_OBSERVERS))
		for (var/mob/M in src.observers)
			if (!M.client || CLIENT_IGNORES_SOUND(M.client))
				continue
			M.client.sound_playing[ S.channel ][1] = vol
			M.client.sound_playing[ S.channel ][2] = channel
			S.volume = vol * M.client.getVolume(channel) / 100

			M << S

/**
	Plays a sound to some clients without caring about its source location and stuff.
	`target` can be either a list of clients or a list of mobs or `world` or an area or a z-level number.
*/
/proc/playsound_global(target, soundin, vol, vary, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME)
	// don't play if over the per-tick sound limit
	if (!limiter || !limiter.canISpawn(/sound))
		return

	var/play_id = "global [SOUNDIN_ID]"
	if (!limiter || !limiter.canISpawn(/sound) || !limiter.canISpawn(play_id, 1))
		return

	EARLY_RETURN_IF_QUIET(vol)

	var/list/clients = null
	if(islist(target))
		if(!length(target))
			return
		if(isclient(target[1]))
			clients = target
		else if(ismob(target[1]))
			clients = list()
			for(var/mob/M as anything in target)
				if(M.client)
					clients += M.client
		else
			CRASH("Incorrect object in target list `[target[1]]` in playsound_global.")
	else if(target == world)
		clients = global.clients
	else if(isnum(target))
		clients = list()
		for(var/client/client as anything in global.clients)
			var/turf/T = get_turf(client?.mob)
			if(T?.z == target)
				clients += client
	else if(isarea(target))
		clients = list()
		for(var/mob/M in target)
			if(M.client)
				clients += M.client
	else
		CRASH("Incorrect argument `[target]` in playsound_global.")

	var/source = null
	if(isatom(target))
		source = target
	var/sound/S
	var/ourvolume
	var/storedVolume

	for(var/client/C as anything in clients)
		if (!C)
			continue

		if (CLIENT_IGNORES_SOUND(C))
			continue

		ourvolume = vol

		storedVolume = ourvolume
		ourvolume *= C.getVolume(channel) / 100

		EARLY_CONTINUE_IF_QUIET(ourvolume)

		if (!S) S = generate_sound(source, soundin, vol, vary, extrarange=0, pitch=pitch)
		if (!S) CRASH("Did not manage to generate sound \"[soundin]\" with source [source]. Likely that the filename is misnamed or does not exist.")
		C.sound_playing[ S.channel ][1] = storedVolume
		C.sound_playing[ S.channel ][2] = channel

		S.volume = ourvolume

		var/orig_freq = S.frequency
		if(C.mob)
			S.frequency *= (HAS_ATOM_PROPERTY(C.mob, PROP_MOB_HEARD_PITCH) ? GET_ATOM_PROPERTY(C.mob, PROP_MOB_HEARD_PITCH) : 1)

		C << S

		S.frequency = orig_freq

/mob/living/silicon/ai/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
	..()
	if (deployed_to_eyecam && src.eyecam)
		src.eyecam.playsound_local(source, soundin, vol, vary, extrarange, pitch, ignore_flag, channel)
	return


//handles a wide variety of inputs and spits out a valid sound object
/proc/getSound(thing)
	var/sound/S
	if (istype(thing, /sound))
		S = thing
	else
		//we got a dumb text path
		if (istext(thing))
			//first we check the rsc cache list thing and use that if available
			//if not, we load the file from disk if it's there
			//Wire note: this is part of the system to transition a large quantity of sounds to disk-based-only
			var/cachedSound = csound(thing)
			if (cachedSound)
				S = sound(cachedSound)
			else if (fexists(thing))
				S = sound(file(thing))

		//it's a file but not yet a sound, make it so
		else if (isfile(thing))
			S = sound(thing)

	return S

var/global/number_of_sound_generated = 0

/proc/generate_sound(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch = 1)
	if (istext(soundin))
		switch(soundin)
			if ("shatter") soundin = pick(sounds_shatter)
			if ("explosion") soundin = pick(sounds_explosion)
			if ("sparks") soundin = pick(sounds_sparks)
			if ("rustle") soundin = pick(sounds_rustle)
			if ("punch") soundin = pick(sounds_punch)
			if ("clownstep") soundin = pick(sounds_clown)
			if ("footstep") soundin = pick(sounds_footstep)
			if ("cluwnestep") soundin = pick(sounds_cluwne)
			if ("gabe") soundin = pick(sounds_gabe)
			if ("swing_hit") soundin = pick(sounds_hit)
			if ("warp") soundin = pick(sounds_warp)
			if ("keyboard") soundin = pick(sounds_keyboard)
			if ("step_barefoot") soundin = pick(sounds_step_barefoot)
			if ("step_carpet") soundin = pick(sounds_step_carpet)
			if ("step_default") soundin = pick(sounds_step_default)
			if ("step_lattice") soundin = pick(sounds_step_lattice)
			if ("step_outdoors") soundin = pick(sounds_step_outdoors)
			if ("step_plating") soundin = pick(sounds_step_plating)
			if ("step_wood") soundin = pick(sounds_step_wood)
			if ("step_rubberboot") soundin = pick(sounds_step_rubberboot)
			if ("step_robo") soundin = pick(sounds_step_robo)
			if ("step_flipflop") soundin = pick(sounds_step_flipflop)
			if ("step_heavyboots") soundin = pick(sounds_step_heavyboots)
			if ("step_military") soundin = pick(sounds_step_military)

	if(islist(soundin))
		soundin = pick(soundin)

	var/sound/S = getSound(soundin)

	//yeah that sound outright doesn't exist
	if (!S)
		logTheThing(LOG_DEBUG, null, "<b>Sounds:</b> Unable to find sound: [soundin]")
		return

	S.falloff = 9999//(world.view + extrarange) / 3.5
	//world.log << "Playing sound; wv = [world.view] + er = [extrarange] / 3.5 = falloff [S.falloff]"
	S.wait = 0 //No queue
	S.channel = (number_of_sound_generated++) % 900 + 1
	S.volume = vol
	S.priority = 5
	S.environment = 0

	var/area/sound_area = get_area(source)
	if (istype(sound_area))
		S.environment = sound_area.sound_environment

	if (vary)
		S.frequency = rand(725, 1250) / 1000 * pitch
	else
		S.frequency = pitch

	if(narrator_mode)
		S = narrator_mode_sound(S)

	return S


proc/narrator_mode_sound(sound/S)
	var/sound/output_sound = null
	var/new_sound_file = narrator_mode_sound_file(S.file)
	if(istext(new_sound_file))
		if(!fexists(new_sound_file))
			CRASH("Narrator mode sound file '[new_sound_file]' does not exist!")
		output_sound = sound(file(new_sound_file))
	else if(isfile(new_sound_file))
		output_sound = sound(new_sound_file)
	if(isnull(output_sound))
		return S

	// for reasons unknown to me just setting S.file and returning S does not work correctly
	output_sound.falloff = S.falloff
	output_sound.wait = S.wait
	output_sound.channel = S.channel
	output_sound.volume = S.volume
	output_sound.priority = S.priority
	output_sound.environment = S.environment
	output_sound.frequency = S.frequency
	output_sound.pan = S.pan
	output_sound.echo = S.echo
	output_sound.x = S.x
	output_sound.y = S.y
	output_sound.z = S.z
	if(new_sound_file in list("sound/vox/door.ogg", "sound/vox/deny.ogg"))
		output_sound.falloff = 4 // doors be too damn annoying and loud
	return output_sound

proc/narrator_mode_sound_file(sound_file)
	var/static/list/narrator_mode_translation = list(
		'sound/impact_sounds/Generic_Hit_1.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Hit_2.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Hit_3.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Punch_1.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Punch_2.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Punch_3.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Punch_4.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Punch_5.ogg' = "sound/vox/hit.ogg",
		'sound/impact_sounds/Generic_Stab_1.ogg' = "sound/vox/hit.ogg",
		'sound/voice/virtual_scream.ogg' = "sound/vox/scream.ogg",
		'sound/voice/virtual_gassy.ogg' = "sound/vox/fart.ogg",
		'sound/voice/virtual_snap.ogg' = "sound/vox/snap.ogg",
		'sound/effects/fingersnap.ogg' = "sound/vox/snap.ogg",
		'sound/impact_sounds/Generic_Snap_1.ogg' = "sound/vox/snap.ogg",
		'sound/voice/burp.ogg' = "sound/vox/burpone.ogg",
		'sound/machines/whistlealert.ogg' = "sound/vox/deeoo.ogg",
		'sound/machines/whistlebeep.ogg' = "sound/vox/dadeda.ogg",
		'sound/musical_instruments/Bikehorn_1.ogg' = "sound/vox/honk.ogg",
		'sound/musical_instruments/Bikehorn_2.ogg' = "sound/vox/honk.ogg",
		'sound/musical_instruments/Bikehorn_bonk1.ogg' = "sound/vox/honk.ogg",
		'sound/musical_instruments/Bikehorn_bonk2.ogg' = "sound/vox/honk.ogg",
		'sound/musical_instruments/Bikehorn_bonk3.ogg' = "sound/vox/honk.ogg",
		'sound/items/rubberduck.ogg' = "sound/vox/duck.ogg",
		'sound/machines/windowdoor.ogg' = "sound/vox/door.ogg",
		'sound/machines/airlock_swoosh_temp.ogg' = "sound/vox/door.ogg",
		'sound/machines/airlock.ogg' = "sound/vox/door.ogg",
		'sound/machines/door_open.ogg' = "sound/vox/door.ogg",
		'sound/machines/door_close.ogg' = "sound/vox/door.ogg",
		'sound/impact_sounds/Glass_Shatter_1.ogg' = "sound/vox/break.ogg",
		'sound/impact_sounds/Glass_Shatter_2.ogg' = "sound/vox/break.ogg",
		'sound/impact_sounds/Glass_Shatter_3.ogg' = "sound/vox/break.ogg",
		'sound/machines/tractor_running2.ogg' = "sound/vox/engine.ogg",
		'sound/machines/tractor_running3.ogg' = "sound/vox/engine.ogg",
		'sound/misc/clownstep1.ogg' = "sound/vox/clown.ogg",
		'sound/misc/clownstep2.ogg' = "sound/vox/clown.ogg",
		'sound/impact_sounds/Bush_Hit.ogg' = "sound/vox/shake.ogg",
		'sound/misc/lightswitch.ogg' = "sound/vox/switch.ogg",
		'sound/machines/alarm_a.ogg' = "sound/vox/alarm.ogg",
		'sound/machines/firealarm.ogg' = "sound/vox/alarm.ogg",
		'sound/effects/explosionfar.ogg' = "sound/vox/explosion.ogg",
		'sound/effects/ExplosionFirey.ogg' = "sound/vox/explosion.ogg",
		'sound/machines/airlock_deny.ogg' = "sound/vox/deny.ogg",
		'sound/misc/body_thud.ogg' = "sound/vox/lie.ogg",
		'sound/items/Crowbar.ogg' = "sound/vox/crow.ogg",
		'sound/machines/airlock_pry.ogg' = "sound/vox/crow.ogg",
		'sound/machines/airlock_deny_temp.ogg' = "sound/vox/deny.ogg",
	)
	if(sound_file in narrator_mode_translation)
		return narrator_mode_translation[sound_file]

	var/filetext = "[sound_file]"
	if(startswith(filetext, "sound/misc/step") || startswith(filetext, "sound/misc/talk"))
		return null
	if(startswith(filetext, "sound/voice/screams"))
		return "sound/vox/scream.ogg"
	if(startswith(filetext, "sound/voice/farts"))
		return "sound/vox/fart.ogg"

	var/list/path_parts = splittext(filetext, "/")
	var/filename = path_parts[length(path_parts)]
	var/without_extension = splittext(filename, ".")[1]
	var/list/underscore_parts = splittext(replacetext(without_extension, "-", "_"), "_")
	for(var/part in underscore_parts)
		var/normalized = ckey(part)
		var/without_numbers = regex(@"[0-9]", "g").Replace(normalized, "")
		var/datum/VOXsound/voxsound = global.voxsounds[without_numbers]
		if(istype(voxsound))
			return voxsound.ogg

	return null


/**
	* Client part of the Area Ambience Project
 	*
 	* Calling this proc is handled by the Area our client is in, see [area/proc/Exited()] and [area/proc/Entered()]
 	*
 	* LOOPING channel sound will keep playing until fed a pass_volume of 0 (done automagically)
 	* For FX sounds, they will play once.
 	*
 	* FX_1 is area-specific background noise handled by area/pickAmbience(), FX_2 is more noticeable stuff directly triggered, normally shorter
 	*/
/client/proc/playAmbience(area/A, type = AMBIENCE_LOOPING, pass_volume)

	/// Types of sounds: AMBIENCE_LOOPING, AMBIENCE_FX_1, and AMBIENCE_FX_2
	var/soundtype = null

	/// Holds the associated sound channel we want
	var/soundchannel = 0

	/// Determines if we are repeating or not
	var/soundrepeat = 0

	/// Should the sound set the wait var?
	var/soundwait = 0

	switch(type)
		if (AMBIENCE_LOOPING)
			if (pass_volume != 0) //lets us cancel loop sounds by passing 0
				if (src.last_soundgroup && (src.last_soundgroup == A.sound_group))
					return //Don't need to change loopAMB if we're in the same sound group
				soundtype = A.sound_loop
			soundchannel = SOUNDCHANNEL_LOOPING
			soundrepeat = 1
		if (AMBIENCE_FX_1)
			soundtype = A.sound_fx_1
			soundchannel = SOUNDCHANNEL_FX_1
			soundwait = 1
		if (AMBIENCE_FX_2)
			soundtype = A.sound_fx_2
			soundchannel = SOUNDCHANNEL_FX_2

	var/sound/S = sound(soundtype, repeat = soundrepeat, wait = soundwait, volume = pass_volume, channel = soundchannel)
	S.priority = 200
	sound_playing[ S.channel ][1] = S.volume
	sound_playing[ S.channel ][2] = VOLUME_CHANNEL_AMBIENT
	S.volume *= getVolume( VOLUME_CHANNEL_AMBIENT ) / 100
	S.status = SOUND_STREAM // playing one at a time
	if (pass_volume != 0)
		S.volume *= attenuate_for_location(A)
		EARLY_RETURN_IF_QUIET(S.volume)
	src << S

	switch (type) //After play actions, let the area know
		if (AMBIENCE_FX_1)
			A.played_fx_1 = 1
			SPAWN(40 SECONDS) //40s
				A.played_fx_1 = 0
		if (AMBIENCE_FX_2)
			A.played_fx_2 = 1
			SPAWN(20 SECONDS) //20s
				A.played_fx_2 = 0


/// pool of precached sounds
/var/global/list/sb_tricks = list(sound('sound/effects/sbtrick1.ogg'),sound('sound/effects/sbtrick2.ogg'),sound('sound/effects/sbtrick3.ogg'),sound('sound/effects/sbtrick4.ogg'),sound('sound/effects/sbtrick5.ogg'),sound('sound/effects/sbtrick6.ogg'),sound('sound/effects/sbtrick7.ogg'),sound('sound/effects/sbtrick8.ogg'),sound('sound/effects/sbtrick9.ogg'),sound('sound/effects/sbtrick10.ogg'))
/var/global/list/sb_fails = list(sound('sound/effects/sbfail1.ogg'),sound('sound/effects/sbfail2.ogg'),sound('sound/effects/sbfail3.ogg'))

/var/global/list/big_explosions = list(sound('sound/effects/Explosion1.ogg'),sound('sound/effects/Explosion2.ogg'),sound('sound/effects/explosion_new1.ogg'),sound('sound/effects/explosion_new2.ogg'),sound('sound/effects/explosion_new3.ogg'),sound('sound/effects/explosion_new4.ogg'))

/var/global/list/sounds_shatter = list(sound('sound/impact_sounds/Glass_Shatter_1.ogg'),sound('sound/impact_sounds/Glass_Shatter_2.ogg'),sound('sound/impact_sounds/Glass_Shatter_3.ogg'))
/var/global/list/sounds_explosion = list(sound('sound/effects/Explosion1.ogg'),sound('sound/effects/Explosion2.ogg'))
/var/global/list/sounds_sparks = list(sound('sound/effects/sparks1.ogg'),sound('sound/effects/sparks2.ogg'),sound('sound/effects/sparks3.ogg'),sound('sound/effects/sparks4.ogg'),sound('sound/effects/sparks5.ogg'),sound('sound/effects/sparks6.ogg'))
/var/global/list/sounds_rustle = list(sound('sound/misc/rustle1.ogg'),sound('sound/misc/rustle2.ogg'),sound('sound/misc/rustle3.ogg'),sound('sound/misc/rustle4.ogg'),sound('sound/misc/rustle5.ogg'))
/var/global/list/sounds_punch = list(sound('sound/impact_sounds/Generic_Punch_2.ogg'),sound('sound/impact_sounds/Generic_Punch_3.ogg'),sound('sound/impact_sounds/Generic_Punch_4.ogg'),sound('sound/impact_sounds/Generic_Punch_5.ogg'))
/var/global/list/sounds_clown = list(sound('sound/misc/clownstep1.ogg'),sound('sound/misc/clownstep2.ogg'))
/var/global/list/sounds_footstep = list(sound('sound/misc/footstep1.ogg'),sound('sound/misc/footstep2.ogg'))
/var/global/list/sounds_cluwne = list(sound('sound/misc/cluwnestep1.ogg'),sound('sound/misc/cluwnestep2.ogg'),sound('sound/misc/cluwnestep3.ogg'),sound('sound/misc/cluwnestep4.ogg'))
/var/global/list/sounds_gabe = list(sound('sound/voice/animal/gabe1.ogg'),sound('sound/voice/animal/gabe2.ogg'),sound('sound/voice/animal/gabe3.ogg'),sound('sound/voice/animal/gabe4.ogg'),sound('sound/voice/animal/gabe5.ogg'),sound('sound/voice/animal/gabe6.ogg'),sound('sound/voice/animal/gabe7.ogg'),sound('sound/voice/animal/gabe8.ogg'),sound('sound/voice/animal/gabe9.ogg'),sound('sound/voice/animal/gabe10.ogg'),sound('sound/voice/animal/gabe11.ogg'))
/var/global/list/sounds_hit = list(sound('sound/impact_sounds/Generic_Hit_1.ogg'),sound('sound/impact_sounds/Generic_Hit_2.ogg'),sound('sound/impact_sounds/Generic_Hit_3.ogg'))
/var/global/list/sounds_warp = list(sound('sound/effects/warp1.ogg'),sound('sound/effects/warp2.ogg'))
/var/global/list/sounds_engine = list(sound('sound/machines/tractor_running2.ogg'),sound('sound/machines/tractor_running3.ogg'))
/var/global/list/sounds_keyboard = list(sound('sound/machines/keyboard1.ogg'),sound('sound/machines/keyboard2.ogg'),sound('sound/machines/keyboard3.ogg'))

/var/global/list/sounds_enginegrump = list(sound('sound/machines/engine_grump1.ogg'),sound('sound/machines/engine_grump2.ogg'),sound('sound/machines/engine_grump3.ogg'),sound('sound/machines/engine_grump4.ogg'))

/var/global/list/ambience_general = list(sound('sound/ambience/station/Station_VocalNoise1.ogg'),
			sound('sound/ambience/station/Station_VocalNoise2.ogg'),
			sound('sound/ambience/station/Station_VocalNoise3.ogg'),
			sound('sound/ambience/station/Station_VocalNoise4.ogg'),
			sound('sound/ambience/station/Station_MechanicalThrum1.ogg'),
			sound('sound/ambience/station/Station_MechanicalThrum2.ogg'),
			sound('sound/ambience/station/Station_MechanicalThrum3.ogg'),
			sound('sound/ambience/station/Station_MechanicalThrum4.ogg'),
			sound('sound/ambience/station/Station_MechanicalThrum5.ogg'),
			sound('sound/ambience/station/Station_MechanicalThrum6.ogg'),
			sound('sound/ambience/station/Station_StructuralCreaking.ogg'),
			sound('sound/ambience/station/Station_MechanicalHissing.ogg'))

/var/global/list/ambience_submarine = list(sound('sound/ambience/station/underwater/sub_ambi.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi1.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi2.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi3.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi4.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi5.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi6.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi7.ogg'),
		sound('sound/ambience/station/underwater/sub_ambi8.ogg'))

/var/global/list/ambience_power = list(sound('sound/ambience/station/Machinery_PowerStation1.ogg'),sound('sound/ambience/station/Machinery_PowerStation2.ogg'))
/var/global/list/ambience_computer = list(sound('sound/ambience/station/Machinery_Computers1.ogg'),sound('sound/ambience/station/Machinery_Computers2.ogg'),sound('sound/ambience/station/Machinery_Computers3.ogg'))
/var/global/list/ambience_atmospherics = list(sound('sound/ambience/loop/Wind_Low.ogg'))
/var/global/list/ambience_engine = list(sound('sound/ambience/loop/Wind_Low.ogg'))

/var/global/list/ghostly_sounds = list('sound/effects/ghostambi1.ogg', 'sound/effects/ghostambi2.ogg', 'sound/effects/ghostbreath.ogg', 'sound/effects/ghostlaugh.ogg', 'sound/effects/ghostvoice.ogg')

//stepsounds
/var/global/list/sounds_step_barefoot = list(sound('sound/misc/step/step_barefoot_1.ogg'),sound('sound/misc/step/step_barefoot_2.ogg'),sound('sound/misc/step/step_barefoot_3.ogg'),sound('sound/misc/step/step_barefoot_4.ogg'))
/var/global/list/sounds_step_carpet = 	list(sound('sound/misc/step/step_carpet_1.ogg'),sound('sound/misc/step/step_carpet_2.ogg'),sound('sound/misc/step/step_carpet_3.ogg'),sound('sound/misc/step/step_carpet_4.ogg'),sound('sound/misc/step/step_carpet_5.ogg'))
/var/global/list/sounds_step_default = 	list(sound('sound/misc/step/step_default_1.ogg'),sound('sound/misc/step/step_default_2.ogg'),sound('sound/misc/step/step_default_3.ogg'),sound('sound/misc/step/step_default_4.ogg'),sound('sound/misc/step/step_default_5.ogg'))
/var/global/list/sounds_step_lattice = 	list(sound('sound/misc/step/step_lattice_1.ogg'),sound('sound/misc/step/step_lattice_2.ogg'),sound('sound/misc/step/step_lattice_3.ogg'),sound('sound/misc/step/step_lattice_4.ogg'))
/var/global/list/sounds_step_outdoors = list(sound('sound/misc/step/step_outdoors_1.ogg'),sound('sound/misc/step/step_outdoors_2.ogg'),sound('sound/misc/step/step_outdoors_3.ogg'))
/var/global/list/sounds_step_plating = 	list(sound('sound/misc/step/step_plating_1.ogg'),sound('sound/misc/step/step_plating_2.ogg'),sound('sound/misc/step/step_plating_3.ogg'),sound('sound/misc/step/step_plating_4.ogg'),sound('sound/misc/step/step_plating_5.ogg'))
/var/global/list/sounds_step_wood = 	list(sound('sound/misc/step/step_wood_1.ogg'),sound('sound/misc/step/step_wood_2.ogg'),sound('sound/misc/step/step_wood_3.ogg'),sound('sound/misc/step/step_wood_4.ogg'),sound('sound/misc/step/step_wood_5.ogg'))
/var/global/list/sounds_step_rubberboot = 	list(sound('sound/misc/step/step_rubberboot_1.ogg'),sound('sound/misc/step/step_rubberboot_2.ogg'),sound('sound/misc/step/step_rubberboot_3.ogg'),sound('sound/misc/step/step_rubberboot_4.ogg'))
/var/global/list/sounds_step_robo = 		list(sound('sound/misc/step/step_robo_1.ogg'),sound('sound/misc/step/step_robo_2.ogg'),sound('sound/misc/step/step_robo_3.ogg'))
/var/global/list/sounds_step_flipflop = 	list(sound('sound/misc/step/step_flipflop_1.ogg'),sound('sound/misc/step/step_flipflop_2.ogg'),sound('sound/misc/step/step_flipflop_3.ogg'))
/var/global/list/sounds_step_heavyboots = 	list(sound('sound/misc/step/step_heavyboots_1.ogg'),sound('sound/misc/step/step_heavyboots_2.ogg'),sound('sound/misc/step/step_heavyboots_3.ogg'))
/var/global/list/sounds_step_military = 	list(sound('sound/misc/step/step_military_1.ogg'),sound('sound/misc/step/step_military_2.ogg'),sound('sound/misc/step/step_military_3.ogg'),sound('sound/misc/step/step_military_4.ogg'))




//talksounds
/var/global/list/sounds_speak = list(	\
		"1" = sound('sound/misc/talk/speak_1.ogg'),	"1!" = sound('sound/misc/talk/speak_1_exclaim.ogg'),"1?" = sound('sound/misc/talk/speak_1_ask.ogg'),\
		"2" = sound('sound/misc/talk/speak_2.ogg'),	"2!" = sound('sound/misc/talk/speak_2_exclaim.ogg'),"2?" = sound('sound/misc/talk/speak_2_ask.ogg'),\
 		"3" = sound('sound/misc/talk/speak_3.ogg'),	"3!" = sound('sound/misc/talk/speak_3_exclaim.ogg'),"3?" = sound('sound/misc/talk/speak_3_ask.ogg'), \
 		"4" = sound('sound/misc/talk/speak_4.ogg'),	"4!" = sound('sound/misc/talk/speak_4_exclaim.ogg'),	"4?" = sound('sound/misc/talk/speak_4_ask.ogg'), \
 		"bloop" = sound('sound/misc/talk/buwoo.ogg'),	"bloop!" = sound('sound/misc/talk/buwoo_exclaim.ogg'),	"bloop?" = sound('sound/misc/talk/buwoo_ask.ogg'), \
 		"lizard" = sound('sound/misc/talk/lizard.ogg'),	"lizard!" = sound('sound/misc/talk/lizard_exclaim.ogg'),"lizard?" = sound('sound/misc/talk/lizard_ask.ogg'), \
 		"skelly" = sound('sound/misc/talk/skelly.ogg'),	"skelly!" = sound('sound/misc/talk/skelly_exclaim.ogg'),"skelly?" = sound('sound/misc/talk/skelly_ask.ogg'), \
		"blub" = sound('sound/misc/talk/blub.ogg'),	"blub!" = sound('sound/misc/talk/blub_exclaim.ogg'),"blub?" = sound('sound/misc/talk/blub_ask.ogg'), \
		"cow" = sound('sound/misc/talk/cow.ogg'),	"cow!" = sound('sound/misc/talk/cow_exclaim.ogg'),"cow?" = sound('sound/misc/talk/cow_ask.ogg'), \
		"pug" = sound('sound/misc/talk/pug.ogg'),	"pug!" = sound('sound/misc/talk/pug_exclaim.ogg'),"pug?" = sound('sound/misc/talk/pug_ask.ogg'), \
		"pugg" = sound('sound/misc/talk/pugg.ogg'),	"pugg!" = sound('sound/misc/talk/pugg_exclaim.ogg'),"pugg?" = sound('sound/misc/talk/pugg_ask.ogg'), \
		"roach" = sound('sound/misc/talk/roach.ogg'),	"roach!" = sound('sound/misc/talk/roach_exclaim.ogg'),"roach?" = sound('sound/misc/talk/roach_ask.ogg'), \
		"cyborg" = sound('sound/misc/talk/cyborg.ogg'),	"cyborg!" = sound('sound/misc/talk/cyborg_exclaim.ogg'),"cyborg?" = sound('sound/misc/talk/cyborg_ask.ogg'), \
 		"radio" = sound('sound/misc/talk/radio.ogg')\
 		)


/**
 * Soundcache
 * NEVER use these sounds for modifying.
 * This should only be used for sounds that are played unaltered to the user.
 * @param text name the name of the sound that will be returned
 * @return sound
 */
/proc/csound(var/name)
	return soundCache[name]

#undef SOUNDIN_ID
