/datum/buildmode/projectile
	name = "Projectile"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Select projectile type<br>
Ctrl + RMB on buildmode button         = Edit projectile variables<br>
Left Mouse Button                      = FIRE!<br>
***********************************************************"}
	icon_state = "buildmode_zap"
	var/tmp/datum/projectile/P
	var/proj_type = null

	New(datum/buildmode_holder/H)
		. = ..()
		if(!isnull(proj_type))
			src.P = new proj_type()

	click_mode_right(var/ctrl, var/alt, var/shift)
		if (ctrl && P)
			usr.client.debug_variables(P)
		else
			proj_type = tgui_input_list(holder.owner, "Select a projectile type.", "Projectile type", childrentypesof(/datum/projectile), P?.type)
			if (!proj_type) return
			if (P)
				if (proj_type == P.type)
					return
			P = new proj_type()
			update_button_text(proj_type)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!P || !object.loc) return
		if (!get_turf(object)) return
		var/obj/projectile/proj = initialize_projectile_ST(usr, P, object)

		if (proj && !proj.disposed) //ZeWaka: Fix for null.launch()

			if (istype(proj,/datum/projectile/special/homing/orbiter))
				proj.targets = list(usr)

			if (istype(proj.proj_data,/datum/projectile/special/homing/travel))
				proj.special_data["owner"] = usr

			proj.launch()
