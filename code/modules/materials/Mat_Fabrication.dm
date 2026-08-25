/obj/machinery/nanofab/refining
	name = "Nano-fabricator (Refining)"
	blueprints = list(/datum/matfab_recipe/coilsmall,
#ifdef MAP_OVERRIDE_NADIR
	/datum/matfab_recipe/catarod,
#endif
	/datum/matfab_recipe/spear,
	/datum/matfab_recipe/arrow,
	/datum/matfab_recipe/bow,
	/datum/matfab_recipe/quiver,
	/datum/matfab_recipe/lens,
	/datum/matfab_recipe/tripod,
	/datum/matfab_recipe/glasses,
	/datum/matfab_recipe/jumpsuit,
	/datum/matfab_recipe/glovesins,
	/datum/matfab_recipe/glovearmor,
	/datum/matfab_recipe/shoes,
	/datum/matfab_recipe/flashlight,
	/datum/matfab_recipe/lighttube,
	/datum/matfab_recipe/lightbulb,
	/datum/matfab_recipe/tripodbulb,
	/datum/matfab_recipe/sheet,
	/datum/matfab_recipe/thermocouple,
	/datum/matfab_recipe/cell_small,
	/datum/matfab_recipe/cell_large,
	/datum/matfab_recipe/infusion,
	/datum/matfab_recipe/spacesuit)
	/*
	Note: the following items were removed from the refining nanofab due to the unfinished state of matsci and the resulting lack of any use for those:
	/datum/matfab_recipe/fuel_rod,
	/datum/matfab_recipe/fuel_rod_4,
	/datum/matfab_recipe/gears,
	/datum/matfab_recipe/aplates
	*/

/obj/machinery/nanofab/mining
	name = "Nano-fabricator (Mining)"
	color = "#f4a742"
	blueprints = list(/datum/matfab_recipe/mining_tool,
	/datum/matfab_recipe/mining_head_drill,
	/datum/matfab_recipe/mining_head_hammer,
	/datum/matfab_recipe/mining_head_blaster,
	/datum/matfab_recipe/mining_head_pick,
	/datum/matfab_recipe/mining_mod_conc,
	/datum/matfab_recipe/spacesuit)

/obj/machinery/nanofab/nuclear
	name = "Nano-fabricator (Nuclear)"
	color = "#094721"
	blueprints = list(/datum/matfab_recipe/simple/nuclear/gas_channel,
	/datum/matfab_recipe/simple/nuclear/heat_exchanger,
	/datum/matfab_recipe/simple/nuclear/control_rod,
	/datum/matfab_recipe/simple/nuclear/fuel_rod,
	/datum/matfab_recipe/makeshift_fuel_rod,
	/datum/matfab_recipe/simple/turbine/blade,
	/datum/matfab_recipe/simple/turbine/stator)

/obj/machinery/nanofab/prototype
	name = "Nano-fabricator (Prototype)"
	color = "#496ba3"
	blueprints = list(/datum/matfab_recipe/mining_tool,
	/datum/matfab_recipe/mining_head_drill,
	/datum/matfab_recipe/mining_head_hammer,
	/datum/matfab_recipe/mining_head_blaster,
	/datum/matfab_recipe/mining_head_pick,
	/datum/matfab_recipe/mining_mod_conc,
	/datum/matfab_recipe/spacesuit)

/obj/machinery/nanofab/artifactengine
	name = "Nano-fabricator (Prototype)"
	color = "#496ba3"

/// Material science fabricator
/obj/machinery/nanofab
	name = "Nano-fabricator"
	desc = "A more complicated sibling to the manufacturers, this machine can make things that inherit material properties."// this isnt super good but it's better than what it was
	icon = 'icons/obj/crafting.dmi'
	icon_state = "fab2-on"
	anchored = ANCHORED
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	flags = NOSPLASH | TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL

	/// Produced objects are fed back into the fabricator.
	var/outputInternal = FALSE

	var/datum/matfab_recipe/selectedRecipe = null
	var/list/recipes = list()

	var/datum/matfab_part/selectingPart = null
	var/list/selectingPartList = list()

	var/list/blueprints = list()

	var/output_target = null

	New()
		for(var/R in blueprints)
			recipes.Add(new R())
		..()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "NanoFabricator", src.name)
			ui.open()

	proc/get_recipe_icon(datum/matfab_recipe/recipe)
		if (!recipe)
			return null
		return recipe.get_recipe_icon()

	proc/get_item_icon(var/obj/item/item)
		if (!item)
			return null
		var/icon/item_icon = getFlatIcon(item, no_anim = TRUE)
		var/icon_key = "nanofab-item-\ref[item]"
		return "data:image/png;base64,[icon2base64(item_icon, icon_key)]"

	/// Returns the current storage items that can be assigned to the selected component
	proc/get_selecting_part_options()
		var/list/valid_options = list()
		if (!src.selectingPart || !src.selectedRecipe \
			|| !(src.selectingPart in src.selectedRecipe.required_parts))
			return valid_options
		// Begin with all stored items, then remove incompatible or empty entries
		valid_options.Add(src.contents)
		for (var/obj/item/I in valid_options)
			if (!I.amount)
				valid_options.Remove(I)
				continue
			var/matchlevel = src.selectingPart.checkMatch(I)
			if (matchlevel == 0)
				valid_options.Remove(I)
			// Include material already assigned to other components when checking this stack's remaining amount
			else if (matchlevel == -1 || src.selectedRecipe.get_assigned_amount(I, src.selectingPart) \
				+ src.selectingPart.required_amount > I.amount)
				valid_options[I] = 1
		return valid_options

	mouse_drop(over_object, src_location, over_location)
		if(over_object == src)
			boutput(usr, SPAN_NOTICE("You reset the output location of [src]!"))
			src.output_target = src.loc
			return

		if(!istype(usr,/mob/living/))
			boutput(usr, SPAN_ALERT("Only living mobs are able to set the output target for [src]."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("[src] is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable crate as an output target."))
			else
				src.output_target = over_object
				boutput(usr, SPAN_NOTICE("You set [src] to output to [over_object]!"))

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, SPAN_NOTICE("You set [src] to output on top of [O]!"))

		else if (istype(over_object,/turf) && !over_object:density)
			src.output_target = over_object
			boutput(usr, SPAN_NOTICE("You set [src] to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	proc/get_output_location()
		if (!src.output_target)
			return src.loc

		if (BOUNDS_DIST(src.output_target, src) > 0)
			src.output_target = null
			return src.loc

		if (istype(src.output_target,/obj/storage/crate/))
			var/obj/storage/crate/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C

		else if (istype(src.output_target,/turf/simulated/floor/))
			return src.output_target

		else
			return src.loc

	ui_static_data(mob/user)
		var/list/recipe_data = list()
		var/list/categories = list()
		for (var/datum/matfab_recipe/R as anything in src.recipes)
			var/list/part_data = list()
			for (var/datum/matfab_part/P as anything in R.required_parts)
				part_data += list(list(
					"ref" = "\ref[P]",
					"name" = P.name,
					"part_name" = P.part_name,
					"amount" = P.required_amount,
					"optional" = P.optional,
				))
			recipe_data += list(list(
				"ref" = "\ref[R]",
				"name" = R.name,
				"description" = R.desc,
				"category" = R.category,
				"img" = src.get_recipe_icon(R),
				"parts" = part_data,
			))
			if (!(R.category in categories))
				categories += R.category
		return list(
			"recipes" = recipe_data,
			"categories" = categories,
		)

	ui_data(mob/user)
		var/list/storage_data = list()
		for (var/obj/item/I in src)
			if (!I.amount)
				continue
			storage_data += list(list(
				"ref" = "\ref[I]",
				"name" = I.name,
				"amount" = I.amount,
				"img" = src.get_item_icon(I),
			))

		var/list/data = list(
			"outputInternal" = !!src.outputInternal,
			"storage" = storage_data,
			"selectedRecipe" = null,
			"selectingPart" = null,
			"partOptions" = list(),
		)
		if (src.selectedRecipe)
			var/list/part_data = list()
			for (var/datum/matfab_part/P as anything in src.selectedRecipe.required_parts)
				var/list/assigned_data = null
				if (P.assigned && (P.assigned in src))
					assigned_data = list(
						"name" = P.assigned.name,
						"amount" = P.assigned.amount,
						"img" = src.get_item_icon(P.assigned),
					)
				part_data += list(list(
					"ref" = "\ref[P]",
					"name" = P.name,
					"part_name" = P.part_name,
					"amount" = P.required_amount,
					"optional" = P.optional,
					"assigned" = assigned_data,
				))
			data["selectedRecipe"] = list(
				"ref" = "\ref[src.selectedRecipe]",
				"name" = src.selectedRecipe.name,
				"description" = src.selectedRecipe.desc,
				"img" = src.get_recipe_icon(src.selectedRecipe),
				"complete" = !!src.selectedRecipe.canBuild(1, src),
				"maxAmount" = src.selectedRecipe.getMaxAmount(),
				"parts" = part_data,
			)

		if (src.selectingPart && src.selectedRecipe)
			var/list/current_part_options = src.get_selecting_part_options()
			src.selectingPartList = current_part_options
			data["selectingPart"] = list(
				"ref" = "\ref[src.selectingPart]",
				"name" = src.selectingPart.name,
				"part_name" = src.selectingPart.part_name,
			)
			var/list/options = list()
			for (var/obj/item/I as anything in current_part_options)
				options += list(list(
					"ref" = "\ref[I]",
					"name" = I.name,
					"amount" = I.amount,
					"img" = src.get_item_icon(I),
					"insufficient" = !!current_part_options[I],
				))
			data["partOptions"] = options
		return data

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		var/mob/user = ui?.user
		if (!user)
			return
		switch (action)
			if ("select_recipe")
				var/datum/matfab_recipe/R = locate(params["ref"]) in src.recipes
				if (!R)
					return
				src.selectedRecipe = R
				R.clear()
				src.selectingPart = null
				src.selectingPartList.Cut()
				. = TRUE
			if ("eject")
				var/obj/item/I = locate(params["ref"]) in src.contents
				if (!I)
					return
				I.set_loc(src.get_output_location())
				. = TRUE
			if ("toggle_output")
				src.outputInternal = !src.outputInternal
				. = TRUE
			if ("select_part")
				if (!src.selectedRecipe)
					return
				var/datum/matfab_part/P = locate(params["ref"]) in src.selectedRecipe.required_parts
				if (!P)
					return
				src.selectingPart = P
				src.selectingPartList = src.get_selecting_part_options()
				. = TRUE
			if ("cancel_part")
				src.selectingPart = null
				src.selectingPartList.Cut()
				. = TRUE
			if ("choose_part")
				if (!src.selectedRecipe || !src.selectingPart)
					return
				var/list/current_part_options = src.get_selecting_part_options()
				var/obj/item/I = locate(params["ref"]) in current_part_options
				if (!I || !(I in src) || current_part_options[I] || src.selectingPart.checkMatch(I) != 1)
					return
				src.selectingPart.assigned = I
				src.selectingPart = null
				src.selectingPartList.Cut()
				. = TRUE
			if ("build")
				if (!src.selectedRecipe)
					return
				var/datum/matfab_recipe/build_recipe = src.selectedRecipe
				var/max_amount = build_recipe.getMaxAmount()
				if (max_amount <= 0)
					return
				var/how_many = params["amount"]
				if (isnull(how_many) || build_recipe != src.selectedRecipe)
					return
				max_amount = build_recipe.getMaxAmount()
				if (!isnum_safe(how_many) || how_many < 1 || how_many > max_amount \
					|| !build_recipe.canBuild(how_many, src))
					return
				build_recipe.build(how_many, src)
				var/list/parts = list()
				var/list/required_amounts = build_recipe.get_assigned_amounts()
				for (var/datum/matfab_part/P as anything in build_recipe.required_parts)
					if (P.assigned)
						parts += "[P.part_name]: [P.assigned]"
				for (var/obj/item/I as anything in required_amounts)
					I.change_stack_amount(-(required_amounts[I] * how_many))
				for (var/datum/matfab_part/P as anything in build_recipe.required_parts)
					if (P.assigned && QDELETED(P.assigned))
						P.assigned = null
				logTheThing(LOG_STATION, user, "printed [how_many] [build_recipe.name] (parts: [jointext(parts, ", ")])")
				src.selectingPart = null
				src.selectingPartList.Cut()
				FLICK("fab2-work", src)
				. = TRUE

	proc/addMaterial(var/obj/item/W, var/mob/user)
		for(var/obj/item/A in src)
			if(A == W|| !A.amount) continue
			if(A.material && W.material)
				if(A.material.isSameMaterial(W.material) && A.check_valid_stack(W))
					var/obj/item/I = A
					I.change_stack_amount(W.amount)
					if(W == user.equipped())
						user.drop_item()
					qdel(W)
					return
		if(W == user.equipped())
			user.drop_item()
		W.set_loc(src)

	attackby(var/obj/item/W , mob/user as mob)
		if(issilicon(user)) // fix bug where borgs could put things into the nanofab and then reject them
			boutput(user, SPAN_ALERT("You can't put that in, it's attached to you."))
			return

		if(isExploitableObject(W))
			boutput(user, SPAN_ALERT("\the [src] grumps at you and refuses to use [W]."))
			return

		user.visible_message(SPAN_NOTICE("[user] puts \the [W] in \the [src]."))
		addMaterial(W, user)
		/*
		if(W.material != null)
			user.visible_message(SPAN_NOTICE("[user] puts \the [W] in \the [src]."))
			if( W.material )
				addMaterial(W, user)
			else
				boutput(user, SPAN_ALERT("The fabricator can only use material-based objects."))
				return
		*/
		return

	ex_act(severity)
		return


/obj/item/paper/nano_blueprint
	name = "Nanofab Blueprint"
	desc = "It's a blueprint to allow a nanofab unit to build something."
	info = "There's all manner of confusing diagrams and instructions on here. It's meant for a machine to read."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "blueprint"
	item_state = "sheet"

	var/datum/matfab_recipe/recipe = null

	New(var/loc,var/schematic = null)
		..()
		if (!src.recipe)
			qdel(src)
			return 0
		src.name = "Manufacturer Blueprint: [src.recipe.name]"
		src.desc = "This blueprint will allow a nanofab unit to build a [src.recipe.name]"
		src.pixel_x = rand(-4,4)
		src.pixel_y = rand(-4,4)
		return 1
