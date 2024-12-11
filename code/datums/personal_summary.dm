///Combination of personal metacurrency windows, shown end-of-round
/datum/personal_summary
	// jobxp
	var/current_job
	var/current_level
	var/earned_exp
	var/level_exp
	var/total_exp
	var/next_level_exp
	var/exp_earned

	// spacebux
	var/is_antagonist
	var/is_part_time
	var/is_escaped
	var/is_pilot
	var/base_wage
	var/score_adjusted_wage
	var/objective_completed_bonus
	var/all_objectives_bonus
	var/pilot_bonus
	var/earned_spacebux
	var/total_spacebux
	var/held_item

	var/personal_summary_data


/datum/personal_summary/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/personal_summary/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/personal_summary/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PersonalSummary")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/personal_summary/proc/generate_xp(key, mob/M)
	if(key in xp_archive)
		var/list/keyList = xp_archive[key]
		var/hasEntries = 0
		for(var/job in keyList)
			hasEntries = 1
			src.exp_earned = TRUE
			src.current_job = job
			src.earned_exp = keyList[job]
			src.total_exp = get_xp(key, job)

			if (isnull(src.total_exp))
				src.total_exp = src.earned_exp // for local dev servers where get_xp will always return null
			src.current_level = LEVEL_FOR_XP(src.total_exp)
			src.level_exp = src.total_exp - XP_FOR_LEVEL(src.current_level)
			src.next_level_exp = XP_FOR_LEVEL(src.current_level  + 1) - XP_FOR_LEVEL(src.current_level)

		if(!hasEntries)
			src.exp_earned = FALSE

/datum/personal_summary/proc/generate_output_data()
	src.personal_summary_data = list()
	src.personal_summary_data["jobxp_data"] = list()
	src.personal_summary_data["jobxp_data"]["current_job"] = src.current_job
	src.personal_summary_data["jobxp_data"]["current_level"] = src.current_level
	src.personal_summary_data["jobxp_data"]["earned_exp"] = src.earned_exp
	src.personal_summary_data["jobxp_data"]["level_exp"] = src.level_exp
	src.personal_summary_data["jobxp_data"]["total_exp"] = src.total_exp
	src.personal_summary_data["jobxp_data"]["next_level_exp"] = src.next_level_exp
	src.personal_summary_data["jobxp_data"]["exp_earned"] = src.exp_earned

	src.personal_summary_data["spacebux_data"] = list()
	src.personal_summary_data["spacebux_data"]["is_antagonist"] = src.is_antagonist
	src.personal_summary_data["spacebux_data"]["is_part_time"] = src.is_part_time
	src.personal_summary_data["spacebux_data"]["is_escaped"] = src.is_escaped
	src.personal_summary_data["spacebux_data"]["is_pilot"] = src.is_pilot
	src.personal_summary_data["spacebux_data"]["base_wage"] = src.base_wage
	src.personal_summary_data["spacebux_data"]["score_adjusted_wage"] = src.score_adjusted_wage
	src.personal_summary_data["spacebux_data"]["objective_completed_bonus"] = src.objective_completed_bonus
	src.personal_summary_data["spacebux_data"]["all_objectives_bonus"] = src.all_objectives_bonus
	src.personal_summary_data["spacebux_data"]["pilot_bonus"] = src.pilot_bonus
	src.personal_summary_data["spacebux_data"]["earned_spacebux"] = src.earned_spacebux
	src.personal_summary_data["spacebux_data"]["total_spacebux"] = src.total_spacebux
	src.personal_summary_data["spacebux_data"]["held_item"] = src.held_item

/datum/personal_summary/ui_static_data(mob/user)
	if (isnull(src.personal_summary_data))
		src.generate_output_data()
	return src.personal_summary_data
