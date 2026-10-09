/datum/ghost_critter_respawn_menu
	ui_state(mob/user)
		return tgui_observer_state

	ui_status(mob/user, datum/ui_state/state)
		if (!user.client || user.client.mob != user || !user.mind || user.mind.current != user)
			return UI_CLOSE
		return tgui_observer_state.can_use_topic(src, user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "GhostCritterRespawn", "Respawn as Animal")
			ui.open()

	ui_data(mob/user)
		var/list/critters = list()
		for (var/mob/living/critter/critter_type as anything in user.get_ghost_critter_types())
			var/preview_state = initial(critter_type.icon_state)
			// Figures choose their actual appearance in New() at random; so we just use a representative figure for the preview.
			if (ispath(critter_type, /mob/living/critter/small_animal/figure))
				var/datum/figure_info/figure = /datum/figure_info/assistant
				preview_state = "fig-[initial(figure.icon_state)]"
			critters += list(list(
				"type" = "[critter_type]",
				"name" = capitalize(initial(critter_type.name)),
				"icon" = get_tgui_icon(get_initial_icon(critter_type)),
				"iconState" = preview_state,
				"isAntagonist" = (critter_type in antag_respawn_critter_types),
			))
		return list("critters" = critters)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		if (..())
			return
		if (action != "respawn")
			return
		var/mob/dead/observer/ghost = ui.user
		if (!istype(ghost) || src.ui_status(ghost, state) != UI_INTERACTIVE)
			return
		if (!istext(params["type"]))
			return
		var/critter_type = text2path(params["type"])
		if (!(critter_type in ghost.get_ghost_critter_types()))
			return
		if (!ghost.can_respawn_as_ghost_critter())
			return

		var/turf/spawnpoint = pick_landmark(LANDMARK_PESTSTART)
		if (!spawnpoint)
			spawnpoint = pick_landmark(LANDMARK_LATEJOIN, get_turf(ghost))
		ui.close()
		ghost.make_ghost_critter(spawnpoint, critter_type = critter_type)
		return TRUE
