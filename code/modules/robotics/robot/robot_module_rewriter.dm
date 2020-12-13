/obj/machinery/computer/robot_module_rewriter
	name = "cyborg module rewriter"
	desc = "A machine used to reconfigure cyborg modules."
	icon_state = "robot_module_rewriter"
	anchored = 1
	density = 1
	lr = 1
	lg = 0.4
	lb = 0
	var/list/obj/item/robot_module/modules = null
	var/obj/item/robot_module/selectedModule = null

/obj/machinery/computer/robot_module_rewriter/attackby(obj/item/I as obj, mob/user as mob)
	if (isscrewingtool(I))
		playsound(get_turf(src), "sound/items/Screwdriver.ogg", 50, 1)
		if (do_after(user, 2 SECONDS))
			var/obj/computerframe/computer = new /obj/computerframe(src.loc)
			var/obj/item/circuitboard/robot_module_rewriter/circuitboard = new /obj/item/circuitboard/robot_module_rewriter(computer)
			computer.circuit = circuitboard
			computer.anchored = 1
			if (src.material)
				computer.setMaterial(src.material)
			if (src.status & BROKEN)
				boutput(user, "<span class=\"notice\">The broken glass falls out.</span>")
				var/obj/item/raw_material/shard/glass/glassShard = unpool(/obj/item/raw_material/shard/glass)
				glassShard.set_loc(src.loc)
				computer.state = 3
				computer.icon_state = "3"
			else
				boutput(user, "<span class=\"notice\">You disconnect the monitor.</span>")
				computer.state = 4
				computer.icon_state = "4"
			for (var/obj/containedItem in src)
				containedItem.set_loc(src.loc)
			qdel(src)
	else if (istype(I, /obj/item/robot_module))
		user.drop_item()
		I.set_loc(src)
		LAZYLISTADD(src.modules, I)
		boutput(user, "<span class=\"notice\">You insert [I] into the [src].</span>")
		tgui_process.update_uis(src)
	else
		src.attack_hand(user)

/obj/machinery/computer/robot_module_rewriter/attack_ai(mob/user as mob)
	return src.attack_hand(user)

// INTERFACE

/obj/machinery/computer/robot_module_rewriter/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CyborgModuleRewriter", src.name)
		ui.open()

/obj/machinery/computer/robot_module_rewriter/ui_data(mob/user)
	var/list/data = list()
	var/list/modulesData = list()

	var/list/availableModulesData = list()
	for (var/obj/item/robot_module/module in src.modules)
		var/list/availableModuleData = list()
		availableModuleData["name"] = module.name
		availableModuleData["ref"] = "\ref[module]"
		// wrapping in a list to append actual list rather than contents
		availableModulesData += list(availableModuleData)
	modulesData["available"] = availableModulesData

	var/list/selectedModuleData = null
	if (src.selectedModule)
		selectedModuleData = list()
		selectedModuleData["ref"] = "\ref[src.selectedModule]"
		var/list/selectedModuleToolsData = list()
		for (var/obj/item/tool in src.selectedModule.tools)
			var/list/toolData = list()
			toolData["name"] = tool.name
			toolData["ref"] = "\ref[tool]"
			// wrapping in a list to append actual list rather than contents
			selectedModuleToolsData += list(toolData)
		selectedModuleData["tools"] = selectedModuleToolsData
	modulesData["selected"] = selectedModuleData

	// "modules" is the only field on the "data" object, so could be flattened,
	// but there is intent to add more features in the near future
	data["modules"] = modulesData
	return data

/obj/machinery/computer/robot_module_rewriter/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if (.)
		return

	var/mob/user = ui.user

	switch (action)

		if ("module-eject")
			var/moduleRef = params["moduleRef"]
			if (moduleRef)
				var/obj/item/robot_module/module = locate(moduleRef) in src.modules
				if (module)
					// removing from modules list, as either being ejected or not in the machine for some reason
					LAZYLISTREMOVE(src.modules, module)
					if (module == src.selectedModule)
						src.selectedModule = null
					if (module.loc == src)
						user.put_in_hand_or_eject(module)
			. = TRUE

		if ("module-reset")
			var/moduleId = params["moduleId"]
			var/moduleRef = params["moduleRef"]
			if (moduleId && moduleRef)
				var/obj/item/robot_module/module = locate(moduleRef) in src.modules
				if (module)
					if (module.loc != src)
						// sanity check, tidy up modules list if not in the machine for some reason
						LAZYLISTREMOVE(src.modules, module)
						src.selectedModule = null
					else if (module == src.selectedModule)
						var/moduleResetType
						switch (moduleId)
							if ("brobocop")
								moduleResetType = /obj/item/robot_module/brobocop
							if ("chemistry")
								moduleResetType = /obj/item/robot_module/chemistry
							if ("civilian")
								moduleResetType = /obj/item/robot_module/civilian
							if ("engineering")
								moduleResetType = /obj/item/robot_module/engineering
							if ("medical")
								moduleResetType = /obj/item/robot_module/medical
							if ("mining")
								moduleResetType = /obj/item/robot_module/mining
						if (moduleResetType)
							var/obj/item/robot_module/replacementModule = new moduleResetType(src)
							var/moduleIndex = src.modules.Find(module)
							if (moduleIndex)
								src.modules[moduleIndex] = replacementModule
								src.selectedModule = replacementModule
								qdel(module)
			. = TRUE

		if ("module-select")
			var/moduleRef = params["moduleRef"]
			if (moduleRef)
				src.selectedModule = locate(moduleRef) in src.modules
				// sanity check, tidy up modules list if not in the machine for some reason
				if (src.selectedModule && src.selectedModule.loc != src)
					LAZYLISTREMOVE(src.modules, src.selectedModule)
			else
				src.selectedModule = null
			. = TRUE

		if ("tool-move")
			var/dir = params["dir"]
			var/moduleRef = params["moduleRef"]
			var/toolRef = params["toolRef"]
			if (moduleRef && toolRef)
				var/obj/item/robot_module/module = locate(moduleRef) in src.modules
				if (module)
					if (module.loc != src)
						// sanity check, tidy up modules list if not in the machine for some reason
						LAZYLISTREMOVE(src.modules, module)
					else if (module == src.selectedModule)
						var/obj/item/tool = locate(toolRef) in module
						if (tool)
							var/toolIndex = module.tools.Find(tool)
							switch (dir)
								if ("down")
									if (toolIndex > 0 && toolIndex < module.tools.len)
										module.tools.Swap(toolIndex, toolIndex + 1)
								if ("up")
									if (toolIndex >= 2)
										module.tools.Swap(toolIndex, toolIndex - 1)
			. = TRUE

		if ("tool-remove")
			var/moduleRef = params["moduleRef"]
			var/toolRef = params["toolRef"]
			if (moduleRef && toolRef)
				var/obj/item/robot_module/module = locate(moduleRef) in src.modules
				if (module)
					if (module.loc != src)
						// sanity check, tidy up modules list if not in the machine for some reason
						LAZYLISTREMOVE(src.modules, module)
					else if (module == src.selectedModule)
						var/obj/item/tool = locate(toolRef) in module.tools
						if (tool)
							module.tools -= tool
							qdel(tool)
			. = TRUE
