
/// Record an antag spawn
/datum/eventRecord/Antag
	eventType = "antag"
	body = /datum/eventRecordBody/TracksPlayer/Antag

	send(
		player_id,
		mob_name,
		mob_job,
		traitor_type,
		special,
		late_joiner,
		success
	)
		. = ..(args)

	buildAndSend(datum/antagonist/antagonist_role)
		var/datum/mind/M = antagonist_role.owner

		var/traitor_type = antagonist_role.id
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
			if (ROLE_VAMPTHRALL, ROLE_MINDHACK)
				var/datum/mind/master = M.get_master(traitor_type)
				if (master?.current)
					special = master.current.real_name
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
			//if (ROLE_MINDEATER)
			if (ROLE_NUKEOP, ROLE_NUKEOP_COMMANDER)
				if (istype(ticker.mode, /datum/game_mode/nuclear))
					special = syndicate_name()
			if (ROLE_SPY_THIEF)
				special = "Bounties claimed: "
				var/datum/antagonist/spy_thief/antag_role = M.get_antagonist(ROLE_SPY_THIEF)
				for(var/obj/stolen_item in antag_role.stolen_items)
					if (stolen_item.name != "")
						special += "[stolen_item.name], "

		var/overallSuccess = 1
		if (M.objectives)
			for (var/datum/objective/objective in M.objectives)
#ifdef CREW_OBJECTIVES
				if (istype(objective, /datum/objective/crew)) continue
#endif
				if (!objective.check_completion())
					overallSuccess = 0
					break

		src.send(
			M.get_player().id,
			M.current.real_name,
			M.current.job,
			M.special_role,
			special,
			M.late_special_role ? TRUE : FALSE,
			overallSuccess
		)
