TYPEINFO(/obj/item/device/nerd_tool)
	mats = 6

/obj/item/device/nerd_tool
	desc = "A device commonly reffered to with it's abbreviation, N.E.R.D. This tool consists of a stick with complex curcuitry and a port to connect it to electrical tools. Apply it to electric devices to manipulate them to your advantage."
	name = "Network-Enganging Reconfiguration Device"
	icon_state = "nerd_tool"
	item_state = "analyzer"
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	is_syndicate = 1
	contraband = 4
	w_class = W_CLASS_TINY
	inventory_counter_enabled = 1
	var/can_swap_cell = 1 // Can we swap the cell?
	var/rechargeable = 1 // Can we put this gun in a recharger? False should be a very rare exception.
	var/custom_cell_max_capacity = null // There is no limit to this device power
	var/cell_type = /obj/item/ammo/power_cell/med_power // Type of cell to spawn by default.
	var/charge_icon_state = "nerd_tool"
	var/image/charge_image = null

/obj/item/device/nerd_tool/New()
	var/cell = null
	if(cell_type)
		cell = new cell_type
	AddComponent(/datum/component/cell_holder, cell, rechargeable, custom_cell_max_capacity, can_swap_cell)
	RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
	..()
	UpdateIcon()

/obj/item/device/nerd_tool/was_built_from_frame(mob/user, newly_built)
	. = ..()
	SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY) //better drain the cell

/obj/item/device/nerd_tool/afterattack(var/atom/target, var/mob/user)
	if(!target || !user)
		return
	var/energy_cost = target.nerd_tool_act(user, src, FALSE)
	if (energy_cost && (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, energy_cost) & CELL_SUFFICIENT_CHARGE))
		user.visible_message("<span class='combat'><B>[user] applies the [src] onto [target]!</B></span>")
		target.nerd_tool_act(user, src, TRUE)
		SEND_SIGNAL(src, COMSIG_CELL_USE, energy_cost)
		return

/obj/item/device/nerd_tool/examine()
	. = ..()
	var/list/ret = list()
	if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
		. += "There are [ret["charge"]]/[ret["max_charge"]] PUs left!"
	else
		. += "There is no cell loaded!"


/obj/item/device/nerd_tool/update_icon()

	var/list/ret = list()
	if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
		src.inventory_counter.update_percent(ret["charge"], ret["max_charge"])
		src.update_charge_overlay()
	else
		src.inventory_counter.update_text("-")
	return 0

/obj/item/device/nerd_tool/proc/update_charge_overlay()
	var/list/ret = list()
	if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret))
		if (!src.charge_image)
			src.charge_image = image(src.icon)
			src.charge_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
		var/ratio = min(1, ret["charge"] / ret["max_charge"])
		ratio = round(ratio, 0.25) * 100
		src.charge_image.icon_state = "[src.charge_icon_state][ratio]"
		src.UpdateOverlays(src.charge_image, "charge")


/obj/item/device/nerd_tool/emp_act()
	SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
	src.visible_message("[src] sparks briefly as it overloads!")
	playsound(src, "sparks", 75, 1, -1)
	src.UpdateIcon()
	return

/obj/item/device/nerd_tool/nerd_tool_act(var/mob/user, var/obj/item/used_tool, var/do_effect)
	if (used_tool == src)
		return
	if (do_effect)
		src.emp_act()
	return 50
