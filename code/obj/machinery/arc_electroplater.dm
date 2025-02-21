/** Arc Electroplater
  * Applies materials directly to items
  */
TYPEINFO(/obj/machinery/arc_electroplater)
	mats = 20

/obj/machinery/arc_electroplater
	name = "\improper Arc Electroplater"
	desc = "An industrial arc electroplater. It uses strong currents to coat a target object with a provided material."
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
			boutput(user, SPAN_ALERT("You try to turn on [src] and jump into it, but it is not working."))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] jumps into [src].</b>"), SPAN_ALERT("<b>You jump into [src].</b>"))
		var/obj/statue = user.become_statue(src.my_bar.material, survive=TRUE)
		user.TakeDamage("All", burn=200)
		qdel(src.my_bar)
		src.my_bar = null
		statue.set_loc(src)
		src.cooktime = 0
		src.target_item = statue
		src.SubscribeToProcess()
		src.UpdateIcon()
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

		if (src.status & (BROKEN|NOPOWER))
			boutput(usr, SPAN_ALERT("[src] doesn't seem to be working.</span>"))
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

		if(istype(W, /obj/item/assembly/complete))
			//holy heck, blacklisting from the arcplater should certainly be handled by a flag
			boutput(user, SPAN_ALERT("[W] can't be plated in [src]!"))
			return

		if(W.amount > 1)
			boutput(user, SPAN_ALERT("You can only plate one thing at a time!"))
			return

		if(my_bar)
			src.visible_message(SPAN_NOTICE("[user] loads [W] into [src]."))
			if (status & (BROKEN|NOPOWER))
				boutput(user, SPAN_ALERT("You try to turn on [src] but it doesn't seem to be working."))
				src.eject_contents(FALSE)
				return
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			src.power_usage = initial(src.power_usage)
			src.cooktime = 0
			src.target_item = W
			src.SubscribeToProcess()
			src.UpdateIcon()
			return
		else
			boutput(user, SPAN_ALERT("You can't plate something without a source material!"))
			return

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
		src.my_bar.set_loc(src.loc)
		src.my_bar = null
		return

	process()
		if ((status & (BROKEN|NOPOWER)) && (src.my_bar || src.target_item))
			src.eject_contents(FALSE)
			return

		if(src.status & BROKEN)
			return // don't unsubscribe if broken to maintain equipment faults

		if(!src.target_item)
			UnsubscribeProcess()
			return

		if (src.cooktime >= 5)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.visible_message(SPAN_NOTICE("[src] dings!"))
			src.eject_contents(TRUE)

		src.cooktime++
		. = ..()

	proc/eject_contents(successful)
		if(!successful && (src.my_bar || src.target_item))
			animate_shake(src, 3, rand(2,5), rand(2,5))
			if (status & NOPOWER)
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 100)
				src.visible_message("[src] buzzes as it spits out everything inside it, and completely runs out of power.")
			if (status & BROKEN)
				playsound(src.loc, 'sound/machines/hydraulic.ogg', 100)
				src.visible_message("[src] spits out everything inside it as it breaks down!")

		if(src.my_bar && !src.target_item)
			src.my_bar.set_loc(src.loc)
			src.my_bar = null

		if (!src.target_item)
			src.UpdateIcon()
			UnsubscribeProcess()
			return

		if(my_bar?.material && isnull(target_item.material) && successful)
			target_item.setMaterial(my_bar.material)
			qdel(my_bar)
		src.my_bar = null

		for (var/atom/movable/AM in src) //Things can get dropped somehow sometimes ok
			AM.set_loc(src.loc)

		src.target_item = null
		UnsubscribeProcess()
		src.UpdateIcon()
		return

/obj/machinery/arc_electroplater/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
			src.set_broken()
		if(3)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				src.set_broken()

/obj/machinery/arc_electroplater/bullet_act(obj/projectile/P)
	if(P.proj_data.damage_type & (D_KINETIC | D_PIERCING | D_SLASHING))
		if(prob(P.power * P.proj_data?.ks_ratio / 2))
			src.set_broken()
	..()

/obj/machinery/arc_electroplater/power_change()
	..()
	if (src.status & (BROKEN|NOPOWER))
		if(src.target_item || src.my_bar)
			src.eject_contents(FALSE)
	if (src.status & BROKEN)
		src.power_usage = 100 WATTS // lower power usage while broken
		src.SubscribeToProcess()
	src.power_usage = initial(src.power_usage)
	src.UpdateIcon()

/obj/machinery/arc_electroplater/update_icon()
	if ((src.status & BROKEN) && (src.status & NOPOWER))
		src.icon_state = "plater-broken-nopower"
		return
	if (src.status & BROKEN)
		src.icon_state = "plater-broken"
		return
	if (src.status & NOPOWER)
		src.icon_state = "plater-nopower"
		return
	if (src.target_item)
		src.icon_state = "plater1"
		return
	src.icon_state = "plater0"

/obj/machinery/arc_electroplater/set_broken(mob/user)
	. = ..()
	if(.) return
	AddComponent(/datum/component/equipment_fault/embers, tool_flags = TOOL_WELDING | TOOL_WRENCHING | TOOL_SCREWING)
	playsound(src, 'sound/impact_sounds/Machinery_Break_1.ogg', 50, 1)
