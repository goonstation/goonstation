#define MW_STATE_WORKING 0
#define MW_STATE_BROKEN_1 1
#define MW_STATE_BROKEN_2 2

#define IDLE_POWER_USAGE 5
#define ACTIVE_POWER_USAGE 80

/// Amount of heat that the microwave exposes its contents to.
#define MW_HEAT 500 KELVIN // The only reasoning for this value is that it's hot enough to warm up donk pockets.


TYPEINFO(/obj/machinery/microwave)
	mats = 12

/obj/machinery/microwave
	name = "microwave"
	icon = 'icons/obj/kitchen.dmi'
	desc = "The automatic chef of the future!"
	icon_state = "mw"
	density = 1
	anchored = ANCHORED
	object_flags = NO_BLOCK_TABLE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	var/emagged = FALSE
	/// Microwave is currently running
	var/operating = FALSE
	/// If dirty the microwave cannot be used until cleaned
	var/dirty = MW_CLEAN
	/// Microwave damage, cannot be used until repaired
	var/microwave_state = MW_STATE_WORKING
	/// List of the recipes the microwave will check first
	var/static/list/available_recipes
	/// List of recipes the microwave will check when heating contents in sequence, after previous recipe check fails
	var/static/list/single_input_recipes
	/// The default cooking instructions used during regular batch cooking when no unique instruction is given by the recipe
	var/static/datum/recipe_instructions/microwave/default_instructions
	/// The default cooking instructions used when heating up (sequential cooking) when no unique instruction is given by the recipe
	var/static/datum/recipe_instructions/microwave/default_heat_up/default_instructions_sequential
	/// value is at least enough for all the recipes, but is otherwise arbitrary
	var/maximum_contents = 4
	/// Temporary holder for items meant to be deleted during cooking. Should be processed if cooking is interrupted.
	// the reason this isn't a local variable is that the full input list is kept around for the whole cooking process, for the purposes flexibility,
	// and the deletion only occurs after cooking finishes.
	var/list/for_deletion = list()

	HELP_MESSAGE_OVERRIDE("Place items inside by clicking, then click the microwave with an open hand to open cooking menu.")

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				user.show_text("You use the card to change the internal radiation setting to \"IONIZING\"", "blue")
			src.emagged = TRUE
			return TRUE
		else
			if (user)
				user.show_text("The [src] has already been tampered with", "red")

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You reset the radiation levels to a more food-safe setting.", "blue")
		src.emagged = FALSE
		return TRUE

/obj/machinery/microwave/get_help_message(dist, mob/user)
	if(src.status & BROKEN)
		if(src.microwave_state == MW_STATE_BROKEN_2)
			return "The microwave is broken! Use a <b>screwing tool</b> to begin repairing."
		if(src.microwave_state == MW_STATE_BROKEN_1)
			return "The microwave is broken! Use a <b>wrenching tool</b> to finish repairing."
	if (src.dirty)
		return "The microwave is dirty! Use a <b>sponge</b> or <b>spray bottle</b> to clean it up."
	return "Place items inside, then click the microwave with an open hand to open the cooking controls."

/// After making the recipe in datums\recipes.dm, add it in here!
/obj/machinery/microwave/New()
	..()
	if (!available_recipes)
		// really need a global recipe cache
		available_recipes = list(
			new /datum/recipe/waffles(),
			new /datum/recipe/donut(),
			new /datum/recipe/donkpocket(),
			new /datum/recipe/burger/roburger(),
			new /datum/recipe/burger/meat(),
			new /datum/recipe/burger/buttburger(),
			new /datum/recipe/burger/butterburger(),
			new /datum/recipe/burger/heartburger(),
			new /datum/recipe/burger/brainburger(),
			new /datum/recipe/pie_custard_mw()
		)

	if (!single_input_recipes)
		single_input_recipes = list(
			new /datum/recipe/sequential/microwaved_egg(),
			new /datum/recipe/sequential/microwaved_skeleton_head(),
			new /datum/recipe/sequential/microwaved_dice(),
			new /datum/recipe/sequential/cooked_slug(),
			new /datum/recipe/sequential/popcorn()
		)

	if (!default_instructions)
		default_instructions = new /datum/recipe_instructions/microwave/default_cook()
	if (!default_instructions_sequential)
		default_instructions_sequential = new /datum/recipe_instructions/microwave/default_heat_up()

	UnsubscribeProcess()

/**
	*  Item Adding
	*/


/obj/machinery/microwave/attackby(var/obj/item/O, var/mob/user)
	if(src.operating)
		return
	if(src.dirty)
		if(istype(O, /obj/item/spraybottle))
			src.visible_message(SPAN_NOTICE("[user] starts to clean [src]."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "cleaner", "", null)
			return

		else if(istype(O, /obj/item/sponge))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "sponge", "", null)
			return
	if(src.microwave_state > MW_STATE_WORKING)
		if (isscrewingtool(O) && src.microwave_state == MW_STATE_BROKEN_2)
			src.visible_message(SPAN_NOTICE("[user] starts to fix part of [src]."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/screwdriver.dmi', "screwdriver", "", null)
		else if (src.microwave_state == MW_STATE_BROKEN_1 && iswrenchingtool(O))
			src.visible_message(SPAN_NOTICE("[user] starts to fix part of [src]."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/wrench.dmi', "wrench", "", null)
		else
			boutput(user, SPAN_ALERT("It's broken! It could be fixed with some common tools."))
		return
	if (O.cant_drop) //For borg held items, if the microwave is functioning
		boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
	else if (isghostdrone(user))
		boutput(user, SPAN_ALERT("[src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	else if(istype(O, /obj/item/card/emag))
		return
	else if(O.w_class <= W_CLASS_NORMAL)
		if (length(src.contents) >= src.maximum_contents)
			boutput(user, SPAN_ALERT("You can't fit anything else inside [src]."))
			return
		user.u_equip(O)
		O.set_loc(src)
		src.visible_message(SPAN_NOTICE("[user] adds [O] to [src]."))
		tgui_process.update_uis(src)
	else
		boutput(user, "[O] is too large and bulky to be microwaved.")

/obj/machinery/microwave/blob_act(power)
	if (!src.is_broken())
		src.set_broken()
		return
	..()


/obj/machinery/microwave/bullet_act(obj/projectile/P)
	if(P.proj_data.damage_type & (D_KINETIC | D_PIERCING | D_SLASHING))
		if(prob(P.power * P.proj_data?.ks_ratio))
			src.set_broken()

/obj/machinery/microwave/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				src.set_broken()
				return
		if(3)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				src.set_broken()
				return

/obj/machinery/microwave/overload_act()
	return !src.set_broken()

/// Set the microwave to a broken state, interrupting any cooking that's in progress
/obj/machinery/microwave/set_broken()
	. = ..()
	if (.) return
	src.microwave_state = MW_STATE_BROKEN_2
	src.stop_cooking()

/// interrupt any cooking in progress - forcing ejection of contents and processing the deletion list
/obj/machinery/microwave/proc/stop_cooking()
	if (!src.operating)
		return
	src.operating = FALSE
	for(var/atom/thing as anything in src.for_deletion)
		qdel(thing)
	src.for_deletion.Cut()
	for(var/atom/movable/thing in src.contents)
		thing.set_loc(get_turf(src))
	src.power_usage = IDLE_POWER_USAGE
	src.update_icon_state()
	tgui_process.update_uis(src)

/obj/machinery/microwave/proc/repair(mob/user as mob)
	if (src.microwave_state == MW_STATE_BROKEN_2)
		src.visible_message(SPAN_NOTICE("[user] fixes part of the [src]."))
		src.microwave_state = MW_STATE_BROKEN_1 // Fix it a bit
	else if (src.microwave_state == MW_STATE_BROKEN_1)
		src.visible_message(SPAN_NOTICE("[user] fixes the [src]!"))
		src.microwave_state = MW_STATE_WORKING // Fix it!
		src.status &= ~BROKEN
		src.update_icon_state()

/obj/machinery/microwave/proc/clean(mob/user as mob)
	if (src.dirty)
		src.visible_message(SPAN_NOTICE("[user] finishes cleaning the [src]."))
		src.dirty = FALSE
		src.update_icon_state()

/**
	*  Microwave Menu
	*/


/obj/machinery/microwave/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Microwave")
		ui.open()

/obj/machinery/microwave/ui_data(mob/user)
	var/list/contents = list()
	var/index = 1
	for(var/obj/item/I in src.contents)
		contents.Add(list(list(
            "index" = index,
            "name" = I.name,
            "iconData" = src.get_item_icon(I)
        )))
		index++
	var/list/thing = list(
		"broken" = src.microwave_state > 0,
		"operating" = src.operating,
		"dirty" = 0,
		"maxItems" = 4,
		"items" = contents
		)
	return thing

/obj/machinery/microwave/proc/get_item_icon(var/obj/item/target)
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

/obj/machinery/microwave/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("start_microwave")
			if(src.operating)
				return FALSE
			src.try_cook()
			return TRUE
		if ("eject_contents")
			if(src.operating)
				src.stop_cooking()
				return TRUE
			if (!length(src.contents))
				return FALSE
			boutput(usr, SPAN_NOTICE("You empty the contents out of the microwave."))
			for(var/atom/movable/thing as anything in src.contents)
				thing.set_loc(get_turf(src))
			return TRUE
		if ("eject_single")
			var/index = params["index"]
			var/atom/movable/target = src.contents[index]
			if (BOUNDS_DIST(usr, src) == 0)
				usr.put_in_hand_or_drop(target)
			else
				target.set_loc(src.loc)
			tgui_process.update_uis(src)
			boutput(usr, SPAN_NOTICE("You eject the [target.name] from [src]."))

/obj/machinery/microwave/attack_hand(mob/user)
	if (src.microwave_state)
		boutput(user, SPAN_ALERT("It's broken! It could be fixed with some common tools."))
		return
	if (isghostdrone(user))
		boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	src.ui_interact(user)

/obj/machinery/microwave/proc/update_icon_state()
	if (src.microwave_state)
		src.icon_state = "mwb"
		return

	switch(src.dirty)
		if (MW_CLEAN)
			src.icon_state = src.operating ? "mw1" : "mw"
		if (MW_DIRTY)
			src.icon_state = src.operating ? "mwbloody1" : "mwbloody"
		if (MW_DIRTY_SLIME)
			src.icon_state = src.operating ? "mwbloody2" : "mwbloodyS"
		if (MW_DIRTY_EGG)
			src.icon_state = src.operating ? "mweggexplode1" : "mweggexplode"
		else
			src.icon_state = "mw"

/obj/machinery/microwave/proc/set_dirtiness(var/value)
	src.dirty = value
	src.update_icon_state()

/**
	*  Microwave Cooking
	*/

/obj/machinery/microwave/proc/try_cook()
	if(src.operating)
		return

	src.visible_message(SPAN_NOTICE("The microwave turns on."))
	playsound(src.loc, 'sound/machines/microwave_start.ogg', 25, 0)
	var/datum/recipe/recipe
	recipe = src.get_recipe(src.contents, src.available_recipes)

	src.operating = TRUE
	src.power_usage = ACTIVE_POWER_USAGE
	src.update_icon_state()

	if (recipe == null)
		src.heat_up(src.default_instructions_sequential)
	else
		src.visible_message(SPAN_NOTICE("The microwave begins cooking something!"))
		var/datum/recipe_instructions/microwave/instructions = recipe.get_recipe_instructions("microwave")
		if (!istype(instructions))
			instructions = src.default_instructions
		src.cook(instructions, recipe)


/obj/machinery/microwave/proc/get_recipe(var/input, var/list/possible_recipes)
	for(var/datum/recipe/R in possible_recipes)
		if (R.can_cook_recipe(input))
			return R
	return null

/// Cooks a recipe
/obj/machinery/microwave/proc/cook(var/datum/recipe_instructions/microwave/instruction, var/datum/recipe/recipe)
	sleep((instruction.cook_time / 2))
	if (isnull(src))
		return
	if (instruction.force_dirtiness != null)
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		src.set_dirtiness(instruction.force_dirtiness)
	if (instruction.force_breakage)
		elecflash(src,power=2)
		src.visible_message(SPAN_ALERT("The microwave breaks!"))
		src.set_broken()
	var/obj/results = list()
	recipe.try_get_output(src.contents, results)
	if(instruction.delete_ingredient)
		for(var/atom/thing in src.contents)
			qdel(thing)
	for(var/atom/thing in results)
		src.affect_thing(thing, instruction)

	// if it breaks during cooking, eject immediately
	if (src.microwave_state != MW_STATE_WORKING)
		for(var/atom/movable/thing in results)
			thing.set_loc(get_turf(src))
		return
	results = null
	sleep((instruction.cook_time / 2))
	if (isnull(src))
		return
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.stop_cooking()

/// warm up the contents
/obj/machinery/microwave/proc/heat_up(var/datum/recipe_instructions/microwave/instructions)
	// it seems fairly feasible to make the microwave heat up the contents of containers, but it would have to take into account where the
	// outputs are meant to go, whether they go back in the container or not, what the size of the container is, if it can hold the results when there
	// are multiple, and I just can't be arsed
	var/list/src_contents = src.contents.Copy()
	var/list/output = list()
	var/cook_delay = (instructions.cook_time / (length(src.contents) + 1))
	var/contents_length = length(src_contents)
	var/list/post_cook_effects = list()

	for(var/i = 1, i <= contents_length, i++)
		sleep(cook_delay)
		if (isnull(src) || src.operating == FALSE)
			return
		var/datum/recipe/recipe = src.get_recipe(src_contents, src.single_input_recipes)
		var/datum/recipe_instructions/microwave/sequential_instructions = instructions
		if (recipe && recipe.try_get_output(src_contents, output, src))
			sequential_instructions = recipe.get_recipe_instructions(RECIPE_ID_MICROWAVE) || instructions
			if (sequential_instructions.force_dirtiness != null)
				src.set_dirtiness(sequential_instructions.force_dirtiness)

			for(var/atom/out in output)
				src.affect_thing(out, instructions)
		else
			src.affect_thing(src_contents[1], instructions)
		if (sequential_instructions.post_cook_effect)
			post_cook_effects += sequential_instructions
		if (sequential_instructions?.delete_ingredient)
			src.for_deletion += src_contents[1]
		if (sequential_instructions.force_breakage)
			elecflash(src,power=2)
			src.visible_message(SPAN_ALERT("The microwave breaks!"))
			src.set_broken()
			return
		// rotate the list to process the next item. We do it this way so that the recipes can have the context of the items they are cooked with
		var/last = src_contents[contents_length]
		src_contents.Cut(contents_length)
		src_contents.Insert(1, last)

	for(var/atom/thing in src.for_deletion)
		qdel(thing)

	sleep(cook_delay)
	if (isnull(src) || !src.operating)
		return
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.stop_cooking()

	// call all the effects that the successful recipes want to perform upon being ejected
	for(var/datum/recipe_instructions/microwave/instruction in post_cook_effects)
		instruction.post_cook_effect(src)

/// Do the microwave effects on each output object
/obj/machinery/microwave/proc/affect_thing(var/atom/thing, var/datum/recipe_instructions/microwave/instructions = null)
	if(prob(1))
		thing.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
	if (src.emagged)
		thing.reagents?.add_reagent("radium", 25)
	if(src.dirty != MW_CLEAN) // a dirty microwave contaminates the food
		thing.reagents?.add_reagent("yuck", 5)
	thing.temperature_expose(null, MW_HEAT, 400)
	if (istype(thing, /atom/movable))
		var/atom/movable/movablething = thing
		movablething.set_loc(src)

#undef MW_STATE_WORKING
#undef MW_STATE_BROKEN_1
#undef MW_STATE_BROKEN_2

#undef IDLE_POWER_USAGE
#undef ACTIVE_POWER_USAGE

#undef MW_HEAT
