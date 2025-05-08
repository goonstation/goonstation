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

//no, voluntary is not a boolean. screm
/mob/emote(act, voluntary = 0, atom/target)
	set waitfor = FALSE //this shouldn't be necessary, but I think set SpacemanDMM_should_not_sleep isn't respecting /mob/parent_type = /atom/movable
	.=..()
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

/mob/verb/toggleflyingchat()
	set desc = "Toggle seeing what people say over their heads"
	set name = "Toggle Flying Chat"

	if (!usr.client) //How could this even happen?
		return

	usr.client.preferences.flying_chat_hidden = !usr.client.preferences.flying_chat_hidden
	boutput(usr, SPAN_NOTICE("[usr.client.preferences.flying_chat_hidden ? "No longer": "Now"] seeing flying chat."))

/// Generate a hue for maptext from a given name
/proc/living_maptext_color(given_name)
	var/num = hex2num(copytext(md5(given_name), 1, 7))
	return hsv2rgb(num % 360, (num / 360) % 10 + 18, num / 360 / 10 % 15 + 85)

/// Generate a desatureated hue for maptext from a given name
/proc/dead_maptext_color(given_name)
	var/num = hex2num(copytext(md5(given_name), 1, 7))
	return hsv2rgb((num % 360)%40+240, (num / 360) % 15+5, (((num / 360) / 10) % 15) + 55)

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
/atom/proc/audible_message(var/message, var/alt, var/alt_type, var/group = "")
	for (var/mob/M in all_hearers(null, src))
		if (istype(M, /mob/living/silicon/ai) && !M.client && M.hearing_check(1)) //if heard, relay msg to client mob if they're in aieye form
			var/mob/living/silicon/ai/mainframe = M
			var/mob/message_mob = mainframe.get_message_mob()
			if(isAIeye(message_mob))
				message_mob.show_message(message, null, alt, alt_type, group) // type=null as AIeyes can't hear directly
			continue
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
