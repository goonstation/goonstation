
TYPEINFO(/obj/item/radiojammer)
	mats = 10

/obj/item/radiojammer
	name = "signal jammer"
	desc = "An illegal device used to jam radio signals, preventing broadcast or transmission. This one is equipped with a miniaturised singularity for infinite charge."
	icon = 'icons/obj/shield_gen.dmi'
	icon_state = "syndieshieldoff"
	w_class = W_CLASS_TINY
	is_syndicate = TRUE
	var/active = FALSE
	var/range = DEFAULT_RADIO_JAMMER_RANGE
	var/base_icon = "syndieshield"

/obj/item/radiojammer/New()
	. = ..()
	src.RegisterSignal(src, COMSIG_SIGNAL_JAMMED, PROC_REF(signal_jammed))
	src.UpdateIcon()

/obj/item/radiojammer/disposing()
	STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
	. = ..()

/obj/item/radiojammer/update_icon(...)
	. = ..()
	src.icon_state = "[src.base_icon][src.active ? "on" : "off"]"

/obj/item/radiojammer/get_desc(dist, mob/user)
	. = ..()
	. += " The range is currently set to [src.range]."
	if(!src.active)
		.+= " It is off."

/obj/item/radiojammer/proc/signal_jammed(_source, datum/signal/signal)
	//hoping this isn't too performance heavy if a lot of signals get blocked at once
	if (!src.GetOverlayImage("jammed_light"))
		//automatic heartbeat signals: we still want to know when we're jamming them but we probably don't care most of the time
		var/icon_state = signal.data["command"] == "heartbeat" ? "signal_jammed_heartbeat" : "signal_jammed"
		src.UpdateOverlays(image(src.icon, icon_state), "jammed_light")
	SPAWN(2 DECI SECONDS)
		src.ClearSpecificOverlays("jammed_light")

/obj/item/radiojammer/attack_self(mob/user)
	if (!istype(global.radio_controller))
		return

	src.active = !src.active

	if (src.active)
		boutput(user, "You activate [src].")
		START_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
	else
		boutput(user, "You shut off [src].")
		STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
	src.UpdateIcon()

/obj/item/radiojammer/attackby(obj/item/W, mob/user, params)
	if(isscrewingtool(W) || ispulsingtool(W))
		src.edit_range(user)
		return
	. = ..()

/obj/item/radiojammer/proc/edit_range(mob/user)
	var/inputted_number = tgui_input_number(user, "Input radio jammer range", "Radio Jammer", DEFAULT_RADIO_JAMMER_RANGE, DEFAULT_RADIO_JAMMER_RANGE, 1)
	if(!inputted_number)
		return
	if(!can_act(user))
		boutput(user, SPAN_ALERT("Not while incapacitated!"))
		return
	if(BOUNDS_DIST(src,user) > 1)
		boutput(user, SPAN_ALERT("You are too far away from [src]!"))
		return
	inputted_number = trunc(inputted_number)
	if(!isnum_safe(inputted_number) || inputted_number > DEFAULT_RADIO_JAMMER_RANGE || inputted_number < 1)
		boutput(user, SPAN_ALERT("That number is out of [src]'s range!"))
		return
	src.range = inputted_number
	boutput(user, SPAN_NOTICE("You set [src]'s range to [inputted_number]."))

/obj/item/radiojammer/charged
	desc = "An illegal device used to jam radio signals, preventing broadcast or transmission. This one has a slot for a power cell."
	icon_state = "shieldoff"
	w_class = W_CLASS_TINY
	base_icon = "shield"
	inventory_counter_enabled = TRUE
	var/power_cost_per_tick = 10

	New()
		. = ..()
		AddComponent(/datum/component/cell_holder, new/obj/item/ammo/power_cell)
		global.processing_items |= src
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)

	disposing()
		global.processing_items -= src
		. = ..()

	process()
		if(!src.active)
			return
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, src.power_cost_per_tick) & CELL_SUFFICIENT_CHARGE))
			src.active = FALSE
			STOP_TRACKING_CAT(TR_CAT_RADIO_JAMMERS)
			src.UpdateIcon()
			if(ismob(src.loc))
				boutput(src.loc, SPAN_ALERT("[src] runs out of charge and powers down!"))
			return
		SEND_SIGNAL(src, COMSIG_CELL_USE, src.power_cost_per_tick)

	update_icon(...)
		. = ..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])

	attack_self()
		if (!src.active && !(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, src.power_cost_per_tick) & CELL_SUFFICIENT_CHARGE))
			boutput(src.loc, SPAN_ALERT("[src] doesn't have enough charge to turn on!"))
			return
		. = ..()



