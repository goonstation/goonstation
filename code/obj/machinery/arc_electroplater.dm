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
	var/obj/item/target_item = null
	var/cooktime = 0
	var/max_wclass = 3
	var/obj/item/material_piece/my_bar = null

	New()
		..()
		UnsubscribeProcess()

	attackby(obj/item/W as obj, mob/user as mob)
		if (isghostdrone(user) || isAI(user))
			boutput(usr, "<span class='alert'>[src] refuses to interface with you!</span>")
			return
		if (W.cant_drop) //For borg held items
			boutput(user, "<span class='alert'>You can't put that in [src] when it's attached to you!</span>")
			return

		if(istype(W,/obj/item/material_piece/))
			if(my_bar)
				boutput(user, "<span class='alert'>There is already a source material loaded in [src]!</span>")
				return
			else
				src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
				user.u_equip(W)
				W.set_loc(src)
				W.dropped()
				src.my_bar = W
				return

		if (src.target_item)
			boutput(user, "<span class='alert'>There is already something in [src]!</span>")
			return
		if (W.material)
			boutput(user, "<span class='alert'>You can't plate something that already has a material!.</span>")
			return

		if (istype(W, /obj/item/grab))
			boutput(user, "<span class='alert'>That wouldn't possibly fit!</span>")
			return

		if (W.w_class > src.max_wclass || istype(W, /obj/item/storage) || istype(W, /obj/item/storage/secure) || istype(W, /obj/item/plate)) //can't do plates because of material duping with breaking them over your head
			boutput(user, "<span class='alert'>There is no way that could fit!</span>")
			return

		if(W.amount > 1)
			boutput(user, "<span class='alert'>You can only plate one thing at a time!</span>")
			return

		if(my_bar)
			src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			W.dropped()
			src.cooktime = 0
			src.target_item = W
			src.icon_state = "plater1"
			SubscribeToProcess()
			return
		else
			boutput(user, "<span class='alert'>You can't plate something without a source material!.</span>")
			return

	onVarChanged(variable, oldval, newval)
		if (variable == "target_item")
			if (!oldval && newval)
				SubscribeToProcess()
			else if (oldval && !newval)
				UnsubscribeProcess()

	attack_hand(mob/user as mob)
		if (isghostdrone(user))
			boutput(usr, "<span class='alert'>The [src] refuses to interface with you!</span>")
			return
		if (!src.target_item)
			boutput(user, "<span class='alert'>There is nothing in the plater to remove.</span>")
			return

		if (src.cooktime < 5)
			boutput(user, "<span class='alert'>Plating things takes time! Be patient!</span>")
			return

		user.visible_message("<span class='notice'>[user] removes [src.target_item] from [src]!</span>", "<span class='notice'>You remove [src.target_item] from [src].</span>")
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
			playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
			src.visible_message("<span class='notice'>[src] dings!</span>")

		return

	proc/eject_item()
		if (!src.target_item)
			src.icon_state = "plater0"
			UnsubscribeProcess()
			return

		if(my_bar?.material)
			target_item.setMaterial(my_bar.material)
			pool(my_bar)
			my_bar = null

		for (var/obj/item/I in src) //Things can get dropped somehow sometimes ok
			I.set_loc(src.loc)

		src.target_item = null
		src.icon_state = "plater0"
		UnsubscribeProcess()
		return
