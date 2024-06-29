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
	/datum/matfab_recipe/makeshift_fuel_rod)

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
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "fab2-on"
	anchored = ANCHORED
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	flags = NOSPLASH
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL

	/// Produced objects are fed back into the fabricator.
	var/outputInternal = 0

	var/list/queue = list()
	/// recipes,storage,selected,part
	var/tab = "recipes"

	var/datum/matfab_recipe/selectedRecipe = null
	var/list/recipes = list()

	var/datum/matfab_part/selectingPart = null
	var/list/selectingPartList = list()

	var/filter_category = null
	var/filter_string = null

	var/list/blueprints = list()

	var/output_target = null

	New()
		for(var/R in blueprints)
			recipes.Add(new R())
		..()

	attack_hand(mob/user)
		user.Browse(buildHtml(), "window=nfab;size=550x650;title=Nano-fabricator;fade_in=0;can_resize=0", 1)
		return

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

	proc/buildHtml()
		var/html = list()
		html += "<a href='?src=\ref[src];tab=recipes'><i class='icon-list'></i> Blueprints</a>  "
		html += "<a href='?src=\ref[src];tab=storage'><i class='icon-folder-open'></i> Storage</a>  "
		html += "<a href='?src=\ref[src];tab=progress'><i class='icon-cog'></i> Progress</a>  "
		html += "<a href='?src=\ref[src];tab=settings'><i class='icon-wrench'></i> Settings</a>"
		html += "<hr>"

		html += "<div>"
		switch(tab)
			if("settings")
				html += "Output into fabricator: <a href='?src=\ref[src];toggleoutput=1'>[outputInternal ? "ON":"OFF"]</a><br>"
			if("recipes")
				if(filter_category)
					html += "<i class='icon-exclamation-sign'></i> Filtering by Category: [filter_category] <a href='?src=\ref[src];filteroff=1'><i class='icon-remove-sign'></i></a>"
				else if (filter_string)
					html += "<i class='icon-exclamation-sign'></i> Filtering by Name: [filter_string] <a href='?src=\ref[src];filteroff=1'><i class='icon-remove-sign'></i></a>"
				else
					html += "<i class='icon-search'></i> Category: "
					var/list/categories = list()
					for(var/datum/matfab_recipe/E in recipes)
						if(!(E.category in categories))
							categories.Add(E.category)
							html += "<a href='?src=\ref[src];filtercat=[E.category]'>[E.category]</a> "
					html += "<i class='icon-caret-right'></i> <a href='?src=\ref[src];filterstr=1'>Name</a>"
				html += "<hr>"

				html += "<div style='overflow-y: auto; height:500px;'>"
				for(var/datum/matfab_recipe/R in recipes)
					if(filter_category && R.category != filter_category) continue
					if(filter_string && !findtext(lowertext(R.name), lowertext(filter_string)) ) continue
					html += "<i class='icon-caret-right'></i> <a href='?src=\ref[src];select=\ref[R]'>[R.name]</a><br>"
					html += " Materials: "
					var/commanow = 0
					for(var/datum/matfab_part/P in R.required_parts)
						html += "[commanow ? ", ":""]([P.required_amount]) [P.name]"
						commanow = 1
					html += "<br>"
					html += " [R.desc]<br><br>"
				html +=  "</div>"
			if("progress")
				html += "Current production queue:<br><br>"
				for(var/X in queue)
					html += "[X]<br>" // The queue doesn't exist yet so this doesn't do anything :/
			if("storage")
				var/count = 0
				for(var/obj/item/I in src)
					if(!I.amount) continue
					html += "<a href='?src=\ref[src];eject=\ref[I]'><i class='icon-signout'></i></a> [I.name]<br>"
					count++
				if(!count)
					html += "<i class='icon-exclamation-sign'></i> No objects found in storage.<br>"
			if("selected")
				if(!selectedRecipe) html += "ERROR: No recipe selected."
				else
					html += "[selectedRecipe.name] :<br>"
					var/complete = 1
					for(var/datum/matfab_part/P in selectedRecipe.required_parts)
						html += "<i class='icon-chevron-sign-right'></i> [P.required_amount] [P.name] <i class='icon-chevron-sign-right'></i> [P.part_name] <i class='icon-chevron-sign-right'></i> "
						html += "<a href='?src=\ref[src];selectpart=\ref[P]'>[P.assigned ? P.assigned.name : "(EMPTY)"]</a>"
						html += "<br>"
						if(!P.assigned && !P.optional) complete = 0
					if(complete)
						html += "<br><a href='?src=\ref[src];build=1'><i class='icon-cogs'></i> BUILD</a>"
			if("part")
				if(selectedRecipe && selectingPart)
					if(!selectingPartList.len)
						html += "<i class='icon-exclamation-sign'></i> No valid components found for this slot.<br>"
						html += "<br><a href='?src=\ref[src];partreturn=1'>Return</a>"
					else
						for(var/obj/item/I in selectingPartList)
							if(selectingPartList[I]) //If this is set to 1, we dont have enough of the material.
								html += "<p style='color:red;display: inline;'><i class='icon-plus'></i> [I.name] (Insufficient amount)</p><br>"
							else
								html += "<a href='?src=\ref[src];choosepart=\ref[I]'><i class='icon-plus'></i></a> [I.name]<br>"
						html += "<br><a href='?src=\ref[src];partreturn=1'>Return</a>"
		html += "</div>"
		return jointext(html, "")

	Topic(href, href_list)
		if(BOUNDS_DIST(usr, src) > 0 || usr.z != src.z) return

		if(href_list["tab"])
			tab = href_list["tab"]
		else if(href_list["filteroff"])
			filter_category = null
			filter_string = null
		else if(href_list["filtercat"])
			filter_category = strip_html(href_list["filtercat"])
			filter_string = null
		else if(href_list["filterstr"])
			filter_category = null
			filter_string = strip_html(input(usr,"Search for:","Search",""))
		else if(href_list["toggleoutput"])
			outputInternal = !outputInternal
		else if(href_list["select"])
			var/datum/matfab_recipe/R = locate(href_list["select"]) in recipes
			if(R)
				selectedRecipe = R
				selectedRecipe.clear()
				tab = "selected"
		else if(href_list["eject"])
			var/obj/item/L = locate(href_list["eject"]) in src.contents
			if(!(L in src)) return
			L.set_loc(src.get_output_location())
		else if(href_list["selectpart"])
			if(selectedRecipe)
				var/datum/matfab_part/P = locate(href_list["selectpart"]) in selectedRecipe.required_parts
				if(P)
					selectingPart = P
					var/list/validOptions = list()
					validOptions.Add(src.contents)
					for(var/datum/matfab_part/RP in selectedRecipe.required_parts)
						if(RP == P) continue
						if(RP.assigned) validOptions.Remove(RP.assigned)
					for(var/obj/item/I in validOptions)
						if(!I.amount)
							validOptions.Remove(I)
						var/matchlevel = P.checkMatch(I)
						if(matchlevel == 0)
							validOptions.Remove(I)
						if(matchlevel == -1)
							validOptions[I] = 1

					selectingPartList = validOptions
					tab = "part"
		else if(href_list["partreturn"])
			tab = "selected"
			selectingPart = null
			selectingPartList.Cut()
		else if(href_list["choosepart"])
			var/obj/item/L = locate(href_list["choosepart"]) in selectingPartList
			if(!(L in src) || !L) return
			selectingPart.assigned = L
			tab = "selected"
			selectingPart = null
			selectingPartList.Cut()
		else if(href_list["build"])
			if(selectedRecipe)
				var/maxAmt = selectedRecipe.getMaxAmount()
				if(maxAmt)
					var/howMany = input(usr, "How many ([maxAmt] max)?", "Select amount", maxAmt)
					if(howMany > maxAmt || !selectedRecipe) return //ZeWaka: Fix for null.canBuild
					if(selectedRecipe.canBuild(howMany, src))
						selectedRecipe.build(howMany, src)
						var/list/parts = list()
						for(var/datum/matfab_part/P in selectedRecipe.required_parts)
							if(P.assigned)
								parts += "[P.part_name]: [P.assigned]"
								P.assigned.change_stack_amount(-(P.required_amount*howMany))
								if(QDELETED(P.assigned))
									P.assigned = null
						logTheThing(LOG_STATION, usr, "printed [howMany] [selectedRecipe.name] (parts: [jointext(parts, ", ")])")

						tab = "recipes"
						selectingPart = null
						selectingPartList.Cut()
						selectedRecipe = null
						flick("fab2-work", src)
		src.Attackhand(usr)

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
		if(istype(W, /obj/item/deconstructor))
			return ..()
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
