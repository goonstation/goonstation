/obj/item/reagent_containers/bath_bomb
	name = "Discount Dan's Bath Bomb"
	desc = "a bath bomb"
	icon = 'icons/obj/items/bathbomb.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	icon_state = "bathbomb"
	item_state = "bathbomb"
	rc_flags = RC_SPECTRO		// only spectroscopic analysis
	initial_volume = 50
	var/batbomb = 0

	EnteredFluid(obj/fluid/F as obj, atom/oldloc)

		src.visible_message("<span class='alert'>[src] dissolves into [F]!</span>")

		if(src.batbomb)
			src.batbomb()
			qdel(src)
			return

		var/turf/T = get_turf(src)
		T?.fluid_react(reagents,reagents.total_volume)
		qdel(src)

	attack(mob/M, mob/user, def_zone)
		if (!src.reagents || !src.reagents.total_volume)
			user.show_text("[src] doesn't contain any reagents.", "red")
			return

		if (iscarbon(M) || ismobcritter(M))
			..()
		else
			return 0

	afterattack(var/atom/target, mob/user, flag)
		if (!isobj(target))
			..()
			return
		if (istype(target,/obj/machinery/bathtub))
			if(src.batbomb)
				src.batbomb()
				user.u_equip(src)
				user.drop_item(src)
				qdel(src)
				return

			if (!src.reagents || !src.reagents.total_volume)
				boutput(user, "<span class='alert'>[src] doesn't contain any reagents.</span>")
				return
			if (target.reagents.is_full())
				boutput(user, "<span class='alert'>[target] is full!</span>")
				return
			else
				user.visible_message("<span class='alert'>[user] puts [src] in [target].</span>",\
				"<span class='success'>You dissolve [src] in [target].</span>")

			//logTheThing(LOG_COMBAT, user, "dissolves a bath bomb [log_reagents(src)] in [target] at [log_loc(user)].")
			reagents.trans_to(target, src.reagents.total_volume)
			user.u_equip(src)
			user.drop_item(src)
			qdel(src)
			return

		else if (istype(target,/obj/fluid))

			if(src.batbomb)
				src.batbomb()
				user.u_equip(src)
				user.drop_item(src)
				qdel(src)
				return

			user.visible_message("<span class='alert'>[user] puts [src] in [target].</span>",\
            "<span class='success'>You dissolve [src] in [target].</span>")

			//logTheThing(LOG_COMBAT, user, "dissolves a bath bomb [log_reagents(src)] in [target] at [log_loc(user)].")
			var/turf/T = get_turf(target)
			T.fluid_react(src.reagents,src.reagents.total_volume)
			user.u_equip(src)
			user.drop_item(src)
			qdel(src)
			return
		else
			return ..()

	proc/batbomb()
		if(!src.batbomb)
			return

		var/turf/T = get_turf(src)
		var/list/bat_names = list("Batholomew","Batthew","Batilda","Randy")
		if (T)
			var/batnum = rand(1,4)
			for(var/i = 0, i<batnum,i++)
				var/obj/critter/bat/B = new/obj/critter/bat(T)
				B.name = pick(bat_names)
				bat_names -= B.name
				switch(rand(1,5))
					if(1)
						step(B, NORTH)
					if(2)
						step(B, SOUTH)
					if(3)
						step(B,EAST)
					if(4)
						step(B,WEST)
					else
						continue

		src.visible_message("<span class='alert'>[src] bursts into a furry mass!</span>")
		return

	New()
		..()
		src.event_handler_flags |= USE_FLUID_ENTER

		//ensure_reagent_holder()
		var/datum/reagents/R = reagents

		var/flavor_value = rand(1,100)


		if (flavor_value == 1)
			src.batbomb = 1
			name += " - Bat Bomb Flavor"
			desc = "The noise this thing's making is driving you batty!"
			color = "#551469"

		else if (flavor_value < 7)
			name += " - Sail The Seven Cs Flavor"
			desc = "Time for a little Arr and Arr!"
			R.add_reagent("cocktail_citrus", 5)
			var/list/seas = list("carbon","charcoal","calomel","cyanide","cholesterol","cider","infernite","chocolate milk","cheese","cola","carpet","cornsyrup","capulettium")
			var/temp = null
			for(var/i=0,i<4,i++)
				temp = pick(seas)
				R.add_reagent(temp,5)
				seas -= temp
				temp = null

		else if(flavor_value < 12)
			name += " - Icy Hot Flavor"
			if(prob(10))
				desc = "You know how you turn on the shower and it's too hot but then you turn it down just a little and suddenly it's way too cold so you turn it up again and it just keeps going and going and going? Yeah."
			else
				desc = "You know, you never could get the temperature right, anyways."
			R.add_reagent("krokodil", 5)
			R.add_reagent(pick("cryostylane","infernite"),5)
			R.add_reagent("cryoxadone",5)
			R.add_reagent("capsaicin",10)


		else if(flavor_value < 17)
			name += " - Melting Into Relaxation Flavor"
			desc = "The perfect bath bomb for when you just feel like getting away from it all."
			R.add_reagent("denatured_enzyme", 10)
			if(prob(10))
				R.add_reagent("morphine",7)
			else
				R.add_reagent("haloperidol",7)

			if(prob(10))
				R.add_reagent("neurotoxin",5)
			else
				R.add_reagent("mercury",5)
			R.add_reagent("acid",3)

		else if(flavor_value < 27)
			name += " - Intervention Flavor"
			desc = "We need to talk."
			R.add_reagent("antihol", 15)
			R.add_reagent("love",5)
			R.add_reagent("hugs",5)

		else if(flavor_value < 37)
			name += " - Farty Party Flavor"
			desc = "What a blast!"
			R.add_reagent("fartonium", 10)
			R.add_reagent("refried_beans",5)
			R.add_reagent("egg",5)
			R.add_reagent("milk",5)

		else if(flavor_value < 47)
			name += " - Herbal Cleanse Flavor"
			desc = "Better out than in, I always say!"
			R.add_reagent("sewage", 5)
			R.add_reagent("coffee",5)
			R.add_reagent("ipecac",5) // NOT IN 2016
			R.add_reagent("toxic_slurry",5)
			R.add_reagent("thc",5)

		else if(flavor_value < 57)
			name += " - Public Pool Flavor"
			desc = pick("No Running!","Don't forget to wear sunscreen!","Smells like summer. Hot, sweaty, and miserable.")
			R.add_reagent("urine", 3)
			if(prob(10))
				R.add_reagent("gvomit",7)
			else
				R.add_reagent("vomit",7)
			if(prob(10))
				R.add_reagent("bloodc",5)
			else
				R.add_reagent("blood",5)
			R.add_reagent("chlorine",10)

		else if(flavor_value < 67)
			name += " - Vampire Tea Party Flavor"
			desc = "Ugh, who invited Nosferatu?"
			R.add_reagent("blood", 5)
			R.add_reagent("honey_tea",5)
			R.add_reagent("sweet_tea",5)
			R.add_reagent("tea",5)
			R.add_reagent("halfandhalf",5)

		else if(flavor_value < 77)
			name += " - Beff Bath and Byond Flavor"

			if(prob(1))
				desc = "We are here to be changed."
			else
				desc = "The fact that this thing even exists is ridiculous."
			R.add_reagent("beff", 10)
			R.add_reagent("cleaner",9)
			R.add_reagent("glitter",5)
			R.add_reagent("colors",1)

		else if(flavor_value < 87)
			name += " - Relaxation Rodeo Flavor"
			desc = "Yeet haw."
			R.add_reagent("sorium", 5)
			R.add_reagent("ghostchilijuice", 5)
			R.add_reagent("refried_beans", 5)
			R.add_reagent("pepperoni", 5)
			R.add_reagent("beff", 5)

		else
			name += " - Primal Scream Therapy Flavor"
			desc = "Just let it all out."
			R.add_reagent("ants", 3)
			R.add_reagent("spiders", 3)
			R.add_reagent("juice_lemon", 5)
			R.add_reagent("pepperoni", 5)
			R.add_reagent("salt", 4)
			R.add_reagent("styptic_powder", 5)

		if(!src.batbomb)
			if (prob(50))
				R.add_reagent("barium", 5)
			else
				R.add_reagent("potassium",5)
			R.add_reagent("salt",10)
			R.add_reagent("nicotine",10)

			src.color = R.get_average_color().to_rgb()
