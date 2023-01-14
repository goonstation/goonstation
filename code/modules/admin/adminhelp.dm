#define ADMINHELP_DELAY 30 // 3 seconds
////////////////////////////////
/mob/verb/adminhelp()
	set category = "Commands"
	set name = "adminhelp"

	var/client/client = src.client

	if (IsGuestKey(client.key))
		boutput(client.mob, "You are not authorized to communicate over these channels.")
		gib(client.mob)
		return

	if (client.cloud_available() && client.cloud_get("adminhelp_banner"))
		boutput(client.mob, "You have been banned from using this command.")
		return

	if(ON_COOLDOWN(client.player, "ahelp", ADMINHELP_DELAY))
		boutput(src, "You must wait [time_to_text(ON_COOLDOWN(src, "ahelp", 0))].")
		return

	var/msg = input("Please enter your help request to admins.\nAdminhelps are also sent to admins via Discord.\n\nFor questions on game mechanics, use Mentorhelp (F3).", "Adminhelp") as null|text

	msg = copytext(html_encode(msg), 1, MAX_MESSAGE_LEN * 4)

	if (!msg)
		return

	if (client.mob.mind)
		client.mob.add_karma(-1)

//	for_no_raisin(client.mob, msg)

	for (var/client/C)
		if (C.holder)
			if (C.player_mode && !C.player_mode_ahelp)
				continue
			else
				boutput(C, "<span class='ahelp'><font size='3'><b><span class='alert'>HELP: </span>[key_name(client.mob,0,0)][(client.mob.real_name ? "/"+client.mob.real_name : "")] <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[client.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [msg]</font></span>")
				switch(C.holder.audible_ahelps)
					if(PM_AUDIBLE_ALERT)
						C.mob.playsound_local(C.mob.loc, 'sound/misc/newsting.ogg', 50, 1)
					if(PM_DECTALK_ALERT)
						var/audio = dectalk(msg)
						var/vol = C.getVolume(VOLUME_CHANNEL_ADMIN)
						if(vol)
							C.chatOutput.playDectalk(audio["audio"], "Admin Help from [src] ([src.ckey]) to [C.mob.ckey]", vol)

#ifdef DATALOGGER
	game_stats.Increment("adminhelps")
	game_stats.ScanText(msg)
#endif
	boutput(client.mob, "<span class='ahelp'><font size='3'><b><span class='alert'>HELP: </span> You</b>: [msg]</font></span>")
	logTheThing(LOG_AHELP, client.mob, "HELP: [msg]")
	var/logLine = global.logLength
	logTheThing(LOG_DIARY, client.mob, "HELP: [msg]", "ahelp")

	if (!first_adminhelp_happened)
		first_adminhelp_happened = 1
		var/ircmsg[] = new()
		ircmsg["key"] = "Loggo"
		ircmsg["name"] = "First Adminhelp Notice"
		// ircmsg["msg"] = "Logs for this round can be found here: https://mini.xkeeper.net/ss13/admin/log-get.php?id=[config.server_id]&date=[roundLog_date]"
		ircmsg["msg"] = "Logs for this round can be found here: https://mini.xkeeper.net/ss13/admin/log-viewer.php?server=[config.server_id]&redownload=1&view=[roundLog_date].html"
		ircbot.export_async("help", ircmsg)

	var/dead = isdead(client.mob) ? "Dead " : ""
	var/ircmsg[] = new()
	ircmsg["key"] = client.key
	ircmsg["name"] = client.mob.job ? "[stripTextMacros(client.mob.real_name)] \[[dead][client.mob.mind?.special_role] [client.mob.job]]" : (istype(client.mob, /mob/new_player) ? "<not ingame>" : "[stripTextMacros(client.mob.real_name)] \[[dead][client.mob.mind?.special_role]]")
	ircmsg["msg"] = html_decode(msg)
	ircmsg["log_link"] = "https://mini.xkeeper.net/ss13/admin/log-viewer.php?server=[config.server_id]&redownload=1&view=[roundLog_date].html#l[logLine]"
	ircbot.export_async("help", ircmsg)

	return msg

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
					var/rendered = "<span class='[class]'><b>[mmouse.is_admin ? "A" : "M"]MOUSEWHISPER: [key_name(client.mob,0,0,1)]<span class='name text-normal' data-ctx='\ref[src.mind]'>[(client.mob.real_name ? "/"+client.mob.real_name : "")]</span> <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[client.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[msg]</span></span>"
					boutput(C,  "<span class='adminHearing' data-ctx='[C.chatOutput.ctxFlag]'>[rendered]</span>")
		logTheThing(LOG_DIARY, client.mob, "([mmouse.is_admin ? "A" : "M"]MOUSEWHISPER): [msg]", "say")
		return

	if (client.cloud_available() && client.cloud_get("mentorhelp_banner"))
		boutput(client.mob, "You have been banned from using this command.")
		return

	if(ON_COOLDOWN(client.player, "ahelp", ADMINHELP_DELAY))
		boutput(src, "You must wait [time_to_text(ON_COOLDOWN(src, "ahelp", 0))].")
		return

	var/msg = input("Enter your help request to mentors.\nMentorhelps are sent to mentors via Discord.\n\nPlease use Adminhelp (F1) for rules questions.", "mentorhelp") as null|text

	msg = copytext(strip_html(msg), 1, MAX_MESSAGE_LEN * 4)
	if (client.can_see_mentor_pms())
		msg = linkify(msg)

	if (!msg)
		return

	if (client?.ismuted())
		return


	for (var/client/C)
		if (C.holder)
			if (C.player_mode && !C.player_mode_mhelp)
				continue
			else
				var/rendered = "<span class='mhelp'><b>MENTORHELP: [key_name(client.mob,0,0,1)]<span class='name text-normal' data-ctx='\ref[src.mind]'>[(client.mob.real_name ? "/"+client.mob.real_name : "")]</span> <A HREF='?src=\ref[C.holder];action=adminplayeropts;targetckey=[client.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: <span class='message'>[msg]</span></span>"
				boutput(C,  "<span class='adminHearing' data-ctx='[C.chatOutput.ctxFlag]'>[rendered]</span>")
		else if (C?.can_see_mentor_pms())
			if(istype(C.mob, /mob/dead/observer) || C.mob.type == /mob/dead/target_observer || C.mob.type == /mob/dead/target_observer/mentor_mouse_observer || istype(C.mob, /mob/living/critter/small_animal/mouse/weak/mentor))
				var/rendered = "<span class='mhelp'><b>MENTORHELP: [key_name(client.mob,0,0,1)]<span class='name text-normal' data-ctx='\ref[src.mind]'>[(client.mob.real_name ? "/"+client.mob.real_name : "")]</span></b>: <span class='message'>[msg]</span></span>"
				boutput(C, "<span class='adminHearing' data-ctx='[C.chatOutput.ctxFlag]'>[rendered]</span>")
			else
				boutput(C, "<span class='mhelp'><b>MENTORHELP: [key_name(client.mob,0,0,1)]</b>: <span class='message'>[msg]</span></span>")

	boutput(client.mob, "<span class='mhelp'><b>MENTORHELP: You</b>: [msg]</span>")
	logTheThing(LOG_MHELP, client.mob, "MENTORHELP: [msg]")
	logTheThing(LOG_DIARY, client.mob, "MENTORHELP: [msg]", "mhelp")
#ifdef DATALOGGER
	game_stats.Increment("mentorhelps")
#endif
	var/dead = isdead(client.mob) ? "Dead" : ""
	var/ircmsg[] = new()
	ircmsg["key"] = client.key
	ircmsg["name"] = client.mob.job ? "[stripTextMacros(client.mob.real_name)] \[[dead] [client.mob.job]]" : (dead ? "[stripTextMacros(client.mob.real_name)] \[[dead]\]" : stripTextMacros(client.mob.real_name))
	ircmsg["msg"] = html_decode(msg)
	ircbot.export_async("mentorhelp", ircmsg)

/mob/verb/pray(msg as text)
	set category = "Commands"
	set name = "pray"
	set desc = "Attempt to gain the attention of a divine being. Note that it's not necessarily the kind of attention you want."

	var/client/client = src.client

	if(!client)
		return
	if(client.ismuted())
		boutput(client.mob, "You are muted and cannot pray.")
		return
	if(client.cloud_available() && client.cloud_get( "prayer_banner" ))
		boutput(client.mob, "You have been banned from using this command.")
		return

	if (IsGuestKey(client.key))
		boutput(client.mob, "You are not authorized to communicate over these channels.")
		gib(client.mob)
		return

	if(ON_COOLDOWN(client.player, "ahelp", ADMINHELP_DELAY))
		boutput(src, "You must wait [time_to_text(ON_COOLDOWN(src, "ahelp", 0))].")
		return

	if(!msg)
		msg = input("Please enter your prayer to any gods that may be listening - be careful what you wish for, as the gods may be the vengeful sort!") as null|text

	if(msg)
		phrase_log.log_phrase("prayer", msg)

	msg = copytext(strip_html(msg), 1, MAX_MESSAGE_LEN)

	if (!msg)
		return

	var/in_chapel = 0
	if(istype(get_area(client.mob), /area/station/chapel))
		in_chapel = 1

	if (client.mob.mind)
		src.add_karma(-1)

	var/is_atheist = client.mob.traitHolder?.hasTrait("atheist")

	if (is_atheist)
		boutput(client.mob, "You feel ridiculous doing it, but manage to get through a silent prayer,</B> <I>\"[msg]\"</I>")
		client.mob.take_oxygen_deprivation(10)
		logTheThing(LOG_AHELP, client.mob, "PRAYER (atheist): [msg]")
		logTheThing(LOG_DIARY, client.mob, "PRAYER (atheist): [msg]", "ahelp")
	else
		boutput(client.mob, "<B>You whisper a silent prayer,</B> <I>\"[msg]\"</I>")
		logTheThing(LOG_AHELP, client.mob, "PRAYER: [msg]")
		logTheThing(LOG_DIARY, client.mob, "PRAYER: [msg]", "ahelp")

#ifdef DATALOGGER
	game_stats.Increment("prayers")
#endif

	var/audio

	for (var/client/C)
		if (!C.mob) continue
		var/mob/M = C.mob
		if (C.holder)
			if (!M.client.holder.hear_prayers || (M.client.player_mode == 1 && M.client.player_mode_ahelp == 0)) //XOR for admin prayer setting and player mode w/ no ahelps
				continue
			else
				boutput(M, "<span class='notice' [in_chapel? "style='font-size:1.1em'":""]><B>PRAYER: [is_atheist ? "(ATHEIST)" : ""]</B><a href='?src=\ref[M.client.holder];action=subtlemsg&targetckey=[client.ckey]'>[client.key]</a> / [client.mob.real_name ? client.mob.real_name : client.mob.name] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[client.ckey]' class='popt'><i class='icon-info-sign'>: <I>[msg]</I></span>")
				if(M.client.holder.audible_prayers == 1)
					M << sound("sound/misc/boing/[rand(1,6)].ogg", volume=50, wait=0)
				else if(M.client.holder.audible_prayers == 2) // this is a terrible idea
					if(!audio)
						audio = dectalk(msg)
					var/vol = M.client.getVolume(VOLUME_CHANNEL_ADMIN)
					if(vol)
						M.client.chatOutput.playDectalk(audio["audio"], "prayer by [src] ([src.ckey]) to [M.ckey]", vol)
	return msg

/proc/do_admin_pm(var/C, var/mob/user) //C is a passed ckey

	var/mob/M = ckey_to_mob(C)
	if(M)
		if (!( ismob(M) ))
			return
		if (!user || !user.client)
			return

		if (!user.client.holder && !(M.client && M.client.holder))
			return

		var/client/user_client = user.client

		var/t = input("Message:", text("Private message to [admin_key(M.client, 1)]")) as null|text

		M = ckey_to_mob(C)
		user = user_client.mob

		if(!(user && user.client && user.client.holder && user.client.holder.level >= LEVEL_ADMIN))
			t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN * 4)
		if (!( t ))
			return

		if (user.client.holder)
			// Sender is admin
			boutput(M, {"
				<div style='border: 2px solid red; font-size: 110%;'>
					<div style="color: black; background: #f88; font-weight: bold; border-bottom: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
						Admin PM from [key_name(user, 0, 0)]
					</div>
					<div style="padding: 0.2em 0.5em;">
					[t]
					</div>
					<div style="font-size: 90%; background: #fcc; font-weight: bold; border-top: 1px solid red; text-align: center; padding: 0.2em 0.5em;">
						<a href=\"byond://?action=priv_msg&target=[user.ckey]" style='color: #833; font-weight: bold;'>&lt; Click to Reply &gt;</a></div>
					</div>
				</div>
				"}, forceScroll=TRUE)
			M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
			boutput(user, "<span class='ahelp' class=\"bigPM\">Admin PM to-<b>[key_name(M, 0, 0)][(M.real_name ? "/"+M.real_name : "")] <A HREF='?src=\ref[user.client.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [t]</span>")
			M.client.make_sure_chat_is_open()
		else
			// Sender is not admin
			if (M.client && M.client.holder)
				// But recipient is
				boutput(M, "<span class='ahelp' class=\"bigPM\">Reply PM from-<b>[key_name(user, 0, 0)][(user.real_name ? "/"+user.real_name : "")] <A HREF='?src=\ref[M.client.holder];action=adminplayeropts;targetckey=[user.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [t]</span>")
				M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
			else
				boutput(M, "<span class='alert' class=\"bigPM\">Reply PM from-<b>[key_name(user, 0, 0)]</b>: [t]</span>")
				M << sound('sound/misc/adminhelp.ogg', volume=100, wait=0)
			boutput(user, "<span class='ahelp' class=\"bigPM\">Reply PM to-<b>[key_name(M, 0, 0)]</b>: [t]</span>")

		logTheThing(LOG_AHELP, user, "<b>PM'd [constructTarget(M,"admin_help")]</b>: [t]")
		logTheThing(LOG_DIARY, user, "PM'd [constructTarget(M,"diary")]: [t]", "ahelp")

		var/ircmsg[] = new()
		ircmsg["key"] = user?.client ? user.client.key : ""
		ircmsg["name"] = stripTextMacros(user.real_name)
		ircmsg["key2"] = (M != null && M.client != null && M.client.key != null) ? M.client.key : ""
		ircmsg["name2"] = (M != null && M.real_name != null) ? stripTextMacros(M.real_name) : ""
		ircmsg["msg"] = html_decode(t)
		ircbot.export_async("pm", ircmsg)

		//we don't use message_admins here because the sender/receiver might get it too
		for (var/client/CC)
			if (!CC.mob) continue
			var/mob/K = CC.mob
			if(K.client.holder && K.key != user.key && (M && K.key != M.key))
				if (K.client.player_mode && !K.client.player_mode_ahelp)
					continue
				else
					boutput(K, "<span class='ahelp'><b>PM: [key_name(user,0,0)][(user.real_name ? "/"+user.real_name : "")] <A HREF='?src=\ref[K.client.holder];action=adminplayeropts;targetckey=[user.ckey]' class='popt'><i class='icon-info-sign'></i></A> <i class='icon-arrow-right'></i> [key_name(M,0,0)][(M.real_name ? "/"+M.real_name : "")] <A HREF='?src=\ref[K.client.holder];action=adminplayeropts;targetckey=[M.ckey]' class='popt'><i class='icon-info-sign'></i></A></b>: [t]</span>")
