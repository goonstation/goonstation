/mob/verb/who()
	set name = "Who"
	var/rendered = "<div class='who-list'>"

	var/list/whoAdmins = list()
	var/list/whoMentors = list()
	var/list/whoNormies = list()
	for (var/client/C in clients)
		if (!C || !C.mob) continue

		//Admins
		if (C.holder)
			if (usr.client.holder) //The viewer is an admin, we can show them stuff
				var/thisW = "<a href='?src=\ref[usr.client.holder];action=adminplayeropts;targetckey=[C.ckey]' class='adminooc text-normal'>"
				if (C.stealth || C.alt_key)
					thisW += "[C.key] <i>(as [C.fakekey])</i>"
				else
					thisW += C.key

				whoAdmins += thisW + "</a>"

			else //A lowly normal person is viewing, hide!
				var/thisW = "<span class='adminooc text-normal'>"
				if (C.alt_key)
					thisW += "[C.fakekey]</span>"
					whoAdmins += thisW
				else if (C.stealth) // no you fucks don't show us as an admin anyway!!
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

	whoAdmins = sortList(whoAdmins)
	whoMentors = sortList(whoMentors)
	whoNormies = sortList(whoNormies)

	if (whoAdmins.len)
		rendered += "<b>Admins:</b>"
		for (var/anAdmin in whoAdmins)
			rendered += anAdmin
	if (whoMentors.len)
		rendered += "<b>Mentors:</b>"
		for (var/aMentor in whoMentors)
			rendered += aMentor
	if (whoNormies.len)
		rendered += "<b>Normal:</b>"
		for (var/aNormie in whoNormies)
			rendered += aNormie

	rendered += "<b>Total Players: [whoAdmins.len + whoMentors.len + whoNormies.len]</b>"
	rendered += "</div>"
	boutput(usr, rendered)

	if (!usr.client.holder)
		logTheThing("admin", usr, null, "used Who and saw [whoAdmins.len] admins.")
		logTheThing("diary", usr, null, "used Who and saw [whoAdmins.len] admins.", "admin")
		if (whoAdmins.len < 1)
			message_admins("<span class='internal'>[key_name(usr)] used Who and saw [whoAdmins.len] admins.</span>")

/client/verb/adminwho()
	set category = "Commands"

	var/adwnum = 0
	var/rendered = ""
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

	for (var/client/C in clients)
		if(C?.mob && !C.holder && C.can_see_mentor_pms())
			rendered += "&emsp;[C]<br>"

	boutput(usr, rendered)

	if(!usr.client.holder)
		logTheThing("admin", usr, null, "used adminwho and saw [adwnum] admins.")
		logTheThing("diary", usr, null, "used adminwho and saw [adwnum] admins.", "admin")
		if(adwnum < 1)
			message_admins("<span class='internal'>[key_name(usr)] used adminwho and saw [adwnum] admins.</span>")
