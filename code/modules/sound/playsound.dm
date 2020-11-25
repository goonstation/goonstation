var/global/admin_sound_channel = 1014 //Ranges from 1014 to 1024

/client/proc/play_sound_real(S as sound, var/vol as num, var/freq as num)
	if (!config.allow_admin_sounds)
		alert("Admin sounds disabled")
		return

	var/admin_key = admin_key(src)
	vol = max(min(vol, 100), 0)

	var/sound/uploaded_sound = new()
	uploaded_sound.file = S
	uploaded_sound.wait = 0
	uploaded_sound.volume = vol
	uploaded_sound.repeat = 0
	uploaded_sound.priority = 254
	uploaded_sound.channel = admin_sound_channel
	uploaded_sound.frequency = freq
	uploaded_sound.environment = -1
	uploaded_sound.echo = -1
	if (!vol)
		return

	logTheThing("admin", src, null, "played sound [S]")
	logTheThing("diary", src, null, "played sound [S]", "admin")
	message_admins("[key_name(src)] played sound [S]")
	SPAWN_DBG(0)
		for (var/client/C in clients)
			C.sound_playing[ admin_sound_channel ][1] = vol
			C.sound_playing[ admin_sound_channel ][2] = VOLUME_CHANNEL_ADMIN
			uploaded_sound.volume = vol * C.getVolume( VOLUME_CHANNEL_ADMIN ) / 100
			C << uploaded_sound

			//DEBUG_MESSAGE("Playing sound for [C] on channel [uploaded_sound.channel]")
			if (src.djmode || src.non_admin_dj)
				boutput(C, "<span class=\"medal\"><b>[admin_key] played:</b></span> <span class='notice'>[S]</span>")
		dj_panel.move_admin_sound_channel()

/client/proc/play_music_real(S as sound, var/freq as num)
	if (!config.allow_admin_sounds)
		alert("Admin sounds disabled")
		return 0

	var/sound/music_sound = new()
	music_sound.file = S
	music_sound.wait = 0
	music_sound.repeat = 0
	music_sound.priority = 254
	music_sound.channel = admin_sound_channel //having this set to 999 removed layering music functionality -ZeWaka
	if(!freq)
		music_sound.frequency = 1
	else
		music_sound.frequency = freq
	music_sound.environment = -1
	music_sound.echo = -1

	SPAWN_DBG(0)
		var/admin_key = admin_key(src)
		for (var/client/C in clients)
			LAGCHECK(LAG_LOW)
			var/client_vol = C.getVolume(VOLUME_CHANNEL_ADMIN)

			if (src.djmode || src.non_admin_dj)
				boutput(C, "<span class=\"medal\"><b>[admin_key] played (your volume: [client_vol ? "[client_vol]" : "muted"]):</b></span> <span class='notice'>[S]</span>")

			if (!client_vol)
				continue

			C.sound_playing[ admin_sound_channel ][1] = 1
			C.sound_playing[ admin_sound_channel ][2] = VOLUME_CHANNEL_ADMIN

			music_sound.volume = client_vol
			C << music_sound
			boutput(C, "Now playing music. <a href='byond://winset?command=Stop-the-Music!'>Stop music</a>")
			//DEBUG_MESSAGE("Playing sound for [C] on channel [music_sound.channel] with volume [music_sound.volume]")
		dj_panel.move_admin_sound_channel()
	logTheThing("admin", src, null, "started loading music [S]")
	logTheThing("diary", src, null, "started loading music [S]", "admin")
	message_admins("[key_name(src)] started loading music [S]")
	return 1

/client/proc/play_music_radio(soundPath, var/name)
	var/sound/music_sound = getSound(soundPath)
	music_sound.wait = 0
	music_sound.repeat = 0
	music_sound.priority = 254
	music_sound.channel = 1013 // This probably works?
	music_sound.environment = -1
	music_sound.echo = -1
	SPAWN_DBG(0)
		for (var/client/C in clients)
			LAGCHECK(LAG_LOW)
			C.verbs += /client/verb/stop_the_radio
			var/client_vol = C.getVolume(VOLUME_CHANNEL_RADIO)

			if (!client_vol)
				continue

			C.sound_playing[ music_sound.channel ][1] = 1
			C.sound_playing[ music_sound.channel ][2] = VOLUME_CHANNEL_RADIO

			music_sound.volume = client_vol
			C << music_sound
			boutput(C, "Now playing radio tunes. <a href='byond://winset?command=Stop-the-Radio!'>Stop music</a>")
			//DEBUG_MESSAGE("Playing sound for [C] on channel [music_sound.channel] with volume [client_vol]")

	logTheThing("admin", src, null, "started loading music [soundPath], by the name of: [name]")
	logTheThing("diary", src, null, "started loading music [soundPath], by the name of: [name]", "admin")
	message_admins("[key_name(src)] started loading music [soundPath], by the name of: [name]")
	return 1

/proc/play_music_remote(data)
	if (!config.allow_admin_sounds)
		alert("Admin sounds disabled")
		return 0

	var/client/adminC
	for (var/client/C in clients)
		if (C.key == data["key"])
			adminC = C

	SPAWN_DBG(0)
		for (var/client/C in clients)
			LAGCHECK(LAG_LOW)
			C.verbs += /client/verb/stop_the_music
			var/vol = C.getVolume(VOLUME_CHANNEL_ADMIN)

			var/ismuted
			if (!vol) ismuted = 1

			if (adminC && (adminC.djmode || adminC.non_admin_dj))
				var/show_other_key = 0
				if (adminC.stealth || adminC.alt_key)
					show_other_key = 1
				boutput(C, "<span class=\"medal\"><b>[show_other_key ? adminC.fakekey : adminC.key] played (your volume: [ ismuted ? "muted" : vol ]):</b></span> <span class='notice'>[data["title"]] ([data["duration"]])</span>")

			if (ismuted) //bullshit BYOND 0 is not null fuck you
				continue

			C.chatOutput.playMusic(data["file"], vol)
			boutput(C, "Now playing music. <a href='byond://winset?command=Stop-the-Music!'>Stop music</a>")


	if (adminC)
		logTheThing("admin", adminC, null, "loaded remote music: [data["file"]] ([data["filesize"]])")
		logTheThing("diary", adminC, null, "loaded remote music: [data["file"]] ([data["filesize"]])", "admin")
		message_admins("[key_name(adminC)] loaded remote music: [data["title"]] ([data["duration"]] / [data["filesize"]])")
	else
		logTheThing("admin", data["key"], null, "loaded remote music: [data["file"]] ([data["filesize"]])")
		logTheThing("diary", data["key"], null, "loaded remote music: [data["file"]] ([data["filesize"]])", "admin")
		message_admins("[key_name(data["key"])] loaded remote music: [data["title"]] ([data["duration"]] / [data["filesize"]])")
	return 1

/mob/verb/adminmusicvolume()
	set name = "Alter Music Volume"
	set desc = "Alter admin music volume, default is 50"
	set hidden = 1

	if (!usr.client) //How could this even happen?
		return

	var/vol = input("Goes from 0-100. Default is 50", "Admin Music Volume", usr.client.getRealVolume(VOLUME_CHANNEL_ADMIN) * 100) as num
	vol = max(0,min(vol,100))
	//usr.client.preferences.admin_music_volume = vol
	usr.client.setVolume( VOLUME_CHANNEL_ADMIN, vol/100 )
	boutput(usr, "<span class='notice'>You have changed Admin Music Volume to [vol].</span>")

/mob/verb/radiomusicvolume()
	set name = "Alter Radio Volume"
	set desc = "Alter radio music volume, default is 50"
	set hidden = 1

	if (!usr.client)
		return

	var/vol = input("Goes from 0-100. Default is 50", "Radio Music Volume", usr.client.getRealVolume(VOLUME_CHANNEL_RADIO) * 100) as num
	vol = max(0,min(vol,100))
	usr.client.setVolume( VOLUME_CHANNEL_RADIO, vol/100 )
	boutput(usr, "<span class='notice'>You have changed Radio Music Volume to [vol].</span>")

/mob/verb/gamevolume()
	set name = "Alter Game Volume"
	set desc = "Alter game volume, default is 100"
	//set hidden = 1

	if (!usr.client)
		return

	var/vol = input("Goes from 0-100. Default is 100", "Game Volume", usr.client.getRealVolume(VOLUME_CHANNEL_GAME) * 100) as num
	vol = max(0,min(vol,100))
	usr.client.setVolume( VOLUME_CHANNEL_GAME, vol/100 )
	boutput(usr, "<span class='notice'>You have changed Game Volume to [vol].</span>")

/mob/verb/ambiencevolume()
	set name = "Alter Ambience Volume"
	set desc = "Alter ambience volume, default is 100"
	//set hidden = 1

	if (!usr.client)
		return

	var/vol = input("Goes from 0-100. Default is 100", "Ambience Volume", usr.client.getRealVolume(VOLUME_CHANNEL_AMBIENT) * 100) as num
	vol = max(0,min(vol,100))
	usr.client.setVolume( VOLUME_CHANNEL_AMBIENT, vol/100 )
	boutput(usr, "<span class='notice'>You have changed Ambience Volume to [vol].</span>")


/mob/verb/mastervolume()
	set name = "Alter Master Volume"
	set desc = "Alter master volume, default is 100"
	//set hidden = 1

	if (!usr.client)
		return

	var/vol = input("Goes from 0-100. Default is 100", "Ambience Volume", usr.client.getMasterVolume() * 100) as num
	vol = max(0,min(vol,100))
	usr.client.setVolume( VOLUME_CHANNEL_MASTER, vol/100 )
	boutput(usr, "<span class='notice'>You have changed Master Volume to [vol].</span>")





// for giving non-admins the ability to play music
/client/proc/non_admin_dj(S as sound)
	set category = "Commands"
	set name = "Play Music"

	if (src.play_music_real(S))
		boutput(src, "<span class='notice'>Loading music [S]...</span>")

/client/verb/stop_the_music()
	set category = "Commands"
	set name = "Stop the Music!"
	set desc = "Is there music playing? Do you hate it? Press this to make it stop!"
	set popup_menu = 0
	set hidden = 1

	ehjax.send(src, "browseroutput", "stopaudio") //For client-side audio

	var/mute_channel = 1014
	var/sound/stopsound = sound(null,wait = 0,channel=mute_channel)
	for (var/i = 1 to 10)
		//DEBUG_MESSAGE("Muting sound channel [stopsound.channel] for [src]")
		stopsound.channel = mute_channel
		src << 	stopsound
		mute_channel ++
	//DEBUG_MESSAGE("Muting sound channel [stopsound.channel] for [src]")

/client/verb/stop_the_radio()
	set category = "Commands"
	set name = "Stop the Radio!"
	set desc = "Is the radio playing shitty songs? Do you hate it? Press this to make it stop!"
	set popup_menu = 0
	set hidden = 1

	ehjax.send(src, "browseroutput", "stopaudio") //For client-side audio

	src.verbs -= /client/verb/stop_the_radio
	var/mute_channel = 1013
	var/sound/stopsound = sound(null,wait = 0,channel=mute_channel)
	//DEBUG_MESSAGE("Muting sound channel [stopsound.channel] for [src]")
	stopsound.channel = mute_channel
	src << 	stopsound
	//DEBUG_MESSAGE("Muting sound channel [stopsound.channel] for [src]")
	SPAWN_DBG(5 SECONDS)
		src.verbs += /client/verb/stop_the_radio

/client/verb/stop_all_sounds()
	set category = "Commands"
	set name = "Stop Sounds"
	set desc = "Is there some weird sound that won't go away? Try this."
	set popup_menu = 0
	set hidden = 1

	src.verbs -= /client/verb/stop_all_sounds
	for(var/sound/s in SoundQuery())
		if (!s.channel) return //fixes a list index out of bounds from the channel stop below - possibly SoundQuery bug
		s.status |= SOUND_UPDATE
		s.volume = 0
		sound_playing[ s.channel ][1] = 0
		src << s

	//DEBUG_MESSAGE("Muting sound channel [stopsound.channel] for [src]")
	SPAWN_DBG(5 SECONDS)
		src.verbs += /client/verb/stop_all_sounds

/client/proc/play_youtube_audio()
	if (!config.youtube_audio_key)
		alert("You don't have access to the youtube audio converter")
		return 0

	var/video = input("Input the Youtube video information\nEither the full URL e.g. https://www.youtube.com/watch?v=145RCdUwAxM\nOr just the video ID e.g. 145RCdUwAxM", "Play Youtube Audio") as null|text
	if (!video)
		return

	// Fetch via HTTP from goonhub
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "http://yt.goonhub.com/index.php?server=[config.server_id]&key=[src.key]&video=[video]&auth=[config.youtube_audio_key]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	var/datum/http_response/response = request.into_response()

	if (response.errored || !response.body)
		boutput(src, "<span class='bold' class='notice'>Something went wrong with the youtube thing! Yell at Wire.</span>")
		logTheThing("debug", null, null, "<b>Youtube Error</b>: No response from server with video: <b>[video]</b>")
		logTheThing("diary", null, null, "Youtube Error: No response from server with video: [video]", "debug")
		return

	var/data = json_decode(response.body)
	if (data["error"])
		boutput(src, "<span class='bold' class='notice'>Error returned from youtube server thing: [data["error"]].</span>")
		return

	boutput(src, "<span class='bold' class='notice'>Youtube audio loading started. This may take some time to play and a second message will be displayed when it finishes.</span>")
