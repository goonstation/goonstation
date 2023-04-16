#define MW_COOK_VALID_RECIPE 1
#define MW_COOK_BREAK 2
#define MW_COOK_EGG 3
#define MW_COOK_DIRTY 4
#define MW_COOK_EMPTY 5

#define MW_STATE_WORKING 0
#define MW_STATE_BROKEN_1 1
#define MW_STATE_BROKEN_2 2

TYPEINFO(/obj/machinery/microwave)
	mats = 12

/obj/machinery/microwave
	name = "Microwave"
	icon = 'icons/obj/kitchen.dmi'
	desc = "The automatic chef of the future!"
	icon_state = "mw"
	density = 1
	anchored = ANCHORED
	/// Current number of eggs inside the microwave
	var/egg_amount = 0
	/// Current amount of flour inside the microwave
	var/flour_amount = 0
	/// Current amount of water inside the microwave
	var/water_amount = 0
	/// Current total of monkey meat inside the microwave
	var/monkeymeat_amount = 0
	/// Current total of synth meat inside the microwave
	var/synthmeat_amount = 0
	/// Current total of human meat inside the microwave
	var/humanmeat_amount = 0
	/// Current total of donk pockets inside the microwave
	var/donkpocket_amount = 0
	/// Stored name of human meat for cooked recipe
	var/humanmeat_name = ""
	/// Stored job of human meat for cooked recipe
	var/humanmeat_job = ""
	/// Microwave is currently running
	var/operating = FALSE
	/// If dirty the microwave cannot be used until cleaned
	var/dirty = FALSE
	/// Microwave damage, cannot be used until repaired
	var/microwave_state = MW_STATE_WORKING
	/// The time to wait before spawning the item
	var/cook_time = 20 SECONDS
	/// List of the recipes the microwave will check
	var/list/available_recipes = list()
	/// The current recipe being cooked
	var/datum/recipe/cooked_recipe = null
	/// The item to create when finished cooking
	var/obj/item/reagent_containers/food/snacks/being_cooked = null
	/// Single non food item that can be added to the microwave
	var/obj/item/extra_item
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	var/emagged = FALSE

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

/// After making the recipe in datums\recipes.dm, add it in here!
/obj/machinery/microwave/New()
	..()
	src.available_recipes += new /datum/recipe/donut(src)
	src.available_recipes += new /datum/recipe/synthburger(src)
	src.available_recipes += new /datum/recipe/monkeyburger(src)
	src.available_recipes += new /datum/recipe/humanburger(src)
	src.available_recipes += new /datum/recipe/waffles(src)
	src.available_recipes += new /datum/recipe/brainburger(src)
	src.available_recipes += new /datum/recipe/meatball(src)
	src.available_recipes += new /datum/recipe/buttburger(src)
	src.available_recipes += new /datum/recipe/roburger(src)
	src.available_recipes += new /datum/recipe/heartburger(src)
	src.available_recipes += new /datum/recipe/donkpocket(src)
	src.available_recipes += new /datum/recipe/donkpocket_warm(src)
	src.available_recipes += new /datum/recipe/pie(src)
	src.available_recipes += new /datum/recipe/popcorn(src)
	UnsubscribeProcess()

/**
	*  Item Adding
	*/

obj/machinery/microwave/attackby(var/obj/item/O, var/mob/user)
	if(src.operating)
		return
	if(src.microwave_state > 0)
		if (isscrewingtool(O) && src.microwave_state == MW_STATE_BROKEN_2)
			src.visible_message("<span class='notice'>[user] starts to fix part of the microwave.</span>")
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/screwdriver.dmi', "screwdriver", "", null)
		else if (src.microwave_state == MW_STATE_BROKEN_1 && iswrenchingtool(O))
			src.visible_message("<span class='notice'>[user] starts to fix part of the microwave.</span>")
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/wrench.dmi', "wrench", "", null)
		else
			boutput(user, "It's broken! It could be fixed with some common tools.")
			return
	else if(src.dirty) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/spraybottle))
			src.visible_message("<span class='notice'>[user] starts to clean the microwave.</span>")
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "cleaner", "", null)

		else if(istype(O, /obj/item/sponge))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "sponge", "", null)

		else //Otherwise bad luck!!
			boutput(user, "It's dirty! It could be cleaned with a sponge or spray bottle")
			return
	else if (O.cant_drop) //For borg held items, if the microwave is clean and functioning
		boutput(user, "<span class='alert'>You can't put that in [src] when it's attached to you!</span>")
	else if (isghostdrone(user))
		boutput(user, "<span class='alert'>\The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
		return
	else if(istype(O, /obj/item/card/emag))
		return
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/egg)) // If an egg is used, add it
		if(src.egg_amount < 5)
			src.visible_message("<span class='notice'>[user] adds an egg to the microwave.</span>")
			src.egg_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/flour)) // If flour is used, add it
		if(src.flour_amount < 5)
			src.visible_message("<span class='notice'>[user] adds some flour to the microwave.</span>")
			src.flour_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat))
		if(src.monkeymeat_amount < 5)
			src.visible_message("<span class='notice'>[user] adds some meat to the microwave.</span>")
			src.monkeymeat_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat))
		if(src.synthmeat_amount < 5)
			src.visible_message("<span class='notice'>[user] adds some meat to the microwave.</span>")
			src.synthmeat_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/))
		if(src.humanmeat_amount < 5)
			src.visible_message("<span class='notice'>[user] adds some meat to the microwave.</span>")
			src.humanmeat_name = O:subjectname
			src.humanmeat_job = O:subjectjob
			src.humanmeat_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if (istype(O, /obj/item/reagent_containers/food/snacks/donkpocket_w))
		// Band-aid fix. The microwave code could really use an overhaul (Convair880).
		user.show_text("Syndicate donk pockets don't have to be heated.", "red")
		return
	else if(istype(O, /obj/item/reagent_containers/food/snacks/donkpocket))
		if(src.donkpocket_amount < 2)
			src.visible_message("<span class='notice'>[user] adds a donk-pocket to the microwave.</span>")
			src.donkpocket_amount++
			user.u_equip(O)
			O.set_loc(src)
	else
		if(!isitem(extra_item)) //Allow one non food item to be added!
			if(O.w_class <= W_CLASS_NORMAL)
				user.u_equip(O)
				extra_item = O
				user.u_equip(O)
				O.set_loc(src)
				src.visible_message("<span class='notice'>[user] adds [O] to the microwave.</span>")
			else
				boutput(user, "[O] is too large and bulky to be microwaved.")
		else
			boutput(user, "There already seems to be an unusual item inside, so you don't add this one too.") //Let them know it failed for a reason though

/obj/machinery/microwave/proc/repair(mob/user as mob)
	if (src.microwave_state == MW_STATE_BROKEN_2)
		src.visible_message("<span class='notice'>[user] fixes part of the [src].</span>")
		src.microwave_state = MW_STATE_BROKEN_1 // Fix it a bit
	else if (src.microwave_state == MW_STATE_BROKEN_1)
		src.visible_message("<span class='notice'>[user] fixes the [src]!</span>")
		src.icon_state = "mw"
		src.microwave_state = MW_STATE_WORKING // Fix it!

/obj/machinery/microwave/proc/clean(mob/user as mob)
	if (src.dirty)
		src.visible_message("<span class='notice'>[user] finishes cleaning the [src].</span>")
		src.dirty = FALSE
		src.icon_state = "mw"

/**
	*  Microwave Menu
	*/

/obj/machinery/microwave/attack_hand(mob/user)
	if (isghostdrone(user))
		boutput(user, "<span class='alert'>\The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
		return
	var/dat
	if(src.microwave_state > 0)
		dat = {"
		<TT>Bzzzzttttt<BR>
		It's broken! It could be fixed with some common tools.</TT><BR>
		<BR>
				"}
	else if(src.operating)
		dat = {"
		<TT>Microwaving in progress!<BR>
		Please wait...!</TT><BR>
		<BR>
		"}
	else if(src.dirty)
		dat = {"
		<TT>This microwave is dirty!<BR>
		Please clean it before use!</TT><BR>
		<BR>
		"}
	else
		dat = {"
		<B>Eggs:</B>[src.egg_amount] eggs<BR>
		<B>Flour:</B>[src.flour_amount] cups of flour<BR>
		<B>Monkey Meat:</B>[src.monkeymeat_amount] slabs of meat<BR>
		<B>Synth-Meat:</B>[src.synthmeat_amount] slabs of meat<BR>
		<B>Meat Turnovers:</B>[src.donkpocket_amount] turnovers<BR>
		<B>Other Meat:</B>[src.humanmeat_amount] slabs of meat<BR><HR>
		<B>Unusual Item:</B>[src.extra_item]<BR><HR>
		<BR>
		<A href='?src=\ref[src];cook=1'>Turn on!<BR>
		<A href='?src=\ref[src];cook=2'>Empty contents!<BR>
		"}

	user.Browse("<HEAD><TITLE>Microwave Controls</TITLE></HEAD><TT>[dat]</TT>", "window=microwave")
	onclose(user, "microwave")
	return


/**
	*  Microwave Menu Selection Handling
	*/

/obj/machinery/microwave/Topic(href, href_list)
	if(..())
		return

	src.add_dialog(usr)
	src.add_fingerprint(usr)

	if(href_list["cook"])
		if(!src.operating)
			var/operation = text2num_safe(href_list["cook"])
			var/cooked_item = ""

			/// If cook was pressed in the menu
			if(operation == 1)
				src.visible_message("<span class='notice'>The microwave turns on.</span>")
				playsound(src.loc, 'sound/machines/microwave_start.ogg', 25, 0)
				var/diceinside = 0
				for(var/obj/item/dice/D in src.contents)
					if(!diceinside)
						diceinside = 1
					D.load()
				if(diceinside)
					src.cook(MW_COOK_BREAK)
					for(var/obj/item/dice/d in src.contents)
						d.set_loc(get_turf(src))
					return
				for(var/datum/recipe/R in src.available_recipes) //Look through the recipe list we made above
					if(src.egg_amount == R.egg_amount && src.flour_amount == R.flour_amount && src.monkeymeat_amount == R.monkeymeat_amount && src.synthmeat_amount == R.synthmeat_amount && src.humanmeat_amount == R.humanmeat_amount && src.donkpocket_amount == R.donkpocket_amount) // Check if it's an accepted recipe
						if(R.extra_item == null || (src.extra_item && src.extra_item.type == R.extra_item)) // Just in case the recipe doesn't have an extra item in it
							src.cooked_recipe = R
							cooked_item = R.creates // Store the item that will be created

				if(cooked_item == "") //Oops that wasn't a recipe dummy!!!
					if(src.flour_amount > 0 || src.water_amount > 0 || src.monkeymeat_amount > 0 || src.synthmeat_amount > 0 || src.humanmeat_amount > 0 || src.donkpocket_amount > 0 && src.extra_item == null) //Make sure there's something inside though to dirty it
						src.cook(MW_COOK_DIRTY)
					else if(src.egg_amount > 0) // egg was inserted alone
						src.cook(MW_COOK_EGG)
					else if(src.extra_item != null) // However if there's a weird item inside we want to break it, not dirty it
						src.cook(MW_COOK_BREAK)
					else //Otherwise it was empty, so just turn it on then off again with nothing happening
						src.visible_message("<span class='notice'>You're grilling nothing!</span>")
						src.cook(MW_COOK_EMPTY)
				else
					var/cooking = text2path(cooked_item) // Get the item that needs to be spanwed
					if(!isnull(cooking))
						src.visible_message("<span class='notice'>The microwave begins cooking something!</span>")
						src.being_cooked = new cooking(src)
						src.cook(MW_COOK_VALID_RECIPE)

			/// If empty was selected in the menu
			if(operation == 2)
				if (length(src.contents))
					for(var/obj/item/I in src.contents)
						I.set_loc(get_turf(src))
				src.clean_up()
				boutput(usr, "You empty the contents out of the microwave.")

/**
	*  Microwave Cooking
	*/

/obj/machinery/microwave/proc/cook(var/result)
	src.operating = TRUE
	src.power_usage = 80
	src.icon_state = "mw1"
	src.updateUsrDialog()
	switch(result)
		if(MW_COOK_VALID_RECIPE)
			sleep(cook_time)
			if(isnull(src))
				return
			src.icon_state = "mw"
			if(!isnull(src.being_cooked))
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				if(istype(src.being_cooked, /obj/item/reagent_containers/food/snacks/burger/humanburger))
					src.being_cooked.name = "[humanmeat_name] [src.being_cooked.name]"
				if(istype(src.being_cooked, /obj/item/reagent_containers/food/snacks/donkpocket))
					src.being_cooked:warm = 1
					src.being_cooked.name = "warm " + src.being_cooked.name
					src.being_cooked:cooltime()
				if (src.emagged)
					src.being_cooked.reagents.add_reagent("radium", 25)
				if((src.extra_item && src.extra_item.type == src.cooked_recipe.extra_item))
					qdel(src.extra_item)
				if(prob(1))
					src.being_cooked.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
				src.being_cooked.set_loc(get_turf(src)) // Create the new item
				src.extra_item = null
				src.cooked_recipe = null
				src.being_cooked = null // We're done!
		if(MW_COOK_BREAK)
			sleep(6 SECONDS) // Wait a while
			if(isnull(src))
				return
			elecflash(src,power=2)
			icon_state = "mwb"
			src.visible_message("<span class='alert'>The microwave breaks!</span>")
			src.microwave_state = MW_STATE_BROKEN_2
			src.extra_item.set_loc(get_turf(src)) // Eject the extra item so important shit like the disk can't be destroyed in there
			src.extra_item = null
		if(MW_COOK_EGG)
			sleep(4 SECONDS)
			if(isnull(src))
				return
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
			icon_state = "mweggexplode1"
			sleep(4 SECONDS)
			if(isnull(src))
				return
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.visible_message("<span class='alert'>The microwave gets covered in cooked egg!</span>")
			src.dirty = TRUE
			src.icon_state = "mweggexplode"
		if(MW_COOK_DIRTY)
			sleep(4 SECONDS)
			if(isnull(src))
				return
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
			icon_state = "mwbloody1"
			sleep(4 SECONDS)
			if(isnull(src))
				return
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.visible_message("<span class='alert'>The microwave gets covered in muck!</span>")
			src.dirty = TRUE
			src.icon_state = "mwbloody"
		if(MW_COOK_EMPTY)
			sleep(8 SECONDS)
			if(isnull(src))
				return
			src.icon_state = "mw"
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.clean_up()
	src.operating = FALSE
	src.power_usage = 5

/**
	*  Disposing of microwave contents
	*/

/obj/machinery/microwave/proc/clean_up()
	src.egg_amount = 0
	src.flour_amount = 0
	src.water_amount = 0
	src.humanmeat_amount = 0
	src.synthmeat_amount = 0
	src.monkeymeat_amount = 0
	src.donkpocket_amount = 0
	src.humanmeat_name = ""
	src.humanmeat_job = ""
	src.extra_item = null
	if (length(src.contents))
		for(var/obj/item/O in src.contents)
			if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/egg))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/flour))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/donkpocket))
				qdel(O)
			else
				O.set_loc(get_turf(src))

#undef MW_COOK_VALID_RECIPE
#undef MW_COOK_BREAK
#undef MW_COOK_EGG
#undef MW_COOK_DIRTY
#undef MW_COOK_EMPTY
#undef MW_STATE_WORKING
#undef MW_STATE_BROKEN_1
#undef MW_STATE_BROKEN_2
