/client/proc/set_mentorhelp_visibility(var/set_as = null)
	if (!isnull(set_as))
		player.see_mentor_pms = set_as
	else
		player.see_mentor_pms = !player.see_mentor_pms
	boutput(src, "<span class='ooc mentorooc'>You will [player.see_mentor_pms ? "now" : "no longer"] see Mentorhelps [player.see_mentor_pms ? "and" : "or"] show up as a Mentor.</span>")

/client/proc/toggle_mentorhelps()
	set name = "Toggle Mentorhelps"
	set category = "Commands"
	set desc = "Show or hide mentorhelp messages. You will also no longer show up as a mentor in OOC and via the Who command if you disable mentorhelps."

	if (!src.is_mentor() && !src.holder)
		boutput(src, SPAN_ALERT("Only mentors may use this command."))
		src.verbs -= /client/proc/toggle_mentorhelps // maybe?
		return

	src.set_mentorhelp_visibility()

/mob/verb/mentorhelp()
	set category = "Commands"
	set name = "mentorhelp"

	var/client/client = src.client

	if (IsGuestKey(client.key))
		boutput(client.mob, "You are not authorized to communicate over these channels.")
		gib(client.mob)
		return

	var/mob/dead/target_observer/mentor_mouse_observer/mmouse = locate() in src
	if(mmouse) // mouse in your pocket takes precedence over mhelps
		var/msg = input("Please enter your whispers to the mouse:") as null|text
		msg = copytext(strip_html(msg), 1, MAX_MESSAGE_LEN * 4)
		if (!msg)
			return
		var/class = mmouse.is_admin ? "adminooc" : "mhelp"
		boutput(mmouse, "<span class='[class]'><b>[client.mob]</b> whispers: \"<i>[msg]</i>\"</span>")
		boutput(client.mob, "<span class='[class]'>You whisper to \the [mmouse]: \"<i>[msg]</i>\"</span>")
		for (var/client/C)
			if (C.holder)
				if (C.player_mode || C == client || C == mmouse.client)
					continue
				else
					var/rendered = "<span class='[class]'><b>[mmouse.is_admin ? "A" : "M"]MOUSEWHISPER: [key_name(client.mob,0,0,1)]<span class='name text-normal' data-ctx='\ref[src.mind]'>[(client.mob.real_name ? "/"+client.mob.real_name : "")]</span> <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[client.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [SPAN_MESSAGE("[msg]")]</span>"
					boutput(C,  "<span class='adminHearing' data-ctx='[C.chatOutput.ctxFlag]'>[rendered]</span>")
		logTheThing(LOG_DIARY, client.mob, "([mmouse.is_admin ? "A" : "M"]MOUSEWHISPER): [msg]", "say")
		return

	if (client.player.cloudSaves.getData("mentorhelp_banner"))
		boutput(client.mob, "You have been banned from using this command.")
		return

	if(ON_COOLDOWN(client.player, "ahelp", ADMINHELP_DELAY))
		boutput(src, "You must wait [time_to_text(ON_COOLDOWN(src, "ahelp", 0))].")
		return

	var/msg = input("Enter your help request to mentors.\nMentorhelps are sent to mentors via Discord.\n\nPlease use Adminhelp (F1) for rules questions.", "mentorhelp") as null|message

	msg = copytext(strip_html(msg, strip_newlines=FALSE), 1, MAX_MESSAGE_LEN * 4)
	if (client.can_see_mentor_pms())
		msg = linkify(msg)

	if (!msg)
		return

	if (client?.ismuted())
		return

	var/dead = isdead(client.mob) ? "Dead " : ""
	var/ircmsg[] = new()
	ircmsg["key"] = client.key
	ircmsg["name"] = client.mob.job ? "[stripTextMacros(client.mob.real_name)] \[[dead][client.mob.job]]" : (dead ? "[stripTextMacros(client.mob.real_name)] \[[dead]\]" : stripTextMacros(client.mob.real_name))
	ircmsg["msg"] = html_decode(msg)
	var/unique_message_id = md5("mhelp" + json_encode(ircmsg))
	ircmsg["msgid"] = unique_message_id
	ircbot.export_async("mentorhelp", ircmsg)

	var/src_keyname = key_name(client.mob, 0, 0, 1, additional_url_data="&msgid=[unique_message_id]")

	for (var/client/C)
		if (C.holder)
			if (C.player_mode && !C.player_mode_mhelp)
				continue
			else
				var/rendered = SPAN_MHELP("<b>MENTORHELP: [src_keyname]<span class='name text-normal' data-ctx='\ref[src.mind]'>[(client.mob.real_name ? "/"+client.mob.real_name : "")]</span> <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[client.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [SPAN_MESSAGE("[msg]")]")
				boutput(C,  "<span class='adminHearing' data-ctx='[C.chatOutput.ctxFlag]'>[rendered]</span>")
		else if (C?.can_see_mentor_pms())
			if(istype(C.mob, /mob/dead/observer) || C.mob.type == /mob/dead/target_observer || C.mob.type == /mob/dead/target_observer/mentor_mouse_observer || istype(C.mob, /mob/living/critter/small_animal/mouse/weak/mentor))
				var/rendered = SPAN_MHELP("<b>MENTORHELP: [src_keyname]<span class='name text-normal' data-ctx='\ref[src.mind]'>[(client.mob.real_name ? "/"+client.mob.real_name : "")]</span></b>: [SPAN_MESSAGE("[msg]")]")
				boutput(C, "<span class='adminHearing' data-ctx='[C.chatOutput.ctxFlag]'>[rendered]</span>")
			else
				boutput(C, SPAN_MHELP("<b>MENTORHELP: [src_keyname]</b>: [SPAN_MESSAGE("[msg]")]"))

	boutput(client.mob, SPAN_MHELP("<b>MENTORHELP: You</b>: [msg]"))
	logTheThing(LOG_MHELP, client.mob, "MENTORHELP: [msg]")
	logTheThing(LOG_DIARY, client.mob, "MENTORHELP: [msg]", "mhelp")
#ifdef DATALOGGER
	game_stats.Increment("mentorhelps")
#endif
