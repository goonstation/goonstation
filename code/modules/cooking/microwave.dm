#define MW_STATE_WORKING 0
#define MW_STATE_BROKEN_1 1
#define MW_STATE_BROKEN_2 2

#define MW_CLEAN 0
#define MW_DIRTY 1
#define MW_DIRTY_SLIME 2
#define MW_DIRTY_EGG 3


TYPEINFO(/obj/machinery/microwave)
	mats = 12

/obj/machinery/microwave
	name = "Microwave"
	icon = 'icons/obj/kitchen.dmi'
	desc = "The automatic chef of the future!"
	icon_state = "mw"
	density = 1
	anchored = ANCHORED
	/// Microwave is currently running
	var/operating = FALSE
	/// If dirty the microwave cannot be used until cleaned
	var/dirty = MW_CLEAN
	/// Microwave damage, cannot be used until repaired
	var/microwave_state = MW_STATE_WORKING
	/// List of the recipes the microwave will check
	var/list/available_recipes = list()
	/// The default cooking instructions used when no unique instruction is given by the recipe
	var/datum/recipe_instructions/microwave_instructions/default_instructions
	object_flags = NO_BLOCK_TABLE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	var/emagged = FALSE

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
	src.available_recipes += new /datum/recipe/cooking/porridge(src)
	src.available_recipes += new /datum/recipe/cooking/burger/meat(src)
	src.default_instructions =  new /datum/recipe_instructions/microwave_instructions()
	src.default_instructions.cook_time = 8 SECONDS
	UnsubscribeProcess()

/**
	*  Item Adding
	*/


/obj/machinery/microwave/attackby(var/obj/item/O, var/mob/user)
	if(src.operating)
		return
	if(src.microwave_state > MW_STATE_WORKING)
		if (isscrewingtool(O) && src.microwave_state == MW_STATE_BROKEN_2)
			src.visible_message(SPAN_NOTICE("[user] starts to fix part of the microwave."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/screwdriver.dmi', "screwdriver", "", null)
		else if (src.microwave_state == MW_STATE_BROKEN_1 && iswrenchingtool(O))
			src.visible_message(SPAN_NOTICE("[user] starts to fix part of the microwave."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/wrench.dmi', "wrench", "", null)
		else
			boutput(user, "It's broken! It could be fixed with some common tools.")
			return
	else if(src.dirty) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/spraybottle))
			src.visible_message(SPAN_NOTICE("[user] starts to clean the microwave."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "cleaner", "", null)

		else if(istype(O, /obj/item/sponge))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "sponge", "", null)

		else //Otherwise bad luck!!
			boutput(user, "It's dirty! It could be cleaned with a sponge or spray bottle")
			return
	else if (O.cant_drop) //For borg held items, if the microwave is clean and functioning
		boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
	else if (isghostdrone(user))
		boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	else if(istype(O, /obj/item/card/emag))
		return

	else if(O.w_class <= W_CLASS_NORMAL)
		user.u_equip(O)
		O.set_loc(src)
		src.visible_message(SPAN_NOTICE("[user] adds [O] to the microwave."))
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

/obj/machinery/microwave/set_broken()
	. = ..()
	if (.) return
	src.microwave_state = MW_STATE_BROKEN_2
	src.update_icon_state()

/obj/machinery/microwave/proc/repair(mob/user as mob)
	if (src.microwave_state == MW_STATE_BROKEN_2)
		src.visible_message(SPAN_NOTICE("[user] fixes part of the [src]."))
		src.microwave_state = MW_STATE_BROKEN_1 // Fix it a bit
	else if (src.microwave_state == MW_STATE_BROKEN_1)
		src.visible_message(SPAN_NOTICE("[user] fixes the [src]!"))
		src.icon_state = "mw"
		src.microwave_state = MW_STATE_WORKING // Fix it!
		src.status &= ~BROKEN

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
	. = list(
		"broken" = src.microwave_state > 0,
		"operating" = src.operating,
		"dirty" = src.dirty,
		"eggs" = 0,
		"flour" = 0,
		"monkey_meat" = 0,
		"synth_meat" = 0,
		"donk_pockets" = 0,
		"other_meat" = 0,
		"unclassified_item" = null
		)

/obj/machinery/microwave/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("start_microwave")
			src.try_cook()
			return TRUE
		if ("eject_contents")
			if (length(src.contents))
				for(var/obj/item/I in src.contents)
					I.set_loc(get_turf(src))
				boutput(usr, "You empty the contents out of the microwave.")
				return TRUE

/obj/machinery/microwave/attack_hand(mob/user)
	if (isghostdrone(user))
		boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	src.ui_interact(user)

/obj/machinery/microwave/proc/update_icon_state()
	if (src.microwave_state)
		src.icon_state = "mwb"
		return
	if (src.operating)
		switch(src.dirty)
			if (MW_CLEAN)
				src.icon_state = "mw1"
			if (MW_DIRTY)
				src.icon_state = "mwbloody1"
			if (MW_DIRTY_SLIME)
				src.icon_state = "mwbloody2"
			if (MW_DIRTY_EGG)
				src.icon_state = "mweggexplode1"
	else
		switch(src.dirty)
			if (MW_CLEAN)
				src.icon_state = "mw"
			if (MW_DIRTY)
				src.icon_state = "mwbloody"
			if (MW_DIRTY_SLIME)
				src.icon_state = "mwbloodyS"
			if (MW_DIRTY_EGG)
				src.icon_state = "mweggexplode"

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
	var/datum/recipe/cooking/recipe
	for(var/datum/recipe/cooking/R in src.available_recipes) //Look through the recipe list we made above
		if (R.can_cook_recipe(src.contents))
			recipe = R
			break

	if (recipe == null)
		src.visible_message(SPAN_NOTICE("blergh."))
		src.heat_up(src.default_instructions)
		return
	src.visible_message(SPAN_NOTICE("The microwave begins cooking something!"))
	var/datum/recipe_instructions/microwave_instructions/instructions = recipe.get_recipe_instructions("microwave")
	if (istype(instructions, /datum/recipe_instructions/microwave_instructions))
		src.cook(instructions, recipe)
	else
		src.cook(src.default_instructions, recipe)


/// Cooks a recipe
/obj/machinery/microwave/proc/cook(var/datum/recipe_instructions/microwave_instructions/instructions, var/datum/recipe/cooking/recipe)
	src.operating = TRUE
	src.power_usage = 80
	src.update_icon_state()

	sleep((instructions.cook_time / 2))
	if (isnull(src))
		return
	switch(instructions.end_state)
		if ("dirty")
			icon_state = "mwbloody1"
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		if ("green_dirty")
			icon_state = "mwbloody2"
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		if ("egg_dirty")
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
			icon_state = "mweggexplode1"

	sleep((instructions.cook_time / 2))
	if (isnull(src))
		return
	if (instructions.end_state == "break")
		elecflash(src,power=2)
		src.visible_message(SPAN_ALERT("The microwave breaks!"))
		src.set_broken()
	var/obj/result = recipe.get_output(src.contents)
	if (src.emagged)
		result.reagents?.add_reagent("radium", 25)
	if(prob(1))
		result.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
	result.set_loc(get_turf(src))
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	for(var/atom/thing in src.contents)
		qdel(thing)
	src.power_usage = 5
	src.operating = FALSE
	src.update_icon_state()
	return

/// warm up the contents
/obj/machinery/microwave/proc/heat_up(var/datum/recipe_instructions/microwave_instructions/instructions)
	src.operating = TRUE
	src.update_icon_state()
	src.power_usage = 80

	var/list/src_contents = src.contents.Copy()
	var/cook_delay = instructions.cook_time / length(src.contents) + 1
	for(var/atom/thing in src_contents)
		sleep(cook_delay)
		if (isnull(src))
			return
		thing = src.affect_thing(thing)
		if (thing.reagents)
			thing.reagents.temperature_reagents(4000,400)
		if(prob(1))
			thing.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
	sleep(cook_delay)
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	for(var/atom/movable/thing in src.contents)
		affect_thing_end(thing)
		thing.set_loc(get_turf(src))
	src.power_usage = 5
	src.operating = FALSE
	src.update_icon_state()

/// Account for the specific interactions that don't work as recipes
/obj/machinery/microwave/proc/affect_thing(var/thing)
	// this structure is very unscalable, if there's ever more than a few of these special cases they should belong to the items themselves
	if (istype(thing,/obj/item/organ/head))
		var/obj/item/organ/head/head = thing

		var/mob/living/carbon/human/H = head.linked_human
		if (H && head.head_type == HEAD_SKELETON && isskeleton(H))
			head.linked_human.emote("scream")
			boutput(H, SPAN_ALERT("The microwave burns your skull!"))

			if (!(head.glasses && istype(head.glasses, /obj/item/clothing/glasses/sunglasses))) //Always wear protection
				H.take_eye_damage(1, 2)
				H.change_eye_blurry(2)
				H.changeStatus("stunned", 1 SECOND)
				H.change_misstep_chance(5)
		return thing
	else if (istype(thing, /obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug))
		var/mob/adultSlug = new /mob/living/critter/small_animal/slug
		src.visible_message(SPAN_NOTICE("The slug is expanding..."))
		adultSlug.set_loc(src)
		src.set_dirtiness(MW_DIRTY_EGG)
		qdel(thing)
		return adultSlug
	else if (istype(thing, /obj/item/reagent_containers/food/snacks/ingredient/egg))
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		src.set_dirtiness(MW_DIRTY_EGG)
		return thing
	else if (istype(thing, /obj/item/dice))
		var/obj/item/dice/dice = thing
		dice.load()
		return thing
	return thing

/// Account for specific interactions that occur at the end
/obj/machinery/microwave/proc/affect_thing_end(var/thing)
	if (istype(thing, /mob/living/critter/small_animal/slug) && prob(6))
		src.visible_message(SPAN_NOTICE("Nature is beautiful."))

#undef MW_STATE_WORKING
#undef MW_STATE_BROKEN_1
#undef MW_STATE_BROKEN_2
