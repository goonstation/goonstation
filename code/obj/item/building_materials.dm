/*
CONTAINS:
RODS
METAL
REINFORCED METAL
MATERIAL

*/

/proc/window_reinforce_callback(var/datum/action/bar/icon/build/B, var/obj/window/reinforced/W)
	sheet_crafting_callback(B)

	W.ini_dir = 2
	if (!istype(W) || !usr) //Wire: Fix for Cannot read null.loc (|| !usr)
		return
	if (B.sheet.reinforcement)
		W.set_reinforcement(B.sheet.reinforcement)
		if (map_settings)
			W = new map_settings.rwindows_thin (usr.loc)
		else
			W = new /obj/window/reinforced(usr.loc)

/proc/window_reinforce_full_callback(var/datum/action/bar/icon/build/B, var/obj/window/reinforced/W)
	sheet_crafting_callback(B)

	W.set_dir(SOUTHWEST)
	W.ini_dir = SOUTHWEST
	if (!istype(W))
		return
	if (!usr) //Wire: Fix for Cannot read null.loc
		return
	if (B.sheet.reinforcement)
		W.set_reinforcement(B.sheet.reinforcement)
		if (map_settings)
			W = new map_settings.rwindows (usr.loc)
		else
			W = new /obj/window/reinforced(usr.loc)

/proc/sheet_crafting_callback(var/datum/action/bar/icon/build/B)
	tgui_process.update_uis(B.sheet)

/obj/item/sheet
	name = "sheet"
	icon = 'icons/obj/metal.dmi'
	icon_state = "sheet-m_5"
	//Used to determine the right icon_state: combined with suffixes for material/reinforcement in update_appearance and one for amount in change_stack_appearance
	var/icon_state_base = "sheet"
	desc = "Thin sheets of building material. Can be used to build many things."
	flags = FPRINT | TABLEPASS
	throwforce = 5
	throw_speed = 1
	throw_range = 4
	w_class = W_CLASS_NORMAL
	max_stack = 50
	stamina_damage = 42
	stamina_cost = 23
	stamina_crit_chance = 10
	material_amt = 0.1
	var/datum/material/reinforcement = null
	rand_pos = 1
	inventory_counter_enabled = 1

	New()
		..()
		SPAWN(0)
			update_appearance()
		create_inventory_counter()
		BLOCK_SETUP(BLOCK_ALL)

	proc/amount_check(var/use_amount,var/mob/user)
		if (src.amount < use_amount)
			if (user)
				boutput(user, "<span class='alert'>You need at least [use_amount] sheets to do that.</span>")
			return 0
		else
			return 1

	change_stack_amount(diff)
		. = ..()
		if (amount < 1)
			if (isliving(src.loc))
				tgui_process.update_uis(src)

	proc/set_reinforcement(var/datum/material/M)
		if (!istype(M))
			return
		src.reinforcement = M
		update_appearance()

	onMaterialChanged()
		..()
		update_appearance()

	proc/update_appearance()
		src.name = initial(name)
		src.icon_state_base = initial(icon_state_base)
		if (istype(material))
			if (src.material.material_flags & MATERIAL_CRYSTAL)
				src.icon_state_base += "-g"
			else
				src.icon_state_base += "-m"
			src.name = "[material.name] " + src.name
			if (istype(reinforcement))
				src.name = "[reinforcement.name]-reinforced " + src.name
				src.icon_state_base += "-r"
			src.color = src.material.color
			src.alpha = src.material.alpha
		inventory_counter?.update_number(amount)
		UpdateStackAppearance()

	_update_stack_appearance()
		if (amount <= 10)
			icon_state = "[icon_state_base]_1"
		else if (amount <= 20)
			icon_state = "[icon_state_base]_2"
		else if (amount <= 30)
			icon_state = "[icon_state_base]_3"
		else if (amount <= 40)
			icon_state = "[icon_state_base]_4"
		else
			icon_state = "[icon_state_base]_5"



	attack_hand(mob/user)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = round(input("How many sheets do you want to take from the stack?","Stack of [src.amount]",1) as num)
			if(!in_interact_range(src, user) || !isnum_safe(splitnum))
				return
			splitnum = round(clamp(splitnum, 0, src.amount))
			if(amount == 0)
				return
			var/obj/item/sheet/new_stack = split_stack(splitnum)
			if (!istype(new_stack))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
			boutput(user, "<span class='notice'>You take [splitnum] sheets from the stack, leaving [src.amount] sheets behind.</span>")
			tgui_process.update_uis(src)
		else
			..(user)

	split_stack(toRemove)
		. = ..()
		if(. && src.reinforcement)
			var/obj/item/sheet/S = .
			S.set_reinforcement(src.reinforcement)
			. = S

	attackby(obj/item/W, mob/user as mob)
		if (istype(W, /obj/item/sheet))
			var/obj/item/sheet/S = W
			if (S.material && src.material && !isSameMaterial(S.material, src.material))
				// build glass tables
				if (src.material.material_flags & MATERIAL_METAL && S.material.material_flags & MATERIAL_CRYSTAL) // we're a metal and they're a glass
					if (src.amount_check(1,user) && S.amount_check(2,user))
						var/reinf = S.reinforcement ? 1 : 0
						var/a_type = reinf ? /obj/item/furniture_parts/table/glass/reinforced : /obj/item/furniture_parts/table/glass
						var/a_icon_state = "[reinf ? "r_" : null]table_parts"
						var/a_name = "[reinf ? "reinforced " : null]glass table parts"
						actions.start(new /datum/action/bar/icon/build(S, a_type, 2, S.material, 1, 'icons/obj/furniture/table_glass.dmi', a_icon_state, a_name, /proc/sheet_crafting_callback, src, 1), user)
					return
				else if (src.material.material_flags & MATERIAL_CRYSTAL && S.material.material_flags & MATERIAL_METAL) // we're a glass and they're a metal
					if (src.amount_check(2,user) && S.amount_check(1,user))
						var/reinf = src.reinforcement ? 1 : 0
						var/a_type = reinf ? /obj/item/furniture_parts/table/glass/reinforced : /obj/item/furniture_parts/table/glass
						var/a_icon_state = "[reinf ? "r_" : null]table_parts"
						var/a_name = "[reinf ? "reinforced " : null]glass table parts"
						actions.start(new /datum/action/bar/icon/build(src, a_type, 2, src.material, 1, 'icons/obj/furniture/table_glass.dmi', a_icon_state, a_name, /proc/sheet_crafting_callback, S, 1), user)
					return

				else
					boutput(user, "<span class='alert'>You can't mix different materials!</span>")
					return
			if (!isSameMaterial(S.reinforcement, src.reinforcement))
				boutput(user, "<span class='alert'>You can't mix different reinforcements!</span>")
				return
			var/success = stack_item(W)
			if (!success)
				boutput(user, "<span class='alert'>You can't put any more sheets in this stack!</span>")
			else
				if(!user.is_in_hands(src))
					user.put_in_hand(src)
				if(isrobot(user))
					boutput(user, "<span class='notice'>You add [success] sheets to the stack. It now has [S.amount] sheets.</span>")
				else
					boutput(user, "<span class='notice'>You add [success] sheets to the stack. It now has [src.amount] sheets.</span>")
				tgui_process.update_uis(src)
			return

		else if (istype(W,/obj/item/rods))
			var/obj/item/rods/R = W
			if (src.reinforcement)
				boutput(user, "<span class='alert'>That's already reinforced!</span>")
				return
			if (!R.material)
				boutput(user, "<span class='alert'>These rods won't work for reinforcing.</span>")
				return

			if (src.material && (src.material.material_flags & MATERIAL_METAL || src.material.material_flags & MATERIAL_CRYSTAL))
				var/makesheets = min(min(R.amount,src.amount),50)
				var/sheetsinput = input("Reinforce how many sheets?","Min: 1, Max: [makesheets]",1) as num
				if (sheetsinput < 1 || !isnum_safe(sheetsinput))
					return
				sheetsinput = min(sheetsinput,makesheets)

				if (!in_interact_range(src, user) || !R) //moving, or the rods are getting destroyed during the input()
					return

				var/obj/item/sheet/S = new /obj/item/sheet(get_turf(user))
				S.setMaterial(src.material)
				S.set_reinforcement(R.material)
				S.amount = sheetsinput
				S.inventory_counter.update_number(S.amount)
				R.change_stack_amount(-sheetsinput)
				src.change_stack_amount(-sheetsinput)
			else
				boutput(user, "<span class='alert'>You may only reinforce metal or crystal sheets.</span>")
				return
		else
			..()
		return

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins gathering up [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish gathering sheets.</span>")

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/sheet/))
			//boutput(world, "check valid stack check 1 failed")
			return 0
		var/obj/item/sheet/S = O
		if (!S.material || !src.material)
			return 0
		if (S.material.type != src.material.type)
			//boutput(world, "check valid stack check 2 failed")
			return 0
		if (S.material && src.material && !isSameMaterial(S.material, src.material))
			//boutput(world, "check valid stack check 3 failed")
			return 0
		if ((src.reinforcement && !S.reinforcement) || (S.reinforcement && !src.reinforcement))
			//boutput(world, "check valid stack check 4 failed")
			return 0
		if (src.reinforcement && S.reinforcement)
			if (src.reinforcement.type != S.reinforcement.type)
				//boutput(world, "check valid stack check 5 failed")
				return 0
			if (!isSameMaterial(S.reinforcement, src.reinforcement))
				//boutput(world, "check valid stack check 6 failed")
				return 0
		return 1

	examine()
		. = ..()
		. += "There [src.amount > 1 ? "are" : "is"] [src.amount] sheet\s on the stack."


	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "SheetCrafting", "Sheet Crafting")
			ui.open()

	attack_self(mob/user as mob)
		ui_interact(user)

	ui_data(mob/user)
		. = list()

		.["availableAmount"] = src.amount
		.["labeledAvailableAmount"] = "[src.amount] [src.name]\s"

		var/list/availableRecipes = list()
		if (src?.material?.material_flags & MATERIAL_METAL)
			if (istype(src.reinforcement))
				for(var/recipePath in concrete_typesof(/datum/sheet_crafting_recipe/reinforced_metal))
					availableRecipes.Add(sheet_crafting_recipe_get_ui_data(recipePath))

				availableRecipes.Add(sheet_crafting_recipe_get_ui_data(/datum/sheet_crafting_recipe/remetal))
			else
				for(var/recipePath in concrete_typesof(/datum/sheet_crafting_recipe/metal))
					availableRecipes.Add(sheet_crafting_recipe_get_ui_data(recipePath))
		if (src?.material?.material_flags & MATERIAL_CRYSTAL)
			for(var/recipePath in concrete_typesof(/datum/sheet_crafting_recipe/glass))
				availableRecipes.Add(sheet_crafting_recipe_get_ui_data(recipePath))
			if (istype(src.reinforcement))
				availableRecipes.Add(sheet_crafting_recipe_get_ui_data(/datum/sheet_crafting_recipe/remetal/glass))
		if (src?.material?.mat_id == "cardboard")
			for(var/recipePath in concrete_typesof(/datum/sheet_crafting_recipe/cardboard))
				availableRecipes.Add(sheet_crafting_recipe_get_ui_data(recipePath))
		if (src?.material?.material_flags & MATERIAL_WOOD)
			for(var/recipePath in concrete_typesof(/datum/sheet_crafting_recipe/wood))
				availableRecipes.Add(sheet_crafting_recipe_get_ui_data(recipePath))

		.["itemList"] = availableRecipes

	ui_act(action, params)
		. = ..()
		if(.)
			return

		if (usr.restrained() || usr.stat)
			if(!isrobot(usr))
				return

		//Magtractor holding metal check
		var/atom/equipped = usr.equipped()
		if (equipped != src)
			if (istype(equipped, /obj/item/magtractor) && equipped:holding)
				if (equipped:holding != src)
					return
			else
				return
//You can't build! The if is to stop compiler warnings
#if defined(MAP_OVERRIDE_POD_WARS)
		if (src)
			boutput(usr, "<span class='alert'>What are you gonna do with this? You have a very particular set of skills, and building is not one of them...</span>")
			return
#endif

		if (action == "make")
			if (src.amount < 1)
				src.change_stack_amount(0) //Basically "clean up and pool"
				return

			var/datum/sheet_crafting_recipe/currentRecipe

			var/a_type = null
			var/a_amount = null
			var/a_cost = null
			var/a_callback = null

			//When adding a new recipe, consider using the for loop technique used by a recipe like "rack" instead of adding a new if
			switch(params["recipeID"])
				if("rods")
					var/makerods = min(src.amount,25)
					var/rodsinput = input("Use how many sheets? (Get 2 rods for each sheet used)","Min: 1, Max: [makerods]",1) as num
					if (rodsinput < 1 || !isnum_safe(rodsinput)) return
					rodsinput = min(rodsinput,makerods)

					if (!in_interact_range(src, usr)) //no walking away
						return

					currentRecipe = /datum/sheet_crafting_recipe/metal/rods

					a_amount = rodsinput * initial(currentRecipe.yield)
					a_cost = rodsinput * initial(currentRecipe.sheet_cost)

				if("fl_tiles")
					var/maketiles = min(src.amount,20)
					var/tileinput = input("Use how many sheets? (Get 4 tiles for each sheet used)","Max: [maketiles]",1) as num
					if (tileinput < 1 || !isnum_safe(tileinput)) return
					tileinput = min(tileinput,maketiles)

					if (!in_interact_range(src, usr)) //no walking away
						return

					currentRecipe = /datum/sheet_crafting_recipe/metal/fl_tiles

					a_amount = tileinput * initial(currentRecipe.yield)
					a_cost = tileinput * initial(currentRecipe.sheet_cost)

				if("construct")
					var/turf/T = get_turf(usr)
					var/area/A = get_area (usr)

					if (!istype(T, /turf/simulated/floor))
						boutput(usr, "<span class='alert'>You can't build girders here.</span>")
						return
					if (istype(A, /area/supply/spawn_point || /area/supply/delivery_point || /area/supply/sell_point))
						boutput(usr, "<span class='alert'>You can't build girders here.</span>")
						return
					if (!amount_check(2,usr)) return

					currentRecipe = /datum/sheet_crafting_recipe/metal/construct

				if("smallwindow")
					if (src.reinforcement)
						a_type = map_settings ? map_settings.rwindows_thin : /obj/window/reinforced
					else
						a_type = map_settings ? map_settings.windows_thin : /obj/window

					currentRecipe = /datum/sheet_crafting_recipe/glass/smallwindow

					a_callback = /proc/window_reinforce_callback

				if("bigwindow")
					if (!amount_check(2,usr)) return
					if (src.reinforcement)
						a_type = map_settings ? map_settings.rwindows : /obj/window/reinforced
					else
						a_type = map_settings ? map_settings.windows : /obj/window

					currentRecipe = /datum/sheet_crafting_recipe/glass/bigwindow

					a_callback = /proc/window_reinforce_full_callback

				if("remetal")
					// what the fuck is this
					var/input = input("Use how many sheets?","Max: [src.amount]",1) as num
					if (input < 1 || !isnum_safe(input)) return
					input = min(input,src.amount)

					if (!in_interact_range(src, usr)) //no walking away
						return

					var/obj/item/sheet/C = new /obj/item/sheet(usr.loc)
					var/obj/item/rods/R = new /obj/item/rods(usr.loc)
					if(src.material)
						C.setMaterial(src.material)
					if(src.reinforcement)
						R.setMaterial(src.reinforcement)
					C.amount = input
					R.amount = input
					src.change_stack_amount(-input)
					. = TRUE

				else
					for(var/recipePath in concrete_typesof(/datum/sheet_crafting_recipe))
						var/datum/sheet_crafting_recipe/loopedRecipe = recipePath
						if (initial(loopedRecipe.recipe_id) == params["recipeID"])

							if (!amount_check(initial(loopedRecipe.sheet_cost),usr)) return

							currentRecipe = loopedRecipe

			if (currentRecipe)
				if (!a_type)
					a_type = initial(currentRecipe.craftedType)
				if (!a_amount)
					a_amount = initial(currentRecipe.yield)
				if (!a_cost)
					a_cost = initial(currentRecipe.sheet_cost)
				if (!a_callback)
					a_callback = /proc/sheet_crafting_callback

				actions.start(new /datum/action/bar/icon/build(src, a_type, a_cost, src.material, a_amount, initial(currentRecipe.icon), initial(currentRecipe.icon_state), initial(currentRecipe.name), a_callback), usr)
				. = TRUE

		return

/obj/item/sheet/steel

	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "sheet-metal"

	New()
		..()
		var/datum/material/M = getMaterial("steel")
		src.setMaterial(M)

	reinforced
		icon_state = "sheet-m-r_5"
		New()
			..()
			var/datum/material/M = getMaterial("steel")
			src.set_reinforcement(M)

/obj/item/sheet/glass

	icon_state = "sheet-g_5" //overriden in-game but shows up in map editors
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "sheet-glass"

	New()
		..()
		var/datum/material/M = getMaterial("glass")
		src.setMaterial(M)

	reinforced
		icon_state = "sheet-g-r_5"
		New()
			..()
			var/datum/material/M = getMaterial("steel")
			src.set_reinforcement(M)

	crystal

		New()
			..()
			var/datum/material/M = getMaterial("plasmaglass")
			src.setMaterial(M)

		reinforced
			icon_state = "sheet-g-r_5"
			New()
				..()
				var/datum/material/M = getMaterial("steel")
				src.set_reinforcement(M)

/obj/item/sheet/wood

	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "sheet-metal"
	amount = 10

	New()
		..()
		var/datum/material/M = getMaterial("wood")
		src.setMaterial(M)

/obj/item/sheet/bamboo

	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "sheet-metal"
	amount = 10

	New()
		..()
		var/datum/material/M = getMaterial("bamboo")
		src.setMaterial(M)

// RODS
/obj/item/rods
	name = "rods"
	desc = "A set of metal rods, useful for constructing grilles and other objects, and decent for hitting people."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rods_5"
	item_state = "rods"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = W_CLASS_NORMAL
	force = 9
	throwforce = 15
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_stack = 50
	stamina_damage = 20
	stamina_cost = 16
	stamina_crit_chance = 30
	rand_pos = 1
	inventory_counter_enabled = 1
	material_amt = 0.05

	New()
		..()
		SPAWN(0)
			UpdateStackAppearance()
		BLOCK_SETUP(BLOCK_ROD)

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/rods/))
			return 0
		var/obj/item/rods/S = O
		if (!S.material || !src.material)
			return 0
		if (S.material.type != src.material.type)
			return 0
		if (!isSameMaterial(S.material, src.material))
			return 0
		return 1

	_update_stack_appearance()
		if (amount <= 10)
			icon_state = "rods_1"
		else if (amount <= 20)
			icon_state = "rods_2"
		else if (amount <= 30)
			icon_state = "rods_3"
		else if (amount <= 40)
			icon_state = "rods_4"
		else
			icon_state = "rods_5"
		src.inventory_counter.update_number(amount)

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins gathering up [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		UpdateStackAppearance()
		boutput(user, "<span class='notice'>You finish gathering rods.</span>")

	examine()
		. = ..()
		. += "There are [src.amount] rod\s on this stack."

	attack_hand(mob/user)
		if((user.r_hand == src || user.l_hand == src) && src.amount > 1)
			var/splitnum = round(input("How many rods do you want to take from the stack?","Stack of [src.amount]",1) as num)

			if (!in_interact_range(src, user) || !isnum_safe(splitnum)) //no walking away
				return

			var/obj/item/rods/new_stack = split_stack(splitnum)
			if (!istype(new_stack))
				boutput(user, "<span class='alert'>Invalid entry, try again.</span>")
				return
			user.put_in_hand_or_drop(new_stack)
			new_stack.add_fingerprint(user)
			boutput(user, "<span class='notice'>You take [splitnum] rods from the stack, leaving [src.amount] rods behind.</span>")
		else
			..(user)

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			if(src.amount < 2)
				boutput(user, "<span class='alert'>You need at least two rods to make a material sheet.</span>")
				return
			if (!istype(src.loc,/turf/))
				if (issilicon(user))
					boutput(user, "<span class='alert'>Hardcore as it sounds, smelting parts of yourself off isn't big or clever.</span>")
				else
					boutput(user, "<span class='alert'>You should probably put the rods down first.</span>")
				return
			if(!W:try_weld(user, 1))
				return

			var/weldinput = 1
			if (src.amount > 3)
				var/makemetal = round(src.amount / 2)
				boutput(user, "<span class='notice'>You could make up to [makemetal] sheets by welding this stack.</span>")
				weldinput = input("How many sheets do you want to make?","Welding",1) as num
				makemetal = round(src.amount / 2) // could have changed during input()

				if (!in_interact_range(src, user) || !isnum_safe(weldinput)) //no walking away
					return

				if (weldinput < 1) return
				if (weldinput > makemetal) weldinput = makemetal
			var/obj/item/sheet/M = new /obj/item/sheet/steel(user.loc)
			if(src.material) M.setMaterial(src.material)
			M.amount = weldinput
			src.change_stack_amount(-(weldinput * 2))

			user.visible_message("<span class='alert'><B>[user]</B> welds the rods together into sheets.</span>")
			UpdateStackAppearance()
			if(src.amount < 1)	qdel(src)
			return

		if (istype(W, /obj/item/rods))
			// stack_item won't succeed if the materials differ but we want a specific error message
			if (W.material && src.material && !isSameMaterial(W.material, src.material))
				boutput(user, "<span class='alert'>You can't mix 2 stacks of different metals!</span>")
				return
			var/success = stack_item(W)
			if (!success)
				boutput(user, "<span class='alert'>You can't put any more rods in this stack!</span>")
			else
				if(!user.is_in_hands(src))
					user.put_in_hand(src)
				if(isrobot(user))
					boutput(user, "<span class='notice'>You add [success] rods to the stack. It now has [W.amount] rods.</span>")
				else
					boutput(user, "<span class='notice'>You add [success] rods to the stack. It now has [src.amount] rods.</span>")
			return

		if (istype(W, /obj/item/organ/head))
			user.visible_message("<span class='alert'><B>[user] impales [W.name] on a spike!</B></span>")
			var/obj/head_on_spike/HS = new /obj/head_on_spike(get_turf(src))
			HS.heads += W
			user.u_equip(W)
			W.set_loc(HS)
			/*	Can't do this because it colours the heads as well as the spike itself.
			if(src.material) HS.setMaterial(src.material)*/
			change_stack_amount(-1)
		return

	attack_self(mob/user as mob)
		if (user.getStatusDuration("weakened") | user.getStatusDuration("stunned"))
			return
		if (istype(user.loc, /obj/vehicle/segway))
			var/obj/vehicle/segway/S = user.loc
			if (S.joustingTool == src) // already raised as a lance, lower it
				user.visible_message("[user] lowers the rod lance.", "You lower the rod. Everybody lets out a sigh of relief.")
				S.joustingTool = null
			else // Lances up!
				user.visible_message("[user] raises a rod as a lance!", "You raise the rod into jousting position.")
				S.joustingTool = src
		else if (locate(/obj/grille, user.loc))
			for(var/obj/grille/G in user.loc)
				if (G.ruined)
					G.health = G.health_max
					G.set_density(1)
					G.ruined = 0
					G.UpdateIcon()
					if(src.material)
						G.setMaterial(src.material)
					boutput(user, "<span class='notice'>You repair the broken grille.</span>")
					src.change_stack_amount(-1)
				else
					boutput(user, "<span class='alert'>There is already a grille here.</span>")
				break
		else
			if (src.amount < 2)
				boutput(user, "<span class='alert'>You need at least two rods to build a grille.</span>")
				return
			user.visible_message("<span class='notice'><b>[user]</b> begins building a grille.</span>")
			SETUP_GENERIC_ACTIONBAR(user, src, 1.5 SECONDS, /obj/item/rods/proc/build_grille, list(user), src.icon, src.icon_state, null, INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ATTACKED | INTERRUPT_STUNNED | INTERRUPT_ACTION)
		src.add_fingerprint(user)
		return

	proc/build_grille(mob/user)
		if (src.amount >= 2)
			var/atom/A = new /obj/grille(user.loc)
			A.setMaterial(src.material)
			src.change_stack_amount(-2)
			logTheThing(LOG_STATION, user, "builds a grille (<b>Material:</b> [A.material?.mat_id || "*UNKNOWN*"]) at [log_loc(user)].")
			A.add_fingerprint(user)

/obj/head_on_spike
	name = "head on a spike"
	desc = "A human head impaled on a spike, dim-eyed, grinning faintly, blood blackening between the teeth."
	icon = 'icons/obj/metal.dmi'
	icon_state = "head_spike"
	anchored = UNANCHORED
	density = 1
	var/list/heads = list()
	var/head_offset = 0 //so the ones at the botton don't teleport upwards when a head is removed
	var/bloodiness = 0 //

	New()
		..()
		SPAWN(0) //wait for the head to be added
			update()

	attack_hand(mob/user)
		if(length(heads))
			var/obj/item/organ/head/head = heads[length(heads)]

			user.visible_message("<span class='alert'><B>[user.name] pulls [head.name] off of the spike!</B></span>")
			head.set_loc(user.loc)
			head.Attackhand(user)
			head.add_fingerprint(user)
			head.pixel_x = rand(-8,8)
			head.pixel_y = rand(-8,8)
			heads -= head

			if(!length(heads))
				head_offset = 0
			else
				head_offset++

			src.update()
		else
			..(user)

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W))
			if(!src.anchored && !istype(src.loc,/turf/simulated/floor) && !istype(src.loc,/turf/unsimulated/floor))
				boutput(user, "<span class='alert'>There's nothing to weld that to.</span>")
				return

			if(!W:try_weld(user, 1))
				return

			if(!src.anchored) user.visible_message("<span class='alert'><B>[user.name] welds the [src.name] to the floor.</B></span>")
			else user.visible_message("<span class='alert'><B>[user.name] cuts the [src.name] free from the floor.</B></span>")
			src.anchored = !(src.anchored)

			update()

		else if (istype(W,/obj/item/organ/head))
			if(!has_space())
				boutput(user, "<span class='alert'>There isn't room on that spike for another head.</span>")
				return

			if(!length(heads)) user.visible_message("<span class='alert'><B>[user.name] impales a [W.name] on the [src.name]!</B></span>")
			else user.visible_message("<span class='alert'><B>[user.name] adds a [W.name] to the spike!</B></span>")

			if(head_offset > 0) head_offset--

			heads += W
			user.u_equip(W)
			W.set_loc(src)

			src.update()

		return

	proc/update()
		src.overlays = null

		if((length(heads) < 3 && head_offset > 0) || length(heads) == 0)
			src.overlays += image('icons/obj/metal.dmi',"head_spike_blood")

		switch(length(heads)) //fuck it
			if(0)
				src.name = "bloody spike"
				src.desc = "A bloody spike."
			if(1)
				/*	This shit doesn't work ugh
				src.name = "[heads[1]:donor] on a spike"*/
				var/obj/item/organ/head/head1 = heads[1]
				src.name = "[head1.name] on a spike"
				src.desc = "A human head impaled on a spike, dim-eyed, grinning faintly, blood blackening between the teeth."
			if(2)
				src.name = "heads on a spike"
				var/obj/item/organ/head/head1 = heads[1]
				var/obj/item/organ/head/head2 = heads[2]
				src.desc = "The heads of [head1.donor_original] and [head2.donor_original] impaled on a spike."
				/*	This shit doesn't work ugh
				src.desc = "The heads of [heads[1]:donor] and [heads[2]:donor] impaled on a spike."*/
			if(3)
				src.name = "heads on a spike"
				var/obj/item/organ/head/head1 = heads[1]
				var/obj/item/organ/head/head2 = heads[2]
				var/obj/item/organ/head/head3 = heads[3]
				src.desc = "The heads of [head1.donor_original], [head2.donor_original] and [head3.donor_original] impaled on a spike."
				/*	This shit doesn't work ugh
				src.desc = "The heads of [heads[1]:donor], [heads[2]:donor] and [heads[3]:donor] impaled on a spike."*/


		if(length(heads) > 0)
			var/pixely = 8 - 8*head_offset - 8*length(heads)
			for(var/obj/item/organ/head/H in heads)
				H.pixel_x = 0
				H.pixel_y = pixely
				pixely += 8
				H.set_dir(SOUTH)
				src.overlays += H

			src.overlays += image('icons/obj/metal.dmi',"head_spike_flies")

		if(anchored)
			src.overlays += image('icons/obj/metal.dmi',"head_spike_weld")


	proc/has_space()
		if(length(heads) < 3) return 1

		return 0

	custom_suicide = 1
	suicide(var/mob/living/carbon/human/user as mob)
		if (!istype(user) || !src.user_can_suicide(user))
			return 0
		if (!src.has_space() || !user.organHolder)//!hasvar(user,"organHolder")) STOP USING HASVAR YOU UTTER FUCKWITS
			return 0

		user.visible_message("<span class='alert'><b>[user] headbutts the spike, impaling [his_or_her(user)] head on it!</b></span>")
		user.TakeDamage("head", 50, 0)
		user.changeStatus("stunned", 50 SECONDS)
		playsound(src.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1)
		if(prob(40)) user.emote("scream")

		SPAWN(1 SECOND)
			user.visible_message("<span class='alert'><b>[user] tears [his_or_her(user)] body away from the spike, leaving [his_or_her(user)] head behind!</b></span>")
			var/obj/head = user.organHolder.drop_organ("head")
			head.set_loc(src)
			heads += head
			src.update()
			make_cleanable( /obj/decal/cleanable/blood,user.loc)
			playsound(src.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)

		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0

		return 1


/obj/item/rods/steel

	New()
		..()
		var/datum/material/M = getMaterial("steel")
		src.setMaterial(M)

// TILES

/obj/item/tile
	name = "floor tile"
	desc = "They keep the floor in a good and walkable condition."
	icon = 'icons/obj/metal.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "tile_5"
	item_state = "tile"
	health = 2
	w_class = W_CLASS_NORMAL
	m_amt = 937.5
	throw_speed = 3
	throw_range = 20
	force = 6
	throwforce = 5
	max_stack = 80
	stamina_damage = 25
	stamina_cost = 15
	stamina_crit_chance = 15
	tooltip_flags = REBUILD_DIST
	inventory_counter_enabled = 1
	material_amt = 0.025

	New(make_amount = 0)
		..()
		src.pixel_x = rand(0, 14)
		src.pixel_y = rand(0, 14)
		SPAWN(0)
			UpdateStackAppearance()
			src.inventory_counter?.update_number(amount)
		return

	check_valid_stack(atom/movable/O as obj)
		if (!istype(O,/obj/item/tile/))
			return 0
		var/obj/item/tile/S = O
		if (!S.material || !src.material)
			return 0
		if (!isSameMaterial(S.material, src.material))
			return 0
		return 1

	_update_stack_appearance()
		if (amount <= 10)
			icon_state = "tile_1"
		else if (amount <= 20)
			icon_state = "tile_2"
		else if (amount <= 30)
			icon_state = "tile_3"
		else if (amount <= 40)
			icon_state = "tile_4"
		else if (amount <= 50)
			icon_state = "tile_5"
		else if (amount <= 60)
			icon_state = "tile_6"
		else if (amount <= 70)
			icon_state = "tile_7"
		else
			icon_state = "tile_8"

	get_desc(dist)
		if (dist <= 3)
			. += "<br>There are [src.amount] tile[s_es(src.amount)] left on the stack."

	attack_hand(mob/user)

		if ((user.r_hand == src || user.l_hand == src))
			src.add_fingerprint(user)
			var/obj/item/tile/F = split_stack(1)
			if (!istype(F))
				return
			tooltip_rebuild = 1
			user.put_in_hand_or_drop(F)
		else
			..()
		return

	attack_self(mob/user as mob)

		if (user.stat)
			return
		var/T = user.loc
		if (!( istype(T, /turf) ))
			boutput(user, "<span class='notice'>You must be on the ground!</span>")
			return
		else
			var/S = T
			if (!( istype(S, /turf/space) || istype(S, /turf/simulated/floor/metalfoam) || istype(S, /turf/simulated/floor/plating/airless/asteroid)))
				// If this isn't space, metal foam, or an asteroid...
				if (istype(T, /turf/simulated/floor))
					// If it's still a floor, attempt to place or replace the floor tile
					var/turf/simulated/floor/F = T
					F.attackby(src, user)
					tooltip_rebuild = 1
				else
					boutput(user, "You cannot build on or repair this turf!")
					return
			else
				// Otherwise, try to build on top of it
				src.build(S)
				tooltip_rebuild = 1
		src.add_fingerprint(user)
		return

	attackby(obj/item/tile/W, mob/user)

		if (!( istype(W, /obj/item/tile) ))
			return
		if (W.material && src.material && !isSameMaterial(W.material, src.material))
			boutput(user, "<span class='alert'>You can't mix two stacks of different materials!</span>")
			return
		var/inMagtractor = istype(W.loc, /obj/item/magtractor)
		var/success = stack_item(W)
		if (!success)
			boutput(user, "<span class='alert'>You can't put any more tiles in this stack!</span>")
			return
		if(!(user.is_in_hands(src) || inMagtractor))
			user.put_in_hand(src)
		if(issilicon(user))
			boutput(user, "<span class='notice'>You add [success] tiles to the stack. It now has [W.amount] tiles.</span>")
		else
			boutput(user, "<span class='notice'>You add [success] tiles to the stack. It now has [src.amount] tiles.</span>")
		tooltip_rebuild = 1
		if (!W.disposed)
			W.add_fingerprint(user)
			W.tooltip_rebuild = 1
		return

	before_stack(atom/movable/O as obj, mob/user as mob)
		user.visible_message("<span class='notice'>[user] begins stacking [src]!</span>")

	after_stack(atom/movable/O as obj, mob/user as mob, var/added)
		boutput(user, "<span class='notice'>You finish stacking tiles.</span>")

	proc/build(turf/S as turf)
//for now, any turf can't be built on.
#if defined(MAP_OVERRIDE_POD_WARS)
		boutput(usr, "you can't build in this mode, you don't know how or something...")
		return
#else
		if (src.amount < 1)
			return FALSE
		var/turf/simulated/floor/W = S.ReplaceWithFloor()
		if (W) //Wire: Fix for: Cannot read null.icon_old
			W.inherit_area()
			if (!W.icon_old)
				W.icon_old = "floor"
			W.to_plating()

		if(ismob(usr) && !istype(src.material, /datum/material/metal/steel))
			logTheThing(LOG_STATION, usr, "constructs a floor (<b>Material:</b>: [src.material && src.material.name ? "[src.material.name]" : "*UNKNOWN*"]) at [log_loc(S)].")
		if(src.material)
			W.setMaterial(src.material)
		src.change_stack_amount(-1)
		return TRUE
#endif

/obj/item/tile/steel

	New()
		..()
		var/datum/material/M = getMaterial("steel")
		src.setMaterial(M)

/obj/item/tile/cardboard // for drones
	desc = "They keep the floor in a good and walkable condition. At least, they would if they were actually made of steel."
	force = 0
	New()
		..()
		var/datum/material/M = getMaterial("cardboard")

		src.setMaterial(M)

/obj/item/sheet/electrum
	New()
		..()
		setMaterial(getMaterial("electrum"))

	change_stack_amount(var/use_amount)
		if (!isnum(use_amount))
			return
		if (isrobot(usr))
			var/mob/living/silicon/robot/R = usr
			R.cell.use(use_amount * 200)

// kinda needed for some stuff I'm making - haine
/obj/item/sheet/steel/fullstack
	amount = 50
/obj/item/sheet/steel/reinforced/fullstack
	amount = 50
/obj/item/sheet/glass/fullstack
	amount = 50
/obj/item/sheet/glass/reinforced/fullstack
	amount = 50
/obj/item/sheet/glass/crystal/fullstack
	amount = 50
/obj/item/sheet/glass/crystal/reinforced/fullstack
	amount = 50
/obj/item/rods/steel/fullstack
	amount = 50
/obj/item/tile/steel/fullstack
	amount = 80
/obj/item/tile/cardboard/fullstack
	amount = 100


ABSTRACT_TYPE(/datum/sheet_crafting_recipe)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/reinforced_metal)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/metal)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/glass)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/cardboard)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/wood)
/datum/sheet_crafting_recipe
	var/recipe_id //The ID of the recipe, used for TGUI act()s
	var/name
	var/sheet_cost = 1
	var/yield = 1
	var/can_craft_multiples = FALSE
	var/icon
	var/icon_state
	var/craftedType //The type of item the recipe will build

	reinforced_metal
		retable
			recipe_id = "retable"
			craftedType = /obj/item/furniture_parts/table/reinforced
			name = "Reinforced Table Parts"
			sheet_cost = 2
			icon = 'icons/obj/furniture/table_reinforced.dmi'
			icon_state = "table_parts"
		industrialtable
			recipe_id = "industrialtable"
			craftedType = /obj/item/furniture_parts/table/reinforced/industrial
			name = "Industrial Table Parts"
			sheet_cost = 2
			icon = 'icons/obj/furniture/table_industrial.dmi'
			icon_state = "table_parts"

	metal
		fl_tiles
			recipe_id = "fl_tiles"
			craftedType = /obj/item/tile
			name = "Floor Tile"
			yield = 4
			can_craft_multiples = TRUE
			icon = 'icons/obj/metal.dmi'
			icon_state = "tile_5"
		rods
			recipe_id = "rods"
			craftedType =  /obj/item/rods
			name = "Rods"
			yield = 2
			can_craft_multiples = TRUE
			icon = 'icons/obj/metal.dmi'
			icon_state = "rods_5"

		rack
			recipe_id = "rack"
			craftedType = /obj/item/furniture_parts/rack
			name = "Rack Parts"
			icon = 'icons/obj/metal.dmi'
			icon_state = "rack_base_parts"
		railing
			recipe_id = "railing"
			craftedType = /obj/railing
			name = "Railing"
			icon = 'icons/obj/objects.dmi'
			icon_state = "railing"
		stool
			recipe_id = "stool"
			craftedType = /obj/stool
			name = "Stool"
			icon = 'icons/obj/furniture/chairs.dmi'
			icon_state = "stool"
		chair
			recipe_id = "chair"
			craftedType = /obj/stool/chair
			name = "Chair"
			icon = 'icons/obj/furniture/chairs.dmi'
			icon_state = "chair"

		table
			recipe_id = "table"
			craftedType = /obj/item/furniture_parts/table
			name = "Table Parts"
			sheet_cost = 2
			icon = 'icons/obj/furniture/table.dmi'
			icon_state = "table_parts"
		light
			recipe_id = "light"
			craftedType = /obj/item/light_parts
			name = "Light Fixture Parts, Tube"
			sheet_cost = 2
			icon = 'icons/obj/lighting.dmi'
			icon_state = "tube-fixture"
		light2
			recipe_id = "light2"
			craftedType = /obj/item/light_parts/bulb
			name = "Light Fixture Parts, Bulb"
			sheet_cost = 2
			icon = 'icons/obj/lighting.dmi'
			icon_state = "bulb-fixture"
		light3
			recipe_id = "light3"
			craftedType = /obj/item/light_parts/floor
			name = "Light Fixture Parts, Floor"
			sheet_cost = 2
			icon = 'icons/obj/lighting.dmi'
			icon_state = "floor-fixture"
		bed
			recipe_id = "bed"
			craftedType = /obj/stool/bed
			name = "Bed"
			sheet_cost = 2
			icon = 'icons/obj/furniture/chairs.dmi'
			icon_state = "bed"
		closet
			recipe_id = "closet"
			craftedType = /obj/storage/closet
			name = "Closet"
			sheet_cost = 2
			icon = 'icons/obj/large_storage.dmi'
			icon_state = "closed"
		construct
			recipe_id = "construct"
			craftedType = /obj/structure/girder
			name = "Wall Girders"
			sheet_cost = 2
			icon = 'icons/obj/structures.dmi'
			icon_state = "girder"

		pipef
			recipe_id = "pipef"
			craftedType = /obj/item/pipebomb/frame
			name = "Pipe Frame"
			sheet_cost = 3
			icon = 'icons/obj/items/assemblies.dmi'
			icon_state = "Pipe_Frame"
		tcomputer
			recipe_id = "tcomputer"
			craftedType = /obj/computer3frame/terminal
			name = "Computer Terminal Frame"
			sheet_cost = 3
			icon = 'icons/obj/terminal_frame.dmi'
			icon_state = "0"
		computer
			recipe_id = "computer"
			craftedType = /obj/computerframe
			name = "Console Frame"
			sheet_cost = 5
			icon = 'icons/obj/computer_frame.dmi'
			icon_state = "0"
		hcomputer
			recipe_id = "hcomputer"
			craftedType = /obj/computer3frame
			name = "Computer Frame"
			sheet_cost = 5
			icon = 'icons/obj/computer_frame.dmi'
			icon_state = "0"
		vending
			recipe_id = "vending"
			craftedType = /obj/machinery/vendingframe
			name = "Vending Machine Frame"
			sheet_cost = 3
			icon = 'icons/obj/vending.dmi'
			icon_state = "standard-frame"

	glass
		smallwindow
			recipe_id = "smallwindow"
			name = "Thin Window"
			icon = 'icons/obj/window.dmi'
			icon_state = "window"
		bigwindow
			recipe_id = "bigwindow"
			name = "Large Window"
			sheet_cost = 2
			icon = 'icons/obj/window.dmi'
			icon_state = "window"
		displaycase
			recipe_id = "displaycase"
			craftedType = /obj/displaycase
			name = "Display Case"
			sheet_cost = 3
			icon = 'icons/obj/stationobjs.dmi'
			icon_state = "glassbox0"

	cardboard
		c_box
			recipe_id = "c_box"
			craftedType = /obj/item/clothing/suit/cardboard_box
			name = "Cardboard Box"
			sheet_cost = 2
			icon = 'icons/obj/clothing/overcoats/item_suit_cardboard.dmi'
			icon_state = "c_box"

	//Used for both reinforced metal and glass
	remetal
		recipe_id = "remetal"
		name = "Remove Reinforcement"
		icon = 'icons/obj/metal.dmi'
		icon_state = "sheet-m_5"
		can_craft_multiples = TRUE

		glass
			icon_state = "sheet-g_5"

	wood
		fl_tiles
			recipe_id = "fl_tiles_wood"
			craftedType = /obj/item/tile
			name = "Floor Tile"
			yield = 4
			can_craft_multiples = TRUE
			icon = 'icons/obj/metal.dmi'
			icon_state = "tile_5"
		stool
			recipe_id = "wood_stool"
			craftedType = /obj/stool/wooden/constructed
			name = "Stool"
			icon = 'icons/obj/furniture/chairs.dmi'
			icon_state = "wstool"
		chair
			recipe_id = "wood_chair"
			craftedType = /obj/stool/chair/wooden/constructed
			name = "Chair"
			icon = 'icons/obj/furniture/chairs.dmi'
			icon_state = "chair_wooden"
		table
			recipe_id = "wood_table"
			craftedType = /obj/item/furniture_parts/table/wood
			name = "Table Parts"
			sheet_cost = 2
			icon = 'icons/obj/furniture/table_wood.dmi'
			icon_state = "table_parts"
		dresser
			recipe_id = "wood_dresser"
			craftedType = /obj/storage/closet/dresser
			name = "dresser"
			sheet_cost = 2
			icon = 'icons/obj/large_storage.dmi'
			icon_state = "dresser"
		coffin
			recipe_id = "coffin"
			craftedType = /obj/storage/closet/coffin
			name = "coffin"
			sheet_cost = 2
			icon = 'icons/obj/large_storage.dmi'
			icon_state = "coffin"
		construct
			recipe_id = "wood_construct"
			craftedType = /obj/structure/girder
			name = "Wall Girders"
			sheet_cost = 2
			icon = 'icons/obj/structures.dmi'
			icon_state = "girder$$wood"
		barricade
			recipe_id = "barricade"
			craftedType = /obj/structure/woodwall
			name = "Barricade"
			sheet_cost = 5
			icon = 'icons/obj/structures.dmi'
			icon_state = "woodwall"
		wood_door
			recipe_id = "wood_door"
			craftedType = /obj/machinery/door/unpowered/wood
			name = "Door"
			sheet_cost = 3
			icon = 'icons/obj/doors/door_wood.dmi'
			icon_state = "door1"
		bookshelf
			recipe_id = "bookshelf"
			craftedType = /obj/bookshelf
			name = "Bookshelf"
			sheet_cost = 5
			icon = 'icons/obj/furniture/bookshelf.dmi'
			icon_state = "bookshelf_small"
		wood_double_door
			recipe_id = "wood_double_door"
			craftedType = /obj/machinery/door/unpowered/wood/pyro
			name = "Double Door"
			sheet_cost = 6
			icon = 'icons/obj/doors/SL_doors.dmi'
			icon_state = "wood1"


/proc/sheet_crafting_recipe_get_ui_data(var/recipePath)
	var/datum/sheet_crafting_recipe/typedRecipePath = recipePath
	. = list(list(
		"recipeID" = initial(typedRecipePath.recipe_id),
		"name" = initial(typedRecipePath.name),
		"sheetCost" = initial(typedRecipePath.sheet_cost),
		"itemYield" = initial(typedRecipePath.yield),
		"canCraftMultiples" = initial(typedRecipePath.can_craft_multiples),
		"img" = sheet_crafting_recipe_getBase64Img(initial(typedRecipePath.recipe_id), initial(typedRecipePath.icon), initial(typedRecipePath.icon_state))
	))

/proc/sheet_crafting_recipe_getBase64Img(var/recipeID, var/icon, var/icon_state)
	var/static/base64_preview_cache = list() // Base64 preview images for item types, for use in ui interfaces.

	. = base64_preview_cache[recipeID]
	if(isnull(.))
		var/dir = SOUTH
		if (recipeID == "bigwindow")
			dir = 5 //full tile

		var/icon/result_icon = icon(icon, icon_state, dir)

		if(result_icon)
			. = icon2base64(result_icon)
		else
			. = "" // Empty but not null
		base64_preview_cache[recipeID] = .
