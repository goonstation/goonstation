//oven power settings
#define OVEN_LOW "Low"
#define OVEN_HIGH "High"

ABSTRACT_TYPE(/obj/machinery/cookingmachine)
/obj/machinery/cookingmachine
	name = "nondescript culinary appliance"
	desc = "You shouldn't be able to see this!"
	icon = 'icons/obj/kitchen.dmi'
	anchored = ANCHORED
	density = 1
	flags = NOSPLASH | TGUI_INTERACTIVE
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

	var/power_active ///power usage while active
	var/max_contents //max amount of items allowed inside
	var/cooktime //time it takes to cook something. on ovens this is adjustable
	var/list/datum/cookingrecipe/possible_recipes //list of all recipes that can possibly be cooked from the contained ingredients
	var/list/to_remove = list() //items being used in the current recipe
	var/list/allowed = list(/obj/item)
	var/working = FALSE
	var/time_finish

	attack_hand(var/mob/user)
		if (isghostdrone(user))
			boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
			return
		src.ui_interact(user)

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
		if (isghostdrone(user))
			boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
			return
		if (W.cant_drop) //For borg held items
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return
		if(W.w_class > W_CLASS_BULKY)
			boutput(user, SPAN_ALERT("[W] is far too large and unwieldly to fit in [src]!"))
			return
		if (istype(W, /obj/item/grab) || istype(W, /obj/item/card/emag))
			..()
			return
		if (src.working)
			boutput(user, SPAN_ALERT("It's already on! Putting a new thing in could result in a collapse of the cooking waveform into a really lousy eigenstate, like a vending machine chili dog."))
			return
		if (length(src.contents) >= src.max_contents)
			boutput(user, SPAN_ALERT("\The [src] cannot hold any more items."))
			return
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (!proceed)
			boutput(user, SPAN_ALERT("You can't put that in [src]!"))
			return
		user.visible_message(SPAN_NOTICE("[user] loads [W] into [src]."))
		src.load_item(W, user)
		src.update_icon() //for subtypes that have a filled iconstate
		src.ui_interact(user)

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && W.w_class <= W_CLASS_HUGE && !W.anchored && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	process()
		. = ..()
		if (status & (NOPOWER|BROKEN))
			UnsubscribeProcess()
			return

		var/amount = length(src.contents)
		if (!amount)
			UnsubscribeProcess()
			return

		if (TIME < src.time_finish)
			return

		var/obj/item/F = src.cook_item()
		F.set_loc(src.loc)

		src.handle_leftovers

		src.working = 0
		src.UpdateIcon()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		tgui_process.update_uis(src)

		src.power_usage = 0
		UnsubscribeProcess()
		return

	proc/get_valid_recipe()
		for (var/datum/cookingrecipe/R in src.possible_recipes)
			src.to_remove.len = 0
			if (src.can_cook_recipe(R))
				return R
		return null

	proc/can_cook_recipe(datum/cookingrecipe/recipe)
		for(var/I in recipe.ingredients)
			if (!check_item(I, recipe.ingredients[I])) return FALSE

		return TRUE

	proc/check_item(var/recipeitem, var/recipecount)
		if (!locate(recipeitem) in src.contents) return FALSE
		var/count = 0
		for(var/obj/item/I in src.contents)
			if(istype(I, recipeitem))
				count++
				to_remove += I
				(count >= recipecount)
					return TRUE
		return FALSE

	proc/load_item(obj/item/ingredient, mob/user)
		if(!locate(ingredient.type) in src.contents)
			src.possible_recipes += src.get_recipes_from_ingredient(ingredient)
		user.u_equip(ingredient)
		ingredient.set_loc(src)
		ingredient.dropped(user)

	proc/eject_item(obj/item/ingredient)
		if (ingredient)
			if (BOUNDS_DIST(usr, src) == 0)
				usr.put_in_hand_or_drop(ingredient)
			else
				ingredient.set_loc(src.loc)
			if(!locate(ingredient.type) in src.contents)
				src.possible_recipes -= src.get_recipes_from_ingredient(ingredient)

	proc/get_recipes_from_ingredient(obj/item/ingredient)
		var/considered_type = ingredient.type
		while(considered_type != /obj/item && considered_type != /obj/item/reagent_containers/food/snacks/ingredient)
			if(oven_recipes_by_ingredient[considered_type])
				var/output = oven_recipes_by_ingredient[considered_type] //bit of a hack, remember to change when cooking flags are added
				if(oven_recipes_by_ingredient[considered_type.parent_type])
					output += oven_recipes_by_ingredient[considered_type.parent_type] //this ensures the more specific recipes are checked first
				return output
			else
				considered_type = considered_type.parent_type
		return

	proc/cooking_power() //used to find cook amounts on
		return cooktime/10

	proc/start_cook()
		if (!length(src.contents))
			boutput(usr, SPAN_ALERT("There's nothing in [src]."))
			return
		src.working = 1
		src.time_finish = TIME + src.cooktime
		src.power_usage = src.power_active
		tgui_process.update_uis(src)
		src.UpdateIcon()
		SubscribeToProcess()

	/// Called when the machine finishes cooking
	proc/finish_cook()
		var/obj/item/output = null
		var/quality = null
		var/cook_amount = src.cooking_power()
		var/datum/cookingrecipe/R = src.get_valid_recipe()
		var/obj/item/food/snacks/F
		if (R)
			// this is null if it uses normal outputs (see below),
			// otherwise it will be the created item from this
			output = R.specialOutput(src)
			if (isnull(output))
				output = new R.output
			if(R.cookbonus)
				recipebonus = R.cookbonus
				if (abs(cook_amount - R.cookbonus) <= 1)
					// if -1, 0, or 1, you did ok
					output.quality = 5
				else if (cook_amount >= R.cookbonus + 5)
					// you burned it
					output = new /obj/item/reagent_containers/food/snacks/yuck/burn
					output.quality = 0
				else// mediocre meals
					output.quality = clamp(5 - abs(R.cookbonus - cook_amount), 0, 5)
			if(R.useshumanmeat)
				var/obj/item/reagent_containers/food/snacks/F = output
				var/foodname = F.name
				for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in src.contents)
					F.name = "[M.subjectname] [foodname]"
					F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
					if(!isnull(F.unlock_medal_when_eaten))
						continue
					else if (M.subjectjob && M.subjectjob == "Clown")
						F.unlock_medal_when_eaten = "That tasted funny"
					else
						F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method

			// the case where there are no valid recipies is handled below in the outer context
			// (namely it replaces them with yuck)
		if (isnull(output))
			output = new /obj/item/reagent_containers/food/snacks/yuck
			output.quality = rand(-5, 1) //small chance of being actually edible
		// this only happens if the output is a yuck item, either from an
		// invalid recipe or otherwise...
		for (var/obj/item/I in to_remove)
			qdel(I)
		to_remove.len = 0
		handle_leftovers()
		possible_recipes.len = 0
		return output

	proc/handle_leftovers() ///what to do with things that weren't part of the recipe
		for(obj/item/I in src.contents)
			qdel(I)

TYPEINFO(/obj/machinery/cookingmachine/oven)
	mats = 18

/obj/machinery/cookingmachine/oven
	name = "oven"
	desc = "A multi-cooking unit featuring a hob, grill, oven and more."
	icon_state = "oven_off"
	object_flags = NO_GHOSTCRITTER
	cooktime = 5 SECONDS
	var/emagged = TRUE
	var/heat = OVEN_LOW
	var/static/tmp/recipe_html = null // see: create_oven_recipe_html()
	var/icon_idle = "oven_off"
	var/icon_active = "oven_bake"

	//these are for recipe previews
	var/list/possible_recipe_icons = list()
	var/list/possible_recipe_names = list()
	var/output_icon
	var/output_name
	var/output_time

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!emagged)
			emagged = TRUE
			if (user)
				boutput(user, SPAN_NOTICE("[src] produces a strange grinding noise."))
			return TRUE
		else
			return FALSE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Oven")
			ui.open()

	ui_data(mob/user)
		src.get_recipes()
		. = list(
			"time" = src.time,
			"heat" = src.heat,
			"cooking" = src.working,
			"content_icons" = src.get_content_icons(),
			"content_names" = src.get_content_names(),
			"recipe_icons" = src.possible_recipe_icons,
			"recipe_names" = src.possible_recipe_names,
			"output_icon" = src.output_icon,
			"output_name" = src.output_name,
			"cook_time" = src.output_time
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		. = TRUE
		switch (action)
			if ("set_time")
				src.cooktime = params["time"] SECONDS
			if ("set_heat")
				src.heat = params["heat"]
			if ("start")
				src.start_cook()
			if ("eject_all")
				for (var/obj/item/I in src.contents)
					src.eject_item(I)
			if ("eject")
				var/obj/item/thing_to_eject = src.contents[params["ejected_item"]]
				if (thing_to_eject)
					src.eject_item(I)
			if ("open_recipe_book")
				usr.Browse(recipe_html, "window=recipes;size=500x700")

	proc/get_content_icons()
		if (!length(src.contents))
			return
		var/list/contained = list()
		for (var/obj/item/I in src.contents)
			contained += icon2base64(getFlatIcon(I), "chef_oven-\ref[src]")
		return contained

	proc/get_content_names()
		if (!length(src.contents))
			return
		var/list/contained = list()
		for (var/obj/item/I in src.contents)
			contained += I.name
		return contained

	proc/get_recipes()
		src.possible_recipe_icons = list()
		src.possible_recipe_names = list()
		src.output_icon = null
		src.output_name = null
		src.output_time = null

		var/datum/cookingrecipe/possible = src.get_valid_recipe()
		if (!possible)
			return

		for(var/I in possible.ingredients)
			var/atom/item_path = I
			src.possible_recipe_icons += icon2base64(icon(initial(item_path.icon), initial(item_path.icon_state)), "chef_oven-\ref[src]")
			src.possible_recipe_names += "[initial(item_path.name)][possible.ingredients[I] > 1 ? " x[possible.ingredients[I]]" : ""]"

		if (ispath(possible.output))
			var/atom/item_path = possible.output
			src.output_icon = icon2base64(icon(initial(item_path.icon), initial(item_path.icon_state)), "chef_oven-\ref[src]")
			src.output_name = initial(item_path.name)

		if (possible.cookbonus < 10)
			src.output_time = "[possible.cookbonus] seconds low"
		else
			src.output_time = "[floor(possible.cookbonus/2)] seconds high"

	cooking_power()
		return src.cooktime / 10 * (src.heat == OVEN_HIGH ? 2 : 1)

	finish_cook()
		// If emagged produce random output.
		if (emagged)
			var/obj/item/output
			// Enforce GIGO and prevent infinite reuse
			var/contentsok = FALSE
			for(var/obj/item/I in src.contents)
				if(istype(I, /obj/item/reagent_containers/food/snacks/yuck))
					contentsok = FALSE
					break
				if(istype(I, /obj/item/reagent_containers/food))
					var/obj/item/reagent_containers/food/F = I
					if (F.from_emagged_oven) // hyphz checked heal_amt but I think this custom var is a nicer solution (also I'm not sure that valid food not from an emagged oven will never have a heal_amt of 0 (because I am lazy and don't want to read the code))
						contentsok = FALSE
						break
				// Pick a random recipe
			var/datum/cookingrecipe/xrecipe = pick(src.recipes)
			var/xrecipeok = TRUE
			// Don't choose recipes with human meat since we don't have a name for them
			if (xrecipe.useshumanmeat)
				xrecipeok = FALSE
			// Don't choose recipes with special outputs since we don't have valid inputs for them
			if (isnull(xrecipe.output))
				xrecipeok = FALSE
			// Bail out to a mess if we didn't get a valid recipe
			if (xrecipeok && contentsok)
				output = new xrecipe.output
			else
				output = new /obj/item/reagent_containers/food/snacks/yuck
			output.quality = 0
			return output
		. = ..()

	UpdateIcon(...)
		if (!src || !istype(src))
			return
		if(src.working)
			src.icon = src.icon_active
		else
			src.icon = src.icon_idle


	custom_suicide = TRUE
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return FALSE
		user.visible_message(SPAN_ALERT("<b>[user] shoves [his_or_her(user)] head in the oven and turns it on.</b>"))
		src.icon_state = "oven_bake"
		user.TakeDamage("head", 0, 150)
		sleep(5 SECONDS)
		src.icon_state = "oven_off"
		SPAWN(55 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return TRUE

TYPEINFO(/obj/machinery/cookingmachine/mixer)
	mats = 15

/obj/machinery/cookingmachine/mixer
	name = "KitchenHelper"
	desc = "A food mixer."
	icon_state = "blender_empty"
	power_active = 1 KILO WATT
	max_contents = 4
	cooktime = 2 SECONDS
	allowed = list(/obj/item/reagent_containers/food/, /obj/item/parts/robot_parts/head, /obj/item/clothing/head/butt, /obj/item/organ/brain)

	var/image/blender_off
	var/image/blender_powered
	var/image/blender_working
	var/list/recipes = null

	New()
		..()
		src.blender_off = image(src.icon, "blender_off")
		src.blender_powered = image(src.icon, "blender_powered")
		src.blender_working = image(src.icon, "blender_working")
		src.UpdateIcon()
		UnsubscribeProcess()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "MixerMachine")
			ui.open()

	ui_static_data(mob/user)
		. = list("maxItems" = src.max_contents)

	ui_data(mob/user)
		var/mixerContents = list()
		var/index = 1
		for(var/obj/item/I in src.contents)
			var/itemData = list()
			itemData["name"] = I.name
			itemData["index"] = index
			itemData["iconData"] = get_item_icon(I)
			mixerContents += list(itemData)
			index += 1
		. = list("working" = src.working, "mixerContents" = mixerContents)

	proc/get_item_icon(var/obj/item/target)
		var/static/base64_preview_cache = list()
		var/original_name = initial(target.name)
		. = base64_preview_cache[original_name]

		if(isnull(.))
			var/icon/result = getFlatIcon(target, no_anim=TRUE)
			if(result)
				. = icon2base64(result)
			else
				. = ""
			base64_preview_cache[original_name] = .

	ui_act(action, params)
		. = ..()
		if (.)
			return

		switch (action)
			if ("eject")
				var/index = params["index"]
				var/obj/item/target = src.contents[index]
				src.ejectItemFromMixer(target)

				usr.show_text(SPAN_NOTICE("You eject the [target.name] from the [src]."))
				. = TRUE

			if ("mix")
				src.start_cook()
				. = TRUE

			if ("ejectAll")
				for (var/obj/item/target in src.contents)
					src.ejectItemFromMixer(target)

				usr.show_text(SPAN_NOTICE("You eject all contents from the [src]."))
				. = TRUE

	get_recipes_from_ingredient(obj/item/ingredient) //this is a gross hack
		var/considered_type = ingredient.type
		while(considered_type != /obj/item && considered_type != /obj/item/reagent_containers/food/snacks/ingredient)
			if(mixer_recipes_by_ingredient[considered_type])
				var/output = mixer_recipes_by_ingredient[considered_type]
				if(mixer_recipes_by_ingredient[considered_type.parent_type])
					output += mixer_recipes_by_ingredient[considered_type.parent_type]
				return output
			else
				considered_type = considered_type.parent_type
		return

	start_cook()
		..()
		playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)

	handle_leftovers()
		for (var/obj/I in src.contents)
			I.set_loc(src.loc)
			src.visible_message(SPAN_ALERT("[I] is tossed out of [src]!"))
			var/edge = get_edge_target_turf(src, pick(alldirs))
			I.throw_at(edge, 25, 4)

	power_change()
		. = ..()
		src.UpdateIcon()

	disposing()
		. = ..()
		src.ClearSpecificOverlays(0)

	update_icon()
		if (!src || !istype(src))
			return

		if (length(src.contents) > 0)
			src.icon_state = "blender_filled"
		else
			src.icon_state = "blender_empty"

		var/notPowered = src.status & NOPOWER
		if (notPowered)
			src.UpdateOverlays(src.blender_off, "blender_light")
		else if (!notPowered && !src.working)
			src.UpdateOverlays(src.blender_powered, "blender_light")
		else
			src.UpdateOverlays(src.blender_working, "blender_light")

		return
