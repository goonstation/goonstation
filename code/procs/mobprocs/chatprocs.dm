/mob/proc/say(message)
	if (message)
		SEND_SIGNAL(src, COMSIG_MOB_SAY, message)

/mob/proc/whisper(message, forced=FALSE)
	return

/mob/verb/whisper_verb(message as text)
	set name = "whisper"
	return src.whisper(message)

/mob/verb/say_verb(message as text)
	set name = "say"
	if (!message)
		return
	if (src.client && url_regex?.Find(message) && !client.holder)
		boutput(src, SPAN_NOTICE("<b>Web/BYOND links are not allowed in ingame chat.</b>"))
		boutput(src, SPAN_ALERT("&emsp;<b>\"[message]</b>\""))
		return
	src.say(message)
	if (!dd_hasprefix(message, "*")) // if this is an emote it is logged in emote
		logTheThing(LOG_SAY, src, "SAY: [html_encode(message)] [log_loc(src)]")

/mob/verb/sa_verb(message as text)
	set name = "sa"
	set hidden = 1
	src.say_verb(message)

/mob/verb/say_radio()
	set name = "say_radio"
	set hidden = 1

/mob/verb/say_main_radio(msg as text)
	set name = "say_main_radio"
	set hidden = 1

/mob/living/say_main_radio(msg as text)
	set name = "say_main_radio"
	set desc = "Speaking on the main radio frequency"
	set hidden = 1
	if (src.capitalize_speech())
		var/i = 1
		while (copytext(msg, i, i+1) == " ")
			i++
		msg = capitalize(copytext(msg, i))
	src.say_verb(";" + msg)

/mob/living/say_radio()
	set name = "say_radio"
	set hidden = 1

	if (isAI(src))
		var/mob/living/silicon/ai/A = src
		var/list/choices = list()
		var/list/channels = list()
		var/list/radios = list(A.radio1, A.radio2, A.radio3)
		for (var/i = 1, i <= radios.len, i++)
			var/obj/item/device/radio/R = radios[i]
			var/channel_name

			if (!istype(R, /obj/item/device/radio/headset/command/ai))
				// Skip the AI headset (radio 3) because it reads the first char as a channel.
				// Honestly this should probably be fixed in some other way, but, effort.
				channel_name = "[format_frequency(R.frequency)] - " + (headset_channel_lookup["[R.frequency]"] ? headset_channel_lookup["[R.frequency]"] : "(Unknown)")
				choices += channel_name
				channels[channel_name] = ":[i]"
			if (R.bricked)
				usr.show_text(R.bricked_msg, "red")
				return
			if (istype(R.secure_frequencies) && length(R.secure_frequencies))
				for (var/sayToken in R.secure_frequencies)
					channel_name = "[format_frequency(R.secure_frequencies[sayToken])] - " + (headset_channel_lookup["[R.secure_frequencies[sayToken]]"] ? headset_channel_lookup["[R.secure_frequencies[sayToken]]"] : "(Unknown)")

					choices += channel_name
					channels[channel_name] = ":[i][sayToken]"

		if (A.robot_talk_understand)
			var/channel_name = "* - Robot Talk"
			channels[channel_name] = ":s"
			choices += channel_name

		var/choice = 0
		if (length(choices) == 1)
			choice = choices[1]
		else
			choice = input("", "Select Radio and Channel", null) as null|anything in choices
		if (!choice)
			return

		var/token = channels[choice]
		if (!token)
			boutput(src, "Somehow '[choice]' didn't match anything. Welp. Probably busted.")
		var/text = input("", "Speaking over [choice] ([token])") as null|text
		if (text)
			if (src.capitalize_speech())
				text = capitalize(text)

			src.say_verb(token + " " + text)

	else
		var/obj/item/device/radio/R = null
		if ((src.ears && istype(src.ears, /obj/item/device/radio)))
			R = src.ears
		else if (ishuman(src))	//Check if the decapitated skeleton head has a headset
			var/mob/living/carbon/human/H = src
			var/datum/mutantrace/skeleton/S = H.mutantrace
			if (isskeleton(H) && !H.organHolder.head && S.head_tracker.ears && istype(S.head_tracker.ears, /obj/item/device/radio))
				R = S.head_tracker.ears
		if (R)
			if (R.bricked)
				usr.show_text(R.bricked_msg, "red")
				return
			var/token = ""
			var/list/choices = list()
			choices += "[ headset_channel_lookup["[R.frequency]"] ? headset_channel_lookup["[R.frequency]"] : "???" ]: \[[format_frequency(R.frequency)]]"

			if (istype(R.secure_frequencies) && length(R.secure_frequencies))
				for (var/sayToken in R.secure_frequencies)
					choices += "[ headset_channel_lookup["[R.secure_frequencies["[sayToken]"]]"] ? headset_channel_lookup["[R.secure_frequencies["[sayToken]"]]"] : "???" ]: \[[format_frequency(R.secure_frequencies["[sayToken]"])]]"

			if (src.robot_talk_understand)
				choices += "Robot Talk: \[***]"


			var/choice = 0
			if (length(choices) == 1)
				choice = choices[1]
			else
				choice = input("", "Select Radio Channel", null) as null|anything in choices
			if (!choice)
				return

			var/choice_index = choices.Find(choice)
			if (choice_index == 1)
				token = ";"
			else if (choice == "Robot Talk: \[***]")
				token = ":s"
			else
				token = ":" + R.secure_frequencies[choice_index - 1]

			var/text = input("", "Speaking to [choice] frequency") as null|text
			if (!text)
				return
			if (src.capitalize_speech())
				var/i = 1
				while (copytext(text, i, i+1) == " ")
					i++
				text = capitalize(copytext(text, i))
			src.say_verb(token + " " + text)
		else
			boutput(src, SPAN_NOTICE("You must put a headset on your ear slot to speak on the radio."))

// ghosts now can emote now too so vOv
/*	if (isliving(src))
		if (copytext(message, 1, 2) != "*") // if this is an emote it is logged in emote
			logTheThing(LOG_SAY, src, "SAY: [message]")
	else logTheThing(LOG_SAY, src, "SAY: [message]")
*/
/mob/verb/me_verb(message as text)
	set name = "me"

	if (src.client && !src.client.holder && url_regex?.Find(message))
		boutput(src, SPAN_NOTICE("<b>Web/BYOND links are not allowed in ingame chat.</b>"))
		boutput(src, SPAN_ALERT("&emsp;<b>\"[message]</b>\""))
		return

	src.emote(message, 1)

/mob/verb/me_verb_hotkey(message as text)
	set name = "me_hotkey"
	set hidden = 1

	if (src.client && !src.client.holder && url_regex?.Find(message)) //we still do this check just in case they access the hidden emote
		boutput(src, SPAN_NOTICE("<b>Web/BYOND links are not allowed in ingame chat.</b>"))
		boutput(src, SPAN_ALERT("&emsp;<b>\"[message]</b>\""))
		return

	src.emote(message,2)

/* ghost emotes wooo also the logging is already taken care of in the emote() procs vOv
	if (isliving(src) && isalive(src))
		src.emote(message, 1)
		logTheThing(LOG_SAY, src, "EMOTE: [message]")
	else
		boutput(src, SPAN_NOTICE("You can't emote when you're dead! How would that even work!?"))
*/
/mob/proc/try_render_chat_to_admin(client/C, message)
	if (C.holder && C.deadchat && !C.player_mode)
		if (src.mind)
			message = "<span class='adminHearing' data-ctx='[C.chatOutput.getContextFlags()]'>[message]</span>"
		boutput(C, message)
		return 1

/mob/proc/say_dead(var/message, wraith = 0)
	var/name = src.real_name
	var/alt_name = ""

	if (!deadchat_allowed)
		boutput(usr, "<b>Deadchat is currently disabled.</b>")
		return

	message = trimtext(copytext(html_encode(sanitize(message)), 1, MAX_MESSAGE_LEN))
	if (!message)
		return

	if (ishuman(src) && src.name != src.real_name)
		if (src:wear_id && src:wear_id:registered && src:wear_id:registered != src.real_name)
			alt_name = " (as [src:wear_id:registered])"
		else if (!src:wear_id)
			alt_name = " (as Unknown)"

	else if (isobserver(src))
		name = "Ghost"
		alt_name = " ([src.real_name])"
	else if (ispoltergeist(src))
		name = "Poltergeist"
		alt_name = " ([src.real_name])"
	else if (iswraith(src))
		name = "Wraith"
		alt_name = " ([src.real_name])"

	else if (!ishuman(src))
		name = src.name

	if(src?.client?.preferences.auto_capitalization)
		message = capitalize(message)

#ifdef DATALOGGER
	game_stats.ScanText(message)
#endif

	var/image/chat_maptext/chat_text = null
	if (speechpopups && src.chat_text)
		var/maptext_color = dead_maptext_color(src.get_heard_name(just_name_itself=TRUE))

		var/turf/T = get_turf(src)
		for(var/i = 0; i < 2; i++) T = get_step(T, WEST)
		for(var/i = 0; i < 5; i++)
			for(var/mob/M in T)
				if(M != src)
					for(var/image/chat_maptext/I in M.chat_text?.lines)
						I.bump_up()
			T = get_step(T, EAST)

		var/singing_italics = singing ? " font-style: italic;" : ""
		chat_text = make_chat_maptext(src, message, singing_italics)

		if(chat_text)
			chat_text.measure(src.client)
			for(var/image/chat_maptext/I in src.chat_text.lines)
				if(I != chat_text)
					I.bump_up(chat_text.measured_height)

		oscillate_colors(chat_text, list(maptext_color, "#c482d1"))

	message = src.say_quote(message)
	//logTheThing(LOG_SAY, src, "SAY: [message]")

	var/rendered = SPAN_DEADSAY("[SPAN_PREFIX("DEAD:")] <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> [SPAN_MESSAGE("[message]")]")
	//logit( "chat", 0, "([name])", src, message )
	for (var/client/C)
		if (C.deadchatoff) continue
		if (!C.mob) continue
		var/mob/M = C.mob
		if (istype(M, /mob/new_player)) continue

		if(try_render_chat_to_admin(C, rendered))
			if(chat_text && !M.client.preferences.flying_chat_hidden)
				chat_text.show_to(C)
			continue

		if (istype(M, /mob/dead/target_observer))
			var/mob/dead/target_observer/tobserver = M
			if(!tobserver.is_respawnable)
				continue
		if (iswraith(M))
			var/mob/living/intangible/wraith/the_wraith = M
			if (!the_wraith.hearghosts)
				continue

		if (isdead(M) || iswraith(M) || isghostdrone(M) || isVRghost(M) || inafterlifebar(M))
			if(chat_text && !M.client.preferences.flying_chat_hidden)
				chat_text.show_to(C)
			boutput(M, rendered)



//changeling hivemind say
/mob/proc/say_hive(var/message, var/datum/abilityHolder/changeling/hivemind_owner)
	var/name = src.real_name
	var/alt_name = ""

	if (!hivemind_owner)
		return

	var/mob/living/L = src
	if (istype(L))
		message = L.check_singing_prefix(message)

	//i guess this caused some real ugly text huh
	//message = trimtext(copytext(html_encode(sanitize(message)), 1, MAX_MESSAGE_LEN))
	if (!message)
		return

	if (istype(src, /mob/living/critter/changeling/handspider))
		name = src.real_name
		alt_name = " (HANDSPIDER)"
	else if (istype(src, /mob/living/critter/changeling/eyespider))
		name = src.real_name
		alt_name = " (EYESPIDER)"
	else if (istype(src, /mob/living/critter/changeling/legworm))
		name = src.real_name
		alt_name = " (LEGWORM)"
	else if(!hivemind_owner.master)
		//Standard behaviour
		if (src == hivemind_owner.owner)
			name = src.name
			alt_name = " (MASTER)"
	else
		//Someone else is controlling stuff
		if (src == hivemind_owner.owner)
			name = hivemind_owner.original_controller_real_name
			alt_name = " (CONTROLLER)"
		else if (src == hivemind_owner.master)
			name = src.name
			alt_name = " (MASTER)"

#ifdef DATALOGGER
	game_stats.ScanText(message)
#endif

	message = src.say_quote(message)
	//logTheThing(LOG_SAY, src, "SAY: [message]")

	var/rendered = SPAN_HIVESAY("[SPAN_PREFIX("HIVEMIND:")] <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> [SPAN_MESSAGE("[message]")]")

	//show to hivemind
	var/list/mob/hivemind = hivemind_owner.get_current_hivemind()
	for (var/client/C in clients)
		if (C.mob in hivemind)
			continue
		try_render_chat_to_admin(C, rendered)
	if (isabomination(hivemind_owner.owner))
		var/abomination_rendered = SPAN_REGULAR("[SPAN_PREFIX("")] <span class='name' data-ctx='\ref[src.mind]'>Congealed [name]</span> [SPAN_MESSAGE("[message]")]")
		src.audible_message(abomination_rendered)
	else
		for (var/mob/member in hivemind)
			boutput(member, rendered)

//vampire thrall say
/mob/proc/say_thrall(var/message, var/datum/abilityHolder/vampire/owner)
	var/name = src.real_name
	var/alt_name = ""

	if (!owner)
		return

	var/mob/living/L = src
	if (istype(L))
		message = L.check_singing_prefix(message)

	if (!message)
		return

	if (isvampire(src))
		alt_name = " (VAMPIRE)"
	else if (isvampiricthrall(src))
		alt_name = " (THRALL)"

#ifdef DATALOGGER
	game_stats.ScanText(message)
#endif

	message = src.say_quote(message)
	//logTheThing(LOG_SAY, src, "SAY: [message]")

	var/rendered = SPAN_THRALLSAY("[SPAN_PREFIX("Thrall speak:")] <span class='name [isvampire(src) ? "vamp" : ""]' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> [SPAN_MESSAGE("[message]")]")

	//show to ghouls
	for (var/client/C in clients)
		try_render_chat_to_admin(C, rendered)
	for (var/mob/M in (owner.thralls + owner.owner))
		if ((M.client?.holder && M.client.deadchat && !M.client.player_mode)) continue
		boutput(M, rendered)

//kudzu hivemind say
/mob/proc/say_kudzu(var/message, var/datum/abilityHolder/kudzu/owner)
	var/name = src.real_name
	var/alt_name = ""

	if (!owner)
		return

	var/mob/living/L = src
	if (istype(L))
		message = L.check_singing_prefix(message)

	if (!message)
		return

#ifdef DATALOGGER
	game_stats.ScanText(message)
#endif
	logTheThing(LOG_DIARY, src, "(KUDZU): [message]", "hivesay")

	message = src.say_quote(message)
	//logTheThing(LOG_SAY, src, "SAY: [message]")

	var/rendered = SPAN_KUDZUSAY("[SPAN_PREFIX("<small>Kudzu speak:</small>")] <span class='name' data-ctx='\ref[src.mind]'>[name]<span class='text-normal'>[alt_name]</span></span> [SPAN_MESSAGE("[message]")]")


	//show message to admins (Follow rules of their deadchat toggle)
	for (var/client/C)
		if (!C.mob) continue
		if (try_render_chat_to_admin(C, rendered)) continue
		if (istype(C.mob.abilityHolder, /datum/abilityHolder/kudzu))
			boutput(C, rendered)
		//////////////////////////////////

/mob/proc/say_understands(var/mob/other, var/forced_language)
	if (isdead(src))
		return 1
//	else if (istype(other, src.type) || istype(src, other.type))
//		return 1
	var/L = other.say_language
	if (forced_language)
		L = forced_language
	if (understands_language(L))
		return 1
	return 0
	/*if (isrobot(other) || isAI(other) || (ismonkey(other) && src.bioHolder.HasEffect("monkey_speak")))
		return 1
	else
		. = 0
		. += ismonkey(src) ? 1 : 0
		. += ismonkey(other) ? 1 : 0
		if (. == 1)
			return monkeysspeakhuman
		else
			return 1
	return 0*/

/mob/proc/say_quote(var/text, var/special = 0, var/speechverb = null)
	var/ending = copytext(text, length(text))
	var/loudness = 0
	var/font_accent = null
	var/class = ""
	var/first_quote = " \""
	var/second_quote = "\""

	if(!speechverb)
		speechverb = speechverb_say
		if (ending == "?")
			speechverb = speechverb_ask
		else if (ending == "!")
			speechverb = speechverb_exclaim
	if (src.stuttering)
		speechverb = speechverb_stammer
	for (var/datum/ailment_data/A in src.ailments)
		if (istype(A.master, /datum/ailment/disease/berserker))
			if (A.stage > 1)
				speechverb = "roars"
	if ((src.reagents && src.reagents.get_reagent_amount("ethanol") > 30))
		speechverb = "slurs"
	if (src.bioHolder)
		if (src.bioHolder.HasEffect("loud_voice"))
			speechverb = "bellows"
			loudness += 1
		if (src.bioHolder.HasEffect("quiet_voice"))
			speechverb = "murmurs"
			loudness -= 1
		if (src.bioHolder.HasEffect("unintelligable"))
			speechverb = "splutters"
		if (src.bioHolder.HasEffect("accent_comic"))
			font_accent = "Comic Sans MS"

		if (src.bioHolder.genetic_stability < 50 || src.bioHolder.HasEffect("accent_thrall"))
			speechverb = "gurgles"

	if (src.get_brain_damage() >= 60)
		speechverb = pick("says","stutters","mumbles","slurs")

	if(src.find_type_in_hand(/obj/item/megaphone))
		var/obj/item/megaphone/megaphone = src.find_type_in_hand(/obj/item/megaphone)
		loudness += megaphone.loudness_mod

	if (src.speech_void)
		text = voidSpeak(text)

	if (src.singing || (src.bioHolder && src.bioHolder.HasEffect("accent_elvis")))
		// use note icons instead of normal quotes
		var/note_type = src.singing & BAD_SINGING ? "notebad" : "note"
		var/note_img = "<img class='icon misc' style='position: relative; bottom: -3px;' src='[resource("images/radio_icons/[note_type].png")]'>"
		if (src.singing & LOUD_SINGING)
			first_quote = "[note_img][note_img]"
			second_quote = first_quote
		else
			first_quote = note_img
			second_quote = note_img
		// select singing adverb
		var/adverb = ""
		if (src.singing & BAD_SINGING)
			adverb = pick("dissonantly", "flatly", "unmelodically", "tunelessly")
		else if (src.traitHolder?.hasTrait("nervous"))
			adverb = pick("nervously", "tremblingly", "falteringly")
		else if (src.singing & LOUD_SINGING && !src.traitHolder?.hasTrait("smoker"))
			adverb = pick("loudly", "deafeningly", "noisily")
		else if (src.singing & SOFT_SINGING)
			adverb = pick("softly", "gently")
		else if (src.mind?.assigned_role == "Musician")
			adverb = pick("beautifully", "tunefully", "sweetly")
		else if (src.bioHolder?.HasEffect("accent_scots"))
			adverb = pick("sorrowfully", "sadly", "tearfully")
		// select singing verb
		if (src.traitHolder?.hasTrait("smoker"))
			speechverb = "rasps"
			if ((singing & LOUD_SINGING))
				speechverb = "sings Tom Waits style"
		else if (src.traitHolder?.hasTrait("french") && rand(2) < 1)
			speechverb = "sings [pick("Charles Trenet", "Serge Gainsborough", "Edith Piaf")] style"
		else if (src.bioHolder?.HasEffect("accent_swedish"))
			speechverb = "sings disco style"
		else if (src.bioHolder?.HasEffect("accent_scots"))
			speechverb = pick("laments", "sings", "croons", "intones", "sobs", "bemoans")
		else if (src.bioHolder?.HasEffect("accent_chav"))
			speechverb = "raps"
		else if (src.singing & SOFT_SINGING)
			speechverb = pick("hums", "lullabies")
		else
			speechverb = pick("sings", pick("croons", "intones", "warbles"))
		if (adverb != "")
		// combine adverb and verb
			speechverb = "[adverb] [speechverb]"
		// add style for singing
		text = "<i>[text]</i>"
		class = "sing"

	if (special)
		if (special == "gasp_whisper")
			speechverb = speechverb_gasp
			loudness -= 1

	// hi cirr here i feel this should be relative for weak mobs
	var/health_percentage = (src.health/(max(1, src.max_health))) * 100 // prevent div/0 errors from stopping people talking
	// better to inaccurately not gasp than be silenced by runtimes
	if (health_percentage <= 20)
		speechverb = speechverb_gasp
	if (isdead(src) || isobserver(src))
		speechverb = pick("moans","wails","laments")
		if (prob(5))
			speechverb = "grumps"

	if (text == "" || !text)
		return speechverb

	if(class)
		class = " class='[class]'"
	if (loudness > 1)
		return "[speechverb],[first_quote][font_accent ? "<font face='[font_accent]'>" : null]<strong style='font-size:36px'><b [class? class : ""]>[text]</b></strong>[font_accent ? "</font>" : null][second_quote]"
	else if (loudness > 0)
		return "[speechverb],[first_quote][font_accent ? "<font face='[font_accent]'>" : null]<big><strong><b [class? class : ""]>[text]</b></strong></big>[font_accent ? "</font>" : null][second_quote]"
	else if (loudness < 0)
		return "[speechverb],[first_quote][font_accent ? "<font face='[font_accent]'>" : null]<small [class? class : ""]>[text]</small>[font_accent ? "</font>" : null][second_quote]"
	else
		return "[speechverb],[first_quote][font_accent ? "<font face='[font_accent]'>" : null]<span [class? class : ""]>[text]</span>[font_accent ? "</font>" : null][second_quote]"

//no, voluntary is not a boolean. screm
/mob/proc/emote(act, voluntary = 0, atom/target)
	set waitfor = FALSE
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_EMOTE, act, voluntary, target)

/mob/proc/emote_check(voluntary = 1, time = 1 SECOND, admin_bypass = TRUE, dead_check = TRUE)
	if ((!src.emote_allowed))
		return FALSE
	if (dead_check && isdead(src))
		src.emote_allowed = FALSE
		return FALSE
	if (voluntary && (src.hasStatus("unconscious") || src.hasStatus("paralysis") || isunconscious(src)))
		return FALSE
	if (world.time >= (src.last_emote_time + src.last_emote_wait))
		if (!no_emote_cooldowns && !(src.client && (src.client.holder && admin_bypass) && !src.client.player_mode) && voluntary)
			src.emotes_on_cooldown = TRUE
			src.last_emote_time = world.time
			src.last_emote_wait = time
			SPAWN(time)
				src.emotes_on_cooldown = FALSE
		return TRUE
	return FALSE
/mob/proc/listen_ooc()
	set name = "(Un)Mute OOC"
	set desc = "Mute or Unmute Out Of Character chat."

	if (src.client)
		src.client.preferences.listen_ooc = !src.client.preferences.listen_ooc
		if (src.client.preferences.listen_ooc)
			boutput(src, SPAN_NOTICE("You are now listening to messages on the OOC channel."))
		else
			boutput(src, SPAN_NOTICE("You are no longer listening to messages on the OOC channel."))

/mob/verb/ooc(msg as text)
	if (IsGuestKey(src.key))
		boutput(src, "You are not authorized to communicate over these channels.")
		return
	if (oocban_isbanned(src))
		boutput(src, "You are currently banned from using OOC and LOOC, you may appeal at https://forum.ss13.co/index.php")
		return

	msg = trimtext(copytext(html_encode(msg), 1, MAX_MESSAGE_LEN))
	if (!msg)
		return
	else if (!src.client.preferences.listen_ooc)
		return
	else if (!ooc_allowed && !src.client.holder)
		boutput(usr, "OOC is currently disabled. For gameplay questions, try <a href='byond://winset?command=mentorhelp'>mentorhelp</a>.")
		return
	else if (!dooc_allowed && !src.client.holder && (src.client.deadchat != 0))
		boutput(usr, "OOC for dead mobs has been turned off.")
		return
	else if (src.client && src.client.ismuted())
		boutput(usr, "You are currently muted and cannot talk in OOC.")
		return
	else if (findtext(msg, "byond://") && !src.client.holder)
		boutput(src, "<B>Advertising other servers is not allowed.</B>")
		logTheThing(LOG_ADMIN, src, "has attempted to advertise in OOC.")
		logTheThing(LOG_DIARY, src, "has attempted to advertise in OOC.", "admin")
		message_admins("[key_name(src)] has attempted to advertise in OOC.")
		return

	logTheThing(LOG_DIARY, src, ": [msg]", "ooc")
	phrase_log.log_phrase("ooc", msg)

#ifdef DATALOGGER
	game_stats.ScanText(msg)
#endif

	for (var/client/C in clients)
		// DEBUGGING
		if (!C.preferences)
			logTheThing(LOG_DEBUG, null, "[C] (\ref[C]): client.preferences is null")

		if (C.preferences && !C.preferences.listen_ooc)
			continue

		var ooc_class = ""
		var display_name = src.key
		var/ooc_icon = ""

		if (src.client.stealth || src.client.alt_key)
			if (!C.holder)
				display_name = src.client.fakekey
			else
				display_name += " (as [src.client.fakekey])"

		if (src.client.holder && (!src.client.stealth || C.holder))
			if (src.client.holder.level == LEVEL_BABBY)
				ooc_class = "gfartooc"
			else
				ooc_class = "adminooc"
		else if (src.client.is_mentor() && !src.client.stealth)
			ooc_class = "mentorooc"
		else if (src.client.player.is_newbee)
			ooc_class = "newbeeooc"
			ooc_icon = "Newbee"

		if (src.client.player.cloudSaves.getData("donor") )
			msg = replacetext(msg, ":shelterfrog:", "<img src='http://stuff.goonhub.com/shelterfrog.png' width=32>")

		if (src.client.has_contestwinner_medal)
			msg = replacetext(msg, ":shelterbee:", "<img src='http://stuff.goonhub.com/shelterbee.png' width=32>")

		var/rendered = "<span class='ooc [ooc_class]'>[SPAN_PREFIX("OOC:")] <span class='name' data-ctx='\ref[src.mind]'>[display_name]:</span> [SPAN_MESSAGE("[msg]")]</span>"
		if (ooc_icon)
			rendered = {"
			<div class='tooltip'>
				<img class='icon misc' style='position: relative; bottom: -3px;' src='[resource("images/radio_icons/[ooc_icon].png")]'>
				<span class="tooltiptext">[ooc_icon]</span>
			</div>
			"} + rendered
		if (C.holder)
			rendered = "<span class='adminHearing' data-ctx='[C.chatOutput.getContextFlags()]'>[rendered]</span>"

		boutput(C, rendered)

	logTheThing(LOG_OOC, src, "OOC: [msg]")

/mob/proc/listen_looc()
	set name = "(Un)Mute LOOC"
	set desc = "Mute or Unmute Local Out Of Character chat."

	if (src.client)
		src.client.preferences.listen_looc = !src.client.preferences.listen_looc
		if (src.client.preferences.listen_looc)
			boutput(src, SPAN_NOTICE("You are now listening to messages on the LOOC channel."))
		else
			boutput(src, SPAN_NOTICE("You are no longer listening to messages on the LOOC channel."))

/mob/verb/looc(msg as text)
	if (IsGuestKey(src.key))
		boutput(src, "You are not authorized to communicate over these channels.")
		return
	if (oocban_isbanned(src))
		boutput(src, "You are currently banned from using OOC and LOOC, you may appeal at https://forum.ss13.co/index.php")
		return

	msg = trimtext(copytext(html_encode(sanitize(msg)), 1, MAX_MESSAGE_LEN))
	if (!msg)
		return
	else if (!src.client.preferences.listen_looc)
		return
	else if (!looc_allowed && !src.client.holder)
		boutput(usr, "LOOC is currently disabled.")
		return
	else if (!dooc_allowed && !src.client.holder && (src.client.deadchat != 0))
		boutput(usr, "LOOC for dead mobs has been turned off.")
		return
	else if (src.client && src.client.ismuted())
		boutput(usr, "You are currently muted and cannot talk in LOOC.")
		return
	else if (findtext(msg, "byond://") && !src.client.holder)
		boutput(src, "<B>Advertising other servers is not allowed.</B>")
		logTheThing(LOG_ADMIN, src, "has attempted to advertise in LOOC.")
		logTheThing(LOG_DIARY, src, "has attempted to advertise in LOOC.", "admin")
		message_admins("[key_name(src)] has attempted to advertise in LOOC.")
		return

	logTheThing(LOG_DIARY, src, ": [msg]", "ooc")

#ifdef DATALOGGER
	game_stats.ScanText(msg)
#endif

	var/list/recipients = list()

	for (var/client/C in clients)
		if (!C.mob)
			continue
		if (C.preferences && !C.preferences.listen_looc)
			continue
		if (C.holder && !C.only_local_looc && !C.player_mode) // is admin with global looc enabled and not in player mode
			recipients += C
		else if (IN_RANGE(C.mob, src, LOOC_RANGE)) // is in range to hear looc
			recipients += C

	var looc_style = ""
	if (src.client.holder && !src.client.stealth)
		if (src.client.holder.level == LEVEL_BABBY)
			looc_style = "color: #4cb7db;"
		else
			looc_style = "color: #cd6c4c;"
	else if (src.client.is_mentor() && !(src.client.stealth || !src.client.player.see_mentor_pms))
		looc_style = "color: #a24cff;"
	else if (src.client.player.is_newbee)
		looc_style = "color: #8BC16E;"

	var/image/chat_maptext/looc_text = null
	looc_text = make_chat_maptext(src, "\[LOOC: [msg]]", looc_style)
	if(looc_text)
		looc_text.measure(src.client)
		for(var/image/chat_maptext/I in src.chat_text.lines)
			if(I != looc_text)
				I.bump_up(looc_text.measured_height)

	phrase_log.log_phrase("looc", msg)
	for (var/client/C in recipients)
		// DEBUGGING
		if (!C.preferences)
			logTheThing(LOG_DEBUG, null, "[C] (\ref[C]): client.preferences is null")

		if (C.preferences && !C.preferences.listen_ooc)
			continue

		var looc_class = ""
		var display_name = src.key
		var/looc_icon = ""

		if (src.client.stealth || src.client.alt_key)
			if (!C.holder)
				display_name = src.client.fakekey
			else
				display_name += " (as [src.client.fakekey])"

		if (src.client.holder && (!src.client.stealth || C.holder))
			if (src.client.holder.level == LEVEL_BABBY)
				looc_class = "gfartlooc"
			else
				looc_class = "adminlooc"
		else if (src.client.is_mentor() && !src.client.stealth)
			looc_class = "mentorlooc"
		else if (src.client.player.is_newbee)
			looc_class = "newbeelooc"
			looc_icon = "Newbee"

		var/rendered = "<span class='looc [looc_class]'>[SPAN_PREFIX("LOOC:")] <span class='name' data-ctx='\ref[src.mind]'>[display_name]:</span> [SPAN_MESSAGE("[msg]")]</span>"
		if (looc_icon)
			rendered = {"
			<div class='tooltip'>
				<img class='icon misc' style='position: relative; bottom: -3px;' src='[resource("images/radio_icons/[looc_icon].png")]'>
				<span class="tooltiptext">[looc_icon]</span>
			</div>
			"} + rendered
		if (C.holder)
			rendered = "<span class='adminHearing' data-ctx='[C.chatOutput.getContextFlags()]'>[rendered]</span>"

		boutput(C, rendered)
		var/mob/M = C.mob
		if(looc_text && speechpopups && M.chat_text && !C.preferences?.flying_chat_hidden)
			looc_text.show_to(C)

	logTheThing(LOG_OOC, src, "LOOC: [msg]")

/mob/proc/heard_say(var/mob/other)
	return

/mob/proc/lastgasp(allow_dead=FALSE)
	set waitfor = FALSE
	return

/mob/proc/item_attack_message(var/mob/T, var/obj/item/S, var/d_zone, var/devastating = 0, var/armor_blocked = 0)
	if (d_zone && ishuman(T))
		if(armor_blocked)
			return SPAN_COMBAT("<B>[src] [islist(S.attack_verbs) ? pick(S.attack_verbs) : S.attack_verbs] [T] in the [d_zone] with [S], but [T]'s armor blocks it!</B>")
		else
			return SPAN_COMBAT("<B>[src] [islist(S.attack_verbs) ? pick(S.attack_verbs) : S.attack_verbs] [T] in the [d_zone] with [S][devastating ? " and lands a devastating hit!" : "!"]</B>")
	else
		if(armor_blocked)
			return SPAN_COMBAT("<B>[src] [islist(S.attack_verbs) ? pick(S.attack_verbs) : S.attack_verbs] [T] with [S], but [T]'s armor blocks it!</B>")
		else
			return SPAN_COMBAT("<B>[src] [islist(S.attack_verbs) ? pick(S.attack_verbs) : S.attack_verbs] [T] with [S] [devastating ? "and lands a devastating hit!" : "!"]</B>")

/mob/proc/get_age_pitch_for_talk()
	if (!src.bioHolder || !src.bioHolder.age) return
	var/modifier = 30
	if (src.reagents && src.reagents.has_reagent("helium"))
		modifier += 30
	if (deep_farting)
		modifier -= 120
	if (modifier == 0)
		modifier = 1
	return 1.0 + (0.5*(modifier - src.bioHolder.age)/80) + ((src.gender == MALE) ? 0.1 : 0.3)

/mob/proc/get_age_pitch()
	if (!src.bioHolder || !src.bioHolder.age) return
	var/modifier = 30
	if (src.reagents && src.reagents.has_reagent("helium"))
		modifier += 30
	if (src.getStatusDuration("crunched") > 0)
		modifier += 100
	if (deep_farting)
		modifier -= 120
	if (modifier == 0)
		modifier = 1
	return 1.0 + 0.5*(modifier - src.bioHolder.age)/80

/mob/proc/understands_language(var/langname)
	if (langname == say_language)
		return 1
	if (langname == "english" || !langname)
		return 1
	if (langname == "monkey" && (monkeysspeakhuman || (bioHolder?.HasEffect("monkey_speak"))))
		return 1
	return 0

/mob/proc/get_language_id(var/forced_language = null)
	var/language = say_language
	if (forced_language)
		language = forced_language
	return language

/mob/proc/process_language(var/message, var/forced_language = null)
	// Separate the radio prefix (if it exists) and message so the language can't destroy the prefix
	var/prefixAndMessage = separate_radio_prefix_and_message(message)
	var/prefix = prefixAndMessage[1]
	message = prefixAndMessage[2]

	var/datum/language/L = languages.language_cache[get_language_id(forced_language)]
	if (!L)
		L = languages.language_cache["english"]

	var/list/messages = L.get_messages(message)
	return list(prefix + messages[1], prefix + messages[2])

/mob/proc/get_special_language(var/secure_mode)
	return null

/mob/proc/see(message)
	if (!isalive(src))
		return 0
	boutput(src, message)
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in AIviewers())
		M.see(message)

/mob/verb/toggle_auto_capitalization()
	set desc = "Toggles auto capitalization of chat messages"
	set name = "Toggle Auto Capitalization"

	if (!usr.client)
		return

	usr.client.preferences.auto_capitalization = !usr.client.preferences.auto_capitalization
	boutput(usr, SPAN_NOTICE("[usr.client.preferences.auto_capitalization ? "Now": "No Longer"] auto capitalizing messages."))

/mob/dead/verb/togglelocaldeadchat()
	set desc = "Toggle whether you can hear all chat while dead or just local chat"
	set name = "Toggle Deadchat Range"
	set category = "Ghost"

	if (!usr.client) //How could this even happen?
		return

	usr.client.preferences.local_deadchat = !usr.client.preferences.local_deadchat
	boutput(usr, SPAN_NOTICE("[usr.client.preferences.local_deadchat ? "Now" : "No longer"] hearing local chat only."))

/mob/dead/verb/toggle_ghost_radio()
	set desc = "Toggle whether you can hear radio chatter while dead"
	set name = "Toggle Ghost Radio"
	set category = "Ghost"

	if (!usr.client) //How could this even happen?
		return

	usr.client.mute_ghost_radio = !usr.client.mute_ghost_radio
	boutput(usr, SPAN_NOTICE("[usr.client.mute_ghost_radio ? "No longer" : "Now"] hearing radio as a ghost."))

/mob/verb/toggleflyingchat()
	set desc = "Toggle seeing what people say over their heads"
	set name = "Toggle Flying Chat"

	if (!usr.client) //How could this even happen?
		return

	usr.client.preferences.flying_chat_hidden = !usr.client.preferences.flying_chat_hidden
	boutput(usr, SPAN_NOTICE("[usr.client.preferences.flying_chat_hidden ? "No longer": "Now"] seeing flying chat."))

/mob/proc/show_message(msg, type, alt, alt_type, group = "", just_maptext, image/chat_maptext/assoc_maptext = null)
	if (!src.client)
		return
	if(isnull(msg) && isnull(assoc_maptext))
		CRASH("show_message() called with null message and null maptext")

	// We have procs to check for this stuff, you know. Ripped out a bunch of duplicate code, which also fixed earmuffs (Convair880).
	var/check_failed = FALSE
	if (type)
		if ((type & 1) && !src.sight_check(1))
			check_failed = TRUE
			if (!alt)
				return
			else
				msg = alt
				type = alt_type
		if ((type & 2) && !src.hearing_check(1))
			check_failed = TRUE
			if (!alt)
				return
			else
				msg = alt
				type = alt_type
			if ((type & 1) && !src.sight_check(1))
				return

	if (!just_maptext && (isunconscious(src) || src.sleeping || src.getStatusDuration("unconscious")))
		if (prob(20))
			boutput(src, "<I>... You can almost hear something ...</I>")
			if (isliving(src))
				for (var/mob/dead/target_observer/observer in src:observers)
					boutput(observer, "<I>... You can almost hear something ...</I>")
	else
		if(!just_maptext)
			boutput(src, msg, group)

		var/psychic_link = src.get_psychic_link()
		if (ismob(psychic_link))
			boutput(psychic_link, msg, group)

		if(!check_failed)
			if(assoc_maptext && src.client && !src.client.preferences?.flying_chat_hidden)
				assoc_maptext.show_to(src.client)

			if (isliving(src))
				for (var/mob/dead/target_observer/M in src.observers)
					if(!just_maptext)
						if (M.client?.holder && !M.client.player_mode)
							if (M.mind)
								msg = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[msg]</span>"
							boutput(M, msg, group)
						else
							boutput(M, msg, group)
					if(assoc_maptext && M.client && !M.client.preferences.flying_chat_hidden)
						assoc_maptext.show_to(M.client)

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(message, self_message, blind_message, group = "")
	for (var/mob/M in AIviewers(src))
		if (!M.client && !isAI(M))
			continue
		var/msg = message
		if (self_message && M == src)
			M.show_message(self_message, 1, self_message, 2, group)
		else
			M.show_message(msg, 1, blind_message, 2, group)

// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(message, blind_message, group = "")
	for (var/mob/M in AIviewers(src))
		if (!M.client)
			continue
		M.show_message(message, 1, blind_message, 2, group)

/**
 * Used in messages with three separate parties that should receive different messages
 * second_target - the second individual involved in the interaction, with the source atom being the first individual
 * viewer_message - the message shown to observers that aren't specified targets
 * first_message - the message shown to the atom this proc is called from
 * second_message - the message shown to second_target
 * blind_message (optional) is what blind people will hear, e.g. "You hear something!"
 * Observers in range of either target will see the message, so the proc can be called on either target
 */
/atom/proc/tri_message(atom/second_target, viewer_message, first_message, second_message, blind_message)
	var/list/source_viewers = AIviewers(Center = src)
	var/list/target_viewers = AIviewers(Center = second_target)
	// get a list of all viewers within range of either target, discarding duplicates
	for (var/atom/A in target_viewers)
		if (!source_viewers.Find(A))
			source_viewers.Add(A)
	for (var/mob/M in source_viewers)
		if (!M.client)
			continue
		var/msg = viewer_message
		if (first_message && M == src)
			msg = first_message
		if (second_message && M == second_target && M != src)
			msg = second_message
		M.show_message(msg, 1, blind_message, 2)
		//DEBUG_MESSAGE("<b>[M] receives message: &quot;[msg]&quot;</b>")

// it was about time we had this instead of just visible_message()
/atom/proc/audible_message(var/message, var/alt, var/alt_type, var/group = "", var/just_maptext, var/image/chat_maptext/assoc_maptext = null)
	for (var/mob/M in all_hearers(null, src))
		if (istype(M, /mob/living/silicon/ai) && !M.client && M.hearing_check(1)) //if heard, relay msg to client mob if they're in aieye form
			var/mob/living/silicon/ai/mainframe = M
			var/mob/message_mob = mainframe.get_message_mob()
			if(isAIeye(message_mob))
				message_mob.show_message(message, null, alt, alt_type, group, just_maptext, assoc_maptext) // type=null as AIeyes can't hear directly
			continue
		if (!M.client)
			continue
		M.show_message(message, 2, alt, alt_type, group, just_maptext, assoc_maptext)

/mob/audible_message(var/message, var/self_message, var/alt, var/alt_type, var/group = "", var/just_maptext, var/image/chat_maptext/assoc_maptext = null)
	for (var/mob/M in all_hearers(null, src))
		if (!M.client)
			continue
		var/msg = message
		if (self_message && M==src)
			msg = self_message
		M.show_message(msg, 2, alt, alt_type, group, just_maptext, assoc_maptext)


// FLOCKSAY
//#define FLOCK_SPEAKER_SYSTEM 1
//#define FLOCK_SPEAKER_ADMIN 2
//#define FLOCK_SPEAKER_FLOCKMIND 3
//#define FLOCK_SPEAKER_FLOCKTRACE 4
//#define FLOCK_SPEAKER_NPC 5

/// how to speak in the flock
/// for speaker, pass:
/// -null to give a general system message
/// -mob to make a mob speak
/// -flock_structure for a structure message
/// involuntary overrides the sentient styling for messages generated by the possessed flock critter
/proc/flock_speak(atom/speaker, message as text, datum/flock/flock, involuntary = FALSE, speak_as_admin = FALSE)
	var/mob/mob_speaking = null
	var/obj/flock_structure/structure_speaking = null

	if (ismob(speaker))
		mob_speaking = speaker
	else
		structure_speaking = speaker

	var/name = ""
	var/is_npc = FALSE

	if (!speak_as_admin)
		if(mob_speaking)
			message = mob_speaking.say_quote(message)
		else // system message
			message = gradientText("#3cb5a3", "#124e43", "\"[message]\"")
			message = "alerts, [message]"

		if(istype(mob_speaking, /mob/living/critter/flock/drone))
			var/mob/living/critter/flock/drone/F = mob_speaking
			if(F.is_npc)
				name = "Drone [F.real_name]"
				is_npc = TRUE
			else if(F.controller)
				name = "[F.controller.real_name]"
				if(istype(F.controller, /mob/living/intangible/flock))
					mob_speaking = F.controller
		else if(mob_speaking)
			name = mob_speaking.real_name

	var/class = "flocksay"

	if(istype(mob_speaking, /mob/living/intangible/flock) && !involuntary || speak_as_admin)
		class += " sentient"
		if (istype(mob_speaking, /mob/living/intangible/flock/flockmind))
			class += " flockmind"
	else if(is_npc)
		class += " flocknpc"
	else if(isnull(mob_speaking))
		if (flock?.quiet)
			return
		class += " bold italics"
		name = "\[SYSTEM\]"

	var/rendered = ""
	var/flockmindRendered = ""
	var/siliconrendered = ""

	if(speak_as_admin)
		var/client/C = null
		if(mob_speaking)
			C = mob_speaking.client

		var/show_other_key = FALSE
		if (C.stealth || C.alt_key)
			show_other_key = TRUE
		rendered = "<span class='[class]'>[SPAN_BOLD("")][SPAN_NAME("ADMIN([show_other_key ? C.fakekey : C.key])")] informs, [SPAN_MESSAGE("\"[message]\"")]</span>"
		flockmindRendered = rendered // no need for URLs
	else
		rendered = "<span class='[class]'>[SPAN_BOLD("\[[flock ? flock.name : "--.--"]\] ")]<span class='name' [mob_speaking ? "data-ctx='\ref[mob_speaking.mind]'" : ""]>[name]</span> [SPAN_MESSAGE("[message]")]</span>"
		flockmindRendered = "<span class='[class]'>[SPAN_BOLD("\[[flock ? flock.name : "--.--"]\] ")][SPAN_NAME("[flock && speaker ? "<a href='?src=\ref[flock.flockmind];origin=\ref[structure_speaking ? structure_speaking.loc : mob_speaking]'>[name]</a>" : "[name]"]")] [SPAN_MESSAGE("[message]")]</span>"
		if (flock && !flock.flockmind?.tutorial && flock.total_compute() >= FLOCK_RELAY_COMPUTE_COST / 4 && prob(90))
			siliconrendered = "<span class='[class]'>[SPAN_BOLD("\[?????\] ")]<span class='name' [mob_speaking ? "data-ctx='\ref[mob_speaking.mind]'" : ""]>[radioGarbleText(name, FLOCK_RADIO_GARBLE_CHANCE)]</span> [SPAN_MESSAGE("[radioGarbleText(message, FLOCK_RADIO_GARBLE_CHANCE)]")]</span>"

	for (var/client/CC)
		if (!CC.mob) continue
		if(istype(CC.mob, /mob/new_player))
			continue
		var/mob/M = CC.mob

		var/thisR = ""

		var/is_dead_observer = isobserver(M)
		if (istype(M, /mob/dead/target_observer))
			var/mob/dead/target_observer/tobserver = M
			if(!tobserver.is_respawnable)
				continue

		if((isflockmob(M)) || (M.client.holder && !M.client.player_mode) || is_dead_observer)
			thisR = rendered
		if((M.robot_talk_understand || istype(M, /mob/living/intangible/aieye)) && (!involuntary && mob_speaking || prob(30)))
			thisR = siliconrendered
		if(istype(M, /mob/living/intangible/flock/flockmind) && !(istype(mob_speaking, /mob/living/intangible/flock/flockmind)) && M:flock == flock)
			thisR = flockmindRendered
		if ((istype(M, /mob/dead/observer)||M.client.holder) && mob_speaking?.mind)
			thisR = rendered
			thisR = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[thisR]</span>"

		if(thisR != "")
			boutput(M, thisR)

/// Generate a hue for maptext from a given name
/proc/living_maptext_color(given_name)
	var/num = hex2num(copytext(md5(given_name), 1, 7))
	return hsv2rgb(num % 360, (num / 360) % 10 + 18, num / 360 / 10 % 15 + 85)

/// Generate a desatureated hue for maptext from a given name
/proc/dead_maptext_color(given_name)
	var/num = hex2num(copytext(md5(given_name), 1, 7))
	return hsv2rgb((num % 360)%40+240, (num / 360) % 15+5, (((num / 360) / 10) % 15) + 55)
