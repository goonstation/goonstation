/mob/verb/who()
	set name = "Who"

	var/list/rendered = list("<div class='who-list'>")

	var/list/whoAdmins = list()
	var/list/whoMentors = list()
	var/list/whoNormies = list()

	for (var/client/C as anything in clients)
		if (!C || !C.mob) continue

		//Admins
		if (C.holder)
			if (usr.client.holder) //The viewer is an admin, we can show them stuff
				var/thisW = "<a href='?src=\ref[usr.client.holder];action=adminplayeropts;targetckey=[C.ckey]' class='adminooc text-normal'>"
				if (C.stealth)
					if (C.fakekey)
						thisW += "<i>[C.key] (stealthed as [C.fakekey])</i>"
					else
						thisW += "<i>[C.key] (hidden)</i>"

				else if (C.alt_key)
					thisW += "[C.key] (as [C.fakekey])"
				else
					thisW += C.key

				whoAdmins += thisW + "</a>"

			else //A lowly normal person is viewing, hide!
				var/thisW = "<span class='adminooc text-normal'>"
				if (C.alt_key)
					thisW += "[C.fakekey]</span>"
					whoAdmins += thisW
				else if (C.stealth) // no you fucks don't show us as an admin anyway!!
					if (C.fakekey)
						// Only show them if they have a key to show. Shhhh.
						whoNormies += "<span class='ooc text-normal'>[C.fakekey]</span>"
				else
					thisW += "[C.key]</span>"
					whoAdmins += thisW

		//Mentors
		else if (C.can_see_mentor_pms())
			var/thisW
			if (usr.client.holder)
				thisW += "<a href='?src=\ref[usr.client.holder];action=adminplayeropts;targetckey=[C.ckey]' class='mentorooc text-normal'>"
			else
				thisW += "<span class='mentorooc text-normal'>"

			thisW += C.key + (usr.client.holder ? "</a>" : "</span>")
			whoMentors += thisW

		//Normies
		else
			var/thisW
			if (usr.client.holder)
				thisW += "<a href='?src=\ref[usr.client.holder];action=adminplayeropts;targetckey=[C.ckey]' class='ooc text-normal'>"
			else
				thisW += "<span class='ooc text-normal'>"

			thisW += C.key + (usr.client.holder ? "</a>" : "</span>")
			whoNormies += thisW

	if (length(whoAdmins))
		sortList(whoAdmins, /proc/cmp_text_asc)
		rendered += "<b>Admins:</b>"
		for (var/anAdmin in whoAdmins)
			rendered += anAdmin
	if (length(whoMentors))
		sortList(whoMentors, /proc/cmp_text_asc)
		rendered += "<b>Mentors:</b>"
		for (var/aMentor in whoMentors)
			rendered += aMentor
	if (length(whoNormies))
		sortList(whoNormies, /proc/cmp_text_asc)
		rendered += "<b>Normal:</b>"
		for (var/aNormie in whoNormies)
			rendered += aNormie

	rendered += "<b>Total Players: [length(whoAdmins) + length(whoMentors) + length(whoNormies)]</b>"
	rendered += "</div>"
	boutput(usr, rendered.Join())

	if (!usr.client.holder)
		logTheThing(LOG_ADMIN, usr, "used Who and saw [whoAdmins.len] admins.")
		logTheThing(LOG_DIARY, usr, "used Who and saw [whoAdmins.len] admins.", "admin")
		if (length(whoAdmins) < 1)
			for (var/client/C as anything in clients)
				if (C?.holder?.adminwho_alerts && !C.player_mode)
					var/msg = "<span class='admin'>ADMIN LOG: [key_name(usr)] used Who and saw [length(whoAdmins)] admins.</span>"
					boutput(C, replacetext(replacetext(msg, "%admin_ref%", "\ref[C?.holder]"), "%client_ref%", "\ref[C]"))

/client/verb/adminwho()
	set category = "Commands"

	var/adwnum = 0
	var/list/rendered = list("")
	rendered += "<b>Remember: even if there are no admins ingame, your adminhelps will still be sent to our Discord channel. Current Admins:</b><br>"

	for (var/client/C in clients)
		if (C?.mob && C.holder && !C.player_mode)
			if (usr.client.holder)
				rendered += "[C.key] is "

				if (C.holder.rank == "Administrator")
					rendered += "an"
				else
					rendered += "a"

				rendered += " [C.holder.rank][(C.stealth || C.fakekey) ? " <i>(as [C.fakekey])</i>" : ""]<br>"
			else
				if (C.alt_key)
					rendered += "&emsp;[C.fakekey]<br>"
					adwnum++
				else if (!C.stealth)
					rendered += "&emsp;[C]<br>"
					adwnum++

	rendered += "<br><b>Current Mentors:</b><br>"

	for (var/client/C as anything in clients)
		if(C?.mob && !C.holder && C.can_see_mentor_pms())
			rendered += "&emsp;[C]<br>"

	boutput(usr, rendered.Join())

	if(!usr.client.holder)
		logTheThing(LOG_ADMIN, usr, "used adminwho and saw [adwnum] admins.")
		logTheThing(LOG_DIARY, usr, "used adminwho and saw [adwnum] admins.", "admin")
		for(var/client/C as anything in clients)
			if(C?.holder?.adminwho_alerts && !C.player_mode)
				var/msg = "<span class='admin'>ADMIN LOG: [key_name(usr)] used adminwho and saw [adwnum] admins.</span>"
				boutput(C, replacetext(replacetext(msg, "%admin_ref%", "\ref[C?.holder]"), "%client_ref%", "\ref[C]"))
