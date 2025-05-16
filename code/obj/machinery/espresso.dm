/* ==================================================== */
/* --------------------- Machine ---------------------- */
/* ==================================================== */
TYPEINFO(/obj/machinery/espresso_machine)
	mats = 30

/obj/machinery/espresso_machine
	name = "espresso machine"
	desc = "It's top of the line NanoTrasen espresso technology! Featuring 100% Organic Locally-Grown espresso beans!" //haha no
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "espresso_machine"
	density = 1
	anchored = ANCHORED
	flags = NOSPLASH | TGUI_INTERACTIVE
	event_handler_flags = NO_MOUSEDROP_QOL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS
	var/cupslimit = 2
	var/cupsinside = 0
	var/top_on = 1 //screwed on or screwed off
	var/cup_name = "espresso cup"
	var/image/image_cup = null
	var/list/drink_options = list("Americano", "Cappuchino", "Decaf", "Espresso", "Flat White", "Latte", "Mocha")

	New()
		..()
		UnsubscribeProcess()
		src.update()

	ui_interact(mob/user, datum/tgui/ui)
		for(var/obj/item/reagent_containers/container in src.contents)
			SEND_SIGNAL(container.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "EspressoMachine")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"drinks" = drink_options
		)

	ui_data(mob/user)
		var/cups = list()
		var/cup_index = 1
		for(var/obj/item/reagent_containers/C in src.contents)
			var/cup = list()
			cup["capacity"] = C.initial_volume
			cup["reagents"] = list()
			cup["index"] = cup_index
			for(var/reagent_id in C.reagents.reagent_list)
				var/datum/reagent/R = C.reagents.reagent_list[reagent_id]
				cup["reagents"] += list(list(R.name, R.volume, R.fluid_r, R.fluid_g, R.fluid_b))
			cups += list(cup)
			cup_index += 1

		. = list(
			"containers" = cups
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		switch(action)
			if("eject")
				var/cup_index = params["cup_index"]
				var/obj/item/target = src.contents[cup_index]
				if (target)
					if((BOUNDS_DIST(usr, src) == 0))
						usr.put_in_hand_or_drop(target)
					else
						target.set_loc(src.loc)
				usr.show_text("You have removed the [src.cup_name] from [src].")
				src.cupsinside -= 1
				src.update()
				. = TRUE
			if("flush")
				var/cup_index = params["cup_index"]
				var/obj/item/reagent_containers/target = src.contents[cup_index]
				if (target)
					target.reagents.clear_reagents()
					. = TRUE
			if("pour")
				. = TRUE
				var/drink_choice = params["drink_name"]
				switch (drink_choice)  //finds cup in contents and adds chosen drink to it
					if ("Espresso")
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C.reagents.add_reagent("espresso",10)
					if ("Latte") // 5:1 milk:espresso
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C.reagents.add_reagent("espresso", 1.6)
							C.reagents.add_reagent("milk", 8.4)
					if ("Mocha") // 3:1:3 espresso:milk:chocolate
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C.reagents.add_reagent("espresso", 4.3)
							C.reagents.add_reagent("milk", 1.4)
							C.reagents.add_reagent("chocolate", 4.3)
					if ("Cappuchino") // 1:1:1 milk foam:milk:espresso
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C.reagents.add_reagent("espresso", 3.5)
							C.reagents.add_reagent("milk", 6.5)
					if ("Americano") // 3:2 water:espresso
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C.reagents.add_reagent("espresso", 4)
							C.reagents.add_reagent("water", 6)
					if ("Decaf") // 1 decaf espresso
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C.reagents.add_reagent("decafespresso", 10)
					if ("Flat White") // 3:2 milk:espresso
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C.reagents.add_reagent("espresso", 4)
							C.reagents.add_reagent("milk", 6)
				playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
				use_power(10)

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/reagent_containers/food/drinks/espressocup))
			if (cupsinside >= src.cupslimit)
				user.show_text("The [src.name] can't hold any more [src.cup_name]s, doofus!")
				return ..()
			else
				src.cupsinside += 1
				user.drop_item()
				W.set_loc(src)
				user.show_text ("You place the [src.cup_name] into [src].")
				src.update()
				tgui_process.update_uis(src)
				return ..()

	MouseDrop_T(atom/movable/O as obj, mob/user as mob)
		if (!istype(O, /obj/item/reagent_containers/food/drinks/espressocup))
			return

		if (!isliving(user))
			boutput(user, SPAN_ALERT("How are you planning on drinking coffee as a ghost!?"))
			return

		if (isAI(user) || !can_reach(user, O) || BOUNDS_DIST(user, src) > 1 || !can_act(user) )
			return

		src.Attackby(O, user)

	attack_hand(mob/user)
		if (can_reach(user,src) && !(status & (NOPOWER|BROKEN)))
			src.add_fingerprint(user)
			return ..()

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	proc/update()
		if (src.cupsinside == 1)
			src.image_cup = image(src.icon, icon_state = "cupoverlay")
		else if(src.cupsinside == 2)
			src.image_cup = image(src.icon, icon_state = "cupoverlay2")
		else
			src.image_cup = null
		src.UpdateOverlays(src.image_cup, "cup")
		return

/* ===================================================== */
/* ---------------------- Coffeemaker ------------------ */
/* ===================================================== */
//Sorry for budging in here, whoever made the espresso machine. Lets just rename this to coffee.dm?

TYPEINFO(/obj/machinery/coffeemaker)
	mats = 30

/obj/machinery/coffeemaker
	name = "coffeemaker"
	desc = "It's top of the line NanoTrasen espresso technology! Featuring 100% Organic Locally-Grown espresso beans!" //haha no
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "coffeemaker-gen"
	density = 1
	anchored = ANCHORED
	flags = NOSPLASH
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS
	var/carafe_name = "coffee carafe"
	var/image/image_top = null
	var/image/image_carafe = null
	var/obj/item/reagent_containers/food/drinks/carafe/my_carafe
	var/default_carafe = /obj/item/reagent_containers/food/drinks/carafe
	var/image/fluid_image

	var/emagged = FALSE
	var/reagent_id = "coffee_fresh"

	New()
		..()
		UnsubscribeProcess()
		if (ispath(src.default_carafe))
			src.my_carafe = new src.default_carafe (src)
		src.update()

	emag_act(var/mob/user, var/obj/item/card/emag/E)

		if(!src.emagged)
			if (user)
				boutput(user, SPAN_NOTICE("You force the machine to brew something else..."))

			src.desc = " It's top of the line NanoTrasen tea technology! Featuring 100% Organic Locally-Grown green leaves!"
			src.reagent_id = "tea"
			return TRUE
		else
			if (user)
				boutput(user, SPAN_ALERT("This has already been tampered with."))
			return FALSE

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/reagent_containers/food/drinks/carafe))
			if (src.my_carafe)
				user.show_text("The [src] can't hold any more [src.carafe_name]s, doofus!")
				return ..()
			else
				user.drop_item()
				W.set_loc(src)
				src.my_carafe = W
				user.show_text ("You place the [src.carafe_name] into the [src].")
				src.update()
				return ..()

	attack_hand(mob/user)
		if (can_reach(user,src))
			src.add_fingerprint(user)
			if (src.my_carafe) //freaking spacing errors made me waste hours on this
				if (!(status & (NOPOWER|BROKEN)))
					var/choice = tgui_alert(user, "What would you like to do with [src]?", "Coffeemaker", list("Brew [src.emagged ? "tea" : "coffee"]", "Remove carafe", "Nothing"))
					if (!choice || choice == "Nothing")
						return
					switch (choice)
						if ("Brew coffee","Brew tea")
							for(var/obj/item/reagent_containers/food/drinks/carafe/C in src.contents)
								C.reagents.add_reagent(src.reagent_id,100)
								playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
								use_power(10)
						if ("Remove carafe")
							if (!src.my_carafe)
								user.show_text("The carafe is gone!")
								return
							if (BOUNDS_DIST(src, user) > 0 || isAI(user))
								user.show_text("You can not do that remotely.")
								return
							user.put_in_hand_or_drop(src.my_carafe)
							src.my_carafe = null
							user.show_text("You have removed the [src.carafe_name] from the [src].")
							src.update()
			else return ..()

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	proc/update(var/passed_color)
		if (src.my_carafe)
			src.UpdateOverlays(SafeGetOverlayImage("carafe", src.icon, src.my_carafe.icon_state),"carafe")
			if (src.my_carafe.reagents && src.my_carafe.reagents.total_volume)
				var/image/I = SafeGetOverlayImage("carafe-fluid", src.icon, "carafe-fluid")
				var/datum/color/average = my_carafe.reagents.get_average_color()
				var/average_rgb = average.to_rgba()
				I.color = average_rgb
				src.UpdateOverlays(I, "carafe-fluid")
			else
				src.UpdateOverlays(null, "carafe-fluid", 0, 1)
		else
			src.UpdateOverlays(null, "carafe", 0, 1)
			src.UpdateOverlays(null, "carafe-fluid", 0, 1)
		return

/obj/machinery/coffeemaker/medbay
	icon_state = "coffeemaker-med"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/medbay

/obj/machinery/coffeemaker/botany
	icon_state = "coffeemaker-hyd"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/botany

/obj/machinery/coffeemaker/security
	icon_state = "coffeemaker-sec"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/security

/obj/machinery/coffeemaker/research
	icon_state = "coffeemaker-sci"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/research

/obj/machinery/coffeemaker/engineering
	icon_state = "coffeemaker-eng"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/engineering

/obj/machinery/coffeemaker/command
	icon_state = "coffeemaker-com"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/command

/* ===================================================== */
/* ---------------------- Racks --------------------- */
/* ===================================================== */

ABSTRACT_TYPE(/obj/drink_rack)
/obj/drink_rack
	anchored = ANCHORED
	var/amount_on_rack = null
	var/max_amount = null
	var/contained = null
	var/contained_name = null
	var/icon_state_prefix = null

	get_desc(dist, mob/user)
		if (dist <= 2)
			. += "There's [(src.amount_on_rack > 0) ? src.amount_on_rack : "no" ] [src.contained_name][s_es(src.amount_on_rack)] on \the [src]."

	attackby(obj/item/W, mob/user)
		if (istype(W, src.contained) & src.amount_on_rack < max_amount)
			if (W.reagents.total_volume > 0)
				var/turf/T = get_turf(src)
				W.reagents.reaction(T)
				boutput(user, "The [src.contained_name] wasn't empty! You spill its contents on the floor.")
			user.drop_item()
			qdel(W)
			src.amount_on_rack ++
			boutput(user, "You place \the [src.contained_name] back onto \the [src].")
			src.UpdateIcon()
		else return ..()

	attack_hand(mob/user)
		src.add_fingerprint(user)
		if (src.amount_on_rack <= 0)
			user.show_text("\The [src] doesn't have any [src.contained_name]s left, doofus!", "red")
		else
			boutput(user, "You take \an [src.contained_name] off of \the [src].")
			src.amount_on_rack--
			user.put_in_hand_or_drop(new contained)
			src.UpdateIcon()

	update_icon()
		src.icon_state = "[src.icon_state_prefix][src.amount_on_rack]" //sets the icon_state to the ammount on the rack
		return

/obj/drink_rack/cup
	name = "coffee cup rack"
	desc = "It's a rack to hang your fancy coffee cups." //*tip
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "cuprack7" //changes based on cup_ammount in updateicon
	amount_on_rack = 7
	max_amount = 7
	contained = /obj/item/reagent_containers/food/drinks/espressocup
	contained_name = "espresso cup"
	icon_state_prefix = "cuprack"

/obj/drink_rack/mug
	name = "coffee mug rack"
	desc = "It's a rack to hang your not-so-fancy coffee cups." //*tip
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "mugrack4" //changes based on cup_ammount in updateicon
	amount_on_rack = 4
	max_amount = 4
	contained = /obj/item/reagent_containers/food/drinks/mug
	contained_name = "mug"
	icon_state_prefix = "mugrack"

