///////////////////////////////////////Rad Crossbow
TYPEINFO(/obj/item/gun/energy/crossbow)
	analyser_flags = parent_type::analyser_flags | ANALYSER_SYNDIE_ONLY
	mats = list("metal" = 5,
				"conductive_high" = 5,
				"energy_high" = 10)
/obj/item/gun/energy/crossbow
	name = "\improper Wenshen mini rad-poison-crossbow"
	desc = "The XIANG|GIESEL Wenshen (瘟神) crossbow favored by many of the Syndicate's stealth specialists, which does damage over time using a slow-acting radioactive poison. Utilizes a self-recharging atomic power cell from Giesel Radiofabrik."
	icon_state = "crossbow"
	w_class = W_CLASS_SMALL
	item_state = "crossbow"
	force = 4
	throw_speed = 3
	throw_range = 10
	rechargeable = 0 // Cannot be recharged manually.
	cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/slowcharge
	projectiles = null
	silenced = 1 // No conspicuous text messages, please (Convair880).
	hide_attack = ATTACK_FULLY_HIDDEN
	custom_cell_max_capacity = 100 // Those self-charging ten-shot radbows were a bit overpowered (Convair880)
	muzzle_flash = null
	uses_charge_overlay = TRUE
	charge_icon_state = "crossbow"

	New()
		set_current_projectile(new/datum/projectile/rad_bolt)
		projectiles = list(current_projectile)
		..()


	update_charge_overlay()
		var/list/ret = list()
		if(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret))
			if (!src.charge_image)
				src.charge_image = image(src.icon)
				src.charge_image.appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA
			var/ratio = min(1, ret["charge"] / ret["max_charge"])
			// the -0.125 is so we only show the final state when we're actually ready to fire
			ratio = round(ratio-0.125, 0.25) * 100
			src.charge_image.icon_state = "[src.charge_icon_state][ratio]"
			src.UpdateOverlays(src.charge_image, "charge")
