var/list/bad_name_characters = list("_", "'", "\"", "<", ">", ";", "\[", "\]", "{", "}", "|", "\\", "/")
var/regex/emoji_regex = regex(@{"([^\u0020-\u8000]+)"})

proc/remove_bad_name_characters(string)
	for (var/char in bad_name_characters)
		string = replacetext(string, char, "")
	return emoji_regex.Replace_char(string, "")

var/list/removed_jobs = list(
	// jobs that have been removed or replaced (replaced -> new name, removed -> null)
	"Barman" = "Bartender",
	"Mechanic" = "Engineer",
	"Mailman" = "Mail Courier"
)

/datum/preferences
	var/profile_name
	var/profile_number
	var/profile_modified
	var/real_name
	var/name_first
	var/name_middle
	var/name_last
	var/hyphenate_name
	var/robot_name
	var/gender = MALE
	var/age = 30
	var/pin = null
	var/blType = "A+"

	var/flavor_text // I'm gunna regret this aren't I
	// These notes are put in the datacore records on the start of the round
	var/security_note
	var/medical_note
	var/synd_int_note
	var/employment_note

	var/be_traitor = FALSE
	var/be_syndicate = FALSE
	var/be_syndicate_commander = FALSE
	var/be_spy = FALSE
	var/be_gangleader = FALSE
	var/be_gangmember = FALSE
	var/be_revhead = FALSE
	var/be_changeling = FALSE
	var/be_wizard = FALSE
	var/be_werewolf = FALSE
	var/be_vampire = FALSE
	var/be_arcfiend = FALSE
	var/be_wraith = FALSE
	var/be_blob = FALSE
	var/be_conspirator = FALSE
	var/be_flock = FALSE
	var/be_salvager = FALSE
	var/be_mindeater = FALSE
	var/be_misc = FALSE

	var/be_random_name = FALSE
	var/be_random_look = FALSE
	var/random_blood = FALSE
	var/view_changelog = TRUE
	var/view_score = TRUE
	var/view_tickets = TRUE
	var/admin_music_volume = 50
	var/radio_music_volume = 10
	var/use_click_buffer = FALSE
	var/help_text_in_examine = TRUE
	var/listen_ooc = TRUE
	var/listen_looc = TRUE
	var/flying_chat_hidden = FALSE
	var/auto_capitalization = FALSE
	var/local_deadchat = FALSE
	var/use_wasd = TRUE
	var/use_azerty = FALSE // do they have an AZERTY keyboard?
	var/spessman_direction = SOUTH
	var/PDAcolor = "#6F7961"

	var/job_favorite = null
	var/list/jobs_med_priority = list()
	var/list/jobs_low_priority = list()
	var/list/jobs_unwanted = list()

	var/pda_ringtone_index = "Two-Beep"

	var/datum/appearanceHolder/AH = new

	var/datum/movable_preview/character/preview = null

	var/mentor = FALSE
	var/see_mentor_pms = TRUE // do they wanna disable mentor pms?
	var/antispam = FALSE

	var/datum/traitPreferences/traitPreferences = new

	var/target_cursor = "Default"
	var/hud_style = "New"

	var/tgui_fancy = TRUE
	var/tgui_lock = FALSE

	var/tooltip_option = TOOLTIP_ALWAYS

	var/scrollwheel_limb_targeting = SCROLL_TARGET_ALWAYS

	var/regex/character_name_validation = null //This regex needs to match the name in order to consider it a valid name

	var/preferred_map = ""

	var/font_size = null

	///An associative list of slots to part IDs, see part_customization.dm
	var/list/custom_parts = null

	var/list/profile_names = null
	var/profile_names_dirty = TRUE
	//var/fartsound = "default"
	//var/screamsound = "default"

	New()
		src.character_name_validation = regex("\\w+") //TODO: Make this regex a bit sturdier (capitalization requirements, character whitelist, etc)
		src.randomize_name()
		src.randomizeLook()
		src.profile_names = new/list(SAVEFILE_PROFILES_MAX)
		..()
		if (isnull(src.custom_parts)) //I feel like there should be a better place to init this
			src.custom_parts = list(
				"l_arm" = "arm_default_left",
				"r_arm" = "arm_default_right",
				"l_leg" = "leg_default_left",
				"r_leg" = "leg_default_right",
				"left_eye" = "eye_default_left",
				"right_eye" = "eye_default_right",
			)

	ui_state(mob/user)
		return tgui_always_state.can_use_topic(src, user)

	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

	ui_interact(mob/user, datum/tgui/ui)
		if (!tgui_process)
			boutput(user, SPAN_ALERT("Hold on a moment, stuff is still setting up."))
			return
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "CharacterPreferences")
			ui.set_autoupdate(FALSE)
			ui.open()
		SPAWN(0) //this awful hack is required to stop the preview rendering with the scale all wrong the first time the window is opened
			src.update_preview_icon() //apparently you need to poke byond into re-sending the window data by changing something about the preview mob??

	ui_close(mob/user)
		. = ..()
		if (!isnull(src.preview))
			qdel(src.preview)
			src.preview = null

	ui_static_data(mob/user)
		var/list/traitsData = list()
		for (var/datum/trait/trait as anything in src.traitPreferences.getTraits(user))
			var/list/categories
			if (islist(trait.category))
				categories = trait.category.Copy()
				categories.Remove(src.traitPreferences.hidden_categories)

			traitsData[trait.id] = list(
				"id" = trait.id,
				"name" = trait.name,
				"desc" = trait.desc,
				"category" = categories,
				"img" = icon2base64(icon(trait.icon, trait.icon_state)),
				"points" = trait.points,
			)
		. = list(
			"traitsData" = traitsData
		)

	ui_data(mob/user)
		if (isnull(src.preview))
			src.preview = new(user.client, "preferences", "preferences_character_preview")
			src.preview.add_background()
			src.update_preview_icon()

		var/client/client = ismob(user) ? user.client : user
		if (!client)
			return

		var/list/profiles = new/list(SAVEFILE_PROFILES_MAX)
		for (var/i = 1, i <= SAVEFILE_PROFILES_MAX, i++)
			if (src.profile_names_dirty)
				src.profile_names[i] = src.savefile_get_profile_name(client, i)
			profiles[i] = list(
				"active" = i == src.profile_number,
				"name" = src.profile_names[i],
			)
		src.profile_names_dirty = FALSE

		var/list/cloud_saves = list()
		for (var/name in client.player.cloudSaves.saves)
			cloud_saves += name

		src.sanitize_null_values()

		var/list/traits = src.traitPreferences.generateTraitData(user)

		var/list/custom_parts_data = list()
		for (var/slot_id in src.custom_parts)
			var/datum/part_customization/customization = get_part_customization(src.custom_parts[slot_id])
			custom_parts_data[slot_id] = list(
				"id" = customization.id,
				"name" = customization.get_name(),
				"points" = customization.trait_cost,
				"img" = customization.get_base64_icon(),
			)

		. = list(
			"isMentor" = client.is_mentor(),

			"profiles" = profiles,
			"cloudSaves" = cloud_saves,

			"profileName" = src.profile_name,
			"profileModified" = src.profile_modified,

			"preview" = src.preview?.preview_id,

			"nameFirst" = src.name_first,
			"nameMiddle" = src.name_middle,
			"nameLast" = src.name_last,
			"hyphenateName" = src.hyphenate_name,
			"robotName" = src.robot_name,
			"randomName" = src.be_random_name,
			"gender" = src.gender == MALE ? "Male" : "Female",
			"pronouns" = isnull(src.AH.pronouns) ? "Default" : src.AH.pronouns.name,
			"age" = src.age,
			"bloodRandom" = src.random_blood,
			"bloodType" = src.blType,
			"pin" = src.pin,
			"flavorText" = src.flavor_text,
			"securityNote" = src.security_note,
			"medicalNote" = src.medical_note,
			"syndintNote" = src.synd_int_note,
			"fartsound" = src.AH.fartsound,
			"screamsound" = src.AH.screamsound,
			"chatsound" = src.AH.voicetype,
			"pdaColor" = src.PDAcolor,
			"pdaRingtone" = src.pda_ringtone_index,
			"skinTone" = src.AH.s_tone_original,
			"specialStyle" = src.AH.special_style,
			"eyeColor" = src.AH.e_color,
			"customColor1" = src.AH.customizations["hair_bottom"].color,
			"customStyle1" = src.AH.customizations["hair_bottom"].style.name,
			"customColor2" = src.AH.customizations["hair_middle"].color,
			"customStyle2" = src.AH.customizations["hair_middle"].style.name,
			"customColor3" = src.AH.customizations["hair_top"].color,
			"customStyle3" = src.AH.customizations["hair_top"].style.name,
			"underwearColor" = src.AH.u_color,
			"underwearStyle" = src.AH.underwear,
			"randomAppearance" = src.be_random_look,

			"fontSize" = src.font_size,
			"seeMentorPms" = src.see_mentor_pms,
			"listenOoc" = src.listen_ooc,
			"listenLooc" = src.listen_looc,
			"flyingChatHidden" = src.flying_chat_hidden,
			"autoCapitalization" = src.auto_capitalization,
			"localDeadchat" = src.local_deadchat,
			"hudTheme" = src.hud_style,
			"hudThemePreview" = icon2base64(icon(hud_style_selection[src.hud_style], "preview")),
			"targetingCursor" = src.target_cursor,
			"targetingCursorPreview" = icon2base64(icon(cursors_selection[src.target_cursor])),
			"tooltipOption" = src.tooltip_option,
			"scrollWheelTargeting" = src.scrollwheel_limb_targeting,
			"tguiFancy" = src.tgui_fancy,
			"tguiLock" = src.tgui_lock,
			"viewChangelog" = src.view_changelog,
			"viewScore" = src.view_score,
			"viewTickets" = src.view_tickets,
			"useClickBuffer" = src.use_click_buffer,
			"helpTextInExamine" = src.help_text_in_examine,
			"useWasd" = src.use_wasd,
			"useAzerty" = src.use_azerty,
			"preferredMap" = src.preferred_map,
			"traitsAvailable" = traits,
			"traitsMax" = src.traitPreferences.max_traits,
			"traitsPointsTotal" = src.traitPreferences.calcTotal(src.traitPreferences.traits_selected, src.custom_parts),
			"partsData" = custom_parts_data,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		var/client/client = ismob(usr) ? usr.client : usr

		switch (action)
			if ("previewSound")
				var/sound_file

				if (params["pdaRingtone"])
					get_all_character_setup_ringtones()
					var/datum/ringtone/RT = selectable_ringtones[src.pda_ringtone_index]
					if (istype(RT) && length(RT.ringList))
						sound_file = RT.ringList[rand(1, length(RT.ringList))]

				if (params["fartsound"])
					sound_file = sound(src.AH.fartsounds[src.AH.fartsound])

				if (params["screamsound"])
					sound_file = sound(src.AH.screamsounds[src.AH.screamsound])

				if (params["chatsound"])
					sound_file = sounds_speak["[src.AH.voicetype]"]

				if (sound_file)
					src.preview_sound(sound_file)

				return FALSE

			if ("rotate-clockwise")
				src.spessman_direction = turn(src.spessman_direction, 90)
				src.update_preview_icon()
				return

			if ("rotate-counter-clockwise")
				src.spessman_direction = turn(src.spessman_direction, -90)
				src.update_preview_icon()
				return

			if ("open-occupation-window")
				src.SetChoices(usr)
				ui.close()
				return TRUE

			if ("save")
				var/index = params["index"]
				if (isnull(src.profile_name) || is_blank_string(src.profile_name))
					tgui_alert(usr, "You need to give your profile a name.", "Pick name")
					return
				src.profile_names_dirty = TRUE
				if (!isnull(index) && isnum(index))
					src.savefile_save(client.key, index)
					src.profile_number = index
					boutput(usr, SPAN_NOTICE("<b>Character saved to Slot [index].</b>"))
					return TRUE

			if ("load")
				var/index = params["index"]
				if (!isnull(index) && isnum(index))
					if (!src.savefile_load(client, index))
						tgui_alert(usr, "You do not have a savefile.", "No savefile")
						return FALSE

					boutput(usr, SPAN_NOTICE("<b>Character loaded from Slot [index].</b>"))
					src.traitPreferences.traitDataDirty = TRUE
					src.update_preview_icon()
					return TRUE

			if ("cloud-new")
				if (length(client.player.cloudSaves.saves) >= SAVEFILE_CLOUD_PROFILES_MAX)
					tgui_alert(usr, "You have hit your cloud save limit. Please write over an existing save.", "Max saves")
				else
					var/new_name = tgui_input_text(usr, "What would you like to name the save?", "Save Name")
					if (length(new_name) < 3 || length(new_name) > MOB_NAME_MAX_LENGTH)
						tgui_alert(usr, "The name must be between 3 and [MOB_NAME_MAX_LENGTH] letters!", "Letter count out of range")
					else
						var/ret = src.cloudsave_save(usr.client, new_name)
						if (!ret)
							boutput( usr, SPAN_ALERT("Failed to save savefile: [ret]") )
						else
							boutput( usr, SPAN_NOTICE("Savefile saved!") )
							return TRUE

			if ("cloud-save")
				var/ret = src.cloudsave_save(client, params["name"])
				if (!ret)
					boutput(usr, SPAN_ALERT("Failed to save savefile: [ret]"))
				else
					boutput(usr, SPAN_NOTICE("Savefile saved!"))
					return TRUE

			if ("cloud-load")
				var/profilenum_old = src.profile_number
				var/ret = src.cloudsave_load(client, params["name"])
				src.profile_number = profilenum_old
				if (istext(ret))
					boutput(usr, SPAN_ALERT("Failed to load savefile: [ret]"))
				else
					boutput(usr, SPAN_NOTICE("Savefile loaded!"))
					src.traitPreferences.traitDataDirty = TRUE
					src.profile_modified = TRUE
					src.update_preview_icon()
					return TRUE

			if ("cloud-delete")
				var/ret = src.cloudsave_delete(client, params["name"])
				if (istext(ret))
					boutput(usr, SPAN_ALERT("Failed to delete savefile: [ret]"))
				else
					boutput(usr, SPAN_NOTICE("Savefile deleted!"))
					return TRUE

			if ("profile-file-export")
				src.profile_export()

			if ("profile-file-import")
				src.profile_import()
				return TRUE

			if ("update-profileName")
				var/new_profile_name = tgui_input_text(usr, "New profile name:", "Character Generation", src.profile_name)

				for (var/c in bad_name_characters)
					new_profile_name = replacetext(new_profile_name, c, "")

				new_profile_name = trimtext(new_profile_name)

				if (new_profile_name)
					if (length(new_profile_name) >= 26)
						new_profile_name = copytext(new_profile_name, 1, 26)
					src.profile_name = new_profile_name
					src.profile_modified = TRUE
					return TRUE

			if ("update-randomName")
				src.be_random_name = !src.be_random_name
				src.profile_modified = TRUE
				return TRUE

			if ("update-nameFirst")
				var/new_name = tgui_input_text(usr, "Please select a first name:", "Character Generation", src.name_first)
				if (isnull(new_name))
					return
				new_name = trimtext(new_name)
				new_name = remove_bad_name_characters(new_name)
				if (length(new_name) < NAME_CHAR_MIN)
					tgui_alert(usr, "Your first name is too short. It must be at least [NAME_CHAR_MIN] characters long.", "Name too short")
					return
				else if (length(new_name) > NAME_CHAR_MAX)
					tgui_alert(usr, "Your first name is too long. It must be no more than [NAME_CHAR_MAX] characters long.", "Name too long")
					return
				else if (is_blank_string(new_name))
					tgui_alert(usr, "Your first name cannot contain only spaces.", "Blank name")
					return
				else if (!character_name_validation.Find(new_name))
					tgui_alert(usr, "Your first name must contain at least one letter.", "Letters required")
					return
				new_name = capitalize(new_name)

				if (new_name)
					src.name_first = new_name
					src.set_real_name()
					src.profile_modified = TRUE
					return TRUE

			if ("update-nameMiddle")
				var/new_name = tgui_input_text(usr, "Please select a middle name:", "Character Generation", src.name_middle, allowEmpty = TRUE)
				if (isnull(new_name))
					new_name = ""
				new_name = trimtext(new_name)
				new_name = remove_bad_name_characters(new_name)
				if (length(new_name) > NAME_CHAR_MAX)
					tgui_alert(usr, "Your middle name is too long. It must be no more than [NAME_CHAR_MAX] characters long.", "Name too long")
					return
				else if (is_blank_string(new_name) && new_name != "")
					new_name = ""
				new_name = capitalize(new_name)
				src.name_middle = new_name // don't need to check if there is one in case someone wants no middle name I guess
				src.profile_modified = TRUE
				return TRUE

			if ("update-nameLast")
				var/new_name = tgui_input_text(usr, "Please select a last name:", "Character Generation", src.name_last)
				if (isnull(new_name))
					return
				new_name = trimtext(new_name)
				new_name = remove_bad_name_characters(new_name)
				if (length(new_name) < NAME_CHAR_MIN)
					tgui_alert(usr, "Your last name is too short. It must be at least [NAME_CHAR_MIN] characters long.", "Name too short")
					return
				else if (length(new_name) > NAME_CHAR_MAX)
					tgui_alert(usr, "Your last name is too long. It must be no more than [NAME_CHAR_MAX] characters long.", "Name too long")
					return
				else if (is_blank_string(new_name))
					tgui_alert(usr, "Your last name cannot contain only spaces.", "Blank name")
					return
				else if (!character_name_validation.Find(new_name))
					tgui_alert(usr, "Your last name must contain at least one letter.", "Letters required")
					return
				new_name = capitalize(new_name)

				if (new_name)
					src.name_last = new_name
					src.set_real_name()
					src.profile_modified = TRUE
					return TRUE

			if ("toggle-hyphenation")
				src.hyphenate_name = !src.hyphenate_name
				src.set_real_name()
				src.profile_modified = TRUE
				return TRUE

			if ("update-robotName")
				var/new_name = tgui_input_text(usr, "Your preferred cyborg name, leave empty for random.", "Character Generation", src.robot_name)
				if (isnull(new_name))
					return
				if (is_blank_string(new_name))
					src.robot_name = ""
					src.profile_modified = TRUE
					return TRUE

				new_name = strip_html(new_name, MOB_NAME_MAX_LENGTH, 1)
				if (!length(new_name))
					tgui_alert(usr, "That name was too short after removing bad characters from it. Please choose a different name.", "Name too short")
					return

				if (new_name)
					src.robot_name = new_name
					src.profile_modified = TRUE
					return TRUE

			if ("update-gender")
				if (src.gender == MALE)
					src.gender = FEMALE
					src.AH.gender = FEMALE
				else
					src.gender = MALE
					src.AH.gender = MALE
				src.update_preview_icon()
				src.profile_modified = TRUE
				return TRUE

			if ("update-pronouns")
				if (isnull(src.AH.pronouns))
					src.AH.pronouns = get_singleton(/datum/pronouns/theyThem)
				else
					src.AH.pronouns = src.AH.pronouns.next_pronouns()
					if (src.AH.pronouns == get_singleton(/datum/pronouns/theyThem))
						src.AH.pronouns = null
				src.profile_modified = TRUE
				return TRUE

			if ("update-age")
				var/new_age = tgui_input_number(usr, "Please select type in age: 20-80", "Character Generation", src.age, 80, 20)
				if (new_age)
					src.age = clamp(round(text2num(new_age)), 20, 80)
					src.profile_modified = TRUE
					return TRUE

			if ("update-bloodType")
				var/blTypeNew = tgui_input_list(usr, "Please select a blood type:", "Character Generation", list("Random", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"), src.blType)
				if (blTypeNew)
					if (blTypeNew == "Random")
						src.random_blood = TRUE
					else
						src.random_blood = FALSE
						src.blType = blTypeNew
					src.profile_modified = TRUE
					return TRUE

			if ("update-pin")
				if (params["random"])
					src.pin	= null
					return TRUE
				else
					var/new_pin = tgui_input_pin(usr, "Please select a PIN between [PIN_MIN] and [PIN_MAX]", "Character Generation", src.pin || null, PIN_MAX, PIN_MIN)
					if (new_pin)
						src.pin = new_pin
						src.profile_modified = TRUE
						return TRUE

			if ("update-flavorText")
				var/new_text = tgui_input_text(usr, "Please enter new flavor text (appears when examining you):", "Character Generation", html_decode(src.flavor_text), multiline = TRUE, allowEmpty=TRUE)
				if (!isnull(new_text))
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						tgui_alert(usr, "Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.", "Flavor text too long")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					new_text = html_encode(new_text)
					src.flavor_text = new_text || null
					src.profile_modified = TRUE
					return TRUE

			if ("update-securityNote")
				var/new_text = tgui_input_text(usr, "Please enter new flavor text (appears when examining your security record):", "Character Generation", html_decode(src.security_note), multiline = TRUE, allowEmpty=TRUE)
				if (!isnull(new_text))
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						tgui_alert(usr, "Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.", "Flavor text too long")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					new_text = html_encode(new_text)
					src.security_note = new_text || null
					src.profile_modified = TRUE
					return TRUE

			if ("update-medicalNote")
				var/new_text = tgui_input_text(usr, "Please enter new flavor text (appears when examining your medical record):", "Character Generation", html_decode(src.medical_note), multiline = TRUE, allowEmpty=TRUE)
				if (!isnull(new_text))
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						tgui_alert(usr, "Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.", "Flavor text too long")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					new_text = html_encode(new_text)
					src.medical_note = new_text || null
					src.profile_modified = TRUE
					return TRUE

			if ("update-syndintNote")
				var/new_text = tgui_input_text(usr, "Please enter new information Syndicate agents have gathered on you (visible to traitors and spies):", "Character Generation", html_decode(src.synd_int_note), multiline = TRUE, allowEmpty=TRUE)
				if (!isnull(new_text))
					if (length(new_text) > LONG_FLAVOR_CHAR_LIMIT)
						tgui_alert(usr, "Your flavor text is too long. It must be no more than [LONG_FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.", "Flavor text too long")
						new_text = copytext(new_text, 1, LONG_FLAVOR_CHAR_LIMIT+1)
					new_text = html_encode(new_text)
					src.synd_int_note = new_text || null
					src.profile_modified = TRUE
					return TRUE

			if ("update-pdaRingtone")
				get_all_character_setup_ringtones()
				if (!length(selectable_ringtones))
					src.pda_ringtone_index = "Two-Beep"
					tgui_alert(usr, "Oh no! The JamStar-DCXXI PDA ringtone distribution satellite is out of range! Please try again later.", "x.x ringtones broke x.x")
					logTheThing(LOG_DEBUG, usr, "get_all_character_setup_ringtones() didn't return anything!")
				else
					src.pda_ringtone_index = tgui_input_list(usr, "Choose a ringtone", "PDA", selectable_ringtones)
					if (!(src.pda_ringtone_index in selectable_ringtones))
						src.pda_ringtone_index = "Two-Beep"
					src.profile_modified = TRUE
					return TRUE

			if ("update-pdaColor")
				var/new_color = tgui_color_picker(usr, "Choose a color", "PDA", src.PDAcolor)
				if (!isnull(new_color))
					src.PDAcolor = new_color
					src.profile_modified = TRUE
					return TRUE

			if ("update-skinTone")
				var/new_tone = "#FEFEFE"
				if (usr.has_medal("Contributor"))
					switch (tgui_alert(usr, "Goonstation contributors get to pick any colour for their skin tone!", "Thanks, pal!", list("Paint me like a posh fence!", "Use Standard tone.", "Cancel")))
						if ("Paint me like a posh fence!")
							new_tone = tgui_color_picker(usr, "Please select skin color.", "Character Generation", src.AH.s_tone)
						if ("Use Standard tone.")
							new_tone = get_standard_skintone(usr)
						else
							return

					if (new_tone)
						src.AH.s_tone = new_tone
						src.AH.s_tone_original = new_tone
						src.update_preview_icon()
						src.profile_modified = TRUE
						return TRUE
				else
					new_tone = get_standard_skintone(usr)
					if (new_tone)
						src.AH.s_tone = new_tone
						src.AH.s_tone_original = new_tone
						src.update_preview_icon()
						src.profile_modified = TRUE
						return TRUE

			if ("decrease-skinTone")
				var/units = 1
				if (params["alot"])
					units = 8
				var/list/L = hex_to_rgb_list(src.AH.s_tone_original)
				src.AH.s_tone_original = rgb(max(L[1]-units, 61), max(L[2]-units, 8), max(L[3]-units, 0))
				src.AH.s_tone = src.AH.s_tone_original
				src.update_preview_icon()
				src.profile_modified = TRUE
				return TRUE

			if ("increase-skinTone")
				var/units = 1
				if (params["alot"])
					units = 8
				var/list/L = hex_to_rgb_list(src.AH.s_tone_original)
				src.AH.s_tone_original = rgb(min(L[1]+units, 255), min(L[2]+units, 236), min(L[3]+units, 183))
				src.AH.s_tone = src.AH.s_tone_original
				src.update_preview_icon()
				src.profile_modified = TRUE
				return TRUE

			if ("update-specialStyle")
				var/mob/living/carbon/human/H = src.preview.preview_thing
				var/typeinfo/datum/mutantrace/typeinfo = H.mutantrace?.get_typeinfo()
				if (!typeinfo || !typeinfo.special_styles)
					tgui_alert(usr, "No usable special styles detected for this mutantrace.", "Error")
					return
				var/list/style_list = typeinfo.special_styles
				var/new_style = tgui_input_list(usr, "Select a style pattern", "Special Style", style_list)
				if (new_style)
					src.AH.special_style = new_style
					src.update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-eyeColor")
				var/new_color = tgui_color_picker(usr, "Please select an eye color.", "Character Generation", src.AH.e_color)
				if (new_color)
					src.AH.e_color = new_color
					src.update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-randomAppearance")
				src.be_random_look = !src.be_random_look
				src.profile_modified = TRUE
				return TRUE

			if ("update-detail-color")
				var/current_color
				switch (params["id"])
					if ("custom1")
						current_color = src.AH.customizations["hair_bottom"].color
					if ("custom2")
						current_color = src.AH.customizations["hair_middle"].color
					if ("custom3")
						current_color = src.AH.customizations["hair_top"].color
					if ("underwear")
						current_color = src.AH.u_color
				var/new_color = tgui_color_picker(usr, "Please select a color.", "Character Generation", current_color)
				if (new_color)
					switch (params["id"])
						if ("custom1")
							src.AH.customizations["hair_bottom"].color = new_color
						if ("custom2")
							src.AH.customizations["hair_middle"].color = new_color
						if ("custom3")
							src.AH.customizations["hair_top"].color = new_color
						if ("underwear")
							src.AH.u_color = new_color
					src.update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-detail-style")
				var/new_style
				switch (params["id"])
					if ("custom1", "custom2", "custom3")
						new_style = select_custom_style(usr, no_gimmick_hair=TRUE)
					if ("underwear")
						new_style = tgui_input_list(usr, "Select an underwear style", "Character Generation", underwear_styles)
				if (new_style)
					switch (params["id"])
						if ("custom1")
							src.AH.customizations["hair_bottom"].style = new_style
						if ("custom2")
							src.AH.customizations["hair_middle"].style = new_style
						if ("custom3")
							src.AH.customizations["hair_top"].style = new_style
						if ("underwear")
							src.AH.underwear = new_style
					src.update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-detail-style-cycle")
				var/new_style
				var/current_style
				var/current_index
				var/list/style_list

				switch (params["id"])
					if ("custom1")
						current_style = src.AH.customizations["hair_bottom"].style.type
					if ("custom2")
						current_style = src.AH.customizations["hair_middle"].style.type
					if ("custom3")
						current_style = src.AH.customizations["hair_top"].style.type
					if ("underwear")
						current_style = src.AH.underwear

				if (isnull(current_style))
					return

				switch (params["id"])
					if ("custom1", "custom2", "custom3")
						style_list = get_available_custom_style_types(usr.client, no_gimmick_hair=TRUE)
					if ("underwear")
						style_list = underwear_styles

				if (isnull(style_list))
					return

				current_index = style_list.Find(current_style)
				if (params["direction"] == 1)
					new_style = style_list[current_index + 1 > length(style_list) ? 1 : current_index + 1]
				else if (params["direction"] == -1)
					new_style = style_list[current_index - 1 < 1 ? length(style_list) : current_index - 1]

				if (new_style)
					switch (params["id"])
						if ("custom1")
							src.AH.customizations["hair_bottom"].style = new new_style
						if ("custom2")
							src.AH.customizations["hair_middle"].style = new new_style
						if ("custom3")
							src.AH.customizations["hair_top"].style = new new_style
						if ("underwear")
							src.AH.underwear = new_style
					src.update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-fartsound")
				var/list/sound_list = list_keys(src.AH.fartsounds)
				var/new_sound = tgui_input_list(usr, "Select a farting sound", "Fart sound", sound_list)
				if (new_sound)
					src.AH.fartsound = new_sound
					src.preview_sound(sound(src.AH.fartsounds[src.AH.fartsound]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-screamsound")
				var/list/sound_list = list_keys(src.AH.screamsounds)
				var/new_sound = tgui_input_list(usr, "Select a screaming sound", "Scream sound", sound_list)
				if (new_sound)
					src.AH.screamsound = new_sound
					src.preview_sound(sound(src.AH.screamsounds[src.AH.screamsound]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-chatsound")
				var/list/sound_list = list_keys(src.AH.voicetypes)
				var/new_sound = tgui_input_list(usr, "Select a chatting sound", "Chat sound", sound_list)
				if (new_sound)
					new_sound = src.AH.voicetypes[new_sound]
					src.AH.voicetype = new_sound
					src.preview_sound(sound(sounds_speak[src.AH.voicetype]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-fontSize")
				if (params["reset"])
					src.font_size = initial(src.font_size)
					return TRUE
				else
					var/new_font_size = tgui_input_number(usr, "Desired font size (in percent):", "Font setting", src.font_size || 100, 200, 1)
					if (!isnull(new_font_size))
						src.font_size = new_font_size
						src.profile_modified = TRUE
						return TRUE

			if ("update-seeMentorPms")
				src.see_mentor_pms = !src.see_mentor_pms
				src.profile_modified = TRUE
				return TRUE

			if ("update-listenOoc")
				usr.client.toggle_ooc(!src.listen_ooc)
				src.profile_modified = TRUE
				return TRUE

			if ("update-listenLooc")
				usr.client.toggle_looc(!src.listen_looc)
				src.profile_modified = TRUE
				return TRUE

			if ("update-flyingChatHidden")
				src.flying_chat_hidden = !src.flying_chat_hidden
				src.profile_modified = TRUE
				return TRUE

			if ("update-autoCapitalization")
				src.auto_capitalization = !src.auto_capitalization
				src.profile_modified = TRUE
				return TRUE

			if ("update-localDeadchat")
				src.local_deadchat = !src.local_deadchat
				src.profile_modified = TRUE
				return TRUE

			if ("update-hudTheme")
				var/new_hud = tgui_input_list(usr, "Please select a HUD style:", "New", hud_style_selection)
				if (new_hud)
					src.hud_style = new_hud
					src.profile_modified = TRUE
					return TRUE

			if ("update-targetingCursor")
				var/new_cursor = tgui_input_list(usr, "Please select a cursor:", "Cursor", cursors_selection)
				if (new_cursor)
					src.target_cursor = new_cursor
					src.profile_modified = TRUE
					return TRUE

			if ("update-tooltipOption")
				if (params["value"] == TOOLTIP_ALWAYS || params["value"] == TOOLTIP_ALT || params["value"] == TOOLTIP_NEVER)
					src.tooltip_option = params["value"]
					src.profile_modified = TRUE
					return TRUE

			if ("update-scrollWheelTargeting")
				if (params["value"] == SCROLL_TARGET_ALWAYS || params["value"] == SCROLL_TARGET_HOVER || params["value"] == SCROLL_TARGET_NEVER)
					src.scrollwheel_limb_targeting = params["value"]
					src.profile_modified = TRUE
					return TRUE

			if ("update-tguiFancy")
				src.tgui_fancy = !src.tgui_fancy
				src.profile_modified = TRUE
				return TRUE

			if ("update-tguiLock")
				src.tgui_lock = !src.tgui_lock
				src.profile_modified = TRUE
				return TRUE

			if ("update-viewChangelog")
				src.view_changelog = !src.view_changelog
				src.profile_modified = TRUE
				return TRUE

			if ("update-viewScore")
				src.view_score = !src.view_score
				src.profile_modified = TRUE
				return TRUE

			if ("update-viewTickets")
				src.view_tickets = !src.view_tickets
				src.profile_modified = TRUE
				return TRUE

			if ("update-useClickBuffer")
				src.use_click_buffer = !src.use_click_buffer
				src.profile_modified = TRUE
				return TRUE

			if ("update-helpTextInExamine")
				src.help_text_in_examine = !src.help_text_in_examine
				src.profile_modified = TRUE
				return TRUE

			if ("update-useWasd")
				src.use_wasd = !src.use_wasd
				src.profile_modified = TRUE
				return TRUE

			if ("update-useAzerty")
				src.use_azerty = !src.use_azerty
				src.profile_modified = TRUE
				return TRUE

			if ("update-preferredMap")
				src.preferred_map = mapSwitcher.clientSelectMap(usr.client, pickable=TRUE)
				src.profile_modified = TRUE
				return TRUE

			if ("select-trait")
				src.profile_modified = src.traitPreferences.selectTrait(params["id"], src.custom_parts)
				return TRUE

			if ("unselect-trait")
				src.profile_modified = src.traitPreferences.unselectTrait(params["id"], src.custom_parts)
				return TRUE

			if ("reset-traits")
				src.traitPreferences.resetTraits()
				src.profile_modified = TRUE
				return TRUE

			if ("pick_part")
				var/list/options = list()
				for (var/part_id in part_customizations)
					var/datum/part_customization/customization = part_customizations[part_id]
					if (customization.slot == params["slot_id"])
						var/option_string = "[customization.get_name()]"
						if (customization.trait_cost)
							option_string += " ([customization.trait_cost] trait point[customization.trait_cost > 1 ? "s" : ""])"
						options[option_string] = customization.id
				src.traitPreferences.traitDataDirty = TRUE
				var/result = tgui_input_list(usr, "Select custom part", "Pick part", options)
				if (!result)
					return FALSE
				var/list/new_custom_parts = src.custom_parts.Copy()
				new_custom_parts[params["slot_id"]] = options[result] //this is kind of unsafe
				if (!src.traitPreferences.isValid(src.traitPreferences.traits_selected, new_custom_parts))
					boutput(usr, SPAN_ALERT("Cannot afford trait cost"))
					return FALSE
				var/datum/part_customization/customization = get_part_customization(options[result])
				if (!customization.can_apply(src.preview.preview_thing, new_custom_parts))
					boutput(usr, SPAN_ALERT("Unable to equip part"))
					return FALSE
				src.custom_parts = new_custom_parts
				src.profile_modified = TRUE
				src.update_preview_icon()
				return TRUE

			if ("reset")
				src.profile_modified = TRUE

				src.gender = MALE
				src.AH.gender = MALE
				src.randomize_name()

				src.AH.customizations["hair_bottom"].style = new /datum/customization_style/hair/short/short
				src.AH.customizations["hair_middle"].style = new /datum/customization_style/none
				src.AH.customizations["hair_top"].style = new /datum/customization_style/none
				src.AH.underwear = "No Underwear"

				src.AH.customizations["hair_bottom"].color = initial(src.AH.customizations["hair_bottom"].color)
				src.AH.customizations["hair_middle"].color = initial(src.AH.customizations["hair_middle"].color)
				src.AH.customizations["hair_top"].color = initial(src.AH.customizations["hair_top"].color)
				src.AH.e_color = "#101010"
				src.AH.u_color = "#FEFEFE"

				src.AH.s_tone = "#FAD7D0"
				src.AH.s_tone_original = "#FAD7D0"

				src.age = 30
				src.pin = null
				src.flavor_text = null
				src.ResetAllPrefsToLow(usr)
				src.flying_chat_hidden = FALSE
				src.local_deadchat = FALSE
				src.auto_capitalization = FALSE
				usr.client.toggle_ooc(TRUE)
				src.view_changelog = TRUE
				src.view_score = TRUE
				src.view_tickets = TRUE
				src.admin_music_volume = 50
				src.radio_music_volume = 50
				src.use_click_buffer = FALSE
				src.help_text_in_examine = TRUE
				src.be_traitor = FALSE
				src.be_syndicate = FALSE
				src.be_syndicate_commander = FALSE
				src.be_spy = FALSE
				src.be_gangleader = FALSE
				src.be_gangmember = FALSE
				src.be_revhead = FALSE
				src.be_changeling = FALSE
				src.be_wizard = FALSE
				src.be_werewolf = FALSE
				src.be_vampire = FALSE
				src.be_wraith = FALSE
				src.be_blob = FALSE
				src.be_conspirator = FALSE
				src.be_flock = FALSE
				src.be_mindeater = FALSE
				src.be_misc = FALSE
				src.tooltip_option = TOOLTIP_ALWAYS
				src.scrollwheel_limb_targeting = SCROLL_TARGET_ALWAYS
				src.tgui_fancy = TRUE
				src.tgui_lock = FALSE
				src.PDAcolor = "#6F7961"
				src.pda_ringtone_index = "Two-Beep"
				src.be_random_name = force_random_names
				src.be_random_look = force_random_looks
				src.blType = "A+"
				src.update_preview_icon()
				return TRUE

#ifndef SECRETS_ENABLED
#define CHAR_EXPORT_SECRET "input_validation_is_hell_sorry"
#endif

	proc/profile_export()
		var/savefile/message = src.savefile_save(usr.ckey, 1, 1)
		var/fname
		message["1_profile_name"] >> fname
		fname = "[usr.ckey]_[fname].sav"
		if(fexists(fname))
			fdel(fname)
		var/F = file(fname)
		message["hash"] << null
		var/hash = sha1("[sha1(message.ExportText("/"))][usr.ckey][CHAR_EXPORT_SECRET]")
		message["hash"] << hash
		message.ExportText("/", F)
		usr << ftp(F, fname)
		SPAWN(15 SECONDS)
			var/tries = 0
			while((fdel(fname) == 0) && tries++ < 10)
				sleep(30 SECONDS)

	proc/profile_import()
		var/F = input(usr) as file|null
		if(!F)
			return
		var/savefile/message = new()
		message.ImportText("/", file2text(F))
		var/hash
		message["hash"] >> hash
		message["hash"] << null
		if(hash == sha1("[sha1(message.ExportText("/"))][usr.ckey][CHAR_EXPORT_SECRET]"))
			var/profilenum_old = profile_number
			savefile_load(usr.client, 1, message)
			src.profile_modified = TRUE
			src.profile_number = profilenum_old
			src.traitPreferences.traitDataDirty = TRUE


	proc/preview_sound(var/sound/S)
		// tgui kinda adds the ability to spam stuff very fast. This just limits people to spam sound previews.
		if (!ON_COOLDOWN(usr, "preferences_preview_sound", 0.5 SECONDS))
			usr.playsound_local(usr, S, 100)

	proc/randomize_name(first = TRUE, middle = TRUE, last = TRUE)
		if (src.gender == MALE)
			if (first)
				src.name_first = capitalize(pick_string_autokey("names/first_male.txt"))
			if (middle)
				src.name_middle = capitalize(pick_string_autokey("names/first_male.txt"))
		else
			if (first)
				src.name_first = capitalize(pick_string_autokey("names/first_female.txt"))
			if (middle)
				src.name_middle = capitalize(pick_string_autokey("names/first_female.txt"))
		if (last)
			src.name_last = capitalize(pick_string_autokey("names/last.txt"))
		src.set_real_name()

	proc/randomizeLook() // im laze
		if (!src.AH)
			logTheThing(LOG_DEBUG, usr ? usr : null, null, "a preference datum's appearence holder is null!")
			return
		randomize_look(src.AH, 0, 0, 0, 0, 0, 0) // keep gender/bloodtype/age/name/underwear/bioeffects
		if (prob(1))
			blType = "Zesty Ranch"
		src.update_preview_icon()

	proc/sanitize_name()
		src.name_first = remove_bad_name_characters(src.name_first)
		src.name_middle = remove_bad_name_characters(src.name_middle)
		src.name_last = remove_bad_name_characters(src.name_last)

		if (length(src.name_first) < NAME_CHAR_MIN || length(src.name_first) > NAME_CHAR_MAX || is_blank_string(src.name_first) || !character_name_validation.Find(src.name_first))
			src.randomize_name(1, 0, 0)

		if (length(src.name_middle) > NAME_CHAR_MAX)
			src.randomize_name(0, 1, 0)

		if (length(src.name_last) < NAME_CHAR_MIN || length(src.name_last) > NAME_CHAR_MAX || is_blank_string(src.name_last) || !character_name_validation.Find(src.name_last))
			src.randomize_name(0, 0, 1)

		src.set_real_name()

	proc/set_real_name()
		if (!src.name_middle)
			src.real_name = src.name_first + (!src.hyphenate_name ? " " : "-") + src.name_last
		else
			src.real_name = src.name_first + (!src.hyphenate_name ? " " : "-[src.name_middle]-") + src.name_last


	proc/update_preview_icon()
		if (!src.AH)
			logTheThing(LOG_DEBUG, usr ? usr : null, null, "a preference datum's appearence holder is null!")
			return
		if (!src.preview)
			return

		var/datum/mutantrace/mutantRace = /datum/mutantrace/human
		for (var/trait_id in src.traitPreferences.traits_selected)
			var/datum/trait/T = getTraitById(trait_id)
			if (T?.mutantRace)
				mutantRace = T.mutantRace
				break

		var/mob/living/carbon/human/H = src.preview.preview_thing
		src.AH.mutant_race = mutantRace
		var/s_orig = src.AH.s_tone_original
		if (src.traitPreferences.traits_selected.Find("mutant_hair") && mutantRace)
			H.hair_override = TRUE
		else
			H.hair_override = FALSE
		src.preview?.update_appearance(src.AH, mutantRace, src.spessman_direction, name = src.real_name)
		src.AH.s_tone_original = s_orig // refuse any edits made by mutantrace setting/etc
		// bald trait preview stuff
		var/ourWig = H.head
		if (ourWig)
			H.u_equip(ourWig)
			qdel(ourWig)

		if (src.traitPreferences.traits_selected.Find("bald") && mutantRace)
			H.equip_if_possible(H.create_wig(keep_hair = TRUE), SLOT_HEAD)

		for (var/slot_id in src.custom_parts)
			var/datum/part_customization/customization = get_part_customization(src.custom_parts[slot_id])
			customization.try_apply(H, src.custom_parts)
		H.update_icons_if_needed()

	proc/ShowChoices(mob/user)
		src.ui_interact(user)

	proc/ResetAllPrefsToMed(mob/user)
		src.job_favorite = null
		src.jobs_med_priority = list()
		src.jobs_low_priority = list()
		src.jobs_unwanted = list()
		for (var/datum/job/J in job_controls.staple_jobs)
			if (jobban_isbanned(user, J.name) || (J.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J.requires_whitelist && !NT.Find(ckey(user.mind.key))))
				src.jobs_unwanted += J.name
				continue
			if (user.client && !J.has_rounds_needed(user.client.player))
				src.jobs_unwanted += J.name
				continue
			src.jobs_med_priority += J.name
		return

	proc/ResetAllPrefsToLow(mob/user)
		src.job_favorite = null
		src.jobs_med_priority = list()
		src.jobs_low_priority = list()
		src.jobs_unwanted = list()
		for (var/datum/job/J in job_controls.staple_jobs)
			if (jobban_isbanned(user,J.name) || (J.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J.requires_whitelist && !NT.Find(ckey(user.mind.key))))
				src.jobs_unwanted += J.name
				continue
			if (user.client && !J.has_rounds_needed(user.client.player))
				src.jobs_unwanted += J.name
				continue
			src.jobs_low_priority += J.name
		return

	proc/ResetAllPrefsToUnwanted(mob/user)
		src.job_favorite = null
		src.jobs_med_priority = list()
		src.jobs_low_priority = list()
		src.jobs_unwanted = list()
		for (var/datum/job/J in job_controls.staple_jobs)
			if (J.cant_allocate_unwanted)
				src.jobs_low_priority += J.name
			else
				src.jobs_unwanted += J.name
		return

	proc/ResetAllPrefsToDefault(mob/user)
		src.job_favorite = null
		src.jobs_med_priority = list()
		src.jobs_low_priority = list()
		src.jobs_unwanted = list()
		for (var/datum/job/J in job_controls.staple_jobs)
			if (jobban_isbanned(user,J.name) || (J.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J.requires_whitelist && !NT.Find(user.ckey || ckey(user.mind?.key))) || istype(J, /datum/job/command) || istype(J, /datum/job/civilian/AI) || istype(J, /datum/job/civilian/cyborg) || istype(J, /datum/job/security/security_officer))
				src.jobs_unwanted += J.name
				continue
			if (user.client && !J.has_rounds_needed(user.client.player))
				src.jobs_unwanted += J.name
				continue
			src.jobs_low_priority += J.name
		return

	proc/SetChoices(mob/user)
		if (isnull(src.jobs_med_priority) || isnull(src.jobs_low_priority) || isnull(src.jobs_unwanted))
			src.ResetAllPrefsToDefault(user)
			boutput(user, SPAN_ALERT("<b>Your Job Preferences were null, and have been reset.</b>"))
		else if (isnull(src.job_favorite) && !src.jobs_med_priority.len && !src.jobs_low_priority.len && !length(src.jobs_unwanted))
			src.ResetAllPrefsToDefault(user)
			boutput(user, SPAN_ALERT("<b>Your Job Preferences were empty, and have been reset.</b>"))
		else
			// remove/replace jobs that were removed/renamed
			for (var/job in removed_jobs)
				if (job in src.jobs_med_priority)
					src.jobs_med_priority -= job
					if (removed_jobs[job])
						src.jobs_med_priority |= removed_jobs[job]
				if (job in src.jobs_low_priority)
					src.jobs_low_priority -= job
					if (removed_jobs[job])
						src.jobs_low_priority |= removed_jobs[job]
				if (job in src.jobs_unwanted)
					src.jobs_unwanted -= job
					if (removed_jobs[job])
						src.jobs_unwanted |= removed_jobs[job]
			// add missing jobs

//pod wars only special jobs
#if defined(MAP_OVERRIDE_POD_WARS)
			for (var/datum/job/J in job_controls.special_jobs)
				if (istype(J, /datum/job/special/pod_wars))
					if (src.job_favorite != J.name && !(J.name in src.jobs_med_priority) && !(J.name in src.jobs_low_priority))
						if (J.cant_allocate_unwanted)
							src.jobs_low_priority |= J.name
						else
							src.jobs_unwanted |= J.name
#else
			for (var/datum/job/J in job_controls.staple_jobs)
				if (src.job_favorite != J.name && !(J.name in src.jobs_med_priority) && !(J.name in src.jobs_low_priority))
					src.jobs_unwanted |= J.name
#endif

			// remove duplicate jobs
			var/list/seen_jobs = list()
			if (src.job_favorite)
				seen_jobs[src.job_favorite] = TRUE
			for (var/J in src.jobs_med_priority)
				if (seen_jobs[J])
					src.jobs_med_priority.Remove(J)
				else
					seen_jobs[J] = TRUE
			for (var/J in src.jobs_low_priority)
				if (seen_jobs[J])
					src.jobs_low_priority.Remove(J)
				else
					seen_jobs[J] = TRUE
			for (var/J in src.jobs_unwanted)
				if (seen_jobs[J])
					src.jobs_unwanted.Remove(J)
				else
					seen_jobs[J] = TRUE


		var/list/HTML = list()

		HTML += {"<title>Job Preferences</title>
<style type="text/css">
	.jobtable {
		margin-top: 0.3em;
		width: 100%;
		}
	.jobtable td, th {
		vertical-align: top;
		text-align: center;
		width: 25%;
		margin: 0;
		padding: 0.1em 0.5em;
		}
	.jobtable td + td {
		border-left: 1px solid black;
		}
	.jobtable td div {
		margin-bottom: 3px;
		text-align: center;
		position: relative;
		padding: 0 1.2em;
		border: 1px solid rgba(128, 128, 128, 0.5);
		}
	.jobtable td a {
		text-decoration: none;
		}
	.jobtable td div a.job {
		width: 100%;
		display: inline-block;
		text-align: center;
		background: rgba(128, 128, 128, 0.05);
	}
	.jobtable td div .arrow {
		position: absolute;
		top: 0;
		bottom: 0;
		width: 1em;
		text-align: center;
		background: rgba(128, 128, 128, 0.3);
		}

	.jobtable td div .arrow:hover {
		background: rgba(128, 128, 128, 0.5);
		}
	.jobtable td div a.job:hover {
		background: rgba(128, 128, 128, 0.15);
		}
	.info-thing {
		background: rgba(128, 128, 255, 0.4);
		color: rgba(255, 255, 255, 0.8);
		margin-left: 0.5em;
		display: inline-block;
		text-align: center;
		font-size: 80%;
		font-weight: bold;
		min-width: 1.2em;
		min-height: 1.2em;
		border-radius: 100%;
		position: relative;
		top: -1px;
		cursor: help;
		}
	.antagprefs a {
		display: block;
		text-align: left;
		margin-bottom: 0.2em;
		text-decoration: none;
		}
	.antagprefs a.yup {
		color: #ff4444;
		}
	.antagprefs a.nope {
		color: inherit;
		}
</style>

<div style="float: right;">
	<a href="byond://?src=\ref[src];preferences=1;closejobswindow=1">Back to Setup</a> &bull;
	<a href="byond://?src=\ref[src];preferences=1;jobswindow=1">Refresh</a> &bull;
	<a href="byond://?src=\ref[src];preferences=1;resetalljobs=1"><b>Reset All Jobs</b></a>
</div>
		"}

		// this still sucks but at least the rest is slightly less awful

		HTML += "<b>Favorite Job</b><span class='info-thing' title=\"This is for the one job you like the most - the game will always try to get you into this job first if it can. You might not always get your favorite job, especially if it's a single-slot role like a Head, but don't be discouraged if you don't get it - it's just luck of the draw. You might get it next time.\">?</span>:"
		if (!src.job_favorite)
			HTML += " None"
		else
			var/print_the_job = FALSE
			var/datum/job/J_Fav = src.job_favorite ? find_job_in_controller_by_string(src.job_favorite) : null
			if (!J_Fav)
				HTML += " Favorite Job not found!"
			else if (jobban_isbanned(user,J_Fav.name) || (J_Fav.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J_Fav.requires_whitelist && !NT.Find(ckey(user.mind.key))))
				boutput(user, SPAN_ALERT("<b>You are no longer allowed to play [J_Fav.name]. It has been removed from your Favorite slot.</b>"))
				src.jobs_unwanted += J_Fav.name
				src.job_favorite = null
			else if (J_Fav.rounds_needed_to_play && (user.client && user.client.player))
				if (!J_Fav.has_rounds_needed(user.client.player))
					var/played_rounds = user.client.player.get_rounds_participated()
					var/needed_rounds = J_Fav.rounds_needed_to_play
					var/allowed_rounds = J_Fav.rounds_allowed_to_play
					var/reason_msg = ""
					if (allowed_rounds && !needed_rounds)
						reason_msg =  "You've already played </b>[played_rounds]</b> rounds, but this job has a cap of <b>[allowed_rounds] allowed rounds. You should be experienced enough!</b>"
					else if (needed_rounds)
						reason_msg =  "You've only played </b>[played_rounds]</b> rounds and need to play <b>[needed_rounds].</b>"
					boutput(user, SPAN_ALERT("<b>You cannot play [J_Fav.name].</b> [reason_msg]"))
					src.jobs_unwanted += J_Fav.name
					src.job_favorite = null
				else
					print_the_job = TRUE
			else
				print_the_job = TRUE
			if (print_the_job)
				HTML += " <a href=\"byond://?src=\ref[src];preferences=1;occ=1;job=[J_Fav.name];level=0\" style='font-weight: bold; color: [J_Fav.linkcolor];'>[J_Fav.name]</a>"

		HTML += {"
	<table class='jobtable'>
		<tr>
			<th>Medium Priority <span class="info-thing" title="Medium Priority Jobs are any jobs you would like to play that aren't your favorite. People with jobs in this category get priority over those who have the same job in their low priority bracket. It's best to put jobs here that you actively enjoy playing and wouldn't mind ending up with if you don't get your favorite.">?</span></th>
			<th>Low Priority <span class="info-thing" title="Low Priority Jobs are jobs that you don't mind doing. When the game is finding candidates for a job, it will try to fill it with Medium Priority players first, then Low Priority players if there are still free slots.">?</span></th>
			<th>Unwanted Jobs <span class="info-thing" title="Unwanted Jobs are jobs that you absolutely don't want to have. The game will never give you a job you list here. The 'Staff Assistant' role can't be put here, however, as it's the fallback job if there are no other openings.">?</span></th>
			<th>Antagonist Roles <span class="info-thing" title="Antagonist roles are randomly chosen when the game starts, before jobs have been allocated. Leaving an antagonist role unchecked means you will never be chosen for it automatically.">?</span></th>
		</tr>
		<tr>"}

		var/list/jerbs = list(medium = src.jobs_med_priority, low = src.jobs_low_priority, unwanted = src.jobs_unwanted)

		for (var/cat in jerbs)
			var/level = 0
			switch (cat)
				if ("medium")
					level = 2
				if ("low")
					level = 3
				if ("unwanted")
					level = 4

			HTML += "<td valign='top'>"

			for (var/J in jerbs[cat])
				var/datum/job/JD = find_job_in_controller_by_string(J)

				if (!JD)
					continue
				if (JD.needs_college && !user.has_medal("Unlike the director, I went to college"))
					continue
				if (JD.requires_whitelist && !NT.Find(user.ckey))
					continue
				if (jobban_isbanned(user, JD.name))
					if (cat != "unwanted")
						jerbs[cat] -= JD.name
						jerbs["unwanted"] += JD.name
					else
						HTML += {"
						<div>
							<s style="color: #888888;">[JD.name]</s>
						</div>
						"}
					continue

				if (cat == "unwanted" && JD.cant_allocate_unwanted)
					boutput(user, SPAN_ALERT("<b>[JD.name] is not supposed to be in the Unwanted category. It has been moved to Low Priority.</b> You may need to refresh your job preferences page to correct the job count."))
					src.jobs_unwanted -= JD.name
					src.jobs_low_priority += JD.name

				var/hover_text = JD.short_description

				HTML += {"
				<div>
					<a href="byond://?src=\ref[src];preferences=1;occ=[level];job=[JD.name];level=[level - 1]" class="arrow" style="left: 0;">&lt;</a>
					[level < (4 - (JD.cant_allocate_unwanted ? 1 : 0)) ? {"<a href="byond://?src=\ref[src];preferences=1;occ=[level];job=[JD.name];level=[level + 1]" class="arrow" style="right: 0;">&gt;</a>"} : ""]
					<a href="byond://?src=\ref[src];preferences=1;occ=[level];job=[JD.name];level=0" class="job" style="color: [JD.linkcolor];[istype(JD, /datum/job/civilian/clown) ? "font-family: Comic Sans MS;" : ""]" title="[hover_text]">
					[JD.name]</a>
				</div>
				"}

			HTML += "</td>"

		HTML += "<td valign='top' class='antagprefs'>"
#ifdef LIVE_SERVER
		if ((user?.client?.player.get_rounds_participated() < TEAM_BASED_ROUND_REQUIREMENT) && !user?.client?.player.cloudSaves.getData("bypass_round_reqs"))
			HTML += "You need to play at least [TEAM_BASED_ROUND_REQUIREMENT] rounds to play group-based antagonists."
			src.be_syndicate = FALSE
			src.be_syndicate_commander = FALSE
			src.be_gangleader = FALSE
			src.be_gangmember = FALSE
			src.be_revhead = FALSE
			src.be_conspirator = FALSE
#endif
		if (jobban_isbanned(user, "Syndicate"))
			HTML += "You are banned from playing antagonist roles."
			src.be_traitor = FALSE
			src.be_syndicate = FALSE
			src.be_syndicate_commander = FALSE
			src.be_spy = FALSE
			src.be_gangleader = FALSE
			src.be_gangmember = FALSE
			src.be_revhead = FALSE
			src.be_changeling = FALSE
			src.be_wizard = FALSE
			src.be_werewolf = FALSE
			src.be_vampire = FALSE
			src.be_arcfiend = FALSE
			src.be_salvager = FALSE
			src.be_wraith = FALSE
			src.be_blob = FALSE
			src.be_conspirator = FALSE
			src.be_flock = FALSE
			src.be_mindeater = FALSE
		else

			HTML += {"
			<a href="byond://?src=\ref[src];preferences=1;b_traitor=1" class="[src.be_traitor ? "yup" : "nope"]">[crap_checkbox(src.be_traitor)] Traitor</a>
			<a href="byond://?src=\ref[src];preferences=1;b_syndicate=1" class="[src.be_syndicate ? "yup" : "nope"]">[crap_checkbox(src.be_syndicate)] Nuclear Operative</a>
			<a href="byond://?src=\ref[src];preferences=1;b_syndicate_commander=1" class="[src.be_syndicate_commander ? "yup" : "nope"]">[crap_checkbox(src.be_syndicate_commander)] Nuclear Operative Commander</a>
			<a href="byond://?src=\ref[src];preferences=1;b_spy=1" class="[src.be_spy ? "yup" : "nope"]">[crap_checkbox(src.be_spy)] Spy/Thief</a>
			<a href="byond://?src=\ref[src];preferences=1;b_gangleader=1" class="[src.be_gangleader ? "yup" : "nope"]">[crap_checkbox(src.be_gangleader)] Gang Leader</a>
			<a href="byond://?src=\ref[src];preferences=1;b_gangmember=1" class="[src.be_gangmember ? "yup" : "nope"]">[crap_checkbox(src.be_gangmember)] Gang Member</a>
			<a href="byond://?src=\ref[src];preferences=1;b_revhead=1" class="[src.be_revhead ? "yup" : "nope"]">[crap_checkbox(src.be_revhead)] Revolution Leader</a>
			<a href="byond://?src=\ref[src];preferences=1;b_changeling=1" class="[src.be_changeling ? "yup" : "nope"]">[crap_checkbox(src.be_changeling)] Changeling</a>
			<a href="byond://?src=\ref[src];preferences=1;b_wizard=1" class="[src.be_wizard ? "yup" : "nope"]">[crap_checkbox(src.be_wizard)] Wizard</a>
			<a href="byond://?src=\ref[src];preferences=1;b_werewolf=1" class="[src.be_werewolf ? "yup" : "nope"]">[crap_checkbox(src.be_werewolf)] Werewolf</a>
			<a href="byond://?src=\ref[src];preferences=1;b_vampire=1" class="[src.be_vampire ? "yup" : "nope"]">[crap_checkbox(src.be_vampire)] Vampire</a>
			<a href="byond://?src=\ref[src];preferences=1;b_arcfiend=1" class="[src.be_arcfiend ? "yup" : "nope"]">[crap_checkbox(src.be_arcfiend)] Arcfiend</a>
			<a href="byond://?src=\ref[src];preferences=1;b_wraith=1" class="[src.be_wraith ? "yup" : "nope"]">[crap_checkbox(src.be_wraith)] Wraith</a>
			<a href="byond://?src=\ref[src];preferences=1;b_blob=1" class="[src.be_blob ? "yup" : "nope"]">[crap_checkbox(src.be_blob)] Blob</a>
			<a href="byond://?src=\ref[src];preferences=1;b_conspirator=1" class="[src.be_conspirator ? "yup" : "nope"]">[crap_checkbox(src.be_conspirator)] Conspirator</a>
			<a href="byond://?src=\ref[src];preferences=1;b_flock=1" class="[src.be_flock ? "yup" : "nope"]">[crap_checkbox(src.be_flock)] Flockmind</a>
			<a href="byond://?src=\ref[src];preferences=1;b_salvager=1" class="[src.be_salvager ? "yup" : "nope"]">[crap_checkbox(src.be_salvager)] Salvager</a>
			<a href="byond://?src=\ref[src];preferences=1;b_mindeater=1" class="[src.be_mindeater ? "yup" : "nope"]">[crap_checkbox(src.be_mindeater)] Mindeater</a>
			<a href="byond://?src=\ref[src];preferences=1;b_misc=1" class="[src.be_misc ? "yup" : "nope"]">[crap_checkbox(src.be_misc)] Other Foes</a>
		"}

		HTML += {"</td></tr></table>"}

		user.Browse(null, "window=preferences")
		user.Browse(HTML.Join(), "window=mob_occupation;size=850x580")
		return

	proc/SetJob(mob/user, occ=1, job="Captain", level = 0)
		if (src.antispam)
			return
		switch (occ)
			if (1)
				if (src.job_favorite != job)
					return
			if (2)
				if (!(job in src.jobs_med_priority))
					return
			if (3)
				if (!(job in src.jobs_low_priority))
					return
			if (4)
				if (!(job in src.jobs_unwanted))
					return
			else
				return
				//
		//works for now, maybe move this to something on game mode to decide proper jobs... -kyle
#if defined(MAP_OVERRIDE_POD_WARS)
		if (!find_job_in_controller_by_string(job,0,TRUE))
#else
		if (!find_job_in_controller_by_string(job,1,TRUE))
#endif
			boutput(user, SPAN_ALERT("<b>The game could not find that job in the internal list of jobs.</b>"))
			switch (occ)
				if (1) src.job_favorite = null
				if (2) src.jobs_med_priority -= job
				if (3) src.jobs_low_priority -= job
				if (4) src.jobs_unwanted -= job
			return
		if (job=="AI" && (!config.allow_ai))
			boutput(user, SPAN_ALERT("<b>Selecting the AI is not currently allowed.</b>"))
			if (occ != 4)
				switch (occ)
					if (1) src.job_favorite = null
					if (2) src.jobs_med_priority -= job
					if (3) src.jobs_low_priority -= job
				src.jobs_unwanted += job
			return

		if (jobban_isbanned(user, job))
			boutput(user, SPAN_ALERT("<b>You are banned from this job and may not select it.</b>"))
			if (occ != 4)
				switch (occ)
					if (1) src.job_favorite = null
					if (2) src.jobs_med_priority -= job
					if (3) src.jobs_low_priority -= job
				src.jobs_unwanted += job
			return

//pod wars only special jobs
#if defined(MAP_OVERRIDE_POD_WARS)
		var/datum/job/temp_job = find_job_in_controller_by_string(job,0)
#else
		var/datum/job/temp_job = find_job_in_controller_by_string(job,1)
#endif
		if (user.client && !temp_job.has_rounds_needed(user.client.player))
			var/played_rounds = user.client.player.get_rounds_participated()
			var/needed_rounds = temp_job.rounds_needed_to_play
			var/allowed_rounds = temp_job.rounds_allowed_to_play
			var/reason_msg = ""
			if (allowed_rounds && !needed_rounds)
				reason_msg =  "You've already played </b>[played_rounds]</b> rounds, but this job has a cap of <b>[allowed_rounds] allowed rounds. You should be experienced enough!</b>"
			else if (needed_rounds)
				reason_msg =  "You've only played </b>[played_rounds]</b> rounds and need to play <b>[needed_rounds].</b>"
			boutput(user, SPAN_ALERT("<b>You cannot play [temp_job.name].</b> [reason_msg]"))
			if (occ != 4)
				switch (occ)
					if (1) src.job_favorite = null
					if (2) src.jobs_med_priority -= job
					if (3) src.jobs_low_priority -= job
				src.jobs_unwanted += job
			return

		src.antispam = TRUE

		var/picker = "Low Priority"
		var/datum/job/J = find_job_in_controller_by_string(job)
		if (level == 0)
			var/list/valid_actions = list("Favorite", "Medium Priority", "Low Priority", "Unwanted")
			if (J.wiki_link)
				valid_actions += "Show Wiki Page"

			switch (occ)
				if (1) valid_actions -= "Favorite"
				if (2) valid_actions -= "Medium Priority"
				if (3) valid_actions -= "Low Priority"
				if (4) valid_actions -= "Unwanted"

			picker = tgui_input_list(usr, "Which bracket would you like to move this job to?", "Job Preferences", valid_actions)
			if (!picker)
				src.antispam = FALSE
				return
		else
			switch (level)
				if (1) picker = "Favorite"
				if (2) picker = "Medium Priority"
				if (3) picker = "Low Priority"
				if (4) picker = "Unwanted"

		if (J.cant_allocate_unwanted && picker == "Unwanted")
			boutput(user, SPAN_ALERT("<b>[job] cannot be set to Unwanted.</b>"))
			src.antispam = FALSE
			return

		var/successful_move = FALSE

		switch (picker)
			if ("Favorite")
				if (src.job_favorite)
					src.jobs_med_priority += src.job_favorite
				src.job_favorite = job
				successful_move = TRUE
			if ("Medium Priority")
				src.jobs_med_priority += job
				if (occ == 1)
					src.job_favorite = null
				successful_move = TRUE
			if ("Low Priority")
				src.jobs_low_priority += job
				if (occ == 1)
					src.job_favorite = null
				successful_move = TRUE
			if ("Unwanted")
				src.jobs_unwanted += job
				if (occ == 1)
					src.job_favorite = null
				successful_move = TRUE
			if ("Show Wiki Page")
				user << link(J.wiki_link)

		if (successful_move)
			switch (occ)
				// i know, repetitive, but its the safest way i can think of right now
				if (2) src.jobs_med_priority -= job
				if (3) src.jobs_low_priority -= job
				if (4) src.jobs_unwanted -= job

		src.antispam = FALSE
		return 1

	Topic(href, href_list[])
		if (usr?.client?.preferences)
			if (src == usr.client.preferences)
				process_link(usr, href_list)
			else
				boutput(usr, "<h3 class='alert'>Those aren't your prefs!</h3>")
		else
			boutput(usr, "<h3 class='alert'>Something went wrong with preferences. Call a coder.</span>")
		..()

	proc/process_link(mob/user, list/link_tags)
		if (!user.client)
			return

		// do we check if they actually modified something? no.
		// thats effort.
		src.profile_modified = TRUE

		if (link_tags["job"])
			src.SetJob(user, text2num(link_tags["occ"]), link_tags["job"], text2num(link_tags["level"]))
			src.SetChoices(user)
			return

		if (link_tags["jobswindow"])
			src.SetChoices(user)
			return

		if (link_tags["closejobswindow"])
			user.Browse(null, "window=mob_occupation")
			src.ShowChoices(user)
			return

		if (link_tags["resetalljobs"])
			var/resetwhat = tgui_input_list(user, "Reset all jobs to which level?", "Job Preferences", list("Medium Priority", "Low Priority", "Unwanted"))
			switch (resetwhat)
				if ("Medium Priority")
					src.ResetAllPrefsToMed(user)
				if ("Low Priority")
					src.ResetAllPrefsToLow(user)
				if ("Unwanted")
					src.ResetAllPrefsToUnwanted(user)
				else
					return
			src.SetChoices(user)
			return

		if (link_tags["b_traitor"])
			src.be_traitor = !src.be_traitor
			src.SetChoices(user)
			return

		if (link_tags["b_syndicate"])
			src.be_syndicate = !src.be_syndicate
			src.SetChoices(user)
			return

		if (link_tags["b_syndicate_commander"])
			src.be_syndicate_commander = !src.be_syndicate_commander
			src.be_syndicate |= src.be_syndicate_commander
			src.SetChoices(user)
			return

		if (link_tags["b_spy"])
			src.be_spy = !src.be_spy
			src.SetChoices(user)
			return

		if (link_tags["b_gangleader"])
			src.be_gangleader = !src.be_gangleader
			src.SetChoices(user)
			return

		if (link_tags["b_gangmember"])
			src.be_gangmember = !src.be_gangmember
			src.SetChoices(user)
			return

		if (link_tags["b_revhead"])
			src.be_revhead = !src.be_revhead
			src.SetChoices(user)
			return

		if (link_tags["b_changeling"])
			src.be_changeling = !src.be_changeling
			src.SetChoices(user)
			return

		if (link_tags["b_wizard"])
			src.be_wizard = !src.be_wizard
			src.SetChoices(user)
			return

		if (link_tags["b_werewolf"])
			src.be_werewolf = !src.be_werewolf
			src.SetChoices(user)
			return

		if (link_tags["b_vampire"])
			src.be_vampire = !src.be_vampire
			src.SetChoices(user)
			return

		if (link_tags["b_arcfiend"])
			src.be_arcfiend = !src.be_arcfiend
			src.SetChoices(user)
			return

		if (link_tags["b_salvager"])
			src.be_salvager = !src.be_salvager
			src.SetChoices(user)
			return

		if (link_tags["b_wraith"])
			src.be_wraith = !src.be_wraith
			src.SetChoices(user)
			return

		if (link_tags["b_blob"])
			src.be_blob = !src.be_blob
			src.SetChoices(user)
			return

		if (link_tags["b_conspirator"])
			src.be_conspirator = !src.be_conspirator
			src.SetChoices(user)
			return

		if (link_tags["b_flock"])
			src.be_flock = !src.be_flock
			src.SetChoices(user)
			return

		if (link_tags["b_mindeater"])
			src.be_mindeater = !src.be_mindeater
			src.SetChoices(user)
			return

		if (link_tags["b_misc"])
			src.be_misc = !src.be_misc
			src.SetChoices(user)
			return

		src.ShowChoices(user)

	proc/copy_to(mob/living/character, mob/user, ignore_randomizer = FALSE, skip_post_new_stuff = FALSE)
		src.sanitize_null_values()
		if (!ignore_randomizer)
			if (src.be_random_name)
				src.randomize_name()

			if (src.be_random_look)
				src.randomizeLook()

			if (character.bioHolder)
				if (src.random_blood)
					character.bioHolder.bloodType = random_blood_type()
				else
					character.bioHolder.bloodType = src.blType

			SPAWN(0) // avoid blocking
				if (jobban_isbanned(user, "Custom Names"))
					src.randomize_name()
					src.randomizeLook()
					character.bioHolder?.bloodType = random_blood_type()
					src.copy_to(character, user, TRUE) // apply the other stuff again but with the random name

		//character.real_name = real_name
		src.set_real_name()
		character.real_name = src.real_name
		phrase_log.log_phrase("name-human", character.real_name, no_duplicates=TRUE)

		//Wire: Not everything has a bioholder you morons
		if (character.bioHolder)
			character.bioHolder.age = age
			character.bioHolder.mobAppearance.CopyOther(src.AH)
			character.bioHolder.mobAppearance.gender = src.gender
			if (!src.be_random_name)
				character.bioHolder.mobAppearance.flavor_text = src.flavor_text

		//Also I think stuff other than human mobs can call this proc jesus christ
		if (ishuman(character))
			var/mob/living/carbon/human/H = character
			H.pin = src.pin
			H.gender = src.gender

		if (!skip_post_new_stuff)
			src.apply_post_new_stuff(character)

		character.update_face()
		character.update_body()

		character.sound_scream = src.AH.screamsounds[src.AH.screamsound || "default"] || src.AH.screamsounds["default"]
		character.sound_fart = src.AH.fartsounds[src.AH.fartsound || "default"] || src.AH.fartsounds["default"]
		character.voice_type = src.AH.voicetype || RANDOM_HUMAN_VOICE

		if (ishuman(character))
			var/mob/living/carbon/human/H = character
			if (H.mutantrace?.voice_override) //yass TODO: find different way of handling this
				H.voice_type = H.mutantrace.voice_override

	proc/apply_post_new_stuff(mob/living/character, var/role_for_traits)
		if (src.traitPreferences.isValid(src.traitPreferences.traits_selected, src.custom_parts) && character.traitHolder)
			character.traitHolder.mind_role_fallback = role_for_traits
			for (var/T in src.traitPreferences.traits_selected)
				character.traitHolder.addTrait(T)
		for (var/slot_id in src.custom_parts)
			var/part_id = src.custom_parts[slot_id]
			var/datum/part_customization/customization = get_part_customization(part_id)
			customization.try_apply(character, src.custom_parts)

	proc/sanitize_null_values()
		if (!src.gender || !(src.gender == MALE || src.gender == FEMALE))
			src.gender = MALE
		if (!src.AH)
			src.AH = new
		if (src.AH.gender != src.gender)
			src.AH.gender = src.gender
		if (src.AH.customizations["hair_bottom"].color == null)
			src.AH.customizations["hair_bottom"].color = "#101010"
		if (src.AH.customizations["hair_bottom"].style == null)
			src.AH.customizations["hair_bottom"].style = new  /datum/customization_style/none
		if (src.AH.customizations["hair_middle"].color == null)
			src.AH.customizations["hair_middle"].color = "#101010"
		if (src.AH.customizations["hair_middle"].style == null)
			src.AH.customizations["hair_middle"].style = new /datum/customization_style/none
		if (src.AH.customizations["hair_top"].color == null)
			src.AH.customizations["hair_top"].color = "#101010"
		if (src.AH.customizations["hair_top"].style == null)
			src.AH.customizations["hair_top"].style = new /datum/customization_style/none
		if (src.AH.e_color == null)
			src.AH.e_color = "#101010"
		if (src.AH.u_color == null)
			src.AH.u_color = "#FEFEFE"
		if (src.AH.s_tone == null || src.AH.s_tone == "#FFFFFF" || src.AH.s_tone == "#ffffff")
			src.AH.s_tone = "#FEFEFE"

	proc/keybind_prefs_updated(var/client/C)
		if (!isclient(C))
			var/mob/M = C
			if (ismob(M) && M.client)
				C = M.client
			else
				boutput(C, "<h3 class='alert'>Something went wrong. Maybe the game isn't done loading yet, give it a minute!</h3>")
				return
		if (C.preferences.use_wasd)
			winset(C, "menu.wasd_controls", "is-checked=true")
		else
			winset(C, "menu.wasd_controls", "is-checked=false")
		C.mob.reset_keymap()

// Generates a real crap checkbox for html toggle links.
// it sucks but it's a bit more readable i guess.
/proc/crap_checkbox(var/checked)
	if (checked) return "&#9745;"
	else return "&#9744;"
