
//[00:45]	AngriestIBM	Let me generate a round backstory in 5 seconds: This is how the syndicate determines who gets higher ranking positions -- by handing the candidates quad-injectors of mindhacks and having them fight to the death

// Idea: each leader gets a unique goofy experimental piece of equipment, traitor gear that needs field testing (Or worse)
// ex: bottle of corrosive fermid oil, OmegaFlash (field effect turboflash), etc
// like the R&D stuff in paranoia

/datum/game_mode/spy
	name = "conspiracy"
	config_tag = "spy"

	var/list/leaders = list()
	var/list/spies = list()

	var/const/setup_min_teams = 4
	var/const/setup_max_teams = 6
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/spy/announce()
	boutput(world, "<B>The current game mode is - Conspiracy!</B>")
	boutput(world, "<B>The Syndicate is using the [station_or_ship()] as a battleground to train elite operatives!</B>")

/datum/game_mode/spy/pre_setup()
	var/list/leaders_possible = get_possible_enemies(ROLE_SPY_THIEF, 1)

	if (!leaders_possible.len)
		return 0

	var/num_players = 0
	for(var/client/C)
		var/mob/new_player/player = C.mob
		if (!istype(player)) continue

		if (player.ready)
			num_players++

	var/i = rand(5)
	var/num_teams = clamp(round((num_players + i) / 7), setup_min_teams, setup_max_teams)
	if (num_teams > leaders_possible.len)
		num_teams = length(leaders_possible)

	var/list/chosen_spies = antagWeighter.choose(pool = leaders_possible, role = "spy", amount = num_teams, recordChosen = 1)
	for (var/datum/mind/spy in chosen_spies)
		leaders += spy
		spy.special_role = "spy"
		leaders_possible.Remove(spy)

	return 1

/datum/game_mode/spy/post_setup()

	for (var/datum/mind/leaderMind in leaders)
		if (!leaderMind.current)
			continue

		var/datum/objective/specialist/conspiracy/spyObjective = bestow_objective(leaderMind,/datum/objective/specialist/conspiracy)
		spyObjective = bestow_objective(leaderMind, pick(/datum/objective/escape, /datum/objective/escape/survive)) // They have to stay alive, dunno why dying a glorious death was a possible objective.

		switch(rand(1, ((leaderMind.assigned_role in list("Captain","Head of Personnel","Head of Security","Chief Engineer","Research Director")) ? 3 : 4) ))
			if (1,2)
				spyObjective = bestow_objective(leaderMind,/datum/objective/regular/assassinate)
			/*if (2)
				spyObjective = bestow_objective(leaderMind,/datum/objective/regular/aikill)
			if (3)
				spyObjective = bestow_objective(leaderMind,/datum/objective/regular/borgdeath)*/
			if (3,4)
				spyObjective = bestow_objective(leaderMind,/datum/objective/regular/steal)

		leaderMind.current.show_antag_popup("spy")
		boutput(leaderMind.current, "<span class='alert'>Oh yes, and <b>one more thing:</b> <b>[spyObjective.explanation_text]</b> That is, if you <i>really</i> want that new position.</span>")

		equip_leader(leaderMind.current)

	SPAWN(rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/spy/send_intercept()
	..(src.leaders)

/datum/game_mode/spy/proc/equip_leader(mob/living/carbon/human/leader)
	if (!istype(leader))
		return

	//equip_traitor(leader) <- Quad mindhacks and the starter gear are more than sufficient. Spies really don't need a traitor uplink on top of that.

	var/the_slot = null
	if (istype(leader.back, /obj/item/storage/) && leader.back.contents.len < 7)
		leader.equip_if_possible(new /obj/item/storage/box/spykit(leader), leader.slot_in_backpack)
		the_slot = "backpack"
	else
		var/obj/K2 = new /obj/item/storage/box/spykit(get_turf(leader))
		leader.put_in_hand_or_drop(K2)
		the_slot = "hand"

	boutput(leader, "<span class='notice'>You've been supplied with a <b>special quad-use implanter</b> in the spy starter kit in your [!isnull(the_slot) ? "[the_slot]" : "UNKNOWN"]. Use it to recruit some mindhacked henchmen!</span>")
	return

/datum/game_mode/spy/proc/add_spy(mob/living/new_spy, mob/living/leader)
	if (!new_spy || !leader || !new_spy.mind || !leader.mind)
		return 0

	var/datum/mind/spymind = new_spy.mind
	var/datum/mind/leadermind = leader.mind
	if (spymind in src.spies)
		if (leadermind != src.spies[spymind])
			src.spies[spymind] = leadermind
			return 1

		return 0

	src.spies.Add(spymind)
	src.spies[spymind] = leadermind
	spymind.special_role = "spyminion"
	spymind.master = leader.ckey

	return 1

/datum/game_mode/spy/proc/remove_spy(mob/living/spy)
	src.spies.Remove(spy)
	spy.mind.special_role = null
	spy.mind.master = null
	return 1

/datum/game_mode/spy/declare_completion()

	var/text = ""

	boutput(world, "<FONT size = 2><B>The infiltrators were: </B></FONT>")
	var/datum/mind/potential_winner = null
	var/survived_count = 0
	for(var/datum/mind/leader_mind in leaders)
		text = ""
		if(leader_mind.current)
			text += "[leader_mind.current.real_name]"
			var/turf/T = get_turf(leader_mind.current)
			if(isdead(leader_mind.current))
				text += " (Dead)"
			else
				text += " (Survived!)"
				survived_count++
				if (T.z == 2)
					var/all_complete = 1
					for (var/datum/objective/O in leader_mind.objectives)
						if (istype(O, /datum/objective/specialist/conspiracy))
							continue

						if (O.check_completion() != 1)
							all_complete = 0
							break

					if (isnull(potential_winner) && all_complete)
						potential_winner = leader_mind
		else
			text += "[leader_mind.key] (character destroyed)"

		boutput(world, text)

	if (istype(potential_winner) && potential_winner.current && (survived_count == 1))
		boutput(world, "<h2><b>[potential_winner.current.real_name] succeeded! The Syndicate has promoted them to [pick("Executive Bathroom Toilet Scrubber", "Head Office Cafeteria Worker", "Board Room Custodian")]!</b></h2>")

#ifdef DATALOGGER
		game_stats.Increment("traitorwin")
#endif
	else
		boutput(world, "<h2><b>The infiltrators did not succeed!</b></h2>")
#ifdef DATALOGGER
		game_stats.Increment("traitorloss")
#endif


	text = ""
	boutput(world, "<FONT size = 2><B>The brainwashed conspirators were: </B></FONT>")
	if (!spies.len)
		text += "Nobody!"
	else
		for(var/datum/mind/spy_mind in spies)
			if(spy_mind.current)
				text += "[spy_mind.current.real_name]"
				if(isdead(spy_mind.current))
					text += " (Dead)"
				else
					text += " (Survived!)"
			else
				text += "[spy_mind.key] (character destroyed)"
			text += ", "

	boutput(world, text)

	..() // Admin-assigned antagonists or whatever.

/obj/item/device/spy_implanter
	name = "Multi-Use Implanter"
	desc = "A specialized, self-sanitizing implantation implement that may be used to inject multiple implants. As a trade-off, it cannot be reloaded outside of the factory."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "revimplanter4"
	item_state = "syringe_0"
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	var/charges = 4

	update_icon()
		src.icon_state = "revimplanter[min(4, round((src.charges/initial(src.charges)), 0.25) * 4)]"
		return

	attack(mob/M, mob/user)
		if (!iscarbon(M))
			return

		var/override = 0
		if (user && (charges > 0))
			for (var/obj/item/implant/spy_implant/implant_check in M)
				if (!implant_check.leader_name)
					continue

				if (user.mind && (user.mind == implant_check.leader_mind))
					boutput(user, "<span class='alert'>Injecting the same person twice won't solve anything!</span>")
					return
				else
					override = (override || prob(10))

				if (override)
					implant_check.leader_mind = null
					implant_check.leader_name = null
					if (istype(implant_check.linked_objective))
						if (M.mind)
							M.mind.objectives -= implant_check.linked_objective

						qdel(implant_check.linked_objective)
				else
					override = -1
					break

			var/obj/item/implant/spy_implant/new_imp = new
			M.visible_message("<span class='alert'>[M] has been implanted by [user].</span>", "<span class='alert'>You have been implanted by [user].</span>")

			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.implant.Add(new_imp)

			new_imp.set_loc(M)
			new_imp.implanted = 1
			new_imp.owner = M
			user.show_message("<span class='alert'>You implanted the implant into [M]. <b>[src.charges-1]</b> implants remaining!</span>")
			new_imp.implanted(M, user, override)

			src.charges--
			src.UpdateIcon()


/obj/item/implant/spy_implant
	name = "mind hack XL"
	var/leader_name = null
	var/datum/mind/leader_mind = null
	var/datum/objective/linked_objective = null

	implanted(mob/M, mob/Implanter, override=0)
		..()

		if (!istype(ticker.mode, /datum/game_mode/spy))
			boutput(M, "<span class='alert'>A stunning pain shoots through your brain!</span>")
			boutput(M, "<h1><font color=red>You feel an unwavering loyalty to...</font>yourself.</h1>Maybe the implant was defective? Oh dear, act natural!")
			return

		if (M == Implanter)
			boutput(M, "<span class='alert'>This was a great idea! You always have the best ideas!  You feel more self-control than you ever have before!</span>")
			alert(M, "This was a great idea! You always have the best ideas!  You feel more self-control than you ever have before!", "YOUR BEST IDEA YET!!")
			return

		if (override == -1)
			logTheThing(LOG_COMBAT, M, "'s loyalties are unchanged! (Injector: [constructTarget(Implanter,"combat")])")
			boutput(M, "<h1><font color=red>Your loyalties are unaffected! You have resisted this new implant!</font></h1>")
			return

		var/datum/game_mode/spy/spymode = ticker.mode

		if (M.mind && (M.mind in spymode.leaders))
			boutput(M, "<span class='alert'>A sharp pain flares behind your eyes, but quickly subsides.</span>")
			boutput(M, "<span class='alert'>You have undergone special mental conditioning to gain immunity from the control implants of competing agents.</span>")
			return

		var/datum/mind/oldLeader = leader_mind
		leader_name = Implanter.real_name
		leader_mind = Implanter.mind
		//todo - implantation when there is another XL already in here
		boutput(M, "<span class='alert'>A brilliant pain flashes through your brain!</span>")
		if (override)
			boutput(M, "<h1><font color=red>Your loyalties have shifted! You now know that it is [leader_name] that is truly deserving of your obedience!</font></h1>")
			alert(M, "Your loyalties have shifted! You now know that it is [leader_name] that is truly deserving of your obedience!", "YOU HAVE A NEW MASTER!")
			if (istype(leader_mind) && leader_mind.current && M.client)
				for (var/image/I in M.client.images)
					if (I.loc == oldLeader.current)
						qdel(I)
						break
		else
			boutput(M, "<h1><font color=red>You feel an unwavering loyalty to [leader_name]! You feel you must obey [his_or_her(leader_name)] every order! Do not tell anyone about this unless [leader_name] tells you to!</font></h1>")
			alert(M, "You feel an unwavering loyalty to [leader_name]! You feel you must obey [his_or_her(leader_name)] every order! Do not tell anyone about this unless [leader_name] tells you to!", "YOU HAVE BEEN MINDHACKED!")

		if (M.mind)
			if (!src.linked_objective)
				src.linked_objective = new /datum/objective(null, M.mind)

			src.linked_objective.explanation_text = "Obey [leader_name]'s every order."

		if (leader_mind?.current && M.client)
			var/I = image(antag_spyleader, loc = leader_mind.current)
			M.client.images += I

		spymode.add_spy(M, Implanter)
		return

	on_remove(var/mob/M)
		..()

		if (leader_name)
			boutput(M, "<h1><font color=red>Your loyalty to [leader_mind?.current ? leader_mind.current.real_name : leader_name] fades away!</font></h1>")

			if (istype(ticker.mode, /datum/game_mode/spy))
				var/datum/game_mode/spy/spymode = ticker.mode
				spymode.remove_spy(M)
				if (M.client && src.leader_mind && src.leader_mind.current)
					for (var/image/I in M.client.images)
						if (I.loc == src.leader_mind.current)
							qdel(I)
							break

				if (M.mind && src.linked_objective)
					M.mind.objectives -= src.linked_objective
					qdel(src.linked_objective)

				src.leader_name = null
				src.leader_mind = null

		return
