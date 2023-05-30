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
	for (var/index as anything in target_mob.bioHolder.effects)
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
		"stability" = target_mob.bioHolder.genetic_stability
		)

/datum/bioeffectmanager/ui_act(action, params)
	. = ..()
	if (.)
		return
	var/datum/bioEffect/BE = target_mob.bioHolder.effects[params["id"]]
	switch(action)
		if ("addBioEffect")
			var/input = tgui_input_text(usr, "Enter a /datum/bioEffect path or partial name.", "Add a Bioeffect", null, allowEmpty = TRUE)
			input = get_one_match(input, "/datum/bioEffect")
			var/datum/bioEffect/type_to_add = text2path("[input]")
			target_mob.bioHolder.AddEffect(initial(type_to_add.id))
			. = TRUE
		if ("updateStability")
			var/new_stability = text2num(params["value"])
			target_mob.bioHolder.genetic_stability = isnull(new_stability) ? 0 : max(new_stability, 0)
			. = TRUE
		if ("updateCooldown")
			var/new_cooldown = text2num(params["value"])
			BE.cooldown = isnull(new_cooldown) ? 0 : max(new_cooldown, 0)
			. = TRUE
		if ("toggleBoosted")
			BE.power = BE.power == 1 ? 2 : 1
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
			usr.client.debug_variables(BE)
			. = TRUE
		if ("deleteBioEffect")
			target_mob.bioHolder.RemoveEffect(params["id"])
			. = TRUE
