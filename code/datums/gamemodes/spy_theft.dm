#define BOUNTY_TYPE_ORGAN	1
#define BOUNTY_TYPE_TRINK	2
#define BOUNTY_TYPE_PHOTO	3
#define BOUNTY_TYPE_ITEM	4
#define BOUNTY_TYPE_BIG		5

/datum/game_mode/spy_theft
	name = "Spy Theft"
	config_tag = "spy_theft"

	antag_token_support = TRUE
	latejoin_antag_compatible = 1
	latejoin_antag_roles = list(ROLE_TRAITOR)
	var/const/waittime_l = 600	// Minimum after round start to send threat information to printer
	var/const/waittime_h = 1800	// Maximum after round start to send threat information to printer

#ifdef RP_MODE
	var/const/bounty_refresh_interval = 25 MINUTES
#else
	var/const/bounty_refresh_interval = 15 MINUTES
#endif
	var/last_refresh_time = 0

	var/const/spies_possible = 7

#ifdef RP_MODE
	var/const/pop_divisor = 10
#else
	var/const/pop_divisor = 6
#endif

	var/list/station_bounties = list()			// On-station items that can have bounties placed on them, pair list
	var/list/big_station_bounties = list()	// On-station machines/other big objects that can have bounties placed on them, pair list
	var/list/personal_bounties = list() 		// Things that belong to people like trinkets, pair list
	var/list/organ_bounties = list()				// Things that belong to people that are on the inside
	var/list/photo_bounties = list()				// Photos of people (Operates by text, because that's the only info that photos store)

	var/organ_bounty_amt = 4
	var/person_bounty_amt = 4
	var/photo_bounty_amt = 4
	var/station_bounty_amt = 5
	var/big_station_bounty_amt = 3

	var/list/possible_areas = list()
	var/list/active_bounties = list()

	var/list/uplinks = list()

/datum/bounty_item
	var/name = "bounty name (this is a BUG)" 	//When a bounty object is deleted, we will still need a ref to its name
	var/obj/item = null										//Ref to exact item
	var/path = null												//Req path of item
	var/claimed = null											//Claimed already?
	var/area/delivery_area = null					//You need to stand here to deliver this
	var/photo_containing = null 						//Name required in a photograph. alright look photographs work on the basis of matching strings. Photos don't store refs to the mob or whatever so this will have to do
	var/reveal_area = FALSE									//Show area of target in pda
	var/job = "job name"								//Job of bounty item owner (if item has an owner). Used for target difficulty on personal/organ bounties
	var/bounty_type = null 								//Type of objective, used to determine difficulty and organs 'Anywhere' delivery location
	var/difficulty = 0									//Stored difficulty for items and big items
	var/hot_bounty = FALSE									//This bounty randomly rolled a high tier reward

	var/datum/syndicate_buylist/reward = null
	var/value_low = 0
	var/value_high = 10

	var/datum/game_mode/spy_theft/game_mode = null

	var/reward_was_spawned = FALSE

	New(var/datum/game_mode/spy_theft/ST)
		game_mode = ST
		..()

	proc/estimate_target_difficulty(var/job)
	// Adjust reward based off target job to estimate risk level
		if (job == "Head of Security" || job == "Captain")
			return 3
		else if (job == "Medical Director" || job == "Head of Personnel" || job == "Chief Engineer" || job == "Research Director" || job == "Nanotrasen Security Consultant" || job == "Security Officer" || job == "Detective")
			return 2
		else
			return 1

	//Choose a reward from the four tiers
	proc/pick_reward_tier(var/val)
		switch(val)
			if (1)
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
		//Find a suitable reward
		var/list/possible_items = list()
		for (var/datum/syndicate_buylist/S in syndi_buylist_cache)
			if(!(S.can_buy & UPLINK_SPY_THIEF))
				continue

			if (S.cost <= value_high && S.cost >= value_low)
				possible_items[S] = S.surplus_weight

		reward = weighted_pick(possible_items)

	proc/spawn_reward(var/mob/user,var/obj/item/device/pda2/hostpda)
		if (reward_was_spawned) return

		var/turf/pda_turf = get_turf(hostpda)
		playsound(pda_turf, "warp", 15, 1, 0.2, 1.2)
		animate_portal_tele(hostpda)

		var/datum/antagonist/spy_thief/antag_role = user.mind?.get_antagonist(ROLE_SPY_THIEF)
		if (length(reward.items) > 0)
			for (var/reward_item in reward.items)
				var/obj/item = new reward_item(pda_turf)
				logTheThing(LOG_DEBUG, user, "spy thief reward spawned: [item] at [log_loc(user)]")
				user.show_text("Your PDA accepts the bounty and spits out [reward] in exchange.", "red")
				reward.run_on_spawn(item, user, FALSE, hostpda.uplink)
			if (!hostpda.uplink.purchase_log[reward.type])
				hostpda.uplink.purchase_log[reward.type] = 0
			hostpda.uplink.purchase_log[reward.type]++
			if (istype(antag_role))
				antag_role.redeemed_items.Add(reward)

		for(var/obj/item/uplink/integrated/pda/spy/spy_uplink in game_mode.uplinks)
			LAGCHECK(LAG_LOW)
			spy_uplink.ui_update()

		reward_was_spawned = 1
		return 1



/datum/game_mode/spy_theft/announce()
	boutput(world, "<B>The current game mode is - Spy!</B>")
	boutput(world, "<B>There are spies planted on [station_or_ship()]. They plan to steal valuables and assasinate rival spies  - Do not let them succeed!</B>")

/datum/game_mode/spy_theft/pre_setup()
	var/num_players = src.roundstart_player_count()

	var/randomizer = rand(0,6)
	var/num_spies = 2 //minimum

	if (traitor_scaling)
		num_spies = clamp(round((num_players + randomizer) / pop_divisor), 2, spies_possible)

	var/list/possible_spies = get_possible_enemies(ROLE_SPY_THIEF, num_spies)

	if (!possible_spies.len)
		return 0

	token_players = antag_token_list()
	for(var/datum/mind/tplayer in token_players)
		if (!token_players.len)
			break
		traitors += tplayer
		token_players.Remove(tplayer)
		logTheThing(LOG_ADMIN, tplayer.current, "successfully redeemed an antag token.")
		message_admins("[key_name(tplayer.current)] successfully redeemed an antag token.")

	var/list/chosen_spy_thieves = antagWeighter.choose(pool = possible_spies, role = ROLE_SPY_THIEF, amount = num_spies, recordChosen = 1)
	traitors |= chosen_spy_thieves
	for (var/datum/mind/spy in traitors)
		spy.special_role = ROLE_SPY_THIEF
		possible_spies.Remove(spy)

	return 1

/datum/game_mode/spy_theft/post_setup()
	for(var/datum/mind/spy in traitors)
		spy.add_antagonist(ROLE_SPY_THIEF, source = ANTAGONIST_SOURCE_ROUND_START)

	SPAWN(5 SECONDS) //Some possible bounty items (like organs) need some time to get set up properly and be assigned names
		build_bounty_list()

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/spy_theft/process()
	..()
	if (ticker.round_elapsed_ticks - last_refresh_time >= bounty_refresh_interval)
		src.build_bounty_list()
		src.update_bounty_readouts()

/datum/game_mode/spy_theft/send_intercept()
	..(src.traitors)
/datum/game_mode/spy_theft/declare_completion()
	. = ..()

/datum/game_mode/spy_theft/proc/update_bounty_readouts()
	for(var/obj/item/uplink/integrated/pda/spy/spy_uplink in uplinks)
		LAGCHECK(LAG_LOW)
		spy_uplink.ui_update()

	for(var/datum/mind/M in ticker.mode.traitors) //We loop through ticker.mode.traitors and do spy checks here because the mode might not actually be spy thief. And this instance of the datum may be held by the TRUE MODE
		LAGCHECK(LAG_LOW)
		if (M.special_role == ROLE_SPY_THIEF && M.current)
			boutput(M.current, SPAN_NOTICE("<b>Spy Console</b> has been updated with new requests.")) //MAGIC SPY SENSE (I feel this is justified, spies NEED to know this)
			M.current.playsound_local(M.current, 'sound/machines/twobeep.ogg', 35)

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
	if (!names.len)
		return null
	return pick(names)


/datum/game_mode/spy_theft/proc/build_bounty_list()
	src.last_refresh_time = ticker.round_elapsed_ticks

	//Clear and reset these lists. Some of these items may have gone missing, new crewmembers may have arrived.
	personal_bounties.len = 0
	organ_bounties.len = 0
	photo_bounties.len = 0

	//Look for every living human that should be on the station, store their limbs and names for organ/photos
	for(var/mob/living/carbon/human/H in mobs)
		LAGCHECK(LAG_LOW)

		if (isvirtual(H) || istype(get_area(H),/area/afterlife))
			continue

		if (istype(H.loc, /obj/cryotron))
			continue

		var/turf/T = get_turf(H)
		if (!T || T.z != 1) //Nobody in the adventure zones, thanks.
			continue

		//Personal bounties (items that belong to a person)
		//Pair list, stores job for difficulty lookup
		var/datum/deref = H?.trinket?.deref()
		if (istype(deref, /obj/item))
			personal_bounties += list(list(H.trinket.deref(), H.job))
		if (H.wear_id)
			personal_bounties += list(list(H.wear_id, H.job))


		if (H.client)
			if (H.limbs.get_limb("l_arm"))
				organ_bounties += list(list(H.limbs.get_limb("l_arm"), H.job))
			if (H.limbs.get_limb("r_arm"))
				organ_bounties += list(list(H.limbs.get_limb("r_arm"), H.job))
			if (H.limbs.get_limb("l_leg"))
				organ_bounties += list(list(H.limbs.get_limb("l_leg"), H.job))
			if (H.limbs.get_limb("r_leg"))
				organ_bounties += list(list(H.limbs.get_limb("r_leg"), H.job))


		//Add photographs of the crew
		photo_bounties += H.real_name


	//Master list of station item bounties (misc. things on the station that would be fun to steal)
	//Exact type and difficult rating - Does not automatically include subtypes
	station_bounties[/obj/item/ghostboard] = 1
	station_bounties[/obj/item/gnomechompski] = 1
	station_bounties[/obj/item/diary] = 1
	station_bounties[/obj/item/football] = 1
	station_bounties[/obj/item/basketball] = 1
	station_bounties[/obj/item/clothing/head/cakehat] = 1
	station_bounties[/obj/item/gun/russianrevolver] = 1
	station_bounties[/obj/item/clothing/suit/johnny_coat] = 1
	station_bounties[/obj/item/clothing/shoes/flippers] = 1
	station_bounties[/obj/item/clothing/head/apprentice] = 1
	station_bounties[/obj/item/clothing/head/helmet/space/santahat] = 1
	station_bounties[/obj/item/clothing/head/merchant_hat] = 1
	station_bounties[/obj/item/clothing/head/beret/prisoner] = 2
	station_bounties[/obj/item/clothing/head/caphat] = 3
	station_bounties[/obj/item/clothing/head/hos_hat] = 3

	station_bounties[/obj/item/disk/data/floppy/read_only/communications] = 2
	station_bounties[/obj/item/disk/data/floppy/read_only/authentication] = 3
	station_bounties[/obj/item/disk/data/floppy/manudrive/ai] = 2
	station_bounties[/obj/item/disk/data/floppy/manudrive/law_rack] = 1
	station_bounties[/obj/item/aiModule/freeform] = 3
	station_bounties[/obj/item/aiModule/nanotrasen1] = 2
	station_bounties[/obj/item/aiModule/nanotrasen2] = 2

	station_bounties[/obj/item/cell] = 1
	station_bounties[/obj/item/device/multitool] = 1
	station_bounties[/obj/item/device/net_sniffer] = 1
	station_bounties[/obj/item/mop] = 1
	station_bounties[/obj/item/spraybottle] = 1

	station_bounties[/obj/item/clothing/gloves/yellow] = 1
	station_bounties[/obj/item/clothing/under/misc/clown] = 1
	station_bounties[/obj/item/clothing/shoes/galoshes] = 1
	station_bounties[/obj/item/clothing/shoes/magnetic] = 1
	station_bounties[/obj/item/clothing/shoes/clown_shoes] = 1

	station_bounties[/obj/item/clothing/suit/hazard/bio_suit] = 1
	station_bounties[/obj/item/clothing/suit/hazard/paramedic] = 1
	station_bounties[/obj/item/clothing/suit/judgerobe] = 1
	station_bounties[/obj/item/clothing/suit/hazard/fire] = 1
	station_bounties[/obj/item/clothing/suit/armor/vest] = 2

	station_bounties[/obj/item/robodefibrillator] = 1
	station_bounties[/obj/item/remote/porter/port_a_medbay] = 2
	station_bounties[/obj/item/staple_gun] = 1
	station_bounties[/obj/item/storage/firstaid] = 1
	station_bounties[/obj/item/circular_saw] = 1
	station_bounties[/obj/item/reagent_containers/hypospray] = 1
	station_bounties[/obj/item/paper/book/from_file/pharmacopia] = 1
	station_bounties[/obj/item/reagent_containers/mender] = 2

	station_bounties[/obj/item/stamp/qm] = 1
	station_bounties[/obj/item/stamp/law] = 2
	station_bounties[/obj/item/stamp/rd] = 2
	station_bounties[/obj/item/stamp/md] = 2
	station_bounties[/obj/item/stamp/ce] = 2
	station_bounties[/obj/item/stamp/cap] = 2
	station_bounties[/obj/item/stamp/hop] = 2
	station_bounties[/obj/item/stamp/hos] = 2

	station_bounties[/obj/item/reagent_containers/food/drinks/mug/HoS] = 1
	station_bounties[/obj/item/reagent_containers/food/drinks/rum_spaced] = 2
	station_bounties[/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff] = 2
	station_bounties[/obj/item/reagent_containers/food/drinks/bottle/champagne] = 2
	station_bounties[/obj/item/pen/crayon/golden] = 2
	station_bounties[/obj/item/remote/porter/port_a_sci] = 2
	station_bounties[/obj/item/clothing/suit/security_badge/hosmedal] = 3
	station_bounties[/obj/item/rddiploma] = 2
	station_bounties[/obj/item/mdlicense] = 2
	station_bounties[/obj/item/firstbill] = 2
	station_bounties[/obj/captain_bottleship] = 3
	station_bounties[/obj/item/hand_tele] = 3
	station_bounties[/obj/item/card/id/captains_spare] = 3
	station_bounties[/obj/item/rcd] = 2
	station_bounties[/obj/item/rcd/construction/chiefEngineer] = 3

	station_bounties[/obj/item/baton] = 2
	station_bounties[/obj/item/gun/kinetic/riot40mm] = 2
	station_bounties[/obj/item/gun/kinetic/dart_rifle] = 3
	station_bounties[/obj/item/gun/kinetic/detectiverevolver] = 3
	station_bounties[/obj/item/gun/energy/antique] = 3
	station_bounties[/obj/item/gun/energy/taser_gun] = 2
	station_bounties[/obj/item/gun/energy/egun] = 3
	station_bounties[/obj/item/gun/energy/pulse_rifle] = 3
	station_bounties[/obj/item/gun/kinetic/pumpweapon/riotgun] = 3


	station_bounties[/obj/item/kitchen/utensil] = 1
	station_bounties[/obj/item/kitchen/rollingpin] = 1
	station_bounties[/obj/item/reagent_containers/food/snacks/cereal_box] = 1
	station_bounties[/obj/item/reagent_containers/food/snacks/beefood] = 1
	station_bounties[/obj/item/reagent_containers/food/snacks/ingredient/meat] = 1
	station_bounties[/obj/item/reagent_containers/glass/bottle/bubblebath] = 1
	station_bounties[/obj/item/reagent_containers/glass/wateringcan] = 1
	station_bounties[/obj/item/reagent_containers/food/drinks/bottle/vintage] = 1

	station_bounties[/obj/item/storage/belt/medical] = 1
	station_bounties[/obj/item/storage/belt/utility] = 1
	station_bounties[/obj/item/storage/belt/security] = 2

	station_bounties[/obj/item/instrument/saxophone] = 1
	station_bounties[/obj/item/instrument/bagpipe] = 1
	station_bounties[/obj/item/instrument/bikehorn/dramatic] = 1
	station_bounties[/obj/item/instrument/bikehorn] = 1
	station_bounties[/obj/item/instrument/harmonica] = 1
	station_bounties[/obj/item/instrument/whistle] = 1
	station_bounties[/obj/item/instrument/vuvuzela] = 1
	station_bounties[/obj/item/instrument/trumpet] = 1
	station_bounties[/obj/item/instrument/fiddle] = 1
	station_bounties[/obj/item/instrument/cowbell] = 1
	station_bounties[/obj/item/instrument/triangle] = 1
	station_bounties[/obj/item/instrument/tambourine] = 1

	station_bounties[/obj/item/clothing/glasses/blindfold] = 1
	station_bounties[/obj/item/clothing/glasses/toggleable/meson] = 1
	station_bounties[/obj/item/clothing/glasses/sunglasses/sechud] = 2
	station_bounties[/obj/item/clothing/glasses/sunglasses] = 1
	station_bounties[/obj/item/clothing/glasses/visor] = 1
	station_bounties[/obj/item/clothing/glasses/healthgoggles] = 1
	station_bounties[/obj/item/clothing/glasses/packetvision] = 2

	#ifdef UNDERWATER_MAP
	station_bounties[/obj/item/clothing/suit/space/diving/security] = 2
	station_bounties[/obj/item/clothing/suit/space/diving/civilian] = 1
	station_bounties[/obj/item/clothing/suit/space/diving/command] = 2
	station_bounties[/obj/item/clothing/suit/space/diving/engineering] = 1
	#else
	station_bounties[/obj/item/clothing/suit/space] = 1
	station_bounties[/obj/item/clothing/suit/space/santa] = 1
	station_bounties[/obj/item/clothing/suit/space/captain/blue] = 2
	station_bounties[/obj/item/clothing/suit/space/captain/red] = 2
	station_bounties[/obj/item/clothing/suit/space/captain] = 2
	station_bounties[/obj/item/clothing/suit/space/engineer] = 1
	#endif
	station_bounties[/obj/item/tank/jetpack] = 1

	station_bounties[/obj/item/storage/secure/sbriefcase] = 2
	station_bounties[/obj/item/storage/briefcase/toxins] = 2
	station_bounties[/obj/item/storage/backpack/medic] = 2
	station_bounties[/obj/item/storage/backpack/NT] = 3
	station_bounties[/obj/item/storage/backpack/captain/blue] = 3
	station_bounties[/obj/item/storage/backpack/captain/red] = 3
	station_bounties[/obj/item/storage/backpack/captain] = 3
	station_bounties[/obj/item/storage/backpack/satchel/captain/blue] = 3
	station_bounties[/obj/item/storage/backpack/satchel/captain/red] = 3
	station_bounties[/obj/item/storage/backpack/satchel/captain] = 3

	station_bounties[/obj/item/device/radio/headset/engineer] = 1
	station_bounties[/obj/item/device/radio/headset/medical] = 1
	station_bounties[/obj/item/device/radio/headset/research] = 1
	station_bounties[/obj/item/device/radio/headset/shipping] = 1
	station_bounties[/obj/item/device/radio/headset/mail] = 1
	station_bounties[/obj/item/device/radio/headset/clown] = 1
	station_bounties[/obj/item/device/radio/headset/deaf] = 1
	station_bounties[/obj/item/device/radio/headset/miner] = 1
	station_bounties[/obj/item/device/radio/headset/security] = 2
	station_bounties[/obj/item/device/radio/headset/command/radio_show_host] = 2
	station_bounties[/obj/item/device/radio/headset/command/hop] = 2
	station_bounties[/obj/item/device/radio/headset/command/rd] = 2
	station_bounties[/obj/item/device/radio/headset/command/md] = 2
	station_bounties[/obj/item/device/radio/headset/command/ce] = 2
	station_bounties[/obj/item/device/radio/headset/command] = 2
	station_bounties[/obj/item/device/radio/headset/command/nt] = 3
	station_bounties[/obj/item/device/radio/headset/command/captain] = 3
	station_bounties[/obj/item/device/radio/headset/command/hos] = 3

	// Big machinery (non portable) objects

	#ifdef UNDERWATER_MAP
	big_station_bounties[/obj/machinery/vehicle/tank/minisub/secsub] = 1
	big_station_bounties[/obj/machinery/vehicle/tank/minisub/mining] = 1
	big_station_bounties[/obj/machinery/vehicle/tank/minisub/civilian] = 1
	big_station_bounties[/obj/machinery/vehicle/tank/minisub/engineer] = 1
	big_station_bounties[/obj/machinery/vehicle/tank/minisub/escape_sub] = 1
	big_station_bounties[/obj/machinery/vehicle/tank/minisub] = 1
	#else
	big_station_bounties[/obj/machinery/vehicle/pod] = 1
	big_station_bounties[/obj/machinery/vehicle/escape_pod] = 1
	big_station_bounties[/obj/machinery/vehicle/cargo] = 1
	big_station_bounties[/obj/machinery/vehicle/miniputt/nanoputt] = 1
	#endif

	big_station_bounties[/obj/machinery/power/reactor_stats] = 1
	big_station_bounties[/obj/machinery/computer/supplycomp] = 1
	big_station_bounties[/obj/machinery/computer3/generic/communications] = 1
	big_station_bounties[/obj/machinery/computer3/terminal/zeta] = 1
	big_station_bounties[/obj/machinery/networked/teleconsole] = 2
	big_station_bounties[/obj/machinery/chem_dispenser] = 2
	big_station_bounties[/obj/machinery/computer/announcement] = 2
	big_station_bounties[/obj/machinery/computer/card] = 2
	big_station_bounties[/obj/machinery/computer/genetics] = 2
	big_station_bounties[/obj/machinery/computer/robotics] = 2
	big_station_bounties[/obj/machinery/turret] = 3

	big_station_bounties[/obj/machinery/vending/medical] = 1
	big_station_bounties[/obj/machinery/vending/port_a_nanomed] = 1
	big_station_bounties[/obj/machinery/vending/fortune] = 1
	big_station_bounties[/obj/machinery/vending/standard] = 1
	big_station_bounties[/obj/machinery/vending/monkey] = 1
	big_station_bounties[/obj/machinery/vending/security] = 2

	big_station_bounties[/obj/machinery/traymachine/morgue] = 1
	big_station_bounties[/obj/machinery/optable] = 2
	big_station_bounties[/obj/machinery/clonegrinder] = 2
	big_station_bounties[/obj/machinery/genetics_scanner] = 2
	big_station_bounties[/obj/machinery/atmospherics/unary/cryo_cell] = 2
	big_station_bounties[/obj/machinery/computer/cloning] = 2
	big_station_bounties[/obj/machinery/clonepod] = 2
	big_station_bounties[/obj/machinery/dialysis] = 2

	big_station_bounties[/obj/machinery/flasher/portable] = 2
	big_station_bounties[/obj/machinery/recharge_station] = 2

	big_station_bounties[/obj/machinery/sleeper/port_a_medbay] = 1
	big_station_bounties[/obj/machinery/port_a_brig] = 3
	big_station_bounties[/obj/machinery/recharger] = 3

	big_station_bounties[/obj/machinery/manufacturer/robotics] = 2
	big_station_bounties[/obj/machinery/manufacturer/medical] = 2
	big_station_bounties[/obj/machinery/manufacturer/general] = 1

	big_station_bounties[/obj/submachine/chef_oven] = 1
	big_station_bounties[/obj/machinery/gibber] = 1

	big_station_bounties[/obj/machinery/bot/guardbot] = 1
	big_station_bounties[/obj/machinery/plantpot] = 1
	big_station_bounties[/obj/machinery/partyalarm] = 1
	big_station_bounties[/obj/pool_springboard] = 1
	big_station_bounties[/obj/machinery/hydro_growlamp] = 1

	big_station_bounties[/obj/reagent_dispensers/foamtank] = 1
	big_station_bounties[/obj/reagent_dispensers/watertank/fountain] = 1
	big_station_bounties[/obj/reagent_dispensers/watertank] = 1
	big_station_bounties[/obj/reagent_dispensers/compostbin] = 1
	big_station_bounties[/obj/reagent_dispensers/fueltank] = 1
	big_station_bounties[/obj/reagent_dispensers/beerkeg] = 2
	big_station_bounties[/obj/reagent_dispensers/still] = 2

	big_station_bounties[/obj/machinery/communications_dish] = 2
	big_station_bounties[/obj/item/teg_semiconductor/prototype] = 2
	big_station_bounties[/obj/machinery/power/smes] = 2
	big_station_bounties[/obj/machinery/rkit] = 2
	big_station_bounties[/obj/machinery/crusher] = 3

	big_station_bounties[/obj/item/instrument/large/piano/grand] = 1
	big_station_bounties[/obj/item/instrument/large/piano] = 1
	big_station_bounties[/obj/item/instrument/large/organ] = 1
	big_station_bounties[/obj/item/instrument/large/jukebox] = 1

	active_bounties.len = 0

	// Find matches for all our possible bounties
	var/list/spy_thief_target_types = station_bounties + big_station_bounties
	var/list/valid_spy_thief_targets_by_type = list()
	// Loop through all objects and pick valid objects on station
	for(var/obj/Object in world)
		LAGCHECK(LAG_LOW)
		if (spy_thief_target_types[Object.type])
			var/turf/Turf = get_turf(Object)
			if (!Turf || Turf.z != Z_LEVEL_STATION)
				continue
			var/area/A = get_area(Object)
			if (A.name == "Listening Post")
				continue
			if (valid_spy_thief_targets_by_type[Object.type])
				valid_spy_thief_targets_by_type[Object.type] += Object
			else
				valid_spy_thief_targets_by_type[Object.type] = list(Object)
	//Add organs
	var/list/O = organ_bounties.Copy()
	var/found_organs = 0
	var/organs_length = length(O)
	for(var/i=1, (found_organs < organ_bounty_amt) && (i <= organs_length), i++)
		var/datum/bounty_item/B = new /datum/bounty_item(src)
		var/list/pair = pick(O)
		B.item = pair[1]
		B.job = pair[2]
		// B.path = B.item.type
		if (istype(B.item, /obj/item/parts))
			var/obj/item/parts/P = B.item
			if (!P || P.qdeled || !P.holder || P.holder.qdeled)
				// Not found, next organ
				O -= list(pair)
				continue
			B.name = P.holder.real_name + "'s " + P.name
		B.reveal_area = 1
		O -= list(pair)

		found_organs++
		B.bounty_type = BOUNTY_TYPE_ORGAN
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
		P -= list(pair)

		B.bounty_type = BOUNTY_TYPE_TRINK
		active_bounties += B

	//Add big station item bounties
	var/big_choice = null
	var/obj/obj_existing = null
	var/big_picked=1
	while(big_picked<=big_station_bounty_amt)
		if (length(big_station_bounties) <= 0)
			logTheThing(LOG_DEBUG, src, "spy_theft.dm was unable to create enough big station bounties.")
			message_admins("Spy bounty logic was unable to create enough big station bounties.")
			break
		// Pick an item type then check if it is valid
		big_choice = pick(big_station_bounties)
		obj_existing = pick(valid_spy_thief_targets_by_type[big_choice])
		if (obj_existing == null)
			// Catch picks that weren't found
			big_station_bounties -= big_choice
			continue
		var/datum/bounty_item/B = new /datum/bounty_item(src)
		B.path = obj_existing.type
		B.item = obj_existing
		B.name = obj_existing.name

		//Retrieve difficulty rating
		B.difficulty = big_station_bounties[big_choice]
		B.bounty_type = BOUNTY_TYPE_BIG
		active_bounties += B
		big_station_bounties -= big_choice
		big_picked++

	//Add photos
	var/list/PH = photo_bounties.Copy()
	for(var/i=1, i<=photo_bounty_amt && PH.len, i++)
		var/datum/bounty_item/B = new /datum/bounty_item(src)
		B.photo_containing = pick(PH)
		B.name = "a photograph of [B.photo_containing]"
		PH -= B.photo_containing

		B.bounty_type = BOUNTY_TYPE_PHOTO
		active_bounties += B

	//Add station item bounties
	var/item_choice = null
	var/obj/item_existing = null
	var/item_picked=1
	while(item_picked<=station_bounty_amt)
		if (length(station_bounties) <= 0)
			logTheThing(LOG_DEBUG, src, "spy_theft.dm was unable to create enough item bounties.")
			message_admins("Spy bounty logic was unable to create enough item bounties.")
			break
		// Pick an item type then check if it is valid
		item_choice = pick(station_bounties)
		item_existing = pick(valid_spy_thief_targets_by_type[item_choice])
		if (item_existing == null)
			// Catch picks that weren't found
			station_bounties -= item_choice
			continue
		var/datum/bounty_item/B = new /datum/bounty_item(src)
		B.path = item_existing.type
		B.item = item_existing
		B.name = item_existing.name

		//Retrieve difficulty rating
		B.difficulty = station_bounties[item_choice]
		B.bounty_type = BOUNTY_TYPE_ITEM

		active_bounties += B
		station_bounties -= item_choice
		item_picked++


	//Set delivery areas
	for (var/area/A in (get_areas_with_unblocked_turfs(/area/station) + get_areas_with_unblocked_turfs(/area/diner)))
		LAGCHECK(LAG_LOW)
		if (A.virtual)
			continue
		var/typeinfo/area/typeinfo = A.get_typeinfo()
		if (typeinfo.valid_bounty_area)
			possible_areas += A

	for (var/datum/bounty_item/B in active_bounties)
		if (B.bounty_type == BOUNTY_TYPE_ORGAN || B.bounty_type == BOUNTY_TYPE_BIG)
			B.delivery_area = 0
		else
			B.delivery_area = pick(possible_areas)
		// Calculate bounty difficulty
		if (B.bounty_type == BOUNTY_TYPE_PHOTO)
			// Adjust reward based off delivery area
			if (B.delivery_area.spy_secure_area)
				B.pick_reward_tier(2)
			else
				B.pick_reward_tier(1)
		else if (B.bounty_type == BOUNTY_TYPE_ORGAN)
			// Adjust reward based off target job and to estimate risk level
			B.difficulty = B.estimate_target_difficulty(B.job)
			switch(B.difficulty)
				if (3)
					B.pick_reward_tier(4)
				if (2)
					B.pick_reward_tier(3)
				if (1)
					if (prob(10))	// Hot bounty
						B.pick_reward_tier(pick(3,4))
						B.hot_bounty = TRUE
					else
						B.pick_reward_tier(2)
		else if (B.bounty_type == BOUNTY_TYPE_TRINK)
			// Adjust reward based off target job and delivery area to estimate risk level
			B.difficulty = B.estimate_target_difficulty(B.job)
			switch(B.difficulty)
				if (3)
					B.pick_reward_tier(4)
				if (2)
					if (prob(10))	// Hot bounty
						B.pick_reward_tier(4)
						B.hot_bounty = TRUE
					else
						if (B.delivery_area.spy_secure_area)
							B.pick_reward_tier(pick(3,4))
						else
							B.pick_reward_tier(pick(2,3))
				if (1)
					if (prob(10))	// Hot bounty
						B.pick_reward_tier(4)
						B.hot_bounty = TRUE
					else
						if (B.delivery_area.spy_secure_area)
							B.pick_reward_tier(3)
						else
							B.pick_reward_tier(pick(1,2))
		else if (B.bounty_type == BOUNTY_TYPE_BIG)
			// Preset difficulty depending upon type
			switch(B.difficulty)
				if (3)
					B.pick_reward_tier(pick(2,3))
				if (2)
					B.pick_reward_tier(pick(1,2))
				if (1)
					if (prob(15))	// Random increase for variety
						B.pick_reward_tier(pick(1,2))
					else
						B.pick_reward_tier(1)
		else if (B.bounty_type == BOUNTY_TYPE_ITEM)
			// Preset difficulty depending upon type, adjusted by delivery area
			switch(B.difficulty)
				if (3)
					if (B.delivery_area.spy_secure_area)
						B.pick_reward_tier(pick(3,4))
					else
						B.pick_reward_tier(pick(2,3))
				if (2)
					if (B.delivery_area.spy_secure_area)
						B.pick_reward_tier(pick(2,3))
					else
						B.pick_reward_tier(pick(1,2))
				if (1)
					if (B.delivery_area.spy_secure_area)
						B.pick_reward_tier(pick(2,3))
					else
						if (prob(15))	// Random increase for variety
							B.pick_reward_tier(pick(1,2))
						else
							B.pick_reward_tier(1)
	return
