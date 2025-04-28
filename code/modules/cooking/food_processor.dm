#define MIN_FLUID_INGREDIENT_LEVEL 10
TYPEINFO(/obj/submachine/foodprocessor)
	mats = 18

/obj/submachine/foodprocessor
	name = "Processor"
	desc = "Refines various food substances into different forms."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor-off"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	var/working = 0
	var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/plant/, /obj/item/organ/brain, /obj/item/clothing/head/butt)

	attack_hand(var/mob/user)
		if (length(src.contents) < 1)
			boutput(user, SPAN_ALERT("There is nothing in the processor!"))
			return
		if (src.working == 1)
			boutput(user, SPAN_ALERT("The processor is busy!"))
			return
		src.icon_state = "processor-on"
		src.working = 1
		src.visible_message("The [src] begins processing its contents.")
		sleep(rand(30,70))
		// Dispense processed stuff
		for(var/obj/item/P in src.contents)
			if (istype(P,/obj/item/reagent_containers/food/drinks))
				var/milk_amount = P.reagents.get_reagent_amount("milk")
				var/yoghurt_amount = P.reagents.get_reagent_amount("yoghurt")
				if (milk_amount < 10 && yoghurt_amount < 10)
					continue

				var/cream_output = floor(milk_amount / 10)
				var/yoghurt_output = floor(yoghurt_amount / 10)
				P.reagents.remove_reagent("milk", cream_output * 10)
				P.reagents.remove_reagent("yoghurt", yoghurt_output * 10)
				for (var/i in 1 to cream_output)
					new/obj/item/reagent_containers/food/snacks/condiment/cream(src.loc)
				for (var/i in 1 to yoghurt_output)
					new/obj/item/reagent_containers/food/snacks/yoghurt(src.loc)

			switch( P.type )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = P:subjectname + " meatball"
					F.desc = "Meaty balls taken from the station's finest [P:subjectjob]."
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "monkey meatball"
					F.desc = "Welcome to Space Station 13, where you too can eat a rhesus macaque's balls."
					qdel( P )
				if (/obj/item/organ/brain)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "brain meatball"
					F.desc = "Oh jesus, brain meatballs? That's just nasty."
					F.icon_state = "meatball_brain"
					qdel( P )
				if (/obj/item/clothing/head/butt)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "buttball"
					F.desc = "The best you can hope for is that the meat was lean..."
					F.icon_state = "meatball_butt"
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "synthetic meatball"
					F.desc = "Let's be honest, this is probably as good as these things are going to get."
					F.icon_state = "meatball_plant"
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "mystery meatball"
					F.desc = "A meatball of even more dubious quality than usual."
					F.icon_state = "meatball_mystery"
					qdel( P )
				if (/obj/item/plant/wheat/metal)
					new/obj/item/reagent_containers/food/snacks/condiment/ironfilings/(src.loc)
					qdel( P )
				if (/obj/item/plant/wheat/durum)
					new/obj/item/reagent_containers/food/snacks/ingredient/flour/semolina(src.loc)
					qdel( P )
				if (/obj/item/plant/wheat)
					new/obj/item/reagent_containers/food/snacks/ingredient/flour/(src.loc)
					qdel( P )
				if (/obj/item/plant/oat)
					new/obj/item/reagent_containers/food/snacks/ingredient/oatmeal/(src.loc)
					qdel( P )
				if (/obj/item/plant/oat/salt)
					var/obj/item/reagent_containers/food/snacks/ingredient/salt/F = new(src.loc)
					F.reagents.add_reagent("salt", P.reagents.get_reagent_amount("salt")) // item/plant has no plantgenes :(
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig)
					new/obj/item/reagent_containers/food/snacks/ingredient/rice(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/tomato)
					new/obj/item/reagent_containers/food/snacks/condiment/ketchup(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/peanuts)
					new/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/egg)
					new/obj/item/reagent_containers/food/snacks/condiment/mayo(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet)
					new/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/sheet)
					new/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/ramen(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili/chilly)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/coldsauce/F = new(src.loc)
					F.reagents.add_reagent("cryostylane", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/hotsauce/ghostchilisauce/F = new(src.loc)
					F.reagents.add_reagent("ghostchilijuice", 5 + HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/hotsauce/F = new(src.loc)
					F.reagents.add_reagent("capsaicin", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry/mocha)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/candy/chocolate/F = new(src.loc)
					F.reagents.add_reagent("chocolate", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry/latte)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/cream/F = new(src.loc)
					F.reagents.add_reagent("cream", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/plant/sugar)
					var/obj/item/reagent_containers/food/snacks/ingredient/sugar/F = new(src.loc)
					F.reagents.add_reagent("sugar", 20)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/condiment/cream)
					new/obj/item/reagent_containers/food/snacks/ingredient/butter(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/candy/chocolate)
					new/obj/item/reagent_containers/food/snacks/condiment/chocchips(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/corn)
					new/obj/item/reagent_containers/food/snacks/popcorn(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/corn/pepper)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/ingredient/pepper/F = new(src.loc)
					F.reagents.add_reagent("pepper", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/avocado)
					new/obj/item/reagent_containers/food/snacks/soup/guacamole(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/soy)
					new/obj/item/reagent_containers/food/drinks/milk/soy(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry)
					new/obj/item/reagent_containers/food/snacks/plant/coffeebean(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meatpaste)
					new/obj/item/reagent_containers/food/snacks/ingredient/pepperoni_log(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/fishpaste)
					new/obj/item/reagent_containers/food/snacks/ingredient/kamaboko_log(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/cucumber)
					new/obj/item/reagent_containers/food/snacks/pickle(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/cherry)
					new/obj/item/cocktail_stuff/maraschino_cherry(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/turmeric)
					new/obj/item/reagent_containers/food/snacks/ingredient/currypowder(src.loc)
					qdel( P )
				if (/obj/item/plant/herb/tea)
					new/obj/item/reagent_containers/food/snacks/condiment/matcha(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/mustard)
					new/obj/item/reagent_containers/food/snacks/condiment/mustard(src.loc)
					qdel( P )
		// Wind down
		for(var/obj/item/S in src.contents)
			S.set_loc(get_turf(src))
		src.working = 0
		src.icon_state = "processor-off"
		playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
		return

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/satchel/))
			var/obj/item/satchel/S = W
			if (length(S.contents) < 1) boutput(user, SPAN_ALERT("There's nothing in the satchel!"))
			else
				user.visible_message(SPAN_NOTICE("[user] loads [S]'s contents into [src]!"))
				var/amtload = 0
				for (var/obj/item/reagent_containers/food/F in S.contents)
					F.set_loc(src)
					amtload++
				for (var/obj/item/plant/P in S.contents)
					P.set_loc(src)
					amtload++
				S.UpdateIcon()
				boutput(user, SPAN_NOTICE("[amtload] items loaded from satchel!"))
				S.tooltip_rebuild = 1
			return
		else
			var/proceed = 0
			for(var/check_path in src.allowed)
				if(istype(W, check_path))
					proceed = 1
					break
			if (!proceed)
				boutput(user, SPAN_ALERT("You can't put that in the processor!"))
				return
			// If item is attached to you, don't drop it in, ex Silicons can't load in their icing tubes
			if (W.cant_drop)
				boutput(user, SPAN_ALERT("You can't put that in the [src] when it's attached to you!"))
				return
			user.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			return

	mouse_drop(over_object, src_location, over_location)
		..()
		if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return
		if (over_object == usr && (in_interact_range(src, usr) || usr.contents.Find(src)))
			for(var/obj/item/P in src.contents)
				P.set_loc(get_turf(src))
			for(var/mob/O in AIviewers(usr, null))
				O.show_message(SPAN_NOTICE("[usr] empties the [src]."))
			return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (BOUNDS_DIST(src, user) > 0 || !isliving(user) || iswraith(user) || isintangible(user) || !isalive(user) || isintangible(user))
			return
		if (is_incapacitated(user) || user.restrained())
			return

		if (istype(O, /obj/storage))
			if (O:locked)
				boutput(user, SPAN_ALERT("You need to unlock it first!"))
				return
			user.visible_message(SPAN_NOTICE("[user] loads [O]'s contents into [src]!"))
			var/amtload = 0
			for (var/obj/item/reagent_containers/food/M in O.contents)
				M.set_loc(src)
				amtload++
			for (var/obj/item/plant/P in O.contents)
				P.set_loc(src)
				amtload++
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] items of food loaded from [O]!"))
			else boutput(user, SPAN_ALERT("No food loaded!"))
		else if (istype(O, /obj/item/reagent_containers/food/) || istype(O, /obj/item/plant/))
			user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing food into [src]!"))
			var/staystill = user.loc
			for(var/obj/item/reagent_containers/food/M in view(1,user))
				// Stop putting attached items in processor, looking at you borgs with icing tubes...
				if (!M.cant_drop)
					M.set_loc(src)
					sleep(0.3 SECONDS)
					if (user.loc != staystill) break
			for(var/obj/item/plant/P in view(1,user))
				P.set_loc(src)
				sleep(0.3 SECONDS)
				if (user.loc != staystill) break
			boutput(user, SPAN_NOTICE("You finish stuffing food into [src]!"))
		else ..()
