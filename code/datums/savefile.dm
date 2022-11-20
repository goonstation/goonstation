// See _std/_setup.dm for safe file defines


// todo:
// force_random_looks -> do on char gen, not here
// force_random_names -> do on char gen, not here
// split game settings into own load/save proc
// and/or split from character prefs
// rn some are client skin checkboxes, some are here,
// some are stored in ~the butt~

/datum/preferences/proc

	savefile_path(var/key)
		return "data/player_saves/[copytext(ckey(key), 1, 2)]/[ckey(key)].sav"


	// returnSaveFile returns the file rather than writing it
	// used for cloud saves
	savefile_save(key, profileNum = 1, returnSavefile = 0)
		if (key)
			if (IsGuestKey(key))
				return 0
		else if (!returnSavefile) // if we don't have a user and we're trying to write it, it isn't going to work
			CRASH("Tried to write a preferences savefile with no user specified.")

		profileNum = clamp(profileNum, 1, SAVEFILE_PROFILES_MAX)

		var/savefile/F
		if (returnSavefile)
			F = new /savefile
		else
			F = new /savefile(src.savefile_path(key), -1)
		F.Lock(-1)

		F["version"] << SAVEFILE_VERSION_MAX
		// Mark the profile as having not been modified (for the prefs window)
		src.profile_modified = 0

		// Internal shit
		F["[profileNum]_saved"] << 1
		F["[profileNum]_profile_name"] << src.profile_name

		// Character details
		F["[profileNum]_real_name"] << src.real_name
		F["[profileNum]_name_first"] << src.name_first
		F["[profileNum]_name_middle"] << src.name_middle
		F["[profileNum]_name_last"] << src.name_last
		F["[profileNum]_robot_name"] << src.robot_name
		F["[profileNum]_gender"] << src.gender
		F["[profileNum]_age"] << src.age
		F["[profileNum]_fartsound"] << AH.fartsound
		F["[profileNum]_screamsound"] << AH.screamsound
		F["[profileNum]_voicetype"] << AH.voicetype
		F["[profileNum]_PDAcolor"] << src.PDAcolor
		F["[profileNum]_pda_ringtone_index"] << src.pda_ringtone_index
		F["[profileNum]_random_blood"] << src.random_blood
		F["[profileNum]_blood_type"] << src.blType

		// Records
		F["[profileNum]_pin"] << src.pin
		F["[profileNum]_flavor_text"] << src.flavor_text
		F["[profileNum]_medical_note"] << src.medical_note
		F["[profileNum]_security_note"] << src.security_note

		// Randomize appearances
		F["[profileNum]_name_is_always_random"] << src.be_random_name
		F["[profileNum]_look_is_always_random"] << src.be_random_look

		// AppearanceHolder details
		if (src.AH)
			F["[profileNum]_pronouns"] << (isnull(AH.pronouns) ? "" : AH.pronouns.name)
			F["[profileNum]_eye_color"] << AH.e_color
			F["[profileNum]_hair_color"] << AH.customization_first_color
			F["[profileNum]_facial_color"] << AH.customization_second_color
			F["[profileNum]_detail_color"] << AH.customization_third_color
			F["[profileNum]_skin_tone"] << AH.s_tone
			F["[profileNum]_special_style"] << AH.special_style
			F["[profileNum]_hair_style_name"] << AH.customization_first
			F["[profileNum]_facial_style_name"] << AH.customization_second
			F["[profileNum]_detail_style_name"] << AH.customization_third
			F["[profileNum]_underwear_style_name"] << AH.underwear
			F["[profileNum]_underwear_color"] << AH.u_color

		// Job prefs
		F["[profileNum]_job_prefs_1"] << src.job_favorite
		F["[profileNum]_job_prefs_2"] << src.jobs_med_priority
		F["[profileNum]_job_prefs_3"] << src.jobs_low_priority
		F["[profileNum]_job_prefs_4"] << src.jobs_unwanted
		F["[profileNum]_be_traitor"] << src.be_traitor
		F["[profileNum]_be_syndicate"] << src.be_syndicate
		F["[profileNum]_be_syndicate_commander"] << src.be_syndicate_commander
		F["[profileNum]_be_spy"] << src.be_spy
		F["[profileNum]_be_gangleader"] << src.be_gangleader
		F["[profileNum]_be_revhead"] << src.be_revhead
		F["[profileNum]_be_changeling"] << src.be_changeling
		F["[profileNum]_be_wizard"] << src.be_wizard
		F["[profileNum]_be_werewolf"] << src.be_werewolf
		F["[profileNum]_be_vampire"] << src.be_vampire
		F["[profileNum]_be_arcfiend"] << src.be_arcfiend
		F["[profileNum]_be_wraith"] << src.be_wraith
		F["[profileNum]_be_blob"] << src.be_blob
		F["[profileNum]_be_conspirator"] << src.be_conspirator
		F["[profileNum]_be_flock"] << src.be_flock
		F["[profileNum]_be_misc"] << src.be_misc

		// UI settings. Ehhhhh.
		F["[profileNum]_hud_style"] << src.hud_style
		F["[profileNum]_tcursor"] << src.target_cursor

		if(src.traitPreferences.isValid())
			F["[profileNum]_traits"] << src.traitPreferences.traits_selected



		// Global options
		F["tooltip"] << (src.tooltip_option ? src.tooltip_option : TOOLTIP_ALWAYS)
		F["changelog"] << src.view_changelog
		F["score"] << src.view_score
		F["tickets"] << src.view_tickets
		F["sounds"] << src.admin_music_volume
		F["radio_sounds"] << src.radio_music_volume
		F["clickbuffer"] << src.use_click_buffer
		F["font_size"] << src.font_size

		F["see_mentor_pms"] << src.see_mentor_pms
		F["listen_ooc"] << src.listen_ooc
		F["listen_looc"] << src.listen_looc
		F["default_wasd"] << src.use_wasd
		F["use_azerty"] << src.use_azerty
		F["preferred_map"] << src.preferred_map
		F["flying_chat_hidden"] << src.flying_chat_hidden
		F["auto_capitalization"] << src.auto_capitalization
		F["local_deachat"] << src.local_deadchat

		if (returnSavefile)
			return F
		return 1



	// loads the savefile corresponding to the client's ckey
	// if silent=true, report incompatible savefiles
	// returns 1 if loaded (or file was incompatible)
	// returns 0 if savefile did not exist
	savefile_load(client/user, var/profileNum = 1, var/savefile/loadFrom = null)
		if (user) // bypass these checks if we're loading from a savefile and don't have a user
			if (!isclient(user))
				CRASH("[user] isnt a client. please give me a client. please. i beg you.")

			if (IsGuestKey(user.key))
				return 0

		var/savefile/F
		var/path
		if (loadFrom)
			F = loadFrom
		else if (user)
			path = savefile_path(user.ckey)
			if (!fexists(path))
				return 0
			profileNum = clamp(profileNum, 1, SAVEFILE_PROFILES_MAX)
			F = new /savefile(path, -1)
		else
			CRASH("Tried to load a savefile with no passed user and no savefile to load from!")

		var/version = null
		F["version"] >> version

		if (isnull(version) || version < SAVEFILE_VERSION_MIN || version > SAVEFILE_VERSION_MAX)
			if (!loadFrom)
				fdel(path)
			return 0

		// Check if any saved profiles are present
		var/sanity_check = null
		F["[profileNum]_saved"] >> sanity_check
		if (isnull(sanity_check))
			for (var/i=1, i <= SAVEFILE_PROFILES_MAX, i++)
				F["[i]_saved"] >> sanity_check
				if (!isnull(sanity_check))
					break
			if (isnull(sanity_check) && !loadFrom)
				fdel(path)
			return 0

		src.profile_number = profileNum
		src.profile_modified = 0

		// Old version upgrades
		if (version < 6)
			F["[profileNum]_clickbuffer"] << 0

		if (version < 7)
			F["listen_ooc"] << 1

		if (version <= 8)
			// Global prefs change
			F["tooltip"] << F["[profileNum]_tooltip"]
			F["changelog"] << F["[profileNum]_changelog"]
			F["score"] << F["[profileNum]_score"]
			F["tickets"] << F["[profileNum]_tickets"]
			F["sounds"] << F["[profileNum]_sounds"]
			F["radio_sounds"] << F["[profileNum]_radio_sounds"]
			F["clickbuffer"] << F["[profileNum]_clickbuffer"]

		// Character details
		F["[profileNum]_profile_name"] >> src.profile_name
		F["[profileNum]_real_name"] >> src.real_name
		F["[profileNum]_name_first"] >> src.name_first
		F["[profileNum]_name_middle"] >> src.name_middle
		F["[profileNum]_name_last"] >> src.name_last
		F["[profileNum]_robot_name"] >> src.robot_name
		F["[profileNum]_gender"] >> src.gender
		F["[profileNum]_age"] >> src.age
		F["[profileNum]_fartsound"] >> AH.fartsound
		F["[profileNum]_screamsound"] >> AH.screamsound
		F["[profileNum]_voicetype"] >> AH.voicetype
		F["[profileNum]_PDAcolor"] >> src.PDAcolor
		F["[profileNum]_pda_ringtone_index"] >> src.pda_ringtone_index
		F["[profileNum]_random_blood"] >> src.random_blood
		F["[profileNum]_blood_type"] >> src.blType

		// Records
		F["[profileNum]_pin"] >> src.pin
		F["[profileNum]_flavor_text"] >> src.flavor_text
		F["[profileNum]_medical_note"] >> src.medical_note
		F["[profileNum]_security_note"] >> src.security_note

		// Randomization options
		F["[profileNum]_name_is_always_random"] >> src.be_random_name
		F["[profileNum]_look_is_always_random"] >> src.be_random_look

		// AppearanceHolder details
		if (src.AH)
			var/saved_pronouns
			F["[profileNum]_pronouns"] >> saved_pronouns
			for (var/P as anything in filtered_concrete_typesof(/datum/pronouns, /proc/pronouns_filter_is_choosable))
				var/datum/pronouns/pronouns = get_singleton(P)
				if (saved_pronouns == pronouns.name)
					AH.pronouns = pronouns
					break
			F["[profileNum]_eye_color"] >> AH.e_color
			F["[profileNum]_hair_color"] >> AH.customization_first_color
			F["[profileNum]_hair_color"] >> AH.customization_first_color_original
			F["[profileNum]_facial_color"] >> AH.customization_second_color
			F["[profileNum]_facial_color"] >> AH.customization_second_color_original
			F["[profileNum]_detail_color"] >> AH.customization_third_color
			F["[profileNum]_detail_color"] >> AH.customization_third_color_original
			F["[profileNum]_skin_tone"] >> AH.s_tone
			F["[profileNum]_skin_tone"] >> AH.s_tone_original
			F["[profileNum]_special_style"] >> AH.special_style
			F["[profileNum]_hair_style_name"] >> AH.customization_first
			F["[profileNum]_hair_style_name"] >> AH.customization_first_original
			F["[profileNum]_facial_style_name"] >> AH.customization_second
			F["[profileNum]_facial_style_name"] >> AH.customization_second_original
			F["[profileNum]_detail_style_name"] >> AH.customization_third
			F["[profileNum]_detail_style_name"] >> AH.customization_third_original
			F["[profileNum]_underwear_style_name"] >> AH.underwear
			F["[profileNum]_underwear_color"] >> AH.u_color
			if(!istype(src.AH.customization_first,/datum/customization_style))
				src.AH.customization_first = find_style_by_name(src.AH.customization_first)
			if(!istype(src.AH.customization_second,/datum/customization_style))
				src.AH.customization_second = find_style_by_name(src.AH.customization_second)
			if(!istype(src.AH.customization_third,/datum/customization_style))
				src.AH.customization_third = find_style_by_name(src.AH.customization_third)
			if(!istype(src.AH.customization_first_original,/datum/customization_style))
				src.AH.customization_first_original = find_style_by_name(src.AH.customization_first_original)
			if(!istype(src.AH.customization_second_original,/datum/customization_style))
				src.AH.customization_second_original = find_style_by_name(src.AH.customization_second_original)
			if(!istype(src.AH.customization_third_original,/datum/customization_style))
				src.AH.customization_third_original = find_style_by_name(src.AH.customization_third_original)

		// Job prefs
		F["[profileNum]_job_prefs_1"] >> src.job_favorite
		F["[profileNum]_job_prefs_2"] >> src.jobs_med_priority
		F["[profileNum]_job_prefs_3"] >> src.jobs_low_priority
		F["[profileNum]_job_prefs_4"] >> src.jobs_unwanted
		F["[profileNum]_be_traitor"] >> src.be_traitor
		F["[profileNum]_be_syndicate"] >> src.be_syndicate
		F["[profileNum]_be_syndicate_commander"] >> src.be_syndicate_commander
		F["[profileNum]_be_spy"] >> src.be_spy
		F["[profileNum]_be_gangleader"] >> src.be_gangleader
		F["[profileNum]_be_revhead"] >> src.be_revhead
		F["[profileNum]_be_changeling"] >> src.be_changeling
		F["[profileNum]_be_wizard"] >> src.be_wizard
		F["[profileNum]_be_werewolf"] >> src.be_werewolf
		F["[profileNum]_be_vampire"] >> src.be_vampire
		F["[profileNum]_be_arcfiend"] >> src.be_arcfiend
		F["[profileNum]_be_wraith"] >> src.be_wraith
		F["[profileNum]_be_blob"] >> src.be_blob
		F["[profileNum]_be_conspirator"] >> src.be_conspirator
		F["[profileNum]_be_flock"] >> src.be_flock
		F["[profileNum]_be_misc"] >> src.be_misc

		// UI settings...
		F["[profileNum]_hud_style"] >> src.hud_style
		F["[profileNum]_tcursor"] >> src.target_cursor

		F["[profileNum]_traits"] >> src.traitPreferences.traits_selected


		// Game setting options, not per-profile
		F["tooltip"] >> src.tooltip_option
		F["changelog"] >> src.view_changelog
		F["score"] >> src.view_score
		F["tickets"] >> src.view_tickets
		F["sounds"] >> src.admin_music_volume
		F["radio_sounds"] >> src.radio_music_volume
		F["clickbuffer"] >> src.use_click_buffer
		F["font_size"] >> src.font_size

		F["see_mentor_pms"] >> src.see_mentor_pms
		F["listen_ooc"] >> src.listen_ooc
		F["listen_looc"] >> src.listen_looc
		F["default_wasd"] >> src.use_wasd
		F["use_azerty"] >> src.use_azerty
		F["preferred_map"] >> src.preferred_map
		F["flying_chat_hidden"] >> src.flying_chat_hidden
		F["auto_capitalization"] >> src.auto_capitalization
		F["local_deachat"] >> src.local_deadchat


		if (isnull(src.name_first) || !length(src.name_first) || isnull(src.name_last) || !length(src.name_last))
			// Welp, you get a random name then.
			src.randomize_name()

		// Clean up invalid / default preferences
		if (isnull(AH.fartsound))
			AH.fartsound = "default"
		if (isnull(AH.screamsound) || AH.screamsound == "default")
			AH.screamsound = "male"
		if (!AH.voicetype)
			AH.voicetype = RANDOM_HUMAN_VOICE

		if(!is_valid_color_string(src.PDAcolor)) //how?
			src.PDAcolor = "#6F7961"

		get_all_character_setup_ringtones()
		if(!(src.pda_ringtone_index in selectable_ringtones))
			src.pda_ringtone_index = "Two-Beep"

		if (!istext(src.hud_style))
			src.hud_style = "New"
		if (!istext(src.target_cursor))
			src.target_cursor = "Default"


		// Validate trait choices
		if (src.traitPreferences.traits_selected == null)
			src.traitPreferences.traits_selected = list()

		for (var/T as anything in src.traitPreferences.traits_selected)
			if (!(T in traitList)) src.traitPreferences.traits_selected.Remove(T)

		if (!src.traitPreferences.isValid())
			src.traitPreferences.traits_selected.Cut()
			tgui_alert(user, "Your traits couldn't be loaded. Please reselect your traits.", "Reselect traits")

		src.traitPreferences.updateTotal()

		if(!src.radio_music_volume) // We can take this out some time, when we're decently sure that most people will have this var set to something
			F["[profileNum]_sounds"] >> src.radio_music_volume
			F["[profileNum]_radio_sounds"] << src.radio_music_volume

		// Global pref validation
		if (user?.is_mentor())
			if (isnull(src.see_mentor_pms))
				src.see_mentor_pms = 1
			if (src.see_mentor_pms == 0)
				user.set_mentorhelp_visibility(0)

		if (isnull(src.listen_looc))
			src.listen_looc = 1
		if (isnull(src.use_wasd))
			src.use_wasd = 1
		if (isnull(src.use_azerty))
			src.use_azerty = 0


		src.tooltip_option = (src.tooltip_option ? src.tooltip_option : TOOLTIP_ALWAYS) //For fucks sake.
		src.keybind_prefs_updated(user)


		return 1


	//This might be a bad way of doing it IDK
	savefile_get_profile_name(client/user, var/profileNum = 1)
		if (IsGuestKey(user.key))
			return 0

		LAGCHECK(LAG_REALTIME)

		var/path = savefile_path(user.ckey)

		if (!fexists(path))
			return 0

		profileNum = clamp(profileNum, 1, SAVEFILE_PROFILES_MAX)

		var/savefile/F = new /savefile(path, -1)

		var/version = null
		F["version"] >> version

		if (isnull(version) || version < SAVEFILE_VERSION_MIN || version > SAVEFILE_VERSION_MAX)
			fdel(path)
			return 0

		var/profile_name = null
		F["[profileNum]_profile_name"] >> profile_name

		return profile_name

	/// Save a character profile to the cloud.
	/// load_from (if not null) is the ckey to load this profile from. Can be used to load profiles from another ckey.
	cloudsave_load(client/user, var/name, var/load_from)
		if (user) // bypass these checks if we're loading from an arbitrary key
			if(user && isnull( user.player.cloudsaves ))
				return "Failed to retrieve cloud data, try rejoining."

			if (IsGuestKey(user.key))
				return 0

		// Fetch via HTTP from goonhub
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.spacebee_api_url]/api/cloudsave?get&ckey=[ckey(load_from) || user.ckey]&name=[url_encode(name)]&api_key=[config.spacebee_api_key]", "", "")
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/http_response/response = request.into_response()

		if (response.errored || !response.body)
			logTheThing(LOG_DEBUG, null, "<b>cloudsave_load:</b> Failed to contact goonhub. u: [user.ckey]")
			return

		var/list/ret = json_decode(response.body)
		if( ret["status"] == "error" )
			return ret["error"]["error"]

		var/savefile/save = new
		save.ImportText( "/", ret["savedata"] )
		return src.savefile_load(user, 1, save)

	/// Save a character profile to the cloud.
	/// save_to (if not null) is the ckey to save this profile to. Can be used to save profiles to another ckey.
	cloudsave_save(client/user, var/name, var/save_to)
		if (user) // bypass these checks if we're saving to an arbitrary key
			if(isnull( user.player.cloudsaves ))
				return "Failed to retrieve cloud data, try rejoining."
			if (IsGuestKey( user.key ))
				return 0
			if (save_to)
				CRASH("Tried to save a cloud save with a client and a key to save to specified- need one or the other")

		var/savefile/save = src.savefile_save(ckey(save_to) || user.ckey, 1, 1)
		var/exported = save.ExportText()

		// Fetch via HTTP from goonhub
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.spacebee_api_url]/api/cloudsave?put&ckey=[ckey(save_to) || user.ckey]&name=[url_encode(name)]&api_key=[config.spacebee_api_key]&data=[url_encode(exported)]", "", "")
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/http_response/response = request.into_response()

		if (response.errored || !response.body)
			logTheThing(LOG_DEBUG, null, "<b>cloudsave_load:</b> Failed to contact goonhub. u: [save_to || user.ckey]")
			return

		var/list/ret = json_decode(response.body)
		if( ret["status"] == "error" )
			return ret["error"]["error"]
		user?.player.cloudsaves[ name ] = length( exported )
		return 1

	cloudsave_delete( client/user, var/name )

		// Request deletion via HTTP from goonhub
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.spacebee_api_url]/api/cloudsave?delete&ckey=[user.ckey]&name=[url_encode(name)]&api_key=[config.spacebee_api_key]", "", "")
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/http_response/response = request.into_response()

		if (response.errored || !response.body)
			logTheThing(LOG_DEBUG, null, "<b>cloudsave_delete:</b> Failed to contact goonhub. u: [user.ckey]")
			return

		user.player.cloudsaves.Remove( name )
		return 1
