/// Effectively traitor lite, with random objectives and no uplink. Created through a random event.
/datum/antagonist/sleeper_agent
	id = ROLE_SLEEPER_AGENT
	display_name = "sleeper agent"
	antagonist_icon = "traitor"
	var/dead_drop

/datum/antagonist/sleeper_agent/remove_self(take_gear, source)
	. = ..()
	if (src.dead_drop)
		src.owner.current.RemoveComponentsOfType(/datum/component/tracker_hud/dead_drop)

/datum/antagonist/sleeper_agent/announce()
	boutput(owner.current, SPAN_ALERT("<h3>You have awakened as a Syndicate [display_name]!</h3>"))

/datum/antagonist/sleeper_agent/assign_objectives()
	// 1-3 regular objectives, plus a guaranteed gimmick objective and escape objective
	var/list/eligible_objectives = list(
		/datum/objective/regular/assassinate,
		/datum/objective/regular/steal,
		/datum/objective/regular/multigrab
	)

	var/list/escape_objectives = list(
		/datum/objective/escape,
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
	for (var/i in 1 to rand(1, 2))
		new_objective = pick(eligible_objectives)
		objectives += new new_objective(null, owner, src)
	var/datum/objective/escape/E = pick(escape_objectives)
	objectives += new /datum/objective/regular/gimmick(null, owner, src)
	objectives += new E(null, owner, src)
