//at long last, there is someone to hear
/datum/random_event/menhir/song
	name = "They Sing, They Sing"
	description = "The chorus that dwells in the Crown sings to the world around it, akin to a radio broadcast."
	message_delay = 1 MINUTE
	weight = 70
	var/list/songs = list("song_attuned",
		"song_interfacing",
		"song_kindled",
		"song_rapport",
		"song_serenade")

	is_event_available(ignore_time_lock)
		. = ..()
		if(.)
			if (is_music_playing()) //a song already occupies the air
				. = FALSE
			if (length(src.songs) < 2) //we've sung enough, for the moment
				. = FALSE

	event_effect()
		var/sound_name = pick(src.songs)
		src.songs -= sound_name
		var/sound_path = "sound/misc/menhir/[sound_name].ogg"
		var/sound/music_sound = getSound(sound_path)
		music_sound.wait = 0
		music_sound.repeat = 0
		music_sound.priority = 254
		music_sound.channel = 1013
		music_sound.environment = -1
		music_sound.echo = -1
		SPAWN(0)
			for (var/client/C in clients)
				LAGCHECK(LAG_LOW)
				C.verbs += /client/verb/stop_the_radio
				var/client_vol = C.getVolume(VOLUME_CHANNEL_RADIO)

				if (!client_vol)
					continue

				C.sound_playing[ music_sound.channel ][1] = 100
				C.sound_playing[ music_sound.channel ][2] = VOLUME_CHANNEL_RADIO

				music_sound.volume = client_vol
				C << music_sound
				boutput(C, "Now playing radio tunes...? <a href='byond://winset?command=Stop-the-Radio!'>Stop music</a>")
				//DEBUG_MESSAGE("Playing sound for [C] on channel [music_sound.channel] with volume [client_vol]")

		message_delay = rand(6 SECONDS, 9 SECONDS)
		..()

		logTheThing(LOG_STATION, null, "Menhir event [src.name] triggered, playing [sound_name].")
		message_admins("Menhir event [src.name] triggered, playing [sound_name].")
		EXTEND_COOLDOWN(global, "music", max(2 MINUTES, music_sound.len))

