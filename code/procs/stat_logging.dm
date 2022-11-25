/////////FOR LOGGING TO STATS FILE/////////

//Called in tickets New() in datacore.dm
/proc/statlog_ticket(var/datum/ticket/T, var/mob/living/M)
	var/message[] = new()
	message["data_type"] = "tickets"
	message["data_status"] = "insert"
	message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	message["target"] = T.target
	message["reason"] = T.reason
	message["issuer"] = M.real_name
	message["issuer_job"] = M.job
	message["target_byond_key"] = T.target_byond_key
	message["issuer_byond_key"] = M.key

	hublog << list2params(message)

//Called in fines New() in datacore.dm
/proc/statlog_fine(var/datum/fine/F, var/mob/living/M)
	var/message[] = new()
	message["data_type"] = "fines"
	message["data_status"] = "insert"
	message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	message["byond_uid"] = F.ID

	message["target"] = F.target
	message["reason"] = F.reason
	message["issuer"] = M.real_name
	message["issuer_job"] = M.job
	message["amount"] = F.amount
	message["target_byond_key"] = F.target_byond_key
	message["issuer_byond_key"] = M.key

	hublog << list2params(message)

//Called in crittergauntlet.dm
/proc/statlog_gauntlet(var/mobs, var/final_score, var/last_completed_wave)
	if (final_score == 0 && last_completed_wave < 2)
		return
	var/message[] = new()
	message["data_type"] = "gauntlet_high_scores"
	message["data_status"] = "insert"
	message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	message["names"] = mobs
	message["score"] = final_score
	message["highest_wave"] = last_completed_wave

	hublog << list2params(message)

//Called in living death() in living.dm
/proc/statlog_death(var/mob/living/M,var/gibbed)
	var/message[] = new()
	message["data_type"] = "deaths"
	message["data_status"] = "insert"
	message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	message["mob_name"] = M.real_name
	message["mob_job"] = M.job
	message["mob_byond_key"] = M.key
	var/atom/T = get_turf(M)
	if (!T) T = M
	message["x"] = T.x
	message["y"] = T.y
	message["z"] = T.z
	message["bruteloss"] = M.get_brute_damage()
	message["fireloss"] = M.get_burn_damage()
	message["toxloss"] = M.get_toxin_damage()
	message["oxyloss"] = M.get_oxygen_deprivation()
	message["gibbed"] = gibbed ? 1 : 0

	hublog << list2params(message)

//Called in syndicate and integrated Topic() in uplinks.dm
/proc/statlog_traitor_item(var/mob/living/M, var/itemIdentifier, var/cost)
	if (!istype(M))
		return 1

	var/message[] = new()
	message["data_type"] = "traitor_items"
	message["data_status"] = "insert"
	message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	message["mob_name"] = M.real_name
	message["mob_job"] = M.job
	message["mob_byond_key"] = M.key
	var/atom/T = get_turf(M)
	if (!T) T = M
	message["x"] = T.x
	message["y"] = T.y
	message["z"] = T.z
	message["item"] = itemIdentifier ? itemIdentifier : "???"
	message["cost"] = isnum(cost) ? "[cost]" : "0"

	hublog << list2params(message)

//Called in gameticker.dm in proc/declare_completion
/proc/statlog_traitors()
	var/list/datum/mind/traitors = get_all_enemies()

	for (var/datum/mind/M in traitors)
		var/message[] = new()
		message["data_type"] = "traitors"
		message["data_status"] = "insert"
		message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

		message["mob_name"] = M.current.real_name
		message["mob_job"] = M.current.job
		message["mob_byond_key"] = M.key

		if (M.objectives)
			var/overallSuccess = 1
			var/count = 1
			for(var/datum/objective/objective in M.objectives)
#ifdef CREW_OBJECTIVES
				if (istype(objective, /datum/objective/crew)) continue
#endif
				message["objective[count]"] = objective.explanation_text
				if(objective.check_completion())
					message["success[count]"] = 1
				else
					message["success[count]"] = 0
					overallSuccess = 0
				count++

			message["success"] = overallSuccess
			message["objective_count"] = count - 1

		var/traitor_type = M.special_role
		message["traitor_type"] = traitor_type
		var/special
		switch(traitor_type)
			if (ROLE_CHANGELING)
				if (M.current)
					var/datum/abilityHolder/changeling/C = M.current.get_ability_holder(/datum/abilityHolder/changeling)
					if (C && istype(C))
						special = C.absorbtions
			if (ROLE_VAMPIRE)
				if (M.current)
					special = M.current.get_vampire_blood(1)
			if (ROLE_WIZARD)
				if (M.current)
					var/datum/abilityHolder/wizard/W = M.current.get_ability_holder(/datum/abilityHolder/wizard)
					if (W && istype(W))
						var/spells = ""
						for (var/datum/targetable/spell/S in W.abilities)
							if (spells != "")
								spells += ", "
							spells += S.name
			if (ROLE_WEREWOLF)
				for (var/datum/objective/specialist/werewolf/feed/O in M.objectives)
					if (O && istype(O, /datum/objective/specialist/werewolf/feed/))
						special = length(O.mobs_fed_on)
			if (ROLE_VAMPTHRALL)
				if (M.master)
					var/mob/mymaster = ckey_to_mob(M.master)
					if (mymaster) special = mymaster.real_name
			if ("spyminion")
				if (M.master)
					var/mob/mymaster = ckey_to_mob(M.master)
					if (mymaster) special = mymaster.real_name
			if (ROLE_MINDHACK)
				if (M.master)
					var/mob/mymaster = ckey_to_mob(M.master)
					if (mymaster) special = mymaster.real_name
			if (ROLE_FLOCKMIND)
				var/relay_successful = FALSE
				if (isflockmob(M.current))
					if (!istype(M.current, /mob/living/critter/flock/drone))
						var/mob/living/intangible/flock/flockmind/flockmind = M.current
						relay_successful = flockmind.flock.relay_finished
					else
						var/mob/living/critter/flock/drone/flockdrone = M.current
						relay_successful = flockdrone.flock.relay_finished
				special = "Relay transmission [relay_successful ? "successful" : "unsuccessful"]"
			if (ROLE_FLOCKTRACE)
				if (isflockmob(M.current))
					var/datum/flock/flock_joined = null
					if (!istype(M.current, /mob/living/critter/flock/drone))
						var/mob/living/intangible/flock/trace/flocktrace = M.current
						flock_joined = flocktrace.flock
					else
						var/mob/living/critter/flock/drone/flockdrone = M.current
						flock_joined = flockdrone.flock
					special = "Part of Flock [flock_joined.name]"
			if (ROLE_NUKEOP)
				if (istype(ticker.mode, /datum/game_mode/nuclear))
					special = syndicate_name()
					if (ticker.mode:nuke_detonated)
						message["success"] = 1
			if (ROLE_SPY_THIEF)
				special = "Bounties claimed: "
				for(var/stolen_item_name in M.spy_stolen_items)
					if (stolen_item_name != "")
						special += stolen_item_name
						special += ", "

		message["special"] = special

		if (M.late_special_role)
			message["late_joiner"] = 1
		/*else if (M.random_event_special_role)
			message["random_event"] = 1*/
		else
			message["late_joiner"] = 0
			//message["random_event"] = 0

		hublog << list2params(message)

//BEES
/proc/statlog_bees(var/obj/critter/domestic_bee/B)
	var/message[] = new()
	message["data_type"] = "bees"
	message["data_status"] = "insert"
	message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	message["name"] = B.name

	if(B.beeMom)
		message["mom"] = B.beeMom.real_name

	hublog << list2params(message)

//Called in gameticker.dm at proc/declare_completion, ai_laws.dm at set_zeroth_law and add_supplied_law
/proc/statlog_ailaws(var/during, var/law, adder)


	//For individual laws
	if (during)
		var/message[] = new()
		message["data_type"] = "ai_laws"
		message["data_status"] = "insert"
		message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

		if (ismob(adder))
			var/mob/M = adder
			message["uploader_name"] = M.real_name
			message["uploader_key"] = M.key
			message["uploader_job"] = M.job
		else
			message["uploader_name"] = "Ion Storm"
			message["uploader_key"] = "Random Event"
			message["uploader_job"] = ""

		message["type"] = "during"
		message["law_text"] = html_decode(law)

		hublog << list2params(message)
		return 1
	//For end of round laws
	else
		for_by_tcl(aiPlayer, /mob/living/silicon/ai)
			var/laws[] = new()
			if(aiPlayer.law_rack_connection)
				laws = aiPlayer.law_rack_connection.format_for_irc()

			for (var/key in laws)
				var/message[] = new()
				message["data_type"] = "ai_laws"
				message["data_status"] = "insert"
				message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

				message["ai_name"] = aiPlayer.real_name
				message["ai_key"] = aiPlayer.key
				message["type"] = "end"
				message["law_number"] = key
				message["law_text"] = html_decode(laws[key])

				hublog << list2params(message)

		return 1

#ifdef HALLOWEEN
/proc/statlog_spookpoints()//(/datum/spooktober_ghost_handler/SGH)
	var/groupedPoints[] = new()

	for (var/i in spooktober_GH.earned_points)
		if (!groupedPoints[i]) groupedPoints[i] = list("earned" = 0, "spent" = 0)
		groupedPoints[i]["earned"] = spooktober_GH.earned_points[i]
	for (var/i in spooktober_GH.spent_points)
		if (!groupedPoints[i]) groupedPoints[i] = list("earned" = 0, "spent" = 0)
		groupedPoints[i]["spent"] = spooktober_GH.spent_points[i]

	for (var/ckey in groupedPoints)
		var/message[] = new()
		message["data_type"] = "ghostpoints"
		message["data_status"] = "insert"
		message["data_timestamp"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

		message["ckey"] = ckey
		message["earned"] = groupedPoints[ckey]["earned"]
		message["spent"] = groupedPoints[ckey]["spent"]

		hublog << list2params(message)
#endif
