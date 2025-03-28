/datum/game_mode/gang
	name = "Gang War (Beta)"
	config_tag = "gang"
	regular = FALSE

	/// Makes it so gang members are chosen randomly at roundstart instead of being recruited.
	var/random_gangs = TRUE

	antag_token_support = TRUE
	var/list/datum/gang/gangs = list()

	var/const/setup_min_teams = 2
#ifdef RP_MODE
	var/const/setup_max_teams = 2
#else
	var/const/setup_max_teams = 3
#endif
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/minimum_players = 15 // Minimum ready players for the mode

	var/slow_process = 0			//number of ticks to skip the extra gang process loops
	var/shuttle_called = FALSE

/datum/game_mode/gang/announce()
	boutput(world, "<B>The current game mode is - Gang War!</B>")
	boutput(world, "<B>A number of gangs are competing for control of the station!</B>")
	boutput(world, "<B>Gang members are antagonists and can kill or be killed!</B>")

#ifdef RP_MODE
#define PLAYERS_PER_GANG_GENERATED 15
#else
#define PLAYERS_PER_GANG_GENERATED 12
#endif
/datum/game_mode/gang/pre_setup()
	var/num_players = src.roundstart_player_count()

#ifndef ME_AND_MY_40_ALT_ACCOUNTS
	if (num_players < minimum_players)
		message_admins("<b>ERROR: Minimum player count of [minimum_players] required for Gang game mode, aborting gang round pre-setup.</b>")
		logTheThing(LOG_GAMEMODE, src, "Failed to start gang mode. [num_players] players were ready but a minimum of [minimum_players] players is required. ")
		return 0
#endif

	var/num_teams = clamp(round((num_players) / PLAYERS_PER_GANG_GENERATED), setup_min_teams, setup_max_teams) //1 gang per 9 players, 15 on RP
	logTheThing(LOG_GAMEMODE, src, "Counted [num_players] available, with [PLAYERS_PER_GANG_GENERATED] per gang that means [num_teams] gangs.")

	var/list/leaders_possible = get_possible_enemies(ROLE_GANG_LEADER, num_teams)
	if (num_teams > length(leaders_possible))
		logTheThing(LOG_GAMEMODE, src, "Reducing number of gangs from [num_teams] to [length(leaders_possible)] due to lack of available gang leaders.")
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

#ifndef ME_AND_MY_40_ALT_ACCOUNTS
	// check if we can actually run the mode before assigning special roles to minds
	if(length(get_possible_enemies(ROLE_GANG_MEMBER, round(num_teams * GANG_MAX_MEMBERS), force_fill = FALSE) - src.traitors) < round(num_teams * GANG_MAX_MEMBERS * 0.66)) //must have at least 2/3 full gangs or there's no point
		//boutput(world, SPAN_ALERT("<b>ERROR: The readied players are not collectively gangster enough for the selected mode, aborting gangwars.</b>"))
		return 0
#endif

	for (var/datum/mind/leader in src.traitors)
		leaders_possible.Remove(leader)
		leader.special_role = ROLE_GANG_LEADER

	return 1
#undef PLAYERS_PER_GANG_GENERATED

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
		candidates = get_possible_enemies(ROLE_GANG_MEMBER, num_people_needed, allow_carbon=TRUE, filter_proc=GLOBAL_PROC_REF(can_join_gangs), force_fill = FALSE)
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

/proc/can_join_gangs(mob/M) //stupid frickin 515 call syntax making me make this a global grumble grumble
	var/datum/job/job = find_job_in_controller_by_string(M.mind.assigned_role)
	. = (!job || !job.can_be_antag(ROLE_GANG_LEADER) || !job.can_be_antag(ROLE_GANG_LEADER))

/datum/game_mode/gang/send_intercept()
	..(src.traitors)


/datum/game_mode/gang/process()
	..()
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
				if (!H)
					return
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
	for (var/datum/gang/gang in src.gangs)
		logTheThing(LOG_GAMEMODE, src, "Gang [gang.gang_name] ended the round with [gang.gang_score()] total score.")
	if (!check_winner())
		boutput(world, "<h2><b>The round was a draw!</b></h2>")

	else
		var/datum/gang/winner = check_winner()
		if (istype(winner))
			boutput(world, "<h2><b>[winner.gang_name], led by [winner.leader.current.real_name], won the round!</b></h2>")

			var/datum/hud/gang_victory/victory_hud = get_singleton(/datum/hud/gang_victory)
			victory_hud.set_winner(winner)
			for (var/client/C in clients)
				victory_hud.add_client(C)
				C.mob.addAbility(/datum/targetable/toggle_gang_victory_hud)

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
	var/static/list/color_list = list("#88CCEE","#117733","#332288","#DDCC77","#CC6677","#AA4499") //(hopefully) colorblind friendly palette
	var/static/list/colors_left = null
	/// The radio source for the gang's announcer, who will announce various messages of importance over the gang's frequency.
	var/datum/generic_radio_source/announcer_source
	/// The radio headset that the gang's announcer will use.
	var/obj/item/device/radio/headset/gang/announcer_radio
	/// String displayed to show the next spray paint restock
	var/next_spray_paint_restock ="--:--"

	/// The chosen name of this gang.
	var/gang_name = "Gang Name"
	/// The randomly selected tag of this gang.
	var/gang_tag = 0
	/// The ID of the color selected
	var/color_id = 0
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
	var/list/datum/mind/members = list()
	var/list/tags = list()
	/// The minds of members of this gang who are currently on cooldown from redeeming their gear from the gang locker.
	var/list/gear_cooldown = list()
	/// List of antag datums who have obtained their free gun from the locker so far
	var/list/free_gun_owners = list()
	/// The gang locker of this gang.
	var/obj/ganglocker/locker = null
	/// The usable number of points that this gang has to spend with.
	/// The street cred this gang has - used exclusively by the leader for purchasing gang members & revives
	var/street_cred = 0
	/// The number of tiles this gang controls.
	var/tiles_controlled = 0
	/// Associative list between Gang members -> their points
	var/gang_points = list()
	/// Associative list of tracked vandalism zones to their required vandalism score.
	var/list/vandalism_tracker_target = list()
	/// Associative list of tracked vandalism zones to the amount of vandalism score accrued.
	var/list/vandalism_tracker = list()

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
	/// Total score. may not be perfectly up to date
	var/score_total = 0
	var/static/list/first_names = strings("gangwar.txt", "part1")
	var/static/list/second_names = strings("gangwar.txt", "part2")

	/// Whether or not the leader of this gang has claimed a recruitment briefcase
	var/claimed_briefcase = FALSE

	/// Price of the janktank II, for this gang (gang member revival syringe)
	var/current_revival_price = GANG_REVIVE_COST

	/// Price to hire a spectator gang member, for this gang
	var/current_newmember_price = GANG_NEW_MEMBER_COST

	/// Whether a gang member can claim to be leader. For when the leader cryos & observes (and NOT when the leader dies)
	var/leader_claimable = FALSE

	/// Potential loot drop zones for this gang
	var/list/potential_drop_zones

	/// Strings used to build PDA messages sent to civilians.
	var/static/gangGreetings[] = list("yo", "hey","hiya","oi", "psst", "pssst" )
	var/static/gangIntermediates[] = list("don't ask how I got your number.","heads up.", "help us out.")
	var/static/gangThreats[] =list("don't try to snatch it, you hear?", "if you take our stuff, it'll get ugly.", "don't try and intervene.", "leave it alone.")
	var/static/gangEndings[] = list("help them, or they might break your knees.", "stay in line and you'll probably live.", "don't fuck this up, or you're next.", "don't fuck this up.")

	proc/living_member_count()
		var/result = 0
		for (var/datum/mind/member as anything in members)
			if (!isdead(member.current))
				result++
		return result

	/// how to handle the gang leader dying horribly early into the shift (suicide etc)
	proc/handle_leader_early_death()
		if (!src.locker)
			choose_new_leader()
			logTheThing(LOG_ADMIN, src.leader.ckey, "was given the role of leader for [gang_name], as their previous leader died early with no locker.")
			message_admins("[src.leader.ckey] has been granted the role of leader for their gang, [gang_name], as the previous leader died early with no locker.")
			broadcast_to_gang("Your leader has died early into the shift. Leadership has been transferred to [src.leader.current.real_name]")
		else
			broadcast_to_gang("Your leader has died early into the shift. If not revived, a new leader will be picked in [GANG_LEADER_SOFT_DEATH_DELAY/(1 MINUTE)] minutes.")
			SPAWN (GANG_LEADER_SOFT_DEATH_DELAY)
				if (!isalive(src.leader.current))
					choose_new_leader()
					logTheThing(LOG_ADMIN, src.leader.ckey, "was given the role of leader for [gang_name], as their previous leader died early and wasn't respawned/revived.")
					message_admins("[src.leader.ckey] has been granted the role of leader for their gang, [gang_name], as the previous leader died early and wasn't respawned/revived.")
					broadcast_to_gang("Your leader has died early into the shift. Leadership has been transferred to [src.leader.current.real_name]")

	/// how to handle the gang leader entering cryo (but not guaranteed to be permanent)
	proc/handle_leader_temp_cryo()
		if (!src.locker)
			choose_new_leader()
		else
			// the delay here is handled by the locker.
			broadcast_to_gang("Your leader has entered temporary cryogenic storage. You can claim leadership at your locker in [GANG_CRYO_LOCKOUT/(1 MINUTE)] minutes.")

	/// handle the gang leader entering cryo permanently
	proc/handle_leader_perma_cryo()
		if (src.locker)
			broadcast_to_gang("Your leader has entered permanent cryogenic storage. You can claim leadership at your locker.")
			leader_claimable = TRUE
		else
			logTheThing(LOG_ADMIN, src.leader.ckey, "was given the role of leader for [gang_name], as their leader cryo'd without a locker.")
			message_admins("[src.leader.ckey] has been granted the role of leader for their gang, [gang_name], as leader cryo'd without a locker.")
			broadcast_to_gang("As your leader has entered cryogenic storage without a locker, [src.leader.current.real_name] is now your new leader.")
			choose_new_leader()

	proc/choose_new_leader()
		var/datum/mind/smelly_unfortunate
		for (var/datum/mind/member in members)
			if (isliving(member.current))
				var/mob/living/carbon/candidate = member.current
				if (!candidate.hibernating)
					smelly_unfortunate = member
		if (!smelly_unfortunate)
			logTheThing(LOG_ADMIN, leader.ckey, "The leader of [gang_name] cryo'd/died early with no living members to take the role.")
			message_admins("The leader of [gang_name], [leader.ckey] cryo'd/died early with no living members to take the role.")
			return

		var/datum/mind/bad_leader = leader
		var/datum/antagonist/leaderRole = leader.get_antagonist(ROLE_GANG_LEADER)
		var/datum/antagonist/oldRole = smelly_unfortunate.get_antagonist(ROLE_GANG_MEMBER)
		smelly_unfortunate.current.remove_ability_holder(/datum/abilityHolder/gang)
		oldRole.silent = TRUE // so they dont get a spooky 'you are no longer a gang member' popup!
		smelly_unfortunate.remove_antagonist(ROLE_GANG_MEMBER,ANTAGONIST_REMOVAL_SOURCE_OVERRIDE,FALSE)
		leaderRole.transfer_to(smelly_unfortunate, FALSE, ANTAGONIST_REMOVAL_SOURCE_EXPIRED)
		bad_leader.add_subordinate_antagonist(ROLE_GANG_MEMBER, master = smelly_unfortunate)

	proc/get_dead_memberlist()
		var/list/result = list()
		for (var/datum/mind/member as anything in members)
			if (istype(member.current.loc, /obj/cryotron))
				var/obj/cryotron/cryo = member.current.loc
				var/cryoTime = cryo.stored_mobs[member.current]
				if (TIME - cryoTime > GANG_CRYO_LOCKOUT)
					result[(member.current?.real_name)] = member
				continue
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
			if (!tileClaim)
				return
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
		if (colors_left == null)
			colors_left = new/list(length(color_list))
			for (var/color = 1 to length(color_list))
				colors_left[color] = color
		if (!src.used_tags)
			src.used_tags = list()
		if (!src.used_names)
			src.used_names = list()
		if (!src.used_frequencies)
			src.used_frequencies = list()
		if (!src.uniform_list || !src.headwear_list)
			src.make_item_lists()
		color_id = pick(colors_left)
		colors_left -= color_id
		color = color_list[color_id]
		src.gang_tag = rand(0, 22)
		while(src.gang_tag in src.used_tags)
			src.gang_tag = rand(0, 22)
		src.used_tags += src.gang_tag

		src.gang_frequency = rand(1360, 1420)
		while(src.gang_frequency in src.used_frequencies)
			src.gang_frequency = rand(1360, 1420)
		src.used_frequencies += src.gang_frequency
		protected_frequencies += gang_frequency

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

		score += score_turf
		score += score_cash
		score += score_gun
		score += score_drug
		score += score_event
		score_total = round(score)
		return score_total

	/// Shows maptext to the gang, with formatting for score increases.
	proc/show_score_maptext(amount, turf/location)
		var/image/chat_maptext/chat_text = null
		chat_text = make_chat_maptext(location, "<span class='ol c pixel' style='color: #08be4e;'>+[amount]</span>", alpha = 180, time = 0.5 SECONDS)
		chat_text.show_to(src.leader?.current.client)
		for (var/datum/mind/userMind as anything in src.members)
			var/client/userClient = userMind.current.client
			if (userClient?.preferences?.flying_chat_hidden)
				chat_text.show_to(userClient)

	/// Shows maptext to the gang, with formatting for score increases.
	proc/show_vandal_maptext(score, area/targetArea, turf/location, notable)
		if (vandalism_tracker[targetArea] == null) return
		var/image/chat_maptext/chat_text = null
		if (!notable)
			chat_text = make_chat_maptext(location, "<span class='ol c pixel' style='color: #e60000;'>+[score]</span>", alpha = 180, time = 0.5 SECONDS)
		else
			chat_text = make_chat_maptext(location, "<span class='ol c pixel' style='color: #e60000;'>+[score]\n [vandalism_tracker[targetArea]]/[vandalism_tracker_target[targetArea]]</span>", alpha = 180, time = 2 SECONDS)
		chat_text.show_to(src.leader?.current.client)
		for (var/datum/mind/userMind as anything in src.members)
			var/client/userClient = userMind.current.client
			if (userClient?.preferences?.flying_chat_hidden)
				chat_text.show_to(userClient)

	/// Checks to see if <location> is one the gang has to vandalise. If so, adds <amount> progress.
	proc/do_vandalism(amount, turf/location)
		if (amount == 0) return
		var/area/area = get_area(location)
		for (var/area/targetArea as anything in vandalism_tracker)
			if (istype(area,targetArea))
				var/notable_value_prior = vandalism_tracker[targetArea]
				vandalism_tracker[targetArea] += amount
				//show a recap tracker every 50 points for minor things like tile breaking
				var/notable_value_steps = round(notable_value_prior/50)-round(vandalism_tracker_target[targetArea]/10)
				if (amount >= 10 || notable_value_steps > 0 )
					show_vandal_maptext(amount, targetArea, location, TRUE)
				else
					show_vandal_maptext(amount, targetArea, location, FALSE)

				if (vandalism_tracker[targetArea] >= vandalism_tracker_target[targetArea])
					src.broadcast_to_gang("You've successfully ruined \the [targetArea.name]! The duffle bag has been delivered to where the last act of vandalism occurred.")
					var/obj/item/loot = new/obj/item/gang_loot/guns_and_gear(location)
					showswirl(loot)
					vandalism_tracker -= targetArea
				break



	/// add points to this gang, bonusMob optionally getting a bonus
	/// if location is defined, maptext will come from that location, for all members.
	proc/add_points(amount, mob/bonusMob = null, turf/location = null, showText = FALSE)
		street_cred += amount
		var/datum/mind/bonusMind = bonusMob?.mind
		if (leader)
			if (gang_points[leader] == null)
				gang_points[leader] = GANG_STARTING_POINTS
			if (leader == bonusMind)
				gang_points[leader] += round(amount * 1.25) //give a 25% reward for the one providing
			else
				gang_points[leader] += amount
		for (var/datum/mind/M in members)
			if (gang_points[M] == null)
				gang_points[M] = GANG_STARTING_POINTS
			if (M == bonusMind)
				gang_points[M] += round(amount * 1.25)
			else
				gang_points[M] += amount

		gang_score()
		if (!showText)
			return
		if (location)
			show_score_maptext(amount, location)
		else if (bonusMob.client && !bonusMob.client.preferences?.flying_chat_hidden)
			var/image/chat_maptext/chat_text = null
			if (amount >= 1000)
				chat_text = make_chat_maptext(bonusMob, "<span class='ol c pixel' style='color: #08be4e; font-weight: bold; font-size: 24px;'>+[amount]</span>", alpha = 180, time = 3 SECONDS)
			else
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

		if (M.wear_suit && !istype(M.wear_suit, /obj/item/clothing/suit/armor/gang))
			count--
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
		"mail courier's jumpsuit" = /obj/item/clothing/under/misc/mail,
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
		"mail courier's hat" = /obj/item/clothing/head/mailcap,
		"turban" = /obj/item/clothing/head/turban,
		"formal turban" = /obj/item/clothing/head/formal_turban,
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
	proc/target_loot_spawn(datum/mind/civvie, datum/gang/ownerGang)
		var/message = lootbag_spawn(civvie, ownerGang)
		var/datum/signal/newsignal = get_free_signal()
		newsignal.source = src
		newsignal.encryption = "GDFTHR+\ref[civvie.originalPDA]"
		newsignal.encryption_obfuscation = 90 // too easy to decipher these
		newsignal.data["command"] = "text_message"
		newsignal.data["sender_name"] = "Unknown Sender"
		newsignal.data["message"] = "[message]"
		newsignal.data["address_1"] = civvie.originalPDA.net_id

		logTheThing(LOG_GAMEMODE, civvie, "Informed [civvie.ckey]/[civvie.current.name] on their PDA [civvie.originalPDA] about the loot bag for [src.gang_name].")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(newsignal)

	/// pick a random civilian (non-gang, non-sec), ideally not picking any deferred_minds
	proc/get_random_civvie(var/list/deferred_minds)
		var/mindList[0]
		for (var/datum/mind/M as anything in ticker.minds)
			if (M.get_antagonist(ROLE_GANG_LEADER) || M.get_antagonist(ROLE_GANG_MEMBER) || !(M.originalPDA) || !ishuman(M.current) || (M.assigned_role in security_jobs) || M.assigned_role == "Captain")
				continue
			if (isnull(M.current.loc)) //deleted or an admin who has removeself'd
				continue
			if (isliving(M.current))
				var/mob/living/L = M.current
				if (L.hibernating) //cryod
					continue
			if (is_dead_or_ghost_role(M.current)) //stop sending PDA messages to the afterlife
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
		var/list/area/areas = get_accessible_station_areas()
		for(var/area in areas)
			if(istype(areas[area], /area/station/security) || areas[area].teleport_blocked || istype(areas[area], /area/station/solar))
				continue
			var/typeinfo/area/typeinfo = areas[area].get_typeinfo()
			if (!typeinfo.valid_bounty_area)
				continue
			potential_drop_zones += areas[area]

	/// hide a loot bag somewhere, return a probably-somewhat-believable PDA message explaining its' location
	proc/lootbag_spawn(datum/mind/civvie, datum/gang/ownerGang)
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
					if (!crate.secure && !crate.locked && !crate.open)
						crateList.Add(O)
				else if (istype(O,/obj/table) && !istype(O,/obj/table/glass))
					tableList.Add(O)

			if (!is_blocked_turf(T))
				if (T.intact && !(istype(T, /turf/simulated/floor/glassblock) || istype(T, /turf/simulated/floor/auto/glassblock)))
					turfList.Add(T)
				else
					uncoveredTurfList.Add(T)
		var/obj/item/gang_loot/loot
		if(length(bushList))
			loot = new/obj/item/gang_loot/guns_and_gear
			var/obj/shrub/target = pick(bushList)
			target.override_default_behaviour = 1
			target.additional_items.Add(loot)
			target.spawn_chance = 75
			target.last_use = 0
			target.max_uses += 1
			message += " we left some goods in a bush [pick("somewhere around", "inside", "somewhere inside")] \the [loot_zone]."
			logTheThing(LOG_GAMEMODE, target, "Spawned at \the [loot_zone] for [src.gang_name], inside a shrub: [target] at [target.x],[target.y]")
		else if(length(crateList) && prob(80))
			var/obj/storage/target = pick(crateList)
			loot = new/obj/item/gang_loot/guns_and_gear(target.contents)
			target.contents.Add(loot)
			message += " we left a bag in \the [target], [pick("somewhere around", "inside", "somewhere inside")] \the [loot_zone]. "
			logTheThing(LOG_GAMEMODE, target, "Spawned at \the [loot_zone] for [src.gang_name], inside a crate: [target] at [target.x],[target.y]")

		else if(length(disposalList) && prob(85))
			var/obj/machinery/disposal/target = pick(disposalList)
			loot = new/obj/item/gang_loot/guns_and_gear(target.contents)
			target.contents.Add(loot)
			message += " we left a bag in \the [target], [pick("somewhere around", "inside", "somewhere inside")] \the [loot_zone]. "
			logTheThing(LOG_GAMEMODE, target, "Spawned at \the [loot_zone] for [src.gang_name], inside a chute: [target] at [target.x],[target.y]")
		else if(length(tableList) && (length(uncoveredTurfList) > 0 || prob(65))) // only spawn on uncovered turf as a last resort
			var/turf/target = get_turf(pick(tableList))
			loot = new/obj/item/gang_loot/guns_and_gear
			target.contents.Add(loot)
			loot.layer = OVERFLOOR
			//nudge this into position, for sneakiness
			loot.transform = matrix()
			loot.transform = loot.transform.Scale(0.8,0.8)
			loot.transform = loot.transform.Turn(20)
			loot.pixel_x = 1
			loot.pixel_y = 1
			loot.AddComponent(/datum/component/reset_transform_on_pickup)

			message += " we hid a bag in \the [loot_zone], under a table. "
			logTheThing(LOG_GAMEMODE, loot, "Spawned at \the [loot_zone] for [src.gang_name], under a table: [target] at [target.x],[target.y]")
		else if(length(turfList))
			var/turf/target = pick(turfList)
			loot = new/obj/item/gang_loot/guns_and_gear(target)
			loot.level = UNDERFLOOR
			loot.hide(target.intact)
			message += " we had to hide a bag in \the [loot_zone], under the floor tiles. "
			logTheThing(LOG_GAMEMODE, loot, "Spawned at \the [loot_zone] for [src.gang_name], under the floor at [loot.x],[loot.y]")
		else
			var/turf/simulated/floor/target = pick(uncoveredTurfList)
			loot = new/obj/item/gang_loot/guns_and_gear
			target.contents.Add(loot)
			loot.hide(target.intact)
			message += " we had to hide a bag in \the [loot_zone]. "
			logTheThing(LOG_GAMEMODE, loot, "Spawned at \the [loot_zone] for [src.gang_name], on the floor at [loot.x],[loot.y].")

		loot.informant = civvie.current.real_name

		loot.owning_gang = ownerGang
		loot.start_area = get_area(loot.loc)
		message += pick(gangThreats)
		message += " we've got folk aboard who will come by and ask you for this information. "
		message += pick(gangEndings)

		return message

/obj/item/spray_paint_gang
	name = "'Red X' Xtra Heavy Spray Paint"
	desc = "The bane of janitors everywhere. Red X is an extra thick, toxic brand of spray paint, infamous for permanently marking spots all over the galaxy. No points for guessing their slogan."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan_gang"
	item_state = "spraycan"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	object_flags = NO_GHOSTCRITTER
	var/in_use = FALSE
	var/empty = FALSE

	New()
		..()
		src.setItemSpecial(/datum/item_special/graffiti)

	attack_self(mob/user)
		if (ON_COOLDOWN(src,"shake",1 SECOND))
			user.visible_message(SPAN_ALERT("[user] shakes the [src.name]!"))
			playsound(user.loc, 'sound/items/graffitishake.ogg', 50, FALSE)

	afterattack(target, mob/user)
		do_gang_tag(target,user)
	/// Checks a tile has no nearby claims from other tags
	proc/check_tile_unclaimed(turf/target, mob/user)
		// check it's far enough from another tag to claim
		for_by_tcl(tag, /obj/decal/gangtag)
			if(!IN_EUCLIDEAN_RANGE(tag, target, GANG_TAG_SIGHT_RANGE)) continue
			if (tag.owners == user.get_gang() && tag.active)
				boutput(user, SPAN_ALERT("This is too close to an existing tag!"))
				return
		// check it's far enough from lockers
		for_by_tcl(locker, /obj/ganglocker)
			if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_SIGHT_RANGE_LOCKER)) continue
			if (locker.gang == user.get_gang())
				boutput(user, SPAN_ALERT("This is too close to your locker!"))
				return

		var/tagging_over = FALSE
		var/obj/decal/gangtag/existingTag
		for (var/obj/decal/gangtag/turfTag in target.contents)
			if (turfTag.active)
				existingTag = turfTag

		var/validLocation = FALSE
		if (existingTag)
			if (existingTag.owners != user.get_gang())
				//if we're tagging over someone's tag, double our search radius
				//(this will find any tags whose influence intersects with the target tag's influence)
				for_by_tcl(locker, /obj/ganglocker)
					if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_INFLUENCE_LOCKER+GANG_TAG_INFLUENCE)) continue
					if (locker.gang == user.get_gang())
						validLocation = TRUE
				for_by_tcl(otherTag, /obj/decal/gangtag)
					//if we can see one of our own tags in 2x the influence, then these tags are touching
					if(!IN_EUCLIDEAN_RANGE(otherTag, target, GANG_TAG_INFLUENCE*2)) continue
					if (otherTag.owners && otherTag.owners == user.get_gang() && otherTag.active)
						validLocation = TRUE
						tagging_over = TRUE
			else
				boutput(user, SPAN_ALERT("You can't spray over your own tags!"))
				return GANG_CLAIM_INVALID
		else
			//we're tagging, check it's in our territory and not someone else's territory
			for_by_tcl(tag, /obj/decal/gangtag)
				if(!IN_EUCLIDEAN_RANGE(tag, target, GANG_TAG_INFLUENCE)) continue
				if (tag.owners == user.get_gang())
					validLocation = TRUE
				else if (tag.owners && tag.active)
					boutput(user, SPAN_ALERT("You can't spray in another gang's territory! Spray over their tag, instead!"))
					if (user.GetComponent(/datum/component/tracker_hud))
						return GANG_CLAIM_INVALID
					var/datum/game_mode/gang/mode = ticker.mode
					if (!istype(mode))
						return GANG_CLAIM_INVALID
					user.AddComponent(/datum/component/tracker_hud/gang, get_turf(tag))
					SPAWN(3 SECONDS)
						var/datum/component/tracker_hud/gang/component = user.GetComponent(/datum/component/tracker_hud/gang)
						component.RemoveComponent()
					return GANG_CLAIM_INVALID
			for_by_tcl(locker, /obj/ganglocker)
				if(!IN_EUCLIDEAN_RANGE(locker, target, GANG_TAG_INFLUENCE_LOCKER)) continue
				if (locker.gang == user.get_gang())
					validLocation = TRUE
				else
					boutput(user, SPAN_ALERT("There's better places to tag than near someone else's locker! "))
					return GANG_CLAIM_INVALID

		if(!validLocation)
			boutput(user, SPAN_ALERT("This is outside your gang's influence!"))
			return GANG_CLAIM_INVALID

		var/area/getarea = get_area(target)
		if(!getarea)
			boutput(user, SPAN_ALERT("You can't claim this place!"))
			return GANG_CLAIM_INVALID
		if(getarea.name == "Space")
			boutput(user, SPAN_ALERT("You can't claim space!"))
			return GANG_CLAIM_INVALID
		if(getarea.name == "Ocean")
			boutput(user, SPAN_ALERT("You can't claim the entire ocean!"))
			return GANG_CLAIM_INVALID
		if((getarea.teleport_blocked) || istype(getarea, /area/supply) || istype(getarea, /area/shuttle/))
			boutput(user, SPAN_ALERT("You can't claim this place!"))
			return GANG_CLAIM_INVALID
		if(!ishuman(user))
			boutput(user, SPAN_ALERT("You don't have the dexterity to spray paint a gang tag!"))
			return GANG_CLAIM_INVALID

		if (validLocation)
			if (tagging_over)
				return GANG_CLAIM_TAKEOVER
			else
				return GANG_CLAIM_VALID

		return GANG_CLAIM_INVALID

	proc/do_gang_tag(target, mob/user)
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
		var/gang_claim = check_tile_unclaimed(turftarget, user)
		if (gang_claim == GANG_CLAIM_TAKEOVER)
			user.visible_message(SPAN_ALERT("[user] begins to spray over a gang tag on the [turftarget.name]!"))
			actions.start(new/datum/action/bar/icon/spray_gang_tag(turftarget, src, TRUE), user)
		else if (gang_claim == GANG_CLAIM_VALID)
			user.visible_message(SPAN_ALERT("[user] begins to paint a gang tag on the [turftarget.name]!"))
			actions.start(new/datum/action/bar/icon/spray_gang_tag(turftarget, src, FALSE), user)
/obj/item/spray_paint_graffiti
	name = "'ProPaint' spray paint can"
	desc = "A can of gloss spray paint. Great for doing wicked sick art. Not so great when the janitor shows up."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan"
	item_state = "spraycan"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL
	object_flags = NO_GHOSTCRITTER
	var/in_use = FALSE
	var/list/turf/graffititargets = list()
	var/list/image/targetoverlay = list()
	var/charges = GANG_VANDALISM_GRAFFITI_MAX
	var/tagging_horizontally = FALSE
	var/tagging_vertically = FALSE
	var/tagging_direction
	var/list/tags_single
	var/list/tags_double
	var/list/tags_triple

	w_class = W_CLASS_TINY

	update_icon()
		if (charges > 0 )
			inventory_counter?.update_number(charges)
		else
			inventory_counter?.update_text("-")
		..()

	New()
		inventory_counter_enabled = TRUE
		refresh_single_tags()
		refresh_double_tags()
		refresh_triple_tags()
		..()
		src.setItemSpecial(/datum/item_special/graffiti)
	attack_self(mob/user)
		if (ON_COOLDOWN(src,"shake",1 SECOND))
			user.visible_message(SPAN_ALERT("[user] shakes the [src.name]!"))
			playsound(user.loc, 'sound/items/graffitishake.ogg', 50, FALSE)

	afterattack(target, mob/user)
		do_graffiti(target,user)

	proc/clear_targets()
		graffititargets = list()
		tagging_horizontally = FALSE
		tagging_vertically = FALSE
		for (var/image/image in targetoverlay)
			targetoverlay -= image
			qdel(image)
	proc/add_target(mob/user, turf/turftarget)
		graffititargets += turftarget
		var/image/target_image = image('icons/effects/effects.dmi', turftarget)
		targetoverlay += target_image
		target_image.icon_state = "tile_channel_target"
		target_image.layer = NOLIGHT_EFFECTS_LAYER_BASE
		user << target_image



	proc/refresh_single_tags()
		tags_single = list()
		for (var/i=1 to 16)
			tags_single += i
	proc/refresh_double_tags()
		tags_double = list()
		for (var/i=1 to 13)
			tags_double += i
	proc/refresh_triple_tags()
		tags_triple = list()
		for (var/i=1 to 17)
			tags_triple += i

	proc/do_graffiti(target, mob/user)
		if(!istype(target,/turf) && !istype(target,/obj/decal/gangtag)) return

		if (!user)
			return
		if (length(graffititargets) + 1 > charges)
			return
		var/turf/turftarget = get_turf(target)

		if(BOUNDS_DIST(src, target) > 0 || (turftarget in graffititargets) || turftarget == get_turf(user)) //spraying at your feet messes with math
			return
		if(in_use)
			var/valid = FALSE
			for (var/turf/sprayedturf in graffititargets)
				var/relative_dir = get_dir(turftarget,sprayedturf)
				if (BOUNDS_DIST(sprayedturf, turftarget) == 0 && (relative_dir in cardinal))
					if (tagging_horizontally && (relative_dir == WEST || relative_dir == EAST))
						valid = TRUE
						break
					if (tagging_vertically && (relative_dir == NORTH || relative_dir == SOUTH))
						valid = TRUE
						break
					if (!tagging_horizontally && !tagging_vertically)
						valid = TRUE
						break
			if (!valid)
				boutput(user, SPAN_ALERT("You are already tagging elsewhere!"))
				return

		user.visible_message(SPAN_ALERT("[user] begins to spray graffiti on the [turftarget.name]!"))
		if (!actions.hasAction(user,/datum/action/bar/icon/spray_graffiti,FALSE))
			actions.start(new/datum/action/bar/icon/spray_graffiti(src), user)
			clear_targets()
			add_target(user, turftarget)
			var/chosen_dir = get_dir(turftarget,user)
			if (chosen_dir)
				tagging_direction = chosen_dir
			else
				tagging_direction = SOUTH
		else if (length(graffititargets) == 1)
			var/chosen_dir = get_dir(turftarget,user)
			var/direction_check = get_dir(turftarget,graffititargets[1])
			if (direction_check == NORTH || direction_check == SOUTH)
				tagging_vertically = TRUE
				if (chosen_dir == 0)
					tagging_direction = turn(direction_check,-90) & (EAST | WEST)
				else
					tagging_direction = chosen_dir & (EAST | WEST)

			else if (direction_check == EAST || direction_check == WEST)
				tagging_horizontally = TRUE
				if (chosen_dir == 0)
					tagging_direction = turn(direction_check,-90) & (NORTH | SOUTH)
				else
					tagging_direction = chosen_dir & (NORTH | SOUTH)
			add_target(user, turftarget)
		else if (length(graffititargets) < 3)
			add_target(user, turftarget)

/datum/action/bar/icon/spray_gang_tag
	duration = GANG_SPRAYPAINT_TAG_TIME
	interrupt_flags = INTERRUPT_STUNNED
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan"
	var/turf/target_turf
	var/area/target_area
	var/obj/item/spray_paint_gang/spraycan
	/// the mob spraying this tag
	var/mob/M
	/// the gang we're spraying for
	var/datum/gang/gang
	/// when our next spray sound can beplayed
	var/next_spray = 0 DECI SECONDS

	New(var/turf/target_turf as turf, var/obj/item/spray_paint_gang/can, var/tag_over)
		src.target_turf = target_turf
		src.target_area = get_area(target_turf)
		src.spraycan = can
		if (tag_over)
			src.duration = GANG_SPRAYPAINT_TAG_REPLACE_TIME
		..()

	onStart()
		//just being very careful. The icon has to be set before the parent is called, so
		//if something breaks and the parent is not called then you the OnUpdate and OnInterrupt will probably runtime forever.
		try
			if (ismob(owner))
				M = owner
				src.gang = M?.get_gang()
			if (gang)
				icon = 'icons/obj/decals/gang_tags.dmi'
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

		spraycan.in_use = TRUE
		playsound(target_turf, 'sound/items/graffitishake.ogg', 50, FALSE)
		next_spray += rand(10,15) DECI SECONDS

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target_turf) > 0 || target_turf == null || !owner || !(spraycan in M.equipped_list()))
			interrupt(INTERRUPT_ALWAYS)
			return
		if(src.time_spent() > next_spray)
			next_spray += rand(18,26) DECI SECONDS
			playsound(target_turf, 'sound/items/graffitispray3.ogg', 100, TRUE)

	onInterrupt(var/flag)
		boutput(owner, SPAN_ALERT("You were interrupted!"))
		if (spraycan)
			spraycan.in_use = FALSE
		..()

	onEnd()
		var/mob/M = owner
		..()
		if(BOUNDS_DIST(owner, target_turf) > 0 || target_turf == null || !owner || !(spraycan in M.equipped_list()))
			interrupt(INTERRUPT_ALWAYS)
			return
		if(!spraycan.check_tile_unclaimed(target_turf, owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		spraycan.in_use = FALSE
		target_area.being_captured = FALSE
		var/sprayOver = FALSE
		for (var/obj/decal/gangtag/otherTag in range(1,target_turf))
			otherTag.disable()
			sprayOver = TRUE

		src.gang.make_tag(target_turf)
		spraycan.empty = TRUE
		spraycan.icon_state = "spraycan_crushed_gang"
		spraycan.setItemSpecial(/datum/item_special/simple)
		spraycan.tooltip_rebuild = 1
		gang.add_points(GANG_SPRAYPAINT_INSTANT_SCORE, M, showText = TRUE)
		if(sprayOver)
			logTheThing(LOG_GAMEMODE, owner, "[owner] has successfully tagged the [target_area], spraying over another tag.")
		else
			logTheThing(LOG_GAMEMODE, owner, "[owner] has successfully tagged the [target_area]")
		boutput(M, SPAN_NOTICE("You have claimed this area for your gang and gained bonus points!"))


/datum/action/bar/icon/spray_graffiti
	duration = 100 SECONDS
	interrupt_flags = INTERRUPT_STUNNED
	icon = 'icons/obj/items/items.dmi'
	icon_state = "spraycan"
	var/obj/item/spray_paint_graffiti/spraycan
	/// the mob spraying this tag
	var/mob/M
	/// the gang we're spraying for
	var/datum/gang/gang
	/// when our next spray sound can beplayed
	var/next_spray = 0 DECI SECONDS

	New(obj/item/spray_paint_graffiti/S)
		src.spraycan = S
		..()

	onStart()
		if (ismob(owner))
			M = owner
			var/ownerGang = M?.get_gang()
			if (ownerGang)
				gang = ownerGang
		..()

		for (var/turf/sprayedturf in spraycan.graffititargets)
			if (BOUNDS_DIST(owner, sprayedturf) > 0)
				interrupt(INTERRUPT_ALWAYS)
				return

		spraycan.in_use = TRUE
		next_spray += rand(10,15) DECI SECONDS

	onUpdate()
		..()
		for (var/turf/sprayedturf in spraycan.graffititargets)
			if (BOUNDS_DIST(owner, sprayedturf) > 0)
				interrupt(INTERRUPT_ALWAYS)
				return
		if(src.time_spent() > next_spray)
			next_spray += rand(18,26) DECI SECONDS
			playsound(owner.loc, 'sound/items/graffitispray3.ogg', 100, TRUE)
		var/new_duration = duration
		switch (length(spraycan.graffititargets))
			if (1)
				new_duration = 2 SECONDS
			if (2)
				new_duration = 4 SECONDS
			if (3)
				new_duration = 6 SECONDS
		if (new_duration != duration)
			duration = new_duration
			updateBar()

	onInterrupt(flag)
		boutput(owner, SPAN_ALERT("You were interrupted!"))
		if (spraycan)
			spraycan.in_use = FALSE
			spraycan.clear_targets()
		..()

	onEnd()
		..()
		for (var/turf/sprayedturf in spraycan.graffititargets)
			if (BOUNDS_DIST(owner, sprayedturf) > 0)
				interrupt(INTERRUPT_ALWAYS)
				return
		if(!owner)
			interrupt(INTERRUPT_ALWAYS)
			return
		spraycan.in_use = FALSE
		var/iconstate
		var/targets = length(spraycan.graffititargets)
		switch (targets)
			if (1)
				var/result = pick(spraycan.tags_single)
				spraycan.tags_single -= result
				iconstate = "graffiti-single-[result]"
				if (length(spraycan.tags_single) == 0)
					spraycan.refresh_single_tags()
			if (2)
				var/result = pick(spraycan.tags_double)
				spraycan.tags_double -= result
				iconstate = "graffiti-dbl-[result]-"
				if (length(spraycan.tags_double) == 0)
					spraycan.refresh_double_tags()
			if (3)
				var/result = pick(spraycan.tags_triple)
				spraycan.tags_triple -= result
				iconstate = "graffiti-trpl-[result]-"
				if (length(spraycan.tags_triple) == 0)
					spraycan.refresh_triple_tags()
		spraycan.charges -= targets
		spraycan.UpdateIcon()
		if (targets == 1)
			var/vandalism_points = 0
			if(!(locate(/obj/decal/cleanable/gang_graffiti) in spraycan.graffititargets[1]))
				vandalism_points += GANG_VANDALISM_PER_GRAFFITI_TILE
			var/obj/decal/cleanable/gang_graffiti/tag = new/obj/decal/cleanable/gang_graffiti(spraycan.graffititargets[1])
			tag.icon_state = iconstate
			tag.dir = spraycan.tagging_direction
			gang?.do_vandalism(vandalism_points, spraycan.graffititargets[1])
		else
			var/list/turf/turfs_ordered = new/list(length(spraycan.graffititargets))
			var/spraydirection = dir_to_angle(spraycan.tagging_direction)
			var/vec = angle_to_vector(spraydirection)
			var/min_distance = 1000
			// the smallest X/Y coord, depending on if X/Y used
			for (var/i = 1 to targets)
				min_distance = min(vec[2] * spraycan.graffititargets[i].y - vec[1] * spraycan.graffititargets[i].x , min_distance)

			//sorts tags by their distance from min_distance, 1-3
			for (var/sorting = 1 to targets)
				var/dist = (vec[2] * spraycan.graffititargets[sorting].y -vec[1] * spraycan.graffititargets[sorting].x ) - min_distance
				turfs_ordered[dist+1] = spraycan.graffititargets[sorting]

			var/vandal_score = 0
			var/turf/chosenTurf
			for (var/i = 1 to targets)
				if(!(locate(/obj/decal/cleanable/gang_graffiti) in turfs_ordered[i]))
					vandal_score += GANG_VANDALISM_PER_GRAFFITI_TILE
				var/obj/decal/cleanable/gang_graffiti/tag = new/obj/decal/cleanable/gang_graffiti(turfs_ordered[i])
				var/area = get_area(turfs_ordered[i])
				tag.icon_state = "[iconstate][i]"
				tag.dir = spraycan.tagging_direction

				if (gang && !chosenTurf)
					for (var/area/targetArea as anything in gang.vandalism_tracker)
						if (istype(area,targetArea))
							chosenTurf = turfs_ordered[i]
							break
			gang?.do_vandalism(vandal_score, chosenTurf)


		spraycan.clear_targets()
		playsound(spraycan.loc, 'sound/effects/graffiti_hit.ogg', 20, TRUE)
		if (spraycan.charges == 0)
			boutput(M, SPAN_ALERT("The graffiti can's empty!"))
			playsound(M.loc, "sound/items/can_crush-[rand(1,3)].ogg", 50, 1)
			spraycan.icon_state = "spraycan_crushed"
			spraycan.setItemSpecial(/datum/item_special/simple)
			spraycan.tooltip_rebuild = 1


/obj/ganglocker
	desc = "Gang locker."
	name = "gang closet"
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "gang"
	density = FALSE
	anchored = ANCHORED
	object_flags = NO_GHOSTCRITTER
	/// gang that owns this locker
	var/datum/gang/gang = null
	/// the overlay this locker should show, after doing stuff like blinking red for errors
	var/image/default_screen_overlay = null
	var/HTML = null

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

	/// Tracks how many units of each drug this gang has inserted
	var/list/tracked_drugs_list = list()
	/// Tracks how many points' worth of drugs have been inserted, after the GANG_DRUG_BONUS_CAP
	var/untracked_drugs_score = 0
	/// How many leaves of weed have been given in
	var/gang_weed = 0
	/// If this locker is hiding under the floor
	var/is_hiding = FALSE
	/// The turf this locker is registered as hiding under
	var/registered_turf = 0

	New()
		START_TRACKING
		..()
		default_screen_overlay = image('icons/obj/large_storage.dmi', "gang_overlay_yellow")
		src.UpdateOverlays(default_screen_overlay, "screen")
		buyable_items = list(
			new/datum/gang_item/consumable/medkit,
			new/datum/gang_item/consumable/omnizine,
			new/datum/gang_item/consumable/quickhack,
			new/datum/gang_item/consumable/tipoff,
			new/datum/gang_item/equipment/graffiti,
			new/datum/gang_item/equipment/armor,
			new/datum/gang_item/weapon/throwing_knife,
			new/datum/gang_item/weapon/shuriken,
			new/datum/gang_item/weapon/ratstick,
			new/datum/gang_item/weapon/switchblade,
			new/datum/gang_item/weapon/baseball,
			new/datum/gang_item/weapon/machete,
			new/datum/gang_item/weapon/discount_katana,
			new/datum/gang_item/weapon/discount_csaber,
			new/datum/gang_item/special/cop_car)

	disposing(var/uncapture = 1)
		STOP_TRACKING
		..()

	examine()
		. = ..()
		. += "The screen displays \"Total Score: [gang.gang_score()]\""

	attack_hand(var/mob/user)
		if(!isalive(user))
			boutput(user, SPAN_ALERT("Not when you're incapacitated."))
			return
		if(!isliving(user))
			boutput(user, SPAN_ALERT("You're too, er, dead."))
			return

		add_fingerprint(user)

		// if (!src.HTML)
		var/page = src.generate_HTML(user)

		user.Browse(page, "window=gang_locker;size=650x670")
		//onclose(user, "gang_locker")

	ex_act()
		return //no!

	proc/set_gang(datum/gang/gang)
		src.name = "[gang.gang_name] Locker"
		src.desc = "A locker with a small screen attached to the door, and the words 'Property of [gang.gang_name] - DO NOT TOUCH!' scratched into both sides."
		src.gang = gang
		src.UpdateIcon()

		var/image/antag_icon = image('icons/mob/antag_overlays.dmi', icon_state = "gang_locker_[src.gang.color_id]", loc=src)
		antag_icon.appearance_flags = PIXEL_SCALE | RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART
		get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS).add_image(antag_icon)
		get_image_group(src.gang).add_image(antag_icon)

	//puts the html string in the var/HTML on src
	proc/generate_HTML(var/mob/living/carbon/human/user)
		var/datum/mind/M = user.mind
		var/dat = {"<HTML>
		<div style="width: 100%; overflow: hidden;">
			<div style="height: 150px;width: 290px;padding-left: 5px;; float: left;border-style: solid; text-align: center;">
				<center style="padding-top: 25px;"><font size="5"><a href='byond://?src=\ref[src];get_gear=1'>Get gear</a></font></center><br>
				<font size="3">The gang has [gang.spray_paint_remaining] spray paints remaining.
				<br>
				<font size="3">Spray paint will restock at [gang.next_spray_paint_restock].
				</font>
				<center><font size="5"><a href='byond://?src=\ref[src];get_spray=1'>Grab spraypaint</a></font></center><br>
			</div>
			<div>
			<div style="height: 72px;width: 290px;padding-left: 5px;; float: left;border-style: solid; text-align: center;">
				[(is_leader_cryod() || src.gang.leader_claimable) ? {"<font size="3"><a href='byond://?src=\ref[src];claim_leader=1'>Become the leader!</a></font>"}: {"
				<font size="3">[src.gang.leader == user.mind ? {"You have [gang.street_cred] street cred!"} : {"You aren't the leader!"} ] </font><br>
				<font size="3"><a href='byond://?src=\ref[src];respawn_new=1'>Recruit a new member:</a></font> [src.gang.current_newmember_price] cred<br>
				<font size="3"><a href='byond://?src=\ref[src];respawn_syringe=1'>Buy a revival stim:</a></font> [src.gang.current_revival_price] cred<br>
				"}]
			</div>
			<div style="height: 72px;width: 290px;padding-left: 5px;; float: left;border-style: solid; text-align: center;">
				<center><font size="3"><a href='byond://?src=\ref[src];get_drugs=1'>List drug prices</a></font></center><br>
				<center><font size="3"><a href='byond://?src=\ref[src];get_scoreboard=1'>Scoreboard</a></font></center><br>
			</div>
			</div>
		</div>
		<HR>
		<font size="3">You have [src.gang.gang_points[M]] points to spend! These aren't shared with your gang.</font>
		<HR>
		"}


		dat += {"
		<table>
		"}

		dat += "<tr><td align=\"center\" colspan=\"4\"><font size=\"2\"><b>Consumables</b></font></td></tr>"
		var/list/items = list()
		for (var/datum/gang_item/consumable/GI in buyable_items)
			if (items[GI.category] == null)
				items[GI.category] = list()
			var/icon_rsc = getItemIcon(initial(GI.item_path), C = user.client)
			dat += "<tr><td><img class='icon' src='[icon_rsc]'></td><td><a href='byond://?src=\ref[src];buy_item=\ref[GI]'>[GI.name]</a></td><td>[GI.price]</td><td>[GI.desc]</td></tr>"
		dat += "<tr><td align=\"center\" colspan=\"4\"><font size=\"2\"><b>Equipment</b></font></td></tr>"
		for (var/datum/gang_item/equipment/GI in buyable_items)
			if (items[GI.category] == null)
				items[GI.category] = list()
			var/icon_rsc = getItemIcon(initial(GI.item_path), C = user.client)
			dat += "<tr><td><img class='icon' src='[icon_rsc]'></td><td><a href='byond://?src=\ref[src];buy_item=\ref[GI]'>[GI.name]</a></td><td>[GI.price]</td><td>[GI.desc]</td></tr>"

		dat += "<tr><td align=\"center\" colspan=\"4\"><font size=\"2\"><b>Weapons</b></font></td></tr>"
		for (var/datum/gang_item/weapon/GI in buyable_items)
			if (items[GI.category] == null)
				items[GI.category] = list()
			var/icon_rsc = getItemIcon(initial(GI.item_path), C = user.client)
			dat += "<tr><td><img class='icon' src='[icon_rsc]'></td><td><a href='byond://?src=\ref[src];buy_item=\ref[GI]'>[GI.name]</a></td><td>[GI.price]</td><td>[GI.desc]</td></tr>"

		dat += "<tr><td align=\"center\" colspan=\"4\"><font size=\"2\"><b>Special</b></font></td></tr>"
		for (var/datum/gang_item/special/GI in buyable_items)
			if (items[GI.category] == null)
				items[GI.category] = list()
			var/icon_rsc = getItemIcon(initial(GI.item_path), C = user.client)
			dat += "<tr><td><img class='icon' src='[icon_rsc]'></td><td><a href='byond://?src=\ref[src];buy_item=\ref[GI]'>[GI.name]</a></td><td>[GI.price]</td><td>[GI.desc]</td></tr>"


		dat += "</table></HTML>"

		return dat

	/// deploys a spraypaint for the user, if possible
	proc/handle_get_spraypaint(var/mob/living/carbon/human/user)
		var/image/overlay = null
		if(user.get_gang() == src.gang)
			if (gang.spray_paint_remaining > 0)
				gang.spray_paint_remaining--
				user.put_in_hand_or_drop(new /obj/item/spray_paint_gang(user.loc))
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
		if (href_list["get_drugs"])
			print_drug_prices(usr)
		if (href_list["get_scoreboard"])
			print_scoreboard(usr)
		if (href_list["claim_leader"])
			claim_leadership(usr)
		if (href_list["buy_item"])
			if (usr.get_gang() != src.gang)
				boutput(usr, SPAN_ALERT("You are not a member of this gang, you cannot purchase items from it."))
				return
			var/datum/gang_item/GI = locate(href_list["buy_item"])
			if (locate(GI) in buyable_items)
				if (GI.price <= src.gang.gang_points[usr.mind])
					src.gang.gang_points[usr.mind] -= GI.price

					boutput(usr, SPAN_NOTICE("You purchase [GI.name] for [GI.price]. Remaining balance = [src.gang.gang_points[usr.mind]] points."))
					if (!GI.on_purchase(src, usr))
						new GI.item_path(src.loc)
					gang.items_purchased[GI.item_path]++
					updateDialog()
				else
					boutput(usr, SPAN_ALERT("Insufficient funds."))

	proc/increase_janktank_price()
		src.janktank_price = round(src.janktank_price * 1.1)

		for (var/datum/gang/gang in get_all_gangs())
			var/datum/gang_item/equipment/janktank/JT = locate(/datum/gang_item/equipment/janktank) in gang.locker.buyable_items
			JT.price = janktank_price

	proc/is_leader_cryod()
		var/mob/gangleader = src.gang.leader?.current
		if (gangleader && istype(gangleader.loc, /obj/cryotron))
			var/obj/cryotron/cryo = gangleader.loc
			var/cryoTime = cryo.stored_mobs[gangleader]
			if (TIME - cryoTime > GANG_CRYO_LOCKOUT)
				return TRUE
		return FALSE

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
				var/datum/mind/chosenPlayer = tgui_input_list(usr, "Select a gang member to remove.", "Remove Gang Member", members)
				if (!chosenPlayer)
					return
				else
					members[chosenPlayer].remove_antagonist(ROLE_GANG_MEMBER)

		boutput(user, "Hunting for a new member...")
		try_gang_respawn(user)

	/// Respawns a mind as a new gang member
	proc/gang_respawn(var/datum/mind/target)
		if (target.get_antagonist("gang_leader"))
			target.remove_antagonist(ROLE_GANG_LEADER)
		else
			target.remove_antagonist(ROLE_GANG_MEMBER)
		var/mob/living/carbon/human/normal/H = new/mob/living/carbon/human/normal(src.loc)
		H.initializeBioholder(target.current?.client?.preferences?.gender) //try to preserve gender if we can
		SPAWN(0)
			H.JobEquipSpawned("Gang Respawn")
			target.transfer_to(H)
			target.add_subordinate_antagonist(ROLE_GANG_MEMBER, master = src.gang.leader)
			message_admins("[key_name(target)] respawned as a gang member for [src.gang.gang_name].")
			log_respawn_event(target, "gang member respawn", src.gang.gang_name)
			boutput(H, SPAN_NOTICE("<b>You have been respawned as a gang member!</b>"))
			if (src.gang.leader)
				boutput(H, SPAN_ALERT("<b>You're allied with [src.gang.gang_name]! Work with your leader, [src.gang.leader.current.real_name], to become the baddest gang ever!</b>"))
			else
				boutput(H, SPAN_ALERT("<b>You're allied with [src.gang.gang_name]! Work to become the baddest gang ever!</b>"))
			get_gang_gear(H)

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
			logTheThing(LOG_ADMIN, null, "Couldn't set up gang member respawn for gang [src.name] ; gang full. Source: [user]")
			boutput(user, "Your gang is full, search for a new candidate cancelled.")
			return

		if (!islist(candidates) || !length(candidates))
			message_admins("Couldn't set up gang member respawn for [src.gang.gang_name]; no ghosts responded. Source: [user]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up gang member respawn for gang [src.name]; no ghosts responded. Source: [user]")
			boutput(user, "We couldn't find any new recruits. Your street cred is refunded.")
			gang.street_cred += gang.current_newmember_price
			return

		var/datum/mind/lucky_dude = candidates[1]

		if (lucky_dude.current)
			gang_respawn(lucky_dude)
			gang.current_newmember_price = round(gang.current_newmember_price*GANG_NEW_MEMBER_COST_MULT/100)*100
		else
			message_admins("Couldn't set up gang member respawn for [src.gang.gang_name]; [lucky_dude] had no current mob. Source: [user]")
			logTheThing(LOG_DEBUG, null, "Couldn't set up gang member respawn for gang [src.name]; [lucky_dude] had no current mob. Source: [user]")

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
		gang.current_revival_price = round(gang.current_revival_price*GANG_REVIVE_COST_MULT/100)*100

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
			uniform.setProperty("meleeprot", 2)
			uniform.setProperty("rangedprot", 0)

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

		var/datum/antagonist/antag_datum = user.mind.get_antagonist(ROLE_GANG_MEMBER) || user.mind.get_antagonist(ROLE_GANG_LEADER)
		if (!(antag_datum in src.gang.free_gun_owners))
			var/gun_type = pick(/obj/item/gun/kinetic/lopoint, /obj/item/gun/energy/lasergat)
			user.stow_in_available(new gun_type(user.loc), FALSE)
			if (antag_datum.id == ROLE_GANG_LEADER)
				if (gun_type == /obj/item/gun/kinetic/lopoint)
					user.stow_in_available(new /obj/item/ammo/bullets/bullet_9mm/lopoint)
				else
					user.stow_in_available(new /obj/item/ammo/power_cell/lasergat)
			src.gang.free_gun_owners += antag_datum

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
			var/obj/item/currency/spacecash/cashObj = new(src.loc,stolenCash)
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
			var/obj/item/currency/spacecash/cash = item

			var/cash_to_take = max(0,min(GANG_LAUNDER_CAP-stored_cash, cash.amount))

			if (cash.hasStatus("freshly_laundered"))
				superlaunder_stacks += round(cash_to_take/(GANG_LAUNDER_RATE*1.5))

			if (cash_to_take == 0)
				boutput(user, SPAN_ALERT("<b>You've crammed the money laundering slot full! Let it launder some.<b>"))
				return
			if (stored_cash == 0)
				boutput(user, SPAN_ALERT("The [src] boots up and starts laundering the money. This will take some time, so defend it!"))
			if (cash_to_take < cash.amount)
				stored_cash += cash_to_take
				cash.amount -= cash_to_take
				boutput(user, SPAN_ALERT("<b>You load [cash_to_take][CREDIT_SIGN] into the [src.name], the laundering slot is full.<b>"))
				cash.UpdateStackAppearance()
				return
			stored_cash += cash.amount

		//gun score
		else if (istype(item, /obj/item/gun))
			if(istype(item, /obj/item/gun/kinetic/foamdartgun))
				boutput(user, SPAN_ALERT("<b>You cant stash toy guns in the locker</b>"))

				return

			if(istype(item, /obj/item/gun/kinetic/slamgun) || istype(item, /obj/item/gun/kinetic/zipgun))
				boutput(user, SPAN_ALERT("<b>This shoddy firearm isn't worth selling.</b>"))
				return
			else
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
				if (istype(item, /obj/item/reagent_containers/glass))
					boutput(user, SPAN_ALERT("It seems whatever's in your beaker is valueless."))
					return TRUE
				return FALSE
			gang.add_points(temp_score_drug,user)
			aggregate_score(temp_score_drug)
			gang.score_drug += temp_score_drug
			if (istype(item, /obj/item/reagent_containers/glass))
				item.reagents.clear_reagents()
				boutput(user, SPAN_ALERT("You pour the contents of the beaker into the handy drug receptacle."))
				return FALSE

		else if (istype(item, /obj/item/storage/pill_bottle))
			var/itemInserted = FALSE
			for (var/obj/item/sub_item in item.contents)
				var/temp_score_drug = get_I_score_drug(sub_item)
				if(temp_score_drug == 0)
					continue
				itemInserted = TRUE
				gang.add_points(temp_score_drug,user)
				aggregate_score(temp_score_drug)
				gang.score_drug += temp_score_drug
				sub_item.dropped(user)
				sub_item.set_loc(src)
			if (itemInserted)
				boutput(user, SPAN_ALERT("You add the contents of the pill bottle to the handy drug receptacle."))
			return FALSE


		user.u_equip(item)
		item.dropped(user)
		add_fingerprint(user)
		item.set_loc(src)

		return 1

	/// Calculate the score of provided drugs, adding them to the total acquired
	proc/do_drug_score(obj/O, drug, price_per_unit)
		if (!(drug in tracked_drugs_list))
			tracked_drugs_list[drug] = 0
		var/volume = round(O.reagents.get_reagent_amount(drug))
		var/score = 0
		if (volume <= 0)
			return
		var/bonus_volume = clamp((GANG_DRUG_BONUS_CAP - tracked_drugs_list[drug]), 0, volume)
		var/regular_volume = volume - bonus_volume
		/// Bonus score for finding small amounts of each drug
		tracked_drugs_list[drug] += volume
		score += round(price_per_unit * GANG_DRUG_BONUS_MULT * bonus_volume)
		/// Regular score afterwards
		if (regular_volume > 0)
			var/multiplier = max(0,((GANG_DRUG_LIMIT) - (tracked_drugs_list[drug]-GANG_DRUG_BONUS_CAP))/GANG_DRUG_LIMIT)*(GANG_DRUG_BONUS_MULT/2)
			var/untracked_score = round(price_per_unit * multiplier * regular_volume)
			score += untracked_score
		return score

	/// Get the price per unit of a drug, taking into account multipliers
	proc/get_drug_score(drug, price_per_unit)
		if (!(drug in tracked_drugs_list))
			tracked_drugs_list[drug] = 0
		if (tracked_drugs_list[drug] < GANG_DRUG_BONUS_CAP)
			return price_per_unit * GANG_DRUG_BONUS_MULT
		var/multiplier = max(0,((GANG_DRUG_LIMIT) - (tracked_drugs_list[drug]-GANG_DRUG_BONUS_CAP))/GANG_DRUG_LIMIT)*(GANG_DRUG_BONUS_MULT/2)
		return price_per_unit * multiplier

	proc/drug_hotness(drug)
		if (!(drug in tracked_drugs_list))
			return GANG_DRUG_BONUS_CAP
		else if(tracked_drugs_list[drug] < GANG_DRUG_BONUS_CAP)
			return (GANG_DRUG_BONUS_CAP-tracked_drugs_list[drug])
		return 0
	/// get the score of an item given the drugs inside
	proc/get_I_score_drug(var/obj/O)
		var/score = 0
		score += do_drug_score(O,"bathsalts", GANG_DRUG_SCORE_BATHSALTS)
		score += do_drug_score(O,"morphine", GANG_DRUG_SCORE_MORPHINE)
		score += do_drug_score(O,"crank", GANG_DRUG_SCORE_CRANK)
		score += do_drug_score(O,"LSD", GANG_DRUG_SCORE_LSD)
		score += do_drug_score(O,"lsd_bee", GANG_DRUG_SCORE_LSBEE)
		score += do_drug_score(O,"THC", GANG_DRUG_SCORE_THC)
		score += do_drug_score(O,"space_drugs", GANG_DRUG_SCORE_SPACEDRUGS)
		score += do_drug_score(O,"psilocybin", GANG_DRUG_SCORE_PSILOCYBIN)
		score += do_drug_score(O,"krokodil", GANG_DRUG_SCORE_KROKODIL)
		score += do_drug_score(O,"catdrugs", GANG_DRUG_SCORE_CATDRUGS)
		score += do_drug_score(O,"methamphetamine", GANG_DRUG_SCORE_METH)
		//uncapped because weed is cool
		//now capped because weed was too cool
		if(istype(O, /obj/item/plant/herb/cannabis) && gang_weed < GANG_WEED_LIMIT)
			gang_weed++
			score += 10
		return round(score)

	proc/claim_leadership(var/mob/living/carbon/human/user)
		if (user.get_gang() != src.gang)
			boutput(user, "You aren't part of this gang!")
			return

		if (!src.gang.leader_claimable && !is_leader_cryod())
			boutput(user, "You can't claim the role of leader right now!")
			return
		src.gang.leader_claimable = FALSE
		var/datum/antagonist/leaderRole = src.gang.leader.get_antagonist(ROLE_GANG_LEADER)
		var/datum/antagonist/oldRole = user.mind.get_antagonist(ROLE_GANG_MEMBER)
		oldRole.silent = TRUE // so they dont get a spooky 'you are no longer a gang member' popup!
		user.mind.remove_antagonist(ROLE_GANG_MEMBER,ANTAGONIST_REMOVAL_SOURCE_OVERRIDE,FALSE)
		leaderRole.transfer_to(user.mind)
		boutput(user, "You're the leader of your gang now!")
		logTheThing(LOG_ADMIN, user, "claims the role of leader for [src.gang.gang_name].")
		message_admins("[key_name(user)] has claimed the role of leader for their gang, [src.gang.gang_name].")

	proc/print_drug_prices(var/mob/living/carbon/human/user)
		var/text = {"The going prices for drugs are as follows:<br>
		[drug_hotness("bathsalts") ? "*HIGH DEMAND: [drug_hotness("bathsalts")]u* - " : ""] 1u of bathsalts = [get_drug_score("bathsalts", GANG_DRUG_SCORE_BATHSALTS)]<br>
		[drug_hotness("morphine") ? "*HIGH DEMAND: [drug_hotness("morphine")]u* - " : ""]1u of morphine = [get_drug_score("morphine", GANG_DRUG_SCORE_MORPHINE)]<br>
		[drug_hotness("crank") ? "*HIGH DEMAND: [drug_hotness("crank")]u* - " : ""]1u of crank = [get_drug_score("crank", GANG_DRUG_SCORE_CRANK)] <br>
		[drug_hotness("space_drugs") ? "*HIGH DEMAND: [drug_hotness("space_drugs")]u* - " : ""]1u of space drugs = [get_drug_score("space_drugs", GANG_DRUG_SCORE_SPACEDRUGS)] <br>
		[drug_hotness("LSD") ? "*HIGH DEMAND: [drug_hotness("LSD")]u* - " : ""]1u of LSD = [get_drug_score("LSD", GANG_DRUG_SCORE_LSD)] <br>
		[drug_hotness("lsd_bee") ? "*HIGH DEMAND: [drug_hotness("lsd_bee")]u* - " : ""]1u of LSBee = [get_drug_score("lsd_bee", GANG_DRUG_SCORE_LSBEE)] <br
		[drug_hotness("THC") ? "*HIGH DEMAND: [drug_hotness("THC")]u* - " : ""]1u of THC =[get_drug_score("THC", GANG_DRUG_SCORE_THC)] <br>
		[drug_hotness("psilocybin") ? "*HIGH DEMAND: [drug_hotness("psilocybin")]u* - " : ""]1u of psilocybin = [get_drug_score("psilocybin", GANG_DRUG_SCORE_PSILOCYBIN)] <br>
		[drug_hotness("krokodil") ? "*HIGH DEMAND: [drug_hotness("krokodil")]u* - " : ""]1u of krokodil = [get_drug_score("krokodil", GANG_DRUG_SCORE_KROKODIL)] <br>
		[drug_hotness("catdrugs") ? "*HIGH DEMAND: [drug_hotness("catdrugs")]u* - " : ""]1u of cat drugs = [get_drug_score("catdrugs", GANG_DRUG_SCORE_CATDRUGS)] <br>
		[drug_hotness("methamphetamine") ? "*HIGH DEMAND: [drug_hotness("methamphetamine")]u* - " : ""]1u of methamphetamine = [get_drug_score("methamphetamine", GANG_DRUG_SCORE_METH)] <br>
		There is additional demand for [GANG_WEED_LIMIT-gang_weed] leaves of cannabis, for 10 points each."}
		boutput(user, SPAN_ALERT(text))

	proc/print_scoreboard(var/mob/living/carbon/human/user)
		var/text = {"The current scores are:</br>"}
		var/list/datum/gang/scores
		var/datum/game_mode/gang/gamemode = ticker.mode
		scores = sortListCopy(gamemode.gangs, /proc/cmp_gang_score_desc)
		for (var/i=1 to length(scores))
			text += "<b>[i]: [scores[i].gang_name]</b></br>"
		boutput(user, SPAN_ALERT(text))

	proc/turf_attacked(target, mob/user)
		if (!ismob(user))
			return
		if (user.get_gang() != src.gang)
			return
		if(!isalive(user))
			return
		if(!isliving(user) && !issilicon(user))
			return
		if (ON_COOLDOWN(src, "hide_delay", 1 SECOND))
			return
		toggle_hide(!is_hiding)
		if (is_hiding)
			boutput(user,SPAN_NOTICE("You hide your gang's locker."))
		else
			boutput(user,SPAN_NOTICE("You reveal your gang's locker."))

	proc/pre_move_locker()
		gang.unclaim_tiles(src.loc, GANG_TAG_INFLUENCE_LOCKER, GANG_TAG_SIGHT_RANGE_LOCKER)

	proc/post_move_locker()
		if (registered_turf)
			UnregisterSignal(registered_turf, COMSIG_ATTACKHAND)
		toggle_hide(FALSE)
		gang.claim_tiles(src.loc, GANG_TAG_INFLUENCE_LOCKER, GANG_TAG_SIGHT_RANGE_LOCKER)
		registered_turf = get_turf(src)
		RegisterSignal(registered_turf, COMSIG_ATTACKHAND, PROC_REF(turf_attacked))

	proc/toggle_hide(desired)
		if (desired == is_hiding)
			return
		is_hiding = desired
		var/turf/floorturf = get_turf(src)
		animate_slide(floorturf, 0, 22, 4)
		SPAWN(0.4 SECONDS)
			if (!src)
				return
			if(is_hiding)
				src.layer = PLATING_LAYER-0.01
				src.plane = PLANE_FLOOR
				src.mouse_opacity = 0
			else
				src.layer = MOB_LAYER
				src.plane = PLANE_DEFAULT
				src.mouse_opacity = 1
			animate_slide(floorturf, 0, 0, 4)

	proc/cash_amount()
		var/number = 0

		for(var/obj/item/currency/spacecash/cash in contents)
			number += cash.amount

		return round(number)

	proc/gun_amount()
		var/number = 0

		for(var/obj/item/gun/G in contents)
			number ++

		return round(number) //no point rounding it really but fuck it

	attackby(obj/item/W, mob/user)
		if (W.cant_drop)
			return

		if (istype(W,/obj/item/plant/herb/cannabis) || istype(W,/obj/item/gun) || istype(W,/obj/item/currency/spacecash) || istype(W,/obj/item/device/transfer_valve)|| istype(W,/obj/item/storage/pill_bottle))
			if (insert_item(W,user))
				user.visible_message(SPAN_NOTICE("[user] puts [W] into [src]!"))
			return

		//split this out because fire extinguishers should probably not just get stored
		if (W.reagents?.total_volume > 0)
			if (insert_item(W,user))
				user.visible_message(SPAN_NOTICE("[user] puts [W] into [src]!"))
				return

		if(istype(W,/obj/item/satchel))
			var/obj/item/satchel/satchel = W
			var/hadcannabis = 0

			for(var/obj/item/plant/herb/cannabis/herb in satchel.contents)
				insert_item(herb,user)
				satchel.UpdateIcon()
				satchel.tooltip_rebuild = 1
				hadcannabis = 1

			if(hadcannabis)
				boutput(user, SPAN_NOTICE("You empty the cannabis from [satchel] into the [src]."))
			else
				boutput(user, SPAN_NOTICE("[satchel] doesn't contain any cannabis."))
			return

		user.lastattacked = get_weakref(src)
		switch(W.hit_type)
			if (DAMAGE_BURN)
				user.visible_message(SPAN_ALERT("[user] ineffectually hits the [src] with [W]!"))
			else
				attack_particle(user,src)
				hit_twitch(src)
				if (src.stored_cash > 0)
					take_damage(W.force)
					if (W.hitsound)
						playsound(src.loc, W.hitsound, 50, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user] hits the [src] with [W]!</b>"))
				else
					if (W.hitsound)
						playsound(src.loc, W.hitsound, 20, TRUE)
					user.visible_message(SPAN_ALERT("<b>[user] hits the [src] with [W], but it's empty!</b>"))


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
		if(job && (!job.can_be_antag(ROLE_GANG_MEMBER) || !job.can_be_antag(ROLE_GANG_LEADER)))
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
	desc = "A secret cocktail of drugs & spices, reportedly able to bring sufficiently gangster individuals back to life."
	icon = 'icons/obj/items/gang.dmi'
	icon_state = "janktank_2"
	throwforce = 1
	force = 1
	w_class = W_CLASS_TINY
	object_flags = NO_GHOSTCRITTER
	HELP_MESSAGE_OVERRIDE({"Using this on a dying gang member, or their unrotten corpse, will start a short action bar.\n
	On completion, if the syringe is not promptly removed, they will come back to life, disoriented, at low health."})

	attack(mob/O, mob/user)
		if (istype(O, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = O
			if (!H.get_gang() && !H.ghost?.get_gang())
				boutput(user, SPAN_ALERT("They aren't part of a gang! Janktank is <b><i>too cool</i></b> for them."))
				return
			if (H == user)
				boutput(user, SPAN_ALERT("You're not jamming that in yourself!"))
				return
			if (H.decomp_stage)
				boutput(user, SPAN_ALERT("It's too late, they're rotten."))
				return
			if (H.mind?.get_player()?.dnr || H.ghost?.mind?.get_player()?.dnr)
				boutput(user, SPAN_ALERT("Seems they don't want to come back. Huh."))
				return
			if (isdead(H) || H.health < 0)
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
		H.nauseate(6)
		//un-kill organs
		for (var/organ_slot in H.organHolder.organ_list)
			var/obj/item/organ/O = H.organHolder.organ_list[organ_slot]
			if(istype(O))
				O.unbreakme()
		if (H.organHolder) //would be nice to make these heal to desired_health_pct but requires new organHolder functionality...
			H.organHolder.heal_organs(1000,1000,1000, list("brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail"))
		H.remove_ailments()

		setalive(H)

		var/mob/G = find_ghost_by_key((H.mind?.key || H.ghost?.mind?.key))
		logTheThing(LOG_COMBAT, H, "is resuscitated with a JankTank at [log_loc(H)].")

		if (G)
			if (!isdead(G)) // so if they're in VR, the afterlife bar, or a ghostcritter
				G.show_text(SPAN_NOTICE("You feel yourself being pulled out of your current plane of existence!"))
				G.ghostize()?.mind?.transfer_to(H)
			else
				G.show_text(SPAN_ALERT("You feel yourself being dragged out of the afterlife!"))
				G.mind?.transfer_to(H)
			qdel(G)
			H.visible_message(SPAN_ALERT("<b>[H]</b> [pick("barfs up","spews", "projectile vomits")] as they're wrenched cruelly back to life!"),SPAN_ALERT("<b>[pick("JESUS CHRIST","THE PAIN!","IT BURNS!!")]</b>"))
		SPAWN(0) //some part of the vomit proc makes these duplicate
			H.reagents.clear_reagents()
			H.reagents.add_reagent("atropine", 2.5) //don't slip straight back into crit, get dizzy
			H.reagents.add_reagent("synaptizine", 5)
			H.reagents.add_reagent("proconvertin", 5)
			H.reagents.add_reagent("ephedrine", 5)
			H.reagents.add_reagent("salbutamol", 10) //don't die immediately in a vacuum
			H.reagents.add_reagent("space_drugs", 5) //heh
			H.make_jittery(200)
			H.delStatus("resting")
			H.hud.update_resting()
			H.delStatus("stunned")
			H.delStatus("knockdown")
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
	desc = "A highly illegal, disposable device that open doors like an AI."
	icon = 'icons/obj/items/gang.dmi'
	icon_state = "quickhack"
	object_flags = NO_GHOSTCRITTER
	throwforce = 1
	force = 1
	w_class = W_CLASS_TINY
	contraband = 2
	var/max_charges = 5
	var/charges = 5

	New()
		inventory_counter_enabled = TRUE
		..()

	syndicate
		max_charges = 10
		charges = 10

	update_icon()
		if (charges > 0 )
			inventory_counter?.update_number(charges)
		else
			inventory_counter?.update_text("-")

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
				flick("quickhack_fire", src)
				boutput(user, SPAN_ALERT("The [src.name] beeps!"))
			else
				boutput(user, SPAN_ALERT("The [src.name] buzzes. Maybe something's wrong with the door?"))
		else
			boutput(user, SPAN_ALERT("The [src.name] fizzles and hisses angrily! The AI control wire is probably cut."))
		UpdateIcon()

/obj/item/storage/box/gang_flyers
	name = "gang recruitment flyer case"
	desc = "A briefcase full of neat stuff."
	icon_state = "briefcase_black"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "sec-case"

	spawn_contents = list(/obj/item/gang_flyer = 4, /obj/item/spray_paint_gang = 2, /obj/item/tool/quickhack = 1)
	var/datum/gang/gang = null

	New(turf/newloc, datum/gang/gang)
		src.name = "[gang.gang_name] recruitment material"
		src.desc = "A briefcase full of flyers advertising the [gang.gang_name] gang."
		src.gang = gang
		..()

	random_gangs
		name = "gang equipment case"
		spawn_contents = list(/obj/item/spray_paint_gang = 3, /obj/item/tool/quickhack = 1, /obj/item/switchblade = 1, /obj/item/tool/janktanktwo = 1)
		New(turf/newloc, datum/gang/gang)
			..()
			src.desc = "A briefcase full of equipment for the [gang.gang_name] gang."

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
	var/category = ""			//This should be general category: weapon, clothing/armor, misc
	var/class2 = ""			//This should be the gang item style: Street Gang, Western Gang, Space Gang
	var/item_path = null 		// Type Path of the item
	var/price = 100 			//

	/// custom functionality for this purchase - if this returns TRUE, do not spawn the item
	proc/on_purchase(var/obj/ganglocker/locker, var/mob/user )
		return FALSE
/datum/gang_item/street
	category = "Street Gang"
/datum/gang_item/thirties_chicago
	category = "30s Chicago Gang"
/datum/gang_item/kung_fu
	category = "Kung Fu"
/datum/gang_item/ninja
	category = "Ninja"
/datum/gang_item/country_western
	category = "Country Western"
/datum/gang_item/space
	category = "Space Gang"
/datum/gang_item/weapon
	category = "Weapon"
/datum/gang_item/equipment
	category = "Consumable"

/datum/gang_item/equipment/graffiti
	name = "'ProPaint' Spray Can"
	desc = "Non-permanent graffiti, great for vandalism & blinding the fuzz. Not able to claim territory."
	class2 = "consumable"
	price = 300
	item_path = /obj/item/spray_paint_graffiti

/datum/gang_item/weapon/ratstick
	name = "Rat Stick"
	desc = "A stick for killing rats. Can deal both blunt and slashing damage."
	class2 = "weapon"
	price = 1200
	item_path = /obj/item/ratstick
/datum/gang_item/equipment/armor
	name = "Armored Vest"
	desc = "Grants you protection, and lets you keep your wicked style bonus!"
	class2 = "clothing"
	price = 7500
	item_path = /obj/item/clothing/suit/armor/gang

/datum/gang_item/weapon/lead_pipe
	name = "Lead Pipe"
	desc = "A pipe made of lead... Probably."
	class2 = "weapon"
	price = 500
	// item_path = /obj/item/lead_pipe
/datum/gang_item/weapon/nunchucks
	name = "Nunchucks"
	desc = "A pair of nunchucks, trading some raw lethality for pain compliance."
	class2 = "weapon"
	price = 1200
	item_path = /obj/item/nunchucks
/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	desc = "A stylish knife you can hide in your clothes. Special attacks do extreme bleeding damage."
	price = 1700
	class2 = "weapon"
	item_path = /obj/item/switchblade
/datum/gang_item/weapon/baseball
	name = "Baseball Bat"
	desc = "A wooden baseball bat. Deflects thrown weapons while equipped. Special attacks can launch enemies."
	price = 2000
	class2 = "weapon"
	item_path = /obj/item/bat
/datum/gang_item/weapon/machete
	name = "Machete"
	desc = "A sharp, heavy machete for the real sadists. Special attacks start a flurry of attacks."
	price = 10000
	class2 = "weapon"
	item_path = /obj/item/gang_machete
/datum/gang_item/weapon/Shiv
	name = "Shiv"
	desc = "A single-use stabbing implement, dealing heavy damage and constant BLEED."
	class2 = "weapon"
	price = 800
//	item_path = /obj/item/lead_pipe

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
/datum/gang_item/special/cop_car				//let gang members enter cars faster wearing their clothes
	name = "Stolen Cop Car"
	desc = "An enterprising member of your gang stole this from the fuzz. Hopefully it doesn't have lojack."
	class2 = "misc"
	price = 20000
	item_path = /obj/machinery/vehicle/tank/car/security

/////////////////////////////////////////////////////////////////////
////////////////////////////////NINJA////////////////////////////////
/////////////////////////////////////////////////////////////////////
/datum/gang_item/weapon/discount_katana
	name = "Katana"
	desc = "A discount japanese sword. Only folded 2 times. The blade is on the wrong side..."
	class2 = "weapon"
	price = 10000
	item_path = /obj/item/swords_sheaths/katana/reverse

/datum/gang_item/weapon/katana
	name = "Katana"
	desc = "It's the real McCoy. Folded so many times."
	class2 = "weapon"
	price = 25000
	item_path = /obj/item/swords_sheaths/katana

/datum/gang_item/weapon/shuriken
	name = "Shuriken"
	desc = "A pouch of 4 Shuriken throwing stars that embed on hit."
	class2 = "weapon"
	price = 800
	item_path = /obj/item/storage/pouch/shuriken

/datum/gang_item/weapon/throwing_knife
	name = "Throwing Knife"
	desc = "A weighty, throwable knife that disorients & causes bleed. Makes for a capable melee weapon in a pinch."
	class2 = "weapon"
	price = 700
	item_path = /obj/item/dagger/throwing_knife

/datum/gang_item/weapon/headband
	name = "Ninja Headband"
	desc = "A silly headband with a bit of metal on the front."
	class2 = "clothing"
	price = 1000
	// item_path = /obj/item/clothing/headgear/ninja_headband
/////////////////////////////////////////////////////////////////////
////////////////////////////SPACE////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/datum/gang_item/weapon/discount_csaber
	name = "Faux C-Saber"
	desc = "It's not a c-saber, it's something from the discount rack. Some kinda kooky laser stick. It looks pretty dangerous."
	class2 = "weapon"
	price = 10000
	item_path = /obj/item/sword/discount/gang
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
	name = "Janktank III"
	desc = "An abhorrent miscreation from the people behind JankTank I, to create the ultimate melee drug addict."
	class2 = "misc"
	price = 15000
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


/datum/gang_item/equipment/bathsalts
	name = "Bathsalts Pill Bottle"
	desc = "5 pills, 10u each of bathsalts."
	class2 = "drug"
	price = 200
	item_path = /obj/item/storage/pill_bottle/bathsalts
/datum/gang_item/equipment/crank
	name = "Crank Pill Bottle"
	desc = "5 pills, 10u each of crank."
	class2 = "drug"
	price = 300
	item_path = /obj/item/storage/pill_bottle/crank
/datum/gang_item/equipment/methamphetamine
	name = "Methamphetamine Pill Bottle"
	desc = "5 pills, 10u each of methamphetamine."
	class2 = "drug"
	price = 500
	item_path = /obj/item/storage/pill_bottle/methamphetamine

/datum/gang_item/equipment/janktank
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
	price = 800
	item_path = /obj/item/storage/firstaid/regular

/datum/gang_item/consumable/omnizine
	name = "Omnizine Injector"
	desc = "A single, convenient dose of omnizine."
	class2 = "Healing"
	price = 1100
	item_path = /obj/item/reagent_containers/emergency_injector/omnizine

/datum/gang_item/consumable/quickhack
	name = "Quickhack"
	desc = "Quickly opens unbolted doors you lack access to like an AI. 5 uses."
	class2 = "Tools"
	price = 800
	item_path = /obj/item/tool/quickhack

/datum/gang_item/consumable/tipoff
	name = "Tip off"
	desc = "Schedule an immediate duffle bag drop. A random civilian will be informed of the drop location."
	class2 = "Tools"
	price = 8000
	item_path = /obj/item/gang_loot/guns_and_gear

	on_purchase(var/obj/ganglocker/locker, var/mob/user )
		var/datum/gang/ourGang = locker.gang
		var/datum/mind/target = ourGang.get_random_civvie()
		ourGang.target_loot_spawn(target, ourGang)
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

// GRAFFITI
/obj/decal/cleanable/gang_graffiti
	name = "graffiti"
	desc = "A mural, of some kind. Made with cheap paint."
	icon = 'icons/obj/decals/graffiti.dmi'
// GANG TAGS

/obj/decal/gangtag
	name = "gang tag"
	desc = "A gang tag, sprayed with nigh-uncleanable heavy metals."
	density = FALSE
	anchored = TRUE
	layer = TAG_LAYER
	icon = 'icons/obj/decals/gang_tags.dmi'
	icon_state = "gangtag0"
	var/exploded = FALSE
	var/datum/gang/owners = null
	var/list/mobs
	var/heat = 0 // a rough estimation of how regularly this tag has people near it
	var/image/heatTracker
	var/active = TRUE
	/// Deletes all duplicate tags (IE, from the same gang) on this tile
	proc/delete_same_tags()
		for(var/obj/decal/gangtag/tag in get_turf(src))
			if(tag.owners == src.owners && tag != src) qdel(tag)

	/// Makes this tag inert, so it no longer provides points.
	proc/disable()
		if (!active)
			return
		active = FALSE
		src.owners?.unclaim_tiles(get_turf(src), GANG_TAG_INFLUENCE, GANG_TAG_SIGHT_RANGE)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		if (src.heatTracker)
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

	ex_act(severity)
		if (severity > 1)
			if (!exploded)
				exploded = TRUE
				desc = desc + " So heavy, in fact, that this tag hasn't exploded. Huh."
			return //no!
		..()

	proc/apply_score(var/largestHeat)
		var/mappedHeat // the 'heat' value mapped to the scale of 0-5
		if (heat == 0 || largestHeat == 0)
			mappedHeat = 0
		else
			var/pct = heat/largestHeat
			var/calculatedHeat = log(10,10*pct)*5 // the raw value of the heat calc, before rounding
			if (calculatedHeat <= 0)
				mappedHeat = 0
			else
				mappedHeat = round(max(0,calculatedHeat))+1 //round it to create mappedHeat


		var/score = 0
		score = ceil(mappedHeat * GANG_TAG_POINTS_PER_HEAT)
		owners.score_turf += score
		owners.add_points(score)
		owners.show_score_maptext(score, get_turf(src))
		heatTracker.icon_state = "gang_heat_[mappedHeat]"

	New()
		..()
		START_TRACKING
		for(var/obj/decal/gangtag/tag in get_turf(src))
			tag.layer = SUB_TAG_LAYER
		src.layer = TAG_LAYER
		src.mobs = new/list()
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		heatTracker = image('icons/effects/gang_tag.dmi', get_turf(src))
		heatTracker.icon_state = "gang_heat_0"
		heatTracker.layer = NOLIGHT_EFFECTS_LAYER_BASE
		imgroup.add_image(heatTracker)


	examine()
		. = ..()
		if (active)
			. += "The heat of this tag is: [heat]"


	disposing(var/uncapture = 1)
		src.disable()
		STOP_TRACKING
		owners = null
		mobs = null
		var/area/tagarea = get_area(src)
		if(tagarea.gang_owners == src.owners && uncapture)
			tagarea.gang_owners = null
			var/turf/T = get_turf(src)
			T.tagged = 0
		..()

