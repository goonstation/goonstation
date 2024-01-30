/obj/item/stick
	name = "stick"
	desc = "You made a house out of these once in kindergarten."
	icon = 'icons/obj/foodNdrink/food_popsicles.dmi'
	icon_state = "stick"
	throwforce = 1
	throw_speed = 4
	throw_range = 5
	w_class = W_CLASS_TINY
	stamina_damage = 0
	stamina_cost = 0
	var/broken = 0

	attack_self(mob/user)
		if (user.find_in_hand(src) && !src.broken)
			user.visible_message("<b>[user]</b> bends [src] a little too far back and it snaps in half. Shoot!")
			playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 60, TRUE, 0, 2)
			src.name = "broken stick"
			src.icon_state = "stick-broken"
			src.broken = 1

/obj/item/popsicle
	name = "popsicle"
	desc = "A popsicle. It's in a wrapper right now."
	icon = 'icons/obj/foodNdrink/food_popsicles.dmi'
	icon_state = "popsiclewrapper"
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 6

	attack_self(var/mob/user)
		if (user.find_in_hand(src))
			boutput(user,SPAN_NOTICE("<b>You unwrap [src].</b>"))
			var/obj/item/reagent_containers/food/snacks/popsicle/P = new /obj/item/reagent_containers/food/snacks/popsicle(src.loc)
			user.put_in_hand_or_drop(P)
			if(prob(8))
				P.melt(user)
			qdel(src)

/obj/item/reagent_containers/food/snacks/popsicle
	name = "popsicle"
	desc = "A popsicle. It's in a wrapper right now."
	icon = 'icons/obj/foodNdrink/food_popsicles.dmi'
	icon_state = null
	bites_left = 4
	heal_amt = 4
	food_color = null
	initial_volume = 40
	var/flavor = ""
	dropped_item = /obj/item/stick

	New()
		..()
		var/datum/reagents/R = reagents
		if(prob(1))
			src.flavor = "orangecreamsicle"
			R.add_reagent("juice_orange", 5)
			R.add_reagent("omnizine", 5)
			R.add_reagent("oculine", 5)
			R.add_reagent("vanilla", 5)
			R.add_reagent("water_holy", 5)
		else
			src.flavor = pick("orange","grape","lemon","cherry","apple","blueberry")
		src.icon_state = src.flavor

		switch(flavor)
			if("orangecreamsicle")
				src.desc = "An orange popsicle, which appears to be \"Oecumenical Orange Creamsicle\" fla- wait, it's a creamsicle? HELL. YES."
			if("orange")
				src.desc = "An orange popsicle, which appears to be \"Cold Case Citrus\" flavor, for opening your sinuses again when you're having a sick day."
				R.add_reagent("juice_orange", 5)
				R.add_reagent("oculine", 5)
				R.add_reagent("chickensoup", 5)
				R.add_reagent("screwdriver", 5)
				R.add_reagent("honey_tea", 5)
			if("grape")
				src.desc = "A purple popsicle, which appears to be \"Raisin' Hell Raisin\" flavor, which features a boost of \"Super Energy Raisin Juice,\" whatever that is."
				R.add_reagent("wine", 5)
				R.add_reagent("cold_medicine", 5)
				R.add_reagent("coffee", 5)
				R.add_reagent("bread", 5)
				R.add_reagent("milk", 5)
			if("lemon")
				src.desc = "A yellowish popsicle, which appears to be \"Lemon-Lime Violent Crime\" flavor, with a tang so good it's a crime to sell this cheap."
				R.add_reagent("juice_lemon", 5)
				R.add_reagent("juice_lime", 5)
				R.add_reagent("luminol", 5)
				R.add_reagent("chalk", 5)
			if("cherry")
				src.desc = "A red popsicle, which appears to be \"'Roid Rage Redberry\" flavor, guaranteed to put you into a rage until you taste more."
				R.add_reagent("juice_strawberry", 5)
				R.add_reagent("juice_cherry", 5)
				R.add_reagent("blood", 5)
				R.add_reagent("crank", 5)
				R.add_reagent("aranesp", 5)
			if("apple")
				src.desc = "A green popsicle, which appears to be \"Green Apple Gastroenteritis\" flavor, which boasts a more active digestive system."
				R.add_reagent("juice_apple", 5)
				R.add_reagent("cider", 5)
				R.add_reagent("ipecac", 5) //?
				R.add_reagent("gcheese", 5)
				R.add_reagent("hunchback", 5)
			if("blueberry")
				src.desc = "A blue popsicle, which appears to be \"Batshit Blueberry Brain Hemorrhage\" flavor, which allegedly tastes so good it fries your brain."
				R.add_reagent("juice_blueberry", 5)
				R.add_reagent("mannitol", 5)
				R.add_reagent("haloperidol", 5)
				R.add_reagent("expresso", 5) //?
				R.add_reagent("krokodil", 5)

	heal(var/mob/M)
		..()
		M.bodytemperature = min(M.base_body_temp, M.bodytemperature-20)
		return

	proc/melt(var/mob/user)
		boutput(user,SPAN_NOTICE("<b>[src] has already melted! Damn!</b>"))
		src.reagents.reaction(get_turf(src))
		user.u_equip(src)
		src.set_loc(get_turf(user))
		qdel(src)
		var/obj/item/stick/S = new
		user.put_in_hand_or_drop(S)
		return
