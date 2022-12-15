var
	oocban_runonce	// Updates legacy bans with new info
	oocban_keylist[0]		//to store the keys & ranks

/proc/oocban_fullban(mob/M)
	if (!M || !M.ckey) return
	oocban_keylist.Add(text("[M.ckey]"))
	oocban_savebanfile()

/proc/oocban_isbanned(mob/M)
	if (!M || !M.ckey ) return
	if(oocban_keylist.Find(text("[M.ckey]")))
		return 1
	else
		return 0

/proc/oocban_loadbanfile()
	var/savefile/S=new("data/ooc_ban.ban")
	S["keys[0]"] >> oocban_keylist
	logTheThing(LOG_ADMIN, null, "Loading oocban_rank")
	logTheThing(LOG_DIARY, null, "Loading oocban_rank", "admin")
	S["runonce"] >> oocban_runonce
	if (!length(oocban_keylist))
		oocban_keylist=list()
		logTheThing(LOG_ADMIN, null, "oocban_keylist was empty")
		logTheThing(LOG_DIARY, null, "oocban_keylist was empty", "admin")

/proc/oocban_savebanfile()
	var/savefile/S=new("data/ooc_ban.ban")
	S["keys[0]"] << oocban_keylist

/proc/oocban_unban(mob/M)
	if (!M || !M.ckey ) return

	oocban_keylist.Remove(text("[M.ckey]"))


	oocban_savebanfile()

/* this... does nothing? -drsingh
/proc/oocban_updatelegacybans()
	set background = 1
	if(!oocban_runonce)
		logTheThing(LOG_ADMIN, null, "Updating jobbanfile!")
		logTheThing(LOG_DIARY, null, "Updating jobbanfile!", "admin")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in oocban_keylist)
			if(!T)	continue
		oocban_runonce++	//don't run this update again
*/
/proc/oocban_remove(X)
	if(oocban_keylist.Find(X))
		oocban_keylist.Remove(X)
		oocban_savebanfile()
		return 1
	return 0
