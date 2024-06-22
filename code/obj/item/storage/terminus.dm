/obj/item/terminus_drive
	name = "prototype terminus drive"
	desc = "It's longer than you think."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "terminus0"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	inventory_counter_enabled = 1
	w_class = W_CLASS_NORMAL
	var/synchronized = FALSE
	var/cell_type = /obj/item/ammo/power_cell/med_power
	var/power_usage = 2 //cell units per process

	New()
		..()
		var/cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, swappable = FALSE)
		src.create_storage(/datum/storage/terminus, max_wclass = W_CLASS_NORMAL)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		START_TRACKING
		UpdateIcon()

	disposing()
		..()
		processing_items -= src
		STOP_TRACKING

	proc/boot_storage(var/mob/user)
		if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, 10) & CELL_SUFFICIENT_CHARGE)
			if(!user.find_in_hand(src))
				return
			src.storage:synchronize()
			src.icon_state = "terminus1"
			flick("terminus-on",src)
			src.w_class = W_CLASS_BULKY
			src.synchronized = TRUE
			processing_items |= src
			playsound(src.loc, 'sound/effects/manta_interface.ogg', 40, 1)
			if(user)
				boutput(user, SPAN_NOTICE("You initialize [src]'s spatial linkage."))
		else
			if(user)
				boutput(user, SPAN_ALERT("[src] is insufficiently charged to initialize."))

	proc/stop_storage()
		src.synchronized = FALSE
		src.storage:desync()
		src.w_class = W_CLASS_NORMAL
		src.icon_state = "terminus0"
		processing_items -= src
		playsound(src.loc, 'sound/machines/heater_off.ogg', 40, 1)
		flick("terminus-off",src)

	attack_self(mob/user)
		if(!ON_COOLDOWN(src, "toggle", 2 SECONDS))
			if(src.synchronized)
				src.stop_storage()
				boutput(user, SPAN_NOTICE("You deactivate [src]'s spatial linkage."))
			else
				src.boot_storage(user)

	process(datum/source)
		if(SEND_SIGNAL(src, COMSIG_CELL_USE, src.power_usage) & CELL_INSUFFICIENT_CHARGE)
			src.stop_storage()
		return

	update_icon()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
		else
			inventory_counter.update_text("-")
		return 0
