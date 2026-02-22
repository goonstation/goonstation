
/datum/random_event/minor/sleeper_dead_drop
	name = "Sleeper Dead Drop"
	customization_available = TRUE
	var/admin_override = FALSE
	var/dead_drop_type
	var/sleepers = list()
	var/lock = FALSE
	var/tracker = TRUE
	weight = 500

	is_event_available(var/ignore_time_lock = 0)
		if( emergency_shuttle.online )
			return FALSE

		var/found = FALSE
		for (var/datum/mind/M in ticker.mode?.traitors + ticker.mode?.Agimmicks)
			if (src.eligible(M))
				found = TRUE
				break

		if(found)
			. = ..()
		else
			. = FALSE

	proc/eligible(datum/mind/M)
		var/datum/antagonist/sleeper_agent/SA = M.get_antagonist(ROLE_SLEEPER_AGENT)
		return SA && isnull(SA.dead_drop) && !isdead(M.current) && SA.did_equip

	admin_call(var/source)
		if (..())
			return

		src.admin_override = TRUE

		src.dead_drop_type = tgui_input_list(usr,"Type of...", "Dead Drop Type", concrete_typesof(/datum/dead_drop))
		if (!src.dead_drop_type) //cancel buttons should CANCEL
			return

		src.event_effect(source)
		return

	event_effect(var/source)
		if (!src.admin_override)
			if (!source && (!ticker.mode || ticker.mode.latejoin_antag_compatible == 0 || late_traitors == 0))
				message_admins("Sleeper Agents are disabled in this game mode, aborting.")
				return

			if (emergency_shuttle.online)
				return

		if(!src.dead_drop_type)
#ifdef RP_MODE
			src.dead_drop_type = /datum/dead_drop/infil
#else
			src.dead_drop_type = /datum/dead_drop/chaos
#endif

		message_admins(SPAN_INTERNAL("Setting up Dead Drops. Source: [source ? "[source]" : "random"]"))
		logTheThing(LOG_ADMIN, null, "Setting up Sleeper Dead Drops. Source: [source ? "[source]" : "random"]")

		sleepers = list()
		for (var/datum/mind/M in ticker.mode.traitors + ticker.mode.Agimmicks)
			if (src.eligible(M))
				src.sleepers += M

		SPAWN(0)
			src.lock = TRUE
			do_event(source)

	proc/do_event(var/source)
		var/list/potential_drop_zones = list()
		var/list/area/stationAreas = get_accessible_station_areas()
		for(var/area_name in stationAreas)
			if(istype(stationAreas[area_name], /area/station/security) || stationAreas[area_name].teleport_blocked || istype(stationAreas[area_name], /area/station/turret_protected))
				continue
			potential_drop_zones += stationAreas[area_name]

		for (var/datum/mind/M in src.sleepers )
			var/keycode = random_hex(4)
			var/datum/dead_drop/sleeper_dd = new src.dead_drop_type()
			var/target = sleeper_dd.find_target_location(M.current, potential_drop_zones)

			sleeper_dd.add(target, M.current, keycode, src.tracker)
			var/datum/antagonist/sleeper_agent/SA = M.get_antagonist(ROLE_SLEEPER_AGENT)
			SA.dead_drop = target

		lock = FALSE


/proc/give_them_dead_drop(mob/M, atom/target, datum/dead_drop/drop_type)
	USR_ADMIN_ONLY

	var/list/potential_drop_zones = list()
	var/list/area/stationAreas = get_accessible_station_areas()
	for(var/area_name in stationAreas)
		if(istype(stationAreas[area_name], /area/station/security) || stationAreas[area_name].teleport_blocked || istype(stationAreas[area_name], /area/station/turret_protected))
			continue
		potential_drop_zones += stationAreas[area_name]
	var/dead_drop_type = drop_type
	var/keycode = random_hex(4)

	if(!dead_drop_type)
#ifdef RP_MODE
		dead_drop_type = /datum/dead_drop/infil
#else
		dead_drop_type = /datum/dead_drop/chaos
#endif

	var/datum/dead_drop/sleeper_dd = new dead_drop_type()
	if(!target)
		target = sleeper_dd.find_target_location(M, potential_drop_zones)

	sleeper_dd.add(target, M, keycode, TRUE)


#define KEYPAD_ERR "ERROR"
#define KEYPAD_SET "SET"
#define KEYPAD_OK "OK"

/datum/storage/unholdable/dead_drop
	var/datum/mind/owner
	var/opened = TRUE
	var/locked = TRUE
	var/guess = ""
	var/pad_msg
	var/configure_mode = FALSE
	var/code_len = 4
	var/code = "1234"

	New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding, check_wclass, max_wclass, \
		slots, sneaky, stealthy_storage, opens_if_worn, list/params)
		..()
		if(params["owner"])
			owner = params["owner"]
		if(params["code"])
			code = params["code"]

		RegisterSignal(storage_item, COMSIG_ATTACKHAND, PROC_REF(handle_sig_attackhand))

	disposing()
		UnregisterSignal(src.linked_item, COMSIG_ATTACKHAND)
		..()

	proc/handle_sig_attackhand(comsig_target, mob/attacker)
		if(locked && attacker.mind == owner)
			ui_interact(attacker)
			return TRUE
		else if(attacker.mind == owner && opened)
			src.show_hud(attacker)
		if(attacker.s_active == src.hud)
			opened = TRUE
			return TRUE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "SecureSafe")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"codeLen" = src.code_len,
			"safeName" = "Dead Drop",
			"theme" = "syndicate",
		)

	ui_data(mob/user)
		. = list(
			"attempt" = src.guess,
			"disabled" = FALSE,
			"emagged" = FALSE,
			"padMsg" = src.pad_msg,
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return

		if (!ON_COOLDOWN(linked_item, "playsound", 0.2 SECONDS))
			playsound(linked_item.loc, 'sound/machines/keypress.ogg', 20, 1, -3)

		switch(action)
			if("input")
				src.add_input(params["input"])
			if("enter")
				if (src.configure_mode)
					src.set_code()
				else
					// We're dealing with a configured safe, try to open / close it using the set code
					src.submit_guess(usr)
			if("reset")
				src.clear_input()
		. = TRUE

	ui_status(mob/user, datum/ui_state/state)
		. = min(tgui_physical_state.can_use_topic(linked_item, user),
				tgui_not_incapacitated_state.can_use_topic(linked_item, user))

	transfer_stored_item(obj/item/I, atom/location, add_to_storage = FALSE, mob/user = null)
		..()
		if (!length(src.stored_items))
			qdel(src)

	storage_item_mouse_drop(mob/user, atom/over_object, src_location, over_location)
		if (!src.locked)
			..()

	proc/add_input(var/key)
		var/key_len = length(key)
		var/guess_len = length(src.guess)
		// User is trying to type in code higher than the length, just dump the new input and bail out early
		if (guess_len + key_len > src.code_len)
			return

		// Otherwise add the input to the code attempt
		src.pad_msg = null
		src.guess += key

	proc/set_code()
		// The code is not the correct format: null, wrong length, isn't in hex.
		if (length(src.guess) != src.code_len || !is_hex(src.guess))
			src.pad_msg = KEYPAD_ERR
		// The code is in valid format, lets set it.
		else
			src.pad_msg = KEYPAD_SET
			src.code = src.guess
			src.configure_mode = FALSE
		src.guess = ""

	proc/submit_guess(mob/user)
		if (guess == src.code)
			src.pad_msg = KEYPAD_OK
			src.guess = ""
			src.locked = !src.locked
			boutput(user, SPAN_ALERT("[src.linked_item]'s lock mechanism clicks [src.locked ? "locked" : "unlocked"]."))
			if (!src.locked)
				logTheThing(LOG_STATION, src.linked_item, "at [log_loc(src.linked_item)] has been unlocked by [key_name(user)]. Contents: [linked_item.contents.Join(", ")]")
			var/datum/component/tracker_hud/arrow = user.GetComponent(/datum/component/tracker_hud)
			if(arrow.target == linked_item)
				arrow?.RemoveComponent()
		else
			if (length(guess) == src.code_len)
				boutput(user, SPAN_ALERT("[src.linked_item]'s lock panel emits an error."))
				playsound(linked_item.loc, 'sound/machines/twobeep.ogg', 55, 1)

			src.pad_msg = KEYPAD_ERR
			src.guess= ""

	proc/clear_input()
		src.pad_msg = null
		src.guess = ""

#undef KEYPAD_ERR
#undef KEYPAD_SET
#undef KEYPAD_OK

ABSTRACT_TYPE(/datum/dead_drop)
/datum/dead_drop
	var/list/items = list()
	var/items_min = 3
	var/items_max = 3

	proc/add(atom/target, mob/user, keycode, tracker)
		var/list/params = list()
		if(user)
			params["owner"] = user.mind
		if(keycode)
			params["code"] = keycode

		var/spawn_contents = list()
		var/item_count = rand(items_min, items_max)

		var/possible_spawns = items.Copy()
		for(var/i in 1 to item_count)
			var/new_item = weighted_pick(possible_spawns)
			possible_spawns -= new_item
			spawn_contents += new_item

		target.create_storage(/datum/storage/unholdable/dead_drop, spawn_contents=spawn_contents, slots = length(spawn_contents)+1, max_wclass = W_CLASS_BULKY, params = params)

		user.show_text("<h4>You recall a vision of a dead drop being set up inside of \a [target] at the [get_area(target)].  The code to open it is [keycode].</h4>", "red")
		user.mind.store_memory("<b>Dead Drop:</b> [target] in the [get_area(target)] use the code [keycode].")
		logTheThing(LOG_GAMEMODE, "Setting up Dead Drop for [key_name(user)] inside of \a [target] at [log_loc(target)]. Contents: ([english_list(spawn_contents)])")
		if(tracker)
			user.AddComponent(/datum/component/tracker_hud/dead_drop, target)

	proc/find_target_location(mob/user, area_type_filter)
		var/target = pick(by_cat[TR_CAT_POSSIBLE_DEAD_DROP])

		if(area_type_filter)
			var/attempts = 10
			while(length(by_cat[TR_CAT_POSSIBLE_DEAD_DROP]) && attempts)
				var/area = get_area(target)
				if(area in area_type_filter)
					by_cat[TR_CAT_POSSIBLE_DEAD_DROP] -= target
					attempts = 0
				else
					target = pick(by_cat[TR_CAT_POSSIBLE_DEAD_DROP])
					attempts--

		else
			by_cat[TR_CAT_POSSIBLE_DEAD_DROP] -= target

		return target


/datum/dead_drop/infil
	items_max = 4
	items = list(/obj/item/card/id/syndicate=100,
				/obj/item/gun/kinetic/pistol=25,
				/obj/item/radiojammer=25,
				/obj/item/tool/omnitool=10,
				/obj/item/assembly/flash_cell=5,
				/obj/item/handcuffs/guardbot=5
				)

/datum/dead_drop/destruction
	items_max = 4
	items = list(/obj/item/card/id/syndicate=100,
				/obj/item/implanter/uplink_microbomb=25,
				/obj/item/breaching_charge/thermite=50,
				/obj/item/breaching_charge=50,
				/obj/item/gun/kinetic/pistol=10,
				/obj/item/storage/landmine_pouch=10,
				/obj/item/tool/omnitool=5
				)

/datum/dead_drop/assassin
	items = list(/obj/item/card/id/syndicate=100,
				/obj/item/gun/kinetic/silenced_22=25,
				/obj/item/pen/sleepypen=25,
				/obj/item/dagger/syndicate=10,
				/obj/item/reagent_containers/glass/bottle/poison=10,
				/obj/item/garrote=10
				)

/datum/dead_drop/chaos
	items_max = 5
	items = list(/obj/item/card/id/syndicate=100,
			/obj/item/gun/kinetic/pistol=25,
			/obj/item/assembly/flash_cell=5
			)


#define OPT_INTO_DEAD_DROP(TYPE) \
	TYPE/New() { \
		..(); \
		if(src.z == Z_LEVEL_STATION) {START_TRACKING_CAT(TR_CAT_POSSIBLE_DEAD_DROP);} \
	} \
	TYPE/disposing() { \
		STOP_TRACKING_CAT(TR_CAT_POSSIBLE_DEAD_DROP); \
		..(); \
	}

OPT_INTO_DEAD_DROP(/obj/submachine/slot_machine)
OPT_INTO_DEAD_DROP(/obj/item/instrument/large/jukebox)
OPT_INTO_DEAD_DROP(/obj/machinery/status_display)
OPT_INTO_DEAD_DROP(/obj/stool/bar)
OPT_INTO_DEAD_DROP(/obj/shrub)
OPT_INTO_DEAD_DROP(/obj/potted_plant)
OPT_INTO_DEAD_DROP(/obj/reagent_dispensers/watertank/fountain)
OPT_INTO_DEAD_DROP(/obj/machinery/computer)
OPT_INTO_DEAD_DROP(/obj/machinery/power/apc)
OPT_INTO_DEAD_DROP(/obj/machinery/phone)
