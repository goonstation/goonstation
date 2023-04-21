/datum/game_mode/gang
	name = "Gang War (Beta)"
	config_tag = "gang"
	regular = FALSE

	antag_token_support = TRUE
	var/list/gangs = list()

	var/const/setup_min_teams = 3
	var/const/setup_max_teams = 5
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/potential_hot_zones = null
	var/area/hot_zone = null
	var/area/drop_zone = null
#ifdef RP_MODE
	var/hot_zone_timer = 10 MINUTES
#else
	var/hot_zone_timer = 5 MINUTES
#endif
	var/hot_zone_score = 1000

	var/crate_drop_frequency = 10 MINUTES
	var/crate_drop_timer = 5 MINUTES
	var/crate_drop_score = 1000
	var/loot_drop_frequency = 5 MINUTES
	var/loot_drop_count = 3


#ifdef RP_MODE
	var/const/kidnapping_timer = 15 MINUTES 	//Time to find and kidnap the victim.
	var/const/delay_between_kidnappings = 12 MINUTES
#else
	var/const/kidnapping_timer = 8 MINUTES 	//Time to find and kidnap the victim.
	var/const/delay_between_kidnappings = 5 MINUTES
#endif
	var/kidnapping_score = 20000
	var/kidnap_success = 0			//true if the gang successfully kidnaps.

	var/slow_process = 0			//number of ticks to skip the extra gang process loops
	var/shuttle_called = FALSE
	var/mob/kidnapping_target

	var/gangtag_scheduler = new /datum/controller/processScheduler()
	gangtag_scheduler

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
	if (num_teams > length(leaders_possible))
		num_teams = length(leaders_possible)

	if (!length(leaders_possible))
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!length(token_players))
			break
		src.traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeems an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeems an antag token.")

	var/list/chosen_leader = antagWeighter.choose(pool = leaders_possible, role = ROLE_GANG_LEADER, amount = num_teams, recordChosen = 1)
	src.traitors |= chosen_leader
	for (var/datum/mind/leader in src.traitors)
		leader.special_role = ROLE_GANG_LEADER
		leaders_possible.Remove(leader)

	return 1

/datum/game_mode/gang/post_setup()
	for (var/datum/mind/leaderMind in src.traitors)
		leaderMind.add_antagonist(ROLE_GANG_LEADER)


	find_potential_hot_zones()

	SPAWN(crate_drop_frequency)
		//process_hot_zones()
		process_lootcrate_spawn()

	SPAWN(loot_drop_frequency)
		process_lootbag_spawn()


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
	..(src.traitors)

/datum/game_mode/gang/check_finished()
	if(emergency_shuttle.location == SHUTTLE_LOC_RETURNED)
		return 1

	if (no_automatic_ending)
		return 0

	var/leadercount = 0
	for (var/datum/mind/L in ticker.mode:traitors)
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
	boutput(world, slow_process)
	if (slow_process < 5)
		return
	else
		slow_process = 0

	for(var/datum/gang/G in gangs)
		if (G.leader)
			var/mob/living/carbon/human/H = G.leader.current
			var/turf/sourceturf = get_turf(H)
			if ((G in sourceturf.gang_control) && G.gear_worn(H) == 2)
				H.setStatus("ganger", duration = INFINITE_STATUS)
			else
				H.delStatus("ganger")

		if (islist(G.members))
			for (var/datum/mind/M in G.members)
				var/mob/living/carbon/human/H = M.current
				var/turf/sourceturf = get_turf(H)
				var/gearworn = G.gear_worn(H)

				if ((G in sourceturf.gang_control)) //if we're in friendly territory (or contested territory)
					H.delStatus("ganger_debuff")
					if (gearworn == 2)  //gain a buff for wearing your gang outfit
						H.setStatus("ganger", duration = INFINITE_STATUS)
					else
						H.delStatus("ganger")

				else if (length(sourceturf.gang_control) > 0) //if we're in enemy territory (and not contested territory)
					H.delStatus("ganger")
					if (gearworn == 2) //gain a debuff for not wearing your outfit
						H.delStatus("ganger_debuff")
					else
						H.setStatus("ganger_debuff", duration = INFINITE_STATUS)
				else //if we're in neutral ground, remove all debuffs
					H.delStatus("ganger_debuff")
					H.delStatus("ganger")


/datum/game_mode/gang/declare_completion()
	if (!check_winner())
		boutput(world, "<h2><b>The round was a draw!</b></h2>")

	else
		var/datum/gang/winner = check_winner()
		if (istype(winner))
			boutput(world, "<h2><b>[winner.gang_name], led by [winner.leader.current.real_name], won the round!</b></h2>")

	..()

/datum/game_mode/gang/proc/check_winner()
	var/datum/gang/victorius_gang = null

	// Find the highest scoring gang.
	for (var/datum/gang/gang in src.gangs)
		if(!victorius_gang)
			victorius_gang = gang
		else if(victorius_gang.gang_score() < gang.gang_score())
			victorius_gang = gang

	// Check if the highest score is a draw.
	for (var/datum/gang/gang in src.gangs)
		if((victorius_gang != gang) && (victorius_gang.gang_score() == gang.gang_score()))
			return 0

	if (istype(victorius_gang))
		return victorius_gang

/// hot zone thing

/datum/game_mode/gang/proc/find_potential_hot_zones()
	potential_hot_zones = list()

	for(var/area/A as area in world)
		if(A.z != 1 || A.teleport_blocked || istype(A, /area/supply) || istype(A, /area/shuttle/) || A.name == "Space" || A.name == "Ocean")
			continue
		potential_hot_zones += A

	return
/datum/game_mode/gang/proc/process_lootcrate_spawn()

	drop_zone = pick(potential_hot_zones)
	var/turfList[0]
	var/valid = 0

	for (var/turf/simulated/floor/T in drop_zone.contents)
		if (!T.density)
			valid = 1
			for (var/obj/O in T.contents)
				if (O.density)
					valid=0
					break
				else
			if (valid == 1)
				turfList.Add(T)

	var/turf/target = pick(turfList)
	new/obj/storage/crate/gang_crate/guns_and_gear(target)
	broadcast_to_all_gangs("We've dropped off some gear at the [drop_zone.name]! It's anchored in place for 5 minutes, so get fortifying!")

	SPAWN(crate_drop_timer-600)
		if(drop_zone != null) broadcast_to_all_gangs("The loot crate at the [hot_zone.name] can be moved in 1 minute!")
		sleep(1 MINUTE)
		if(drop_zone != null) broadcast_to_all_gangs("The loot crate at the [hot_zone.name] is free! Drag it to your locker!")
		sleep(crate_drop_timer)
		process_lootcrate_spawn()


/datum/game_mode/gang/proc/get_random_civvie()
	var/mindList[0]
	for (var/datum/mind/M in ticker.minds)
		//if (M.gang) continue
		mindList.Add(M)
	return pick(mindList)


var/gangGreetings[] = list("Yo","Whassup","Hey","Sup","Hiya","Oi" )
var/gangSalutations[] = list("Peace.","Good luck.","Enjoy!","Try not to die.","Over n out.","lol" )
/datum/game_mode/gang/proc/process_lootbag_spawn()
	for(var/i = 1 to loot_drop_count)
		var/area/loot_zone = pick(potential_hot_zones)
		var/turfList[0]
		var/uncoveredTurfList[0]
		var/bushList[0]
		var/crateList[0]
		var/disposalList[0]
		var/valid

		var message = pick(gangGreetings) +", [prob(20) ? " don't ask how I got your number - " : null]"
		for (var/turf/simulated/floor/T in loot_zone.contents)
			if (!T.density)
				valid = 1
				for (var/obj/O in T.contents)
					if (istype(O,/obj/shrub))
						bushList.Add(O)
					else if (istype(O,/obj/machinery/disposal))
						disposalList.Add(O)
					else if (istype(O,/obj/storage))
						var/obj/storage/crate = O
						if (!crate.secure && !crate.locked)
							crateList.Add(O)
					if (O.density)
						valid=0
						break

				if (valid == 1)
					if (T.intact)
						turfList.Add(T)
					else
						uncoveredTurfList.Add(T)

		if(length(bushList))
			var/obj/shrub/target = pick(bushList)
			target.override_default_behaviour = 1
			target.additional_items.Add(/obj/item/gang_loot/guns_and_gear)
			target.max_uses = 1
			target.last_use = 0
			message += " we left some goods in a bush somewhere around [loot_zone]."

		else if(length(crateList))
			var/obj/storage/target = pick(crateList)
			target.contents.Add(new/obj/item/gang_loot/guns_and_gear(target.contents))
			message += " we left a bag in [target], somewhere around [loot_zone]. "

		else if(length(disposalList))
			var/obj/machinery/disposal/target = pick(disposalList)
			target.contents.Add(new/obj/item/gang_loot/guns_and_gear(target.contents))
			message += " we left a bag in [target], somewhere around [loot_zone]. "

		else if(length(turfList))
			var/turf/simulated/floor/target = pick(turfList)
			var/obj/item/gang_loot/loot = new/obj/item/gang_loot/guns_and_gear
			target.contents.Add(loot)
			loot.hide(target.intact)
			message += " we had to hide a bag in [loot_zone], under the floor tiles. "
		else
			var/turf/simulated/floor/target = pick(uncoveredTurfList)
			var/obj/item/gang_loot/loot = new/obj/item/gang_loot/guns_and_gear
			target.contents.Add(loot)
			loot.hide(target.intact)
			message += " we had to hide a bag in [loot_zone]. "


		message += "You won't find it useful, but there are some guys aboard who will. "

		if (prob(40))
			message += pick(gangSalutations)
		var/datum/mind/civvie = get_random_civvie()

		var/datum/signal/newsignal = get_free_signal()
		newsignal.source = src
		newsignal.data["command"] = "text_message"
		newsignal.data["sender_name"] = "Unknown Sender"
		newsignal.data["message"] = "[message]"
		newsignal.data["address_1"] = civvie.originalPDA.net_id
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(newsignal)


	sleep(loot_drop_frequency)
	process_lootbag_spawn()

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
		if (H.ckey && !isdead(H) && H.get_gang() != top_gang && !istype(H.mutantrace, /datum/mutantrace/virtual))
			potential_targets += H

	if (!length(potential_targets))
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
			G.broadcast_to_gang("A bounty has been placed on the capture of [target_name]. Shove them into your gang locker <ALIVE>, within 8 minutes for a massive reward!")
		else
			G.broadcast_to_gang("[target_name] is the target of a kidnapping by [top_gang.gang_name]. Ensure that [target_name] is alive and well for the next 8 minutes for a reward!")

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
						G.score_event += kidnapping_score / length(gangs)	//This is less than the total points the top_gang would get, so it behooves security to help the non-top gangs keep the target safe.
				broadcast_to_all_gangs("[top_gang.gang_name] has failed to kidnap [target_name] and the other gangs have been rewarded for thwarting the kidnapping attempt!")
			else
				broadcast_to_all_gangs("[target_name] has died in one way or another. No gangs have been rewarded for this futile exercise.")

			sleep(delay_between_kidnappings)
		process_kidnapping_event()


proc/broadcast_to_all_gangs(var/message)
	var/datum/language/L = languages.language_cache["english"]
	var/list/messages = L.get_messages(message)

	for (var/datum/gang/gang in get_all_gangs())
		gang.announcer_radio.set_secure_frequency("g", gang.gang_frequency)
		gang.announcer_radio.talk_into(gang.announcer_source, messages, "g", gang.announcer_source.name, "english")
/datum/gang
	/// The maximum number of gang members per gang.
	var/static/current_max_gang_members = 5
	/// Gang tag icon states that are being used by other gangs.
	var/static/list/used_tags
	/// Gang names that are being used by other gangs.
	var/static/list/used_names
	/// Radio frequencies that are being used by other gangs.
	var/static/list/used_frequencies
	/// Jumpsuit items that are being used by other gangs as part of their gang uniform.
	var/static/list/uniform_list
	/// Mask or hat items that are being used by other gangs as part of their gang uniform.
	var/static/list/headwear_list

	/// The radio source for the gang's announcer, who will announce various messages of importance over the gang's frequency.
	var/datum/generic_radio_source/announcer_source
	/// The radio headset that the gang's announcer will use.
	var/obj/item/device/radio/headset/gang/announcer_radio

	/// The chosen name of this gang.
	var/gang_name = "Gang Name"
	/// The randomly selected tag of this gang.
	var/gang_tag = 0
	/// The unique radio frequency that members of this gang will communicate over.
	var/gang_frequency = 0
	var/spray_paint_remaining = GANG_STARTING_SPRAYPAINT
	/// The chosen jumpsuit item of this gang.
	var/obj/item/clothing/uniform = null
	/// The chosen mask or hat item of this gang.
	var/obj/item/clothing/headwear = null
	/// The location of this gang's locker.
	var/area/base = null
	/// The various areas that this gang currently controls.
	var/list/area/controlled_areas = list()
	/// The mind of this gang's leader.
	var/datum/mind/leader = null
	/// The minds of gang members associated with this gang. Does not include the gang leader.
	var/list/members = list()
	var/list/tags = list()
	/// The minds of members of this gang who are currently on cooldown from redeeming their gear from the gang locker.
	var/list/gear_cooldown = list()
	/// The gang locker of this gang.
	var/obj/ganglocker/locker = null
	/// The usable number of points that this gang has to spend with.
	var/spendable_points = 0
	/// The street cred this gang has - used exclusively by the leader for purchasing gang members & revives
	var/street_cred = 0
	/// An associative list of the items that this gang has purchased and the quantity in which they have been purchased.
	var/list/items_purchased = list()
	var/datum/client_image_group/turf_image_group = new/datum/client_image_group()
	var/color = "#DDDDDD"

	/// Points gained by this gang from owning areas.
	var/score_turf = 0
	/// The total quantity of cash that this gang has deposited.
	var/score_cash = 0
	/// Points gained by this gang from gun deposits.
	var/score_gun = 0
	/// Points gained by this gang from drug deposits.
	var/score_drug = 0
	/// Points gained by this gang from completing events.
	var/score_event = 0

	/// Starting price of the janktank II (gang member revival syringe)
	var/current_revival_price = GANG_REVIVE_COST
	/// Price increase for every janktank II purchased
	var/revival_price_gain = GANG_REVIVE_COST_GAIN

	/// Price to hire a spectator gang member
	var/current_newmember_price = GANG_NEW_MEMBER_COST
	/// Price increase for each following hire, to discourage zergs
	var/newmember_price_gain = GANG_NEW_MEMBER_COST_GAIN


	proc/unclaim_tiles(var/location)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		var/turf/sourceturf = get_turf(location)
		for (var/turf/turftile in range(GANG_TAG_INFLUENCE,sourceturf))
			var/tileDistance = GET_SQUARED_EUCLIDEAN_DIST(turftile, sourceturf)
			if(tileDistance > GANG_TAG_INFLUENCE_SQUARED) continue
			if (turftile.gang_control[src])
				turftile.gang_control[src][3] -= 1
				if (tileDistance <= GANG_TAG_MINIMUM_RANGE_SQUARED)
					turftile.gang_control[src][2] -= 1

				if (turftile.gang_control[src][2] == 0)
					turftile.gang_control[src][1].alpha = 80

				if (turftile.gang_control[src][3] == 0)
					imgroup.remove_image(turftile.gang_control[src][1])
					qdel(turftile.gang_control[src][1])
					turftile.gang_control[src] = null


	proc/claim_tiles(var/location)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		var/turf/sourceturf = get_turf(location)
		if (!sourceturf.gang_control[src])
			var/image/img = image('icons/effects/white.dmi', sourceturf)
			img.alpha = 230
			img.color = src.color
			sourceturf.gang_control[src] = list(img,1,1)
			imgroup.add_image(img)
		else
			sourceturf.gang_control[src][1].alpha = 230
			sourceturf.gang_control[src][2] += 1
			sourceturf.gang_control[src][3] += 1

		for (var/turf/turftile in orange(GANG_TAG_INFLUENCE,sourceturf))
			var/distance = GET_SQUARED_EUCLIDEAN_DIST(turftile, sourceturf)
			if(distance > GANG_TAG_INFLUENCE_SQUARED) continue
			if (!turftile.gang_control[src])
				var/image/img = image('icons/effects/white.dmi', turftile)
				if(distance > GANG_TAG_MINIMUM_RANGE_SQUARED)
					turftile.gang_control[src] = list(img,0,1)
					img.alpha = 80
				else
					turftile.gang_control[src] = list(img,1,1)
					img.alpha = 170
				img.color = src.color
				imgroup.add_image(img)
			else
				if(distance <= GANG_TAG_MINIMUM_RANGE_SQUARED)
					turftile.gang_control[src][1].alpha = 170
					turftile.gang_control[src][2] += 1
				turftile.gang_control[src][3] += 1


	New()
		. = ..()
		if (!src.used_tags)
			src.used_tags = list()
		if (!src.used_names)
			src.used_names = list()
		if (!src.used_frequencies)
			src.used_frequencies = list()
		if (!src.uniform_list || !src.headwear_list)
			src.make_item_lists()

		src.gang_tag = rand(0, 22)
		while(src.gang_tag in src.used_tags)
			src.gang_tag = rand(0, 22)
		src.used_tags += src.gang_tag

		src.gang_frequency = rand(1360, 1420)
		while(src.gang_frequency in src.used_frequencies)
			src.gang_frequency = rand(1360, 1420)
		src.used_frequencies += src.gang_frequency

		src.announcer_source = new /datum/generic_radio_source()
		src.announcer_source.set_name("The [pick("Kingpin","Cabal","Council","Boss")]")
		src.announcer_radio = new /obj/item/device/radio/headset/gang()

		if (istype(ticker?.mode, /datum/game_mode/gang))
			var/datum/game_mode/gang/gamemode = ticker.mode
			gamemode.gangs += src

	proc/select_gang_name()
		if (!src.leader || !src.leader.current.client)
			return

		var/temporary_name = pick_string("gangwar.txt", "fullchosen")
		var/first_name
		var/second_name

		var/list/first_names = strings("gangwar.txt", "part1")
		var/list/second_names = strings("gangwar.txt", "part2")

		while(src.gang_name == "Gang Name")
			switch(tgui_alert(src.leader.current, "Name: [temporary_name].", "Approve Your Gang's Name", list("Accept", "Reselect", "Randomise")))
				if ("Accept")
					if (temporary_name in src.used_names)
						boutput(src.leader.current, "<span class='alert'>Another gang has this name.</span>")
						continue

					src.gang_name = temporary_name
					src.used_names += temporary_name
					boutput(src.leader.current, "<h4><span class='alert'>Your gang name is [src.gang_name]!</span></h4>")

				if ("Reselect")
					first_name = tgui_input_list(src.leader.current, "Select the first word in your gang's name:", "Gang Name Selection", first_names)
					second_name = tgui_input_list(src.leader.current, "Select the second word in your gang's name:", "Gang Name Selection", second_names)
					temporary_name = "[first_name] [second_name]"

				if ("Randomise")
					if (prob(70))
						temporary_name = pick_string("gangwar.txt", "fullchosen")
					else
						first_name = pick(first_names)
						second_name = pick(second_names)
						temporary_name = "[first_name] [second_name]"

	proc/select_gang_uniform()
		// Jumpsuit Selection.
		var/temporary_jumpsuit = tgui_input_list(src.leader.current, "Select your gang's uniform slot item:", "Gang Uniform Selection", src.uniform_list)

		while (!src.uniform_list[temporary_jumpsuit])
			boutput(src.leader.current , "<span class='alert'>That uniform has been claimed by another gang.</span>")
			temporary_jumpsuit = tgui_input_list(src.leader.current, "Select your gang's uniform slot item:", "Gang Uniform Selection", src.uniform_list)

		src.uniform = src.uniform_list[temporary_jumpsuit]
		src.uniform_list -= temporary_jumpsuit

		// Mask/Headwear Selection.
		if(src.gang_name == "NICOLAS CAGE FAN CLUB")
			src.headwear = /obj/item/clothing/mask/niccage
		else
			var/temporary_headwear = tgui_input_list(src.leader.current, "Select your gang's mask or head slot item:", "Gang Uniform Selection", src.headwear_list)

			while(!src.headwear_list[temporary_headwear])
				boutput(src.leader.current , "<span class='alert'>That mask or hat has been claimed by another gang.</span>")
				temporary_headwear = tgui_input_list(src.leader.current, "Select your gang's mask or head slot item:", "Gang Uniform Selection", src.headwear_list)

			src.headwear = src.headwear_list[temporary_headwear]
			src.headwear_list -= temporary_headwear

	proc/broadcast_to_gang(var/message)
		var/datum/language/L = languages.language_cache["english"]
		var/list/messages = L.get_messages(message)

		src.announcer_radio.set_secure_frequency("g", src.gang_frequency)
		src.announcer_radio.talk_into(src.announcer_source, messages, "g", src.announcer_source.name, "english")

	proc/num_areas_controlled()
		return length(src.controlled_areas)

	proc/gang_score()
		var/score = 0

		score += score_turf //x25
		score += score_cash
		score += score_gun
		score += score_drug
		score += score_event

		return round(score)

	proc/add_points(amount, datum/mind/bonusMind)
		street_cred += amount
		if (leader)
			if (leader == bonusMind)
				leader.gang_points += amount * 2 //give double rewards for the one providing
			else
				leader.gang_points += amount
		if (islist(members))
			for (var/datum/mind/M in members)
				if (M == bonusMind)
					M.gang_points += amount * 2
				else
					M.gang_points += amount

	proc/can_be_joined() //basic for now but might be expanded on so I'm making it a proc of its own
		if(length(src.members) >= src.current_max_gang_members)
			return FALSE
		return TRUE

	proc/gear_worn(var/mob/living/carbon/human/M)
		if(!istype(M))
			return FALSE

		var/count = 0

		if(istype(M.w_uniform, src.uniform))
			count++

		if(istype(M.head, src.headwear) || istype(M.wear_mask, src.headwear))
			count++

		return count

	proc/make_tag(turf/T)
		var/obj/decal/gangtag/tag = new /obj/decal/gangtag(T)
		tag.icon_state = "gangtag[src.gang_tag]"
		tag.name = "[src.gang_name] tag"
		tag.owners = src
		tag.delete_same_tags()
		src.claim_tiles(T)
		var/area/area = T.loc
		T.tagged = TRUE
		area.gang_owners = src


	proc/make_item_lists()
		// Must be jumpsuit. `/obj/item/clothing/under`
		src.uniform_list = list(
		"owl suit" = /obj/item/clothing/under/gimmick/owl,
		"pinstripe suit" = /obj/item/clothing/under/suit/pinstripe,
		"purple suit" = /obj/item/clothing/under/suit/purple,
		"assless chaps" = /obj/item/clothing/under/gimmick/chaps,
		"mailman's jumpsuit" = /obj/item/clothing/under/misc/mail,
		"comfy sweater" = /obj/item/clothing/under/gimmick/sweater,
		"party princess uniform" = /obj/item/clothing/under/gimmick/princess,
		"salesman's uniform" = /obj/item/clothing/under/gimmick/merchant,
		"birdman suit" = /obj/item/clothing/under/gimmick/birdman,
		"safari clothing" = /obj/item/clothing/under/gimmick/safari,
		"hard worn suit" = /obj/item/clothing/under/rank/det,
		"red athletic shorts" = /obj/item/clothing/under/shorts/red,
		"blue athletic shorts" = /obj/item/clothing/under/shorts/blue,
		"black basketball jersey" = /obj/item/clothing/under/jersey/black,
		"white basketball jersey" = /obj/item/clothing/under/jersey,
		"rainbow jumpsuit" = /obj/item/clothing/under/gimmick/rainbow,
		"johnny" = /obj/item/clothing/under/gimmick/johnny,
		"rastafarian's shirt" = /obj/item/clothing/under/misc/chaplain/rasta,
		"atheist's sweater" = /obj/item/clothing/under/misc/chaplain/atheist,
		"barber's uniform" = /obj/item/clothing/under/misc/barber,
		"mechanic's uniform" = /obj/item/clothing/under/rank/mechanic,
		"vice officer's suit" = /obj/item/clothing/under/misc/vice,
		"sailor uniform" = /obj/item/clothing/under/gimmick,
		"bowling suit" = /obj/item/clothing/under/gimmick/bowling,
		"tactical turtleneck" = /obj/item/clothing/under/misc/syndicate,
		"black lawyer's suit" = /obj/item/clothing/under/misc/lawyer/black,
		"red lawyer's suit" = /obj/item/clothing/under/misc/lawyer/red,
		"lawyer suit" = /obj/item/clothing/under/misc/lawyer,
		"blue tracksuit" = /obj/item/clothing/under/gimmick/chav,
		"aged hipster clothes" = /obj/item/clothing/under/gimmick/dawson,
		"diver jumpsuit" = /obj/item/clothing/under/gimmick/sealab,
		"spiderman suit" = /obj/item/clothing/under/gimmick/spiderman,
		"Vault 13 jumpsuit" = /obj/item/clothing/under/gimmick/vault13,
		"duke's suit" = /obj/item/clothing/under/gimmick/duke,
		"psychedelic jumpsuit" = /obj/item/clothing/under/gimmick/psyche,
		"hawaiian shirt" = /obj/item/clothing/under/misc/tourist,
		"western shirt and pants" = /obj/item/clothing/under/misc/western)


		// Must be mask or hat. `/obj/item/clothing/mask` or `/obj/item/clothing/head`
		src.headwear_list = list(
		"owl mask" = /obj/item/clothing/mask/owl_mask,
		"smiling face" = /obj/item/clothing/mask/smile,
		"balaclava" = /obj/item/clothing/mask/balaclava,
		"horse mask" = /obj/item/clothing/mask/horse_mask,
		"'George Melons' mask" = /obj/item/clothing/mask/melons,
		"spiderman mask" = /obj/item/clothing/mask/spiderman,
		"SWAT mask" = /obj/item/clothing/mask/gas/swat,
		"skull mask" = /obj/item/clothing/mask/skull,
		"sterile mask" = /obj/item/clothing/mask/surgical,
		"bobble hat and glasses" = /obj/item/clothing/head/waldohat,
		"top hat" = /obj/item/clothing/head/that,
		"purple top hat" = /obj/item/clothing/head/that/purple,
		"cakehat" = /obj/item/clothing/head/cakehat,
		"blue wizard hat" = /obj/item/clothing/head/wizard,
		"red wizard hat" = /obj/item/clothing/head/wizard/red,
		"necromancer hood" = /obj/item/clothing/head/wizard/necro,
		"carved pumpkin" = /obj/item/clothing/head/pumpkin,
		"flat cap" = /obj/item/clothing/head/flatcap,
		"smooth criminal's hat" = /obj/item/clothing/head/mj_hat,
		"genki" = /obj/item/clothing/head/genki,
		"purple butt hat" = /obj/item/clothing/head/purplebutt,
		"mailman's hat" = /obj/item/clothing/head/mailcap,
		"turban" = /obj/item/clothing/head/turban,
		"formal turban" = /obj/item/clothing/head/formal_turban,
		"constable's helmet" = /obj/item/clothing/head/helmet/bobby,
		"viking helmet" = /obj/item/clothing/head/helmet/viking,
		"batcowl" = /obj/item/clothing/head/helmet/batman,
		"welding helmet" = /obj/item/clothing/head/helmet/welding,
		"biker cap" = /obj/item/clothing/head/biker_cap,
		"NT beret" = /obj/item/clothing/head/NTberet,
		"rastafarian cap" = /obj/item/clothing/head/rastacap,
		"XComHair" = /obj/item/clothing/head/XComHair,
		"burberry cap" = /obj/item/clothing/head/chav,
		"psychedelic hat" = /obj/item/clothing/head/psyche,
		"Snake's bandana" = /obj/item/clothing/head/snake,
		"powdered wig" = /obj/item/clothing/head/powdered_wig,
		"black ten-gallon hat" = /obj/item/clothing/head/westhat/black)

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
		if(!istype(target,/turf) && !istype(target,/obj/decal/gangtag)) return

		if (!user)
			return

		if(in_use)
			boutput(user, "<span class='alert'>You are already tagging an area!</span>")
			return

		var/turf/turftarget = get_turf(target)

		if((turftarget == loc) || (BOUNDS_DIST(src, target) > 0))
			return

		var/datum/gang/gang = user.get_gang()

		if(!gang)
			boutput(user, "<span class='alert'>You aren't in a gang, why would you do that?</span>")
			return



		for (var/obj/decal/gangtag/tag in orange(GANG_TAG_MINIMUM_RANGE,target))
			if(!IN_EUCLIDEAN_RANGE(tag, target, GANG_TAG_MINIMUM_RANGE)) continue
			if (tag.owners == user.get_gang())
				boutput(user, "<span class='alert'>This is too close to an existing tag!</span>")
				return
		for (var/obj/ganglocker/locker in orange(GANG_TAG_MINIMUM_RANGE,target))
			if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_MINIMUM_RANGE)) continue
			if (locker.gang == user.get_gang())
				boutput(user, "<span class='alert'>This is too close to your locker!</span>")
				return

		var/validLocation = FALSE
		if (istype(target,/obj/decal/gangtag))
			var/obj/decal/gangtag/tag = target
			if (tag.owners != user.get_gang())
				//if we're tagging over someone's tag, double our search radius
				//(this will find any tags whose influence intersects with the target tag's influence)
				for (var/obj/ganglocker/locker in orange(GANG_TAG_INFLUENCE*2,target))
					if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_INFLUENCE*2)) continue
					if (locker.gang == user.get_gang())
						validLocation = TRUE
				for (var/obj/decal/gangtag/otherTag in orange(GANG_TAG_INFLUENCE*2,target))
					if(!IN_EUCLIDEAN_RANGE(otherTag, target, GANG_TAG_INFLUENCE*2)) continue
					if (otherTag.owners && otherTag.owners == user.get_gang())
						validLocation = TRUE
			else
				boutput(user, "<span class='alert'>You can't spray over your own tags!</span>")
				return
		else
			//we're tagging a wall, check it's in our territory and not someone else's territory
			for (var/obj/decal/gangtag/tag in orange(GANG_TAG_INFLUENCE,target))
				if(!IN_EUCLIDEAN_RANGE(tag, target, GANG_TAG_INFLUENCE)) continue
				if (tag.owners == user.get_gang())
					validLocation = TRUE
				else if (tag.owners)
					boutput(user, "<span class='alert'>You can't spray in another gang's territory! Spray over their tag, instead!</span>")
					return
			for (var/obj/ganglocker/locker in orange(GANG_TAG_INFLUENCE,target))
				if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_INFLUENCE)) continue
				if (locker.gang == user.get_gang())
					validLocation = TRUE
				else
					boutput(user, "<span class='alert'>There's better places to tag than here! </span>")
					return

		if(!validLocation)
			boutput(user, "<span class='alert'>This is outside your gang's influence!</span>")
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

		if(getarea.gang_owners && getarea.gang_owners != gang && !turftarget.tagged)
			boutput(user, "<span class='alert'>[getarea.gang_owners.gang_name] own this area! You must paint over their tag to capture it!</span>")
			if (user.GetComponent(/datum/component/tracker_hud))
				return
			var/datum/game_mode/gang/mode = ticker.mode
			if (!istype(mode))
				return
			for (var/datum/gang/other_gang in mode.gangs)
				for (var/obj/decal/cleanable/gangtag/tag in other_gang.tags)
					if (get_area(tag) == getarea)
						user.AddComponent(/datum/component/tracker_hud/gang, get_turf(tag))
						SPAWN(3 SECONDS)
							var/datum/component/tracker_hud/gang/component = user.GetComponent(/datum/component/tracker_hud/gang)
							component.RemoveComponent()
						return
			return
		if(getarea.being_captured)
			boutput(user, "<span class='alert'>Somebody is already tagging that area!</span>")
			return
		if(getarea.gang_owners == gang)
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
	var/datum/gang/gang

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
				src.gang = M?.get_gang()
			if (gang)
				icon = 'icons/obj/decals/graffiti.dmi'
				icon_state = "gangtag[src.gang.gang_tag]"
				var/speedup = src.gang.gear_worn(M)
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

		S.in_use = FALSE
		target_area.being_captured = FALSE
		for (var/obj/decal/gangtag/otherTag in range(1,target_turf))
			otherTag.owners.unclaim_tiles(target_turf)
			otherTag.owners = null

		src.gang.make_tag(target_turf)
		qdel(S)

		boutput(M, "<span class='notice'>You have claimed this area for your gang!</span>")

/obj/ganglocker
	desc = "Gang locker."
	name = "Gang Closet"
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "gang"
	density = 0
	anchored = 1
	var/datum/gang/gang = null
	var/image/default_screen_overlay = null
	var/HTML = null
	var/list/buyable_items = list()

	var/static/janktank_price = 300

	New()
		..()
		default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
		src.UpdateOverlays(default_screen_overlay, "screen")
		buyable_items = list(
			new/datum/gang_item/consumable/medkit,
			new/datum/gang_item/consumable/quickhack,
			new/datum/gang_item/misc/janktank,
			new/datum/gang_item/misc/ratstick,
			new/datum/gang_item/ninja/throwing_knife,
			new/datum/gang_item/ninja/shuriken,
			new/datum/gang_item/ninja/sneaking_suit,
			new/datum/gang_item/ninja/discount_katana,
			//new/datum/gang_item/space/phaser_gun,
			//new/datum/gang_item/space/laser_gun,
			new/datum/gang_item/space/discount_csaber,
			// new/datum/gang_item/space/csaber,
			// new/datum/gang_item/ninja/katana,
			new/datum/gang_item/street/cop_car,

			new/datum/gang_item/space/stims)

	examine()
		. = ..()
		. += "The screen displays \"Total Score: [gang.gang_score()]\""

	attack_hand(var/mob/living/carbon/human/user)
		if(!isalive(user))
			boutput(user, "<span class='alert'>Not when you're incapacitated.</span>")
			return

		add_fingerprint(user)

		// if (!src.HTML)
		var/page = src.generate_HTML(user)

		user.Browse(page, "window=gang_locker;size=650x630")
		//onclose(user, "gang_locker")

	//puts the html string in the var/HTML on src
	proc/generate_HTML(var/mob/living/carbon/human/user)
		var/datum/mind/M = user.mind
		var/dat = {"<HTML>
		<div style="width: 100%; overflow: hidden;">
			<div style="height: 150px;width: 290px;padding-left: 5px;; float: left;border-style: solid;">
				<center><font size="6"><a href='byond://?src=\ref[src];get_gear=1'>get gear</a></font></center><br>
				<font size="3">You have [M.gang_points] points to spend!</font>
				<center><font size="6"><a href='byond://?src=\ref[src];get_spray=1'>grab spraypaint</a></font></center><br>
				<font size="3">The gang has [gang.spray_paint_remaining] spray paints remaining.</font>
			</div>
			<div style="height: 150px;width: 290px;padding-left: 5px;; float: left;border-style: solid;">
				<center><font size="6"><a href='byond://?src=\ref[src];get_gear=1'>get gear</a></font></center><br>
				<font size="3">You have [gang.street_cred] street cred!</font>
			</div>
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
			if (istype(GI, /datum/gang_item/misc/janktank))
				var/datum/gang_item/misc/janktank/JT = GI
				JT.price = src.janktank_price

			dat += "<tr><td><a href='byond://?src=\ref[src];buy_item=\ref[GI]'>[GI.name]</a></td><td>[GI.price]</td><td>[GI.desc]</td><td>[GI.class1]</td><td>[GI.class2]</td>  </tr>"

		dat += "</table></HTML>"

		return dat

	proc/handle_get_spraypaint(var/mob/living/carbon/human/user)
		var/image/overlay = null
		if(user.get_gang() == src.gang)
			if (gang.spray_paint_remaining > 0)
				gang.spray_paint_remaining--
				user.put_in_hand_or_drop(new /obj/item/spray_paint(user.loc))
				boutput(user, "<span class='alert'>You grab a bottle of spray paint from the locker..</span>")
		else
			boutput(user, "<span class='alert'>The locker's screen briefly displays the message \"Access Denied\".</span>")
			overlay = image('icons/obj/large_storage.dmi', "gang_overlay_red")

		src.UpdateOverlays(overlay, "screen")
		SPAWN(1 SECOND)
			src.UpdateOverlays(default_screen_overlay, "screen")

	Topic(href, href_list)
		..()
		if ((usr.stat || usr.restrained()) || (BOUNDS_DIST(src, usr) > 0))
			return

		if (href_list["get_gear"])
			handle_gang_gear(usr)
		if (href_list["get_spray"])
			handle_get_spraypaint(usr)
		if (href_list["buy_item"])
			if (usr.get_gang() != src.gang)
				boutput(usr, "<span class='alert'>You are not a member of this gang, you cannot purchase items from it.</span>")
				return
			var/datum/gang_item/GI = locate(href_list["buy_item"])
			if (locate(GI) in buyable_items)
				if (GI.price <= usr.mind.gang_points)
					usr.mind.gang_points -= GI.price
					new GI.item_path(src.loc)
					boutput(usr, "<span class='notice'>You purchase [GI.name] for [GI.price]. Remaining balance = [usr.mind.gang_points] points.</span>")
					gang.items_purchased[GI.item_path]++
					updateDialog()
				else
					boutput(usr, "<span class='alert'>Insufficient funds.</span>")

	proc/increase_janktank_price()
		src.janktank_price = round(src.janktank_price * 1.1)

		for (var/datum/gang/gang in get_all_gangs())
			var/datum/gang_item/misc/janktank/JT = locate(/datum/gang_item/misc/janktank) in gang.locker.buyable_items
			JT.price = janktank_price

	proc/handle_gang_gear(var/mob/living/carbon/human/user)
		var/image/overlay = null
		switch(src.get_gang_gear(user))
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

		src.UpdateOverlays(overlay, "screen")
		SPAWN(1 SECOND)
			src.UpdateOverlays(default_screen_overlay, "screen")

	proc/get_gang_gear(var/mob/living/carbon/human/user)
		if (!istype(user))
			return 0

		if(!(user.mind in src.gang.members) && user.mind != src.gang.leader)
			return 0

		if (user in src.gang.gear_cooldown)
			return 1

		var/has_gang_uniform = FALSE
		var/has_gang_headwear = FALSE
		var/has_spray_paint = FALSE
		var/has_gang_headset = FALSE

		for(var/obj/item/I in user.contents)
			if(istype(I, src.gang.uniform))
				has_gang_uniform = TRUE
			else if(istype(I, src.gang.headwear))
				has_gang_headwear = TRUE
			else if(istype(I, /obj/item/spray_paint))
				has_spray_paint = TRUE
			else if(istype(I, /obj/item/device/radio/headset))
				var/obj/item/device/radio/headset/headset = I
				if (istype(headset.wiretap, /obj/item/device/radio_upgrade/gang))
					has_gang_headset = TRUE

		if(!has_gang_uniform)
			var/obj/item/clothing/uniform = new src.gang.uniform(user.loc)
			// Effectively a copy of the `autoequip_slot` macro in `code\datums\hud\human.dm`.
			if (user.can_equip(uniform, user.slot_w_uniform))
				var/obj/item/current_uniform = user.w_uniform
				if (current_uniform)
					current_uniform.unequipped(user)
					user.hud.remove_item(current_uniform)
					user.w_uniform = null
					user.drop_from_slot(current_uniform, get_turf(current_uniform))
				user.force_equip(uniform, user.slot_w_uniform)

		if(!has_gang_headwear)
			var/obj/item/clothing/headwear = new src.gang.headwear(user.loc)
			if (istype(headwear, /obj/item/clothing/head))
				user.drop_from_slot(user.head)
				user.equip_if_possible(headwear, user.slot_head)
			else if (istype(headwear, /obj/item/clothing/mask))
				user.drop_from_slot(user.wear_mask)
				user.equip_if_possible(headwear, user.slot_wear_mask)

		if(!has_gang_headset)
			var/obj/item/device/radio/headset/headset
			if (istype(user.ears, /obj/item/device/radio/headset))
				headset = user.ears
			else
				headset = new /obj/item/device/radio/headset(user)
				if (!user.r_store)
					user.equip_if_possible(headset, user.slot_r_store)
				else if (!user.l_store)
					user.equip_if_possible(headset, user.slot_l_store)
				else if (istype(user.back, /obj/item/storage/) && length(user.back.contents) < 7)
					user.equip_if_possible(headset, user.slot_in_backpack)
				else
					user.put_in_hand_or_drop(headset)

			if (headset.wiretap)
				headset.remove_radio_upgrade()
			headset.install_radio_upgrade(new /obj/item/device/radio_upgrade/gang(frequency = src.gang.gang_frequency))

		if(!has_spray_paint)
			user.put_in_hand_or_drop(new /obj/item/spray_paint(user.loc))

		if(user.mind.special_role == ROLE_GANG_LEADER)
			var/obj/item/storage/box/gang_flyers/case = new /obj/item/storage/box/gang_flyers(user.loc)
			case.name = "[src.gang.gang_name] recruitment material"
			case.desc = "A briefcase full of flyers advertising the [src.gang.gang_name] gang."
			case.gang = src.gang
			user.put_in_hand_or_drop(case)

		src.gang.gear_cooldown += user
		SPAWN(300 SECONDS)
			if(user.mind != null && src.gang != null)
				src.gang.gear_cooldown -= user

		return 2

	update_icon()

		src.UpdateOverlays(default_screen_overlay, "screen")

		if(gang.can_be_joined())
			src.UpdateOverlays(image('icons/obj/large_storage.dmi', "greenlight"), "light")
		else
			src.UpdateOverlays(image('icons/obj/large_storage.dmi', "redlight"), "light")


	proc/respawn_member(var/mob/H)
		if (H.mind && H.get_gang() != src.gang)
			return
		var/mob/living/carbon/human/clone = new /mob/living/carbon/human/clone(src.loc)
		clone.bioHolder.CopyOther(H.bioHolder, copyActiveEffects = TRUE)
		clone.set_mutantrace(H.bioHolder?.mobAppearance?.mutant_race?.type)
		clone.update_colorful_parts()
		if (H.abilityHolder)
			clone.abilityHolder = H.abilityHolder.deepCopy()
			clone.abilityHolder.transferOwnership(clone)
			clone.abilityHolder.remove_unlocks()
		if(!isnull(H.traitHolder))
			H.traitHolder.copy_to(clone.traitHolder)
		clone.real_name = H.real_name
		clone.UpdateName()

		if(clone.client)
			clone.client.set_layout(clone.client.tg_layout)

		if(H.mind)
			H.mind.transfer_to(clone)
		get_gang_gear(clone)

	proc/insert_item(var/obj/item/item,var/mob/user)
		if(!user)
			return 0
		if (user.get_gang() != src.gang)
			boutput(user, "<span class='alert'>You are not a member of this gang, you cannot add items to it.</span>")
			return 0

		//cash score
		if (istype(item, /obj/item/spacecash))
			var/obj/item/spacecash/S = item
			if (S.amount > 10000)
				boutput(user, "<span class='alert'><b>You can't physically cram more than 10,000[CREDIT_SIGN] into the [src.name] at once!<b></span>")
				return 0
			gang.score_cash += round(S.amount/CASH_DIVISOR)
			gang.add_points(round(S.amount/CASH_DIVISOR))

		//gun score
		else if (istype(item, /obj/item/gun))
			if(istype(item, /obj/item/gun/kinetic/foamdartgun) || istype(item, /obj/item/gun/kinetic/foamdartshotgun) || istype(item, /obj/item/gun/kinetic/foamdartrevolver))
				boutput(user, "<span class='alert'><b>You cant stash toy guns in the locker<b></span>")
				return 0
			// var/obj/item/gun/gun = item
			if (item.two_handed)
				gang.score_gun += round(500)
				gang.add_points(round(500),user.mind)
			else
				gang.score_gun += round(300)
				gang.add_points(round(300),user.mind)


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

	attackby(obj/item/W, mob/user)
		if (W.cant_drop)
			return

		//kidnapping event here
		//if they're the target
		var/datum/gang/user_gang = user.get_gang()
		if (istype(W, /obj/item/grab))
			if (user_gang != src.gang)
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

						user_gang.score_event += mode.kidnapping_score
						broadcast_to_all_gangs("[src.gang.gang_name] has successfully kidnapped [mode.kidnapping_target] and has been rewarded for their efforts.")

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
		user.visible_message("<span class='alert'>[user] ineffectually hits the [src] with [W]!</span>")

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

		var/datum/gang/target_gang = target.get_gang()
		if(target_gang == gang)
			boutput(target, "<span class='alert'>You're already in that gang!</span>")
			return

		if(target_gang && (target == target_gang.leader))
			boutput(target, "<span class='alert'>You can't join a gang, you run your own!</span>")
			return

		if(target_gang)
			boutput(target, "<span class='alert'>You're already in a gang, you can't switch sides!</span>")
			return

		if(target.mind.assigned_role in list("Security Officer", "Security Assistant", "Vice Officer","Part-time Vice Officer","Head of Security","Captain","Head of Personnel","Communications Officer", "Medical Director", "Chief Engineer", "Research Director", "Detective", "Nanotrasen Security Consultant", "Nanotrasen Special Operative"))
			boutput(target, "<span class='alert'>You are too responsible to join a gang!</span>")
			return

		if(length(src.gang.members) >= src.gang.current_max_gang_members)
			boutput(target, "<span class='alert'>That gang is full!</span>")
			return

		var/joingang = tgui_alert(target, "Do you wish to join [src.gang.gang_name]?", "[src]", list("Yes", "No"), timeout = 10 SECONDS)
		if (joingang != "Yes")
			return

		target.mind?.add_subordinate_antagonist(ROLE_GANG_MEMBER, master = src.gang.leader)

		return


/obj/item/tool/janktanktwo
	name = "JankTank II"
	desc = "A secret cocktail of drugs & spices able to revive even the most horribly maimed gang member."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "dna_scrambler_2"
	amount = 1
	throwforce = 1
	force = 1
	w_class = W_CLASS_TINY
	var/gang_only= FALSE

	attack(mob/O, mob/user)
		if (istype(O, /mob/living/carbon/human))
			if (amount == 0)
				boutput(user, "<span class='alert'>The [src.name] is empty! </span>")
				return
			boutput(user, "<span class='alert'>attempt</span>")
			var/mob/living/carbon/human/H = O
			if (H.decomp_stage)
				boutput(user, "<span class='alert'>It's too late, they're rotten.</span>")
				return
			if (isdead(H)) //TODO: and H.Mind.Gang
				actions.start(new /datum/action/bar/icon/janktanktwo(user, H, src),user)


	proc/inject(mob/user, mob/O )
		if (istype(O, /mob/living/carbon/human))
			update_icon()
			var/mob/living/carbon/human/H = O
			var/obj/item/implant/imp= new/obj/item/implant/projectile/body_visible/janktanktwo(H)
			imp.implanted(H, user)
			qdel(src)

/obj/item/tool/quickhack
	name = "QuickHack"
	desc = "A highly illegal, disposable device can fake an AI's 'open' signal to a door a few times."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "hack"
	amount = 1
	throwforce = 1
	force = 1
	w_class = W_CLASS_TINY
	var/max_charges = 5
	var/charges = 5

	New()
		..()

	update_icon()
		var/perc
		if (src.max_charges >= src.charges > 0)
			perc = (src.charges / src.max_charges) * 100
		else
			perc = 0
		src.overlays = null
		switch(perc)
			if (-INFINITY to 0)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter0")
			if (1 to 24)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter1")
			if (25 to 49)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter2")
			if (50 to 74)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter3")
			if (75 to 99)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter4")
			if (100 to INFINITY)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter5")
		signal_event("icon_updated")

	afterattack(obj/O, mob/user)
		if (istype(O, /obj/machinery/door/airlock))
			if (charges == 0)
				boutput(user, "<span class='alert'>The [src.name] doesn't react. Must be out of charges.</span>")
				return
			var/obj/machinery/door/airlock/AL = O
			if (!AL.hardened && !AL.cant_emag)
				actions.start(new /datum/action/bar/icon/doorhack(user, AL, src),user)

	proc/force_open(mob/user, obj/machinery/door/airlock/A)
		if (A.canAIControl())
			if (A.open())
				src.charges--
				boutput(user, "<span class='alert'>The [src.name] beeps!</span>")
			else
				boutput(user, "<span class='alert'>The [src.name] buzzes. Maybe something's wrong with the door?</span>")
		else
			boutput(user, "<span class='alert'>The [src.name] fizzles and hisses angrily!</span>")
		update_icon()

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
/datum/gang_item/consumable
	class1 = "Consumable"

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
	item_path = /obj/item/switchblade
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

////////////////////////////////////////////////////////
/////////////CONSUMABLES////////////////////////////
/////////////////////////////////////////////////////////
/datum/gang_item/consumable/medkit
	name = "First Aid Kit"
	desc = "A set of medicines for those expecting to be beaten up."
	class2 = "Healing"
	price = 500
	item_path = /obj/item/storage/firstaid/regular

/datum/gang_item/consumable/quickhack
	name = "Doorjack"
	desc = "A highly illegal tool able to doors 5 times."
	class2 = "Tools"
	price = 500
	item_path = /obj/item/tool/quickhack

/datum/gang_item/consumable/quickhack
	name = "Doorjack"
	desc = "A highly illegal tool able to break into doors 5 times."
	class2 = "Tools"
	price = 500
	item_path = /obj/item/tool/quickhack


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
#undef CASH_DIVISOR


// GANG TAGS

/obj/decal/gangtag
	name = "gang tag"
	desc = "A gang tag, sprayed with nigh-uncleanable heavy metals."
	density = 0
	anchored = 1
	layer = OBJ_LAYER
	icon = 'icons/obj/decals/graffiti.dmi'
	icon_state = "gangtag0"
	var/datum/gang/owners = null
	var/list/mobs[0]
	proc/delete_same_tags()
		for(var/obj/decal/gangtag/T in get_turf(src))
			if(T.owners == src.owners && T != src) qdel(T)

	proc/find_players()
		for(var/mob/M in view(GANG_TAG_INFLUENCE, src.loc))
			if(M.client)
				mobs[M] = 1
	proc/score_players()
		var/score = 0
		for(var/thing in mobs)
			score = score + GANG_TAG_POINTS_PER_VIEWER

		owners.score_turf += score
		owners.add_points(score)

		mobs = list()
		boutput(world, "Scored [score] points for [owners.gang_name]")


	New()
		..()
		START_TRACKING_CAT(TR_CAT_GANGTAGS)
		for(var/obj/decal/gangtag/T in get_turf(src))
			T.layer = 3

		src.layer = 4
	Del()
		STOP_TRACKING_CAT(TR_CAT_GANGTAGS)
		..()
	setup()
		..()
		for(var/obj/decal/gangtag/T in get_turf(src))
			T.layer = 3
		src.layer = 4



	disposing(var/uncapture = 1)
		var/area/tagarea = get_area(src)
		if(tagarea.gang_owners == src.owners && uncapture)
			tagarea.gang_owners = null
			var/turf/T = get_turf(src)
			T.tagged = 0
		..()
