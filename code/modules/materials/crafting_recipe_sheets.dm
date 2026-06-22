

/obj/item/sheet/ui_act(action, params)
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
		boutput(usr, SPAN_ALERT("What are you gonna do with this? You have a very particular set of skills, and building is not one of them..."))
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
				if(rodsinput < 1 || !isnum_safe(rodsinput))
					return
				rodsinput = min(rodsinput,makerods)

				if (!in_interact_range(src, usr)) //no walking away
					return
				currentRecipe = /datum/sheet_crafting_recipe/unreinforced/rods
				a_amount = rodsinput * initial(currentRecipe.yield)
				a_cost = rodsinput * initial(currentRecipe.sheet_cost)

			if("fl_tiles")
				var/maketiles = min(src.amount,20)
				var/tileinput = input("Use how many sheets? (Get 4 tiles for each sheet used)","Max: [maketiles]",1) as num
				if (tileinput < 1 || !isnum_safe(tileinput))
					return
				tileinput = min(tileinput,maketiles)

				if (!in_interact_range(src, usr)) //no walking away
					return
				currentRecipe = /datum/sheet_crafting_recipe/unreinforced/fl_tiles
				a_amount = tileinput * initial(currentRecipe.yield)
				a_cost = tileinput * initial(currentRecipe.sheet_cost)

			if("construct")
				var/turf/T = get_turf(usr)
				var/area/A = get_area (usr)
				if (!(istype(T, /turf/simulated/floor) || istype(T, /turf/simulated/space_phoenix_ice_tunnel)))
					boutput(usr, SPAN_ALERT("You can't build girders here."))
					return
				if (istype(A, /area/supply/spawn_point || /area/supply/sell_point))
					boutput(usr, SPAN_ALERT("You can't build girders here."))
					return
				if (!amount_check(2,usr))
					return
				currentRecipe = /datum/sheet_crafting_recipe/unreinforced/metal/construct

			if ("barricade","zbarricade")
				var/turf/T = get_turf(usr)
				if (!istype(T, /turf/simulated/floor) || locate(/obj/structure/woodwall) in T.contents)
					boutput(usr,SPAN_ALERT("You can't build that here."))
					return
				if (params["recipeID"] == "barricade")
					currentRecipe = /datum/sheet_crafting_recipe/unreinforced/wood/barricade
				else
					currentRecipe = /datum/sheet_crafting_recipe/unreinforced/wood/zbarricade

			if("smallwindow")
				for (var/obj/window/window in get_turf(src))
					//the same direction thindow or a full window
					if (window.dir == usr.dir || !(window.dir in cardinal))
						return
				if (src.reinforcement)
					a_type = map_settings ? map_settings.rwindows_thin : /obj/window/reinforced
				else
					a_type = map_settings ? map_settings.windows_thin : /obj/window
				currentRecipe = /datum/sheet_crafting_recipe/unreinforced/glass/smallwindow
				a_callback = /proc/window_reinforce_callback

			if("bigwindow")
				if (locate(/obj/window) in get_turf(usr))
					return
				if (!amount_check(2,usr))
					return
				if (src.reinforcement)
					a_type = map_settings ? map_settings.rwindows : /obj/window/reinforced
				else
					a_type = map_settings ? map_settings.windows : /obj/window
				currentRecipe = /datum/sheet_crafting_recipe/unreinforced/glass/bigwindow
				a_callback = /proc/window_reinforce_full_callback

			if("remetal")
				// what the fuck is this
				var/input = input("Use how many sheets?","Max: [src.amount]",1) as num
				if (input < 1 || !isnum_safe(input))
					return
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
						if (!amount_check(initial(loopedRecipe.sheet_cost),usr))
							return
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
			actions.start(new /datum/action/bar/icon/build(a_type, src.loc, a_amount, 3 SECONDS, src, a_cost, null, null, src.material, initial(currentRecipe.icon), initial(currentRecipe.icon_state), a_callback), usr)
			. = TRUE

	return

/obj/item/sheet/ui_data(mob/user)
	. = list()

	.["availableAmount"] = src.amount
	.["labeledAvailableAmount"] = "[src.amount] [src.name]\s"

	var/list/availableRecipes = list()
	for(var/recipePath in concrete_typesof(/datum/sheet_crafting_recipe))
		var/datum/sheet_crafting_recipe/dummy = new recipePath
		if(dummy.is_craftable(src))
			availableRecipes.Add(sheet_crafting_recipe_get_ui_data(recipePath, src))
	.["itemList"] = availableRecipes

ABSTRACT_TYPE(/datum/sheet_crafting_recipe)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/unreinforced)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/unreinforced/metal)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/unreinforced/glass)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/unreinforced/wood)
ABSTRACT_TYPE(/datum/sheet_crafting_recipe/reinforced)
/datum/sheet_crafting_recipe
	var/recipe_id //The ID of the recipe, used for TGUI act()s
	var/name
	var/sheet_cost = 1
	var/yield = 1
	var/can_craft_multiples = FALSE
	var/icon
	var/icon_state
	var/icon_default_mat = null
	var/craftedType //The type of item the recipe will build
	var/required_mat_flags = 0 // Only requires at least one material type to be built

	proc/is_craftable(var/obj/item/sheet/sheet)
		if(required_mat_flags)
			if((sheet.material.getMaterialFlags() & required_mat_flags) == 0)
				return FALSE
		return TRUE

/datum/sheet_crafting_recipe/unreinforced
	is_craftable(var/obj/item/sheet/sheet)
		if(sheet.reinforcement)
			return FALSE
		if(required_mat_flags)
			if((sheet.material.getMaterialFlags() & required_mat_flags) == 0)
				return FALSE
		return TRUE

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
		icon = 'icons/obj/items/materials/rods.dmi'
		icon_state = "rods_5"
		required_mat_flags = MATERIAL_METAL | MATERIAL_WOOD

/datum/sheet_crafting_recipe/unreinforced/metal
	required_mat_flags = MATERIAL_METAL
	icon_default_mat = "steel"

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
	strip_door
		recipe_id = "strip_door"
		craftedType = /obj/strip_door/constructed
		name = "Strip Door Frame"
		icon = 'icons/obj/stationobjs.dmi'
		icon_state = "strip_door_open"
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
		icon = 'icons/obj/storage/locker.dmi'
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
		name = "Terminal Frame"
		sheet_cost = 3
		icon = 'icons/obj/terminal_frame.dmi'
		icon_state = "0"
	computer
		recipe_id = "computer"
		craftedType = /obj/computerframe
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
	scrap_handle
		recipe_id = "scrap_handle"
		craftedType = /obj/item/scrapweapons/parts/handle
		name = "Scrap Handle"
		sheet_cost = 1
		icon = 'icons/obj/items/scrapweapons.dmi'
		icon_state = "handle"
	scrap_blade
		recipe_id = "scrap_blade"
		craftedType = /obj/item/scrapweapons/parts/blade
		name = "Scrap Blade"
		sheet_cost = 3
		icon = 'icons/obj/items/scrapweapons.dmi'
		icon_state = "blade"
	scrap_shaft
		recipe_id = "scrap_shaft"
		craftedType = /obj/item/scrapweapons/parts/shaft
		name = "Scrap Shaft"
		sheet_cost = 2
		icon = 'icons/obj/items/scrapweapons.dmi'
		icon_state = "shaft"

/datum/sheet_crafting_recipe/unreinforced/glass
	required_mat_flags = MATERIAL_CRYSTAL

	smallwindow
		recipe_id = "smallwindow"
		name = "Thin Window"
		icon = 'icons/obj/window.dmi'
		icon_state = "window"
		required_mat_flags = MATERIAL_CRYSTAL
	bigwindow
		recipe_id = "bigwindow"
		name = "Large Window"
		sheet_cost = 2
		icon = 'icons/obj/window.dmi'
		icon_state = "window"
		required_mat_flags = MATERIAL_CRYSTAL
	displaycase
		recipe_id = "displaycase"
		craftedType = /obj/displaycase
		name = "Display Case"
		sheet_cost = 3
		icon = 'icons/obj/stationobjs.dmi'
		icon_state = "glassbox0"
		required_mat_flags = MATERIAL_CRYSTAL

/datum/sheet_crafting_recipe/unreinforced/wood
	required_mat_flags = MATERIAL_WOOD
	icon_default_mat = "wood"

	c_box
		recipe_id = "c_box"
		craftedType = /obj/item/clothing/suit/cardboard_box
		name = "Cardboard Box"
		sheet_cost = 2
		icon = 'icons/obj/clothing/overcoats/item_suit_cardboard.dmi'
		icon_state = "c_box"
		icon_default_mat = "cardboard"

		is_craftable(var/obj/item/sheet/sheet)
			if(sheet.material.getID() == "cardboard" && sheet.reinforcement == null)
				return TRUE
			return FALSE

	stool
		recipe_id = "wood_stool"
		craftedType = /obj/stool/wooden/constructed
		name = "Stool"
		icon = 'icons/obj/furniture/chairs.dmi'
		icon_state = "wstool"
	chair
		recipe_id = "wood_chair"
		craftedType = /obj/stool/chair/dining/wood/constructed
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
		icon = 'icons/obj/storage/closet.dmi'
		icon_state = "dresser"
	coffin
		recipe_id = "coffin"
		craftedType = /obj/storage/closet/coffin
		name = "coffin"
		sheet_cost = 2
		icon = 'icons/obj/storage/coffin.dmi'
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
	swing_sign
		recipe_id = "swing_sign"
		craftedType = /obj/item/swingsignfolded
		name = "Swing Sign"
		sheet_cost = 2
		icon = 'icons/obj/furniture/swingsign.dmi'
		icon_state = "written"
	zbarricade
		recipe_id = "zbarricade"
		craftedType = /obj/structure/woodwall/anti_zombie
		name = "Zombie Barricade"
		sheet_cost = 5
		icon = 'icons/obj/structures.dmi'
		icon_state = "woodwall"

		is_craftable(var/obj/item/sheet)
			if(istype(sheet, /obj/item/sheet/wood/zwood))
				return TRUE
			return FALSE


/datum/sheet_crafting_recipe/reinforced
	icon_default_mat = "steel"

	is_craftable(var/obj/item/sheet/sheet)
		if(sheet.reinforcement == null)
			return FALSE
		if(required_mat_flags)
			if((sheet.material.getMaterialFlags() & required_mat_flags) == 0)
				return FALSE
		return TRUE

	remove_reinforcement
		recipe_id = "remetal"
		name = "Remove Reinforcement"
		icon = 'icons/obj/items/materials/sheets.dmi'
		icon_state = "metal_1"
		icon_default_mat = null
		can_craft_multiples = TRUE
		required_mat_flags = MATERIAL_METAL

		glass
			icon_state = "glass_1"
			icon_default_mat = null
			required_mat_flags = MATERIAL_CRYSTAL
	retable
		recipe_id = "retable"
		craftedType = /obj/item/furniture_parts/table/reinforced
		name = "Reinforced Table Parts"
		sheet_cost = 2
		icon = 'icons/obj/furniture/table_reinforced.dmi'
		icon_state = "table_parts"
		required_mat_flags = MATERIAL_METAL
	industrialtable
		recipe_id = "industrialtable"
		craftedType = /obj/item/furniture_parts/table/reinforced/industrial
		name = "Industrial Table Parts"
		sheet_cost = 2
		icon = 'icons/obj/furniture/table_industrial.dmi'
		icon_state = "table_parts"
		required_mat_flags = MATERIAL_METAL
	industrialchair
		recipe_id = "industrialchair"
		craftedType = /obj/item/furniture_parts/dining_chair/industrial
		name = "Industrial Chair Parts"
		icon = 'icons/obj/furniture/chairs.dmi'
		icon_state = "ichair_parts"
		required_mat_flags = MATERIAL_METAL

/proc/sheet_crafting_recipe_get_ui_data(var/recipePath, var/obj/item/sheet/sheet)
	var/datum/sheet_crafting_recipe/typedRecipePath = recipePath
	. = list(list(
		"recipeID" = initial(typedRecipePath.recipe_id),
		"name" = initial(typedRecipePath.name),
		"sheetCost" = initial(typedRecipePath.sheet_cost),
		"itemYield" = initial(typedRecipePath.yield),
		"canCraftMultiples" = initial(typedRecipePath.can_craft_multiples),
		"img" = sheet_crafting_recipe_getBase64Img(initial(typedRecipePath.recipe_id), initial(typedRecipePath.icon), initial(typedRecipePath.icon_state), initial(typedRecipePath.icon_default_mat), sheet)
	))
/proc/sheet_crafting_recipe_getBase64Img(var/recipeID, var/icon, var/icon_state, var/icon_default_mat, var/obj/item/sheet/sheet)
	var/static/base64_preview_cache = list() // Base64 preview images for item types, for use in ui interfaces.

	var/preview_cache_id = recipeID
	var/potential_new_icon_state = "[icon_state]$$[sheet.material.getID()]"
	if(sheet.is_valid_icon_state(potential_new_icon_state, icon))
		icon_state = potential_new_icon_state
		preview_cache_id += "$$[sheet.material.getID()]"
	else if(sheet.material.getID() != icon_default_mat)
		preview_cache_id += "$$[sheet.material.getID()]"

	. = base64_preview_cache[preview_cache_id]
	if(isnull(.))
		var/dir = SOUTH
		if (recipeID == "bigwindow")
			dir = NORTHEAST //full tile
		var/icon/result_icon = icon(icon, icon_state, dir)
		if(result_icon)
			. = icon2base64(result_icon)
		else
			. = "" // Empty but not null
		base64_preview_cache[preview_cache_id] = .
