TYPEINFO(/obj/item/firearm/energy)
	analyser_flags = parent_type::analyser_flags | ANALYSER_ELECTRONIC
	mats = 32

/obj/item/firearm/energy
	name = "energy weapon"
	icon = 'icons/obj/items/guns/energy.dmi'
	item_state = "gun"
	m_amt = 2000
	g_amt = 1000
	add_residue = 0 // Does this gun add gunshot residue when fired? Energy guns shouldn't.
	recoil_inaccuracy_max = 0 //lasers probably dont shudder as you shoot them
	icon_recoil_enabled = FALSE // same, this is probably better to visualize inaccuracy anyway
	camera_recoil_enabled = FALSE // no camera recoil on tasers etc please

	var/rechargeable = 1 // Can we put this gun in a recharger? False should be a very rare exception.
	var/robocharge = 800
	var/cell_type = /obj/item/ammo/power_cell // Type of cell to spawn by default.
	var/from_frame_cell_type = /obj/item/ammo/power_cell
	var/custom_cell_max_capacity = null // Is there a limit as to what power cell (in PU) we can use?
	var/wait_cycle = 0 // Using a self-charging cell should auto-update the gun's sprite.
	var/can_swap_cell = 1
	var/uses_charge_overlay = FALSE //! Does this gun use charge overlays on the sprite?
	var/charge_icon_state
	var/restrict_cell_type
	var/image/charge_image = null
	muzzle_flash = null
	inventory_counter_enabled = 1

	New()
		var/cell = null
		if(cell_type)
			cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, rechargeable, custom_cell_max_capacity, can_swap_cell, restrict_cell_type)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		..()
		UpdateIcon()

	disposing()
		processing_items -= src
		..()

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		if(from_frame_cell_type)
			AddComponent(/datum/component/cell_holder, new from_frame_cell_type)

		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY) //also drain the cell out of spite

	examine()
		. = ..()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			. += "[src.projectiles ? "It is set to [src.current_projectile.sname]. " : ""]There are [ret["charge"]]/[ret["max_charge"]] PUs left!"
		else
			. += "There is no cell loaded!"
		if(current_projectile)
			. += "Each shot will currently use [src.current_projectile.cost] PUs!"
		else
			. += SPAN_ALERT("*ERROR* No output selected!")

	update_icon()

		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
			inventory_counter.update_percent(ret["charge"], ret["max_charge"])
			if(uses_charge_overlay)
				update_charge_overlay()
		else
			inventory_counter.update_text("-")
		return 0

	emp_act()
		SEND_SIGNAL(src, COMSIG_CELL_USE, INFINITY)
		src.visible_message("[src] sparks briefly as it overloads!")
		playsound(src, "sparks", 75, 1, -1)
		src.UpdateIcon()
		return

	proc/update_charge_overlay()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret))
			if (!src.charge_image)
				src.charge_image = image(src.icon)
				src.charge_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			ratio = round(ratio, 0.25) * 100
			src.charge_image.icon_state = "[src.charge_icon_state][ratio]"
			src.UpdateOverlays(src.charge_image, "charge")

/*
	process()
		src.wait_cycle = !src.wait_cycle // Self-charging cells recharge every other tick (Convair880).
		if (src.wait_cycle)
			return

		if (!(src in processing_items))
			logTheThing(LOG_DEBUG, null, "<b>Convair880</b>: Process() was called for an egun ([src]) that wasn't in the item loop. Last touched by: [replace_if_false(src.get_last_ckey(), "None")]")
			processing_items.Add(src)
			return
		if (!src.cell)
			processing_items.Remove(src)
			return
		if (!istype(src.cell, /obj/item/ammo/power_cell/self_charging)) // Plain cell? No need for dynamic updates then (Convair880).
			processing_items.Remove(src)
			return
		if (src.cell.charge == src.cell.max_charge) // Keep them in the loop, as we might fire the gun later (Convair880).
			return

		src.UpdateIcon()
		return
*/

	canshoot(mob/user)
		if(src.current_projectile)
			if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, current_projectile.cost) & CELL_SUFFICIENT_CHARGE)
				return 1
		return 0

	process_ammo(var/mob/user)
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(R.cell)
				if(R.cell.charge >= src.robocharge)
					R.cell.use(src.robocharge)
					return 1
			return 0
		else
			if(canshoot(user))
				SEND_SIGNAL(src, COMSIG_CELL_USE, src.current_projectile.cost)
				return 1
			if (src.click_sound)
				boutput(user, SPAN_ALERT(src.click_msg))
				if (!src.silenced)
					playsound(user, src.click_sound, 60, TRUE)
			return 0
