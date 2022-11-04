
/datum/hud/zone_sel
	var/atom/movable/screen/hud/background
	var/atom/movable/screen/hud/head
	var/atom/movable/screen/hud/chest
	var/atom/movable/screen/hud/l_arm
	var/atom/movable/screen/hud/r_arm
	var/atom/movable/screen/hud/l_leg
	var/atom/movable/screen/hud/r_leg
	var/atom/movable/screen/hud/selection

	var/slocation = ui_zone_sel

	var/selecting = "chest"

	var/mob/master
	var/icon/icon_hud = 'icons/mob/hud_human_new.dmi'

	New(M, var/sloc, var/icon/I)
		..()
		master = M
		if (sloc)
			slocation = sloc
		SPAWN(0)
			if (istype(I))
				icon_hud = I
			else if (isrobot(master))
				icon_hud = 'icons/mob/hud_robot.dmi'
			else
				var/icon/hud_style = hud_style_selection[get_hud_style(master)]
				if (isicon(hud_style))
					icon_hud = hud_style
			if (master?.client?.tg_layout && ishuman(master))
				slocation = tg_ui_zone_sel

			background = create_screen("background", "Zone Selection", src.icon_hud, "zone_sel", src.slocation, HUD_LAYER)
			head = create_screen("head", "Target Head", src.icon_hud, "sel-head", src.slocation, HUD_LAYER+1)
			chest = create_screen("chest", "Target Chest", src.icon_hud, "sel-chest", src.slocation, HUD_LAYER+1)
			l_arm = create_screen("l_arm", "Target Left Arm", src.icon_hud, "sel-l_arm", src.slocation, HUD_LAYER+1)
			r_arm = create_screen("r_arm", "Target Right Arm", src.icon_hud, "sel-r_arm", src.slocation, HUD_LAYER+1)
			l_leg = create_screen("l_leg", "Target Left Leg", src.icon_hud, "sel-l_leg", src.slocation, HUD_LAYER+1)
			r_leg = create_screen("r_leg", "Target Right Leg", src.icon_hud, "sel-r_leg", src.slocation, HUD_LAYER+1)
			selection = create_screen("selection", "Current Target ([capitalize(zone_sel2name[src.selecting])])", src.icon_hud, src.selecting, src.slocation, HUD_LAYER+2)

	clear_master()
		master = null
		..()

	relay_click(id, mob/user, list/params)
		if (!id || id == "background" || id == "selection")
			return
		src.select_zone(id)

	proc/select_zone(var/zone)
		if (!zone)
			return
		src.selecting = zone
		src.selection.name = "Current Target ([capitalize(zone_sel2name[zone])])"
		src.selection.icon_state = zone
		out(master, "Now targeting the [zone_sel2name[zone]].")

	proc/change_hud_style(var/icon/new_file)
		if (new_file)
			src.icon_hud = new_file
			if (background) background.icon = new_file
			if (head) head.icon = new_file
			if (chest) chest.icon = new_file
			if (l_arm) l_arm.icon = new_file
			if (r_arm) r_arm.icon = new_file
			if (l_leg) l_leg.icon = new_file
			if (r_leg) r_leg.icon = new_file
			if (selection) selection.icon = new_file
