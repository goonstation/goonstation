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
	var/robot_name
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
	var/be_syndicate_commander = 0
	var/be_spy = 0
	var/be_gangleader = 0
	var/be_revhead = 0
	var/be_changeling = 0
	var/be_wizard = 0
	var/be_werewolf = 0
	var/be_vampire = 0
	var/be_arcfiend = 0
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
		if(!tgui_process)
			boutput(user, "<span class='alert'>Hold on a moment, stuff is still setting up.</span>")
			return
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

	ui_static_data(mob/user)
		var/list/traits = list()
		for (var/datum/trait/trait as anything in src.traitPreferences.getTraits(user))
			var/list/categories
			if (islist(trait.category))
				categories = trait.category.Copy()
				categories.Remove(src.traitPreferences.hidden_categories)

			traits[trait.id] = list(
				"id" = trait.id,
				"name" = trait.name,
				"desc" = trait.desc,
				"category" = categories,
				"img" = icon2base64(icon(trait.icon, trait.icon_state)),
				"points" = trait.points,
			)

		. = list(
			"traitsData" = traits
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

		var/list/traits = list()
		for (var/datum/trait/trait as anything in src.traitPreferences.getTraits(user))
			var/selected = (trait.id in traitPreferences.traits_selected)
			var/list/categories
			if (islist(trait.category))
				categories = trait.category.Copy()
				categories.Remove(src.traitPreferences.hidden_categories)

			traits += list(list(
				"id" = trait.id,
				"selected" = selected,
				"available" = src.traitPreferences.isAvailableTrait(trait.id, selected)
			))

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
			"robotName" = src.robot_name,
			"randomName" = src.be_random_name,
			"gender" = src.gender == MALE ? "Male" : "Female",
			"pronouns" = isnull(AH.pronouns) ? "Default" : AH.pronouns.name,
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
			"specialStyle" = src.AH.special_style,
			"eyeColor" = src.AH.e_color,
			"customColor1" = src.AH.customization_first_color,
			"customStyle1" = src.AH.customization_first.name,
			"customColor2" = src.AH.customization_second_color,
			"customStyle2" = src.AH.customization_second.name,
			"customColor3" = src.AH.customization_third_color,
			"customStyle3" = src.AH.customization_third.name,
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
			"hudThemePreview" = icon2base64(icon(hud_style_selection[hud_style], "preview")),
			"targetingCursor" = src.target_cursor,
			"targetingCursorPreview" = icon2base64(icon(cursors_selection[target_cursor])),
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
			"traitsAvailable" = traits,
			"traitsMax" = src.traitPreferences.max_traits,
			"traitsPointsTotal" = src.traitPreferences.point_total,
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
					sound_file = sounds_speak["[AH.voicetype]"]

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

			if ("save")
				var/index = params["index"]
				if (isnull(src.profile_name) || is_blank_string(src.profile_name))
					tgui_alert(usr, "You need to give your profile a name.", "Pick name")
					return

				if (!isnull(index) && isnum(index))
					src.savefile_save(client.key, index)
					src.profile_number = index
					boutput(usr, "<span class='notice'><b>Character saved to Slot [index].</b></span>")
					return TRUE

			if ("load")
				var/index = params["index"]
				if (!isnull(index) && isnum(index))
					if (!src.savefile_load(client, index))
						tgui_alert(usr, "You do not have a savefile.", "No savefile")
						return FALSE

					boutput(usr, "<span class='notice'><b>Character loaded from Slot [index].</b></span>")
					update_preview_icon()
					return TRUE

			if ("cloud-new")
				if (!client.cloud_available())
					return
				if(length(client.player.cloudsaves) >= SAVEFILE_CLOUD_PROFILES_MAX)
					tgui_alert(usr, "You have hit your cloud save limit. Please write over an existing save.", "Max saves")
				else
					var/new_name = tgui_input_text(usr, "What would you like to name the save?", "Save Name")
					if(length(new_name) < 3 || length(new_name) > MOB_NAME_MAX_LENGTH)
						tgui_alert(usr, "The name must be between 3 and [MOB_NAME_MAX_LENGTH] letters!", "Letter count out of range")
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
				var/new_profile_name = tgui_input_text(usr, "New profile name:", "Character Generation", src.profile_name)

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
				var/new_name = tgui_input_text(usr, "Please select a first name:", "Character Generation", src.name_first)
				if (isnull(new_name))
					return
				new_name = trim(new_name)
				for (var/c in bad_name_characters)
					new_name = replacetext(new_name, c, "")
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
					src.real_name = src.name_first + " " + src.name_last
					src.profile_modified = TRUE
					return TRUE

			if ("update-nameMiddle")
				var/new_name = tgui_input_text(usr, "Please select a middle name:", "Character Generation", src.name_middle)
				if (isnull(new_name))
					return
				new_name = trim(new_name)
				for (var/c in bad_name_characters)
					new_name = replacetext(new_name, c, "")
				if (length(new_name) > NAME_CHAR_MAX)
					tgui_alert(usr, "Your middle name is too long. It must be no more than [NAME_CHAR_MAX] characters long.", "Name too long")
					return
				else if (is_blank_string(new_name) && new_name != "")
					tgui_alert(usr, "Your middle name cannot contain only spaces.", "Blank name")
					return
				new_name = capitalize(new_name)
				src.name_middle = new_name // don't need to check if there is one in case someone wants no middle name I guess
				src.profile_modified = TRUE

				return TRUE

			if ("update-nameLast")
				var/new_name = tgui_input_text(usr, "Please select a last name:", "Character Generation", src.name_last)
				if (isnull(new_name))
					return
				new_name = trim(new_name)
				for (var/c in bad_name_characters)
					new_name = replacetext(new_name, c, "")
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
					src.real_name = src.name_first + " " + src.name_last
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
					AH.gender = FEMALE
				else
					src.gender = MALE
					AH.gender = MALE
				update_preview_icon()
				src.profile_modified = TRUE
				return TRUE

			if ("update-pronouns")
				if(isnull(AH.pronouns))
					AH.pronouns = get_singleton(/datum/pronouns/theyThem)
				else
					AH.pronouns = AH.pronouns.next_pronouns()
					if(AH.pronouns == get_singleton(/datum/pronouns/theyThem))
						AH.pronouns = null
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
					var/new_pin = tgui_input_number(usr, "Please select a PIN between 1000 and 9999", "Character Generation", src.pin || 1000, 9999, 1000)
					if (new_pin)
						src.pin = clamp(round(text2num(new_pin)), 1000, 9999)
						src.profile_modified = TRUE
						return TRUE

			if ("update-flavorText")
				var/new_text = tgui_input_text(usr, "Please enter new flavor text (appears when examining you):", "Character Generation", src.flavor_text, multiline = TRUE)
				if (!isnull(new_text))
					new_text = html_encode(new_text)
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						tgui_alert(usr, "Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.", "Flavor text too long")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					src.flavor_text = new_text
					src.profile_modified = TRUE

					return TRUE

			if ("update-securityNote")
				var/new_text = tgui_input_text(usr, "Please enter new flavor text (appears when examining your security record):", "Character Generation", src.security_note, multiline = TRUE)
				if (!isnull(new_text))
					new_text = html_encode(new_text)
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						tgui_alert(usr, "Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.", "Flavor text too long")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					src.security_note = new_text
					src.profile_modified = TRUE

					return TRUE

			if ("update-medicalNote")
				var/new_text = tgui_input_text(usr, "Please enter new flavor text (appears when examining your medical record):", "Character Generation", src.medical_note, multiline = TRUE)
				if (!isnull(new_text))
					new_text = html_encode(new_text)
					if (length(new_text) > FLAVOR_CHAR_LIMIT)
						tgui_alert(usr, "Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.", "Flavor text too long")
						new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
					src.medical_note = new_text
					src.profile_modified = TRUE

					return TRUE

			if ("update-pdaRingtone")
				get_all_character_setup_ringtones()
				if(!length(selectable_ringtones))
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
				var/new_color = input(usr, "Choose a color", "PDA", src.PDAcolor) as color | null
				if (!isnull(new_color))
					src.PDAcolor = new_color
					src.profile_modified = TRUE

					return TRUE

			if ("update-skinTone")
				var/new_tone = "#FEFEFE"
				if (usr.has_medal("Contributor"))
					switch(tgui_alert(usr, "Goonstation contributors get to pick any colour for their skin tone!", "Thanks, pal!", list("Paint me like a posh fence!", "Use Standard tone.", "Cancel")))
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
			if ("decrease-skinTone")
				var/units = 1
				if (params["alot"])
					units = 8
				var/list/L = hex_to_rgb_list(AH.s_tone)
				AH.s_tone = rgb(max(L[1]-units, 61), max(L[2]-units, 8), max(L[3]-units, 0))
				AH.s_tone_original = AH.s_tone

				update_preview_icon()
				src.profile_modified = TRUE
				return TRUE
			if ("increase-skinTone")
				var/units = 1
				if (params["alot"])
					units = 8
				var/list/L = hex_to_rgb_list(AH.s_tone)
				AH.s_tone = rgb(min(L[1]+units, 255), min(L[2]+units, 236), min(L[3]+units, 183))
				AH.s_tone_original = AH.s_tone

				update_preview_icon()
				src.profile_modified = TRUE
				return TRUE
			if ("update-specialStyle")
				var/mob/living/carbon/human/H = src.preview.preview_mob
				var/typeinfo/datum/mutantrace/typeinfo = H.mutantrace?.get_typeinfo()
				if (!typeinfo || !typeinfo.special_styles)
					tgui_alert(usr, "No usable special styles detected for this mutantrace.", "Error")
					return
				var/list/style_list = typeinfo.special_styles
				var/current_index = style_list.Find(AH.special_style) // do they already have a special style in their prefs
				var/new_style = style_list[current_index + 1 > length(style_list) ? 1 : current_index + 1]
				if (new_style)
					AH.special_style = new_style
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
						var/list/customization_types = concrete_typesof(/datum/customization_style) - concrete_typesof(/datum/customization_style/hair/gimmick)
						new_style = select_custom_style(customization_types, usr)
					if ("underwear")
						new_style = tgui_input_list(usr, "Select an underwear style", "Character Generation", underwear_styles)

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
						current_style = src.AH.customization_first.type
					if ("custom2")
						current_style = src.AH.customization_second.type
					if ("custom3")
						current_style = src.AH.customization_third.type
					if ("underwear")
						current_style = src.AH.underwear

				if (isnull(current_style))
					return

				switch(params["id"])
					if ("custom1", "custom2", "custom3")
						style_list = concrete_typesof(/datum/customization_style) - concrete_typesof(/datum/customization_style/hair/gimmick)
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
							src.AH.customization_first = new new_style
						if ("custom2")
							src.AH.customization_second = new new_style
						if ("custom3")
							src.AH.customization_third = new new_style
						if ("underwear")
							src.AH.underwear = new_style

					update_preview_icon()
					src.profile_modified = TRUE
					return TRUE

			if ("update-fartsound")
				var/list/sound_list = list_keys(AH.fartsounds)
				var/new_sound = tgui_input_list(usr, "Select a farting sound", "Fart sound", sound_list)

				if (new_sound)
					src.AH.fartsound = new_sound
					preview_sound(sound(src.AH.fartsounds[src.AH.fartsound]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-screamsound")
				var/list/sound_list = list_keys(AH.screamsounds)
				var/new_sound = tgui_input_list(usr, "Select a screaming sound", "Scream sound", sound_list)

				if (new_sound)
					src.AH.screamsound = new_sound
					preview_sound(sound(src.AH.screamsounds[src.AH.screamsound]))
					src.profile_modified = TRUE
					return TRUE

			if ("update-chatsound")
				var/list/sound_list = list_keys(AH.voicetypes)
				var/new_sound = tgui_input_list(usr, "Select a chatting sound", "Chat sound", sound_list)

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
					var/new_font_size = tgui_input_number(usr, "Desired font size (in percent):", "Font setting", src.font_size || 100, 100, 1)
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

			if ("select-trait")
				src.profile_modified = src.traitPreferences.selectTrait(params["id"])
				return TRUE

			if ("unselect-trait")
				src.profile_modified = src.traitPreferences.unselectTrait(params["id"])
				return TRUE

			if ("reset-traits")
				src.traitPreferences.resetTraits()
				src.profile_modified = TRUE
				return TRUE

			if ("reset")
				src.profile_modified = TRUE

				src.gender = MALE
				AH.gender = MALE
				randomize_name()

				AH.customization_first = new /datum/customization_style/hair/short/short
				AH.customization_second = new /datum/customization_style/none
				AH.customization_third = new /datum/customization_style/none
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
				be_syndicate_commander = 0
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
			usr.playsound_local(usr, S, 100)

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
			logTheThing(LOG_DEBUG, usr ? usr : null, null, "a preference datum's appearence holder is null!")
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
			logTheThing(LOG_DEBUG, usr ? usr : null, null, "a preference datum's appearence holder is null!")
			return

		var/datum/mutantrace/mutantRace = null
		for (var/ID in traitPreferences.traits_selected)
			var/datum/trait/T = getTraitById(ID)
			if (T?.mutantRace)
				mutantRace = T.mutantRace
				break

		src.preview?.update_appearance(src.AH, mutantRace, src.spessman_direction, name=src.real_name)

		// bald trait preview stuff
		if (!src.preview)
			return
		var/mob/living/carbon/human/H = src.preview.preview_mob
		var/ourWig = H.head
		if (ourWig)
			H.u_equip(ourWig)
			qdel(ourWig)

		if (traitPreferences.traits_selected.Find("bald") && mutantRace)
			H.equip_if_possible(H.create_wig(), H.slot_head)

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
			if (jobban_isbanned(user,J.name) || (J.needs_college && !user.has_medal("Unlike the director, I went to college")) || (J.requires_whitelist && !NT.Find(user.ckey || ckey(user.mind?.key))) || istype(J, /datum/job/command) || istype(J, /datum/job/civilian/AI) || istype(J, /datum/job/civilian/cyborg) || istype(J, /datum/job/security/security_officer))
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
		if (user?.client?.player.get_rounds_participated() < TEAM_BASED_ROUND_REQUIREMENT)
			HTML += "You need to play at least [TEAM_BASED_ROUND_REQUIREMENT] rounds to play group-based antagonists."
			src.be_syndicate = FALSE
			src.be_syndicate_commander = FALSE
			src.be_gangleader = FALSE
			src.be_revhead = FALSE
			src.be_conspirator = FALSE
		if (jobban_isbanned(user, "Syndicate"))
			HTML += "You are banned from playing antagonist roles."
			src.be_traitor = FALSE
			src.be_syndicate = FALSE
			src.be_syndicate_commander = FALSE
			src.be_spy = FALSE
			src.be_gangleader = FALSE
			src.be_revhead = FALSE
			src.be_changeling = FALSE
			src.be_wizard = FALSE
			src.be_werewolf = FALSE
			src.be_vampire = FALSE
			src.be_arcfiend = FALSE
			src.be_wraith = FALSE
			src.be_blob = FALSE
			src.be_conspirator = FALSE
			src.be_flock = FALSE
		else

			HTML += {"
			<a href="byond://?src=\ref[src];preferences=1;b_traitor=1" class="[src.be_traitor ? "yup" : "nope"]">[crap_checkbox(src.be_traitor)] Traitor</a>
			<a href="byond://?src=\ref[src];preferences=1;b_syndicate=1" class="[src.be_syndicate ? "yup" : "nope"]">[crap_checkbox(src.be_syndicate)] Nuclear Operative</a>
			<a href="byond://?src=\ref[src];preferences=1;b_syndicate_commander=1" class="[src.be_syndicate_commander ? "yup" : "nope"]">[crap_checkbox(src.be_syndicate_commander)] Nuclear Operative Commander</a>
			<a href="byond://?src=\ref[src];preferences=1;b_spy=1" class="[src.be_spy ? "yup" : "nope"]">[crap_checkbox(src.be_spy)] Spy/Thief</a>
			<a href="byond://?src=\ref[src];preferences=1;b_gangleader=1" class="[src.be_gangleader ? "yup" : "nope"]">[crap_checkbox(src.be_gangleader)] Gang Leader</a>
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

			picker = tgui_input_list(usr, "Which bracket would you like to move this job to?", "Job Preferences", valid_actions)
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

		if (link_tags["closejobswindow"])
			user.Browse(null, "window=mob_occupation")
			src.ShowChoices(user)
			return

		if (link_tags["resetalljobs"])
			var/resetwhat = tgui_input_list(usr, "Reset all jobs to which level?", "Job Preferences", list("Medium Priority", "Low Priority", "Unwanted"))
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

		if (link_tags["b_syndicate_commander"])
			src.be_syndicate_commander = !( src.be_syndicate_commander )
			src.be_syndicate |= src.be_syndicate_commander
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

		if (link_tags["b_arcfiend"])
			src.be_arcfiend = !( src.be_arcfiend)
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

	proc/copy_to(mob/living/character,var/mob/user,ignore_randomizer = 0, skip_post_new_stuff=FALSE)
		sanitize_null_values()
		if (!ignore_randomizer)
			if (be_random_name)
				randomize_name()

			if (be_random_look)
				randomizeLook()

			if (character.bioHolder)
				if (random_blood)
					character.bioHolder.bloodType = random_blood_type()
				else
					character.bioHolder.bloodType = blType

			SPAWN(0) // avoid blocking
				if(jobban_isbanned(user, "Custom Names"))
					randomize_name()
					randomizeLook()
					character.bioHolder?.bloodType = random_blood_type()
					src.copy_to(character, user, TRUE) // apply the other stuff again but with the random name

		//character.real_name = real_name
		src.real_name = src.name_first + " " + src.name_last
		character.real_name = src.real_name

		//Wire: Not everything has a bioholder you morons
		if (character.bioHolder)
			character.bioHolder.age = age
			character.bioHolder.mobAppearance.CopyOther(AH)
			character.bioHolder.mobAppearance.gender = src.gender
			if (!src.be_random_name)
				character.bioHolder.mobAppearance.flavor_text = src.flavor_text

		//Also I think stuff other than human mobs can call this proc jesus christ
		if (ishuman(character))
			var/mob/living/carbon/human/H = character
			H.pin = pin
			H.gender = src.gender
			//H.desc = src.flavor_text

		if (!skip_post_new_stuff)
			apply_post_new_stuff(character)

		character.update_face()
		character.update_body()

		character.sound_scream = AH.screamsounds[AH.screamsound || "default"] || AH.screamsounds["default"]
		character.sound_fart = AH.fartsounds[AH.fartsound || "default"] || AH.fartsounds["default"]
		character.voice_type = AH.voicetype || RANDOM_HUMAN_VOICE

		if (ishuman(character))
			var/mob/living/carbon/human/H = character
			if (H.mutantrace && H.mutantrace.voice_override)
				H.voice_type = H.mutantrace.voice_override

	proc/apply_post_new_stuff(mob/living/character)
		if(ishuman(character))
			var/mob/living/carbon/human/H = character
			if (H?.organHolder?.head?.donor_appearance) // aaaa
				H.organHolder.head.donor_appearance.CopyOther(AH)
		if (traitPreferences.isValid() && character.traitHolder)
			for (var/T in traitPreferences.traits_selected)
				character.traitHolder.addTrait(T)

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
			AH.customization_first = new  /datum/customization_style/none
		if (AH.customization_second_color == null)
			AH.customization_second_color = "#101010"
		if (AH.customization_second == null)
			AH.customization_second = new /datum/customization_style/none
		if (AH.customization_third_color == null)
			AH.customization_third_color = "#101010"
		if (AH.customization_third == null)
			AH.customization_third = new /datum/customization_style/none
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

proc/isfem(datum/customization_style/style)
	return !!(initial(style.gender) & FEMININE)

proc/ismasc(datum/customization_style/style)
	return !!(initial(style.gender) & MASCULINE)

// this is weird but basically: a list of hairstyles and their appropriate detail styles, aka hair_details["80s"] would return the Hairmetal: Faded style
// further on in the randomize_look() proc we'll see if we've got one of the styles in here and if so, we have a chance to add the detailing
// if it's a list then we'll pick from the options in the list
var/global/list/hair_details = list("einstein" = /datum/customization_style/hair/short/einalt,\
	"80s" = /datum/customization_style/hair/long/eightiesfade,\
	"glammetal" = /datum/customization_style/hair/long/glammetalO,\
	"lionsmane" = /datum/customization_style/hair/long/lionsmane_fade,\
	"longwaves" = /datum/customization_style/hair/long/longwaves_fade,\
	"ripley" = /datum/customization_style/hair/long/ripley_fade,\
	"violet" = /datum/customization_style/hair/long/violet_fade,\
	"willow" = /datum/customization_style/hair/long/willow_fade,\
	"rockponytail" = /datum/customization_style/hair/hairup/rockponytail_fade,\
	"pompompigtail" = /datum/customization_style/hair/long/flatbangs, /datum/customization_style/hair/long/twobangs_long,\
	"breezy" = /datum/customization_style/hair/long/breezy_fade,\
	"flick" = /datum/customization_style/hair/short/flick_fade,\
	"mermaid" = /datum/customization_style/hair/long/mermaidfade,\
	"smoothwave" = /datum/customization_style/hair/long/smoothwave_fade,\
	"longbeard" = /datum/customization_style/beard/longbeardfade,\
	"pomp" = /datum/customization_style/hair/short/pompS,\
	"mohawk" = list(/datum/customization_style/hair/short/mohawkFT, /datum/customization_style/hair/short/mohawkFB, /datum/customization_style/hair/short/mohawkS),\
	"emo" = /datum/customization_style/hair/short/emoH,\
	"clown" = list(/datum/customization_style/hair/short/clownT, /datum/customization_style/hair/short/clownM, /datum/customization_style/hair/short/clownB),\
	"dreads" = /datum/customization_style/hair/long/dreadsA,\
	"afro" = list(/datum/customization_style/hair/short/afroHR, /datum/customization_style/hair/short/afroHL, /datum/customization_style/hair/short/afroST, /datum/customization_style/hair/short/afroSM, /datum/customization_style/hair/short/afroSB, /datum/customization_style/hair/short/afroSL, /datum/customization_style/hair/short/afroSR, /datum/customization_style/hair/short/afroSC, /datum/customization_style/hair/short/afroCNE, /datum/customization_style/hair/short/afroCNW, /datum/customization_style/hair/short/afroCSE, /datum/customization_style/hair/short/afroCSW, /datum/customization_style/hair/short/afroSV, /datum/customization_style/hair/short/afroSH))

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
	var/type_first
	if (AH.gender == MALE)
		if (prob(5)) // small chance to have a hairstyle more geared to the other gender
			type_first = pick(filtered_concrete_typesof(/datum/customization_style,.proc/isfem))
			AH.customization_first = new type_first
		else // otherwise just use one standard to the current gender
			type_first = pick(filtered_concrete_typesof(/datum/customization_style,.proc/ismasc))
			AH.customization_first = new type_first

		if (prob(33)) // since we're a guy, a chance for facial hair
			var/type_second = pick(concrete_typesof(/datum/customization_style/beard) + concrete_typesof(/datum/customization_style/moustache))
			AH.customization_second = new type_second
			has_second = 1 // so the detail check doesn't do anything - we already got a secondary thing!!

	else // if FEMALE
		if (prob(8)) // same as above for guys, just reversed and with a slightly higher chance since it's ~more appropriate~ for ladies to have guy haircuts than vice versa  :I
			type_first = pick(filtered_concrete_typesof(/datum/customization_style,.proc/ismasc))
			AH.customization_first = new type_first
		else // ss13 is coded with gender stereotypes IN ITS VERY CORE
			type_first = pick(filtered_concrete_typesof(/datum/customization_style,.proc/isfem))
			AH.customization_first = new type_first

	if (!has_second)
		var/hair_detail = hair_details[AH.customization_first.name] // check for detail styles for our chosen style

		if (hair_detail && prob(50)) // found something in the list
			AH.customization_second = new hair_detail // default to being whatever we found

			if (islist(hair_detail)) // if we found a bunch of things in the list
				var/type_second = pick(hair_detail) // let's choose just one (we don't need to assign a list as someone's hair detail)
				AH.customization_second = new type_second
				if (prob(20)) // with a small chance for another detail thing
					var/type_third = pick(hair_detail)
					AH.customization_third = new type_third
					AH.customization_third_color = random_saturated_hex_color()
					if (prob(5))
						AH.customization_third_color = randomize_hair_color(pick(hair_colors))
				else
					AH.customization_third = new /datum/customization_style/none

			AH.customization_second_color = random_saturated_hex_color() // if you have a detail style you're likely to want a crazy color
			if (prob(15))
				AH.customization_second_color = randomize_hair_color(pick(hair_colors)) // but have a chance to be a normal hair color

		else if (prob(5)) // chance for a special eye color
			var/type_second = pick(/datum/customization_style/biological/hetcroL, /datum/customization_style/biological/hetcroR)
			AH.customization_second = new type_second
			if (prob(75))
				AH.customization_second_color = random_saturated_hex_color()
			else
				AH.customization_second_color = randomize_eye_color(pick(eye_colors))
			AH.customization_third = new /datum/customization_style/none

		else // otherwise, nada
			AH.customization_second = new /datum/customization_style/none
			AH.customization_third = new /datum/customization_style/none

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

	SPAWN(1 DECI SECOND)
		H?.update_colorful_parts()

// Generates a real crap checkbox for html toggle links.
// it sucks but it's a bit more readable i guess.
/proc/crap_checkbox(var/checked)
	if (checked) return "&#9745;"
	else return "&#9744;"
