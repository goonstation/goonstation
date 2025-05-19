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
		var/atom/target = locate(params["targetref"])
		if(is_valid_observable(target))
			user.insert_observer(target)
			ui.close()

/datum/observe_menu/proc/is_valid_observable(atom/observable, list/atom/all_observables=null)
	if(isnull(all_observables))
		all_observables = machine_registry[MACHINES_BOTS] + by_cat[TR_CAT_GHOST_OBSERVABLES]
	if(!(observable in all_observables))
		return FALSE

	if(isnull(observable.loc))
		return FALSE

	if(ismob(observable))
		var/mob/M = observable
		// admins aren't observable unless they're in player mode
		if (M.client?.holder && !M.client.player_mode)
			return FALSE
		// remove any secret mobs that someone is controlling
		if (M.unobservable)
			return FALSE

		var/is_npc = M.client == null && M.ghost == null
		if(is_npc && !(M.z == Z_LEVEL_STATION || M.z == Z_LEVEL_DEBRIS || M.z == Z_LEVEL_MINING))
			return FALSE //don't display azone NPCs outside of station, debris, and mining z levels

	return TRUE

/datum/observe_menu/ui_static_data(mob/user)
	var/list/all_observables = machine_registry[MACHINES_BOTS] + by_cat[TR_CAT_GHOST_OBSERVABLES]
	var/DNRSet = user.mind?.get_player()?.dnr

	var/list/uidata = list()
	var/list/namecounts = list()

	for(var/atom/observable in all_observables)
		if(!is_valid_observable(observable, all_observables))
			continue
		var/list/obs_data = list()
		var/mob/observable_mob = observable
		ENSURE_TYPE(observable_mob)
		obs_data["name"] = observable_mob ? observable_mob.real_name : observable.name
		obs_data["ref"] = "\ref[observable]"
		obs_data["real_name"] = obs_data["name"]
		obs_data["dead"] = FALSE
		obs_data["job"] = null
		obs_data["npc"] = FALSE
		obs_data["antag"] = null
		obs_data["player"] = FALSE
		obs_data["dup_name_count"] = 0
		for(var/mob/dead/target_observer/newobs in observable)
			obs_data["ghost_count"]++

		if(ismob(observable))
			var/mob/M = observable
			obs_data["real_name"] = M.real_name
			if(isAIeye(M))
				obs_data["name"] += "'s eye"
				obs_data["real_name"] += "'s eye"
			obs_data["dead"] = isdead(M) || inafterlife(M) || isVRghost(M)
			obs_data["job"] = M.job
			obs_data["npc"] = (M.client == null && M.ghost == null) //dead players have no client, but should have a ghost
			obs_data["player"] = (M.client != null || M.ghost != null) //okay, I know this is just !npc, but it won't ever get set for objects, so it's needed
			if(DNRSet)
				for(var/datum/antagonist/antagdatum in M.mind?.antagonists)
					if(!antagdatum.vr) //if we have one valid antag, that counts
						obs_data["antag"] = antagdatum.display_name
						break

		if (obs_data["name"] in namecounts) //in assoc lists, x in list checks keys for x
			namecounts[obs_data["name"]]++
			obs_data["dup_name_count"] = namecounts[obs_data["name"]]
		else
			namecounts[obs_data["name"]] = 1
		uidata += list(obs_data)
	return list("mydata"=uidata, "dnrset"=DNRSet)
