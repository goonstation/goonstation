/obj/machinery/deep_fryer
	name = "Deep Fryer"
	desc = "An industrial deep fryer.  A big hit at state fairs!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer0"
	anchored = 1
	density = 1
	flags = NOSPLASH
	mats = 20
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS
	var/obj/item/fryitem = null
	var/cooktime = 0
	var/frytemp = 185 + T0C //365 F is a good frying temp, right?
	var/max_wclass = 3

	New()
		..()
		UnsubscribeProcess()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

		R.add_reagent("grease", 25)
		R.set_reagent_temp(src.frytemp)

	attackby(obj/item/W as obj, mob/user as mob)
		if (isghostdrone(user) || isAI(user))
			boutput(usr, "<span class='alert'>The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
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
				logTheThing("combat", user, null, "pours chemicals [log_reagents(W)] into the [src] at [log_loc(src)].") // Logging for the deep fryer (Convair880).
				src.visible_message("<span class='notice'>[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
				playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 100, 1)
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
				logTheThing("combat", user, G.affecting, "shoves %target% into the [src] at [log_loc(src)].") // For player monkeys (Convair880).
				src.visible_message("<span class='alert'><b>[user] shoves [G.affecting] into [src]!</b></span>")
				src.icon_state = "fryer1"
				src.cooktime = 0
				src.fryitem = G.affecting
				SubscribeToProcess()
				G.affecting.set_loc(src)
				G.affecting.death( 0 )
				qdel(W)
				return

			logTheThing("combat", user, G.affecting, "shoves %target%'s face into the [src] at [log_loc(src)].")
			src.visible_message("<span class='alert'><b>[user] shoves [G.affecting]'s face into [src]!</b></span>")
			src.reagents.reaction(G.affecting, TOUCH)

			return

		if (W.w_class > src.max_wclass || istype(W, /obj/item/storage) || istype(W, /obj/item/storage/secure) || istype(W, /obj/item/plate))
			boutput(user, "<span class='alert'>There is no way that could fit!</span>")
			return

		src.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>")
		user.u_equip(W)
		W.set_loc(src)
		W.dropped()
		src.cooktime = 0
		src.fryitem = W
		src.icon_state = "fryer1"
		SubscribeToProcess()
		return

	onVarChanged(variable, oldval, newval)
		if (variable == "fryitem")
			if (!oldval && newval)
				SubscribeToProcess()
			else if (oldval && !newval)
				UnsubscribeProcess()

	attack_hand(mob/user as mob)
		if (isghostdrone(user))
			boutput(usr, "<span class='alert'>The [src] refuses to interface with you, as you are not a properly trained chef!</span>")
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

		if (!src.fryitem.reagents)
			var/datum/reagents/R = new/datum/reagents(50)
			src.fryitem.reagents = R
			R.my_atom = src.fryitem


		src.reagents.trans_to(src.fryitem, 2)

		if (src.cooktime < 60)

			if (src.cooktime == 30)
				playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
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

		user.set_loc(src)
		src.cooktime = 0
		src.fryitem = user
		src.icon_state = "fryer1"
		user.TakeDamage("head", 0, 175)
		if(user.reagents && user.reagents.has_reagent("dabs"))
			var/amt = user.reagents.get_reagent_amount("dabs")
			user.reagents.del_reagent("dabs")
			user.reagents.add_reagent("deepfrieddabs",amt)
		SubscribeToProcess()
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/eject_food()
		if (!src.fryitem)
			UnsubscribeProcess()
			return

		var/obj/item/reagent_containers/food/snacks/shell/deepfry/fryholder = new /obj/item/reagent_containers/food/snacks/shell/deepfry(src)

		if (src.cooktime >= 60)
			if (ismob(src.fryitem))
				var/mob/M = src.fryitem
				M.ghostize()
			else
				for (var/mob/M in src.fryitem)
					M.ghostize()
			qdel(src.fryitem)
			src.fryitem = new /obj/item/reagent_containers/food/snacks/yuckburn (src)
			if (!src.fryitem.reagents)
				var/datum/reagents/R = new/datum/reagents(50)
				src.fryitem.reagents = R
				R.my_atom = src.fryitem

			src.fryitem.reagents.add_reagent("grease", 50)
			fryholder.desc = "A heavily fried...something.  Who can tell anymore?"
		else
			if (istype(src.fryitem, /obj/item/reagent_containers/food/snacks))
				fryholder.food_effects += fryitem:food_effects

		var/icon/composite = new(src.fryitem.icon, src.fryitem.icon_state)//, src.fryitem.dir, 1)
		for(var/O in src.fryitem.underlays + src.fryitem.overlays)
			var/image/I = O
			composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)

		switch(src.cooktime)
			if (0 to 15)
				fryholder.name = "lightly-fried [src.fryitem.name]"
				fryholder.color = ( rgb(166,103,54) )


			if (16 to 49)
				fryholder.name = "fried [src.fryitem.name]"
				fryholder.color = ( rgb(103,63,24) )

			if (50 to 59)
				fryholder.name = "deep-fried [src.fryitem.name]"
				fryholder.color = ( rgb(63, 23, 4) )

			else
				fryholder.color = ( rgb(33,19,9) )
				fryholder.reagents.maximum_volume += 25
				fryholder.reagents.add_reagent("friedessence",25)

		fryholder.charcoaliness = src.cooktime
		fryholder.icon = composite
		fryholder.overlays = fryitem.overlays
		fryholder.set_loc(get_turf(src))
		if (ismob(fryitem))
			fryholder.amount = 5
		else
			fryholder.amount = src.fryitem.w_class
		fryholder.reagents.maximum_volume += src.fryitem.reagents.total_volume
		src.fryitem.reagents.trans_to(fryholder, src.fryitem.reagents.total_volume)
		fryholder.reagents.my_atom = fryholder

		src.fryitem.set_loc(fryholder)

		src.fryitem = null
		src.icon_state = "fryer0"
		for (var/obj/item/I in src) //Things can get dropped somehow sometimes ok
			I.set_loc(src.loc)

		UnsubscribeProcess()
		return

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
