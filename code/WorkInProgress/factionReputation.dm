//Level == every 1000 positive or negative.
//Global faction list is called factions
//Format is (id : faction datum)

#define REP_MAX_CHANGES_PER_MIN 50 // How many changes to rep per minute max. Very basic exploit protection. Very very basic.

/proc/faction_dbg(var/client/C)
	if(!C) C = usr.client
	var/html = "<body>"
	for(var/A in factions)
		var/datum/faction/F = factions[A]
		html += "<span>[F.id] - [F.name]<br>[F.desc]<br>[C.reputations.get_reputation_value(A)] REP, [C.reputations.get_reputation_level(A)] LVL, [C.reputations.get_reputation_string(A)]</span><br><br><hr><br>"
	html += "</body>"

	usr.Browse(html, "window=factiondbg;can_minimize=1;can_resize=1;size=250x600")
	onclose(usr, "window=factiondbg")
	return

/proc/faction_reset(var/client/C)
	if(!C) C = usr.client
	for(var/A in factions)
		var/datum/faction/F = factions[A]
		C.reputations.set_reputation(A, F.default_rep, 1, 1)
	return

/obj/item/factionreset
	name = "diplomatic correspondence"
	icon = 'icons/obj/writing.dmi'
	icon_state = "stamped-thin"
	desc = "Guaranteed to restore your relations with various groups. Or ... you know ... destroy them."
	var/used = 0

	attack_self(var/mob/user)
		if(used) return
		if(tgui_alert(user, "Using this item will reset ALL your reputation scores - are you sure you want to do this?", "Confirmation", list("Yes", "No")) == "Yes")
			if(tgui_alert(user, "Really really sure?", "Confirmation", list("Yes", "No")) == "Yes")
				used = 1
				user.drop_item(src)
				faction_reset(user.client)
				SPAWN(0)
					boutput(user,"It is done.<br>The papers vanish in a puff of smoke. Politics is easy!")
				qdel(src)

/datum/faction
	nanotrasen
		name = "Nanotrasen"
		desc = "You work for these guys."
		id = "nt"
		default_rep = 0

	syndicate
		name = "Syndicate"
		desc = "These are the baddies."
		id = "syndi"
		default_rep = -4500

/datum/reputations
	var/list/rep_changes_recent = list()
	var/list/rep_changes_all = list()
	var/client/master = null

	New(var/client/C)
		if(C)
			master = C
		..()

	proc/set_reputation(var/id = "", var/amt = 0, var/absolute = 0, var/ignore_limiter = 0)
		if(factions[id])
			var/datum/faction/F = factions[id]
			if(!ignore_limiter)
				var/count = 0
				for(var/X in rep_changes_recent)
					var/diff = world.timeofday - text2num(X)
					if(diff < 0) diff += 864000 //Wrapping protection.
					if(diff > 600) rep_changes_recent.Remove(X)
					else count++
				if(count > REP_MAX_CHANGES_PER_MIN)
					boutput(world, "[count] 3b")
					return 0
			var/time = num2text(world.timeofday)
			var/what = "[absolute?"!":""][amt]"
			rep_changes_recent.Add(time)
			rep_changes_recent[time] = what
			rep_changes_all.Add(time)
			rep_changes_all[time] = what
			return F.set_reputation(master, amt, absolute)
		else
			throw ("Invalid faction id [id]")

	proc/get_reputation_level(var/id = "", var/include_modifiers = 1)
		if(factions[id])
			var/datum/faction/F = factions[id]
			return F.get_reputation_level(master, include_modifiers)
		else throw ("Invalid faction id [id]")

	proc/get_reputation_string(var/id = "", var/include_modifiers = 1)
		if(factions[id])
			var/datum/faction/F = factions[id]
			return F.get_reputation_string(master, include_modifiers)
		else throw ("Invalid faction id [id]")

	proc/get_reputation_value(var/id = "", var/include_modifiers = 1)
		if(factions[id])
			var/datum/faction/F = factions[id]
			return F.get_reputation(master, include_modifiers)
		else throw ("Invalid faction id [id]")

	proc/get_Nanotrasen_rank_string(var/id = "", var/include_modifiers = 1)
		if(factions[id])
			var/datum/faction/F = factions[id]
			return F.get_Nanotrasen_rank_string(master, include_modifiers)
		else throw ("Invalid faction id [id]")

/datum/faction
	var/name = "FACTION"
	var/desc = "FACTION DESCRIPTION"
	var/id = ""
	var/default_rep = 0 //0 == neutral, negative == hostile, positive == friendly

	proc/get_reputation_level(var/client = null, var/include_modifiers = 1) //This is super verbose and could be done much simpler but i chose this to make it easier to visualize.
		var/lvl = get_reputation(client, include_modifiers = 1)
		switch(lvl)
			if(0 to 999) return 0
			if(1000 to 1999) return 1
			if(2000 to 2999) return 2
			if(3000 to 3999) return 3
			if(4000 to 4999) return 4
			if(5000 to 5999) return 5
			if(6000 to INFINITY) return 6
			if(-1999 to -1000) return -1
			if(-2999 to -2000) return -2
			if(-3999 to -3000) return -3
			if(-4999 to -4000) return -4
			if(-5999 to -5000) return -5
			if(-INFINITY to -6000) return -6
		return

	proc/get_reputation_string(var/client = null, var/include_modifiers = 1)
		var/lvl = get_reputation_level(client, include_modifiers = 1)
		switch(lvl)
			if(0) return "Neutral"
			if(1) return "Friendly"
			if(2) return "Respected"
			if(3) return "Trusted"
			if(4) return "Initiated"
			if(5) return "Honored"
			if(6 to INFINITY) return "Exalted"
			if(-1) return "Unfriendly"
			if(-2) return "Suspicious"
			if(-3) return "Mistrusted"
			if(-4) return "Hostile"
			if(-5) return "Despised"
			if(-INFINITY to -6) return "Scorned"
			else return "UNKNOWN"

	proc/get_modifiers(var/client = null)
		//Stub. TBI
		return 0

	proc/get_reputation(var/client/client = null, var/include_modifiers = 1)
		var/modifiers = get_modifiers(client)
		if(!client)
			return default_rep + (include_modifiers ? modifiers : 0)
		var/val = client.player?.cloudSaves.getData("rep_[lowertext(id)]")
		if(val == null)
			set_reputation(client, default_rep, 1)
			val = default_rep
		else if(istext(val))
			val = text2num(val)
		val = val + (include_modifiers ? modifiers : 0)
		return val

	proc/set_reputation(var/client/client = null, var/amt = 0, var/absolute = 0)
		if(!client)
			return 0
		var/curr = (absolute ? 0 : get_reputation(client, 0))
		client.player?.cloudSaves.putData("rep_[lowertext(id)]", (absolute ? amt : (curr + amt)))
		return 0

	proc/get_Nanotrasen_rank_string(var/client = null, var/include_modifiers = 1)
		var/rank = get_reputation_level(client, include_modifiers = 1)
		switch(rank)
			if(1) return "Seaman"
			if(2) return "Cadet"
			if(3) return "Lieutenant"
			if(4) return "Lieutenant First Class"
			if(5) return "Officer"
			if(6 to INFINITY) return "Chief Officer"
			else
				return
