/datum/bioeffectmanager
	var/mob/target_mob

/datum/bioeffectmanager/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/bioeffectmanager/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/bioeffectmanager/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "BioEffectManager")
		ui.open()

/datum/bioeffectmanager/ui_data(mob/user)
	var/list/bioEffects = list()
	for (var/index as anything in target_mob.bioHolder?.effects)
		var/datum/bioEffect/BE = target_mob.bioHolder.effects[index]
		bioEffects += list(list(
			"name" = BE,
			"id" = BE.id,
			"stabilized" = !BE.stability_loss,
			"reinforced" = !BE.curable_by_mutadone,
			"boosted" = (BE.power == 2), //it's a multiplier...
			"synced" = BE.safety,
			"cooldown" = BE.cooldown))
	. = list(
		"target_name" = target_mob,
		"bioEffects" = bioEffects,
		"stability" = target_mob.bioHolder?.genetic_stability
		)

/datum/bioeffectmanager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	if (!target_mob?.bioHolder)
		return // mob was qdeleted
	var/datum/bioEffect/BE = target_mob.bioHolder.effects[params["id"]]
	switch(action)
		if ("addBioEffect")
			var/input = tgui_input_text(ui.user, "Enter a /datum/bioEffect path or partial name.", "Add a Bioeffect", null, allowEmpty = TRUE)
			var/datum/bioEffect/type_to_add = get_one_match(input, /datum/bioEffect, cmp_proc=/proc/cmp_text_asc)
			target_mob.bioHolder.AddEffect(initial(type_to_add.id))
			target_mob.onProcCalled("addBioEffect", list(initial(type_to_add.id)))
			logTheThing(LOG_ADMIN, ui.user, "Added bioeffect [initial(type_to_add.id)] to [constructName(target_mob)]")
			. = TRUE
		if ("updateStability")
			var/new_stability = round(text2num(params["value"]))
			target_mob.bioHolder.genetic_stability = isnull(new_stability) ? 0 : max(new_stability, 0)
			. = TRUE
		if ("updateCooldown")
			var/new_cooldown = round(text2num(params["value"]))
			BE.cooldown = isnull(new_cooldown) ? 0 : max(new_cooldown, 0)
			. = TRUE
		if ("toggleBoosted")
			var/old_power = BE.power
			BE.power = BE.power == 1 ? 2 : 1
			BE.onPowerChange(old_power, BE.power)
			. = TRUE
		if ("toggleReinforced")
			BE.curable_by_mutadone = !BE.curable_by_mutadone
			. = TRUE
		if ("toggleStabilized")
			if (BE.stability_loss == 0)
				BE.stability_loss = BE.global_instance.stability_loss
				BE.holder.genetic_stability = max(0, BE.holder.genetic_stability -= BE.stability_loss) //update mob stability
			else
				BE.holder.genetic_stability = max(0, BE.holder.genetic_stability += BE.stability_loss) //update mob stability
				BE.stability_loss = 0
			. = TRUE
		if ("toggleSynced")
			BE.safety = !BE.safety
			. = TRUE
		if ("manageBioEffect")
			ui.user.client.debug_variables(BE)
			. = TRUE
		if ("deleteBioEffect")
			target_mob.bioHolder.RemoveEffect(params["id"])
			logTheThing(LOG_ADMIN, ui.user, "Removed bioeffect [params["id"]] from [constructName(target_mob)]")
			. = TRUE
