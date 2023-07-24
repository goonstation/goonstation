/datum/observe_menu


/datum/observe_menu/ui_state(mob/user)
	return tgui_always_state.can_use_topic(src, user)

/datum/observe_menu/ui_status(mob/user, datum/ui_state/state)
	return tgui_always_state.can_use_topic(src, user)

/datum/observe_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ObserverMenu")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/observe_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/dead/observer/user = ui.user
	if(istype(user) && params["targetref"])
		user.insert_observer(locate(params["targetref"]))


/datum/observe_menu/ui_static_data(mob/user)
	var/list/all_observables = machine_registry[MACHINES_BOTS] + by_cat[TR_CAT_GHOST_OBSERVABLES]
	var/DNRSet = user.mind?.get_player()?.dnr

	var/list/uidata = list()
	var/list/namecounts = list()

	for(var/atom/observable in all_observables)
		var/list/obs_data = list()
		obs_data["name"] = observable.name
		obs_data["ref"] = "\ref[observable]"
		obs_data["real_name"] = obs_data["name"]
		obs_data["dead"] = FALSE
		obs_data["job"] = null
		obs_data["npc"] = FALSE
		obs_data["antag"] = FALSE
		obs_data["player"] = null

		if(ismob(observable))
			var/mob/M = observable
			// admins aren't observable unless they're in player mode
			if (M.client?.holder && !M.client.player_mode)
				continue
			// remove any secret mobs that someone is controlling
			if (M.unobservable)
				continue

			obs_data["real_name"] = M.real_name
			obs_data["dead"] = isdead(M)
			obs_data["job"] = M.job
			obs_data["npc"] = (M.client == null)
			if(DNRSet)
				obs_data["antag"] = !isnull(M.mind?.special_role)

		if (observable.name in namecounts) //in assoc lists, x in list checks keys for x
			namecounts[observable.name]++
			obs_data["name"] = "[observable.name] ([namecounts[observable.name]])"
		else
			namecounts[observable.name] = 1
		uidata += list(obs_data)
	return uidata
