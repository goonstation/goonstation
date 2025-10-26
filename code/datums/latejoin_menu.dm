var/datum/latejoin_menu/latejoin_menu = new()

#define GET_JOBS(USER, TYPES...) src.get_jobs(USER, global.job_controls.staple_jobs, list(##TYPES))
#define GET_SPECIAL_JOBS(USER, TYPES...) global.job_controls.allow_special_jobs ? src.get_jobs(USER, global.job_controls.special_jobs, list(##TYPES)) : list()


/datum/latejoin_menu

/datum/latejoin_menu/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/latejoin_menu/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/latejoin_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "LatejoinMenu")
		ui.open()

/datum/latejoin_menu/ui_data(mob/user)
	. = list()

	var/list/command_department = list()
	command_department["name"] = "Command"
	command_department["colour"] = TGUI_COLOUR_GREEN
	command_department["jobs"] = GET_JOBS(user, /datum/job/command)

	var/list/security_department = list()
	security_department["name"] = "Security"
	security_department["colour"] = TGUI_COLOUR_RED
	security_department["jobs"] = GET_JOBS(user, /datum/job/security)

	var/list/research_department = list()
	research_department["name"] = "Research"
	research_department["colour"] = TGUI_COLOUR_PURPLE
	research_department["jobs"] = GET_JOBS(user, /datum/job/research)

	var/list/medical_department = list()
	medical_department["name"] = "Medical"
	medical_department["colour"] = TGUI_COLOUR_PINK
	medical_department["jobs"] = GET_JOBS(user, /datum/job/medical)

	var/list/engineering_department = list()
	engineering_department["name"] = "Engineering"
	engineering_department["colour"] = TGUI_COLOUR_ORANGE
	engineering_department["jobs"] = GET_JOBS(user, /datum/job/engineering)

	var/list/civilian_department = list()
	civilian_department["name"] = "Civilian"
	civilian_department["colour"] = TGUI_COLOUR_BLUE
	civilian_department["jobs"] = GET_JOBS(user, /datum/job/civilian, /datum/job/daily)

	var/list/silicon_department = list()
	silicon_department["name"] = "Silicon"
	silicon_department["colour"] = TGUI_COLOUR_GREY
	silicon_department["jobs"] = src.get_silicon_jobs()

	var/list/special_jobs = list()
	special_jobs["name"] = "Special Jobs"
	special_jobs["colour"] = TGUI_COLOUR_BLUE
	special_jobs["jobs"] = GET_SPECIAL_JOBS(user, /datum/job/daily, /datum/job/special, /datum/job/created)

	.["departments"] = list(
		command_department,
		security_department,
		research_department,
		medical_department,
		engineering_department,
		civilian_department,
		silicon_department,
		special_jobs,
	)

/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	var/mob/new_player/M = ui.user
	if (!istype(M) || M.spawning)
		return

	if (!global.enter_allowed)
		boutput(M, SPAN_NOTICE("There is an administrative lock on entering the game!"))
		return

	var/datum/job/J = locate(params["job_ref"])
	if (!istype(J))
		global.stack_trace("Unknown job: [J] [params["job_ref"]]")

	var/obj/item/organ/brain/latejoin/silicon_latejoin = locate(params["silicon_latejoin"])

	switch (action)
		if ("open-job-wiki")
			M << link(J.wiki_link)

		if ("join-as-job")
			M.close_spawn_windows()
			ui.close()

			if (istype(silicon_latejoin))
				M.AttemptSiliconLateSpawn(silicon_latejoin)
			else
				M.AttemptLateSpawn(J)

/datum/latejoin_menu/proc/get_jobs(mob/user, list/job_list, list/job_types)
	. = list()

	for (var/datum/job/J as anything in job_list)
		if (!istypes(J, job_types))
			continue

		var/list/job_props = src.get_job_props(user, J)
		if (!length(job_props))
			continue

		. += list(job_props)

/datum/latejoin_menu/proc/get_job_props(mob/user, datum/job/J)
	if (J.no_late_join || (!J.assigned && !J.limit))
		return

	. = list()

	// During revolution rounds, all command slots appear as filled.
	var/slot_count = J.assigned
	if (istype(J, /datum/job/command) && istype(ticker.mode, /datum/game_mode/revolution))
		slot_count = max(slot_count, J.limit)

	.["job_name"] = J.name
	.["priority_role"] = (global.job_controls.priority_job == J)
	.["player_requested"] = J.player_requested
	.["has_wiki_link"] = !!J.wiki_link
	.["job_ref"] = ref(J)
	.["colour"] = J.ui_colour
	.["slot_count"] = slot_count
	.["slot_limit"] = J.limit
	.["disabled"] = !global.job_controls.check_job_eligibility(user, J, STAPLE_JOBS | SPECIAL_JOBS)

/datum/latejoin_menu/proc/get_silicon_jobs()
	. = list()

	for (var/mob/living/silicon/S in global.mobs)
		var/obj/item/organ/brain/latejoin/silicon_latejoin = src.get_silicon_latejoin(S)
		if (!silicon_latejoin)
			continue

		var/datum/job/J = null
		var/job_name = null
		if (istype(S, /mob/living/silicon/ai))
			J = get_singleton(/datum/job/civilian/AI)
			job_name = "[S.name] (AI)"
		else
			J = get_singleton(/datum/job/civilian/cyborg)
			job_name = "[S.name] (Cyborg)"

		var/list/silicon_job_props = list()
		silicon_job_props["job_name"] = job_name
		silicon_job_props["priority_role"] = FALSE
		silicon_job_props["player_requested"] = FALSE
		silicon_job_props["has_wiki_link"] = !!J.wiki_link
		silicon_job_props["job_ref"] = ref(J)
		silicon_job_props["silicon_latejoin"] = ref(silicon_latejoin)
		silicon_job_props["colour"] = J.ui_colour
		silicon_job_props["slot_count"] = 0
		silicon_job_props["slot_limit"] = 1
		silicon_job_props["disabled"] = FALSE
		. += list(silicon_job_props)

/datum/latejoin_menu/proc/get_silicon_latejoin(mob/living/silicon/S)
	if (isdead(S))
		return FALSE

	var/obj/item/organ/brain/latejoin/latejoin = astype(S, /mob/living/silicon/ai)?.brain
	latejoin ||= astype(S, /mob/living/silicon/robot)?.part_head?.brain

	if (istype(latejoin) && !latejoin.activated)
		return latejoin

	return FALSE


#undef GET_JOBS
#undef GET_SPECIAL_JOBS
