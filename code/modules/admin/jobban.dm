var
	jobban_runonce	// Updates legacy bans with new info
	jobban_keylist[0]		//to store the keys & ranks

/proc/jobban_fullban(mob/M, rank)
	if (!M || !M.ckey) return
	jobban_keylist.Add(text("[M.ckey] - [rank]"))
	jobban_savebanfile()

/proc/jobban_isbanned(mob/M, rank)
	if (!M || !M.ckey ) return

	//you cant be banned from nothing!!
	if (!rank)
		return 0

	var/datum/job/J = find_job_in_controller_by_string(rank)
	if (J?.no_jobban_from_this_job)
		return 0

	if(jobban_keylist.Find(text("[M.ckey] - Everything Except Assistant")))
		if(rank != "Staff Assistant" && rank != "Technical Assistant" && rank != "Medical Assistant")
			return 1

	if(jobban_keylist.Find(text("[M.ckey] - Engineering Department")))
		if(rank in list("Mining Supervisor","Engineer","Atmospheric Technician","Miner","Mechanic"))
			return 1

	if(jobban_keylist.Find(text("[M.ckey] - Security Department")) || jobban_keylist.Find(text("[M.ckey] - Security Officer")))
		if(rank in list("Security Officer","Vice Officer","Detective"))
			return 1

	if(jobban_keylist.Find(text("[M.ckey] - Heads of Staff")))
		if(rank in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director","Medical Director"))
			return 1

	if(jobban_keylist.Find(text("[M.ckey] - [rank]")))
		return 1
	else
		return 0

/proc/jobban_loadbanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] >> jobban_keylist
	logTheThing("admin", null, null, "Loading jobban_rank")
	logTheThing("diary", null, null, "Loading jobban_rank", "admin")
	S["runonce"] >> jobban_runonce
	if (!length(jobban_keylist))
		jobban_keylist=list()
		logTheThing("admin", null, null, "Jobban_keylist was empty")
		logTheThing("diary", null, null, "Jobban_keylist was empty", "admin")

/proc/jobban_savebanfile()
	var/savefile/S=new("data/job_full.ban")
	S["keys[0]"] << jobban_keylist

/proc/jobban_unban(mob/M, rank)
	if (!M || !M.ckey ) return

	jobban_keylist.Remove(text("[M.ckey] - [rank]"))

	if(rank == "Security Department")
		if(jobban_keylist.Find(text("[M.ckey] - Security Officer")))
			jobban_unban(M.ckey, "Security Officer")

	jobban_savebanfile()

/proc/jobban_updatelegacybans()
	if(!jobban_runonce)
		logTheThing("admin", null, null, "Updating jobbanfile!")
		logTheThing("diary", null, null, "Updating jobbanfile!", "admin")
		// Updates bans.. Or fixes them. Either way.
		for(var/T in jobban_keylist)
			if(!T)	continue
		jobban_runonce++	//don't run this update again

/proc/jobban_remove(X)
	if(jobban_keylist.Find(X))
		jobban_keylist.Remove(X)
		jobban_savebanfile()
		return 1
	return 0
