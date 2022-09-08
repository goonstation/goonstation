/mob/living/silicon/shell
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "eyebot-logout"

	health = 40
	max_health = 40

	var/mob/living/silicon/ai/controller
	var/inactive_name = "Shell"
	var/datum/hud/shell/hud

	var/active_tool = 0
	var/list/obj/item/active_tools = list(null, null, null)
	var/list/obj/item/tools = list()

	New()
		..()
		bioHolder = new(src)

		inactive_name = "Shell-[rand(111, 999)]"
		name = inactive_name

		cell = new /obj/item/cell(src)
		cell.charge = cell.maxcharge
		tools = list(new /obj/item/device/light/flashlight(src), new /obj/item/crowbar(src), new /obj/item/device/multitool(src), new /obj/item/screwdriver(src))

		hud = new(src)

	death(gibbed)
	//	if (controller)
	//		controller.leave_shell()
		UpdateIcon()
		set_density(0)
		..()

	click(atom/target, list/params)
		if ((target in src.tools) && !(target in src.active_tools))
			src.equip_tool(target)
			return
		..()

	UpdateIcon()
		if (src.stat)
			src.icon_state = "eyebot-dead"
		else if (src.controller)
			src.icon_state = "eyebot"
		else
			src.icon_state = "eyebot-logout"

	show_message(msg, type, alt, alt_type)
		if (src.controller)
			boutput(src.controller, msg)
		..()

	Life(datum/controller/process/mobs/parent)
		..(parent)

		if (src.controller)
			hud.update_charge()

	updatehealth()
		..()
		if (health < 0 && !isdead(src))
			setdead(src)
			death(FALSE)

	swap_hand(var/switchto = 0)
		if (!switchto)
			switchto = (active_tool % 3) + 1
		if (switchto == active_tool) // trying to select the same tool deselects
			active_tool = 0
		else
			active_tool = tool
		if (active_tool > 0 && isnull(active_tools[active_tool]))
			active_tool = 0
		hud.update_active_tool()

	proc/equip_tool(obj/item/tool)
		if (isnull(active_tools[1]))
			active_tools[1] = tool
			boutput(world, tool)
			boutput(world, src)
			boutput(active_tools[1])
			tool.pickup(src)  // attempted fix for no flashlight functionality - cirr
		else if (isnull(active_tools[2]))
			active_tools[2] = tool
			tool.pickup(src)  // attempted fix for no flashlight functionality - cirr
		else if (isnull(active_tools[3]))
			active_tools[3] = tool
			tool.pickup(src)  // attempted fix for no flashlight functionality - cirr
		hud.update_tool_selector()
		hud.update_tools()

	proc/store_active_tool()
		if (active_tool < 1)
			return
		active_tools[active_tool].dropped(src) // attempted fix for no flashlight functionality - cirr
		active_tools[active_tool] = null
		active_tool = 0
		hud.update_active_tool()
		hud.update_tools()
		hud.update_tool_selector()

	equipped()
		if (active_tool < 1)
			return null
		return active_tools[active_tool]

	bump(atom/movable/AM as mob|obj)
		SPAWN( 0 )
			if (src.now_pushing)
				return
			..()
			if (!istype(AM, /atom/movable))
				return
			if (!src.now_pushing)
				src.now_pushing = 1
				if (!AM.anchored)
					var/t = get_dir(src, AM)
					step(AM, t)
				src.now_pushing = null
			return
		return
