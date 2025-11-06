/datum/abilitymanager
	var/mob/target_mob

/datum/abilitymanager/ui_state(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/abilitymanager/ui_status(mob/user)
	return tgui_admin_state.can_use_topic(src, user)

/datum/abilitymanager/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AbilityManager")
		ui.open()

/datum/abilitymanager/ui_data(mob/user)
	var/list/ability_props = list()
	if (target_mob?.abilityHolder)
		var/list/abilities = list()
		if (istype(target_mob.abilityHolder, /datum/abilityHolder/composite))
			var/datum/abilityHolder/composite/CH = target_mob.abilityHolder
			if (CH.holders.len)
				for (var/datum/abilityHolder/AH in CH.holders)
					abilities += AH.abilities //get a list of all the different abilities in each holder
		else
			abilities += target_mob.abilityHolder?.abilities
		for (var/datum/targetable/ability as anything in abilities)
			ability_props += list(list(
				"abilityRef" = ref(ability),
				"name" = ability,
				"subtype" = strip_prefix(ability.type, "/datum/targetable/"),
				"pointCost" = ability.pointCost,
				"cooldown" = ability.cooldown))
	. = list(
		"target_name" = target_mob,
		"abilities" = ability_props
		)
/datum/abilitymanager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	var/datum/targetable/T = locate(params["abilityRef"])
	if (T && !istype(T)) return
	switch(action)
		if ("addAbility")
			if (!target_mob.abilityHolder)
				tgui_alert(ui.user,"No ability holder detected. Create a holder first!")
				return
			var/input = tgui_input_text(ui.user, "Enter a /datum/targetable path or partial name.", "Add an ability", null, allowEmpty = TRUE)
			input = get_one_match(input, "/datum/targetable", cmp_proc=/proc/cmp_text_asc)
			target_mob.onProcCalled("addAbility", list(input))
			target_mob.abilityHolder.addAbility(input)
			target_mob.abilityHolder.updateButtons()
			logTheThing(LOG_ADMIN, ui.user, "Added ability [input] to [constructName(target_mob)]")
			. = TRUE
		if ("updatePointCost")
			var/new_pointCost = round(text2num(params["value"]))
			T.pointCost = isnull(new_pointCost) ? 0 : max(new_pointCost, 0)
			if (!T.pointCost)
				var/atom/movable/screen/ability/topBar/B = T.object
				B.point_overlay.maptext = null
			. = TRUE
		if ("updateCooldown")
			var/new_cooldown = round(text2num(params["value"]))
			T.cooldown = isnull(new_cooldown) ? 0 : max(new_cooldown, 0)
			. = TRUE
		if ("resetCooldown")
			T.last_cast = 0
		if ("manageAbility")
			ui.user.client.debug_variables(T)
			. = TRUE
		if ("renameAbility")
			var/new_name = tgui_input_text(ui.user, "Enter a new name", "Rename Ability", T.name)
			if (!new_name) return
			T.name = new_name
			T.object.name = new_name
			. = TRUE
		if ("deleteAbility")
			target_mob.abilityHolder.removeAbilityInstance(T)
			target_mob.abilityHolder.updateButtons()
			logTheThing(LOG_ADMIN, ui.user, "Removed ability [T.type] from [constructName(target_mob)]")
			. = TRUE
