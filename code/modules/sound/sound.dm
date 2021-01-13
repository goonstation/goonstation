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
} while(false)

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
} while(false)

#define MAX_SOUND_RANGE 33
#define MAX_SPACED_RANGE 6 //diff range for when youre in a vaccuum
#define CLIENT_IGNORES_SOUND(C) (C?.ignore_sound_flags && ((ignore_flag && C.ignore_sound_flags & ignore_flag) || C.ignore_sound_flags & SOUND_ALL))

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
		if (T.turf_flags & IS_TYPE_SIMULATED) //danger :)
			var/turf/simulated/sim_T = T
			if (sim_T.air)
				attenuate *= MIXTURE_PRESSURE(sim_T.air) / ONE_ATMOSPHERE
				attenuate = min(1, max(0, attenuate))

	return attenuate

var/global/SPACED_ENV = list(100,0.52,0,-1600,-1500,0,2,2,-10000,0,200,0.01,0.165,0,0.25,0.01,-5,1000,20,10,53,100,0x3f)
var/global/SPACED_ECHO = list(-10000,0,-1450,0,0,1,0,1,10,10,0,1,0,10,10,10,10,7)
var/global/ECHO_AFAR = list(0,0,0,0,0,0,-10000,1.0,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
var/global/ECHO_CLOSE = list(0,0,0,0,0,0,0,0.25,1.5,1.0,0,1.0,0,0,0,0,1.0,7)
var/global/list/falloff_cache = list()

//default volumes
var/global/list/default_channel_volumes = list(1, 1, 0.1, 0.5, 0.5, 1)

//volumous hair with l'orial paris
/client/var/list/volumes
/client/var/list/sound_playing = new/list(1024, 2)

/// Returns a list of friendly names for available sound channels
/client/proc/getVolumeNames()
	return list("Game", "Ambient", "Radio", "Admin", "Emote")

/// Returns the default volume for a channel, unattenuated for the master channel (0-1)
/client/proc/getDefaultVolume(channel)
	return volumes[channel + 1]

/// Returns a list of friendly descriptions for available sound channels
/client/proc/getVolumeDescriptions()
	return list("Most in-game audio will use this channel.", "Ambient background music in various areas will use this channel.", "Any music played from the radio station", "Any music or sounds played by admins.", "Screams and farts.")

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
	volume = clamp(volume, 0, 1)
	volumes[channel + 1] = volume

	cloud_put("audio_volume", json_encode(volumes))

	var/list/playing = src.SoundQuery()
	if( channel == VOLUME_CHANNEL_MASTER )
		for( var/sound/s in playing )
			s.status |= SOUND_UPDATE
			var/list/vol = sound_playing[ s.channel ]
			s.volume = vol[1] * volume * volumes[ vol[2] ] * 100
			src << s
		src.chatOutput.adjustVolumeRaw( volume * getRealVolume(VOLUME_CHANNEL_ADMIN) )
	else
		for( var/sound/s in playing )
			if( sound_playing[s.channel][2] == channel )
				s.status |= SOUND_UPDATE
				s.volume = sound_playing[s.channel][1] * volume * volumes[1] * 100
				src << s

	if( channel == VOLUME_CHANNEL_ADMIN )
		src.chatOutput.adjustVolumeRaw( getMasterVolume() * volume )

/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME)
	// don't play if over the per-tick sound limit
	if (!limiter || !limiter.canISpawn(/sound))
		return

	// don't play if the sound is happening nowhere
	if (!source || !source.loc || source.z <= 0)
		return

	EARLY_RETURN_IF_QUIET(vol)

	var/area/source_location = get_area(source)
	var/source_location_sound_group = null
	if (source_location)
		source_location_sound_group = source_location.sound_group

	var/spaced_source = 0
	var/spaced_env = 0
	var/atten_temp = attenuate_for_location(source)
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

	for (var/mob/M in GET_NEARBY(source,MAX_SOUND_RANGE + extrarange))
		var/client/C = M.client
		if (!C)
			continue

		if (CLIENT_IGNORES_SOUND(C))
			continue

		Mloc = get_turf(M)

		if (!Mloc)
			continue

		//Hard attentuation
		dist = max(GET_MANHATTAN_DIST(Mloc, source), 1)
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
			if (!S) CRASH("Did not manage to generate sound \"[soundin]\" with source [source].")
			C.sound_playing[ S.channel ][1] = storedVolume
			C.sound_playing[ S.channel ][2] = channel

			S.volume = ourvolume

			if (spaced_env)
				S.environment = SPACED_ENV
				S.echo = SPACED_ECHO
			else
				if(listener_location != source_location)
					//boutput(M, "You barely hear a [source] at [source_location]!")
					S.echo = ECHO_AFAR //Sound is occluded
				else
					//boutput(M, "You hear a [source] at [source_location]!")
					S.echo = ECHO_CLOSE

			S.x = source.x - Mloc.x
			S.z = source.y - Mloc.y //Since sound coordinates are 3D, z for sound falls on y for the map.  BYOND.
			S.y = 0

			C << S


/mob/proc/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME)
	if(!src.client)
		return

	// don't play if over the per-tick sound limit
	if (!limiter || !limiter.canISpawn(/sound))
		return

	// don't play if the sound is happening nowhere
	if (!source || !source.loc)
		return

	var/dist = max(GET_MANHATTAN_DIST(get_turf(src), get_turf(source)), 1)
	if (dist > MAX_SOUND_RANGE + extrarange)
		return

	if (CLIENT_IGNORES_SOUND(src.client))
		return

	vol *= client.getVolume(channel) / 100

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
	client.sound_playing[ S.channel ][1] = ourvolume
	client.sound_playing[ S.channel ][2] = channel

	if (S)
		if (spaced_env)
			S.environment = SPACED_ENV
			S.echo = SPACED_ECHO

		var/turf/source_turf = get_turf(source)
		if (istype(source_turf))
			var/dx = source_turf.x - src.x
			S.pan = max(-100, min(100, dx/8.0 * 100))

		src << S

		if (src.observers.len)
			for (var/mob/M in src.observers)
				if (CLIENT_IGNORES_SOUND(M.client))
					continue
					M.client.sound_playing[ S.channel ][1] = ourvolume
					M.client.sound_playing[ S.channel ][2] = channel

					M << S



/mob/living/silicon/ai/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch = 1, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME)
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

/proc/generate_sound(var/atom/source, soundin, vol as num, vary, extrarange as num, pitch = 1)
	if (narrator_mode && (soundin in list("punch", "swing_hit", "shatter", "explosion")))
		switch(soundin)
			if ("shatter") soundin = 'sound/vox/break.ogg'
			if ("explosion") soundin = list('sound/vox/explosion.ogg', 'sound/vox/explode.ogg')
			if ("swing_hit") soundin = 'sound/vox/hit.ogg'
			if ("punch") soundin = 'sound/vox/hit.ogg'
	else
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
		logTheThing("debug", null, null, "<b>Sounds:</b> Unable to find sound: [soundin]")
		return

	S.falloff = 9999//(world.view + extrarange) / 3.5
	//world.log << "Playing sound; wv = [world.view] + er = [extrarange] / 3.5 = falloff [S.falloff]"
	S.wait = 0 //No queue
	S.channel = rand(1,900) //Any channel
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

	return S


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
	if (pass_volume != 0)
		S.volume *= attenuate_for_location(A)
		EARLY_RETURN_IF_QUIET(S.volume)
	src << S

	switch (type) //After play actions, let the area know
		if (AMBIENCE_FX_1)
			A.played_fx_1 = 1
			SPAWN_DBG(40 SECONDS) //40s
				A.played_fx_1 = 0
		if (AMBIENCE_FX_2)
			A.played_fx_2 = 1
			SPAWN_DBG(20 SECONDS) //20s
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

sound
	disposing()
		//LAGCHECK(LAG_LOW)
		..()
/*
sound
	disposing()
		// Haha you cant delete me you fuck
		if(!qdeled)
			pool(src)
		else
			//Yes I can
			..()
		return

	unpooled()
		file = initial(file)
		repeat = initial(repeat)
		wait = initial(wait)
		channel = initial(channel)
		volume = initial(volume)
		frequency = initial(frequency)
		pan = initial(pan)
		priority = initial(priority)
		status = initial(status)
		x = initial(x)
		y = initial(y)
		z = initial(z)
		falloff = initial(falloff)
		environment = initial(environment)
		echo = initial(echo)
*/
