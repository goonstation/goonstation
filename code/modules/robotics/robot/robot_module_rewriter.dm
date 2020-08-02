/obj/machinery/computer/robot_module_rewriter
	name = "cyborg module rewriter"
	desc = "A machine used to reconfigure cyborg modules."
	icon_state = "robot_module_rewriter"
	anchored = 1
	density = 1
	lr = 1
	lg = 0.4
	lb = 0
	var/chui/window/robot_module_rewriter/ui = null
	var/obj/item/robot_module/module = null
	var/module_reset_lock = 1
	var/module_tool_removal_lock = 1

/obj/machinery/computer/robot_module_rewriter/attackby(obj/item/I as obj, mob/user as mob)
	if (isscrewingtool(I))
		playsound(get_turf(src), "sound/items/Screwdriver.ogg", 50, 1)
		if (do_after(user, 20))
			var/obj/computerframe/computer = new /obj/computerframe(src.loc)
			var/obj/item/circuitboard/robot_module_rewriter/circuitboard = new /obj/item/circuitboard/robot_module_rewriter(computer)
			computer.circuit = circuitboard
			computer.anchored = 1
			if (src.material)
				computer.setMaterial(src.material)
			if (src.status & BROKEN)
				boutput(user, "<span class=\"notice\">The broken glass falls out.</span>")
				var/obj/item/raw_material/shard/glass/glass_shard = unpool(/obj/item/raw_material/shard/glass)
				glass_shard.set_loc(src.loc)
				computer.state = 3
				computer.icon_state = "3"
			else
				boutput(user, "<span class=\"notice\">You disconnect the monitor.</span>")
				computer.state = 4
				computer.icon_state = "4"
			for (var/obj/contained_item in src)
				contained_item.set_loc(src.loc)
			qdel(src)
	else if (istype(I, /obj/item/robot_module))
		// insert cyborg module
		if (src.module)
			boutput(user, "<span class=\"alert\">The [src] already has a module inserted.</span>")
			return
		user.drop_item()
		I.set_loc(src)
		src.module = I
		boutput(user, "<span class=\"notice\">You insert [I] into the [src].</span>")
		src.update_module_ui()
	else
		src.attack_hand(user)

/obj/machinery/computer/robot_module_rewriter/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/robot_module_rewriter/attack_hand(mob/user as mob)
	if (!user)
		return
	src.add_fingerprint(user)
	if (src.status & (BROKEN | NOPOWER))
		return
	if (!src.ui)
		src.ui = new /chui/window/robot_module_rewriter(src)
	src.ui.Subscribe(user.client)

/**
 * @typedef {/list} RobotModuleRewriter~ConfigurationData
 * @property {boolean} [moduleResetLock] Whether module reset lock is engaged.
 * @property {boolean} [moduleToolRemovalLock] Whether module tool removal lock is engaged.
 */

/**
 * @return {RobotModuleRewriter~ConfigurationData}
 */
/obj/machinery/computer/robot_module_rewriter/proc/build_configuration_data()
	var/list/data = list()
	data["moduleResetLock"] = src.module_reset_lock
	data["moduleToolRemovalLock"] = src.module_tool_removal_lock
	return data

/**
 * @typedef {/list} RobotModuleRewriter~ModuleData
 * @property {string} [moduleName]  Name of module, if module is present.
 */

/**
 * @return {RobotModuleRewriter~ModuleData}
 */
/obj/machinery/computer/robot_module_rewriter/proc/build_module_data()
	var/list/data = list()
	if (src.module)
		data["moduleName"] = src.module.name
	return data

/**
 * @typedef {/list} RobotModuleRewriter~ModuleTool}
 * @property {string} name Name of the tool.
 * @property {string} ref \ref of the tool.
 */

/**
 * @typedef {/list} RobotModuleRewriter~ModuleToolsData
 * @property {RobotModuleRewriter~ModuleTool[]} [tools] Tools within the module.
 */

/**
 * @return {RobotModuleRewriter~ModuleToolsData}
 */
/obj/machinery/computer/robot_module_rewriter/proc/build_module_tools_data()
	var/list/data = list()
	var/list/tools_data = list()
	if (src.module)
		for (var/obj/item/tool in src.module.modules)
			var/list/tool_data = list()
			tool_data["name"] = tool.name
			tool_data["ref"] = "\ref[tool]"
			// wrapping in a list to append actual list rather than contents
			tools_data += list(tool_data)
	data["tools"] = tools_data
	return data

/obj/machinery/computer/robot_module_rewriter/proc/send_configuration_details()
	if (src.ui)
		var/list/data = list()
		data += src.build_configuration_data()
		src.ui.CallJSFunction("updateConfiguration", list(json_encode(data)))

/obj/machinery/computer/robot_module_rewriter/proc/send_module_details()
	if (src.ui)
		var/list/data = list()
		if (src.module)
			data += src.build_module_data()
			data += src.build_module_tools_data()
		src.ui.CallJSFunction("updateModule", list(json_encode(data)))

/obj/machinery/computer/robot_module_rewriter/proc/send_module_tools_details()
	if (src.ui)
		var/list/data = list()
		if (src.module)
			data += src.build_module_tools_data()
		src.ui.CallJSFunction("updateModuleTools", list(json_encode(data)))

/obj/machinery/computer/robot_module_rewriter/proc/update_ui()
	src.update_configuration_ui()
	src.update_module_ui()

/obj/machinery/computer/robot_module_rewriter/proc/update_configuration_ui()
	src.send_configuration_details()

/obj/machinery/computer/robot_module_rewriter/proc/update_module_ui()
	src.send_module_details()

/obj/machinery/computer/robot_module_rewriter/proc/update_module_tools_ui()
	src.send_module_tools_details()

/obj/machinery/computer/robot_module_rewriter/Topic(href, href_list)
	if (..())
		return

	if (href_list["lock-toggle"])
		switch (href_list["lock-toggle"])
			if ("module-reset")
				src.module_reset_lock = !src.module_reset_lock
			if ("module-tool-removal")
				src.module_tool_removal_lock = !src.module_tool_removal_lock
		src.update_configuration_ui()
	else if (href_list["module-eject"])
		if (src.module)
			usr.put_in_hand_or_eject(src.module)
			src.module = null
			src.update_module_ui()
	else if (href_list["module-reset"])
		if (src.module && !src.module_reset_lock)
			// wipe the module and replace with a fresh one from the available options
			var/module_path = null
			switch (href_list["module-reset"])
				if ("brobocop")
					module_path = /obj/item/robot_module/brobocop
				if ("chemistry")
					module_path = /obj/item/robot_module/chemistry
				if ("civilian")
					module_path = /obj/item/robot_module/civilian
				if ("engineering")
					module_path = /obj/item/robot_module/engineering
				if ("medical")
					module_path = /obj/item/robot_module/medical
				if ("mining")
					module_path = /obj/item/robot_module/mining
			if (module_path)
				qdel(src.module)
				var/obj/item/robot_module/replacement_module = new module_path(src)
				src.module = replacement_module
				// re-apply the lock, to avoid accidentally leaving unlocked
				src.module_reset_lock = 1
				src.update_configuration_ui()
				src.update_module_ui()
	else if (href_list["tool-move-down"])
		if (src.module)
			var/obj/item/tool = locate(href_list["tool-move-down"])
			if (tool)
				var/toolIndex = src.module.modules.Find(tool)
				if (toolIndex > 0 && toolIndex < src.module.modules.len)
					// allow move if second to last tool or earlier
					src.module.modules.Swap(toolIndex, toolIndex + 1)
			src.update_module_tools_ui()
	else if (href_list["tool-move-up"])
		if (src.module)
			var/obj/item/tool = locate(href_list["tool-move-up"])
			if (tool)
				var/toolIndex = src.module.modules.Find(tool)
				if (toolIndex >= 2)
					// allow move if the second tool or later
					src.module.modules.Swap(toolIndex, toolIndex - 1)
			src.update_module_tools_ui()
	else if (href_list["tool-remove"])
		if (src.module && !src.module_tool_removal_lock)
			var/obj/item/tool = locate(href_list["tool-remove"])
			if (tool && (tool in src.module.modules))
				// remove tool
				src.module.modules -= tool
				qdel(tool)
			src.update_module_tools_ui()
	else
		ui.Unsubscribe(usr.client)

/chui/window/robot_module_rewriter
	name = "Cyborg Module Rewriter"
	windowSize = "600x480"
	var/obj/machinery/computer/robot_module_rewriter/owner = null

/chui/window/robot_module_rewriter/New(obj/machinery/computer/robot_module_rewriter/creator)
	..()
	src.owner = creator

/chui/window/robot_module_rewriter/GetBody()
	if (!src.template)
		src.template = grabResource("html/robotModuleRewriter.html")
	return ..()

/chui/window/robot_module_rewriter/OnClick(client/who, id, data)
	..()
	if (src.owner)
		src.owner.Topic("", list("[id]"=1) + params2list(data))

/chui/window/robot_module_rewriter/Subscribe(client/who)
	..()
	src.owner.update_ui()
