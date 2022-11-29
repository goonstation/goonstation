/** Arc Electroplater
  * Applies materials directly to items
  */
/obj/machinery/arc_electroplater
	name = "Arc Electroplater"
	desc = "An industrial arc electroplater.  It uses strong currents to coat a target object with a provided material."
	icon = 'icons/obj/crafting.dmi'
	icon_state = "plater0"
	anchored = 1
	density = 1
	flags = NOSPLASH
	mats = 20
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
			boutput(user, "<span class='alert'>You can't plate yourself without a source material!</span>")
			return 0
		user.visible_message("<span class='alert'><b>[user] jumps into \the [src].</b></span>", "<span class='alert'><b>You jump into \the [src].</b></span>")
		var/obj/statue = user.become_statue(src.my_bar.material, survive=TRUE)
		user.TakeDamage("All", burn=200)
		qdel(src.my_bar)
		src.my_bar = null
		statue.set_loc(src)
		src.cooktime = 0
		src.target_item = statue
		src.icon_state = "plater1"
		SubscribeToProcess()
		return 1

	attackby(obj/item/W, mob/user)
		if (isghostdrone(user) || isAI(user))
			boutput(user, "<span class='alert'>[src] refuses to interface with you!</span>")
			return
		if (W.cant_drop) //For borg held items
			boutput(user, "<span class='alert'>You can't put that in [src] when it's attached to you!</span>")
			return

		if(istype(W, /obj/item/raw_material))
			boutput(user, "<span class='alert'>You need to process \the [W] first before using it in [src]!</span>")
			return

		if(istype(W,/obj/item/material_piece))
			if(my_bar)
				boutput(user, "<span class='alert'>There is already a source material loaded in [src]!</span>")
				return
			else if(W.amount == 1)
				src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
				user.u_equip(W)
				W.set_loc(src)
				W.dropped(user)
				src.my_bar = W
				return
			else
				src.visible_message("<span class='notice'>[user] loads one of the [W] into the [src].</span>")
				var/obj/item/material_piece/single_bar = W.split_stack(1)
				single_bar.set_loc(src)
				single_bar.dropped(user)
				src.my_bar = single_bar
				return

		if (src.target_item)
			boutput(user, "<span class='alert'>There is already something in [src]!</span>")
			return
		if (W.material)
			boutput(user, "<span class='alert'>You can't plate something that already has a material!</span>")
			return

		if (istype(W, /obj/item/grab))
			boutput(user, "<span class='alert'>That wouldn't possibly fit!</span>")
			return

		if (istype(W, /obj/item/implant))
			boutput(user, "<span class='alert'>You can't plate something this tiny!</span>")
			return

		if (W.w_class > src.max_wclass || istype(W, /obj/item/storage/secure))
			boutput(user, "<span class='alert'>There is no way that could fit!</span>")
			return

		if(W.amount > 1)
			boutput(user, "<span class='alert'>You can only plate one thing at a time!</span>")
			return

		if(my_bar)
			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			src.cooktime = 0
			src.target_item = W
			src.icon_state = "plater1"
			SubscribeToProcess()
			return
		else
			boutput(user, "<span class='alert'>You can't plate something without a source material!</span>")
			return

	onVarChanged(variable, oldval, newval)
		if (variable == "target_item")
			if (!oldval && newval)
				SubscribeToProcess()
			else if (oldval && !newval)
				UnsubscribeProcess()

	attack_hand(mob/user)
		if (isghostdrone(user))
			boutput(user, "<span class='alert'>The [src] refuses to interface with you!</span>")
			return

		if (!src.my_bar)
			boutput(user, "<span class='alert'>There is nothing in the plater to remove.</span>")
			return

		if (src.cooktime < 5 && src.target_item)
			boutput(user, "<span class='alert'>Plating things takes time! Be patient!</span>")
			return

		user.visible_message("<span class='notice'>[user] removes [src.my_bar] from [src]!</span>", "<span class='notice'>You remove [src.my_bar] from [src].</span>")
		src.eject_item()
		return

	process()
		if (status & BROKEN)
			UnsubscribeProcess()
			return

		if(!src.target_item)
			UnsubscribeProcess()
			return
		else
			src.cooktime++

		if (src.cooktime == 5)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			src.visible_message("<span class='notice'>[src] dings!</span>")
			eject_item()

		return

	proc/eject_item()
		if(src.my_bar && !src.target_item)
			my_bar.set_loc(src.loc)
			my_bar = null

		if (!src.target_item)
			src.icon_state = "plater0"
			UnsubscribeProcess()
			return

		if(my_bar?.material && isnull(target_item.material))
			target_item.setMaterial(my_bar.material)
			qdel(my_bar)
		my_bar = null

		for (var/atom/movable/AM in src) //Things can get dropped somehow sometimes ok
			AM.set_loc(src.loc)

		src.target_item = null
		src.icon_state = "plater0"
		UnsubscribeProcess()
		return
