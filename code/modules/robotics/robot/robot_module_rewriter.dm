/obj/machinery/computer/robot_module_rewriter
	name = "cyborg module rewriter"
	desc = "A machine used to reconfigure cyborg modules."
	icon_state = "robot_module_rewriter"
	anchored = ANCHORED
	density = 1
	light_r = 1
	light_g = 0.4
	light_b = 0
	circuit_type = /obj/item/circuitboard/robot_module_rewriter
	var/list/obj/item/robot_module/modules = null
	var/obj/item/robot_module/selected_module = null

/obj/machinery/computer/robot_module_rewriter/New()
	..()
	src.modules = list()

/obj/machinery/computer/robot_module_rewriter/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/robot_module))
		user.drop_item()
		I.set_loc(src)
		src.modules += I
		boutput(user, SPAN_NOTICE("You insert [I] into \the [src]."))
		tgui_process.update_uis(src)
	else
		..()

/obj/machinery/computer/robot_module_rewriter/Exited(atom/movable/I)
	. = ..()
	if (istype(I, /obj/item/robot_module))
		src.modules -= I
		if (src.selected_module == I)
			src.selected_module = null

/obj/machinery/computer/robot_module_rewriter/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "CyborgModuleRewriter", src.name)
		ui.open()

/obj/machinery/computer/robot_module_rewriter/ui_data(mob/user)
	. = ..()
	var/list/modulesData = list()

	var/list/availableModulesData = list()
	for (var/obj/item/robot_module/module in src.modules)
		var/list/availableModuleData = list(
			"name" = module.name,
			"item_ref" = "\ref[module]"
		)
		// wrapping in a list to append actual list rather than contents
		availableModulesData += list(availableModuleData)
	modulesData["available"] = availableModulesData

	var/list/selectedModuleData = null
	if (src.selected_module)
		selectedModuleData = list(
			"item_ref" = "\ref[src.selected_module]"
		)
		var/list/selectedModuleToolsData = list()
		for (var/obj/item/tool in src.selected_module.tools)
			var/list/toolData = list(
				"name" = tool.name,
				"item_ref" = "\ref[tool]"
			)
			// wrapping in a list to append actual list rather than contents
			selectedModuleToolsData += list(toolData)
		selectedModuleData["tools"] = selectedModuleToolsData
	modulesData["selected"] = selectedModuleData

	// "modules" is the only key in our return list, so could be flattened,
	// but there is intent to add more features in the near future
	.["modules"] = modulesData

/obj/machinery/computer/robot_module_rewriter/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if (.)
		return

	var/mob/user = ui.user

	switch (action)

		if ("module-eject")
			var/item_ref = params["itemRef"]
			if (!item_ref)
				return
			var/obj/item/robot_module/item = locate(item_ref) in src.modules
			if (!item)
				return
			user.put_in_hand_or_eject(item)
			. = TRUE

		if ("module-reset")
			var/module_id = params["moduleId"]
			if (!module_id)
				return
			if (!src.selected_module)
				return
			var/module_reset_path
			switch (module_id)
				if ("brobocop")
					module_reset_path = /obj/item/robot_module/brobocop
				if ("science")
					module_reset_path = /obj/item/robot_module/science
				if ("civilian")
					module_reset_path = /obj/item/robot_module/civilian
				if ("engineering")
					module_reset_path = /obj/item/robot_module/engineering
				if ("medical")
					module_reset_path = /obj/item/robot_module/medical
				if ("mining")
					module_reset_path = /obj/item/robot_module/mining
			if (!module_reset_path)
				return
			var/module_index = src.modules.Find(src.selected_module)
			if (!module_index)
				return
			var/obj/item/robot_module/replacement_module = new module_reset_path(src)
			src.modules[module_index] = replacement_module
			qdel(src.selected_module)
			src.selected_module = replacement_module
			. = TRUE

		if ("module-select")
			var/item_ref = params["itemRef"]
			if (!item_ref)
				src.selected_module = null
				return
			src.selected_module = locate(item_ref) in src.modules
			. = TRUE

		if ("tool-move")
			var/dir = params["dir"]
			var/item_ref = params["itemRef"]
			if (!dir || !item_ref)
				return
			if (!src.selected_module)
				return
			var/obj/item/item = locate(item_ref) in src.selected_module.tools
			if (!item)
				return
			var/item_index = src.selected_module.tools.Find(item)
			if (!item_index)
				return
			switch (dir)
				if ("down")
					if (item_index < length(src.selected_module.tools))
						src.selected_module.tools.Swap(item_index, item_index + 1)
				if ("up")
					if (item_index >= 2)
						src.selected_module.tools.Swap(item_index, item_index - 1)
			. = TRUE

		if ("tool-remove")
			var/item_ref = params["itemRef"]
			if (!item_ref)
				return
			if (!src.selected_module)
				return
			var/obj/item/item = locate(item_ref) in src.selected_module.tools
			if (!item)
				return
			src.selected_module.tools -= item
			qdel(item)
			. = TRUE
