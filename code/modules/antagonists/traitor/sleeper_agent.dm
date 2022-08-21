/// Effectively traitor lite, with random objectives and no uplink. Created through a random event.
/datum/antagonist/sleeper_agent
	id = ROLE_SLEEPER_AGENT
	display_name = "sleeper agent"

/datum/antagonist/sleeper_agent/announce()
	boutput(owner.current, "<h3><span class='alert'>You have awakened as a Syndicate [display_name]!</span></h3>")

/datum/antagonist/sleeper_agent/assign_objectives()
	// 1-3 regular objectives, plus a guaranteed gimmick objective and escape objective
	var/list/eligible_objectives = list(
		/datum/objective/regular/assassinate,
		/datum/objective/regular/steal,
		/datum/objective/regular/multigrab
	)

	var/list/escape_objectives = list(
		/datum/objective/escape,
#ifndef RP_MODE
		/datum/objective/escape/hijack,
#endif
		/datum/objective/escape/survive,
		/datum/objective/escape/kamikaze
	)
	// Can't have us trying to both kill and rescue the same monkey. Schrodinger's ape.
	if (prob(50))
		escape_objectives += /datum/objective/escape/stirstir
	else
		eligible_objectives += /datum/objective/regular/killstirstir
	var/list/objectives = list()
	var/datum/objective/new_objective = null
	for (var/i in 0 to rand(1, 3))
		new_objective = pick(eligible_objectives)
		objectives += new new_objective(null, owner)
	var/datum/objective/escape/E = pick(escape_objectives)
	objectives += new /datum/objective/regular/gimmick(null, owner)
	objectives += new E(null, owner)
