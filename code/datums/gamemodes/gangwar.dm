/datum/game_mode/gang
	name = "Gang War (Beta)"
	config_tag = "gang"
	regular = FALSE

	/// Makes it so gang members are chosen randomly at roundstart instead of being recruited.
	var/random_gangs = TRUE

	antag_token_support = TRUE
	var/list/gangs = list()

	var/const/setup_min_teams = 2
	var/const/setup_max_teams = 6
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/potential_hot_zones = null
	var/area/hot_zone
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

#ifdef RP_MODE
#define PLAYERS_PER_GANG_GENERATED 15
#else
#define PLAYERS_PER_GANG_GENERATED 9
#endif
	var/num_teams = clamp(round((num_players) / PLAYERS_PER_GANG_GENERATED), setup_min_teams, setup_max_teams) //1 gang per 9 players, 15 on RP
#undef PLAYERS_PER_GANG_GENERATED

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
		leaders_possible.Remove(leader)
		leader.special_role = ROLE_GANG_LEADER

	if(length(get_possible_enemies(ROLE_GANG_MEMBER, round(num_teams * GANG_MAX_MEMBERS), force_fill = FALSE) - src.traitors) < round(num_teams * GANG_MAX_MEMBERS * 0.66)) //must have at least 2/3 full gangs or there's no point
		boutput(world, SPAN_ALERT("<b>ERROR: The readied players are not collectively gangster enough for the selected mode, aborting gangwars.</b>"))
		return 0

	return 1

/datum/game_mode/gang/post_setup()
	for(var/datum/mind/antag_mind in src.traitors)
		if(antag_mind.special_role == ROLE_GANG_LEADER)
			antag_mind.add_antagonist(ROLE_GANG_LEADER, silent=TRUE)

	if(src.random_gangs)
		fill_gangs()

	// we delay announcement to make sure everyone gets information about the other members
	for(var/datum/mind/antag_mind in src.traitors)
		antag_mind.get_antagonist(ROLE_GANG_LEADER)?.unsilence()
		antag_mind.get_antagonist(ROLE_GANG_MEMBER)?.unsilence()


	find_potential_hot_zones()

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

	return 1

/datum/game_mode/gang/proc/fill_gangs(list/datum/mind/candidates = null, max_member_count = INFINITY)
	var/num_teams = length(src.gangs)
	var/num_people_needed = 0
	if(num_teams == 0)
		logTheThing(LOG_DEBUG, null, "Gangs gamemode attempted to fill gangs, but there were no gangs to fill.")
		message_admins("It's gangs, but there are no gangs??")
		return
	for(var/datum/gang/gang in src.gangs)
		num_people_needed += min(gang.current_max_gang_members, max_member_count) - length(gang.members)
	if(isnull(candidates))
		candidates = get_possible_enemies(ROLE_GANG_MEMBER, num_people_needed, allow_carbon=TRUE, filter_proc=PROC_REF(can_join_gangs), force_fill = FALSE)
	var/num_people_available = min(num_people_needed, length(candidates))
	var/people_added_per_gang = round(num_people_available / num_teams)
	num_people_available = people_added_per_gang * num_teams
	shuffle_list(candidates)
	var/i = 1
	for(var/datum/gang/gang in src.gangs)
		for(var/j in 1 to people_added_per_gang)
			var/datum/mind/candidate = candidates[i++]
			candidate.add_subordinate_antagonist(ROLE_GANG_MEMBER, master = gang.leader, silent=TRUE)
			traitors |= candidate

/datum/game_mode/gang/proc/can_join_gangs(mob/M)
	var/datum/job/job = find_job_in_controller_by_string(M.mind.assigned_role)
	. = !job || job.can_join_gangs

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
#ifndef RP_MODE
		force_shuttle()
		return 1
#else
		return 0
#endif

	else return 0

/datum/game_mode/gang/process()
	..()
#ifndef RP_MODE
	if (ticker.round_elapsed_ticks >= 55 MINUTES && !shuttle_called)
		shuttle_called = TRUE
		force_shuttle()
#endif //RP_MODE
	slow_process ++
	if (slow_process < 5)
		return
	else
		slow_process = 0

	for(var/datum/gang/G as anything in gangs)
		if (G.leader) //leaders immune to debuffs
			var/mob/living/carbon/human/H = G.leader.current
			var/turf/sourceturf = get_turf(H)
			if ((G in sourceturf?.controlling_gangs) && G.gear_worn(H) == 2)
				H.setStatus("ganger", duration = INFINITE_STATUS)
			else
				H.delStatus("ganger")

		if (islist(G.members))
			for (var/datum/mind/M as anything in G.members)
				var/mob/living/carbon/human/H = M.current
				var/turf/sourceturf = get_turf(H)
				var/gearworn = G.gear_worn(H)

				if (G in sourceturf.controlling_gangs) //if we're in friendly territory (or contested territory)
					H.delStatus("ganger_debuff")
					if (gearworn == 2)  //gain a buff for wearing your gang outfit
						H.setStatus("ganger", duration = INFINITE_STATUS)
					else
						H.delStatus("ganger")

				else if (length(sourceturf.controlling_gangs)) //if we're in enemy territory (and not contested territory)
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
	var/list/areas = get_accessible_station_areas()
	for(var/k in areas)
		if(istype(areas[k], /area/station/security))
			continue
		potential_hot_zones += areas[k]
	return

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

	boutput(kidnapping_target, SPAN_ALERT("You get the feeling that [top_gang.gang_name] wants you dead! Run and hide or ask security for help!"))

	SPAWN(kidnapping_timer - 1 MINUTE)
		if(kidnapping_target != null) broadcast_to_all_gangs("[target_name] has still not been captured by [top_gang.gang_name] and they have 1 minute left!")
		sleep(1 MINUTE)
		//if they didn't kidnap em, then give points to other gangs depending on whether they are alive or not.
		if(!kidnap_success)
			//if the kidnapping target is null or dead, nobody gets points. (the target will be "gibbed" if successfully "kidnapped" and points awarded there)
			if (kidnapping_target && !isdead(kidnapping_target))
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

/// For a given tile, this contains the number of gang tags that see or influence this tile for a gang. Used to track overlays.
/datum/gangtileclaim
	var/datum/gang/gang
	var/sights //! whether this tile is *seen* by a nearby tag, generating points for it.
	var/claims //! whether this tile is claimed by a tag, meaning it is valid for expanding a gangs'territory
	var/image/image //! The overlay for this tile.
	New(gang, newImage, newSight, newClaim)
		image = newImage
		sights = newSight
		claims = newClaim
		..()

/datum/gang
	/// The maximum number of gang members per gang.
	var/static/current_max_gang_members = GANG_MAX_MEMBERS
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
	var/static/list/colors_left =  list("#88CCEE","#117733","#332288","#DDCC77","#CC6677","#AA4499") //(hopefully) colorblind friendly palette

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
	/// The amount of spray paint cans this gang may spawn.
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
	/// The street cred this gang has - used exclusively by the leader for purchasing gang members & revives
	var/street_cred = 0
	/// The number of tiles this gang controls.
	var/tiles_controlled = 0

#ifdef BONUS_POINTS
	street_cred = 99999
#endif
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
	var/static/list/first_names = strings("gangwar.txt", "part1")
	var/static/list/second_names = strings("gangwar.txt", "part2")

	/// Whether or not the leader of this gang has claimed a recruitment briefcase
	var/claimed_briefcase = FALSE

	/// Starting price of the janktank II (gang member revival syringe)
	var/current_revival_price = GANG_REVIVE_COST
	/// Price increase for every janktank II purchased
	var/revival_price_gain = GANG_REVIVE_COST_GAIN

	/// Price to hire a spectator gang member
	var/current_newmember_price = GANG_NEW_MEMBER_COST
	/// Price increase for each following hire, to discourage zergs
	var/newmember_price_gain = GANG_NEW_MEMBER_COST_GAIN

	/// Potential loot drop zones for this gang
	var/list/potential_drop_zones

	/// Strings used to build PDA messages sent to civilians.
	var/static/gangGreetings[] = list("yo", "hey","hiya","oi", "psst", "pssst" )
	var/static/gangIntermediates[] = list("don't ask how I got your number.","heads up.", "help us out.")
	var/static/gangEndings[] = list("best of luck.", "maybe help them, yeah?", "stay in line and you'll probably live.", "don't think of stealing it.")

	proc/living_member_count()
		var/result = 0
		for (var/datum/mind/member as anything in members)
			if (!isdead(member.current))
				result++
		return result

	proc/get_dead_memberlist()
		var/list/result = list()
		for (var/datum/mind/member as anything in members)
			if (isdead(member.current))
				result[(member.current?.real_name)] = member
		return result

	proc/unclaim_tiles(var/location,  claimRange, minimumRange)
		var/squared_claim = claimRange*claimRange
		var/squared_minimum = minimumRange*minimumRange
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		var/turf/sourceturf = get_turf(location)
		for (var/turf/turftile in range(claimRange,sourceturf))
			var/tileDistance = GET_SQUARED_EUCLIDEAN_DIST(turftile, sourceturf)
			if(tileDistance > squared_claim) continue

			if (!turftile.controlling_gangs)
				return
			if (!(src in turftile.controlling_gangs))
				return
			var/datum/gangtileclaim/tileClaim = turftile.controlling_gangs[src]
			tileClaim.claims -= 1
			if (tileDistance <= squared_minimum)
				tileClaim.sights -= 1

			if (tileClaim.sights == 0)
				if (tileClaim.claims > 0)
					imgroup.remove_image(tileClaim.image)
					qdel(tileClaim.image)
					tileClaim.image = image('icons/effects/gang_overlays.dmi', turftile, "owned")
					tileClaim.image.color = src.color
					imgroup.add_image(tileClaim.image)

				tileClaim.image.alpha = 80

			if (tileClaim.claims == 0)
				imgroup.remove_image(tileClaim.image)
				qdel(tileClaim.image)
				src.tiles_controlled -= 1
				turftile.controlling_gangs[src] = null

	/// Claim all tiles within claimRange, making all within minimumRange unclaimable.
	proc/claim_tiles(var/location, claimRange, minimumRange)
		var/squared_claim = claimRange*claimRange
		var/squared_minimum = minimumRange*minimumRange
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)

		var/turf/sourceturf = get_turf(location)
		if (!sourceturf.controlling_gangs)
			sourceturf.controlling_gangs = new/list()
		if (!sourceturf.controlling_gangs[src])
			var/image/img = image('icons/effects/gang_overlays.dmi', sourceturf, "owned")
			img.alpha = 230
			img.color = src.color
			src.tiles_controlled += 1
			sourceturf.controlling_gangs[src] = new/datum/gangtileclaim(src,img,1,1)
			imgroup.add_image(img)
		else
			var/datum/gangtileclaim/tileClaim = sourceturf.controlling_gangs[src]
			tileClaim.image.alpha = 230
			tileClaim.sights += 1
			tileClaim.claims += 1

		for (var/turf/turftile in orange(claimRange,sourceturf))
			var/distance = GET_SQUARED_EUCLIDEAN_DIST(turftile, sourceturf)
			if(distance > squared_claim) continue

			if (!turftile.controlling_gangs)
				turftile.controlling_gangs = new/list()
			if (!turftile.controlling_gangs[src] || turftile.controlling_gangs[src].claims == 0)
				var/image/img
				//give the tiles different effects based on their distance
				if(distance > squared_minimum)
					img = image('icons/effects/gang_overlays.dmi', turftile, "owned")
					turftile.controlling_gangs[src] = new/datum/gangtileclaim(src,img,0,1) //mark this tile as claimable
					img.alpha = 80
				else
					img = image('icons/effects/gang_overlays.dmi', turftile, "seen")
					turftile.controlling_gangs[src] = new/datum/gangtileclaim(src,img,1,1)	//mark this tile as unclaimable
					img.alpha = 170
				img.color = src.color
				src.tiles_controlled += 1
				imgroup.add_image(img)
			else
				var/datum/gangtileclaim/tileClaim = turftile.controlling_gangs[src]
				if(distance <= squared_minimum)
					if (tileClaim.sights == 0)
						imgroup.remove_image(tileClaim.image)
						qdel(tileClaim.image)
						tileClaim.image = image('icons/effects/gang_overlays.dmi', turftile, "seen")
						tileClaim.image.color = src.color
						imgroup.add_image(tileClaim.image)
					tileClaim.image.alpha = 170
					tileClaim.sights += 1
				tileClaim.claims += 1


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
		color = pick(colors_left)
		colors_left -= color
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

	proc/generate_random_name()
		if (prob(70))
			. = pick_string("gangwar.txt", "fullchosen")
		else
			. = "[pick(first_names)] [pick(second_names)]"

	proc/select_gang_name()
		var/temporary_name = generate_random_name()

		while(src.gang_name == "Gang Name")
			var/choice = "Accept"
			if(src.leader?.current)
				// if the leader is disconnected, this tgui_alert call will return null, breaking everything. Default to "Accept" and give them the random name
				choice = tgui_alert(src.leader?.current, "Name: [temporary_name].", "Approve Your Gang's Name", list("Accept", "Reselect", "Randomise")) || "Accept"
			switch(choice)
				if ("Accept")
					if (temporary_name in src.used_names)
						boutput(src.leader.current, SPAN_ALERT("Another gang has this name."))
						// to prevent the incredibly slim chance that a disconncted gang leader rolls the same name as an existing gang
						temporary_name = generate_random_name()
						continue

					src.gang_name = temporary_name
					src.used_names += temporary_name

					for(var/datum/mind/member in src.members + list(src.leader))
						boutput(member.current, SPAN_ALERT("<h4>Your gang name is [src.gang_name]!</h4>"))

				if ("Reselect")
					var/first_name = tgui_input_list(src.leader.current, "Select the first word in your gang's name:", "Gang Name Selection", first_names)
					var/second_name = tgui_input_list(src.leader.current, "Select the second word in your gang's name:", "Gang Name Selection", second_names)
					temporary_name = "[first_name] [second_name]"

				if ("Randomise")
					temporary_name = generate_random_name()


		// add the gang to their displayed name for antag and round end stuff. works hopefully??
		var/datum/antagonist/leader_antag = src.leader.get_antagonist(ROLE_GANG_LEADER)
		leader_antag.display_name = "[src.gang_name] [leader_antag.display_name]"

		for (var/datum/mind/ganger in src.members)
			var/datum/antagonist/antag = ganger.get_antagonist(ROLE_GANG_MEMBER)
			antag.display_name = "[src.gang_name] [antag.display_name]"

	proc/select_gang_uniform()
		// Jumpsuit Selection.
		var/temporary_jumpsuit = tgui_input_list(src.leader.current, "Select your gang's uniform slot item:", "Gang Uniform Selection", src.uniform_list)

		while (!src.uniform_list[temporary_jumpsuit])
			boutput(src.leader.current , SPAN_ALERT("That uniform has been claimed by another gang."))
			temporary_jumpsuit = tgui_input_list(src.leader.current, "Select your gang's uniform slot item:", "Gang Uniform Selection", src.uniform_list)

		src.uniform = src.uniform_list[temporary_jumpsuit]
		src.uniform_list -= temporary_jumpsuit

		// Mask/Headwear Selection.
		if(src.gang_name == "NICOLAS CAGE FAN CLUB")
			src.headwear = /obj/item/clothing/mask/niccage
		else
			var/temporary_headwear = tgui_input_list(src.leader.current, "Select your gang's mask or head slot item:", "Gang Uniform Selection", src.headwear_list)

			while(!src.headwear_list[temporary_headwear])
				boutput(src.leader.current , SPAN_ALERT("That mask or hat has been claimed by another gang."))
				temporary_headwear = tgui_input_list(src.leader.current, "Select your gang's mask or head slot item:", "Gang Uniform Selection", src.headwear_list)

			src.headwear = src.headwear_list[temporary_headwear]
			src.headwear_list -= temporary_headwear

	proc/broadcast_to_gang(var/message)
		var/datum/language/L = languages.language_cache["english"]
		var/list/messages = L.get_messages(message)

		src.announcer_radio.set_secure_frequency("g", src.gang_frequency)
		src.announcer_radio.talk_into(src.announcer_source, messages, "g", src.announcer_source.name, "english")

	proc/num_tiles_controlled()
		return src.tiles_controlled

	proc/gang_score()
		var/score = 0

		score += score_turf //x25
		score += score_cash
		score += score_gun
		score += score_drug
		score += score_event

		return round(score)

	/// Shows maptext to the gang, with formatting for score increases.
	proc/show_score_maptext(amount, turf/location)
		var/image/chat_maptext/chat_text = null
		chat_text = make_chat_maptext(location, "<span class='ol c pixel' style='color: #08be4e;'>+[amount]</span>", alpha = 180, time = 0.5 SECONDS)
		chat_text.show_to(src.leader.current.client)
		for (var/datum/mind/userMind as anything in src.members)
			var/client/userClient = userMind.current.client
			if (userClient?.preferences?.flying_chat_hidden)
				chat_text.show_to(userClient)
	/// add points to this gang, bonusMind optionally getting a bonus
	/// if location is defined, maptext will come from that location, for all members.
	proc/add_points(amount, mob/bonusMob = null, turf/location = null, showText = FALSE)
		street_cred += amount
		var/datum/mind/bonusMind = bonusMob?.mind
		if (leader)
			if (leader == bonusMind)
				leader.gang_points += round(amount * 1.25) //give a 25% reward for the one providing
			else
				leader.gang_points += amount
		for (var/datum/mind/M in members)
			if (M == bonusMind)
				M.gang_points += round(amount * 1.25)
			else
				M.gang_points += amount

		if (!showText)
			return
		if (location)
			show_score_maptext(amount, location)
		else if (bonusMob.client && !bonusMob.client.preferences?.flying_chat_hidden)
			var/image/chat_maptext/chat_text = null
			chat_text = make_chat_maptext(bonusMob, "<span class='ol c pixel' style='color: #08be4e;'>+[amount]</span>", alpha = 180, time = 1.5 SECONDS)
			if (chat_text)
				chat_text.show_to(bonusMob.client)

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
		src.claim_tiles(T, GANG_TAG_INFLUENCE, GANG_TAG_SIGHT_RANGE)
		var/area/area = T.loc
		T.tagged = TRUE
		area.gang_owners = src


	proc/make_item_lists()
		// Must be jumpsuit. `/obj/item/clothing/under`
		src.uniform_list = list(
		"owl suit" = /obj/item/clothing/under/gimmick/owl,
		"pinstripe suit" = /obj/item/clothing/under/suit/pinstripe,
		"purple suit" = /obj/item/clothing/under/suit/purple,
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
		"sailor uniform" = /obj/item/clothing/under/gimmick/sailor,
		"bowling suit" = /obj/item/clothing/under/gimmick/bowling,
		"tactical turtleneck" = /obj/item/clothing/under/misc/syndicate,
		"black lawyer's suit" = /obj/item/clothing/under/misc/lawyer/black,
		"red lawyer's suit" = /obj/item/clothing/under/misc/lawyer/red,
		"lawyer suit" = /obj/item/clothing/under/misc/lawyer,
		"blue tracksuit" = /obj/item/clothing/under/gimmick/chav,
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
		"black ten-gallon hat" = /obj/item/clothing/head/westhat/black,
		"red mushroom cap" = /obj/item/clothing/head/mushroomcap/red,
		"stag beetle helm" = /obj/item/clothing/head/stagbeetle,
		"rhino beetle helm" = /obj/item/clothing/head/rhinobeetle)

	/// spawn loot and message a specific mind about it
	proc/target_loot_spawn(var/datum/mind/civvie)
		var/message = lootbag_spawn()
		var/datum/signal/newsignal = get_free_signal()
		newsignal.source = src
		newsignal.data["command"] = "text_message"
		newsignal.data["sender_name"] = "Unknown Sender"
		newsignal.data["message"] = "[message]"
		newsignal.data["address_1"] = civvie.originalPDA.net_id
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(newsignal)

	/// pick a random civilian (non-gang, non-sec), ideally not picking any deferred_minds
	proc/get_random_civvie(var/list/deferred_minds)
		var/mindList[0]
		for (var/datum/mind/M as anything in ticker.minds)
			if (M.get_antagonist(ROLE_GANG_LEADER) || M.get_antagonist(ROLE_GANG_MEMBER) || !(M.originalPDA) || (M.assigned_role in security_jobs))
				continue
			if (!(M in deferred_minds))
				mindList.Add(M)
		if (length(mindList) == 0 && !deferred_minds) //no valid minds among ALL minds, it's likely we're testing/solo. so just pick anything.
			return pick(ticker.minds)
		else if (length(mindList) == 0) //we have no choice but to pick amongst the blacklist.
			return get_random_civvie()
		else
			return pick(mindList)

	/// collects and remembers all valid areas to spawn loot/crates
	proc/find_potential_drop_zones()
		potential_drop_zones = list()
		var/list/areas = get_accessible_station_areas()
		for(var/k in areas)
			if(istype(areas[k], /area/station/security))
				continue
			potential_drop_zones += areas[k]
		return

	/// hide a loot bag somewhere, return a probably-somewhat-believable PDA message explaining its' location
	proc/lootbag_spawn()
		if (!potential_drop_zones)
			find_potential_drop_zones()
		var/area/loot_zone = pick(potential_drop_zones)
		var/turfList[0]
		var/uncoveredTurfList[0]
		var/bushList[0]
		var/crateList[0]
		var/disposalList[0]
		var/tableList[0]

		var/message = pick(gangGreetings) +", [prob(20) ? pick(gangIntermediates) : null]"
		// Scan the entire loot zone for every valid place to hide
		for (var/turf/simulated/floor/T in loot_zone.contents)
			for (var/obj/O in T.contents)
				if (istype(O,/obj/shrub))
					bushList.Add(O)
				else if (istype(O,/obj/machinery/disposal))
					disposalList.Add(O)
				else if (istype(O,/obj/storage))
					var/obj/storage/crate = O
					if (!crate.secure && !crate.locked)
						crateList.Add(O)
				else if (istype(O,/obj/table))
					tableList.Add(O)

			if (!is_blocked_turf(T))
				if (T.intact)
					turfList.Add(T)
				else
					uncoveredTurfList.Add(T)

		if(length(bushList))
			var/obj/shrub/target = pick(bushList)
			target.override_default_behaviour = 1
			target.additional_items.Add(/obj/item/gang_loot/guns_and_gear)
			target.max_uses = 1
			target.spawn_chance = 75
			target.last_use = 0

			message += " we left some goods in a bush [pick("somewhere around", "inside", "somewhere inside")] \the [loot_zone]."

		else if(length(crateList) && prob(80))
			var/obj/storage/target = pick(crateList)
			target.contents.Add(new/obj/item/gang_loot/guns_and_gear(target.contents))
			message += " we left a bag in \the [target], [pick("somewhere around", "inside", "somewhere inside")] \the [loot_zone]. "

		else if(length(disposalList) && prob(85))
			var/obj/machinery/disposal/target = pick(disposalList)
			target.contents.Add(new/obj/item/gang_loot/guns_and_gear(target.contents))
			message += " we left a bag in \the [target], [pick("somewhere around", "inside", "somewhere inside")] \the [loot_zone]. "

		else if(length(tableList) && prob(65))
			var/turf/simulated/floor/target = pick(tableList)
			var/obj/item/gang_loot/loot = new/obj/item/gang_loot/guns_and_gear
			target.contents.Add(loot)
			loot.layer = OVERFLOOR
			message += " we hid a bag in \the [loot_zone], under a table. "
		else if(length(turfList))
			var/turf/simulated/floor/target = pick(turfList)
			var/obj/item/gang_loot/loot = new/obj/item/gang_loot/guns_and_gear
			target.contents.Add(loot)
			loot.hide(target.intact)
			message += " we had to hide a bag in \the [loot_zone], under the floor tiles. "
		else
			var/turf/simulated/floor/target = pick(uncoveredTurfList)
			var/obj/item/gang_loot/loot = new/obj/item/gang_loot/guns_and_gear
			target.contents.Add(loot)
			loot.hide(target.intact)
			message += " we had to hide a bag in \the [loot_zone]. "


		message += " there are folks aboard who will probably come looking. "

		if (prob(40))
			message += pick(gangEndings)

		return message


/obj/item/spray_paint
	name = "spraypaint can"
	desc = "A can of spray paint."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan"
	item_state = "spraycan"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	var/in_use = FALSE
	var/empty = FALSE

	/// Checks a tile has no nearby claims from other tags
	proc/check_tile_unclaimed(turf/target, mob/user)
		for (var/obj/decal/gangtag/tag in range(GANG_TAG_SIGHT_RANGE,target))
			if(!IN_EUCLIDEAN_RANGE(tag, target, GANG_TAG_SIGHT_RANGE)) continue
			if (tag.owners == user.get_gang())
				boutput(user, SPAN_ALERT("This is too close to an existing tag!"))
				return
		for (var/obj/ganglocker/locker in range(GANG_TAG_SIGHT_RANGE_LOCKER,target))
			if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_SIGHT_RANGE_LOCKER)) continue
			if (locker.gang == user.get_gang())
				boutput(user, SPAN_ALERT("This is too close to your locker!"))
				return

		var/obj/decal/gangtag/existingTag
		for (var/obj/decal/gangtag/turfTag in target.contents)
			if (turfTag.active)
				existingTag = turfTag

		var/validLocation = FALSE
		if (existingTag)
			if (existingTag.owners != user.get_gang())
				//if we're tagging over someone's tag, double our search radius
				//(this will find any tags whose influence intersects with the target tag's influence)
				for (var/obj/ganglocker/locker in range(GANG_TAG_INFLUENCE_LOCKER+GANG_TAG_INFLUENCE,target))
					if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_INFLUENCE_LOCKER+GANG_TAG_INFLUENCE)) continue
					if (locker.gang == user.get_gang())
						validLocation = TRUE
				for (var/obj/decal/gangtag/otherTag in range(GANG_TAG_INFLUENCE*2,target))
					if(!IN_EUCLIDEAN_RANGE(otherTag, target, GANG_TAG_INFLUENCE*2)) continue
					if (otherTag.owners && otherTag.owners == user.get_gang())
						validLocation = TRUE
			else
				boutput(user, SPAN_ALERT("You can't spray over your own tags!"))
				return
		else
			//we're tagging, check it's in our territory and not someone else's territory
			for (var/obj/decal/gangtag/tag in range(GANG_TAG_INFLUENCE,target))
				if(!IN_EUCLIDEAN_RANGE(tag, target, GANG_TAG_INFLUENCE)) continue
				if (tag.owners == user.get_gang())
					validLocation = TRUE
				else if (tag.owners)
					boutput(user, SPAN_ALERT("You can't spray in another gang's territory! Spray over their tag, instead!"))
					if (user.GetComponent(/datum/component/tracker_hud))
						return
					var/datum/game_mode/gang/mode = ticker.mode
					if (!istype(mode))
						return
					user.AddComponent(/datum/component/tracker_hud/gang, get_turf(tag))
					SPAWN(3 SECONDS)
						var/datum/component/tracker_hud/gang/component = user.GetComponent(/datum/component/tracker_hud/gang)
						component.RemoveComponent()
					return
			for (var/obj/ganglocker/locker in range(GANG_TAG_INFLUENCE_LOCKER,target))
				if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_INFLUENCE_LOCKER)) continue
				if (locker.gang == user.get_gang())
					validLocation = TRUE
				else
					boutput(user, SPAN_ALERT("There's better places to tag than near someone else's locker! "))
					return

		if(!validLocation)
			boutput(user, SPAN_ALERT("This is outside your gang's influence!"))
			return

		var/area/getarea = get_area(target)
		if(!getarea)
			boutput(user, SPAN_ALERT("You can't claim this place!"))
			return
		if(getarea.name == "Space")
			boutput(user, SPAN_ALERT("You can't claim space!"))
			return
		if(getarea.name == "Ocean")
			boutput(user, SPAN_ALERT("You can't claim the entire ocean!"))
			return
		if((getarea.teleport_blocked) || istype(getarea, /area/supply) || istype(getarea, /area/shuttle/))
			boutput(user, SPAN_ALERT("You can't claim this place!"))
			return
		if(!ishuman(user))
			boutput(user, SPAN_ALERT("You don't have the dexterity to spray paint a gang tag!"))

		return validLocation

	afterattack(target, mob/user)
		if(!istype(target,/turf) && !istype(target,/obj/decal/gangtag)) return

		if (!user)
			return
		if (empty)
			return
		if(in_use)
			boutput(user, SPAN_ALERT("You are already tagging an area!"))
			return

		var/turf/turftarget = get_turf(target)

		if(BOUNDS_DIST(src, target) > 0)
			return

		var/datum/gang/gang = user.get_gang()

		if(!gang)
			boutput(user, SPAN_ALERT("You aren't in a gang, why would you do that?"))
			return

		if (check_tile_unclaimed(turftarget, user))
			user.visible_message(SPAN_ALERT("[user] begins to paint a gang tag on the [turftarget.name]!"))
			actions.start(new/datum/action/bar/icon/spray_gang_tag(turftarget, src), user)

/datum/action/bar/icon/spray_gang_tag
	duration = 15 SECONDS
	interrupt_flags = INTERRUPT_STUNNED
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan"
	var/turf/target_turf
	var/area/target_area
	var/obj/item/spray_paint/S
	/// the mob spraying this tag
	var/mob/M
	/// the gang we're spraying for
	var/datum/gang/gang
	/// when our next spray sound can beplayed
	var/next_spray = 0 DECI SECONDS

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

		S.in_use = TRUE
		playsound(target_turf, 'sound/items/graffitishake.ogg', 50, FALSE)
		next_spray += rand(10,15) DECI SECONDS

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target_turf) > 0 || target_turf == null || !owner)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(!S.check_tile_unclaimed(target_turf, owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		if(src.time_spent() > next_spray)
			next_spray += rand(18,26) DECI SECONDS
			playsound(target_turf, 'sound/items/graffitispray3.ogg', 100, TRUE)

	onInterrupt(var/flag)
		boutput(owner, SPAN_ALERT("You were interrupted!"))
		if (S)
			S.in_use = FALSE
		..()

	onEnd()
		..()
		if(BOUNDS_DIST(owner, target_turf) > 0 || target_turf == null || !owner)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(!S.check_tile_unclaimed(target_turf, owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		S.in_use = FALSE
		target_area.being_captured = FALSE
		for (var/obj/decal/gangtag/otherTag in range(1,target_turf))
			otherTag.owners.unclaim_tiles(target_turf,GANG_TAG_INFLUENCE, GANG_TAG_SIGHT_RANGE)
			otherTag.disable()

		src.gang.make_tag(target_turf)
		S.empty = TRUE
		S.icon_state = "spraycan_crushed"
		var/mob/M = owner
		gang.add_points(round(100), M, showText = TRUE)
		boutput(M, SPAN_NOTICE("You have claimed this area for your gang and gained bonus points!"))

/obj/ganglocker
	desc = "Gang locker."
	name = "gang closet"
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "gang"
	density = FALSE
	anchored = ANCHORED
	/// gang that owns this locker
	var/datum/gang/gang = null
	/// the overlay this locker should show, after doing stuff like blinking red for errors
	var/image/default_screen_overlay = null
	var/HTML = null

	/// the overlay this locker should show, after doing stuff like blinking red for errors
	var/list/buyable_items = list()
	/// time that ghosts get to choose to be a gang member
	var/ghost_confirmation_delay  = 30 SECONDS
	/// the amount of money stored inside this locker for laundering
	var/stored_cash = 0
	/// are we hunting for new gang members right now?
	var/hunting_for_ghosts = FALSE
	var/given_flyers = FALSE
	/// how many ticks are left of super laundering (when you insert pre-laundered money)
	var/superlaunder_stacks = 0
	/// has some angel sold TTVs to this locker yet?
	var/has_sold_ttv = FALSE
	var/static/janktank_price = 300

	/// How long to wait before displaying maptext after recieving bulk items
	var/aggregate_item_score_time = 1 SECOND
	/// Do we have a queued maptext for showing bulk item scores?
	var/is_aggregating_item_scores = FALSE
	/// How many points have been scored in the aggregate_item_score_time window?
	var/aggregate_score_count = 0

	New()
		START_TRACKING
		..()
		default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
		src.UpdateOverlays(default_screen_overlay, "screen")
		buyable_items = list(
			new/datum/gang_item/consumable/medkit,
			new/datum/gang_item/consumable/quickhack,
			new/datum/gang_item/consumable/omnizine,
			new/datum/gang_item/consumable/tipoff,
			new/datum/gang_item/misc/ratstick,
			new/datum/gang_item/ninja/throwing_knife,
			new/datum/gang_item/ninja/shuriken,
			new/datum/gang_item/ninja/sneaking_suit,
			new/datum/gang_item/ninja/discount_katana,
			new/datum/gang_item/space/discount_csaber,
			new/datum/gang_item/street/cop_car,
			new/datum/gang_item/space/stims)

	disposing(var/uncapture = 1)
		STOP_TRACKING
		..()

	examine()
		. = ..()
		. += "The screen displays \"Total Score: [gang.gang_score()]\""

	attack_hand(var/mob/living/carbon/human/user)
		if(!isalive(user))
			boutput(user, SPAN_ALERT("Not when you're incapacitated."))
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
				<font size="3">You have [gang.street_cred] street cred!</font><br>
				<font size="3"><a href='byond://?src=\ref[src];respawn_new=1'>Recruit a new member:</a></font> [src.gang.current_newmember_price] cred<br>
				<font size="3"><a href='byond://?src=\ref[src];respawn_syringe=1'>Buy a revival stim:</a></font> [src.gang.current_revival_price] cred<br>
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

	/// deploys a spraypaint for the user, if possible
	proc/handle_get_spraypaint(var/mob/living/carbon/human/user)
		var/image/overlay = null
		if(user.get_gang() == src.gang)
			if (gang.spray_paint_remaining > 0)
				gang.spray_paint_remaining--
				user.put_in_hand_or_drop(new /obj/item/spray_paint(user.loc))
				boutput(user, SPAN_ALERT("You grab a bottle of spray paint from the locker."))
		else
			boutput(user, SPAN_ALERT("The locker's screen briefly displays the message \"Access Denied\"."))
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
		if (href_list["respawn_new"])
			handle_respawn_new(usr)
		if (href_list["respawn_syringe"])
			handle_respawn_syringe(usr)
		if (href_list["get_spray"])
			handle_get_spraypaint(usr)
		if (href_list["buy_item"])
			if (usr.get_gang() != src.gang)
				boutput(usr, SPAN_ALERT("You are not a member of this gang, you cannot purchase items from it."))
				return
			var/datum/gang_item/GI = locate(href_list["buy_item"])
			if (locate(GI) in buyable_items)
				if (GI.price <= usr.mind.gang_points)
					usr.mind.gang_points -= GI.price

					boutput(usr, SPAN_NOTICE("You purchase [GI.name] for [GI.price]. Remaining balance = [usr.mind.gang_points] points."))
					if (!GI.on_purchase(src, usr))
						new GI.item_path(src.loc)
					gang.items_purchased[GI.item_path]++
					updateDialog()
				else
					boutput(usr, SPAN_ALERT("Insufficient funds."))

	proc/increase_janktank_price()
		src.janktank_price = round(src.janktank_price * 1.1)

		for (var/datum/gang/gang in get_all_gangs())
			var/datum/gang_item/misc/janktank/JT = locate(/datum/gang_item/misc/janktank) in gang.locker.buyable_items
			JT.price = janktank_price

	/// Checks to see if the user can respawn a gang member at this locker
	proc/handle_respawn_new(var/mob/living/carbon/human/user)
		if (src.gang.leader != user.mind)
			boutput(user, "You're not this gang's leader!")
			return
		if (hunting_for_ghosts)
			boutput(user, "A new member is being recruited, wait a minute!")
			return

		if (gang.street_cred < gang.current_newmember_price)
			boutput(user, "You don't have enough cred for a new gang member!")
			return

		if (length(src.gang.members) >= GANG_MAX_MEMBERS)
			if (src.gang.living_member_count() >= GANG_MAX_MEMBERS)
				boutput(user, "You've got a full gang!")
				return
			else
				boutput(user, "You've got a full gang! Choose a dead member to hire over.")
				var/list/datum/mind/members = gang.get_dead_memberlist()
				var/datum/mind/chosenPlayer = input("Select a gang member to remove.", "Remove gang member") as null|anything in members
				if (!chosenPlayer)
					return
				else
					members[chosenPlayer].remove_antagonist(ROLE_GANG_MEMBER)

		try_gang_respawn(user)

	/// Respawns a mind as a new gang member
	proc/gang_respawn(var/datum/mind/target)
		var/mob/living/carbon/human/normal/P = new/mob/living/carbon/human/normal(src.loc)
		P.initializeBioholder(target.current?.client?.preferences?.gender) //try to preserve gender if we can
		SPAWN(0)
			P.JobEquipSpawned("Gang Respawn")
			target.transfer_to(P)
			target.add_subordinate_antagonist(ROLE_GANG_MEMBER, master = src.gang.leader)
			message_admins("[target.key] respawned as a gang member for [src.gang.gang_name].")
			log_respawn_event(target, "gang member respawn", src.gang.gang_name)
			boutput(P, SPAN_NOTICE("<b>You have been respawned as a gang member!</b>"))
			boutput(P, SPAN_ALERT("<b>You're allied with [src.gang.gang_name]! Work with your leader, [src.gang.leader.current.real_name], to become the baddest gang ever!</b>"))
			get_gang_gear(P)

	/// Tries to find a ghost to respawn
	proc/try_gang_respawn(var/mob/living/carbon/human/user)
		hunting_for_ghosts = TRUE
		gang.street_cred -= gang.current_newmember_price
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a gang member? Your name will be added to the list of eligible candidates.")
		text_messages.Add("You are eligible to be respawned as a gang member. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")
		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending gang member respawn offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)
		hunting_for_ghosts = FALSE

		if (length(src.gang.members) >= GANG_MAX_MEMBERS)
			logTheThing(LOG_ADMIN, null, "Couldn't set up gang member respawn ; gang full. Source: [user]")
			boutput(user, "Your gang is full, search for a new candidate cancelled.")
			return

		if (!islist(candidates) || !length(candidates))
			message_admins("Couldn't set up gang member respawn for [src.gang.gang_name]; no ghosts responded. Source: [user]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up gang member respawn ; no ghosts responded. Source: [user]")
			boutput(user, "We couldn't find any new recruits. Your street cred is refunded.")
			gang.street_cred += gang.current_newmember_price
			return

		var/datum/mind/lucky_dude = candidates[1]

		if (lucky_dude.current)
			gang_respawn(lucky_dude)
			gang.current_newmember_price += gang.newmember_price_gain
		else
			message_admins("Couldn't set up gang member respawn for [src.gang.gang_name]; [lucky_dude] had no current mob. Source: [user]")
			logTheThing(LOG_DEBUG, null, "Couldn't set up gang member respawn ; [lucky_dude] had no current mob. Source: [user]")

	/// Attempt to buy a janktank II
	proc/handle_respawn_syringe(var/mob/living/carbon/human/user)
		if (src.gang.leader != user.mind)
			boutput(user, "You're not this gang's leader!")
			return
		if (gang.street_cred < gang.current_revival_price)
			boutput(user, "You don't have enough cred for a revival syringe!")
			return
		gang.street_cred -= gang.current_revival_price

		new/obj/item/tool/janktanktwo(src.loc)
		gang.current_revival_price += gang.revival_price_gain

	/// Check that it's feasible to give a user gang equipment
	proc/handle_gang_gear(var/mob/living/carbon/human/user)
		var/image/overlay = null
		switch(src.get_gang_gear(user))
			if(0)
				boutput(user, "<b class='alert'>The locker's screen briefly displays the message \"Access Denied\".</b>")
				overlay = image('icons/obj/large_storage.dmi', "gang_overlay_red")
			if(1)
				boutput(user, "<b class='alert'>The locker's screen briefly displays the message \"Access Denied\".</b>")
				boutput(user, SPAN_ALERT("You may only receive one set of gang gear every five minutes."))
				overlay = image('icons/obj/large_storage.dmi', "gang_overlay_red")
			if(2)
				boutput(user, SPAN_SUCCESS("The locker's screen briefly displays the message \"Access Granted\". A set of gang equipment drops out of a slot."))
				overlay = image('icons/obj/large_storage.dmi', "gang_overlay_green")

		src.UpdateOverlays(overlay, "screen")
		SPAWN(1 SECOND)
			src.UpdateOverlays(default_screen_overlay, "screen")

	/// Handle spawning equipment for a gang member
	proc/get_gang_gear(var/mob/living/carbon/human/user)
		if (!istype(user))
			return 0

		if(!(user.mind in src.gang.members) && user.mind != src.gang.leader)
			return 0

		if (user in src.gang.gear_cooldown)
			return 1

		var/has_gang_uniform = FALSE
		var/has_gang_headwear = FALSE
		var/has_gang_headset = FALSE

		for(var/obj/item/I in user.contents)
			if(istype(I, src.gang.uniform))
				has_gang_uniform = TRUE
			else if(istype(I, src.gang.headwear))
				has_gang_headwear = TRUE
			else if(istype(I, /obj/item/device/radio/headset))
				var/obj/item/device/radio/headset/headset = I
				if (istype(headset.wiretap, /obj/item/device/radio_upgrade/gang))
					has_gang_headset = TRUE

		if(!has_gang_uniform)
			var/obj/item/clothing/uniform = new src.gang.uniform(user.loc)
			// Effectively a copy of the `autoequip_slot` macro in `code\datums\hud\human.dm`.
			if (user.can_equip(uniform, SLOT_W_UNIFORM))
				var/obj/item/current_uniform = user.w_uniform
				if (current_uniform)
					current_uniform.unequipped(user)
					user.hud.remove_item(current_uniform)
					user.w_uniform = null
					user.drop_from_slot(current_uniform, get_turf(current_uniform))
				user.force_equip(uniform, SLOT_W_UNIFORM)

		if(!has_gang_headwear)
			var/obj/item/clothing/headwear = new src.gang.headwear(user.loc)
			if (istype(headwear, /obj/item/clothing/head))
				user.drop_from_slot(user.head)
				user.equip_if_possible(headwear, SLOT_HEAD)
			else if (istype(headwear, /obj/item/clothing/mask))
				user.drop_from_slot(user.wear_mask)
				user.equip_if_possible(headwear, SLOT_WEAR_MASK)

		if(!has_gang_headset)
			var/obj/item/device/radio/headset/headset
			if (istype(user.ears, /obj/item/device/radio/headset))
				headset = user.ears
			else
				headset = new /obj/item/device/radio/headset(user)
				if (!user.r_store)
					user.equip_if_possible(headset, SLOT_R_STORE)
				else if (!user.l_store)
					user.equip_if_possible(headset, SLOT_L_STORE)
				else if (user.back?.storage && !user.back.storage.is_full())
					user.equip_if_possible(headset, SLOT_IN_BACKPACK)
				else
					user.put_in_hand_or_drop(headset)

			if (headset.wiretap)
				headset.remove_radio_upgrade()
			headset.install_radio_upgrade(new /obj/item/device/radio_upgrade/gang(frequency = src.gang.gang_frequency))

		if(user.mind.special_role == ROLE_GANG_LEADER && !src.gang.claimed_briefcase)
			var/datum/game_mode/gang/gamemode = ticker.mode
			src.gang.claimed_briefcase = TRUE
			if(gamemode.random_gangs)
				user.put_in_hand_or_drop(new /obj/item/storage/box/gang_flyers/random_gangs(user.loc, src.gang))
			else
				user.put_in_hand_or_drop(new /obj/item/storage/box/gang_flyers(user.loc, src.gang))

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

	/// Handles dropping laundering money if the locker takes damage.
	proc/take_damage(var/amount)
		// Alert the gang that owns the closet.
		if(src.stored_cash > 0)
			var/stolenCash = min(src.stored_cash, round(amount * rand(900, 1100)/10)) //if you're laundering money, you gotta watch your locker
			if (stolenCash == 0)
				return
			src.stored_cash -= stolenCash
			var/obj/item/currency/spacecash/cashObj = new/obj/item/currency/spacecash(src.loc,stolenCash)
			ThrowRandom(cashObj, 1, bonus_throwforce = -10)
			superlaunder_stacks = min(superlaunder_stacks, round(src.stored_cash/(GANG_LAUNDER_RATE*1.5)))
			if (!ON_COOLDOWN(src, "damage_warning", 60 SECONDS))
				src.gang.broadcast_to_gang("Your locker is under attack!")

	/// Add score to the next maptext that can be shown once per second.
	proc/aggregate_score(var/score)
		if (!is_aggregating_item_scores)
			is_aggregating_item_scores = TRUE
			SPAWN (aggregate_item_score_time)
				gang.show_score_maptext(aggregate_score_count, get_turf(src))
				aggregate_score_count = 0
				is_aggregating_item_scores = FALSE
		aggregate_score_count += score

	/// Handles an item being inserted into a gang locker
	proc/insert_item(var/obj/item/item,var/mob/user)
		if(!user)
			return 0
		if (user.get_gang() != src.gang)
			boutput(user, SPAN_ALERT("You are not a member of this gang, you cannot add items to it."))
			return 0

		//cash score
		if (istype(item, /obj/item/currency/spacecash))
			var/obj/item/currency/spacecash/S = item

			var/cash_to_take = max(0,min(GANG_LAUNDER_CAP-stored_cash, S.amount))

			if (S.hasStatus("freshly_laundered"))
				superlaunder_stacks += round(cash_to_take/(GANG_LAUNDER_RATE*1.5))

			if (cash_to_take == 0)
				boutput(user, SPAN_ALERT("<b>You've crammed the money laundering slot full! Let it launder some.<b>"))
				return
			if (stored_cash == 0)
				boutput(user, SPAN_ALERT("The [src] boots up and starts laundering the money. This will take some time, so defend it!"))
			if (cash_to_take < S.amount)
				stored_cash += cash_to_take
				S.amount -= cash_to_take
				boutput(user, SPAN_ALERT("<b>You load [cash_to_take][CREDIT_SIGN] into the [src.name], the laundering slot is full.<b>"))
				S.UpdateStackAppearance()
				return
			stored_cash += S.amount

		//gun score
		else if (istype(item, /obj/item/gun))
			if(istype(item, /obj/item/gun/kinetic/foamdartgun))
				boutput(user, SPAN_ALERT("<b>You cant stash toy guns in the locker</b>"))

				return
			// var/obj/item/gun/gun = item
			gang.score_gun += round(300)
			gang.add_points(round(300),user, showText = TRUE)

		else if (istype(item, /obj/item/device/transfer_valve))
			if (!has_sold_ttv) //double points for our saviors
				has_sold_ttv = TRUE
				boutput(user, SPAN_ALERT("<b>A sense of relief washes over your body. You've resisted the urge to explode everything.</b>"))
				gang.score_gun += round(600)
				gang.add_points(round(600),user, showText = TRUE)
			else
				gang.score_gun += round(300)
				gang.add_points(round(300),user, showText = TRUE)

		//drug score
		else if (item.reagents)
			var/temp_score_drug = get_I_score_drug(item)
			if(temp_score_drug == 0)
				return
			gang.add_points(temp_score_drug,user)
			aggregate_score(temp_score_drug)
			gang.score_drug += temp_score_drug

		user.u_equip(item)
		item.dropped(user)
		add_fingerprint(user)

		item.set_loc(src)

		return 1

	/// get the score of an item given the drugs inside
	proc/get_I_score_drug(var/obj/O)
		var/score = 0
		var/multiplier = clamp(ceil(10*(GANG_DRUG_SCORE_SOFTCAP - gang.score_drug) / GANG_DRUG_SCORE_SOFTCAP),1,10)
		score += O.reagents.get_reagent_amount("bathsalts")
		score += O.reagents.get_reagent_amount("jenkem")/2
		score += O.reagents.get_reagent_amount("morphine")
		score += O.reagents.get_reagent_amount("crank")*1.5
		score += O.reagents.get_reagent_amount("LSD")/2
		score += O.reagents.get_reagent_amount("lsd_bee")/3
		score += O.reagents.get_reagent_amount("space_drugs")/4
		score += O.reagents.get_reagent_amount("THC")/8
		score += O.reagents.get_reagent_amount("psilocybin")/2
		score += O.reagents.get_reagent_amount("krokodil")
		score += O.reagents.get_reagent_amount("catdrugs")
		score += O.reagents.get_reagent_amount("methamphetamine")*1.5 //meth
		if(istype(O, /obj/item/plant/herb/cannabis))
			score += 7
		score = score * multiplier
		return round(score)

	proc/cash_amount()
		var/number = 0

		for(var/obj/item/currency/spacecash/S in contents)
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
				boutput(user, SPAN_ALERT("You can't kidnap someone for a different gang!"))
				return
			if (istype(ticker.mode, /datum/game_mode/gang))	//gotta be gang mode to kidnap
				var/datum/game_mode/gang/mode = ticker.mode
				var/obj/item/grab/G = W
				if (G.affecting == mode.kidnapping_target)		//Can only shove the target in, nobody else. target must be not dead and must have a kill or pin grab on em.
					if (isdead(G.affecting))
						boutput(user, SPAN_ALERT("[G.affecting] is dead, you can't kidnap a dead person!"))
					else if (G.state < GRAB_AGGRESSIVE)
						boutput(user, SPAN_ALERT("You'll need a stronger grip to successfully kinapp this person!"))
					else
						user.visible_message(SPAN_NOTICE("[user] shoves [G.affecting] into [src]!"))
						G.affecting.set_loc(src)
						//assign poitns, gangs

						user_gang.score_event += mode.kidnapping_score
						broadcast_to_all_gangs("[src.gang.gang_name] has successfully kidnapped [mode.kidnapping_target] and has been rewarded for their efforts.")

						mode.kidnapping_target = null
						mode.kidnap_success = 1
						G.affecting.remove()
						qdel(G)
			return


		if (istype(W,/obj/item/plant/herb/cannabis) || istype(W,/obj/item/gun) || istype(W,/obj/item/currency/spacecash) || istype(W,/obj/item/device/transfer_valve))
			if (insert_item(W,user))
				user.visible_message(SPAN_NOTICE("[user] puts [W] into [src]!"))
			return

		//split this out because fire extinguishers should probably not just get stored
		if (W.reagents?.total_volume > 0)
			if (insert_item(W,user))
				user.visible_message(SPAN_NOTICE("[user] puts [W] into [src]!"))
				return

		if(istype(W,/obj/item/satchel))
			var/obj/item/satchel/S = W
			var/hadcannabis = 0

			for(var/obj/item/plant/herb/cannabis/C in S.contents)
				insert_item(C,user)
				S.UpdateIcon()
				S.tooltip_rebuild = 1
				hadcannabis = 1

			if(hadcannabis)
				boutput(user, SPAN_NOTICE("You empty the cannabis from [S] into the [src]."))
			else
				boutput(user, SPAN_NOTICE("[S] doesn't contain any cannabis."))
			return

		user.lastattacked = src
		switch(W.hit_type)
			if (DAMAGE_BURN)
				user.visible_message(SPAN_ALERT("[user] ineffectually hits the [src] with [W]!"))
			else
				if (src.stored_cash > 0) //if it isn't obvious hitting an empty locker does nothing
					attack_particle(user,src)
					hit_twitch(src)
					if (W.hitsound)
						playsound(src.loc, W.hitsound, 50, TRUE)
				take_damage(W.force)
				user.visible_message(SPAN_ALERT("<b>[user] hits the [src] with [W]!</b>"))


	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if(!istype(O, /obj/item/plant/herb/cannabis))
			boutput(user, SPAN_ALERT("[src] cannot hold that kind of item!"))
			return

		user.visible_message(SPAN_NOTICE("[user] begins quickly filling the [src]!"))
		var/staystill = user.loc
		for(var/obj/item/I in view(1,user))
			if (!istype(I, O)) continue
			if (I in user)
				continue
			if (!insert_item(I,user))
				break
			I.set_loc(src)
			sleep(0.2 SECONDS)
			if (user.loc != staystill) break

		boutput(user, SPAN_NOTICE("You finish filling the [src]!"))

/obj/item/gang_flyer
	desc = "A gang recruitment flyer."
	name = "gang recruitment flyer"
	icon = 'icons/obj/writing.dmi'
	icon_state = "paper_caution"
	w_class = W_CLASS_TINY
	var/datum/gang/gang = null

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (istype(target,/mob/living) && user.a_intent != INTENT_HARM)
			if(user != target)
				user.visible_message(SPAN_ALERT("<b>[user] shows [src] to [target]!</b>"))
			// induct_to_gang(target)		//this was sometimes kinda causing people to accidentally accept joining a gang.
			return
		else
			return ..()

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob)
		if (istype(A, /turf/simulated/wall) || istype(A, /turf/simulated/shuttle/wall) || istype(A, /turf/unsimulated/wall) || istype(A, /obj/window))
			user.visible_message("<b>[user]</b> attaches [src] to [A].","You attach [src] to [A].")
			user.u_equip(src)
			src.set_loc(A)
			src.anchored = ANCHORED
		else
			return ..()

	attack_hand(mob/user)
		if (src.anchored == UNANCHORED)
			return ..()

		var/turf/T = src.loc
		user.visible_message(SPAN_ALERT("<b>[user]</b> rips down [src] from [T]!"), SPAN_ALERT("You rip down [src] from [T]!"))
		src.anchored = UNANCHORED
		user.put_in_hand_or_drop(src)

	attack_self(mob/living/carbon/human/user as mob)
		induct_to_gang(user)

	proc/induct_to_gang(var/mob/living/carbon/human/target)
		var/datum/game_mode/gang/gamemode = ticker.mode
		if(gamemode.random_gangs)
			boutput(target, SPAN_ALERT("You can't join a gang, they're already preformed!"))
			return

		if(gang == null)
			boutput(target, SPAN_ALERT("The flyer doesn't specify which gang it's advertising!"))
			return

		if(!ishuman(target))
			boutput(target, SPAN_ALERT("Only humans can join a gang!"))
			return

		if(!isalive(target))
			boutput(target, SPAN_ALERT("Not when you're incapacitated."))
			return

		if (issmallanimal(target))
			var/mob/living/critter/small_animal/C = target
			if (C.ghost_spawned)
				boutput(target, SPAN_ALERT("Your spectral brain can't comprehend the concept of a gang!"))
				return

		var/datum/gang/target_gang = target.get_gang()
		if(target_gang == gang)
			boutput(target, SPAN_ALERT("You're already in that gang!"))
			return

		if(target_gang && (target == target_gang.leader))
			boutput(target, SPAN_ALERT("You can't join a gang, you run your own!"))
			return

		if(target_gang)
			boutput(target, SPAN_ALERT("You're already in a gang, you can't switch sides!"))
			return

		var/datum/job/job = find_job_in_controller_by_string(target.mind.assigned_role)
		if(job && !job.can_join_gangs)
			boutput(target, SPAN_ALERT("You are too responsible to join a gang!"))
			return

		if(length(src.gang.members) >= src.gang.current_max_gang_members)
			boutput(target, SPAN_ALERT("That gang is full!"))
			return

		var/joingang = tgui_alert(target, "Do you wish to join [src.gang.gang_name]?", "[src]", list("Yes", "No"), timeout = 10 SECONDS)
		if (joingang != "Yes")
			return

		target.mind?.add_subordinate_antagonist(ROLE_GANG_MEMBER, master = src.gang.leader)

		return


/obj/item/tool/janktanktwo
	name = "JankTank II"
	desc = "A secret cocktail of drugs & spices, reportedly able to bring corpses to life."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "dna_scrambler_2"
	throwforce = 1
	force = 1
	w_class = W_CLASS_TINY

	attack(mob/O, mob/user)
		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			if (!H.get_gang() && !H.ghost.get_gang())
				boutput(user, SPAN_ALERT("They aren't part of a gang! Janktank is <b><i>too cool</i></b> for them."))
				return
			if (H.decomp_stage)
				boutput(user, SPAN_ALERT("It's too late, they're rotten."))
				return
			if (isdead(H))
				actions.start(new /datum/action/bar/icon/janktanktwo(user, H, src),user)

	/// heals and revives a human to JANKTANK2_DESIRED_HEALTH_PCT percent
	proc/do_heal(mob/living/carbon/human/H)
		//heal basic damage
		H.take_oxygen_deprivation(-INFINITY)
		H.take_brain_damage(-H.get_brain_damage())
		var/desiredDamage = H.max_health * (1-JANKTANK2_DESIRED_HEALTH_PCT)
		var/damage = H.max_health - H.health
		var/multi = 0
		if (damage > 0)
			multi = max(0,1-(desiredDamage/damage)) //what to multiply all damage by to get to desired HP,
		H.blood_volume = max(min(H.blood_volume,550),480)
		H.HealDamage("All", H.get_brute_damage()*multi, H.get_burn_damage()*multi, H.get_toxin_damage()*multi)

		H.visible_message("<span class='alert'>[H] shudders to life!</span>")
		playsound(H.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 0)
		playsound(H.loc, 'sound/misc/meat_plop.ogg', 30, 0)
		H.reagents.reaction(get_turf(H.loc),TOUCH, H.reagents.total_volume)
		H.vomit()
		//un-kill organs
		for (var/organ_slot in H.organHolder.organ_list)
			var/obj/item/organ/O = H.organHolder.organ_list[organ_slot]
			if(istype(O))
				O.unbreakme()
		if (H.organHolder) //would be nice to make these heal to desired_health_pct but requires new organHolder functionality...
			H.organHolder.heal_organs(1000,1000,1000, list("brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail"))
		H.remove_ailments()

		setalive(H)
		SPAWN(0) //some part of the vomit proc makes these duplicate
			H.reagents.clear_reagents()
			H.reagents.add_reagent("atropine", 2.5) //don't slip straight back into crit
			H.reagents.add_reagent("synaptizine", 5)
			H.reagents.add_reagent("ephedrine", 5)
			H.reagents.add_reagent("salbutamol", 10) //don't die immediately in a vacuum
			H.reagents.add_reagent("space_drugs", 5) //heh
			H.make_jittery(200)
			H.delStatus("resting")
			H.hud.update_resting()
			H.delStatus("stunned")
			H.delStatus("weakened")
			H.force_laydown_standup()
			#ifdef USE_STAMINA_DISORIENT
			H.do_disorient(H.get_stamina()+75, disorient = 100, remove_stamina_below_zero = TRUE, target_type = DISORIENT_NONE)
			#endif

	/// Turns the in-hand item into an implant inside a gang member.
	proc/inject(mob/user, mob/M )
		if (istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/obj/item/implant/projectile/body_visible/janktanktwo/janktank = new(H)
			janktank.set_owner(src)
			user.drop_item(src)
			src.set_loc(janktank)

/obj/item/tool/quickhack
	name = "QuickHack"
	desc = "A highly illegal, disposable device that can fake an AI's 'open' signal to a door a few times."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "hack"
	throwforce = 1
	force = 1
	w_class = W_CLASS_TINY
	var/max_charges = 5
	var/charges = 5

	New()
		..()

	update_icon()
		var/state = ceil(src.charges / src.max_charges * 5)
		src.overlays = null
		switch(state)
			if (0)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter0")
			if (1)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter1")
			if (2)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter2")
			if (3)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter3")
			if (4)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter4")
			if (5 to INFINITY)
				src.overlays += image('icons/obj/items/items.dmi', "satcounter5")

	afterattack(obj/O, mob/user)
		if (istype(O, /obj/machinery/door/airlock))
			if (charges == 0)
				boutput(user, SPAN_ALERT("The [src.name] doesn't react. Must be out of charges."))
				return
			var/obj/machinery/door/airlock/AL = O
			if (!AL.hardened && !AL.cant_emag)
				actions.start(new /datum/action/bar/icon/doorhack(user, AL, src),user)

	proc/force_open(mob/user, obj/machinery/door/airlock/A)
		if (A.canAIControl())
			if (A.open())
				src.charges--
				boutput(user, SPAN_ALERT("The [src.name] beeps!"))
			else
				boutput(user, SPAN_ALERT("The [src.name] buzzes. Maybe something's wrong with the door?"))
		else
			boutput(user, SPAN_ALERT("The [src.name] fizzles and hisses angrily! The AI control wire is probably cut."))
		UpdateIcon()

/obj/item/storage/box/gang_flyers
	name = "gang recruitment flyer case"
	desc = "A briefcase full of flyers advertising a gang, and some other neat stuff."
	icon_state = "briefcase_black"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"

	spawn_contents = list(/obj/item/gang_flyer = 4, /obj/item/spray_paint = 2, /obj/item/tool/quickhack = 1)
	var/datum/gang/gang = null

	New(turf/newloc, datum/gang/gang)
		src.name = "[gang.gang_name] recruitment material"
		src.desc = "A briefcase full of flyers advertising the [gang.gang_name] gang."
		src.gang = gang
		..()

	random_gangs
		spawn_contents = list(/obj/item/spray_paint = 3, /obj/item/tool/quickhack = 2, /obj/item/switchblade = 1)

	make_my_stuff()
		..()

		for(var/obj/item/gang_flyer/flyer in src.storage.get_contents())
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

	/// custom functionality for this purchase - if this returns TRUE, do not spawn the item
	proc/on_purchase(var/obj/ganglocker/locker, var/mob/user )
		return FALSE
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
	desc = "A stylish, concealable knife with a button to release the blade."
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
	item_path = /obj/item/storage/pouch/shuriken

/datum/gang_item/ninja/throwing_knife
	name = "Throwing Knive"
	desc = "A knife made to be thrown."
	class2 = "weapon"
	price = 1000
	item_path = /obj/item/dagger/throwing_knife

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


// ---- CONSUMABLES

/datum/gang_item/consumable/medkit
	name = "First Aid Kit"
	desc = "A simple box of medicine for those expecting to be beaten up."
	class2 = "Healing"
	price = 700
	item_path = /obj/item/storage/firstaid/regular

/datum/gang_item/consumable/omnizine
	name = "Omnizine Injector"
	desc = "A single, convenient dose of omnizine."
	class2 = "Healing"
	price = 1200
	item_path = /obj/item/reagent_containers/emergency_injector/omnizine

/datum/gang_item/consumable/quickhack
	name = "Doorjack"
	desc = "A highly illegal tool able to fake up to 5 AI 'open' signals to unbolted doors."
	class2 = "Tools"
	price = 500
	item_path = /obj/item/tool/quickhack

/datum/gang_item/consumable/tipoff
	name = "Tip off"
	desc = "Schedule an early duffle bag drop. A random civilian will be informed of the drop location."
	class2 = "Tools"
	price = 3000
	item_path = null

	on_purchase(var/obj/ganglocker/locker, var/mob/user )
		var/datum/gang/ourGang = locker.gang
		var/datum/mind/target = ourGang.get_random_civvie()
		ourGang.target_loot_spawn(target)
		ourGang.broadcast_to_gang("An extra tip off has been purchased; "+ target.current.real_name + " recieved the location on their PDA.")
		return TRUE //don't spawn anything


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


// GANG TAGS

/obj/decal/gangtag
	name = "gang tag"
	desc = "A gang tag, sprayed with nigh-uncleanable heavy metals."
	density = FALSE
	anchored = TRUE
	layer = TAG_LAYER
	icon = 'icons/obj/decals/graffiti.dmi'
	icon_state = "gangtag0"
	var/datum/gang/owners = null
	var/list/mobs
	var/heat = 0 // a rough estimation of how regularly this tag has people near it
	var/image/heatTracker
	var/active = TRUE
	/// Deletes all duplicate tags (IE, from the same gang) on this tile
	proc/delete_same_tags()
		for(var/obj/decal/gangtag/T in get_turf(src))
			if(T.owners == src.owners && T != src) qdel(T)

	/// Makes this tag insert, so it no longer provides points.
	proc/disable()
		active = FALSE
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		imgroup.remove_image(heatTracker)
		src.heatTracker = null
		qdel(heatTracker)

	/// Look for & remember players in this gang's sight range
	proc/find_players()
		for(var/mob/M in range(GANG_TAG_SIGHT_RANGE, src.loc))
			if (IN_EUCLIDEAN_RANGE(src,M,GANG_TAG_SIGHT_RANGE))
				if(M.client && isalive(M))
					mobs[M] = TRUE //remember mob

	/// Adds heat to this tag based upon how many mobs it's remembered. Then forgets all mobs it's seen and cools down.
	proc/calculate_heat()
		heat += length(mobs)
		heat = round(heat * GANG_TAG_HEAT_DECAY_MUL, 0.01) //slowly decay heat
		mobs = list()
		return heat

	proc/apply_score(var/largestHeat)
		var/mappedHeat
		if (heat == 0 || largestHeat == 0)
			mappedHeat = 0
		else
			var/pct = heat/largestHeat
			var/calculatedHeat = log(10,10*pct)*5
			if (calculatedHeat < 0)
				mappedHeat = 0
			else
				mappedHeat = round(max(0,calculatedHeat))+1


		var/score = 0
		score = mappedHeat * GANG_TAG_POINTS_PER_HEAT
		owners.score_turf += score
		owners.add_points(score)
		owners.show_score_maptext(score, get_turf(src))
		heatTracker.icon_state = "gang_heat_[mappedHeat]"

	New()
		..()
		START_TRACKING
		for(var/obj/decal/gangtag/T in get_turf(src))
			T.layer = SUB_TAG_LAYER
		src.layer = TAG_LAYER
		src.mobs = new/list()
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		heatTracker = image('icons/effects/gang_tag.dmi', get_turf(src))
		heatTracker.icon_state = "gang_heat_0"
		heatTracker.layer = NOLIGHT_EFFECTS_LAYER_BASE
		imgroup.add_image(heatTracker)


	examine()
		. = ..()
		. += "The heat of this tag is: [heat]"


	disposing(var/uncapture = 1)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		imgroup.remove_image(heatTracker)
		STOP_TRACKING
		heatTracker = null
		owners = null
		mobs = null
		var/area/tagarea = get_area(src)
		if(tagarea.gang_owners == src.owners && uncapture)
			tagarea.gang_owners = null
			var/turf/T = get_turf(src)
			T.tagged = 0
		..()
