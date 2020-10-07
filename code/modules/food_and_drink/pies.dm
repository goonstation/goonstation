
/obj/item/reagent_containers/food/snacks/pie
	name = "pie"
	icon = 'icons/obj/foodNdrink/food_dessert.dmi'
	desc = "A null pie. You shouldn't be able to see this!"
	item_state = "pie"
	needspoon = 1
	var/splat = 0 // for thrown pies
	food_effects = list("food_refreshed","food_cold")

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (ismob(hit_atom) && src.splat)
			var/mob/M = hit_atom
			src.visible_message("<span class='alert'>[src] splats in [M]'s face!</span>")
			playsound(get_turf(src), "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
			M.change_eye_blurry(rand(5,10))
			M.take_eye_damage(rand(0, 2), 1)
			if (prob(40))
				JOB_XP(M, "Clown", 2)
		else
			..()

/obj/item/reagent_containers/food/snacks/pie/custard
	name = "custard pie"
	desc = "It smells delicious. You just want to plant your face in it."
	icon_state = "pie"
	splat = 1
	needspoon = 1
	amount = 3
	throwforce = 0
	force = 0

/obj/item/reagent_containers/food/snacks/pie/apple
	name = "apple pie"
	desc = "It smells delicious."
	icon_state = "pie"
	amount = 3
	heal_amt = 4

/obj/item/reagent_containers/food/snacks/pie/lime
	name = "key lime pie"
	desc = "Shouldn't the topping be white? Space is weird."
	icon_state = "limepie"
	amount = 3
	heal_amt = 4
	var/has_key = 0
	var/static/had_key = 0
	initial_volume = 30
	initial_reagents = list("juice_lime"=15)

	New()
		..()
		if (prob(6) && !had_key)
			had_key = 1
			src.has_key = 1
		return

	heal(var/mob/M)
		..()
		if (has_key)
			src.has_key = 0
			M.visible_message("<span class='alert'>[M] pulls a key out of [src]!</span>","<span class='alert'>You discover an iron key in [src]! Gross!</span>")
			new /obj/item/device/key/haunted(get_turf(src))
		return

/obj/item/reagent_containers/food/snacks/pie/lemon
	name = "lemon meringue pie"
	desc = "A fine use of fruit curd."
	icon_state = "lemonpie"
	amount = 3
	heal_amt = 4
	initial_volume = 30
	initial_reagents = list("juice_lemon"=15)

/obj/item/reagent_containers/food/snacks/pie/strawberry
	name = "strawberry pie"
	desc = "It smells delicious."
	icon_state = "strawberrypie"
	amount = 3
	heal_amt = 4
	initial_volume = 30
	initial_reagents = list("juice_strawberry"=15)

/obj/item/reagent_containers/food/snacks/pie/pumpkin
	name = "pumpkin pie"
	desc = "An autumn favourite."
	icon_state = "pumpie"
	amount = 3
	heal_amt = 4

/obj/item/reagent_containers/food/snacks/pie/cream
	name = "cream pie"
	desc = "More often used in pranks than culinary matters..."
	icon_state = "creampie"
	splat = 1
	needspoon = 1
	throwforce = 0
	force = 0
	amount = 2
	heal_amt = 6

/obj/item/reagent_containers/food/snacks/pie/anything
	name = "anything pie"
	desc = "An empty anything pie. You shouldn't be able to see this!"
	icon_state = "pie"
	amount = 3
	heal_amt = 4
	use_bite_mask = 0

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		if (contents)
			var/atom/movable/randomContent
			if (contents.len >= 1)
				randomContent = pick(contents)
			else
				randomContent = src

			if (randomContent != src)
				randomContent.throw_impact(hit_atom)

			hit_atom.attackby(randomContent, thr?.user)

			if (ismob(hit_atom))
				playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 100, 1)
				var/mob/M = hit_atom
				if (M == thr.user)
					src.visible_message("<span class='alert'>[thr.user] fumbles and smacks the [src] into their own face!</span>")
				else
					src.visible_message("<span class='alert'>[src] smacks into [M]!</span>")

/obj/item/reagent_containers/food/snacks/pie/slurry
	name = "slurry pie"
	desc = "Though dangerous to eat raw, the slurrypod produces a fine, tart pie noted for its curative properties."
	icon_state = "slurrypie"
	amount = 3
	heal_amt = 5
	initial_volume = 30
	initial_reagents = list("mutadone"=15)
	food_effects = list("food_bad_breath","food_cold")

/obj/item/reagent_containers/food/snacks/pie/bacon
	name = "bacon pie"
	desc = "Named in honor of Sir Francis Bacon, who tragically died as the result of an early experiment into the field of bacon ice cream."
	icon_state = "baconpie"
	amount = 3
	heal_amt = 6
	initial_volume = 80
	initial_reagents = list("porktonium"=75)
	food_effects = list("food_sweaty", "food_hp_up_big", "food_cold")


	heal(var/mob/M)
		M.nutrition += 500
		return

/obj/item/reagent_containers/food/snacks/pie/ass
	name = "moon pie" // it's 2020 jabronis, out with the ableism ;)
	desc = "Thicc."
	icon_state = "asspie"
	splat = 1
	throwforce = 0
	force = 0
	amount = 3
	heal_amt = 2
	food_effects = list("food_sweaty_big","food_refreshed")
	New()
		..()
		if(prob(10))
			name = pick("fart pie","butt pie","mud pie","piesterior","ham pie","dump cake","derri-eclaire")

/obj/item/reagent_containers/food/snacks/pie/pot
	name = "space-chicken pot pie"
	desc = "Space-chickens are identical to regular chickens, but in space.  This is a pastry filled with their cooked flesh, some vegetables, and a cream gravy."
	icon_state = "pie"
	heal_amt = 6
	amount = 3
	initial_volume = 30
	initial_reagents = list("chickensoup"=20)
	food_effects = list("food_sweaty","food_hp_up_big","food_refreshed")
