/** Arc Electroplater
  * Applies materials directly to items
  */
TYPEINFO(/obj/machinery/arc_electroplater)
	mats = 20

/obj/machinery/arc_electroplater
	name = "Arc Electroplater"
	desc = "An industrial arc electroplater.  It uses strong currents to coat a target object with a provided material."
	icon = 'icons/obj/crafting.dmi'
	icon_state = "plater0"
	anchored = ANCHORED
	density = 1
	flags = NOSPLASH
	power_usage = 10 KILO WATTS
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS
	var/obj/target_item = null
	var/cooktime = 0
	var/max_wclass = W_CLASS_BULKY
	var/obj/item/material_piece/my_bar = null

	New()
		..()
		UnsubscribeProcess()

	custom_suicide = TRUE
	suicide(mob/user)
		if (!src.user_can_suicide(user))
			return 0
		if(isnull(src.my_bar))
			boutput(user, SPAN_ALERT("You can't plate yourself without a source material!"))
			return 0
		if(status & (BROKEN|NOPOWER))
			boutput(user, SPAN_ALERT("You try to turn on \the [src] and jump into it, but it is out of power."))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] jumps into \the [src].</b>"), SPAN_ALERT("<b>You jump into \the [src].</b>"))
		var/obj/statue = user.become_statue(src.my_bar.material.getID(), survive=TRUE)
		user.TakeDamage("All", burn=200)
		qdel(src.my_bar)
		src.my_bar = null
		statue.set_loc(src)
		src.cooktime = 0
		src.target_item = statue
		src.icon_state = "plater1"
		SubscribeToProcess()
		return 1

	// It is time for borgs to get in on this hot electroplating action.
	MouseDrop_T(var/obj/item/W, var/mob/user)
		src.PlaterInteract(W, user)

	attackby(var/obj/item/W, var/mob/user)
		src.PlaterInteract(W, user)

	// See if I can piece together how to make this fly.
	proc/PlaterInteract(var/obj/item/W, var/mob/user)
		// Please don't drag the nano-crucible into the plater. Or any other machine or mob for that matter.
		if (!istype(W, /obj/item))
			return
		// Theres a suicide button for this.
		if (W == user)
			return
		// Do not attempt to plate objects from a distance.
		if (BOUNDS_DIST(user, src) > 0)
			return
		// Do not attempt to plate objects at a distance.
		if (BOUNDS_DIST(W, src) > 0)
			return
		// Do not attempt to plate distant objects.
		if (BOUNDS_DIST(W, user) > 0)
			return
		// No ghosts or AI or wraiths or blobs or flockminds shall use the plater. This is for the physical and the living.
		if (iswraith(user) || isintangible(user) || is_incapacitated(user)|| isghostdrone(user) || isAI(user))
			boutput(user, SPAN_ALERT("[src] refuses to interface with you!"))
			return
		if (W.cant_drop) //For borg held items
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return

		if(istype(W, /obj/item/raw_material))
			boutput(user, SPAN_ALERT("You need to process \the [W] first before using it in [src]!"))
			return

		if(istype(W,/obj/item/material_piece))
			if(my_bar)
				boutput(user, SPAN_ALERT("There is already a source material loaded in [src]!"))
				return
			else if(W.amount == 1)
				src.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
				user.u_equip(W)
				W.set_loc(src)
				W.dropped(user)
				src.my_bar = W
				return
			else
				src.visible_message(SPAN_NOTICE("[user] loads one of the [W] into the [src]."))
				var/obj/item/material_piece/single_bar = W.split_stack(1)
				single_bar.set_loc(src)
				single_bar.dropped(user)
				src.my_bar = single_bar
				return

		if (src.target_item)
			boutput(user, SPAN_ALERT("There is already something in [src]!"))
			return
		if (W.material)
			boutput(user, SPAN_ALERT("You can't plate something that already has a material!"))
			return

		if (istype(W, /obj/item/grab))
			boutput(user, SPAN_ALERT("That wouldn't possibly fit!"))
			return

		if (istype(W, /obj/item/implant))
			boutput(user, SPAN_ALERT("You can't plate something this tiny!"))
			return

		if (W.w_class > src.max_wclass || istype(W, /obj/item/storage/secure) || W.anchored)
			boutput(user, SPAN_ALERT("There is no way that could fit!"))
			return

		if(W.amount > 1)
			boutput(user, SPAN_ALERT("You can only plate one thing at a time!"))
			return

		if(my_bar)
			src.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
			if (status & (BROKEN|NOPOWER))
				boutput(usr, "<spawn class='alert'>You try to turn on \the [src] but it is out of power.</span>")
				src.eject_item(FALSE)
				return
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			src.cooktime = 0
			src.target_item = W
			src.icon_state = "plater1"
			SubscribeToProcess()
			return
		else
			boutput(user, SPAN_ALERT("You can't plate something without a source material!"))
			return

	onVarChanged(variable, oldval, newval)
		. = ..()
		if (variable == "target_item")
			if (!oldval && newval)
				SubscribeToProcess()
			else if (oldval && !newval)
				UnsubscribeProcess()

	attack_hand(mob/user)
		if (isghostdrone(user))
			boutput(user, SPAN_ALERT("The [src] refuses to interface with you!"))
			return

		if (!src.my_bar)
			boutput(user, SPAN_ALERT("There is nothing in the plater to remove."))
			return

		if (src.cooktime < 5 && src.target_item)
			boutput(user, SPAN_ALERT("Plating things takes time! Be patient!"))
			return

		user.visible_message(SPAN_NOTICE("[user] removes [src.my_bar] from [src]!"), SPAN_NOTICE("You remove [src.my_bar] from [src]."))
		src.eject_item()
		return

	process()
		if (status & (BROKEN|NOPOWER))
			UnsubscribeProcess()
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 100)
			animate_shake(src, 3, rand(2,5), rand(2,5))
			src.visible_message("\The [src] buzzes as it spits everything inside it, and completely runs out of power.")
			src.eject_item(FALSE)
			return

		if(!src.target_item)
			UnsubscribeProcess()
			return

		if (src.cooktime >= 5)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.visible_message(SPAN_NOTICE("[src] dings!"))
			src.eject_item()

		src.cooktime++
		use_power(src.power_usage)

		return

	proc/eject_item(successful = TRUE)
		if(src.my_bar && !src.target_item)
			my_bar.set_loc(src.loc)
			my_bar = null

		if (!src.target_item)
			src.icon_state = "plater0"
			UnsubscribeProcess()
			return

		if(my_bar?.material && isnull(target_item.material) && successful)
			target_item.setMaterial(my_bar.material)
			qdel(my_bar)
		my_bar = null

		for (var/atom/movable/AM in src) //Things can get dropped somehow sometimes ok
			AM.set_loc(src.loc)

		src.target_item = null
		src.icon_state = "plater0"
		UnsubscribeProcess()
		return
