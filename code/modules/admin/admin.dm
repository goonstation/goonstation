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
var/global/player_audio_players = TRUE // Whether Record Players and Tape Decks should be available or not.

////////////////////////////////
/proc/message_admins(var/text, var/asay = 0, var/irc = 0)
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">[irc ? "DISCORD:" : "ADMIN LOG:"]</span> <span class=\"message\">[text]</span></span>"
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
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">CODER LOG:</span> <span class=\"message\">[text]</span></span>"
	for (var/client/C)
		if (C.mob && C.holder && rank_to_level(C.holder.rank) >= LEVEL_CODER) //This is for edge cases where a coder needs a goddamn notification when it happens
			boutput(C.mob, replacetext(rendered, "%admin_ref%", "\ref[C.holder]"))

/proc/message_coders_vardbg(var/text, var/datum/d)
	var/rendered
	for (var/client/C)
		if (C.mob && C.holder && rank_to_level(C.holder.rank) >= LEVEL_CODER)
			var/dbg_html = C.debug_variable("", d, 0)
			rendered = "<span class=\"admin\"><span class=\"prefix\">CODER LOG:</span> <span class=\"message\">[text]</span>[dbg_html]</span>"
			boutput(C.mob, replacetext(rendered, "%admin_ref%", "\ref[C.holder]"))

/proc/message_attack(var/text) //Sends a message to folks when an attack goes down
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ATTACK LOG:</span> <span class=\"message\">[text]</span></span>"
	for (var/client/C)
		if (C.mob && C.holder && C.holder.attacktoggle && !C.player_mode && rank_to_level(C.holder.rank) >= LEVEL_MOD)
			boutput(C.mob, replacetext(rendered, "%admin_ref%", "\ref[C.holder]"))

/proc/rank_to_level(var/rank)
	var/level = 0
	switch(rank)
		if("Host")
			level = LEVEL_HOST
		if("Coder")
			level = LEVEL_CODER
		if("Administrator")
			level = LEVEL_ADMIN
		if("Primary Administrator")
			level = LEVEL_PA
		if("Intermediate Administrator")
			level = LEVEL_IA
		if("Secondary Administrator")
			level = LEVEL_SA
		if("Moderator")
			level = LEVEL_MOD
		if("Goat Fart", "Ayn Rand's Armpit")
			level = LEVEL_BABBY
	return level

/proc/level_to_rank(var/level)
	var/rank = "ERROR"
	switch(level)
		if(LEVEL_HOST)
			rank = "Host"
		if(LEVEL_CODER)
			rank = "Coder"
		if(LEVEL_ADMIN)
			rank = "Administrator"
		if(LEVEL_PA)
			rank = "Primary Administrator"
		if(LEVEL_IA)
			rank = "Intermediate Administrator"
		if(LEVEL_SA)
			rank = "Secondary Administrator"
		if(LEVEL_MOD)
			rank = "Moderator"
		if(LEVEL_BABBY)
			rank = "Goat Fart or Ayn Rand's Armpit"
	return rank

/datum/admins/Topic(href, href_list)
	..()

	if (src.level < 0)
		tgui_alert(usr,"UM, EXCUSE ME??  YOU AREN'T AN ADMIN, GET DOWN FROM THERE!")
		usr << csound('sound/voice/farts/poo2.ogg')
		return

	if (usr.client != src.owner)
		message_admins("<span class='internal'>[key_name(usr)] has attempted to override the admin panel!</span>")
		logTheThing(LOG_ADMIN, usr, "tried to use the admin panel without authorization.")
		logTheThing(LOG_DIARY, usr, "tried to use the admin panel without authorization.", "admin")
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
					C.cloud_put("adminhelp_banner", usr.client.key)
					src.show_chatbans(C)
		if ("ah_unmute")//guHGUHGUGHGUHG
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.cloud_put("adminhelp_banner", "")
					src.show_chatbans(C)
		if ("mh_mute")//AHDUASHDUHWUDHWDUHWDUWDH
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.cloud_put("mentorhelp_banner", usr.client.key)
					src.show_chatbans(C)
		if ("mh_unmute")//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.cloud_put("mentorhelp_banner", "")
					src.show_chatbans(C)
		if ("pr_mute")
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.cloud_put("prayer_banner", usr.client.key)
					src.show_chatbans(C)
		if ("pr_unmute")
			if (src.level >= LEVEL_PA)
				var/client/C = locate(href_list["target"])
				if(istype(C))
					C.cloud_put("prayer_banner", "")
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
		if ("toggle_popup_verbs")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_popup_verbs()
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
		if ("toggle_auto_stealth")
			if (src.level >= LEVEL_SA)
				src.auto_stealth = !(src.auto_stealth)
				boutput(usr, "<span class='notice'>Auto Stealth [src.auto_stealth ? "enabled" : "disabled"].</span>")
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
							boutput(usr, "<span class='notice'>Auto Stealth name removed.</span>")
							return src.show_pref_window(usr)
						if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", list("OK", "Cancel")) == "OK")
							src.auto_stealth_name = new_key
							src.set_stealth_mode(src.auto_stealth_name)
						else
							src.auto_stealth_name = null
							boutput(usr, "<span class='notice'>Auto Stealth name removed.</span>")
							return src.show_pref_window(usr)
				src.show_pref_window(usr)
		if ("set_auto_stealth_name")
			if (src.level >= LEVEL_SA)
				var/new_key = input("Enter your desired display name.", "Fake Key", usr.client.key) as null|text
				if (!new_key)
					src.auto_stealth_name = null
					boutput(usr, "<span class='notice'>Auto Stealth name removed.</span>")
					return
				if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", list("OK", "Cancel")) == "OK")
					src.auto_stealth_name = new_key
					src.show_pref_window(usr)
				else
					src.auto_stealth_name = null
					boutput(usr, "<span class='notice'>Auto Stealth name removed.</span>")
					return
		if ("toggle_auto_alt_key")
			if (src.level >= LEVEL_SA)
				src.auto_alt_key = !(src.auto_alt_key)
				boutput(usr, "<span class='hint'>Auto Alt Key [src.auto_alt_key ? "enabled" : "disabled"].</span>")
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
							boutput(usr, "<span class='hint'>Auto Alt Key removed.</span>")
							return src.show_pref_window(usr)
						if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", list("OK", "Cancel")) == "OK")
							src.auto_alt_key_name = new_key
							src.set_alt_key(src.auto_alt_key_name)
						else
							src.auto_alt_key_name = null
							boutput(usr, "<span class='hint'>Auto Alt Key removed.</span>")
							return src.show_pref_window(usr)
				src.show_pref_window(usr)
		if ("set_auto_alt_key_name")
			if (src.level >= LEVEL_SA)
				var/new_key = input("Enter your desired display name.", "Alt Key", usr.client.key) as null|text
				if (!new_key)
					src.auto_alt_key_name = null
					boutput(usr, "<span class='notice'>Auto Alt Key removed.</span>")
					return
				if (tgui_alert(usr,"Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", list("OK", "Cancel")) == "OK")
					src.auto_alt_key_name = new_key
					src.show_pref_window(usr)
				else
					src.auto_alt_key_name = null
					boutput(usr, "<span class='notice'>Auto Alt Key removed.</span>")
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
							command_announcement(call_reason + "<br><b><span class='alert'>It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</span></b>", "The Emergency Shuttle Has Been Called", css_class = "notice")
							logTheThing(LOG_ADMIN, usr,  "called the Emergency Shuttle (reason: [call_reason])")
							logTheThing(LOG_DIARY, usr, "called the Emergency Shuttle (reason: [call_reason])", "admin")
							message_admins("<span class='internal'>[key_name(usr)] called the Emergency Shuttle to the station.</span>")

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
									command_announcement(call_reason + "<br><b><span class='alert'>It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</span></b>", "The Emergency Shuttle Has Been Called", css_class = "notice")
									logTheThing(LOG_ADMIN, usr, "called the Emergency Shuttle (reason: [call_reason])")
									logTheThing(LOG_DIARY, usr, "called the Emergency Shuttle (reason: [call_reason])", "admin")
									message_admins("<span class='internal'>[key_name(usr)] called the Emergency Shuttle to the station</span>")
							if(1)
								emergency_shuttle.recall()
								boutput(world, "<span class='notice'><B>Alert: The shuttle is going back!</B></span>")
								logTheThing(LOG_ADMIN, usr, "sent the Emergency Shuttle back")
								logTheThing(LOG_DIARY, usr, "sent the Emergency Shuttle back", "admin")
								message_admins("<span class='internal'>[key_name(usr)] recalled the Emergency Shuttle</span>")
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
				message_admins("<span class='internal'>[key_name(usr)] edited the Emergency Shuttle's timeleft to [timeleft]</span>")
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
				message_admins("<span class='internal'>[key_name(usr)] [emergency_shuttle.can_recall ? "en" : "dis"]abled recalling the Emergency Shuttle</span>")
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to enable/disable shuttle recalling.")

		if("radio_audio_toggle")
			if(src.level >= LEVEL_MOD)

				switch (player_audio_players)
					if (FALSE)
						for(var/obj/submachine/record_player/O in by_type[/obj/submachine/record_player])
							for(var/mob/living/M in oview(5, O)) // An indicator for the players to know that the player is enabled.
								boutput(M, "<span class='alert'>A glowing hand appears out of nowhere and rips \"out of order\" sticker on \the [O.name]!</span>")
							O.can_play_music = TRUE

						for(var/obj/submachine/tape_deck/O in by_type[/obj/submachine/tape_deck])
							for(var/mob/living/M in oview(5, O)) // An indicator for the players to know that the player is enabled.
								boutput(M, "<span class='alert'>A glowing hand appears out of nowhere and rips the \"out of order\" sticker on \the [O.name]!</span>")
							O.can_play_tapes = TRUE

						player_audio_players = FALSE
						logTheThing(LOG_DIARY, usr, null, "allowed for radio music/tapes to play.")
						logTheThing(LOG_ADMIN, usr, null, "allowed for radio music/tapes to play.")
					if (TRUE)
						for(var/obj/submachine/record_player/O in by_type[/obj/submachine/record_player])
							for(var/mob/living/M in oview(5, O)) // An indicator for the players to know that the player is disabled.
								boutput(M, "<span class='alert'>A glowing hand appears out of nowhere and slaps a \"out of order\" sticker on \the [O.name]!</span>")
							O.can_play_music = FALSE

						for(var/obj/submachine/tape_deck/O in by_type[/obj/submachine/tape_deck])
							for(var/mob/living/M in oview(5, O)) // An indicator for the players to know that the player is disabled.
								boutput(M, "<span class='alert'>A glowing hand appears out of nowhere and slaps a \"out of order\" sticker on \the [O.name]!</span>")
							O.can_play_tapes = FALSE

						player_audio_players = TRUE
						logTheThing(LOG_DIARY, usr, null, "disallowed for radio music/tapes to play.")
						logTheThing(LOG_ADMIN, usr, null, "disallowed for radio music/tapes to play.")
			else
				tgui_alert(usr,"You need to be at least a Moderator to disallow radio audio.")

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
							message_admins("<span class='internal'>[key_name(usr)] deleted note [noteId] belonging to <A href='?src=%admin_ref%;action=notes&target=[player]'>[player]</A>.</span>")

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
					message_admins("<span class='internal'>[key_name(usr)] added a note for <A href='?src=%admin_ref%;action=notes&target=[player]'>[player]</A>: [the_note]</span>")

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
				tgui_alert(usr,"You need to be an actual admin to view compIDs.")
				return

			view_client_compid_list(usr, player)

			return

		/////////////////////////////////////ban stuff
		if ("addban") //Add ban
			var/mob/M = (href_list["target"] ? locate(href_list["target"]) : null)
			usr.client.addBanDialog(M)

		if ("sharkban") //Add ban
			var/mob/M = (href_list["target"] ? locate(href_list["target"]) : null)
			usr.client.sharkban(M)

		if("unbane") //Edit ban
			if (src.level >= LEVEL_SA)
				var/id = html_decode(href_list["id"])
				var/ckey = html_decode(href_list["target"])
				var/compID = html_decode(href_list["compID"])
				var/ip = html_decode(href_list["ip"])
				var/reason = html_decode(href_list["reason"])
				var/timestamp = html_decode(href_list["timestamp"])

				usr.client.editBanDialog(id, ckey, compID, ip, reason, timestamp)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to edit bans.")

		if("unbanf") //Delete ban
			if (src.level >= LEVEL_SA)
				var/id = html_decode(href_list["id"])
				var/ckey = html_decode(href_list["target"])
				var/compID = html_decode(href_list["compID"])
				var/ip = html_decode(href_list["ip"])
				var/akey = usr.client.ckey

				usr.client.deleteBanDialog(id, ckey, compID, ip, akey)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to remove bans.")
		/////////////////////////////////////end ban stuff

		if("jobbanpanel")
			var/dat = ""
			var/header = "<b>Pick Job to ban this guy from | <a href='?src=\ref[src];action=jobbanpanel;target=[href_list["target"]]'>Refresh</a><br>"
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
				M = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M), 1)[M]
			if (!M)
				return

			//Determine which system we're using.

			for(var/job in uniquelist(occupations))
				if(job in list("Tourist","Mining Supervisor","Atmospheric Technician","Vice Officer"))
					continue
				if(jobban_isbanned(M, job))
					jobs += "<a href='?src=\ref[src];action=[action];type=[job];target=[target]'><font color=red>[replacetext(job, " ", "&nbsp")]</font></a> "
				else
					jobs += "<a href='?src=\ref[src];action=[action];type=[job];target=[target]'>[replacetext(job, " ", "&nbsp")]</a> " //why doesn't this work

			if(jobban_isbanned(M, "Captain"))
				jobs += "<a href='?src=\ref[src];action=[action];type=Captain;target=[target]'><font color=red>Captain</font></a> "
			else
				jobs += "<a href='?src=\ref[src];action=[action];type=Captain;target=[target]'>Captain</a> " //why doesn't this work

			if(jobban_isbanned(M, "Head of Security"))
				jobs += "<a href='?src=\ref[src];action=[action];type=Head of Security;target=[target]'><font color=red>Head of Security</font></a> "
			else
				jobs += "<a href='?src=\ref[src];action=[action];type=Head of Security;target=[target]'>Head of Security</a> "

			if(jobban_isbanned(M, "Syndicate"))
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Syndicate;target=[target]'><font color=red>[replacetext("Syndicate", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Syndicate;target=[target]'>[replacetext("Syndicate", " ", "&nbsp")]</a> " //why doesn't this work

			if(jobban_isbanned(M, "Special Respawn"))
				jobs += " <a href='?src=\ref[src];action=[action];type=Special Respawn;target=[target]'><font color=red>[replacetext("Special Respawn", " ", "&nbsp")]</font></a> "
			else
				jobs += " <a href='?src=\ref[src];action=[action];type=Special Respawn;target=[target]'>[replacetext("Special Respawn", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Engineering Department"))
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Engineering Department;target=[target]'><font color=red>[replacetext("Engineering Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Engineering Department;target=[target]'>[replacetext("Engineering Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Security Department"))
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Security Department;target=[target]'><font color=red>[replacetext("Security Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Security Department;target=[target]'>[replacetext("Security Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Heads of Staff"))
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Heads of Staff;target=[target]'><font color=red>[replacetext("Heads of Staff", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Heads of Staff;target=[target]'>[replacetext("Heads of Staff", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Everything Except Assistant"))
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Everything Except Assistant;target=[target]'><font color=red>[replacetext("Everything Except Assistant", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Everything Except Assistant;target=[target]'>[replacetext("Everything Except Assistant", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Ghostdrone"))
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Ghostdrone;target=[target]'><font color=red>Ghostdrone</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Ghostdrone;target=[target]'>Ghostdrone</a> "

			if(jobban_isbanned(M, "Custom Names"))
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Custom Names;target=[target]'><font color=red>[replacetext("Having a Custom Name", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=[action];type=Custom Names;target=[target]'>[replacetext("Having a Custom Name", " ", "&nbsp")]</a> "


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
					if(job in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
						if(player.cached_jobbans.Find("Engineering Department"))
							tgui_alert(usr,"This person is banned from Engineering Department. You must lift that ban first.")
							return
					if(job in list("Security Officer","Security Assistant","Vice Officer","Part-time Vice Officer","Detective"))
						if(player.cached_jobbans.Find("Security Department"))
							tgui_alert(usr,"This person is banned from Security Department. You must lift that ban first.")
							return
					if(job in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
						if(player.cached_jobbans.Find("Heads of Staff"))
							tgui_alert(usr,"This person is banned from Heads of Staff. You must lift that ban first.")
							return
					logTheThing(LOG_ADMIN, usr, "unbanned [constructTarget(M,"admin")] from [job]")
					logTheThing(LOG_DIARY, usr, "unbanned [constructTarget(M,"diary")] from [job]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] unbanned [key_name(M)] from [job]</span>")
					addPlayerNote(M.ckey, usr.ckey, "[usr.ckey] unbanned [M.ckey] from [job]")
					jobban_unban(M, job)
					if (announce_jobbans) boutput(M, "<span class='alert'><b>[key_name(usr)] has lifted your [job] job-ban.</b></span>")
				else
					logTheThing(LOG_ADMIN, usr, "banned [constructTarget(M,"admin")] from [job]")
					logTheThing(LOG_DIARY, usr, "banned [constructTarget(M,"diary")] from [job]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] banned [key_name(M)] from [job]</span>")
					addPlayerNote(M.ckey, usr.ckey, "[usr.ckey] banned [M.ckey] from [job]")
					if(job == "Everything Except Assistant")
						if(player.cached_jobbans.Find("Engineering Department"))
							jobban_unban(M,"Engineering Department")
						if(player.cached_jobbans.Find("Security Department"))
							jobban_unban(M,"Security Department")
						if(player.cached_jobbans.Find("Heads of Staff"))
							jobban_unban(M,"Heads of Staff")
						for(var/Trank1 in uniquelist(occupations))
							if(player.cached_jobbans.Find("[Trank1]"))
								jobban_unban(M,Trank1)
					else if(job == "Engineering Department")
						for(var/Trank2 in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
							if(player.cached_jobbans.Find("[Trank2]"))
								jobban_unban(M,Trank2)
					else if(job == "Security Department")
						for(var/Trank3 in list("Security Officer","Security Assistant","Vice Officer","Part-time Vice Officer","Detective"))
							if(player.cached_jobbans.Find("[Trank3]"))
								jobban_unban(M,Trank3)
					else if(job == "Heads of Staff")
						for(var/Trank4 in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
							if(player.cached_jobbans.Find("[Trank4]"))
								jobban_unban(M,Trank4)
					jobban_fullban(M, job, usr.ckey)
					if (announce_jobbans) boutput(M, "<span class='alert'><b>[key_name(usr)] has job-banned you from [job].</b></span>")
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to work with job bans.")

		if("jobban_offline")
			if (src.level >= LEVEL_SA)
				var/M = href_list["target"]
				var/job = href_list["type"]
				var/list/cache = apiHandler.queryAPI("jobbans/get/player", list("ckey"=M), 1)[M]
				if (!M) return
				if (jobban_isbanned(cache, job))
					if(cache.Find("Everything Except Assistant") && job != "Everything Except Assistant")
						tgui_alert(usr,"This person is banned from Everything Except Assistant. You must lift that ban first.")
						return
					if(job in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
						if(cache.Find("Engineering Department"))
							tgui_alert(usr,"This person is banned from Engineering Department. You must lift that ban first.")
							return
					if(job in list("Security Officer","Security Assistant","Vice Officer","Part-time Vice Officer","Detective"))
						if(cache.Find("Security Department"))
							tgui_alert(usr,"This person is banned from Security Department. You must lift that ban first.")
							return
					if(job in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
						if(cache.Find("Heads of Staff"))
							tgui_alert(usr,"This person is banned from Heads of Staff. You must lift that ban first.")
							return
					logTheThing(LOG_ADMIN, usr, "unbanned [M](Offline) from [job]")
					logTheThing(LOG_DIARY, usr, "unbanned [M](Offline) from [job]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] unbanned [M](Offline) from [job]</span>")
					addPlayerNote(M, usr.ckey, "[usr.ckey] unbanned [M](Offline) from [job]")
					jobban_unban(M, job)
				else
					logTheThing(LOG_ADMIN, usr, "banned [M](Offline) from [job]")
					logTheThing(LOG_DIARY, usr, "banned [M](Offline) from [job]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] banned [M](Offline) from [job]</span>")
					addPlayerNote(M, usr.ckey, "[usr.ckey] banned [M](Offline) from [job]")
					if(job == "Everything Except Assistant")
						if(cache.Find("Engineering Department"))
							jobban_unban(M,"Engineering Department")
						if(cache.Find("Security Department"))
							jobban_unban(M,"Security Department")
						if(cache.Find("Heads of Staff"))
							jobban_unban(M,"Heads of Staff")
						for(var/Trank1 in uniquelist(occupations))
							if(cache.Find("[Trank1]"))
								jobban_unban(M,Trank1)
					else if(job == "Engineering Department")
						for(var/Trank2 in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
							if(cache.Find("[Trank2]"))
								jobban_unban(M,Trank2)
					else if(job == "Security Department")
						for(var/Trank3 in list("Security Officer","Security Assistant","Vice Officer","Part-time Vice Officer","Detective"))
							if(cache.Find("[Trank3]"))
								jobban_unban(M,Trank3)
					else if(job == "Heads of Staff")
						for(var/Trank4 in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
							if(cache.Find("[Trank4]"))
								jobban_unban(M,Trank4)
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
					message_admins("<span class='internal'>[key_name(usr)] has [(muted ? "permanently muted" : "unmuted")] [key_name(M)].</span>")
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
					message_admins("<span class='internal'>[key_name(usr)] has [(muted ? "temporarily muted" : "unmuted")] [key_name(M)].</span>")
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
					message_admins("<span class='internal'>[key_name(usr)] has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [key_name(M)].</span>")

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
				if (current_state > GAME_STATE_PREGAME)
					cmd = "c_mode_next"
					addltext = " next round"
				var/list/dat = list({"
							<html><body><title>Select Round Mode</title>
							<B>What mode do you wish to play[addltext]?</B><br>
							Current mode is: <i>[master_mode]</i><br>
							Mode is <A href='?src=\ref[src];action=toggle_hide_mode'>[ticker.hide_mode ? "hidden" : "not hidden"]</a><br/>
							<HR>
							<b>Regular Modes:</b><br>
							<A href='?src=\ref[src];action=[cmd];type=secret'>Secret</A><br>
							<A href='?src=\ref[src];action=[cmd];type=action'>Secret: Action</A><br>
							<A href='?src=\ref[src];action=[cmd];type=intrigue'>Secret: Intrigue</A><br>
							<A href='?src=\ref[src];action=[cmd];type=mixed'>Mixed (Action)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=mixed_rp'>Mixed (Mild)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=traitor'>Traitor</A><br>
							<A href='?src=\ref[src];action=[cmd];type=nuclear'>Nuclear Emergency</A><br>
							<A href='?src=\ref[src];action=[cmd];type=wizard'>Wizard</A><br>
							<A href='?src=\ref[src];action=[cmd];type=changeling'>Changeling</A><br>
							<A href='?src=\ref[src];action=[cmd];type=vampire'>Vampire</A><br>
							<A href='?src=\ref[src];action=[cmd];type=blob'>Blob</A><br>
							<A href='?src=\ref[src];action=[cmd];type=conspiracy'>Conspiracy</A><br>
							<A href='?src=\ref[src];action=[cmd];type=spy_theft'>Spy Theft</A><br>
							<A href='?src=\ref[src];action=[cmd];type=arcfiend'>Arcfiend</A><br>
							<b>Other Modes</b><br>
							<A href='?src=\ref[src];action=[cmd];type=extended'>Extended</A><br>
							<A href='?src=\ref[src];action=[cmd];type=flock'>Flock (Beta)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=disaster'>Disaster (Beta)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=spy'>Spy</A><br>
							<A href='?src=\ref[src];action=[cmd];type=revolution'>Revolution</A><br>
							<A href='?src=\ref[src];action=[cmd];type=revolution_extended'>Revolution (no time limit)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=gang'>Gang War (Beta)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=pod_wars'>Pod Wars (Beta)(only works if current map is pod_wars.dmm)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=battle_royale'>Battle Royale</A><br>
							<A href='?src=\ref[src];action=[cmd];type=everyone-is-a-traitor'>Everyone is a traitor</A><br>
							<A href='?src=\ref[src];action=[cmd];type=construction'>Construction (For testing only. Don't select this!)</A><br>
							"})
#if FOOTBALL_MODE
				dat += "<A href='?src=\ref[src];action=[cmd];type=football'>Football</A>"
#endif
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
					boutput(usr, "<span class='alert'><b>You can only set the mode to Pod Wars if the current map is a Pod Wars map!<br>If you want to play Pod Wars, you have to set the next map for compile to be pod_wars.dmm!</b></span>")
					return
#endif
				var/requestedMode = href_list["type"]
				if (requestedMode in global.valid_modes)
					logTheThing(LOG_ADMIN, usr, "set the mode as [requestedMode].")
					logTheThing(LOG_DIARY, usr, "set the mode as [requestedMode].", "admin")
					message_admins("<span class='internal'>[key_name(usr)] set the mode as [requestedMode].</span>")
					world.save_mode(requestedMode)
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
					if (tgui_alert(usr,"Declare mode change to all players?","Mode Change",list("Yes", "No")) == "Yes")
						boutput(world, "<span class='notice'><b>The mode is now: [requestedMode]</b></span>")
				else
					boutput(usr, "<span class='alert'><b>That is not a valid game mode!</b></span>")
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("c_mode_next")
			if (src.level >= LEVEL_SA)
				var/newmode = href_list["type"]
				logTheThing(LOG_ADMIN, usr, "set the next round's mode as [newmode].")
				logTheThing(LOG_DIARY, usr, "set the next round's mode as [newmode].", "admin")
				message_admins("<span class='internal'>[key_name(usr)] set the next round's mode as [newmode].</span>")
				world.save_mode(newmode)
				if (tgui_alert(usr,"Declare mode change to all players?","Mode Change",list("Yes", "No")) == "Yes")
					boutput(world, "<span class='notice'><b>The next round's mode will be: [newmode]</b></span>")
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
					message_admins("<span class='internal'>[key_name(usr)] attempting to monkeyize [key_name(M)]</span>")
					N.monkeyize()
				else
					boutput(usr, "<span class='alert'>You can't transform that mob type into a monkey.</span>")
					return
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to monkeyize players.")

		if ("forcespeech")
			var/mob/M = locate(href_list["target"])
			if (src.level >= LEVEL_PA || isnull(M.client) && src.level >= LEVEL_SA)
				if (ismob(M))
					var/speech = input("What will [M] say?", "Force speech", null) as text
					if(!speech)
						return
					M.say(speech)
					speech = copytext(sanitize(speech), 1, MAX_MESSAGE_LEN)
					logTheThing(LOG_ADMIN, usr, "forced [constructTarget(M,"admin")] to say: [speech]")
					logTheThing(LOG_DIARY, usr, "forced [constructTarget(M,"diary")] to say: [speech]", "admin")
					if(M.client)
						message_admins("<span class='internal'>[key_name(usr)] forced [key_name(M)] to say: [speech]</span>")
			else
				tgui_alert(usr,"You need to be at least a Primary Administrator to force players to say things.")

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
				boutput(M, "<span class='notice'><b>You have been sent to the Thunderdome. You are on [team].</b></span>")
				boutput(M, "<span class='notice'><b>Prepare for combat. If you are not let out of the preparation area within a few minutes, please adminhelp. (F1 key)</b></span>")

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
						M.revive()
						message_admins("<span class='alert'>Admin [key_name(usr)] healed / revived [key_name(M)]!</span>")
						logTheThing(LOG_ADMIN, usr, "healed / revived [constructTarget(M,"admin")]")
						logTheThing(LOG_DIARY, usr, "healed / revived [constructTarget(M,"diary")]", "admin")
					else
						tgui_alert(usr,"Reviving is currently disabled.")
			else
				tgui_alert(usr,"You need to be at least a Primary Adminstrator to revive players.")

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
				if (isobserver(M))
					boutput(usr, "<span class='alert'>You can't observe a ghost.</span>")
				else
					if (!istype(usr, /mob/dead/observer))
						boutput(usr, "<span class='alert'>This command only works when you are a ghost.</span>")
						return
					var/mob/dead/observer/ghost = usr
					ghost.insert_observer(M)
			else
				tgui_alert(usr,"You need to be at least a Secondary Adminstrator to observe mobs... For some reason.")

		if ("jumptocoords")
			if(src.level >= LEVEL_SA)
				var/list/coords = splittext(href_list["target"], ",")
				if (coords.len < 3) return
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
					message_admins("<span class='internal'>[key_name(usr)] transformed [H.real_name] into a [which].</span>")
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

		if ("managebioeffect_debug_vars")
			if (src.level >= LEVEL_PA)
				var/datum/bioEffect/B = locate(href_list["bioeffect"])
				usr.client.debug_variables(B)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to view variables!")

		if ("managebioeffect_remove")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				M.bioHolder.RemoveEffect(href_list["bioeffect"])
				usr.client.cmd_admin_managebioeffect(M)

				message_admins("[key_name(usr)] removed the [href_list["bioeffect"]] bio-effect from [key_name(M)].")
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to remove the bioeffects of a player.")
				return

		if("managebioeffect_alter_stable")
			if(src.level >= LEVEL_SA)
				var/datum/bioEffect/BE = locate(href_list["bioeffect"])
				BE.altered = 1
				if (BE.stability_loss == 0)
					BE.stability_loss = BE.global_instance.stability_loss
					BE.holder.genetic_stability = max(0, BE.holder.genetic_stability -= BE.stability_loss) //update mob stability
				else
					BE.holder.genetic_stability = max(0, BE.holder.genetic_stability += BE.stability_loss) //update mob stability
					BE.stability_loss = 0

				usr.client.cmd_admin_managebioeffect(BE.holder.owner)
			else
				return

		if("managebioeffect_alter_reinforce")
			if(src.level >= LEVEL_SA)
				var/datum/bioEffect/BE = locate(href_list["bioeffect"])
				BE.altered = 1
				if (BE.curable_by_mutadone)
					BE.curable_by_mutadone = 0
				else
					BE.curable_by_mutadone = 1

				usr.client.cmd_admin_managebioeffect(BE.holder.owner)
			else
				return

		if("managebioeffect_alter_power_boost")
			if(src.level >= LEVEL_SA)
				var/datum/bioEffect/power/BE = locate(href_list["bioeffect"])
				BE.altered = 1
				var/oldpower = BE.power
				if (BE.power > 1)
					BE.power = 1
				else
					BE.power = 2
				BE.onPowerChange(oldpower, BE.power)
				usr.client.cmd_admin_managebioeffect(BE.holder.owner)
			else
				return

		if("managebioeffect_alter_sync")
			if(src.level >= LEVEL_SA)
				var/datum/bioEffect/power/BE = locate(href_list["bioeffect"])
				BE.altered = 1
				if(istype(BE, /datum/bioEffect/power)) //powers only
					if (BE.safety)
						BE.safety = 0
					else
						BE.safety = 1
				else
					return

				usr.client.cmd_admin_managebioeffect(BE.holder.owner)
			else
				return
		if("managebioeffect_alter_cooldown")
			if(src.level >= LEVEL_SA)
				var/datum/bioEffect/power/BE = locate(href_list["bioeffect"])
				BE.altered = 1
				if(istype(BE, /datum/bioEffect/power)) //powers only
					var/input = input(usr, "Enter a cooldown in deciseconds", "Alter Cooldown", BE.cooldown) as num|null
					if(isnull(input))
						return
					else if(input < 0)
						BE.cooldown = 0
					else
						BE.cooldown = round(input)
				else
					return
				usr.client.cmd_admin_managebioeffect(BE.holder.owner)
			else
				return

		if ("managebioeffect_chromosome")
			if(src.level >= LEVEL_SA)
				var/list/applicable_chromosomes = null
				var/datum/bioEffect/BE = locate(href_list["bioeffect"])
				var/datum/bioEffect/power/P = null
				if (istype(BE, /datum/bioEffect/power)) //powers
					applicable_chromosomes = list("Stabilizer", "Reinforcer", "Weakener", "Camouflager", "Power Booster", "Energy Booster", "Synchronizer", "Custom", "REMOVE CHROMOSOME")
					P = BE
				else if (istype(BE, /datum/bioEffect)) //nonpowers
					applicable_chromosomes = list("Stabilizer", "Reinforcer", "Weakener", "Camouflager", "Custom", "REMOVE CHROMOSOME")
				else
					return

				//ask the user what they want to add
				switch (input(usr, "Select a chromosome", "Manage Bioeffects Splice") as null|anything in applicable_chromosomes)
					if ("Stabilizer")
						if (BE.altered) managebioeffect_chromosome_clean(BE)
						BE.holder.genetic_stability = max(0, BE.holder.genetic_stability += BE.stability_loss) //update mob stability
						BE.stability_loss = 0
						BE.name = "Stabilized " + BE.name
						BE.altered = 1
					if ("Reinforcer")
						if (BE.altered) managebioeffect_chromosome_clean(BE)
						BE.curable_by_mutadone = 0
						BE.name = "Reinforced " + BE.name
						BE.altered = 1
					if ("Weakener")
						if (BE.altered) managebioeffect_chromosome_clean(BE)
						BE.reclaim_fail = 0
						BE.reclaim_mats *= 2
						BE.name = "Weakened " + BE.name
						BE.altered = 1
					if ("Camouflager")
						if (BE.altered) managebioeffect_chromosome_clean(BE)
						BE.msgGain = ""
						BE.msgLose = ""
						BE.name = "Camouflaged " + BE.name
						BE.altered = 1
					if ("Power Booster")
						if (P.altered) managebioeffect_chromosome_clean(P)
						P.power = 2
						P.name = "Empowered " + P.name
						P.altered = 1
					if ("Energy Booster")
						if (P.altered) managebioeffect_chromosome_clean(P)
						if(P.cooldown != 0)
							P.cooldown /= 2
						P.name = "Energized " + P.name
						P.altered = 1
					if ("Synchronizer")
						if (P.altered) managebioeffect_chromosome_clean(P)
						P.safety = 1
						P.name = "Synchronized " + P.name
						P.altered = 1
					if ("Custom") //build your own chromosome!
						if (BE.altered) managebioeffect_chromosome_clean(BE)
						BE.altered = 1
						var/prefix = input(usr, "Enter a custom name for your chromosome", "Manage Bioeffects Splice")
						if (prefix)
							BE.name = "[prefix] " + BE.name
					if ("REMOVE CHROMOSOME")
						if (BE.altered) managebioeffect_chromosome_clean(BE)
					else //user cancelled do nothing
						return
				usr.client.cmd_admin_managebioeffect(BE.holder.owner)
				return

			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to modify the bioeffects of a player.")

		if ("managebioeffect_add")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/input = input(usr, "Enter a /datum/bioEffect path or partial name.", "Add a Bioeffect", null) as null|text
				input = get_one_match(input, "/datum/bioEffect")
				var/datum/bioEffect/BE = text2path("[input]")
				if (BE)
					M.bioHolder.AddEffect(initial(BE.id))
					usr.client.cmd_admin_managebioeffect(M)
					message_admins("[key_name(usr)] added the [initial(BE.id)] bio-effect to [key_name(M)].")
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to add bioeffects to a player.")

		if ("managebioeffect_refresh")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				usr.client.cmd_admin_managebioeffect(M)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to manage the bioeffects of a player.")

		if ("managebioeffect_alter_genetic_stability")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/input = input(usr, "Enter a new genetic stability for the target", "Alter Genetic Stability", M.bioHolder.genetic_stability) as null|num
				if (isnull(input))
					return
				if (input < 0)
					M.bioHolder.genetic_stability = 0
				else
					M.bioHolder.genetic_stability = round(input)
				usr.client.cmd_admin_managebioeffect(M)
			else
				tgui_alert(usr,"You need to be at least a Secondary Administrator to modify the genetic stability of a player.")

		if ("addbioeffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				var/pick = input("Which effect(s)?","Give Bioeffects") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (length(picklist))
					var/string_version
					for(pick in picklist)
						M.bioHolder.AddEffect(pick, magical = 1)

						if (string_version)
							string_version = "[string_version], \"[pick]\""
						else
							string_version = "\"[pick]\""

					message_admins("[key_name(usr)] added the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] to [key_name(M)].")
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

					message_admins("[key_name(usr)] removed the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] from [M.real_name].")
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

		if ("kill")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if(M)
					M.death()
					message_admins("<span class='alert'>Admin [key_name(usr)] killed [key_name(M)]!</span>")
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
				boutput(usr, "<span class='success'>Added [amount] units of [reagent.id] to [M.name]</span>")

				logTheThing(LOG_ADMIN, usr, "added [amount] units of [reagent.id] to [M] at [log_loc(M)].")
				logTheThing(LOG_DIARY, usr, "added [amount] units of [reagent.id] to [M] at [log_loc(M)].", "admin")
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

		if ("removereagent")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!M.reagents) // || !target.reagents.total_volume)
					boutput(usr, "<span class='notice'><b>[M] contains no reagents.</b></span>")
					return
				var/datum/reagents/reagents = M.reagents

				var/list/target_reagents = list()
				var/pick
				for (var/current_id in reagents.reagent_list)
					var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
					target_reagents += current_reagent.name
				pick = tgui_input_list(usr, "Select Reagent:", "Select", target_reagents)
				if (!pick)
					return
				var/pick_id
				if(!isnull(reagents.reagent_list[pick]))
					pick_id = pick
				else
					for (var/current_id in reagents.reagent_list)
						if(pick == reagents.reagent_list[current_id].name)
							var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
							pick_id = current_reagent.id
							break

				if (pick_id)
					var/string_version

					var/amt = input("How much of [pick]?","Remove Reagent") as null|num
					if(!amt || amt < 0)
						return

					if (M.reagents)
						M.reagents.remove_reagent(pick_id,amt)

					if (string_version)
						string_version = "[string_version], [amt] \"[pick]\""
					else
						string_version = "[amt] \"[pick]\""

					message_admins("[key_name(usr)] removed [string_version] from [M.real_name].")
			else
				tgui_alert(usr,"If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to affect player reagents.")

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
				var/origin = href_list["origin"]
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
				M.abilityHolder.addAbility(ab_to_add)
				M.abilityHolder.updateButtons()
				message_admins("[key_name(usr)] added ability [ab_to_add] to [key_name(M)].")
				logTheThing(LOG_ADMIN, usr, "added ability [ab_to_add] to [constructTarget(M,"admin")].")
				if (origin == "manageabils")//called via ability management panel
					usr.client.cmd_admin_manageabils(M)
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
						boutput(usr, "<b><span class='alert'>[M]'s composite holder lacks any ability holders to remove from!</span></b>")
						return //no ability holders in composite holder
				else
					abils += M.abilityHolder.abilities

				if(!abils.len)
					boutput(usr, "<b><span class='alert'>[M] doesn't have any abilities!</span></b>")
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

		if ("manageabils_remove")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				var/datum/targetable/A = locate(href_list["ability"])
				if (!M || !A) return
				message_admins("[key_name(usr)] removed ability [A] from [key_name(M)].")
				logTheThing(LOG_ADMIN, usr, "removed ability [A] from [constructTarget(M,"admin")].")
				M.abilityHolder.removeAbilityInstance(A)
				M.abilityHolder.updateButtons()
				usr.client.cmd_admin_manageabils(M)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("manageabils_alter_cooldown")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				var/datum/targetable/A = locate(href_list["ability"])
				if (!M || !A) return
				var/input = input(usr, "Enter a cooldown in deciseconds", "Alter Cooldown", A.cooldown) as num|null
				if(isnull(input))
					return
				else if(input < 0)
					A.cooldown = 0
				else
					A.cooldown = round(input)
				usr.client.cmd_admin_manageabils(M)
			else
				tgui_alert(usr,"You must be at least a Primary Administrator to do this!")

		if ("manageabilt_debug_vars")
			if (src.level >= LEVEL_PA)
				var/datum/targetable/A = locate(href_list["ability"])
				usr.client.debug_variables(A)
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
				M.traitHolder.addTrait(all_traits[trait_to_add_name])
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
					boutput(usr, "<b><span class='alert'>[M] doesn't have any traits!</span></b>")
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

		if("subtlemsg")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.cmd_admin_subtle_message(M)

		if("adminalert")
			var/mob/M = locate(href_list["target"])
			if(!M) return
			usr.client.cmd_admin_alert(M)

		if ("makewraith")
			if( src.level < LEVEL_PA)
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a wraith.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Make [M] a wraith?", "Make Wraith", list("Yes", "No")) == "Yes")
				var/datum/mind/mind = M.mind
				if (!mind)
					mind = new /datum/mind(  )
					mind.ckey = M.ckey
					mind.key = M.key
					mind.current = M
					ticker.minds += mind
					M.mind = mind
				if (mind.objectives)
					mind.objectives.len = 0
				else
					mind.objectives = list()
				switch (tgui_alert(usr,"Objectives?", "Objectives", list("Custom", "Random", "None")))
					if ("Custom")
						var/WO = null
						do
							WO = input("What objective?", "Objective", null) as null|anything in childrentypesof(/datum/objective/specialist/wraith)
							if (WO)
								new WO(null, mind)
						while (WO != null)
					if ("Random")
						generate_wraith_objectives(mind)
				var/mob/wraith/Wr = M.wraithize()
				if (!Wr)
					if (!iswraith(mind.current))
						boutput(usr, "<span class='alert'>Wraithization failed! Call 1-800-MARQUESAS for help.</span>")
						return
					else
						Wr = mind.current
				if (mind.objectives.len)
					boutput(Wr, "<b>Your objectives:</b>")
					var/obj_count = 1
					for (var/datum/objective/objective in mind.objectives)
						boutput(Wr, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
						obj_count++
				mind.special_role = ROLE_WRAITH
				ticker.mode.Agimmicks += mind
				Wr.antagonist_overlay_refresh(1, 0)

		if ("makeblob")
			if( src.level < LEVEL_PA )
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a blob.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Make [M] a blob?", "Make Blob", list("Yes", "No")) == "Yes")
				var/mob/B = M.blobize()
				if (B)
					if (B.mind)
						B.mind.special_role = ROLE_BLOB
						ticker.mode.bestow_objective(B,/datum/objective/specialist/blob)
						//Bl.owner = B.mind
						//B.mind.objectives = list(Bl)

						var/i = 1
						for (var/datum/objective/Obj in B.mind.objectives)
							boutput(B, "<b>Objective #[i]</b>: [Obj.explanation_text]")
							i++
						ticker.mode.Agimmicks += B.mind
						B.antagonist_overlay_refresh(1, 0)

						SPAWN(0)
							var/newname = input(B, "You are a Blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name change") as text

							if (newname)
								if (length(newname) >= 26) newname = copytext(newname, 1, 26)
								newname = strip_html(newname) + " the Blob"
								B.real_name = newname
								B.name = newname

		if ("makemacho")
			if( src.level < LEVEL_PA )
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a Macho Man.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Make [M] a macho man?", "Make Macho", list("Yes", "No")) == "Yes")
				M.machoize()

		if ("makeslasher")
			if( src.level < LEVEL_PA )
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a Slasher.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Make [M] into a Slasher?", "Make Slasher", list("Yes", "No")) == "Yes")
				M.slasherize()

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

		if ("makeflock")
			if( src.level < LEVEL_PA)
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a flockmind or flocktrace.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Make [M] a flockmind or flocktrace?", "Make Flockmind", list("Yes", "No")) == "Yes")
				var/datum/mind/mind = M.mind
				if (!mind)
					mind = new /datum/mind()
					mind.ckey = M.ckey
					mind.key = M.key
					mind.current = M
					ticker.minds += mind
					M.mind = mind
				// if there's no existing flocks, default to making a flockmind
				// else, present choice: new flockmind of new flock, or new flocktrace of existing flock?
				var/datum/flock/chosen = null
				if(flocks.len > 0)
					var/flockName = input("Add to existing flock? (Hit Cancel to make new flockmind)","Flock Decide Time") as null|anything in flocks
					chosen = flocks[flockName]
				var/mob/living/intangible/flock/F = M.flockerize(chosen)
				if (!F)
					if (!istype(mind.current, /mob/living/intangible/flock))
						boutput(usr, "<span class='alert'>Could not into flockmind. Cirr is a dum and must be shamed.</span>")
						return
					else
						F = mind.current
				if(istype(F, /mob/living/intangible/flock/flockmind))
					mind.special_role = ROLE_FLOCKMIND
				else if(istype(F, /mob/living/intangible/flock/trace))
					mind.special_role = "flocktrace"
				ticker.mode.Agimmicks += mind
				F.antagonist_overlay_refresh(1, 0)

		if("makefloorgoblin")
			if( src.level < LEVEL_PA)
				tgui_alert(usr,"You must be at least a Primary Administrator to make someone a floor goblin.")
				return
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Make [M] a floor goblin?", "Make Floor Goblin", list("Yes", "No")) == "Yes")
				evilize(M, ROLE_FLOOR_GOBLIN)

		if ("remove_traitor")
			if ( src.level < LEVEL_SA )
				tgui_alert(usr,"You must be at least a Secondary Administrator to remove someone's status as an antagonist.")
				return
			if (!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (tgui_alert(usr,"Remove [M]'s antag status?", "Remove Antag", list("Yes", "No")) == "Yes")
				if (!M) return
				if (!isturf(M.loc))
					// They could be in a pod or whatever, which would have unfortunate results when respawned (Convair880).
					tgui_alert(usr, "You currently cannot remove the antagonist status of somebody hiding in a pod, closet or other container.", "An error occurred")
					return
				remove_antag(M, usr, 0, 1)

		if ("traitor")
			if(!ticker || !ticker.mode)
				tgui_alert(usr,"The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return

			//independant of mode and can be traitors as well
			var/datum/game_mode/current_mode = ticker.mode
			if (istype(current_mode, /datum/game_mode/revolution))
				if(M.mind in current_mode:head_revolutionaries)
					tgui_alert(usr,"Head Revolutionary!")
					return
				else if(M.mind in current_mode:revolutionaries)
					tgui_alert(usr,"Revolutionary!")
					return
			else if (istype(current_mode, /datum/game_mode/nuclear))
				if(M.mind in current_mode:syndicates)
					tgui_alert(usr,"Syndicate Operative!", "[M.key]")
					return
			else if (istype(current_mode, /datum/game_mode/spy))
				if(M.mind in current_mode:leaders)
					var/datum/mind/antagonist = M.mind
					var/t = ""
					for(var/datum/objective/OB in antagonist.objectives)
						if (istype(OB, /datum/objective/crew))
							continue
						t += "[OB.explanation_text]\n"
					if(antagonist.objectives.len == 0)
						t = "None defined."
					tgui_alert(usr,"Infiltrator. Objective(s):\n[t]", "[M.key]")
					return
			else if (istype(current_mode, /datum/game_mode/gang))
				if(M.mind in current_mode:leaders)
					tgui_alert(usr,"Leader of [M.mind.gang.gang_name].", "[M.key]")
					return
				for(var/datum/gang/G in current_mode:gangs)
					if(M.mind in G.members)
						tgui_alert(usr,"Member of [G.gang_name].", "[M.key]")
						return

			// traitor, or other modes where traitors/counteroperatives would be.
			if(M.mind in current_mode.traitors)
				var/datum/mind/antagonist = M.mind
				var/t = ""
				for(var/datum/objective/OB in antagonist.objectives)
					if (istype(OB, /datum/objective/crew))
						continue
					t += "[OB.explanation_text]\n"
				if(antagonist.objectives.len == 0)
					t = "None defined."
				tgui_alert(usr,"Assigned [M.mind.special_role]. Objective(s):\n[t]", "[M.key]")
				return
			if(M.mind in ticker.mode.Agimmicks)
				var/datum/mind/antagonist = M.mind
				var/t = ""
				for(var/datum/objective/OB in antagonist.objectives)
					if (istype(OB, /datum/objective/crew))
						continue
					t += "[OB.explanation_text]\n"
				if(antagonist.objectives.len == 0)
					t = "None defined."
				tgui_alert(usr,"Assigned [M.mind.special_role]. Objective(s):\n[t]", "[M.key]")
				return

			//they're nothing so turn them into a traitor!
			if(ishuman(M) || isAI(M) || isrobot(M) || ismobcritter(M))
				var/antagonize = "Cancel"
				antagonize = tgui_alert(usr,"Is not an antagonist, make antagonist?", "antagonist", list("Yes", "Cancel"))
				if(antagonize == "Cancel")
					return
				if(antagonize == "Yes")
					if (issilicon(M))
						evilize(M, ROLE_TRAITOR)
					else if (ismobcritter(M))
						// The only role that works for all critters at this point is hard-mode traitor, really. The majority of existing
						// roles don't work for them, most can't wear clothes and some don't even have arms and/or can pick things up.
						// That said, certain roles are mostly compatible and thus selectable.
						var/list/traitor_types = list(ROLE_HARDMODE_TRAITOR, ROLE_WRESTLER, ROLE_GRINCH)
						var/selection = input(usr, "Select traitor type.", "Traitorize", ROLE_HARDMODE_TRAITOR) as null|anything in traitor_types
						switch (selection)
							if (ROLE_HARDMODE_TRAITOR)
								evilize(M, ROLE_TRAITOR, "hardmode")
							else
								evilize(M, selection)
						/*	else
								SPAWN(0) tgui_alert(usr,"An error occurred, please try again.")*/
					else
						var/list/traitor_types = list(ROLE_TRAITOR, ROLE_WIZARD, ROLE_CHANGELING, ROLE_VAMPIRE, ROLE_WEREWOLF, ROLE_HUNTER, ROLE_WRESTLER, ROLE_GRINCH, ROLE_OMNITRAITOR, ROLE_SPY_THIEF, ROLE_ARCFIEND)
						if(ticker?.mode && istype(ticker.mode, /datum/game_mode/gang))
							traitor_types += ROLE_GANG_LEADER
						var/selection = input(usr, "Select traitor type.", "Traitorize", ROLE_TRAITOR) as null|anything in traitor_types
						switch(selection)
							if(ROLE_TRAITOR)
								if (tgui_alert(usr,"Hard Mode?","Treachery",list("Yes", "No")) == "Yes")
									evilize(M, ROLE_TRAITOR, "hardmode")
								else
									evilize(M, ROLE_TRAITOR)
							else
								evilize(M, selection)
							/*else
								SPAWN(0) tgui_alert(usr,"An error occurred, please try again.")*/
			//they're a ghost/hivebotthing/etc
			else
				tgui_alert(usr,"Cannot make this mob a traitor")

		if ("add_antagonist")
			if (src.level < LEVEL_PA)
				tgui_alert(usr, "You must be at least a Primary Administrator to change someone's antagonist status.")
				return
			var/mob/M = locate(href_list["targetmob"])
			if (!M?.mind)
				return
			var/list/antag_options = list()
			for (var/V as anything in concrete_typesof(/datum/antagonist))
				var/datum/antagonist/A = V
				if (!M.mind.get_antagonist(initial(A.id)))
					antag_options[initial(A.display_name)] = initial(A.id)
			if (!length(antag_options))
				boutput(usr, "<span class='alert'>Antagonist assignment failed - no valid antagonist roles exist.</span>")
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
			var/do_objectives = tgui_alert(usr, "Assign randomly-generated objectives?", "Add Antagonist", list("Yes", "No", "Cancel"))
			if (do_objectives == "Cancel" || !M?.mind || !selected_keyvalue)
				return
			if (tgui_alert(usr, "[M.real_name] (ckey [M.ckey]) will immediately become \a [selected_keyvalue]. Equipment and abilities will[do_equipment == "Yes" ? "" : " NOT"] be added. Objectives will [do_objectives == "Yes" ? "be generated automatically" : "not be present"]. Is this what you want?", "Add Antagonist", list("Make it so.", "Cancel.")) != "Make it so.") // This is definitely not ideal, but it's what we have for now
				return
			boutput(usr, "<span class='notice'>Adding antagonist of type \"[selected_keyvalue]\" to mob [M.real_name] (ckey [M.ckey])...</span>")
			var/success = M.mind.add_antagonist(antag_options[selected_keyvalue], do_equipment == "Yes", do_objectives == "Yes", source = ANTAGONIST_SOURCE_ADMIN, respect_mutual_exclusives = FALSE)
			if (success)
				boutput(usr, "<span class='notice'>Addition successful. [M.real_name] (ckey [M.ckey]) is now \a [selected_keyvalue].</span>")
			else
				boutput(usr, "<span class='alert'>Addition failed with return code [success]. The mob may be incompatible. Report this to a coder.</span>")

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
			boutput(usr, "<span class='notice'>Removing antagonist of type \"[antag.id]\" from mob [M.real_name] (ckey [M.ckey])...</span>")
			var/success = M.mind.remove_antagonist(antag.id)
			if (success)
				boutput(usr, "<span class='notice'>Removal successful.[length(M.mind.antagonists) ? "" : " As this was [M.real_name] (ckey [M.ckey])'s only antagonist role, their antagonist status is now fully removed."]</span>")
			else
				boutput(usr, "<span class='alert'>Removal failed with return code [success]; report this to a coder.</span>")

		if ("wipe_antagonists")
			if (src.level < LEVEL_PA)
				tgui_alert(usr, "You must be at least a Primary Administrator to change someone's antagonist status.")
				return
			var/mob/M = locate(href_list["targetmob"])
			if (!M?.mind)
				return
			if (tgui_alert(usr, "Really remove all antagonists from [M.real_name] (ckey [M.ckey])?", "antagonist", list("Yes", "Cancel")) != "Yes")
				return
			boutput(usr, "<span class='notice'>Removing all antagonist statuses from [M.real_name] (ckey [M.ckey])...</span>")
			var/success = M.mind.wipe_antagonists()
			if (success)
				boutput(usr, "<span class='notice'>Removal successful. [M.real_name] (ckey [M.ckey]) is no longer an antagonist.")
			else
				boutput(usr, "<span class='alert'>Removal failed with return code [success]; report this to a coder.</span>")

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
							<A href='?src=\ref[src];action=chgadlvl;type=Coder;target=\ref[C]'>Coder</A><BR>
							"}
				if (src.level >= LEVEL_ADMIN)
					dat += "<A href='?src=\ref[src];action=chgadlvl;type=Administrator;target=\ref[C]'>Administrator</A><BR>"
					dat += "<A href='?src=\ref[src];action=chgadlvl;type=Primary Administrator;target=\ref[C]'>Primary Administrator</A><BR>"
				if (src.level >= LEVEL_PA)
					dat += {"
							<A href='?src=\ref[src];action=chgadlvl;type=Intermediate Administrator;target=\ref[C]'>Intermediate Administrator</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Secondary Administrator;target=\ref[C]'>Secondary Administrator</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Moderator;target=\ref[C]'>Moderator</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Ayn Rand%27s Armpit;target=\ref[C]'>Ayn Rand's Armpit</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Goat Fart;target=\ref[C]'>Goat Fart</A><BR>
							<A href='?src=\ref[src];action=chgadlvl;type=Remove;target=\ref[C]'>Remove Admin</A><BR>
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
					var/X = offset.len > 0 ? text2num(offset[1]) : 0
					var/Y = offset.len > 1 ? text2num(offset[2]) : 0
					var/Z = offset.len > 2 ? text2num(offset[3]) : 0
					var/direction = text2num(href_list["one_direction"]) // forgive me

					for (var/i = 1 to number)
						switch (href_list["offset_type"])
							if ("absolute")
								for (var/path in paths)
									var/atom/thing
									if(ispath(path, /turf))
										var/turf/T = locate(0 + X,0 + Y,0 + Z)
										thing = T.ReplaceWith(path, FALSE, TRUE, FALSE, TRUE)
									else
										thing = new path(locate(0 + X,0 + Y,0 + Z))
									thing.set_dir(direction ? direction : SOUTH)
									LAGCHECK(LAG_LOW)

							if ("relative")
								if (loc)
									for (var/path in paths)
										var/atom/thing
										if(ispath(path, /turf))
											var/turf/T = locate(loc.x + X,loc.y + Y,loc.z + Z)
											thing = T.ReplaceWith(path, FALSE, TRUE, FALSE, TRUE)
										else
											thing = new path(locate(loc.x + X,loc.y + Y,loc.z + Z))
										thing.set_dir(direction ? direction : SOUTH)
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
						logTheThing(LOG_ADMIN, usr, "created [number]ea [english_list(paths)]")
						logTheThing(LOG_DIARY, usr, "created [number]ea [english_list(paths)]", "admin")
						for(var/path in paths)
							if(ispath(path, /mob))
								message_admins("[key_name(usr)] created [number]ea [english_list(paths, 1)]")
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
				if (M.ckey && M.ckey == usr.ckey)
					tgui_alert(usr, "You cannot modify your own antag tokens.")
					return
				var/tokens = input(usr, "Current Tokens: [M.client.antag_tokens]","Set Antag Tokens to...") as null|num
				if (!tokens)
					return
				M.client.set_antag_tokens( tokens )
				if (tokens <= 0)
					logTheThing(LOG_ADMIN, usr, "Removed all antag tokens from [constructTarget(M,"admin")]")
					logTheThing(LOG_DIARY, usr, "Removed all antag tokens from [constructTarget(M,"diary")]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] removed all antag tokens from [key_name(M)]</span>")
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
					boutput( usr, "<span class='alert'>Revoke failed, couldn't contact hub!</span>" )
				else if(suc)
					boutput( usr, "<span class='alert'>Contributor medal revoked.</span>" )
					logTheThing(LOG_ADMIN, usr, "revoked [constructTarget(M,"admin")]'s contributor status.")
					logTheThing(LOG_DIARY, usr, "revoked [constructTarget(M,"diary")]'s contributor status.")
					message_admins( "[key_name(usr)] revoked [key_name(M)]'s contributor status." )
				else
					boutput( usr, "<span class='alert'>Failed to revoke, did they have the medal to begin with?</span>" )
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
					boutput( usr, "<span class='alert'>Revoke failed, couldn't contact hub!</span>" )
				else if(suc)
					boutput( usr, "<span class='alert'>Clown college diploma revoked.</span>" )
					logTheThing(LOG_ADMIN, usr, "revoked [constructTarget(M,"admin")]'s clown college diploma.")
					logTheThing(LOG_DIARY, usr, "revoked [constructTarget(M,"diary")]'s clown college diploma.")
					message_admins( "[key_name(usr)] revoked [key_name(M)]'s clown college diploma." )
				else
					boutput( usr, "<span class='alert'>Failed to revoke, did they have the medal to begin with?</span>" )
			else
				tgui_alert(usr,"You need to be at least an SA to revoke this.")

		if ("viewvars")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.debug_variables(M)
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
						for(var/obj/item/clothing/suit/fire/O in world)
							qdel(O)
							LAGCHECK(LAG_LOW)
						for(var/obj/grille/O in world)
							qdel(O)
							LAGCHECK(LAG_LOW)
						for(var/obj/machinery/vehicle/pod/O in all_processing_machines())
							for(var/atom/movable/A in O)
								A.set_loc(O.loc)
							qdel(O)
							LAGCHECK(LAG_LOW)

					if("transform_one")
						var/who = input("Transform who?","Transform") as null|mob in world
						if (!who)
							return
						if (!ishuman(who))
							tgui_alert(usr,"This secret can only be used on human mobs.")
							return
						var/mob/living/carbon/human/H = who
						var/which = input("Transform them into what?","Transform") as null|anything in list("Monkey","Cyborg","Lizardman","Squidman","Martian","Skeleton","Flashman","Cow")
						if (!which)
							return
						switch(which)
							if("Monkey") H.monkeyize()
							if("Cyborg") H.Robotize_MK2()
							if("Lizardman")
								H.set_mutantrace(/datum/mutantrace/lizard)
							if("Squidman")
								H.set_mutantrace(/datum/mutantrace/ithillid)
							if("Martian")
								H.set_mutantrace(/datum/mutantrace/martian)
							if("Skeleton")
								H.set_mutantrace(/datum/mutantrace/skeleton)
							if("Flashman")
								H.set_mutantrace(/datum/mutantrace/flashy)
							if ("Cow")
								H.set_mutantrace(/datum/mutantrace/cow)
						message_admins("<span class='internal'>[key_name(usr)] transformed [H.real_name] into a [which].</span>")
						logTheThing(LOG_ADMIN, usr, "transformed [H.real_name] into a [which].")
						logTheThing(LOG_DIARY, usr, "transformed [H.real_name] into a [which].", "admin")

					if("transform_all")
						var/which = input("Transform everyone into what?","Transform") as null|anything in list("Monkey","Cyborg","Lizardman","Squidman","Martian","Skeleton","Flashman","Cow")
						for(var/mob/living/carbon/human/H in mobs)
							switch(which)
								if("Monkey") H.monkeyize()
								if("Cyborg") H.Robotize_MK2()
								if("Lizardman")
									H.set_mutantrace(/datum/mutantrace/lizard)
								if("Squidman")
									H.set_mutantrace(/datum/mutantrace/ithillid)
								if("Martian")
									H.set_mutantrace(/datum/mutantrace/martian)
								if("Skeleton")
									H.set_mutantrace(/datum/mutantrace/skeleton)
								if("Flashman")
									H.set_mutantrace(/datum/mutantrace/flashy)
								if("Cow")
									H.set_mutantrace(/datum/mutantrace/cow)
							LAGCHECK(LAG_LOW)
						message_admins("<span class='internal'>[key_name(usr)] transformed everyone into a [which].</span>")
						logTheThing(LOG_ADMIN, usr, "transformed everyone into a [which].")
						logTheThing(LOG_DIARY, usr, "transformed everyone into a [which].", "admin")
					if("prisonwarp")
						if(!ticker)
							tgui_alert(usr,"The game hasn't started yet!")
							return
						message_admins("<span class='internal'>[key_name(usr)] teleported all players to the prison zone.</span>")
						logTheThing(LOG_ADMIN, usr, "teleported all players to the prison zone.")
						logTheThing(LOG_DIARY, usr, "teleported all players to the prison zone.", "admin")
						for(var/mob/living/carbon/human/H in mobs)
							var/turf/loc = get_turf(H)
							var/security = 0
							if(loc.z > 1 || prisonwarped.Find(H))
								//don't warp them if they aren't ready or are already there
								continue
							H.changeStatus("paralysis", 7 SECONDS)
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

							message_admins("<span class='internal'>[key_name(usr)] critterized everyone into [CT].</span>")
							logTheThing(LOG_ADMIN, usr, "critterized everyone into [CT]")
							logTheThing(LOG_DIARY, usr, "critterized everyone into a critter [CT]", "admin")
						else
							tgui_alert(usr,"You're not of a high enough rank to do this")
					if("traitor_all")
						if (src.level >= LEVEL_SA)
							if(!ticker)
								tgui_alert(usr,"The game hasn't started yet!")
								return

							var/which_traitor = input("What kind of traitor?","Everyone's a Traitor") as null|anything in list(ROLE_TRAITOR,ROLE_WIZARD,ROLE_CHANGELING,ROLE_WEREWOLF,ROLE_VAMPIRE,ROLE_ARCFIEND,ROLE_HUNTER,ROLE_WRESTLER,ROLE_GRINCH,ROLE_OMNITRAITOR)
							if(!which_traitor)
								return
							var/hardmode = null
							if (which_traitor == ROLE_TRAITOR)
								if (tgui_alert(usr,"Hard Mode?","Everyone's a Traitor",list("Yes", "No")) == "Yes")
									hardmode = "hardmode"
							var/custom_objective = input("What should the objective be?","Everyone's a Traitor") as null|text
							if (!custom_objective)
								return
							var/escape_objective = input("Which escaping objective?") as null|anything in typesof(/datum/objective/escape/) + "None"
							if (!escape_objective)
								return

							if (escape_objective == "None")
								escape_objective = null

							for(var/mob/living/carbon/human/H in mobs)
								if(isdead(H) || !(H.client)) continue
								if(checktraitor(H)) continue
								evilize(H, which_traitor, hardmode, custom_objective, escape_objective)

							message_admins("<span class='internal'>[key_name(usr)] made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]</span>")
							logTheThing(LOG_ADMIN, usr, "made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]")
							logTheThing(LOG_DIARY, usr, "made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]", "admin")
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
												M.show_message(text("<span class='notice'>You shudder as if cold...</span>"), 1)
											if(2)
												M.show_message(text("<span class='notice'>You feel something gliding across your back...</span>"), 1)
											if(3)
												M.show_message(text("<span class='notice'>Your eyes twitch, you feel like something you can't see is here...</span>"), 1)
											if(4)
												M.show_message(text("<span class='notice'>You notice something moving out of the corner of your eye, but nothing is there...</span>"), 1)
										for(var/obj/W in orange(5,M))
											if(prob(25) && !W.anchored)
												step_rand(W)
							sleep(rand(100,1000))
						for(var/mob/M in mobs)
							if(M.client && !isdead(M))
								M.show_message(text("<span class='notice'>The chilling wind suddenly stops...</span>"), 1)
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
							if (tgui_alert(usr,"Do you want to give everyone a gun?", "Confirmation", list("Yes", "No")) != "Yes")
								return
							for (var/mob/living/L in mobs)
								new /obj/random_item_spawner/kineticgun(get_turf(L))
							message_admins("[key_name(usr)] gave everyone a random firearm.")
							logTheThing(LOG_ADMIN, usr, "gave everyone a random firearm.")
							logTheThing(LOG_DIARY, usr, "gave everyone a random firearm.", "admin")
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
							boutput(usr, text("<span class='alert'><B>Preparing to warp time</B></span>"))
							timeywimey(timedelay)
							boutput(usr, text("<span class='alert'><B>Time warped!</B></span>"))
							logTheThing(LOG_ADMIN, usr, "triggered a time warp.")
							logTheThing(LOG_DIARY, usr, "triggered a time warp.", "admin")
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

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(M)].")
								logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(M)].")
								logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(M)].", "admin")
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

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing(LOG_ADMIN, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing(LOG_DIARY, usr, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.", "admin")
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
								W.icon = 'icons/obj/items/gun.dmi'
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

								qdel(H.mutantrace)
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


									playsound(M, 'sound/machines/chainsaw_red.ogg', 60, 1)
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
									M.changeStatus("weakened", 2 SECONDS)

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

								if(people_to_swap.len > 1) //Jenny Antonsson switches bodies with herself! #wow #whoa
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
									while(people_to_swap.len > 0)

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

					else
				if (usr) logTheThing(LOG_ADMIN, usr, "used secret [href_list["secretsfun"]]")
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
					if("mechanic")
						src.owner:debug_variables(mechanic_controls)
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
			else
				tgui_alert(usr,"You need to be at least a Coder to use debugging secrets.")

		if ("secretsadmin")
			if (src.level >= LEVEL_MOD)
				var/ok = 0

				switch(href_list["type"])
					if("check_antagonist")
						if (ticker?.mode && current_state >= GAME_STATE_PLAYING)
							#define isdeadplayer(M) (isdead(M) || (isVRghost(M) || isghostcritter(M) || inafterlife(M) || isghostdrone(M)))
							var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1><A href='?src=\ref[src];action=secretsadmin;type=check_antagonist'>Refresh</A><br><br>"
							dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
							dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"

							if (istype(ticker.mode, /datum/game_mode/nuclear))
								var/datum/game_mode/nuclear/NN = ticker.mode
								dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
								for(var/datum/mind/N in NN.syndicates)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"

								// This basic bit of info was missing, even though you could look up the
								// location of the old auth disk here in the past (Convair880).
								dat += "</table><br><table><tr><td><b>Nuclear bomb:</b></td></tr>"
								if (NN.the_bomb && istype(NN.the_bomb, /obj/machinery/nuclearbomb/))
									var/turf/T = get_turf(NN.the_bomb)
									dat += "<tr><td>Location:"
									if (T && istype(T, /turf))
										dat += " <a href='?src=\ref[src];action=jumptocoords;target=[T.x],[T.y],[T.z]'>[T.x],[T.y],[T.z]</a> ([get_area(NN.the_bomb)])</tr></td>"
									else
										dat += " Found (unknown location)</tr></td>"
								else
									dat += "<tr><td>N/A (destroyed or not associated with objective)</tr></td>"

								dat += "<tr><td>Target area:"
								if (!isnull(NN.target_location_type))
									dat += " [NN.concatenated_location_names]</tr></td>"
								else
									dat += " Unknown or not assigned</tr></td>"

								dat += "</table>"

							else if (istype(ticker.mode, /datum/game_mode/revolution))
								dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
								for(var/datum/mind/N in ticker.mode:head_revolutionaries)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"
								for(var/datum/mind/N in ticker.mode:revolutionaries)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"
								dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
								for(var/datum/mind/N in ticker.mode:get_living_heads())
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									var/turf/mob_loc = get_turf(M)
									dat += "<td>[mob_loc.loc]</td></tr>"
								dat += "</table>"

							else if (istype(ticker.mode, /datum/game_mode/spy))
								var/datum/game_mode/spy/spymode = ticker.mode
								if(length(spymode.leaders))
									dat += "<br><table cellspacing=5><tr><td><B>Infiltrators:</B></td><td></td><tr>"
									for(var/datum/mind/leader in spymode.leaders)
										var/mob/M = leader.current
										if(!M) continue
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(M)]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
										dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"

									dat += "</table>"
								else
									dat += "There are no infiltrators."

								if(length(spymode.spies))
									dat += "<br><table cellspacing=5><tr><td><B>Brainwashed Followers:</B></td><td></td><tr>"
									for(var/datum/mind/spy in spymode.spies)
										var/mob/M = spy.current
										if(!M) continue
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td>Obeys: "
										var/datum/mind/obeycheck = spymode.spies[spy]
										if (istype(obeycheck) && obeycheck.current)
											dat += "[obeycheck.current.ckey]"
										else
											dat += "Nobody!"
										dat += "</td><td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"

									dat += "</table>"
								else
									dat += "There are no brainwashed followers."

							else if (istype(ticker.mode, /datum/game_mode/gang))
								var/datum/game_mode/gang/gangmode = ticker.mode
								if (length(gangmode.leaders))
									for(var/datum/mind/leader in gangmode.leaders)
										var/mob/M = leader.current
										var/datum/gang/gang = leader.gang
										dat += "<br><table cellspacing=5><tr><td>([format_frequency(gang.gang_frequency)]) <B>[gang.gang_name]:</B></td><td></td><tr>"
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(M)]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
										dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
										for(var/datum/mind/member in gang.members)
											if(member.current != null)
												dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(member.current)]</a>[member.current.client ? "" : " <i>(logged out)</i>"][isdeadplayer(member.current) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
												dat += "<td><a href='?action=priv_msg&target=[member.ckey]'>PM</A></td>"
												dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[member.current]'>Show Objective</A></td></tr>"
									dat += "</table>"
								else
									dat += "There are no gangs."

							if (ticker.mode.traitors.len > 0)
								dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
								for (var/datum/mind/traitor in ticker.mode.traitors)
									var/mob/M = traitor.current
									if (!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>([M?.mind?.special_role])</A></td></tr>"
								dat += "</table>"

							if(ticker.mode.Agimmicks.len > 0)
								dat += "<br><table cellspacing=5><tr><td><B>Misc Foes</B></td><td></td><td></td></tr>"
								for(var/datum/mind/gimmick in ticker.mode.Agimmicks)
									var/mob/M = gimmick.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdeadplayer(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>([M?.mind?.special_role])</A></td></tr>"
								dat += "</table>"

							if (istype(ticker.mode, /datum/game_mode/spy_theft) || ticker.mode.spy_market)
								var/datum/game_mode/spy_theft/game = istype(ticker.mode, /datum/game_mode/spy_theft) ? ticker.mode : ticker.mode.spy_market

								var/refresh_time_formatted = round((game.last_refresh_time + game.bounty_refresh_interval)/10 ,1)
								refresh_time_formatted = "[round(refresh_time_formatted / 3600)]:[add_zero(round(refresh_time_formatted % 3600 / 60), 2)]:[add_zero(num2text(refresh_time_formatted % 60), 2)]"

								dat += "<br><tr><td><B>Current Bounties (Refresh at [refresh_time_formatted])  </B></td><td></td></tr>"
								for(var/datum/bounty_item/B in game.active_bounties)
									var/atext = ""
									if (B.reveal_area && B.item && !B.claimed)
										atext = "<br>(Last Seen : [get_area(B.item)])"
									var/rtext = ""
									if (B.reward)
										rtext = "<br><b>Reward</b> : [B.reward.name]"

									dat += "<br><br><tr><td><b>[B.name]</b>[rtext][atext]<br> [(B.claimed) ? "(<b>CLAIMED</b>)" : "(Deliver : <b>[B.delivery_area ? B.delivery_area : "Anywhere"]</b>)"]</td></tr>"

							dat += "</body></html>"
							usr.Browse(dat, "window=roundstatus;size=400x500")
							#undef isdeadplayer
						else
							tgui_alert(usr,"The game hasn't started yet!")
					if("shuttle_panel")
						if (current_state >= GAME_STATE_PLAYING)
							var/dat = "<html><head><title>Shuttle Controls</title></head><body><h1><B>Shuttle Controls</B></h1>"
							dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"
							dat += "<B>Emergency shuttle:</B><BR>"
							if (!emergency_shuttle.online)
								dat += "<a href='?src=\ref[src];action=call_shuttle&type=1'>Call Shuttle</a><br>"
							else
								var/timeleft = emergency_shuttle.timeleft()
								switch(emergency_shuttle.location)
									if(0)
										dat += "ETA: <a href='?src=\ref[src];action=edit_shuttle_time'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
										dat += "<a href='?src=\ref[src];action=call_shuttle&type=2'>Send Back</a><br>"
									if(1)
										dat += "ETA: <a href='?src=\ref[src];action=edit_shuttle_time'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
							dat += "</body></html>"
							usr.Browse(dat, "window=roundstatus;size=400x500")
					if("manifest")
						var/dat = "<B>Showing Crew Manifest.</B><HR>"
						dat += "<table cellspacing=5><tr><th>Name</th><th>Original Position</th><th>Position</th></tr>"
						for(var/mob/living/carbon/human/H in mobs)
							if(H.ckey)
								dat += "<tr><td>[H.name]</td><td>[(H.mind ? H.mind.assigned_role : "Unknown Position")]</td><td>[(istype(H.wear_id, /obj/item/card/id) || istype(H.wear_id, /obj/item/device/pda2)) ? "[H.wear_id:assignment]" : "Unknown Position"]</td></tr>"
							LAGCHECK(LAG_LOW)
						dat += "</table>"
						usr.Browse(dat, "window=manifest;size=440x410")
					if("jobcaps")
						job_controls.job_config()
					if("respawn_panel")
						src.s_respawn()
					if("randomevents")
						random_events.event_config()
					if("pathology")
						pathogen_controller.cdc_main(src)
					if("motives")
						simsController.showControls(usr)
					if("artifacts")
						artifact_controls.config()
					if("ghostnotifier")
						ghost_notifier.config()
					if("unelectrify_all")
						for(var/obj/machinery/door/airlock/D)
							D.secondsElectrified = 0
							LAGCHECK(LAG_LOW)
						message_admins("Admin [key_name(usr)] de-electrified all airlocks.")
						logTheThing(LOG_ADMIN, usr, "de-electrified all airlocks.")
						logTheThing(LOG_DIARY, usr, "de-electrified all airlocks.", "admin")
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
				usr << link("http://mini.xkeeper.net/ss13/admin/log-viewer.php?server=[config.server_id]&redownload=1&view=[roundLog_date].html")

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

		if ("view_logs_pathology_strain")
			if (src.level >= LEVEL_MOD)
				var/gettxt
				if (href_list["presearch"])
					gettxt = href_list["presearch"]
				else
					gettxt = input("Which pathogen tree?", "Pathogen tree") in pathogen_controller.pathogen_trees

				var/adminLogHtml = get_log_data_html(LOG_PATHOLOGY, gettxt, src)
				usr.Browse(adminLogHtml, "window=pathology_log;size=750x500")

		if ("s_rez")
			if (src.level >= LEVEL_PA)
				switch(href_list["type"])
					if("spawn_syndies")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Syndicates",3) as num
						if(!amount) return
						SR.spawn_syndies(amount)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] syndicate operatives.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] syndicate operatives.", "admin")

					if("spawn_normal")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Normal Players",3) as num
						if(!amount) return
						SR.spawn_normal(amount)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] normal players.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] normal players.", "admin")

					if("spawn_player") //includes antag players
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_normal(amount, INCLUDE_ANTAGS)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] players.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] players.", "admin")

					if("spawn_player_strip_antag") //includes antag players but strips status
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_normal(amount, INCLUDE_ANTAGS, STRIP_ANTAG)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] players.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] players.", "admin")

					if("spawn_job")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
						var/datum/job/job = input(usr,"Select job to spawn players as:","Respawn Panel",null) as null|anything in jobs
						if(!job) return
						var/amount = input(usr,"Amount to respawn:","Spawn Normal Players",3) as num
						if(!amount) return
						SR.spawn_as_job(amount,job)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] normal players.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] normal players.", "admin")

					if("spawn_player_job") //includes antag players
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
						var/datum/job/job = input(usr,"Select job to spawn players as:","Respawn Panel",null) as null|anything in jobs
						if(!job) return
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_as_job(amount, job, INCLUDE_ANTAGS)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] players, and kept any antag statuses.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] players, and kept any antag statuses.", "admin")

					if("spawn_player_job_strip_antag") //includes antag players but strips antag status
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
						var/datum/job/job = input(usr,"Select job to spawn players as:","Respawn Panel",null) as null|anything in jobs
						if(!job) return
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_as_job(amount, job, INCLUDE_ANTAGS, STRIP_ANTAG)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] players, and stripped any antag statuses.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] players, and stripped any antag statuses.", "admin")

	/*				if("spawn_commandos")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						SR.spawn_commandos(3)

					if("spawn_turds")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn TURDS",3) as num
						if(!amount) return
						SR.spawn_TURDS(amount)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] TURDS.")
						logTheThing(LOG_DIARY, src, "has spawned [amount] TURDS.", "admin")

					if("spawn_smilingman")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						SR.spawn_smilingman(1)
						logTheThing(LOG_ADMIN, src, "has spawned a Smiling Man.")
						logTheThing(LOG_DIARY, src, "has spawned a Smiling Man.", "admin")
	*/

					if("spawn_custom")
						var/datum/special_respawn/SR = new /datum/special_respawn
						var/blType = input(usr, "Select a mob type", "Spawn Custom") as null|anything in typesof(/mob/living)
						if(!blType) return
						var/amount = input(usr, "Amount to respawn:", "Spawn Custom",3) as num
						if(!amount) return
						SR.spawn_custom(blType, amount)
						logTheThing(LOG_ADMIN, src, "has spawned [amount] mobs of type [blType].")
						logTheThing(LOG_DIARY, src, "has spawned [amount] mobs of type [blType].", "admin")

					if("spawn_wizards")

					if("spawn_aliens")

					else
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
				usr.client.show_rules_to_player(M)
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

		if ("viewantaghistory")
			if (src.level < LEVEL_SA)
				return tgui_alert(usr,"You must be at least a Secondary Admin to view antag history.")

			usr.client.cmd_antag_history(href_list["targetckey"])

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
			world << "Undefined action [href_list["action"]]"

	//Wires bad hack part 2
	sleep(0.5 SECONDS)
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


/datum/admins/proc/s_respawn()
	var/dat = {"
		<html><head><title>Respawn Panel</title>
			<style>
				table {
					border:1px solid #FF6961;
					border-collapse: collapse;
					width: 100%;
					empty-cells: show;
				}

				th {
					background-color: #FF6961;
					color: white;
					padding: 8px;
					text-align: center;
				}

				td {
					padding: 8px;
					text-align: left;
				}

				tr:nth-child(odd) {background-color: #f2f2f2;}
			</style>
		</head>
		<body>
			<table>
				<th>Respawn Panel</th>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_normal'>Spawn normal players</A></td></tr>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_job'>Spawn normal players as a job</A></td></tr>
				<tr><td></td></tr>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_player'>Spawn players - keep antag status</A></td></tr>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_player_job'>Spawn players as a job - keep antag status</A></td></tr>
				<tr><td></td></tr>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_player_strip_antag'>Spawn players - strip antag status</A></td></tr>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_player_job_strip_antag'>Spawn players as a job - strip antag status</A></td></tr>
				<tr><td></td></tr>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_syndies'>Spawn a Syndicate attack force</A></td></tr>
				<tr><td><A href='?src=\ref[src];action=s_rez;type=spawn_custom'>Spawn a custom mob type</A></td></tr>
			</table>
		</body></html>
		"}
	usr.Browse(dat, "window=SRespawn")

	// Someone else removed these but left the (non-functional) buttons. Move back inside the dat section and uncomment to re-add. - IM
	// <A href='?src=\ref[src];action=s_rez;type=spawn_commandos'>Spawn a force of commandos</A><BR>
	// <A href='?src=\ref[src];action=s_rez;type=spawn_turds'>Spawn a T.U.R.D.S. attack force</A><BR>
	// <A href='?src=\ref[src];action=s_rez;type=spawn_smilingman'>Spawn a Smiling Man</A><BR>

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
	dat += "Current map: <A href='?src=\ref[src];action=switch_map'>[getMapNameFromID(map_setting)]</A>"
	if (mapSwitcher.next)
		dat += " (Next map: [mapSwitcher.next])"

	if (mapSwitcher.votingAllowed)
		dat += " (Vote: <A href='?src=\ref[src];action=start_map_vote'>Start</A> | <A href='?src=\ref[src];action=end_map_vote'>End</A> | <A href='?src=\ref[src];action=cancel_map_vote'>Cancel</A>)"

	dat += "<br>"

	//Station name
	dat += "Station Name: <A href='?src=\ref[src];action=change_station_name'>[station_name()]</A><br>"

	var/shuttletext = " " //setup shuttle message
	if(!emergency_shuttle) return // runtime error fix
	if (emergency_shuttle.online)
		switch(emergency_shuttle.location)
			if(0)// centcom
				if (emergency_shuttle.direction == 1)
					shuttletext = "Coming to Station (ETA: [round(emergency_shuttle.timeleft()/60)])"
				if (emergency_shuttle.direction == -1)
					shuttletext = "Returning to Centcom (ETA: [round(emergency_shuttle.timeleft()/60)])"
			if(1)// ss13
				shuttletext = "Arrived at Station (ETD: [round(emergency_shuttle.timeleft()/60)])"
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
				dat += "<A href='?src=\ref[src];action=c_mode_panel'>Change Next Round's Game Mode</A><br>"
			if (emergency_shuttle.online)
				dat += "<a href='?src=\ref[src];action=call_shuttle&type=2'><b>Shuttle Status:</b></a> <a href='?src=\ref[src];action=edit_shuttle_time'>[shuttletext]</a>"
			else
				dat += "<a href='?src=\ref[src];action=call_shuttle&type=1'><b>Shuttle Status:</b></a> <a href='?src=\ref[src];action=edit_shuttle_time'>[shuttletext]</a>"
			dat += "<br>Players Can Call: [src.level >= LEVEL_PA ? "<a href='?src=\ref[src];action=toggle_shuttle_calling'>" : null][emergency_shuttle.disabled ? "No" : "Yes"][src.level >= LEVEL_PA ? "</a>" : null]"
			dat += " | Players Can Recall: [src.level >= LEVEL_PA ? "<a href='?src=\ref[src];action=toggle_shuttle_recalling'>" : null][emergency_shuttle.can_recall ? "Yes" : "No"][src.level >= LEVEL_PA ? "</a>" : null]"
		else if (current_state <= GAME_STATE_PREGAME)
			dat += "Current Mode: [master_mode], Game has not started yet.<br>"
			if (src.level >= LEVEL_MOD)
				dat += "<A href='?src=\ref[src];action=c_mode_panel'>Change Game Mode</A><br>"
			dat += "<b>Force players to use random names:</b> <A href='?src=\ref[src];action=secretsfun;type=forcerandomnames'>[force_random_names ? "Yes" : "No"]</a><br>"
			dat += "<b>Force players to use random appearances:</b> <A href='?src=\ref[src];action=secretsfun;type=forcerandomlooks'>[force_random_looks ? "Yes" : "No"]</a><br>"
			//dat += "<A href='?src=\ref[src];action=secretsfun;type=forcerandomnames'>Politely suggest all players use random names</a>" // lol
	if (src.level >= LEVEL_SA)
		dat += "<hr>"
		dat += "<A href='?src=\ref[src];action=create_object'>Create Object</A><br>"
		dat += "<A href='?src=\ref[src];action=create_turf'>Create Turf</A><br>"
		dat += "<A href='?src=\ref[src];action=create_mob'>Create Mob</A>"
		// Moved from SG to PA. They can do this through build mode anyway (Convair880).

	dat += "</div>"

	dat += {"<hr><div class='optionGroup' style='border-color:#FF6961'><b class='title' style='background:#FF6961'>Admin Tools</b>
				<A href='?src=\ref[src];action=secretsadmin;type=check_antagonist'>Antagonists</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=jobcaps'>Job Controls</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=respawn_panel'>Respawn Panel</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=randomevents'>Random Event Controls</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=artifacts'>Artifact Controls</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=pathology'>CDC</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=motives'>Motive Control</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=ghostnotifier'>Ghost Notification Controls</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=unelectrify_all'>De-electrify all Airlocks</A><BR>
				<A href='?src=\ref[src];action=secretsadmin;type=manifest'>Crew Manifest</A> |
				<A href='?src=\ref[src];action=secretsadmin;type=DNA'>Blood DNA</A> |
				<A href='?src=\ref[src];action=secretsadmin;type=fingerprints'>Fingerprints</A><BR>
				Player Radio Records/Tapes | <A href='?src=\ref[src];action=radio_audio_toggle'>[player_audio_players ? "ON" : "OFF"]</A>
			"}
#ifdef SECRETS_ENABLED
	dat += {"<A href='?src=\ref[src];action=secretsadmin;type=ideas'>Fun Admin Ideas</A>"}
#endif

	dat += "</div>"

	if (src.level >= LEVEL_ADMIN)
		dat += {"<hr><div class='optionGroup' style='border-color:#FFB347'><b class='title' style='background:#FFB347'>Coder Tools</b>
					<A href='?src=\ref[src];action=secretsdebug;type=budget'>Wages/Money</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=market'>Shipping Market</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=genetics'>Genetics Research</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=jobs'>Jobs</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=hydro'>Hydroponics</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=manuf'>Manufacturing</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=radio'>Communications</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=randevent'>Random Events</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=disease'>Diseases</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=mechanic'>Mechanics</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=artifact'>Artifacts</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=gauntlet'>Gauntlet</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=stock'>Stock Market</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=emshuttle'>Emergency Shuttle</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=datacore'>Data Core</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=miningcontrols'>Mining Controls</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=mapsettings'>Map Settings</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=ghostnotifications'>Ghost Notifications</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=overlays'>Overlays</A>
					<A href='?src=\ref[src];action=secretsdebug;type=overlaysrem'>(Remove)</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=world'>World</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=globals'>Global Variables</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=globalprocs'>Global Procs</A>
				"}

		dat += "</div>"

	dat += {"<hr><div class='optionGroup' style='border-color:#77DD77'><b class='title' style='background:#77DD77'>Logs</b>
				<b><A href='?src=\ref[src];action=view_logs_web'>View all logs - web version</A></b><BR>
				<A href='?src=\ref[src];action=view_logs;type=all_logs_string'>Search all Logs</A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_SPEECH]_log'>Speech Log </A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_SPEECH]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_COMBAT]_log'>Combat Log </A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_COMBAT]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_OOC]_log'>OOC Log </A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_OOC]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_STATION]_log'>Station Log </A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_STATION]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_PDAMSG]_log'>PDA Message Log </A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_PDAMSG]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_TELEPATHY]_log'>Telepathy Log </A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_TELEPATHY]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_ADMIN]_log'>Admin Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_ADMIN]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_GAMEMODE]_log'>Gamemode Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_GAMEMODE]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_DEBUG]_log'>Debug Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_DEBUG]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_AHELP]_log'>Adminhelp Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_AHELP]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_MHELP]_log'>Mentorhelp Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_MHELP]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_BOMBING]_log'>Bombing Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_BOMBING]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_SIGNALERS]_log'>Signaler Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_SIGNALERS]_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_PATHOLOGY]_log'>Pathology Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_PATHOLOGY]_log_string'><small>(Search)</small></A>
				<A href='?src=\ref[src];action=view_logs_pathology_strain'><small>(Find pathogen)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_VEHICLE]_log'>Vehicle Log</A>
				<A href='?src=\ref[src];action=view_logs;type=[LOG_VEHICLE]_log_string'><small>(Search)</small></A><br>
				Topic Log <!-- Viewing the entire log will usually just crash the admin's client, so let's not allow that -->
				<A href='?src=\ref[src];action=view_logs;type=[LOG_TOPIC]_log_string'><small>(Search)</small></A><br>
				<hr>
				<A href='?src=\ref[src];action=view_runtimes'>View Runtimes</A>
			"}

	dat += "</div>"

	// FUN SECRETS PANEL
	if (src.level >= LEVEL_PA || (src.level == LEVEL_SA && usr.client.holder.state == 2))
		dat += {"<hr><div class='optionGroup' style='border-color:#B57EDC'><b class='title' style='background:#B57EDC'>Fun Secrets</b>
					<b>Transformation:</b>
						<A href='?src=\ref[src];action=secretsfun;type=transform_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=transform_all'>All</A><BR>
					<b>Add Bio-Effect<A href='?src=\ref[src];action=secretsfun;type=bioeffect_help'>*</a>:</b>
						<A href='?src=\ref[src];action=secretsfun;type=add_bioeffect_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=add_bioeffect_all'>All</A><BR>
					<b>Remove Bio-Effect:</b>
						<A href='?src=\ref[src];action=secretsfun;type=remove_bioeffect_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=remove_bioeffect_all'>All</A><BR>
					<b>Add Ability:</b>
						<A href='?src=\ref[src];action=secretsfun;type=add_ability_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=add_ability_all'>All</A><BR>
					<b>Remove Ability:</b>
						<A href='?src=\ref[src];action=secretsfun;type=remove_ability_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=remove_ability_all'>All</A><BR>
					<b>Add Reagent<A href='?src=\ref[src];action=secretsfun;type=reagent_help'>*</a>:</b>
						<A href='?src=\ref[src];action=secretsfun;type=add_reagent_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=add_reagent_all'>All</A><BR>
					<b>Remove Reagent:</b>
						<A href='?src=\ref[src];action=secretsfun;type=remove_reagent_one'>One</A> *
						<A href='?src=\ref[src];action=secretsfun;type=remove_reagent_all'>All</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=traitor_all'>Make everyone an Antagonist</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=critterize_all'>Critterize everyone</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=stupify'>Give everyone severe brain damage</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=flipstation'>Set station direction</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=yeolde'>Replace all airlocks with doors</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=woodstation'>Replace all floors and walls with wood</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=ballpit'>Replace all pools with ballpits</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=raiseundead'>Raise all human corpses as undead</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=swaprooms'>Swap station rooms around</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=randomguns'>Give everyone a random firearm</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=timewarp'>Set up a time warp</A><BR>
				"}
	if (src.level >= LEVEL_ADMIN)
		dat += {"<A href='?src=\ref[src];action=secretsfun;type=sawarms'>Give everyone saws for arms</A><BR>
				<A href='?src=\ref[src];action=secretsfun;type=emag_all_things'>Emag everything</A><BR>
				<A href='?src=\ref[src];action=secretsfun;type=noir'>Noir</A><BR>
				<A href='?src=\ref[src];action=secretsfun;type=the_great_switcharoo'>The Great Switcharoo</A><BR>
				<A href='?src=\ref[src];action=secretsfun;type=fartyparty'>Farty Party All The Time</A><BR>
		"}

	dat += "</div>"

	if (src.level >= LEVEL_ADMIN || (src.level == LEVEL_SA && usr.client.holder.state == 2))
		dat += {"<hr><div class='optionGroup' style='border-color:#92BB78'><b class='title' style='background:#92BB78'>Roleplaying Panel</b>
					<A href='?src=\ref[src];action=secretsfun;type=shakecamera'>Apply camera shake</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=creepifystation'>Creepify station</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=command_report_zalgo'>Command Report (Zalgo)</A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=command_report_void'>Command Report (Void)</A><BR>
				"}

	dat += "</div>"

	usr.Browse(dat, "window=gamepanel")
	return

/datum/admins/proc/restart()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Restart"
	set desc= "Restarts the world"

	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		boutput(world, "<span class='alert'><b>Restarting world!</b></span> <span class='notice'>Initiated by [admin_key(usr.client, 1)]!</span>")
		logTheThing(LOG_ADMIN, usr, "initiated a reboot.")
		logTheThing(LOG_DIARY, usr, "initiated a reboot.", "admin")

		var/ircmsg[] = new()
		ircmsg["key"] = usr.client.key
		ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
		ircmsg["msg"] = "manually restarted the server."
		ircbot.export_async("admin", ircmsg)

		round_end_data(2) //Wire: export_async round end packet (manual restart)

		sleep(3 SECONDS)
		Reboot_server()

/datum/admins/proc/announce()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Announce"
	set desc="Announce your desires to the world"
	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if (message)
		if(usr.client.holder.rank != "Coder" && usr.client.holder.rank != "Host")
			message = adminscrub(message,500)
		boutput(world, "<span class='notice'><b>[admin_key(usr.client, 1)] Announces:</b><br>&emsp; [message]</span>")
		logTheThing(LOG_ADMIN, usr, ": [message]")
		logTheThing(LOG_DIARY, usr, ": [message]", "admin")

/datum/admins/proc/startnow()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(!ticker)
		tgui_alert(usr,"Unable to start the game as it is not set up.")
		return
	if(current_state <= GAME_STATE_PREGAME)
		current_state = GAME_STATE_SETTING_UP
		logTheThing(LOG_ADMIN, usr, "has started the game.")
		logTheThing(LOG_DIARY, usr, "has started the game.", "admin")
		message_admins("<span class='internal'>[usr.key] has started the game.</span>")
		return 1
	else
		//tgui_alert(usr,"Game has already started you fucking jerk, stop spamming up the chat :ARGH:") //no, FUCK YOU coder, for making this annoying popup
		boutput(usr,"Game is already started.")
		return 0

/datum/admins/proc/delay_start()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Delay the game start"
	set name="Delay Round Start"

	if (current_state > GAME_STATE_PREGAME)
		return tgui_alert(usr,"Too late... The game has already started!")
	game_start_delayed = !(game_start_delayed)

	if (game_start_delayed)
		boutput(world, "<b>The game start has been delayed.</b>")
		logTheThing(LOG_ADMIN, usr, "delayed the game start.")
		logTheThing(LOG_DIARY, usr, "delayed the game start.", "admin")
		message_admins("<span class='internal'>[usr.key] has delayed the game start.</span>")
	else
		boutput(world, "<b>The game will start soon.</b>")
		logTheThing(LOG_ADMIN, usr, "removed the game start delay.")
		logTheThing(LOG_DIARY, usr, "removed the game start delay.", "admin")
		message_admins("<span class='internal'>[usr.key] has removed the game start delay.</span>")

/datum/admins/proc/delay_end()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Delay the server restart"
	set name="Delay Round End"

	if (game_end_delayed == 2)
		logTheThing(LOG_ADMIN, usr, "removed the restart delay and triggered an immediate restart.")
		logTheThing(LOG_DIARY, usr, "removed the restart delay and triggered an immediate restart.", "admin")
		message_admins("<span class='internal'>[usr.key] removed the restart delay and triggered an immediate restart.</span>")
		ircbot.event("roundend")
		Reboot_server()

	else if (game_end_delayed == 0)
		game_end_delayed = 1
		game_end_delayer = usr.key
		logTheThing(LOG_ADMIN, usr, "delayed the server restart.")
		logTheThing(LOG_DIARY, usr, "delayed the server restart.", "admin")
		message_admins("<span class='internal'>[usr.key] delayed the server restart.</span>")

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
		message_admins("<span class='internal'>[usr.key] removed the restart delay.</span>")

		var/ircmsg[] = new()
		ircmsg["key"] = (usr?.client) ? usr.client.key : "NULL"
		ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
		ircmsg["msg"] = "has removed the server restart delay."
		ircbot.export_async("admin", ircmsg)

/mob/proc/revive()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.full_heal()
		H.stamina = H.stamina_max
		H.remove_ailments() // don't spawn with heart failure
	return

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/checktraitor(mob/M as mob)
	set popup_menu = 0
	if(!M || !M.mind || !ticker || !ticker.mode)
		return 0

	if (istraitor(M))
		return 1

	if (istype(ticker.mode, /datum/game_mode/revolution))
		if(M.mind in (ticker.mode:head_revolutionaries + ticker.mode:revolutionaries))
			return 1
	else if (istype(ticker.mode, /datum/game_mode/nuclear))
		if(M.mind in ticker.mode:syndicates)
			return 1
	else if (istype(ticker.mode, /datum/game_mode/spy))
		if(M.mind in (ticker.mode:leaders + ticker.mode:spies))
			return 1
	else if (istype(ticker.mode, /datum/game_mode/gang))
		if(M.mind in (ticker.mode:leaders))
			return 1
		for(var/datum/gang/G in ticker.mode:gangs)
			if(M.mind in G.members)
				return 1

	if(M.mind in ticker.mode:traitors)
		return 1
	if(M.mind in ticker.mode:Agimmicks)
		return 1

	return 0

/datum/admins/proc/evilize(mob/M as mob, var/traitor_type, var/special = null, var/mass_traitor_obj = null, var/mass_traitor_esc = null)
	if (!M || !traitor_type)
		boutput(usr, "<span class='alert'>No mob or traitor type specified.</span>")
		return
	if (!src.level >= LEVEL_SA)
		boutput(usr, "<span class='alert'>You need to be a Secondary Administrator or above to use this command.</span>")
		return
	if(isdead(M) || isobserver(M))
		boutput(usr, "<span class='alert'>You cannot make someone who is dead an antagonist.</span>")
		return
	if (istype(M,/mob/new_player/))
		boutput(usr, "<span class='alert'>You cannot make someone who has not entered the game an antagonist.</span>")
		return
	if (!M.client)
		boutput(usr, "<span class='alert'>You cannot make someone who is logged out an antagonist.</span>")
		return
	if(checktraitor(M))
		boutput(usr, "<span class='alert'>That person is already an antagonist.</span>")
		return
	if(!(ticker?.mode && istype(ticker.mode, /datum/game_mode/gang)) && traitor_type == ROLE_GANG_LEADER)
		boutput(usr, "<span class='alert'>Gang Leaders are currently restricted to gang mode only.</span>")
		return

	traitor_type = lowertext(traitor_type)
	special = lowertext(special)

	if(mass_traitor_obj)
		new /datum/objective(mass_traitor_obj, M.mind)

		if(mass_traitor_esc)
			new mass_traitor_esc(null, M.mind)
	else
		var/list/eligible_objectives = list()
		if (ishuman(M) || ismobcritter(M))
			eligible_objectives = typesof(/datum/objective/regular/) + typesof(/datum/objective/escape/)
		else if (issilicon(M))
			eligible_objectives = list(/datum/objective/regular,/datum/objective/regular/assassinate,
			/datum/objective/regular/force_evac_time,/datum/objective/regular/gimmick,/datum/objective/escape,/datum/objective/escape/hijack,
			/datum/objective/escape/survive,/datum/objective/escape/kamikaze)
			/*if (isrobot(M))
				eligible_objectives += /datum/objective/regular/borgdeath*/
			traitor_type = ROLE_TRAITOR
		switch(traitor_type)
			if (ROLE_CHANGELING)
				eligible_objectives += /datum/objective/specialist/absorb
			if (ROLE_WEREWOLF)
				eligible_objectives += /datum/objective/specialist/werewolf/feed
			if (ROLE_VAMPIRE)
				eligible_objectives += /datum/objective/specialist/drinkblood
			if (ROLE_HUNTER)
				eligible_objectives += /datum/objective/specialist/hunter/trophy
			if (ROLE_GRINCH)
				eligible_objectives += /datum/objective/specialist/ruin_xmas
			if (ROLE_GANG_LEADER)
				new /datum/objective/specialist/gang(null, M.mind)
				M.mind.special_role = ROLE_GANG_LEADER
		var/done = 0
		var/select_objective = null
		var/custom_text = "Go hog wild!"
		while (done != 1)
			select_objective = input(usr, "Add a new objective. Hit cancel when finished adding.", "Traitor Objectives") as null|anything in eligible_objectives
			if (!select_objective)
				done = 1
				break
			if (select_objective == /datum/objective/regular)
				custom_text = input(usr,"Enter custom objective text.","Traitor Objectives","Go hog wild!") as null|text
				if (custom_text)
					new select_objective(custom_text, M.mind)
				else
					boutput(usr, "<span class='alert'>No text was entered. Objective not given.</span>")
			else
				new select_objective(null, M.mind)

		if (M.mind.objectives.len < 1)
			boutput(usr, "<span class='alert'>Not enough objectives specified.</span>")
			return

	if (isAI(M))
		var/mob/living/silicon/ai/A = M
		A.syndicate = 1
		A.syndicate_possible = 1
		A.make_syndicate("admin")
	else if (isrobot(M))
		var/mob/living/silicon/robot/R = M
		if (R.dependent)
			boutput(usr, "<span class='alert'>You can't evilize AI-controlled shells.</span>")
			return
		R.syndicate = 1
		R.syndicate_possible = 1
		R.make_syndicate("admin")
	else if (ishuman(M) || ismobcritter(M))
		switch(traitor_type)
			if(ROLE_TRAITOR)
				M.show_text("<h2><font color=red><B>You have defected and become a traitor!</B></font></h2>", "red")
				if(special != "hardmode")
					M.mind.special_role = ROLE_TRAITOR
					M.verbs += /client/proc/gearspawn_traitor
					M.show_antag_popup("traitorradio")
				else
					M.mind.special_role = ROLE_HARDMODE_TRAITOR
					M.show_antag_popup("traitorhard")
			if(ROLE_CHANGELING)
				M.mind.special_role = ROLE_CHANGELING
				M.show_text("<h2><font color=red><B>You have mutated into a changeling!</B></font></h2>", "red")
				M.make_changeling()
			if(ROLE_WIZARD)
				M.mind.special_role = ROLE_WIZARD
				M.show_text("<h2><font color=red><B>You have been seduced by magic and become a wizard!</B></font></h2>", "red")
				M.show_antag_popup("adminwizard")
				M.verbs += /client/proc/gearspawn_wizard
			if(ROLE_VAMPIRE)
				M.mind.special_role = ROLE_VAMPIRE
				M.show_text("<h2><font color=red><B>You have joined the ranks of the undead and are now a vampire!</B></font></h2>", "red")
				M.make_vampire()
			if(ROLE_HUNTER)
				M.show_text("<h2><font color=red><B>You have become a hunter!</B></font></h2>", "red")
				M.mind.add_antagonist(ROLE_HUNTER, do_equip = FALSE, do_relocate = FALSE)
			if(ROLE_WRESTLER)
				M.mind.special_role = ROLE_WRESTLER
				M.show_text("<h2><font color=red><B>You feel an urgent need to wrestle!</B></font></h2>", "red")
				M.make_wrestler(1)
			if(ROLE_WEREWOLF)
				M.mind.special_role = ROLE_WEREWOLF
				M.show_text("<h2><font color=red><B>You have become a werewolf!</B></font></h2>", "red")
				M.make_werewolf()
			if(ROLE_GRINCH)
				M.mind.special_role = ROLE_GRINCH
				M.make_grinch()
				M.show_text("<h2><font color=red><B>You have become a grinch!</B></font></h2>", "red")
			if(ROLE_FLOOR_GOBLIN)
				M.mind.special_role = ROLE_FLOOR_GOBLIN
				M.make_floor_goblin()
				M.show_antag_popup("traitorhard")
				M.show_text("<h2><font color=red><B>You have become a floor goblin!</B></font></h2>", "red")
			if(ROLE_ARCFIEND)
				M.show_text("<h2><font color=red><B>You feel starved for power!</B></font></h2>", "red")
				M.mind.add_antagonist(ROLE_ARCFIEND)
			if(ROLE_GANG_LEADER)
				// hi so this tried in the past to make someone a gang leader without, uh, giving them a gang
				// seeing as gang leaders are only allowed during the gang gamemode, this should work
				// error checks included anyways
				if(istype(ticker)) // the day we assume the foundation of the world exists is the day it crumbles into sand
					var/datum/game_mode/gang/G = ticker.mode
					if(istype(G))
						G.generate_gang(M.mind)
					else
						boutput(usr, "<span class='alert'>The game mode isn't gang (or something is deeply fucked up).</span>")
						return

				boutput(M, "<h1><font color=red>You are the leader of the [M.mind.gang.gang_name] gang!</font></h1>")
				boutput(M, "<span class='alert'>You must recruit people to your cause and fight other gangs!</span>")
				boutput(M, "<span class='alert'>You may kill anyone you want, but are advised to convince them to join you instead!</span>")
				boutput(M, "<span class='alert'>You can use the Set Gang Base command once which will make your current area into your gang's base and spawn a locker.</span>")
				boutput(M, "<span class='alert'>You can get gear from your gang's locker. You must store guns, drugs and cash there for points.</span>")
				boutput(M, "<span class='alert'>People can join your gang by reading a flyer, obtained from your gang locker.</span>")
				boutput(M, "<span class='alert'>Your objectives are to <b>kill the opposing gang leaders</b>, and <b>stash guns, drugs and cash in your locker</b>.</span>")
				M.verbs += /client/proc/set_gang_base
				tgui_alert(M, "Use the Set Gang Base verb to claim a home turf, and start recruiting people with flyers from the locker!", "You are a gang leader!")
			if(ROLE_OMNITRAITOR)
				M.mind.special_role = ROLE_OMNITRAITOR
				M.verbs += /client/proc/gearspawn_traitor
				M.verbs += /client/proc/gearspawn_wizard
				M.make_changeling()
				M.make_vampire()
				M.make_werewolf()
				M.make_wrestler(1)
				M.make_grinch()
				M.show_text("<h2><font color=red><B>You have become an omnitraitor!</B></font></h2>", "red")
				M.show_antag_popup("traitoromni")
			if(ROLE_SPY_THIEF)
				if (M.stat || !isliving(M) || isintangible(M) || !ishuman(M) || !M.mind)
					return
				M.show_text("<h1><font color=red><B>You have defected to a Spy Thief!</B></font></h1>", "red")
				M.mind.special_role = ROLE_SPY_THIEF
				var/mob/living/carbon/human/tmob = M
				var/objective_set_path = /datum/objective_set/spy_theft
				new objective_set_path(M.mind)
				equip_spy_theft(tmob)

	else
		M.show_text("<h2><font color=red><B>You have become evil and are now an antagonist!</B></font></h2>", "red")

	if (!(M.mind in ticker.mode.Agimmicks))
		ticker.mode.Agimmicks += M.mind

	if (M.mind.current)
		M.mind.current.antagonist_overlay_refresh(1, 0)

	var/obj_count = 1
	for(var/datum/objective/OBJ in M.mind.objectives)
		boutput(M, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
		obj_count++

	//to stop spamming during traitor all secret
	if(!mass_traitor_obj)
		logTheThing(LOG_ADMIN, usr, "made [constructTarget(M,"admin")] a[special ? " [special]" : ""] [traitor_type].")
		logTheThing(LOG_DIARY, usr, "made [constructTarget(M,"diary")] a[special ? " [special]" : ""] [traitor_type].", "admin")
		message_admins("<span class='internal'>[key_name(usr)] has made [key_name(M)] a[special ? " [special]" : ""] [traitor_type].</span>")
	return

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

/proc/get_one_match(var/object, var/base = /atom, use_concrete_types=TRUE, only_admin_spawnable=TRUE)
	var/list/matches = get_matches(object, base, use_concrete_types, only_admin_spawnable)

	if(!length(matches))
		return null

	var/chosen
	if(length(matches) == 1)
		chosen = text2path(matches[1])
	else
		var/safe_matches = matches - list("/database", "/client", "/icon", "/sound", "/savefile")
		chosen = text2path(tgui_input_list(usr, "Select an atom type", "Matches for pattern", safe_matches))
		if(!chosen)
			return FALSE // need to return something other than null to distinguish between "didn't find anything" and hitting 'cancel'

	. = chosen

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
	if( !C.cloud_available() )
		tgui_alert( "Failed to communicate to Goonhub." )
		return
	var/built = {"<title>Chat Bans (todo: prettify)</title>"}
	if(C.cloud_get( "adminhelp_banner" ))
		built += "<a href='?src=\ref[src];target=\ref[C];action=ah_unmute' class='alert'>Adminhelp Mute</a> (Last by [C.cloud_get( "adminhelp_banner" )])<br/>"
		logTheThing(LOG_ADMIN, src, "unmuted [constructTarget(C,"admin")] from adminhelping.")
	else
		built += "<a href='?src=\ref[src];target=\ref[C];action=ah_mute'>Adminhelp Mute</a><br/>"
		logTheThing(LOG_ADMIN, src, "muted [constructTarget(C,"admin")] from adminhelping.")

	if(C.cloud_get( "mentorhelp_banner" ))
		built += "<a href='?src=\ref[src];target=\ref[C];action=mh_unmute' class='alert'>Mentorhelp Mute</a> (Last by [C.cloud_get( "mentorhelp_banner" )])<br/>"
		logTheThing(LOG_ADMIN, src, "unmuted [constructTarget(C,"admin")] from mentorhelping.")
	else
		built += "<a href='?src=\ref[src];target=\ref[C];action=mh_mute'>Mentorhelp Mute</a><br/>"
		logTheThing(LOG_ADMIN, src, "muted [constructTarget(C,"admin")] from mentorhelping.")

	if(C.cloud_get( "prayer_banner" ))
		built += "<a href='?src=\ref[src];target=\ref[C];action=pr_unmute' class='alert'>Prayer Mute</a> (Last by [C.cloud_get( "prayer_banner" )])<br/>"
		logTheThing(LOG_ADMIN, src, "unmuted [constructTarget(C,"admin")] from praying.")
	else
		built += "<a href='?src=\ref[src];target=\ref[C];action=pr_mute'>Prayer Mute</a><br/>"
		logTheThing(LOG_ADMIN, src, "muted [constructTarget(C,"admin")] from praying.")

	usr.Browse(built, "window=chatban;size=500x100")

/datum/admins/proc/managebioeffect_chromosome_clean(var/datum/bioEffect/BE)
//cleanse a bioeffect
	var/datum/bioEffect/power/P = null
	BE.altered = 0
	BE.name = BE.global_instance.name
	if (!BE.stability_loss) //reapply stability changes
		BE.stability_loss = BE.global_instance.stability_loss
		BE.holder.genetic_stability = max(0, BE.holder.genetic_stability -= BE.stability_loss)
	BE.curable_by_mutadone = BE.global_instance.curable_by_mutadone
	BE.reclaim_fail = BE.global_instance.reclaim_fail
	BE.reclaim_mats = BE.global_instance.reclaim_mats
	BE.msgGain = BE.global_instance.msgGain
	BE.msgLose = BE.global_instance.msgLose
	var/oldpower = P.power
	P.power = P.global_instance_power.power
	P.onPowerChange(oldpower, P.power)
	if (istype(BE, /datum/bioEffect/power)) //powers
		P = BE
		P.cooldown = P.global_instance_power.cooldown
		P.safety = P.global_instance_power.safety

/client/proc/cmd_admin_managebioeffect(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Manage Bioeffects"
	set desc = "Select a mob to manage its bioeffects."
	set popup_menu = 0
	ADMIN_ONLY

	var/list/dat = list()
	dat += {"
		<html>
		<head>
		<title>Manage Bioeffects</title>
		<style>
		table {
			border:1px solid #4CAF50;
			border-collapse: collapse;
			width: 100%;
		}

		td {
			padding: 8px;
			text-align: center;
		}

		th:nth-child(n+2):nth-child(-n+3), td:nth-child(n+2):nth-child(-n+3) {text-align: left;}

		th {
			background-color: #4CAF50;
			color: white;
			padding: 8px;
			text-align: center;
		}

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
		<h3>Bioeffects of [M.name]
		<a href='?src=\ref[src.holder];action=managebioeffect_refresh;target=\ref[M];origin=bioeffect_manage' class="button">&#x1F504;</a></h3>
		<h4>(Stability: <a href='?src=\ref[src.holder];action=managebioeffect_alter_genetic_stability;target=\ref[M];origin=bioeffect_manage'>[M.bioHolder.genetic_stability]</a>)
		<a href='?src=\ref[src.holder];action=managebioeffect_add;target=\ref[M];origin=bioeffect_manage' class="button">&#x2795;</a></h4>
		<table>
			<tr>
				<th>Remove</th>
				<th>ID</th>
				<th>Name</th>
				<th>Stable</th>
				<th>Reinforced</th>
				<th>Power Boosted</th>
				<th>Synced</th>
				<th>Cooldown</th>
				<th>Splice</th>
			</tr>
		"}

	for(var/ID in M.bioHolder.effects)
		var/datum/bioEffect/B = M.bioHolder.effects[ID]
		var/datum/bioEffect/power/P = null
		var/is_stable = 0
		var/is_reinforced = 0
		var/is_power_boosted = null //powers only
		var/is_synced = null //powers only
		var/cooldown = null //0 cooldown is a thing, also powers only

		if (!B.stability_loss)
			is_stable = 1
		if (!B.curable_by_mutadone)
			is_reinforced = 1
		if (B.power > 1)
			is_power_boosted = 1
		else
			is_power_boosted = 0
		if (istype(B, /datum/bioEffect/power))//powers only
			P = B
			if (P.safety)
				is_synced = 1
			else
				is_synced = 0
			cooldown = P.cooldown

		dat += {"
			<tr>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_remove;target=\ref[M];bioeffect=[B.id];origin=bioeffect_manage'>remove</a></td>
				<td>[B.id]</td>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_debug_vars;bioeffect=\ref[B];origin=bioeffect_manage'>[B.name]</a></td>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_alter_stable;target=\ref[M];bioeffect=\ref[B];origin=bioeffect_manage'>[is_stable ? "&#x2714;" : "&#x274C;"]</a></td>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_alter_reinforce;target=\ref[M];bioeffect=\ref[B];origin=bioeffect_manage'>[is_reinforced ? "&#x2714;" : "&#x274C;"]</a></td>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_alter_power_boost;target=\ref[M];bioeffect=\ref[B];origin=bioeffect_manage'>[isnull(is_power_boosted) ? "&#x26D4;" : (is_power_boosted ? "&#x2714;" : "&#x274C;")]</a></td>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_alter_sync;target=\ref[M];bioeffect=\ref[B];origin=bioeffect_manage'>[isnull(is_synced) ? "&#x26D4;" : (is_synced ? "&#x2714;" : "&#x274C;")]</a></td>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_alter_cooldown;target=\ref[M];bioeffect=\ref[B];origin=bioeffect_manage'>[isnull(cooldown) ? "&#x26D4;" : cooldown]</a></td>
				<td><a href='?src=\ref[src.holder];action=managebioeffect_chromosome;target=\ref[M];bioeffect=\ref[B];origin=bioeffect_manage'>Splice</a></td>
			</tr>"}
	dat += "</table></body></html>"
	usr.Browse(dat.Join(),"window=bioeffect_manage;size=900x400")

/client/proc/cmd_admin_manageabils(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Manage Abilities"
	set desc = "Select a mob to manage its abilities."
	set popup_menu = 0
	ADMIN_ONLY

	var/list/dat = list()
	dat += {"
		<html>
		<head>
		<title>Ability Management Panel</title>
		<style>
		table {
			border:1px solid #ff4444;
			border-collapse: collapse;
			width: 100%;
		}

		td {
			padding: 8px;
			text-align: left;
		}

		th {
			background-color: #ff4444;
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
			Abilities of [M.name]
			<a href='?src=\ref[src.holder];action=manageabils;target=\ref[M];origin=manageabils' class="button">&#x1F504;</a>
			<a href='?src=\ref[src.holder];action=addabil;target=\ref[M];origin=manageabils' class="button">&#x2795;</a>
		</h1>
		<table>
			<tr>
				<th>Remove</th>
				<th>Name</th>
				<th>Type Path</th>
				<th>Cooldown</th>
			</tr>
		"}

	if (!M.abilityHolder)
		return
	var/list/abils = list()
	if (istype(M.abilityHolder, /datum/abilityHolder/composite))
		var/datum/abilityHolder/composite/CH = M.abilityHolder
		if (CH.holders.len)
			for (var/datum/abilityHolder/AH in CH.holders)
				abils += AH.abilities //get a list of all the different abilities in each holder
	else
		abils += M.abilityHolder.abilities

	for (var/datum/targetable/A in abils)
		dat += {"
			<tr>
				<td><a href='?src=\ref[src.holder];action=manageabils_remove;target=\ref[M];ability=\ref[A];origin=manageabils'>remove</a></td>
				<td><a href='?src=\ref[src.holder];action=manageabilt_debug_vars;ability=\ref[A];origin=manageabils'>[A.name]</a></td>
				<td>[A.type]
				<td><a href='?src=\ref[src.holder];action=manageabils_alter_cooldown;target=\ref[M];ability=\ref[A];origin=manageabils'>[isnull(A.cooldown) ? "&#x26D4;" : A.cooldown]</a></td>
			</tr>"}
	dat += "</table></body></html>"
	usr.Browse(dat.Join(),"window=manageabils;size=700x400")

/client/proc/cmd_admin_managetraits(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Manage Traits"
	set desc = "Select a mob to manage its traits."
	set popup_menu = 0
	ADMIN_ONLY

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
			<a href='?src=\ref[src.holder];action=managetraits;target=\ref[M];origin=managetraits' class="button">&#x1F504;</a>
			<a href='?src=\ref[src.holder];action=addtrait;target=\ref[M];origin=managetraits' class="button">&#x2795;</a>
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
				<td><a href='?src=\ref[src.holder];action=managetraits_remove;target=\ref[M];trait=\ref[trait];origin=managetraits'>remove</a></td>
				<td><a href='?src=\ref[src.holder];action=managetraits_debug_vars;trait=\ref[trait];origin=managetraits'>[trait.name]</a></td>
				<td>[trait.type]
			</tr>"}
	dat += "</table></body></html>"
	usr.Browse(dat.Join(),"window=managetraits;size=700x400")

/client/proc/respawn_target(mob/M as mob in world, var/forced = 0)
	set name = "Respawn Target"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "Respawn a mob"
	set popup_menu = 0
	if (!M) return

	if (!forced && tgui_alert(src, "Respawn [M]?", "Confirmation", list("Yes", "No")) != "Yes")
		return

	logTheThing(LOG_ADMIN, src, "respawned [constructTarget(M,"admin")]")
	logTheThing(LOG_DIARY, src, "respawned [constructTarget(M,"diary")].", "admin")
	message_admins("[key_name(src)] respawned [key_name(M)].")

	var/mob/new_player/newM = new()
	newM.adminspawned = 1

	newM.key = M.key
	if (M.mind)
		M.mind.damned = 0
		M.mind.transfer_to(newM)
	newM.Login()
	newM.sight = SEE_TURFS //otherwise the HUD remains in the login screen
	qdel(M)

	boutput(newM, "<b>You have been respawned.</b>")
	return newM

/client/proc/respawn_self()
	set name = "Respawn Self"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Respawn yourself"

	logTheThing(LOG_ADMIN, src, "respawned themselves.")
	logTheThing(LOG_DIARY, src, "respawned themselves.", "admin")
	message_admins("[key_name(src)] respawned themselves.")

	var/mob/new_player/M = new()

	M.key = usr.client.key
	M.Login()

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
