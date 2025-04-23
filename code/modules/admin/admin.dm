/////////////////////
//CONTENTS
//Global Vars and procs
//Topic() - A giant fuck tonne of admin options.
//Admin panels
//Admin procs
//

#define INCLUDE_ANTAGS 1
#define STRIP_ANTAG 1

var/global/noir = 0

////////////////////////////////
/proc/message_admins(var/text, var/asay = 0, var/irc = 0)
	var/rendered = SPAN_ADMIN("[SPAN_PREFIX("[irc ? "DISCORD" : "ADMIN <wbr>LOG"]")]: [SPAN_MESSAGE("[text]")]")
	for (var/client/C in clients)
		if(!C.holder)
			continue
		if (!asay && rank_to_level(C.holder.rank) < LEVEL_MOD) // No confidential info for goat farts (Convair880).
			continue
		if (C.player_mode)
			if (!asay || (asay && !C.player_mode_asay))
				continue
		boutput(C, replacetext(replacetext(rendered, "%admin_ref%", "\ref[C.holder]"), "%client_ref%", "\ref[C]"))


/proc/message_coders(var/text) //Shamelessly adapted from message_admins
	var/rendered = SPAN_ADMIN("[SPAN_PREFIX("CODER <wbr>LOG")]: [SPAN_MESSAGE("[text]")]")
	for (var/client/C)
		if (C.mob && C.holder && rank_to_level(C.holder.rank) >= LEVEL_CODER) //This is for edge cases where a coder needs a goddamn notification when it happens
			boutput(C.mob, replacetext(rendered, "%admin_ref%", "\ref[C.holder]"))

/proc/message_coders_vardbg(var/text, var/datum/d)
	var/rendered
	for (var/client/C)
		if (C.mob && C.holder && rank_to_level(C.holder.rank) >= LEVEL_CODER)
			var/dbg_html = C.debug_variable("", d, 0)
			rendered = SPAN_ADMIN("[SPAN_PREFIX("CODER <wbr>LOG")]: [SPAN_MESSAGE("[text]")][dbg_html]")
			boutput(C.mob, replacetext(rendered, "%admin_ref%", "\ref[C.holder]"))

/proc/message_attack(var/text) //Sends a message to folks when an attack goes down
	var/rendered = SPAN_ADMIN("[SPAN_PREFIX("ATTACK <wbr>LOG")]: [SPAN_MESSAGE("[text]")]")
	for (var/client/C)
		if (C.mob && C.holder && C.holder.attacktoggle && !C.player_mode && rank_to_level(C.holder.rank) >= LEVEL_MOD)
			boutput(C.mob, replacetext(rendered, "%admin_ref%", "\ref[C.holder]"))

/proc/rank_to_level(var/rank)
	switch(lowertext(rank))
		if("host")
			return LEVEL_HOST
		if("coder")
			return LEVEL_CODER
		if("administrator")
			return LEVEL_ADMIN
		if("primary administrator")
			return LEVEL_PA
		if("intermediate administrator")
			return LEVEL_IA
		if("secondary administrator")
			return LEVEL_SA
		if("moderator")
			return LEVEL_MOD
		if("goat fart", "ayn rand's armpit")
			return LEVEL_BABBY

/proc/level_to_rank(var/level)
	switch(level)
		if(LEVEL_HOST)
			return "Host"
		if(LEVEL_CODER)
			return "Coder"
		if(LEVEL_ADMIN)
			return "Administrator"
		if(LEVEL_PA)
			return "Primary Administrator"
		if(LEVEL_IA)
			return "Intermediate Administrator"
		if(LEVEL_SA)
			return "Secondary Administrator"
		if(LEVEL_MOD)
			return "Moderator"
		if(LEVEL_BABBY)
			return "Goat Fart or Ayn Rand's Armpit"
	return "ERROR"

/datum/admins/Topic(href, href_list)
	..()

	if (src.level < 0)
		tgui_alert(usr,"UM, EXCUSE ME??  YOU AREN'T AN ADMIN, GET DOWN FROM THERE!")
		usr << csound('sound/voice/farts/poo2.ogg')
		return

	if (usr.client != src.owner)
		message_admins(SPAN_INTERNAL("[key_name(usr)] has attempted to override the admin panel with URL '[href]'!"))
		logTheThing(LOG_ADMIN, usr, "tried to use the admin panel without authorization with URL '[href]'.")
		logTheThing(LOG_DIARY, usr, "tried to use the admin panel without authorization with URL '[href]'.", "admin")
		return

	var/client/targetClient = null
	//Wires bad hack to update the player options menu on click, part 1
	//Also I guess it has sort of expanded now to correctly pick targets
	if (href_list["targetckey"])
		var/targetCkey = href_list["targetckey"]
		for (var/mob/M in mobs) //Find the mob ref for that nerd
			if (M.ckey == targetCkey)
				href_list["target"] = "\ref[M]"
				targetClient = M.client
				break
	if (isnull(href_list["target"]) && href_list["targetmob"])// they're logged out or an npc, but we still want to mess with their mob
		href_list["target"] = href_list["targetmob"]

	var/originWindow
	// var/adminCkey = usr.client.ckey
	var/client/adminClient = usr.client
	if (href_list["origin"])
		originWindow = href_list["origin"]

	if (!href_list["action"])
		//tgui_alert(usr,"You must define an action! Yell at Wire if you see this.")
		return
	switch(href_list["action"])
		if ("ah_mute")//gguhHUhguHUGH
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.player.cloudSaves.putData("adminhelp_banner", usr.client.key)
					src.show_chatbans(C)
		if ("ah_unmute")//guHGUHGUGHGUHG
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.player.cloudSaves.deleteData("adminhelp_banner")
					src.show_chatbans(C)
		if ("mh_mute")//AHDUASHDUHWUDHWDUHWDUWDH
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.player.cloudSaves.putData("mentorhelp_banner", usr.client.key)
					src.show_chatbans(C)
		if ("mh_unmute")//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.player.cloudSaves.deleteData("mentorhelp_banner")
					src.show_chatbans(C)
		if ("pr_mute")
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.player.cloudSaves.putData("prayer_banner", usr.client.key)
					src.show_chatbans(C)
		if ("pr_unmute")
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.player.cloudSaves.deleteData("prayer_banner")
					src.show_chatbans(C)

		if ("load_admin_prefs")
			if (src.level >= LEVEL_MOD)
				src.load_admin_prefs()
			src.show_pref_window(usr)
		if ("save_admin_prefs")
			if (src.level >= LEVEL_MOD)
				src.save_admin_prefs()
		if ("refresh_admin_prefs")
			if (src.level >= LEVEL_MOD)
				src.show_pref_window(usr)

		if ("toggle_extra_verbs")
			if (src.level >= LEVEL_CODER)
				usr.client.toggle_extra_verbs()
				src.show_pref_window(usr)
		if ("toggle_server_toggles_tab")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_server_toggles_tab()
				src.show_pref_window(usr)
		if ("toggle_atom_verbs")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_atom_verbs()
				src.show_pref_window(usr)
		if ("toggle_attack_messages")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_attack_messages()
				src.show_pref_window(usr)
		if ("toggle_adminwho_alerts")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_adminwho_alerts()
				src.show_pref_window(usr)
		if ("toggle_ghost_respawns")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_ghost_respawns()
				src.show_pref_window(usr)
		if ("toggle_rp_word_filtering")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_rp_word_filtering()
				src.show_pref_window(usr)
		if ("toggle_uncool_word_filtering")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_uncool_word_filtering()
				src.show_pref_window(usr)
		if ("toggle_hear_prayers")
			if (src.level >= LEVEL_MOD)
				usr.client.holder.hear_prayers = !usr.client.holder.hear_prayers
				src.show_pref_window(usr)
		if ("toggle_audible_prayers")
			if (src.level >= LEVEL_MOD)
				usr.client.holder.audible_prayers = (usr.client.holder.audible_prayers + 1) % 3
				src.show_pref_window(usr)
		if ("toggle_audible_ahelps")
			if (src.level >= LEVEL_MOD)
				switch(usr.client.holder.audible_ahelps)
					if (PM_NO_ALERT)
						usr.client.holder.audible_ahelps = PM_AUDIBLE_ALERT
					if (PM_AUDIBLE_ALERT)
						usr.client.holder.audible_ahelps = PM_DECTALK_ALERT
					if (PM_DECTALK_ALERT)
						usr.client.holder.audible_ahelps = PM_NO_ALERT
				src.show_pref_window(usr)
		if ("toggle_atags")
			if (src.level >= LEVEL_SA)
				usr.client.toggle_atags()
				src.show_pref_window(usr)
		if ("toggle_buildmode_view")
			if (src.level >= LEVEL_PA)
				usr.client.holder.buildmode_view = !usr.client.holder.buildmode_view
				src.show_pref_window(usr)
		if ("toggle_category")
			var/cat = href_list["cat"]
			if(cat in src.hidden_categories)
				src.owner?.show_verb_category(ADMIN_CAT_PREFIX + cat)
				src.hidden_categories -= cat
			else
				src.owner?.hide_verb_category(ADMIN_CAT_PREFIX + cat)
				src.hidden_categories |= cat
			src.show_pref_window(usr)
		if ("toggle_spawn_in_loc")
			if (src.level >= LEVEL_MOD)
				usr.client.holder.spawn_in_loc = !usr.client.holder.spawn_in_loc
				src.show_pref_window(usr)
		if ("toggle_topic_log")
			if (src.level >= LEVEL_MOD)
				src.show_topic_log = !show_topic_log
				src.show_pref_window(usr)
		if ("toggle_skip_manifest")
			if (src.level >= LEVEL_MOD)
				src.skip_manifest = !skip_manifest
				src.show_pref_window(usr)
		if ("toggle_hide_offline")
			if (src.level >= LEVEL_MOD)
				src.hide_offline_indicators = !hide_offline_indicators
				src.show_pref_window(usr)
		if ("toggle_slow_stat")
			if (src.level >= LEVEL_MOD)
				src.slow_stat = !slow_stat
				src.show_pref_window(usr)
		if ("toggle_auto_stealth")
			if (src.level >= LEVEL_SA)
				src.auto_stealth = !(src.auto_stealth)
				boutput(usr, SPAN_NOTICE("Auto Stealth [src.auto_stealth ? "enabled" : "disabled"]."))
				if (src.auto_stealth)
					if (src.auto_alt_key)
						src.auto_alt_key = 0
					if (usr.client.alt_key)
						src.set_alt_key()
					if (!usr.client.stealth && !isnull(src.auto_stealth_name))
						src.set_stealth_mode(src.auto_stealth_name)
					else if (isnull(src.auto_stealth_name))
						var/new_key = input("Enter your desired display name.", "Fake Key", usr.client.key) as null|text
						if (!new_key)
							src.auto_stealth_name = null
							boutput(usr, SPAN_NOTICE("Auto Stealth name removed."))
							return src.show_pref_window(usr)
						if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", list("OK", "Cancel")) == "OK")
							src.auto_stealth_name = new_key
							src.set_stealth_mode(src.auto_stealth_name)
						else
							src.auto_stealth_name = null
							boutput(usr, SPAN_NOTICE("Auto Stealth name removed."))
							return src.show_pref_window(usr)
				src.show_pref_window(usr)
		if ("set_auto_stealth_name")
			if (src.level >= LEVEL_SA)
				var/new_key = input("Enter your desired display name.", "Fake Key", usr.client.key) as null|text
				if (!new_key)
					src.auto_stealth_name = null
					boutput(usr, SPAN_NOTICE("Auto Stealth name removed."))
					return
				if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", list("OK", "Cancel")) == "OK")
					src.auto_stealth_name = new_key
					src.show_pref_window(usr)
				else
					src.auto_stealth_name = null
					boutput(usr, SPAN_NOTICE("Auto Stealth name removed."))
					return
		if ("toggle_auto_alt_key")
			if (src.level >= LEVEL_SA)
				src.auto_alt_key = !(src.auto_alt_key)
				boutput(usr, SPAN_HINT("Auto Alt Key [src.auto_alt_key ? "enabled" : "disabled"]."))
				if (src.auto_alt_key)
					if (src.auto_stealth)
						src.auto_stealth = 0
					if (usr.client.stealth)
						src.set_stealth_mode()
					if (!usr.client.alt_key && !isnull(src.auto_alt_key_name))
						src.set_alt_key(src.auto_alt_key_name)
					else if (isnull(src.auto_alt_key_name))
						var/new_key = input("Enter your desired display name.", "Alt Key", usr.client.key) as null|text
						if (!new_key)
							src.auto_alt_key_name = null
							boutput(usr, SPAN_HINT("Auto Alt Key removed."))
							return src.show_pref_window(usr)
						if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", list("OK", "Cancel")) == "OK")
							src.auto_alt_key_name = new_key
							src.set_alt_key(src.auto_alt_key_name)
						else
							src.auto_alt_key_name = null
							boutput(usr, SPAN_HINT("Auto Alt Key removed."))
							return src.show_pref_window(usr)
				src.show_pref_window(usr)
		if ("set_auto_alt_key_name")
			if (src.level >= LEVEL_SA)
				var/new_key = input("Enter your desired display name.", "Alt Key", usr.client.key) as null|text
				if (!new_key)
					src.auto_alt_key_name = null
					boutput(usr, SPAN_NOTICE("Auto Alt Key removed."))
					return
				if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", list("OK", "Cancel")) == "OK")
					src.auto_alt_key_name = new_key
					src.show_pref_window(usr)
				else
					src.auto_alt_key_name = null
					boutput(usr, SPAN_NOTICE("Auto Alt Key removed."))
					return
		if ("set_auto_alias_global_save")
			if (src.level >= LEVEL_SA)
				usr.client.holder.auto_alias_global_save = !usr.client.holder.auto_alias_global_save
				src.show_pref_window(usr)
		if ("refreshoptions")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.holder.playeropt(M)

		if("call_shuttle")
			if (src.level >= LEVEL_SA)
				switch(href_list["type"])
					if("1")
						if ((!( ticker ) || emergency_shuttle.location))
							return
						var/call_reason = input("Enter the reason for the shuttle call (or just hit OK to give no reason)","Shuttle Call Reason","No reason given.") as null|text
						if(!call_reason)
							return
						if (emergency_shuttle.incall())
							command_announcement(call_reason + "<br><b>[SPAN_ALERT("It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")]</b>", "The Emergency Shuttle Has Been Called", css_class = "notice")
							logTheThing(LOG_ADMIN, usr,  "called the Emergency Shuttle (reason: [call_reason])")
							logTheThing(LOG_DIARY, usr, "called the Emergency Shuttle (reason: [call_reason])", "admin")
							message_admins(SPAN_INTERNAL("[key_name(usr)] called the Emergency Shuttle to the station."))

					if("2")
						if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
							return
						switch(emergency_shuttle.direction)
							if(-1)
								emergency_shuttle.incall()
								var/call_reason = input("Enter the reason for the shuttle call (or just hit OK to give no reason)","Shuttle Call Reason","") as null|text
								if(!call_reason)
									call_reason = "No reason given."
								if (emergency_shuttle.incall())
									command_announcement(call_reason + "<br><b>[SPAN_ALERT("It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")]</b>", "The Emergency Shuttle Has Been Called", css_class = "notice")
									logTheThing(LOG_ADMIN, usr, "called the Emergency Shuttle (reason: [call_reason])")
									logTheThing(LOG_DIARY, usr, "called the Emergency Shuttle (reason: [call_reason])", "admin")
									message_admins(SPAN_INTERNAL("[key_name(usr)] called the Emergency Shuttle to the station"))
							if(1)
								emergency_shuttle.recall()
								boutput(world, SPAN_NOTICE("<B>Alert: The shuttle is going back!</B>"))
								logTheThing(LOG_ADMIN, usr, "sent the Emergency Shuttle back")
								logTheThing(LOG_DIARY, usr, "sent the Emergency Shuttle back", "admin")
								message_admins(SPAN_INTERNAL("[key_name(usr)] recalled the Emergency Shuttle"))
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to do a shuttle call.")

		if("edit_shuttle_time")
			if (src.level >= LEVEL_PA)
				var/timeleft = input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", emergency_shuttle.timeleft()) as null|num
				if (isnull(timeleft))
					return
				emergency_shuttle.settimeleft(timeleft)
				logTheThing(LOG_ADMIN, usr, "edited the Emergency Shuttle's timeleft to [timeleft]")
				logTheThing(LOG_DIARY, usr, "edited the Emergency Shuttle's timeleft to [timeleft]", "admin")
				message_admins(SPAN_INTERNAL("[key_name(usr)] edited the Emergency Shuttle's timeleft to [timeleft]"))
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to edit the shuttle timer.")

		if("toggle_shuttle_calling")
			if (src.level >= LEVEL_PA)
				if (!emergency_shuttle.disabled)
					var/choice = tgui_alert(usr, "Which calls should be prevented?", "Shuttle Disabling", list("Manual Calls", "All Calls"))
					switch(choice)
						if ("Manual Calls")
							emergency_shuttle.disabled = SHUTTLE_CALL_MANUAL_CALL_DISABLED
						if ("All Calls")
							emergency_shuttle.disabled = SHUTTLE_CALL_FULLY_DISABLED
				else
					emergency_shuttle.disabled = SHUTTLE_CALL_ENABLED

				var/logmsg = "[emergency_shuttle.disabled ? "dis" : "en"]abled calling the Emergency Shuttle\
					[emergency_shuttle.disabled ? emergency_shuttle.disabled == SHUTTLE_CALL_FULLY_DISABLED ? " completely and totally" : " manually" : ""]."

				logTheThing(LOG_ADMIN, usr, logmsg)
				message_admins("[usr] [logmsg]")
				// someone forgetting about leaving shuttle calling disabled would be bad so let's inform the Admin Crew if it happens, just in case
				var/ircmsg[] = new()
				ircmsg["key"] = src.owner:key
				ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
				ircmsg["msg"] = logmsg
				ircbot.export_async("admin", ircmsg)
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to enable/disable shuttle calling.")

		if("toggle_shuttle_recalling")
			if (src.level >= LEVEL_PA)
				emergency_shuttle.can_recall = !emergency_shuttle.can_recall
				logTheThing(LOG_ADMIN, usr, "[emergency_shuttle.can_recall ? "en" : "dis"]abled recalling the Emergency Shuttle")
				logTheThing(LOG_DIARY, usr, "[emergency_shuttle.can_recall ? "en" : "dis"]abled recalling the Emergency Shuttle", "admin")
				message_admins(SPAN_INTERNAL("[key_name(usr)] [emergency_shuttle.can_recall ? "en" : "dis"]abled recalling the Emergency Shuttle"))
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to enable/disable shuttle recalling.")

		if("notes")
			var/player = null
			var/mob/M = locate(href_list["target"])
			if(M)
				player = M.ckey
			else
				player = href_list["target"]
			if(!player)
				return
			src.viewPlayerNotes(player)

		if("notes2")
			var/player = href_list["target"]
			if(!player)
				return

			switch(href_list["type"])
				if("del")
					if(src.level < LEVEL_SA)
						tgui_alert(usr,"You need to be at least a Secondary Administrator to delete notes.")
						return

					if(href_list["id"])
						if(tgui_alert(usr,"Delete This Note?","Confirmation",list("Yes","No")) != "Yes")
							return
						else
							var/noteId = href_list["id"]

							deletePlayerNote(noteId)
							src.viewPlayerNotes(player)

							logTheThing(LOG_ADMIN, usr, "deleted note [noteId] belonging to [player].")
							logTheThing(LOG_DIARY, usr, "deleted note [noteId] belonging to [player].", "admin")
							message_admins(SPAN_INTERNAL("[key_name(usr)] deleted note [noteId] belonging to <A href='byond://?src=%admin_ref%;action=notes&target=[player]'>[player]</A>."))

							var/ircmsg[] = new()
							ircmsg["key"] = src.owner:key
							ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
							ircmsg["msg"] = "Deleted note [noteId] belonging to [player]"
							ircbot.export_async("admin", ircmsg)

				if("add")
					if(src.level < LEVEL_SA)
						tgui_alert(usr,"You need to be at least a Secondary Adminstrator to add notes.")
						return

					var/the_note = input("Write your note here!", "Note for [player]") as null|message
					if (isnull(the_note) || !length(the_note))
						return

					addPlayerNote(player, usr.ckey, the_note)
					SPAWN(2 SECONDS) src.viewPlayerNotes(player)

					logTheThing(LOG_ADMIN, usr, "added a note for [player]: [the_note]")
					logTheThing(LOG_DIARY, usr, "added a note for [player]: [the_note]", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] added a note for <A href='byond://?src=%admin_ref%;action=notes&target=[player]'>[player]</A>: [the_note]"))

					var/ircmsg[] = new()
					ircmsg["key"] = src.owner:key
					ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
					ircmsg["msg"] = "Added a note for [player]: [the_note]"
					ircbot.export_async("admin", ircmsg)

		if("loginnotice")
			var/player = null
			var/mob/M = locate(href_list["target"])
			if(M)
				player = M.ckey
			else
				player = href_list["target"]
			if(!player)
				return
			src.setLoginNotice(player)

		if("viewcompids")
			var/player = href_list["targetckey"]

			if(src.tempmin)
				logTheThing(LOG_ADMIN, usr, "tried to access the compIDs of [constructTarget(player,"admin")]")
				logTheThing(LOG_DIARY, usr, "tried to access the compIDs of [constructTarget(player,"diary")]", "admin")
				message_admins("[key_name(usr)] tried to access the compIDs of [player] but was denied.")
				tgui_alert(usr,"You need to be an actual admin to view compIDs.")
				del(usr.client)
				return

			view_client_compid_list(usr, player)

			return

		if("centcombans")
			var/mob/target = locate(href_list["target"])
			if (isnull(centcomviewer))
				centcomviewer = new
			centcomviewer.target_key = target.key
			centcomviewer.force_static_data_update = TRUE
			centcomviewer.ui_interact(usr.client.mob)

		/////////////////////////////////////ban stuff
		if ("addban") //Add ban
			var/mob/M = (href_list["target"] ? locate(href_list["target"]) : null)
			usr.client.addBanTemp(M)

		if ("sharkban") //Add ban
			var/mob/M = (href_list["target"] ? locate(href_list["target"]) : null)
			usr.client.sharkban(M)
		/////////////////////////////////////end ban stuff

		if("jobbanpanel")
			var/dat = ""
			var/header = "<b>Pick Job to ban this guy from | <a href='byond://?src=\ref[src];action=jobbanpanel;target=[href_list["target"]]'>Refresh</a><br>"
			var/body
			var/jobs = ""
			var/target
			var/action
			var/M = href_list["target"]
			var/mob/found = locate(href_list["target"])
			if(found) //It's a textref, and not a key.
				M = found
				target = "\ref[M]"
				action = "jobban"
			else //It's a key. We need to cache it's ban history to not make 300 requests to the API.
				target = M
				action = "jobban_offline"
				M = jobban_get_for_player(M)
			if (!M)
				return

			//Determine which system we're using.

			for(var/job in uniquelist(occupations))
				if(job in list("Tourist","Mining Supervisor","Atmospheric Technician","Vice Officer"))
					continue
				if(jobban_isbanned(M, job))
					jobs += "<a href='byond://?src=\ref[src];action=[action];type=[job];target=[target]'><font color=red>[replacetext(job, " ", "&nbsp")]</font></a> "
				else
					jobs += "<a href='byond://?src=\ref[src];action=[action];type=[job];target=[target]'>[replacetext(job, " ", "&nbsp")]</a> " //why doesn't this work

			if(jobban_isbanned(M, "Captain"))
				jobs += "<a href='byond://?src=\ref[src];action=[action];type=Captain;target=[target]'><font color=red>Captain</font></a> "
			else
				jobs += "<a href='byond://?src=\ref[src];action=[action];type=Captain;target=[target]'>Captain</a> " //why doesn't this work

			if(jobban_isbanned(M, "Head of Security"))
				jobs += "<a href='byond://?src=\ref[src];action=[action];type=Head of Security;target=[target]'><font color=red>Head of Security</font></a> "
			else
				jobs += "<a href='byond://?src=\ref[src];action=[action];type=Head of Security;target=[target]'>Head of Security</a> "

			if(jobban_isbanned(M, "Syndicate"))
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Syndicate;target=[target]'><font color=red>[replacetext("Syndicate", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Syndicate;target=[target]'>[replacetext("Syndicate", " ", "&nbsp")]</a> " //why doesn't this work

			if(jobban_isbanned(M, "Special Respawn"))
				jobs += " <a href='byond://?src=\ref[src];action=[action];type=Special Respawn;target=[target]'><font color=red>[replacetext("Special Respawn", " ", "&nbsp")]</font></a> "
			else
				jobs += " <a href='byond://?src=\ref[src];action=[action];type=Special Respawn;target=[target]'>[replacetext("Special Respawn", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Engineering Department"))
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Engineering Department;target=[target]'><font color=red>[replacetext("Engineering Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Engineering Department;target=[target]'>[replacetext("Engineering Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Security Department"))
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Security Department;target=[target]'><font color=red>[replacetext("Security Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Security Department;target=[target]'>[replacetext("Security Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Heads of Staff"))
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Heads of Staff;target=[target]'><font color=red>[replacetext("Heads of Staff", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Heads of Staff;target=[target]'>[replacetext("Heads of Staff", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Everything Except Assistant"))
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Everything Except Assistant;target=[target]'><font color=red>[replacetext("Everything Except Assistant", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Everything Except Assistant;target=[target]'>[replacetext("Everything Except Assistant", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Ghostdrone"))
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Ghostdrone;target=[target]'><font color=red>Ghostdrone</font></a> "
			else
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Ghostdrone;target=[target]'>Ghostdrone</a> "

			if(jobban_isbanned(M, "Custom Names"))
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Custom Names;target=[target]'><font color=red>[replacetext("Having a Custom Name", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='byond://?src=\ref[src];action=[action];type=Custom Names;target=[target]'>[replacetext("Having a Custom Name", " ", "&nbsp")]</a> "


			body = "<br>[jobs]<br><br>"
			dat = "<tt>[header][body]</tt>"
			usr.Browse(dat, "window=jobban2;size=600x150")

		if("jobban")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/job = href_list["type"]
				if (!M) return
				if ((M.client && M.client.holder && (M.client.holder.level > src.level)))
					tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
					return
				var/datum/player/player = make_player(M.ckey) //Get the player so we can use their bancache.
				if (jobban_isbanned(M, job))
					if(player.cached_jobbans.Find("Everything Except Assistant") && job != "Everything Except Assistant")
						tgui_alert(usr,"This person is banned from Everything Except Assistant. You must lift that ban first.")
						return
					if(job in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner"))
						if(player.cached_jobbans.Find("Engineering Department"))
							tgui_alert(usr,"This person is banned from Engineering Department. You must lift that ban first.")
							return
					if(job in list("Security Officer","Security Assistant","Vice Officer","Detective"))
						if(player.cached_jobbans.Find("Security Department"))
							tgui_alert(usr,"This person is banned from Security Department. You must lift that ban first.")
							return
					if(job in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
						if(player.cached_jobbans.Find("Heads of Staff"))
							tgui_alert(usr,"This person is banned from Heads of Staff. You must lift that ban first.")
							return
					logTheThing(LOG_ADMIN, usr, "unbanned [constructTarget(M,"admin")] from [job]")
					logTheThing(LOG_DIARY, usr, "unbanned [constructTarget(M,"diary")] from [job]", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] unbanned [key_name(M)] from [job]"))
					addPlayerNote(M.ckey, usr.ckey, "[usr.ckey] unbanned [M.ckey] from [job]")
					jobban_unban(M, job, usr.ckey)
					if (announce_jobbans) boutput(M, SPAN_ALERT("<b>[key_name(usr)] has lifted your [job] job-ban.</b>"))
				else
					logTheThing(LOG_ADMIN, usr, "banned [constructTarget(M,"admin")] from [job]")
					logTheThing(LOG_DIARY, usr, "banned [constructTarget(M,"diary")] from [job]", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] banned [key_name(M)] from [job]"))
					addPlayerNote(M.ckey, usr.ckey, "[usr.ckey] banned [M.ckey] from [job]")
					if(job == "Everything Except Assistant")
						if(player.cached_jobbans.Find("Engineering Department"))
							jobban_unban(M,"Engineering Department", usr.ckey)
						if(player.cached_jobbans.Find("Security Department"))
							jobban_unban(M,"Security Department", usr.ckey)
						if(player.cached_jobbans.Find("Heads of Staff"))
							jobban_unban(M,"Heads of Staff", usr.ckey)
						for(var/Trank1 in uniquelist(occupations))
							if(player.cached_jobbans.Find("[Trank1]"))
								jobban_unban(M,Trank1, usr.ckey)
					else if(job == "Engineering Department")
						for(var/Trank2 in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner"))
							if(player.cached_jobbans.Find("[Trank2]"))
								jobban_unban(M,Trank2, usr.ckey)
					else if(job == "Security Department")
						for(var/Trank3 in list("Security Officer","Security Assistant","Vice Officer","Detective"))
							if(player.cached_jobbans.Find("[Trank3]"))
								jobban_unban(M,Trank3, usr.ckey)
					else if(job == "Heads of Staff")
						for(var/Trank4 in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
							if(player.cached_jobbans.Find("[Trank4]"))
								jobban_unban(M,Trank4, usr.ckey)
					jobban_fullban(M, job, usr.ckey)
					if (announce_jobbans) boutput(M, SPAN_ALERT("<b>[key_name(usr)] has job-banned you from [job].</b>"))
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to work with job bans.")

		if("jobban_offline")
			if (src.level >= LEVEL_SA)
				var/M = href_list["target"]
				var/job = href_list["type"]
				var/list/cache = jobban_get_for_player(M)
				if (!M) return
				if (jobban_isbanned(cache, job))
					if(cache.Find("Everything Except Assistant") && job != "Everything Except Assistant")
						tgui_alert(usr,"This person is banned from Everything Except Assistant. You must lift that ban first.")
						return
					if(job in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner"))
						if(cache.Find("Engineering Department"))
							tgui_alert(usr,"This person is banned from Engineering Department. You must lift that ban first.")
							return
					if(job in list("Security Officer","Security Assistant","Vice Officer","Detective"))
						if(cache.Find("Security Department"))
							tgui_alert(usr,"This person is banned from Security Department. You must lift that ban first.")
							return
					if(job in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
						if(cache.Find("Heads of Staff"))
							tgui_alert(usr,"This person is banned from Heads of Staff. You must lift that ban first.")
							return
					logTheThing(LOG_ADMIN, usr, "unbanned [constructName(M)](Offline) from [job]")
					logTheThing(LOG_DIARY, usr, "unbanned [constructName(M)](Offline) from [job]", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] unbanned [M](Offline) from [job]"))
					addPlayerNote(M, usr.ckey, "[usr.ckey] unbanned [M](Offline) from [job]")
					jobban_unban(M, job, usr.ckey)
				else
					logTheThing(LOG_ADMIN, usr, "banned [constructName(M)](Offline) from [job]")
					logTheThing(LOG_DIARY, usr, "banned [constructName(M)](Offline) from [job]", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] banned [M](Offline) from [job]"))
					addPlayerNote(M, usr.ckey, "[usr.ckey] banned [M](Offline) from [job]")
					if(job == "Everything Except Assistant")
						if(cache.Find("Engineering Department"))
							jobban_unban(M,"Engineering Department", usr.ckey)
						if(cache.Find("Security Department"))
							jobban_unban(M,"Security Department", usr.ckey)
						if(cache.Find("Heads of Staff"))
							jobban_unban(M,"Heads of Staff", usr.ckey)
						for(var/Trank1 in uniquelist(occupations))
							if(cache.Find("[Trank1]"))
								jobban_unban(M,Trank1, usr.ckey)
					else if(job == "Engineering Department")
						for(var/Trank2 in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner"))
							if(cache.Find("[Trank2]"))
								jobban_unban(M,Trank2, usr.ckey, usr.ckey)
					else if(job == "Security Department")
						for(var/Trank3 in list("Security Officer","Security Assistant","Vice Officer","Detective"))
							if(cache.Find("[Trank3]"))
								jobban_unban(M,Trank3, usr.ckey, usr.ckey)
					else if(job == "Heads of Staff")
						for(var/Trank4 in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
							if(cache.Find("[Trank4]"))
								jobban_unban(M,Trank4, usr.ckey, usr.ckey)
					jobban_fullban(M, job, usr.ckey)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to work with job bans.")


		if ("boot")
			var/mob/M = locate(href_list["target"])
			usr.client.cmd_boot(M)

		if ("mute")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (ismob(M) && M.client)
					var/muted = 0
					if (M.client.ismuted())
						M.client.unmute()
					else
						M.client.mute(-1)
						muted = 1
					logTheThing(LOG_ADMIN, usr, "has [(muted ? "permanently muted" : "unmuted")] [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "has [(muted ? "permanently muted" : "unmuted")] [constructTarget(M,"diary")].", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] has [(muted ? "permanently muted" : "unmuted")] [key_name(M)]."))
					boutput(M, "You have been [(muted ? "permanently muted" : "unmuted")].")
			else
				tgui_alert(usr,"You need to be at least a Moderator to mute people.")

		if ("tempmute")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					var/muted = 0
					if (M.client.ismuted())
						M.client.unmute()
					else
						M.client.mute(60)
						muted = 1
					logTheThing(LOG_ADMIN, usr, "has [(muted ? "temporarily muted" : "unmuted")] [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "has [(muted ? "temporarily muted" : "unmuted")] [constructTarget(M,"diary")].", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] has [(muted ? "temporarily muted" : "unmuted")] [key_name(M)]."))
					boutput(M, "You have been [(muted ? "temporarily muted" : "unmuted")].")
			else
				tgui_alert(usr,"You need to be at least a Moderator to mute people.")
		if ("banooc")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (ismob(M) && M.client)
					var/oocbanned = 0
					if (!oocban_isbanned(M))
						oocban_fullban(M)
						oocbanned = 1
					else
						oocban_unban(M)
					logTheThing(LOG_ADMIN, usr, "has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [constructTarget(M,"diary")].", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [key_name(M)]."))

		if ("toggle_hide_mode")
			if (src.level >= LEVEL_SA)
				ticker.hide_mode = !ticker.hide_mode
				Topic(null, list("src" = "\ref[src]", "action" = "c_mode_panel"))
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to hide the game mode.")

		if ("c_mode_panel") // I removed some broken/discontinued game modes here (Convair880).
			if (src.level >= LEVEL_SA)
				var/cmd = "c_mode_current"
				var/addltext = ""
				var/list/regular_modes = list()
				var/list/other_modes = list()
				for(var/game_type in concrete_typesof(/datum/game_mode))
					var/datum/game_mode/GM = game_type
					if(initial(GM.regular))
						regular_modes[initial(GM.name)] = initial(GM.config_tag)
					else
						other_modes[initial(GM.name)] = initial(GM.config_tag)
				sortList(regular_modes, /proc/cmp_text_asc)
				sortList(other_modes, /proc/cmp_text_asc)

				if (current_state > GAME_STATE_PREGAME)
					cmd = "c_mode_next"
					addltext = " next round"
				var/list/dat = list({"
							<html><body><title>Select Round Mode</title>
							<B>What mode do you wish to play[addltext]?</B><br>
							Current mode is: <i>[master_mode]</i><br>
							Mode is <A href='byond://?src=\ref[src];action=toggle_hide_mode'>[ticker.hide_mode ? "hidden" : "not hidden"]</a><br/>
							<HR>
							<b>Regular Modes:</b><br>
							<A href='byond://?src=\ref[src];action=[cmd];type=secret'>Secret</A><br>
							<A href='byond://?src=\ref[src];action=[cmd];type=action'>Secret: Action</A><br>
							"})
				for(var/item in regular_modes)
					dat += "<A href='byond://?src=\ref[src];action=[cmd];type=[regular_modes[item]]'>[item]</A><br>"
				dat += "<b>Other Modes</b><br>"
				for(var/item in other_modes)
					dat += "<A href='byond://?src=\ref[src];action=[cmd];type=[other_modes[item]]'>[item]</A><br>"
				dat += "</body></html>"
				usr.Browse(dat.Join(), "window=c_mode")
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("c_mode_current")
			if (src.level >= LEVEL_SA)
				if (current_state > GAME_STATE_PREGAME)
					return tgui_alert(usr, "The game has already started.")

#ifndef MAP_OVERRIDE_POD_WARS
				if (href_list["type"] == "pod_wars")
					boutput(usr, SPAN_ALERT("<b>You can only set the mode to Pod Wars if the current map is a Pod Wars map!<br>If you want to play Pod Wars, you have to set the next map for compile to be pod_wars.dmm!</b>"))
					return
#endif
				var/requestedMode = href_list["type"]
				if (requestedMode in global.valid_modes)
					logTheThing(LOG_ADMIN, usr, "set the mode as [requestedMode].")
					logTheThing(LOG_DIARY, usr, "set the mode as [requestedMode].", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] set the mode as [requestedMode]."))
					master_mode = requestedMode
					if(master_mode == "battle_royale")
						lobby_titlecard = new /datum/titlecard/battleroyale()
						lobby_titlecard.set_pregame_html()
					else if(master_mode == "disaster")
						lobby_titlecard = new /datum/titlecard/disaster()
						lobby_titlecard.set_pregame_html()
					else if (lobby_titlecard.is_game_mode)
						lobby_titlecard = new /datum/titlecard()
						lobby_titlecard.set_pregame_html()
					if (tgui_alert(usr,"This round only?","Persistent Mode Change",list("Yes", "No")) == "No")
						// generally speaking most gimmick mode changes are one-round affairs
						world.save_mode(requestedMode)
					if (tgui_alert(usr,"Declare mode change to all players?","Mode Change",list("Yes", "No")) == "Yes")
						boutput(world, SPAN_NOTICE("<b>The mode is now: [requestedMode]</b>"))
				else
					boutput(usr, SPAN_ALERT("<b>That is not a valid game mode!</b>"))
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("c_mode_next")
			if (src.level >= LEVEL_SA)
				var/newmode = href_list["type"]
				logTheThing(LOG_ADMIN, usr, "set the next round's mode as [newmode].")
				logTheThing(LOG_DIARY, usr, "set the next round's mode as [newmode].", "admin")
				message_admins(SPAN_INTERNAL("[key_name(usr)] set the next round's mode as [newmode]."))
				world.save_mode(newmode)
				if (tgui_alert(usr,"Declare mode change to all players?","Mode Change",list("Yes", "No")) == "Yes")
					boutput(world, SPAN_NOTICE("<b>The next round's mode will be: [newmode]</b>"))
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("monkeyone")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if(!ismob(M))
					return
				if(ishuman(M))
					var/mob/living/carbon/human/N = M
					logTheThing(LOG_ADMIN, usr, "attempting to monkeyize [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "attempting to monkeyize [constructTarget(M,"diary")]", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] attempting to monkeyize [key_name(M)]"))
					N.monkeyize()
				else
					boutput(usr, SPAN_ALERT("You can't transform that mob type into a monkey."))
					return
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to monkeyize players.")

		if ("forcespeech")
			var/mob/M = locate(href_list["target"])
			if (src.level >= LEVEL_PA || isnull(M.client) && src.level >= LEVEL_SA)
				if (ismob(M))
					var/speech = input("What will [M] say?", "Force speech", null) as text|null
					if(!speech)
						return
					M.say(speech)
					speech = copytext(sanitize(speech), 1, MAX_MESSAGE_LEN)
					logTheThing(LOG_ADMIN, usr, "forced [constructTarget(M,"admin")] to say: [speech]")
					logTheThing(LOG_DIARY, usr, "forced [constructTarget(M,"diary")] to say: [speech]", "admin")
					if(M.client)
						message_admins(SPAN_INTERNAL("[key_name(usr)] forced [key_name(M)] to say: [speech]"))
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to force players to say things.")

		if ("halt")
			var/mob/M = locate(href_list["target"])
			if (src.level >= LEVEL_SA)
				if (ismob(M))
					var/id = rand(1, 1000000)
					APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "adminstop\ref[src][id]")
					boutput(usr, SPAN_ALERT("<b>[M] has been stopped for five seconds.</b>"))
					logTheThing(LOG_ADMIN, usr, "stopped [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "stopped [constructTarget(M,"diary")]", "admin")
					usr.playsound_local(M, 'sound/voice/guard_halt.ogg', 25, 0)
					M.playsound_local(M, 'sound/voice/guard_halt.ogg', 25, 0)
					SPAWN(5 SECONDS)
						REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "adminstop\ref[src][id]")
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to stop players.")

		if ("animate")
			if (src.level >= LEVEL_BABBY)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					var/animationpick = tgui_input_list(usr, "Select animation.", "Animation", global.animations)
					if (animationpick)
						call(animationpick)(M)

		if ("prison")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M || !ismob(M)) return
				usr.client.cmd_admin_prison_unprison(M)
			else
				tgui_alert(usr,"You need to be at least a Moderator to send players to prison.")

		if ("shamecube")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_shame_cube(M)
			else
				tgui_alert(usr,"You need to be at least a Moderator to shame cube a player.")

		if ("tdome")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return

				var/team
				var/type = href_list["type"]
				if (type == "1")
					M.set_loc(pick_landmark(LANDMARK_THUNDERDOME_1))
					team = "Team 1"
				else if (type == "2")
					M.set_loc(pick_landmark(LANDMARK_THUNDERDOME_2))
					team = "Team 2"

				logTheThing(LOG_ADMIN, usr, "sent [constructTarget(M,"admin")] to the thunderdome. ([team])")
				logTheThing(LOG_DIARY, usr, "sent [constructTarget(M,"diary")] to the thunderdome. ([team])", "admin")
				message_admins("[key_name(usr)] has sent [key_name(M)] to the thunderdome. ([team])")
				boutput(M, SPAN_NOTICE("<b>You have been sent to the Thunderdome. You are on [team].</b>"))
				boutput(M, SPAN_NOTICE("<b>Prepare for combat. If you are not let out of the preparation area within a few minutes, please adminhelp. (F1 key)</b>"))

			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to send players to Thunderdome.")

		if ("revive")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					if(isobserver(M))
						tgui_alert(usr,"You can't revive a ghost! How does that even work?!")
						return
					if(config.allow_admin_rev)
						M.full_heal()
						message_admins(SPAN_ALERT("Admin [key_name(usr)] healed / revived [key_name(M)]!"))
						logTheThing(LOG_ADMIN, usr, "healed / revived [constructTarget(M,"admin")]")
						logTheThing(LOG_DIARY, usr, "healed / revived [constructTarget(M,"diary")]", "admin")
					else
						tgui_alert(usr,"Reviving is currently disabled.")
			else
				tgui_alert(usr,"You need to be at least a Primary Adminstrator to revive players.")

		if ("stabilize")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					if(isobserver(M))
						tgui_alert(usr,"You can't stabilize a ghost! How does that even work?!")
						return

					if(isdead(M))
						tgui_alert("Cannot stabilize a dead mob")
						return

					M.stabilize()

					logTheThing(LOG_ADMIN, usr, "stabilized [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "stabilized [constructTarget(M,"diary")]", "admin")
					message_admins(SPAN_ALERT("Admin [key_name(usr)] stabilized [key_name(M)]!"))

		if ("makeai")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (tgui_alert(usr,"Make [M] an AI?", "Make AI", list("Yes", "No")) == "Yes")
					var/mob/newM = usr.client.cmd_admin_makeai(M)
					href_list["target"] = "\ref[newM]"
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to turn players into AI units.")

		if ("makecyborg")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (tgui_alert(usr,"Make [M] a Cyborg?", "Make Cyborg", list("Yes", "No")) == "Yes")
					var/mob/newM = usr.client.cmd_admin_makecyborg(M)
					href_list["target"] = "\ref[newM]"
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to turn players into Cyborgs.")

		if ("makeghostdrone")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (tgui_alert(usr,"Make [M] a Ghost Drone?", "Make Ghost Drone", list("Yes", "No")) == "Yes")
					var/mob/newM = usr.client.cmd_admin_makeghostdrone(M)
					href_list["target"] = "\ref[newM]"
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to turn players into Ghostdrones.")

		if ("modifylimbs")
			if (src.level >= LEVEL_SA)
				var/mob/MC = locate(href_list["target"])
				if (MC && usr.client)
					usr.client.modify_parts(MC, usr)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to modify limbs.")

		if ("changeoutfit")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!ishuman(M))
					boutput(usr, SPAN_ALERT("Target is not human, aborting."))
					return
				var/mob/living/carbon/human/H = M
				if (H && usr.client)
					var/delete_choice
					var/obj/item/card/id
					var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
					sortList(jobs, /proc/cmp_text_asc)
					var/datum/job/job = tgui_input_list(usr, "Select job outfit", "Job outfit", jobs)
					if(!istype(job))
						return
					delete_choice = tgui_alert(usr, "Delete ALL currently worn items? Caution: you may delete traitor uplinks.", "Confirmation", list("No", "Yes", "Cancel"))
					if (delete_choice == "Cancel")
						return
					if (!ishuman(H))
						boutput(usr, SPAN_ALERT("Target is not human, aborting."))
						return
					if (delete_choice == "Yes")
						// Try to recover their ID
						id = H.get_id()
						if (istype(id))
							H.u_equip(id)
							// Hide this somewhere safe until we recover it as we can't keep it on the mob
							id.set_loc(null)
							id.dropped(H)
						else
							boutput(usr, SPAN_ALERT("Could not find [H]'s ID card - Replacing with a standard job ID if available."))
					H.unequip_all(delete_choice == "Yes" ? 1 : 0)
					SPAWN (1 SECOND)
						equip_job_items(job, H)
						if (istype(id))
							if(!H.equip_if_possible(id, SLOT_WEAR_ID))
								H.put_in_hand(id)
						else if (job.spawn_id)
							H.spawnId(job)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to change outfits.")


		if ("jumpto")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!istype(M, /mob/dead/target_observer))
					usr.client.jumptomob(M)
				else
					var/jumptarget = M.eye
					if (jumptarget)
						usr.client.jumptoturf(get_turf(jumptarget))
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to jump to mobs.")

		if ("observe")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!istype(usr, /mob/dead/observer))
					boutput(usr, SPAN_ALERT("This command only works when you are a ghost."))
					return
				var/mob/dead/observer/ghost = usr
				ghost.insert_observer(M)
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to observe mobs... For some reason.")

		if ("jumptocoords")
			if(src.level >= LEVEL_SA)
				var/list/coords = splittext(href_list["target"], ",")
				if (length(coords) < 3) return
				usr.client.jumptocoord(text2num(coords[1]), text2num(coords[2]), text2num(coords[3]))
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to jump to coords.")

		if ("getmob")
			if(( src.level >= LEVEL_ADMIN ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.Getmob(M)
			else
				tgui_alert(usr,"If you are below the rank of Administrator, you need to be observing and at least a Secondary Administrator to get a player.")

		if ("sendmob")
			if(( src.level >= LEVEL_ADMIN ) || ((src.level >= LEVEL_PA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/list/areas = list( )
				for (var/area/A in world)
					areas += A
					LAGCHECK(LAG_LOW)
				sortList(areas, /proc/cmp_name_asc)
				var/area = tgui_input_list(usr, "Area to send to", "Send", areas)
				if (area)
					usr.client.sendmob(M, area)
			else
				tgui_alert(usr,"If you are below the rank of Administrator, you need to be observing and at least a Primary Administrator to get a player.")

		if ("viewport")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/datum/viewport/viewport = usr.create_viewport(VIEWPORT_ID_ADMIN, title = "Following: [M.name]", size=9)
				viewport.handler.listens = TRUE
				viewport.start_following(M)
			else
				tgui_alert(usr, "You need to be at least a Secondary Adminstrator to follow a player with a vieweport.")

		if ("gib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_gib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to gib a dude.")

		if ("buttgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_buttgib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to buttgib a dude.")

		if ("partygib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_partygib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to party gib a dude.")

		if ("owlgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_owlgib(M)
			else
				tgui_alert(usr,"A loud hooting noise is heard. It sounds angry. I guess you aren't allowed to do this.")

		if ("firegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_firegib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to fire gib a dude.")

		if ("elecgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_elecgib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to elec gib a dude.")

		if ("sharkgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.sharkgib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to shark gib a dude.")

		if ("icegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_icegib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to ice gib a dude.")

		if ("goldgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_goldgib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to gold gib a dude.")

		if("spidergib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_spidergib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to spider gib a dude.")

		if("implodegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_implodegib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to implode a dude.")

		if("cluwnegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_cluwnegib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to cluwne gib a dude.")
		if("flockgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_flockgib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to flock gib a dude.")
		if ("tysongib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_tysongib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to tyson gib a dude.")
		if("damn")
			if(src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if(!M || !M.mind) return
				if(M.mind.damned)
					usr.client.cmd_admin_adminundamn(M)
				else
					usr.client.cmd_admin_admindamn(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to damn a dude.")
		if("rapture")
			if(src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (tgui_alert(usr, "Are you sure you want to rapture [M]?", "Confirmation", list("Yes", "No")) == "Yes")
					heavenly_spawn(M, reverse = TRUE)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to rapture a dude.")
		if("smite")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_smitegib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to smite a dude.")
		if ("anvilgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_anvilgib(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Admin to anvil gib a dude.")
		if("transform")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!ishuman(M))
					tgui_alert(usr,"This secret can only be used on human mobs.")
					return
				var/mob/living/carbon/human/H = M

				var/which = tgui_input_list(src, "Transform them into what?", "Transform", list("Monkey","Cyborg","Lizardman","Squidman","Martian","Skeleton","Flashman", "Kudzuman","Ghostdrone","Flubber","Cow"))
				if (!which)
					return
				. = 0
				switch(which)
					if("Monkey")
						H.monkeyize()
					if("Cyborg")
						H.Robotize_MK2()
					if("Lizardman")
						H.set_mutantrace(/datum/mutantrace/lizard)
						. = 1
					if("Squidman")
						H.set_mutantrace(/datum/mutantrace/ithillid)
						. = 1
					if("Martian")
						H.set_mutantrace(/datum/mutantrace/martian)
						. = 1
					if("Skeleton")
						H.set_mutantrace(/datum/mutantrace/skeleton)
						. = 1
					if("Flashman")
						H.set_mutantrace(/datum/mutantrace/flashy)
						. = 1
					if("Kudzuman")
						H.set_mutantrace(/datum/mutantrace/kudzu)
						. = 1
					if("Ghostdrone")
						droneize(H, 0)
					if("Flubber")
						H.set_mutantrace(/datum/mutantrace/flubber)
					if ("Cow")
						H.set_mutantrace(/datum/mutantrace/cow)
				if(.)
					message_admins(SPAN_INTERNAL("[key_name(usr)] transformed [H.real_name] into a [which]."))
			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to transform a player.")

		if ("setstatuseffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])	//doesn't really have to be mob, could be atom.

				var/list/L = list()
				for(var/R in concrete_typesof(/datum/statusEffect))
					L += R
				sortList(L, /proc/cmp_text_asc)
				var/datum/statusEffect/effect = tgui_input_list(usr, "Which Status Effect?", "Give Status Effect", L)

				if (!effect)
					return

				var/duration = input("Duration (in seconds)?","Status Effect Duration") as null|num
				if (isnull(duration))
					return

				if (duration <= 0)
					M.delStatus(initial(effect.id))
					message_admins("[key_name(usr)] removed the [initial(effect.id)] status-effect from [key_name(M)].")
				else
					M.setStatus(initial(effect.id), duration SECONDS)
					message_admins("[key_name(usr)] added the [initial(effect.id)] status-effect on [key_name(M)] for [duration] seconds.")

			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to statuseffect a player.")

		if ("modifystatuseffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])	//doesn't really have to be mob, could be atom.

				var/list/statusList = M.getStatusList()
				var/datum/statusEffect/effect = tgui_input_list(usr, "Which Status Effect?", "Modify Status Effect", statusList)

				if (!effect)
					return
				message_admins("selected [effect]")
				var/duration = input("Duration (in seconds)?","Status Effect Duration") as null|num
				if (isnull(duration))
					return

				if (duration <= 0)
					M.delStatus(effect)
					message_admins("[key_name(usr)] removed the [effect] status-effect from [key_name(M)].")
				else
					M.setStatus(effect, duration SECONDS)
					message_admins("[key_name(usr)] modified the [effect] status-effect on [key_name(M)] to [duration] seconds.")

			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to statuseffect a player.")

		if ("managebioeffect")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				usr.client.cmd_admin_managebioeffect(M)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to manage the bioeffects of a player.")
		if ("addbioeffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				var/pick = input("Which effect(s)?","Give Bioeffects") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				var/successes = 0
				if (length(picklist))
					var/string_version
					for(pick in picklist)
						M.onProcCalled("addBioEffect", list("idToAdd" = pick, "magical" = 1))
						if(!bioEffectList[pick])
							boutput(usr, SPAN_ALERT("Invalid bioEffect ID [pick]"))
							continue
						if(M.bioHolder.AddEffect(pick, magical = 1))
							successes++

						if (string_version)
							string_version = "[string_version], \"[pick]\""
						else
							string_version = "\"[pick]\""

					if(successes == length(picklist))
						message_admins("[key_name(usr)] added the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] to [key_name(M)].")
					else if(successes > 0)
						message_admins("[key_name(usr)] tried to dd the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] but only [successes] succeeded to [key_name(M)].")
					else
						boutput(usr, SPAN_ALERT("<b>Failed to add [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] to [key_name(M)].</b>"))
			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to bioeffect a player.")

		if ("removebioeffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				var/pick = input("Which effect(s)?","Remove Bioeffects") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (length(picklist))
					var/string_version
					for(pick in picklist)
						M.bioHolder.RemoveEffect(pick)

						if (string_version)
							string_version = "[string_version], \"[pick]\""
						else
							string_version = "\"[pick]\""

					message_admins("[key_name(usr)] removed the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] from [M.real_name].")
			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to bioeffect a player.")

		if ("removehandcuff")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (istype(M))
					usr.client.cmd_admin_unhandcuff(M)
				else
					tgui_alert(usr,"Only mobs can have handcuffs, doofus! Are you trying to unhandcuff a shrub or something? Stop that!")

		if ("checkhealth")
			if (src.level >= LEVEL_SA)
				var/atom/A = locate(href_list["target"])
				if (A)
					usr.client.cmd_admin_check_health(A)
					return
		if ("max_health")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					if(isobserver(M))
						tgui_alert(usr,"You can't revive a ghost! How does that even work?!")
						return
					if(config.allow_admin_rev)
						var/amount = input(usr,"Amount:","Amount",100) as null|num
						if(!amount) return
						M.max_health = amount
						M.full_heal()
						message_admins(SPAN_ALERT("Admin [key_name(usr)] set max health of [key_name(M)] to [amount]!"))
						logTheThing(LOG_ADMIN, usr, "set max health of [constructTarget(M,"admin")] to [amount]")
						logTheThing(LOG_DIARY, usr, "set max health of [constructTarget(M,"diary")] to [amount]", "admin")
					else
						tgui_alert(usr,"Reviving is currently disabled, which is tied to changing max health.")

		if ("kill")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if(M)
					M.death()
					message_admins(SPAN_ALERT("Admin [key_name(usr)] killed [key_name(M)]!"))
					logTheThing(LOG_ADMIN, usr, "killed [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "killed [constructTarget(M,"diary")]", "admin")
				return

		if ("addreagent")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if(!M.reagents) M.create_reagents(100)

				var/list/L = list()
				for(var/R in concrete_typesof(/datum/reagent))
					L += R
				sortList(L, /proc/cmp_text_asc)
				var/type = tgui_input_list(usr, "Select Reagent:", "Select", L)

				if(!type) return
				var/datum/reagent/reagent = new type()

				var/amount = input(usr,"Amount:","Amount",50) as null|num
				if(!amount) return

				M.reagents.add_reagent(reagent.id, amount)
				boutput(usr, SPAN_SUCCESS("Added [amount] units of [reagent.id] to [M.name]"))

				logTheThing(LOG_ADMIN, usr, "added [amount] units of [reagent.id] to [constructName(M)] at [log_loc(M)].")
				logTheThing(LOG_DIARY, usr, "added [amount] units of [reagent.id] to [constructName(M)] at [log_loc(M)].", "admin")
				message_admins("[key_name(usr)] added [amount] units of [reagent.id] to [key_name(M)] at [log_loc(M)].")

			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to affect player reagents.")

		if ("checkreagent")
			if (src.level >= LEVEL_SA)
				var/atom/A = locate(href_list["target"])
				if (A)
					usr.client.cmd_admin_check_reagents(A)

		if ("checkreagent_refresh")
			if (src.level >= LEVEL_SA)
				var/atom/A = locate(href_list["target"])
				if (A)
					usr.client.check_reagents_internal(A, refresh = 1)

		if ("checkreagent_add")
			if (src.level >= LEVEL_SA)
				var/atom/A = locate(href_list["target"])
				if (A)
					usr.client.addreagents(A)
					usr.client.check_reagents_internal(A, refresh = 1)

		if ("checkreagent_flush")
			if (src.level >= LEVEL_SA)
				var/atom/A = locate(href_list["target"])
				if (A)
					usr.client.flushreagents(A)
					usr.client.check_reagents_internal(A, refresh = 1)

		if ("removereagent")
			// similar to /client/proc/addreagents, but in a different place.
			// originally limited to mobs, but i made it any atoms
			if (src.level < LEVEL_SA)
				tgui_alert(usr, "You need to be at least a Secondary Administrator to remove reagents.")
				return

			var/atom/A = locate(href_list["target"])

			if (!A.reagents) // || !target.reagents.total_volume)
				boutput(usr, SPAN_NOTICE("<b>[A] contains no reagents.</b>"))
				return
			var/datum/reagents/reagents = A.reagents

			var/pick_id
			var/pick
			if (href_list["skip_pick"])
				pick_id = href_list["skip_pick"]
				pick = href_list["skip_pick"]
			else
				var/list/target_reagents = list()
				for (var/current_id in reagents.reagent_list)
					var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
					target_reagents += current_reagent.name
				pick = tgui_input_list(usr, "Select Reagent:", "Select", target_reagents)
				if (!pick)
					return
				if(!isnull(reagents.reagent_list[pick]))
					pick_id = pick
				else
					for (var/current_id in reagents.reagent_list)
						if(pick == reagents.reagent_list[current_id].name)
							var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
							pick_id = current_reagent.id
							break

			if (!pick_id)
				return

			var/amt = input("How much of [pick]?", "Remove Reagent") as null|num
			if (!amt || amt < 0)
				return

			if (A.reagents)
				if (!A.reagents.remove_reagent(pick_id,amt))
					boutput(usr, SPAN_ALERT("Failed to remove [amt] units of [pick_id] from [A.name]."))
					return

			boutput(usr, SPAN_SUCCESS("Removed [amt] units of [pick_id] from [A]."))

			// Brought in line with adding reagents via the player panel (Convair880).
			logTheThing(LOG_ADMIN, src, "removed [amt] units of [pick_id] from [A] at [log_loc(A)].")
			if (ismob(A))
				message_admins("[key_name(src)] removed [amt] units of [pick_id] from [A] (Key: [key_name(A) || "NULL"]) at [log_loc(A)].")

		if ("possessmob")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (M == usr)
					releasemob(M)
				else
					possessmob(M)
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to possess or release mobs.")

		if ("checkcontents")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_check_contents(M)
			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to check player contents.")

		if ("dropcontents")
			if(( src.level >= LEVEL_ADMIN ) || ((src.level >= LEVEL_PA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (tgui_alert(usr, "Make [M] drop everything?", "Confirmation", list("Yes", "No")) == "Yes")
					usr.client.cmd_admin_drop_everything(M)
			else
				tgui_alert(usr,"If you are below the rank of Shit Guy, you need to be observing and at least a Primary Admin to drop player contents.")

		if ("addabil")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!M.abilityHolder)
					tgui_alert(usr,"No ability holder detected. Create a holder first!")
					return
				var/list/L = list()
				for(var/R in concrete_typesof(/datum/targetable))
					L += R
				sortList(L, /proc/cmp_text_asc)
				var/ab_to_add = tgui_input_list(usr, "Add an Ability:", "Select", L)
				if (!ab_to_add)
					return // user canceled
				M.onProcCalled("addAbility", list(ab_to_add))
				M.abilityHolder.addAbility(ab_to_add)
				M.abilityHolder.updateButtons()
				message_admins("[key_name(usr)] added ability [ab_to_add] to [key_name(M)].")
				logTheThing(LOG_ADMIN, usr, "added ability [ab_to_add] to [constructTarget(M,"admin")].")
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("removeabil")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!M.abilityHolder)
					tgui_alert(usr,"No ability holder detected.")
					return

				var/datum/targetable/ab_to_rem = null
				var/list/abils = list()
				if (istype(M.abilityHolder, /datum/abilityHolder/composite))
					var/datum/abilityHolder/composite/CH = M.abilityHolder
					if (CH.holders.len)
						for (var/datum/abilityHolder/AH in CH.holders)
							abils += AH.abilities //get a list of all the different abilities in each holder
					else
						boutput(usr, SPAN_ALERT("<b>[M]'s composite holder lacks any ability holders to remove from!</b>"))
						return //no ability holders in composite holder
				else
					abils += M.abilityHolder.abilities

				if(!abils.len)
					boutput(usr, SPAN_ALERT("<b>[M] doesn't have any abilities!</b>"))
					return //nothing to remove

				sortList(abils, /proc/cmp_text_asc)
				ab_to_rem = tgui_input_list(usr, "Remove which ability?", "Ability", abils)
				if (!ab_to_rem) return //user cancelled
				message_admins("[key_name(usr)] removed ability [ab_to_rem] from [key_name(M)].")
				logTheThing(LOG_ADMIN, usr, "removed ability [ab_to_rem] from [constructTarget(M,"admin")].")
				M.abilityHolder.removeAbilityInstance(ab_to_rem)
				M.abilityHolder.updateButtons()
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("abilholder")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/ab_to_add = input("Which holder?", "Ability", null) as anything in childrentypesof(/datum/abilityHolder)
				M.add_ability_holder(ab_to_add)
				M.abilityHolder.updateButtons()
				message_admins("[key_name(usr)] created abilityHolder [ab_to_add] for [key_name(M)].")
				logTheThing(LOG_ADMIN, usr, "created abilityHolder [ab_to_add] for [constructTarget(M,"admin")].")
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("manageabils")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_manageabils(M)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("managetraits")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_managetraits(M)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("managetraits_remove")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				var/datum/trait/trait = locate(href_list["trait"])
				if (!M || !trait) return
				message_admins("[key_name(usr)] removed trait [trait.name] from [key_name(M)].")
				logTheThing(LOG_ADMIN, usr, "removed trait [trait.name] from [constructTarget(M,"admin")].")
				M.traitHolder.removeTrait(trait.id)
				usr.client.cmd_admin_managetraits(M)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("managetraits_debug_vars")
			if (src.level >= LEVEL_PA)
				var/datum/trait/trait = locate(href_list["trait"])
				usr.client.debug_variables(trait)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("addtrait")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				var/origin = href_list["origin"]
				if (!M) return
				if (!M.traitHolder)
					tgui_alert(usr,"No trait holder detected.")
					return
				var/list/datum/trait/all_traits = list()
				var/list/traits_by_name = list()
				for(var/datum/trait/trait as anything in traitList)
					all_traits[traitList[trait].name] = traitList[trait].id
					traits_by_name.Add(traitList[trait].name)

				sortList(traits_by_name, /proc/cmp_text_asc)

				var/trait_to_add_name = tgui_input_list(usr, "Add a Trait:", "Select", traits_by_name)
				if (!trait_to_add_name)
					return // user canceled
				M.onProcCalled("addTrait", list(all_traits[trait_to_add_name]))
				M.traitHolder.addTrait(all_traits[trait_to_add_name], force_trait=TRUE)
				message_admins("[key_name(usr)] added the trait [trait_to_add_name] to [key_name(M)].")
				logTheThing(LOG_ADMIN, usr, "added the trait [trait_to_add_name] to [constructTarget(M,"admin")].")
				if (origin == "managetraits")//called via trait management panel
					usr.client.cmd_admin_managetraits(M)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("removetrait")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!M.traitHolder)
					tgui_alert(usr,"No trait holder detected.")
					return

				var/trait_to_remove_name = null
				var/list/traits = list()

				for(var/trait in M.traitHolder.traits)
					var/datum/trait/trait_obj = M.traitHolder.traits[trait]
					traits.Add(trait_obj.name)

				if(length(traits) == 0)
					boutput(usr, SPAN_ALERT("<b>[M] doesn't have any traits!</b>"))
					return //nothing to remove

				sortList(traits, /proc/cmp_text_asc)
				trait_to_remove_name = tgui_input_list(usr, "Remove which trait?", "Trait", traits)
				if (!trait_to_remove_name) return //user cancelled

				// get the id of the selected trait
				for(var/trait in M.traitHolder.traits)
					var/datum/trait/trait_obj = M.traitHolder.traits[trait]
					if(trait_obj.name == trait_to_remove_name)
						M.traitHolder.removeTrait(trait_obj.id)
						message_admins("[key_name(usr)] removed the trait [trait_to_remove_name] from [key_name(M)].")
						logTheThing(LOG_ADMIN, usr, "removed the trait [trait_to_remove_name] from [constructTarget(M,"admin")].")
						break
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("manageobjectives")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_manageobjectives(M)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("manageobjectives_debug_vars")
			if (src.level >= LEVEL_PA)
				var/datum/objective/objective = locate(href_list["objective"])
				usr.client.debug_variables(objective)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("manageobjectives_remove")
			if (src.level < LEVEL_PA)
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")
				return
			var/mob/M = locate(href_list["target"])
			var/datum/objective/objective = locate(href_list["objective"])
			if (!length(M?.mind?.objectives) || !objective)
				return
			message_admins("[key_name(usr)] removed objective [objective.type][objective.explanation_text ? " with text: " : ""][objective.explanation_text] from [key_name(M)].")
			logTheThing(LOG_ADMIN, usr, "removed objective [objective.type][objective.explanation_text ? " with text: " : ""][objective.explanation_text] from [constructTarget(M,"admin")].")
			M.mind.objectives -= objective
			qdel(objective)
			usr.client.cmd_admin_manageobjectives(M)

		if ("addobjective")
			if (src.level < LEVEL_PA)
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")
				return
			var/mob/M = locate(href_list["target"])
			var/origin = href_list["origin"]
			if (!M?.mind)
				return
			LAZYLISTINIT(M.mind.objectives)

			var/objective_type = tgui_input_list(usr, "Add an objective:", "Select", concrete_typesof(/datum/objective))
			if (!objective_type)
				return // user canceled
			var/objective_text = input(usr, "Custom objective text (optional)", "Objective text")
			new objective_type(objective_text, M.mind)
			message_admins("[key_name(usr)] added the objective [objective_type][objective_text ? " with text: " : ""][objective_text] to [key_name(M)].")
			logTheThing(LOG_ADMIN, usr, "added the objective [objective_type][objective_text ? " with text: " : ""][objective_text] to [constructTarget(M,"admin")].")
			if (origin == "manageobjectives")//called via objective management panel
				usr.client.cmd_admin_manageobjectives(M)

		if("subtlemsg")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.cmd_admin_subtle_message(M)

		if("adminalert")
			var/mob/M = locate(href_list["target"])
			if(!M) return
			usr.client.cmd_admin_alert(M)

		if ("makecritter")
			if( src.level < LEVEL_PA )
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a Critter.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return

			var/CT = input("Enter a /mob/living/critter path or partial name.", "Make Critter", null) as null|text

			var/list/matches = get_matches(CT, "/mob/living/critter")

			if (!length(matches))
				return
			if (length(matches) == 1)
				CT = matches[1]
			else
				CT = tgui_input_list(owner, "Select a match", "matches for pattern", matches)
			if (CT && M)
				M.critterize(text2path(CT))
			return

		if ("makecube")
			if( src.level < LEVEL_PA )
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a Cube.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Make [M] a cube?", "Make Cube", list("Yes", "No")) == "Yes")
				var/CT = input("What kind of cube?", "Make Cube", null) as null|anything in childrentypesof(/mob/living/carbon/cube)
				if (CT != null)
					var/amt = input("How long should it live?","Cube Lifetime") as null|num
					if(!amt)
						amt = INFINITY
					M.cubeize(amt, CT)

		if ("add_antagonist")
			if (src.level < LEVEL_PA)
				tgui_alert(usr, "You must be at least a Primary Administrator to change someone's antagonist status.")
				return
			var/mob/M = locate(href_list["targetmob"])
			if (!M?.mind)
				return
			var/list/antag_options = list()
			var/list/eligible_antagonist_types = concrete_typesof(/datum/antagonist) - (concrete_typesof(/datum/antagonist/subordinate) + concrete_typesof(/datum/antagonist/generic))
			for (var/V as anything in eligible_antagonist_types)
				var/datum/antagonist/A = V
				if (!M.mind.get_antagonist(initial(A.id)))
					antag_options[initial(A.display_name)] = initial(A.id)
			if (!length(antag_options))
				boutput(usr, SPAN_ALERT("Antagonist assignment failed - no valid antagonist roles exist."))
				return
			for (var/V as anything in M.mind.antagonists)
				var/datum/antagonist/A = V
				if (A.mutually_exclusive)
					if (tgui_alert(usr, "[M.real_name] (ckey [M.ckey]) has an antagonist role that will not naturally occur with others. Proceed anyway? This might cause !!FUN!! interactions.", "Force Antagonist", list("Yes", "Cancel")) != "Yes")
						return
				break
			var/selected_keyvalue = tgui_input_list(usr, "Choose an antagonist role to assign.", "Add Antagonist", antag_options)
			if (!selected_keyvalue)
				return
			var/do_equipment = tgui_alert(usr, "Give the antagonist its default equipment? (Uplinks, clothing, special abilities, etc.)", "Add Antagonist", list("Yes", "No", "Cancel"))
			if (do_equipment == "Cancel")
				return
			var/do_objectives = tgui_alert(usr, "Assign randomly-generated objectives?", "Add Antagonist", list("Yes", "No", "Custom"))
			if (!M?.mind || !selected_keyvalue)
				return
			var/custom_objective = ""
			if (do_objectives == "Custom")
				custom_objective = tgui_input_text(usr, "Input custom objective text", "Custom objective")
			var/do_objectives_text = ""
			switch (do_objectives)
				if ("No")
					do_objectives_text = "Objectives will not be present"
				if ("Yes")
					do_objectives_text = "Objectives will be generated automatically"
				if ("Custom")
					do_objectives_text = "A custom objective will be added"
			if (tgui_alert(usr, "[M.real_name] (ckey [M.ckey]) will immediately become \a [selected_keyvalue]. Equipment and abilities will[do_equipment == "Yes" ? "" : " NOT"] be added. [do_objectives_text]. Is this what you want?", "Add Antagonist", list("Make it so.", "Cancel.")) != "Make it so.") // This is definitely not ideal, but it's what we have for now
				return
			boutput(usr, SPAN_NOTICE("Adding antagonist of type \"[selected_keyvalue]\" to mob [M.real_name] (ckey [M.ckey])..."))
			M.onProcCalled("add_antagonist", list(antag_options[selected_keyvalue], do_equipment == "Yes", do_objectives == "Yes", source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE))
			var/success = M.mind.add_antagonist(antag_options[selected_keyvalue], do_equipment == "Yes", do_objectives == "Yes", source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
			if (success)
				boutput(usr, SPAN_NOTICE("Addition successful. [M.real_name] (ckey [M.ckey]) is now \a [selected_keyvalue]."))
				logTheThing(LOG_ADMIN, usr, "made [key_name(M)] \a [selected_keyvalue]")
				message_admins("[key_name(usr)] made [key_name(M)] \a [selected_keyvalue]")
				if (length(custom_objective))
					new /datum/objective/regular(custom_objective, M.mind, M.mind.get_antagonist(antag_options[selected_keyvalue]))
					tgui_alert(M, "Your objective is: [custom_objective]", "Objective")
			else
				boutput(usr, SPAN_ALERT("Addition failed with return code [success]. The mob may be incompatible. Report this to a coder."))

		if ("add_subordinate_antagonist")
			if (src.level < LEVEL_PA)
				tgui_alert(usr, "You must be at least a Primary Administrator to change someone's antagonist status.")
				return
			var/mob/M = locate(href_list["targetmob"])
			if (!M?.mind)
				return
			var/list/antag_options = list()
			for (var/V as anything in concrete_typesof(/datum/antagonist/subordinate))
				var/datum/antagonist/A = V
				if (!M.mind.get_antagonist(initial(A.id)))
					antag_options[initial(A.display_name)] = initial(A.id)
			if (!length(antag_options))
				boutput(usr, SPAN_ALERT("Antagonist assignment failed - no valid antagonist roles exist."))
				return
			for (var/V as anything in M.mind.antagonists)
				var/datum/antagonist/A = V
				if (A.mutually_exclusive)
					if (tgui_alert(usr, "[M.real_name] (ckey [M.ckey]) has an antagonist role that will not naturally occur with others. Proceed anyway? This might cause !!FUN!! interactions.", "Force Antagonist", list("Yes", "Cancel")) != "Yes")
						return
				break
			var/selected_keyvalue = tgui_input_list(usr, "Choose an antagonist role to assign.", "Add Subordinate Antagonist", antag_options)
			if (!selected_keyvalue)
				return
			var/list/players = list()
			for (var/client/C in clients)
				if (!C?.mob || !C.mob.mind)
					continue
				players += C.mob
			var/mob/master = tgui_input_list(usr, "Choose a master, leader, or so forth for this antagonist.", "Add Subordinate Antagonist", players)
			if (!master)
				return
			var/do_equipment = tgui_alert(usr, "Give the antagonist its default equipment? (Uplinks, clothing, special abilities, etc.)", "Add Subordinate Antagonist", list("Yes", "No", "Cancel"))
			if (do_equipment == "Cancel")
				return
			var/do_objectives = tgui_alert(usr, "Assign randomly-generated objectives?", "Add Subordinate Antagonist", list("Yes", "No", "Cancel"))
			if (do_objectives == "Cancel" || !M?.mind || !selected_keyvalue)
				return
			if (tgui_alert(usr, "[M.real_name] (ckey [M.ckey]) will immediately become \a [selected_keyvalue]. Equipment and abilities will[do_equipment == "Yes" ? "" : " NOT"] be added. Objectives will [do_objectives == "Yes" ? "be generated automatically" : "not be present"]. Is this what you want?", "Add Antagonist", list("Make it so.", "Cancel.")) != "Make it so.") // This is definitely not ideal, but it's what we have for now
				return
			boutput(usr, SPAN_NOTICE("Adding antagonist of type \"[selected_keyvalue]\" to mob [M.real_name] (ckey [M.ckey])..."))
			var/success = M.mind.add_subordinate_antagonist(antag_options[selected_keyvalue], do_equipment == "Yes", do_objectives == "Yes", source = ANTAGONIST_SOURCE_ADMIN, master = master.mind)
			if (success)
				logTheThing(LOG_ADMIN, usr, "made [key_name(M)] \a [selected_keyvalue] antagonist")
				message_admins("[key_name(usr)] made [key_name(M)] \a [selected_keyvalue] antagonist")
				boutput(usr, SPAN_NOTICE("Addition successful. [M.real_name] (ckey [M.ckey]) is now \a [selected_keyvalue]."))
			else
				boutput(usr, SPAN_ALERT("Addition failed with return code [success]. The mob may be incompatible. Report this to a coder."))

		if ("remove_antagonist")
			if (src.level < LEVEL_PA)
				tgui_alert(usr, "You must be at least a Primary Administrator to change someone's antagonist status.")
				return
			var/datum/antagonist/antag = locate(href_list["target_antagonist"])
			var/mob/M = locate(href_list["targetmob"])
			if (!antag || !M?.mind)
				return
			if (tgui_alert(usr, "Remove the [antag.display_name] antagonist from [M.real_name] (ckey [M.ckey])?", "antagonist", list("Yes", "Cancel")) != "Yes")
				return
			boutput(usr, SPAN_NOTICE("Removing antagonist of type \"[antag.id]\" from mob [M.real_name] (ckey [M.ckey])..."))
			var/success = M.mind.remove_antagonist(antag)
			if (success)
				logTheThing(LOG_ADMIN, usr, "removed [antag.id] antagonist from [key_name(M)]")
				message_admins("[key_name(usr)] removed [antag.id] antagonist from [key_name(M)]")
				boutput(usr, SPAN_NOTICE("Removal successful.[length(M.mind.antagonists) ? "" : " As this was [M.real_name] (ckey [M.ckey])'s only antagonist role, their antagonist status is now fully removed."]"))
			else
				boutput(usr, SPAN_ALERT("Removal failed with return code [success]; report this to a coder."))

		if ("wipe_antagonists")
			if (src.level < LEVEL_PA)
				tgui_alert(usr, "You must be at least a Primary Administrator to change someone's antagonist status.")
				return
			var/mob/M = locate(href_list["targetmob"])
			if (!M?.mind)
				return
			if (tgui_alert(usr, "Really remove all antagonists from [M.real_name] (ckey [M.ckey])?", "antagonist", list("Yes", "Cancel")) != "Yes")
				return
			boutput(usr, SPAN_NOTICE("Removing all antagonist statuses from [M.real_name] (ckey [M.ckey])..."))
			var/success = M.mind.wipe_antagonists()
			if (success)
				logTheThing(LOG_ADMIN, usr, "removed all antagonists from [key_name(M)]")
				message_admins("[key_name(usr)] removed all antagonists from [key_name(M)]")
				boutput(usr, SPAN_NOTICE("Removal successful. [M.real_name] (ckey [M.ckey]) is no longer an antagonist."))
			else
				boutput(usr, SPAN_ALERT("Removal failed with return code [success]; report this to a coder."))

		if ("create_object")
			if (src.level >= LEVEL_SA)
				create_object(usr)
			else
				tgui_alert(usr,"You need to be at least a Primary Adminstrator to create objects.")

		if ("create_turf")
			if (src.level >= LEVEL_SA)
				create_turf(usr)
			else
				tgui_alert(usr,"You need to be at least a Primary Adminstrator to create turfs.")

		if ("create_mob")
			if (src.level >= LEVEL_SA)
				create_mob(usr)
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to create mobs.")

		if ("prom_demot")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/client/C = M.client
				if(C.holder && (C.holder.level >= src.level) && C != usr.client)
					tgui_alert(usr,"This cannot be done as [C] isn't of a lower rank than you!")
					return
				var/dat = "[C] is a [C.holder ? "[C.holder.rank]" : "non-admin"]<br><br>Change [C]'s rank?<br>"
				if (C == usr.client)
					dat += "<strong>IF YOU DEMOTE YOURSELF YOU CANNOT UNDO IT FOR THE REST OF THE ROUND!!!</strong><br>"
				if (src.level >= LEVEL_CODER)
					dat += {"
							<A href='byond://?src=\ref[src];action=chgadlvl;type=Coder;target=\ref[C]'>Coder</A><BR>
							"}
				if (src.level >= LEVEL_ADMIN)
					dat += "<A href='byond://?src=\ref[src];action=chgadlvl;type=Administrator;target=\ref[C]'>Administrator</A><BR>"
					dat += "<A href='byond://?src=\ref[src];action=chgadlvl;type=Primary Administrator;target=\ref[C]'>Primary Administrator</A><BR>"
				if (src.level >= LEVEL_PA)
					dat += {"
							<A href='byond://?src=\ref[src];action=chgadlvl;type=Intermediate Administrator;target=\ref[C]'>Intermediate Administrator</A><BR>
							<A href='byond://?src=\ref[src];action=chgadlvl;type=Secondary Administrator;target=\ref[C]'>Secondary Administrator</A><BR>
							<A href='byond://?src=\ref[src];action=chgadlvl;type=Moderator;target=\ref[C]'>Moderator</A><BR>
							<A href='byond://?src=\ref[src];action=chgadlvl;type=Ayn Rand%27s Armpit;target=\ref[C]'>Ayn Rand's Armpit</A><BR>
							<A href='byond://?src=\ref[src];action=chgadlvl;type=Goat Fart;target=\ref[C]'>Goat Fart</A><BR>
							<A href='byond://?src=\ref[src];action=chgadlvl;type=Remove;target=\ref[C]'>Remove Admin</A><BR>
							"}
				usr.Browse(dat, "window=prom_demot;size=480x300")
			else
				tgui_alert(usr,"You need to be at least a Primary Adminstrator to promote or demote.")

		if ("chgadlvl")
			if (src.level >= LEVEL_PA)
				var/rank = href_list["type"]
				var/client/C = locate(href_list["target"])
				if (!rank || !C) return

				if (C.holder && (C.holder.level >= src.level) && C != usr.client)
					tgui_alert(usr,"This cannot be done as [C] isn't of a lower rank than you!")
					return

				if (src.level < rank_to_level(rank))
					tgui_alert(usr,"You can't promote people above your own rank, dork.")
					return

				if (rank == "Remove")
					C.clear_admin_verbs()
					C.update_admins(null)
					logTheThing(LOG_ADMIN, usr, "has removed [constructTarget(C,"admin")]'s adminship")
					logTheThing(LOG_DIARY, usr, "has removed [C]'s adminship", "admin")
					message_admins("[key_name(usr)] has removed [C]'s adminship")

					var/ircmsg[] = new()
					ircmsg["key"] = usr.client.key
					ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
					ircmsg["msg"] = "has removed [C]'s adminship"
					ircbot.export_async("admin", ircmsg)

					admins.Remove(C.ckey)
					onlineAdmins.Remove(C)
				else
					C.clear_admin_verbs()
					C.update_admins(rank)
					logTheThing(LOG_ADMIN, usr, "has made [constructTarget(C,"admin")] a [rank]")
					logTheThing(LOG_DIARY, usr, "has made [C] a [rank]", "admin")
					message_admins("[key_name(usr)] has made [C] a [rank]")

					var/ircmsg[] = new()
					ircmsg["key"] = usr.client.key
					ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
					ircmsg["msg"] = "has made [C] a [rank]"
					ircbot.export_async("admin", ircmsg)

					admins[C.ckey] = rank
					onlineAdmins.Add(C)
			else
				tgui_alert(usr,"You need to be at least a Primary Adminstrator to promote or demote.")

		if ("object_list")
			if (src.level >= LEVEL_SA)
				if (config.allow_admin_spawning && (src.state == 2 || src.level >= LEVEL_SA))
					var/atom/loc = usr.loc

					var/type = href_list["type"]
					var/dirty_paths
					if (istext(type))
						dirty_paths = list(type)
					else if (islist(type))
						dirty_paths = type

					var/paths = list()
					var/removed_paths = list()
					for (var/dirty_path in dirty_paths)
						var/path = text2path(dirty_path)
						if (!path)
							removed_paths += dirty_path
						else if (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
							removed_paths += dirty_path
						else if (ispath(path, /mob) && src.level < LEVEL_SA)
							removed_paths += dirty_path
						else
							paths += path
						LAGCHECK(LAG_LOW)

					if (!paths)
						return
					else if (length(paths) > 5)
						tgui_alert(usr,"Select five or less object types only, you colossal ass!")
						return
					else if (length(removed_paths))
						tgui_alert(usr,"Spawning of these objects is blocked:\n" + jointext(removed_paths, "\n"))
						return

					var/list/offset = splittext(href_list["offset"],",")
					var/number = clamp(text2num(href_list["object_count"]), 1, 100)
					var/X = length(offset) > 0 ? text2num(offset[1]) : 0
					var/Y = length(offset) > 1 ? text2num(offset[2]) : 0
					var/Z = length(offset) > 2 ? text2num(offset[3]) : 0
					var/direction = text2num(href_list["one_direction"]) // forgive me

					for (var/i = 1 to number)
						switch (href_list["offset_type"])
							if ("absolute")
								for (var/path in paths)
									var/atom/thing
									if(ispath(path, /turf))
										var/turf/T = locate(0 + X,0 + Y,0 + Z)
										thing = T.ReplaceWith(path, FALSE, TRUE, FALSE, TRUE)
										thing.set_dir(direction ? direction : SOUTH)
									else
										new /dmm_suite/preloader(locate(X, Y, Z), list("dir" = direction ? direction : SOUTH))
										thing = new path(locate(X, Y, Z))
										if(isobj(thing))
											var/obj/O = thing
											O.initialize(TRUE)
									LAGCHECK(LAG_LOW)

							if ("relative")
								if (loc)
									for (var/path in paths)
										var/atom/thing
										if(ispath(path, /turf))
											var/turf/T = locate(loc.x + X,loc.y + Y,loc.z + Z)
											thing = T.ReplaceWith(path, FALSE, TRUE, FALSE, TRUE)
											thing.set_dir(direction ? direction : SOUTH)
										else
											new /dmm_suite/preloader(locate(loc.x + X,loc.y + Y,loc.z + Z), list("dir" = direction ? direction : SOUTH))
											thing = new path(locate(loc.x + X,loc.y + Y,loc.z + Z))
											if(isobj(thing))
												var/obj/O = thing
												O.initialize(TRUE)
										LAGCHECK(LAG_LOW)
								else
									return

						sleep(-1)

					if (number == 1)
						logTheThing(LOG_ADMIN, usr, "created a [english_list(paths)]")
						logTheThing(LOG_DIARY, usr, "created a [english_list(paths)]", "admin")
						for(var/path in paths)
							if(ispath(path, /mob))
								message_admins("[key_name(usr)] created a [english_list(paths, 1)]")
								break
							LAGCHECK(LAG_LOW)
					else
						logTheThing(LOG_ADMIN, usr, "created [number] [english_list(paths)]")
						logTheThing(LOG_DIARY, usr, "created [number] [english_list(paths)]", "admin")
						for(var/path in paths)
							if(ispath(path, /mob))
								message_admins("[key_name(usr)] created [number] [english_list(paths, 1)]")
								break
							LAGCHECK(LAG_LOW)
					return
				else
					tgui_alert(usr,"Object spawning is currently disabled for anyone below the rank of Administrator.")
					return
			else
				tgui_alert(usr,"You need to be at least an Adminstrator to spawn objects.")

		if ("polymorph")
			if (src.level >= LEVEL_SA) //gave SA+ restricted polymorph
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_polymorph(M)
			else
				tgui_alert(usr,"You need to be at least a Secondary Admin to polymorph a dude.")

		if ("modcolor")
			if (src.level >= LEVEL_ADMIN)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				mod_color(M)
			else
				tgui_alert(usr,"You need to be at least a Administrator to modify an icon.")

		if("giveantagtoken") //Gives player a token they can redeem to guarantee an antagonist role
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M)
					return
				//frick u im literally an admin
				// if (M.ckey && M.ckey == usr.ckey)
				// 	tgui_alert(usr, "You cannot modify your own antag tokens.")
				// 	return
				var/tokens = input(usr, "Current Tokens: [M.client.antag_tokens]","Set Antag Tokens to...") as null|num
				if (isnull(tokens))
					return
				M.client.set_antag_tokens(tokens)
				if (tokens <= 0)
					logTheThing(LOG_ADMIN, usr, "Removed all antag tokens from [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "Removed all antag tokens from [constructTarget(M,"diary")]", "admin")
					message_admins(SPAN_INTERNAL("[key_name(usr)] removed all antag tokens from [key_name(M)]"))
				else
					logTheThing(LOG_ADMIN, usr, "Set [constructTarget(M,"admin")]'s Antag tokens  to [tokens].")
					logTheThing(LOG_DIARY, usr, "Set [constructTarget(M,"diary")]'s Antag tokens  to [tokens].")
					message_admins( "[key_name(usr)] set [key_name(M)]'s Antag tokens to [tokens]." )
		if("setspacebux")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M)
					return
				var/spacebux = input(usr, "Current Spacebux: [M.client.persistent_bank]","Set Spacebux to...") as null|num
				if (!spacebux)
					return
				M.client.set_persistent_bank( spacebux )
				logTheThing(LOG_ADMIN, usr, "Set [constructTarget(M,"admin")]'s Persistent Bank (Spacebux) to [spacebux].")
				logTheThing(LOG_DIARY, usr, "Set [constructTarget(M,"diary")]'s Persistent Bank (Spacebux) to [spacebux].")
				message_admins( "[key_name(usr)] set [key_name(M)]'s Persistent Bank (Spacebux) to [spacebux]." )
		if ("viewsave")
			if (src.level >= LEVEL_ADMIN)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.view_save_data(M)
			else
				tgui_alert(usr,"You need to be at least a Administrator to view save data.")

		if ("grantcontributor")
			if (src.level >= LEVEL_CODER)
				var/confirmation = tgui_alert(usr, "Are you sure?", "Confirmation", list("Yes", "No"))
				if (confirmation != "Yes")
					return
				var/mob/M = locate(href_list["target"])
				if (!M) return
				M.unlock_medal( "Contributor", 1 )
				logTheThing(LOG_ADMIN, usr, "gave [constructTarget(M,"admin")] contributor status.")
				logTheThing(LOG_DIARY, usr, "gave [constructTarget(M,"diary")] contributor status.")
				message_admins( "[key_name(usr)] gave [key_name(M)] contributor status." )
			else
				tgui_alert(usr,"You need to be at least a Coder to grant the medal.")
		if ("revokecontributor")
			if (src.level >= LEVEL_CODER)
				var/confirmation = tgui_alert(usr, "Are you sure?", "Confirmation", list("Yes", "No"))
				if (confirmation != "Yes")
					return
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/suc = M.revoke_medal( "Contributor" )
				if(!suc)
					boutput( usr, SPAN_ALERT("Revoke failed, couldn't contact hub!") )
				else if(suc)
					boutput( usr, SPAN_ALERT("Contributor medal revoked.") )
					logTheThing(LOG_ADMIN, usr, "revoked [constructTarget(M,"admin")]'s contributor status.")
					logTheThing(LOG_DIARY, usr, "revoked [constructTarget(M,"diary")]'s contributor status.")
					message_admins( "[key_name(usr)] revoked [key_name(M)]'s contributor status." )
				else
					boutput( usr, SPAN_ALERT("Failed to revoke, did they have the medal to begin with?") )
			else
				tgui_alert(usr,"You need to be at least a Coder to revoke the medal.")
		if ("grantclown")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				M.unlock_medal( "Unlike the director, I went to college", 1 )
				logTheThing(LOG_ADMIN, usr, "gave [constructTarget(M,"admin")] their clown college diploma.")
				logTheThing(LOG_DIARY, usr, "gave [constructTarget(M,"diary")] their clown college diploma.")
				message_admins( "[key_name(usr)] gave [key_name(M)] their clown college diploma." )
			else
				tgui_alert(usr,"You need to be at least an SA to grant this.")
		if ("revokeclown")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/suc = M.revoke_medal( "Unlike the director, I went to college" )
				if(!suc)
					boutput( usr, SPAN_ALERT("Revoke failed, couldn't contact hub!") )
				else if(suc)
					boutput( usr, SPAN_ALERT("Clown college diploma revoked.") )
					logTheThing(LOG_ADMIN, usr, "revoked [constructTarget(M,"admin")]'s clown college diploma.")
					logTheThing(LOG_DIARY, usr, "revoked [constructTarget(M,"diary")]'s clown college diploma.")
					message_admins( "[key_name(usr)] revoked [key_name(M)]'s clown college diploma." )
				else
					boutput( usr, SPAN_ALERT("Failed to revoke, did they have the medal to begin with?") )
			else
				tgui_alert(usr,"You need to be at least an SA to revoke this.")

		if ("viewvars")
			if (src.level >= LEVEL_PA)
				var/datum/target = locate(href_list["target"])
				if (!target)
					return
				usr.client.debug_variables(target)
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to view variables.")

		if ("adminplayeropts")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.holder.playeropt(M)

		if ("secretsfun")
			if (src.level >= LEVEL_SA)
				switch(href_list["type"])
					if("sec_clothes")
						for(var/obj/item/clothing/under/O in world)
							qdel(O)
							LAGCHECK(LAG_LOW)
					if("sec_all_clothes")
						for(var/obj/item/clothing/O in world)
							qdel(O)
							LAGCHECK(LAG_LOW)
					if("sec_classic1")
						for(var/obj/item/clothing/suit/hazard/fire/O in world)
							qdel(O)
							LAGCHECK(LAG_LOW)
						for(var/obj/mesh/grille/O in world)
							qdel(O)
							LAGCHECK(LAG_LOW)
						for(var/obj/machinery/vehicle/pod/O in all_processing_machines())
							for(var/atom/movable/A in O)
								A.set_loc(O.loc)
							qdel(O)
							LAGCHECK(LAG_LOW)

					if("transform_one")
						var/list/targets = list()
						for (var/client/C in clients)
							if (!C?.mob)
								continue
							if (ishuman(C.mob))
								targets += C.mob
							LAGCHECK(LAG_LOW)
						sortList(targets, /proc/cmp_text_asc)
						var/who = tgui_input_list(usr, "Please, select a target!", "Transform", targets)
						if (!who)
							return
						if (!ishuman(who))
							tgui_alert(usr,"This secret can only be used on human mobs.")
							return
						var/mob/living/carbon/human/H = who
						var/datum/mutantrace/new_race = tgui_input_list(usr, "Please select mutant race", "Transform Menu", concrete_typesof(/datum/mutantrace) + "Cyborg")
						if (!ispath(new_race, /datum/mutantrace) && new_race != "Cyborg")
							boutput(usr, "Error: Invalid mutant race")
							return
						if(new_race == "Cyborg")
							H.Robotize_MK2()
						else
							H.mutantrace = new new_race
							H.set_mutantrace(new_race)
						message_admins(SPAN_INTERNAL("[key_name(usr)] transformed [H.real_name] into a [new_race]."))
						logTheThing(LOG_ADMIN, usr, "transformed [H.real_name] into a [new_race].")
						logTheThing(LOG_DIARY, usr, "transformed [H.real_name] into a [new_race].", "admin")

					if("transform_all")
						var/datum/mutantrace/new_race = tgui_input_list(usr, "Please select mutant race", "Transform Menu", concrete_typesof(/datum/mutantrace) + "Cyborg")
						if (!ispath(new_race, /datum/mutantrace) && new_race != "Cyborg")
							boutput(usr, "Error: Invalid mutant race")
							return
						for (var/client/C in clients)
							if (!C?.mob)
								continue
							if (ishuman(C.mob))
								var/mob/living/carbon/human/H = C.mob
								if(new_race == "Cyborg")
									H.Robotize_MK2()
								else
									H.mutantrace = new new_race
									H.set_mutantrace(new_race)
							LAGCHECK(LAG_LOW)
						message_admins(SPAN_INTERNAL("[key_name(usr)] transformed everyone into a [new_race]."))
						logTheThing(LOG_ADMIN, usr, "transformed everyone into a [new_race].")
						logTheThing(LOG_DIARY, usr, "transformed everyone into a [new_race].", "admin")
					if("prisonwarp")
						if(!ticker)
							tgui_alert(usr,"The game hasn't started yet!")
							return
						message_admins(SPAN_INTERNAL("[key_name(usr)] teleported all players to the prison zone."))
						logTheThing(LOG_ADMIN, usr, "teleported all players to the prison zone.")
						logTheThing(LOG_DIARY, usr, "teleported all players to the prison zone.", "admin")
						for(var/mob/living/carbon/human/H in mobs)
							var/turf/loc = get_turf(H)
							var/security = 0
							if(loc.z > 1 || prisonwarped.Find(H))
								//don't warp them if they aren't ready or are already there
								continue
							H.changeStatus("unconscious", 7 SECONDS)
							if(H.wear_id)
								for(var/A in H.wear_id:access)
									if(A == access_security)
										security++
							if(!security)
								//teleport person to cell
								H.set_loc(pick_landmark(LANDMARK_PRISONWARP))
							else
								//teleport security person
								H.set_loc(pick_landmark(LANDMARK_PRISONSECURITYWARP))
							prisonwarped += H
					if("critterize_all")
						if (src.level >= LEVEL_PA)
							if(!ticker)
								tgui_alert(usr,"The game hasn't started yet!")
								return

							var/CT = input("Enter a /mob/living/critter path or partial name.", "Make Critter", null) as null|text

							var/list/matches = get_matches(CT, "/mob/living/critter")

							if (!length(matches))
								return
							if (length(matches) == 1)
								CT = matches[1]
							else
								CT = text2path(tgui_input_list(owner, "Select a match", "matches for pattern", matches))

							if (!CT)
								return

							for(var/mob/living/carbon/human/H in mobs)
								if(isdead(H) || !(H.client)) continue
								H.make_critter(CT, get_turf(H))

							message_admins(SPAN_INTERNAL("[key_name(usr)] critterized everyone into [CT]."))
							logTheThing(LOG_ADMIN, usr, "critterized everyone into [CT]")
							logTheThing(LOG_DIARY, usr, "critterized everyone into a critter [CT]", "admin")
						else
							tgui_alert(usr,"You're not of a high enough rank to do this")
					if("traitor_all")
						if (src.level >= LEVEL_SA)
							if(!ticker)
								tgui_alert(usr,"The game hasn't started yet!")
								return

							var/list/antag_options = list()
							var/list/eligible_antagonist_types = concrete_typesof(/datum/antagonist) - (concrete_typesof(/datum/antagonist/subordinate) + concrete_typesof(/datum/antagonist/generic))
							for (var/V as anything in eligible_antagonist_types)
								var/datum/antagonist/A = V
								antag_options[initial(A.display_name)] = initial(A.id)

							var/selected_keyvalue = tgui_input_list(usr, "Choose an antagonist role to assign to everyone.", "Make Everyone An Antagonist", antag_options)
							if (!selected_keyvalue)
								return

							var/antagonist_role_id = antag_options[selected_keyvalue]

							var/equip_traitor = TRUE
							if (antagonist_role_id == ROLE_TRAITOR)
								if (tgui_alert(usr, "Hard Mode?", "Make Everyone An Antagonist", list("Yes", "No")) == "Yes")
									equip_traitor = FALSE

							var/custom_objective = tgui_input_text(usr, "What should their objective be?", "Make Everyone An Antagonist")
							if (!custom_objective)
								return
							var/escape_objective = tgui_input_list(usr, "What should their escape objective be?", "Make Everyone An Antagonist", typesof(/datum/objective/escape/) + "None")
							if (!escape_objective)
								return

							if (escape_objective == "None")
								escape_objective = null

							for (var/mob/living/carbon/human/H in mobs)
								if (isdead(H) || !H.mind || !H.key)
									continue

								H.mind.add_antagonist(antagonist_role_id, do_equip = equip_traitor, do_objectives = FALSE, source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
								var/datum/antagonist/antagonist_role = H.mind.get_antagonist(antagonist_role_id)
								if (istext(custom_objective))
									new /datum/objective(custom_objective, antagonist_role.owner, antagonist_role)
								if (ispath(escape_objective))
									new escape_objective(null, antagonist_role.owner, antagonist_role)
								antagonist_role.announce_objectives()

							message_admins(SPAN_INTERNAL("[key_name(usr)] made everyone a[equip_traitor ? "" : " hard-mode"] [antagonist_role_id]. Objective is [custom_objective]"))
							logTheThing(LOG_ADMIN, usr, "made everyone a[equip_traitor ? "" : " hard-mode"] [antagonist_role_id]. Objective is [custom_objective]")
							logTheThing(LOG_DIARY, usr, "made everyone a[equip_traitor ? "" : " hard-mode"] [antagonist_role_id]. Objective is [custom_objective]", "admin")

						else
							tgui_alert(usr,"You're not of a high enough rank to do this")
					if("flicklights")
						while(!usr.stat)
							//knock yourself out to stop the ghosts
							for(var/mob/M in mobs)
								if(M.client && !isdead(M) && prob(25))
									var/area/AffectedArea = get_area(M)
									if(AffectedArea.name != "Space" && AffectedArea.name != "Ocean" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
										AffectedArea.power_light = 0
										AffectedArea.power_change()
										SPAWN(rand(55,185))
											AffectedArea.power_light = 1
											AffectedArea.power_change()
										var/Message = rand(1,4)
										switch(Message)
											if(1)
												M.show_message(SPAN_NOTICE("You shudder as if cold..."), 1)
											if(2)
												M.show_message(SPAN_NOTICE("You feel something gliding across your back..."), 1)
											if(3)
												M.show_message(SPAN_NOTICE("Your eyes twitch, you feel like something you can't see is here..."), 1)
											if(4)
												M.show_message(SPAN_NOTICE("You notice something moving out of the corner of your eye, but nothing is there..."), 1)
										for(var/obj/W in orange(5,M))
											if(prob(25) && !W.anchored)
												step_rand(W)
							sleep(rand(100,1000))
						for(var/mob/M in mobs)
							if(M.client && !isdead(M))
								M.show_message(SPAN_NOTICE("The chilling wind suddenly stops..."), 1)
							LAGCHECK(LAG_LOW)
					if("stupify")
						if (src.level >= LEVEL_ADMIN)
							if (tgui_alert(usr,"Do you wish to give everyone brain damage?", "Confirmation", list("Yes", "No")) != "Yes")
								return
							for (var/mob/living/carbon/human/H in mobs)
								if (H.get_brain_damage() < 60)
									if (H.client)
										H.show_text("<B>You suddenly feel stupid.</B>","red")
									H.take_brain_damage(min(60 - H.get_brain_damage(), 60)) // 100+ brain damage is lethal.
									LAGCHECK(LAG_LOW)
								else
									continue
							message_admins("[key_name(usr)] gave everybody severe brain damage.")
							logTheThing(LOG_ADMIN, usr, "gave everybody severe brain damage.")
							logTheThing(LOG_DIARY, usr, "gave everybody severe brain damage.", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return
					// FUN SECRETS CODE
					if ("randomguns")
						if (src.level >= LEVEL_PA)
							switch(tgui_alert(usr, "What kind of guns do you want to give everyone?", "Guns2Give", list("Safe-ish Guns", "ANY GUN", "Cancel")))
								if("Cancel")
									return
								if("Safe-ish Guns")
									message_admins("[key_name(usr)] gave everyone a random safe firearm.")
									logTheThing(LOG_ADMIN, usr, "gave everyone a random safe firearm.")
									logTheThing(LOG_DIARY, usr, "gave everyone a random safe firearm.", "admin")
									for (var/mob/living/L in mobs)
										new /obj/random_item_spawner/kineticgun/safer/one(get_turf(L))
								if("ANY GUN")
									message_admins("[key_name(usr)] gave everyone a completely random firearm.")
									logTheThing(LOG_ADMIN, usr, "gave everyone a completely random firearm.")
									logTheThing(LOG_DIARY, usr, "gave everyone a completely random firearm.", "admin")
									for (var/mob/living/L in mobs)
										new /obj/random_item_spawner/kineticgun/fullrandom(get_turf(L))


						else
							tgui_alert(usr,"You must be at least a Primary Administrator")
							return

					if	("swaprooms")
						if (src.level >= LEVEL_PA)
							message_admins("Alrighty, messing up the rooms now ... please wait.")
							fuckthestationuphorribly()
							message_admins("[key_name(usr)] swapped the stations rooms.")
							logTheThing(LOG_ADMIN, usr, "swapped the stations rooms.")
							logTheThing(LOG_DIARY, usr, "swapped the stations rooms.", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator")
							return

					if	("timewarp")
						if (src.level >= LEVEL_PA)
							var/timedelay = input(usr,"Delay before time warp? 10 = 1 second",src.name) as num|null
							if (!isnum(timedelay) || timedelay < 1)
								return
							boutput(usr, SPAN_ALERT("<B>Preparing to warp time</B>"))
							timeywimey(timedelay)
							boutput(usr, SPAN_ALERT("<B>Time warped!</B>"))
							logTheThing(LOG_ADMIN, usr, "triggered a time warp.")
							logTheThing(LOG_DIARY, usr, "triggered a time warp.", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator")
							return
					if ("brick_radios")
						if (src.level >= LEVEL_PA)
							if (tgui_alert(usr, "Really brick all radios for all time?", "Are you sure?", list("Yes", "Oops misclick")) == "Yes")
								no_more_radio()
								message_admins("[key_name(usr)] bricked all radios forever")
								logTheThing(LOG_ADMIN, usr, "bricked all radios forever")
								logTheThing(LOG_DIARY, usr, "bricked all radios forever", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator")
							return
					if ("airlock_safety")
						if (src.level >= LEVEL_PA)
							if (tgui_alert(usr, "Disable all station airlocks safeties?", "Cronch?", list("Yes", "Oops misclick")) == "Yes")
								for (var/obj/machinery/door/airlock/D in by_type[/obj/machinery/door/airlock])
									if (D.z != 1)
										break
									D.safety = 0
									LAGCHECK(LAG_LOW)
								message_admins("[key_name(usr)] disabled the safeties on all station airlocks.")
								logTheThing(LOG_ADMIN, usr, "disabled the safeties on all station airlocks.")
								logTheThing(LOG_DIARY, usr, "disabled the safeties on all station airlocks.", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator")
							return

					if ("bioeffect_help")
						var/be_string = "To add or remove multiple bioeffects enter multiple IDs separated by semicolons.<br><br><b>All Bio Effect IDs</b><hr>"
						for(var/S in bioEffectList)
							be_string += "[S]<br>"
						usr.Browse(be_string,"window=bioeffect_help;size=300x600")

					if ("statuseffect_help")
						var/be_string = "To set Status Effects enter a status effect id (right side) in the first prompt and a duration in seconds in the second prompt.<br><br><b>All Status Effect IDs</b><hr>"
						for(var/datum/statusEffect/S in globalStatusPrototypes)
							be_string += "[S.name] = [S.id]<br>"
						usr.Browse(be_string,"window=statuseffect_help;size=300x600")

					if("traitlist_help")
						var/tl_string = "<b>All Traits and their descriptions</b><hr>"
						for(var/trait in traitList)
							var/datum/trait/trait_obj = traitList[trait]
							tl_string += "[trait_obj.name] - [trait_obj.desc]<br><br>"
						usr.Browse(tl_string,"window=traitlist_help;size=500x600")

					if ("reagent_help")
						var/r_string = "To add or remove multiple reagents enter multiple IDs separated by semicolons.<br><br><b>All Reagent IDs</b><hr>"
						for(var/R in reagents_cache)
							r_string += "[R]<br>"
						usr.Browse(r_string,"window=reagent_help;size=300x600")

					if ("add_bioeffect_one","remove_bioeffect_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_bioeffect_one"
							var/mob/M = input("Which player?","[adding ? "Give" : "Remove"] Bioeffects") as null|mob in world

							if (!M)
								return

							var/pick = input("Which effect(s)?","[adding ? "Give" : "Remove"] Bioeffects") as null|text

							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (length(picklist))
								var/string_version

								for(pick in picklist)
									if (adding)
										M.bioHolder.AddEffect(pick)
									else
										M.bioHolder.RemoveEffect(pick)

									if (string_version)
										string_version = "[string_version], \"[pick]\""
									else
										string_version = "\"[pick]\""

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(M)].")
								logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(M)].")
								logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(M)].", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator to bioeffect players.")
							return
					if ("add_ability_one","remove_ability_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_ability_one"
							var/mob/M = tgui_input_list(owner, "Which player?","[adding ? "Give" : "Remove"] Abilities", sortNames(mobs))

							if (!istype(M))
								return

							if (!M.abilityHolder)
								tgui_alert(usr,"No ability holder detected. Create a holder first!")
								return

							var/ab_to_do = tgui_input_list(owner, "Which ability?", "[adding ? "Give" : "Remove"] Ability", childrentypesof(/datum/targetable))
							if (adding)
								M.onProcCalled("addAbility", list(ab_to_do))
								M.abilityHolder.addAbility(ab_to_do)
							else
								M.abilityHolder.removeAbility(ab_to_do)
							M.abilityHolder.updateButtons()

							message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] [key_name(M)].")
							logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] [key_name(M)].")
							logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] [key_name(M)].", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator to change player abilities.")
							return
					if ("setstatuseffect_one")
						if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
							var/mob/M = tgui_input_list(owner, "Which player?","Set StatusEffect", sortNames(mobs))
							//this doesn't seem to work I give up.
							if (!istype(M))
								return

							var/list/L = list()
							for(var/R in concrete_typesof(/datum/statusEffect))
								L += R
							sortList(L, /proc/cmp_text_asc)
							var/datum/statusEffect/effect = tgui_input_list(usr, "Which Status Effect?", "Give Status Effect", L)

							if (!effect)
								return

							var/duration = input("Duration (in seconds)?","Status Effect Duration") as null|num
							if (isnull(duration))
								return

							if (duration <= 0)
								M.delStatus(initial(effect.id))
								message_admins("[key_name(usr)] removed the [initial(effect.id)] status-effect from [key_name(M)].")
							else
								M.setStatus(initial(effect.id), duration SECONDS)
								message_admins("[key_name(usr)] added the [initial(effect.id)] status-effect on [key_name(M)] for [duration] seconds.")

						else
							tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to statuseffect a player.")

					if ("add_reagent_one","remove_reagent_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_reagent_one"
							var/mob/M = input("Which player?","[adding ? "Add" : "Remove"] Reagents") as null|mob in world

							if (!M)
								return

							var/pick = input("Which reagent(s)?","[adding ? "Add" : "Remove"] Reagents") as null|text

							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (length(picklist))
								var/string_version

								for(pick in picklist)
									var/amt = input("How much of [pick]?","[adding ? "Add" : "Remove"] Reagent") as null|num
									if(!amt || amt < 0)
										return

									if (adding)
										if (M.reagents)
											M.reagents.add_reagent(pick,amt)
									else
										if (M.reagents)
											M.reagents.remove_reagent(pick,amt)

									if (string_version)
										string_version = "[string_version], [amt] \"[pick]\""
									else
										string_version = "[amt] \"[pick]\""

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(M)].")
								logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(M)].")
								logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(M)].", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator to affect player reagents.")
							return

					if ("add_bioeffect_all","remove_bioeffect_all")
						if (src.level >= LEVEL_PA)
							var/adding = href_list["type"] == "add_bioeffect_all"
							var/pick = input("Which effect(s)?","[adding ? "Give" : "Remove"] Bioeffects [adding ? "to" : "from"] Everyone") as null|text
							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (length(picklist))
								var/string_version
								for(pick in picklist)
									if (string_version)
										string_version = "[string_version], \"[pick]\""
									else
										string_version = "\"[pick]\""

								SPAWN(0)
									for(var/mob/living/carbon/X in mobs)
										for(pick in picklist)
											if (adding)
												X.bioHolder.AddEffect(pick)
											else
												X.bioHolder.RemoveEffect(pick)
										sleep(0.1 SECONDS)

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[length(picklist) > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator to bioeffect players.")
							return

					if ("add_ability_all","remove_ability_all")
						if (src.level >= LEVEL_PA)
							var/adding = href_list["type"] == "add_ability_all"

							var/ab_to_do = tgui_input_list(owner, "Which ability?", "[adding ? "Give" : "Remove"] ability [adding ? "to" : "from"] every human.", childrentypesof(/datum/targetable))
							if (!ab_to_do)
								return
							// var/humans = input("[adding ? "Add" : "Remove"] ability [adding ? "to" : "from"] Humans or mob/living?", "Humans or Living?", "Humans") as null|anything in list("Humans", "Living")

							for(var/mob/living/carbon/human/M in mobs)
								if (!M.abilityHolder)
									continue
								if (adding)
									M.abilityHolder.addAbility(ab_to_do)
								else
									M.abilityHolder.removeAbility(ab_to_do)
								M.abilityHolder.updateButtons()


							message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] everyone.")
							logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] everyone.")
							logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] everyone.", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator to change player abilities.")
							return
					if ("setstatuseffect_all")
						if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
							var/list/L = list()
							for(var/R in concrete_typesof(/datum/statusEffect))
								L += R
							sortList(L, /proc/cmp_text_asc)
							var/datum/statusEffect/effect = tgui_input_list(usr, "Which Status Effect?", "Give Status Effect", L)

							if (!effect)
								return

							var/duration = input("Duration (in seconds)?","Status Effect Duration") as null|num
							if (isnull(duration))
								return


							if (duration <= 0)
								for(var/mob/living/carbon/human/M in mobs)
									M.delStatus(initial(effect.id))
								message_admins("[key_name(usr)] removed the [initial(effect.id)] status-effect from everyone.")
							else
								for(var/mob/living/carbon/human/M in mobs)
									M.setStatus(initial(effect.id), duration SECONDS)

								message_admins("[key_name(usr)] added the [initial(effect.id)] status-effect on everyone for [duration] seconds.")

						else
							tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to statuseffect a player.")

					if ("add_reagent_all","remove_reagent_all")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_reagent_all"
							var/pick = input("Which reagent(s)?","[adding ? "Add" : "Remove"] Reagents [adding ? "to" : "from"] Everyone") as null|text
							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (length(picklist))
								var/string_version

								for(pick in picklist)
									var/amt = input("How much of [pick]?","[adding ? "Add" : "Remove"] Reagent") as null|num
									picklist[pick] = amt

									if (string_version)
										string_version = "[string_version], [amt] \"[pick]\""
									else
										string_version = "[amt] \"[pick]\""

								SPAWN(0)
									for(var/mob/living/carbon/X in mobs)
										for(pick in picklist)
											var/amt = picklist[pick]
											if(!amt)
												continue
											if (adding)
												if (X.reagents)
													X.reagents.add_reagent(pick,amt)
											else
												if (X.reagents)
													X.reagents.remove_reagent(pick,amt)
										sleep(0.1 SECONDS)

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.")
								logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.")
								logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.", "admin")

						else
							tgui_alert(usr,"You must be at least a Primary Administrator to affect player reagents.")
							return

					if ("animate_one")
						if (src.level >= LEVEL_PA)
							var/mob/M = input("Which mob?","Adding animation") as null|mob in world
							if (!M)
								return

							var/animationpick = tgui_input_list(usr, "Select animation.", "Animation", global.animations)
							if (!animationpick)
								return
							call(animationpick)(M)

							message_admins("[key_name(usr)] added animation [animationpick] to [M].")
							logTheThing(LOG_ADMIN, usr, "added animation [animationpick] to [M].")
							logTheThing(LOG_DIARY, usr, "added animation [animationpick] to [M].", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator to animate mobs.")
							return

					if ("animate_all")
						if (src.level >= LEVEL_PA)

							var/animationpick = tgui_input_list(usr, "Select animation.", "Animation", global.animations)
							if (!animationpick)
								return

							for(var/mob/living/carbon/human/M in mobs)
								SPAWN(0)
									call(animationpick)(M)

							message_admins("[key_name(usr)] added animation [animationpick] to everyone.")
							logTheThing(LOG_ADMIN, usr, "added animation [animationpick] to everyone.")
							logTheThing(LOG_DIARY, usr, "added animation [animationpick] to everyone.", "admin")
						else
							tgui_alert(usr,"You must be at least a Primary Administrator to animate mobs.")
							return

					if ("ballpit")
						if (src.level >= LEVEL_SA)
							message_admins("[key_name(usr)] began replacing all Z1 pools will ballpits.")
							for (var/obj/poolwater/W in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (W.z != 1)
									break
								if (W.icon_state != "ballpitwater")
									W.icon_state = "ballpitwater"
									W.name = "ball pit"
									W.float_anim = 0
								LAGCHECK(LAG_LOW)
							for (var/obj/pool/P in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (P.z != 1)
									break
								if (P.icon_state == "pool_in_misc")
									P.icon_state = "ballpit_in_misc"
								else if (P.icon_state == "pool_in")
									P.icon_state = "ballpit_in"
								else if (P.icon_state == "pool")
									P.icon_state = "ballpit"
								LAGCHECK(LAG_LOW)
							for (var/turf/simulated/floor/pool/P in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (P.z != 1)
									break
								if (P.icon_state == "poolwaterfloor")
									P.icon_state = "ballpitfloor"
									P.name = "ball pit"
								LAGCHECK(LAG_LOW)
							message_admins("[key_name(usr)] replaced all Z1 pools with ballpits.")
							logTheThing(LOG_ADMIN, usr, "replaced z1 pools with ballpits.")
							logTheThing(LOG_DIARY, usr, "replaced z1 pools with ballpits.", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if ("woodstation")
						if (src.level >= LEVEL_PA)
							message_admins("[key_name(usr)] began replacing all Z1 floors and walls with wooden ones.")
							for (var/turf/simulated/wall/W in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (W.z != 1)
									break
								new /turf/simulated/wall/auto/supernorn/wood(get_turf(W))
								LAGCHECK(LAG_LOW)
							for (var/turf/simulated/floor/F in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (F.z != 1)
									break
								if (istype(F, /turf/simulated/floor/carpet))
									continue
								if (F.icon_state != "wooden")
									F.icon_state = "wooden"
									F.step_material = "step_wood"
								LAGCHECK(LAG_LOW)
							message_admins("[key_name(usr)] replaced all Z1 floors and walls with wooden ones.")
							logTheThing(LOG_ADMIN, usr, "replaced z1 floors and walls with wooden doors.")
							logTheThing(LOG_DIARY, usr, "replaced z1 floors and walls with wooden doors.", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if ("yeolde")
						if (src.level >= LEVEL_PA)
							message_admins("[key_name(usr)] began replacing all Z1 airlocks with wooden doors.")
							for (var/obj/machinery/door/D in by_type[/obj/machinery/door])
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 airlocks with wooden doors was terminated due to the atom emerygency stop!")
									return
								if (D.z != 1)
									break
								if (istype(D, /obj/machinery/door/poddoor/) || istype(D, /obj/machinery/door/firedoor/) || istype(D, /obj/machinery/door/window/))
									continue
								new /obj/machinery/door/unpowered/wood(get_turf(D))
								qdel(D)
								LAGCHECK(LAG_LOW)
							message_admins("[key_name(usr)] replaced all Z1 airlocks with wooden doors.")
							logTheThing(LOG_ADMIN, usr, "replaced z1 airlocks with wooden doors.")
							logTheThing(LOG_DIARY, usr, "replaced z1 airlocks with wooden doors.", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("fakeguns")
						if (src.level >= LEVEL_ADMIN)
							for(var/obj/item/W in world)
								if(istype(W, /obj/item/clothing) || istype(W, /obj/item/card/id) || istype(W, /obj/item/disk) || istype(W, /obj/item/tank))
									continue
								W.icon = 'icons/obj/items/guns/kinetic.dmi'
								W.icon_state = "revolver"
								W.item_state = "gun"
								LAGCHECK(LAG_LOW)
							message_admins("[key_name(usr)] made every item look like a gun")
							logTheThing(LOG_ADMIN, usr, "used Fake Gun secret.")
							logTheThing(LOG_DIARY, usr, "used Fake Gun secret.", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("flipstation")
						var/direction = input("Which way?", "Which direction?", "Normal") in list("Normal", "Rotated CW", "Rotated CCW", "Upside down")
						var/setdir = NORTH
						switch (direction)
							if ("Rotated CW")
								setdir = WEST
							if ("Rotated CCW")
								setdir = EAST
							if ("Upside down")
								setdir = SOUTH
						if (src.level >= LEVEL_ADMIN)
							for(var/mob/M in mobs)
								M.client?.dir = setdir
								LAGCHECK(LAG_LOW)
							message_admins("[key_name(usr)] set station direction to [direction].")
							logTheThing(LOG_ADMIN, src, "set station direction to [direction].")
							logTheThing(LOG_DIARY, src, "set station direction to [direction]", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("raiseundead")
						if (src.level >= LEVEL_ADMIN)
							for(var/mob/living/carbon/human/H in mobs) //Only humans can be zombies!
								if(!isdead(H)) //Not dead!
									continue
								if(istype(H.mutantrace, /datum/mutantrace/zombie))
									continue //Already a zombie!

								H.set_mutantrace(/datum/mutantrace/zombie)
								setalive(H) //Set stat back to zero so we can call death()
								H.death()//Calling death() again means that the zombies will rise after ~20 seconds.
								LAGCHECK(LAG_LOW)

							message_admins("[key_name(usr)] has brought back all dead humans as zombies.")
							logTheThing(LOG_ADMIN, usr, "brought back all dead humans as zombies.")
							logTheThing(LOG_DIARY, usr, "brought back all dead humans as zombies", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("forcerandomnames")
						if (src.level >= LEVEL_PA)
							if(current_state > GAME_STATE_PREGAME)
								tgui_alert(usr,"You can only only trigger this before the game starts, sorry pal!")
								return

							force_random_names = 1

							for(var/client/C in clients)
								if (!C.preferences)
									continue
								C.preferences.be_random_name = 1

							message_admins("[key_name(usr)] has set all players to use random names this round.")
							logTheThing(LOG_ADMIN, usr, "set all players to use random names.")
							logTheThing(LOG_DIARY, usr, "set all players to use random names.", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("forcerandomlooks")
						if (src.level >= LEVEL_PA)
							if(current_state > GAME_STATE_PREGAME)
								tgui_alert(usr,"You can only only trigger this before the game starts, sorry pal!")
								return

							force_random_looks = 1

							for(var/client/C in clients)
								if (!C.preferences)
									continue
								C.preferences.be_random_look = 1

							message_admins("[key_name(usr)] has set all players to use random appearances this round.")
							logTheThing(LOG_ADMIN, usr, "set all players to use random appearances.")
							logTheThing(LOG_DIARY, usr, "set all players to use random appearances.", "admin")
						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("sawarms")
						if (src.level >= LEVEL_ADMIN)
							for (var/mob/living/carbon/human/M in mobs)
								if (!ismonkey(M))
									for (var/obj/item/parts/human_parts/arm/P in M)
										P.sever()
										var/obj/item/parts/human_parts/arm/sawarm = null

										if (P.slot == "l_arm")
											sawarm = new /obj/item/parts/human_parts/arm/left/item(M)
											M.limbs.l_arm = sawarm
										else
											sawarm = new /obj/item/parts/human_parts/arm/right/item(M)
											M.limbs.r_arm = sawarm
										if (!sawarm) return

										sawarm.holder = M
										sawarm.remove_stage = 0
										sawarm:set_item(new /obj/item/saw/elimbinator())


									playsound(M, 'sound/machines/chainsaw_red.ogg', 60, TRUE)
									M.update_body()
							message_admins("[key_name(usr)] has given everyone new arms.")
							logTheThing(LOG_ADMIN, usr, "used the Saw Arms secret.")
							logTheThing(LOG_DIARY, usr, "used the Saw Arms secret.", "admin")

						else
							tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("emag_all_things")
						if (src.level >= LEVEL_ADMIN)
							if (tgui_alert(usr,"Do you really want to emag everything?","Bad Idea", list("Yes", "No")) == "Yes")
								message_admins("[key_name(usr)] has started emagging everything!")
								logTheThing(LOG_ADMIN, usr, "used the Emag Everything secret.")
								logTheThing(LOG_DIARY, usr, "used the Emag Everything secret.", "admin")
								//DO IT!
								for(var/atom/A as mob|obj in world)
									A?.emag_act(null,null)
									LAGCHECK(LAG_LOW)
								message_admins("[key_name(usr)] has emagged everything!")
							else
								return

						else
							tgui_alert(usr,"You need to be at least a Administrator to emag everything")
							return

					if("shakecamera")
						if (src.level >= LEVEL_ADMIN)
							var/intensity = input("Enter intensity of the shaking effect (pixels to jostle view around by). 64 or over will also cause mobs to trip over.","Shaking intensity",null) as num|null
							if (!intensity)
								return
							var/time = input("Enter length of the shaking effect in seconds.", "length of shaking effect", 1) as num
							logTheThing(LOG_ADMIN, src, "created a shake effect (intensity [intensity], length [time])")
							logTheThing(LOG_DIARY, src, "created a shake effect (intensity [intensity], length [time])", "admin")
							message_admins("[key_name(usr)] has created a shake effect (intensity [intensity], length [time]).")
							for (var/mob/M in mobs)
								SPAWN(0)
									shake_camera(M, time * 10, intensity)
								if (intensity >= 64)
									M.changeStatus("knockdown", 2 SECONDS)

						else
							tgui_alert(usr,"You need to be at least a Administrator to shake the camera.")
							return

					if("creepifystation")
						if (src.level >= LEVEL_ADMIN)
							if (tgui_alert(usr,"Are you sure you should creepify the station? There's no going back.", "PARENTAL CONTROL", list("Yes", "No")) == "Yes")
								message_admins("[key_name(usr)] creepified the station.")
								logTheThing(LOG_ADMIN, usr, "used the Creepify Station button")
								logTheThing(LOG_DIARY, usr, "used the Creepify Station button", "admin")
								creepify_station()
						else
							tgui_alert(usr,"You need to be at least a Administrator to creepify the station.")
							return


					if ("command_report_zalgo")
						if (src.level >= LEVEL_ADMIN)
							var/input = input(usr, "Enter the text for the alert. Anything. Serious.", "What?", "") as null|message
							input = zalgoify(input, rand(0,2), rand(0, 2), rand(0, 2))
							if(!input)
								return
							var/input2 = input(usr, "Add a headline for this alert? leaving this blank creates no headline", "What?", "") as null|text
							input2 = zalgoify(input2, rand(0,2), rand(0, 2), rand(0, 2))
							var/input3 = input(usr, "Add an origin to the transmission, leaving this blank 'Unknown Source'", "What?", "") as null|text
							if(!input3)
								input3 = "Unknown Source"

							if (alert(src, "Origin: [input3 ? "\"[input3]\"" : "None"]\nHeadline: [input2 ? "\"[input2]\"" : "None"]\nBody: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
								for_by_tcl(C, /obj/machinery/communications_dish)
									C.add_centcom_report(input2, input)

								var/sound_to_play = 'sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg'
								command_alert(input, input2, sound_to_play, alert_origin = input3);

								logTheThing(LOG_ADMIN, usr, "has created a command report (zalgo): [input]")
								logTheThing(LOG_DIARY, usr, "has created a command report (zalgo): [input]", "admin")
								message_admins("[key_name(usr)] has created a command report (zalgo)")

					if ("command_report_void")
						if (src.level >= LEVEL_ADMIN)
							var/input = input(usr, "Enter the text for the alert. Anything. Serious.", "What?", "") as null|message
							input = voidSpeak(input)
							if(!input)
								return
							var/input2 = input(usr, "Add a headline for this alert? leaving this blank creates no headline", "What?", "") as null|text
							var/input3 = input(usr, "Add an origin to the transmission, leaving this blank 'Unknown Source'", "What?", "") as null|text
							if(!input3)
								input3 = "Unknown Source"

							if (alert(src, "Origin: [input3 ? "\"[input3]\"" : "None"]\nHeadline: [input2 ? "\"[input2]\"" : "None"]\nBody: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
								for_by_tcl(C, /obj/machinery/communications_dish)
									C.add_centcom_report(input2, input)

								var/sound_to_play = 'sound/ambience/spooky/Void_Calls.ogg'
								command_alert(input, input2, sound_to_play, alert_origin = input3);

								logTheThing(LOG_ADMIN, usr, "has created a command report (void): [input]")
								logTheThing(LOG_DIARY, usr, "has created a command report (void): [input]", "admin")
								message_admins("[key_name(usr)] has created a command report (void)")

					if ("noir")
						if(src.level >= LEVEL_ADMIN)
							if (noir)
								if (tgui_alert(usr,"Had enough of noir?", "Good decisions", list("Yes", "No")) == "Yes")
									noir = 0
									for (var/mob/M in mobs)
										if (M.client)
											animate_fade_from_grayscale(M.client, 50)
									message_admins("[key_name(usr)] undid placing the station in noir mode.")
									logTheThing(LOG_ADMIN, usr, "used the Noir secret to remove noir")
									logTheThing(LOG_DIARY, usr, "used the Noir secret to remove noir", "admin")
							if (tgui_alert(usr,"Are you sure you should noir?", "PARENTAL CONTROL", list("Yes", "No")) == "Yes")
								noir = 1
								for (var/mob/M in mobs)
									if (M.client)
										animate_fade_grayscale(M.client, 50)
									LAGCHECK(LAG_LOW)
								message_admins("[key_name(usr)] placed the station in noir mode.")
								logTheThing(LOG_ADMIN, usr, "used the Noir secret")
								logTheThing(LOG_DIARY, usr, "used the Noir secret", "admin")

					if("the_great_switcharoo")
						if(src.level >= LEVEL_ADMIN) //Will be SG when tested
							if (tgui_alert(usr,"Do you really wanna do the great switcharoo?", "Awoo, awoo", list("Yes", "No")) == "Yes")
								var/silicons_too = (tgui_alert(usr, "Include silicons?", "Silicons", list("Yes", "No")) == "Yes")

								var/list/mob/living/people_to_swap = list()

								for(var/mob/living/L in mobs) //Build the swaplist
									if(L?.key && L.mind && !isdead(L) && (ishuman(L) || (issilicon(L) && silicons_too)))
										people_to_swap += L
									LAGCHECK(LAG_LOW)

								if(length(people_to_swap) > 1) //Jenny Antonsson switches bodies with herself! #wow #whoa
									message_admins("[key_name(usr)] did The Great Switcharoo")
									logTheThing(LOG_ADMIN, usr, "used The Great Switcharoo secret")
									logTheThing(LOG_DIARY, usr, "used The Great Switcharoo secret", "admin")

									var/mob/A = pick(people_to_swap)
									do //More random
										people_to_swap -= A
										var/mob/B = pick(people_to_swap)
										if(A?.mind && B)
											A.mind.swap_with(B)
										A = B
										LAGCHECK(LAG_LOW)
									while(length(people_to_swap) > 0)

							else
								return
						else
							tgui_alert(usr,"You are not a shit enough guy to switcharoo, bub.")


					if("fartyparty")
						if(src.level >= LEVEL_ADMIN) //Will be SG when tested
							if (farty_party)
								farty_party = 0
								deep_farting = 0
								message_admins("[key_name(usr)] stopped the farty party, ok everyone go home")
							else
								farty_party = 1
								deep_farting = 1
								message_admins("[key_name(usr)] IS GETTIN THIS FARTY PARTY STARTED")
						logTheThing(LOG_ADMIN, usr, "used Farty Party secret")
						logTheThing(LOG_DIARY, usr, "used Farty Party secret", "admin")
				if (usr)
					logTheThing(LOG_ADMIN, usr, "used secret [href_list["secretsfun"]]")
				logTheThing(LOG_DIARY, usr, "used secret [href_list["secretsfun"]]", "admin")
			else
				tgui_alert(usr,"You need to be at least an Adminstrator to use the secrets panel.")
				return

		if ("secretsdebug")
			if (src.level >= LEVEL_CODER)
				switch(href_list["type"])
					if("budget")
						src.owner:debug_variables(wagesystem)
					if("market")
						src.owner:debug_variables(shippingmarket)
					if("genetics")
						src.owner:debug_variables(genResearch)
					if("jobs")
						src.owner:debug_variables(job_controls)
					if("hydro")
						src.owner:debug_variables(hydro_controls)
					if("manuf")
						src.owner:debug_variables(manuf_controls)
					if("radio")
						src.owner:debug_variables(radio_controller)
					if("randevent")
						src.owner:debug_variables(random_events)
					if("disease")
						src.owner:debug_variables(disease_controls)
					if("artifact")
						src.owner:debug_variables(artifact_controls)
					if("gauntlet")
						src.owner:debug_variables(gauntlet_controller)
					if("stock")
						src.owner:debug_variables(stockExchange)
					if("emshuttle")
						src.owner:debug_variables(emergency_shuttle)
					if("datacore")
						src.owner:debug_variables(data_core)
					if("miningcontrols")
						src.owner:debug_variables(mining_controls)
					if("mapsettings")
						src.owner:debug_variables(map_settings)
					if("ghostnotifications")
						src.owner:debug_variables(ghost_notifier)
					if("overlays")
						overlaytest()
					if("overlaysrem")
						removerlays()
					if("world")
						src.owner:debug_variables(world)
					if("globals")
						src.owner:debug_variables("GLOB")
					if("globalprocs")
						src.owner:show_proc_list(null)
					if("testmerges")
					#if defined(TESTMERGE_PRS)
						var/pr_num = tgui_input_list(src.owner.mob, "Details:", "Testmerges", TESTMERGE_PRS)
						if(pr_num)
							var/file_text = file2text("testmerges/[pr_num].json")
							src.owner.Browse("<html><body><div><pre>[file_text]</pre></div></body></html>", "window=testmerges;title=Testmerges;size=400x700")
					#else
						tgui_alert(src.owner.mob, "No current testmerges! None!", "No Testmerges")
					#endif
			else
				tgui_alert(usr,"You need to be at least a Coder to use debugging secrets.")

		if ("secretsadmin")
			if (src.level >= LEVEL_MOD)
				var/ok = 0

				switch(href_list["type"])
					if("check_antagonist")
						if (isnull(src.antagonist_panel))
							src.antagonist_panel = new

						src.antagonist_panel.ui_interact(src.owner.mob)

					if("shuttle_panel")
						if (current_state >= GAME_STATE_PLAYING)
							var/dat = "<html><head><title>Shuttle Controls</title></head><body><h1><B>Shuttle Controls</B></h1>"
							dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"
							dat += "<B>Emergency shuttle:</B><BR>"
							if (!emergency_shuttle.online)
								dat += "<a href='byond://?src=\ref[src];action=call_shuttle&type=1'>Call Shuttle</a><br>"
							else
								var/timeleft = emergency_shuttle.timeleft()
								switch(emergency_shuttle.location)
									if(0)
										dat += "ETA: <a href='byond://?src=\ref[src];action=edit_shuttle_time'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
										dat += "<a href='byond://?src=\ref[src];action=call_shuttle&type=2'>Send Back</a><br>"
									if(1)
										dat += "ETA: <a href='byond://?src=\ref[src];action=edit_shuttle_time'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
							dat += "</body></html>"
							usr.Browse(dat, "window=roundstatus;size=400x500")
					if("manifest")
						var/dat = "<B>Showing Crew Manifest.</B><HR>"
						dat += "<table cellspacing=5><tr><th>Name</th><th>Original Position</th><th>Position</th></tr>"
						for(var/mob/living/carbon/human/H in mobs)
							if(H.ckey)
								var/obj/item/card/id/id_card = get_id_card(H.wear_id)
								dat += "<tr><td>[H.name]</td><td>[(H.mind ? H.mind.assigned_role : "Unknown Position")]</td><td>[(istype(id_card)) ? "[id_card.assignment]" : "Unknown Position"]</td></tr>"
							LAGCHECK(LAG_LOW)
						dat += "</table>"
						usr.Browse(dat, "window=manifest;size=440x410")
					if("jobcaps")
						usr.client.cmd_job_controls()
					if("respawn_panel")
						usr.client.cmd_custom_spawn_event()
					if("randomevents")
						//random_events.ui_interact(src.owner.mob)
						random_events.event_config()
					if("motives")
						simsController.showControls(usr)
					if("regionallocator")
						usr.client.region_allocator_panel()
					if("artifacts")
						artifact_controls.config()
					if("DNA")
						var/dat = "<B>Showing DNA from blood.</B><HR>"
						dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
						for(var/mob/living/carbon/human/H in mobs)
							if(H.ckey)
								dat += "<tr><td>[H]</td><td>[H.bioHolder.Uid]</td><td>[H.bioHolder.bloodType]</td></tr>"
							LAGCHECK(LAG_LOW)
						dat += "</table>"
						usr.Browse(dat, "window=DNA;size=440x410")
					if("fingerprints")
						var/dat = "<B>Showing Fingerprints.</B><HR>"
						dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
						for(var/mob/living/carbon/human/H in mobs)
							if(H.ckey)
								if(H.bioHolder.Uid)
									dat += "<tr><td>[H]</td><td>[H.bioHolder.fingerprints]</td></tr>"
								else if(!H.bioHolder.Uid)
									dat += "<tr><td>[H]</td><td>H.bioHolder.Uid = null</td></tr>"
							LAGCHECK(LAG_LOW)
						dat += "</table>"
						usr.Browse(dat, "window=fingerprints;size=440x410")
#ifdef SECRETS_ENABLED
					if ("ideas")
						usr.Browse(file2text("+secret/assets/fun_admin_ideas.html"), "window=admin_ideas;size=700x450;title=Admin Ideas")
#endif
				if (usr)
					logTheThing(LOG_ADMIN, usr, "used secret [href_list["secretsadmin"]]")
					logTheThing(LOG_DIARY, usr, "used secret [href_list["secretsadmin"]]", "admin")
					if (ok)
						boutput(world, text("<B>A secret has been activated by []!</B>", usr.key))
				return
			else
				tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")

		if ("view_logs_web")
			if ((src.level >= LEVEL_MOD) && !src.tempmin)
				usr << link("[goonhub_href("/admin/logs/[roundId]")]")

		if ("view_logs")
			if ((src.level >= LEVEL_MOD) && !src.tempmin)
				var/gettxt
				var/logType = href_list["type"]
				var/preSearch
				if (href_list["presearch"])
					preSearch = href_list["presearch"]
				if (findtext(logType, "string") && !preSearch)
					gettxt = input("What are you searching for?","Log by String") as null|text
					if (!gettxt) return
				else if (preSearch)
					gettxt = preSearch

				var/adminLogHtml = get_log_data_html(logType, gettxt, src)

				usr.Browse(adminLogHtml, "window=[logType]_log_[gettxt];size=750x500")
			else
				tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")

		if ("respawntarget")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/mob/newM = usr.client.respawn_target(M)
				href_list["target"] = "\ref[newM]"
			else
				alert ("You must be at least a Secondary Admin to respawn a target.")
		if ("respawnas")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/client/C = M.client
				if (!M) return
				var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
				sortList(jobs, /proc/cmp_text_asc)
				var/datum/job/job = tgui_input_list(usr, "Select job to respawn", "Respawn As", jobs)
				if(!job) return
				var/mob/new_player/newM = usr.client.respawn_target(M)
				newM?.AttemptLateSpawn(job, force=1)
				href_list["target"] = "\ref[C.mob]"
			else
				alert ("You must be at least a Secondary Admin to respawn a target.")
		if ("showrules")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.show_rules_to_player(M, rp_rules=href_list["type"] == "rp")
			else
				alert ("You must be at least a Secondary Admin to show rules to a player.")
		if ("warn")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.warn(M)
			else
				alert ("You must be at least a Secondary Admin to warn a player.")
		if ("clownify")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (tgui_alert(usr,"Make [M] a cluwne?", "Make Cluwne", list("Yes", "No")) == "Yes")
					usr.client.cmd_admin_clownify(M)
			else
				alert ("You must be at least a Primary Admin to clownify a player.")
		if ("plainmsg")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_plain_message(M)
			else
				alert ("You must be at least a Moderator to plain message a player.")
		if ("humanize")
			if (src.level >= LEVEL_SA) // Moved from SG to PA (Convair880). And then back (Somepotato)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/mob/newM = usr.client.cmd_admin_humanize(M)
				href_list["target"] = "\ref[newM]"
			else
				alert ("You must be at least a Primary Admin to humanize a player.")
		if ("chatbans")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M || !M.client)
					tgui_alert( "That player doesn't exist!" )
					return
				src.show_chatbans(M.client)
			else
				tgui_alert( "You must be at least a Primary Admin to manage chat bans." )
		if ("flavortext")
			if( src.level >= LEVEL_SA )
				var/mob/M = locate(href_list["target"])
				if (!M || !M.client)
					tgui_alert( "That player doesn't exist!" )
					return
				var/html = "Flavor Text: \"[M.client.preferences?.flavor_text]\"<br>"
				html += "Security Note: \"[M.client.preferences.security_note]\"<br>"
				html += "Medical Note: \"[M.client.preferences.medical_note]\"<br>"
				html += "Syndicate Intelligence: \"[M.client.preferences.synd_int_note]\""
				usr.Browse(html, "window=flavortext;title=Flavor text")
			else
				tgui_alert( "You must be at least a Secondary Admin to manage chat bans." )
		if ("change_station_name")
			if (!station_name_changing)
				return tgui_alert(usr,"Station name changing is currently disabled.")

			if (src.level >= LEVEL_MOD)
				usr.openStationNameChangeWindow(src, "action=change_station_name_2")
			else
				alert ("You must be at least a Moderator to change the station name.")
		if ("change_station_name_2")
			if (!station_name_changing)
				return tgui_alert(usr,"Station name changing is currently disabled.")

			if (src.level >= LEVEL_MOD)
				var/newName = href_list["newName"]
				if (set_station_name(usr, newName))
					command_alert("The new station name is [station_name]", "Station Naming Ceremony Completion Detection Algorithm", alert_origin = ALERT_STATION)

				usr.Browse(null, "window=stationnamechanger")
				src.Game()

		if ("switch_map")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to switch maps.")

			usr.client.cmd_change_map()

		if ("start_map_vote")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to start map votes.")

			if (!mapSwitcher.votingAllowed)
				return tgui_alert(usr,"Map votes are currently toggled off.")

			usr.client.cmd_start_map_vote()

		if ("end_map_vote")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to end map votes.")

			usr.client.cmd_end_map_vote()

		if ("cancel_map_vote")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to cancel map votes.")

			usr.client.cmd_cancel_map_vote()

		if ("view_runtimes")
			if (src.level < LEVEL_SA)
				return tgui_alert(usr,"You must be at least a Secondary Admin to view runtimes.")

			usr.client.cmd_view_runtimes()

		// if ("viewantaghistory")
		// 	if (src.level < LEVEL_SA)
		// 		return tgui_alert(usr,"You must be at least a Secondary Admin to view antag history.")

		// 	usr.client.cmd_antag_history(href_list["targetckey"])

		if ("show_player_stats")
			if (src.level < LEVEL_SA)
				return tgui_alert(usr,"You must be at least a Secondary Admin to view player stats.")

			//Shortcut to popup with defined params if present, otherwise just call verb
			if (href_list["targetckey"])
				src.showPlayerStats(href_list["targetckey"])
			else
				usr.client.cmd_admin_show_player_stats()

		if ("show_player_ips")
			if (src.level < LEVEL_SA)
				return tgui_alert(usr,"You must be at least a Secondary Admin to view player IPs.")

			//Shortcut to popup with defined params if present, otherwise just call verb
			if (href_list["ckey"])
				var/ckey = href_list["ckey"]
				src.showPlayerIPs(ckey)
			else
				usr.client.cmd_admin_show_player_ips()

		if ("show_player_compids")
			if (src.level < LEVEL_SA)
				return tgui_alert(usr,"You must be at least a Secondary Admin to view player Computer IDs.")

			//Shortcut to popup with defined params if present, otherwise just call verb
			if (href_list["ckey"])
				var/ckey = href_list["ckey"]
				src.showPlayerCompIDs(ckey)
			else
				usr.client.cmd_admin_show_player_compids()

		if ("lightweight_doors")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.lightweight_doors()

		if ("lightweight_mobs")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.lightweight_mobs()

		if ("slow_atmos")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.slow_atmos()

		if ("slow_fluids")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.slow_fluids()

		if ("special_sea_fullbright")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.special_fullbright()

		if ("slow_ticklag")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.slow_ticklag()

		if ("disable_deletions")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.disable_deletions()

		if ("disable_ingame_logs")
			if (src.level < LEVEL_PA)
				return tgui_alert(usr,"You must be at least a Primary Admin to do this.")

			usr.client.disable_ingame_logs()

		////////////

		if ("toggle_dj")
			var/mob/M = (href_list["target"] ? locate(href_list["target"]) : null)
			if(M?.client)
				global.dj_panel.toggledj(M.client, usr.client)
			else
				alert ("No client found, sorry.")

		else
			message_coders("Undefined action [href_list["action"]]")

	//Wires bad hack part 2
	sleep(0)
	switch (originWindow)
		if ("adminplayeropts")
			if (href_list["targetckey"])
				var/mob/target = targetClient?.mob
				if(!target)
					var/targetCkey = href_list["targetckey"]
					for (var/mob/M in mobs) //The ref may have changed with our actions, find it again
						if (M.ckey == targetCkey)
							href_list["target"] = "\ref[M]"
							continue
					target = locate(href_list["target"])
				usr = adminClient.mob
				usr.client.holder.playeropt(target)

//-------------------------------------------- Panels

/datum/admins/proc/Game()
	if (!usr) // somehoooow
		return
	// ADMIN PANEL HTML IS HERE
	var/dat = "<title>Admin Game Panel</title>"

	dat += {"<style>
				a {text-decoration:none}
				.optionGroup {padding:5px; margin-bottom:8px; border:1px solid black}
				.optionGroup .title {display:block; color:white; background:black; padding: 2px 5px; margin: -5px -5px 2px -5px}
			</style>"}

	dat += "<div class='optionGroup' style='border-color:#AEC6CF'><b class='title' style='background:#AEC6CF'>Game Info</b>"

	//Map name
	dat += "Current map: <A href='byond://?src=\ref[src];action=switch_map'>[getMapNameFromID(map_setting)]</A>"
	if (mapSwitcher.next)
		dat += " (Next map: [mapSwitcher.next])"

	if (mapSwitcher.votingAllowed)
		dat += " (Vote: <A href='byond://?src=\ref[src];action=start_map_vote'>Start</A> | <A href='byond://?src=\ref[src];action=end_map_vote'>End</A> | <A href='byond://?src=\ref[src];action=cancel_map_vote'>Cancel</A>)"

	dat += "<br>"

	//Station name
	dat += "Station Name: <A href='byond://?src=\ref[src];action=change_station_name'>[station_name()]</A><br>"

	var/shuttletext = " " //setup shuttle message
	if(!emergency_shuttle) return // runtime error fix
	if (emergency_shuttle.online)
		switch(emergency_shuttle.location)
			if(0)// centcom
				if (emergency_shuttle.direction == 1)
					shuttletext = "Coming to Station (ETA: [round(emergency_shuttle.timeleft())] sec)"
				if (emergency_shuttle.direction == -1)
					shuttletext = "Returning to Centcom (ETA: [round(emergency_shuttle.timeleft())] sec)"
			if(1)// ss13
				shuttletext = "Arrived at Station (ETD: [round(emergency_shuttle.timeleft())] sec)"
			if(2)// evacuated
				shuttletext = "Evacuated to Centcom"
			else
				shuttletext = "Unknown"
	else
		shuttletext = "Idle"


	if (ticker)
		if (current_state >= GAME_STATE_PLAYING)
			dat += "Current Mode: [ticker.mode.name], Timer at [round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]<br>"
			if (src.level >= LEVEL_MOD)
				dat += "<A href='byond://?src=\ref[src];action=c_mode_panel'>Change Next Round's Game Mode</A> - Next: [next_round_mode]<br>"
			if (emergency_shuttle.online)
				dat += "<a href='byond://?src=\ref[src];action=call_shuttle&type=2'><b>Shuttle Status:</b></a> <a href='byond://?src=\ref[src];action=edit_shuttle_time'>[shuttletext]</a>"
			else
				dat += "<a href='byond://?src=\ref[src];action=call_shuttle&type=1'><b>Shuttle Status:</b></a> <a href='byond://?src=\ref[src];action=edit_shuttle_time'>[shuttletext]</a>"
			dat += "<br>Players Can Call: [src.level >= LEVEL_PA ? "<a href='byond://?src=\ref[src];action=toggle_shuttle_calling'>" : null][emergency_shuttle.disabled ? "No" : "Yes"][src.level >= LEVEL_PA ? "</a>" : null]"
			dat += " | Players Can Recall: [src.level >= LEVEL_PA ? "<a href='byond://?src=\ref[src];action=toggle_shuttle_recalling'>" : null][emergency_shuttle.can_recall ? "Yes" : "No"][src.level >= LEVEL_PA ? "</a>" : null]"
		else if (current_state <= GAME_STATE_PREGAME)
			dat += "Current Mode: [master_mode], Game has not started yet.<br>"
			if (src.level >= LEVEL_MOD)
				dat += "<A href='byond://?src=\ref[src];action=c_mode_panel'>Change Game Mode</A><br>"
			dat += "<b>Force players to use random names:</b> <A href='byond://?src=\ref[src];action=secretsfun;type=forcerandomnames'>[force_random_names ? "Yes" : "No"]</a><br>"
			dat += "<b>Force players to use random appearances:</b> <A href='byond://?src=\ref[src];action=secretsfun;type=forcerandomlooks'>[force_random_looks ? "Yes" : "No"]</a><br>"
			//dat += "<A href='byond://?src=\ref[src];action=secretsfun;type=forcerandomnames'>Politely suggest all players use random names</a>" // lol
	if (src.level >= LEVEL_SA)
		dat += "<hr>"
		dat += "<A href='byond://?src=\ref[src];action=create_object'>Create Object</A><br>"
		dat += "<A href='byond://?src=\ref[src];action=create_turf'>Create Turf</A><br>"
		dat += "<A href='byond://?src=\ref[src];action=create_mob'>Create Mob</A>"
		// Moved from SG to PA. They can do this through build mode anyway (Convair880).

	dat += "</div>"

	dat += {"<hr><div class='optionGroup' style='border-color:#FF6961'><b class='title' style='background:#FF6961'>Admin Tools</b>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=check_antagonist'>Antagonists</A><BR>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=jobcaps'>Job Controls</A><BR>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=respawn_panel'>Ghost Spawn Panel</A><BR>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=randomevents'>Random Event Controls</A><BR>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=regionallocator'>Region Allocator</A><BR>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=artifacts'>Artifact Controls</A><BR>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=motives'>Motive Control</A><BR>
				<A href='byond://?src=\ref[src];action=secretsadmin;type=manifest'>Crew Manifest</A> |
				<A href='byond://?src=\ref[src];action=secretsadmin;type=DNA'>Blood DNA</A> |
				<A href='byond://?src=\ref[src];action=secretsadmin;type=fingerprints'>Fingerprints</A><BR>
			"}
#ifdef SECRETS_ENABLED
	dat += {"<A href='byond://?src=\ref[src];action=secretsadmin;type=ideas'>Fun Admin Ideas</A>"}
#endif

	dat += "</div>"

	if (src.level >= LEVEL_ADMIN)
		dat += {"<hr><div class='optionGroup' style='border-color:#FFB347'><b class='title' style='background:#FFB347'>Coder Tools</b>
					<A href='byond://?src=\ref[src];action=secretsdebug;type=budget'>Wages/Money</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=market'>Shipping Market</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=genetics'>Genetics Research</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=jobs'>Jobs</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=hydro'>Hydroponics</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=manuf'>Manufacturing</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=radio'>Communications</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=randevent'>Random Events</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=disease'>Diseases</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=mechanic'>Mechanics</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=artifact'>Artifacts</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=gauntlet'>Gauntlet</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=stock'>Stock Market</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=emshuttle'>Emergency Shuttle</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=datacore'>Data Core</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=miningcontrols'>Mining Controls</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=mapsettings'>Map Settings</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=ghostnotifications'>Ghost Notifications</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=overlays'>Overlays</A>
					<A href='byond://?src=\ref[src];action=secretsdebug;type=overlaysrem'>(Remove)</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=world'>World</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=globals'>Global Variables</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=globalprocs'>Global Procs</A> |
					<A href='byond://?src=\ref[src];action=secretsdebug;type=testmerges'>Testmerges</A>
				"}

		dat += "</div>"

	dat += {"<hr><div class='optionGroup' style='border-color:#77DD77'><b class='title' style='background:#77DD77'>Logs</b>
				<b><A href='byond://?src=\ref[src];action=view_logs_web'>View all logs - web version</A></b><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=all_logs_string'>Search all Logs</A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_SPEECH]_log'>Speech Log </A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_SPEECH]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_COMBAT]_log'>Combat Log </A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_COMBAT]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_OOC]_log'>OOC Log </A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_OOC]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_STATION]_log'>Station Log </A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_STATION]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_PDAMSG]_log'>PDA Message Log </A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_PDAMSG]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_TELEPATHY]_log'>Telepathy Log </A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_TELEPATHY]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_ADMIN]_log'>Admin Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_ADMIN]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_GAMEMODE]_log'>Gamemode Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_GAMEMODE]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_DEBUG]_log'>Debug Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_DEBUG]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_AHELP]_log'>Adminhelp Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_AHELP]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_MHELP]_log'>Mentorhelp Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_MHELP]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_BOMBING]_log'>Bombing Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_BOMBING]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_SIGNALERS]_log'>Signaler Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_SIGNALERS]_log_string'><small>(Search)</small></A><BR>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_VEHICLE]_log'>Vehicle Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_VEHICLE]_log_string'><small>(Search)</small></A><br>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_CHEMISTRY]_log'>Chemistry Log</A>
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_CHEMISTRY]_log_string'><small>(Search)</small></A><br>
				Topic Log <!-- Viewing the entire log will usually just crash the admin's client, so let's not allow that -->
				<A href='byond://?src=\ref[src];action=view_logs;type=[LOG_TOPIC]_log_string'><small>(Search)</small></A><br>
				<hr>
				<A href='byond://?src=\ref[src];action=view_runtimes'>View Runtimes</A>
			"}

	dat += "</div>"

	// FUN SECRETS PANEL
	if (src.level >= LEVEL_PA || (src.level == LEVEL_SA && usr.client.holder.state == 2))
		dat += {"<hr><div class='optionGroup' style='border-color:#B57EDC'><b class='title' style='background:#B57EDC'>Fun Secrets</b>
					<b>Transformation:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=transform_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=transform_all'>All</A><BR>
					<b>Add Bio-Effect<A href='byond://?src=\ref[src];action=secretsfun;type=bioeffect_help'>*</a>:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=add_bioeffect_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=add_bioeffect_all'>All</A><BR>
					<b>Remove Bio-Effect:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=remove_bioeffect_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=remove_bioeffect_all'>All</A><BR>
					<b>Add Ability:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=add_ability_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=add_ability_all'>All</A><BR>
					<b>Remove Ability:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=remove_ability_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=remove_ability_all'>All</A><BR>
					<b>Set StatusEffect:</b>
						*
						<A href='byond://?src=\ref[src];action=secretsfun;type=setstatuseffect_all'>All</A><BR>
					<b>Add Reagent<A href='byond://?src=\ref[src];action=secretsfun;type=reagent_help'>*</a>:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=add_reagent_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=add_reagent_all'>All</A><BR>
					<b>Remove Reagent:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=remove_reagent_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=remove_reagent_all'>All</A><BR>
					<b>Add Mob Animation:</b>
						<A href='byond://?src=\ref[src];action=secretsfun;type=animate_one'>One</A> *
						<A href='byond://?src=\ref[src];action=secretsfun;type=animate_all'>All</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=traitor_all'>Make everyone an Antagonist</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=critterize_all'>Critterize everyone</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=stupify'>Give everyone severe brain damage</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=flipstation'>Set station direction</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=yeolde'>Replace all airlocks with doors</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=woodstation'>Replace all floors and walls with wood</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=ballpit'>Replace all pools with ballpits</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=raiseundead'>Raise all human corpses as undead</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=swaprooms'>Swap station rooms around</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=randomguns'>Give everyone a random firearm</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=timewarp'>Set up a time warp</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=brick_radios'>Completely disable all radios ever</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=airlock_safety'>Disable all airlock's safeties.</A><BR>
				"}
	if (src.level >= LEVEL_ADMIN)
		dat += {"<A href='byond://?src=\ref[src];action=secretsfun;type=sawarms'>Give everyone saws for arms</A><BR>
				<A href='byond://?src=\ref[src];action=secretsfun;type=emag_all_things'>Emag everything</A><BR>
				<A href='byond://?src=\ref[src];action=secretsfun;type=noir'>Noir</A><BR>
				<A href='byond://?src=\ref[src];action=secretsfun;type=the_great_switcharoo'>The Great Switcharoo</A><BR>
				<A href='byond://?src=\ref[src];action=secretsfun;type=fartyparty'>Farty Party All The Time</A><BR>
		"}

	dat += "</div>"

	if (src.level >= LEVEL_ADMIN || (src.level == LEVEL_SA && usr.client.holder.state == 2))
		dat += {"<hr><div class='optionGroup' style='border-color:#92BB78'><b class='title' style='background:#92BB78'>Roleplaying Panel</b>
					<A href='byond://?src=\ref[src];action=secretsfun;type=shakecamera'>Apply camera shake</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=creepifystation'>Creepify station</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=command_report_zalgo'>Command Report (Zalgo)</A><BR>
					<A href='byond://?src=\ref[src];action=secretsfun;type=command_report_void'>Command Report (Void)</A><BR>
				"}

	dat += "</div>"

	usr.Browse(dat, "window=gamepanel")
	return

/datum/admins/proc/restart()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Restart"
	set desc= "Restarts the world"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC

	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		boutput(world, "[SPAN_ALERT("<b>Restarting world!</b>")] [SPAN_NOTICE("Initiated by [admin_key(usr.client, 1)]!")]")
		logTheThing(LOG_ADMIN, usr, "initiated a reboot.")
		logTheThing(LOG_DIARY, usr, "initiated a reboot.", "admin")

		var/ircmsg[] = new()
		ircmsg["key"] = usr.client.key
		ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
		ircmsg["msg"] = "manually restarted the server."
		ircbot.export_async("admin", ircmsg)

		roundManagement.recordEnd(crashed = TRUE)

		sleep(3 SECONDS)
		Reboot_server()

/datum/admins/proc/announce()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Announce"
	set desc="Announce your desires to the world"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if (message)
		if(usr.client.holder.rank != "Coder" && usr.client.holder.rank != "Host")
			message = adminscrub(message,500)
		boutput(world, SPAN_NOTICE("<b>[admin_key(usr.client, 1)] Announces:</b><br>&emsp; [message]"))
		logTheThing(LOG_ADMIN, usr, ": [message]")
		logTheThing(LOG_DIARY, usr, ": [message]", "admin")

/datum/admins/proc/startnow()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	if(!ticker)
		tgui_alert(usr,"Unable to start the game as it is not set up.")
		return
	if(current_state <= GAME_STATE_PREGAME)
		global.game_force_started = TRUE
		current_state = GAME_STATE_SETTING_UP
		logTheThing(LOG_ADMIN, usr, "has started the game.")
		logTheThing(LOG_DIARY, usr, "has started the game.", "admin")
		message_admins(SPAN_INTERNAL("[usr.key] has started the game."))
		return 1
	else
		//tgui_alert(usr,"Game has already started you fucking jerk, stop spamming up the chat :ARGH:") //no, FUCK YOU coder, for making this annoying popup
		boutput(usr,"Game is already started.")
		return 0

/datum/admins/proc/delay_start()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Delay the game start"
	set name="Delay Round Start"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	if (current_state > GAME_STATE_PREGAME)
		return tgui_alert(usr,"Too late... The game has already started!")
	game_start_delayed = !(game_start_delayed)

	if (game_start_delayed)
		boutput(world, "<b>The game start has been delayed.</b>")
		logTheThing(LOG_ADMIN, usr, "delayed the game start.")
		logTheThing(LOG_DIARY, usr, "delayed the game start.", "admin")
		message_admins(SPAN_INTERNAL("[usr.key] has delayed the game start."))
	else
		boutput(world, "<b>The game will start soon.</b>")
		logTheThing(LOG_ADMIN, usr, "removed the game start delay.")
		logTheThing(LOG_DIARY, usr, "removed the game start delay.", "admin")
		message_admins(SPAN_INTERNAL("[usr.key] has removed the game start delay."))

/datum/admins/proc/delay_end()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Delay the server restart"
	set name="Delay Round End"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	// If the game end is delayed AT ALL, confirm removing the delay
	// so that mutiple admins don't end up cancelling their own delays
	if (game_end_delayed)
		if (alert(usr, "The restart was delayed by [game_end_delayer]. Remove delay?", "Hold up, pardner", "Remove delay", "Cancel") != "Remove delay")
			return

	if (game_end_delayed == 2)
		logTheThing(LOG_ADMIN, usr, "removed the restart delay and triggered an immediate restart.")
		logTheThing(LOG_DIARY, usr, "removed the restart delay and triggered an immediate restart.", "admin")
		message_admins(SPAN_INTERNAL("[usr.key] removed the restart delay and triggered an immediate restart."))
		ircbot.event("roundend")
		Reboot_server()

	else if (game_end_delayed == 0)
		game_end_delayed = 1
		game_end_delayer = usr.key
		logTheThing(LOG_ADMIN, usr, "delayed the server restart.")
		logTheThing(LOG_DIARY, usr, "delayed the server restart.", "admin")
		message_admins(SPAN_INTERNAL("[usr.key] delayed the server restart."))

		var/ircmsg[] = new()
		ircmsg["key"] = (usr?.client) ? usr.client.key : "NULL"
		ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
		ircmsg["msg"] = "has delayed the server restart."
		ircbot.export_async("admin", ircmsg)

	else if (game_end_delayed == 1)
		game_end_delayed = 0
		game_end_delayer = null
		logTheThing(LOG_ADMIN, usr, "removed the restart delay.")
		logTheThing(LOG_DIARY, usr, "removed the restart delay.", "admin")
		message_admins(SPAN_INTERNAL("[usr.key] removed the restart delay."))

		var/ircmsg[] = new()
		ircmsg["key"] = (usr?.client) ? usr.client.key : "NULL"
		ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
		ircmsg["msg"] = "has removed the server restart delay."
		ircbot.export_async("admin", ircmsg)

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS
/proc/get_matches_string(var/text, var/list/possibles)
	var/list/matches = new()
	for (var/possible in possibles)
		if (findtext(possible, text))
			matches += possible

	return matches

/proc/get_one_match_string(var/text, var/list/possibles)
	var/list/matches = get_matches_string(text, possibles)
	if (length(matches) == 0)
		return null
	var/chosen
	if (length(matches) == 1)
		chosen = matches[1]
	else
		chosen = input("Select a match", "matches for pattern", null) as null|anything in matches
		if (!chosen)
			return null

	return chosen

/proc/get_matches(var/object, var/base = /atom, use_concrete_types=TRUE, only_admin_spawnable=TRUE)
	var/list/types
	if(use_concrete_types)
		types = concrete_typesof(base)
	else
		types = childrentypesof(base)

	var/list/matches = new()

	for(var/path in types)
		if(only_admin_spawnable)
			var/typeinfo/atom/typeinfo = get_type_typeinfo(path)
			if(!typeinfo.admin_spawnable)
				continue
		if(findtext("[path]$", object))
			matches += "[path]"

	. = matches

/**
 * `get_one_match` attempts to find a type match for a given object.
 * The function allows customization of the base type, whether to use concrete types,
 * whether to use only admin spawnable, the comparison procedure, and the sort limit.
 * The function sorts the matches if a comparison procedure is provided and if the sort limit condition allows it,
 * then it presents a list of matches for the user to choose from.
 *
 * @param object This is the object for which the function is attempting to find a match.
 *
 * @param base This is the base type used for matching. All results will be of this type tree.
 *
 * @param use_concrete_types determines whether the function should respect concrete types for matching.
 *
 * @param only_admin_spawnable This boolean value determines whether the function should only consider objects that
 *		are spawnable by an admin.
 *
 * @param cmp_proc This is the comparison proc used for sorting matches. This should be a proc that takes two arguments
 *		and returns a boolean. The default value is `null`, indicating no comparison procedure is used.
 *		If `cmp_proc` is provided and the number of matches is within the `sort_limit`, the matches will be sorted using `cmp_proc`.
 *
 * @param sort_limit This parameter defines the upper limit for the number of items to consider during the matching process.
 *		If the number of matches exceeds `sort_limit`, they will not be sorted even if `cmp_proc` is provided.
 *		If `sort_limit` is `0` or `null`, there will be no limit and matches will be sorted if `cmp_proc` is provided.
 *
 * @return Returns the path of the selected match if one is chosen. If no matches are found, `null` is returned. If the operation is cancelled, `FALSE` is returned.
 */
/proc/get_one_match(var/object, var/base = /atom, use_concrete_types=TRUE, only_admin_spawnable=TRUE, cmp_proc=null, sort_limit=300)
	var/list/matches = get_matches(object, base, use_concrete_types, only_admin_spawnable)

	if(!length(matches))
		return null
	if(length(matches) == 1)
		return text2path(matches[1])

	var/prefix = get_longest_common_prefix(matches)
	if(length(prefix))
		if(prefix in matches)
			var/last_slash = findlasttext(prefix, "/")
			prefix = copytext(prefix, 1, last_slash + 1)
		strip_prefix_from_list(matches, prefix)
	else
		prefix = null

	var/safe_matches = matches - list("/database", "/client", "/icon", "/sound", "/savefile")
	var/msg = "Select \a [base] type."
	if(prefix)
		msg += " Prefix: [replacetext(prefix, "/", "/\u2060")]" // zero width space for breaking this nicely in tgui
	if(cmp_proc && (!sort_limit || (length(safe_matches) <= sort_limit)))
		sortList(safe_matches, cmp_proc)
	. = tgui_input_list(usr, msg, "Matches for pattern", safe_matches, capitalize=FALSE)
	if(!.)
		return FALSE // need to return something other than null to distinguish between "didn't find anything" and hitting 'cancel'
	. = text2path(prefix + .)

/datum/admins/proc/spawn_atom(var/object as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set desc="(atom path) Spawn an atom"
	set name="Spawn"
	if(!object)
		return

	var/client/client = usr.client

	if (client.holder.level >= LEVEL_PA)
		var/chosen = get_one_match(object, use_concrete_types = FALSE)

		if (chosen)
			if (ispath(chosen, /turf))
				var/turf/location = get_turf(usr)
				if (location)
					location.ReplaceWith(chosen, handle_air = 0)
			else
				var/atom/movable/A
				if (client.holder.spawn_in_loc)
					A = new chosen(usr.loc)
				else
					A = new chosen(get_turf(usr))
				if(isobj(A))
					var/obj/O = A
					O.initialize(TRUE)
				if (client.flourish)
					spawn_animation1(A)
			logTheThing(LOG_ADMIN, usr, "spawned [chosen] at ([log_loc(usr)])")
			logTheThing(LOG_DIARY, usr, "spawned [chosen] at ([showCoords(usr.x, usr.y, usr.z, 1)])", "admin")

	else
		tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
		return

/datum/admins/proc/spawn_figurine(var/figurine as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set desc="Spawn a figurine"
	set name="Spawn-Figurine"
	if(!figurine)
		return

	var/client/client = usr.client

	if (client.holder.level >= LEVEL_PA)
		var/chosen = get_one_match(figurine, /datum/figure_info)

		if (chosen)
			var/atom/movable/A
			if (client.holder.spawn_in_loc)
				A = new /obj/item/toy/figure(usr.loc, new chosen)
			else
				A = new /obj/item/toy/figure(get_turf(usr), new chosen)
			if (client.flourish)
				spawn_animation1(A)
			logTheThing(LOG_ADMIN, usr, "spawned figurine [chosen] at ([log_loc(usr)])")
			logTheThing(LOG_DIARY, usr, "spawned figurine [chosen] at ([showCoords(usr.x, usr.y, usr.z, 1)])", "admin")

	else
		tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
		return

/datum/admins/proc/heavenly_spawn_obj(var/obj/object as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set desc="(object path) Spawn an object. But all fancy-like"
	set name="Spawn-Heavenly"
	if(!object)
		return
	if (usr.client.holder.level >= LEVEL_PA)
		var/chosen = get_one_match(object)

		if (chosen)
			var/obj/A = new chosen()
			var/turf/T = get_turf(usr)
			A.set_loc(T)
			heavenly_spawn(A)
			logTheThing(LOG_ADMIN, usr, "spawned [chosen] at ([log_loc(T)])")
			logTheThing(LOG_DIARY, usr, "spawned [chosen] at ([showCoords(T.x, T.y, T.z, 1)])", "admin")

	else
		tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
		return

/datum/admins/proc/supplydrop_spawn_obj(var/obj/object as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set desc="(object path) Spawn an object. But all fancy-like"
	set name="Spawn-Supplydrop"
	if(!object)
		return
	if (usr.client.holder.level >= LEVEL_PA)
		var/chosen = get_one_match(object)
		var/preDropTime = 3 SECONDS

		if (chosen)
			var/turf/T = get_turf(usr)
			new/obj/effect/supplymarker/safe(T, preDropTime, chosen)
			logTheThing(LOG_ADMIN, usr, "spawned [chosen] at ([log_loc(T)])")
			logTheThing(LOG_DIARY, usr, "spawned [chosen] at ([showCoords(T.x, T.y, T.z, 1)])", "admin")

	else
		tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
		return

/datum/admins/proc/demonically_spawn_obj(var/obj/object as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set desc="(object path) Spawn an object. But all fancy-like"
	set name="Spawn-Demonically"
	if(!object)
		return
	if (usr.client.holder.level >= LEVEL_PA)
		var/chosen = get_one_match(object)

		if (chosen)
			var/obj/A = new chosen()
			var/turf/T = get_turf(usr)
			A.set_loc(T)
			demonic_spawn(A)
			logTheThing(LOG_ADMIN, usr, "spawned [chosen] at ([log_loc(T)])")
			logTheThing(LOG_DIARY, usr, "spawned [chosen] at ([showCoords(T.x, T.y, T.z, 1)])", "admin")

	else
		tgui_alert(usr,"You cannot perform this action. You must be of a higher administrative rank!")
		return

/datum/admins/proc/show_chatbans(var/client/C)//do not use this as an example of how to write DM please.
	var/built = {"<title>Chat Bans (todo: prettify)</title>"}
	if(C.player.cloudSaves.getData( "adminhelp_banner" ))
		built += "<a href='byond://?src=\ref[src];target=\ref[C];action=ah_unmute' class='alert'>Adminhelp Mute</a> (Last by [C.player.cloudSaves.getData( "adminhelp_banner" )])<br/>"
		logTheThing(LOG_ADMIN, src, "unmuted [constructTarget(C,"admin")] from adminhelping.")
	else
		built += "<a href='byond://?src=\ref[src];target=\ref[C];action=ah_mute'>Adminhelp Mute</a><br/>"
		logTheThing(LOG_ADMIN, src, "muted [constructTarget(C,"admin")] from adminhelping.")

	if(C.player.cloudSaves.getData( "mentorhelp_banner" ))
		built += "<a href='byond://?src=\ref[src];target=\ref[C];action=mh_unmute' class='alert'>Mentorhelp Mute</a> (Last by [C.player.cloudSaves.getData( "mentorhelp_banner" )])<br/>"
		logTheThing(LOG_ADMIN, src, "unmuted [constructTarget(C,"admin")] from mentorhelping.")
	else
		built += "<a href='byond://?src=\ref[src];target=\ref[C];action=mh_mute'>Mentorhelp Mute</a><br/>"
		logTheThing(LOG_ADMIN, src, "muted [constructTarget(C,"admin")] from mentorhelping.")

	if(C.player.cloudSaves.getData( "prayer_banner" ))
		built += "<a href='byond://?src=\ref[src];target=\ref[C];action=pr_unmute' class='alert'>Prayer Mute</a> (Last by [C.player.cloudSaves.getData( "prayer_banner" )])<br/>"
		logTheThing(LOG_ADMIN, src, "unmuted [constructTarget(C,"admin")] from praying.")
	else
		built += "<a href='byond://?src=\ref[src];target=\ref[C];action=pr_mute'>Prayer Mute</a><br/>"
		logTheThing(LOG_ADMIN, src, "muted [constructTarget(C,"admin")] from praying.")

	usr.Browse(built, "window=chatban;size=500x100")

/client/proc/cmd_admin_managebioeffect(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Manage Bioeffects"
	set desc = "Select a mob to manage its bioeffects."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (isnull(holder.bioeffectmanager))
		holder.bioeffectmanager = new
	holder.bioeffectmanager.target_mob = M
	holder.bioeffectmanager.ui_interact(src.mob)

/client/proc/cmd_admin_manageabils(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Manage Abilities"
	set desc = "Select a mob to manage its abilities."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (isnull(holder.abilitymanager))
		holder.abilitymanager = new
	holder.abilitymanager.target_mob = M
	holder.abilitymanager.ui_interact(src.mob)

/client/proc/cmd_admin_managetraits(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Manage Traits"
	set desc = "Select a mob to manage its traits."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC
	var/list/dat = list()
	dat += {"
		<html>
		<head>
		<title>Trait Management Panel</title>
		<style>
		table {
			border:1px solid #44aaff;
			border-collapse: collapse;
			width: 100%;
		}

		td {
			padding: 8px;
			text-align: left;
		}

		th {
			background-color: #44aaff;
			color: white;
			padding: 8px;
			text-align: left;
		}

		th:nth-child(4), td:nth-child(4) {text-align: center;}
		tr:nth-child(odd) {background-color: #f2f2f2;}
		tr:hover {background-color: #e2e2e2;}


		.button {
			padding: 6px 12px;
			text-align: center;
			float: right;
			display: inline-block;
			font-size: 12px;
			margin: 0px 2px;
			cursor: pointer;
			color: white;
			border: 2px solid #008CBA;
			background-color: #008CBA;
			text-decoration: none;
		}
		</style>
		</head>
		<body>
		<h1>
			Traits of [M.name]
			<a href='byond://?src=\ref[src.holder];action=managetraits;target=\ref[M];origin=managetraits' class="button">&#x1F504;</a>
			<a href='byond://?src=\ref[src.holder];action=addtrait;target=\ref[M];origin=managetraits' class="button">&#x2795;</a>
		</h1>
		<table>
			<tr>
				<th>Remove</th>
				<th>Name</th>
				<th>Type Path</th>
			</tr>
		"}

	if (!M.traitHolder)
		return
	var/list/traits = list()
	for(var/trait in M.traitHolder.traits)
		var/datum/trait/trait_obj = M.traitHolder.traits[trait]
		traits.Add(trait_obj)

	for (var/datum/trait/trait as anything in traits)
		dat += {"
			<tr>
				<td><a href='byond://?src=\ref[src.holder];action=managetraits_remove;target=\ref[M];trait=\ref[trait];origin=managetraits'>remove</a></td>
				<td><a href='byond://?src=\ref[src.holder];action=managetraits_debug_vars;trait=\ref[trait];origin=managetraits'>[trait.name]</a></td>
				<td>[trait.type]
			</tr>"}
	dat += "</table></body></html>"
	usr.Browse(dat.Join(),"window=managetraits;size=700x400")

//completely copy pasted from above, in the finest traditions of this mess
/client/proc/cmd_admin_manageobjectives(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Manage Objectives"
	set desc = "Select a mob to manage its mind's objectives."
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/list/dat = list()
	dat += {"
		<html>
		<head>
		<title>Objective Management Panel</title>
		<style>
		table {
			border:1px solid #44aaff;
			border-collapse: collapse;
			width: 100%;
		}

		td {
			padding: 8px;
			text-align: left;
		}

		th {
			background-color: #44aaff;
			color: white;
			padding: 8px;
			text-align: left;
		}

		th:nth-child(4), td:nth-child(4) {text-align: center;}
		tr:nth-child(odd) {background-color: #f2f2f2;}
		tr:hover {background-color: #e2e2e2;}


		.button {
			padding: 6px 12px;
			text-align: center;
			float: right;
			display: inline-block;
			font-size: 12px;
			margin: 0px 2px;
			cursor: pointer;
			color: white;
			border: 2px solid #008CBA;
			background-color: #008CBA;
			text-decoration: none;
		}
		</style>
		</head>
		<body>
		<h1>
			Objectives of [M.name]
			<a href='byond://?src=\ref[src.holder];action=manageobjectives;target=\ref[M];origin=manageobjectives' class="button">&#x1F504;</a>
			<a href='byond://?src=\ref[src.holder];action=addobjective;target=\ref[M];origin=manageobjectives' class="button">&#x2795;</a>
		</h1>
		<table>
			<tr>
				<th>Remove</th>
				<th>Text</th>
				<th>Type Path</th>
			</tr>
		"}
	if (!M.mind)
		return

	for (var/datum/objective/objective as anything in M.mind.objectives)
		dat += {"
			<tr>
				<td><a href='byond://?src=\ref[src.holder];action=manageobjectives_remove;target=\ref[M];objective=\ref[objective];origin=manageobjectives'>remove</a></td>
				<td><a href='byond://?src=\ref[src.holder];action=manageobjectives_debug_vars;objective=\ref[objective];origin=manageobjectives'>[objective.explanation_text]</a></td>
				<td>[objective.type]
			</tr>"}
	dat += "</table></body></html>"
	usr.Browse(dat.Join(),"window=manageobjectives;size=700x400")

/client/proc/respawn_target(mob/M as mob in world, var/forced = 0)
	set name = "Respawn Target"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "Respawn a mob"
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC
	if (!M) return

	if (!forced && tgui_alert(src, "Respawn [M]?", "Confirmation", list("Yes", "No")) != "Yes")
		return

	logTheThing(LOG_ADMIN, src, "respawned [constructTarget(M,"admin")]")
	logTheThing(LOG_DIARY, src, "respawned [constructTarget(M,"diary")].", "admin")
	message_admins("[key_name(src)] respawned [key_name(M)].")

	var/mob/new_player/newM = new()
	newM.adminspawned = 1

	if (M.mind)
		M.mind.damned = 0
		M.mind.transfer_to(newM)
	else
		newM.key = M.key
	M.mind = null
	newM.sight = SEE_TURFS //otherwise the HUD remains in the login screen
	qdel(M)

	boutput(newM, "<b>You have been respawned.</b>")
	return newM

/client/proc/respawn_self()
	set name = "Respawn Self"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Respawn yourself"
	ADMIN_ONLY
	SHOW_VERB_DESC
	logTheThing(LOG_ADMIN, src, "respawned themselves.")
	logTheThing(LOG_DIARY, src, "respawned themselves.", "admin")
	message_admins("[key_name(src)] respawned themselves.")

	var/mob/new_player/M = new()

	M.key = usr.client.key

	usr.remove()

// Handling noclip logic
/client/Move(NewLoc, direct)
	if(usr.client.flying || (ismob(usr) && HAS_ATOM_PROPERTY(usr, PROP_MOB_NOCLIP)))
		if(isnull(NewLoc))
			return

		if(!isturf(usr.loc))
			usr.set_loc(get_turf(usr))

		if(NewLoc)
			usr.set_loc(NewLoc)
			src.mob.set_dir(direct)
			return

		if((direct & NORTH) && usr.y < world.maxy)
			usr.y++
		if((direct & SOUTH) && usr.y > 1)
			usr.y--
		if((direct & EAST) && usr.x < world.maxx)
			usr.x++
		if((direct & WEST) && usr.x > 1)
			usr.x--

		src.mob.set_dir(direct)
	else
		..()

#undef INCLUDE_ANTAGS
#undef STRIP_ANTAG
