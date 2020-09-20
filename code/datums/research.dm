/datum/research
	//name of the research
	var/name = "generic research"
	//maximum amount of tiers
	var/max_tiers = 0
	//maximum amount of researchable stuff per tier
	var/max_per_list = 0
	//the starting tier, could maybe start at a random tier?
	var/starting_tier = 0
	//tier of research currently at
	var/tier = 1

	//1 if is researching/ 0 if isn't researching
	var/is_researching = 0

	//what is currently being researched
	var/current_research = null
	//in seconds
	//total time research will take
	var/current_research_time = 0.0
////
//For all these lists we'll just be naughty and ignore the 0th component! hehehehe

	//list of items which HAVE been researched and their associated tiers
	var/researched_items
	//list of items which WILL be researched and their associated tiers
	var/items_to_research


	New()
		..()
		//Max tiers is the maximum, make sure this is kept whenever research is created
		if(src.starting_tier > src.max_tiers)
			src.starting_tier = src.max_tiers
		src.tier = src.starting_tier
		items_to_research = new/list(src.max_tiers,src.max_per_list)
		researched_items = new/list(src.max_tiers,src.max_per_list)

	proc/check_if_tier_completed()
		//this is for detecting if we still have things to research in the current tier
		//prevents people from spamming the advance tier button
		//as far as i know the .len for items to research would just return src.max_per_list
		//hence the reason for the for loop

		//This needs to be re-did for each research. For eg, the variable a has to be a datum/ailment for
		//disease research, though if you're researching objects it needs to be /obj/
		//otherwise it will always return 1, as for some reason it counts when you just use var/a

		var/count = 0
		for(var/a in src.items_to_research[src.tier])
			count++
		if(!count)
			return 1
		return 0


	proc/advance_tier()
		if (!check_if_tier_completed()) return 0 // Dont do anything if they havent finished the tier yet
		if (src.tier < src.max_tiers) src.tier++
		else if (src.tier >= src.max_tiers) return 0 // Don't advance if we're at or above max tiers

		if(src.tier > src.max_tiers)
			// If they've somehow advanced when they're already at max, fix it and don't tell everyone about it
			src.tier = src.max_tiers
		else if (src.tier == src.max_tiers)
			//Let the world know that we've finished our research
			var/cashbonus = src.max_tiers * 10000
			wagesystem.station_budget += cashbonus
			return command_alert("Centcom congratulates the scientists of the station for reaching the maximum tier of [src.name]. As a reward for your hard work, we have added $[cashbonus] to the station budget.","Research Announcement")
		else
			//Let everyone know when we have advanced a tier
			return command_alert("Centcom congratulates the scientists of the station for reaching Tier [src.tier] of [src.name].","Research Announcement")

	//Starts the research, sets the research item text.
	//Sets time default to 0 so research can be set up without it being time based
	//eg engineering research could be based on collecting items, setting up the engine etc.
	proc/start_research(var/time = 0, var/research_item, var/applytimebonus = 1)
		//already researching
		if(is_researching)
			return 0
		//can't find it in in the list of shit we need to research
		var/list/tier_items = src.items_to_research[src.tier]
		if(!tier_items.Find(research_item))
			return 0
		// apply time bonus
		if (applytimebonus)
			for(var/i = robotics_research.starting_tier, i <= robotics_research.max_tiers, i++)
				for(var/datum/roboresearch/X in robotics_research.researched_items[i])
					if (X.resebonus && X.resemulti != 0 && time != 0) time /= X.resemulti
			if (wagesystem.research_budget >= 5000)
				time /= 2
				wagesystem.research_budget -= 5000
		// start that shit
		is_researching = 1
		src.current_research = research_item
		//Only if we're considering time
		if(time)
			//when it'll be finished in seconds
			src.current_research_time = round((world.timeofday + time) / 10, 1)
		return 1

	//End research, sets research item to null and updates finished research list
	proc/end_research()
		//already finished or timeleft is not zero
		if(!is_researching)
			boutput(world, "Uh oh, research has fucked up. Line 68, research.dm. Report this to a coder.")
			//this shouldn't happen
			return 0
		src.is_researching = 0
		src.items_to_research[tier] -= src.current_research
		src.researched_items[tier] += src.current_research
		src.current_research = null
		return 1

	// Stops the current research without finishing it
	proc/cancel_research()
		if(!is_researching) return 0 // No need to cancel if we're not researching anything
		src.is_researching = 0
		src.current_research = null
		src.current_research_time = 0
		return 1

	//Returns the time in seconds until researched is finished
	proc/timeleft()
		if(!is_researching)
			return
		//converting timeofday to seconds
		var/timeleft = round(src.current_research_time - (world.timeofday)/10 ,1)
		if(timeleft <= 0)
			src.end_research()
			return 0
		return timeleft

	//Returns the time, in MM:SS format
	proc/get_research_timeleft()
		var/timeleft = src.timeleft()
		if(timeleft)
			return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"

	proc/calculate_research_time(var/tier, var/applytimebonus = 1)
		var/time = tier*1000
		var/finaltime = 0
		if (applytimebonus)
			for(var/i = robotics_research.starting_tier, i <= robotics_research.max_tiers, i++)
				for(var/datum/roboresearch/X in robotics_research.researched_items[i]) if (X.resebonus && X.resemulti != 0 && time != 0) time /= X.resemulti
			if (wagesystem.research_budget >= 5000)
				time /= 2
				wagesystem.research_budget -= 5000
		finaltime = round(time / 10, 1)
		return finaltime

//The disease research will be mostly handled by the research/disease computer
/datum/research/disease
	name = "Disease Research"
	max_tiers = 5
	max_per_list = 5
	starting_tier = 1

	var/datum/ailment/disease/cold/tier_one_one = new()
	var/datum/ailment/disease/fake_gbs/tier_one_two = new()

	var/datum/ailment/disease/flu/tier_two_one = new()
	var/datum/ailment/disease/food_poisoning/tier_two_two = new()

	var/datum/ailment/disease/berserker/tier_three_one = new()
	var/datum/ailment/disease/clowning_around/tier_three_two = new()
	var/datum/ailment/disease/jungle_fever/tier_three_three = new()

	var/datum/ailment/disease/teleportitis/tier_four_one = new()
	var/datum/ailment/disease/robotic_transformation/tier_four_three = new()
	var/datum/ailment/disease/plasmatoid/tier_four_four = new()

	var/datum/ailment/disease/gbs/tier_five_one = new()
	var/datum/ailment/disease/space_madness/tier_five_two = new()
	var/datum/ailment/disease/panacaea/tier_five_three = new()

	items_to_research = new/list(5,5)
	researched_items = new/list(5,5)

	New()
		..()
		src.items_to_research[1] = list(tier_one_one, tier_one_two)
		src.items_to_research[2] = list(tier_two_one, tier_two_two)
		src.items_to_research[3] = list(tier_three_one, tier_three_two, tier_three_three)
		//src.items_to_research[4] = list(tier_four_one, tier_four_two, tier_four_three, tier_four_four, tier_four_five)
		src.items_to_research[5] = list(tier_five_one, tier_five_two, tier_five_three)

	check_if_tier_completed()
		//this is for detecting if we still have things to research in the current tier
		//prevents people from spamming the advance tier button
		//as far as i know the .len for items to research would just return src.max_per_list
		//hence the reason for the for loop
		var/count = 0
		for(var/datum/ailment/a in src.items_to_research[src.tier])
			count++
		if(!count)
			return 1
		return 0

/datum/research/weaponry
/datum/research/engineering
/datum/research/gaseous
/datum/research/portal

/datum/research/artifact
	name = "Artifact Research"
	max_tiers = 3
	max_per_list = 7
	starting_tier = 1

	var/datum/artiresearch/ancient1/tier_one_one = new()
	var/datum/artiresearch/martian1/tier_one_two = new()
	var/datum/artiresearch/crystal1/tier_one_three = new()
	var/datum/artiresearch/eldritch1/tier_one_four = new()
	var/datum/artiresearch/precursor1/tier_one_five = new()
	var/datum/artiresearch/general1/tier_one_six = new()
	var/datum/artiresearch/analyser1/tier_one_seven = new()

	var/datum/artiresearch/ancient2/tier_two_one = new()
	var/datum/artiresearch/martian2/tier_two_two = new()
	var/datum/artiresearch/crystal2/tier_two_three = new()
	var/datum/artiresearch/eldritch2/tier_two_four = new()
	var/datum/artiresearch/precursor2/tier_two_five = new()
	var/datum/artiresearch/general2/tier_two_six = new()
	var/datum/artiresearch/analyser2/tier_two_seven = new()

	var/datum/artiresearch/ancient3/tier_three_one = new()
	var/datum/artiresearch/martian3/tier_three_two = new()
	var/datum/artiresearch/crystal3/tier_three_three = new()
	var/datum/artiresearch/eldritch3/tier_three_four = new()
	var/datum/artiresearch/precursor3/tier_three_five = new()
	var/datum/artiresearch/general3/tier_three_six = new()
	var/datum/artiresearch/analyser3/tier_three_seven = new()

	items_to_research = new/list(3,4)
	researched_items = new/list(3,4)

	New()
		..()
		src.items_to_research[1] = list(tier_one_one, tier_one_two, tier_one_three, tier_one_four, tier_one_five, tier_one_six, tier_one_seven)
		src.items_to_research[2] = list(tier_two_one, tier_two_two, tier_two_three, tier_two_four, tier_two_five, tier_two_six, tier_two_seven)
		src.items_to_research[3] = list(tier_three_one, tier_three_two, tier_three_three, tier_three_four, tier_three_five, tier_three_six, tier_three_seven)

	check_if_tier_completed()
		var/count = 0
		for(var/datum/artiresearch/a in src.items_to_research[src.tier])
			count++
		if(count <= 2)
			return 1
		return 0

/datum/research/robotics
	name = "Robotics Research"
	max_tiers = 4
	max_per_list = 5
	starting_tier = 1

	var/datum/roboresearch/manufone/tier_one_one = new()
	var/datum/roboresearch/drones/tier_one_two = new()
	var/datum/roboresearch/implants1/tier_one_three = new()
	var/datum/roboresearch/modules1/tier_one_four = new()
	var/datum/roboresearch/upgrades1/tier_one_five = new()

	var/datum/roboresearch/manuftwo/tier_two_one = new()
	var/datum/roboresearch/resespeedone/tier_two_two = new()
	var/datum/roboresearch/rewriter/tier_two_three = new()
	var/datum/roboresearch/modules2/tier_two_four = new()
	var/datum/roboresearch/upgrades2/tier_two_five = new()

	var/datum/roboresearch/manufthree/tier_three_one = new()
	var/datum/roboresearch/manuffour/tier_three_two = new()
	var/datum/roboresearch/implants2/tier_three_three = new()
	var/datum/roboresearch/upgrades3/tier_three_four = new()

	var/datum/roboresearch/manuffive/tier_four_one = new()
	var/datum/roboresearch/resespeedtwo/tier_four_two = new()

	items_to_research = new/list(5,4)
	researched_items = new/list(5,4)

	New()
		..()
		src.items_to_research[1] = list(tier_one_one, tier_one_two, tier_one_three, tier_one_four, tier_one_five)
		src.items_to_research[2] = list(tier_two_one, tier_two_two, tier_two_three, tier_two_four, tier_two_five)
		src.items_to_research[3] = list(tier_three_one, tier_three_two, tier_three_three, tier_three_four, null)
		src.items_to_research[4] = list(tier_four_one, tier_four_two, null, null, null)

	check_if_tier_completed()
		var/count = 0
		for(var/datum/roboresearch/a in src.items_to_research[src.tier]) count++
		if(count <= 1) return 1
		return 0

/// Host/Coder Admin verbs for research

/client/proc/cmd_remove_rs_verbs()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Trim Research Debug"
	set desc = "Removes Research Debug verbs."

	src.verbs -= /client/proc/RS_disease_debug
	src.verbs -= /client/proc/RS_artifact_debug
	src.verbs -= /client/proc/RS_robotics_debug
	src.verbs -= /client/proc/RS_grant_research
	src.verbs -= /client/proc/RS_revoke_research
	src.verbs -= /client/proc/RS_grant_tier
	src.verbs -= /client/proc/RS_revoke_tier

	src.verbs -= /client/proc/cmd_remove_rs_verbs
	src.verbs += /client/proc/cmd_claim_rs_verbs

/client/proc/cmd_claim_rs_verbs()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Expand Research Debug"
	set desc = "Gives verbs specific to debugging Research."

	src.verbs += /client/proc/RS_disease_debug
	src.verbs += /client/proc/RS_artifact_debug
	src.verbs += /client/proc/RS_robotics_debug
	src.verbs += /client/proc/RS_grant_research
	src.verbs += /client/proc/RS_revoke_research
	src.verbs += /client/proc/RS_grant_tier
	src.verbs += /client/proc/RS_revoke_tier

	src.verbs += /client/proc/cmd_remove_rs_verbs
	src.verbs -= /client/proc/cmd_claim_rs_verbs

/client/proc/RS_disease_debug()
	set category = "Specialist Debug"
	set name = "Info: Disease"
	set desc = "Displays information about Disease Research."

	var/datum/research/R
	R = disease_research
	var/resetime = R.calculate_research_time(R.tier, 1)
	var/baseresetime = R.calculate_research_time(R.tier, 0)

	var/dat = {"<B>Research Debug</B><BR>
				<HR>
				<B>Research Name:</B> [R.name]<BR>
				<B>Tier:</B> [R.tier]/[R.max_tiers]<BR>
				<B>Current Research Budget:</B> [wagesystem.research_budget]<BR>
				<B>Base Research Time:</B> [add_zero(num2text((baseresetime / 60) % 60),2)]:[add_zero(num2text(baseresetime % 60), 2)]<BR>
				<B>Research Time:</B> [add_zero(num2text((resetime / 60) % 60),2)]:[add_zero(num2text(resetime % 60), 2)]<BR>
				<HR>"}
	if (R.is_researching)
		var/timeleft = R.get_research_timeleft()
		dat += {"<B>Currently Researching:</B> [R.current_research]<BR>
		<B>Time Left:</B> [timeleft]/[add_zero(num2text((resetime / 60) % 60),2)]:[add_zero(num2text(resetime % 60), 2)]<BR><HR>"}
	else dat += {"Not currently researching.<BR><HR>"}

	dat += {"<b>Researched Items:</b><BR>"}
	for(var/i = R.starting_tier, i <= R.max_tiers, i++)
		dat += "<BR><u><i>Tier [i]</i></u><BR>"
		for(var/datum/a in R.researched_items[i])
			dat += "[a:name]<BR>"

	dat += {"<BR><B>Unresearched Items:</B><BR>"}
	for(var/i = R.starting_tier, i <= R.max_tiers, i++)
		dat += "<BR><u><i>Tier [i]</i></u><BR>"
		for(var/datum/a in R.items_to_research[i])
			dat += "[a:name]<BR>"

	usr.Browse(dat, "window=researchdebug;size=400x400")

/client/proc/RS_artifact_debug()
	set category = "Specialist Debug"
	set name = "Info: Artifact"
	set desc = "Displays information about Artifact Research."

	var/datum/research/R
	R = artifact_research
	var/resetime = R.calculate_research_time(R.tier, 1)
	var/baseresetime = R.calculate_research_time(R.tier, 0)

	var/dat = {"<B>Research Debug</B><BR>
				<HR>
				<B>Research Name:</B> [R.name]<BR>
				<B>Tier:</B> [R.tier]/[R.max_tiers]<BR>
				<B>Current Research Budget:</B> [wagesystem.research_budget]<BR>
				<B>Base Research Time:</B> [add_zero(num2text((baseresetime / 60) % 60),2)]:[add_zero(num2text(baseresetime % 60), 2)]<BR>
				<B>Research Time:</B> [add_zero(num2text((resetime / 60) % 60),2)]:[add_zero(num2text(resetime % 60), 2)]<BR>
				<HR>"}
	if (R.is_researching)
		var/timeleft = R.get_research_timeleft()
		dat += {"<B>Currently Researching:</B> [R.current_research]<BR>
		<B>Time Left:</B> [timeleft]/[add_zero(num2text((resetime / 60) % 60),2)]:[add_zero(num2text(resetime % 60), 2)]<BR><HR>"}
	else dat += {"Not currently researching.<BR><HR>"}

	dat += {"<b>Researched Items:</b><BR>"}
	for(var/i = R.starting_tier, i <= R.max_tiers, i++)
		dat += "<BR><u><i>Tier [i]</i></u><BR>"
		for(var/datum/a in R.researched_items[i])
			dat += "[a:name]<BR>"

	dat += {"<BR><B>Unresearched Items:</B><BR>"}
	for(var/i = R.starting_tier, i <= R.max_tiers, i++)
		dat += "<BR><u><i>Tier [i]</i></u><BR>"
		for(var/datum/a in R.items_to_research[i])
			dat += "[a:name]<BR>"

	usr.Browse(dat, "window=researchdebug;size=400x400")

/client/proc/RS_robotics_debug()
	set category = "Specialist Debug"
	set name = "Info: Robotics"
	set desc = "Displays information about Robotics Research."

	var/datum/research/R
	R = robotics_research
	var/resetime = R.calculate_research_time(R.tier, 1)
	var/baseresetime = R.calculate_research_time(R.tier, 0)

	var/dat = {"<B>Research Debug</B><BR>
				<HR>
				<B>Research Name:</B> [R.name]<BR>
				<B>Tier:</B> [R.tier]/[R.max_tiers]<BR>
				<B>Current Research Budget:</B> [wagesystem.research_budget]<BR>
				<B>Base Research Time:</B> [add_zero(num2text((baseresetime / 60) % 60),2)]:[add_zero(num2text(baseresetime % 60), 2)]<BR>
				<B>Research Time:</B> [add_zero(num2text((resetime / 60) % 60),2)]:[add_zero(num2text(resetime % 60), 2)]<BR>
				<HR>"}
	if (R.is_researching)
		var/timeleft = R.get_research_timeleft()
		dat += {"<B>Currently Researching:</B> [R.current_research]<BR>
		<B>Time Left:</B> [timeleft]/[add_zero(num2text((resetime / 60) % 60),2)]:[add_zero(num2text(resetime % 60), 2)]<BR><HR>"}
	else dat += {"Not currently researching.<BR><HR>"}

	dat += {"<b>Researched Items:</b><BR>"}
	for(var/i = R.starting_tier, i <= R.max_tiers, i++)
		dat += "<BR><u><i>Tier [i]</i></u><BR>"
		for(var/datum/a in R.researched_items[i])
			dat += "[a:name]<BR>"

	dat += {"<BR><B>Unresearched Items:</B><BR>"}
	for(var/i = R.starting_tier, i <= R.max_tiers, i++)
		dat += "<BR><u><i>Tier [i]</i></u><BR>"
		for(var/datum/a in R.items_to_research[i])
			dat += "[a:name]<BR>"

	usr.Browse(dat, "window=researchdebug;size=400x400")

/client/proc/RS_grant_research()
	set category = "Specialist Debug"
	set name = "Give Single Research"
	set desc = "Instantly give a research topic."

	var/input = input("Which kind of research?", "Which?", null) as null|anything in list("Disease","Artifact","Robotics")
	var/datum/research/R

	if(input == "Disease") R = disease_research
	else if(input == "Artifact") R = artifact_research
	else if(input == "Robotics") R = robotics_research
	else
		boutput(usr, "<span class='alert'>Invalid Research type.</span>")
		return 0

	var/input2 = input("Which tier?", "Which?", null) as num
	if (input2 > R.max_tiers)
		boutput(usr, "<span class='alert'>This research doesn't have that many tiers!</span>")
		return
	if (input2 < 1) return

	var/list/unfinished = list()
	var/count = 0
	for(var/datum/a in R.items_to_research[input2])
		if (a == R.current_research) continue // might shit itself if we swipe an in-progress research out from under them
		count++
		unfinished += a

	if (!count)
		boutput(usr, "<span class='alert'>Nothing left to research in that tier.</span>")
		return
	var/complete = input("Give which research?", "Which?", null) as null|anything in unfinished
	if (!complete) return

	R.researched_items[input2] += complete
	R.items_to_research[input2] -= complete

/client/proc/RS_grant_tier()
	set category = "Specialist Debug"
	set name = "Give Whole Tier"
	set desc = "Instantly give an entire tier of research topics."

	var/input = input("Which kind of research?", "Which?", null) as null|anything in list("Disease","Artifact","Robotics")
	var/datum/research/R

	if(input == "Disease") R = disease_research
	else if(input == "Artifact") R = artifact_research
	else if(input == "Robotics") R = robotics_research
	else
		boutput(usr, "<span class='alert'>Invalid Research type.</span>")
		return 0

	var/input2 = input("Which tier?", "Which?", null) as num
	if (input2 > R.max_tiers)
		boutput(usr, "<span class='alert'>This research doesn't have that many tiers!</span>")
		return
	if (input2 < 1) return

	for(var/datum/a in R.items_to_research[input2])
		if (a == R.current_research) continue // might shit itself if we swipe an in-progress research out from under them
		R.researched_items[input2] += a
		R.items_to_research[input2] -= a

/client/proc/RS_revoke_research()
	set category = "Specialist Debug"
	set name = "Revoke Single Research"
	set desc = "Revert a finished research to unresearched."

	var/input = input("Which kind of research?", "Which?", null) as null|anything in list("Disease","Artifact","Robotics")
	var/datum/research/R

	if(input == "Disease") R = disease_research
	else if(input == "Artifact") R = artifact_research
	else if(input == "Robotics") R = robotics_research
	else
		boutput(usr, "<span class='alert'>Invalid Research type.</span>")
		return 0

	var/input2 = input("Which tier?", "Which?", null) as num
	if (input2 > R.max_tiers)
		boutput(usr, "<span class='alert'>This research doesn't have that many tiers!</span>")
		return
	if (input2 < 1) return

	var/list/unfinished = list()
	var/count = 0
	for(var/datum/a in R.researched_items[input2])
		count++
		unfinished += a

	if (!count)
		boutput(usr, "<span class='alert'>Nothing has been researched in that tier.</span>")
		return
	var/complete = input("Revoke which research?", "Which?", null) as null|anything in unfinished
	if (!complete) return

	R.researched_items[input2] -= complete
	R.items_to_research[input2] += complete

/client/proc/RS_revoke_tier()
	set category = "Specialist Debug"
	set name = "Revoke Whole Tier"
	set desc = "Instantly revert an entire tier of researched topics to unresearched."

	var/input = input("Which kind of research?", "Which?", null) as null|anything in list("Disease","Artifact","Robotics")
	var/datum/research/R

	if(input == "Disease") R = disease_research
	else if(input == "Artifact") R = artifact_research
	else if(input == "Robotics") R = robotics_research
	else
		boutput(usr, "<span class='alert'>Invalid Research type.</span>")
		return 0

	var/input2 = input("Which tier?", "Which?", null) as num
	if (input2 > R.max_tiers)
		boutput(usr, "<span class='alert'>This research doesn't have that many tiers!</span>")
		return
	if (input2 < 1) return

	for(var/datum/a in R.researched_items[input2])
		R.researched_items[input2] -= a
		R.items_to_research[input2] += a
