//This serves as a bridge between old materials pieces and new ones. Eventually old ones should just be updated.
/obj/machinery/processor
	name = "Material processor"
	desc = "Turns raw materials, and objects containing materials, into processed pieces."
	icon = 'icons/obj/crafting.dmi'
	icon_state = "fab3-on"
	anchored = 1
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	var/atom/output_location = null

	New()
		..()

	process()
		if(contents.len)
			var/atom/X = contents[1]
			var/list/matches = list()

			for(var/atom/A in contents)
				if(A == X) continue
				if(isSameMaterial(A.material, X.material))
					matches.Add(A)

			var/output_location = get_output_location()
			var/obj/item/material_piece/exists_nearby = null
			for(var/obj/item/material_piece/G in output_location)
				if(isSameMaterial(G.material, X.material))
					exists_nearby = G
					break

			matches.Add(X)

			var/totalAmount = 0
			for(var/obj/item/M in matches)
				totalAmount += M.amount

			var/mat_id

			if(exists_nearby)
				exists_nearby.change_stack_amount(totalAmount)
				mat_id = exists_nearby.material.mat_id
			else
				var/newType = getProcessedMaterialForm(X.material)
				var/obj/item/material_piece/P = unpool(newType)
				P.set_loc(get_output_location())
				P.setMaterial(copyMaterial(X.material))
				P.change_stack_amount(totalAmount - P.amount)
				mat_id = P.material.mat_id

			if (istype(output_location, /obj/machinery/manufacturer))
				var/obj/machinery/manufacturer/M = output_location
				M.update_resource_amount(mat_id, totalAmount * 10)

			for(var/atom/movable/D in matches)
				D.set_loc(null)
				qdel(D)
				D = null

			playsound(src.loc, "sound/effects/pop.ogg", 40, 1)
			flick("fab3-work",src)
		return

	attackby(var/obj/item/W as obj, mob/user as mob)
		//Wire: Fix for: undefined proc or verb /turf/simulated/floor/set loc()
		//		like somehow a dude tried to load a turf? how the fuck? whatever just kill me
		if (!istype(W))
			return

		if(isExploitableObject(W))
			boutput(user, "<span class='alert'>\the [src] grumps at you and refuses to use [W].</span>")
			return

		if(istype(W, /obj/item/material_piece))
			boutput(user, "<span class='alert'>[W] has already been processed.</span>")
			return

		if(istype(W, /obj/item/satchel))
			var/obj/item/satchel/S = W
			boutput(user, "<span class='notice'>You empty \the [W] into \the [src].</span>")
			for(var/obj/item/I in S)
				if(I.material)
					I.set_loc(src)
			S.satchel_updateicon()
			return

		if(W.material)
			boutput(user, "<span class='notice'>You put \the [W] into \the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			W.dropped()
			return

		return

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Get your filthy dead fingers off that!</span>")
			return

		if(over_object == src)
			output_location = null
			boutput(usr, "<span class='notice'>You reset the processor's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The processor is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_location = over_object
				boutput(usr, "<span class='notice'>You set the processor to output to [over_object]!</span>")

		else if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_location = over_object
				boutput(usr, "<span class='notice'>You set the processor to output to [over_object]!</span>")

		else if (istype(over_object,/obj/machinery/manufacturer/))
			var/obj/machinery/manufacturer/M = over_object
			if (M.status & BROKEN || M.status & NOPOWER || M.dismantle_stage > 0)
				boutput(usr, "<span class='alert'>You can't use a non-functioning manufacturer as an output target.</span>")
			else
				src.output_location = M
				boutput(usr, "<span class='notice'>You set the processor to output to [over_object]!</span>")

		else if (istype(over_object, /obj/machinery/nanofab))
			var/obj/machinery/nanofab/N = over_object
			if (N.status & BROKEN || N.status & NOPOWER)
				boutput(usr, "<span class='alert'>You can't use a non-functioning nano-fabricator as an output target.</span>")
			else
				src.output_location = N
				boutput(usr, "<span class='notice'>You set the processor to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) && istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_location = O.loc
			boutput(usr, "<span class='notice'>You set the processor to output on top of [O]!</span>")

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_location = over_object
			boutput(usr, "<span class='notice'>You set the processor to output to [over_object]!</span>")

		else

			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.stat || user.getStatusDuration("paralysis") || user.getStatusDuration("stunned") || user.getStatusDuration("weakened") || isAI(user))
			return

		if (istype(O, /obj/storage/crate/) || istype(O, /obj/storage/cart/))
			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [O]!</span>", "<span class='notice'>You use [src]'s automatic loader on [O].</span>")
			var/amtload = 0
			for (var/obj/item/raw_material/M in O.contents)
				if(!M.material)
					continue
				if(isExploitableObject(M))
					continue
				if(istype(M, /obj/item/material_piece))
					continue
				M.set_loc(src)
				amtload += max(M.amount, 1)
			if (amtload) boutput(user, "<span class='notice'>[amtload] materials loaded from [O]!</span>")
			else boutput(user, "<span class='alert'>No material loaded!</span>")
			return

		var/obj/item/W = O

		if(W in user)
			user.u_equip(W)
			W.set_loc(src.loc)
			W.dropped()


		//if (istype(W, /obj/item/raw_material/) || istype(W, /obj/item/sheet/) || istype(W, /obj/item/rods/) || istype(W, /obj/item/tile/) || istype(W, /obj/item/cable_coil))
		if(!isExploitableObject(W) && W.material && !istype(W, /obj/item/material_piece))
			quickload(user, W)
		else
			attackby(W, user)
			return


	ex_act(severity)
		return

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O || !istype(O))
			return
		user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
		O.set_loc(src)
		var/staystill = user.loc
		for(var/obj/item/M in view(1,user))
			if (!M)
				continue
			if (M.type != O.type)
				continue
			if(!istype(M, /obj/item/cable_coil))
				if (!istype(M.material))
					continue
				//if (!M.material.material_flags & MATERIAL_CRYSTAL || !M.material.material_flags & MATERIAL_METAL)
				//	continue

			M.set_loc(src)
			playsound(get_turf(src), "sound/items/Deconstruct.ogg", 40, 1)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
		return

	proc/get_output_location()
		if (isnull(output_location))
			return src.loc

		if (get_dist(src.output_location,src) > 1)
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

/obj/machinery/processor/portable
	name = "Portable material processor"
	icon = 'icons/obj/scrap.dmi'
	icon_state = "reclaimer"
	anchored = 0
	density = 1

	custom_suicide = 1
	suicide(var/mob/user)
		if (!src.user_can_suicide(user))
			return 0

		user.visible_message("<span class='alert'><b>[user] hops right into [src]! Jesus!</b></span>")
		user.unequip_all()
		user.set_loc(src)
		user.make_cube(life = 5 MINUTES, T = src.loc)
/obj/machinery/neosmelter
	name = "Nano-crucible"
	desc = "A huge furnace-like machine used to combine materials."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smelter0"
	anchored = 1
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

	attack_hand(mob/user as mob)
		var/html = ""
		html += "<div style=\"margin: auto;text-align:center\">[first_part ? "<a href='?src=\ref[src];remove=\ref[first_part]'>[first_part.name]</a>" : "EMPTY"] <i class=\"icon-plus\"></i> [second_part ? "<a href='?src=\ref[src];remove=\ref[second_part]'>[second_part.name]</a>" : "EMPTY"]   <i class=\"icon-double-angle-right\"></i> [resultName]</div><br>"
		html += "<div style=\"margin: auto;text-align:center\"><a href='?src=\ref[src];activate=1'><i class=\"icon-check-sign icon-large\"></i></a></div><br><br>"

		for(var/obj/item/I in src)
			if(!I.amount) continue
			if(first_part == I) continue
			if(second_part == I) continue
			html += "<div style=\"margin: auto;text-align:center\"><a href='?src=\ref[src];select_l=\ref[I]'><i class=\"icon-arrow-left\"></i></a> <a href='?src=\ref[src];eject=\ref[I]'>[I.name]</a> <a href='?src=\ref[src];select_r=\ref[I]'><i class=\"icon-arrow-right\"></i></a></div><br>"

		user.Browse(html, "window=crucible;size=500x650;title=Nano-crucible;fade_in=0", 1)
		return

	Topic(href, href_list)
		if(get_dist(usr, src) > 1 || usr.z != src.z) return

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
				if(amt && isnum(amt) && FP && FP.amount >= amt && SP && SP.amount >= amt && (FP in src) && (SP in src))
					flick("smelter1",src)
					var/datum/material/merged = getFusedMaterial(FP.material, SP.material)
					var/datum/material_recipe/RE = matchesMaterialRecipe(merged)
					var/newtype = getProcessedMaterialForm(merged)
					var/apply_material = 1
					var/output_item = 0

					if(RE)
						if(!RE.result_id && !RE.result_item)
							RE.apply_to(merged)
						else if(RE.result_item)
							newtype = RE.result_item
							apply_material = 0
							output_item = 1
						else if(RE.result_id)
							merged = getMaterial(RE.result_id)

					var/obj/item/piece = new newtype(src)

					if(istype(FP.material, /datum/material/fissile) && istype(SP.material, /datum/material/fissile))
						merged = merge_mat_nuke(merged, FP.material, SP.material)

					if(apply_material)
						piece.setMaterial(merged)

					piece.change_stack_amount(amt - piece.amount)
					FP.change_stack_amount(-amt)
					SP.change_stack_amount(-amt)
					if(!output_item)
						addMaterial(piece, usr)
					else
						piece.set_loc(get_turf(src))
					first_part = null
					second_part = null
					boutput(usr, "<span class='notice'>You make [amt] [piece].</span>")

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
		attack_hand(usr)

	proc/updateResultName()
		if(first_part && second_part)
			resultName = getInterpolatedName(first_part.material.name, second_part.material.name, 0.5)
		else
			resultName = "???"

	proc/addMaterial(var/obj/item/W, var/mob/user)
		for(var/obj/item/A in src)
			if(A == W|| !A.amount) continue
			if(A.material)
				if(isSameMaterial(A.material, W.material))
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
			boutput(user, "<span class='alert'>\the [src] grumps at you and refuses to use [W].</span>")
			return

		if(W.material != null)
			if(!W.material.canMix)
				boutput(user, "<span class='alert'>This material can not be used in \the [src].</span>")
				return

			user.visible_message("<span class='notice'>[user] puts \the [W] in \the [src].</span>")
			if( istype(W, /obj/item/material_piece) || istype(W, /obj/item/raw_material) )
				addMaterial(W, user)
			else
				boutput(user, "<span class='alert'>The crucible can only use raw materials.</span>")
				return
		return

	custom_suicide = 1
	suicide(var/mob/user)
		if (!src.user_can_suicide(user))
			return 0

		user.visible_message("<span class='alert'><b>[user] hops right into [src]! Jesus!</b></span>")
		user.unequip_all()
		user.set_loc(src)

		var/datum/material/M = new /datum/material/organic/flesh {desc="A disgusting wad of flesh."; color="#881111";} ()
		M.name = "[user.real_name] flesh"

		var/obj/item/material_piece/wad/dummyItem = unpool(/obj/item/material_piece/wad)
		dummyItem.set_loc(src)
		dummyItem.setMaterial(M)
		dummyItem.change_stack_amount(5)
		addMaterial(dummyItem, user)
		user.remove()

	ex_act(severity)
		return


/obj/machinery/smelter_portable
	name = "Portable Smelter"
	desc = "A small furnace-like machine used to melt and combine metals or minerals."
	icon = 'icons/obj/crafting.dmi'
	icon_state = "portsmelter0"
	anchored = 0
	density = 1
	layer = FLOOR_EQUIP_LAYER1
	var/list/components = list()
	var/sound/sound_bubble = sound('sound/effects/bubbles.ogg')
	var/datum/material/output = null
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.5)
		light.set_color(1, 0.6, 0.2)

	ex_act(severity)
		return

/obj/machinery/smelter
	name = "Arc Smelter"
	desc = "A huge furnace-like machine used to melt and combine metals or minerals."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smelter0"
	anchored = 1
	bound_height = 96
	bound_width = 96
	density = 1
	layer = FLOOR_EQUIP_LAYER1

	var/list/components = list()
	var/slag_level = 0

	var/sound/sound_thunk = sound('sound/items/Deconstruct.ogg')
	var/sound/sound_zap = sound('sound/effects/elec_bzzz.ogg')
	var/sound/sound_hiss = sound('sound/machines/hiss.ogg')
	var/sound/sound_bubble = sound('sound/effects/bubbles.ogg')

	var/datum/material/output = null
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(src, 1.5, 1.5)
		light.set_brightness(0.5)
		light.set_color(0.4, 0.8, 1)

	proc/resetMats()
		icon_state = "smelter0"
		output = null
		for(var/atom/movable/A in components)
			A.set_loc(null)
			qdel(A)
			A = null
		components.Cut()
		return

	attack_hand(mob/user as mob)
		if(output)
			var/datum/material_recipe/R = matchesMaterialRecipe(output)
			if(R)
				if(R.result_item)
					var/atom/A = new R.result_item(locate(src.x + 1, src.y, src.z))
					boutput(user, "<span class='notice'>You remove [A.name] from the [src].</span>")
					playsound(src.loc, sound_thunk, 40, 1)
					resetMats()
					return
				else if(length(R.result_id))
					output = getMaterial(R.result_id)
				else
					R.apply_to(output)

			boutput(user, "<span class='notice'>You remove [output.name] from the [src].</span>")

			var/bar_type = getProcessedMaterialForm(output)
			var/obj/item/material_piece/M = unpool(bar_type)
			M.set_loc(locate(src.x + 1, src.y, src.z))

			M.add_fingerprint(user) // May not be the same person who smelted the materials (Convair880).
			src.add_fingerprint(user) // Add some prints to the smelter too.

			M.setMaterial(output)
			resetMats()
			playsound(src.loc, sound_thunk, 40, 1)

			if(M.material && M.material.getProperty("stability") <= 30 && prob((30 - M.material.getProperty("stability")) * 2 ) )
				M.visible_message("<span class='alert'>[M] [getMatFailString(M.material.material_flags)]!</span>")
				M.material.triggerOnFail(M)
			return

		if(components.len > 0)
			light.enable()
			playsound(src.loc, sound_zap, 40, 1)
			SPAWN_DBG(0.5 SECONDS)
				playsound(src.loc, sound_bubble, 40, 1)
			if(components.len == 1)
				boutput(user, "<span class='alert'>You activate the [src].</span>")
				icon_state = "smelter1"
				sleep(1 SECOND)
				var/atom/obj1 = components[1]
				output = copyMaterial(obj1.material)
				logTheThing("station", user, null, "creates a [output] bar (<b>Material:</b> <i>[output.mat_id]</i>) with the [src] at [log_loc(src)].") //  Re-added/fixed because of erebite, plasmastone etc. alloys (Convair880).
				handleSlag()
			else
				icon_state = "smelter1"
				sleep(1 SECOND)
				var/atom/obj1 = components[1]
				var/atom/obj2 = components[2]

				var/datum/material/mat1 = obj1.material
				var/datum/material/mat2 = obj2.material

				if(!mat1 || !mat2)
					icon_state = "smelter0"
					return

				output = getFusedMaterial(mat1, mat2)
				output.generation++
				logTheThing("station", user, null, "creates a [output] bar (<b>Material:</b> <i>[output.mat_id]</i>) with the [src] at [log_loc(src)].") // Sorry for code duplication, but I'm regularly seeing runtime errors for some reason if this proc is called after handleSlag (Convair880).
				handleSlag()
			SPAWN_DBG(0.8 SECONDS)
				playsound(src.loc, sound_hiss, 45, 1)
				light.disable()
		else
			boutput(user, "<span class='alert'>There is nothing in the [src].</span>")
		return

	proc/handleSlag()
		switch(slag_level)
			if(500 to 1000)
				particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#967360", 10, locate(src.x +1, src.y, src.z)))
				//output.adjustProperty(PROP_INSTABILITY , 5)
				output.quality += rand(5, -15)
			if(1000 to INFINITY)
				particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#221511", 10, locate(src.x +1, src.y, src.z)))
				output.quality += rand(-15, -30)
				//output.adjustProperty(PROP_INSTABILITY , 15)
		slag_level += (100 - output.quality)
		return

	custom_suicide = 1
	suicide(var/mob/user)
		if (!src.user_can_suicide(user))
			return 0

		user.visible_message("<span class='alert'><b>[user] hops right into [src]! Jesus!</b></span>")
		user.unequip_all()
		user.set_loc(src)

		var/datum/material/M = new /datum/material/organic/flesh {desc="A disgusting wad of flesh."; color="#881111";} ()
		M.name = "[user.real_name] flesh"

		var/obj/item/dummyItem = new (src)
		dummyItem.setMaterial(M, appearance = 0, setname = 0)
		components += dummyItem
		user.ghostize()

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/slag_shovel))
			if(slag_level)
				src.visible_message("<span class='notice'>[user] removes slag from the [src]</span>")
				slag_level = 0
				var/obj/item/material_piece/slag/S = unpool(/obj/item/material_piece/slag)
				S.set_loc(src.loc)
				return
			else
				boutput(user, "<span class='notice'>There is no slag in [src].</span>")
				return

		if(istype(W, /obj/item/wizard_crystal) && components.len < 2 && !W.material)
			W.setMaterial(W:assoc_material, appearance = 0, setname = 0)

		if(W.material != null)
			if(!W.material.canMix)
				boutput(user, "<span class='alert'>This material can not be used in the [src].</span>")
				return

			if((W.material.material_flags & MATERIAL_METAL || W.material.material_flags & MATERIAL_CRYSTAL) && (istype(W, /obj/item/material_piece) || istype(W, /obj/item/raw_material)) )
				if(components.len < 2)
					src.visible_message("<span class='notice'>[user] puts [W] into [src]</span>")
					user.drop_item()
					components.Add(W)
					W.set_loc(src)
					playsound(src.loc, sound_thunk, 40, 1)
				else
					boutput(user, "<span class='alert'>The smelter is already filled to capacity!</span>")
					return
			else
				boutput(user, "<span class='alert'>The smelter can only use metals or minerals in raw form.</span>")
				return
		return

	ex_act(severity) // bloo bloo we blew it up and nobody gets to have fun
		return

//
/obj/item/device/matanalyzer
	icon_state = "matanalyzer"
	name = "Material analyzer"
	desc = "This piece of equipment can detect and analyze materials."
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = 2

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(get_dist(src, target) <= world.view)
			animate_scanning(target, "#597B6D")
			var/atom/W = target
			if(!W.material)
				boutput(user, "<span class='alert'>No significant material found in \the [target].</span>")
			else
				boutput(user, "<span class='notice'><u>[capitalize(W.material.name)]</u></span>")
				boutput(user, "<span class='notice'>[W.material.desc]</span>")

				if(W.material.properties.len)
					boutput(user, "<span class='notice'><u>The material is:</u></span>")
					for(var/datum/material_property/X in W.material.properties)
						var/value = W.material.getProperty(X.id)
						boutput(user, "<span class='notice'>• [X.getAdjective(W.material)] ([value])</span>")
				else
					boutput(user, "<span class='notice'><u>The material is completely unremarkable.</u></span>")
		else
			boutput(user, "<span class='alert'>[target] is too far away.</span>")
		return

/obj/item/slag_shovel
	name = "slag shovel"
	desc = "Used to remove slag from the arc smelter."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "shovel"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "shovel"
	w_class = 3
	flags = ONBELT
	force = 7 // 15 puts it significantly above most other weapons
	hitsound = 'sound/impact_sounds/Metal_Hit_1.ogg'

	New()
		..()
		BLOCK_ROD
