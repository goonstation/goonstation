/*
Contains Wall Trophy code

Subtypes:
	Fish wall trophy


*/


//wall trophy
//this is literally just plate code but with wall attachment

/obj/item/wall_trophy
	name = "Wall Trophy"
	desc = "You shouldn't be seeing this probably"
	icon = 'icons/obj/items/fishing_gear.dmi'
	icon_state = "wall_trophy"
	item_state = "wall_trophy"


	//do we have something attached?
	var/item_added = FALSE
	//what items are allowed to be attached?
	var/allowed_item = /obj/item/
	//can we un anchor the object?
	var/can_unanchor = TRUE
	//for spawning it with an item
	var/intitial_item = null
	//automatically anchors the item that gets attached to it
	var/auto_anchor = FALSE

	New()
		..()

	//procs

	//attaches item to the trophy
	//Some sprites look pretty janky if you try to put it in centre so it's based on clicks
	proc/add_item(var/obj/item/W, var/mob/user, click_params)
		if (W == src)
			boutput(user, "<span class='notice'>You can't attach [W] to another [src]. Duh.</span>")
			return
		if (!istype(W, allowed_item))
			boutput(user, "<span class='notice'>You can't attach [W] to the [src].</span>")
			return
		if (item_added)
			boutput(user,"<span class='notice'>There is already something attached!</span>")
			return
		if(W.cant_drop)
			boutput(user, "<span class='alert'>You can't attach [W] to the [src]! It's attached to you!</span>")
			return
		src.place_on(W, user, click_params)
		W.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		W.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		W.event_handler_flags |= NO_MOUSEDROP_QOL
		W.set_loc(src)
		src.vis_contents += W
		src.UpdateIcon()
		item_added = TRUE
		boutput(user, "<span class='notice'>You attach [W] to \the [src].</span>")
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
		boutput(user,"<span class='notice'>You unattach [W] from \the [src].</span>")

	//attacked by item
	attackby(var/obj/item/W, var/mob/user, click_params)
		add_item(W, user, click_params)
		return

	//unattaching the trophy from the wall
	attack_hand(var/mob/user)
		if (src.anchored)
			if (!can_unanchor) return //checks if item can be unanchored
			src.anchored = FALSE
		. = ..()

	Exited(var/obj/item/W)
		remove_item(W)
		. = ..()

	//fish trophy available for fishing tickets
	fish_trophy
		name = "'Biggest catch' Fish Wall Mount"
		desc = "This Wall Mount can be hung on a wall and display fish for everyone to see. Show off your catch!"
		allowed_item = /obj/item/fish/
