/datum/game_mode/spy_theft
	name = "spy_thief"
	config_tag = "spy_theft"

	//maybe not??
	//latejoin_antag_compatible = 1
	//latejoin_antag_roles = list("spy_thief")
	var/const/waittime_l = 600
	var/const/waittime_h = 1800

	var/const/bounty_refresh_interval = 25 MINUTES
	var/last_refresh_time = 0

	var/const/spies_possible = 7

	var/list/station_bounties = list() // on-station items that can have bounties placed on them, pair list
	var/list/big_station_bounties = list() // on-station machines/other big objects that can have bounties placed on them, pair list
	var/list/personal_bounties = list()  // things that belong to people like trinkets, pair list
	var/list/organ_bounties = list() // things that belong to people that are on the inside
	var/list/photo_bounties = list() // photos of people (Operates by text, because that's the only info that photos store)

	var/const/organ_bounty_amt = 4
	var/const/person_bounty_amt = 5
	var/const/photo_bounty_amt = 4
	var/const/station_bounty_amt = 4
	var/const/big_station_bounty_amt = 2

	var/list/possible_areas = list()
	var/list/active_bounties = list()

	var/list/uplinks = list()

/datum/bounty_item
	var/name = "bounty name (this is a BUG)" 	//when a bounty object is deleted, we will still need a ref to its name
	var/obj/item = 0							//ref to exact item
	var/path = 0								//req path of item
	var/claimed = 0								//claimed already?
	var/area/delivery_area = 0					//You need to stand here to deliver this
	var/photo_containing = 0 					//Name required in a photograph. alright look photographs work on the basis of matching strings. Photos don't store refs to the mob or whatever so this will have to do
	var/reveal_area = 0							//show area in pda
	var/job = "job name"					//Job of bounty item owner (if itemm has an owner). Used for personal/organ bounties

	var/organ = 0 								//silly organ flag that is only checked in one place

	var/datum/syndicate_buylist/reward = 0
	var/value_low = 0
	var/value_high = 10

	var/datum/game_mode/spy_theft/game_mode = 0

	var/reward_was_spawned = 0

	New(var/datum/game_mode/spy_theft/ST)
		game_mode = ST
		..()

	proc/estimate_target_difficulty(var/job)
	// Adjust reward based off target job to estimate risk level
		if (job == "Head of Security" || job == "Captain")
			return 3
		else if (job == "Medical Director" || job == "Head of Personnel" || job == "Chief Engineer" || job == "Research Director" || job == "Nanotrasen Special Operative" || job == "Security Officer" || job == "Detective")
			return 2
		else
			return 1

	//1 to 4
	proc/pick_reward_tier(var/val)
		switch(val)
			if(1)
				value_high = 4
				value_low = 0
			if (2)
				value_high = 6
				value_low = 3
			if (3)
				value_high = 8
				value_low = 5
			if (4)
				value_high = 99
				value_low = 7
		pick_a_reward()

	proc/pick_a_reward()
		//Spawn normal reward
		//using the same items that would be in a surplus crate. change later when i feel less lazy
		var/list/possible_items = list()
		for (var/datum/syndicate_buylist/S in syndi_buylist_cache)
			var/blocked = 0
			if (ticker?.mode && S.blockedmode && islist(S.blockedmode) && S.blockedmode.len)
				for (var/V in S.blockedmode)
					if (ispath(V) && istype(ticker.mode, V))
						blocked = 1
						break

			if (ticker?.mode && S.exclusivemode && islist(S.exclusivemode) && S.exclusivemode.len)
				for (var/V in S.exclusivemode)
					if (ispath(V) && !istype(ticker.mode, V)) // No meta by checking VR uplinks.
						blocked = 1
						break

			if (blocked == 0 && !S.not_in_crates && S.cost <= value_high && S.cost >= value_low)
				possible_items += S

		reward = pick(possible_items)


	proc/spawn_reward(var/mob/user,var/obj/item/hostpda)
		if (reward_was_spawned) return

		var/turf/pda_turf = get_turf(hostpda)
		playsound(pda_turf, "warp", 15, 1, 0.2, 1.2)
		animate_portal_tele(hostpda)

		if (user.mind)
			user.mind.purchased_traitor_items += reward

		if (reward.item)
			var/obj/item = new reward.item(pda_turf)
			user.show_text("Your PDA accepts the bounty and spits out [reward] in exchange.", "red")
			reward.run_on_spawn(item, user)
			user.put_in_hand_or_drop(item)
			//if (src.is_VR_uplink == 0)
			//	statlog_traitor_item(user, reward.name, reward.cost)
		if (reward.item2)
			new reward.item2(pda_turf)
		if (reward.item3)
			new reward.item3(pda_turf)

		for(var/obj/item/uplink/integrated/pda/spy/spy_uplink in game_mode.uplinks)
			LAGCHECK(LAG_LOW)
			spy_uplink.ui_update()

		reward_was_spawned = 1
		return 1



/datum/game_mode/spy_theft/announce()
	boutput(world, "<B>The current game mode is - Spy!</B>")
	boutput(world, "<B>There are spies planted on [station_or_ship()]. They plan to steal valuables and assasinate rival spies  - Do not let them succeed!</B>")

/datum/game_mode/spy_theft/pre_setup()
	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if(player.ready) num_players++

	var/randomizer = rand(0,6)
	var/num_spies = 2 //minimum

	if(traitor_scaling)
		num_spies = max(2, min(round((num_players + randomizer) / 6), spies_possible))

	var/list/possible_spies = get_possible_spies(num_spies)

	if (!possible_spies.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing("admin", tplayer.current, null, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	var/list/chosen_spy_thieves = antagWeighter.choose(pool = possible_spies, role = "spy_thief", amount = num_spies, recordChosen = 1)
	traitors |= chosen_spy_thieves
	for (var/datum/mind/spy in traitors)
		spy.special_role = "spy_thief"
		possible_spies.Remove(spy)

	return 1

/datum/game_mode/spy_theft/post_setup()
	var/objective_set_path = null
	for(var/datum/mind/spy in traitors)
		objective_set_path = null // Gotta reset this.

		objective_set_path = pick(typesof(/datum/objective_set/spy_theft))

		new objective_set_path(spy)
		SPAWN_DBG(1 SECOND) //dumb delay to avoid race condition where spy assignment bugs (can't find PDA)
			equip_spy_theft(spy.current)

		var/obj_count = 1
		for(var/datum/objective/objective in spy.objectives)
			boutput(spy.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++

		//spy_name_list += spy.current.real_name

	SPAWN_DBG(5 SECONDS) //Some possible bounty items (like organs) need some time to get set up properly and be assigned names
		build_bounty_list()

	SPAWN_DBG (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/spy_theft/proc/get_possible_spies(minimum_traitors=1)
	var/list/candidates = list()

	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (ishellbanned(player)) continue //No treason for you
		if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
			if(player.client.preferences.be_spy)
				candidates += player.mind

	if(candidates.len < minimum_traitors)
		logTheThing("debug", null, null, "<b>Enemy Assignment</b>: Only [candidates.len] players with be_spy set to yes were ready. We need [minimum_traitors] traitors so including players who don't want to be traitors in the pool.")
		for(var/client/C)
			var/mob/new_player/player = C.mob
			if (!istype(player)) continue

			if (ishellbanned(player)) continue //No treason for you
			if ((player.ready) && !(player.mind in traitors) && !(player.mind in token_players) && !candidates.Find(player.mind))
				candidates += player.mind

				if ((minimum_traitors > 1) && (candidates.len >= minimum_traitors))
					break

	if(candidates.len < 1)
		return list()
	else
		return candidates

/datum/game_mode/spy_theft/process()
	..()
	if (ticker.round_elapsed_ticks - last_refresh_time >= bounty_refresh_interval)
		src.build_bounty_list()
		src.update_bounty_readouts()

/datum/game_mode/spy_theft/send_intercept()
	var/intercepttext = "Cent. Com. Update Requested status information:<BR>"
	intercepttext += " Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "changeling")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(traitors))

	for_by_tcl(C, /obj/machinery/communications_dish)
		C.add_centcom_report("Cent. Com. Status Summary", intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")


/datum/game_mode/spy_theft/declare_completion()
	. = ..()

/datum/game_mode/spy_theft/proc/update_bounty_readouts()
	for(var/obj/item/uplink/integrated/pda/spy/spy_uplink in uplinks)
		LAGCHECK(LAG_LOW)
		spy_uplink.ui_update()

	for(var/datum/mind/M in ticker.mode.traitors) //We loop through ticker.mode.traitors and do spy checks here because the mode might not actually be spy thief. And this instance of the datum may be held by the TRUE MODE
		LAGCHECK(LAG_LOW)
		if (M.special_role == "spy_thief")
			boutput(M.current, "<span class='notice'><b>Spy Console</b> has been updated with new requests.</span>") //MAGIC SPY SENSE (I feel this is justified, spies NEED to know this)
			M.current << sound('sound/machines/twobeep.ogg')

/datum/game_mode/spy_theft/proc/get_mob_list()
	var/list/mobs = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		mobs += player
	return mobs

/datum/game_mode/spy_theft/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/client/C)
		var/mob/living/player = C.mob
		if (!istype(player)) continue

		if (player.real_name != excluded_name)
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)


/datum/game_mode/spy_theft/proc/build_bounty_list()
	src.last_refresh_time = ticker.round_elapsed_ticks

	//clear and reset these lists. Some of these items may have gone missing, new crewmembers may have arrived.
	personal_bounties.len = 0
	organ_bounties.len = 0
	photo_bounties.len = 0

	for(var/mob/living/carbon/human/H in mobs)
		LAGCHECK(LAG_LOW)

		if (isvirtual(H) || istype(get_area(H),/area/afterlife))
			continue

		if (istype(H.loc, /obj/cryotron_spawner))
			continue

		var/turf/T = get_turf(H)
		if (!T || T.z != 1) //Nobody in the adventure zones, thanks.
			continue

	//personal bounties (items that belong to a person)
	//pair list, stores job for difficulty lookup
		if (H.trinket && istype(H.trinket))
			personal_bounties += list(list(H.trinket, H.job))
		if (H.wear_id)
			personal_bounties += list(list(H.wear_id, H.job))

	//organ bounties (limbs only)
		if (H.client && H.organs.len)
			if (H.organs["l_arm"])
				organ_bounties += list(list(H.organs["l_arm"], H.job))
			if (H.organs["r_arm"])
				organ_bounties += list(list(H.organs["r_arm"], H.job))
			if (H.organs["l_leg"])
				organ_bounties += list(list(H.organs["l_leg"], H.job))
			if (H.organs["r_leg"])
				organ_bounties += list(list(H.organs["r_leg"], H.job))


	//Add photographs of the crew
		photo_bounties += H.real_name


	//fugginhuge list of station item bounties (misc. things on the station that would be fun to steal)
	//Only need to set the list of station bounties once, since it's just a list of paths
	if (!station_bounties.len)
		station_bounties += list(list(/obj/item/ghostboard, 1))
		station_bounties += list(list(/obj/item/gnomechompski, 1))
		station_bounties += list(list(/obj/item/diary, 1))
		station_bounties += list(list(/obj/item/football, 1))
		station_bounties += list(list(/obj/item/basketball, 1))
		station_bounties += list(list(/obj/item/clothing/head/cakehat, 1))
		station_bounties += list(list(/obj/item/gun/russianrevolver, 1))
		station_bounties += list(list(/obj/item/instrument, 1))
		station_bounties += list(list(/obj/item/clothing/suit/johnny_coat, 1))
		station_bounties += list(list(/obj/item/clothing/shoes/flippers, 1))
		station_bounties += list(list(/obj/item/clothing/head/apprentice, 1))
		station_bounties += list(list(/obj/item/clothing/head/helmet/space/santahat, 1))
		station_bounties += list(list(/obj/item/clothing/head/beret/prisoner, 2))
		station_bounties += list(list(/obj/item/clothing/head/merchant_hat, 1))
		station_bounties += list(list(/obj/item/clothing/head/caphat, 2))
		station_bounties += list(list(/obj/item/clothing/head/helmet/HoS, 3))

		station_bounties += list(list(/obj/item/pinpointer/disk, 3))
		station_bounties += list(list(/obj/item/disk/data/floppy/read_only/authentication, 3))
		station_bounties += list(list(/obj/item/disk/data/floppy/read_only/communications, 2))
		station_bounties += list(list(/obj/item/aiModule/freeform, 3))
		station_bounties += list(list(/obj/item/aiModule/reset, 3))
		station_bounties += list(list(/obj/item/cell, 1))
		station_bounties += list(list(/obj/item/device/multitool, 1))

		station_bounties += list(list(/obj/item/mop, 1))
		station_bounties += list(list(/obj/item/spraybottle, 1))

		station_bounties += list(list(/obj/item/clothing/shoes/galoshes, 1))
		station_bounties += list(list(/obj/item/clothing/shoes/magnetic, 1))
		station_bounties += list(list(/obj/item/clothing/under/misc/clown, 1))
		station_bounties += list(list(/obj/item/clothing/shoes/clown_shoes, 1))
		station_bounties += list(list(/obj/item/clothing/glasses, 1))
		station_bounties += list(list(/obj/item/clothing/suit/armor/vest, 2))
		station_bounties += list(list(/obj/item/clothing/suit/bio_suit, 1))
		station_bounties += list(list(/obj/item/clothing/suit/space, 1))

		station_bounties += list(list(/obj/item/robodefibrillator, 1))
		station_bounties += list(list(/obj/item/remote/porter/port_a_medbay, 1))
		station_bounties += list(list(/obj/item/staple_gun, 1))
		station_bounties += list(list(/obj/item/storage/firstaid, 1))
		station_bounties += list(list(/obj/item/gun/kinetic/dart_rifle, 3))
		station_bounties += list(list(/obj/item/circular_saw, 1))
		station_bounties += list(list(/obj/item/paper/book/medical_guide, 1))

		station_bounties += list(list(/obj/item/gun/energy/egun, 3))
		station_bounties += list(list(/obj/item/hand_tele, 3))
		station_bounties += list(list(/obj/item/card/id/captains_spare, 3))
		station_bounties += list(list(/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff, 2))
		station_bounties += list(list(/obj/item/reagent_containers/food/drinks/bottle/champagne, 2))
		station_bounties += list(list(/obj/item/captaingun, 3))
		station_bounties += list(list(/obj/item/gun/kinetic/detectiverevolver, 3))
		station_bounties += list(list(/obj/item/gun/kinetic/riot40mm, 2))

		station_bounties += list(list(/obj/item/baton, 2))
		station_bounties += list(list(/obj/item/gun/energy/taser_gun, 2))
		station_bounties += list(list(/obj/item/tank/jetpack, 1))

		station_bounties += list(list(/obj/item/clothing/gloves/yellow, 1))

		station_bounties += list(list(/obj/item/kitchen/utensil, 1))
		station_bounties += list(list(/obj/item/kitchen/rollingpin, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/cereal_box, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/beefood, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/spaghetti, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/pizza, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/taco, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/cake, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/pancake, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/ingredient/cheese, 1))
		station_bounties += list(list(/obj/item/reagent_containers/glass/bottle/bubblebath, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/snacks/ingredient/meat, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food, 1))

		station_bounties += list(list(/obj/item/reagent_containers/glass/wateringcan, 1))
		station_bounties += list(list(/obj/item/reagent_containers/food/drinks/rum_spaced, 2))
		station_bounties += list(list(/obj/item/reagent_containers/food/drinks/bottle/vintage, 1))

		station_bounties += list(list(/obj/item/storage/belt/medical, 1))
		station_bounties += list(list(/obj/item/storage/belt/utility, 1))
		station_bounties += list(list(/obj/item/storage/belt/security, 2))
		station_bounties += list(list(/obj/item/storage/firstaid/docbag, 1))
		station_bounties += list(list(/obj/item/storage/backpack, 1))

		station_bounties += list(list(/obj/item/device/radio/headset/security, 2))
		station_bounties += list(list(/obj/item/device/radio/headset/command, 2))
		station_bounties += list(list(/obj/item/device/radio/headset/command/captain, 2))
		station_bounties += list(list(/obj/item/device/radio/headset/command/hop, 2))
		station_bounties += list(list(/obj/item/device/radio/headset/command/rd, 2))
		station_bounties += list(list(/obj/item/device/radio/headset/command/md, 2))
		station_bounties += list(list(/obj/item/device/radio/headset/command/ce, 2))

	if (!big_station_bounties.len)
		big_station_bounties += list(list(/obj/machinery/vehicle, 1))
		big_station_bounties += list(list(/obj/machinery/chem_dispenser, 2))
		big_station_bounties += list(list(/obj/machinery/computer/announcement, 2))
		big_station_bounties += list(list(/obj/machinery/computer/card, 2))
		big_station_bounties += list(list(/obj/machinery/computer/aiupload, 3))
		big_station_bounties += list(list(/obj/machinery/computer/genetics, 2))
		big_station_bounties += list(list(/obj/machinery/computer/supplycomp, 1))
		big_station_bounties += list(list(/obj/machinery/computer/robotics, 2))
		big_station_bounties += list(list(/obj/machinery/power/reactor_stats, 1))

		big_station_bounties += list(list(/obj/machinery/computer3/generic/communications, 1))
		big_station_bounties += list(list(/obj/machinery/computer3/terminal/zeta, 1))
		big_station_bounties += list(list(/obj/machinery/vending/security, 2))
		big_station_bounties += list(list(/obj/machinery/vending/medical, 1))
		big_station_bounties += list(list(/obj/machinery/vending/port_a_nanomed, 1))
		big_station_bounties += list(list(/obj/machinery/vending/fortune, 1))
		big_station_bounties += list(list(/obj/machinery/vending/standard, 1))

		big_station_bounties += list(list(/obj/machinery/port_a_brig, 3))
		big_station_bounties += list(list(/obj/machinery/flasher/portable, 2))
		big_station_bounties += list(list(/obj/machinery/sleeper/port_a_medbay, 1))
		big_station_bounties += list(list(/obj/machinery/atmospherics/unary/cryo_cell, 2))
		big_station_bounties += list(list(/obj/machinery/computer/cloning, 2))
		big_station_bounties += list(list(/obj/machinery/clonepod, 2))
		big_station_bounties += list(list(/obj/machinery/clonegrinder, 1))
		big_station_bounties += list(list(/obj/machinery/genetics_scanner, 2))
		//big_station_bounties += /obj/machinery/power/smes
		big_station_bounties += list(list(/obj/machinery/recharge_station, 1))
		big_station_bounties += list(list(/obj/machinery/optable, 2))
		big_station_bounties += list(list(/obj/storage/closet/port_a_sci, 2))

		big_station_bounties += list(list(/obj/machinery/manufacturer/robotics, 1))
		big_station_bounties += list(list(/obj/machinery/manufacturer/medical, 1))
		big_station_bounties += list(list(/obj/machinery/manufacturer/general, 1))
		big_station_bounties += list(list(/obj/machinery/manufacturer/general, 1))

		big_station_bounties += list(list(/obj/submachine/chef_oven, 1))
		big_station_bounties += list(list(/obj/machinery/gibber, 1))

		big_station_bounties += list(list(/obj/machinery/bot/guardbot, 1))
		big_station_bounties += list(list(/obj/machinery/artifact, 1))
		big_station_bounties += list(list(/obj/machinery/plantpot, 1))
		big_station_bounties += list(list(/obj/machinery/partyalarm, 1))
		big_station_bounties += list(list(/obj/pool_springboard, 1))
		//big_station_bounties += /obj/machinery/launcher_loader //lol //Didn't work - ZeWaka
		big_station_bounties += list(list(/obj/reagent_dispensers, 2))
		big_station_bounties += list(list(/obj/machinery/crusher, 2))
		big_station_bounties += list(list(/obj/machinery/communications_dish, 2))
		big_station_bounties += list(list(/obj/decal/poster/wallsign/poster_y4nt, 1))

	active_bounties.len = 0

	//Add organs
	var/list/O = organ_bounties.Copy()
	for(var/i=1, i<=organ_bounty_amt && O.len, i++)
		var/datum/bounty_item/B = new /datum/bounty_item(src)
		var/list/pair = pick(O)
		B.item = pair[1]
		B.job = pair[2]
		// B.path = B.item.type
		if(istype(B.item, /obj/item/parts))
			var/obj/item/parts/P = B.item
			if (!P || P.qdeled || !P.holder || P.holder.qdeled)
				// "this seems really stupid"
				// well, yes; the idea is that this grants a retry
				// (up to ~4 times) to pick a valid solution
				// is it dumb? hell yeah. do i care? naaaaah.
				i -= 0.75
				continue
			B.name = P.holder.real_name + "'s " + P.name
		B.reveal_area = 1
		B.organ = 1
		O -= B.item

		// Adjust reward based off target job to estimate risk level
		var/difficulty = B.estimate_target_difficulty(B.job)
		switch(difficulty)
			if(3)
				B.pick_reward_tier(4)
			if (2)
				B.pick_reward_tier(3)
			if (1)
				if (prob(7))
					B.pick_reward_tier(3)
				else
					B.pick_reward_tier(2)

		active_bounties += B

	//Add personal items
	var/list/P = personal_bounties.Copy()
	for(var/i=1, i<=person_bounty_amt && P.len, i++)
		var/datum/bounty_item/B = new /datum/bounty_item(src)
		var/list/pair = pick(P)
		B.item = pair[1]
		B.job = pair[2]
		B.name = B.item.name
		B.reveal_area = 1
		P -= pair

		// Adjust reward based off target job to estimate risk level
		var/difficulty = B.estimate_target_difficulty(B.job)
		switch(difficulty)
			if(3)
				B.pick_reward_tier(4)
			if (2)
				if (prob(10))
					B.pick_reward_tier(4)
				else
					B.pick_reward_tier(pick(2,3))
			if (1)
				if (prob(10))
					B.pick_reward_tier(4)
				else
					B.pick_reward_tier(pick(1,3))

		active_bounties += B

	//Add big station item bounties (copy paste. bad)
	var/list/BS = big_station_bounties.Copy()
	var/big_choice = null
	var/difficulty = 0
	var/obj/obj_existing = null
	for(var/i=1, i<=big_station_bounty_amt, i++)
		big_choice = null
		obj_existing = null

		//try to find an item that exists on the station zlevel
		for(var/q=1, q<= 50, q++) //just like try 50 times i guess lol
			LAGCHECK(LAG_LOW)
			var/list/pair = pick(BS)
			big_choice = pair[1]
			difficulty = pair[2]
			obj_existing = locate(big_choice)
			if (obj_existing?.z == 1)
				break
			else
				obj_existing = null

		if (obj_existing?.z == 1)
			var/datum/bounty_item/B = new /datum/bounty_item(src)
			B.path = obj_existing.type
			B.item = obj_existing
			B.name = obj_existing.name

			switch(difficulty)
				if(3)
					B.pick_reward_tier(pick(2,3))
				if (2)
					B.pick_reward_tier(pick(1,2))
				if (1)
					if (prob(15))
						B.pick_reward_tier(pick(1,2))
					else
						B.pick_reward_tier(1)

			active_bounties += B
			BS -= big_choice

	//Add photos
	var/list/PH = photo_bounties.Copy()
	for(var/i=1, i<=photo_bounty_amt && PH.len, i++)
		var/datum/bounty_item/B = new /datum/bounty_item(src)
		B.photo_containing = pick(PH)
		B.name = "a photograph of [B.photo_containing]"
		PH -= B.photo_containing

		B.pick_reward_tier(1)

		active_bounties += B


	//Add station item bounties
	var/list/S = station_bounties.Copy()
	var/choice = 0
	var/obj/item/item_existing = 0


	for(var/i=1, i<=station_bounty_amt, i++)
		choice = 0
		difficulty = 0
		item_existing = 0

		//try to find an item that exists on the station zlevel
		for(var/q=1, q<= 50, q++) //just like try 50 times i guess lol
			LAGCHECK(LAG_LOW)
			var/list/pair = pick(S)
			choice = pair[1]
			difficulty = pair[2]
			item_existing = locate(choice)
			var/turf/T = get_turf(item_existing)
			if (item_existing && T?.z == 1)
				break
			else
				item_existing = 0

		var/turf/T = get_turf(item_existing)
		if (item_existing && T.z == 1)
			var/datum/bounty_item/B = new /datum/bounty_item(src)
			B.path = choice
			B.item = item_existing
			B.name = item_existing.name

			switch(difficulty)
				if(3)
					B.pick_reward_tier(pick(2,3))
				if (2)
					B.pick_reward_tier(pick(1,2))
				if (1)
					if (prob(10))
						B.pick_reward_tier(pick(1,2))
					else
						B.pick_reward_tier(1)

			active_bounties += B
			S -= choice


	//Set delivery areas
	possible_areas = get_areas_with_unblocked_turfs(/area/station)
	possible_areas += get_areas_with_unblocked_turfs(/area/diner)
	possible_areas -= get_areas_with_unblocked_turfs(/area/diner/tug)
	possible_areas -= get_areas_with_unblocked_turfs(/area/station/maintenance)
	possible_areas -= get_areas_with_unblocked_turfs(/area/station/hallway)
	possible_areas -= get_areas_with_unblocked_turfs(/area/station/engine/substation)
	possible_areas -= /area/sim/test_area

	for (var/area/A in possible_areas)
		LAGCHECK(LAG_LOW)
		if (A.virtual)
			possible_areas -= A
			break
		if (A.name == "AI Perimeter Defenses" || A.name == "VR Test Area") //I have no idea what this "AI Perimeter Defenses" is, can't find it in code! All I know is that it's an area that the game can choose that DOESNT HAVE ANY TURFS
			possible_areas -= A
			break

	for (var/datum/bounty_item/B in active_bounties)
		if ((B.item && !istype(B.item,/obj/item)) || B.organ)
			B.delivery_area = 0
		else
			B.delivery_area = pick(possible_areas)

	return
