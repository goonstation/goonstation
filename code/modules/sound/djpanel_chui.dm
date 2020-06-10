/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=DJ PANEL BY ZEWAKA-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/*
	Allows for easily accessible music/sound playing for admins/allowed players.
	Uses CHUI Template Variables to store strings/nums.
*/

client/proc/open_dj_panel()
	set name = "DJ Panel"
	set desc = "Get your groove on!" //"funny function names???? first you use the WRONG INDENT STYLE and now this????" --that fuckhead on the forums
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	if (!isadmin(src) && !src.non_admin_dj)
		boutput(src, "Only administrators or those with access may use this command.")
		return

	if(admin_dj.IsSubscribed(src))
		admin_dj.Unsubscribe(src)
	else
		admin_dj.Subscribe(src)

chui/window/dj_panel //global panel
	name = "DJ Panel"
	windowSize = "500x400"
	flags = CHUI_FLAG_MOVABLE | CHUI_FLAG_CLOSABLE | CHUI_FLAG_SIZABLE
	var/loaded_song = null //holds current song file

	GetBody()
		var/list/html = list()

		html += "<strong>Loaded Soundfile:</strong> [theme.generateButton("changefile", "[template("set_file", "None")]")] <br>"
		html += "<strong>Sound Volume:</strong> [theme.generateButton("changevol", "[template("set_volume", 50)]")] <br>"
		html += "<strong>Sound Frequency:</strong> [theme.generateButton("changefreq", "[template("set_freq", 1)]")] <br>"
		html += "<strong>DJ Announce Mode: [theme.generateButton("toggleanndj", "Toggle")]</strong> <br>"
		html += "<strong>Current Sound Channel:</strong> [template("admin_channel", admin_sound_channel)]<br><hr><br>"

		html += "[theme.generateButton("playsound", "Play Sound")] &nbsp; &nbsp; [theme.generateButton("playmusic", "Play Music")]<br><br>"
		html += "[theme.generateButton("playamb", "Play Local Ambience")] &nbsp; &nbsp; [theme.generateButton("playremote", "Play Remote File")]<br><br>"
		html += "[theme.generateButton("playplayr", "Play To Player")] &nbsp; &nbsp; [theme.generateButton("toggledj", "Toggle DJ For Player")]<br><br>"
		html += "[theme.generateButton("stopsong", "Stop Last Song")] &nbsp; &nbsp; [theme.generateButton("stopradio", "Stop Radio for Everyone")]"

		return html.Join()

	OnClick( var/client/who, var/id )
		if (!config.allow_admin_sounds)
			alert(who, "Admin sounds disabled")
			return

		switch(id)
			if("changevol")
				var/volnum = (input(who, "Please enter a volume:", "Please enter a volume. Default: 50.", "") as num) //have to do this otherwise multiple input boxes
				SetVar("set_volume", clamp(volnum, 0, 100))
				return
			if("changefreq")
				var/freqnum = (input(who, "Please enter a frequency. Default : 1. Use negatives to play in reverse.", "Pitch?", "") as num) //ditto
				SetVar("set_freq", clamp(freqnum, -99, 99))
				return
			if("changefile")
				loaded_song = (input(who, "Upload a file:", "File Uploader - No 50MB songs!", "") as sound|null)
				SetVar("set_file", "[loaded_song || "None"]") //string representation for display
				return
			if ("toggledj")
				var/client/C = input(who, "Choose a client:", "Choose a client:") in clients
				toggledj(C)
				return
			if ("toggleanndj")
				who.djmode = !who.djmode
				boutput(who, "<span class='notice'>DJ mode now [(who.djmode ? "On" : "Off")].</span>")

				logTheThing("admin", who, null, "set their DJ mode to [(who.djmode ? "On" : "Off")]")
				logTheThing("diary", who, null, "set their DJ mode to [(who.djmode ? "On" : "Off")]", "admin")
				message_admins("[key_name(who)] set their DJ mode to [(who.djmode ? "On" : "Off")]")
				return
			if ("stopsong")
				move_admin_sound_channel(opposite=1)
				SPAWN_DBG(0)
					for (var/client/C in clients)
						LAGCHECK(LAG_LOW)
						var/sound/stopsound = sound(null,wait = 0,channel=admin_sound_channel)
						stopsound.channel = admin_sound_channel
						C <<  stopsound
				return
			if ("stopradio")
				SPAWN_DBG(0)
					for (var/client/C in clients)
						LAGCHECK(LAG_LOW)
						var/mute_channel = 1013
						var/sound/stopsound = sound(null,wait = 0,channel=mute_channel)
						stopsound.channel = mute_channel
						C <<  stopsound
				return
			if ("playremote")
				who.play_youtube_audio()
				return


		if (!loaded_song) //need to put here otherwise can't load song in first place
			boutput(who, "There's no sound loaded!")
			return

		switch(id)
			if ("playsound")
				who.play_sound_real(loaded_song, GetVar("set_volume"), GetVar("set_freq"))
			if ("playmusic")
				who.play_music_real(loaded_song, GetVar("set_freq"))
			if ("playamb")
				logTheThing("admin", who, null, "played ambient sound [loaded_song]")
				logTheThing("diary", who, null, "played ambient sound [loaded_song]", "admin")
				message_admins("[admin_key(who)] played ambient sound [loaded_song]")
				playsound(get_turf_loc(who.mob), loaded_song, GetVar("set_volume"), GetVar("set_freq"))
			if ("playplayr")
				var/client/C = input(who, "Choose a client:", "Choose a client:", who) in clients
				logTheThing("admin", who, null, "played sound [loaded_song] to [C]")
				logTheThing("diary", who, null, "played sound [loaded_song] to [C]", "admin")
				message_admins("[admin_key(who)] played sound [loaded_song] to [C]")
				playsound(C.mob, loaded_song, GetVar("set_volume"), GetVar("set_freq"))

proc/toggledj(var/client/C, var/client/who)
	C.non_admin_dj = !C.non_admin_dj
	if (C.non_admin_dj)
		C.verbs += /client/proc/open_dj_panel
		C.verbs += /client/proc/cmd_dectalk
	else
		C.verbs -= /client/proc/cmd_dectalk
		C.verbs -= /client/proc/open_dj_panel

	logTheThing("admin", who, C, "has [C.non_admin_dj ? "given" : "removed"] the ability for %target% to DJ and use dectalk.")
	logTheThing("diary", who, C, "has [C.non_admin_dj ? "given" : "removed"] the ability for %target% to DJ and use dectalk.", "admin")
	message_admins("[key_name(who)] has [C.non_admin_dj ? "given" : "removed"] the ability for [key_name(C)] to DJ and use dectalk.")
	boutput(C, "<span class='alert'><b>You [C.non_admin_dj ? "can now" : "no longer can"] DJ with the 'DJ Panel' and use text2speech with 'Dectalk' commands under 'Special Verbs'.</b></span>")
	return
