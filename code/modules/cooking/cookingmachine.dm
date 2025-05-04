/// Mixing time in seconds
#define MIX_TIME 2 SECONDS

var/list/mixer_recipes = list()

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

	proc/get_valid_recipe()
		for (var/datum/cookingrecipe/R in src.possible_recipes)
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
		if (count < recipecount)
			return FALSE
		return TRUE

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
					output += oven_recipes_by_ingredient[considered_type.parent_type] //this ensure the more specific recipes are checked first
				return output
			else
				considered_type = considered_type.parent_type
		return

	proc/cooking_power() //used to find cook amounts on
		return cooktime/10

	/// Called when the machine finishes cooking
	proc/cook_food()
		var/output = null
		var/quality = null
		var/cook_amount = src.cooking_power()
		var/datum/cookingrecipe/R = src.get_valid_recipe()
		if (R)
			// this is null if it uses normal outputs (see below),
			// otherwise it will be the created item from this
			output = R.specialOutput(src)
			if (isnull(output))
				output = R.output
			if(R.cookbonus)
				recipebonus = R.cookbonus
				if (abs(cook_amount - R.cookbonus) <= 1)
					// if -1, 0, or 1, you did ok
					quality = 5
				else if (cook_amount >= R.cookbonus + 5)
					// you burned it
					output = /obj/item/reagent_containers/food/snacks/yuck/burn
					quality = 0
				else// mediocre meals
					quality = clamp(5 - abs(R.cookbonus - cook_amount), 0, 5)
			if(R.useshumanmeat)
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
			output = /obj/item/reagent_containers/food/snacks/yuck
		// this only happens if the output is a yuck item, either from an
		// invalid recipe or otherwise...
		if (src.contents.len == 1 && output == /obj/item/reagent_containers/food/snacks/yuck)
			for (var/obj/item/reagent_containers/food/snacks/F in src)
				if(F.quality < 1)
					// @TODO cooktime == F.quality can never happen here
					// (cooktime is the time the oven is set to from 1-10,
					//  and F.quality has to be 0 or below to get here)
					recook = 1
					if (cooktime == F.quality) F.quality = 1.5
					else if (cooktime == F.quality + 1) F.quality = 1
					else if (cooktime == F.quality - 1) F.quality = 1
					else if (cooktime <= F.quality - 5) F.quality = 0.5
					else if (cooktime >= F.quality + 5)
						output = /obj/item/reagent_containers/food/snacks/yuck/burn
						bonus = 0




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
	var/timeMixEnd = 0

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
				src.mix()
				. = TRUE

			if ("ejectAll")
				for (var/obj/item/target in src.contents)
					src.ejectItemFromMixer(target)

				usr.show_text(SPAN_NOTICE("You eject all contents from the [src]."))
				. = TRUE

	proc/bowl_checkitem(var/recipeitem, var/recipecount)
		if (!locate(recipeitem) in src.contents) return 0
		var/count = 0
		for(var/obj/item/I in src.contents)
			if(istype(I, recipeitem))
				count++
				to_remove += I

		if (count < recipecount)
			return 0
		return 1

	proc/mix()

		var/amount = length(src.contents)
		if (!amount)
			boutput(usr, SPAN_ALERT("There's nothing in the mixer."))
			return
		src.working = 1
		src.timeMixEnd = TIME + MIX_TIME
		src.power_usage = MIXER_MIXING_POWER_USAGE

		tgui_process.update_uis(src)
		src.UpdateIcon()
		playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
		SubscribeToProcess()

	process()
		. = ..()
		if (status & (NOPOWER|BROKEN))
			UnsubscribeProcess()
			return

		var/amount = length(src.contents)
		if (!amount)
			UnsubscribeProcess()
			return

		if (TIME < src.timeMixEnd)
			return

		var/output = null // /obj/item/reagent_containers/food/snacks/yuck
		var/derivename = 0
		check_recipe:
			for (var/datum/cookingrecipe/R in src.recipes)
				to_remove.len = 0
				for(var/I in R.ingredients)
					if (!bowl_checkitem(I, R.ingredients[I])) continue check_recipe
				output = R.specialOutput(src)
				if (!output)
					output = R.output
				if (R.useshumanmeat)
					derivename = 1
				break

		if (!isnull(output))
			var/obj/item/reagent_containers/food/snacks/F
			if (ispath(output))
				F = new output(get_turf(src))
			else
				F = output
				F.set_loc(get_turf(src))

			if (derivename)
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
		for (var/obj/item/I in to_remove)
			qdel(I)
		to_remove.len = 0

		for (var/obj/I in src.contents)
			I.set_loc(src.loc)
			src.visible_message(SPAN_ALERT("[I] is tossed out of [src]!"))
			var/edge = get_edge_target_turf(src, pick(alldirs))
			I.throw_at(edge, 25, 4)

		src.working = 0
		src.UpdateIcon()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		tgui_process.update_uis(src)

		src.power_usage = 0
		UnsubscribeProcess()
		return

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
