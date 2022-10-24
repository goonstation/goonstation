#define CASH_DIVISOR 200
/datum/game_mode/gang
	name = "gang"
	config_tag = "gang"

	antag_token_support = TRUE
	var/list/leaders = list()
	var/list/gangs = list()

	//List of gang stuff already used so that there are no repeats.
	var/list/tags_used = list()
	var/list/part1_used = list()
	var/list/part2_used = list()
	var/list/fullnames_used = list()
	var/list/item1_used = list()
	var/list/item2_used = list()
	var/list/frequencies_used = list()

	var/list/gang_lockers = list() //list of all existing gang lockers
	var/list/under_list = list()
	var/list/headwear_list = list()

	var/const/setup_min_teams = 3
	var/const/setup_max_teams = 5
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/current_max_gang_members = 5 //maximum number of gang members, not including the leader
	//var/const/absolute_max_gang_members = 9

	var/list/potential_hot_zones = null
	var/area/hot_zone = null
	var/hot_zone_timer = 5 MINUTES
	var/hot_zone_score = 1000

	var/const/kidnapping_timer = 8 MINUTES 	//Time to find and kidnap the victim.
	var/const/delay_between_kidnappings = 5 MINUTES
	var/kidnapping_score = 20000
	var/kidnap_success = 0			//true if the gang successfully kidnaps.

	var/obj/item/device/radio/headset/gang/announcer_radio = new /obj/item/device/radio/headset/gang()
	var/datum/generic_radio_source/announcer_source = new /datum/generic_radio_source()
	var/slow_process = 0			//number of ticks to skip the extra gang process loops
	var/janktank_price = 300		//should start the same as /datum/gang_item/misc/janktank.
	var/shuttle_called = FALSE
	var/mob/kidnapping_target

/datum/game_mode/gang/announce()
	boutput(world, "<B>The current game mode is - Gang War!</B>")
	boutput(world, "<B>A number of gangs are competing for control of the station!</B>")
	boutput(world, "<B>Gang members are antagonists and can kill or be killed!</B>")

/datum/game_mode/gang/pre_setup()
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue
		if(player.ready) num_players++

	var/num_teams = clamp(round((num_players) / 9), setup_min_teams, setup_max_teams) //1 gang per 9 players

	var/list/leaders_possible = get_possible_enemies(ROLE_GANG_LEADER, num_teams)
	if (num_teams > leaders_possible.len)
		num_teams = length(leaders_possible)

	if (!leaders_possible.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		leaders += tplayer
		token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeems an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeems an antag token.")

	var/list/chosen_leader = antagWeighter.choose(pool = leaders_possible, role = ROLE_GANG_LEADER, amount = num_teams, recordChosen = 1)
	leaders |= chosen_leader
	for (var/datum/mind/leader in leaders)
		leader.special_role = ROLE_GANG_LEADER
		leaders_possible.Remove(leader)

	return 1

/datum/game_mode/gang/post_setup()
	make_item_lists()
	//under_list = list(/obj/item/clothing/under/gimmick/owl,/obj/item/clothing/under/suit/pinstripe,/obj/item/clothing/under/suit/purple,/obj/item/clothing/under/gimmick/chaps,/obj/item/clothing/under/misc/mail,/obj/item/clothing/under/gimmick/sweater,/obj/item/clothing/under/gimmick/princess,/obj/item/clothing/under/gimmick/merchant,/obj/item/clothing/under/gimmick/birdman,/obj/item/clothing/under/gimmick/safari,/obj/item/clothing/under/rank/det,/obj/item/clothing/under/shorts/red,/obj/item/clothing/under/shorts/blue,/obj/item/clothing/under/jersey/black,/obj/item/clothing/under/jersey,/obj/item/clothing/under/gimmick/rainbow,/obj/item/clothing/under/gimmick/johnny,/obj/item/clothing/under/misc/chaplain/rasta,/obj/item/clothing/under/misc/chaplain/atheist,/obj/item/clothing/under/misc/barber,/obj/item/clothing/under/rank/mechanic,/obj/item/clothing/under/misc/vice,/obj/item/clothing/under/gimmick,/obj/item/clothing/under/gimmick/bowling,/obj/item/clothing/under/misc/syndicate,/obj/item/clothing/under/misc/lawyer/black,/obj/item/clothing/under/misc/lawyer/red,/obj/item/clothing/under/misc/lawyer,/obj/item/clothing/under/gimmick/chav,/obj/item/clothing/under/gimmick/dawson,/obj/item/clothing/under/gimmick/sealab,/obj/item/clothing/under/gimmick/spiderman,/obj/item/clothing/under/gimmick/vault13,/obj/item/clothing/under/gimmick/duke,/obj/item/clothing/under/gimmick/psyche,/obj/item/clothing/under/misc/tourist)
	//headwear_list = list(/obj/item/clothing/mask/owl_mask,/obj/item/clothing/mask/smile,/obj/item/clothing/mask/balaclava,/obj/item/clothing/mask/horse_mask,/obj/item/clothing/mask/melons,/obj/item/clothing/head/waldohat,/obj/item/clothing/head/that/purple,/obj/item/clothing/head/cakehat,/obj/item/clothing/head/wizard,/obj/item/clothing/head/that,/obj/item/clothing/head/wizard/red,/obj/item/clothing/head/wizard/necro,/obj/item/clothing/head/pumpkin,/obj/item/clothing/head/flatcap,/obj/item/clothing/head/mj_hat,/obj/item/clothing/head/genki,/obj/item/clothing/head/butt,/obj/item/clothing/head/mailcap,/obj/item/clothing/head/turban,/obj/item/clothing/head/helmet/bobby,/obj/item/clothing/head/helmet/viking,/obj/item/clothing/head/helmet/batman,/obj/item/clothing/head/helmet/welding,/obj/item/clothing/head/biker_cap,/obj/item/clothing/head/NTberet,/obj/item/clothing/head/rastacap,/obj/item/clothing/head/XComHair,/obj/item/clothing/head/chav,/obj/item/clothing/head/psyche,/obj/item/clothing/head/formal_turban,/obj/item/clothing/head/snake,/obj/item/clothing/head/powdered_wig,/obj/item/clothing/mask/spiderman,/obj/item/clothing/mask/gas/swat,/obj/item/clothing/mask/skull,/obj/item/clothing/mask/surgical)
	for (var/datum/mind/leaderMind in leaders)
		if (!leaderMind.current)
			continue

		generate_gang(leaderMind)
		bestow_objective(leaderMind,/datum/objective/specialist/gang)

		//ToDo: One of those goofy popup windows?
		// boutput(leaderMind.current, "<h1><font color=red>You are the leader of the [leaderMind.gang.gang_name] gang!</font></h1>")
		boutput(leaderMind.current, "<h1><font color=red>You are the leader of a gang!</font></h1>")
		boutput(leaderMind.current, "<span class='alert'>You must recruit people to your gang and compete for wealth and territory!</span>")
		boutput(leaderMind.current, "<span class='alert'>You can harm whoever you want, but be careful - the crew can harm gang members too!</span>")
		boutput(leaderMind.current, "<span class='alert'>To set your gang's home turf and spawn your locker, use the Set Gang Base ability in the top left. Make sure to pick somewhere safe, as your locker can be broken into and looted. You can only do this once!</span>")
		boutput(leaderMind.current, "<span class='alert'>Build up a stash of cash, guns and drugs. Use the items on your locker to store them.</span>")
		boutput(leaderMind.current, "<span class='alert'>Use recruitment flyers obtained from the locker to invite new members, up to a limit of [current_max_gang_members].</span>")
//		boutput(leaderMind.current, "<span class='alert'>Once all active gangs are at the current maximum size, the member cap will increase, up to an absolute maximum of [absolute_max_gang_members].</span>")
		boutput(leaderMind.current, "<span class='alert'><b>Turf, cash, guns and drugs all count towards victory, and your survival gives your gang bonus points!</b></span>")

		equip_leader(leaderMind.current)
		// uniform_prompt(leaderMind)

	find_potential_hot_zones()

	SPAWN(10 MINUTES)
		process_hot_zones()

	SPAWN(15 MINUTES)
		process_kidnapping_event()

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

	return 1

/datum/game_mode/gang/proc/force_shuttle()
	if (!emergency_shuttle.online)
		emergency_shuttle.disabled = SHUTTLE_CALL_ENABLED
		emergency_shuttle.incall()
		command_alert("Centcom is very disappointed in you all for this 'gang' silliness. The shuttle has been called.","Emergency Shuttle Update")

/datum/game_mode/gang/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested staus information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list("revolution", "wizard", "nuke", "traitor", "changeling")
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(leaders))

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")

/datum/game_mode/gang/proc/equip_leader(mob/living/carbon/human/leader)
	// leader.verbs += /client/proc/set_gang_base
	var/datum/abilityHolder/holder = leader.add_ability_holder(/datum/abilityHolder/gang)
	holder.addAbility(/datum/targetable/gang/set_gang_base)

	//add gang channel to headset
	if(leader.ears != null && istype(leader.ears,/obj/item/device/radio/headset))
		var/obj/item/device/radio/headset/H = leader.ears
		H.set_secure_frequency("g",leader.mind.gang.gang_frequency)
		H.secure_classes["g"] = RADIOCL_SYNDICATE
		boutput(leader, "Your headset has been tuned to your gang's frequency. Prefix a message with :g to communicate on this channel.")

	return

//prompts a gang leader to choose their gang outfit.
//if they choose an outfit item some other leader chose, then they have to choose again
/datum/game_mode/gang/proc/uniform_prompt(var/datum/mind/leaderMind)
	var/temp_item1 = input(leaderMind.current, "Select your gang uniform jumpsuit slot item","Gang Jumpsuit")in under_list
	leaderMind.gang.item1 = under_list[temp_item1]
	while(leaderMind.gang.item1 in item1_used)
		boutput(leaderMind.current , "<h4><span class='alert'>That item has been claimed by another gang.</span></h4>")
		temp_item1 = input(leaderMind.current, "Select jumpsuit slot item","Gang Jumpsuit")in under_list
		leaderMind.gang.item1 = under_list[temp_item1]
	item1_used += leaderMind.gang.item1

	if(leaderMind.gang.gang_name == "NICOLAS CAGE FAN CLUB")
		leaderMind.gang.item2 = /obj/item/clothing/mask/niccage
	else
		var/temp_item2 = input(leaderMind.current, "Select head slot item","Gang Headwear")in headwear_list
		leaderMind.gang.item2 = headwear_list[temp_item2]

	while(leaderMind.gang.item2 in item2_used)
		boutput(leaderMind.current , "<h4><span class='alert'>That item has been claimed by another gang.</span></h4>")
		var/temp_item2 = input(leaderMind.current, "Select head slot item","Gang Headwear")in headwear_list
		leaderMind.gang.item2 = headwear_list[temp_item2]

	item2_used += leaderMind.gang.item2

	return

/datum/game_mode/gang/check_finished()
	if(emergency_shuttle.location == SHUTTLE_LOC_RETURNED)
		return 1

	if (no_automatic_ending)
		return 0

	var/leadercount = 0
	for (var/datum/mind/L in ticker.mode:leaders)
		leadercount++

	if(leadercount <= 1 && ticker.round_elapsed_ticks > 12000 && !emergency_shuttle.online)
		force_shuttle()

	else return 0

/datum/game_mode/gang/process()
	..()
	if (ticker.round_elapsed_ticks >= 55 MINUTES && !shuttle_called)
		shuttle_called = TRUE
		force_shuttle()
	slow_process ++
	if (slow_process < 60)
		return
	else
		slow_process = 0

	for(var/datum/gang/G in gangs)
		var/tmp_turf_points = G.num_areas_controlled()*15
		G.score_turf += tmp_turf_points
		G.spendable_points += tmp_turf_points

		if (G.leader)
			var/mob/living/carbon/human/H = G.leader.current
			if (istype(H))
				if (G.gear_worn(H) == 2)
					H.setStatus("ganger", duration = INFINITE_STATUS)
				else
					H.delStatus("ganger")
		if (islist(G.members))
			for (var/datum/mind/M in G.members)
				var/mob/living/carbon/human/H = M.current
				if (istype(H))
					if (G.gear_worn(H) == 2)
						H.setStatus("ganger", duration = INFINITE_STATUS)
					else
						H.delStatus("ganger")

/datum/game_mode/gang/proc/increase_janktank_price()
	janktank_price = round(janktank_price*1.1)
	for(var/datum/gang/G in gangs)
		var/datum/gang_item/misc/janktank/JT = locate(/datum/gang_item/misc/janktank) in G.locker.buyable_items
		JT.price = janktank_price

/datum/game_mode/gang/declare_completion()

	var/text = ""

	boutput(world, "<FONT size = 2><B>The gang leaders were: </B></FONT><br>")
	for(var/datum/mind/leader_mind in leaders)
		text = ""
		text += "<b>[leader_mind.gang.gang_name]</b><br>"
		if(leader_mind.current)
			text += "<b>Leader: </b>[leader_mind.current.real_name]"
			if(isdead(leader_mind.current)) text += " (Dead)"
			else text += " (Survived)"
		else
			text += "<b>Leader: </b>[leader_mind.key] (Destroyed)"
		text += "<br><b>Members:</b> "
		if(!leader_mind.gang.members.len) text += "None!"
		else
			var/count = 0
			for(var/datum/mind/member in leader_mind.gang.members)
				count++
				if(member.current) text += "[member.current.real_name] ([member.key])[count==leader_mind.gang.members.len ? "." : ", " ]"
				else text += "Unknown ([member.key])[count==leader_mind.gang.members.len ? "." : ", " ]"
		text += "<br>Items Purchased<br>"
		var/items = ""
		for (var/i in leader_mind.gang.items_purchased)
			items += "<b>[i]</b>([leader_mind.gang.items_purchased[i]]x) - "
		if (items == "")
			items = "None"
		text += items
		text += "<br><b>Areas Owned:</b> [leader_mind.gang.num_areas_controlled()]"
		text += "<br><b>Turf Score:</b> [leader_mind.gang.score_turf]"
		text += "<br><b>Cash Pile:</b> $[leader_mind.gang.score_cash*CASH_DIVISOR]"
		text += "<br><b>Guns Stashed:</b> [leader_mind.gang.score_gun]"
		text += "<br><b>Drug Score:</b> [leader_mind.gang.score_drug]"
		text += "<br><b>Event Score:</b> [leader_mind.gang.score_event]"
		text += "<br><b>Total Score: [leader_mind.gang.gang_score()]</b>"
		text += "<br>"
		boutput(world, text)

	if (!check_winner())
		boutput(world, "<h2><b>The round was a draw!</b></h2>")

	else
		var/datum/mind/winner = check_winner()
		if (istype(winner))
			boutput(world, "<h2><b>[winner.gang.gang_name], led by [winner.current.real_name], won the round!</b></h2>")

	..() // Admin-assigned antagonists or whatever.

/datum/game_mode/gang/proc/generate_gang(datum/mind/leaderMind)
	leaderMind.gang = new /datum/gang
	leaderMind.gang.leader = leaderMind

	leaderMind.gang.gang_tag = rand(0,22) // increase if you add more tags!

	while(leaderMind.gang.gang_tag in tags_used)
		leaderMind.gang.gang_tag = rand(0,22) // increase if you add more tags!

	tags_used += leaderMind.gang.gang_tag

	leaderMind.gang.gang_frequency = rand(1360,1420)

	while(leaderMind.gang.gang_frequency in frequencies_used)
		leaderMind.gang.gang_frequency = rand(1360,1420)

	frequencies_used += leaderMind.gang.gang_frequency

	SPAWN(0)
		pick_name(leaderMind)
		pick_theme(leaderMind)

	gangs += leaderMind.gang

//choose name with no user input
/datum/game_mode/gang/proc/auto_choose_name(datum/mind/leaderMind)
	var/part1chosen = null
	var/part2chosen = null
	var/fullchosen = null
	while(leaderMind.gang.gang_name == "Gang Name")
		if(prob(10)) //Unique name.
			fullchosen = pick_string("gangwar.txt", "fullchosen")
			part1chosen = null
			part2chosen = null
			if (!(fullchosen in fullnames_used))
				leaderMind.gang.gang_name = fullchosen
				fullnames_used += fullchosen
		else
			var/list/part1 = pick_string("gangwar.txt", "part1")
			var/list/part2 = pick_string("gangwar.txt", "part2")
			part1chosen = pick(part1)
			part2chosen = pick(part2)
			fullchosen = null
			if (!(part1chosen in part1_used) && !(part2chosen in part2_used))
				leaderMind.gang.gang_name = part1chosen + " " + part2chosen
				part1_used += part1chosen
				part2_used += part2chosen

/datum/game_mode/gang/proc/pick_theme(datum/mind/leaderMind)
	return
/datum/game_mode/gang/proc/pick_name(datum/mind/leaderMind)
	var/part1chosen = null
	var/part2chosen = null
	var/fullchosen = null
	var/temp_name = ""
	while(leaderMind.gang.gang_name == "Gang Name")
		if (prob(10))
			temp_name = pick_string("gangwar.txt", "fullchosen")
			fullchosen = temp_name
		else
			var/list/part1 = pick_string("gangwar.txt", "part1")
			var/list/part2 = pick_string("gangwar.txt", "part2")
			part1chosen = pick(part1)
			part2chosen = pick(part2)
			temp_name = part1chosen + " " + part2chosen

		switch(tgui_alert(leaderMind.current, "Name: [temp_name].", "Approve your gang's name", list("Accept", "Randomize")))
			if ("Accept")
				//make sure no other gangs have this name
				if (fullchosen)
					if (locate(fullchosen) in fullnames_used)
						boutput(leaderMind.current, "<span class='alert'>Another gang has this name.</span>")
						continue
					fullnames_used += fullchosen

				else if (part1chosen && part2chosen)
				//make sure no other gangs have this name
					if (locate(part1chosen) in part1_used && locate(part2chosen) in part2_used)
						boutput(leaderMind.current, "<h3><span class='alert'>Another gang has this name. Sorry, you have to roll again!</span></h3>")
						continue
					part1_used += part1chosen
					part2_used += part2chosen
				leaderMind.gang.gang_name = temp_name
				boutput(leaderMind.current, "<h1><font color=red>Your gang name is [temp_name]!</font></h1>")
			else
				continue

/datum/game_mode/gang/proc/check_winner()
	var/datum/mind/current_winner = null

	for(var/datum/mind/leader_mind in leaders) // Find the highest score
		if(!current_winner)
			current_winner = leader_mind
		else if(current_winner.gang.gang_score() < leader_mind.gang.gang_score())
			current_winner = leader_mind

	for(var/datum/mind/leader_mind in leaders) // See if two gangs have the highest score ie. it's a draw
		if(current_winner != leader_mind && current_winner.gang.gang_score() == leader_mind.gang.gang_score())
			return 0

	if (istype(current_winner))
		return current_winner

/// hot zone thing

/datum/game_mode/gang/proc/find_potential_hot_zones()
	potential_hot_zones = list()

	for(var/area/A as area in world)
		if(A.z != 1 || A.teleport_blocked || istype(A, /area/supply) || istype(A, /area/shuttle/) || A.name == "Space" || A.name == "Ocean")
			continue
		potential_hot_zones += A

	return

/datum/game_mode/gang/proc/process_hot_zones()
	hot_zone = pick(potential_hot_zones)

	broadcast_to_all_gangs("The [hot_zone.name] is a high priority area. Ensure that your gang has control of it five minutes from now!")

	SPAWN(hot_zone_timer-600)
		if(hot_zone != null) broadcast_to_all_gangs("You have a minute left to control the [hot_zone.name]!")
		sleep(1 MINUTE)
		if(hot_zone != null && hot_zone.gang_owners != null)
			var/datum/gang/G = hot_zone.gang_owners
			G.score_event += hot_zone_score
			broadcast_to_all_gangs("[G.gang_name] has been rewarded for their control of the [hot_zone.name].")
			sleep(10 SECONDS)
		process_hot_zones()

/datum/game_mode/gang/proc/process_kidnapping_event()
	kidnap_success = 0
	kidnapping_target = null
	var/datum/gang/top_gang = null
	for (var/datum/gang/G in gangs)
		if (!top_gang)
			top_gang = G
			continue
		if (G.gang_score() > top_gang.gang_score())
			top_gang = G

	if (!top_gang)
		logTheThing(LOG_DEBUG, null, "No winning gang chosen for kidnapping event. Something's broken.")
		message_admins("No winning gang chosen for kidnapping event. Something's broken.")
		return 0

	//get possible targets. Looks for ckey, if they are not dead, and if they are not in the top gang.
	var/list/potential_targets = list()
	for (var/mob/living/carbon/human/H in mobs)
		if (H.ckey && !isdead(H) && H.mind?.gang != top_gang && !istype(H.mutantrace, /datum/mutantrace/virtual))
			potential_targets += H

	if (!potential_targets.len)
		logTheThing(LOG_DEBUG, null, "No players found to be kidnapping targets.")
		message_admins("No kidnapping target has been chosen for kidnapping event. This should be pretty unlikely, unless there's only like 1 person on.")
		return 0

	kidnapping_target = pick(potential_targets)
	var/target_name
	if (ismob(kidnapping_target))
		target_name = kidnapping_target.real_name
	broadcast_to_all_gangs("The [hot_zone.name] is a high priority area. Ensure that your gang has control of it five minutes from now!")

	//alert gangs, alert target which gang to be wary of.
	for (var/datum/gang/G in gangs)
		if (G == top_gang)
			broadcast_to_gang("A bounty has been placed on the capture of [target_name]. Shove them into your gang locker <ALIVE>, within 8 minutes for a massive reward!", G)
		else
			broadcast_to_gang("[target_name] is the target of a kidnapping by [top_gang.gang_name]. Ensure that [target_name] is alive and well for the next 8 minutes for a reward!", G)

	boutput(kidnapping_target, "<span class='alert'>You get the feeling that [top_gang.gang_name] wants you dead! Run and hide or ask security for help!</span>")


	SPAWN(kidnapping_timer - 1 MINUTE)
		if(kidnapping_target != null) broadcast_to_all_gangs("[target_name] has still not been captured by [top_gang.gang_name] and they have 1 minute left!")
		sleep(1 MINUTE)
		//if they didn't kidnap em, then give points to other gangs depending on whether they are alive or not.
		if(!kidnap_success)
			//if the kidnapping target is null or dead, nobody gets points. (the target will be "gibbed" if successfully "kidnapped" and points awarded there)
			if (kidnapping_target && kidnapping_target.stat != 2)
				for (var/datum/gang/G in gangs)
					if (G != top_gang)
						G.score_event += kidnapping_score/gangs.len 	//This is less than the total points the top_gang would get, so it behooves security to help the non-top gangs keep the target safe.
				broadcast_to_all_gangs("[top_gang.gang_name] has failed to kidnap [target_name] and the other gangs have been rewarded for thwarting the kidnapping attempt!")
			else
				broadcast_to_all_gangs("[target_name] has died in one way or another. No gangs have been rewarded for this futile exercise.")

			sleep(delay_between_kidnappings)
		process_kidnapping_event()


//bleh
/datum/game_mode/gang/proc/broadcast_to_all_gangs(var/message)
	if(announcer_source.name == "Unknown")
		announcer_source.set_name("The [pick("Kingpin","Cabal","Council","Boss")]")

	//set up message
	var/datum/language/L = languages.language_cache["english"]
	var/list/messages = L.get_messages(message)

	//send the message on each gang frequency
	for(var/datum/gang/G in gangs)
		announcer_radio.set_secure_frequency("g",G.gang_frequency)
		announcer_radio.talk_into(announcer_source, messages, "g", announcer_source.name, "english")

/datum/game_mode/gang/proc/broadcast_to_gang(var/message,var/datum/gang/gang)
	if(announcer_source.name == "Unknown")
		announcer_source.set_name("The [pick("Kingpin","Cabal","Council","Boss")]")

	//set up message
	var/datum/language/L = languages.language_cache["english"]
	var/list/messages = L.get_messages(message)

	//send message
	announcer_radio.set_secure_frequency("g",gang.gang_frequency)
	announcer_radio.talk_into(announcer_source, messages, "g", announcer_source.name, "english")

/datum/gang
	var/gang_name = "Gang Name"
	var/gang_tag = 0
	var/gang_frequency = 0
	var/obj/item/clothing/item1 = null
	var/obj/item/clothing/item2 = null
	var/area/base = null
	var/list/members = list()
	var/list/gear_cooldown = list()
	var/datum/mind/leader = null
	var/obj/ganglocker/locker = null
	var/spendable_points = 0						//The usable number of points that a gang has to spend with
	var/theme = "misc"					//determines the type of items they can buy from lockers
	var/list/items_purchased = list()

	var/score_turf = 0					//points gained from owning turfs
	var/score_cash = 0					//The total amount of cash a gang has deposited
	var/score_gun = 0					//points gained from gun deposits
	var/score_drug = 0					//points gained from drugs
	var/score_event = 0					//points from hotzones


	proc/num_areas_controlled()
		var/areacount = 0
		var/list/counted_areas = list()
		for(var/area/A in world)
			if(A.gang_owners == src && !(A in counted_areas))
				areacount ++
				counted_areas += A

			LAGCHECK(LAG_LOW)
		return areacount

	proc/gang_score()
		var/score = 0

		score += score_turf //x25
		score += score_cash
		score += score_gun
		score += score_drug
		score += score_event

		return round(score)

	proc/can_be_joined() //basic for now but might be expanded on so I'm making it a proc of its own
		if(members.len >= ticker.mode:current_max_gang_members)
			return 0
		return 1

	proc/gear_worn(var/mob/living/carbon/human/M)
		if(!istype(M)) return 0

		var/count = 0

		if(istype(M.w_uniform,item1))
			count++

		if(istype(M.head, item2) || istype(M.wear_mask,item2))
			count++

		return count

// Deprecated by /datum/targetable/gang/set_gang_base
/client/proc/set_gang_base()
	set category = "Gang"
	set name = "Set Gang Base"
	set desc = "Permanently sets the area you're currently in as your gang's base and spawns your gang's locker."

	var/area/area = get_area(usr)

	if(area.gang_base)
		boutput(usr, "<span class='alert'>Another gang's base is in this area!</span>")
		return

	if(usr.stat)
		boutput(usr, "<span class='alert'>Not when you're incapacitated.</span>")
		return

	// if (istype(ticker.mode, /datum/game_mode/gang))
	// 	var/datum/game_mode/gang/mode = ticker.mode
	// 	mode.uniform_prompt(mind)

	if (istype(ticker.mode, /datum/game_mode/gang))
		var/datum/game_mode/gang/mode = ticker.mode
		mode.uniform_prompt(usr.mind)
	else
		boutput(usr, "<span class='alert'>The round's mode isn't Gang, you can't place a locker here!.</span>")
		return

	usr.mind.gang.base = area
	area.gang_base = 1

	for(var/obj/decal/cleanable/gangtag/G in area)
		if(G.owners == usr.mind.gang) continue
		var/obj/decal/cleanable/gangtag/T = make_cleanable(/obj/decal/cleanable/gangtag,G.loc)
		T.icon_state = "gangtag[usr.mind.gang.gang_tag]"
		T.name = "[usr.mind.gang.gang_name] tag"
		T.owners = usr.mind.gang
		T.delete_same_tags()
		break

	var/obj/ganglocker/locker = new /obj/ganglocker(usr.loc)
	locker.name = "[usr.mind.gang.gang_name] Locker"
	locker.desc = "A locker with a small screen attached to the door, and the words 'Property of [usr.mind.gang.gang_name] - DO NOT TOUCH!' scratched into both sides."
	locker.gang = usr.mind.gang
	ticker.mode:gang_lockers += locker
	usr.mind.gang.locker = locker
	locker.UpdateIcon()

	usr.verbs -= /client/proc/set_gang_base

	return

/obj/item/spray_paint
	name = "Spraypaint Can"
	desc = "A can of spray paint."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan"
	item_state = "spraycan"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	var/in_use = 0

	afterattack(target as turf|obj, mob/user as mob)
		if(!istype(target,/turf) && !istype(target,/obj/decal/cleanable/gangtag)) return

		if (!user)
			return

		if(in_use)
			boutput(user, "<span class='alert'>You are already tagging an area!</span>")
			return

		var/turf/turftarget = get_turf(target)

		if(turftarget == loc || BOUNDS_DIST(src, target) > 0) return

		if(!user.mind || !user.mind.gang)
			boutput(user, "<span class='alert'>You aren't in a gang, why would you do that?</span>")
			return

		var/area/getarea = get_area(turftarget)
		if(!getarea)
			boutput(user, "<span class='alert'>You can't claim this place!</span>")
			return
		if(getarea.name == "Space")
			boutput(user, "<span class='alert'>You can't claim space!</span>")
			return
		if(getarea.name == "Ocean")
			boutput(user, "<span class='alert'>You can't claim the entire ocean!</span>")
			return
		if((getarea.teleport_blocked) || istype(getarea, /area/supply) || istype(getarea, /area/shuttle/))
			boutput(user, "<span class='alert'>You can't claim this place!</span>")
			return
		if(!ishuman(user))
			boutput(user, "<span class='alert'>You don't have the dexterity to spray paint a gang tag!</span>")
		if(getarea.gang_owners && getarea.gang_owners != user.mind.gang && !turftarget.tagged)
			boutput(user, "<span class='alert'>[getarea.gang_owners.gang_name] own this area! You must paint over their tag to capture it!</span>")
			return
		if(getarea.being_captured)
			boutput(user, "<span class='alert'>Somebody is already tagging that area!</span>")
			return
		if(getarea.gang_owners == user.mind.gang)
			boutput(user, "<span class='alert'>This place is already owned by your gang!</span>")
			return

		user.visible_message("<span class='alert'>[user] begins to paint a gang tag on the [turftarget.name]!</span>")
		actions.start(new/datum/action/bar/icon/spray_gang_tag(turftarget, src), user)

/datum/action/bar/icon/spray_gang_tag
	duration = 15 SECONDS
	interrupt_flags = INTERRUPT_STUNNED
	id = "spray_tag"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan"
	var/turf/target_turf
	var/area/target_area
	var/obj/item/spray_paint/S
	var/mob/M

	New(var/turf/target_turf as turf, var/obj/item/spray_paint/S)
		src.target_turf = target_turf
		src.target_area = get_area(target_turf)
		src.S = S
		..()

	onStart()
		//just being very careful. The icon has to be set before the parent is called, so
		//if something breaks and the parent is not called then you the OnUpdate and OnInterrupt will probably runtime forever.
		try
			if (ismob(owner))
				M = owner
			if (M?.mind?.gang)
				icon = 'icons/obj/decals/graffiti.dmi'
				icon_state = "gangtag[M.mind.gang.gang_tag]"
				var/speedup = M.mind.gang.gear_worn(M) + (owner.hasStatus("janktank") ? 1: 0)
				switch (speedup)
					if (1)
						duration = 13 SECONDS
					if (2)
						duration = 9 SECONDS
					if (3)
						duration = 6 SECONDS
			..()
		catch(var/exception/e)
			..()
			throw e

		if(BOUNDS_DIST(owner, target_turf) > 0 || target_turf == null || !owner)
			interrupt(INTERRUPT_ALWAYS)
			return

		target_area.being_captured = 1
		S.in_use = 1
		playsound(target_turf, 'sound/machines/hiss.ogg', 50, 1)	//maybe just repeat the appropriate amount of times

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target_turf) > 0 || target_turf == null || !owner)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(prob(15))
			playsound(target_turf, 'sound/machines/hiss.ogg', 50, 1)

	onInterrupt(var/flag)
		boutput(owner, "<span class='alert'>You were interrupted!</span>")
		if (target_area)
			target_area.being_captured = 0
		if (S)
			S.in_use = 0
		..()

	onEnd()
		..()
		if(BOUNDS_DIST(owner, target_turf) > 0 || target_turf == null || !owner)
			interrupt(INTERRUPT_ALWAYS)
			return

		S.in_use = 0
		target_area.being_captured = 0

		var/obj/decal/cleanable/gangtag/T = make_cleanable(/obj/decal/cleanable/gangtag,target_turf)
		T.icon_state = "gangtag[M.mind.gang.gang_tag]"
		T.name = "[M.mind.gang.gang_name] tag"
		T.owners = M.mind.gang
		T.delete_same_tags()
		target_turf.tagged = 1
		target_area.gang_owners = M.mind.gang
		boutput(M, "<span class='notice'>You have claimed this area for your gang!</span>")

/obj/ganglocker
	desc = "Gang locker."
	name = "Gang Closet"
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "gang"
	density = 1
	anchored = 1
	var/datum/gang/gang = null
	var/max_health = 200
	var/health = 200
	var/damage_warning_timeout = 0
	var/broken = 0
	var/image/default_screen_overlay = null
	var/HTML = null
	var/list/buyable_items = list()

	New()
		..()
		default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
		src.UpdateOverlays(default_screen_overlay, "screen")
		buyable_items = list(
			new/datum/gang_item/misc/ratstick,
			new/datum/gang_item/ninja/throwing_knife,
			new/datum/gang_item/ninja/shuriken,
			new/datum/gang_item/ninja/sneaking_suit,
			new/datum/gang_item/space/phaser_gun,
			new/datum/gang_item/space/laser_gun,

			new/datum/gang_item/country_western/colt_saa,
			new/datum/gang_item/country_western/colt_45_bullet,

			new/datum/gang_item/space/discount_csaber,
			// new/datum/gang_item/space/csaber,
			new/datum/gang_item/ninja/discount_katana,
			// new/datum/gang_item/ninja/katana,
			new/datum/gang_item/street/cop_car,

			new/datum/gang_item/misc/janktank,
			new/datum/gang_item/space/stims)

	examine()
		. = ..()

		if(health == 0)
			. += "It is completely destroyed!"
			return

		switch(round(100*health/max_health))
			if(1 to 25)
				. += "It is almost destroyed!"
			if(26 to 50)
				. += "It is badly damaged!"
			if(51 to 75)
				. += "It is somewhat damaged."
			if(76 to 99)
				. += "It is slightly damaged."
			if(100)
				. += "It is undamaged."

		. += "The screen displays \"Total Score: [gang.gang_score()] and Spendable Points: [gang.spendable_points]\""

	attack_hand(var/mob/living/carbon/human/user)
		if(!isalive(user))
			boutput(user, "<span class='alert'>Not when you're incapacitated.</span>")
			return

		add_fingerprint(user)

		if(health == 0)
			boutput(user, "<span class='alert'>The locker is broken, it needs to be repaired first!</span>")
			return

		// if (!src.HTML)
		src.generate_HTML()

		user.Browse(src.HTML, "window=gang_locker;size=650x630")
		//onclose(user, "gang_locker")

	//puts the html string in the var/HTML on src
	proc/generate_HTML()
		var/janktank = ""
		if (istype(ticker.mode, /datum/game_mode/gang))
			janktank += "<p><b>JankTank purchasers:</b></p>"
			for(var/datum/gang/G in ticker.mode:gangs)
				if (G.gang_name)
					var/num = !G.items_purchased["JankTank Implant"] ? 0 : G.items_purchased["JankTank Implant"]
					janktank += "[G.gang_name] - [num] implant(s)<BR>"

		var/dat = {"<HTML>
		<div style="width: 100%; overflow: hidden;">
			<div style="height: 150px;width: 290px;padding-left: 5px;; float: left;border-style: solid;">
				<center><font size="6"><a href='byond://?src=\ref[src];get_gear=1'>get gear</a></font></center><br>
				<font size="3">You have [gang.spendable_points] points to spend!</font>
			</div>
		    <div style="height: 150px;margin-left: 300px;padding-left: 5px;overflow: auto;"> [janktank] </div>
		</div>
		<HR>
		"}


		dat += {"<table>
		<tr>
			<th>Name</th>
			<th>Price</th>
			<th>Desc</th>
			<th>Category</th>
			<th>Sub-Category</th>
		</tr>
		"}
		for (var/datum/gang_item/GI in buyable_items)
			dat += "<tr><td><a href='byond://?src=\ref[src];buy_item=\ref[GI]'>[GI.name]</a></td><td>[GI.price]</td><td>[GI.desc]</td><td>[GI.class1]</td><td>[GI.class2]</td>  </tr>"

		dat += "</table></HTML>"

		HTML = dat


	Topic(href, href_list)
		..()
		if ((usr.stat || usr.restrained()) || (BOUNDS_DIST(src, usr) > 0))
			return

		if (href_list["get_gear"])
			handle_gang_gear(usr)
		if (href_list["buy_item"])
			if (usr.mind && usr.mind.gang != src.gang)
				boutput(usr, "<span class='alert'>You are not a member of this gang, you cannot purchase items from it.</span>")
				return
			var/datum/gang_item/GI = locate(href_list["buy_item"])
			if (locate(GI) in buyable_items)
				if (GI.price <= gang.spendable_points)
					gang.spendable_points -= GI.price
					new GI.item_path(src.loc)
					boutput(usr, "<span class='notice'>You purchase [GI.name] for [GI.price]. Remaining balance = [gang.spendable_points] points.</span>")
					gang.items_purchased[GI.name]++
					if (istype(GI, /datum/gang_item/misc/janktank))
						ticker.mode:increase_janktank_price()
						updateDialog()
				else
					boutput(usr, "<span class='alert'>Insufficient funds.</span>")


	//Okay, this is fucked up. I don't know why get_gang_gear is a global proc and I don't care. - Kyle
	proc/handle_gang_gear(var/mob/living/carbon/human/user)
		var/image/overlay = null
		if(user.mind.gang == src.gang)
			switch(get_gang_gear(user))
				if(0)
					boutput(user, "<span class='alert'>The locker's screen briefly displays the message \"Access Denied\".</span>")
					overlay = image('icons/obj/large_storage.dmi', "gang_overlay_red")
				if(1)
					boutput(user, "<span class='alert'>The locker's screen briefly displays the message \"Access Denied\".</span>")
					boutput(user, "You may only receive one set of gang gear every five minutes.")
					overlay = image('icons/obj/large_storage.dmi', "gang_overlay_red")
				if(2)
					boutput(user, "<span class='alert'>The locker's screen briefly displays the message \"Access Granted\". A set of gang equipment drops out of a slot.</span>")
					overlay = image('icons/obj/large_storage.dmi', "gang_overlay_green")
		else
			boutput(user, "<span class='alert'>The locker's screen briefly displays the message \"Access Denied\".</span>")
			overlay = image('icons/obj/large_storage.dmi', "gang_overlay_red")

		src.UpdateOverlays(overlay, "screen")
		SPAWN(1 SECOND)
			src.UpdateOverlays(default_screen_overlay, "screen")

	update_icon()
		if(health <= 0)
			src.UpdateOverlays(null, "light")
			src.UpdateOverlays(null, "screen")
			return

		src.UpdateOverlays(default_screen_overlay, "screen")

		if(gang.can_be_joined())
			src.UpdateOverlays(image('icons/obj/large_storage.dmi', "greenlight"), "light")
		else
			src.UpdateOverlays(image('icons/obj/large_storage.dmi', "redlight"), "light")

	proc/insert_item(var/obj/item/item,var/mob/user)
		if(!user)
			return 0
		if (user.mind && user.mind.gang != src.gang)
			boutput(user, "<span class='alert'>You are not a member of this gang, you cannot add items to it.</span>")
			return 0

		//cash score
		if (istype(item, /obj/item/spacecash))
			var/obj/item/spacecash/S = item
			if (S.amount > 500)
				boutput(user, "<span class='alert'><b>[src.name] beeps, it don't accept bills larger than $500!<b></span>")
				return 0

			gang.score_cash += round(S.amount/CASH_DIVISOR)
			gang.spendable_points += round(S.amount/CASH_DIVISOR)

		//gun score
		else if (istype(item, /obj/item/gun))
			if(istype(item, /obj/item/gun/kinetic/foamdartgun))
				boutput(user, "<span class='alert'><b>You cant stash toy guns in the locker<b></span>")
				return 0
			// var/obj/item/gun/gun = item
			gang.score_gun += round(300)
			gang.spendable_points += round(300)


		//drug score
		else if (item.reagents && item.reagents.total_volume > 0)
			var/temp_score_drug = get_I_score_drug(item)
			gang.score_drug += temp_score_drug
			gang.spendable_points += temp_score_drug

		user.u_equip(item)
		item.dropped(user)
		add_fingerprint(user)

		item.set_loc(src)

		return 1

	//invudidual score for an item
	proc/get_I_score_drug(var/obj/O)
		var/score = 0
		score += O.reagents.get_reagent_amount("bathsalts")
		score += O.reagents.get_reagent_amount("jenkem")/2
		score += O.reagents.get_reagent_amount("crank")*1.5
		score += O.reagents.get_reagent_amount("LSD")/2
		score += O.reagents.get_reagent_amount("lsd_bee")/3
		score += O.reagents.get_reagent_amount("space_drugs")/4
		score += O.reagents.get_reagent_amount("THC")/8
		score += O.reagents.get_reagent_amount("psilocybin")/2
		score += O.reagents.get_reagent_amount("krokodil")
		score += O.reagents.get_reagent_amount("catdrugs")
		score += O.reagents.get_reagent_amount("methamphetamine")*1.5 //meth

		if(istype(O, /obj/item/plant/herb/cannabis) && O.reagents.get_reagent_amount("THC") == 0)
			score += 7
		return round(score)

	proc/cash_amount()
		var/number = 0

		for(var/obj/item/spacecash/S in contents)
			number += S.amount

		return round(number)

	proc/gun_amount()
		var/number = 0

		for(var/obj/item/gun/G in contents)
			number ++

		return round(number) //no point rounding it really but fuck it

	proc/take_damage(var/amount)
		health = max(0,health-amount)

		//alert owning gang
		if(istype(ticker.mode,/datum/game_mode/gang) && damage_warning_timeout == 0)
			ticker.mode:broadcast_to_gang("Your locker is under attack!",src.gang)
			damage_warning_timeout = 1
			SPAWN(1 MINUTE)
				damage_warning_timeout = 0

		if(health <= 0)
			break_open()
			if(istype(ticker.mode,/datum/game_mode/gang))
				gang.spendable_points = round(gang.spendable_points*0.8)
				ticker.mode:broadcast_to_gang("Your locker has been destroyed! Your amount of spendable points has been almost decimated!",src.gang)
			src.visible_message("<span class='alert'><b>[src.name] bursts open, spilling its contents!<b></span>")

	proc/repair_damage(var/amount)
		health = min(200,health+amount)
		if(health > 0 && broken == 1)
			repair_broken()
			src.visible_message("<span class='notice'><b>The door to [src] swings shut and switches back on!<b></span>")

	ex_act(severity)
		take_damage(250-50*severity)
		return

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			user.lastattacked = src

			if(health == max_health)
				boutput(user, "<span class='notice'>The locker isn't damaged!</span>")
				return

			if(W:try_weld(user, 4))
				repair_damage(20)
				user.visible_message("<span class='notice'>[user] repairs the [src] with [W]!</span>")
				return

		if (health <= 0)
			boutput(user, "<span class='alert'>The locker is broken, it needs to be repaired first!</span>")
			return

		if (W.cant_drop)
			return


		//kidnapping event here
		//if they're the target
		if (istype(W, /obj/item/grab))
			if (user?.mind.gang != src.gang)
				boutput(user, "<span class='alert'>You can't kidnap someone for a different gang!</span>")
				return
			if (istype(ticker.mode, /datum/game_mode/gang))	//gotta be gang mode to kidnap
				var/datum/game_mode/gang/mode = ticker.mode
				var/obj/item/grab/G = W
				if (G.affecting == mode.kidnapping_target)		//Can only shove the target in, nobody else. target must be not dead and must have a kill or pin grab on em.
					if (G.affecting.stat == 2)
						boutput(user, "<span class='alert'>[G.affecting] is dead, you can't kidnap a dead person!</span>")
					else if (G.state < GRAB_AGGRESSIVE)
						boutput(user, "<span class='alert'>You'll need a stronger grip to successfully kinapp this person!")
					else
						user.visible_message("<span class='notice'>[user] shoves [G.affecting] into [src]!</span></span>")
						G.affecting.set_loc(src)
						//assign poitns, gangs

						user.mind.gang.score_event += mode.kidnapping_score
						mode.broadcast_to_all_gangs("[src.gang.gang_name] has successfully kidnapped [mode.kidnapping_target] and has been rewarded for their efforts.")

						mode.kidnapping_target = null
						mode.kidnap_success = 1
						G.affecting.remove()
						qdel(G)
			return


		if(istype(W,/obj/item/plant/herb/cannabis) || istype(W,/obj/item/gun) || istype(W,/obj/item/spacecash) || (W.reagents != null && W.reagents.total_volume > 0))
			if (insert_item(W,user))
				user.visible_message("<span class='notice'>[user] puts [W] into [src]!</span>")
			return

		if(istype(W,/obj/item/satchel))
			var/obj/item/satchel/S = W
			var/hadcannabis = 0

			for(var/obj/item/plant/herb/cannabis/C in S.contents)
				insert_item(C,null)
				S.UpdateIcon()
				hadcannabis = 1

			if(hadcannabis)
				boutput(user, "<span class='notice'>You empty the cannabis from [S] into the [src].</span>")
			else
				boutput(user, "<span class='notice'>[S] doesn't contain any cannabis.</span>")
			return

		user.lastattacked = src

		switch(W.hit_type)
			if (DAMAGE_BURN)
				user.visible_message("<span class='alert'>[user] ineffectually hits the [src] with [W]!</span>")
			else
				take_damage(W.force)
				user.visible_message("<span class='alert'><b>[user] hits the [src] with [W]!<b></span>")

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if(!istype(O, /obj/item/plant/herb/cannabis))
			boutput(user, "<span class='alert'>[src] cannot hold that kind of item!</span>")
			return

		user.visible_message("<span class='notice'>[user] begins quickly filling the [src]!</span>")
		var/staystill = user.loc
		for(var/obj/item/I in view(1,user))
			if (!istype(I, O)) continue
			if (I in user)
				continue
			I.set_loc(src)
			sleep(0.2 SECONDS)
			if (user.loc != staystill) break

		boutput(user, "<span class='notice'>You finish filling the [src]!</span>")

	proc/break_open()
		broken = 1
		set_density(0)
		for(var/obj/O in contents)
			O.set_loc(src.loc)

		icon_state = "secure-open"
		UpdateIcon()

		return

	proc/repair_broken()
		broken = 0
		set_density(1)
		icon_state = "gang"

		UpdateIcon()

		return

/obj/item/gang_flyer
	desc = "A gang recruitment flyer."
	name = "gang recruitment flyer"
	icon = 'icons/obj/writing.dmi'
	icon_state = "paper_caution"
	w_class = W_CLASS_TINY
	var/datum/gang/gang = null

	attack(mob/target, mob/user)
		if (istype(target,/mob/living) && user.a_intent != INTENT_HARM)
			if(user != target)
				user.visible_message("<span class='alert'><b>[user] shows [src] to [target]!</b></span>")
			// induct_to_gang(target)		//this was sometimes kinda causing people to accidentally accept joining a gang.
			return
		else
			return ..()

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob)
		if (istype(A, /turf/simulated/wall) || istype(A, /turf/simulated/shuttle/wall) || istype(A, /turf/unsimulated/wall) || istype(A, /obj/window))
			user.visible_message("<b>[user]</b> attaches [src] to [A].","You attach [src] to [A].")
			user.u_equip(src)
			src.set_loc(A)
			src.anchored = 1
		else
			return ..()

	attack_hand(mob/user)
		if (!src.anchored)
			return ..()

		var/turf/T = src.loc
		user.visible_message("<span class='alert'><b>[user]</b> rips down [src] from [T]!</span>", "<span class='alert'>You rip down [src] from [T]!</span>")
		src.anchored = 0
		user.put_in_hand_or_drop(src)

	attack_self(mob/living/carbon/human/user as mob)
		induct_to_gang(user)

	proc/induct_to_gang(var/mob/living/carbon/human/target)
		if(gang == null)
			boutput(target, "<span class='alert'>The flyer doesn't specify which gang it's advertising!</span>")
			return

		if(!ishuman(target))
			boutput(target, "<span class='alert'>Only humans can join a gang!</span>")
			return

		if(!isalive(target))
			boutput(target, "<span class='alert'>Not when you're incapacitated.</span>")
			return

		if (issmallanimal(target))
			var/mob/living/critter/small_animal/C = target
			if (C.ghost_spawned)
				boutput(target, "<span class='alert'>Your spectral brain can't comprehend the concept of a gang!</span>")
				return

		if(target.mind.gang == gang)
			boutput(target, "<span class='alert'>You're already in that gang!</span>")
			return

		if(target.mind.gang != null)
			boutput(target, "<span class='alert'>You're already in a gang, you can't switch sides!</span>")
			return

		if(target.mind.assigned_role in list("Security Officer", "Security Assistant", "Vice Officer","Part-time Vice Officer","Head of Security","Captain","Head of Personnel","Communications Officer", "Medical Director", "Chief Engineer", "Research Director", "Detective", "Nanotrasen Security Consultant", "Nanotrasen Special Operative"))
			boutput(target, "<span class='alert'>You are too responsible to join a gang!</span>")
			return

		if(target.mind in ticker.mode:leaders)
			boutput(target, "<span class='alert'>You can't join a gang, you run your own!</span>")
			return

		if(src.gang.members.len >= ticker.mode:current_max_gang_members)
			boutput(target, "<span class='alert'>That gang is full!</span>")
			return

		var/joingang = tgui_alert(target, "Do you wish to join [src.gang.gang_name]?", "[src]", list("Yes", "No"), timeout = 10 SECONDS)
		if (joingang != "Yes")
			return

		target.mind.gang = gang
		src.gang.members += target.mind
		if (!target.mind.special_role)
			target.mind.special_role = ROLE_GANG_MEMBER
		target.show_antag_popup("gang_member")
		new /datum/objective/specialist/gang(
			"Protect your boss, recruit new members, tag up the station and beware the other gangs! [src.gang.gang_name] FOR LIFE!",
			target.mind)
		boutput(target, "<span class='notice'>You are now a member of [src.gang.gang_name]!</span>")
		boutput(target, "<span class='notice'>Your boss has the blue G and your fellow gang members have the red G! Work together and do some crime!</span>")
		boutput(target, "<span class='notice'>You are free to harm anyone who isn't in your gang, but be careful, they can do the same to you!</span>")
		boutput(target, "<span class='notice'>You should only use bombs if you have a good reason to, and also run any bombings past your gang!</span>")
		boutput(target, "<span class='notice'>Capture areas for your gang by using spraypaint on other gangs' tags (or on any turf if the area is unclaimed).</span>")
		boutput(target, "<span class='notice'>You can get spraypaint, an outfit and a gang headset from your locker.</span>")
		boutput(target, "<span class='notice'>Your gang will earn points for cash, drugs and guns stored in your locker.</span>")
		boutput(target, "<span class='notice'>Make sure to defend your locker, as other gangs can break it open to loot it!</span>")
		if(gang.base == null)
			boutput(target, "<span class='notice'>Your gang doesn't have a base or locker yet.</span>")
		else
			boutput(target, "<span class='notice'>Your gang's base is located in [gang.base], along with your locker.</span>")

		//add gang channel to headset
		if(target.ears != null && istype(target.ears,/obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/H = target.ears
			H.set_secure_frequency("g",src.gang.gang_frequency)
			H.secure_classes["g"] = RADIOCL_SYNDICATE
			boutput(target, "Your headset has been tuned to your gang's frequency. Prefix a message with :g to communicate on this channel.")

//		update_max_members()

		//update gang overlays for all members so they can see the new join
		for(var/datum/mind/M in src.gang.members)
			if(M.current) M.current.antagonist_overlay_refresh(1, 0)
		src.gang.leader.current?.antagonist_overlay_refresh(1, 0)

		return

/*	proc/update_max_members()
		for(var/datum/gang/G in ticker.mode:gangs)
			var/dead_members = 0
			for(var/mob/M in G.members)
				if(isdead(M)) dead_members++
			if(G.members.len != ticker.mode:current_max_gang_members && G.members.len != dead_members)
				return

		ticker.mode:current_max_gang_members = min(ticker.mode:absolute_max_gang_members, ticker.mode:current_max_gang_members + 3)*/

/obj/item/storage/box/gang_flyers
	name = "gang recruitment flyer case"
	desc = "A briefcase full of flyers advertising a gang."
	icon_state = "briefcase_black"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"

	spawn_contents = list(/obj/item/gang_flyer = 7)
	var/datum/gang/gang = null

	make_my_stuff()
		..() //spawn the flyers

		for(var/obj/item/gang_flyer/flyer in contents)
			var/gang_name = gang?.gang_name || "C0D3R"
			flyer.name = "[gang_name] recruitment flyer"
			flyer.desc = "A flyer offering membership in the [gang_name] gang."
			flyer.gang = gang

proc/get_gang_gear(var/mob/living/carbon/human/user)
	if (!istype(user)) return 0

	if(user.mind.gang != null) // Needs new gear? Maybe!
		for(var/mob/living/carbon/human/has_cooldown in user.mind.gang.gear_cooldown) //does byond have a .contains() proc? idk this will do
			if(user == has_cooldown)
				return 1

		var/hasitem1 = 0
		var/hasitem2 = 0
		var/haspaint = 0
		var/hasheadset = 0
		for(var/obj/item/I in user.contents)
			if(istype(I,user.mind.gang.item1))
				hasitem1 = 1
			else if(istype(I,user.mind.gang.item2))
				hasitem2 = 1
			else if(istype(I,/obj/item/spray_paint))
				haspaint = 1
			else if(istype(I,/obj/item/device/radio/headset/gang) && I:secure_frequencies && I:secure_frequencies["g"] == user.mind.gang.gang_frequency)
				hasheadset = 1
		if(!hasitem1)
			var/obj/item/clothing/C = new user.mind.gang.item1(user.loc)
			// if (user.w_uniform)
			// 	user.drop_from_slot(user.w_uniform)
			user.equip_if_possible(C, user.slot_w_uniform)

		if(!hasitem2)
			var/obj/item/clothing/C = new user.mind.gang.item2(user.loc)
			if (istype(C, /obj/item/clothing/head))
				user.drop_from_slot(user.head)
				user.equip_if_possible(C, user.slot_head)
			else if (istype(C, /obj/item/clothing/mask))
				user.drop_from_slot(user.wear_mask)
				user.equip_if_possible(C, user.slot_wear_mask)

		if(!hasheadset)
			var/obj/item/device/radio/headset/gang/headset = new /obj/item/device/radio/headset/gang(user.loc)
			headset.set_secure_frequency("g",user.mind.gang.gang_frequency)
			if (user.ears)
				user.drop_from_slot(user.ears)
			user.equip_if_possible(headset, user.slot_ears)

		if(!haspaint)
			user.put_in_hand_or_drop(new /obj/item/spray_paint(user.loc))

		if(user.mind.special_role == ROLE_GANG_LEADER)
			var/obj/item/storage/box/gang_flyers/case = new /obj/item/storage/box/gang_flyers(user.loc)
			case.name = "[user.mind.gang.gang_name] recruitment material"
			case.desc = "A briefcase full of flyers advertising the [user.mind.gang.gang_name] gang."
			case.gang = user.mind.gang //this updates the flyers once they are spawned
			user.put_in_hand_or_drop(case)

		user.mind.gang.gear_cooldown += user
		sleep(3000)
		if(user.mind != null && user.mind.gang != null)
			user.mind.gang.gear_cooldown -= user
		return 2

//Must be jumpsuit. /obj/item/clothing/under
/datum/game_mode/gang/proc/make_item_lists()
	under_list = list(
	"owl" = /obj/item/clothing/under/gimmick/owl,
	"pinstripe" = /obj/item/clothing/under/suit/pinstripe,
	"purple" = /obj/item/clothing/under/suit/purple,
	"chaps" = /obj/item/clothing/under/gimmick/chaps,
	"mail" = /obj/item/clothing/under/misc/mail,
	"sweater" = /obj/item/clothing/under/gimmick/sweater,
	"princess" = /obj/item/clothing/under/gimmick/princess,
	"merchant" = /obj/item/clothing/under/gimmick/merchant,
	"birdman" = /obj/item/clothing/under/gimmick/birdman,
	"safari" = /obj/item/clothing/under/gimmick/safari,
	"det" = /obj/item/clothing/under/rank/det,
	"red" = /obj/item/clothing/under/shorts/red,
	"blue" = /obj/item/clothing/under/shorts/blue,
	"black" = /obj/item/clothing/under/jersey/black,
	"jersey" = /obj/item/clothing/under/jersey,
	"rainbow" = /obj/item/clothing/under/gimmick/rainbow,
	"johnny" = /obj/item/clothing/under/gimmick/johnny,
	"rasta" = /obj/item/clothing/under/misc/chaplain/rasta,
	"atheist" = /obj/item/clothing/under/misc/chaplain/atheist,
	"barber" = /obj/item/clothing/under/misc/barber,
	"mechanic" = /obj/item/clothing/under/rank/mechanic,
	"vice" = /obj/item/clothing/under/misc/vice,
	"gimmick" = /obj/item/clothing/under/gimmick,
	"bowling" = /obj/item/clothing/under/gimmick/bowling,
	"syndicate" = /obj/item/clothing/under/misc/syndicate,
	"black" = /obj/item/clothing/under/misc/lawyer/black,
	"red" = /obj/item/clothing/under/misc/lawyer/red,
	"lawyer" = /obj/item/clothing/under/misc/lawyer,
	"chav" = /obj/item/clothing/under/gimmick/chav,
	"dawson" = /obj/item/clothing/under/gimmick/dawson,
	"sealab" = /obj/item/clothing/under/gimmick/sealab,
	"spiderman" = /obj/item/clothing/under/gimmick/spiderman,
	"vault13" = /obj/item/clothing/under/gimmick/vault13,
	"duke" = /obj/item/clothing/under/gimmick/duke,
	"psyche" = /obj/item/clothing/under/gimmick/psyche,
	"tourist" = /obj/item/clothing/under/misc/tourist,
	"western" = /obj/item/clothing/under/misc/western)

	//must be mask or hat. type /obj/item/clothing/mask or /obj/item/clothing/head
	headwear_list = list(
	"owl_mask" = /obj/item/clothing/mask/owl_mask,
	"smile" = /obj/item/clothing/mask/smile,
	"balaclava" = /obj/item/clothing/mask/balaclava,
	"horse_mask" = /obj/item/clothing/mask/horse_mask,
	"melons" = /obj/item/clothing/mask/melons,
	"spiderman" = /obj/item/clothing/mask/spiderman,
	"swat" = /obj/item/clothing/mask/gas/swat,
	"skull" = /obj/item/clothing/mask/skull,
	"surgical" = /obj/item/clothing/mask/surgical,
	"waldohat" = /obj/item/clothing/head/waldohat,
	"purple" = /obj/item/clothing/head/that/purple,
	"cakehat" = /obj/item/clothing/head/cakehat,
	"wizard" = /obj/item/clothing/head/wizard,
	"that" = /obj/item/clothing/head/that,
	"red" = /obj/item/clothing/head/wizard/red,
	"necro" = /obj/item/clothing/head/wizard/necro,
	"pumpkin" = /obj/item/clothing/head/pumpkin,
	"flatcap" = /obj/item/clothing/head/flatcap,
	"mj_hat" = /obj/item/clothing/head/mj_hat,
	"genki" = /obj/item/clothing/head/genki,
	"butt" = /obj/item/clothing/head/purplebutt,
	"mailcap" = /obj/item/clothing/head/mailcap,
	"turban" = /obj/item/clothing/head/turban,
	"bobby" = /obj/item/clothing/head/helmet/bobby,
	"viking" = /obj/item/clothing/head/helmet/viking,
	"batman" = /obj/item/clothing/head/helmet/batman,
	"welding" = /obj/item/clothing/head/helmet/welding,
	"biker_cap" = /obj/item/clothing/head/biker_cap,
	"NTberet" = /obj/item/clothing/head/NTberet,
	"rastacap" = /obj/item/clothing/head/rastacap,
	"XComHair" = /obj/item/clothing/head/XComHair,
	"chav" = /obj/item/clothing/head/chav,
	"psyche" = /obj/item/clothing/head/psyche,
	"formal_turban" = /obj/item/clothing/head/formal_turban,
	"snake" = /obj/item/clothing/head/snake,
	"powdered_wig" = /obj/item/clothing/head/powdered_wig,
	"westhat_black" = /obj/item/clothing/head/westhat/black)

	//items purchasable from gangs
/datum/gang_item
	var/name = "commodity"	// Name of the item
	var/desc = "item"		//Description for item
	var/class1 = ""			//This should be general category: weapon, clothing/armor, misc
	var/class2 = ""			//This should be the gang item style: Street Gang, Western Gang, Space Gang
	var/item_path = null 		// Type Path of the item
	var/price = 100 			//
/datum/gang_item/street
	class1 = "Street Gang"
/datum/gang_item/thirties_chicago
	class1 = "30s Chicago Gang"
/datum/gang_item/kung_fu
	class1 = "Kung Fu"
/datum/gang_item/ninja
	class1 = "Ninja"
/datum/gang_item/country_western
	class1 = "Country Western"
/datum/gang_item/space
	class1 = "Space Gang"
/datum/gang_item/misc
	class1 = "Misc Gang"

/datum/gang_item/misc/ratstick
	name = "Rat Stick"
	desc = "A stick for killing rats."
	class2 = "weapon"
	price = 900
	item_path = /obj/item/ratstick

/datum/gang_item/street/lead_pipe
	name = "Lead Pipe"
	desc = "A pipe made of lead... Probably."
	class2 = "weapon"
	price = 500
	// item_path = /obj/item/lead_pipe
/datum/gang_item/street/chain_bat
	name = "Chain Bat"
	desc = "A Bat with a metal chain around it."
	class2 = "weapon"
	price = 1000
	// item_path = /obj/item/bat/chain
/datum/gang_item/street/switchblade
	name = "Switchblade"
	desc = "A stylish knife with a button to release the blade."
	price = 500
	class2 = "weapon"
	// item_path = /obj/item/switchblade
/datum/gang_item/street/Shiv	//Maybe have this damage an organ severely at the cost of little damage.
	name = "Shiv"
	desc = "A concealable stabbing implement for quick and deadly strikes."
	class2 = "weapon"
	price = 1000
	// item_path = /obj/item/lead_pipe

/datum/gang_item/street/aviator_glasses				//Reflects flashes back at caster
	name = "Aviator Sunglasses"
	desc = "Questionably stylish sunglasses from the previous century."
	class2 = "clothing"
	price = 2000
	// item_path = /obj/item/clothing/glasses/aviators
/datum/gang_item/street/brass_knuckles
	name = "Brass Knuckles"
	desc = "Wearable weapondry! The street gangs of the turn of the millenium really knew what they were doing!"
	class2 = "weapon"
	price = 1500
	// item_path = /obj/item/clothing/gloves/brass_knuckles
/datum/gang_item/street/getaway_car				//let gang members enter cars faster wearing their clothes
	name = "Getaway Car"
	desc = "A car designed for criminal activity on space stations... Well, not really, but it's a car at least."
	class2 = "misc"
	price = 10000
	// item_path = /obj/item/clothing/gloves/brass_knuckles
/datum/gang_item/street/cop_car				//let gang members enter cars faster wearing their clothes
	name = "Stolen Cop Car"
	desc = "An enterprising member of your gang stole this from the fuzz. Hopefully it doesn't have lojack."
	class2 = "misc"
	price = 20000
	item_path = /obj/machinery/vehicle/tank/car/security
/datum/gang_item/street/molotov_cocktail
	name = "Molotov Cocktail"
	desc = "It's a Molotov Cocktail."
	class2 = "misc"
	price = 1000
	// item_path = /obj/item/clothing/glasses/aviators

/////////////////////////////////////////////////////////////////////
////////////////////////////////NINJA////////////////////////////////
/////////////////////////////////////////////////////////////////////
/datum/gang_item/ninja/discount_katana
	name = "Katana"
	desc = "A discount japanese sword. Only folded 2 times. The blade is on the wrong side..."
	class2 = "weapon"
	price = 7000
	item_path = /obj/item/swords_sheaths/katana/reverse
/datum/gang_item/ninja/katana
	name = "Katana"
	desc = "It's the real McCoy. Folded so many times."
	class2 = "weapon"
	price = 25000
	item_path = /obj/item/swords_sheaths/katana

/datum/gang_item/ninja/shuriken
	name = "Shuriken"
	desc = "A pouch of 4 Shuriken throwing stars."
	class2 = "weapon"
	price = 1200
	item_path = /obj/item/storage/box/shuriken_pouch

/datum/gang_item/ninja/throwing_knife
	name = "Throwing Knive"
	desc = "A knife made to be thrown."
	class2 = "weapon"
	price = 1000
	item_path = /obj/item/dagger/throwing_knife

/datum/gang_item/ninja/nunchucks
	name = "Throwing Knive"
	desc = "A knife made to be thrown."
	class2 = "weapon"
	price = 1000
	// item_path = /obj/item/nunchucks


/datum/gang_item/ninja/sneaking_suit
	name = "Sneaking Suit"
	desc = "Become the shadows."
	class2 = "clothing"
	price = 3000
	item_path = /obj/item/clothing/suit/armor/sneaking_suit
/datum/gang_item/ninja/headband
	name = "Ninja Headband"
	desc = "A silly headband with a bit of metal on the front."
	class2 = "clothing"
	price = 1000
	// item_path = /obj/item/clothing/headgear/ninja_headband
/////////////////////////////////////////////////////////////////////
////////////////////////////SPACE////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/datum/gang_item/space/discount_csaber
	name = "Faux C-Saber"
	desc = "It's not a c-saber, it's something from the discount rack. Some kinda kooky laser stick. It doesn't look very dangerous."
	class2 = "weapon"
	price = 8000
	item_path = /obj/item/sword/discount
/datum/gang_item/space/csaber
	name = "C-Saber"
	desc = "It's not a lightsaber."
	class2 = "weapon"
	price = 30000
	item_path = /obj/item/sword
/datum/gang_item/space/phaser_gun
	name = "Phaser Gun"
	desc = "It shoots phasers."
	class2 = "weapon"
	price = 1300
	item_path = /obj/item/gun/energy/phaser_gun
/datum/gang_item/space/laser_gun
	name = "Laser Gun"
	desc = "It shoots lasers."
	class2 = "weapon"
	price = 20000
	item_path = /obj/item/gun/energy/laser_gun
/datum/gang_item/space/stims
	name = "Stimulants"
	desc = "These drugs'll keep you goin'."
	class2 = "misc"
	price = 30000
	item_path = /obj/item/stimpack
////////////////////////////////////////////////////////
/////////////COUNTRY WESTERN////////////////////////////
/////////////////////////////////////////////////////////
/datum/gang_item/country_western/colt_saa
	name = "Colt Single Action Army .45"
	desc = "It shoots bullets."
	class2 = "weapon"
	price = 7000
	item_path = /obj/item/gun/kinetic/single_action/colt_saa
/datum/gang_item/country_western/colt_45_bullet
	name = "Colt .45 Speedloader"
	desc = "A speedloader containing 7 rounds of Colt .45 ammunition.."
	class2 = "weapon"
	price = 700
	item_path = /obj/item/ammo/bullets/c_45


/datum/gang_item/misc/bathsalts
	name = "Bathsalts Pill Bottle"
	desc = "5 pills, 10u each of bathsalts."
	class2 = "drug"
	price = 200
	item_path = /obj/item/storage/pill_bottle/bathsalts
/datum/gang_item/misc/crank
	name = "Crank Pill Bottle"
	desc = "5 pills, 10u each of crank."
	class2 = "drug"
	price = 300
	item_path = /obj/item/storage/pill_bottle/crank
/datum/gang_item/misc/methamphetamine
	name = "Methamphetamine Pill Bottle"
	desc = "5 pills, 10u each of methamphetamine."
	class2 = "drug"
	price = 500
	item_path = /obj/item/storage/pill_bottle/methamphetamine

/datum/gang_item/misc/janktank
	name = "JankTank Implant"
	desc = "Cartel approved synaptic implant for the common gang footsoldier."
	class2 = "drug"
	price = 300
	item_path = /obj/item/implanter/gang

//////////////////////////////////////////////////////////
/obj/item/implant/gang
	name = "special implant"
	icon_state = "implant-b"
	impcolor = "b"
	var/used = 0

	activate()
		..()
		if (!ishuman(src.owner))
			return
		if (used == 0)
			used = 1
			var/mob/living/carbon/human/H = src.owner
			H.changeStatus("janktank", 6 MINUTES)
			H.show_text("You feel a rush.", "blue")

	deactivate()
		..()
		if (!ishuman(src.owner))
			return
		SPAWN(1 DECI SECOND)
			qdel(src)

/obj/item/implanter/gang
	icon_state = "implanter1-g"
	New()
		src.imp = new /obj/item/implant/gang( src )
		..()
		return

// /obj/item/chem_grenade/incendiary
// 	name = "incendiary grenade"
// 	desc = "A rather volatile grenade that creates a small fire."
// 	icon = 'icons/obj/items/grenade.dmi'
// 	icon_state = "incendiary"
// 	icon_state_armed = "incendiary1"
// 	stage = 2

// 	New()
// 		..()
// 		var/obj/item/reagent_containers/glass/B1 = new(src)
// 		B1.reagents.add_reagent("infernite", 20)
// 		beakers += B1
#undef CASH_DIVISOR
