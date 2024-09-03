/obj/machinery/portable_reclaimer
	name = "portable reclaimer"
	desc = "A sophisticated piece of machinery can process raw materials, scrap, and material sheets into bars."
	icon = 'icons/obj/scrap.dmi'
	icon_state = "reclaimer"
	anchored = UNANCHORED
	density = 1
	event_handler_flags = NO_MOUSEDROP_QOL
	var/active = 0
	var/reject = 0
	var/smelt_interval = 5
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')
	var/sound/sound_process = sound('sound/effects/pop.ogg')
	var/sound/sound_grump = sound('sound/machines/buzz-two.ogg')
	var/atom/output_location = null
	var/list/atom/leftovers = list()

	attack_hand(var/mob/user)
		if (active)
			boutput(user, SPAN_ALERT("It's already working! Give it a moment!"))
			return
		if (length(src.contents) < 1)
			boutput(user, SPAN_ALERT("There's nothing inside to reclaim."))
			return
		user.visible_message("<b>[user.name]</b> switches on [src].")
		active = 1
		anchored = ANCHORED
		icon_state = "reclaimer-on"

		for (var/obj/item/M in src.contents)
			if (istype(M, /obj/item/wizard_crystal))
				var/obj/item/wizard_crystal/wc = M
				wc.setMaterial(getMaterial(wc.assoc_material),0,0,1,0)

			if (!istype(M.material))
				M.set_loc(src.loc)
				src.reject = 1
				continue

			else if (istype(M, /obj/item/cable_coil))
				var/obj/item/cable_coil/C = M
				output_bar_from_item(M, 1 / M.material_amt, C.conductor.getID())
				qdel(C)

			else
				output_bar_from_item(M, 1 / M.material_amt)
				qdel(M)

			sleep(smelt_interval)

		if (reject)
			src.reject = 0
			src.visible_message("<b>[src]</b> emits an angry buzz and rejects some unsuitable materials!")
			playsound(src.loc, sound_grump, 40, 1)

		active = 0
		anchored = UNANCHORED
		icon_state = "reclaimer"
		src.visible_message("<b>[src]</b> finishes working and shuts down.")

	proc/output_bar_from_item(obj/item/O, var/amount_per_bar = 1, var/extra_mat)
		if (!O || !O.material)
			return

		var/output_amount = O.amount

		if (amount_per_bar)
			var/bonus = leftovers[O.material.getID()]
			var/num_bars = O.amount / amount_per_bar + bonus

			output_amount = round(num_bars)
			if (output_amount != num_bars)
				leftovers[O.material.getID()] = num_bars - output_amount

		output_bar(O.material, output_amount)

		if (extra_mat) // i hate this
			output_amount = O.amount

			if (amount_per_bar)
				var/bonus = leftovers[extra_mat]
				var/num_bars = O.amount / amount_per_bar + bonus

				output_amount = round(num_bars)
				if (output_amount != num_bars)
					leftovers[extra_mat] = num_bars - output_amount

			output_bar(extra_mat, output_amount)

	proc/output_bar(material, amount)

		if(amount <= 0)
			return

		var/datum/material/MAT = material
		if (!istype(MAT))
			MAT = getMaterial(material)
			if (!MAT)
				return

		var/atom/output_location = src.get_output_location()

		var/bar_type = getProcessedMaterialForm(MAT)
		var/obj/item/material/BAR = new bar_type
		BAR.setMaterial(MAT)
		BAR.change_stack_amount(amount - 1)

		if (istype(output_location, /obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			M.add_contents(BAR)
		else
			BAR.set_loc(output_location)
			for (var/obj/item/material/other_bar in output_location.contents)
				if (other_bar == BAR)
					continue
				if (BAR.material.isSameMaterial(other_bar.material))
					if (other_bar.stack_item(BAR))
						break

		playsound(src.loc, sound_process, 40, 1)

	proc/load_reclaim(obj/item/W as obj, mob/user as mob)
		. = FALSE
		if (src.is_valid(W) && brain_check(W, user, TRUE))
			if (W.stored)
				W.stored.transfer_stored_item(W, src, user = user)
			else
				W.set_loc(src)
				if (user) user.u_equip(W)
			W.dropped(user)
			. = TRUE

	attackby(obj/item/W, mob/user)

		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			W = scoop.satchel
		if (W.storage || istype(W, /obj/item/satchel))
			var/items = W
			if (W.storage)
				items = W.storage.get_contents()
			for(var/obj/item/O in items)
				if (load_reclaim(O))
					. = TRUE
			if (istype(W, /obj/item/satchel) && .)
				W.UpdateIcon()
			//Users loading individual items would make an annoying amount of messages
			//But loading a container is more noticable and there should be less
			if (.)
				user.visible_message("<b>[user.name]</b> loads [W] into [src].")
				playsound(src, sound_load, 40, TRUE)
				logTheThing(LOG_STATION, user, "loads [W] into \the [src] at [log_loc(src)].")
		else if (W?.cant_drop)
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return ..()
		else if (load_reclaim(W, user))
			boutput(user, "You load [W] into [src].")
			playsound(src, sound_load, 40, TRUE)
			logTheThing(LOG_STATION, user, "loads [W] into \the [src] at [log_loc(src)].")
		else
			. = ..()

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Get your filthy dead fingers off that!"))
			return

		if(over_object == src)
			output_location = null
			boutput(usr, SPAN_NOTICE("You reset the reclaimer's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The reclaimer is too far away from the target!"))
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
				boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, SPAN_ALERT("You can't use a currently unopenable cart as an output target."))
			else
				src.output_location = over_object
				boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else if (istype(over_object,/obj/machinery/manufacturer/))
			var/obj/machinery/manufacturer/M = over_object
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				boutput(usr, SPAN_ALERT("You can't use a non-functioning manufacturer as an output target."))
			else
				src.output_location = M
				boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else if (istype(over_object,/obj/table/) && istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_location = O.loc
			boutput(usr, SPAN_NOTICE("You set the reclaimer to output on top of [O]!"))

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_location = over_object
			boutput(usr, SPAN_NOTICE("You set the reclaimer to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, SPAN_ALERT("Only living mobs are able to use the reclaimer's quick-load feature."))
			return

		if (!isobj(O))
			boutput(user, SPAN_ALERT("You can't quick-load that."))
			return

		if(BOUNDS_DIST(O, user) > 0)
			boutput(user, SPAN_ALERT("You are too far away!"))
			return

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/))
			user.visible_message(SPAN_NOTICE("[user] uses [src]'s automatic loader on [O]!"), SPAN_NOTICE("You use [src]'s automatic loader on [O]."))
			var/amtload = 0
			for (var/obj/item/material/M in O.contents)
				M.set_loc(src)
				amtload++
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] materials loaded from [O]!"))
			else boutput(user, SPAN_ALERT("No material loaded!"))

		else if (is_valid(O))
			quickload(user,O)
		else
			..()

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O)
			return
		user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [O] into [src]!"))
		var/staystill = user.loc
		for(var/obj/item/M in view(1,user))
			if (!M || M.loc == user)
				continue
			if (M.name != O.name)
				continue
			if(!(src.is_valid(M) && brain_check(M, user, FALSE)))
				continue
			M.set_loc(src)
			playsound(src, sound_load, 40, TRUE)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, SPAN_NOTICE("You finish stuffing [O] into [src]!"))
		return

	proc/get_output_location()
		if (!output_location)
			return src.loc

		if (!(BOUNDS_DIST(src.output_location, src) == 0))
			output_location = null
			return src.loc

		if (istype(output_location,/obj/machinery/manufacturer))
			var/obj/machinery/manufacturer/M = output_location
			if (M.status & NOPOWER || M.status & BROKEN | M.dismantle_stage > 0)
				return M.loc
			return M

		if (istype(output_location,/obj/storage))
			var/obj/storage/S = output_location
			if (S.locked || S.welded || S.open)
				return S.loc
			return S

		return output_location

	proc/is_valid(var/obj/item/I)
		if (!istype(I))
			return
		return (I.material && !istype(I,/obj/item/material) && !istype(I,/obj/item/nuclear_waste)) || istype(I,/obj/item/wizard_crystal)

	proc/brain_check(var/obj/item/I, var/mob/user, var/ask)
		if (!istype(I))
			return
		var/obj/item/organ/brain/brain = null
		if (istype(I, /obj/item/parts/robot_parts/head))
			var/obj/item/parts/robot_parts/head/head = I
			brain = head.brain
		else if (istype(I, /obj/item/organ/brain))
			brain = I

		if (brain)
			if (!ask)
				boutput(user, SPAN_ALERT("[I] turned the intelligence detection light on! You decide to not load it for now."))
				return FALSE
			var/accept = tgui_alert(user, "Possible intelligence detected. Are you sure you want to reclaim [I]?", "Incinerate brain?", list("Yes", "No")) == "Yes" && can_reach(user, src) && user.equipped() == I
			if (accept)
				logTheThing(LOG_COMBAT, user, "loads [brain] (owner's ckey [brain.owner ? brain.owner.ckey : null]) into a portable reclaimer.")
			return accept
		return TRUE

/obj/machinery/sheet_extruder
	name = "sheet extruder"
	desc = "A specialised machine for turning material bars into sheets."
	icon = 'icons/obj/crafting.dmi'
	icon_state = "fab3-on"
	density = TRUE
	anchored = ANCHORED
	layer = FLOOR_EQUIP_LAYER1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/working = FALSE

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/material))
			boutput(user, SPAN_ALERT("[I] needs to be refined before it can be turned into sheets."))
			return
		if (!istype(I, /obj/item/material))
			return ..()
		if (src.working || src.is_disabled())
			return
		if (!I.material || !(istype(I.material, /datum/material/metal) || istype(I.material, /datum/material/ceramic)))
			boutput(user, SPAN_ALERT("[I] doesn't go in there!"))
			return
		var/obj/item/material/taken_piece = null
		if (I.amount < 1)
			playsound(src, 'sound/machines/buzz-sigh.ogg')
			return
		if (I.amount == 1)
			user.u_equip(I)
			taken_piece = I
		else
			taken_piece = I.split_stack(1)
		taken_piece.set_loc(src)
		src.working = TRUE
		playsound(src, 'sound/machines/hiss.ogg', 50, TRUE, -1)
		boutput(user, "You load [taken_piece] into [src].")
		SPAWN(2 SECONDS)
			flick("fab3-work", src)
			sleep(0.5 SECONDS)
			src.working = FALSE
			if (src.is_disabled() || QDELETED(src) || QDELETED(taken_piece))
				return
			var/obj/item/sheet/sheets = new(src)
			sheets.set_stack_amount(10)
			sheets.setMaterial(taken_piece.material)
			sheets.set_loc(src.loc)
			for (var/obj/item/sheet/other_sheets in src.loc?.contents)
				if (other_sheets == sheets)
					continue
				if (sheets.material.isSameMaterial(other_sheets.material))
					if (other_sheets.stack_item(sheets))
						break
			qdel(taken_piece)

	power_change()
		..()
		src.UpdateIcon()

	update_icon(...)
		if (src.is_broken())
			src.icon_state = "fab3-broken"
		else if (!src.powered())
			src.icon_state = "fab3-off"
		else
			src.icon_state = "fab3-on"


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
					var/datum/material_recipe/validRecipe = matchesMaterialRecipe(FP.material, SP.material)
					if(!validRecipe)
						boutput(usr, SPAN_NOTICE("Error: Did not match a recipe."))
						return //didnt find a recipe that matches

					var/datum/material/resultMaterial
					var/obj/item/material/resultItem

					if(validRecipe.result_item)
					//recipe specified a specific item to make
						resultItem = new validRecipe.result_item
					else
					//recipe only specified a material and told us to figure it out
						resultItem = new /obj/item/material
						resultItem.setMaterial(resultMaterial)

					resultItem.change_stack_amount(amt - resultItem.amount)
					FP.change_stack_amount(-amt)
					SP.change_stack_amount(-amt)
					if(istype(resultItem, /obj/item/material))
						addMaterial(resultItem, usr)
					else
						resultItem.set_loc(get_turf(src))
					validRecipe?.apply_to_obj(resultItem)
					first_part = null
					second_part = null
					boutput(usr, SPAN_NOTICE("You make [resultItem]."))

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
			user.visible_message(SPAN_NOTICE("[user] puts \the [W] in \the [src]."))
			if(istype(W, /obj/item/material))
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

		var/datum/material/M = new /datum/material/blobby/flesh {desc="A disgusting wad of flesh."; color="#881111";} ()
		M.setName("[user.real_name] flesh")

		var/obj/item/material/wad/dummyItem = new /obj/item/material/wad
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
	name = "material analyzer"
	desc = "This piece of equipment can detect and analyze materials."
	flags = EXTRADELAY | TABLEPASS | CONDUCT
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
						boutput(user, SPAN_NOTICE("• [X.getBriefStatString(W.material)]"))
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
