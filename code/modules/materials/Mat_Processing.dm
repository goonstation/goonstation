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
		if (istype(I, /obj/item/raw_material))
			boutput(user, SPAN_ALERT("[I] needs to be refined before it can be turned into sheets."))
			return
		if (!istype(I, /obj/item/material_piece))
			return ..()
		if (src.working || src.is_disabled())
			return
		if (!I.material || !((I.material.getMaterialFlags() & MATERIAL_METAL) || I.material.getMaterialFlags() & MATERIAL_CRYSTAL))
			boutput(user, SPAN_ALERT("[I] doesn't go in there!"))
			return
		var/obj/item/material_piece/taken_piece = null
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
	name = "material analyzer"
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
