/mob/proc/whisper(message)
	src.say(message, flags = SAYFLAG_WHISPER | SAYFLAG_SPOKEN_BY_PLAYER)

/mob/verb/whisper_verb(message as text)
	set name = "whisper"

	if (!src.can_use_say)
		boutput(src, SPAN_ALERT("You can not speak!"))
		return

	if (!message)
		return

	src.whisper(message)

/mob/verb/say_verb(message as text)
	set name = "say"

	if (!src.can_use_say)
		boutput(src, SPAN_ALERT("You can not speak!"))
		return

	if (!message)
		return

	src.say(message, flags = SAYFLAG_SPOKEN_BY_PLAYER)

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
	src.say_verb("; " + msg)

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

		if (A.ensure_say_tree().GetOutputByID(SPEECH_OUTPUT_SILICONCHAT))
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

			if (src.ensure_say_tree().GetOutputByID(SPEECH_OUTPUT_SILICONCHAT))
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
			continue

		if (istype(M, /mob/dead/target_observer))
			var/mob/dead/target_observer/tobserver = M
			if(!tobserver.is_respawnable)
				continue
		if (iswraith(M))
			var/mob/living/intangible/wraith/the_wraith = M
			if (!the_wraith.hearghosts)
				continue

		if (isdead(M) || iswraith(M) || isghostdrone(M) || isVRghost(M) || inafterlifebar(M) || istype(M, /mob/living/intangible/seanceghost))
			boutput(M, rendered)



//changeling hivemind say
/mob/proc/say_hive(var/message, var/datum/abilityHolder/changeling/hivemind_owner)
	var/name = src.real_name
	var/alt_name = ""

	if (!hivemind_owner)
		return

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

/mob/proc/say_understands(var/mob/other, var/forced_language)
	if (isdead(src))
		return 1
//	else if (istype(other, src.type) || istype(src, other.type))
//		return 1
//	var/L = other.say_language
	// if (forced_language)
	// 	L = forced_language
	// if (understands_language(L))
	// 	return 1
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
		speechverb = speech_verb_say
		if (ending == "?")
			speechverb = speech_verb_ask
		else if (ending == "!")
			speechverb = speech_verb_exclaim
	if (src.stuttering)
		speechverb = speech_verb_stammer
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

	// if (src.singing || (src.bioHolder && src.bioHolder.HasEffect("accent_elvis")))
	// 	// use note icons instead of normal quotes
	// 	var/note_type = src.singing & SAYFLAG_BAD_SINGING ? "notebad" : "note"
	// 	var/note_img = "<img class='icon misc' style='position: relative; bottom: -3px;' src='[resource("images/radio_icons/[note_type].png")]'>"
	// 	if (src.singing & SAYFLAG_LOUD_SINGING)
	// 		first_quote = "[note_img][note_img]"
	// 		second_quote = first_quote
	// 	else
	// 		first_quote = note_img
	// 		second_quote = note_img
	// 	// select singing adverb
	// 	var/adverb = ""
	// 	if (src.singing & SAYFLAG_BAD_SINGING)
	// 		adverb = pick("dissonantly", "flatly", "unmelodically", "tunelessly")
	// 	else if (src.traitHolder?.hasTrait("nervous"))
	// 		adverb = pick("nervously", "tremblingly", "falteringly")
	// 	else if (src.singing & SAYFLAG_LOUD_SINGING && !src.traitHolder?.hasTrait("smoker"))
	// 		adverb = pick("loudly", "deafeningly", "noisily")
	// 	else if (src.singing & SAYFLAG_SOFT_SINGING)
	// 		adverb = pick("softly", "gently")
	// 	else if (src.mind?.assigned_role == "Musician")
	// 		adverb = pick("beautifully", "tunefully", "sweetly")
	// 	else if (src.bioHolder?.HasEffect("accent_scots"))
	// 		adverb = pick("sorrowfully", "sadly", "tearfully")
	// 	// select singing verb
	// 	if (src.traitHolder?.hasTrait("smoker"))
	// 		speechverb = "rasps"
	// 		if ((singing & SAYFLAG_LOUD_SINGING))
	// 			speechverb = "sings Tom Waits style"
	// 	else if (src.traitHolder?.hasTrait("french") && rand(2) < 1)
	// 		speechverb = "sings [pick("Charles Trenet", "Serge Gainsborough", "Edith Piaf")] style"
	// 	else if (src.bioHolder?.HasEffect("accent_swedish"))
	// 		speechverb = "sings disco style"
	// 	else if (src.bioHolder?.HasEffect("accent_scots"))
	// 		speechverb = pick("laments", "sings", "croons", "intones", "sobs", "bemoans")
	// 	else if (src.bioHolder?.HasEffect("accent_chav"))
	// 		speechverb = "raps"
	// 	else if (src.singing & SAYFLAG_SOFT_SINGING)
	// 		speechverb = pick("hums", "lullabies")
	// 	else
	// 		speechverb = pick("sings", pick("croons", "intones", "warbles"))
	// 	if (adverb != "")
	// 	// combine adverb and verb
	// 		speechverb = "[adverb] [speechverb]"
	// 	// add style for singing
	// 	text = "<i>[text]</i>"
	// 	class = "sing"

	if (special)
		if (special == "gasp_whisper")
			speechverb = speech_verb_gasp
			loudness -= 1

	// hi cirr here i feel this should be relative for weak mobs
	var/health_percentage = (src.health/(max(1, src.max_health))) * 100 // prevent div/0 errors from stopping people talking
	// better to inaccurately not gasp than be silenced by runtimes
	if (health_percentage <= 20)
		speechverb = speech_verb_gasp
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
/mob/emote(act, voluntary = 0, atom/target)
	set waitfor = FALSE //this shouldn't be necessary, but I think set SpacemanDMM_should_not_sleep isn't respecting /mob/parent_type = /atom/movable
	.=..()
	SEND_SIGNAL(src, COMSIG_MOB_EMOTE, act, voluntary, target)

/mob/proc/emote_check(voluntary = 1, time = 1 SECOND, admin_bypass = TRUE, dead_check = TRUE)
	if (src.emote_allowed)
		if (dead_check && isdead(src))
			src.emote_allowed = FALSE
			return FALSE
		if (voluntary && (src.hasStatus("unconscious") || src.hasStatus("paralysis") || isunconscious(src)))
			return FALSE
		if (world.time >= (src.last_emote_time + src.last_emote_wait))
			if (!no_emote_cooldowns && !(src.client && (src.client.holder && admin_bypass) && !src.client.player_mode) && voluntary)
				src.emote_allowed = FALSE
				src.last_emote_time = world.time
				src.last_emote_wait = time
				SPAWN(time)
					src.emote_allowed = TRUE
			return TRUE
		else
			return FALSE
	else
		return FALSE

/mob/verb/ooc(msg as text)
	say(":ooc [msg]")

/mob/verb/looc(msg as text)
	say(":looc [msg]")

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
	src.toggle_hearing_all(!usr.client.preferences.local_deadchat)
	boutput(usr, SPAN_NOTICE("[usr.client.preferences.local_deadchat ? "Now" : "No longer"] hearing local chat only."))

/mob/dead/Login()
	. = ..()
	src.toggle_hearing_all(!usr.client.preferences.local_deadchat)

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

/mob/proc/show_message(msg, type, alt, alt_type, group = "")
	if (!src.client)
		return
	if(isnull(msg))
		CRASH("show_message() called with null message.")

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

	if (isunconscious(src) || src.sleeping || src.getStatusDuration("unconscious"))
		if (prob(20))
			boutput(src, "<I>... You can almost hear something ...</I>")
			if (isliving(src))
				for (var/mob/dead/target_observer/observer in src:observers)
					boutput(observer, "<I>... You can almost hear something ...</I>")
	else
		boutput(src, msg, group)

		var/psychic_link = src.get_psychic_link()
		if (ismob(psychic_link))
			boutput(psychic_link, msg, group)

		if(!check_failed && isliving(src))
			for (var/mob/dead/target_observer/M in src.observers)
				if (M.client?.holder && !M.client.player_mode)
					if (M.mind)
						msg = "<span class='adminHearing' data-ctx='[M.client.chatOutput.getContextFlags()]'>[msg]</span>"
					boutput(M, msg, group)
				else
					boutput(M, msg, group)

// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"

/mob/visible_message(var/message, var/self_message, var/blind_message, var/group = "")
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
/atom/proc/visible_message(var/message, var/blind_message, var/group = "")
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
/atom/proc/audible_message(var/message, var/alt, var/alt_type, var/group = "")
	for (var/mob/M in all_hearers(null, src))
		if (!M.client)
			continue
		M.show_message(message, 2, alt, alt_type, group)

/mob/audible_message(var/message, var/self_message, var/alt, var/alt_type, var/group = "")
	for (var/mob/M in all_hearers(null, src))
		if (!M.client)
			continue
		var/msg = message
		if (self_message && M==src)
			msg = self_message
		M.show_message(msg, 2, alt, alt_type, group)
