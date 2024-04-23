/// This serves as a bridge between old materials pieces and new ones. Eventually old ones should just be updated.
TYPEINFO(/obj/machinery/processor)
	mats = 20

/obj/machinery/processor
	name = "Material processor"
	desc = "Turns raw materials, and objects containing materials, into processed pieces."
	icon = 'icons/obj/crafting.dmi'
	icon_state = "fab3-on"
	anchored = ANCHORED
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	event_handler_flags = NO_MOUSEDROP_QOL | USE_FLUID_ENTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL

	/// Things that this is currently processing into materials
	var/list/atom/processing

	var/atom/output_location = null

	New()
		. = ..()
		src.processing = list()

	process()
		if(length(src.processing))
			var/atom/current_thing = src.processing[1]
			var/list/matches = list()

			for(var/atom/A in src.processing)
				if(A == current_thing) continue
				if(A.material.isSameMaterial(current_thing.material))
					matches.Add(A)

			var/output_location = get_output_location()
			var/obj/item/material_piece/exists_nearby = null
			for(var/obj/item/material_piece/G in output_location)
				if(G.material.isSameMaterial(current_thing.material))
					exists_nearby = G
					break

			matches.Add(current_thing)

			var/totalAmount = 0
			for(var/obj/item/M in matches)
				totalAmount += M.amount

			var/mat_id
			var/datum/material/mat

			//Check for exploitable inputs and divide the result accordingly
			var/div_factor = 1 / current_thing.material_amt
			var/second_mat = null

			if (istype(current_thing, /obj/item/cable_coil))
				var/obj/item/cable_coil/C = current_thing
				second_mat = C.conductor

			//Output processed amount if there is enough input material
			var/out_amount = round(totalAmount/div_factor)
			if (out_amount > 0)
				if(exists_nearby)
					exists_nearby.change_stack_amount(out_amount)
					mat_id = exists_nearby.material.getID()
					mat = exists_nearby.material
				else
					var/newType = getProcessedMaterialForm(current_thing.material)
					var/obj/item/material_piece/P = new newType
					P.set_loc(get_output_location())
					P.setMaterial(current_thing.material)
					P.change_stack_amount(out_amount - P.amount)
					mat_id = P.material.getID()
					mat = P.material

				if (istype(output_location, /obj/machinery/manufacturer))
					var/obj/machinery/manufacturer/M = output_location
					M.update_resource_amount(mat_id, out_amount * 10, mat)

				//If the input was a cable coil, output the conductor too
				if (second_mat)
					var/obj/item/material_piece/second_exists_nearby = null
					var/second_mat_id
					for(var/obj/item/material_piece/G in output_location)
						if(G.material.isSameMaterial(second_mat))
							second_exists_nearby = G
							break

					if(second_exists_nearby)
						second_exists_nearby.change_stack_amount(out_amount)
						second_mat_id = second_exists_nearby.material.getID()
						second_mat = second_exists_nearby.material
					else
						var/newType = getProcessedMaterialForm(second_mat)
						var/obj/item/material_piece/PC = new newType
						PC.set_loc(get_output_location())
						PC.setMaterial(second_mat)
						PC.change_stack_amount(out_amount - PC.amount)
						second_mat_id = PC.material.getID()
						second_mat = PC.material

					if (istype(output_location, /obj/machinery/manufacturer))
						var/obj/machinery/manufacturer/M = output_location
						M.update_resource_amount(second_mat_id, out_amount * 10, second_mat)

			//Delete items in processor and output leftovers
			var/leftovers = (totalAmount/div_factor-out_amount)*div_factor
			for(var/atom/movable/D in matches)
				var/obj/item/R = D
				if (leftovers != 0 && R.amount)
					R.change_stack_amount(leftovers-R.amount)
					if(R.amount < 1) //no fractionals tyvm
						qdel(R)
					else
						R.set_loc(src.loc)
					leftovers = 0
					continue
				qdel(D)

			if (out_amount > 0)//No animation and beep if nothing processed
				playsound(src.loc, 'sound/effects/pop.ogg', 40, 1)
				flick("fab3-work",src)
			else
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 40, 1)

	attackby(var/obj/item/W, mob/user)
		// this comment isn't relevant anymore since I removed the check but it's too funny to delete -aloe <3
		//
		//Wire: Fix for: undefined proc or verb /turf/simulated/floor/set loc()
		//		like somehow a dude tried to load a turf? how the fuck? whatever just kill me

		if(istype(W, /obj/item/material_piece))
			boutput(user, SPAN_ALERT("[W] has already been processed."))
			return

		if(istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/O = W
			if (O.satchel)
				W = O.satchel

		if(istype(W, /obj/item/satchel))
			var/obj/item/satchel/S = W
			boutput(user, SPAN_NOTICE("You empty \the [W] into \the [src]."))
			for(var/obj/item/I in S)
				if(I.material)
					src.add_item_for_processing(I, user)
			S.UpdateIcon()
			S.tooltip_rebuild = TRUE
			return

		else if (W.cant_drop) //For borg held items
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return ..()

		if(W.material)
			boutput(user, SPAN_NOTICE("You put \the [W] into \the [src]."))
			user.u_equip(W)
			src.add_item_for_processing(W, user)
			W.dropped(user)

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Get your filthy dead fingers off that!"))
			return

		if(over_object == src)
			output_location = null
			boutput(usr, SPAN_NOTICE("You reset the processor's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The processor is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable crate as an output target."))
			else
				src.output_location = over_object
				boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable cart as an output target."))
			else
				src.output_location = over_object
				boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else if (istype(over_object,/obj/machinery/manufacturer/))
			var/obj/machinery/manufacturer/M = over_object
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				boutput(usr, SPAN_ALERT("You can't use a non-functioning manufacturer as an output target."))
			else
				src.output_location = M
				boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else if (istype(over_object, /obj/machinery/nanofab))
			var/obj/machinery/nanofab/N = over_object
			if (N.status & BROKEN || N.status & NOPOWER)
				boutput(usr, SPAN_ALERT("You can't use a non-functioning nano-fabricator as an output target."))
			else
				src.output_location = N
				boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else if (istype(over_object,/obj/table/) && istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_location = O.loc
			boutput(usr, SPAN_NOTICE("You set the processor to output on top of [O]!"))

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_location = over_object
			boutput(usr, SPAN_NOTICE("You set the processor to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))

	MouseDrop_T(atom/movable/O, mob/user)
		if (BOUNDS_DIST(user, src) > 0 || BOUNDS_DIST(user, O) > 0 || is_incapacitated(user) || isAI(user))
			return

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/))
			user.visible_message(SPAN_NOTICE("[user] uses [src]'s automatic loader on [O]!"), SPAN_NOTICE("You use [src]'s automatic loader on [O]."))
			var/amtload = 0
			for (var/obj/item/raw_material/mat in O.contents)
				src.add_item_for_processing(mat, user)
				amtload += max(mat.amount, 1)
			if (amtload)
				boutput(user, SPAN_NOTICE("[amtload] materials loaded from [O]!"))
			else
				boutput(user, SPAN_ALERT("No material loaded!"))
			return

		if (!istype(O, /obj/item))
			return
		var/obj/item/W = O
		if((W in user) && !W.cant_drop)
			user.u_equip(W)
			W.set_loc(src.loc)
			W.dropped(user)

		//if (istype(W, /obj/item/raw_material/) || istype(W, /obj/item/sheet/) || istype(W, /obj/item/rods/) || istype(W, /obj/item/tile/) || istype(W, /obj/item/cable_coil))
		if(W.material && !istype(W, /obj/item/material_piece))
			quickload(user, W)
		else
			src.Attackby(W, user)

	Exited(thing, newloc)
		. = ..()
		if ((thing in src.processing) && newloc != src)
			src.processing -= thing

	proc/quickload(var/mob/living/user, var/obj/item/initial_item)
		user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [initial_item] into [src]!"),
			SPAN_NOTICE("You begin quickly stuffing [initial_item] into [src]!"),
			SPAN_NOTICE("You hear multiple objects being shoved into a chute."))
		user.u_equip(initial_item)
		src.add_item_for_processing(initial_item, user)
		initial_item.dropped(user)

		var/staystill = user.loc
		for(var/obj/item/other_item in view(1, user))
			if (other_item.loc == user)
				continue
			if (!istype(other_item, initial_item.type))
				continue
			if(!istype(other_item, /obj/item/cable_coil))
				if (!istype(other_item.material))
					continue

			src.add_item_for_processing(other_item, user)
			playsound(src, 'sound/items/Deconstruct.ogg', 40, TRUE)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, SPAN_NOTICE("You finish stuffing [initial_item] into [src]!"))

	proc/get_output_location()
		if (isnull(output_location))
			return src.loc

		if (BOUNDS_DIST(src.output_location, src) > 0)
			output_location = null
			return src.loc

		if (istype(output_location,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			if (M.status & NOPOWER || M.status & BROKEN | M.dismantle_stage > 0)
				return M.loc
			return M

		else if (istype(output_location,/obj/storage/crate))
			var/obj/storage/crate/C = output_location
			if (C.locked || C.welded || C.open)
				return C.loc
			return C

		else if (istype(output_location,/obj/storage/cart))
			var/obj/storage/cart/C = output_location
			if (C.locked || C.welded || C.open)
				return C.loc
			return C

		return output_location

	/// Adds an item to the processing list and places it inside the processor
	proc/add_item_for_processing(obj/thing, mob/user)
		thing.set_loc(src)
		src.processing += thing
		logTheThing(LOG_STATION, user, "adds [log_object(thing)] to a material processor.")

/obj/machinery/processor/portable
	name = "Portable material processor"
	icon = 'icons/obj/scrap.dmi'
	icon_state = "reclaimer"
	anchored = UNANCHORED
	density = 1

	custom_suicide = 1
	suicide(var/mob/user)
		if (!src.user_can_suicide(user))
			return 0

		user.visible_message(SPAN_ALERT("<b>[user] hops right into [src]! Jesus!</b>"))
		user.unequip_all()
		user.set_loc(src)
		user.make_cube(life = 5 MINUTES, T = src.loc)

/obj/machinery/neosmelter
	name = "Nano-crucible"
	desc = "A huge furnace-like machine used to combine materials."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smelter0"
	anchored = ANCHORED_ALWAYS
	bound_height = 96
	bound_width = 96
	density = 1
	layer = FLOOR_EQUIP_LAYER1

	var/datum/light/light

	var/obj/item/first_part = null
	var/obj/item/second_part = null
	var/resultName = "???"

	New()
		..()
		light = new /datum/light/point
		light.attach(src, 1.5, 1.5)
		light.set_brightness(0.5)
		light.set_color(0.4, 0.8, 1)

	attack_hand(mob/user)
		var/list/html = list("")
		html += "<div style='margin: auto;text-align:center'>[first_part ? "<a href='?src=\ref[src];remove=\ref[first_part]'>[first_part.name]</a>" : "EMPTY"] <i class='icon-plus'></i> [second_part ? "<a href='?src=\ref[src];remove=\ref[second_part]'>[second_part.name]</a>" : "EMPTY"]   <i class='icon-double-angle-right'></i> [resultName]</div><br>"
		html += "<div style='margin: auto;text-align:center'><a href='?src=\ref[src];activate=1'><i class='icon-check-sign icon-large'></i></a></div><br><br>"

		for(var/obj/item/I in src)
			if(isnull(I.material))
				stack_trace("Null material item [I] [I.type] in nano-crucible")
				continue
			if(!I.amount) continue
			if(first_part == I) continue
			if(second_part == I) continue
			html += "<div style='margin: auto;text-align:center'><a href='?src=\ref[src];select_l=\ref[I]'><i class='icon-arrow-left'></i></a> <a href='?src=\ref[src];eject=\ref[I]'>[I.name]</a> <a href='?src=\ref[src];select_r=\ref[I]'><i class='icon-arrow-right'></i></a></div><br>"

		user.Browse(html.Join(), "window=crucible;size=500x650;title=Nano-crucible;fade_in=0", 1)
		return

	Topic(href, href_list)
		if(BOUNDS_DIST(usr, src) > 0 || usr.z != src.z) return

		if(href_list["select_l"])
			var/obj/item/L = locate(href_list["select_l"]) in src
			if(!L) return
			first_part = L
		else if(href_list["select_r"])
			var/obj/item/R = locate(href_list["select_r"]) in src
			if(!R) return
			second_part = R

		else if(href_list["activate"])
			if(first_part && second_part)
				var/obj/item/FP = first_part
				var/obj/item/SP = second_part
				var/maxamt = min(FP.amount, SP.amount)
				var/amt = input(usr, "How many? ([maxamt] max)", "Select amount", maxamt) as null|num
				amt = max(0, amt)
				if(amt && isnum_safe(amt) && FP && FP.amount >= amt && SP && SP.amount >= amt && (FP in src) && (SP in src))
					flick("smelter1",src)
					var/datum/material/merged = getFusedMaterial(FP.material, SP.material)
					var/datum/material_recipe/RE = matchesMaterialRecipe(merged)
					var/newtype = getProcessedMaterialForm(merged)
					var/apply_material = 1

					if(RE)
						if(!RE.result_id && !RE.result_item)
							RE.apply_to(merged)
						else if(RE.result_item)
							newtype = RE.result_item
							apply_material = 0
						else if(RE.result_id)
							merged = getMaterial(RE.result_id)

					var/obj/item/piece = new newtype(src)

					if(apply_material)
						piece.setMaterial(merged)

					piece.change_stack_amount(amt - piece.amount)
					FP.change_stack_amount(-amt)
					SP.change_stack_amount(-amt)
					if(istype(piece, /obj/item/material_piece))
						addMaterial(piece, usr)
					else
						piece.set_loc(get_turf(src))
					RE?.apply_to_obj(piece)
					first_part = null
					second_part = null
					boutput(usr, SPAN_NOTICE("You make [piece]."))

		else if(href_list["eject"])
			var/obj/item/L = locate(href_list["eject"]) in src
			if(!(L in src)) return
			if(first_part == L)
				first_part = null
			else if (second_part == L)
				second_part = null
			L.set_loc(src.loc)
		else if(href_list["remove"])
			var/obj/item/L = locate(href_list["remove"]) in src
			if(first_part == L)
				first_part = null
			else if (second_part == L)
				second_part = null

		updateResultName()
		src.Attackhand(usr)

	proc/updateResultName()
		if(first_part && second_part)
			resultName = findRecipeName(first_part, second_part)
		else
			resultName = "???"

	proc/addMaterial(var/obj/item/W, var/mob/user)
		for(var/obj/item/A in src)
			if(A == W|| !A.amount) continue
			if(A.material)
				if(A.material.isSameMaterial(W.material))
					var/obj/item/I = A
					I.change_stack_amount(W.amount)
					if(W == user.equipped())
						user.drop_item()
					W.set_loc(null)
					qdel(W)
					W = null
					return

		if(W == user.equipped())
			user.drop_item()
		W.set_loc(src)
		return

	attackby(var/obj/item/W , mob/user as mob)
		if(isExploitableObject(W))
			boutput(user, SPAN_ALERT("\the [src] grumps at you and refuses to use [W]."))
			return

		if(W.material != null)
			if(!W.material.getCanMix())
				boutput(user, SPAN_ALERT("This material can not be used in \the [src]."))
				return

			user.visible_message(SPAN_NOTICE("[user] puts \the [W] in \the [src]."))
			if( istype(W, /obj/item/material_piece) || istype(W, /obj/item/raw_material) )
				addMaterial(W, user)
			else
				boutput(user, SPAN_ALERT("The crucible can only use raw materials."))
				return
		return

	custom_suicide = 1
	suicide(var/mob/user)
		if (!src.user_can_suicide(user))
			return 0

		user.visible_message(SPAN_ALERT("<b>[user] hops right into [src]! Jesus!</b>"))
		user.unequip_all()
		user.set_loc(src)

		var/datum/material/M = new /datum/material/organic/flesh {desc="A disgusting wad of flesh."; color="#881111";} ()
		M.setName("[user.real_name] flesh")

		var/obj/item/material_piece/wad/dummyItem = new /obj/item/material_piece/wad
		dummyItem.set_loc(src)
		dummyItem.setMaterial(M)
		dummyItem.change_stack_amount(5)
		addMaterial(dummyItem, user)
		user.remove()

	ex_act(severity)
		return

//
TYPEINFO(/obj/item/device/matanalyzer)
	mats = 5

/obj/item/device/matanalyzer
	icon_state = "matanalyzer"
	name = "Material analyzer"
	desc = "This piece of equipment can detect and analyze materials."
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(GET_DIST(src, target) <= world.view)
			animate_scanning(target, "#597B6D")
			var/atom/W = target
			if(!W.material)
				boutput(user, SPAN_ALERT("No significant material found in \the [target]."))
			else
				boutput(user, SPAN_NOTICE("<u>[capitalize(W.material.getName())]</u>"))
				boutput(user, SPAN_NOTICE("[W.material.getDesc()]"))

				if(length(W.material.getMaterialProperties()))
					boutput(user, SPAN_NOTICE("<u>The material is:</u>"))
					for(var/datum/material_property/X in W.material.getMaterialProperties())
						var/value = W.material.getProperty(X.id)
						boutput(user, SPAN_NOTICE("• [X.getAdjective(W.material)] ([value])"))
				else
					boutput(user, SPAN_NOTICE("<u>The material is completely unremarkable.</u>"))
		else
			boutput(user, SPAN_ALERT("[target] is too far away."))
		return

/obj/item/slag_shovel
	name = "slag shovel"
	desc = "Used to remove slag from the arc smelter."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "shovel"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "shovel"
	w_class = W_CLASS_NORMAL
	c_flags = ONBELT
	force = 7 // 15 puts it significantly above most other weapons
	hitsound = 'sound/impact_sounds/Metal_Hit_1.ogg'

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)
