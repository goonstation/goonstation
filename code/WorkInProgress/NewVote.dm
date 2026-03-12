var/list/recently_dead = new/list()
var/datum/vote_manager/vote_manager = new/datum/vote_manager()

//commented out for assjam modevote
/**
/mob/verb/vote_new()
	set name = "Initiate Vote"

	//if(!config.allow_vote_restart && !config.allow_vote_mode && !src.client.holder)
	//	boutput(src, SPAN_ALERT("Player voting disabled."))
	//	return
	if(!ticker)
		boutput(src, SPAN_ALERT("Can not start votes before the game starts."))
		return
	if(!vote_manager) return //shits hitting the fan at ludicrous speeds
	if(vote_manager.active_vote) vote_manager.show_vote(src.client)
	else
		if(src.ckey in vote_log)
			if(vote_log[src.ckey] < max_votes_per_round)
				if(vote_manager.show_vote_selection(src.client)) vote_log[src.ckey]++
			else
				boutput(src, SPAN_ALERT("You may not start any more votes this round. (Maximum reached : [max_votes_per_round])"))
		else
			if(vote_manager.show_vote_selection(src.client)) vote_log[src.ckey] = 1
*/

/client/proc/viewnewvote()
	set category = "Commands"
	set name = "View Current Vote"
	set desc = "Shows you the current ongoing non-map vote."

	vote_manager.show_vote(src)


/obj/newVoteLink
	name = "<span style='color: green; text-decoration: underline;'>Vote</span>"

	Click()
		var/client/C = usr.client
		if (!C) return
		vote_manager.show_vote(C)

	examine()
		return list()

	proc/update_name(new_name="Vote")
		src.name = "<span style='color: green; text-decoration: underline;'>[new_name]</span>"

	proc/chat_link()
		return "<a href='byond://?src=\ref[src]'>[src]</a>"

	Topic(href, href_list)
		. = ..()
		Click()

var/global/obj/newVoteLink/newVoteLinkStat = new /obj/newVoteLink


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
				//	boutput(C, SPAN_ALERT("Restart votes disabled."))
				//	return
				if((C.ckey in recently_dead) && !C.holder)
					boutput(C, SPAN_ALERT("You may not start this type of vote because you recently died."))
					return
				if(C.mob.stat && !C.holder)
					boutput(C, SPAN_ALERT("You may not start this type of vote while dying/unconscious."))
					return
				if(active_vote) return 0
				active_vote = new/datum/vote_new/restart()
				boutput(world, SPAN_SUCCESS("<BIG><B>Vote restart initiated by [C.ckey]</B></BIG>"))
				show_vote(C)
				return 1
			if("Gamemode")
				//if(!config.allow_vote_mode && !C.holder)
				//	boutput(C, SPAN_ALERT("Gamemode votes disabled."))
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
				boutput(world, SPAN_SUCCESS("<BIG><B>Vote gamemode ([mode]) initiated by [C.ckey]</B></BIG>"))
				show_vote(C)
				return 1
			/*if("Player Ban")
				if(world.time < 6000)
					boutput(C, SPAN_ALERT("You may not start this type of vote yet."))
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
				boutput(world, SPAN_SUCCESS("<BIG><B>Vote Ban ([player]) initiated by [C.ckey]</B></BIG>"))
				show_vote(C)
				return 1
			if("Player Mute")
				if(world.time < 6000)
					boutput(C, SPAN_ALERT("You may not start this type of vote yet."))
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
				boutput(world, SPAN_SUCCESS("<BIG><B>Vote Mute ([player]) initiated by [C.ckey]</B></BIG>"))
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
			boutput(world, SPAN_SUCCESS("<BIG><B>Voting aborted.</B></BIG>"))

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
	var/vote_abstain_weight = 0.2 //how much each non-participant counts for in votes that have a "No" result
	var/data = null
	var/vote_flags = 0
	var/curr_win = ""
	var/kill = 0 //just making sure ...

	New(var/A)
		for(var/client/C in clients)
			C.verbs += /client/proc/viewnewvote
			may_vote += C.ckey
		vote_started = world.time
		data = A
		newVoteLinkStat.update_name(src.vote_name ? src.vote_name : "Vote")
		SPAWN(vote_length)
			end_vote()
		..()

	proc/show_to(var/client/C)
		if(kill) return
		if(C in open_votes) return
		if(!(C.ckey in may_vote))
			boutput(C, SPAN_ALERT("<BIG>You may not vote as you were not present when the vote was started.</BIG>"))
			return
		if((C.ckey in voted_ckey) || (C.computer_id in voted_id))
			boutput(C, SPAN_ALERT("<BIG>You have already voted. Current winner: [get_winner()]</BIG>"))
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
		if(ON_COOLDOWN(global, "new vote get_winner", 2 SECONDS))
			return src.curr_win
		var/winner = null
		var/winner_num = 0
		var/adjAbstain = 0
		for(var/A in options)
			if(options[A] >= 0)
				if(A == "No") // abstain = partial no, in votes that contain a no option.
					adjAbstain = options[A]
					for(var/client/C in clients)
						if(!((C.ckey in voted_ckey) || (C.computer_id in voted_id)))
							adjAbstain = adjAbstain + vote_abstain_weight
					if(adjAbstain > winner_num)
						winner_num = adjAbstain
						winner = A
				else
					if(options[A] > winner_num)
						winner_num = options[A]
						winner = A
		if(!winner) winner = "none"
		src.curr_win = winner
		return src.curr_win

	proc/get_winner_num()
		var/winner_num = 0
		var/adjAbstain = 0
		for(var/A in options)
			if(options[A] >= 0)
				if(A == "No")
					adjAbstain = options[A]
					for(var/client/C in clients)
						if(!((C.ckey in voted_ckey) || (C.computer_id in voted_id)))
							adjAbstain = adjAbstain + vote_abstain_weight
					if(adjAbstain > winner_num)
						winner_num = adjAbstain
				else
					if(options[A] > winner_num)
						winner_num = options[A]
		return(winner_num)

	proc/end_vote()
		vote_manager.active_vote = null
		for(var/client/C in clients)
			C.verbs -= /client/proc/viewnewvote
		qdel(src)


/datum/vote_new/mode
	options = list("Yes","No")
	details = ""
	vote_name = "Change gamemode"
	vote_length = 1200 //2 Minutes

	New(var/A)
		details = "Change gamemode to '[A]' ?"
		vote_name = "Change gamemode to [A]"
		..()

	end_vote()
		// boutput(world, SPAN_SUCCESS("<BIG><B>Vote gamemode result: [get_winner()]</B></BIG>"))
		if(get_winner() != "Yes")
			boutput(world, SPAN_ALERT("<BIG><B>Insufficient votes, game mode not changed.</B></BIG>"))
		else if(current_state == GAME_STATE_PREGAME)
			boutput(world, SPAN_SUCCESS("<BIG><B>Gamemode for upcoming round has been changed to [data].</B></BIG>"))
			master_mode = lowertext(data)
		else
			boutput(world, SPAN_SUCCESS("<BIG><B>Gamemode will be changed to [data] at next round start.</B></BIG>"))
			world.save_mode(lowertext(data))
		. = ..()

/datum/vote_new/restart
	options = list("Yes","No")
	details = "Restart the server?"
	vote_name = "Vote restart"
	vote_length = 1200 //2 Minutes
	vote_abstain_weight = 0.5

	end_vote()
		boutput(world, SPAN_SUCCESS("<BIG><B>Vote restart result: [get_winner()]</B></BIG>"))
		if(get_winner() == "Yes")
			Reboot_server()
		. = ..()
/*
//these haven't been adjusted to new weighted vote stuff yet
/datum/vote_new/ban
	options = list("Yes","No")
	details = ""
	vote_name = "Vote Ban"
	vote_length = 1200 //2 Minutes
	var/backup_ckey = ""
	var/backup_computerid = ""
	var/backup_ip = " "

	New(var/A)
		for(var/client/C in clients)
			C.verbs += /client/proc/viewnewvote
			may_vote += C.ckey
		vote_started = world.time
		data = A
		details = "Ban player '[A:mob:name]' for 1 day?"
		backup_ckey = A:ckey
		backup_computerid = A:computer_id
		backup_ip = A:client.address
		process()

	end_vote()
		vote_manager.active_vote = null
		boutput(world, SPAN_SUCCESS("<BIG><B>Vote ban result: [get_winner()]</B></BIG>"))
		if(get_winner() == "Yes")
			if(get_winner_num() < round(total_clients() * 0.7))
				boutput(world, SPAN_SUCCESS("<BIG><B>Minimum ban votes not reached (~70% of players) - Player not banned.</B></BIG>"))
				qdel(src)
				return
			if(data)
				boutput(world, SPAN_SUCCESS("<BIG><B>[data:mob:name] / [data:ckey] has been banned for 3 hours.</B></BIG>"))
				AddBan(data:ckey, data:computer_id, data:client.address, "VOTE BAN - 1 day", "VOTEBAN", 1, 180)
				qdel(data)
			else //Logged out while vote was in progress. Longer ban!
				boutput(world, SPAN_SUCCESS("<BIG><B>[data:backup_ckey] has been banned for 1 week for logging out while vote was in progress.</B></BIG>"))
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
		for(var/client/C in clients)
			C.verbs += /client/proc/viewnewvote
			may_vote += C.ckey
		vote_started = world.time
		data = A
		details = "Mute player '[A:mob:name]'?"
		backup_ckey = A:ckey
		backup_computerid = A:computer_id
		backup_ip = A:client.address
		process()

	end_vote()
		vote_manager.active_vote = null
		boutput(world, SPAN_SUCCESS("Vote mute result: [get_winner()]"))
		if(get_winner() == "Yes")
			if(get_winner_num() < round(total_clients() * 0.5))
				boutput(world, SPAN_SUCCESS("<BIG><B>Minimum mute votes not reached (~50% of players) - Player not muted.</B></BIG>"))
				qdel(src)
				return
			if(data)
				boutput(world, SPAN_SUCCESS("<BIG><B>[data:mob:name] has been muted.</B></BIG>"))
				//data:mob:muted = 1
			else //Logged out while vote was in progress.
				boutput(world, SPAN_SUCCESS("<BIG><B>[data:backup_ckey] has been banned for 15 minutes for logging out while vote was in progress.</B></BIG>"))
				AddBan(backup_ckey, backup_computerid, backup_ip, "VOTE MUTE - Logged out while vote was in progress - 15 minutes", "VOTEMUTE", 1, 15)
		qdel(src)
		return
*/
