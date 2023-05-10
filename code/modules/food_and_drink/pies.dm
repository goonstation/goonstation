ABSTRACT_TYPE(/obj/item/reagent_containers/snacks/pie)
/obj/item/reagent_containers/food/snacks/pie
	name = "pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	desc = "A null pie. You shouldn't be able to see this!"
	item_state = "pie"
	required_utensil = REQUIRED_UTENSIL_SPOON
	sliceable = FALSE
	var/slicetype = /obj/item/reagent_containers/food/snacks/pieslice
	var/splat = 0 // for thrown pies
	food_effects = list("food_refreshed","food_cold")

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (ismob(hit_atom) && src.splat)
			var/mob/M = hit_atom
			src.visible_message("<span class='alert'>[src] splats in [M]'s face!</span>")
			playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
			M.change_eye_blurry(rand(5,10))
			M.take_eye_damage(rand(0, 2), 1)
			if (prob(40))
				JOB_XP(M, "Clown", 2)
		else
			..()

	attackby(obj/item/W, mob/user)
		if (iscuttingtool(W) || issawingtool(W))
			if(user.bioHolder.HasEffect("clumsy") && prob(50))
				user.visible_message("<span class='alert'><b>[user]</b> fumbles and jabs [himself_or_herself(user)] in the eye with [W].</span>")
				user.change_eye_blurry(5)
				user.changeStatus("weakened", 3 SECONDS)
				JOB_XP(user, "Clown", 2)
				return

			if(sliceable == FALSE)
				return

			var/turf/T = get_turf(src)
			user.visible_message("[user] cuts [src] into slices.", "You cut [src] into slices.")
			var/makeslices = 8
			while (makeslices > 0)
				new slicetype (T)
				makeslices -= 1
			qdel (src)
		else ..()

/obj/item/reagent_containers/food/snacks/pieslice
	name = "slice of pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	desc = "A slice of null pie. You shouldn't be able to see this!"
	required_utensil = REQUIRED_UTENSIL_SPOON
	food_effects = list("food_refreshed","food_cold")
	bites_left = 1
	heal_amt = 4
	initial_volume = 5
	apple
		icon_state = "applepie-slice"
		initial_reagents = list("juice_apple"=3)
		desc = "A slice of apple pie. Is there anything more Space-American?"
	lime
		icon_state = "limepie-slice"
		initial_reagents = list("juice_lime"=3)
		desc = "A slice of key lime pie. Tart, sweet, and with a dollop of cream on top."
	lemon
		icon_state = "lemonpie-slice"
		initial_reagents = list("juice_lemon"=3)
		desc = "A slice of lemon meringue pie. A fine use of fruit curd."
	strawberry
		icon_state = "strawberrypie-slice"
		initial_reagents = list("juice_strawberry"=3)
		desc = "A slice of strawberry pie. It smells like summertime memories."
	pumpkin
		icon_state = "pumpie-slice"
		initial_reagents = list("juice_pumpkin"=3)
		desc = "A slice of pumpkin pie. An autumn favourite."
	chocolate
		icon_state = "chocolatepie-slice"
		initial_reagents = list("sugar"=3, "hugs"=2)
		desc = "Like a slice of chocolate cake, but a slice of pie, and also very different."
	raspberry
		icon_state = "raspberrypie-slice"
		initial_reagents = list("juice_raspberry"=3)
		desc = "A slice of raspberry pie. Those are fresh raspberries, too. Oh man."
	blackberry
		icon_state = "blackberrypie-slice"
		initial_reagents = list("juice_blackberry"=3)
		desc = "A slice of balckberry pie. The stains will be oh so worth it."
	blueberry
		icon_state = "blueberrypie-slice"
		initial_reagents = list("juice_blueberry"=3)
		desc = "A slice of blueberry pie. Blueberries cook up purple, who knew?"
	cherry
		icon_state = "cherrypie-slice"
		initial_reagents = list("juice_cherry"=3)
		desc = "A slice of cherry pie. It looks so good, it brings a tear to you eye."

/obj/item/reagent_containers/food/snacks/pie/custard
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	splat = 1
	required_utensil = REQUIRED_UTENSIL_SPOON
	bites_left = 3
	throwforce = 0
	force = 0

/obj/item/reagent_containers/food/snacks/pie/apple
	name = "apple pie"
	desc = "Is there anything more Space-American?"
	icon_state = "applepie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 30
	initial_reagents = list("juice_apple"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/apple

/obj/item/reagent_containers/food/snacks/pie/lime
	name = "key lime pie"
	desc = "Tart, sweet, and with a dollop of cream on top."
	icon_state = "limepie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 30
	initial_reagents = list("juice_lime"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/lime


/obj/item/reagent_containers/food/snacks/pie/lemon
	name = "lemon meringue pie"
	desc = "A fine use of fruit curd."
	icon_state = "lemonpie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_lemon"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/lemon

/obj/item/reagent_containers/food/snacks/pie/strawberry
	name = "strawberry pie"
	desc = "It smells like summertime memories."
	icon_state = "strawberrypie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_strawberry"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/strawberry

/obj/item/reagent_containers/food/snacks/pie/pumpkin
	name = "pumpkin pie"
	desc = "An autumn favourite."
	icon_state = "pumpie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_pumpkin"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/pumpkin

/obj/item/reagent_containers/food/snacks/pie/cream
	name = "cream pie"
	desc = "More often used in pranks than culinary matters..."
	icon_state = "creampie"
	splat = 1
	required_utensil = REQUIRED_UTENSIL_SPOON
	throwforce = 0
	force = 0
	bites_left = 2
	heal_amt = 6

/obj/item/reagent_containers/food/snacks/pie/anything
	name = "anything pie"
	desc = "An empty anything pie. You shouldn't be able to see this!"
	icon_state = "pie"
	bites_left = 3
	heal_amt = 4
	use_bite_mask = FALSE

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (contents)
			var/atom/movable/randomContent
			if (contents.len >= 1)
				randomContent = pick(contents)
			else
				randomContent = src

			hit_atom.Attackby(randomContent, thr?.user)

			if (ismob(hit_atom))
				playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 100, 1)
				var/mob/M = hit_atom
				if (M == thr.user)
					src.visible_message("<span class='alert'>[thr.user] fumbles and smacks the [src] into their own face!</span>")
				else
					src.visible_message("<span class='alert'>[src] smacks into [M]!</span>")

	Exited(atom/movable/Obj, newloc)
		. = ..()
		if(!QDELETED(Obj))
			Obj.visible_message("<span class='alert'>[Obj] dissolves completely upon leaving [src]!</span>")
			qdel(Obj)

/obj/item/reagent_containers/food/snacks/pie/slurry
	name = "slurry pie"
	desc = "Though dangerous to eat raw, the slurrypod produces a fine, tart pie noted for its curative properties."
	icon_state = "slurrypie"
	bites_left = 3
	heal_amt = 5
	initial_volume = 30
	initial_reagents = list("mutadone"=15)
	food_effects = list("food_bad_breath","food_cold")

/obj/item/reagent_containers/food/snacks/pie/bacon
	name = "bacon pie"
	desc = "Named in honor of Sir Francis Bacon, who tragically died as the result of an early experiment into the field of bacon ice cream."
	icon_state = "baconpie"
	bites_left = 3
	heal_amt = 6
	initial_volume = 80
	initial_reagents = list("porktonium"=75)
	food_effects = list("food_sweaty", "food_hp_up_big", "food_cold")


	heal(var/mob/M)
		..()
		M.nutrition += 500
		return

/obj/item/reagent_containers/food/snacks/pie/ass
	name = "moon pie" // it's 2020 jabronis, out with the ableism ;)
	desc = "Thicc."
	icon_state = "asspie"
	splat = 1
	throwforce = 0
	force = 0
	bites_left = 3
	heal_amt = 2
	food_effects = list("food_sweaty_big","food_refreshed")
	New()
		..()
		if(prob(10))
			name = pick("fart pie","butt pie","mud pie","piesterior","ham pie","dump cake","derri-eclaire")

/obj/item/reagent_containers/food/snacks/pie/chocolate
	name = "chocolate mud pie"
	desc = "Like a chocolate cake, but a pie, and also very different."
	icon_state = "chocolatepie"
	heal_amt = 6
	bites_left = 3
	initial_volume = 30
	initial_reagents = list("sugar"=20,"hugs"=10)
	food_effects = list("food_sweaty","food_refreshed", "food_explosion_resist")
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/chocolate

/obj/item/reagent_containers/food/snacks/pie/pot
	name = "space-chicken pot pie"
	desc = "Space-chickens are identical to regular chickens, but in space.  This is a pastry filled with their cooked flesh, some vegetables, and a cream gravy."
	icon_state = "chickenpie"
	heal_amt = 6
	bites_left = 3
	initial_volume = 30
	initial_reagents = list("chickensoup"=20)
	food_effects = list("food_sweaty","food_hp_up_big","food_refreshed")

/obj/item/reagent_containers/food/snacks/pie/weed
	name = "chicken \"pot\" pie"
	desc = "Something about this pie seems off.  Guaranteed to get you pie-in-the-sky high."
	icon_state = "weedpie"
	heal_amt = 4
	bites_left = 3
	initial_volume = 30
	initial_reagents = list("THC"=20,"CBD"=20)
	food_effects = list("food_sweaty","food_refreshed")

/obj/item/reagent_containers/food/snacks/pie/fish
	name = "stargazy pie"
	desc = "The snack that stares back."
	icon_state = "fishpie"
	heal_amt = 4
	bites_left = 3
	initial_volume = 30
	food_effects = list("food_sweaty","food_rad_resist","food_refreshed")

/obj/item/reagent_containers/food/snacks/pie/raspberry
	name = "raspberry pie"
	desc = "Those are fresh raspberries, too. Oh man."
	icon_state = "raspberrypie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_raspberry"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/raspberry

/obj/item/reagent_containers/food/snacks/pie/blackberry
	name = "blackberry pie"
	desc = "The stains will be oh so worth it."
	icon_state = "blackberrypie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_blackberry"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/blackberry

/obj/item/reagent_containers/food/snacks/pie/blueberry
	name = "blueberry pie"
	desc = "Blueberries cook up purple, who knew?"
	icon_state = "blueberrypie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_blueberry"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/blueberry

/obj/item/reagent_containers/food/snacks/pie/cherry
	name = "cherry pie"
	desc = "It looks so good, it brings a tear to you eye."
	icon_state = "cherrypie"
	bites_left = 3
	heal_amt = 4
	initial_volume = 32
	initial_reagents = list("juice_cherry"=24)
	sliceable = TRUE
	slicetype = /obj/item/reagent_containers/food/snacks/pieslice/cherry
