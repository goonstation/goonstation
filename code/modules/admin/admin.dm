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
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">[irc ? "DISCORD:" : "ADMIN LOG:"]</span> <span class=\"message\">[text]</span></span>"
	for (var/client/C in clients)
		if(!C.holder)
			continue
		if (!asay && rank_to_level(C.holder.rank) < LEVEL_MOD) // No confidential info for goat farts (Convair880).
			continue
		if (C.player_mode)
			if (asay && C.player_mode_asay)
				boutput(C, replacetext(rendered, "%admin_ref%", "\ref[C.holder]"))
			else
				continue
		else
			boutput(C, replacetext(rendered, "%admin_ref%", "\ref[C.holder]")) //this doesnt fail if the placeholder doesnt exist ok dont worry

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
		if (C.mob && C.holder && rank_to_level(C.holder.rank) >= LEVEL_MOD && C.holder.attacktoggle && !C.player_mode)
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
		alert("UM, EXCUSE ME??  YOU AREN'T AN ADMIN, GET DOWN FROM THERE!")
		usr << csound("sound/voice/farts/poo2.ogg")
		return

	if (usr.client != src.owner)
		message_admins("<span class='internal'>[key_name(usr)] has attempted to override the admin panel!</span>")
		logTheThing("admin", usr, null, "tried to use the admin panel without authorization.")
		logTheThing("diary", usr, null, "tried to use the admin panel without authorization.", "admin")
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
	else if (href_list["targetmob"])// they're logged out or an npc, but we still want to mess with their mob
		href_list["target"] = href_list["targetmob"]

	var/originWindow
	// var/adminCkey = usr.client.ckey
	var/client/adminClient = usr.client
	if (href_list["origin"])
		originWindow = href_list["origin"]

	if (!href_list["action"])
		//alert("You must define an action! Yell at Wire if you see this.")
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
			if (src.level >= LEVEL_PA)
				usr.client.toggle_atom_verbs()
				src.show_pref_window(usr)
		if ("toggle_attack_messages")
			if (src.level >= LEVEL_MOD)
				usr.client.toggle_attack_messages()
				src.show_pref_window(usr)
		if ("toggle_hear_prayers")
			if (src.level >= LEVEL_MOD)
				usr.client.holder.hear_prayers = !usr.client.holder.hear_prayers
				src.show_pref_window(usr)
		if ("toggle_audible_prayers")
			if (src.level >= LEVEL_MOD)
				usr.client.holder.audible_prayers = (usr.client.holder.audible_prayers + 1) % 3
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
						if (alert("Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", "OK", "Cancel") == "OK")
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
				if (alert("Use \"[new_key]\" as your Auto Stealth name?", "Confirmation", "OK", "Cancel") == "OK")
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
						if (alert("Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", "OK", "Cancel") == "OK")
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
				if (alert("Use \"[new_key]\" as your Auto Alt Key?", "Confirmation", "OK", "Cancel") == "OK")
					src.auto_alt_key_name = new_key
					src.show_pref_window(usr)
				else
					src.auto_alt_key_name = null
					boutput(usr, "<span class='notice'>Auto Alt Key removed.</span>")
					return

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
						emergency_shuttle.incall()
						command_announcement(call_reason + "<br><b><span class='alert'>It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</span></b>", "The Emergency Shuttle Has Been Called", css_class = "notice")
						logTheThing("admin", usr, null,  "called the Emergency Shuttle (reason: [call_reason])")
						logTheThing("diary", usr, null, "called the Emergency Shuttle (reason: [call_reason])", "admin")
						message_admins("<span class='internal'>[key_name(usr)] called the Emergency Shuttle to the station</span>")

					if("2")
						if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
							return
						switch(emergency_shuttle.direction)
							if(-1)
								emergency_shuttle.incall()
								var/call_reason = input("Enter the reason for the shuttle call (or just hit OK to give no reason)","Shuttle Call Reason","") as null|text
								if(!call_reason)
									call_reason = "No reason given."
								emergency_shuttle.incall()
								command_announcement(call_reason + "<br><b><span class='alert'>It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.</span></b>", "The Emergency Shuttle Has Been Called", css_class = "notice")
								logTheThing("admin", usr, null, "called the Emergency Shuttle (reason: [call_reason])")
								logTheThing("diary", usr, null, "called the Emergency Shuttle (reason: [call_reason])", "admin")
								message_admins("<span class='internal'>[key_name(usr)] called the Emergency Shuttle to the station</span>")
							if(1)
								emergency_shuttle.recall()
								boutput(world, "<span class='notice'><B>Alert: The shuttle is going back!</B></span>")
								logTheThing("admin", usr, null, "sent the Emergency Shuttle back")
								logTheThing("diary", usr, null, "sent the Emergency Shuttle back", "admin")
								message_admins("<span class='internal'>[key_name(usr)] recalled the Emergency Shuttle</span>")
			else
				alert("You need to be at least a Secondary Administrator to do a shuttle call.")

		if("edit_shuttle_time")
			if (src.level >= LEVEL_PA)
				var/timeleft = input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", emergency_shuttle.timeleft()) as null|num
				if (isnull(timeleft))
					return
				emergency_shuttle.settimeleft(timeleft)
				logTheThing("admin", usr, null, "edited the Emergency Shuttle's timeleft to [timeleft]")
				logTheThing("diary", usr, null, "edited the Emergency Shuttle's timeleft to [timeleft]", "admin")
				message_admins("<span class='internal'>[key_name(usr)] edited the Emergency Shuttle's timeleft to [timeleft]</span>")
			else
				alert("You need to be at least a Primary Administrator to edit the shuttle timer.")

		if("toggle_shuttle_calling")
			if (src.level >= LEVEL_PA)
				emergency_shuttle.disabled = !emergency_shuttle.disabled
				logTheThing("admin", usr, null, "[emergency_shuttle.disabled ? "dis" : "en"]abled calling the Emergency Shuttle")
				logTheThing("diary", usr, null, "[emergency_shuttle.disabled ? "dis" : "en"]abled calling the Emergency Shuttle", "admin")
				message_admins("<span class='internal'>[key_name(usr)] [emergency_shuttle.disabled ? "dis" : "en"]abled calling the Emergency Shuttle</span>")
				// someone forgetting about leaving shuttle calling disabled would be bad so let's inform the Admin Crew if it happens, just in case
				var/ircmsg[] = new()
				ircmsg["key"] = src.owner:key
				ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
				ircmsg["msg"] = "Has [emergency_shuttle.disabled ? "dis" : "en"]abled calling the Emergency Shuttle"
				ircbot.export("admin", ircmsg)
			else
				alert("You need to be at least a Primary Administrator to enable/disable shuttle calling.")

		if("toggle_shuttle_recalling")
			if (src.level >= LEVEL_PA)
				emergency_shuttle.can_recall = !emergency_shuttle.can_recall
				logTheThing("admin", usr, null, "[emergency_shuttle.can_recall ? "en" : "dis"]abled recalling the Emergency Shuttle")
				logTheThing("diary", usr, null, "[emergency_shuttle.can_recall ? "en" : "dis"]abled recalling the Emergency Shuttle", "admin")
				message_admins("<span class='internal'>[key_name(usr)] [emergency_shuttle.can_recall ? "en" : "dis"]abled recalling the Emergency Shuttle</span>")
			else
				alert("You need to be at least a Primary Administrator to enable/disable shuttle recalling.")

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
						alert("You need to be at least a Secondary Administrator to delete notes.")
						return

					if(href_list["id"])
						if(alert("Delete This Note?",,"Yes","No") == "No")
							return
						else
							var/noteId = href_list["id"]

							deletePlayerNote(noteId)
							src.viewPlayerNotes(player)

							logTheThing("admin", usr, null, "deleted note [noteId] belonging to [player].")
							logTheThing("diary", usr, null, "deleted note [noteId] belonging to [player].", "admin")
							message_admins("<span class='internal'>[key_name(usr)] deleted note [noteId] belonging to <A href='?src=%admin_ref%;action=notes&target=[player]'>[player]</A>.</span>")

							var/ircmsg[] = new()
							ircmsg["key"] = src.owner:key
							ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
							ircmsg["msg"] = "Deleted note [noteId] belonging to [player]"
							ircbot.export("admin", ircmsg)

				if("add")
					if(src.level < LEVEL_SA)
						alert("You need to be at least a Secondary Adminstrator to add notes.")
						return

					var/the_note = input("Write your note here!", "Note for [player]") as null|message
					if (isnull(the_note) || !length(the_note))
						return

					addPlayerNote(player, usr.ckey, the_note)
					SPAWN_DBG(2 SECONDS) src.viewPlayerNotes(player)

					logTheThing("admin", usr, null, "added a note for [player]: [the_note]")
					logTheThing("diary", usr, null, "added a note for [player]: [the_note]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] added a note for <A href='?src=%admin_ref%;action=notes&target=[player]'>[player]</A>: [the_note]</span>")

					var/ircmsg[] = new()
					ircmsg["key"] = src.owner:key
					ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
					ircmsg["msg"] = "Added a note for [player]: [the_note]"
					ircbot.export("admin", ircmsg)

		if("viewcompids")
			var/player = href_list["targetckey"]

			if(src.tempmin)
				logTheThing("admin", usr, player, "tried to access the compIDs of [constructTarget(player,"admin")]")
				logTheThing("diary", usr, player, "tried to access the compIDs of [constructTarget(player,"diary")]", "admin")
				alert("You need to be an actual admin to view compIDs.")
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
				alert("You need to be at least a Secondary Administrator to edit bans.")

		if("unbanf") //Delete ban
			if (src.level >= LEVEL_SA)
				var/id = html_decode(href_list["id"])
				var/ckey = html_decode(href_list["target"])
				var/compID = html_decode(href_list["compID"])
				var/ip = html_decode(href_list["ip"])
				var/akey = usr.client.ckey

				usr.client.deleteBanDialog(id, ckey, compID, ip, akey)
			else
				alert("You need to be at least a Secondary Administrator to remove bans.")
		/////////////////////////////////////end ban stuff

		if("jobbanpanel")
			var/mob/M = locate(href_list["target"])
			var/dat = ""
			var/header = "<b>Pick Job to ban this guy from.<br>"
			var/body
	//		var/list/alljobs = get_all_jobs()
			var/jobs = ""

			if (!M) return

			for(var/job in uniquelist(occupations))
				if(job in list("Tourist","Mining Supervisor","Atmospheric Technician","Vice Officer"))
					continue
				if(jobban_isbanned(M, job))
					jobs += "<a href='?src=\ref[src];action=jobban;type=[job];target=\ref[M]'><font color=red>[replacetext(job, " ", "&nbsp")]</font></a> "
				else
					jobs += "<a href='?src=\ref[src];action=jobban;type=[job];target=\ref[M]'>[replacetext(job, " ", "&nbsp")]</a> " //why doesn't this work

			if(jobban_isbanned(M, "Captain"))
				jobs += "<a href='?src=\ref[src];action=jobban;type=Captain;target=\ref[M]'><font color=red>Captain</font></a> "
			else
				jobs += "<a href='?src=\ref[src];action=jobban;type=Captain;target=\ref[M]'>Captain</a> " //why doesn't this work

			if(jobban_isbanned(M, "Head of Security"))
				jobs += "<a href='?src=\ref[src];action=jobban;type=Head of Security;target=\ref[M]'><font color=red>Head of Security</font></a> "
			else
				jobs += "<a href='?src=\ref[src];action=jobban;type=Head of Security;target=\ref[M]'>Head of Security</a> "

			if(jobban_isbanned(M, "Syndicate"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Syndicate;target=\ref[M]'><font color=red>[replacetext("Syndicate", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Syndicate;target=\ref[M]'>[replacetext("Syndicate", " ", "&nbsp")]</a> " //why doesn't this work

			if(jobban_isbanned(M, "Special Respawn"))
				jobs += " <a href='?src=\ref[src];action=jobban;type=Special Respawn;target=\ref[M]'><font color=red>[replacetext("Special Respawn", " ", "&nbsp")]</font></a> "
			else
				jobs += " <a href='?src=\ref[src];action=jobban;type=Special Respawn;target=\ref[M]'>[replacetext("Special Respawn", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Engineering Department"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Engineering Department;target=\ref[M]'><font color=red>[replacetext("Engineering Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Engineering Department;target=\ref[M]'>[replacetext("Engineering Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Security Department"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Security Department;target=\ref[M]'><font color=red>[replacetext("Security Department", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Security Department;target=\ref[M]'>[replacetext("Security Department", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Heads of Staff"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Heads of Staff;target=\ref[M]'><font color=red>[replacetext("Heads of Staff", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Heads of Staff;target=\ref[M]'>[replacetext("Heads of Staff", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Everything Except Assistant"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Everything Except Assistant;target=\ref[M]'><font color=red>[replacetext("Everything Except Assistant", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Everything Except Assistant;target=\ref[M]'>[replacetext("Everything Except Assistant", " ", "&nbsp")]</a> "

			if(jobban_isbanned(M, "Ghostdrone"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Ghostdrone;target=\ref[M]'><font color=red>Ghostdrone</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Ghostdrone;target=\ref[M]'>Ghostdrone</a> "

			if(jobban_isbanned(M, "Custom Names"))
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Custom Names;target=\ref[M]'><font color=red>[replacetext("Having a Custom Name", " ", "&nbsp")]</font></a> "
			else
				jobs += "<BR><a href='?src=\ref[src];action=jobban;type=Custom Names;target=\ref[M]'>[replacetext("Having a Custom Name", " ", "&nbsp")]</a> "


			body = "<br>[jobs]<br><br>"
			dat = "<tt>[header][body]</tt>"
			usr.Browse(dat, "window=jobban2;size=600x150")

		if("jobban")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/job = href_list["type"]
				if (!M) return
				if ((M.client && M.client.holder && (M.client.holder.level > src.level)))
					alert("You cannot perform this action. You must be of a higher administrative rank!")
					return
				if (jobban_isbanned(M, job))
					if(jobban_keylist.Find(text("[M.ckey] - Everything Except Assistant")) && job != "Everything Except Assistant")
						alert("This person is banned from Everything Except Assistant. You must lift that ban first.")
						return
					if(job in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
						if(jobban_keylist.Find(text("[M.ckey] - Engineering Department")))
							alert("This person is banned from Engineering Department. You must lift that ban first.")
							return
					if(job in list("Security Officer","Vice Officer","Detective"))
						if(jobban_keylist.Find(text("[M.ckey] - Security Department")))
							alert("This person is banned from Security Department. You must lift that ban first.")
							return
					if(job in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
						if(jobban_keylist.Find(text("[M.ckey] - Heads of Staff")))
							alert("This person is banned from Heads of Staff. You must lift that ban first.")
							return
					logTheThing("admin", usr, M, "unbanned [constructTarget(M,"admin")] from [job]")
					logTheThing("diary", usr, M, "unbanned [constructTarget(M,"diary")] from [job]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] unbanned [key_name(M)] from [job]</span>")
					addPlayerNote(M.ckey, usr.ckey, "[usr.ckey] unbanned [M.ckey] from [job]")
					jobban_unban(M, job)
					if (announce_jobbans) boutput(M, "<span class='alert'><b>[key_name(usr)] has lifted your [job] job-ban.</b></span>")
				else
					logTheThing("admin", usr, M, "banned [constructTarget(M,"admin")] from [job]")
					logTheThing("diary", usr, M, "banned [constructTarget(M,"diary")] from [job]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] banned [key_name(M)] from [job]</span>")
					addPlayerNote(M.ckey, usr.ckey, "[usr.ckey] banned [M.ckey] from [job]")
					if(job == "Everything Except Assistant")
						if(jobban_keylist.Find(text("[M.ckey] - Engineering Department")))
							jobban_unban(M,"Engineering Department")
						if(jobban_keylist.Find(text("[M.ckey] - Security Department")))
							jobban_unban(M,"Security Department")
						if(jobban_keylist.Find(text("[M.ckey] - Heads of Staff")))
							jobban_unban(M,"Heads of Staff")
						for(var/Trank1 in uniquelist(occupations))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank1]")))
								jobban_unban(M,Trank1)
					else if(job == "Engineering Department")
						for(var/Trank2 in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank2]")))
								jobban_unban(M,Trank2)
					else if(job == "Security Department")
						for(var/Trank3 in list("Security Officer","Vice Officer","Detective"))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank3]")))
								jobban_unban(M,Trank3)
					else if(job == "Heads of Staff")
						for(var/Trank4 in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director"))
							if(jobban_keylist.Find(text("[M.ckey] - [Trank4]")))
								jobban_unban(M,Trank4)
					jobban_fullban(M, job)
					if (announce_jobbans) boutput(M, "<span class='alert'><b>[key_name(usr)] has job-banned you from [job].</b></span>")
			else
				alert("You need to be at least a Secondary Administrator to work with job bans.")

		if ("boot")
			var/mob/M = locate(href_list["target"])
			usr.client.cmd_boot(M)

		if ("removejobban")
			if (src.level >= LEVEL_SA)
				var/t = href_list["target"]
				if(t)
					logTheThing("admin", usr, null, "removed [t]")
					logTheThing("diary", usr, null, "removed [t]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] removed [t]</span>")
					jobban_remove(t)
			else
				alert("You need to be at least a Secondary Administrator to remove job bans.")

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
					logTheThing("admin", usr, M, "has [(muted ? "permanently muted" : "unmuted")] [constructTarget(M,"admin")]")
					logTheThing("diary", usr, M, "has [(muted ? "permanently muted" : "unmuted")] [constructTarget(M,"diary")].", "admin")
					message_admins("<span class='internal'>[key_name(usr)] has [(muted ? "permanently muted" : "unmuted")] [key_name(M)].</span>")
					boutput(M, "You have been [(muted ? "permanently muted" : "unmuted")].")
			else
				alert("You need to be at least a Moderator to mute people.")

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
					logTheThing("admin", usr, M, "has [(muted ? "temporarily muted" : "unmuted")] [constructTarget(M,"admin")]")
					logTheThing("diary", usr, M, "has [(muted ? "temporarily muted" : "unmuted")] [constructTarget(M,"diary")].", "admin")
					message_admins("<span class='internal'>[key_name(usr)] has [(muted ? "temporarily muted" : "unmuted")] [key_name(M)].</span>")
					boutput(M, "You have been [(muted ? "temporarily muted" : "unmuted")].")
			else
				alert("You need to be at least a Moderator to mute people.")
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
					logTheThing("admin", usr, M, "has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [constructTarget(M,"admin")]")
					logTheThing("diary", usr, M, "has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [constructTarget(M,"diary")].", "admin")
					message_admins("<span class='internal'>[key_name(usr)] has [(oocbanned ? "OOC Banned" : "OOC Unbanned")] [key_name(M)].</span>")

		if ("toggle_hide_mode")
			if (src.level >= LEVEL_SA)
				ticker.hide_mode = !ticker.hide_mode
				Topic(null, list("src" = "\ref[src]", "action" = "c_mode_panel"))
			else
				alert("You need to be at least a Secondary Administrator to hide the game mode.")

		if ("c_mode_panel") // I removed some broken/discontinued game modes here (Convair880).
			if (src.level >= LEVEL_SA)
				var/cmd = "c_mode_current"
				var/addltext = ""
				if (current_state > GAME_STATE_PREGAME)
					cmd = "c_mode_next"
					addltext = " next round"
				var/dat = {"
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
							<b>Other Modes</b><br>
							<A href='?src=\ref[src];action=[cmd];type=extended'>Extended</A><br>
							<A href='?src=\ref[src];action=[cmd];type=flock'>Flock(probably wont work. Press at own risk)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=disaster'>Disaster (Beta)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=spy'>Spy</A><br>
							<A href='?src=\ref[src];action=[cmd];type=revolution'>Revolution</A><br>
							<A href='?src=\ref[src];action=[cmd];type=revolution_extended'>Revolution (no time limit)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=gang'>Gang War (Beta)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=battle_royale'>Battle Royale</A><br>
							<A href='?src=\ref[src];action=[cmd];type=assday'>Ass Day Classic (For testing only.)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=construction'>Construction (For testing only. Don't select this!)</A><br>
							<A href='?src=\ref[src];action=[cmd];type=football'>Football (this only works if built with FOOTBALL_MODE sorry too lazy to ifdef here)</A>
							</body></html>
						"}
				usr.Browse(dat, "window=c_mode")
			else
				alert("You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("c_mode_current")
			if (src.level >= LEVEL_SA)
				if (current_state > GAME_STATE_PREGAME)
					return alert(usr, "The game has already started.", null, null, null, null)

				var/list/valid_modes = list("secret","action","intrigue","random","traitor","meteor","extended","monkey",
				"nuclear","blob","restructuring","wizard","revolution", "revolution_extended","malfunction",
				"spy","gang","disaster","changeling","vampire","mixed","mixed_rp", "construction","conspiracy","spy_theft","battle_royale", "vampire","assday", "football", "flock")

				var/requestedMode = href_list["type"]
				if (requestedMode in valid_modes)
					logTheThing("admin", usr, null, "set the mode as [requestedMode].")
					logTheThing("diary", usr, null, "set the mode as [requestedMode].", "admin")
					message_admins("<span class='internal'>[key_name(usr)] set the mode as [requestedMode].</span>")
					world.save_mode(requestedMode)
					master_mode = requestedMode
					if(master_mode == "battle_royale")
						lobby_titlecard.icon_state += "_battle_royale"
					else
						lobby_titlecard.icon_state = "title_main"
					#ifdef MAP_OVERRIDE_OSHAN
						lobby_titlecard.icon_state = "title_oshan"
					#endif
					#ifdef MAP_OVERRIDE_MANTA
						lobby_titlecard.icon_state = "title_manta"
					#endif
					if (alert("Declare mode change to all players?","Mode Change","Yes","No") == "Yes")
						boutput(world, "<span class='notice'><b>The mode is now: [requestedMode]</b></span>")
				else
					boutput(usr, "<span class='alert'><b>That is not a valid game mode!</b></span>")
			else
				alert("You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("c_mode_next")
			if (src.level >= LEVEL_SA)
				var/newmode = href_list["type"]
				logTheThing("admin", usr, null, "set the next round's mode as [newmode].")
				logTheThing("diary", usr, null, "set the next round's mode as [newmode].", "admin")
				message_admins("<span class='internal'>[key_name(usr)] set the next round's mode as [newmode].</span>")
				world.save_mode(newmode)
				if (alert("Declare mode change to all players?","Mode Change","Yes","No") == "Yes")
					boutput(world, "<span class='notice'><b>The next round's mode will be: [newmode]</b></span>")
			else
				alert("You need to be at least a Secondary Adminstrator to change the game mode.")

		if ("monkeyone")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if(!ismob(M))
					return
				if(ishuman(M))
					var/mob/living/carbon/human/N = M
					logTheThing("admin", usr, M, "attempting to monkeyize [constructTarget(M,"admin")]")
					logTheThing("diary", usr, M, "attempting to monkeyize [constructTarget(M,"diary")]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] attempting to monkeyize [key_name(M)]</span>")
					N.monkeyize()
				else
					boutput(usr, "<span class='alert'>You can't transform that mob type into a monkey.</span>")
					return
			else
				alert("You need to be at least a Secondary Adminstrator to monkeyize players.")

		if ("forcespeech")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					var/speech = input("What will [M] say?", "Force speech", "")
					if(!speech)
						return
					M.say(speech)
					speech = copytext(sanitize(speech), 1, MAX_MESSAGE_LEN)
					logTheThing("admin", usr, M, "forced [constructTarget(M,"admin")] to say: [speech]")
					logTheThing("diary", usr, M, "forced [constructTarget(M,"diary")] to say: [speech]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] forced [key_name(M)] to say: [speech]</span>")
			else
				alert("You need to be at least a Primary Administrator to force players to say things.")

		if ("prison")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M || !ismob(M)) return
				usr.client.cmd_admin_prison_unprison(M)
			else
				alert("You need to be at least a Moderator to send players to prison.")

		if ("shamecube")
			if (src.level >= LEVEL_MOD)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_shame_cube(M)
			else
				alert("You need to be at least a Moderator to shame cube a player.")

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

				logTheThing("admin", usr, M, "sent [constructTarget(M,"admin")] to the thunderdome. ([team])")
				logTheThing("diary", usr, M, "sent [constructTarget(M,"diary")] to the thunderdome. ([team])", "admin")
				message_admins("[key_name(usr)] has sent [key_name(M)] to the thunderdome. ([team])")
				boutput(M, "<span class='notice'><b>You have been sent to the Thunderdome. You are on [team].</b></span>")
				boutput(M, "<span class='notice'><b>Prepare for combat. If you are not let out of the preparation area within a few minutes, please adminhelp. (F1 key)</b></span>")

			else
				alert("You need to be at least a Secondary Adminstrator to send players to Thunderdome.")

		if ("revive")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (ismob(M))
					if(isobserver(M))
						alert("You can't revive a ghost! How does that even work?!")
						return
					if(config.allow_admin_rev)
						M.revive()
						message_admins("<span class='alert'>Admin [key_name(usr)] healed / revived [key_name(M)]!</span>")
						logTheThing("admin", usr, M, "healed / revived [constructTarget(M,"admin")]")
						logTheThing("diary", usr, M, "healed / revived [constructTarget(M,"diary")]", "admin")
					else
						alert("Reviving is currently disabled.")
			else
				alert("You need to be at least a Primary Adminstrator to revive players.")

		if ("makeai")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/mob/newM = usr.client.cmd_admin_makeai(M)
				href_list["target"] = "\ref[newM]"
			else
				alert("You need to be at least a Secondary Adminstrator to turn players into AI units.")

		if ("makecyborg")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/mob/newM = usr.client.cmd_admin_makecyborg(M)
				href_list["target"] = "\ref[newM]"
			else
				alert("You need to be at least a Secondary Adminstrator to turn players into Cyborgs.")

		if ("makeghostdrone")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				var/mob/newM = usr.client.cmd_admin_makeghostdrone(M)
				href_list["target"] = "\ref[newM]"
			else
				alert("You need to be at least a Secondary Adminstrator to turn players into Ghostdrones.")

		if ("modifylimbs")
			if (src.level >= LEVEL_SA)
				var/mob/MC = locate(href_list["target"])
				if (MC && usr.client)
					usr.client.modify_parts(MC, usr)
			else
				alert("You need to be at least a Secondary Administrator to modify limbs.")


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
				alert("You need to be at least a Secondary Adminstrator to jump to mobs.")

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
				alert("You need to be at least a Secondary Adminstrator to observe mobs... For some reason.")

		if ("jumptocoords")
			if(src.level >= LEVEL_SA)
				var/list/coords = splittext(href_list["target"], ",")
				if (coords.len < 3) return
				usr.client.jumptocoord(text2num(coords[1]), text2num(coords[2]), text2num(coords[3]))
			else
				alert("You need to be at least a Secondary Adminstrator to jump to coords.")

		if ("getmob")
			if(( src.level >= LEVEL_ADMIN ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.Getmob(M)
			else
				alert("If you are below the rank of Administrator, you need to be observing and at least a Secondary Administrator to get a player.")

		if ("sendmob")
			if(( src.level >= LEVEL_ADMIN ) || ((src.level >= LEVEL_PA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/list/areas = list( )
				for (var/area/A in world)
					areas += A
					LAGCHECK(LAG_LOW)
				var/area = input(usr, "Select an area") as null|anything in areas
				if (area)
					usr.client.sendmob(M, area)
			else
				alert("If you are below the rank of Administrator, you need to be observing and at least a Primary Administrator to get a player.")

		if ("gib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_gib(M)
			else
				alert("You need to be at least a Primary Admin to gib a dude.")

		if ("buttgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_buttgib(M)
			else
				alert("You need to be at least a Primary Admin to buttgib a dude.")

		if ("partygib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_partygib(M)
			else
				alert("You need to be at least a Primary Admin to party gib a dude.")

		if ("owlgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_owlgib(M)
			else
				alert("A loud hooting noise is heard. It sounds angry. I guess you aren't allowed to do this.")

		if ("firegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_firegib(M)
			else
				alert("You need to be at least a Primary Admin to fire gib a dude.")

		if ("elecgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_elecgib(M)
			else
				alert("You need to be at least a Primary Admin to elec gib a dude.")

		if ("sharkgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.sharkgib(M)
			else
				alert("You need to be at least a Primary Admin to shark gib a dude.")

		if ("icegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_icegib(M)
			else
				alert("You need to be at least a Primary Admin to ice gib a dude.")

		if ("goldgib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_goldgib(M)
			else
				alert("You need to be at least a Primary Admin to gold gib a dude.")

		if("spidergib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_spidergib(M)
			else
				alert("You need to be at least a Primary Admin to spider gib a dude.")

		if("implodegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_implodegib(M)
			else
				alert("You need to be at least a Primary Admin to implode a dude.")

		if("cluwnegib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_cluwnegib(M)
			else
				alert("You need to be at least a Primary Admin to cluwne gib a dude.")
		if ("tysongib")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_tysongib(M)
			else
				alert("You need to be at least a Primary Admin to tyson gib a dude.")
		if("damn")
			if(src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if(!M || !M.mind) return
				if(M.mind.damned)
					usr.client.cmd_admin_adminundamn(M)
				else
					usr.client.cmd_admin_admindamn(M)
			else
				alert("You need to be at least a Primary Admin to damn a dude.")
		if("transform")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!ishuman(M))
					alert("This secret can only be used on human mobs.")
					return
				var/mob/living/carbon/human/H = M
				var/which = input("Transform them into what?","Transform") as null|anything in list("Monkey","Cyborg","Lizardman","Squidman","Martian","Skeleton","Flashman", "Kudzuman","Ghostdrone","Flubber","Cow")
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
					if("reliquary soldier-Don't use yet please")
						H.set_mutantrace(/datum/mutantrace/reliquary_soldier)
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
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to transform a player.")

		if ("managebioeffect")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				usr.client.cmd_admin_managebioeffect(M)

			else
				alert("You need to be at least a Secondary Administrator to manage the bioeffects of a player.")

		if ("managebioeffect_debug_vars")
			if (src.level >= LEVEL_PA)
				var/datum/bioEffect/B = locate(href_list["bioeffect"])
				usr.client.debug_variables(B)
			else
				alert("You must be at least a Primary Administrator to view variables!")

		if ("managebioeffect_remove")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return
				M.bioHolder.RemoveEffect(href_list["bioeffect"])
				usr.client.cmd_admin_managebioeffect(M)

				message_admins("[key_name(usr)] removed the [href_list["bioeffect"]] bio-effect from [key_name(M)].")
			else
				alert("You need to be at least a Secondary Administrator to remove the bioeffects of a player.")
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
				if(istype(BE, /datum/bioEffect/power)) //powers only
					if (BE.power)
						BE.power = 0
					else
						BE.power = 1
				else
					return

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
						P.power = 1
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
				alert("You need to be at least a Secondary Administrator to modify the bioeffects of a player.")

		if ("managebioeffect_add")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return
				var/input = input(usr, "Enter a /datum/bioEffect path or partial name.", "Add a Bioeffect", null) as null|text
				input = get_one_match(input, "/datum/bioEffect")
				var/datum/bioEffect/BE = text2path("[input]")
				if (BE)
					M.bioHolder.AddEffect(initial(BE.id))
					usr.client.cmd_admin_managebioeffect(M)
					message_admins("[key_name(usr)] added the [initial(BE.id)] bio-effect to [key_name(M)].")
			else
				alert("You need to be at least a Secondary Administrator to add bioeffects to a player.")

		if ("managebioeffect_refresh")
			if(src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				usr.client.cmd_admin_managebioeffect(M)
			else
				alert("You need to be at least a Secondary Administrator to manage the bioeffects of a player.")

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
				alert("You need to be at least a Secondary Administrator to modify the genetic stability of a player.")

		if ("addbioeffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M
				var/pick = input("Which effect(s)?","Give Bioeffects") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (picklist && picklist.len >= 1)
					var/string_version
					for(pick in picklist)
						X.bioHolder.AddEffect(pick, magical = 1)

						if (string_version)
							string_version = "[string_version], \"[pick]\""
						else
							string_version = "\"[pick]\""

					message_admins("[key_name(usr)] added the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] to [key_name(X)].")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to bioeffect a player.")

		if ("removebioeffect")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M
				var/pick = input("Which effect(s)?","Remove Bioeffects") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (picklist && picklist.len >= 1)
					var/string_version
					for(pick in picklist)
						X.bioHolder.RemoveEffect(pick)

						if (string_version)
							string_version = "[string_version], \"[pick]\""
						else
							string_version = "\"[pick]\""

					message_admins("[key_name(usr)] removed the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] from [X.real_name].")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to bioeffect a player.")

		if ("removehandcuff")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (istype(M))
					usr.client.cmd_admin_unhandcuff(M)
				else
					alert("Only mobs can have handcuffs, doofus! Are you trying to unhandcuff a shrub or something? Stop that!")

		if ("checkhealth")
			if (src.level >= LEVEL_SA)
				var/atom/A = locate(href_list["target"])
				if (A)
					usr.client.cmd_admin_check_health(A)
					return
		if ("addreagent")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M

				if(!X.reagents) X.create_reagents(100)

				var/list/L = list()
				var/searchFor = input(usr, "Look for a part of the reagent name (or leave blank for all)", "Add reagent") as null|text
				if(searchFor)
					for(var/R in childrentypesof(/datum/reagent))
						if(findtext("[R]", searchFor)) L += R
				else
					L = childrentypesof(/datum/reagent)

				var/type
				if(L.len == 1)
					type = L[1]
				else if(L.len > 1)
					type = input(usr,"Select Reagent:","Reagents",null) as null|anything in L
				else
					usr.show_text("No reagents matching that name", "red")
					return

				if(!type) return
				var/datum/reagent/reagent = new type()

				var/amount = input(usr,"Amount:","Amount",50) as null|num
				if(!amount) return

				X.reagents.add_reagent(reagent.id, amount)
				boutput(usr, "<span class='success'>Added [amount] units of [reagent.id] to [X.name]</span>")

				logTheThing("admin", usr, X, "added [amount] units of [reagent.id] to [X] at [log_loc(X)].")
				logTheThing("diary", usr, X, "added [amount] units of [reagent.id] to [X] at [log_loc(X)].", "admin")
				message_admins("[key_name(usr)] added [amount] units of [reagent.id] to [key_name(X)] at [log_loc(X)].")

			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to affect player reagents.")

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

				if (!ishuman(M))
					alert("You may only use this secret on human mobs.")
					return

				var/mob/living/carbon/human/X = M
				var/pick = input("Which reagent(s)?","Remove Reagents") as null|text
				if (!pick)
					return

				var/list/picklist = params2list(pick)
				if (picklist && picklist.len >= 1)
					var/string_version

					for(pick in picklist)
						var/amt = input("How much of [pick]?","Remove Reagent") as null|num
						if(!amt || amt < 0)
							return

						if (X.reagents)
							X.reagents.remove_reagent(pick,amt)

						if (string_version)
							string_version = "[string_version], [amt] \"[pick]\""
						else
							string_version = "[amt] \"[pick]\""

					message_admins("[key_name(usr)] removed [string_version] from [X.real_name].")
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to affect player reagents.")

		if ("possessmob")
			if( src.level >= LEVEL_PA )
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (M == usr)
					releasemob(M)
				else
					possessmob(M)
			else
				alert("You need to be at least a Primary Administrator to possess or release mobs.")

		if ("checkcontents")
			if(( src.level >= LEVEL_PA ) || ((src.level >= LEVEL_SA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_check_contents(M)
			else
				alert("If you are below the rank of Primary Admin, you need to be observing and at least a Secondary Administrator to check player contents.")

		if ("dropcontents")
			if(( src.level >= LEVEL_ADMIN ) || ((src.level >= LEVEL_PA) ))
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (alert(usr, "Make [M] drop everything?", "Confirmation", "Yes", "No") == "Yes")
					usr.client.cmd_admin_drop_everything(M)
			else
				alert("If you are below the rank of Shit Guy, you need to be observing and at least a Primary Admin to drop player contents.")

		if ("addabil")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				var/origin = href_list["origin"]
				if (!M) return
				if (!M.abilityHolder)
					alert("No ability holder detected. Create a holder first!")
					return
				var/ab_to_add = input("Enter a /datum/targetable path or search by partial path", "Add an Ability", null) as null|text
				ab_to_add = get_one_match(ab_to_add, "/datum/targetable")
				if (!ab_to_add) return // user canceled
				M.abilityHolder.addAbility(ab_to_add)
				M.abilityHolder.updateButtons()
				message_admins("[key_name(usr)] added ability [ab_to_add] to [key_name(M)].")
				logTheThing("admin", usr, M, "added ability [ab_to_add] to [constructTarget(M,"admin")].")
				if (origin == "manageabils")//called via ability management panel
					usr.client.cmd_admin_manageabils(M)
			else
				alert("You must be at least a Primary Administrator to do this!")

		if ("removeabil")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				if (!M.abilityHolder)
					alert("No ability holder detected.")
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

				ab_to_rem = input("Remove which ability?", "Ability", null) as null|anything in abils
				if (!ab_to_rem) return //user cancelled
				message_admins("[key_name(usr)] removed ability [ab_to_rem] from [key_name(M)].")
				logTheThing("admin", usr, M, "removed ability [ab_to_rem] from [constructTarget(M,"admin")].")
				M.abilityHolder.removeAbilityInstance(ab_to_rem)
				M.abilityHolder.updateButtons()
			else
				alert("You must be at least a Primary Administrator to do this!")

		if ("abilholder")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/ab_to_add = input("Which holder?", "Ability", null) as anything in childrentypesof(/datum/abilityHolder)
				M.add_ability_holder(ab_to_add)
				M.abilityHolder.updateButtons()
				message_admins("[key_name(usr)] created abilityHolder [ab_to_add] for [key_name(M)].")
				logTheThing("admin", usr, M, "created abilityHolder [ab_to_add] for [constructTarget(M,"admin")].")
			else
				alert("You must be at least a Primary Administrator to do this!")

		if ("manageabils")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_manageabils(M)
			else
				alert("You must be at least a Primary Administrator to do this!")

		if ("manageabils_remove")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				var/datum/targetable/A = locate(href_list["ability"])
				if (!M || !A) return
				message_admins("[key_name(usr)] removed ability [A] from [key_name(M)].")
				logTheThing("admin", usr, M, "removed ability [A] from [constructTarget(M,"admin")].")
				M.abilityHolder.removeAbilityInstance(A)
				M.abilityHolder.updateButtons()
				usr.client.cmd_admin_manageabils(M)
			else
				alert("You must be at least a Primary Administrator to do this!")

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
				alert("You must be at least a Primary Administrator to do this!")

		if ("manageabilt_debug_vars")
			if (src.level >= LEVEL_PA)
				var/datum/targetable/A = locate(href_list["ability"])
				usr.client.debug_variables(A)
			else
				alert("You must be at least a Primary Administrator to do this!")

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
				alert("You must be at least a Primary Administrator to make someone a wraith.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a wraith?", "Make Wraith", "Yes", "No") == "Yes")
				var/datum/mind/mind = M.mind
				if (!mind)
					mind = new /datum/mind(  )
					mind.key = M.key
					mind.current = M
					ticker.minds += mind
					M.mind = mind
				if (mind.objectives)
					mind.objectives.len = 0
				else
					mind.objectives = list()
				switch (alert("Objectives?", "Objectives", "Custom", "Random", "None"))
					if ("Custom")
						var/WO = null
						do
							WO = input("What objective?", "Objective", null) as null|anything in childrentypesof(/datum/objective/specialist/wraith)
							if (WO)
								var/datum/objective/specialist/wraith/WObj = new WO()
								WObj.owner = mind
								WObj.set_up()
								mind.objectives += WObj
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
				mind.special_role = "wraith"
				ticker.mode.Agimmicks += mind
				Wr.antagonist_overlay_refresh(1, 0)

		if ("makeblob")
			if( src.level < LEVEL_PA )
				alert("You must be at least a Primary Administrator to make someone a blob.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a blob?", "Make Blob", "Yes", "No") == "Yes")
				var/mob/B = M.blobize()
				if (B)
					if (B.mind)
						B.mind.special_role = "blob"
						ticker.mode.bestow_objective(B,/datum/objective/specialist/blob)
						//Bl.owner = B.mind
						//B.mind.objectives = list(Bl)

						var/i = 1
						for (var/datum/objective/Obj in B.mind.objectives)
							boutput(B, "<b>Objective #[i]</b>: [Obj.explanation_text]")
							i++
						ticker.mode.Agimmicks += B.mind
						B.antagonist_overlay_refresh(1, 0)

						SPAWN_DBG(0)
							var/newname = input(B, "You are a Blob. Please choose a name for yourself, it will show in the form: <name> the Blob", "Name change") as text

							if (newname)
								if (length(newname) >= 26) newname = copytext(newname, 1, 26)
								newname = strip_html(newname) + " the Blob"
								B.real_name = newname
								B.name = newname

		if ("makemacho")
			if( src.level < LEVEL_PA )
				alert("You must be at least a Primary Administrator to make someone a Macho Man.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a macho man?", "Make Macho", "Yes", "No") == "Yes")
				M.machoize()

		if ("makecritter")
			if( src.level < LEVEL_PA )
				alert("You must be at least a Primary Administrator to make someone a Critter.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return

			var/CT = input("Enter a /mob/living/critter path or partial name.", "Make Critter", null) as null|text

			var/list/matches = get_matches(CT, "/mob/living/critter")
			matches -= list(/mob/living/critter, /mob/living/critter/small_animal, /mob/living/critter/aquatic) //blacklist
			if (matches.len == 0)
				return
			if (matches.len == 1)
				CT = matches[1]
			else
				CT = input("Select a match", "matches for pattern", null) as null|anything in matches

			if (CT && M)
				M.critterize(CT)
			return

		if ("makecube")
			if( src.level < LEVEL_PA )
				alert("You must be at least a Primary Administrator to make someone a Cube.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a cube?", "Make Cube", "Yes", "No") == "Yes")
				var/CT = input("What kind of cube?", "Make Cube", null) as null|anything in childrentypesof(/mob/living/carbon/cube)
				if (CT != null)
					var/amt = input("How long should it live?","Cube Lifetime") as null|num
					if(!amt)
						amt = INFINITY
					M.cubeize(amt, CT)

		if ("makeflock")
			if( src.level < LEVEL_PA)
				alert("You must be at least a Primary Administrator to make someone a flockmind or flocktrace.")
				return
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Make [M] a flockmind or flocktrace?", "Make Flockmind", "Yes", "No") == "Yes")
				var/datum/mind/mind = M.mind
				if (!mind)
					mind = new /datum/mind()
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
					mind.special_role = "flockmind"
				else if(istype(F, /mob/living/intangible/flock/trace))
					mind.special_role = "flocktrace"
				ticker.mode.Agimmicks += mind
				F.antagonist_overlay_refresh(1, 0)


		if ("remove_traitor")
			if ( src.level < LEVEL_SA )
				alert("You must be at least a Secondary Administrator to remove someone's status as an antagonist.")
				return
			if (!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return
			if (alert("Remove [M]'s antag status?", "Remove Antag", "Yes", "No") == "Yes")
				if (!M) return
				if (!isturf(M.loc))
					// They could be in a pod or whatever, which would have unfortunate results when respawned (Convair880).
					alert(usr, "You currently cannot remove the antagonist status of somebody hiding in a pod, closet or other container.", "An error occurred")
					return
				remove_antag(M, usr, 0, 1)

		if ("traitor")
			if(!ticker || !ticker.mode)
				alert("The game hasn't started yet!")
				return
			var/mob/M = locate(href_list["target"])
			if (!M) return

			//independant of mode and can be traitors as well
			if(M.mind && (M.mind in miscreants))
				var/t = ""
				for(var/datum/objective/O in M.mind.objectives)
					if (istype(O, /datum/objective/miscreant))
						t += "[O.explanation_text]\n"
				alert("Miscreant! Objective: [t]")

			var/datum/game_mode/current_mode = ticker.mode
			if (istype(current_mode, /datum/game_mode/revolution))
				if(M.mind in current_mode:head_revolutionaries)
					alert("Head Revolutionary!")
					return
				else if(M.mind in current_mode:revolutionaries)
					alert("Revolutionary!")
					return
			else if (istype(current_mode, /datum/game_mode/nuclear))
				if(M.mind in current_mode:syndicates)
					alert("Syndicate Operative!", "[M.key]")
					return
			else if (istype(current_mode, /datum/game_mode/spy))
				if(M.mind in current_mode:leaders)
					var/datum/mind/antagonist = M.mind
					var/t = ""
					for(var/datum/objective/OB in antagonist.objectives)
						if (istype(OB, /datum/objective/crew) || istype(OB, /datum/objective/miscreant))
							continue
						t += "[OB.explanation_text]\n"
					if(antagonist.objectives.len == 0)
						t = "None defined."
					alert("Infiltrator. Objective(s):\n[t]", "[M.key]")
					return
			else if (istype(current_mode, /datum/game_mode/gang))
				if(M.mind in current_mode:leaders)
					alert("Leader of [M.mind.gang.gang_name].", "[M.key]")
					return
				for(var/datum/gang/G in current_mode:gangs)
					if(M.mind in G.members)
						alert("Member of [G.gang_name].", "[M.key]")
						return

			// traitor, or other modes where traitors/counteroperatives would be.
			if(M.mind in current_mode.traitors)
				var/datum/mind/antagonist = M.mind
				var/t = ""
				for(var/datum/objective/OB in antagonist.objectives)
					if (istype(OB, /datum/objective/crew) || istype(OB, /datum/objective/miscreant))
						continue
					t += "[OB.explanation_text]\n"
				if(antagonist.objectives.len == 0)
					t = "None defined."
				alert("Assigned [M.mind.special_role]. Objective(s):\n[t]", "[M.key]")
				return
			if(M.mind in ticker.mode.Agimmicks)
				var/datum/mind/antagonist = M.mind
				var/t = ""
				for(var/datum/objective/OB in antagonist.objectives)
					if (istype(OB, /datum/objective/crew) || istype(OB, /datum/objective/miscreant))
						continue
					t += "[OB.explanation_text]\n"
				if(antagonist.objectives.len == 0)
					t = "None defined."
				alert("Assigned [M.mind.special_role]. Objective(s):\n[t]", "[M.key]")
				return

			//they're nothing so turn them into a traitor!
			if(ishuman(M) || isAI(M) || isrobot(M) || ismobcritter(M))
				var/antagonize = "Cancel"
				antagonize = alert("Is not an antagonist, make antagonist?", "antagonist", "Yes", "Cancel")
				if(antagonize == "Cancel")
					return
				if(antagonize == "Yes")
					if (issilicon(M))
						evilize(M, "traitor")
					else if (ismobcritter(M))
						// The only role that works for all critters at this point is hard-mode traitor, really. The majority of existing
						// roles don't work for them, most can't wear clothes and some don't even have arms and/or can pick things up.
						// That said, certain roles are mostly compatible and thus selectable.
						var/list/traitor_types = list("Hard-mode traitor", "Wrestler", "Grinch")
						var/selection = input(usr, "Select traitor type.", "Traitorize", "Traitor") in traitor_types
						switch (selection)
							if ("Hard-mode traitor")
								evilize(M, "traitor", "hardmode")
							else
								evilize(M, selection)
						/*	else
								SPAWN_DBG (0) alert("An error occurred, please try again.")*/
					else
						var/list/traitor_types = list("Traitor", "Wizard", "Changeling", "Vampire", "Werewolf", "Hunter", "Wrestler", "Grinch", "Omnitraitor", "Spy_Thief")
						if(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/gang))
							traitor_types += "Gang Leader"
						var/selection = input(usr, "Select traitor type.", "Traitorize", "Traitor") in traitor_types
						switch(selection)
							if("Traitor")
								if (alert("Hard Mode?","Treachery","Yes","No") == "Yes")
									evilize(M, "traitor", "hardmode")
								else
									evilize(M, "traitor")
							else
								evilize(M, selection)
							/*else
								SPAWN_DBG (0) alert("An error occurred, please try again.")*/
			//they're a ghost/hivebotthing/etc
			else
				alert("Cannot make this mob a traitor")

		if ("create_object")
			if (src.level >= LEVEL_PA)
				create_object(usr)
			else
				alert("You need to be at least a Primary Adminstrator to create objects.")

		if ("create_turf")
			if (src.level >= LEVEL_PA)
				create_turf(usr)
			else
				alert("You need to be at least a Primary Adminstrator to create turfs.")

		if ("create_mob")
			if (src.level >= LEVEL_PA) // Moved from SG to PA. They can do this through build mode anyway (Convair880).
				create_mob(usr)
			else
				alert("You need to be at least a Primary Administrator to create mobs.")

		if ("prom_demot")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/client/C = M.client
				if(C.holder && (C.holder.level >= src.level) && C != usr.client)
					alert("This cannot be done as [C] isn't of a lower rank than you!")
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
				alert("You need to be at least a Primary Adminstrator to promote or demote.")

		if ("chgadlvl")
			if (src.level >= LEVEL_PA)
				var/rank = href_list["type"]
				var/client/C = locate(href_list["target"])
				if (!rank || !C) return

				if (C.holder && (C.holder.level >= src.level) && C != usr.client)
					alert("This cannot be done as [C] isn't of a lower rank than you!")
					return

				if (src.level < rank_to_level(rank))
					alert("You can't promote people above your own rank, dork.")
					return

				if (rank == "Remove")
					C.clear_admin_verbs()
					C.update_admins(null)
					logTheThing("admin", usr, C, "has removed [constructTarget(C,"admin")]'s adminship")
					logTheThing("diary", usr, null, "has removed [C]'s adminship", "admin")
					message_admins("[key_name(usr)] has removed [C]'s adminship")

					var/ircmsg[] = new()
					ircmsg["key"] = usr.client.key
					ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
					ircmsg["msg"] = "has removed [C]'s adminship"
					ircbot.export("admin", ircmsg)

					admins.Remove(C.ckey)
					onlineAdmins.Remove(C)
				else
					C.clear_admin_verbs()
					C.update_admins(rank)
					logTheThing("admin", usr, C, "has made [constructTarget(C,"admin")] a [rank]")
					logTheThing("diary", usr, null, "has made [C] a [rank]", "admin")
					message_admins("[key_name(usr)] has made [C] a [rank]")

					var/ircmsg[] = new()
					ircmsg["key"] = usr.client.key
					ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
					ircmsg["msg"] = "has made [C] a [rank]"
					ircbot.export("admin", ircmsg)

					admins[C.ckey] = rank
					onlineAdmins.Add(C)
			else
				alert("You need to be at least a Primary Adminstrator to promote or demote.")

		if ("object_list")
			if (src.level >= LEVEL_PA)
				if (config.allow_admin_spawning && (src.state == 2 || src.level >= LEVEL_PA))
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
						else if (ispath(path, /mob) && src.level < LEVEL_PA)
							removed_paths += dirty_path
						else
							paths += path
						LAGCHECK(LAG_LOW)

					if (!paths)
						return
					else if (length(paths) > 5)
						alert("Select five or less object types only, you colossal ass!")
						return
					else if (length(removed_paths))
						alert("Spawning of these objects is blocked:\n" + jointext(removed_paths, "\n"))
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
									var/atom/thing = new path(locate(0 + X,0 + Y,0 + Z))
									thing.dir = direction ? direction : SOUTH
									LAGCHECK(LAG_LOW)

							if ("relative")
								if (loc)
									for (var/path in paths)
										var/atom/thing = new path(locate(loc.x + X,loc.y + Y,loc.z + Z))
										thing.dir = direction ? direction : SOUTH
										LAGCHECK(LAG_LOW)
								else
									return

						sleep(-1)

					if (number == 1)
						logTheThing("admin", usr, null, "created a [english_list(paths)]")
						logTheThing("diary", usr, null, "created a [english_list(paths)]", "admin")
						for(var/path in paths)
							if(ispath(path, /mob))
								message_admins("[key_name(usr)] created a [english_list(paths, 1)]")
								break
							LAGCHECK(LAG_LOW)
					else
						logTheThing("admin", usr, null, "created [number]ea [english_list(paths)]")
						logTheThing("diary", usr, null, "created [number]ea [english_list(paths)]", "admin")
						for(var/path in paths)
							if(ispath(path, /mob))
								message_admins("[key_name(usr)] created [number]ea [english_list(paths, 1)]")
								break
							LAGCHECK(LAG_LOW)
					return
				else
					alert("Object spawning is currently disabled for anyone below the rank of Administrator.")
					return
			else
				alert("You need to be at least an Adminstrator to spawn objects.")

		if ("polymorph")
			if (src.level >= LEVEL_SA) //gave SA+ restricted polymorph
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.cmd_admin_polymorph(M)
			else
				alert("You need to be at least a Secondary Admin to polymorph a dude.")

		if ("modcolor")
			if (src.level >= LEVEL_ADMIN)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				mod_color(M)
			else
				alert("You need to be at least a Administrator to modify an icon.")

		if("giveantagtoken") //Gives player a token they can redeem to guarantee an antagonist role
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M)
					return
				if (M.ckey && M.ckey == usr.ckey)
					alert(usr, "You cannot modify your own antag tokens.")
					return
				var/tokens = input(usr, "Current Tokens: [M.client.antag_tokens]","Set Antag Tokens to...") as null|num
				if (!tokens)
					return
				M.client.set_antag_tokens( tokens )
				if (tokens <= 0)
					logTheThing("admin", usr, M, "Removed all antag tokens from [constructTarget(M,"admin")]")
					logTheThing("diary", usr, M, "Removed all antag tokens from [constructTarget(M,"diary")]", "admin")
					message_admins("<span class='internal'>[key_name(usr)] removed all antag tokens from [key_name(M)]</span>")
				else
					logTheThing("admin", usr, M, "Set [constructTarget(M,"admin")]'s Antag tokens  to [tokens].")
					logTheThing("diary", usr, M, "Set [constructTarget(M,"diary")]'s Antag tokens  to [tokens].")
					message_admins( "[key_name(usr)] set [key_name(M)]'s Antag tokens to [tokens]." )
		if("setspacebux")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M)
					return
				if (M.ckey && M.ckey == usr.ckey)
					alert(usr, "You cannot modify your own spacebux.")
					return
				var/spacebux = input(usr, "Current Spacebux: [M.client.persistent_bank]","Set Spacebux to...") as null|num
				if (!spacebux)
					return
				M.client.set_persistent_bank( spacebux )
				logTheThing("admin", usr, M, "Set [constructTarget(M,"admin")]'s Persistent Bank (Spacebux) to [spacebux].")
				logTheThing("diary", usr, M, "Set [constructTarget(M,"diary")]'s Persistent Bank (Spacebux) to [spacebux].")
				message_admins( "[key_name(usr)] set [key_name(M)]'s Persistent Bank (Spacebux) to [spacebux]." )
		if ("viewsave")
			if (src.level >= LEVEL_ADMIN)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.view_save_data(M)
			else
				alert("You need to be at least a Administrator to view save data.")

		if ("grantcontributor")
			if (src.level >= LEVEL_CODER)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				M.unlock_medal( "Contributor", 1 )
				logTheThing("admin", usr, M, "gave [constructTarget(M,"admin")] contributor status.")
				logTheThing("diary", usr, M, "gave [constructTarget(M,"diary")] contributor status.")
				message_admins( "[key_name(usr)] gave [key_name(M)] contributor status." )
			else
				alert("You need to be at least a Coder to grant the medal.")
		if ("revokecontributor")
			if (src.level >= LEVEL_CODER)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/suc = M.revoke_medal( "Contributor" )
				if(!suc)
					boutput( usr, "<span class='alert'>Revoke failed, couldn't contact hub!</span>" )
				else if(suc)
					boutput( usr, "<span class='alert'>Contributor medal revoked.</span>" )
					logTheThing("admin", usr, M, "revoked [constructTarget(M,"admin")]'s contributor status.")
					logTheThing("diary", usr, M, "revoked [constructTarget(M,"diary")]'s contributor status.")
					message_admins( "[key_name(usr)] revoked [key_name(M)]'s contributor status." )
				else
					boutput( usr, "<span class='alert'>Failed to revoke, did they have the medal to begin with?</span>" )
			else
				alert("You need to be at least a Coder to revoke the medal.")
		if ("grantclown")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				M.unlock_medal( "Unlike the director, I went to college", 1 )
				logTheThing("admin", usr, M, "gave [constructTarget(M,"admin")] their clown college diploma.")
				logTheThing("diary", usr, M, "gave [constructTarget(M,"diary")] their clown college diploma.")
				message_admins( "[key_name(usr)] gave [key_name(M)] their clown college diploma." )
			else
				alert("You need to be at least an SA to grant this.")
		if ("revokeclown")
			if (src.level >= LEVEL_SA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				var/suc = M.revoke_medal( "Unlike the director, I went to college" )
				if(!suc)
					boutput( usr, "<span class='alert'>Revoke failed, couldn't contact hub!</span>" )
				else if(suc)
					boutput( usr, "<span class='alert'>Clown college diploma revoked.</span>" )
					logTheThing("admin", usr, M, "revoked [constructTarget(M,"admin")]'s clown college diploma.")
					logTheThing("diary", usr, M, "revoked [constructTarget(M,"diary")]'s clown college diploma.")
					message_admins( "[key_name(usr)] revoked [key_name(M)]'s clown college diploma." )
				else
					boutput( usr, "<span class='alert'>Failed to revoke, did they have the medal to begin with?</span>" )
			else
				alert("You need to be at least an SA to revoke this.")

		if ("viewvars")
			if (src.level >= LEVEL_PA)
				var/mob/M = locate(href_list["target"])
				if (!M) return
				usr.client.debug_variables(M)
			else
				alert("You need to be at least a Primary Administrator to view variables.")

		if ("adminplayeropts")
			var/mob/M = locate(href_list["target"])
			if (!M) return
			usr.client.holder.playeropt(M)

		if ("secretsfun")
			if (src.level >= LEVEL_SA)
				switch(href_list["type"])
					if("sec_clothes")
						for(var/obj/item/clothing/under/O in world)
							del(O)
							LAGCHECK(LAG_LOW)
					if("sec_all_clothes")
						for(var/obj/item/clothing/O in world)
							del(O)
							LAGCHECK(LAG_LOW)
					if("sec_classic1")
						for(var/obj/item/clothing/suit/fire/O in world)
							del(O)
							LAGCHECK(LAG_LOW)
						for(var/obj/grille/O in world)
							del(O)
							LAGCHECK(LAG_LOW)
						for(var/obj/machinery/vehicle/pod/O in all_processing_machines())
							for(var/atom/movable/A in O)
								A.set_loc(O.loc)
							del(O)
							LAGCHECK(LAG_LOW)

					if("transform_one")
						var/who = input("Transform who?","Transform") as null|mob in world
						if (!who)
							return
						if (!ishuman(who))
							alert("This secret can only be used on human mobs.")
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
						logTheThing("admin", usr, null, "transformed [H.real_name] into a [which].")
						logTheThing("diary", usr, null, "transformed [H.real_name] into a [which].", "admin")

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
						logTheThing("admin", usr, null, "transformed everyone into a [which].")
						logTheThing("diary", usr, null, "transformed everyone into a [which].", "admin")
					if("prisonwarp")
						if(!ticker)
							alert("The game hasn't started yet!", null, null, null, null, null)
							return
						message_admins("<span class='internal'>[key_name(usr)] teleported all players to the prison zone.</span>")
						logTheThing("admin", usr, null, "teleported all players to the prison zone.")
						logTheThing("diary", usr, null, "teleported all players to the prison zone.", "admin")
						for(var/mob/living/carbon/human/H in mobs)
							var/turf/loc = get_turf(H)
							var/security = 0
							if(loc.z > 1 || prisonwarped.Find(H))
								//don't warp them if they aren't ready or are already there
								continue
							H.changeStatus("paralysis", 70)
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
					if("traitor_all")
						if (src.level >= LEVEL_SA)
							if(!ticker)
								alert("The game hasn't started yet!")
								return

							var/which_traitor = input("What kind of traitor?","Everyone's a Traitor") as null|anything in list("Traitor","Wizard","Changeling","Werewolf","Vampire","Hunter","Wrestler","Grinch","Omnitraitor")
							if(!which_traitor)
								return
							var/hardmode = null
							if (which_traitor == "Traitor")
								if (alert("Hard Mode?","Everyone's a Traitor","Yes","No") == "Yes")
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
							logTheThing("admin", usr, null, "made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]")
							logTheThing("diary", usr, null, "made everyone a[hardmode ? " hard-mode" : ""] [which_traitor]. Objective is [custom_objective]", "admin")
						else
							alert("You're not of a high enough rank to do this")
					if("flicklights")
						while(!usr.stat)
							//knock yourself out to stop the ghosts
							for(var/mob/M in mobs)
								if(M.client && !isdead(M) && prob(25))
									var/area/AffectedArea = get_area(M)
									if(AffectedArea.name != "Space" && AffectedArea.name != "Ocean" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
										AffectedArea.power_light = 0
										AffectedArea.power_change()
										SPAWN_DBG(rand(55,185))
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
							if (alert("Do you wish to give everyone brain damage?", "Confirmation", "Yes", "No") != "Yes")
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
							logTheThing("admin", usr, null, "gave everybody severe brain damage.")
							logTheThing("diary", usr, null, "gave everybody severe brain damage.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return
					// FUN SECRETS CODE
					if ("randomguns")
						if (src.level >= LEVEL_PA)
							if (alert("Do you want to give everyone a gun?", "Confirmation", "Yes", "No") != "Yes")
								return
							for (var/mob/living/L in mobs)
								new /obj/random_item_spawner/kineticgun(get_turf(L))
							message_admins("[key_name(usr)] gave everyone a random firearm.")
							logTheThing("admin", usr, null, "gave everyone a random firearm.")
							logTheThing("diary", usr, null, "gave everyone a random firearm.", "admin")
						else
							alert("You must be at least a Primary Administrator")
							return

					if	("swaprooms")
						if (src.level >= LEVEL_PA)
							message_admins("Alrighty, messing up the rooms now ... please wait.")
							fuckthestationuphorribly()
							message_admins("[key_name(usr)] swapped the stations rooms.")
							logTheThing("admin", usr, null, "swapped the stations rooms.")
							logTheThing("diary", usr, null, "swapped the stations rooms.", "admin")
						else
							alert("You must be at least a Primary Administrator")
							return

					if	("timewarp")
						if (src.level >= LEVEL_PA)
							var/timedelay = input(usr,"Delay before time warp? 10 = 1 second",src.name) as num|null
							if (!isnum(timedelay) || timedelay < 1)
								return
							boutput(usr, text("<span class='alert'><B>Preparing to warp time</B></span>"))
							timeywimey(timedelay)
							boutput(usr, text("<span class='alert'><B>Time warped!</B></span>"))
							logTheThing("admin", usr, null, "triggered a time warp.")
							logTheThing("diary", usr, null, "triggered a time warp.", "admin")
						else
							alert("You must be at least a Primary Administrator")
							return

					if ("bioeffect_help")
						var/be_string = "To add or remove multiple bioeffects enter multiple IDs separated by semicolons.<br><br><b>All Bio Effect IDs</b><hr>"
						for(var/S in bioEffectList)
							be_string += "[S]<br>"
						usr.Browse(be_string,"window=bioeffect_help;size=300x600")

					if ("reagent_help")
						var/r_string = "To add or remove multiple reagents enter multiple IDs separated by semicolons.<br><br><b>All Reagent IDs</b><hr>"
						for(var/R in reagents_cache)
							r_string += "[R]<br>"
						usr.Browse(r_string,"window=reagent_help;size=300x600")

					if ("add_bioeffect_one","remove_bioeffect_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_bioeffect_one"
							var/who = input("Which player?","[adding ? "Give" : "Remove"] Bioeffects") as null|mob in world

							if (!who)
								return

							if (!ishuman(who))
								alert("You may only use this secret on human mobs.")
								return

							var/mob/living/carbon/human/X = who
							var/pick = input("Which effect(s)?","[adding ? "Give" : "Remove"] Bioeffects") as null|text

							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version

								for(pick in picklist)
									if (adding)
										X.bioHolder.AddEffect(pick)
									else
										X.bioHolder.RemoveEffect(pick)

									if (string_version)
										string_version = "[string_version], \"[pick]\""
									else
										string_version = "\"[pick]\""

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] [key_name(X)].", "admin")
						else
							alert("You must be at least a Primary Administrator to bioeffect players.")
							return
					if ("add_ability_one","remove_ability_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_ability_one"
							var/mob/M = input("Which player?","[adding ? "Give" : "Remove"] Abilities") as null|mob in world

							if (!istype(M))
								return

							if (!M.abilityHolder)
								alert("No ability holder detected. Create a holder first!")
								return

							var/ab_to_do = input("Which ability?", "[adding ? "Give" : "Remove"] Ability", null) as anything in childrentypesof(/datum/targetable)
							if (adding)
								M.abilityHolder.addAbility(ab_to_do)
							else
								M.abilityHolder.removeAbility(ab_to_do)
							M.abilityHolder.updateButtons()

							message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] [key_name(M)].")
							logTheThing("admin", usr, null, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] [key_name(M)].")
							logTheThing("diary", usr, null, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] [key_name(M)].", "admin")
						else
							alert("You must be at least a Primary Administrator to change player abilities.")
							return

					if ("add_reagent_one","remove_reagent_one")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_reagent_one"
							var/who = input("Which player?","[adding ? "Add" : "Remove"] Reagents") as null|mob in world

							if (!who)
								return

							if (!ishuman(who))
								alert("You may only use this secret on human mobs.")
								return

							var/mob/living/carbon/human/X = who
							var/pick = input("Which reagent(s)?","[adding ? "Add" : "Remove"] Reagents") as null|text

							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version

								for(pick in picklist)
									var/amt = input("How much of [pick]?","[adding ? "Add" : "Remove"] Reagent") as null|num
									if(!amt || amt < 0)
										return

									if (adding)
										if (X.reagents)
											X.reagents.add_reagent(pick,amt)
									else
										if (X.reagents)
											X.reagents.remove_reagent(pick,amt)

									if (string_version)
										string_version = "[string_version], [amt] \"[pick]\""
									else
										string_version = "[amt] \"[pick]\""

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(X)].")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] [key_name(X)].", "admin")
						else
							alert("You must be at least a Primary Administrator to affect player reagents.")
							return

					if ("add_bioeffect_all","remove_bioeffect_all")
						if (src.level >= LEVEL_PA)
							var/adding = href_list["type"] == "add_bioeffect_all"
							var/pick = input("Which effect(s)?","[adding ? "Give" : "Remove"] Bioeffects [adding ? "to" : "from"] Everyone") as null|text
							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version
								for(pick in picklist)
									if (string_version)
										string_version = "[string_version], \"[pick]\""
									else
										string_version = "\"[pick]\""

								SPAWN_DBG(0)
									for(var/mob/living/carbon/X in mobs)
										for(pick in picklist)
											if (adding)
												X.bioHolder.AddEffect(pick)
											else
												X.bioHolder.RemoveEffect(pick)
										sleep(0.1 SECONDS)

								message_admins("[key_name(usr)] [adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] the [string_version] bio-effect[picklist.len > 1 ? "s" : ""] [adding ? "to" : "from"] everyone.", "admin")
						else
							alert("You must be at least a Primary Administrator to bioeffect players.")
							return

					if ("add_ability_all","remove_ability_all")
						if (src.level >= LEVEL_PA)
							var/adding = href_list["type"] == "add_ability_all"

							var/ab_to_do = input("Which ability?", "[adding ? "Give" : "Remove"] ability [adding ? "to" : "from"] every human.", null) as null|anything in childrentypesof(/datum/targetable)
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
							logTheThing("admin", usr, null, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] everyone.")
							logTheThing("diary", usr, null, "[adding ? "added" : "removed"] the [ab_to_do] ability [adding ? "to" : "from"] everyone.", "admin")
						else
							alert("You must be at least a Primary Administrator to change player abilities.")
							return

					if ("add_reagent_all","remove_reagent_all")
						if (src.level >= LEVEL_PA)

							var/adding = href_list["type"] == "add_reagent_all"
							var/pick = input("Which reagent(s)?","[adding ? "Add" : "Remove"] Reagents [adding ? "to" : "from"] Everyone") as null|text
							if (!pick)
								return

							var/list/picklist = params2list(pick)

							if (picklist && picklist.len >= 1)
								var/string_version

								for(pick in picklist)
									var/amt = input("How much of [pick]?","[adding ? "Add" : "Remove"] Reagent") as null|num
									picklist[pick] = amt

									if (string_version)
										string_version = "[string_version], [amt] \"[pick]\""
									else
										string_version = "[amt] \"[pick]\""

								SPAWN_DBG(0)
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
								logTheThing("admin", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.")
								logTheThing("diary", usr, null, "[adding ? "added" : "removed"] [string_version] [adding ? "to" : "from"] everyone.", "admin")

						else
							alert("You must be at least a Primary Administrator to affect player reagents.")
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
							for (var/turf/simulated/pool/P in world)
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
							logTheThing("admin", usr, null, "replaced z1 pools with ballpits.")
							logTheThing("diary", usr, null, "replaced z1 pools with ballpits.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if ("woodstation")
						if (src.level >= LEVEL_PA)
							message_admins("[key_name(usr)] began replacing all Z1 floors and walls with wooden ones.")
							var/nornwalls = 0
							if (map_settings && map_settings.walls == /turf/simulated/wall/auto/supernorn)
								nornwalls = 1
							for (var/turf/simulated/wall/W in world)
								if (atom_emergency_stop)
									message_admins("[key_name(usr)]'s command to replace all Z1 floors and walls with wooden ones was terminated due to the atom emerygency stop!")
									return
								if (W.z != 1)
									break
								if (nornwalls)
									var/turf/simulated/wall/auto/AW = W
									if (istype(AW))
										if (AW.icon != 'icons/turf/walls_wood.dmi')
											AW.icon = 'icons/turf/walls_wood.dmi'
											if (istype(AW, /turf/simulated/wall/auto/reinforced))
												AW.icon_state = copytext(W.icon_state,2)
											if (AW.connect_image) // I will get you to work you shit fuck butt FART OVERLAY
												AW.connect_image = image(AW.icon, "connect[AW.connect_overlay_dir]")
												AW.UpdateOverlays(AW.connect_image, "connect")
								else
									if (W.icon_state != "wooden")
										W.icon = 'icons/turf/walls.dmi'
										W.icon_state = "wooden"
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
							logTheThing("admin", usr, null, "replaced z1 floors and walls with wooden doors.")
							logTheThing("diary", usr, null, "replaced z1 floors and walls with wooden doors.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
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
							logTheThing("admin", usr, null, "replaced z1 airlocks with wooden doors.")
							logTheThing("diary", usr, null, "replaced z1 airlocks with wooden doors.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
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
							logTheThing("admin", usr, null, "used Fake Gun secret.")
							logTheThing("diary", usr, null, "used Fake Gun secret.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
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
								if(M.client)
									M.client.dir = setdir
								LAGCHECK(LAG_LOW)
							message_admins("[key_name(usr)] set station direction to [direction].")
							logTheThing("admin", src, null, "set station direction to [direction].")
							logTheThing("diary", src, null, "set station direction to [direction]", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
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
							logTheThing("admin", usr, null, "brought back all dead humans as zombies.")
							logTheThing("diary", usr, null, "brought back all dead humans as zombies", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("forcerandomnames")
						if (src.level >= LEVEL_PA)
							if(current_state > GAME_STATE_PREGAME)
								alert("You can only only trigger this before the game starts, sorry pal!")
								return

							force_random_names = 1

							for(var/client/C in clients)
								if (!C.preferences)
									continue
								C.preferences.be_random_name = 1

							message_admins("[key_name(usr)] has set all players to use random names this round.")
							logTheThing("admin", usr, null, "set all players to use random names.")
							logTheThing("diary", usr, null, "set all players to use random names.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("forcerandomlooks")
						if (src.level >= LEVEL_PA)
							if(current_state > GAME_STATE_PREGAME)
								alert("You can only only trigger this before the game starts, sorry pal!")
								return

							force_random_looks = 1

							for(var/client/C in clients)
								if (!C.preferences)
									continue
								C.preferences.be_random_look = 1

							message_admins("[key_name(usr)] has set all players to use random appearances this round.")
							logTheThing("admin", usr, null, "set all players to use random appearances.")
							logTheThing("diary", usr, null, "set all players to use random appearances.", "admin")
						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
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


									playsound(M, "sound/machines/chainsaw_red.ogg", 60, 1)
									M.update_body()
							message_admins("[key_name(usr)] has given everyone new arms.")
							logTheThing("admin", usr, null, "used the Saw Arms secret.")
							logTheThing("diary", usr, null, "used the Saw Arms secret.", "admin")

						else
							alert("You cannot perform this action. You must be of a higher administrative rank!")
							return

					if("emag_all_things")
						if (src.level >= LEVEL_ADMIN)
							if (alert("Do you really want to emag everything?","Bad Idea", "Yes", "No") == "Yes")
								message_admins("[key_name(usr)] has started emagging everything!")
								logTheThing("admin", usr, null, "used the Emag Everything secret.")
								logTheThing("diary", usr, null, "used the Emag Everything secret.", "admin")
								//DO IT!
								for(var/atom/A as mob|obj in world)
									if(A)
										A.emag_act(null,null)
									LAGCHECK(LAG_LOW)
								message_admins("[key_name(usr)] has emagged everything!")
							else
								return

						else
							alert("You need to be at least a Administrator to emag everything")
							return

					if("shakecamera")
						if (src.level >= LEVEL_ADMIN)
							var/intensity = input("Enter intensity of the shaking effect. (2 or over  will also cause mobs to trip over.)","Shaking intensity",null) as num|null
							if (!intensity)
								return
							var/time = input("Enter lenght of the shaking effect.(In milliseconds, don't use more then 400 unless you want players to complain.) ", "Lenght of shaking effect", 1) as num
							logTheThing("admin", src, null, "created a shake effect (intensity [intensity], lenght [time])")
							logTheThing("diary", src, null, "created a shake effect (intensity [intensity], lenght [time])", "admin")
							message_admins("[key_name(usr)] has created a shake effect (intensity [intensity], lenght [time]).")
							for (var/mob/M in mobs)
								SPAWN_DBG(0)
									shake_camera(M, time, intensity)
								if (intensity >= 2)
									M.changeStatus("weakened", 2 SECONDS)

						else
							alert("You need to be at least a Administrator to shake the camera.")
							return

					if("creepifystation")
						if (src.level >= LEVEL_ADMIN)
							if (alert("Are you sure you should creepify the station? There's no going back.", "PARENTAL CONTROL", "Sure thing!", "Not really.") == "Sure thing!")
								message_admins("[key_name(usr)] creepified the station.")
								logTheThing("admin", usr, null, "used the Creepify Station button")
								logTheThing("diary", usr, null, "used the Creepify Station button", "admin")
							creepify_station()
						else
							alert("You need to be at least a Administrator to creepify the station.")
							return


					if ("command_report_zalgo")
						if (src.level >= LEVEL_ADMIN)
							var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as null|text
							input = zalgoify(input, rand(0,2), rand(0, 2), rand(0, 2))
							if(!input)
								return
							var/input2 = input(usr, "Add a headline for this alert?", "What?", "") as null|text
							input2 = zalgoify(input, rand(0,3), rand(0, 3), rand(0, 3))

							if (alert(src, "Headline: [input2 ? "\"[input2]\"" : "None"] | Body: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
								for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
									C.add_centcom_report("[command_name()] Update", input)

								var/sound_to_play = "sound/musical_instruments/artifact/Artifact_Eldritch_4.ogg"
								if (!input2) command_alert(input, "", sound_to_play);
								else command_alert(input, input2, sound_to_play);

								logTheThing("admin", usr, null, "has created a command report (zalgo): [input]")
								logTheThing("diary", usr, null, "has created a command report (zalgo): [input]", "admin")
								message_admins("[key_name(usr)] has created a command report (zalgo)")

					if ("command_report_void")
						if (src.level >= LEVEL_ADMIN)
							var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as null|text
							input = voidSpeak(input)
							if(!input)
								return
							var/input2 = input(usr, "Add a headline for this alert?", "What?", "") as null|text

							if (alert(src, "Headline: [input2 ? "\"[input2]\"" : "None"] | Body: \"[input]\"", "Confirmation", "Send Report", "Cancel") == "Send Report")
								for (var/obj/machinery/communications_dish/C in by_type[/obj/machinery/communications_dish])
									C.add_centcom_report("[command_name()] Update", input)

								var/sound_to_play = "sound/ambience/spooky/Void_Calls.ogg"
								if (!input2) command_alert(input, "", sound_to_play);
								else command_alert(input, input2, sound_to_play);

								logTheThing("admin", usr, null, "has created a command report (void): [input]")
								logTheThing("diary", usr, null, "has created a command report (void): [input]", "admin")
								message_admins("[key_name(usr)] has created a command report (void)")

					if ("noir")
						if(src.level >= LEVEL_ADMIN)
							if (noir)
								if (alert("Had enough of noir?", "Good decisions", "Yes!", "Never!") == "Yes!")
									noir = 0
									for (var/mob/M in mobs)
										if (M.client)
											animate_fade_from_grayscale(M.client, 50)
									message_admins("[key_name(usr)] undid placing the station in noir mode.")
									logTheThing("admin", usr, null, "used the Noir secret to remove noir")
									logTheThing("diary", usr, null, "used the Noir secret to remove noir", "admin")
							if (alert("Are you sure you should noir?", "PARENTAL CONTROL", "Sure thing!", "Not really.") == "Sure thing!")
								noir = 1
								for (var/mob/M in mobs)
									if (M.client)
										animate_fade_grayscale(M.client, 50)
									LAGCHECK(LAG_LOW)
								message_admins("[key_name(usr)] placed the station in noir mode.")
								logTheThing("admin", usr, null, "used the Noir secret")
								logTheThing("diary", usr, null, "used the Noir secret", "admin")

					if("the_great_switcharoo")
						if(src.level >= LEVEL_ADMIN) //Will be SG when tested
							if (alert("Do you really wanna do the great switcharoo?", "Awoo, awoo", "Sure thing!", "Not really.") == "Sure thing!")

								var/list/mob/living/people_to_swap = list()

								for(var/mob/living/L in mobs) //Build the swaplist
									if(L && L.key && L.mind && !isdead(L) && (ishuman(L) || issilicon(L)))
										people_to_swap += L
									LAGCHECK(LAG_LOW)

								if(people_to_swap.len > 1) //Jenny Antonsson switches bodies with herself! #wow #whoa
									message_admins("[key_name(usr)] did The Great Switcharoo")
									logTheThing("admin", usr, null, "used The Great Switcharoo secret")
									logTheThing("diary", usr, null, "used The Great Switcharoo secret", "admin")

									var/mob/A = pick(people_to_swap)
									do //More random
										people_to_swap -= A
										var/mob/B = pick(people_to_swap)
										if(A && A.mind && B)
											A.mind.swap_with(B)
										A = B
										LAGCHECK(LAG_LOW)
									while(people_to_swap.len > 0)

							else
								return
						else
							alert("You are not a shit enough guy to switcharoo, bub.")


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
						logTheThing("admin", usr, null, "used Farty Party secret")
						logTheThing("diary", usr, null, "used Farty Party secret", "admin")

					else
				if (usr) logTheThing("admin", usr, null, "used secret [href_list["secretsfun"]]")
				logTheThing("diary", usr, null, "used secret [href_list["secretsfun"]]", "admin")
			else
				alert("You need to be at least an Adminstrator to use the secrets panel.")
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
					if("colosseum")
						src.owner:debug_variables(colosseum_controller)
					if("stock")
						src.owner:debug_variables(stockExchange)
					if("emshuttle")
						src.owner:debug_variables(emergency_shuttle)
					if("datacore")
						src.owner:debug_variables(data_core)
					if("miningcontrols")
						src.owner:debug_variables(mining_controls)
					if("goonhub")
						src.owner:debug_variables(goonhub)
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
				alert("You need to be at least a Coder to use debugging secrets.")

		if ("secretsadmin")
			if (src.level >= LEVEL_MOD)
				var/ok = 0

				switch(href_list["type"])
	/*
					if("clear_bombs")
						for(var/obj/item/assembly/radio_bomb/O in world)
							qdel(O)
						for(var/obj/item/assembly/proximity_bomb/O in world)
							qdel(O)
						for(var/obj/item/assembly/time_bomb/O in world)
							qdel(O)
						ok = 1
	*/

					if("check_antagonist")
						if (ticker && ticker.mode && current_state >= GAME_STATE_PLAYING)
							var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
							dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
							dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"

							if (istype(ticker.mode, /datum/game_mode/nuclear))
								var/datum/game_mode/nuclear/NN = ticker.mode
								dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
								for(var/datum/mind/N in NN.syndicates)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
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
									dat += " [NN.target_location_name]</tr></td>"
								else
									dat += " Unknown or not assigned</tr></td>"

								dat += "</table>"

							else if (istype(ticker.mode, /datum/game_mode/revolution))
								dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
								for(var/datum/mind/N in ticker.mode:head_revolutionaries)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"
								for(var/datum/mind/N in ticker.mode:revolutionaries)
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td></tr>"
								dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
								for(var/datum/mind/N in ticker.mode:get_living_heads())
									var/mob/M = N.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
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
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(M)]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
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
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
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
										dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(M)]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
										dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
										for(var/datum/mind/member in gang.members)
											if(member.current != null)
												dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[key_name(member.current)]</a>[member.current.client ? "" : " <i>(logged out)</i>"][isdead(member.current) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
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
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
								dat += "</table>"

							if(ticker.mode.Agimmicks.len > 0)
								dat += "<br><table cellspacing=5><tr><td><B>Misc Foes</B></td><td></td><td></td></tr>"
								for(var/datum/mind/gimmick in ticker.mode.Agimmicks)
									var/mob/M = gimmick.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
								dat += "</table>"

							if(miscreants.len > 0)
								dat += "<br><table cellspacing=5><tr><td><B>Miscreants</B></td><td></td><td></td></tr>"
								for(var/datum/mind/miscreant in miscreants)
									var/mob/M = miscreant.current
									if(!M) continue
									dat += "<tr><td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][isdead(M) ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><a href='?action=priv_msg&target=[M.ckey]'>PM</A></td>"
									dat += "<td><A HREF='?src=\ref[src];action=traitor;target=\ref[M]'>Show Objective</A></td></tr>"
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
						else
							alert("The game hasn't started yet!")
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
						logTheThing("admin", usr, null, "de-electrified all airlocks.")
						logTheThing("diary", usr, null, "de-electrified all airlocks.", "admin")
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
									dat += "<tr><td>[H]</td><td>[H.bioHolder.uid_hash]</td></tr>"
								else if(!H.bioHolder.Uid)
									dat += "<tr><td>[H]</td><td>H.bioHolder.Uid = null</td></tr>"
							LAGCHECK(LAG_LOW)
						dat += "</table>"
						usr.Browse(dat, "window=fingerprints;size=440x410")
					else
				if (usr)
					logTheThing("admin", usr, null, "used secret [href_list["secretsadmin"]]")
					logTheThing("diary", usr, null, "used secret [href_list["secretsadmin"]]", "admin")
					if (ok)
						boutput(world, text("<B>A secret has been activated by []!</B>", usr.key))
				return
			else
				alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)

		if ("view_logs_web")
			if ((src.level >= LEVEL_MOD) && !src.tempmin)
				usr << link("https://mini.xkeeper.net/ss13/admin/log-get.php?id=[config.server_id]&date=[roundLog_date]")

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
				alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)

		if ("view_logs_pathology_strain")
			if (src.level >= LEVEL_MOD)
				var/gettxt
				if (href_list["presearch"])
					gettxt = href_list["presearch"]
				else
					gettxt = input("Which pathogen tree?", "Pathogen tree") in pathogen_controller.pathogen_trees

				var/adminLogHtml = get_log_data_html("pathology", gettxt, src)
				usr.Browse(adminLogHtml, "window=pathology_log;size=750x500")

		if ("s_rez")
			if (src.level >= LEVEL_PA)
				switch(href_list["type"])
					if("spawn_syndies")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Syndicates",3) as num
						if(!amount) return
						SR.spawn_syndies(amount)
						logTheThing("admin", src, null, "has spawned [amount] syndicate operatives.")
						logTheThing("diary", src, null, "has spawned [amount] syndicate operatives.", "admin")

					if("spawn_normal")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Normal Players",3) as num
						if(!amount) return
						SR.spawn_normal(amount)
						logTheThing("admin", src, null, "has spawned [amount] normal players.")
						logTheThing("diary", src, null, "has spawned [amount] normal players.", "admin")

					if("spawn_player") //includes antag players
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_normal(amount, INCLUDE_ANTAGS)
						logTheThing("admin", src, null, "has spawned [amount] players.")
						logTheThing("diary", src, null, "has spawned [amount] players.", "admin")

					if("spawn_player_strip_antag") //includes antag players but strips status
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_normal(amount, INCLUDE_ANTAGS, STRIP_ANTAG)
						logTheThing("admin", src, null, "has spawned [amount] players.")
						logTheThing("diary", src, null, "has spawned [amount] players.", "admin")

					if("spawn_job")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
						var/datum/job/job = input(usr,"Select job to spawn players as:","Respawn Panel",null) as null|anything in jobs
						if(!job) return
						var/amount = input(usr,"Amount to respawn:","Spawn Normal Players",3) as num
						if(!amount) return
						SR.spawn_as_job(amount,job)
						logTheThing("admin", src, null, "has spawned [amount] normal players.")
						logTheThing("diary", src, null, "has spawned [amount] normal players.", "admin")

					if("spawn_player_job") //includes antag players
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
						var/datum/job/job = input(usr,"Select job to spawn players as:","Respawn Panel",null) as null|anything in jobs
						if(!job) return
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_as_job(amount, job, INCLUDE_ANTAGS)
						logTheThing("admin", src, null, "has spawned [amount] players, and kept any antag statuses.")
						logTheThing("diary", src, null, "has spawned [amount] players, and kept any antag statuses.", "admin")

					if("spawn_player_job_strip_antag") //includes antag players but strips antag status
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/list/jobs = job_controls.staple_jobs + job_controls.special_jobs + job_controls.hidden_jobs
						var/datum/job/job = input(usr,"Select job to spawn players as:","Respawn Panel",null) as null|anything in jobs
						if(!job) return
						var/amount = input(usr,"Amount to respawn:","Spawn Players",3) as num
						if(!amount) return
						SR.spawn_as_job(amount, job, INCLUDE_ANTAGS, STRIP_ANTAG)
						logTheThing("admin", src, null, "has spawned [amount] players, and stripped any antag statuses.")
						logTheThing("diary", src, null, "has spawned [amount] players, and stripped any antag statuses.", "admin")

	/*				if("spawn_commandos")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						SR.spawn_commandos(3)

					if("spawn_turds")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						var/amount = input(usr,"Amount to respawn:","Spawn TURDS",3) as num
						if(!amount) return
						SR.spawn_TURDS(amount)
						logTheThing("admin", src, null, "has spawned [amount] TURDS.")
						logTheThing("diary", src, null, "has spawned [amount] TURDS.", "admin")

					if("spawn_smilingman")
						var/datum/special_respawn/SR = new /datum/special_respawn/
						SR.spawn_smilingman(1)
						logTheThing("admin", src, null, "has spawned a Smiling Man.")
						logTheThing("diary", src, null, "has spawned a Smiling Man.", "admin")
	*/

					if("spawn_custom")
						var/datum/special_respawn/SR = new /datum/special_respawn
						var/blType = input(usr, "Select a mob type", "Spawn Custom") as null|anything in typesof(/mob/living)
						if(!blType) return
						var/amount = input(usr, "Amount to respawn:", "Spawn Custom",3) as num
						if(!amount) return
						SR.spawn_custom(blType, amount)
						logTheThing("admin", src, null, "has spawned [amount] mobs of type [blType].")
						logTheThing("diary", src, null, "has spawned [amount] mobs of type [blType].", "admin")

					if("spawn_wizards")

					if("spawn_aliens")

					else
			else
				alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
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
				var/datum/job/job = input(usr,"Select job to respawn [M] as:","Respawn As",null) as null|anything in jobs
				if(!job) return
				var/mob/new_player/newM = usr.client.respawn_target(M)
				newM.AttemptLateSpawn(job, force=1)
				href_list["target"] = "\ref[C.mob]"
			else
				alert ("You must be at least a Secondary Admin to respawn a target.")
		if ("showrules")
			if (src.level >= LEVEL_SA && alert("Are you sure you want to show this player the rules?", "PARENTAL CONTROL", "Sure thing!", "Not really.") == "Sure thing!")
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
					alert( "That player doesn't exist!" )
					return
				src.show_chatbans(M.client)
			else
				alert( "You must be at least a Primary Admin to manage chat bans." )
		if ("change_station_name")
			if (!station_name_changing)
				return alert("Station name changing is currently disabled.")

			if (src.level >= LEVEL_MOD)
				usr.openStationNameChangeWindow(src, "action=change_station_name_2")
			else
				alert ("You must be at least a Moderator to change the station name.")
		if ("change_station_name_2")
			if (!station_name_changing)
				return alert("Station name changing is currently disabled.")

			if (src.level >= LEVEL_MOD)
				var/newName = href_list["newName"]
				if (set_station_name(usr, newName))
					command_alert("The new station name is [station_name]", "Station Naming Ceremony Completion Detection Algorithm")

				usr.Browse(null, "window=stationnamechanger")
				src.Game()

		if ("switch_map")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to switch maps.")

			usr.client.cmd_change_map()

		if ("start_map_vote")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to start map votes.")

			if (!mapSwitcher.votingAllowed)
				return alert("Map votes are currently toggled off.")

			usr.client.cmd_start_map_vote()

		if ("end_map_vote")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to end map votes.")

			usr.client.cmd_end_map_vote()

		if ("cancel_map_vote")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to cancel map votes.")

			usr.client.cmd_cancel_map_vote()

		if ("view_runtimes")
			if (src.level < LEVEL_SA)
				return alert("You must be at least a Secondary Admin to view runtimes.")

			usr.client.cmd_view_runtimes()

		if ("viewantaghistory")
			if (src.level < LEVEL_SA)
				return alert("You must be at least a Secondary Admin to view antag history.")

			usr.client.cmd_antag_history(href_list["targetckey"])

		if ("show_player_stats")
			if (src.level < LEVEL_SA)
				return alert("You must be at least a Secondary Admin to view player stats.")

			//Shortcut to popup with defined params if present, otherwise just call verb
			if (href_list["targetckey"])
				src.showPlayerStats(href_list["targetckey"])
			else
				usr.client.cmd_admin_show_player_stats()

		if ("show_player_ips")
			if (src.level < LEVEL_SA)
				return alert("You must be at least a Secondary Admin to view player IPs.")

			//Shortcut to popup with defined params if present, otherwise just call verb
			if (href_list["ckey"])
				var/ckey = href_list["ckey"]
				src.showPlayerIPs(ckey)
			else
				usr.client.cmd_admin_show_player_ips()

		if ("show_player_compids")
			if (src.level < LEVEL_SA)
				return alert("You must be at least a Secondary Admin to view player Computer IDs.")

			//Shortcut to popup with defined params if present, otherwise just call verb
			if (href_list["ckey"])
				var/ckey = href_list["ckey"]
				src.showPlayerCompIDs(ckey)
			else
				usr.client.cmd_admin_show_player_compids()

		if ("lightweight_doors")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

			usr.client.lightweight_doors()

		if ("lightweight_mobs")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

			usr.client.lightweight_mobs()

		if ("slow_atmos")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

			usr.client.slow_atmos()

		if ("slow_fluids")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

			usr.client.slow_fluids()

		if ("special_sea_fullbright")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

			usr.client.special_fullbright()

		if ("slow_ticklag")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

			usr.client.slow_ticklag()

		if ("disable_deletions")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

			usr.client.disable_deletions()

		if ("disable_ingame_logs")
			if (src.level < LEVEL_PA)
				return alert("You must be at least a Primary Admin to do this.")

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
				var/mob/target = targetClient.mob
				if(!target)
					var/targetCkey = href_list["targetckey"]
					for (var/mob/M in mobs) //The ref may have changed with our actions, find it again
						if (M.ckey == targetCkey)
							href_list["target"] = "\ref[M]"
							continue
					target = locate(href_list["target"])
				usr = adminClient.mob
				usr.client.holder.playeropt(target)

///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/player()
	var/dat = {"<html>
<head>
	<title>Player Menu</title>
	<style>
		table, td, th {
			border-collapse: collapse;
			border: 1px solid rgba(80, 80, 80, .6);
			font-size: 100%;
		}
		th { background: rgba(80, 80, 80, .6); }
		td, th {
			margin:	0;
			padding: 0.25em 0.5em;
		}
	</style>
</head>
<body>
	<table>
		<tr>
			<th colspan='2'>Key</th>
			<th>Name</th>
			<th>Real Name</th>
			<th>Assigned Role</th>
			<th>Special Role</th>
			<th>Type</th>
			<th>Computer ID</th>
			<th>IP</th>
			<th>Joined</th>
		</tr>
		"}

	var/list/mobs = sortmobs()

	for(var/mob/M in mobs)
		if (M.ckey)
			dat += {"
			<tr>
				<td><a href='?src=\ref[src];action=adminplayeropts;target=\ref[M]'>[(M.client ? "[M.client]" : "<em style='opacity: 0.75;'>[M.ckey]</em>")]</a></td>
				<td align="center"><a href='?action=priv_msg&target=[M.ckey]'>PM</a></td>
				<td>[M.name]</td>
				<td>[M.real_name ? "[M.real_name]" : "<em>no real_name</em>"]</td>
				<td>[M.mind ? M.mind.assigned_role : "<em>(no mind/role?)</em>"]</td>
				<td><a href='?src=\ref[src];action=traitor;target=\ref[M]'>[M.mind ? (M.mind.special_role ? "<strong class='alert'>" + M.mind.special_role + "</strong>" : "<em>(none)</em>") : "<em>(no mind?)</em>"]</td>
				<td>[M.type]</td>
				<td align="center">[M.computer_id ? M.computer_id : "None"]</td>
				<td align="center">[M.lastKnownIP]</td>
				<td align="center">[M.client ? M.client.joined_date : "<em>(no client)</em>"]</td>
			</tr>
			"}
			LAGCHECK(LAG_LOW)

	dat += {"
		</table>
	</body>
</html>
"}

	usr.Browse(dat, "window=players;size=1035x480")


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

/datum/admins/proc/buildjobbanspanel()
	set background = 1
	if (building_jobbans != 0)
		boutput(usr, "Rebuild in progress, please try again later.")
		return

	if (alert("Fix a corrupted local panel or force a complete rebuild of the server's panel?","Select Rebuild Type","Local Fix","Server Rebuild") == "Local Fix")
		var/jobban_dialog_text = replacetext(grabResource("html/admin/jobbans_list.html"), "null /* raw_bans */", "\"[global_jobban_cache]\"");
		usr.Browse(replacetext(jobban_dialog_text, "null /* ref_src */", "\"\ref[src]\""),"file=jobbans.html;display=0")
		current_jobbans_rev = global_jobban_cache_rev
		jobbans_last_cached = world.timeofday
		boutput(usr, "Refresh complete, your panel now matches the server's. If you need to edit a ban that was created after the build time shown please do a server rebuild.")
	else
		boutput(usr, "Rebuilding server cache...")

		building_jobbans = 1

		var/buf = ""
		jobban_count = 0
		for(var/t in jobban_keylist) if (t)
			jobban_count++
			buf += text("[t];")

		global_jobban_cache = buf
		global_jobban_cache_rev++
		global_jobban_cache_built = world.timeofday

		building_jobbans = 0
		boutput(usr, "Rebuild complete, everyone's job ban panel is now up to date with the latest job bans.")


/datum/admins/var/current_jobbans_rev = 0
/datum/admins/var/jobbans_last_cached = 0
/datum/admins/proc/Jobbans()
	set background = 1
	if (src.level >= LEVEL_SA)
		if (current_jobbans_rev == 0 || current_jobbans_rev < global_jobban_cache_rev) // the cache is newer than our panel
			var/jobban_dialog_text = replacetext(grabResource("html/admin/jobbans_list.html"), "null /* raw_bans */", "\"[global_jobban_cache]\"");
			usr.Browse(replacetext(jobban_dialog_text, "null /* ref_src */", "\"\ref[src]\""),"file=jobbans.html;display=0")
			current_jobbans_rev = global_jobban_cache_rev
			jobbans_last_cached = world.timeofday

		usr.Browse("<html><head><title>Ban Management</title><style type=\"text/css\">body{font-size: 8pt; font-family: Verdana, sans-serif;}</style></head><body><iframe src=\"jobbans.html\"width=\"100%\" height=\"90%\"></iframe>[jobban_count] job bans. banlist built at [time2text(global_jobban_cache_built)] and downloaded at [time2text(jobbans_last_cached)]</body>", "window=jobbanp;size=400x800")

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

	if (src.level >= LEVEL_PA)
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
				<A href='?src=\ref[src];action=secretsadmin;type=fingerprints'>Fingerprints</A>
			"}

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
					<A href='?src=\ref[src];action=secretsdebug;type=colosseum'>Colosseum</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=stock'>Stock Market</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=emshuttle'>Emergency Shuttle</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=datacore'>Data Core</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=miningcontrols'>Mining Controls</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=goonhub'>Goonhub</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=mapsettings'>Map Settings</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=ghostnotifications'>Ghost Notifications</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=overlays'>Overlays</A>
					<A href='?src=\ref[src];action=secretsdebug;type=overlaysrem'>(Remove)</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=world'>World</A> |
					<A href='?src=\ref[src];action=secretsdebug;type=globals'>Global Variables</A>
					<A href='?src=\ref[src];action=secretsdebug;type=globalprocs'>Global Procs</A>
				"}

		dat += "</div>"

	dat += {"<hr><div class='optionGroup' style='border-color:#77DD77'><b class='title' style='background:#77DD77'>Logs</b>
				<b><A href='?src=\ref[src];action=view_logs_web'>View all logs - web version</A></b><BR>
				<A href='?src=\ref[src];action=view_logs;type=all_logs_string'>Search all Logs</A><BR>
				<A href='?src=\ref[src];action=view_logs;type=speech_log'>Speech Log </A>
				<A href='?src=\ref[src];action=view_logs;type=speech_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=combat_log'>Combat Log </A>
				<A href='?src=\ref[src];action=view_logs;type=combat_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=ooc_log'>OOC Log </A>
				<A href='?src=\ref[src];action=view_logs;type=ooc_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=station_log'>Station Log </A>
				<A href='?src=\ref[src];action=view_logs;type=station_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=pdamsg_log'>PDA Message Log </A>
				<A href='?src=\ref[src];action=view_logs;type=pdamsg_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=telepathy_log'>Telepathy Log </A>
				<A href='?src=\ref[src];action=view_logs;type=telepathy_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=admin_log'>Admin Log</A>
				<A href='?src=\ref[src];action=view_logs;type=admin_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=debug_log'>Debug Log</A>
				<A href='?src=\ref[src];action=view_logs;type=debug_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=admin_help_log'>Adminhelp Log</A>
				<A href='?src=\ref[src];action=view_logs;type=admin_help_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=mentor_help_log'>Mentorhelp Log</A>
				<A href='?src=\ref[src];action=view_logs;type=mentor_help_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=bombing_log'>Bombing Log</A>
				<A href='?src=\ref[src];action=view_logs;type=bombing_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=signalers_log'>Signaler Log</A>
				<A href='?src=\ref[src];action=view_logs;type=signalers_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=atmos_log'>Atmos Log</A>
				<A href='?src=\ref[src];action=view_logs;type=atmos_log_string'><small>(Search)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=pathology_log'>Pathology Log</A>
				<A href='?src=\ref[src];action=view_logs;type=pathology_log_string'><small>(Search)</small></A>
				<A href='?src=\ref[src];action=view_logs_pathology_strain'><small>(Find pathogen)</small></A><BR>
				<A href='?src=\ref[src];action=view_logs;type=vehicle_log'>Vehicle Log</A>
				<A href='?src=\ref[src];action=view_logs;type=vehicle_log_string'><small>(Search)</small></A><br>
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
					<A href='?src=\ref[src];action=secretsfun;type=reliquarystation_wandf'>reliquary station "wandf" </A><BR>
					<A href='?src=\ref[src];action=secretsfun;type=reliquarystation_tdcc'>reliquary station "tdcc" </A><BR>
				"}

	dat += "</div>"

	usr.Browse(dat, "window=gamepanel")
	return

/datum/admins/proc/restart()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set name = "Restart"
	set desc= "Restarts the world"

	if (mapSwitcher.locked)
		return alert("The map switcher is currently compiling the map for next round. You must wait until it finishes.")

	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		boutput(world, "<span class='alert'><b>Restarting world!</b></span> <span class='notice'>Initiated by [admin_key(usr.client, 1)]!</span>")
		logTheThing("admin", usr, null, "initiated a reboot.")
		logTheThing("diary", usr, null, "initiated a reboot.", "admin")

		var/ircmsg[] = new()
		ircmsg["key"] = usr.client.key
		ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
		ircmsg["msg"] = "manually restarted the server."
		ircbot.export("admin", ircmsg)

		round_end_data(2) //Wire: Export round end packet (manual restart)

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
		logTheThing("admin", usr, null, ": [message]")
		logTheThing("diary", usr, null, ": [message]", "admin")

/datum/admins/proc/startnow()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(!ticker)
		alert("Unable to start the game as it is not set up.")
		return
	if(current_state <= GAME_STATE_PREGAME)
		current_state = GAME_STATE_SETTING_UP
		logTheThing("admin", usr, null, "has started the game.")
		logTheThing("diary", usr, null, "has started the game.", "admin")
		message_admins("<span class='internal'>[usr.key] has started the game.</span>")
		return 1
	else
		//alert("Game has already started you fucking jerk, stop spamming up the chat :ARGH:") //no, FUCK YOU coder, for making this annoying popup
		boutput(usr,"Game is already started.")
		return 0

/datum/admins/proc/delay_start()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Delay the game start"
	set name="Delay Round Start"

	if (current_state > GAME_STATE_PREGAME)
		return alert("Too late... The game has already started!", null, null, null, null, null)
	game_start_delayed = !(game_start_delayed)

	if (game_start_delayed)
		boutput(world, "<b>The game start has been delayed.</b>")
		logTheThing("admin", usr, null, "delayed the game start.")
		logTheThing("diary", usr, null, "delayed the game start.", "admin")
		message_admins("<span class='internal'>[usr.key] has delayed the game start.</span>")
	else
		boutput(world, "<b>The game will start soon.</b>")
		logTheThing("admin", usr, null, "removed the game start delay.")
		logTheThing("diary", usr, null, "removed the game start delay.", "admin")
		message_admins("<span class='internal'>[usr.key] has removed the game start delay.</span>")

/datum/admins/proc/delay_end()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER)
	set desc="Delay the server restart"
	set name="Delay Round End"

	if (game_end_delayed == 2)
		logTheThing("admin", usr, null, "removed the restart delay and triggered an immediate restart.")
		logTheThing("diary", usr, null, "removed the restart delay and triggered an immediate restart.", "admin")
		message_admins("<span class='internal'>[usr.key] removed the restart delay and triggered an immediate restart.</span>")
		ircbot.event("roundend")
		Reboot_server()

	else if (game_end_delayed == 0)
		game_end_delayed = 1
		game_end_delayer = usr.key
		logTheThing("admin", usr, null, "delayed the server restart.")
		logTheThing("diary", usr, null, "delayed the server restart.", "admin")
		message_admins("<span class='internal'>[usr.key] delayed the server restart.</span>")

		var/ircmsg[] = new()
		ircmsg["key"] = (usr && usr.client) ? usr.client.key : "NULL"
		ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
		ircmsg["msg"] = "has delayed the server restart."
		ircbot.export("admin", ircmsg)

	else if (game_end_delayed == 1)
		game_end_delayed = 0
		game_end_delayer = null
		logTheThing("admin", usr, null, "removed the restart delay.")
		logTheThing("diary", usr, null, "removed the restart delay.", "admin")
		message_admins("<span class='internal'>[usr.key] removed the restart delay.</span>")

		var/ircmsg[] = new()
		ircmsg["key"] = (usr && usr.client) ? usr.client.key : "NULL"
		ircmsg["name"] = (usr && usr.real_name) ? usr.real_name : "NULL"
		ircmsg["msg"] = "has removed the server restart delay."
		ircbot.export("admin", ircmsg)

/mob/proc/revive()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.full_heal()
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
	if(!(ticker && ticker.mode && istype(ticker.mode, /datum/game_mode/gang)) && traitor_type == "gang leader")
		boutput(usr, "<span class='alert'>Gang Leaders are currently restricted to gang mode only.</span>")
		return

	traitor_type = lowertext(traitor_type)
	special = lowertext(special)

	if(mass_traitor_obj)
		var/datum/objective/custom_objective = new /datum/objective(mass_traitor_obj)
		custom_objective.owner = M.mind
		M.mind.objectives += custom_objective

		if(mass_traitor_esc)
			var/datum/objective/escape/escape_objective = new mass_traitor_esc
			escape_objective.owner = M.mind
			M.mind.objectives += escape_objective
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
			traitor_type = "traitor"
		switch(traitor_type)
			if ("changeling")
				eligible_objectives += /datum/objective/specialist/absorb
			if ("werewolf")
				eligible_objectives += /datum/objective/specialist/werewolf/feed
			if ("vampire")
				eligible_objectives += /datum/objective/specialist/drinkblood
			if ("hunter")
				eligible_objectives += /datum/objective/specialist/hunter/trophy
			if ("grinch")
				eligible_objectives += /datum/objective/specialist/ruin_xmas
			if ("gang leader")
				var/datum/objective/gangObjective = new /datum/objective/specialist/gang(  )
				gangObjective.owner = M.mind
				M.mind.special_role = "gang_leader"
				M.mind.objectives += gangObjective
		var/done = 0
		var/select_objective = null
		var/datum/objective/new_objective = null
		var/custom_text = "Go hog wild!"
		while (done != 1)
			select_objective = input(usr, "Add a new objective. Hit cancel when finished adding.", "Traitor Objectives") as null|anything in eligible_objectives
			if (!select_objective)
				done = 1
				break
			if (select_objective == /datum/objective/regular)
				custom_text = input(usr,"Enter custom objective text.","Traitor Objectives","Go hog wild!") as null|text
				if (custom_text)
					new_objective = new select_objective(custom_text)
					new_objective.owner = M.mind
					new_objective.set_up()
					M.mind.objectives += new_objective
				else
					boutput(usr, "<span class='alert'>No text was entered. Objective not given.</span>")
			else
				new_objective = new select_objective
				new_objective.owner = M.mind
				new_objective.set_up()
				M.mind.objectives += new_objective

		if (M.mind.objectives.len < 1)
			boutput(usr, "<span class='alert'>Not enough objectives specified.</span>")
			return

	if (isAI(M))
		var/mob/living/silicon/ai/A = M
		A.syndicate = 1
		A.syndicate_possible = 1
		A.handle_robot_antagonist_status("admin", 0, usr)
	else if (isrobot(M))
		var/mob/living/silicon/robot/R = M
		if (R.dependent)
			boutput(usr, "<span class='alert'>You can't evilize AI-controlled shells.</span>")
			return
		R.syndicate = 1
		R.syndicate_possible = 1
		R.handle_robot_antagonist_status("admin", 0, usr)
	else if (ishuman(M) || ismobcritter(M))
		switch(traitor_type)
			if("traitor")
				M.show_text("<h2><font color=red><B>You have defected and become a traitor!</B></font></h2>", "red")
				if(special != "hardmode")
					M.mind.special_role = "traitor"
					M.verbs += /client/proc/gearspawn_traitor
					SHOW_TRAITOR_RADIO_TIPS(M)
				else
					M.mind.special_role = "hard-mode traitor"
					SHOW_TRAITOR_HARDMODE_TIPS(M)
			if("changeling")
				M.mind.special_role = "changeling"
				M.show_text("<h2><font color=red><B>You have mutated into a changeling!</B></font></h2>", "red")
				M.make_changeling()
			if("wizard")
				M.mind.special_role = "wizard"
				M.show_text("<h2><font color=red><B>You have been seduced by magic and become a wizard!</B></font></h2>", "red")
				SHOW_ADMINWIZARD_TIPS(M)
				M.verbs += /client/proc/gearspawn_wizard
			if("vampire")
				M.mind.special_role = "vampire"
				M.show_text("<h2><font color=red><B>You have joined the ranks of the undead and are now a vampire!</B></font></h2>", "red")
				M.make_vampire()
			if("hunter")
				M.mind.special_role = "hunter"
				M.mind.assigned_role = "Hunter"
				M.show_text("<h2><font color=red><B>You have become a hunter!</B></font></h2>", "red")
				M.make_hunter()
			if("wrestler")
				M.mind.special_role = "wrestler"
				M.show_text("<h2><font color=red><B>You feel an urgent need to wrestle!</B></font></h2>", "red")
				M.make_wrestler(1)
			if("werewolf")
				M.mind.special_role = "werewolf"
				M.show_text("<h2><font color=red><B>You have become a werewolf!</B></font></h2>", "red")
				M.make_werewolf(1)
			if("grinch")
				M.mind.special_role = "grinch"
				M.make_grinch()
				M.show_text("<h2><font color=red><B>You have become a grinch!</B></font></h2>", "red")
			if("gang leader")
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
				alert(M, "Use the Set Gang Base verb to claim a home turf, and start recruiting people with flyers from the locker!", "You are a gang leader!")
			if("omnitraitor")
				M.mind.special_role = "omnitraitor"
				M.verbs += /client/proc/gearspawn_traitor
				M.verbs += /client/proc/gearspawn_wizard
				M.make_changeling()
				M.make_vampire()
				M.make_werewolf(1)
				M.make_wrestler(1)
				M.make_grinch()
				M.show_text("<h2><font color=red><B>You have become an omnitraitor!</B></font></h2>", "red")
				SHOW_TRAITOR_OMNI_TIPS(M)
			if("spy_thief")
				if (M.stat || !isliving(M) || isintangible(M) || !ishuman(M) || !M.mind)
					return
				M.show_text("<h1><font color=red><B>You have defected to a Spy Thief!</B></font></h1>", "red")
				M.mind.special_role = "spy_thief"
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
		logTheThing("admin", usr, M, "made [constructTarget(M,"admin")] a[special ? " [special]" : ""] [traitor_type].")
		logTheThing("diary", usr, M, "made [constructTarget(M,"diary")] a[special ? " [special]" : ""] [traitor_type].", "admin")
		message_admins("<span class='internal'>[key_name(usr)] has made [key_name(M)] a[special ? " [special]" : ""] [traitor_type].</span>")
	return

/datum/admins/proc/get_item_desc(var/target)
	switch (target)
		if (1)
			return "a fully loaded laser gun"
		if (2)
			return "a hand teleporter"
		if (3)
			return "a fully armed and heated plasma bomb"
		if (4)
			return "a jet pack"
		if (5)
			return "an ID card with universal access"
		if (6)
			return "a captain's dark green jumpsuit"
		else
			return "Error: Invalid theft target: [target]"

/proc/get_matches_string(var/text, var/list/possibles)
	var/list/matches = new()
	for (var/possible in possibles)
		if (findtext(possible, text))
			matches += possible

	return matches

/proc/get_one_match_string(var/text, var/list/possibles)
	var/list/matches = get_matches_string(text, possibles)
	if (matches.len == 0)
		return null
	var/chosen
	if (matches.len == 1)
		chosen = matches[1]
	else
		chosen = input("Select a match", "matches for pattern", null) as null|anything in matches
		if (!chosen)
			return null

	return chosen

/proc/get_matches(var/object, var/base = /atom)
	var/list/types = typesof(base)

	var/list/matches = new()

	for(var/path in types)
		if(findtext("[path]", object))
			matches += path

	return matches

/proc/get_one_match(var/object, var/base = /atom)
	var/list/matches = get_matches(object, base)

	if(matches.len==0)
		return null

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		var/safe_matches = matches - list(/database, /client, /icon, /sound, /savefile)
		chosen = input("Select an atom type", "Matches for pattern", null) as null|anything in safe_matches
		if(!chosen)
			return null

	return chosen

/datum/admins/proc/spawn_atom(var/object as text)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set desc="(atom path) Spawn an atom"
	set name="Spawn"
	if(!object)
		return

	if (usr.client.holder.level >= LEVEL_PA)
		var/chosen = get_one_match(object)

		if (chosen)
			if (ispath(chosen, /turf))
				var/turf/location = get_turf(usr)
				if (location)
					location.ReplaceWith(chosen, handle_air = 0)
			else
				var/atom/movable/A
				if (usr.client.holder.spawn_in_loc)
					A = new chosen(usr.loc)
				else
					A = new chosen(get_turf(usr))
				if (usr.client.flourish)
					spawn_animation1(A)
			logTheThing("admin", usr, null, "spawned [chosen] at ([showCoords(usr.x, usr.y, usr.z)])")
			logTheThing("diary", usr, null, "spawned [chosen] at ([showCoords(usr.x, usr.y, usr.z, 1)])", "admin")

	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
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
			logTheThing("admin", usr, null, "spawned [chosen] at ([showCoords(T.x, T.y, T.z)])")
			logTheThing("diary", usr, null, "spawned [chosen] at ([showCoords(T.x, T.y, T.z, 1)])", "admin")

	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
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
			logTheThing("admin", usr, null, "spawned [chosen] at ([showCoords(T.x, T.y, T.z)])")
			logTheThing("diary", usr, null, "spawned [chosen] at ([showCoords(T.x, T.y, T.z, 1)])", "admin")

	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return

/datum/admins/proc/show_chatbans(var/client/C)//do not use this as an example of how to write DM please.
	if( !C.cloud_available() )
		alert( "Failed to communicate to Goonhub." )
		return
	var/built = {"<title>Chat Bans (todo: prettify)</title>"}
	if(C.cloud_get( "adminhelp_banner" ))
		built += "<a href='?src=\ref[src];target=\ref[C];action=ah_unmute' class='alert'>Adminhelp Mute</a> (Last by [C.cloud_get( "adminhelp_banner" )])<br/>"
		logTheThing("admin", src, C, "unmuted [constructTarget(C,"admin")] from adminhelping.")
	else
		built += "<a href='?src=\ref[src];target=\ref[C];action=ah_mute'>Adminhelp Mute</a><br/>"
		logTheThing("admin", src, C, "muted [constructTarget(C,"admin")] from adminhelping.")

	if(C.cloud_get( "mentorhelp_banner" ))
		built += "<a href='?src=\ref[src];target=\ref[C];action=mh_unmute' class='alert'>Mentorhelp Mute</a> (Last by [C.cloud_get( "mentorhelp_banner" )])<br/>"
		logTheThing("admin", src, C, "unmuted [constructTarget(C,"admin")] from mentorhelping.")
	else
		built += "<a href='?src=\ref[src];target=\ref[C];action=mh_mute'>Mentorhelp Mute</a><br/>"
		logTheThing("admin", src, C, "muted [constructTarget(C,"admin")] from mentorhelping.")

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
	if (istype(BE, /datum/bioEffect/power)) //powers
		P = BE
		P.power = P.global_instance_power.power
		P.cooldown = P.global_instance_power.cooldown
		P.safety = P.global_instance_power.safety

/client/proc/cmd_admin_managebioeffect(var/mob/M in mobs)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Manage Bioeffects"
	set desc = "Select a mob to manage its bioeffects."
	set popup_menu = 0
	admin_only

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
		if (istype(B, /datum/bioEffect/power))//powers only
			P = B
			if (P.power)
				is_power_boosted = 1
			else
				is_power_boosted = 0
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
	admin_only

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

/client/proc/respawn_target(mob/M as mob in world, var/forced = 0)
	set name = "Respawn Target"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "Respawn a mob"
	set popup_menu = 0
	if (!M) return

	if (!forced && alert(src, "Respawn [M]?", "Confirmation", "Yes", "No") != "Yes")
		return

	logTheThing("admin", src, M, "respawned [constructTarget(M,"admin")]")
	logTheThing("diary", src, M, "respawned [constructTarget(M,"diary")].", "admin")
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

	if(!isobserver(usr))
		boutput(usr, "You can't respawn unless you're dead!")
		return

	logTheThing("admin", src, null, "respawned themselves.")
	logTheThing("diary", src, null, "respawned themselves.", "admin")
	message_admins("[key_name(src)] respawned themselves.")

	var/mob/new_player/M = new()

	M.key = usr.client.key
	M.Login()

/client/proc/smnoclip()
	set name = "Planar Shift"
	set category = "Smiling Man Powers"
	set desc = "Shift planes to toggle moving through walls and objects."

	if(!isliving(usr))
		return

	usr.client.flying = !usr.client.flying
	boutput(usr, "You are [usr.client.flying ? "now" : "no longer"] flying through matter.")

/client/Move(NewLoc, direct)
	if(usr.client.flying)
		if(!isturf(usr.loc))
			usr.set_loc(get_turf(usr))

		if(NewLoc)
			usr.set_loc(NewLoc)
			src.mob.dir = direct
			return

		if((direct & NORTH) && usr.y < world.maxy)
			usr.y++
		if((direct & SOUTH) && usr.y > 1)
			usr.y--
		if((direct & EAST) && usr.x < world.maxx)
			usr.x++
		if((direct & WEST) && usr.x > 1)
			usr.x--

		src.mob.dir = direct
	else
		..()

/*
/mob/living/carbon/proc/cloak()
	//Buggy as heck because of the way updating clothing works (it clears all invisibility variables and sets them based on if you have a cloaking device on or not)
	//It also clears overlays so the overlay will dissapear and bluh, I don't want to add another variable sooo this is what you get I guess.
	//If the overlay dissapears you lose the cloaking too, so just retype cloak-self and it should work again
	//If you don't lay down or force yourself to update clothing via fire or whatever it should be good enough to use for the purpose of spying on shitlords I guess.
	set name = "Cloak self"
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set desc = "Make yourself invisible!"

	if (!iscarbon(usr))
		boutput(usr, "Sorry, you have to be alive!")
		return

	if(!(usr.invisibility == 100))
		boutput(usr, "You are now cloaked")
		usr.set_clothing_icon_dirty()

		usr.overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "shield")

		usr.invisibility = 100
	else
		boutput(usr, "You are no longer cloaked")

		usr.set_clothing_icon_dirty()
		usr.invisibility = 0
*/
//
//
//ALL DONE
//*********************************************************************************************************
//
//

#undef INCLUDE_ANTAGS
#undef STRIP_ANTAG
