/obj/machinery/shitty_grill
	name = "shitty grill"
	desc = "Is that a space heater? That doesn't look safe at all!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "shittygrill_off"
	anchored = 1
	density = 1
	flags = NOSPLASH
	mats = 20
	var/obj/item/grillitem = null
	var/cooktime = 0
	var/grilltemp_target = 250 + T0C // lets get it warm enough to cook
	var/grilltemp = 35 + T0C
	var/max_wclass = 3
	var/on = 0
	var/datum/light/light
	var/datum/particleSystem/barrelSmoke/particles

	New()
		..()
		UnsubscribeProcess()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src

		R.add_reagent("charcoal", 25)
		R.set_reagent_temp(src.grilltemp)
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(1)
		light.set_color(0.5, 0.3, 0)


	attackby(obj/item/W as obj, mob/user as mob)
		if (isghostdrone(user) || isAI(user))
			boutput(usr, "<span style=\"color:red\">The [src] refuses to interface with you, as you are not a bus driver!</span>")
			return
		if (src.grillitem)
			boutput(user, "<span style=\"color:red\">There is already something on the grill!</span>")
			return
		if (istype(W, /obj/item/reagent_containers/food/snacks/grill_holder))
			boutput(user, "<span style=\"color:red\">You wanna grill that again? Ask John how well that turns out.</span>")
			return
		if (src.grilltemp <= (200 + T0C))
			boutput(user, "<span style=\"color:red\">You gotta get them coals hot before you can grill anything. What are you, a nerd?</span>")
			return
		if (istype(W, /obj/item/relic))
			src.visible_message("<span style=\"color:blue\">[user] places [W] directly onto the hot, unyielding steel of [src].</span>")
			if (user.mind.karma >= 50)
				src.visible_message("<span style=\"color:blue\">The warm flames of [src] gently envelop [W], its energy radiating outward.</span>")
				for(var/mob/living/M in oview(5,src))
					M.HealDamage("All", 100, 100)
				user.u_equip(W)
				W.set_loc(src)
				W.dropped()
				src.cooktime = 0
				src.grillitem = W
				src.on = 1
				src.icon_state = "shittygrill_bake"
				light.enable()
				SubscribeToProcess()
				return
			else
				boutput(user, "<span style=\"color:red\">Your hubris will not be tolerated.</span>")
				user.gib()
				qdel(W)
				return

		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if (!W.reagents.total_volume)
				boutput(user, "<span style=\"color:red\">There is nothing in [W] to pour!</span>")

			else
				logTheThing("combat", user, null, "pours chemicals [log_reagents(W)] into the [src] at [log_loc(src)].") // Logging for the deep fryer (Convair880).
				src.visible_message("<span style=\"color:blue\">[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
				playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 100, 1)
				W.reagents.trans_to(src, W:amount_per_transfer_from_this)
				if (!W.reagents.total_volume) boutput(user, "<span style=\"color:red\"><b>[W] is now empty.</b></span>")

			return

		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting) return
			user.lastattacked = src
			src.visible_message("<span style=\"color:red\"><b>[user] is trying to shove [G.affecting] onto the [src]!</b></span>")
			if(!do_mob(user, G.affecting) || !W)
				return

			if(ismonkey(G.affecting))
				logTheThing("combat", user, G.affecting, "shoves %target% onto the [src] at [log_loc(src)].") // For player monkeys (Convair880).
				src.visible_message("<span style=\"color:red\"><b>[user] shoves [G.affecting] onto the [src]!</b></span>")
				src.icon_state = "shittygrill_bake"
				light.enable()
				src.cooktime = 0
				src.grillitem = G.affecting
				SubscribeToProcess()
				G.affecting.set_loc(src)
				G.affecting.death( 0 )
				qdel(W)
				return

			logTheThing("combat", user, G.affecting, "shoves %target%'s face into the [src] at [log_loc(src)].")
			src.visible_message("<span style=\"color:red\"><b>[user] shoves [G.affecting]'s face onto the [src]!</b></span>")
			src.reagents.reaction(G.affecting, TOUCH)

			return

		if (W.w_class > src.max_wclass || istype(W, /obj/item/storage) || istype(W, /obj/item/storage/secure))
			boutput(user, "<span style=\"color:red\">There is no way that could fit!</span>")
			return

		src.visible_message("<span style=\"color:blue\">[user] slaps [W] onto the [src].</span>")
		user.u_equip(W)
		W.set_loc(src)
		W.dropped()
		src.cooktime = 0
		src.grillitem = W
		src.on = 1
		src.icon_state = "shittygrill_bake"
		light.enable()
		SubscribeToProcess()
		return

	onVarChanged(variable, oldval, newval)
		if (variable == "grillitem")
			if (!oldval && newval)
				SubscribeToProcess()
	/*		else if (oldval && !newval)
				UnsubscribeProcess() */
		if (variable == "on")
			if (!oldval && newval)
				SubscribeToProcess()
	/*		else if (oldval && !newval)
				UnsubscribeProcess() */

	attack_hand(mob/user as mob)
		if (isghostdrone(user))
			boutput(usr, "<span style=\"color:red\">The [src] refuses to interface with you, as you are not a bus driver!</span>")
			return

		if (!src.grillitem)
			on = !on
			cooktime = 0
			boutput(user, "<span style=\"color:red\">You [on ? "light" : "turn off"] the [src] .</span>")
			if (on)
				icon_state = "shittygrill_on"
				light.enable()
				SubscribeToProcess()
			else
				icon_state = "shittygrill_off"
				light.disable()
//				UnsubscribeProcess()
			return

		if (src.cooktime < 5)
			boutput(user, "<span style=\"color:red\">Grilling things takes time! Be patient!</span>")
			return

		user.visible_message("<span style=\"color:blue\">[user] removes [src.grillitem] from the [src]!</span>", "<span style=\"color:blue\">You remove [src.grillitem] from [src].</span>")
		src.eject_food()
		return

	process()
		if (status & BROKEN)
			particleMaster.RemoveSystem(/datum/particleSystem/barrelSmoke, src)
			UnsubscribeProcess()
			return

		if (!src.reagents.has_reagent("charcoal"))
			src.reagents.add_reagent("charcoal", 5)

		if(src.grillitem || src.on)
			if (src.grilltemp <= src.grilltemp_target)
				src.grilltemp += 5
		else
			if (src.grilltemp >= (30 + T0C))
				src.grilltemp -= 5
			if (src.grilltemp <= (40 + T0C))
				UnsubscribeProcess()

		if (src.grilltemp >= 200 + T0C)
			if (!particles)
				particles = particleMaster.SpawnSystem(new /datum/particleSystem/barrelSmoke(src))
		else
			particleMaster.RemoveSystem(/datum/particleSystem/barrelSmoke, src)
			particles = null

		if (src.grilltemp >= src.reagents.total_temperature)
			src.reagents.set_reagent_temp(src.reagents.total_temperature + 5)
/*
		if(!src.grillitem && !src.on)
			UnsubscribeProcess()
			return
*/
		if(src.grillitem)
			if (!src.grillitem.reagents)
				var/datum/reagents/R = new/datum/reagents(50)
				src.grillitem.reagents = R
				R.my_atom = src.grillitem


			src.reagents.trans_to(src.grillitem, 2)

			src.cooktime++

		if (src.cooktime < 60)
			if (src.cooktime == 30)
				playsound(src.loc, "sound/machines/ding.ogg", 50, 1)
				src.visible_message("<span style=\"color:blue\">[src] emits a delicious smell!</span>")
			else if (src.cooktime == 60) //Welp!
				src.visible_message("<span style=\"color:red\">[src] emits a buncha smoke!</span>")
		else if(src.cooktime >= 120)
			if(prob(30) && (src.cooktime % 5) == 0)
				src.visible_message("<span style=\"color:red\">[src] really flares up!</span>")
				fireflash(src, 1)
		return

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.grillitem)
			return 0
		user.visible_message("<span style='color:red'><b>[user] climbs up onto the hot grill. It's a real dad way to go.</b></span>")

		user.set_loc(src)
		src.cooktime = 0
		src.grillitem = user
		src.icon_state = "shittygrill_bake"
		light.enable()
		user.TakeDamage("head", 0, 175)
		user.updatehealth()
		SubscribeToProcess()
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	proc/eject_food()
		if (!src.grillitem)
		//	UnsubscribeProcess()
			return

		var/obj/item/reagent_containers/food/snacks/grill_holder/shittysteak = new /obj/item/reagent_containers/food/snacks/grill_holder(src)

		if (src.cooktime >= 60)
			if (ismob(src.grillitem))
				var/mob/M = src.grillitem
				M.ghostize()
			else
				for (var/mob/M in src.grillitem)
					M.ghostize()
			qdel(src.grillitem)
			src.grillitem = new /obj/item/reagent_containers/food/snacks/yuckburn (src)
			if (!src.grillitem.reagents)
				var/datum/reagents/R = new/datum/reagents(50)
				src.grillitem.reagents = R
				R.my_atom = src.grillitem

			src.grillitem.reagents.add_reagent("charcoal", 50)
			shittysteak.desc = "A heavily grilled...something.  It's mostly ash now."
		else
			if (istype(src.grillitem, /obj/item/reagent_containers/food/snacks))
				shittysteak.food_effects += grillitem:food_effects

		var/icon/composite = new(src.grillitem.icon, src.grillitem.icon_state)//, src.grillitem.dir, 1)
		for(var/O in src.grillitem.underlays + src.grillitem.overlays)
			var/image/I = O
			composite.Blend(icon(I.icon, I.icon_state, I.dir, 1), ICON_OVERLAY)

		switch(src.cooktime)
			if (0 to 15)
				shittysteak.name = "lightly-grilled [src.grillitem.name]"
				shittysteak.color = ( rgb(206,151,95) )
				grillitem.reagents.remove_any(5)
				grillitem.reagents.add_reagent("beff", 5)


			if (16 to 49)
				shittysteak.name = "grilled [src.grillitem.name]"
				shittysteak.color = ( rgb(142,88,47) )
				grillitem.reagents.remove_any(5)
				grillitem.reagents.add_reagent("omnizine", 5)

			if (50 to 59)
				shittysteak.name = "perfectly grilled [src.grillitem.name]-steak"
				shittysteak.color = ( rgb(102, 61, 29) )
				grillitem.reagents.remove_any(5)
				grillitem.reagents.add_reagent("enriched_msg", 5)

			else
				shittysteak.color = ( rgb(33,19,9) )

		shittysteak.icon = composite
		shittysteak.overlays = grillitem.overlays
		shittysteak.set_loc(get_turf(src))
		if (ismob(grillitem))
			shittysteak.amount = 5
		else
			shittysteak.amount = src.grillitem.w_class
		shittysteak.reagents = src.grillitem.reagents
		shittysteak.reagents.my_atom = shittysteak

		src.grillitem.set_loc(shittysteak)

		src.grillitem = null
		src.icon_state = "shittygrill_on"
		for (var/obj/item/I in src) //Things can get dropped somehow sometimes ok
			I.set_loc(src.loc)
		src.cooktime = 0
	//	UnsubscribeProcess()
		return

	verb/drain()
		set src in oview(1)
		set name = "Clean grill"
		set desc = "Clean the plate and put some fresh coals in there."
		set category = "Local"

		if (src.reagents)
			if (isobserver(usr) || isintangible(usr) || isdead(usr)) // Ghosts probably shouldn't be able to take revenge on a traitor chef or whatever (Convair880).
				return
			else
				src.reagents.clear_reagents()
				src.visible_message("<span style=\"color:red\">[usr] replaces the charcoal!</span>")

		return


/*
farts
*/
