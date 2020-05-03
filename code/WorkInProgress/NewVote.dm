var/list/recently_dead = new/list()
var/datum/vote_manager/vote_manager = new/datum/vote_manager()
var/list/vote_log = new/list()
var/const/max_votes_per_round = 2
var/const/recently_time = 6000 // 10 mins

/mob/verb/vote_new()
	set name = "Vote"
	//if(!config.allow_vote_restart && !config.allow_vote_mode && !src.client.holder)
	//	boutput(src, "<span class='alert'>Player voting disabled.</span>")
	//	return
	if(!ticker)
		boutput(src, "<span class='alert'>Can not start votes before the game starts.</span>")
		return
	if(!vote_manager) return //shits hitting the fan at ludicrous speeds
	if(vote_manager.active_vote) vote_manager.show_vote(src.client)
	else
		if(src.ckey in vote_log)
			if(vote_log[src.ckey] < max_votes_per_round)
				if(vote_manager.show_vote_selection(src.client)) vote_log[src.ckey]++
			else
				boutput(src, "<span class='alert'>You may not start any more votes this round. (Maximum reached : [max_votes_per_round])</span>")
		else
			if(vote_manager.show_vote_selection(src.client)) vote_log[src.ckey] = 1

/datum/vote_manager
	var/datum/vote_new/active_vote = null

	proc/show_vote_selection(var/client/C)
		if(active_vote) return 0
		var/choice
	/*
		if(NT.Find(C.ckey) || NTC.Find(C.ckey) || C.holder) //Trusted player.
			choice = input(C,"Please choose the type of vote you would like to start:","Vote",null) in list("Restart", "Gamemode", "Player Ban", "Player Mute", "***CANCEL***")
		else
			choice = input(C,"Please choose the type of vote you would like to start:","Vote",null) in list("Restart", "Gamemode", "Player Mute", "***CANCEL***")
    */
		choice = input(C,"Please choose the type of vote you would like to start:","Vote",null) in list("Restart", "Gamemode"/*, "Player Mute"*/, "***CANCEL***")
		if(!choice) return 0

		switch(choice)
			if("***CANCEL***")
				return 0
			if("Restart")
				//if(!config.allow_vote_restart && !C.holder)
				//	boutput(C, "<span class='alert'>Restart votes disabled.</span>")
				//	return
				if(C.ckey in recently_dead && !C.holder)
					boutput(C, "<span class='alert'>You may not start this type of vote because you recently died.</span>")
					return
				if(C.mob.stat && !C.holder)
					boutput(C, "<span class='alert'>You may not start this type of vote while dying/unconcious.</span>")
					return
				if(active_vote) return 0
				active_vote = new/datum/vote_new/restart()
				boutput(world, "<span class='success'><BIG><B>Vote restart initiated by [C.ckey]</B></BIG></span>")
				show_vote(C)
				return 1
			if("Gamemode")
				//if(!config.allow_vote_mode && !C.holder)
				//	boutput(C, "<span class='alert'>Gamemode votes disabled.</span>")
				//	return
				var/list/modes = new/list()
				for(var/mode_list in config.votable_modes)
					var/the_mode = capitalize(mode_list)
					if(the_mode == "default") continue
					modes += the_mode
				modes += "Secret"
				var/mode = input(C,"Please choose gamemode:","Vote",null) in modes
				if(!mode) return 0 //Magic?!
				if(active_vote) return 0
				active_vote = new/datum/vote_new/mode(mode)
				boutput(world, "<span class='success'><BIG><B>Vote gamemode ([mode]) initiated by [C.ckey]</B></BIG></span>")
				show_vote(C)
				return 1
			if("Player Ban")
				if(world.time < 6000)
					boutput(C, "<span class='alert'>You may not start this type of vote yet.</span>")
					return
				var/list/bannable = new/list()
				for(var/mob/M in mobs)
					if(!M.client) continue
					if(istype(M,/mob/new_player)) continue
					if(M.client.holder) continue
					bannable += M.name
					bannable[M.name] = M
				bannable += "***CANCEL***"
				var/player = input(C,"Please choose player:","Vote",null) in bannable
				if(!player || player == "***CANCEL***") return 0
				var/mob/picked = bannable[player]
				if(!picked) return 0
				if(active_vote) return 0
				active_vote = new/datum/vote_new/ban(picked.client)
				boutput(world, "<span class='success'><BIG><B>Vote Ban ([player]) initiated by [C.ckey]</B></BIG></span>")
				show_vote(C)
				return 1
			/*if("Player Mute")
				if(world.time < 6000)
					boutput(C, "<span class='alert'>You may not start this type of vote yet.</span>")
					return
				var/list/muteable = new/list()
				for(var/mob/M in mobs)
					if(!M.client) continue
					if(istype(M,/mob/new_player)) continue
					if(M.client.holder) continue
					muteable += M.name
					muteable[M.name] = M
				muteable += "***CANCEL***"
				var/player = input(C,"Please choose player:","Vote",null) in muteable
				if(!player || player == "***CANCEL***") return 0
				var/mob/picked = muteable[player]
				if(!picked) return 0
				if(active_vote) return 0
				active_vote = new/datum/vote_new/mute(picked.client)
				boutput(world, "<span class='success'><BIG><B>Vote Mute ([player]) initiated by [C.ckey]</B></BIG></span>")
				show_vote(C)
				return 1*/
		return 0

	proc/show_vote(var/client/C)
		if(!active_vote) return
		active_vote.show_to(C)
		return

	proc/cancel_vote()
		if(active_vote)
			active_vote.kill = 1
			qdel(active_vote)
			active_vote = null
			boutput(world, "<span class='success'><BIG><B>Voting aborted.</B></BIG></span>")

/datum/vote_new
	var/list/options = new/list()
	var/list/open_votes = new/list()
	var/list/voted_ckey = new/list()
	var/list/voted_id = new/list()
	var/list/may_vote = new/list()
	var/details = ""
	var/vote_name = ""
	var/vote_length = 1200 //2 Minutes
	var/vote_started = 0
	var/data = null
	var/vote_flags = 0
	var/curr_win = ""
	var/kill = 0 //just making sure ...

	New(var/A)
		for(var/mob/M in mobs)
			if(!M.client) continue
			may_vote += M.ckey
		vote_started = world.time
		data = A
		process()
		..()

	proc/process()
		if(kill)
			return
		if(world.time - vote_started >= vote_length)
			end_vote()
			return
		curr_win = get_winner()
		SPAWN_DBG(2 SECONDS) process()

	proc/show_to(var/client/C)
		if(C in open_votes) return
		if(!(C.ckey in may_vote))
			boutput(C, "<span class='alert'><BIG>You may not vote as you were not present when the vote was started.</BIG></span>")
			return
		if(C.ckey in voted_ckey || C.computer_id in voted_id)
			boutput(C, "<span class='alert'><BIG>You have already voted. Current winner : [curr_win]</BIG></span>")
			return
		open_votes += C
		var/choice = input(C,details,vote_name,null) in options
		if(!src) return //I suppose this could happen ...
		if(!choice)
			open_votes -= C
			return
		if(!options[choice]) options[choice] = 1
		else options[choice]++
		open_votes -= C
		voted_ckey += C.ckey
		voted_id += C.computer_id

	proc/get_winner()
		var/winner = null
		var/winner_num = 0
		for(var/A in options)
			if(options[A])
				if(options[A] > winner_num)
					winner_num = options[A]
					winner = A
		if(!winner) winner = "none"
		return(winner)

	proc/get_winner_num()
		var/winner_num = 0
		for(var/A in options)
			if(options[A])
				if(options[A] > winner_num)
					winner_num = options[A]
		return(winner_num)

	proc/end_vote()
		vote_manager.active_vote = null
		qdel(src)
		return

/datum/vote_new/mode
	options = list("Yes","No")
	details = ""
	vote_name = "Vote gamemode"
	vote_length = 1200 //2 Minutes

	New(var/A)
		for(var/mob/M in mobs)
			if(!M.client) continue
			may_vote += M.ckey
		vote_started = world.time
		data = A
		details = "Change gamemode to '[A]' ?"
		process()

	end_vote()
		vote_manager.active_vote = null
		boutput(world, "<span class='success'><BIG><B>Vote gamemode result: [get_winner()]</B></BIG></span>")
		if(get_winner() == "Yes")
			if(get_winner_num() < 3)
				boutput(world, "<span class='success'><BIG><B>Minimum mode votes not reached (3)</B></BIG></span>")
				qdel(src)
				return
			boutput(world, "<span class='success'><BIG><B>Gamemode will be changed to [data] after the next reboot.</B></BIG></span>")
			world.save_mode(lowertext(data))
		qdel(src)
		return

/datum/vote_new/restart
	options = list("Yes","No")
	details = "Restart the server?"
	vote_name = "Vote restart"
	vote_length = 1200 //2 Minutes

	end_vote()
		vote_manager.active_vote = null
		boutput(world, "<span class='success'><BIG><B>Vote restart result: [get_winner()]</B></BIG></span>")
		if(get_winner() == "Yes")
			if(get_winner_num() < 5)
				boutput(world, "<span class='success'><BIG><B>Minimum restart votes not reached (5).</B></BIG></span>")
				qdel(src)
				return
			Reboot_server()
		qdel(src)
		return

/datum/vote_new/ban
	options = list("Yes","No")
	details = ""
	vote_name = "Vote Ban"
	vote_length = 1200 //2 Minutes
	var/backup_ckey = ""
	var/backup_computerid = ""
	var/backup_ip = " "

	New(var/A)
		for(var/mob/M in mobs)
			if(!M.client) continue
			may_vote += M.ckey
		vote_started = world.time
		data = A
		details = "Ban player '[A:mob:name]' for 1 day?"
		backup_ckey = A:ckey
		backup_computerid = A:computer_id
		backup_ip = A:client.address
		process()

	end_vote()
		vote_manager.active_vote = null
		boutput(world, "<span class='success'><BIG><B>Vote ban result: [get_winner()]</B></BIG></span>")
		if(get_winner() == "Yes")
			if(get_winner_num() < 5)
				boutput(world, "<span class='success'><BIG><B>Minimum ban votes not reached (5) - Player not banned.</B></BIG></span>")
				qdel(src)
				return
			if(data)
				boutput(world, "<span class='success'><BIG><B>[data:mob:name] / [data:ckey] has been banned for 3 hours.</B></BIG></span>")
				AddBan(data:ckey, data:computer_id, data:client.address, "VOTE BAN - 1 day", "VOTEBAN", 1, 180)
				qdel(data)
			else //Logged out while vote was in progress. Longer ban!
				boutput(world, "<span class='success'><BIG><B>[data:backup_ckey] has been banned for 1 week for logging out while vote was in progress.</B></BIG></span>")
				AddBan(backup_ckey, backup_computerid, backup_ip, "VOTE BAN - Logged out while vote was in progress - 1 day", "VOTEBAN", 1, 1440)
		qdel(src)
		return

/datum/vote_new/mute
	options = list("Yes","No")
	details = ""
	vote_name = "Vote Mute"
	vote_length = 1200 //2 Minutes
	var/backup_ckey = ""
	var/backup_computerid = ""
	var/backup_ip = " "

	New(var/A)
		for(var/mob/M in mobs)
			if(!M.client) continue
			may_vote += M.ckey
		vote_started = world.time
		data = A
		details = "Mute player '[A:mob:name]'?"
		backup_ckey = A:ckey
		backup_computerid = A:computer_id
		backup_ip = A:client.address
		process()

	end_vote()
		vote_manager.active_vote = null
		boutput(world, "<span class='success'>Vote mute result: [get_winner()]</span>")
		if(get_winner() == "Yes")
			if(get_winner_num() < 3)
				boutput(world, "<span class='success'><BIG><B>Minimum mute votes not reached (3) - Player not muted.</B></BIG></span>")
				qdel(src)
				return
			if(data)
				boutput(world, "<span class='success'><BIG><B>[data:mob:name] has been muted.</B></BIG></span>")
				//data:mob:muted = 1
			else //Logged out while vote was in progress.
				boutput(world, "<span class='success'><BIG><B>[data:backup_ckey] has been banned for 15 minutes for logging out while vote was in progress.</B></BIG></span>")
				AddBan(backup_ckey, backup_computerid, backup_ip, "VOTE MUTE - Logged out while vote was in progress - 15 minutes", "VOTEMUTE", 1, 15)
		qdel(src)
		return
