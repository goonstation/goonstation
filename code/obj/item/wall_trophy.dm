/*
Contains Wall Trophy code

Subtypes:
	Fish wall trophy
*/


//wall trophy
//some things are taken from plate code

/obj/item/wall_trophy
	name = "\improper Wall Trophy"
	desc = "Simple wall trophy that can display items on a wall."
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "wall_trophy"
	item_state = "wall_trophy"

	event_handler_flags = NO_MOUSEDROP_QOL

	///do we have something attached?
	var/item_added = FALSE
	///what items are allowed to be attached?
	var/allowed_item = /obj/item/
	///can we un anchor the object?
	var/can_unanchor = TRUE
	///for spawning it with an item
	var/initial_item = null
	///automatically anchors the item that gets attached to it
	var/auto_anchor = FALSE

	New()
		..()
		/*for mapping, checks for item in initial items and adds them to the trophy

		*/
		BLOCK_SETUP(BLOCK_BOOK)
		if (initial_item)
			. = src.add_item(new initial_item(src.loc))
			if (!.)
				stack_trace("Failed to add item to trophy with initial items. [identify_object(src)]- likely can not accept this kind of object")

	//procs

	//attaches item to the trophy
	proc/add_item(var/obj/item/W, var/mob/user, params)
		. = FALSE
		if (W == src)
			boutput(user, SPAN_NOTICE("You can't attach [W] to another [src]. Duh."))
			return
		if (!istype(W, allowed_item))
			boutput(user, SPAN_NOTICE("You can't attach [W] to \the [src]."))
			return
		if (item_added)
			boutput(user,SPAN_NOTICE("There is already something attached!"))
			return
		if(W.cant_drop)
			boutput(user, SPAN_ALERT("You can't attach [W] to \the [src]! It's attached to you!"))
			return
		. = TRUE
		src.place_on(W, user, params)
		W.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		W.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		W.event_handler_flags |= NO_MOUSEDROP_QOL
		W.set_loc(src)
		src.vis_contents += W
		src.UpdateIcon()
		item_added = TRUE
		boutput(user, SPAN_NOTICE("You attach [W] to \the [src]."))
		if (auto_anchor)
			W.anchored = TRUE

	//removes item
	proc/remove_item(var/obj/item/W)
		var/mob/user
		MOVE_OUT_TO_TURF_SAFE(W, src)
		W.appearance_flags = initial(W.appearance_flags)
		W.vis_flags = initial(W.vis_flags)
		W.event_handler_flags = initial(W.event_handler_flags)
		src.vis_contents -= W
		src.UpdateIcon()
		item_added = FALSE
		boutput(user,SPAN_NOTICE("You unattach [W] from \the [src]."))


	//attacked by item
	attackby(var/obj/item/W, var/mob/user, click_params)
		add_item(W, user, click_params)
		return

	//attaching trophy to the wall
	afterattack(var/turf/simulated/wall/T, var/mob/user)
		if (istype(T))
			. = T.attach_item(user, src)
			if (.)
				playsound(src, 'sound/impact_sounds/Wood_Tap.ogg', 50, TRUE)
		. = ..()

	//unattaching the trophy from the wall
	attack_hand(var/mob/user)
		if (src.anchored)
			if (!can_unanchor) return //checks if item can be unanchored
			src.anchored = FALSE
			playsound(src, 'sound/impact_sounds/Wood_Tap.ogg', 50, TRUE)
			boutput(user,"You unattach \the [src].")
		. = ..()

	Exited(var/obj/item/W)
		remove_item(W)
		. = ..()

	//fish wall mount
	fish_trophy
		name = "\improper 'Biggest catch' Fish Wall Mount"
		desc = "This Wall Mount can be hung on a wall and display fish for everyone to see. Show off your catch!"
		allowed_item = /obj/item/reagent_containers/food/fish
