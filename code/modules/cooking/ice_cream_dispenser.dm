ADMIN_INTERACT_PROCS(/obj/submachine/ice_cream_dispenser, proc/add_flavor)
TYPEINFO(/obj/submachine/ice_cream_dispenser)
	mats = 18

/obj/submachine/ice_cream_dispenser
	name = "Ice Cream Dispenser"
	desc = "A machine designed to dispense space ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "ice_creamer0"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = NOSPLASH | TGUI_INTERACTIVE
	/// A list of reagent_ids we will dispense by default
	var/list/flavors = list("chocolate","vanilla","coffee")
	var/obj/item/reagent_containers/glass/beaker = null
	var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = null
	var/doing_a_thing = 0

	ui_interact(mob/user, datum/tgui/ui)
		if (src.beaker)
			SEND_SIGNAL(src.beaker.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "IceCreamMachine")
			ui.open()

	ui_static_data(mob/user)
		var/list/flavorsTemp = list()
		if(!flavors)
			return
		for(var/reagent in flavors)
			var/datum/reagent/fooddrink/current_reagent = reagents_cache[reagent]
			flavorsTemp.Add(list(list(
				name = current_reagent.name,
				id = current_reagent.id,
				colorR = current_reagent.fluid_r,
				colorG = current_reagent.fluid_g,
				colorB = current_reagent.fluid_b
			)))
		. = list(
			"flavors" = flavorsTemp
		)

	ui_data(mob/user)
		. = list(
			"beaker" = ui_describe_reagents(src.beaker),
			"has_cone" = src.cone ? TRUE : FALSE
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return

		if (istype(src.loc, /turf) && (( BOUNDS_DIST(src, usr) == 0) || issilicon(usr) || isAI(usr)))
			if (!isliving(usr) || iswraith(usr) || isintangible(usr))
				return
			if (is_incapacitated(usr) || usr.restrained())
				return

		src.add_fingerprint(usr)
		switch(action)
			if("eject_cone")
				var/obj/item/target = src.cone
				if (!target)
					boutput(usr, SPAN_ALERT("There is no cone loaded!"))
					return
				usr.put_in_hand_or_eject(target)
				boutput(usr, SPAN_NOTICE("You have removed the cone from [src]."))
				src.cone = null
				src.UpdateIcon()
				. = TRUE

			if("eject_beaker")
				var/obj/item/target = src.beaker
				if (!target)
					boutput(usr, SPAN_ALERT("There is no beaker loaded!"))
					return

				usr.put_in_hand_or_eject(target)
				boutput(usr, SPAN_NOTICE("You have removed the beaker from [src]."))
				src.beaker = null
				src.UpdateIcon()
				. = TRUE

			if("insert_beaker")
				var/obj/item/reagent_containers/newbeaker = usr.equipped()
				if (istype(newbeaker, /obj/item/reagent_containers/glass/) || istype(newbeaker, /obj/item/reagent_containers/food/drinks/))
					if(!newbeaker.cant_drop)
						usr.drop_item()
						newbeaker.set_loc(src)
					src.beaker = newbeaker
					src.UpdateIcon()
					. = TRUE

			if("make_ice_cream")
				if(!cone)
					boutput(usr, SPAN_ALERT("There is no cone loaded!"))
					return

				var/flavor = params["flavor"]
				var/obj/item/reagent_containers/food/snacks/ice_cream/newcream = new(src)
				if(flavor == "beaker")
					if(!beaker.reagents.total_volume)
						boutput(usr, SPAN_ALERT("The beaker is empty!"))
						return

					beaker.reagents.trans_to(newcream,40)
				else if(flavor in src.flavors)
					newcream.reagents.add_reagent(flavor,40)

				usr.put_in_hand_or_eject(newcream)
				src.cone = null
				src.UpdateIcon()
				. = TRUE


	attack_ai(var/mob/user as mob)
		return ui_interact(user)

	attackby(obj/item/W, mob/user)
		if (W.cant_drop) // For borg held items
			boutput(user, SPAN_ALERT("You can't put that in \the [src] when it's attached to you!"))
			return

		if (istype(W, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
			if(src.cone)
				boutput(user, "There is already a cone loaded.")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.cone = W
				boutput(user, SPAN_NOTICE("You load the cone into [src]."))

			src.UpdateIcon()
			tgui_process.update_uis(src)

		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.beaker)
				boutput(user, "There is already a beaker loaded.")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.beaker = W
				boutput(user, SPAN_ALERT("You load [W] into [src]."))

			src.UpdateIcon()
			tgui_process.update_uis(src)
		else ..()

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if ((istype(W, /obj/item/reagent_containers/food/snacks/ice_cream_cone) || istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/)) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	update_icon()
		if(src.beaker)
			src.overlays += image(src.icon, "ice_creamer_beaker")
		else
			src.overlays.len = 0

		src.icon_state = "ice_creamer[src.cone ? "1" : "0"]"

		return

	proc/add_flavor()
		set name = "Add flavor"

		var/datum/reagent/reagent = pick_reagent(usr)
		if (!reagent)
			return

		if (reagent.id in src.flavors)
			boutput(usr, "[src] already has flavor [reagent.name]")
			return

		src.flavors += reagent.id
		src.update_static_data_for_all_viewers()
