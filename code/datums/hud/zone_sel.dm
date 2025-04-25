
/atom/movable/screen/hud/zone_zel
	MouseWheel(delta_x, delta_y, location, control, params)
		var/datum/hud/zone_sel/zone_sel = master
		if (zone_sel.master?.zone_sel != zone_sel || usr != zone_sel.master)
			return
		if (usr.client.preferences.scrollwheel_limb_targeting == SCROLL_TARGET_HOVER)
			zone_sel.scroll_target(delta_y)

/datum/hud/zone_sel

	// list of current zone sel to the next zone sel if you scroll up
	var/static/list/zone_sels_positive_delta = list("head" = "head", "chest" = "head", "l_arm" = "chest", "r_arm" = "l_arm", "l_leg" = "r_arm", "r_leg" = "l_leg")
	// list of current zone sel to the next zone sel if you scroll down
	var/static/list/zone_sels_negative_delta = list("head" = "chest", "chest" = "l_arm", "l_arm" = "r_arm", "r_arm" = "l_leg", "l_leg" = "r_leg", "r_leg" = "r_leg")

	var/atom/movable/screen/hud/zone_zel/background
	var/atom/movable/screen/hud/zone_zel/head
	var/atom/movable/screen/hud/zone_zel/chest
	var/atom/movable/screen/hud/zone_zel/l_arm
	var/atom/movable/screen/hud/zone_zel/r_arm
	var/atom/movable/screen/hud/zone_zel/l_leg
	var/atom/movable/screen/hud/zone_zel/r_leg
	var/atom/movable/screen/hud/zone_zel/selection

	var/slocation = ui_zone_sel

	var/selecting = "chest"

	var/mob/master
	var/icon/icon_hud = 'icons/mob/hud_human_new.dmi'

	New(M, var/sloc, var/icon/I)
		..()
		master = M
		if (sloc)
			slocation = sloc
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

		background = create_screen("background", "Zone Selection", src.icon_hud, "zone_sel", src.slocation, HUD_LAYER, customType=/atom/movable/screen/hud/zone_zel)
		head = create_screen("head", "Target Head", src.icon_hud, "sel-head", src.slocation, HUD_LAYER+1, customType=/atom/movable/screen/hud/zone_zel)
		chest = create_screen("chest", "Target Chest", src.icon_hud, "sel-chest", src.slocation, HUD_LAYER+1, customType=/atom/movable/screen/hud/zone_zel)
		l_arm = create_screen("l_arm", "Target Left Arm", src.icon_hud, "sel-l_arm", src.slocation, HUD_LAYER+1, customType=/atom/movable/screen/hud/zone_zel)
		r_arm = create_screen("r_arm", "Target Right Arm", src.icon_hud, "sel-r_arm", src.slocation, HUD_LAYER+1, customType=/atom/movable/screen/hud/zone_zel)
		l_leg = create_screen("l_leg", "Target Left Leg", src.icon_hud, "sel-l_leg", src.slocation, HUD_LAYER+1)
		r_leg = create_screen("r_leg", "Target Right Leg", src.icon_hud, "sel-r_leg", src.slocation, HUD_LAYER+1, customType=/atom/movable/screen/hud/zone_zel)
		selection = create_screen("selection", "Current Target ([capitalize(zone_sel2name[src.selecting])])", src.icon_hud, src.selecting, src.slocation, HUD_LAYER+2, customType=/atom/movable/screen/hud/zone_zel)

	disposing()
		QDEL_NULL(background)
		QDEL_NULL(head)
		QDEL_NULL(chest)
		QDEL_NULL(l_arm)
		QDEL_NULL(r_arm)
		QDEL_NULL(l_leg)
		QDEL_NULL(r_leg)
		QDEL_NULL(selection)
		src.master = null
		. = ..()


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
		boutput(master, "Now targeting the [zone_sel2name[zone]].", group="zone_sel")

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

	proc/scroll_target(delta_y)
		var/new_zone = src.selecting
		if (delta_y > 0)
			new_zone = src.zone_sels_positive_delta[src.selecting]
		else
			new_zone = src.zone_sels_negative_delta[src.selecting]
		if(new_zone != src.selecting)
			src.select_zone(new_zone)
