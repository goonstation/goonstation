/* ==================================================== */
/* --------------------- Machine ---------------------- */
/* ==================================================== */
/obj/machinery/espresso_machine/
	name = "espresso machine"
	desc = "It's top of the line NanoTrasen espresso technology! Featuring 100% Organic Locally-Grown espresso beans!" //haha no
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "espresso_machine"
	density = 1
	anchored = 1
	flags = FPRINT | NOSPLASH
	mats = 30
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS
	var/cupinside = 0 //true or false
	var/top_on = 1 //screwed on or screwed off
	var/cup_name = "espresso cup"
	var/image/image_top = null
	var/image/image_cup = null

	New()
		..()
		UnsubscribeProcess()
		src.update()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/drinks/espressocup))
			if (src.cupinside == 1)
				user.show_text("The [src] can't hold any more [src.cup_name]s, doofus!")
				return ..()
			if (src.cupinside == 0)
				user.drop_item()
				src.cupinside = 1
				W.set_loc(src)
				user.show_text ("You place the [src.cup_name] into the [src].")
				src.update()
				return ..()

	attack_hand(mob/user as mob)
		if (can_reach(user,src))
			src.add_fingerprint(user)
			if (src.cupinside == 1) //freaking spacing errors made me waste hours on this
				if(!status & (NOPOWER|BROKEN))
					switch(alert("What would you like to do with [src]?",,"Make espresso","Remove cup","Nothing"))
						if ("Make espresso")
							var/drink_choice = input(user, "What kind of espresso do you want to make?", "Selection") as null|anything in list("Espresso","Latte","Mocha","Cappuchino","Americano", "Decaf", "Flat White")
							if (!drink_choice)
								return
							switch (drink_choice)  //finds cup in contents and adds chosen drink to it
								if ("Espresso")
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso",10)
										playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
									return
								if ("Latte") // 5:1 milk:espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 1.6)
										C.reagents.add_reagent("milk", 8.4)
										playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
									return
								if ("Mocha") // 3:1:3 espresso:milk:chocolate
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 4.3)
										C.reagents.add_reagent("milk", 1.4)
										C.reagents.add_reagent("chocolate", 4.3)
										playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
									return
								if ("Cappuchino") // 1:1:1 milk foam:milk:espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 3.5)
										C.reagents.add_reagent("milk", 6.5)
										playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
									return
								if ("Americano") // 3:2 water:espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 4)
										C.reagents.add_reagent("water", 6)
										playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
									return
								if ("Decaf") // 1 decaf espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("decafespresso", 10)
										playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
									return
								if ("Flat White") // 3:2 milk:espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 4)
										C.reagents.add_reagent("milk", 6)
										playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
									return
						if ("Remove cup")
							src.cupinside = 0
							for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents) //removes cup from contents and ejects
								C:set_loc(src.loc)
							user.show_text("You have removed the [src.cup_name] from the [src].")
							src.update()
						if ("Nothing")
							return
			else return ..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	proc/update()
		if (src.cupinside == 1)
			if (!src.image_cup)
				src.image_cup = image(src.icon, icon_state = "cupoverlay")
			src.UpdateOverlays(src.image_cup, "cup")
		else
			src.UpdateOverlays(null, "cup")
		if (src.top_on == 1)
			if (!src.image_top)
				src.image_top = image(src.icon, icon_state = "coffeetopoverlay")
			src.UpdateOverlays(src.image_top, "top")
		else
			src.UpdateOverlays(null, "top")
		return

/* ===================================================== */
/* ---------------------- Cup Rack --------------------- */
/* ===================================================== */
/obj/cup_rack
	name = "coffee cup rack"
	desc = "It's a rack to hang your fancy coffee cups." //*tip
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "cuprack7" //changes based on cup_ammount in updateicon
	anchored = 1
	var/cup_amount = 7
	var/contained_cup = /obj/item/reagent_containers/food/drinks/espressocup
	var/contained_cup_name = "espresso cup"

	get_desc(dist, mob/user)
		if (dist <= 2)
			. += "There's [(src.cup_amount > 0) ? src.cup_amount : "no" ] [src.contained_cup_name][s_es(src.cup_amount)] on \the [src]."

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, src.contained_cup) & src.cup_amount < 7)
			user.drop_item()
			qdel(W)
			src.cup_amount ++
			boutput(user, "You place \the [src.contained_cup_name] back onto \the [src].")
			src.updateicon()
		else return ..()

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if (src.cup_amount <= 0)
			user.show_text("\The [src] doesn't have any [src.contained_cup_name]s left, doofus!", "red")
		else
			boutput(user, "You take \an [src.contained_cup_name] off of \the [src].")
			src.cup_amount--
			var/obj/item/reagent_containers/food/drinks/espressocup/P = new /obj/item/reagent_containers/food/drinks/espressocup
			user.put_in_hand_or_drop(P)
			src.updateicon()

	proc/updateicon()
		src.icon_state = "cuprack[src.cup_amount]" //sets the icon_state to the ammount of cups on the rack
		return

/* ===================================================== */
/* ---------------------- Coffeemaker ------------------ */
/* ===================================================== */
//Sorry for budging in here, whoever made the espresso machine. Lets just rename this to coffee.dm?

/obj/machinery/coffeemaker
	name = "coffeemaker"
	desc = "It's top of the line NanoTrasen espresso technology! Featuring 100% Organic Locally-Grown espresso beans!" //haha no
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "coffeemaker-eng"
	density = 1
	anchored = 1
	flags = FPRINT | NOSPLASH
	mats = 30
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_WIRECUTTERS
	var/carafe_name = "coffee carafe"
	var/image/image_top = null
	var/image/image_carafe = null
	var/obj/item/reagent_containers/food/drinks/carafe/my_carafe
	var/default_carafe = /obj/item/reagent_containers/food/drinks/carafe
	var/image/fluid_image

	New()
		..()
		UnsubscribeProcess()
		if (ispath(src.default_carafe))
			src.my_carafe = new src.default_carafe (src)
		src.update()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/drinks/carafe))
			if (src.my_carafe)
				user.show_text("The [src] can't hold any more [src.carafe_name]s, doofus!")
				return ..()
			else
				user.drop_item()
				W.set_loc(src)
				src.my_carafe = W
				user.show_text ("You place the [src.carafe_name] into the [src].")
				src.update()
				return ..()

	attack_hand(mob/user as mob)
		if (can_reach(user,src))
			src.add_fingerprint(user)
			if (src.my_carafe) //freaking spacing errors made me waste hours on this
				if (!status & (NOPOWER|BROKEN))
					switch (alert("What would you like to do with [src]?",,"Brew coffee","Remove carafe","Nothing"))
						if ("Brew coffee")
							for(var/obj/item/reagent_containers/food/drinks/carafe/C in src.contents)
								C.reagents.add_reagent("coffee_fresh",40)
								playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
						if ("Remove carafe")
							if (!src.my_carafe)
								return
							src.my_carafe.set_loc(src.loc)
							src.my_carafe = null
							user.show_text("You have removed the [src.carafe_name] from the [src].")
							src.update()
						if ("Nothing")
							return
			else return ..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	proc/update(var/passed_color)
		if (src.my_carafe)
			src.UpdateOverlays(SafeGetOverlayImage("carafe", src.icon, src.my_carafe.icon_state),"carafe")
			if (src.my_carafe.reagents && src.my_carafe.reagents.total_volume)
				var/image/I = SafeGetOverlayImage("carafe-fluid", src.icon, "carafe-fluid")
				var/datum/color/average = my_carafe.reagents.get_average_color()
				var/average_rgb = average.to_rgba()
				I.color = average_rgb
				src.UpdateOverlays(I, "carafe-fluid")
			else
				src.UpdateOverlays(null, "carafe-fluid", 0, 1)
		else
			src.UpdateOverlays(null, "carafe", 0, 1)
			src.UpdateOverlays(null, "carafe-fluid", 0, 1)
		return

/obj/machinery/coffeemaker/medbay
	icon_state = "coffeemaker-med"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/medbay

/obj/machinery/coffeemaker/botany
	icon_state = "coffeemaker-hyd"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/botany

/obj/machinery/coffeemaker/security
	icon_state = "coffeemaker-sec"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/security

/obj/machinery/coffeemaker/research
	icon_state = "coffeemaker-sci"
	default_carafe = /obj/item/reagent_containers/food/drinks/carafe/research


/* ===================================================== */
/* ---------------------- Mug Rack --------------------- */
/* ===================================================== */
/obj/mug_rack
	name = "coffee mug rack"
	desc = "It's a rack to hang your not-so-fancy coffee cups." //*tip
	icon = 'icons/obj/foodNdrink/espresso.dmi'
	icon_state = "mugrack4" //changes based on cup_ammount in updateicon
	anchored = 1
	var/cup_amount = 4
	var/contained_cup = /obj/item/reagent_containers/food/drinks/mug
	var/contained_cup_name = "mug"

	get_desc(dist, mob/user)
		if (dist <= 2)
			. += "There's [(src.cup_amount > 0) ? src.cup_amount : "no" ] [src.contained_cup_name][s_es(src.cup_amount)] on \the [src]."

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, src.contained_cup) & src.cup_amount < 7)
			user.drop_item()
			qdel(W)
			src.cup_amount ++
			boutput(user, "You place \the [src.contained_cup_name] back onto \the [src].")
			src.updateicon()
		else return ..()

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if (src.cup_amount <= 0)
			user.show_text("\The [src] doesn't have any [src.contained_cup_name]s left, doofus!", "red")
		else
			boutput(user, "You take \a [src.contained_cup_name] off of \the [src].")
			src.cup_amount--
			var/obj/item/reagent_containers/food/drinks/espressocup/P = new /obj/item/reagent_containers/food/drinks/mug
			user.put_in_hand_or_drop(P)
			src.updateicon()

	proc/updateicon()
		src.icon_state = "mugrack[src.cup_amount]" //sets the icon_state to the amount of cups on the rack
		return
