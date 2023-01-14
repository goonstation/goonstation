TYPEINFO(/obj/machinery/deep_fryer)
	mats = 20

/obj/machinery/deep_fryer
	name = "Deep Fryer"
	desc = "An industrial deep fryer.  A big hit at state fairs!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer0"
	anchored = 1
	density = 1
	flags = NOSPLASH
	status = REQ_PHYSICAL_ACCESS
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS
	var/atom/movable/fryitem = null
	var/cooktime = 0
	var/frytemp = 185 + T0C //365 F is a good frying temp, right?
	var/max_wclass = W_CLASS_NORMAL

	New()
		..()
		UnsubscribeProcess()
		src.create_reagents(50)

		reagents.add_reagent("grease", 25)
		reagents.set_reagent_temp(src.frytemp)

	attackby(obj/item/W, mob/user)
		if (isghostdrone(user) || isAI(user))
			boutput(user, "<span class='alert'>The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
			return
		if (W.cant_drop) //For borg held items
			boutput(user, "<span class='alert'>You can't put that in [src] when it's attached to you!</span>")
			return
		if (src.fryitem)
			boutput(user, "<span class='alert'>There is already something in the fryer!</span>")
			return
		if (istype(W, /obj/item/reagent_containers/food/snacks/shell/deepfry))
			boutput(user, "<span class='alert'>Your cooking skills are not up to the legendary Doublefry technique.</span>")
			return

		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if (!W.reagents.total_volume)
				boutput(user, "<span class='alert'>There is nothing in [W] to pour!</span>")

			else
				logTheThing(LOG_CHEMISTRY, user, "pours chemicals [log_reagents(W)] into the [src] at [log_loc(src)].") // Logging for the deep fryer (Convair880).
				src.visible_message("<span class='notice'>[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				W.reagents.trans_to(src, W:amount_per_transfer_from_this)
				if (!W.reagents.total_volume) boutput(user, "<span class='alert'><b>[W] is now empty.</b></span>")

			return

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting) return
			user.lastattacked = src
			src.visible_message("<span class='alert'><b>[user] is trying to shove [G.affecting] into [src]!</b></span>")
			if(!do_mob(user, G.affecting) || !W)
				return

			if(ismonkey(G.affecting))
				logTheThing(LOG_COMBAT, user, "shoves [constructTarget(G.affecting,"combat")] into the [src] at [log_loc(src)].") // For player monkeys (Convair880).
				src.visible_message("<span class='alert'><b>[user] shoves [G.affecting] into [src]!</b></span>")
				src.start_frying(G.affecting)
				G.affecting.death(FALSE)
				qdel(W)
				return

			logTheThing(LOG_COMBAT, user, "shoves [constructTarget(G.affecting,"combat")]'s face into the [src] at [log_loc(src)].")
			src.visible_message("<span class='alert'><b>[user] shoves [G.affecting]'s face into [src]!</b></span>")
			src.reagents.reaction(G.affecting, TOUCH)

			return

		if (W.w_class > src.max_wclass || istype(W, /obj/item/storage) || istype(W, /obj/item/storage/secure) || istype(W, /obj/item/plate))
			boutput(user, "<span class='alert'>There is no way that could fit!</span>")
			return

		src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
		user.u_equip(W)
		W.dropped(user)
		src.start_frying(W)
		SubscribeToProcess()

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user))
			return src.Attackby(W, user)
		return ..()

	onVarChanged(variable, oldval, newval)
		if (variable == "fryitem")
			if (!oldval && newval)
				SubscribeToProcess()
			else if (oldval && !newval)
				UnsubscribeProcess()
			src.UpdateIcon()

	update_icon()
		if (src.fryitem)
			src.icon_state = "fryer1"
		else
			src.icon_state = "fryer0"

	attack_hand(mob/user)
		if (isghostdrone(user))
			boutput(user, "<span class='alert'>The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
			return
		if (!src.fryitem)
			boutput(user, "<span class='alert'>There is nothing in the fryer.</span>")
			return

		if (src.cooktime < 5)
			boutput(user, "<span class='alert'>Frying things takes time! Be patient!</span>")
			return

		user.visible_message("<span class='notice'>[user] removes [src.fryitem] from [src]!</span>", "<span class='notice'>You remove [src.fryitem] from [src].</span>")
		src.eject_food()
		return

	process()
		if (status & BROKEN)
			UnsubscribeProcess()
			return

		if (!src.reagents.has_reagent("grease"))
			src.reagents.add_reagent("grease", 25)

		//DaerenNote: so it turned out hellmixes + self-heating mixes constantly got dragged to the src.frytemp
		//so i fixed that, heated stuff won't get cooled by the fryer now b/c thats lame + i am not going to thermodynamics this shit to model equilibrium
		if (src.frytemp >= src.reagents.total_temperature)
			src.reagents.set_reagent_temp(src.frytemp) // I'd love to have some thermostat logic here to make it heat up / cool down slowly but aaaaAAAAAAAAAAAAA (exposing it to the frytemp is too slow)

		if(!src.fryitem)
			UnsubscribeProcess()
			return
		else
			src.cooktime++

		if (src.fryitem.material?.mat_id == "ice" && !ON_COOLDOWN(src, "ice_explosion", 10 SECONDS))
			qdel(src.fryitem)
			src.fryitem = null
			src.visible_message("<span class='alert'>The ice reacts violently with the hot oil!</span>")
			fireflash(src, 3)
			UnsubscribeProcess()
			return

		if (!src.fryitem.reagents)
			src.fryitem.create_reagents(50)


		src.reagents.trans_to(src.fryitem, 2)

		if (src.cooktime < 60)

			if (src.cooktime == 30)
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				src.visible_message("<span class='notice'>[src] dings!</span>")
			else if (src.cooktime == 60) //Welp!
				src.visible_message("<span class='alert'>[src] emits an acrid smell!</span>")
		else if(src.cooktime >= 120)

			if((src.cooktime % 5) == 0 && prob(10))
				src.visible_message("<span class='alert'>[src] sprays burning oil all around it!</span>")
				fireflash(src, 1)

		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.fryitem)
			return 0
		user.visible_message("<span class='alert'><b>[user] climbs into the deep fryer! How is that even possible?!</b></span>")

		src.start_frying(user)
		user.TakeDamage("head", 0, 175)
		if(user.reagents && user.reagents.has_reagent("dabs"))
			var/amt = user.reagents.get_reagent_amount("dabs")
			user.reagents.del_reagent("dabs")
			user.reagents.add_reagent("deepfrieddabs",amt)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/start_frying(atom/movable/frying) //might be an item, might be a mob, might be a fucking singularity
		if (!istype(frying))
			return
		frying.set_loc(src)
		src.cooktime = 0
		src.fryitem = frying
		src.UpdateIcon()
		SubscribeToProcess()

	proc/fryify(atom/movable/thing, burnt=FALSE)
		var/obj/item/reagent_containers/food/snacks/shell/deepfry/fryholder = new(src)

		if(burnt)
			if (ismob(thing))
				var/mob/M = thing
				M.ghostize()
			else
				for (var/mob/M in thing)
					M.ghostize()
			qdel(thing)
			thing = new /obj/item/reagent_containers/food/snacks/yuckburn (src)
			if (!thing.reagents)
				thing.create_reagents(50)

			thing.reagents.add_reagent("grease", 50)
			fryholder.desc = "A heavily fried...something.  Who can tell anymore?"
		if (istype(thing, /obj/item/reagent_containers/food/snacks))
			fryholder.food_effects += thing:food_effects

		var/icon/composite = new(thing.icon, thing.icon_state)
		for(var/O in thing.underlays + thing.overlays)
			var/image/I = O
			composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)

		switch(src.cooktime)
			if (0 to 15)
				fryholder.name = "lightly-fried [thing.name]"
				fryholder.color = ( rgb(166,103,54) )


			if (16 to 49)
				fryholder.name = "fried [thing.name]"
				fryholder.color = ( rgb(103,63,24) )

			if (50 to 59)
				fryholder.name = "deep-fried [thing.name]"
				fryholder.color = ( rgb(63, 23, 4) )

			else
				fryholder.color = ( rgb(33,19,9) )
				fryholder.reagents.maximum_volume += 25
				fryholder.reagents.add_reagent("friedessence",25)

		fryholder.charcoaliness = src.cooktime
		fryholder.icon = composite
		fryholder.overlays = thing.overlays
		if (isitem(thing))
			var/obj/item/item = thing
			fryholder.bites_left = item.w_class
			fryholder.w_class = item.w_class
		else
			fryholder.bites_left = 5
		if (ismob(thing))
			fryholder.w_class = W_CLASS_BULKY
		if(thing.reagents)
			fryholder.reagents.maximum_volume += thing.reagents.total_volume
			thing.reagents.trans_to(fryholder, thing.reagents.total_volume)
		fryholder.reagents.my_atom = fryholder

		thing.set_loc(fryholder)
		return fryholder

	proc/eject_food()
		if (!src.fryitem)
			UnsubscribeProcess()
			return

		var/obj/item/reagent_containers/food/snacks/shell/deepfry/fryholder = src.fryify(src.fryitem, src.cooktime >= 60)
		fryholder.set_loc(get_turf(src))

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.fryitem)
			src.fryitem = null
			src.UpdateIcon()
			for (var/obj/item/I in src) //Things can get dropped somehow sometimes ok
				I.set_loc(src.loc)
			UnsubscribeProcess()


	verb/drain()
		set src in oview(1)
		set name = "Drain Oil"
		set desc = "Drain and replenish fryer oils."
		set category = "Local"

		if (src.reagents)
			if (isobserver(usr) || isintangible(usr)) // Ghosts probably shouldn't be able to take revenge on a traitor chef or whatever (Convair880).
				return
			else
				src.reagents.clear_reagents()
				src.visible_message("<span class='alert'>[usr] drains and refreshes the frying oil!</span>")

		return
