/datum/hud/shell
	var/atom/movable/screen/hud
		tool1
		tool2
		tool3
		charge
		eyecam

	var/list/last_tools = list()
	var/list/atom/movable/screen/hud/tool_selector_bg = list()
	var/list/obj/item/tool_selector_tools = list()
	var/show_tool_selector = 0
	var/mob/living/silicon/hivebot/master

	New(M)
		..()
		master = M

		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_bg", "CENTER-3:16, SOUTH to CENTER+2:16, SOUTH", HUD_LAYER)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-3:16, SOUTH+1 to CENTER+2:16, SOUTH+1", HUD_LAYER, SOUTH)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-4:16, SOUTH+1", HUD_LAYER, SOUTHWEST)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER-4:16, SOUTH", HUD_LAYER, EAST)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+3:16, SOUTH+1", HUD_LAYER, SOUTHEAST)
		create_screen("", "", 'icons/mob/hud_common.dmi', "hotbar_side", "CENTER+3:16, SOUTH", HUD_LAYER, WEST)

		charge = create_screen("charge", "Battery", 'icons/mob/hud_robot.dmi', "charge4", "CENTER-3:16, SOUTH", HUD_LAYER+1)
		tool1 = create_screen("tool1", "Tool 1", 'icons/mob/hud_robot.dmi', "mod10", "CENTER-2:16, SOUTH", HUD_LAYER+1)
		tool2 = create_screen("tool2", "Tool 2", 'icons/mob/hud_robot.dmi', "mod20", "CENTER-1:16, SOUTH", HUD_LAYER+1)
		tool3 = create_screen("tool3", "Tool 3", 'icons/mob/hud_robot.dmi', "mod30", "CENTER:16, SOUTH", HUD_LAYER+1)
		create_screen("store", "Store", 'icons/mob/hud_robot.dmi', "store", "CENTER+1:16, SOUTH", HUD_LAYER+1)
		create_screen("tools", "Tools", 'icons/mob/hud_robot.dmi', "tools", "CENTER+2:16, SOUTH", HUD_LAYER+1)

		eyecam = create_screen("eyecam", "Eject to eyecam", 'icons/mob/screen1.dmi', "x", "SOUTH,EAST", HUD_LAYER)
		eyecam.underlays += "block"

		update_active_tool()
		update_tools()
		update_tool_selector()

	clear_master()
		master = null
		..()

	relay_click(id)
		if (!master)
			return

		switch (id)
			if ("tool1")
				master.swap_hand(1)
			if ("tool2")
				master.swap_hand(2)
			if ("tool3")
				master.swap_hand(3)
			if ("store")
				master.uneq_active()
			if ("tools")
				set_show_tool_selector(!show_tool_selector)
			if ("eyecam")
				master.become_eye()

	proc
		update_charge()
			if (master.cell)
				switch(round(100*master.cell.charge/master.cell.maxcharge))
					if(75 to INFINITY)
						charge.icon_state = "charge4"
					if(50 to 75)
						charge.icon_state = "charge3"
					if(25 to 50)
						charge.icon_state = "charge2"
					if(1 to 25)
						charge.icon_state = "charge1"
					else
						charge.icon_state = "charge0"
			else
				charge.icon_state = "charge-none"

		update_active_tool()
			if (!master.module_active)
				tool1.icon_state = "mod10"
				tool2.icon_state = "mod20"
				tool3.icon_state = "mod30"
			else
				tool1.icon_state = "mod1[master.module_active == master.module_states[1]]"
				tool2.icon_state = "mod2[master.module_active == master.module_states[2]]"
				tool3.icon_state = "mod3[master.module_active == master.module_states[3]]"

		update_tools()
			for (var/obj/item/I in last_tools)
				I.set_loc(master.module) //All the set_loc calls in this proc are because some items (or really just the flashlight) need a location change to update component stuff correctly
				remove_object(I)
			var/obj/item/tool1 = master.module_states[1]
			var/obj/item/tool2 = master.module_states[2]
			var/obj/item/tool3 = master.module_states[3]
			if (tool1)
				add_object(tool1, HUD_LAYER+2, "CENTER-2:16, SOUTH")
				tool1.set_loc(master)
			if (tool2)
				add_object(tool2, HUD_LAYER+2, "CENTER-1:16, SOUTH")
				tool2.set_loc(master)
			if (tool3)
				add_object(tool3, HUD_LAYER+2, "CENTER:16, SOUTH")
				tool3.set_loc(master)
			last_tools = master.module_states.Copy()

		update_tool_selector()
			if (!master.module)
				return

			for (var/obj/item/tool in tool_selector_tools)
				remove_object(tool)

			tool_selector_tools.len = 0
			var/i = 0
			for (var/obj/item/tool in master.module.tools)
				if (!(tool in master.module_states))
					tool_selector_tools += tool
					tool.screen_loc = "CENTER+2:16, SOUTH+[1+i]"
					i += 1

			for (var/atom/movable/screen/hud/H in tool_selector_bg)
				remove_screen(H)


			tool_selector_bg.len = 0
			if (tool_selector_tools.len > 0)
				tool_selector_bg += create_screen("", "", 'icons/mob/hud_robot.dmi', "tools-top", "CENTER+2:16, SOUTH+[tool_selector_tools.len]", HUD_LAYER+1)
			if (tool_selector_tools.len > 1)
				tool_selector_bg += create_screen("", "", 'icons/mob/hud_robot.dmi', "tools-mid", "CENTER+2:16, SOUTH+1 to CENTER+2:16, SOUTH+[tool_selector_tools.len-1]", HUD_LAYER+1)

			if (!show_tool_selector)
				for (var/atom/movable/screen/hud/H in tool_selector_bg) // this is dumb
					remove_screen(H)
			else
				for (var/obj/item/tool in tool_selector_tools)
					add_object(tool, HUD_LAYER+2)

		set_show_tool_selector(show)
			if (show == show_tool_selector)
				return
			show_tool_selector = show
			if (show)
				for (var/atom/movable/screen/hud/H in tool_selector_bg)
					add_screen(H)
				for (var/obj/item/tool in tool_selector_tools)
					add_object(tool, HUD_LAYER+2)
			else
				for (var/atom/movable/screen/hud/H in tool_selector_bg)
					remove_screen(H)
				for (var/obj/item/tool in tool_selector_tools)
					remove_object(tool)
