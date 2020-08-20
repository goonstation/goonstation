
/* ==================================================== */
/* -------------------- Dispensers -------------------- */
/* ==================================================== */

/obj/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = FPRINT | FLUID_SUBMERGE
	pressure_resistance = 2*ONE_ATMOSPHERE
	p_class = 1.5

	var/amount_per_transfer_from_this = 10

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/cargotele))
			W:cargoteleport(src, user)
		return

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(4000)
		reagents = R
		R.my_atom = src


	get_desc(dist, mob/user)
		if (dist <= 2 && reagents)
			. += "<br><span class='notice'>[reagents.get_description(user,RC_SCALE)]</span>"

	proc/smash()
		var/turf/T = get_turf(src)
		T.fluid_react(src.reagents, min(src.reagents.total_volume,10000))
		src.reagents.clear_reagents()
		qdel(src)

	ex_act(severity)
		switch(severity)
			if (1.0)
				smash()
				return
			if (2.0)
				if (prob(50))
					smash()
					return
			if (3.0)
				if (prob(5))
					smash()
					return
			else
		return

	blob_act(var/power)
		if (prob(25))
			smash()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		..()
		if (reagents)
			for (var/i = 0, i < 9, i++) // ugly hack
				reagents.temperature_reagents(exposed_temperature, exposed_volume)

	MouseDrop(atom/over_object as obj)
		if (!istype(over_object, /obj/item/reagent_containers/glass) && !istype(over_object, /obj/item/reagent_containers/food/drinks) && !istype(over_object, /obj/item/spraybottle) && !istype(over_object, /obj/machinery/plantpot) && !istype(over_object, /obj/mopbucket) && !istype(over_object, /obj/machinery/hydro_mister) && !istype(over_object, /obj/item/tank/jetpack/backtank))
			return ..()

		if (get_dist(usr, src) > 1 || get_dist(usr, over_object) > 1)
			boutput(usr, "<span class='alert'>That's too far!</span>")
			return

		src.transfer_all_reagents(over_object, usr)

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/reagent_dispensers/ants
	name = "space ants"
	desc = "A bunch of space ants."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spaceants"
	layer = MOB_LAYER
	density = 0
	anchored = 1
	amount_per_transfer_from_this = 5

	New()
		..()
		var/scale = (rand(2, 10) / 10) + (rand(0, 5) / 100)
		src.Scale(scale, scale)
		src.dir = pick(NORTH, SOUTH, EAST, WEST)
		reagents.add_reagent("ants",20)

	get_desc(dist, mob/user)
		return null

	attackby(obj/item/W as obj, mob/user as mob)
		..(W, user)
		SPAWN_DBG(1 SECOND)
			if (src && src.reagents)
				if (src.reagents.total_volume <= 1)
					qdel(src)
		return

/obj/reagent_dispensers/spiders
	name = "spiders"
	desc = "A bunch of spiders."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spaceants"
	layer = MOB_LAYER
	density = 0
	anchored = 1
	amount_per_transfer_from_this = 5
	color = "#160505"

	New()
		..()
		var/scale = (rand(2, 10) / 10) + (rand(0, 5) / 100)
		src.Scale(scale, scale)
		src.dir = pick(NORTH, SOUTH, EAST, WEST)
		src.pixel_x = rand(-8,8)
		src.pixel_y = rand(-8,8)
		reagents.add_reagent("spiders", 5)

	get_desc(dist, mob/user)
		return null

	attackby(obj/item/W as obj, mob/user as mob)
		..(W, user)
		SPAWN_DBG(1 SECOND)
			if (src && src.reagents)
				if (src.reagents.total_volume <= 1)
					qdel(src)
		return

/obj/reagent_dispensers/foamtank
	name = "foamtank"
	desc = "A foamtank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "foamtank"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("ff-foam",1000)

/obj/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("water",1000)

/obj/reagent_dispensers/watertank/big
	name = "high-capacity watertank"
	desc = "A specialised high-pressure water tank for holding large amounts of water."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertankbig"
	anchored = 0
	amount_per_transfer_from_this = 25

	attackby(obj/item/W as obj, mob/user as mob)
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			if(!src.anchored)
				user.visible_message("<b>[user]</b> secures the [src] to the floor!")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
				src.anchored = 1
			else
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
				src.anchored = 0
			return

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(10000)
		reagents = R
		R.my_atom = src
		reagents.add_reagent("water",10000)

/obj/reagent_dispensers/watertank/fountain
	name = "water cooler"
	desc = "A popular gathering place for NanoTrasen's finest bureaucrats and pencil-pushers."
	icon_state = "coolerbase"
	anchored = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR
	mats = 8

	var/has_tank = 1

	var/cup_max = 12
	var/cup_amount

	var/image/cup_sprite = null
	var/image/fluid_sprite = null
	var/image/tank_sprite = null

	New()
		..()

		src.cup_sprite = new /image(src.icon, "coolercup")
		src.fluid_sprite = new /image(src.icon,"fluid-coolertank")
		src.tank_sprite = new /image(src.icon,"coolertank", layer=src.fluid_sprite.layer + 0.1)
		src.tank_sprite.alpha = 180

		src.cup_amount = src.cup_max

		src.update_icon()

	//on_reagent_change()
	//	src.update_icon()

	proc/update_icon()
		if (src.has_tank)
			if (src.reagents.total_volume)
				var/datum/color/average = reagents.get_average_color()
				src.fluid_sprite.color = average.to_rgba()
				src.UpdateOverlays(fluid_sprite, "fluid_overlay")
			src.UpdateOverlays(tank_sprite, "tank_overlay")
		else
			src.UpdateOverlays(null, "fluid_overlay")
			src.UpdateOverlays(null, "tank_overlay")
		if (cup_amount > 0)
			src.UpdateOverlays(cup_sprite, "cup_overlay")
		else
			src.UpdateOverlays(null, "cup_overlay")

	get_desc(dist, mob/user)
		. += "There's [cup_amount] paper cup[s_es(src.cup_amount)] in [src]'s cup dispenser."
		if (dist <= 2 && reagents)
			. += "<br><span class='notice'>[reagents.get_description(user,RC_SCALE)]</span>"

	attackby(obj/W as obj, mob/user as mob)
		if (has_tank)
			if (istype(W, /obj/item/wrench))
				user.show_text("You disconnect the bottle from [src].", "blue")
				var/obj/item/reagent_containers/food/drinks/P = new /obj/item/reagent_containers/food/drinks/coolerbottle(src.loc)
				P.reagents.maximum_volume = max(P.reagents.maximum_volume, src.reagents.total_volume)
				src.reagents.trans_to(P, reagents.total_volume)
				src.reagents.clear_reagents()
				src.has_tank = 0
				src.update_icon()
				return
		else if (istype(W, /obj/item/reagent_containers/food/drinks/coolerbottle))
			user.show_text("You connect the bottle to [src].", "blue")
			W.reagents.trans_to(src, W.reagents.total_volume)
			user.u_equip(W)
			qdel(W)
			src.has_tank = 1
			src.update_icon()
			return

		if (istype(W, /obj/item/screwdriver))
			if (src.anchored)
				playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
				user.show_text("You start unscrewing [src] from the floor.", "blue")
				if (do_after(user, 30))
					user.show_text("You unscrew [src] from the floor.", "blue")
					src.anchored = 0
					return
			else
				var/turf/T = get_turf(src)
				if (istype(T, /turf/space))
					user.show_text("What exactly are you gunna secure [src] to?", "red")
					return
				else
					playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
					user.show_text("You start securing [src] to [T].", "blue")
					if (do_after(user, 30))
						user.show_text("You secure [src] to [T].", "blue")
						src.anchored = 1
						return
		..()

	attack_hand(mob/user as mob)
		if (src.cup_amount <= 0)
			user.show_text("\The [src] doesn't have any cups left, damnit.", "red")
			return
		else
			src.visible_message("<b>[user]</b> grabs a paper cup from [src].",\
			"You grab a paper cup from [src].")
			src.cup_amount --
			var/obj/item/reagent_containers/food/drinks/paper_cup/P = new /obj/item/reagent_containers/food/drinks/paper_cup(src)
			user.put_in_hand_or_drop(P)
			if (src.cup_amount <= 0)
				user.show_text("That was the last cup!", "red")
				src.update_icon()

	piss
		New()
			..()
			var/datum/reagents/R = new/datum/reagents(4000)
			reagents = R
			R.my_atom = src
			reagents.add_reagent("urine",400)
			reagents.add_reagent("water",600)
			src.update_icon()
		name = "discolored water fountain"
		desc = "It's called a fountain, but it's not very decorative or interesting. You can get a drink from it, though seeing the color you feel you shouldn't"
		color = "#ffffcc"

	juicer
		New()
			..()
			var/datum/reagents/R = new/datum/reagents(4000)
			reagents = R
			R.my_atom = src
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent(pick("CBD","THC","urine","refried_beans","coffee","methamphetamine"),100)
			reagents.add_reagent("water",600)
			src.update_icon()
		name = "discolored water fountain"
		desc = "It's called a fountain, but it's not very decorative or interesting. You can get a drink from it, though seeing the color you feel you shouldn't"
		color = "#ccffcc"



/obj/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank"
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("fuel",4000)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (!src.reagents.has_reagent("fuel",20))
			return 0
		user.visible_message("<span class='alert'><b>[user] drinks deeply from [src]. [capitalize(he_or_she(user))] then pulls out a match from somewhere, strikes it and swallows it!</b></span>")
		src.reagents.remove_any(20)
		playsound(src.loc, "sound/items/drink.ogg", 50, 1, -6)
		user.TakeDamage("chest", 0, 150)
		if (isliving(user))
			var/mob/living/L = user
			L.changeStatus("burning", 100)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1


	electric_expose(var/power = 1) //lets throw in ANOTHER hack to the temp expose one above
		if (reagents)
			for (var/i = 0, i < 3, i++)
				reagents.temperature_reagents(power*400, power*125)

/obj/reagent_dispensers/heliumtank
	name = "heliumtank"
	desc = "A tank of helium."
	icon = 'icons/obj/objects.dmi'
	icon_state = "heliumtank"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("helium",4000)

/obj/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg"
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	amount_per_transfer_from_this = 25

	New()
		..()
		reagents.add_reagent("beer",1000)

/obj/reagent_dispensers/compostbin
	name = "compost tank"
	desc = "A device that mulches up unwanted produce into usable fertiliser."
	icon = 'icons/obj/objects.dmi'
	icon_state = "compost"
	anchored = 0
	amount_per_transfer_from_this = 30

	New()
		..()

	get_desc(dist, mob/user)
		if (dist > 2)
			return
		if (!reagents)
			return
		. = "<br><span class='notice'>[reagents.get_description(user,RC_FULLNESS)]</span>"
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			if(!src.anchored)
				user.visible_message("<b>[user]</b> secures the [src] to the floor!")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
				src.anchored = 1
			else
				user.visible_message("<b>[user]</b> unbolts the [src] from the floor!")
				playsound(src.loc, "sound/items/Screwdriver.ogg", 100, 1)
				src.anchored = 0
			return
		var/load = 1
		if (istype(W,/obj/item/reagent_containers/food/snacks/plant/)) src.reagents.add_reagent("poo", 20)
		else if (istype(W,/obj/item/reagent_containers/food/snacks/mushroom/)) src.reagents.add_reagent("poo", 25)
		else if (istype(W,/obj/item/seed/)) src.reagents.add_reagent("poo", 2)
		else if (istype(W,/obj/item/plant/)) src.reagents.add_reagent("poo", 15)
		else load = 0

		if(load)
			boutput(user, "<span class='notice'>[src] mulches up [W].</span>")
			playsound(src.loc, "sound/impact_sounds/Slimy_Hit_4.ogg", 50, 1)
			user.u_equip(W)
			W.dropped()
			pool( W )
			return
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			boutput(user, "<span class='alert'>Excuse me you are dead, get your gross dead hands off that!</span>")
			return
		if (get_dist(user,src) > 1)
			boutput(user, "<span class='alert'>You need to move closer to [src] to do that.</span>")
			return
		if (get_dist(O,src) > 1 || get_dist(O,user) > 1)
			boutput(user, "<span class='alert'>[O] is too far away to load into [src]!</span>")
			return
		if (istype(O, /obj/item/reagent_containers/food/snacks/plant/) || istype(O, /obj/item/reagent_containers/food/snacks/mushroom/) || istype(O, /obj/item/seed/) || istype(O, /obj/item/plant/))
			user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
			var/itemtype = O.type
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				if (src.reagents.total_volume >= src.reagents.maximum_volume)
					boutput(user, "<span class='alert'>[src] is full!</span>")
					break
				if (user.loc != staystill) break
				if (P.type != itemtype) continue
				var/amount = 20
				if (istype(P,/obj/item/reagent_containers/food/snacks/mushroom/))
					amount = 25
				else if (istype(P,/obj/item/seed/))
					amount = 2
				else if (istype(P,/obj/item/plant/))
					amount = 15
				playsound(src.loc, "sound/impact_sounds/Slimy_Hit_4.ogg", 50, 1)
				src.reagents.add_reagent("poo", amount)
				pool( P )
				sleep(0.3 SECONDS)
			boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
		else ..()

/obj/reagent_dispensers/still
	name = "still"
	desc = "A piece of equipment for brewing alcoholic beverages."
	icon = 'icons/obj/objects.dmi'
	icon_state = "still"
	amount_per_transfer_from_this = 25

	// what was the point here exactly
	//New()
		//..()

	proc/brew(var/obj/item/W as obj)
		if (!W || !(istype(W,/obj/item/reagent_containers/food) || istype(W, /obj/item/plant)))
			return 0

		if (!W:brewable || !W:brew_result)
			return 0

		if (istype(W,/obj/item/reagent_containers/food/snacks/snack_cake) || istype(W,/obj/item/reagent_containers/food/snacks/burrito))
			if (islist(W:brew_result) && W:brew_result:len)
				W:brew_result += W.reagents.reagent_list

		//var/brewed_name = null
		if (islist(W:brew_result) && W:brew_result:len)
			for (var/i in W:brew_result)
				//brewed_name += ", [reagent_id_to_name(i)]"
				src.reagents.add_reagent(i, 10)
			//brewed_name = copytext(brewed_name, 3)
		else
			src.reagents.add_reagent(W:brew_result, 20)
			//brewed_name = reagent_id_to_name(W:brew_result)

		src.visible_message("<span class='notice'>[src] brews up [W]!</span>")// into [brewed_name]!")
		return 1

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W,/obj/item/reagent_containers/food) || istype(W, /obj/item/plant))
			var/load = 0
			if (src.brew(W))
				load = 1
			else
				load = 0

			if (load)
				user.u_equip(W)
				W.dropped()
				pool(W)
				return
			else  ..()
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			user.show_text("It's probably a bit too late for you to drink your problems away.", "red")
			return
		if (get_dist(user,src) > 1)
			user.show_text("You need to move closer to [src] to do that.", "red")
			return
		if (get_dist(O,src) > 1 || get_dist(O,user) > 1)
			user.show_text("[O] is too far away to load into [src]!", "red")
			return

		if (istype(O, /obj/storage/crate/))
			user.visible_message("<span class='notice'>[user] loads [O]'s contents into [src]!</span>",\
			"<span class='notice'>You load [O]'s contents into [src]!</span>")
			var/amtload = 0
			for (var/obj/item/P in O.contents)
				if (src.reagents.is_full())
					user.show_text("[src] is full!", "red")
					break
				if (src.brew(P))
					amtload++
					pool(P)
				else
					continue
			if (amtload)
				user.show_text("[amtload] items loaded from [O]!", "blue")
			else
				user.show_text("Nothing was loaded!", "red")
		else if (istype(O, /obj/item/reagent_containers/food) || istype(O, /obj/item/plant))
			user.visible_message("<span class='notice'><b>[user]</b> begins quickly stuffing items into [src]!</span>",\
			"<span class='notice'>You begin quickly stuffing items into [src]!</span>")
			var/staystill = user.loc
			for (O in view(1,user))
				if (src.reagents.is_full())
					user.show_text("[src] is full!", "red")
					break
				if (user.loc != staystill)
					user.show_text("You were interrupted!", "red")
					break
				if (src.brew(O))
					pool(O)
				else
					continue
			user.visible_message("<span class='notice'><b>[user]</b> finishes stuffing items into [src].</span>",\
			"<span class='notice'>You finish stuffing items into [src].</span>")
		else
			return ..()


/* ==================================================== */
/* --------------- Water Cooler Bottle ---------------- */
/* ==================================================== */

/obj/item/reagent_containers/food/drinks/coolerbottle
	name = "water cooler bottle"
	desc = "A water cooler bottle. Can hold up to 1000 units."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "itemtank"
	item_state = "flask"
	initial_volume = 1000
	w_class = 4.0
	incompatible_with_chem_dispensers = 1

	var/image/fluid_image

	New()
		..()
		fluid_image = image(src.icon, "fluid-[src.icon_state]")

	on_reagent_change()
		src.update_icon()

	proc/update_icon()
		src.underlays = null
		if (reagents.total_volume)
			var/datum/color/average = reagents.get_average_color()
			fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image
