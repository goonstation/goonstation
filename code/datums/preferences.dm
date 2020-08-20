var/list/bad_name_characters = list("_", "'", "\"", "<", ">", ";", "\[", "\]", "{", "}", "|", "\\", "/")

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


	var/be_changeling = 0
	var/be_revhead = 0
	var/be_syndicate = 0
	var/be_wizard = 0
	var/be_traitor = 0
	var/be_werewolf = 0
	var/be_vampire = 0
	var/be_spy = 0
	var/be_gangleader = 0
	var/be_wraith = 0
	var/be_blob = 0
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
	var/use_wasd = 1
	var/use_azerty = 0 // do they have an AZERTY keyboard?
	var/spessman_direction = SOUTH

	var/job_favorite = null
	var/list/jobs_med_priority = list()
	var/list/jobs_low_priority = list()
	var/list/jobs_unwanted = list()

	var/datum/appearanceHolder/AH = new

	var/random = 0
	var/random2 = 0
	var/random3 = 0

	var/icon/preview_icon = null

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

	proc/randomize_name(var/first = 1, var/middle = 1, var/last = 1)
		//real_name = random_name(src.gender)
		if (src.gender == MALE)
			if (first)
				src.name_first = capitalize(pick(first_names_male))
			if (middle)
				src.name_middle = capitalize(pick(first_names_male))
		else
			if (first)
				src.name_first = capitalize(pick(first_names_female))
			if (middle)
				src.name_middle = capitalize(pick(first_names_female))
		if (last)
			src.name_last = capitalize(pick(last_names))
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
/*		var/list/namecheck = splittext(trim(real_name), " ")
		if (namecheck.len < 2 || length(real_name) < 5)
			randomize_name()
			return
		for (var/i = 1, i <= namecheck.len, i++)
			namecheck[i] = capitalize(namecheck[i])
		real_name = jointext(namecheck, " ")
*/
	proc/update_preview_icon()
		//qdel(src.preview_icon)
		if (!AH)
			logTheThing("debug", usr ? usr : null, null, "a preference datum's appearence holder is null!")
			return

		src.preview_icon = null

		src.preview_icon = new /icon('icons/mob/human.dmi', "body_[src.gender == MALE ? "m" : "f"]", "dir" = src.spessman_direction)

		// Skin tone
		if (AH.s_tone)
			src.preview_icon.Blend(AH.s_tone, ICON_MULTIPLY)

		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = "eyes", "dir" = src.spessman_direction)
		if (is_valid_color_string(AH.e_color))
			eyes_s.Blend(AH.e_color, ICON_MULTIPLY)
		else
			eyes_s.Blend("#101010", ICON_MULTIPLY)

		var/customization_first_r = customization_styles[AH.customization_first]
		if (!customization_first_r)
			customization_first_r = "None"

		var/customization_second_r = customization_styles[AH.customization_second]
		if (!customization_second_r)
			customization_second_r = "None"

		var/customization_third_r = customization_styles[AH.customization_third]
		if (!customization_third_r)
			customization_third_r = "none"

		var/icon/hair_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = customization_first_r, "dir" = src.spessman_direction)
		if (is_valid_color_string(AH.customization_first_color))
			hair_s.Blend(AH.customization_first_color, ICON_MULTIPLY)
		else
			hair_s.Blend("#101010", ICON_MULTIPLY)

		var/icon/facial_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = customization_second_r, "dir" = src.spessman_direction)
		if (is_valid_color_string(AH.customization_second_color))
			facial_s.Blend(AH.customization_second_color, ICON_MULTIPLY)
		else
			facial_s.Blend("#101010", ICON_MULTIPLY)

		var/icon/detail_s = new/icon("icon" = 'icons/mob/human_hair.dmi', "icon_state" = customization_third_r, "dir" = src.spessman_direction)
		if (is_valid_color_string(AH.customization_third_color))
			detail_s.Blend(AH.customization_third_color, ICON_MULTIPLY)
		else
			detail_s.Blend("#101010", ICON_MULTIPLY)

		var/underwear_style = underwear_styles[AH.underwear]
		var/icon/underwear_s = new/icon("icon" = 'icons/mob/human_underwear.dmi', "icon_state" = "[underwear_style]", "dir" = src.spessman_direction)
		if (is_valid_color_string(AH.u_color))
			underwear_s.Blend(AH.u_color, ICON_MULTIPLY)

		eyes_s.Blend(underwear_s, ICON_OVERLAY)
		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)
		eyes_s.Blend(detail_s, ICON_OVERLAY)

		src.preview_icon.Blend(eyes_s, ICON_OVERLAY)

		facial_s = null
		hair_s = null
		underwear_s = null
		eyes_s = null

	var/list/profile_cache
	var/rebuild_profile

	var/list/rebuild_data
	var/list/data_cache

	proc/ShowChoices(mob/user)
		LAGCHECK(LAG_HIGH)

		if(!user)
			return

		if (!AH)
			boutput(usr, "Your settings are missing an AppearanceHolder. This is a good time to tell a coder.")

		if (!data_cache)
			data_cache = list("script" = null,"css" = null,"profile_name" = null,"character_name" = null,"gender" = null,"age_blood" = null,\
								"bank" = null,"flavortext" = null,"security_note" = null,"medical_note" = null,"occupation" = null,"traits" = null,\
								"fartsound" = null,"screamsound" = null,"chatsound" = null,"skintone" = null,"eyecolor" = null,"hair_top" = null,"hair_mid" = null,"hair_bottom" = null,\
								"underwear" = null,"randomize" = null,"font_size" = null,"messages" = null,"hud" = null,"tooltips" = null, "tgui" = null,"popups" = null,"controls" = null,"map"=null)
			rebuild_data = list("script" = 1,"css" = 1,"profile_name" = 1,"character_name" = 1,"gender" = 1,"age_blood" = 1,\
								"bank" = 1,"flavortext" = 1,"security_note" = 1,"medical_note" = 1,"occupation" = 1,"traits" = 1,\
								"fartsound" = 1,"screamsound" = 1,"chatsound" = 1,"skintone" = 1,"eyecolor" = 1,"hair_top" = 1,"hair_mid" = 1,"hair_bottom" = 1,\
								"underwear" = 1,"randomize" = 1,"font_size" = 1,"messages" = 1,"hud" = 1,"tooltips" = 1, "tgui" = 1, "popups" = 1,"controls" = 1,"map"=1)
		if (!profile_cache)
			profile_cache = list()
			rebuild_profile = 1

		sanitize_null_values()
		update_preview_icon()
		LAGCHECK(LAG_HIGH)
		user << browse_rsc(preview_icon, "previewicon.png")
		user << browse_rsc(icon(cursors_selection[target_cursor]), "tcursor.png")
		user << browse_rsc(icon(hud_style_selection[hud_style], "preview"), "hud_preview.png")
		LAGCHECK(LAG_HIGH)
		var/display_gender = (src.gender == MALE ? "Male" : "Female") + " " + (!AH.pronouns ? (src.gender == MALE ? "(he/him)" : "(she/her)") : "(they/them)")

		var/favoriteJob = src.job_favorite ? find_job_in_controller_by_string(src.job_favorite) : ""
		//mbc is sorry
		var/chui_toggle_script_jqery_thing = (user && user.client && !user.client.use_chui) ? "<script type='text/javascript' src='[resource("js/jquery.min.js")]'></script>" : ""

		LAGCHECK(LAG_HIGH)
		//mbc is sorry
		//var/header_thing_chui_toggle = (user.client && !user.client.use_chui) ? "<html><head><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\"><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><meta http-equiv=\"pragma\" content=\"no-cache\"><style type='text/css'>body { font-family: Tahoma, sans-serif; font-size: 10pt; }</style></head><body>" : ""
		//var/pref_link = "byond://?src=\ref[src];preferences=1;"
		var/pref_link = "byond://?src=\ref[src];preferences=1;"

		//var/profile_menu[]

		if (user && !IsGuestKey(user.key)) //ZeWaka: Fix for null.key
			if (rebuild_profile)
				rebuild_profile = 0
				profile_cache.len = 0
				profile_cache += "<div id='cloudsaves'><strong>Cloud Saves</strong><hr>"
				var/client/wtf = ismob( user ) ? user.client : user
				for( var/name in wtf.cloudsaves )
					profile_cache += "<a href='[pref_link]cloudload=[url_encode(name)]'>[html_encode(name)]</a> (<a href='[pref_link]cloudsave=[url_encode(name)]'>Save</a> - <a href='[pref_link]clouddelete=[url_encode(name)]'>Delete</a>)<br>"
					LAGCHECK(LAG_REALTIME)
				profile_cache += "<a href='[pref_link]cloudnew=1'>Create new save</a></div>"

				profile_cache += {"
	<div id="profiles">
	"}
				for (var/i = 1, i <= SAVEFILE_PROFILES_MAX, i++)
					profile_cache += {"
		<div[i == src.profile_number ? " id='profiles-active'" : ""]><a href='[pref_link]load=[i]'>Profile [i]</a>
		<br><strong>[savefile_get_profile_name(user, i) || "<em>(empty)</em>"]</strong>
		<br><a href='[pref_link]save=[i]'>Save</a> &middot; <a href='[pref_link]load=[i]'>Load</a></div>
					"}
					LAGCHECK(LAG_REALTIME)

				profile_cache += "</div>"

		var/unsaved_changes_warning = ""
		if (src.profile_modified)
			unsaved_changes_warning = {"<div id="unsaved-warning"><strong>You may have unsaved changes.</strong><br>Any unsaved changes will take effect for this round only.</div> "}
		//var/list/dat = list()
		LAGCHECK(LAG_MED)

		data_cache["script"] = {"
[chui_toggle_script_jqery_thing]
<script type='text/javascript'>
$(function() {
	function SwitchPic(picID) {
		var pic = document.getElementById(picID);
		var d = new Date();
		var image='previewicon.png?'+d.getMilliseconds();
		setTimeout(function(){
			pic.src = image;

			}, 500)
	}
	//stole this debounce function from Kfir Zuberi at https://medium.com/walkme-engineering/debounce-and-throttle-in-real-life-scenarios-1cc7e2e38c68
	function debounce (func, interval) {
		var timeout;
		return function () {
			var context = this, args = arguments;
			var later = function () {
				timeout = null;
				func.apply(context, args);
			};
			clearTimeout(timeout);
			timeout = setTimeout(later, interval || 200);
		}
	}
	 var update_image = debounce(function(){
			var id = $(this).attr('id')
		var r = $("#" + id + " option:selected" ).text();
		window.location='byond://?src=\ref[src];preferences=1;id='+id+';style='+encodeURIComponent(r);
		SwitchPic("sprite_preview");
	}, 250);
	$(function() {
		$('select').change(update_image)
	})
});
</script>"}

		LAGCHECK(LAG_HIGH)

		if (rebuild_data["css"])
			rebuild_data["css"] = 0
			data_cache["css"] = {"
<style type="text/css">
	a:link {
		text-decoration: none;
		}
	a:hover {
		background-color: rgba(0, 0, 100, 0.3);
		}
	a.toggle {
		color: inherit;
		background: rgba(120, 120, 120, 0.2);
		text-decoration: none;
		padding: 0.05em 0.4em;
		margin: 0.1em;
		display: inline-block;
		text-decoration: none;
	}
	table#prefs {
		border-collapse: collapse;
		font-size: 100%;
		width: 100%;
	}
	td, th {
		border: 1px solid #888;
		padding: 0.1em 0.3em;
	}
	th {
		background: rgba(125, 125, 125, 0.4);
		white-space: nowrap;
	}

	th\[colspan="3"] {
		background: rgba(125, 125, 125, 0.6);
		padding: 0.5em;
	}

	.colorbit {
		font-family: monospace;
		display: inline-block;
		border: 1px solid black;
		font-size: 80%;
		padding: 0 0.3em;
		padding-left: 1.5em;
		border-radius: 10px;
		color: white;
		text-shadow:
			1px 1px 0 #000,
			1px 0px 0 #000,
			0px 1px 0 #000,
			0px -1px 0 #000;
	}

	#cloudsaves {
		float: right;
		z-index: 99999999999; /* i loev html */
	}
	#profiles {
		z-index: 50;
	}
	#profiles > div {
		text-align: center;
		padding: 0.1em 0.25em;
		margin-bottom: 0.25em;
		margin-right: 0.25em;
		display: inline-block;
		border: 1px dotted #666;
		background-color: rgba(128, 128, 128, 0.2);
	}
	#profiles > div:hover {
		background-color: rgba(128, 128, 128, 0.5);
	}
	#profiles > div#profiles-active {
		position: relative;
		border: 1px solid #888;
		background-color: rgba(200, 210, 230, 0.2);
	}
	#profiles > div em {
		font-weight: normal;
	}
	#unsaved-warning {
		max-width: 400px;
		padding: 0.2em 0.5em;
		text-align: center;
		margin: 0.5em auto;
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
</style>"}
		LAGCHECK(80)
		if (rebuild_data["profile_name"])
			rebuild_data["profile_name"] = 0
			data_cache["profile_name"] = {"
<title>Character Setup</title>
[jointext(profile_cache, "")]
<div style="clear: both; margin: 0.5em;"></div>
[unsaved_changes_warning]
<table id="prefs">
	<tr>
		<th colspan="3">Character Setup</th>
	</tr>
	<tr>
		<th>Profile Name<span class="info-thing" title="Name of the profile, used in the list above. Your first profile is the one that's loaded by default.">?</span></th>
		<td colspan="2">
			<a href="[pref_link]profile_name=input">[src.profile_name ? src.profile_name : "Unnamed"]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["character_name"])
			rebuild_data["character_name"] = 0
			data_cache["character_name"] = {"
	<tr>
		<th>Name<span class="info-thing" title="Your character's name.">?</span></th>
		<td colspan="2">
			<a href="[pref_link]first_name=input">[length(src.name_first) ? src.name_first : "_"]</a>
			<a href="[pref_link]middle_name=input">[length(src.name_middle) ? src.name_middle : "_"]</a>
			<a href="[pref_link]last_name=input">[length(src.name_last) ? src.name_last : "_"]</a>
			<br><a href="[pref_link]b_random_name=1" class="toggle">[crap_checkbox(src.be_random_name)] Use a random name instead</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["gender"])
			rebuild_data["gender"] = 0
			data_cache["gender"] = {"
	<tr>
		<th>
			Gender<span class="info-thing" title="Your character's gender and pronouns.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]gender=input">[display_gender]</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["age_blood"])
			rebuild_data["age_blood"] = 0
			data_cache["age_blood"] = {"
	<tr>
		<th>
			Age<span class="info-thing" title="Your character's age. Determines the pitch of your screams and farts (lower is deeper) but otherwise has no effect.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]age=input'>[src.age]</a>
	<tr>
		<th>
			Blood Type<span class="info-thing" title="Your character's blood type. Doesn't affect anything (yet) but shows up in records.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]blType=input'>[src.random_blood ? "Random" : src.blType]</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["bank"])
			rebuild_data["bank"] = 0
			data_cache["bank"] = {"
	<tr>
		<th>
			Bank PIN<span class="info-thing" title="The PIN you use when using your ID card at an ATM or vending machine. You can check what your PIN is at any time by using the 'Notes' command, under the Commands tab in the top right.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]pin=random" class="toggle">[crap_checkbox(!(src.pin))] Random</a> &middot; <a href='[pref_link]pin=input' class="toggle">[src.pin ? (crap_checkbox(1) + " Set: [src.pin]") : (crap_checkbox(0) + " Set")]</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["flavortext"])
			rebuild_data["flavortext"] = 0
			data_cache["flavortext"] = {"
	<tr>
		<th>
			Flavor Text<span class="info-thing" title="This text is shown when examining your character.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]flavor_text=input' style="float: left; margin: 0.2em;">&#9998;</a>
			[length(src.flavor_text) ? src.flavor_text : "<em>None</em>"]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["security_note"])
			rebuild_data["security_note"] = 0
			data_cache["security_note"] = {"
	<tr>
		<th>
			Security Note<span class="info-thing" title="This text is added to your Security Record. It has no other effects.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]security_flavor_text=input' style="float: left; margin: 0.2em;">&#9998;</a>
			[length(src.security_note) ? src.security_note : "<em>None</em>"]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["medical_note"])
			rebuild_data["medical_note"] = 0
			data_cache["medical_note"] = {"
	<tr>
		<th>
			Medical Note<span class="info-thing" title="This text is added to your Medical Record. It has no other effects.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]medical_flavor_text=input' style="float: left; margin: 0.2em;">&#9998;</a>
			[length(src.medical_note) ? src.medical_note : "<em>None</em>"]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["occupation"])
			rebuild_data["occupation"] = 1 //always rebuild egh
			data_cache["occupation"] = {"
	<tr>
		<th>
			Occupation<span class="info-thing" title="These are your occupation / job preferences. This only affects your job if you join when a round starts.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]jobswindow=1">Change occupation preferences...</a><br><em>Favorite job: [favoriteJob ? "<strong>[favoriteJob]</strong>" : "(unset)"]</em>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["traits"])
			rebuild_data["traits"] = 1 //always rebuild egh
			data_cache["traits"] = {"
	<tr>
		<th>
			Traits<span class="info-thing" title="Traits are quirks and oddities you can give your character. They can affect things from giving your character accents or robot arms.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]traitswindow=1">Choose traits...</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["fartsound"])
			rebuild_data["fartsound"] = 0
			data_cache["fartsound"] = {"
	<tr>
		<th>
			Fart Sound<span class="info-thing" title="This is the sound your character makes when they fart. You will hear it a lot, so pick a good one.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]fartsound=input'>[AH.fartsound]</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["screamsound"])
			rebuild_data["screamsound"] = 0
			data_cache["screamsound"] = {"
	<tr>
		<th>
			Scream Sound<span class="info-thing" title="This is the sound your character makes when they scream.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]screamsound=input'>[AH.screamsound]</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["chatsound"])
			rebuild_data["chatsound"] = 0
			data_cache["chatsound"] = {"
	<tr>
		<th>
			Chat Sound<span class="info-thing" title="This sound will play when your character says something. It's very quiet, though.">?</span>
		</th>
		<td colspan="2">
			<a href='[pref_link]voicetype=input'>[AH.voicetype]</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["skintone"])
			rebuild_data["skintone"] = 0
			data_cache["skintone"] = {"
	<tr>
		<th colspan="3">
			Character Appearance
		</th>
	</tr>
	<tr>
		<th>
			Skin Tone<span class="info-thing" title="Your character's skin tone.">?</span>
		</th>
		<td>
			<a href='[pref_link]s_tone=input'>&#9998;</a>
			<span class='colorbit' style="background-color: [AH.s_tone];">[AH.s_tone]</span>
		</td>
		<td rowspan="6" style="vertical-align: middle; text-align: center;">
			<strong>Preview</strong><br>
			<img style="-ms-interpolation-mode:nearest-neighbor;" src="previewicon.png" id='sprite_preview' height="64" width="64" title="It's you!"><br>
			<a href="[pref_link]rotate_counter_clockwise=1">&#x27f2;</a>
			<a href="[pref_link]rotate_clockwise=1">&#x27f3;</a>
		</th>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["eyecolor"])
			rebuild_data["eyecolor"] = 0
			data_cache["eyecolor"] = {"
	<tr>
		<th>
			Eye Color<span class="info-thing" title="Your character's eye color. You can use one of the detail slots for heterochromia.">?</span>
		</th>
		<td>
			<a href='[pref_link]eyes=input'>&#9998;</a>
			<span class='colorbit' style="background-color: [AH.e_color];">[AH.e_color]</span>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["hair_top"])
			rebuild_data["hair_top"] = 0
			data_cache["hair_top"] = {"
	<tr>
		<th>
			Top Detail<span class="info-thing" title="Hair or other features. This one is applied above the other ones.">?</span>
		</th>
		<td>
			<a href='[pref_link]detail=input'>&#9998;</a>
			<span class='colorbit' style="background-color: [AH.customization_third_color];">[AH.customization_third_color]</span>
			[generate_select_table("custom_third", AH.customization_third, customization_styles)]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["hair_mid"])
			rebuild_data["hair_mid"] = 0
			data_cache["hair_mid"] = {"
	<tr>
		<th>
			Mid Detail<span class="info-thing" title="Hair or other features. This one is placed between the top and bottom detail.">?</span>
		</th>
		<td>
			<a href='[pref_link]facial=input'>&#9998;</a>
			<span class='colorbit' style="background-color: [AH.customization_second_color];">[AH.customization_second_color]</span>
			[generate_select_table("custom_second", AH.customization_second, customization_styles)]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["hair_bottom"])
			rebuild_data["hair_bottom"] = 0
			data_cache["hair_bottom"] = {"
	<tr>
		<th>
			Bottom Detail<span class="info-thing" title="Hair or other features. This one is placed at under the others, making it the best choice for things like beards.">?</span>
		</th>
		<td>
			<a href='[pref_link]hair=input'>&#9998;</a>
			<span class='colorbit' style="background-color: [AH.customization_first_color];">[AH.customization_first_color]</span>
			[generate_select_table("custom_first", AH.customization_first, customization_styles)]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["underwear"])
			rebuild_data["underwear"] = 0
			data_cache["underwear"] = {"
	<tr>
		<th>
			Underwear<span class="info-thing" title="These are the clothes that your character will wear under their jumpsuit/uniform, and when freshly cloned.">?</span>
		</th>
		<td>
			<a href='[pref_link]underwear_color=input'>&#9998;</a>
			<span class='colorbit' style="background-color: [AH.u_color];">[AH.u_color]</span>
			[generate_select_table("underwear", AH.underwear, underwear_styles)]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["randomize"])
			rebuild_data["randomize"] = 0
			data_cache["randomize"] = {"
	<tr>
		<th>
			Randomization<span class="info-thing" title="You can let the game randomly make an appearance for you here. Note that the randomizer has even less of a sense of style than you do, so it might look weird.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]b_random_look=1" class="toggle">[crap_checkbox(src.be_random_look)] Always use a randomized appearance</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["font_size"])
			rebuild_data["font_size"] = 0
			data_cache["font_size"] = {"


	<tr>
		<th colspan="3">
			Game Settings
		</th>
	</tr>
	<tr>
		<th>
			Popup Font Size<span class="info-thing" title="Changes the font size used in popup windows. Only works when CHUI is disabled at the moment. CHUI support coming soon™.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]font_size=input">[src.font_size ? "[src.font_size]%" : "Default"]
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["messages"])
			rebuild_data["messages"] = 0
			data_cache["messages"] = {"
	<tr>
		<th>
			Messages<span class="info-thing" title="Toggles if certain messages are shown in the chat window by default. You can change these mid-round by using the Toggle OOC/LOOC commands under the Commands tab in the top right.">?</span>
		</th>
		<td colspan="2">
			[((user && ismob(user)) && user.client && user.client.is_mentor()) ? "<a href=\"[pref_link]toggle_mentorhelp=1\" class=\"toggle\">[crap_checkbox(src.see_mentor_pms)] Display Mentorhelps</a><span class=\"info-thing\" title=\"[pick("how to forgot swedish?", "how i collect urine", "why do i exploded", "I'm just punching myself with food.", "no im a wizard and i ate a bean and it said 'Oh yeah! This tastes like Pina colada' and I was erased.")]\">?</span><br>" : ""]
			<a href="[pref_link]listen_ooc=1" class="toggle">[crap_checkbox(src.listen_ooc)] Display <abbr title="Out-of-Character">OOC</abbr> chat</a><span class="info-thing" title="Out-of-Character chat. This mostly just shows up on the RP server and at the end of rounds.">?</span><br>
			<a href="[pref_link]listen_looc=1" class="toggle">[crap_checkbox(src.listen_looc)] Display <abbr title="Local Out-of-Character">LOOC</abbr> chat</a><span class="info-thing" title="Local Out-of-Character is OOC chat, but only appears for nearby players. This is basically only used on the RP server.">?</span><br>
			<a href="[pref_link]flying_chat_hidden=1" class="toggle">[crap_checkbox(!src.flying_chat_hidden)] See chat above people's heads</a><span class="info-thing" title="Chat messages will appear over characters as they're talking.">?</span><br>
			<a href="[pref_link]auto_capitalization=1" class="toggle">[crap_checkbox(src.auto_capitalization)] Auto-capitalize your messages</a><span class="info-thing" title="Chat messages you send will be automatically capitalized.">?</span>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["hud"])
			rebuild_data["hud"] = 0
			data_cache["hud"] = {"
	<tr>
		<th>
			HUD/UI<span class="info-thing" title="These affect the HUD that shows up in-game, as well as the cursor used when you have to target something.">?</span>
		</th>
		<td colspan="2" style="text-align: center;">
			<div style="display: inline-block; text-align: center; margin: 0.2em 0.5em;">
				<strong>HUD Theme</strong>
				<br><img style="-ms-interpolation-mode:nearest-neighbor;" src="hud_preview.png">
				<br><a href="[pref_link]hud_style=1">Change</a>
			</div>
			<div style="display: inline-block; text-align: center; margin: 0.2em 0.5em;">
				<strong>Targeting Cursor</strong>
				<br><img style="-ms-interpolation-mode:nearest-neighbor;" src="tcursor.png">
				<br><a href="[pref_link]tcursor=1">Change</a>
			</div>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["tooltips"])
			rebuild_data["tooltips"] = 0
			data_cache["tooltips"] = {"
	<tr>
		<th>
			Tooltips<span class="info-thing" title="Tooltips can appear when hovering over items. These tooltips can provide bits of information about the item, such as attack strength, special moves, etc...">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]tooltip=1" class="toggle">[crap_checkbox(src.tooltip_option == TOOLTIP_ALWAYS)] Show Always</a>
			<br><a href="[pref_link]tooltip=2" class="toggle">[crap_checkbox(src.tooltip_option == TOOLTIP_ALT)] Show When ALT is held</a>
			<br><a href="[pref_link]tooltip=3" class="toggle">[crap_checkbox(src.tooltip_option == TOOLTIP_NEVER)] Never Show</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["tgui"])
			rebuild_data["tgui"] = 0
			data_cache["tgui"] = {"
	<tr>
		<th>
			tgui<span class="info-thing" title="tgui is the UI framework we use for some game windows, and it comes with options!">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]tgui_fancy=1" class="toggle">[crap_checkbox(src.tgui_fancy)] Fast & Fancy Windows</a>
			<br><a href="[pref_link]tgui_lock=1" class="toggle">[crap_checkbox(src.tgui_lock)] Lock initial placement of windows</a>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["popups"])
			rebuild_data["popups"] = 0
			data_cache["popups"] = {"
	<tr>
		<th>
			Popups<span class="info-thing" title="These options toggle the popups that appear when logging in and at the end of a round.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]changelog=1" class="toggle">[crap_checkbox(src.view_changelog)] Auto-open changelog</a><span class="info-thing" title="The changelog can be shown at any time by using the 'Changelog' command, under the Commands tab in the top right.">?</span>
			<br><a href="[pref_link]scores=1" class="toggle">[crap_checkbox(src.view_score)] Auto-open end-of-round score</a><span class="info-thing" title="The end-of-round scoring shows various stats on how the round went. If this option is off, you won't be able to see it.">?</span>
			<br><a href="[pref_link]tickets=1" class="toggle">[crap_checkbox(src.view_tickets)] Auto-open end-of-round ticket summary</a><span class="info-thing" title="The end-of-round ticketing summary shows the various tickets and fines that were handed out. If this option is off, you can still see them on Goonhub (goonhub.com).">?</span>
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["controls"])
			rebuild_data["controls"] = 0
			data_cache["controls"] = {"
	<tr>
		<th>
			Controls<span class="info-thing" title="Various options for how you control your character and the game.">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]clickbuffer=1" class="toggle">[crap_checkbox(src.use_click_buffer)] Queue Combat Clicks</a><span class="info-thing" title="There is a cooldown after clicking on things in-game. When enabled, if you click something during this cooldown, the game will apply that click after the cooldown. Otherwise, the click is ignored.">?</span>
			<br><a href="[pref_link]use_wasd=1" class="toggle">[crap_checkbox(src.use_wasd)] Use WASD Mode</a><span class="info-thing" title="Enabling this allows you to use WASD to move instead of the arrow keys, and enables a few other hotkeys.">?</span>
			<br><a href="[pref_link]use_azerty=1" class="toggle">[crap_checkbox(src.use_azerty)] Use AZERTY Keyboard Layout</a><span class="info-thing" title="If you have an AZERTY keyboard, enable this. Yep. This sure is a tooltip.">?</span>
			<br>Familiar with /tg/station controls? You can enable/disable them under the Game/Interface menu in the top left.
		</td>
	</tr>"}
		LAGCHECK(80)
		if (rebuild_data["map"])
			rebuild_data["map"] = 0
			data_cache["map"] = {"
	<tr>
		<th>
			Preferred Map<span class="info-thing" title="During a map vote, you will automatically vote for this map if you don't otherwise vote. Note that automatic votes are given much less weight!">?</span>
		</th>
		<td colspan="2">
			<a href="[pref_link]preferred_map=1">[length(src.preferred_map) ? src.preferred_map : "<em>(None)</em>"]</a>
		</td>
	</tr>
</table>

	<br>
	<br><a href='[pref_link]reset_all=1'>Reset All</a> - <a href='[pref_link]real_name=random'>Randomize</a><br>

"}

		LAGCHECK(LAG_MED)
		traitPreferences.updateTraits(user)
		LAGCHECK(LAG_MED)

		//Mob has been deleted or client been deleted
		if (!user || !user.client)
			return

		var/list/dat = list()
		for (var/x in data_cache)
			dat += data_cache[x]

		user.Browse(dat.Join(),"window=preferences;size=666x750;title=Character Setup")


	//id, The name of the Select table ID to be used.
	//ah_var, The var in the appearance holder that is in focus
	//Style_list, The assoc list with the values to be used for generating this select table
	proc/generate_select_table(var/id, var/ah_var, var/list/style_list)
		var/list/select = list()
		select += "<select id='[id]'>"
		for (var/i in style_list)
			//this is for setting the default value
			if (AH && i == ah_var)
				select += "<option value='[style_list[i]]' selected='selected'>[i]</option>"
			else
				select += "<option value='[style_list[i]]'>[i]</option>"
			LAGCHECK(LAG_REALTIME)
		select += "</select>"
		return select.Join()

	Topic(href, href_list[])
		var/table_id = href_list["id"]
		//the if block determines whatever to save the incoming choice in the AppearanceHolder. Then in all cases it will update the icon and send it to the browser
		var/changed = 0
		if (table_id)
			if (table_id == "underwear")
				rebuild_data["underwear"] = 1
				if (AH.underwear != href_list["style"])
					AH.underwear = href_list["style"]
					changed = 1
			else if (table_id == "custom_first")
				rebuild_data["hair_bottom"] = 1
				if (AH.customization_first != href_list["style"])
					AH.customization_first = href_list["style"]
					changed = 1

			else if (table_id == "custom_second")
				rebuild_data["hair_mid"] = 1
				if (AH.customization_second != href_list["style"])
					AH.customization_second = href_list["style"]
					changed = 1
			else if (table_id == "custom_third")
				rebuild_data["hair_top"] = 1
				if (AH.customization_third != href_list["style"])
					AH.customization_third = href_list["style"]
					changed = 1

			if (changed)
				update_preview_icon()
				usr << browse_rsc(preview_icon, "previewicon.png")
				usr << browse("previewicon.png","display=0")

		..()

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
		else if (isnull(src.job_favorite) && !src.jobs_med_priority.len && !src.jobs_low_priority.len && !src.jobs_unwanted.len)
			src.ResetAllPrefsToDefault(user)
			boutput(user, "<span class='alert'><b>Your Job Preferences were empty, and have been reset.</b></span>")


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
				HTML += " <a href=\"byond://?src=\ref[src];preferences=1;occ=1;job=[J_Fav.name];level=0\" style='font-weight: bold; color: [J_Fav.linkcolor];'>[J_Fav.name]</a>"

		HTML += {"
	<table class='jobtable'>
		<tr>
			<th>Medium Priority <span class="info-thing" title="Medium Priority Jobs are any jobs you would like to play that aren't your favorite. People with jobs in this category get priority over those who have the same job in their low priority bracket. It's best to put jobs here that you actively enjoy playing and wouldn't mind ending up with if you don't get your favorite.">?</span></th>
			<th>Low Priority <span class="info-thing" title="Low Priority Jobs are jobs that you don't mind doing. When the game is finding candidates for a job, it will try to fill it with Medium Priority players first, then Low Priority players if there are still free slots.">?</span></th>
			<th>Unwanted Jobs <span class="info-thing" title="Unwanted Jobs are jobs that you absolutely don't want to have. The game will never give you a job you list here. The 'Staff Assistant' role can't be put here, however, as it's the fallback job if there are no other openings.">?</span></th>
			<th>Antagonist Roles <span class="info-thing" title="Antagonist roles are randomly chosen when the game starts, before jobs have been allocated. Having an antagonist role disabled means you will never be chosen for it automatically.">?</span></th>
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
			src.be_changeling = 0
			src.be_revhead = 0
			src.be_syndicate = 0
			src.be_wizard = 0
			src.be_traitor = 0
			src.be_werewolf = 0
			src.be_vampire = 0
			src.be_spy = 0
			src.be_gangleader = 0
			src.be_wraith = 0
			src.be_blob = 0
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
		if (!find_job_in_controller_by_string(job,1))
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

		var/datum/job/temp_job = find_job_in_controller_by_string(job,1)
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
		if (usr && usr.client && usr.client.preferences)
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

		if (link_tags["linkshairstuff"])
			//refresh sprite call here
			var/new_style = link_tags["linkshairstuff"]
			traitPreferences.showTraits(user)

			if (new_style)
				AH.customization_first = new_style

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

		if (link_tags["profile_name"])
			rebuild_data["profile_name"] = 1
			var/new_profile_name

			new_profile_name = input(user, "Please select a name:", "Character Generation")  as null|text

			//var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\", "/")
			for (var/c in bad_name_characters)
				new_profile_name = replacetext(new_profile_name, c, "")

			new_profile_name = trim(new_profile_name)

			if (new_profile_name)
				if (length(new_profile_name) >= 26)
					new_profile_name = copytext(new_profile_name, 1, 26)
				src.profile_name = new_profile_name
/*
		if (link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if ("input")
					new_name = input(user, "Please select a name:", "Character Generation")  as null|text
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\", "/")
					for (var/c in bad_characters)
						new_name = replacetext(new_name, c, "")

					new_name = trim(new_name)
					if (!new_name || (lowertext(new_name) in list("unknown", "floor", "wall", "r wall")))
						alert("That name is reserved for use by the game. Please select another.")
						return
					if (!usr.client.holder)
						var/list/namecheck = splittext(trim(new_name), " ")
						if (namecheck.len < 2)
							alert("Your name must have at least a First and Last name, e.g. John Smith")
							return
						if (length(new_name) < 5)
							alert("Your name is too short. It must be at least 5 characters long.")
							return
						for (var/i = 1, i <= namecheck.len, i++)
							namecheck[i] = capitalize(namecheck[i])
						new_name = jointext(namecheck, " ")

				if ("random")
					if (src.gender == MALE)
						new_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
					else
						new_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
					randomizeLook()
			if (new_name)
				if (length(new_name) >= 26)
					new_name = copytext(new_name, 1, 26)
				src.real_name = new_name
*/
// -------------------------------------------
		if (link_tags["first_name"])
			rebuild_data["character_name"] = 1

			var/new_name
			switch(link_tags["first_name"])
				if ("input")
					new_name = input(user, "Please select a first name:", "Character Generation", src.name_first) as null|text
					if (isnull(new_name))
						return
					//new_name = trim(new_name)
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
				if ("random")
					if (src.gender == MALE)
						new_name = capitalize(pick(first_names_male))
					else
						new_name = capitalize(pick(first_names_female))
			if (new_name)
				src.name_first = new_name
				src.real_name = src.name_first + " " + src.name_last
// -------------------------------------------
		if (link_tags["middle_name"])
			rebuild_data["character_name"] = 1
			var/new_name
			switch(link_tags["middle_name"])
				if ("input")
					new_name = input(user, "Please select a middle name:", "Character Generation", src.name_middle) as null|text
					if (isnull(new_name))
						return
					for (var/c in bad_name_characters)
						new_name = replacetext(new_name, c, "")
					if (length(new_name) > NAME_CHAR_MAX)
						alert("Your middle name is too long. It must be no more than [NAME_CHAR_MAX] characters long.")
						return
					else if (is_blank_string(new_name) && new_name != "")
						alert("Your middle name cannot contain only spaces.")
						return
					new_name = capitalize(new_name)
				if ("random")
					if (src.gender == MALE)
						new_name = capitalize(pick(first_names_male))
					else
						new_name = capitalize(pick(first_names_female))
			src.name_middle = new_name // don't need to check if there is one in case someone wants no middle name I guess
// -------------------------------------------
		if (link_tags["last_name"])
			rebuild_data["character_name"] = 1
			var/new_name
			switch(link_tags["last_name"])
				if ("input")
					new_name = input(user, "Please select a last name:", "Character Generation", src.name_last) as null|text
					if (isnull(new_name))
						return
					//new_name = trim(new_name)
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
				if ("random")
					new_name = capitalize(pick(last_names))
			if (new_name)
				src.name_last = new_name
				src.real_name = src.name_first + " " + src.name_last
// -------------------------------------------
		if (link_tags["flavor_text"])
			rebuild_data["flavortext"] = 1
			var/new_text = input(user, "Please enter new flavor text (appears when examining you):", "Character Generation", src.flavor_text) as null|text
			if (isnull(new_text))
				return
			new_text = html_encode(new_text)
			if (length(new_text) > FLAVOR_CHAR_LIMIT)
				alert("Your flavor text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.")
				new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
			src.flavor_text = new_text

		if (link_tags["security_flavor_text"])
			rebuild_data["security_note"] = 1
			var/new_text = input(user, "Please enter new security note (appears as important note in Secmate):", "Character Generation", src.security_note) as null|text
			if (isnull(new_text))
				return
			new_text = html_encode(new_text)
			if (length(new_text) > FLAVOR_CHAR_LIMIT)
				alert("Your note is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.")
				new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
			src.security_note = new_text

		if (link_tags["medical_flavor_text"])
			rebuild_data["medical_note"] = 1
			var/new_text = input(user, "Please enter new medical note (appears as important note in Medtrak):", "Character Generation", src.medical_note) as null|text
			if (isnull(new_text))
				return
			new_text = html_encode(new_text)
			if (length(new_text) > FLAVOR_CHAR_LIMIT)
				alert("Your note text is too long. It must be no more than [FLAVOR_CHAR_LIMIT] characters long. The current text will be trimmed down to meet the limit.")
				new_text = copytext(new_text, 1, FLAVOR_CHAR_LIMIT+1)
			src.medical_note = new_text

// -------------------------------------------

		if (link_tags["font_size"])
			rebuild_data["font_size"] = 1
			var/new_font_size = input(user, "Desired font size (in percent):", "Font setting", (src.font_size ? src.font_size : 100)) as null|num
			src.font_size = new_font_size

		if (link_tags["hud_style"])
			rebuild_data["hud"] = 1
			var/new_hud = input(user, "Please select HUD style:", "New") as null|anything in hud_style_selection

			if (new_hud)
				src.hud_style = new_hud

		if (link_tags["tcursor"])
			rebuild_data["hud"] = 1
			var/new_cursor = input(user, "Please select cursor:", "Cursor") as null|anything in cursors_selection

			if (new_cursor)
				src.target_cursor = new_cursor

		if (link_tags["age"])
			rebuild_data["age_blood"] = 1
			var/new_age = input(user, "Please select type in age: 20-80", "Character Generation")  as null|num

			if (new_age)
				src.age = max(min(round(text2num(new_age)), 80), 20)


		if (link_tags["pin"])
			rebuild_data["bank"] = 1
			if (link_tags["pin"] == "input")
				var/new_pin = input(user, "Please select a PIN between 1000 and 9999", "Character Generation")  as null|num
				if (new_pin)
					src.pin = max(min(round(text2num(new_pin)), 9999), 1000)
			else if (link_tags["pin"] == "random")
				src.pin	= null


		if (link_tags["blType"])
			rebuild_data["age_blood"] = 1
			var/blTypeNew = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list("Random", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")

			if (blTypeNew)
				if (blTypeNew == "Random")
					src.random_blood = 1
				else
					src.random_blood = 0
					blType = blTypeNew

		if (link_tags["hair"])
			rebuild_data["hair_bottom"] = 1
			var/new_hair = input(user, "Please select hair color.", "Character Generation") as null|color
			if (new_hair)
				AH.customization_first_color = new_hair

		if (link_tags["facial"])
			rebuild_data["hair_mid"] = 1
			var/new_facial = input(user, "Please select detail 1 color.", "Character Generation") as null|color
			if (new_facial)
				AH.customization_second_color = new_facial

		if (link_tags["detail"])
			rebuild_data["hair_top"] = 1
			var/new_detail = input(user, "Please select detail 2 color.", "Character Generation") as null|color
			if (new_detail)
				AH.customization_third_color = new_detail

		if (link_tags["eyes"])
			rebuild_data["eyecolor"] = 1
			var/new_eyes = input(user, "Please select eye color.", "Character Generation") as null|color
			if (new_eyes)
				AH.e_color = new_eyes

		if (link_tags["s_tone"])
			rebuild_data["skintone"] = 1
			var/new_tone = "#FEFEFE"
			if (usr.has_medal("Contributor"))
				switch(alert(user, "Goonstation contributors get to pick any colour for their skin tone!", "Thanks, pal!", "Paint me like a posh fence!", "Use Standard tone.", "Cancel"))
					if("Paint me like a posh fence!")
						new_tone = input(user, "Please select skin color.", "Character Generation")  as null|color
					if("Use Standard tone.")
						new_tone = get_standard_skintone(user)
					else
						return

				if(new_tone)
					AH.s_tone = new_tone
			else
				new_tone = get_standard_skintone(user)
				if(new_tone)
					AH.s_tone = new_tone

		if (link_tags["underwear_color"])
			rebuild_data["underwear"] = 1
			var/new_ucolor = input(user, "Please select underwear color.", "Character Generation") as null|color
			if (new_ucolor)
				AH.u_color = new_ucolor

		if (link_tags["gender"])
			rebuild_data["gender"] = 1
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

		if (link_tags["changelog"])
			rebuild_data["popups"] = 1
			src.view_changelog = !(src.view_changelog)

		if (link_tags["toggle_mentorhelp"])
			rebuild_data["messages"] = 1
			if (user && user.client && user.client.is_mentor())
				src.see_mentor_pms = !(src.see_mentor_pms)
				user.client.set_mentorhelp_visibility(src.see_mentor_pms)

		if (link_tags["listen_ooc"])
			rebuild_data["messages"] = 1
			src.listen_ooc = !(src.listen_ooc)

		if (link_tags["listen_looc"])
			rebuild_data["messages"] = 1
			src.listen_looc = !(src.listen_looc)

		if (link_tags["flying_chat_hidden"])
			rebuild_data["messages"] = 1
			src.flying_chat_hidden = !(src.flying_chat_hidden)

		if (link_tags["auto_capitalization"])
			rebuild_data["messages"] = 1
			src.auto_capitalization = !(src.auto_capitalization)

		if (link_tags["volume"])
			src.admin_music_volume = input("Goes from 0 to 100.","Admin Music Volume", src.admin_music_volume) as num
			src.admin_music_volume = max(0,min(src.admin_music_volume,100))

		if (link_tags["radio"])
			src.radio_music_volume = input("Goes from 0 to 100.","Radio Music Volume", src.radio_music_volume) as num
			src.radio_music_volume = max(0,min(src.radio_music_volume,100))

		if (link_tags["clickbuffer"])
			rebuild_data["controls"] = 1
			src.use_click_buffer = !(src.use_click_buffer)

		if (link_tags["use_wasd"])
			rebuild_data["controls"] = 1
			src.use_wasd = !src.use_wasd
			src.keybind_prefs_updated(user.client)

		if (link_tags["use_azerty"])
			rebuild_data["controls"] = 1
			src.use_azerty = !src.use_azerty
			src.keybind_prefs_updated(user.client)

		if (link_tags["preferred_map"])
			rebuild_data["map"] = 1
			src.preferred_map = mapSwitcher.clientSelectMap(usr.client)

		if (link_tags["tooltip"])
			rebuild_data["tooltips"] = 1
			switch(link_tags["tooltip"])
				if("1")
					src.tooltip_option = TOOLTIP_ALWAYS
				if("2")
					src.tooltip_option = TOOLTIP_ALT
				if("3")
					src.tooltip_option = TOOLTIP_NEVER
				else src.tooltip_option = TOOLTIP_ALWAYS

		if (link_tags["tgui_fancy"])
			rebuild_data["tgui"] = 1
			src.tgui_fancy = !(src.tgui_fancy)

		if (link_tags["tgui_lock"])
			rebuild_data["tgui"] = 1
			src.tgui_lock = !(src.tgui_lock)

		if (link_tags["scores"])
			rebuild_data["popups"] = 1
			src.view_score = !(src.view_score)

		if (link_tags["tickets"])
			rebuild_data["popups"] = 1
			src.view_tickets = !(src.view_tickets)

		if (link_tags["b_changeling"])
			src.be_changeling = !( src.be_changeling )
			src.SetChoices(user)
			return

		if (link_tags["b_revhead"])
			src.be_revhead = !( src.be_revhead )
			src.SetChoices(user)
			return

		if (link_tags["b_syndicate"])
			src.be_syndicate = !( src.be_syndicate )
			src.SetChoices(user)
			return

		if (link_tags["b_wizard"])
			src.be_wizard = !( src.be_wizard)
			src.SetChoices(user)
			return

		if (link_tags["b_traitor"])
			src.be_traitor = !( src.be_traitor)
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

		if (link_tags["b_spy"])
			src.be_spy = !( src.be_spy)
			src.SetChoices(user)
			return

		if (link_tags["b_gangleader"])
			src.be_gangleader = !( src.be_gangleader)
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
		if (link_tags["b_flock"])
			src.be_flock = !( src.be_flock)
			src.SetChoices(user)
			return

		if (link_tags["b_misc"])
			src.be_misc = !src.be_misc
			src.SetChoices(user)
			return

		if (link_tags["b_random_name"])
			rebuild_data["character_name"] = 1
			if (!force_random_names)
				src.be_random_name = !src.be_random_name
			else
				src.be_random_name = 1

		if (link_tags["b_random_look"])
			rebuild_data["randomize"] = 1
			if (!force_random_looks)
				src.be_random_look = !src.be_random_look
			else
				src.be_random_look = 1

		if (link_tags["rotate_counter_clockwise"])
			src.spessman_direction = turn(spessman_direction, 90)

		if (link_tags["rotate_clockwise"])
			src.spessman_direction = turn(spessman_direction, -90)

		else if (link_tags["fartsound"])
			rebuild_data["fartsound"] = 1
			var/list/soundlist = list()//this is a horror of code
			for(var/k in AH.fartsounds)
				soundlist[++soundlist.len] = k
			AH.fartsound = (input( "What fartsound do you want?" ) in soundlist) || "default"
			usr << sound( AH.fartsounds[AH.fartsound] )
		else if (link_tags["screamsound"])
			rebuild_data["screamsound"] = 1
			var/list/soundlist = list()//this is a horror of code v2
			for(var/k in AH.screamsounds)
				soundlist[++soundlist.len] = k
			AH.screamsound = (input( "What screamsound do you want?" ) in soundlist) || "default"
			usr << sound( AH.screamsounds[AH.screamsound] )
		else if (link_tags["voicetype"])
			rebuild_data["chatsound"] = 1
			var/list/soundlist = list()//this is a horror of code v2
			for(var/k in AH.voicetypes)
				soundlist[++soundlist.len] = k
			AH.voicetype = AH.voicetypes[(input( "What voice do you want?" ) in soundlist)]
			usr << sound( sounds_speak[AH.voicetype] )


		/* Wire: a little thing i'll finish up eventually
		if (link_tags["set_will"])
			var/new_will = input(user, "Write a Will that shall appear in the event of your death. (250 max)", "Character Generation")  as text
			var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\", "/")
			for (var/c in bad_characters)
				new_will = replacetext(new_will, c, "")

			if (new_will)
				if (length(new_will) > 250)
					new_will = copytext(new_will, 1, 251)
				src.will = new_will
		*/

		if (!isnull(user) && !IsGuestKey(user.key))
			if (link_tags["cloudsave"] && user.client.cloudsaves[ link_tags["cloudsave"] ])
				rebuild_profile = 1
				var/ret = src.cloudsave_save( user.client, link_tags["cloudsave"] )
				if( istext( ret ) )
					boutput( user, "<span class='alert'>Failed to save savefile: [ret]</span>" )
				else
					boutput( user, "<span class='notice'>Savefile saved!</span>" )
			else if (link_tags["cloudnew"])
				rebuild_profile = 1
				if( user.client.cloudsaves.len >= SAVEFILE_PROFILES_MAX )
					alert( user, "You have hit your cloud save limit. Please write over an existing save." )
				else
					var/newname = input( user, "What would you like to name the save?", "Save Name" ) as text
					if( length( newname ) < 3 || length( newname ) > MOB_NAME_MAX_LENGTH )
						alert( user, "The name must be between 3 and [MOB_NAME_MAX_LENGTH] letters!" )
					else
						var/ret = src.cloudsave_save( user.client, newname )
						if( istext( ret ) )
							boutput( user, "<span class='alert'>Failed to save savefile: [ret]</span>" )
						else
							boutput( user, "<span class='notice'>Savefile saved!</span>" )
			else if( link_tags["clouddelete"] && user.client.cloudsaves[ link_tags["clouddelete"] ] && alert( user, "Are you sure you want to delete [link_tags["clouddelete"]]?", "Uhm!", "Yes", "No" ) == "Yes" )
				rebuild_profile = 1
				var/ret = src.cloudsave_delete( user.client, link_tags["clouddelete"] )
				if( istext( ret ) )
					boutput( user, "<span class='alert'>Failed to delete savefile: [ret]</span>" )
				else
					boutput( user, "<span class='notice'>Savefile deleted!</span>" )
			else if (link_tags["cloudload"] && user.client.cloudsaves[ link_tags["cloudload"] ])
				for (var/x in rebuild_data)
					rebuild_data[x] = 1
				rebuild_profile = 1
				var/ret = src.cloudsave_load( user.client, link_tags["cloudload"] )
				if( istext( ret ) )
					boutput( user, "<span class='alert'>Failed to load savefile: [ret]</span>" )
				else
					boutput( user, "<span class='notice'>Savefile loaded!</span>" )

			else if (link_tags["save"])
				rebuild_profile = 1
				src.savefile_save(user, (isnum(text2num(link_tags["save"])) ? text2num(link_tags["save"]) : 1))
				boutput(user, "<span class='notice'><b>Character saved to Slot [text2num(link_tags["save"])].</b></span>")
			else if (link_tags["load"])
				for (var/x in rebuild_data)
					rebuild_data[x] = 1

				rebuild_profile = 1
				if (!src.savefile_load(user.client, (isnum(text2num(link_tags["load"])) ? text2num(link_tags["load"]) : 1)))
					alert(user, "You do not have a savefile.")
				else if (!user.client.holder)
					sanitize_name()
					boutput(user, "<span class='notice'><b>Character loaded from Slot [text2num(link_tags["load"])].</b></span>")
				else
					boutput(user, "<span class='notice'><b>Character loaded from Slot [text2num(link_tags["load"])].</b></span>")


		if (link_tags["reset_all"])
			src.gender = MALE
			AH.gender = MALE
			randomize_name()

			AH.customization_first = "Trimmed"
			AH.customization_second = "None"
			AH.customization_third = "None"
			AH.underwear = "No Underwear"

			AH.customization_first_color = 0
			AH.customization_second_color = 0
			AH.customization_third_color = 0
			AH.e_color = 0
			AH.u_color = "#FEFEFE"

			AH.s_tone = "#FAD7D0"

			age = 30
			pin = null
			flavor_text = null
			src.ResetAllPrefsToLow(user)
			flying_chat_hidden = 0
			auto_capitalization = 0
			listen_ooc = 1
			view_changelog = 1
			view_score = 1
			view_tickets = 1
			admin_music_volume = 50
			radio_music_volume = 50
			use_click_buffer = 0
			be_changeling = 0
			be_revhead = 0
			be_syndicate = 0
			be_wizard = 0
			be_wraith = 0
			be_blob = 0
			be_flock = 0
			be_misc = 0
			be_traitor = 0
			be_werewolf = 0
			be_vampire = 0
			be_spy = 0
			be_gangleader = 0
			tooltip_option = TOOLTIP_ALWAYS
			tgui_fancy = TRUE
			tgui_lock = FALSE
			if (!force_random_names)
				be_random_name = 0
			else
				be_random_name = 1
			if (!force_random_looks)
				be_random_look = 0
			else
				be_random_look = 1
			blType = "A+"

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
	"Disheveled" = "disheveled")

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
	"Temsik" = "temsik")

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
	"Eyebrows" = "eyebrows",
	"Huge Eyebrows" = "thufir")

// this is weird but basically: a list of hairstyles and their appropriate detail styles, aka hair_details["80s"] would return the Hairmetal: Faded style
// further on in the randomize_look() proc we'll see if we've got one of the styles in here and if so, we have a chance to add the detailing
// if it's a list then we'll pick from the options in the list
var/global/list/hair_details = list("einstein" = "einalt",\
	"80s" = "80sfade",\
	"glammetal" = "glammetalO",\
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

/proc/randomize_look(var/to_randomize, var/change_gender = 1, var/change_blood = 1, var/change_age = 1, var/change_name = 1, var/change_underwear = 1, var/remove_effects = 1)
	if (!to_randomize)
		return

	var/mob/living/carbon/human/H
	var/datum/appearanceHolder/AH

	if (ishuman(to_randomize))
		H = to_randomize
		if (H.bioHolder && H.bioHolder.mobAppearance)
			AH = H.bioHolder.mobAppearance

	else if (istype(to_randomize, /datum/appearanceHolder))
		AH = to_randomize
		if (ishuman(AH.owner))
			H = AH.owner

	else
		return

	if (H && remove_effects)
		H.bioHolder.RemoveAllEffects()
		H.bioHolder.BuildEffectPool()

	if (change_gender)
		AH.gender = pick(MALE, FEMALE)
	if (H && AH.gender)
		H.sound_scream = AH.screamsounds[pick(AH.gender == MALE ? male_screams : female_screams)]
	if (H && change_name)
		if (AH.gender == FEMALE)
			H.real_name = pick(first_names_female)
		else
			H.real_name = pick(first_names_male)
		H.real_name += " [pick(last_names)]"

	AH.voicetype = RANDOM_HUMAN_VOICE

	var/list/hair_colors = list("#101010", "#924D28", "#61301B", "#E0721D", "#D7A83D",\
	"#D8C078", "#E3CC88", "#F2DA91", "#F21AE", "#664F3C", "#8C684A", "#EE2A22", "#B89778", "#3B3024", "#A56b46")
	var/hair_color
	if (prob(75))
		hair_color = randomize_hair_color(pick(hair_colors))
	else
		hair_color = randomize_hair_color(random_saturated_hex_color())

	AH.customization_first_color = hair_color
	AH.customization_second_color = hair_color
	AH.customization_third_color = hair_color

	var/stone = rand(34,-184)
	if (stone < -30)
		stone = rand(34,-184)
	if (stone < -50)
		stone = rand(34,-184)

	AH.s_tone = blend_skintone(stone, stone, stone)

	if (H)
		if (H.limbs)
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

	if (H && H.organHolder && H.organHolder.head && H.organHolder.head.donor_appearance) // aaaa
		H.organHolder.head.donor_appearance.CopyOther(AH)

	SPAWN_DBG(1 DECI SECOND)
		AH.UpdateMob()
		if (H)
			H.set_face_icon_dirty()
			H.set_body_icon_dirty()


// Generates a real crap checkbox for html toggle links.
// it sucks but it's a bit more readable i guess.
/proc/crap_checkbox(var/checked)
	if (checked) return "&#9745;"
	else return "&#9744;"
