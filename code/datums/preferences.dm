var/list/bad_name_characters = list("_", "'", "\"", "<", ">", ";", "\[", "\]", "{", "}", "|", "\\", "/")
var/list/removed_jobs = list(
	// jobs that have been removed or replaced (replaced -> new name, removed -> null)
	"Barman" = "Bartender",
)

datum/preferences
	var/profile_name
	var/profile_number
	var/profile_modified
	var/real_name
	var/name_first
	var/name_middle
	var/name_last
	var/gender = MALE
	var/age = 30
	var/pin = null
	var/blType = "A+"

	var/flavor_text // I'm gunna regret this aren't I
	// These notes are put in the datacore records on the start of the round
	var/security_note
	var/medical_note
	var/employment_note

	var/be_traitor = 0
	var/be_syndicate = 0
	var/be_spy = 0
	var/be_gangleader = 0
	var/be_revhead = 0
	var/be_changeling = 0
	var/be_wizard = 0
	var/be_werewolf = 0
	var/be_vampire = 0
	var/be_wraith = 0
	var/be_blob = 0
	var/be_conspirator = 0
	var/be_flock = 0
	var/be_misc = 0

	var/be_random_name = 0
	var/be_random_look = 0
	var/random_blood = 0
	var/view_changelog = 1
	var/view_score = 1
	var/view_tickets = 1
	var/admin_music_volume = 50
	var/radio_music_volume = 10
	var/use_click_buffer = 0
	var/listen_ooc = 1
	var/listen_looc = 1
	var/flying_chat_hidden = 0
	var/auto_capitalization = 0
	var/local_deadchat = 0
	var/use_wasd = 1
	var/use_azerty = 0 // do they have an AZERTY keyboard?
	var/spessman_direction = SOUTH
	var/PDAcolor = "#6F7961"

	var/job_favorite = null
	var/list/jobs_med_priority = list()
	var/list/jobs_low_priority = list()
	var/list/jobs_unwanted = list()

	var/pda_ringtone_index = "Two-Beep"

	var/datum/appearanceHolder/AH = new

	var/datum/character_preview/preview = null

	var/mentor = 0
	var/see_mentor_pms = 1 // do they wanna disable mentor pms?
	var/antispam = 0

	var/datum/traitPreferences/traitPreferences = new

	var/target_cursor = "Default"
	var/hud_style = "New"

	var/tgui_fancy = TRUE
	var/tgui_lock = FALSE

	var/tooltip_option = TOOLTIP_ALWAYS

	var/regex/character_name_validation = null //This regex needs to match the name in order to consider it a valid name

	var/preferred_map = ""

	var/font_size = null

	//var/fartsound = "default"
	//var/screamsound = "default"

	New()
		character_name_validation = regex("\\w+") //TODO: Make this regex a bit sturdier (capitalization requirements, character whitelist, etc)
		randomize_name()
		randomizeLook()
		..()

	ui_state(mob/user)
		return tgui_always_state.can_use_topic(src, user)

	ui_status(mob/user, datum/ui_state/state)
		return tgui_always_state.can_use_topic(src, user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "CharacterPreferences")
			ui.set_autoupdate(FALSE)
			ui.open()

	ui_close(mob/user)
		. = ..()
		if (!isnull(src.preview))
			qdel(src.preview)
			src.preview = null

	ui_data(mob/user)
		if (isnull(src.preview))
			src.preview = new(user.client, "preferences", "preferences_character_preview")
			src.preview.add_background("#191919")
			src.update_preview_icon()

		var/client/client = ismob(user) ? user.client : user

		if (!client)
			return

		var/list/profiles = new/list(SAVEFILE_PROFILES_MAX)
		for (var/i = 1, i <= SAVEFILE_PROFILES_MAX, i++)
			profiles[i] = list(
				"active" = i == src.profile_number,
				"name" = src.savefile_get_profile_name(client, i),
			)

		var/list/cloud_saves = null

		if (client.cloud_available())
			cloud_saves = list()
			for (var/name in client.player.cloudsaves)
				cloud_saves += name

		sanitize_null_values()
		user << browse_rsc(icon(cursors_selection[target_cursor]), "tcursor_[src.target_cursor].png")
		user << browse_rsc(icon(hud_style_selection[hud_style], "preview"), "hud_preview_[src.hud_style].png")

		. = list(
			"isMentor" = client.is_mentor(),

			"profiles" = profiles,
			"cloudSaves" = cloud_saves,

			"profileName" = src.profile_name,
			"profileModified" = src.profile_modified,

			"preview" = src.preview.preview_id,

			"nameFirst" = src.name_first,
			"nameMiddle" = src.name_middle,
			"nameLast" = src.name_last,
			"randomName" = src.be_random_name,
			"gender" = (src.gender == MALE ? "Male" : "Female") + " " + (!AH.pronouns ? (src.gender == MALE ? "(he/him)" : "(she/her)") : "(they/them)"),
			"age" = src.age,
			"bloodRandom" = src.random_blood,
			"bloodType" = src.blType,
			"pin" = src.pin,
			"flavorText" = src.flavor_text,
			"securityNote" = src.security_note,
			"medicalNote" = src.medical_note,
			"fartsound" = src.AH.fartsound,
			"screamsound" = src.AH.screamsound,
			"chatsound" = src.AH.voicetype,
			"pdaColor" = src.PDAcolor,
			"pdaRingtone" = src.pda_ringtone_index,
			"skinTone" = src.AH.s_tone,
			"eyeColor" = src.AH.e_color,
			"customColor1" = src.AH.customization_first_color,
			"customStyle1" = src.AH.customization_first,
			"customColor2" = src.AH.customization_second_color,
			"customStyle2" = src.AH.customization_second,
			"customColor3" = src.AH.customization_third_color,
			"customStyle3" = src.AH.customization_third,
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
			"targetingCursor" = src.target_cursor,
			"tooltipOption" = src.tooltip_option,
			"tguiFancy" = src.tgui_fancy,
			"tguiLock" = src.tgui_lock,
			"viewChangelog" = src.view_changelog,
			"viewScore" = src.view_score,
			"viewTickets" = src.view_tickets,
			"useClickBuffer" = src.use_click_buffer,
			"useWasd" = src.use_wasd,
			"useAzerty" = src.use_azerty,
			"preferredMap" = src.preferred_map,
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		var/client/client = ismob(usr) ? usr.client : usr

		switch(action)
			if ("previewSound")
				var/sound_file

				if (params["pdaRingtone"])
					get_all_character_setup_ringtones()
					var/datum/ringtone/RT = selectable_ringtones[src.pda_ringtone_index]
					if(istype(RT) && length(RT.ringList))
						sound_file = RT.ringList[rand(1,length(RT.ringList))]

				if (params["fartsound"])
					sound_file = sound(src.AH.fartsounds[src.AH.fartsound])

				if (params["screamsound"])
					sound_file = sound(src.AH.screamsounds[src.AH.screamsound])

				if (params["chatsound"])
					sound_file = sounds_speak[AH.voicetype]

				if (sound_file)
					preview_sound(sound_file)

				return FALSE

			if ("rotate-clockwise")
				src.spessman_direction = turn(src.spessman_direction, 90)
				update_preview_icon()
				return

			if ("rotate-counter-clockwise")
				src.spessman_direction = turn(src.spessman_direction, -90)
				update_preview_icon()
				return

			if ("open-occupation-window")
				src.SetChoices(usr)
				ui.close()
				return TRUE

			if ("open-traits-window")
				traitPreferences.showTraits(usr)
				ui.close()
				return TRUE

			if ("save")
				var/index = params["index"]
				if (isnull(src.profile_name) || is_blank_string(src.profile_name))
					alert(usr, "You need to give your profile a name.")
					return

				if (!isnull(index) && isnum(index))
					src.savefile_save(client, index)
					src.profile_number = index
					boutput(usr, "<span class='notice'><b>Character saved to Slot [index].</b></span>")
					return TRUE

			if ("load")
				var/index = params["index"]
				if (!isnull(index) && isnum(index))
					if (!src.savefile_load(client, index))
						alert(usr, "You do not have a savefile.")
						return FALSE

					boutput(usr, "<span class='notice'><b>Character loaded from Slot [index].</b></span>")
					update_preview_icon()
					return TRUE

			if ("cloud-new")
				if (!client.cloud_available())
					return
				if(length(client.player.cloudsaves) >= SAVEFILE_CLOUD_PROFILES_MAX)
					alert(usr, "You have hit your cloud save limit. Please write over an existing save.")
				else
					var/new_name = input(usr, "What would you like to name the save?", "Save Name") as null|text
					if(!isnull(new_name) && length(new_name) < 3 || length(new_name) > MOB_NAME_MAX_LENGTH)
						alert(usr, "The name must be between 3 and [MOB_NAME_MAX_LENGTH] letters!")
					else
						var/ret = src.cloudsave_save(usr.client, new_name)
						if(istext(ret))
							boutput( usr, "<span class='alert'>Failed to save savefile: [ret]</span>" )
						else
							boutput( usr, "<span class='notice'>Savefile saved!</span>" )

			if ("cloud-save")
				if (!client.cloud_available())
					return
				var/ret = src.cloudsave_save(client, params["name"])
				if(istext(ret))
					boutput(usr, "<span class='alert'>Failed to save savefile: [ret]</span>")
				else
					boutput(usr, "<span class='notice'>Savefile saved!</span>")
					return TRUE

			if ("cloud-load")
				if (!client.cloud_available())
					return
				var/ret = src.cloudsave_load(client, params["name"])
				if( istext(ret))
					boutput(usr, "<span class='alert'>Failed to load savefile: [ret]</span>")
				else
					boutput(usr, "<span class='notice'>Savefile loaded!</span>")
					update_preview_icon()
					return TRUE

			if ("cloud-delete")
				if (!client.cloud_available())
					return
				var/ret = src.cloudsave_delete(client, params["name"])
				if(istext(ret))
					boutput(usr, "<span class='alert'>Failed to delete savefile: [ret]</span>")
				else
					boutput(usr, "<span class='notice'>Savefile deleted!</span>")
					return TRUE

			if ("update-profileName")
				var/new_profile_name = input(usr, "New profile name:", "Character Generation", src.profile_name)

				for (var/c in bad_name_characters)
					new_profile_name = replacetext(new_profile_name, c, "")

				new_profile_name = trim(new_profile_name)

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
				var/new_name = input(usr, "Please select a first name:", "Character Generation", src.name_first) as null|text
				if (isnull(new_name))
					return
				new_name = trim(new_name)
				for (var/c in bad_name_characters)
					new_name = replacetext(new_name, c, "")
				if (length(new_name) < NAME_CHAR_MIN)
					alert("Your first name is too short. It must be at least [NAME_CHAR_MIN] characters long.")
					return
				else if (length(new_name) > NAME_CHAR_MAX)
					alert("Your first name is too long. It must be no more than [NAME_CHAR_MAX] characters long.")
					return
				else if (is_blank_string(new_name))
					alert("Your first name cannot contain only spaces.")
					return
				else if (!character_name_validation.Find(new_name))
					alert("Your first name must contain at least one letter.")
					return
				new_name = capitalize(new_name)

				if (new_name)
					src.name_first = new_name
					src.real_name = src.name_first + " " + src.name_last
					src.profile_modified = TRUE
					return TRUE

			if ("update-nameMiddle")
				var/new_name = input(usr, "Please select a middle name:", "Character Generation", src.name_middle) as null|text
				if (isnull(new_name))
					return
				new_name = trim(new_name)
				for (var/c in bad_name_characters)
					new_name = replacetext(new_name, c, "")
				if (length(new_name) > NAME_CHAR_MAX)
					alert("Your middle name is too long. It must be no more than [NAME_CHAR_MAX] characters long.")
					return
				else if (is_blank_string(new_name) && new_name != "")
					alert("Your middle name cannot contain only spaces.")
					return
				new_name = capitalize(new_name)
				src.name_middle = new_name // don't need to check if there is one in case someone wants no middle name I guess
				src.profile_modified = TRUE

				return TRUE

			if ("update-nameLast")
				var/new_name = input(usr, "Please select a last name:", "Character Generation", src.name_last) as null|text
				if (isnull(new_name))
					return
				new_name = trim(new_name)
				for (var/c in bad_name_characters)
					new_name = replacetext(new_name, c, "")
				if (length(new_name) < NAME_CHAR_MIN)
					alert("Your last name is too short. It must be at least [NAME_CHAR_MIN] characters long.")
					return
				else if (length(new_name) > NAME_CHAR_MAX)
					alert("Your last name is too long. It must be no more than [NAME_CHAR_MAX] characters long.")
					return
				else if (is_blank_string(new_name))
					alert("Your last name cannot contain only spaces.")
					return
				else if (!character_name_validation.Find(new_name))
					alert("Your last name must contain at least one letter.")
					return
				new_name = capitalize(new_name)

				if (new_name)
					src.name_last = new_name
					src.real_name = src.name_first + " " + src.name_last
					src.profile_modified = TRUE
					return TRUE

			if ("update-gender")
				if (!AH.pronouns)
					if (src.gender == MALE)
						src.gender = FEMALE
						AH.gender = FEMALE
					else if (src.gender == FEMALE)
						src.gender = MALE
						AH.gender = MALE
						AH.pronouns = 1
				else
					if (src.gender == MALE)
						src.gender = FEMALE
						AH.gender = FEMALE
					else if (src.gender == FEMALE)
						src.gender = MALE
						AH.gender = MALE
						AH.pronouns = 0
				update_preview_icon()
				src.profile_modified = TRUE
				return TRUE

			if ("update-age")
				var/new_age = input(usr, "Please select type in age: 20-80", "Character Generation", src.age)  as null|num

				if (new_age)
					src.age = max(min(round(text2num(new_age)), 80), 20)
					src.profile_modified = TRUE

					return TRUE

			if ("update-bloodType")
				var/blTypeNew = input(usr, "Please select a blood type:", "Character Generation", src.blType)  as null|anything in list("Random", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")

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
					var/new_pin = input(usr, "Please select a PIN between 1000 and 9999", "Character Generation", src.pin)  as null|num
					if (new_pin)
						src.pin = max(min(round(text2num(new_pin)), 9999), 1000)
						src.profile_modified = TRUE
						return TRUE

			if ("update-flavorText")
				var/new_text = input(usr, "Please enter new flavor text (appears when examining you):", "Character Generation", src.flavor_text) as null|text
				if (!isnull(new_text))
					new_text = html_encode(new_text)
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						alert("Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					src.flavor_text = new_text
					src.profile_modified = TRUE

					return TRUE

			if ("update-securityNote")
				var/new_text = input(usr, "Please enter new flavor text (appears when examining you):", "Character Generation", src.security_note) as null|text
				if (!isnull(new_text))
					new_text = html_encode(new_text)
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						alert("Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					src.security_note = new_text
					src.profile_modified = TRUE

					return TRUE

			if ("update-medicalNote")
				var/new_text = input(usr, "Please enter new flavor text (appears when examining you):", "Character Generation", src.medical_note) as null|text
				if (!isnull(new_text))
					new_text = html_encode(new_text)
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						alert("Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					src.medical_note = new_text
					src.profile_modified = TRUE

					return TRUE

			if ("update-pdaRingtone")
				get_all_character_setup_ringtones()
				if(!length(selectable_ringtones))
					src.pda_ringtone_index = "Two-Beep"
					alert(usr, "Oh no! The JamStar-DCXXI PDA ringtone distribution satellite is out of range! Please try again later.", "x.x ringtones broke x.x", "Okay")
					logTheThing("debug", usr, null, "get_all_character_setup_ringtones() didn't return anything!")
				else
					src.pda_ringtone_index = input(usr, "Choose a ringtone", "PDA") as null|anything in selectable_ringtones
					if (!(src.pda_ringtone_index in selectable_ringtones))
						src.pda_ringtone_index = "Two-Beep"

					src.profile_modified = TRUE
					return TRUE

			if ("update-pdaColor")
				var/new_color = input(usr, "Choose a color", "PDA", src.PDAcolor) as color | null
				if (!isnull(new_color))
					src.PDAcolor = new_color
					src.profile_modified = TRUE

					return TRUE

			if ("update-skinTone")
				var/new_tone = "#FEFEFE"
				if (usr.has_medal("Contributor"))
					switch(alert(usr, "Goonstation contributors get to pick any colour for their skin tone!", "Thanks, pal!", "Paint me like a posh fence!", "Use Standard tone.", "Cancel"))
						if("Paint me like a posh fence!")
							new_tone = input(usr, "Please select skin color.", "Character Generation", AH.s_tone)  as null|color
						if("Use Standard tone.")
							new_tone = get_standard_skintone(usr)
						else
							return

					if(new_tone)
						AH.s_tone = new_tone
						AH.s_tone_original = new_tone

						update_preview_icon()
						src.profile_modified = TRUE
						return TRUE
				else
					new_tone = get_standard_skintone(usr)
					if(new_tone)
						AH.s_tone = new_tone
						AH.s_tone_original = new_tone

						update_preview_icon()
						src.profile_modified = TRUE
						return TRUE

			if ("update-eyeColor")
				var/new_color = input(usr, "Please select an eye color.", "Character Generation", AH.e_color) as null|color
				if (new_color)
					AH.e_color = new_color

					update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-randomAppearance")
				src.be_random_look = !src.be_random_look
				src.profile_modified = TRUE
				return TRUE

			if ("update-detail-color")
				var/current_color
				switch(params["id"])
					if ("custom1")
						current_color = src.AH.customization_first_color
					if ("custom2")
						current_color = src.AH.customization_second_color
					if ("custom3")
						current_color = src.AH.customization_third_color
					if ("underwear")
						current_color = src.AH.u_color
				var/new_color = input(usr, "Please select a color.", "Character Generation", current_color) as null|color
				if (new_color)
					switch(params["id"])
						if ("custom1")
							src.AH.customization_first_color = new_color
						if ("custom2")
							src.AH.customization_second_color = new_color
						if ("custom3")
							src.AH.customization_third_color = new_color
						if ("underwear")
							src.AH.u_color = new_color

					update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-detail-style")
				var/new_style
				switch(params["id"])
					if ("custom1", "custom2", "custom3")
						new_style = input(usr, "Select a hair style", "Character Generation") as null|anything in customization_styles
					if ("underwear")
						new_style = input(usr, "Select an underwear style", "Character Generation") as null|anything in underwear_styles

				if (new_style)
					switch(params["id"])
						if ("custom1")
							src.AH.customization_first = new_style
						if ("custom2")
							src.AH.customization_second = new_style
						if ("custom3")
							src.AH.customization_third = new_style
						if ("underwear")
							src.AH.underwear = new_style

					update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-detail-style-cycle")
				var/new_style
				var/current_style
				var/current_index
				var/list/style_list

				switch(params["id"])
					if ("custom1")
						current_style = src.AH.customization_first
					if ("custom2")
						current_style = src.AH.customization_second
					if ("custom3")
						current_style = src.AH.customization_third
					if ("underwear")
						current_style = src.AH.underwear

				if (isnull(current_style))
					return

				switch(params["id"])
					if ("custom1", "custom2", "custom3")
						style_list = customization_styles
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
					switch(params["id"])
						if ("custom1")
							src.AH.customization_first = new_style
						if ("custom2")
							src.AH.customization_second = new_style
						if ("custom3")
							src.AH.customization_third = new_style
						if ("underwear")
							src.AH.underwear = new_style

					update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-fartsound")
				var/list/sound_list = list_keys(AH.fartsounds)
				var/new_sound = input(usr, "Select a farting sound") as null|anything in sound_list

				if (new_sound)
					src.AH.fartsound = new_sound
					preview_sound(sound(src.AH.fartsounds[src.AH.fartsound]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-screamsound")
				var/list/sound_list = list_keys(AH.screamsounds)
				var/new_sound = input(usr, "Select a screaming sound") as null|anything in sound_list

				if (new_sound)
					src.AH.screamsound = new_sound
					preview_sound(sound(src.AH.screamsounds[src.AH.screamsound]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-chatsound")
				var/list/sound_list = list_keys(AH.voicetypes)
				var/new_sound = input(usr, "Select a chatting sound") as null|anything in sound_list

				if (new_sound)
					new_sound = src.AH.voicetypes[new_sound]
					src.AH.voicetype = new_sound
					preview_sound(sound(sounds_speak[src.AH.voicetype]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-fontSize")
				if (params["reset"])
					src.font_size = initial(src.font_size)
					return TRUE
				else
					var/new_font_size = input(usr, "Desired font size (in percent):", "Font setting", (src.font_size ? src.font_size : 100)) as null|num
					if (!isnull(new_font_size))
						src.font_size = new_font_size
						src.profile_modified = TRUE
						return TRUE

			if ("update-seeMentorPms")
				src.see_mentor_pms = !src.see_mentor_pms
				src.profile_modified = TRUE
				return TRUE

			if ("update-listenOoc")
				src.listen_ooc = !src.listen_ooc
				src.profile_modified = TRUE
				return TRUE

			if ("update-listenLooc")
				src.listen_looc = !src.listen_looc
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
				var/new_hud = input(usr, "Please select a HUD style:", "New") as null|anything in hud_style_selection

				if (new_hud)
					src.hud_style = new_hud
					src.profile_modified = TRUE
					return TRUE

			if ("update-targetingCursor")
				var/new_cursor = input(usr, "Please select a cursor:", "Cursor") as null|anything in cursors_selection

				if (new_cursor)
					src.target_cursor = new_cursor
					src.profile_modified = TRUE
					return TRUE

			if ("update-tooltipOption")
				if (params["value"] == TOOLTIP_ALWAYS || params["value"] == TOOLTIP_ALT || params["value"] == TOOLTIP_NEVER)
					src.tooltip_option = params["value"]
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

			if ("update-useWasd")
				src.use_wasd = !src.use_wasd
				src.profile_modified = TRUE
				return TRUE

			if ("update-useAzerty")
				src.use_azerty = !src.use_azerty
				src.profile_modified = TRUE
				return TRUE

			if ("update-preferredMap")
				src.preferred_map = mapSwitcher.clientSelectMap(usr.client,pickable=0)
				src.profile_modified = TRUE
				return TRUE

			if ("reset")
				src.profile_modified = TRUE

				src.gender = MALE
				AH.gender = MALE
				randomize_name()

				AH.customization_first = "Trimmed"
				AH.customization_second = "None"
				AH.customization_third = "None"
				AH.underwear = "No Underwear"

				AH.customization_first_color = initial(AH.customization_first_color)
				AH.customization_second_color = initial(AH.customization_second_color)
				AH.customization_third_color = initial(AH.customization_third_color)
				AH.e_color = "#101010"
				AH.u_color = "#FEFEFE"

				AH.s_tone = "#FAD7D0"
				AH.s_tone_original = "#FAD7D0"

				age = 30
				pin = null
				flavor_text = null
				src.ResetAllPrefsToLow(usr)
				flying_chat_hidden = 0
				local_deadchat = 0
				auto_capitalization = 0
				listen_ooc = 1
				view_changelog = 1
				view_score = 1
				view_tickets = 1
				admin_music_volume = 50
				radio_music_volume = 50
				use_click_buffer = 0
				be_traitor = 0
				be_syndicate = 0
				be_spy = 0
				be_gangleader = 0
				be_revhead = 0
				be_changeling = 0
				be_wizard = 0
				be_werewolf = 0
				be_vampire = 0
				be_wraith = 0
				be_blob = 0
				be_conspirator = 0
				be_flock = 0
				be_misc = 0
				tooltip_option = TOOLTIP_ALWAYS
				tgui_fancy = TRUE
				tgui_lock = FALSE
				PDAcolor = "#6F7961"
				pda_ringtone_index = "Two-Beep"
				if (!force_random_names)
					be_random_name = 0
				else
					be_random_name = 1
				if (!force_random_looks)
					be_random_look = 0
				else
					be_random_look = 1
				blType = "A+"

				update_preview_icon()

				return TRUE

	proc/preview_sound(var/sound/S)
		// tgui kinda adds the ability to spam stuff very fast. This just limits people to spam sound previews.
		if (!ON_COOLDOWN(usr, "preferences_preview_sound", 0.5 SECONDS))
			usr << S

	proc/randomize_name(var/first = 1, var/middle = 1, var/last = 1)
		//real_name = random_name(src.gender)
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
		src.real_name = src.name_first + " " + src.name_last

	proc/randomizeLook() // im laze
		if (!AH)
			logTheThing("debug", usr ? usr : null, null, "a preference datum's appearence holder is null!")
			return
		randomize_look(AH, 0, 0, 0, 0, 0, 0) // keep gender/bloodtype/age/name/underwear/bioeffects
		if (prob(1))
			blType = "Zesty Ranch"

		update_preview_icon()

	proc/sanitize_name()
		//var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "\[", "\]", "{", "}", "|", "\\", "/")
		for (var/c in bad_name_characters)
			//real_name = replacetext(real_name, c, "")
			name_first = replacetext(name_first, c, "")
			name_middle = replacetext(name_middle, c, "")
			name_last = replacetext(name_last, c, "")

		if (length(name_first) < NAME_CHAR_MIN || length(name_first) > NAME_CHAR_MAX || is_blank_string(name_first) || !character_name_validation.Find(name_first))
			src.randomize_name(1, 0, 0)

		if (length(name_middle) > NAME_CHAR_MAX || is_blank_string(name_middle))
			src.randomize_name(0, 1, 0)

		if (length(name_last) < NAME_CHAR_MIN || length(name_last) > NAME_CHAR_MAX || is_blank_string(name_last) || !character_name_validation.Find(name_last))
			src.randomize_name(0, 0, 1)

		src.real_name = src.name_first + " " + src.name_last


	proc/update_preview_icon()
		if (!AH)
			logTheThing("debug", usr ? usr : null, null, "a preference datum's appearence holder is null!")
			return

		var/datum/mutantrace/mutantRace = null
		for (var/ID in traitPreferences.traits_selected)
			var/obj/trait/T = getTraitById(ID)
			if (T?.mutantRace)
				mutantRace = T.mutantRace
				break

		src.preview?.update_appearance(src.AH, mutantRace, src.spessman_direction, name=src.real_name)


	proc/ShowChoices(mob/user)
		src.ui_interact(user)

	proc/ResetAllPrefsToMed(mob/user)
		src.job_favorite = null
		src.jobs_med_priority = list()
		src.jobs_low_priority = list()
		src.jobs_unwanted = list()
		for (var/datum/job/J in job_controls.staple_jobs)
			if (istype(J, /datum/job/daily))
				continue
			if (jobban_isbanned(user,J.name) || (J.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J.requires_whitelist && !NT.Find(ckey(user.mind.key))))
				src.jobs_unwanted += J.name
				continue
			if (J.rounds_needed_to_play && (user.client && user.client.player))
				var/round_num = user.client.player.get_rounds_participated() //if this list is null, the api query failed, so we just let it happen
				if (!isnull(round_num) && round_num < J.rounds_needed_to_play) //they havent played enough rounds!
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
			if (istype(J, /datum/job/daily))
				continue
			if (jobban_isbanned(user,J.name) || (J.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J.requires_whitelist && !NT.Find(ckey(user.mind.key))))
				src.jobs_unwanted += J.name
				continue
			if (J.rounds_needed_to_play && (user.client && user.client.player))
				var/round_num = user.client.player.get_rounds_participated()
				if (!isnull(round_num) && round_num < J.rounds_needed_to_play) //they havent played enough rounds!
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
			if (istype(J, /datum/job/daily))
				continue
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
			if (istype(J, /datum/job/daily))
				continue
			if (jobban_isbanned(user,J.name) || (J.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J.requires_whitelist && !NT.Find(ckey(user.mind.key))) || istype(J, /datum/job/command) || istype(J, /datum/job/civilian/AI) || istype(J, /datum/job/civilian/cyborg) || istype(J, /datum/job/security/security_officer))
				src.jobs_unwanted += J.name
				continue
			if (J.rounds_needed_to_play && (user.client && user.client.player))
				var/round_num = user.client.player.get_rounds_participated()
				if (!isnull(round_num) && round_num < J.rounds_needed_to_play) //they havent played enough rounds!
					src.jobs_unwanted += J.name
					continue
			src.jobs_low_priority += J.name
		return

	proc/SetChoices(mob/user)
		if (isnull(src.jobs_med_priority) || isnull(src.jobs_low_priority) || isnull(src.jobs_unwanted))
			src.ResetAllPrefsToDefault(user)
			boutput(user, "<span class='alert'><b>Your Job Preferences were null, and have been reset.</b></span>")
		else if (isnull(src.job_favorite) && !src.jobs_med_priority.len && !src.jobs_low_priority.len && !length(src.jobs_unwanted))
			src.ResetAllPrefsToDefault(user)
			boutput(user, "<span class='alert'><b>Your Job Preferences were empty, and have been reset.</b></span>")
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
				if (istype(J, /datum/job/daily))
					continue
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
				boutput(user, "<span class='alert'><b>You are no longer allowed to play [J_Fav.name]. It has been removed from your Favorite slot.</b></span>")
				src.jobs_unwanted += J_Fav.name
				src.job_favorite = null
			else if (J_Fav.rounds_needed_to_play && (user.client && user.client.player))
				var/round_num = user.client.player.get_rounds_participated()
				if (!isnull(round_num) && round_num < J_Fav.rounds_needed_to_play) //they havent played enough rounds!
					boutput(user, "<span class='alert'><b>You cannot play [J_Fav.name].</b> You've only played </b>[round_num]</b> rounds and need to play more than <b>[J_Fav.rounds_needed_to_play].</b></span>")
					src.jobs_unwanted += J_Fav.name
					src.job_favorite = null
				else
					print_the_job = TRUE
			else
				print_the_job = TRUE
			if(print_the_job)
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
				if (JD.requires_whitelist && !NT.Find(ckey(user.mind.key)))
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
					boutput(user, "<span class='alert'><b>[JD.name] is not supposed to be in the Unwanted category. It has been moved to Low Priority.</b> You may need to refresh your job preferences page to correct the job count.</span>")
					src.jobs_unwanted -= JD.name
					src.jobs_low_priority += JD.name


				HTML += {"
				<div>
					<a href="byond://?src=\ref[src];preferences=1;occ=[level];job=[JD.name];level=[level - 1]" class="arrow" style="left: 0;">&lt;</a>
					[level < (4 - (JD.cant_allocate_unwanted ? 1 : 0)) ? {"<a href="byond://?src=\ref[src];preferences=1;occ=[level];job=[JD.name];level=[level + 1]" class="arrow" style="right: 0;">&gt;</a>"} : ""]
					<a href="byond://?src=\ref[src];preferences=1;occ=[level];job=[JD.name];level=0" class="job" style="color: [JD.linkcolor];">
					[JD.name]</a>
				</div>
				"}

			HTML += "</td>"

		HTML += "<td valign='top' class='antagprefs'>"

		if (jobban_isbanned(user, "Syndicate"))
			HTML += "You are banned from playing antagonist roles."
			src.be_traitor = 0
			src.be_syndicate = 0
			src.be_spy = 0
			src.be_gangleader = 0
			src.be_revhead = 0
			src.be_changeling = 0
			src.be_wizard = 0
			src.be_werewolf = 0
			src.be_vampire = 0
			src.be_wraith = 0
			src.be_blob = 0
			src.be_conspirator = 0
			src.be_flock = 0
		else

			HTML += {"
			<a href="byond://?src=\ref[src];preferences=1;b_traitor=1" class="[src.be_traitor ? "yup" : "nope"]">[crap_checkbox(src.be_traitor)] Traitor</a>
			<a href="byond://?src=\ref[src];preferences=1;b_syndicate=1" class="[src.be_syndicate ? "yup" : "nope"]">[crap_checkbox(src.be_syndicate)] Nuclear Operative</a>
			<a href="byond://?src=\ref[src];preferences=1;b_spy=1" class="[src.be_spy ? "yup" : "nope"]">[crap_checkbox(src.be_spy)] Spy/Thief</a>
			<a href="byond://?src=\ref[src];preferences=1;b_gangleader=1" class="[src.be_gangleader ? "yup" : "nope"]">[crap_checkbox(src.be_gangleader)] Gang Leader</a>
			<a href="byond://?src=\ref[src];preferences=1;b_revhead=1" class="[src.be_revhead ? "yup" : "nope"]">[crap_checkbox(src.be_revhead)] Revolution Leader</a>
			<a href="byond://?src=\ref[src];preferences=1;b_changeling=1" class="[src.be_changeling ? "yup" : "nope"]">[crap_checkbox(src.be_changeling)] Changeling</a>
			<a href="byond://?src=\ref[src];preferences=1;b_wizard=1" class="[src.be_wizard ? "yup" : "nope"]">[crap_checkbox(src.be_wizard)] Wizard</a>
			<a href="byond://?src=\ref[src];preferences=1;b_werewolf=1" class="[src.be_werewolf ? "yup" : "nope"]">[crap_checkbox(src.be_werewolf)] Werewolf</a>
			<a href="byond://?src=\ref[src];preferences=1;b_vampire=1" class="[src.be_vampire ? "yup" : "nope"]">[crap_checkbox(src.be_vampire)] Vampire</a>
			<a href="byond://?src=\ref[src];preferences=1;b_wraith=1" class="[src.be_wraith ? "yup" : "nope"]">[crap_checkbox(src.be_wraith)] Wraith</a>
			<a href="byond://?src=\ref[src];preferences=1;b_blob=1" class="[src.be_blob ? "yup" : "nope"]">[crap_checkbox(src.be_blob)] Blob</a>
			<a href="byond://?src=\ref[src];preferences=1;b_conspirator=1" class="[src.be_conspirator ? "yup" : "nope"]">[crap_checkbox(src.be_conspirator)] Conspirator</a>
			<a href="byond://?src=\ref[src];preferences=1;b_flock=1" class="[src.be_flock ? "yup" : "nope"]">[crap_checkbox(src.be_flock)] Flockmind</a>
			<a href="byond://?src=\ref[src];preferences=1;b_misc=1" class="[src.be_misc ? "yup" : "nope"]">[crap_checkbox(src.be_misc)] Other Foes</a>
		"}

		HTML += {"</td></tr></table>"}

		user.Browse(null, "window=preferences")
		user.Browse(HTML.Join(), "window=mob_occupation;size=850x580")
		return

	proc/SetJob(mob/user, occ=1, job="Captain",var/level = 0)
		if (src.antispam)
			return
		switch(occ)
			if (1)
				if(src.job_favorite != job)
					return
			if (2)
				if(!(job in src.jobs_med_priority))
					return
			if (3)
				if(!(job in src.jobs_low_priority))
					return
			if (4)
				if(!(job in src.jobs_unwanted))
					return
			else
				return
				//
		//works for now, maybe move this to something on game mode to decide proper jobs... -kyle
#if defined(MAP_OVERRIDE_POD_WARS)
		if (!find_job_in_controller_by_string(job,0))
#else
		if (!find_job_in_controller_by_string(job,1))
#endif
			boutput(user, "<span class='alert'><b>The game could not find that job in the internal list of jobs.</b></span>")
			switch(occ)
				if (1) src.job_favorite = null
				if (2) src.jobs_med_priority -= job
				if (3) src.jobs_low_priority -= job
				if (4) src.jobs_unwanted -= job
			return
		if (job=="AI" && (!config.allow_ai))
			boutput(user, "<span class='alert'><b>Selecting the AI is not currently allowed.</b></span>")
			if (occ != 4)
				switch(occ)
					if (1) src.job_favorite = null
					if (2) src.jobs_med_priority -= job
					if (3) src.jobs_low_priority -= job
				src.jobs_unwanted += job
			return

		if (jobban_isbanned(user, job))
			boutput(user, "<span class='alert'><b>You are banned from this job and may not select it.</b></span>")
			if (occ != 4)
				switch(occ)
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
		if (temp_job.rounds_needed_to_play && (user.client && user.client.player))
			var/round_num = user.client.player.get_rounds_participated()
			if (!isnull(round_num) && round_num < temp_job.rounds_needed_to_play) //they havent played enough rounds!
				boutput(user, "<span class='alert'><b>You cannot play [temp_job.name].</b> You've only played </b>[round_num]</b> rounds and need to play more than <b>[temp_job.rounds_needed_to_play].</b></span>")
				if (occ != 4)
					switch(occ)
						if (1) src.job_favorite = null
						if (2) src.jobs_med_priority -= job
						if (3) src.jobs_low_priority -= job
					src.jobs_unwanted += job
				return

		src.antispam = 1

		var/picker = "Low Priority"
		if (level == 0)
			var/list/valid_actions = list("Favorite","Medium Priority","Low Priority","Unwanted")

			switch(occ)
				if (1) valid_actions -= "Favorite"
				if (2) valid_actions -= "Medium Priority"
				if (3) valid_actions -= "Low Priority"
				if (4) valid_actions -= "Unwanted"

			picker = input("Which bracket would you like to move this job to?","Job Preferences") as null|anything in valid_actions
			if (!picker)
				src.antispam = 0
				return
		else
			switch(level)
				if (1) picker = "Favorite"
				if (2) picker = "Medium Priority"
				if (3) picker = "Low Priority"
				if (4) picker = "Unwanted"
		var/datum/job/J = find_job_in_controller_by_string(job)
		if (J.cant_allocate_unwanted && picker == "Unwanted")
			boutput(user, "<span class='alert'><b>[job] cannot be set to Unwanted.</b></span>")
			src.antispam = 0
			return

		var/successful_move = 0

		switch(picker)
			if ("Favorite")
				if (src.job_favorite)
					src.jobs_med_priority += src.job_favorite
				src.job_favorite = job
				successful_move = 1
			if ("Medium Priority")
				src.jobs_med_priority += job
				if (occ == 1)
					src.job_favorite = null
				successful_move = 1
			if ("Low Priority")
				src.jobs_low_priority += job
				if (occ == 1)
					src.job_favorite = null
				successful_move = 1
			if ("Unwanted")
				src.jobs_unwanted += job
				if (occ == 1)
					src.job_favorite = null
				successful_move = 1

		if (successful_move)
			switch(occ)
				// i know, repetitive, but its the safest way i can think of right now
				if (2) src.jobs_med_priority -= job
				if (3) src.jobs_low_priority -= job
				if (4) src.jobs_unwanted -= job

		src.antispam = 0
		return 1

	Topic(href, href_list[])
		if (usr?.client?.preferences)
			if (src == usr.client.preferences)
				process_link(usr, href_list)
			else
				boutput(usr, "Those aren't your prefs!")
		else
			boutput(usr, "Something went wrong with preferences. Call a coder.")
		..()

	proc/process_link(mob/user, list/link_tags)
		if (!user.client)
			return

		// do we check if they actually modified something? no.
		// thats effort.
		src.profile_modified = 1

		if (link_tags["job"])
			src.SetJob(user, text2num(link_tags["occ"]), link_tags["job"], text2num(link_tags["level"]))
			src.SetChoices(user)
			return

		if (link_tags["jobswindow"])
			src.SetChoices(user)
			return

		if (link_tags["traitswindow"])
			traitPreferences.showTraits(user)
			return

		if (link_tags["closejobswindow"])
			user.Browse(null, "window=mob_occupation")
			src.ShowChoices(user)
			return

		if (link_tags["resetalljobs"])
			var/resetwhat = input("Reset all jobs to which level?","Job Preferences") as null|anything in list("Medium Priority","Low Priority","Unwanted")
			switch(resetwhat)
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
			src.be_traitor = !( src.be_traitor)
			src.SetChoices(user)
			return

		if (link_tags["b_syndicate"])
			src.be_syndicate = !( src.be_syndicate )
			src.SetChoices(user)
			return

		if (link_tags["b_spy"])
			src.be_spy = !( src.be_spy)
			src.SetChoices(user)
			return

		if (link_tags["b_gangleader"])
			src.be_gangleader = !( src.be_gangleader)
			src.SetChoices(user)
			return

		if (link_tags["b_revhead"])
			src.be_revhead = !( src.be_revhead )
			src.SetChoices(user)
			return

		if (link_tags["b_changeling"])
			src.be_changeling = !( src.be_changeling )
			src.SetChoices(user)

		if (link_tags["b_wizard"])
			src.be_wizard = !( src.be_wizard)
			src.SetChoices(user)
			return

		if (link_tags["b_werewolf"])
			src.be_werewolf = !( src.be_werewolf)
			src.SetChoices(user)
			return

		if (link_tags["b_vampire"])
			src.be_vampire = !( src.be_vampire)
			src.SetChoices(user)
			return

		if (link_tags["b_wraith"])
			src.be_wraith = !( src.be_wraith)
			src.SetChoices(user)
			return

		if (link_tags["b_blob"])
			src.be_blob = !( src.be_blob)
			src.SetChoices(user)
			return

		if (link_tags["b_conspirator"])
			src.be_conspirator = !( src.be_conspirator )
			src.SetChoices(user)
			return

		if (link_tags["b_flock"])
			src.be_flock = !( src.be_flock)
			src.SetChoices(user)
			return

		if (link_tags["b_misc"])
			src.be_misc = !src.be_misc
			src.SetChoices(user)
			return

		src.ShowChoices(user)

	proc/copy_to(mob/living/character,var/mob/user,ignore_randomizer = 0)//LOOK SORRY, I MADE THIS /mob/living iF THIS BREAKS SOMETHING YOU SHOULD PROBABLY NOT BE CALLING THIS ON A NON LIVING MOB
		sanitize_null_values()
		if (!ignore_randomizer)
			var/namebanned = jobban_isbanned(user, "Custom Names")
			if (be_random_name || namebanned)
				randomize_name()

			if (be_random_look || namebanned)
				randomizeLook()

			if (character.bioHolder)
				if (random_blood || namebanned)
					character.bioHolder.bloodType = random_blood_type()
				else
					character.bioHolder.bloodType = blType

		//character.real_name = real_name
		src.real_name = src.name_first + " " + src.name_last
		character.real_name = src.real_name

		//Wire: Not everything has a bioholder you morons
		if (character.bioHolder)
			character.bioHolder.age = age
			character.bioHolder.mobAppearance.CopyOther(AH)
			character.bioHolder.mobAppearance.gender = src.gender
			character.bioHolder.mobAppearance.flavor_text = src.flavor_text

		//Also I think stuff other than human mobs can call this proc jesus christ
		if (ishuman(character))
			var/mob/living/carbon/human/H = character
			H.pin = pin
			H.gender = src.gender
			//H.desc = src.flavor_text
			if (H?.organHolder?.head?.donor_appearance) // aaaa
				H.organHolder.head.donor_appearance.CopyOther(AH)

		if (traitPreferences.isValid() && character.traitHolder)
			for (var/T in traitPreferences.traits_selected)
				character.traitHolder.addTrait(T)

		character.update_face()
		character.update_body()

		character.sound_scream = AH.screamsounds[AH.screamsound || "default"] || AH.screamsounds["default"]
		character.sound_fart = AH.fartsounds[AH.fartsound || "default"] || AH.fartsounds["default"]
		character.voice_type = AH.voicetype || RANDOM_HUMAN_VOICE

		if (ishuman(character))
			var/mob/living/carbon/human/H = character
			if (H.mutantrace && H.mutantrace.voice_override)
				H.voice_type = H.mutantrace.voice_override

	proc/sanitize_null_values()
		if (!src.gender || !(src.gender == MALE || src.gender == FEMALE))
			src.gender = MALE
		if (!AH)
			AH = new
		if (AH.gender != src.gender)
			AH.gender = src.gender
		if (AH.customization_first_color == null)
			AH.customization_first_color = "#101010"
		if (AH.customization_first == null)
			AH.customization_first = "None"
		if (AH.customization_second_color == null)
			AH.customization_second_color = "#101010"
		if (AH.customization_second == null)
			AH.customization_second = "None"
		if (AH.customization_third_color == null)
			AH.customization_third_color = "#101010"
		if (AH.customization_third == null)
			AH.customization_third = "None"
		if (AH.e_color == null)
			AH.e_color = "#101010"
		if (AH.u_color == null)
			AH.u_color = "#FEFEFE"
		if (AH.s_tone == null || AH.s_tone == "#FFFFFF" || AH.s_tone == "#ffffff")
			AH.s_tone = "#FEFEFE"

	proc/keybind_prefs_updated(var/client/C)
		if (!isclient(C))
			var/mob/M = C
			if (ismob(M) && M.client)
				C = M.client
			else
				boutput(C,"Something went wrong. Maybe the game isn't done loading yet, give it a minute!")
				return
		if (C.preferences.use_wasd)
			winset( C, "menu.wasd_controls", "is-checked=true" )
		else
			winset( C, "menu.wasd_controls", "is-checked=false" )
		C.mob.reset_keymap()

/* ---------------------- RANDOMIZER PROC STUFF */

/proc/random_blood_type(var/weighted = 1)
	var/return_type
	// set a default one so that, if none of the weighted ones happen, they at least have SOME kind of blood type
	return_type = pick("O", "A", "B", "AB") + pick("+", "-")
	if (weighted)
		var/list/types_and_probs = list(\
		"O" = 40,\
		"A" = 30,\
		"B" = 15,\
		"AB" = 5)
		for (var/i in types_and_probs)
			if (prob(types_and_probs[i]))
				return_type = i
				if (prob(80))
					return_type += "+"
				else
					return_type += "-"

	if (prob(1))
		return_type = "Zesty Ranch"

	return return_type

/proc/random_saturated_hex_color()
	return pick(rgb(255, rand(0, 255), rand(0, 255)), rgb(rand(0, 255), 255, rand(0, 255)), rgb(rand(0, 255), rand(0, 255), 255))

/proc/randomize_hair_color(var/hcolor)
	if (!hcolor)
		return
	var/adj = 0
	if (copytext(hcolor, 1, 2) == "#")
		adj = 1
	//DEBUG_MESSAGE("HAIR initial: [hcolor]")
	var/hR_adj = num2hex(hex2num(copytext(hcolor, 1 + adj, 3 + adj)) + rand(-25,25), 2)
	//DEBUG_MESSAGE("HAIR R: [hR_adj]")
	var/hG_adj = num2hex(hex2num(copytext(hcolor, 3 + adj, 5 + adj)) + rand(-5,5), 2)
	//DEBUG_MESSAGE("HAIR G: [hG_adj]")
	var/hB_adj = num2hex(hex2num(copytext(hcolor, 5 + adj, 7 + adj)) + rand(-10,10), 2)
	//DEBUG_MESSAGE("HAIR B: [hB_adj]")
	var/return_color = "#" + hR_adj + hG_adj + hB_adj
	//DEBUG_MESSAGE("HAIR final: [return_color]")
	return return_color

/proc/randomize_eye_color(var/ecolor)
	if (!ecolor)
		return
	var/adj = 0
	if (copytext(ecolor, 1, 2) == "#")
		adj = 1
	//DEBUG_MESSAGE("EYE initial: [ecolor]")
	var/eR_adj = num2hex(hex2num(copytext(ecolor, 1 + adj, 3 + adj)) + rand(-10,10), 2)
	//DEBUG_MESSAGE("EYE R: [eR_adj]")
	var/eG_adj = num2hex(hex2num(copytext(ecolor, 3 + adj, 5 + adj)) + rand(-10,10), 2)
	//DEBUG_MESSAGE("EYE G: [eG_adj]")
	var/eB_adj = num2hex(hex2num(copytext(ecolor, 5 + adj, 7 + adj)) + rand(-10,10), 2)
	//DEBUG_MESSAGE("EYE B: [eB_adj]")
	var/return_color = "#" + eR_adj + eG_adj + eB_adj
	//DEBUG_MESSAGE("EYE final: [return_color]")
	return return_color

var/global/list/feminine_hstyles = list("Mohawk" = "mohawk",
	"Pompadour" = "pomp",
	"Ponytail" = "ponytail",
	"Mullet" = "long",
	"Emo" = "emo",
	"Bun" = "bun",
	"Bieber" = "bieb",
	"Parted Hair" = "part",
	"Draped" = "shoulders",
	"Bedhead" = "bedhead",
	"Afro" = "afro",
	"Long Braid" = "longbraid",
	"Very Long" = "vlong",
	"Hairmetal" = "80s",
	"Glammetal" = "glammetal",
	"Fabio" = "fabio",
	"Right Half-Shaved" = "halfshavedL",
	"Left Half-Shaved" = "halfshavedR",
	"Long Half-Shaved" = "halfshaved_s",
	"High Ponytail" = "spud",
	"Low Ponytail" = "band",
	"Double Braids" = "indian",
	"Shoulder Drape" = "pulledf",
	"Punky Flip" = "shortflip",
	"Pigtails" = "pig",
	"Low Pigtails" = "lowpig",
	"Mini Pigtails" = "minipig",
	"Double Buns" = "doublebun",
	"Shimada" = "geisha_s",
	"Mid-Back Length" = "midb",
	"Shoulder Length" = "shoulderl",
	"Shoulder-Length Mess" = "slightlymessy_s",
	"Pulled Back" = "pulledb",
	"Choppy Short" = "chop_short",
	"Long and Froofy" = "froofy_long",
	"Mid-Length Curl" = "bluntbangs_s",
	"Long Flip" = "longsidepart_s",
	"Wavy Ponytail" = "wavy_tail",
	"Bobcut" = "bobcut",
	"Bobcut Alt" = "baum_s",
	"Combed Bob" = "combedbob_s",
	"Mermaid" = "mermaid",
	"Captor" = "sakura",
	"Sage" = "sage",
	"Fun Bun" = "fun_bun",
	"Croft" = "croft",
	"Disheveled" = "disheveled",
	"Tulip" = "tulip",
	"Floof" = "floof",
	"Bloom" = "bloom",
	"Smooth Waves" = "smoothwave",
	"Long Mini Tail" = "longtailed")

var/global/list/masculine_hstyles = list("None" = "None",
	"Balding" = "balding",
	"Tonsure" = "tonsure",
	"Buzzcut" = "cut",
	"Trimmed" = "short",
	"Combed" = "combed_s",
	"Mohawk" = "mohawk",
	"Flat Top" = "flattop",
	"Pompadour" = "pomp",
	"Ponytail" = "ponytail",
	"Mullet" = "long",
	"Emo" = "emo",
	"Bieber" = "bieb",
	"Persh Cut" = "bowl",
	"Parted Hair" = "part",
	"Einstein" = "einstein",
	"Bedhead" = "bedhead",
	"Dreadlocks" = "dreads",
	"Afro" = "afro",
	"Kingmetal" = "king-of-rock-and-roll",
	"Scraggly" = "scraggly",
	"Right Half-Shaved" = "halfshavedL",
	"Left Half-Shaved" = "halfshavedR",
	"High Flat Top" = "charioteers",
	"Punky Flip" = "shortflip",
	"Mid-Back Length" = "midb",
	"Split-Tails" = "twotail",
	"Choppy Short" = "chop_short",
	"Bangs" = "bangs",
	"Mini Pigtails" = "minipig",
	"Temsik" = "temsik",
	"Visual" = "visual",
	"Tulip" = "tulip",
	"Spiky" = "spiky",
	"Subtle Spiky" = "subtlespiky",
	"Bloom" = "bloom")

var/global/list/facial_hair = list("None" = "none",
	"Chaplin" = "chaplin",
	"Selleck" = "selleck",
	"Watson" = "watson",
	"Old Nick" = "devil",
	"Biker" = "fu",
	"Twirly" = "villain",
	"Dali" = "dali",
	"Hogan" = "hogan",
	"Van Dyke" = "vandyke",
	"Hipster" = "hip",
	"Robotnik" = "robo",
	"Elvis" = "elvis",
	"Goatee" = "gt",
	"Chinstrap" = "chin",
	"Neckbeard" = "neckbeard",
	"Abe" = "abe",
	"Full Beard" = "fullbeard",
	"Braided Beard" = "braided",
	"Puffy Beard" = "puffbeard",
	"Long Beard" = "longbeard",
	"Tramp" = "tramp",
	"Motley" = "motley",
	"Eyebrows" = "eyebrows",
	"Huge Eyebrows" = "thufir")

// this is weird but basically: a list of hairstyles and their appropriate detail styles, aka hair_details["80s"] would return the Hairmetal: Faded style
// further on in the randomize_look() proc we'll see if we've got one of the styles in here and if so, we have a chance to add the detailing
// if it's a list then we'll pick from the options in the list
var/global/list/hair_details = list("einstein" = "einalt",\
	"80s" = "80sfade",\
	"glammetal" = "glammetalO",\
	"mermaid" = "mermaidfade",\
	"smoothwave" = "smoothwave_fade",\
	"longbeard" = "longbeardfade",\
	"pomp" = "pompS",\
	"mohawk" = list("mohawkFT", "mohawkFB", "mohawkS"),\
	"emo" = "emoH",\
	"clown" = list("clownT", "clownM", "clownB"),\
	"dreads" = "dreadsA",\
	"afro" = list("afroHR", "afroHL", "afroST", "afroSM", "afroSB", "afroSL", "afroSR", "afroSC", "afroCNE", "afroCNW", "afroCSE", "afroCSW", "afroSV", "afroSH"))

// all these icon state names are ridiculous
var/global/list/feminine_ustyles = list("No Underwear" = "none",\
	"Bra and Panties" = "brapan",\
	"Tanktop and Panties" = "tankpan",\
	"Bra and Boyshorts" = "braboy",\
	"Tanktop and Boyshorts" = "tankboy",\
	"Panties" = "panties",\
	"Boyshorts" = "boyshort")
var/global/list/masculine_ustyles = list("No Underwear" = "none",\
	"Briefs" = "briefs",\
	"Boxers" = "boxers",\
	"Boyshorts" = "boyshort")

var/global/list/male_screams = list("male", "malescream4", "malescream5", "malescream6", "malescream7")
var/global/list/female_screams = list("female", "femalescream1", "femalescream2", "femalescream3", "femalescream4")

/proc/randomize_look(to_randomize, change_gender = 1, change_blood = 1, change_age = 1, change_name = 1, change_underwear = 1, remove_effects = 1, optional_donor)
	if (!to_randomize)
		return

	var/mob/living/carbon/human/H
	var/datum/appearanceHolder/AH

	if (ishuman(to_randomize))
		H = to_randomize
		if (H.bioHolder && H.bioHolder.mobAppearance)
			AH = H.bioHolder.mobAppearance
		else if (H.bioHolder)
			H.bioHolder.mobAppearance = new /datum/appearanceHolder()
			H.bioHolder.mobAppearance.owner = H
			H.bioHolder.mobAppearance.parentHolder = H.bioHolder
			AH = H.bioHolder.mobAppearance
		else
			H.bioHolder = new /datum/bioHolder()
			H.initializeBioholder()

			H.bioHolder.mobAppearance = new /datum/appearanceHolder()
			H.bioHolder.mobAppearance.owner = H
			H.bioHolder.mobAppearance.parentHolder = H.bioHolder
			AH = H.bioHolder.mobAppearance

	else if (istype(to_randomize, /datum/appearanceHolder))
		AH = to_randomize
		if (ishuman(AH.owner))
			H = AH.owner
		else
			H = optional_donor
	else
		return

	if (H?.bioHolder && remove_effects)
		H.bioHolder.RemoveAllEffects()
		H.bioHolder.BuildEffectPool()

	if (change_gender)
		AH.gender = pick(MALE, FEMALE)
	if (H && AH.gender)
		H.sound_scream = AH.screamsounds[pick(AH.gender == MALE ? male_screams : female_screams)]
	if (H && change_name)
		if (AH.gender == FEMALE)
			H.real_name = pick_string_autokey("names/first_female.txt")
		else
			H.real_name = pick_string_autokey("names/first_male.txt")
		H.real_name += " [pick_string_autokey("names/last.txt")]"

	AH.voicetype = RANDOM_HUMAN_VOICE

	var/list/hair_colors = list("#101010", "#924D28", "#61301B", "#E0721D", "#D7A83D",\
	"#D8C078", "#E3CC88", "#F2DA91", "#F21AE", "#664F3C", "#8C684A", "#EE2A22", "#B89778", "#3B3024", "#A56b46")
	var/hair_color1
	var/hair_color2
	var/hair_color3
	if (prob(75))
		hair_color1 = randomize_hair_color(pick(hair_colors))
		hair_color2 = prob(50) ? hair_color1 : randomize_hair_color(pick(hair_colors))
		hair_color3 = prob(50) ? hair_color1 : randomize_hair_color(pick(hair_colors))
	else
		hair_color1 = randomize_hair_color(random_saturated_hex_color())
		hair_color2 = prob(50) ? hair_color1 : randomize_hair_color(random_saturated_hex_color())
		hair_color3 = prob(50) ? hair_color1 : randomize_hair_color(random_saturated_hex_color())

	AH.customization_first_color = hair_color1
	AH.customization_second_color = hair_color2
	AH.customization_third_color = hair_color3

	var/stone = rand(34,-184)
	if (stone < -30)
		stone = rand(34,-184)
	if (stone < -50)
		stone = rand(34,-184)

	AH.s_tone = blend_skintone(stone, stone, stone)
	AH.s_tone_original = AH.s_tone

	if (H?.limbs)
		H.limbs.reset_stone()

	var/list/eye_colors = list("#101010", "#613F1D", "#808000", "#3333CC")
	AH.e_color = randomize_eye_color(pick(eye_colors))

	var/has_second = 0
	if (AH.gender == MALE)
		if (prob(5)) // small chance to have a hairstyle more geared to the other gender
			AH.customization_first = pick(feminine_hstyles)
		else // otherwise just use one standard to the current gender
			AH.customization_first = pick(masculine_hstyles)

		if (prob(33)) // since we're a guy, a chance for facial hair
			AH.customization_second = pick(facial_hair)
			has_second = 1 // so the detail check doesn't do anything - we already got a secondary thing!!

	else // if FEMALE
		if (prob(8)) // same as above for guys, just reversed and with a slightly higher chance since it's ~more appropriate~ for ladies to have guy haircuts than vice versa  :I
			AH.customization_first = pick(masculine_hstyles)
		else // ss13 is coded with gender stereotypes IN ITS VERY CORE
			AH.customization_first = pick(feminine_hstyles)

	if (!has_second)
		var/hair_detail = hair_details[AH.customization_first] // check for detail styles for our chosen style

		if (hair_detail && prob(50)) // found something in the list
			AH.customization_second = hair_detail // default to being whatever we found

			if (islist(hair_detail)) // if we found a bunch of things in the list
				AH.customization_second = pick(hair_detail) // let's choose just one (we don't need to assign a list as someone's hair detail)

				if (prob(20)) // with a small chance for another detail thing
					AH.customization_third = pick(hair_detail)
					AH.customization_third_color = random_saturated_hex_color()
					if (prob(5))
						AH.customization_third_color = randomize_hair_color(pick(hair_colors))
				else
					AH.customization_third = "none"

			AH.customization_second_color = random_saturated_hex_color() // if you have a detail style you're likely to want a crazy color
			if (prob(15))
				AH.customization_second_color = randomize_hair_color(pick(hair_colors)) // but have a chance to be a normal hair color

		else if (prob(5)) // chance for a special eye color
			AH.customization_second = pick("hetcroL", "hetcroR")
			if (prob(75))
				AH.customization_second_color = random_saturated_hex_color()
			else
				AH.customization_second_color = randomize_eye_color(pick(eye_colors))
			AH.customization_third = "none"

		else // otherwise, nada
			AH.customization_second = "none"
			AH.customization_third = "none"

	if (change_underwear)
		if (AH.gender == MALE)
			if (prob(1))
				AH.underwear = pick(feminine_ustyles)
			else
				AH.underwear = pick(masculine_ustyles)
		else
			if (prob(5))
				AH.underwear = pick(masculine_ustyles)
			else
				AH.underwear = pick(feminine_ustyles)
		AH.u_color = random_saturated_hex_color()

	if (H && change_blood)
		H.bioHolder.bloodType = random_blood_type(1)

	if (H && change_age)
		H.bioHolder.age = rand(20,80)

	if (H?.organHolder?.head?.donor_appearance) // aaaa
		H.organHolder.head.donor_appearance.CopyOther(AH)

	SPAWN_DBG(1 DECI SECOND)
		H?.update_colorful_parts()

// Generates a real crap checkbox for html toggle links.
// it sucks but it's a bit more readable i guess.
/proc/crap_checkbox(var/checked)
	if (checked) return "&#9745;"
	else return "&#9744;"
