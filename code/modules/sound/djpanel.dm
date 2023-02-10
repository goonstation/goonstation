/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=DJ PANEL BY ZEWAKA-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

client/proc/open_dj_panel()
	set name = "DJ Panel"
	set desc = "Get your groove on!" //"funny function names???? first you use the WRONG INDENT STYLE and now this????" --that fuckhead on the forums
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	if (!isadmin(src) && !src.non_admin_dj)
		boutput(src, "Only administrators or those with access may use this command.")
		return FALSE

	global.dj_panel.ui_interact(src.mob)

/**
 * # DJ Panel for Admins
 *
 *  Allows for easily accessible music/sound playing for admins/allowed players.
 */
/datum/dj_panel
	var/loaded_sound = null // holds current song file
	var/sound_volume = 50
	var/sound_frequency = 1
	var/list/preloaded_sounds = list()

/datum/dj_panel/ui_state(mob/user)
	return tgui_always_state

/datum/dj_panel/ui_status(mob/user)
  return max(
		tgui_admin_state.can_use_topic(src, user),
		src.dj_access_check(user)
	)

/// Checks if the passed mob is an admin or has dj access
/datum/dj_panel/proc/dj_access_check(mob/user)
	if (isadmin(user) || user?.client?.non_admin_dj)
		return UI_INTERACTIVE
	else
		return UI_CLOSE

/datum/dj_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DJPanel")
		ui.open()

/datum/dj_panel/ui_data(mob/user)
	. = list(
		"adminChannel" = admin_sound_channel,
		"loadedSound" = "[loaded_sound]",
		"volume" = sound_volume,
		"frequency" = sound_frequency,
		"announceMode" = user.client?.djmode,
		"preloadedSounds" = preloaded_sounds,
	)

/datum/dj_panel/ui_act(action, params)
	. = ..()
	if (.)
		return

	if (!config.allow_admin_sounds)
		alert(usr, "Admin sounds disabled")
		ui_close(usr)

	switch(action)

		if("set-file")
			var/foundsound = input(usr, "Upload a file:", "File Uploader - No 50MB songs!", null) as null|sound
			loaded_sound = foundsound
			. = TRUE

		if("set-volume")
			var/new_volume = params["volume"]
			if(new_volume  == "reset")
				sound_volume = initial(sound_volume)
				. = TRUE
			else if(text2num(new_volume) != null)
				sound_volume = clamp(text2num(new_volume), 0, 100)
				. = TRUE

		if("set-freq")
			var/new_freq = params["frequency"]
			if(new_freq  == "reset")
				sound_frequency = initial(sound_frequency)
				. = TRUE
			else if(text2num(new_freq) != null)
				sound_frequency = clamp(text2num(new_freq), -100, 100)
				. = TRUE

		if("toggle-announce")
			if (!usr.client)
				return TRUE
			usr.client.djmode = !usr.client.djmode
			boutput(usr, "<span class='notice'>DJ mode now [(usr.client.djmode ? "On" : "Off")].</span>")

			logTheThing(LOG_ADMIN, usr, "set their DJ mode to [(usr.client.djmode ? "On" : "Off")]")
			logTheThing(LOG_DIARY, usr, "set their DJ mode to [(usr.client.djmode ? "On" : "Off")]", "admin")
			message_admins("[key_name(usr)] set their DJ mode to [(usr.client.djmode ? "On" : "Off")]")
			. = TRUE

		if("play-sound")
			usr.client?.play_sound_real(loaded_sound, sound_volume, sound_frequency)
			. = TRUE

		if("play-music")
			usr.client?.play_music_real(loaded_sound, sound_frequency)
			. = TRUE

		if("play-ambience")
			logTheThing(LOG_ADMIN, usr, "played ambient sound [loaded_sound]")
			logTheThing(LOG_DIARY, usr, "played ambient sound [loaded_sound]", "admin")
			message_admins("[admin_key(usr.client)] played ambient sound [loaded_sound]")
			playsound(usr, loaded_sound, sound_volume, sound_frequency)

		if("play-remote")
			usr.client?.play_youtube_audio()

		if("play-player")
			var/client/C = input(usr, "Choose a client:", "Choose a client:", usr) as null|anything in clients
			if (!C) return FALSE
			logTheThing(LOG_ADMIN, usr, "played sound [loaded_sound] to [C]")
			logTheThing(LOG_DIARY, usr, "played sound [loaded_sound] to [C]", "admin")
			message_admins("[admin_key(usr.client)] played sound [loaded_sound] to [C]")
			playsound(C.mob, loaded_sound, sound_volume, sound_frequency)

		if("preload-sound")
			preloaded_sounds["[loaded_sound]"] = loaded_sound
			for (var/client/C in clients)
				C << load_resource(loaded_sound, -1)
			message_admins("[admin_key(usr.client)] preloaded sound [loaded_sound]")

		if("play-preloaded")
			var/selected = tgui_input_list(usr, "Which sound?", "Sound Selector", preloaded_sounds, timeout = 5 MINUTES, allowIllegal = TRUE)
			if (selected && (selected in preloaded_sounds))
				var/sound/selected_sound = preloaded_sounds[selected]
				usr.client?.play_music_real(selected_sound, sound_frequency)
				preloaded_sounds.Remove(selected)

		if("toggle-player-dj")
			var/dude = input(usr, "Choose a client:", "Choose a client:", null) as null|anything in clients
			if (!dude) return FALSE
			toggledj(dude, usr)

		if("stop-sound")
			move_admin_sound_channel(TRUE)
			SPAWN(0)
				var/sound/stopsound = sound(null, wait = 0, channel=admin_sound_channel)
				for (var/client/C in clients)
					C << stopsound
					LAGCHECK(LAG_MED)
			. = TRUE

		if("stop-radio")
			SPAWN(0)
				var/sound/stopsound = sound(null, wait = 0, channel=1013)
				for (var/client/C in clients)
					C << stopsound
					LAGCHECK(LAG_MED)


/**
 * Moves the global admin sound channel up or down one
 *
 * * backwards - Moves it backwards if true
 */
/datum/dj_panel/proc/move_admin_sound_channel(backwards = FALSE)
	if (backwards)
		if (admin_sound_channel > SOUNDCHANNEL_ADMIN_LOW)
			admin_sound_channel--
		else
			admin_sound_channel = SOUNDCHANNEL_ADMIN_HIGH
	else
		if (admin_sound_channel < SOUNDCHANNEL_ADMIN_HIGH)
			admin_sound_channel++
		else
			admin_sound_channel = SOUNDCHANNEL_ADMIN_LOW

/**
 * Toggles the DJ Mode for a given client
 *
 * * required C - Client to toggle the DJ Mode of
 * * required actor - The client actor toggled the DJ Mode
 */
/datum/dj_panel/proc/toggledj(client/C, client/actor)
	C.non_admin_dj = !C.non_admin_dj
	if (C.non_admin_dj)
		C.verbs += /client/proc/open_dj_panel
		C.verbs += /client/proc/cmd_dectalk
	else
		C.verbs -= /client/proc/cmd_dectalk
		C.verbs -= /client/proc/open_dj_panel

	logTheThing(LOG_ADMIN, actor, "has [C.non_admin_dj ? "given" : "removed"] the ability for [constructTarget(C,"admin")] to DJ and use dectalk.")
	logTheThing(LOG_DIARY, actor, "has [C.non_admin_dj ? "given" : "removed"] the ability for [constructTarget(C,"diary")] to DJ and use dectalk.", "admin")
	message_admins("[key_name(actor)] has [C.non_admin_dj ? "given" : "removed"] the ability for [key_name(C)] to DJ and use dectalk.")
	boutput(C, "<span class='alert'><b>You [C.non_admin_dj ? "can now" : "no longer can"] DJ with the 'DJ Panel' and use text2speech with 'Dectalk' commands under 'Special Verbs'.</b></span>")
