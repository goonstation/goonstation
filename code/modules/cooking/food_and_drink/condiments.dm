// Condiments

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/condiment)
/obj/item/reagent_containers/food/snacks/condiment
	name = "condiment"
	desc = "you shouldn't be able to see this"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	amount = 1
	heal_amt = 0

	heal(var/mob/M)
		..()
		boutput(M, SPAN_ALERT("It's just not good enough on its own..."))

	afterattack(atom/target, mob/user, flag)
		if (!src.reagents || !src.reagents?.total_volume || QDELETED(src)) return //how
		if (istype(target, /obj/item/reagent_containers/food/snacks/condiment))
			boutput(user, "<span class='alert'>You can't flavour a condiment!</span>")
			return

		if (istype(target, /obj/item/reagent_containers/food/snacks/))
			user.visible_message(SPAN_NOTICE("[user] adds [src] to \the [target]."), SPAN_NOTICE("You add [src] to \the [target]."))
			src.reagents.trans_to(target, 100)
			qdel (src)
			return

		if (istype(target, /obj/item/reagent_containers/))
			user.visible_message(SPAN_NOTICE("<b>[user]</b> crushes up \the [src] in \the [target]."),\
			SPAN_NOTICE("You crush up \the [src] in \the [target]."))
			src.reagents.trans_to(target, 100)
			qdel (src)

		else return

/obj/item/reagent_containers/food/snacks/condiment/ironfilings
	name = "iron filings"
	desc = "You probably shouldn't eat these."
	icon_state = "ironfilings"
	heal_amt = 0

/obj/item/reagent_containers/food/snacks/condiment/ketchup
	name = "ketchup"
	desc = "Puréed tomatoes as a sauce."
	icon_state = "sachet-ketchup"
	initial_volume = 30
	initial_reagents = list("ketchup"=20)

/obj/item/reagent_containers/food/snacks/condiment/syrup
	name = "maple syrup"
	desc = "Made with real artificial maple syrup!"
	icon_state = "syrup"

/obj/item/reagent_containers/food/snacks/condiment/gravyboat
	name = "gravy boat"
	desc = "Not actually a boat, but that sure is gravy."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "gravyboat"
	initial_volume = 10
	initial_reagents = list("gravy"=10)

/obj/item/reagent_containers/food/snacks/condiment/soysauce
	name = "soy sauce"
	desc = "A dark brown sauce brewed from soybeans and wheat. Salty!"
	icon_state = "soy-sauce"
	initial_volume = 30
	initial_reagents = "soysauce"

	heal(var/mob/M)
		. = ..()
		boutput(M, SPAN_ALERT("FUCK, SALTY!"))
		M.emote("scream")

/obj/item/reagent_containers/food/snacks/condiment/mayo
	name = "mayonnaise"
	desc = "The subject of many a tiresome innuendo."
	icon_state = "mayonnaise" //why the fuck was this icon state called cookie
	initial_volume = 5
	#ifdef SECRETS_ENABLED
	initial_reagents = "mayo"
	#endif

/obj/item/reagent_containers/food/snacks/condiment/hotsauce
	name = "hot sauce"
	desc = "Dangerously spicy!"
	icon_state = "sachet-hot"
	initial_volume = 100
	initial_reagents = "capsaicin"

/obj/item/reagent_containers/food/snacks/condiment/coldsauce
	name = "cold sauce"
	desc = "This isn't very hot at all!"
	icon_state = "sachet-cold"
	initial_volume = 100
	initial_reagents = "cryostylane"

/obj/item/reagent_containers/food/snacks/condiment/hotsauce/ghostchilisauce
	name = "incredibly hot sauce"
	desc = "Extraordinarily spicy!"
	icon_state = "sachet-hot"
	initial_volume = 100
	initial_reagents = list("capsaicin"=50,"ghostchilijuice"=50)

/obj/item/reagent_containers/food/snacks/condiment/syndisauce
	name = "syndicate sauce"
	desc = "Traitorous tang."
	icon_state = "sachet-cold"
	initial_volume = 100
	initial_reagents = list("amanitin"=50)

/obj/item/reagent_containers/food/snacks/condiment/cream
	name = "cream"
	desc = "Not related to any kind of crop."
	icon_state = "cream" //ITS NOT A GODDAMN COOKIE
	food_color = "#F8F8F8"
	initial_volume = 10
	initial_reagents = list("cream"=10)

/obj/item/reagent_containers/food/snacks/condiment/custard
	name = "custard"
	desc = "A perennial favourite of clowns."
	icon_state = "custard"
	required_utensil = REQUIRED_UTENSIL_SPOON
	bites_left = 2
	heal_amt = 3

/obj/item/reagent_containers/food/snacks/condiment/matcha
	name = "matcha"
	desc = "A powder created from dried tea leaves."
	icon_state = "matcha"
	initial_volume = 10
	initial_reagents = "matcha"
	food_color = "#74A12E"

/obj/item/reagent_containers/food/snacks/condiment/mustard
	name = "mustard"
	desc = "A sauce of ground mustard seeds."
	icon_state = "mustard"
	initial_volume = 30
	initial_reagents = list("mustard" = 20)

/obj/item/reagent_containers/food/snacks/condiment/chocchips
	name = "chocolate chips"
	desc = "Mmm! Little bits of chocolate! Or rabbit droppings. Either or."
	icon_state = "chocchips"
	bites_left = 5
	heal_amt = 1
	initial_volume = 10
	initial_reagents = "chocolate"

	afterattack(atom/target, mob/user, flag)
		if (istype(target, /obj/item/reagent_containers/food/snacks/) && src.reagents) //Wire: fix for Cannot execute null.trans to()
			user.visible_message(SPAN_NOTICE("[user] sprinkles [src] onto [target]."), SPAN_NOTICE("You sprinkle [src] onto [target]."))
			src.reagents.trans_to(target, 20)
			qdel (src)
		else return

/obj/item/reagent_containers/food/snacks/condiment/butters
	name = "butt-er"
	desc = "Fluffy and fragrant."
	icon_state = "butters"
	heal_amt = 3
	fill_amt = 2
	initial_volume = 20

	New()
		..()
		reagents.add_reagent("cholesterol", 20)

/obj/item/shaker // todo: rewrite shakers to not be horrible hacky nonsense - haine
	name = "shaker"
	desc = "A little bottle for shaking things onto other things."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "shaker"
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	g_amt = 10
	var/stuff = null
	var/shakes = 0
	var/myVerb = "shake"

	afterattack(atom/A, mob/user as mob)
		if (src.shakes >= 15)
			user.show_text("[src] is empty!", "red")
			return
		if (istype(A, /obj/item/reagent_containers/food))
			A.reagents.add_reagent("[src.stuff]", 2)
			src.shakes ++
			user.show_text("You put some [src.stuff] onto [A].")
		else if (istype(A, /obj/item/reagent_containers/glass/beaker))
			A.reagents.add_reagent("[src.stuff]", 5)
			src.shakes += 5
			user.show_text("You [src.myVerb] some [src.stuff] into [A]")
		else
			return ..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.shakes >= 15)
			user.show_text("[src] is empty!", "red")
			return
		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES))
				H.tri_message(user, SPAN_ALERT("<b>[user]</b> uselessly [myVerb]s some [src.stuff] onto [H]'s headgear!"),\
					SPAN_ALERT("[H == user ? "You uselessly [myVerb]" : "[user] uselessly [myVerb]s"] some [src.stuff] onto your headgear! Okay then."),\
					SPAN_ALERT("You uselessly [myVerb] some [src.stuff] onto [user == H ? "your" : "[H]'s"] headgear![user == H ? " Okay then." : null]"))
				src.shakes ++
				return
			else
				switch (src.stuff)
					if ("salt")
						logTheThing(LOG_COMBAT, user, "uses [src] on [constructTarget(H, "combat")] at [log_loc(user)].")
						H.tri_message(user, SPAN_ALERT("<b>[user]</b> [myVerb]s something into [H]'s eyes!"),\
							SPAN_ALERT("[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some salt into your eyes! <B>FUCK THAT STINGS!</B>"),\
							SPAN_ALERT("You [myVerb] some salt into [user == H ? "your" : "[H]'s"] eyes![user == H ? " <B>FUCK THAT STINGS!</B>" : null]"))
						random_brute_damage(user, 1)
						H.change_eye_blurry(rand(10, 16))
						H.take_eye_damage(rand(12, 16))
						src.shakes ++
						return
					if ("pepper")
						H.tri_message(user, SPAN_ALERT("<b>[user]</b> [myVerb]s something onto [H]'s nose!"),\
							SPAN_ALERT("[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some pepper onto your nose! <B>Why?!</B>"),\
							SPAN_ALERT("You [myVerb] some pepper onto [user == H ? "your" : "[H]'s"] nose![user == H ? " <B>Why?!</B>" : null]"))
						H.emote("sneeze")
						src.shakes ++
						for (var/i = 1, i <= 30, i++)
							SPAWN(50*i)
								if (H && prob(20)) //Wire: Fix for Cannot execute null.emote().
									H.emote("sneeze")
						return
					else
						H.tri_message(user, SPAN_ALERT("<b>[user]</b> [myVerb]s some [src.stuff] at [H]'s head!"),\
							SPAN_ALERT("[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some [src.stuff] at your head! Fuck!"),\
							SPAN_ALERT("You [myVerb] some [src.stuff] at [user == H ? "your" : "[H]'s"] head![user == H ? " Fuck!" : null]"))
						src.shakes ++
						return
		else if (istype(target, /mob/living/critter/small_animal/slug) && src.stuff == "salt")
			target.visible_message(SPAN_ALERT("<b>[user]</b> [myVerb]s some salt onto [target] and it shrivels up!"),\
			SPAN_ALERT("<b>OH GOD THE SALT [pick("IT BURNS","HOLY SHIT THAT HURTS","JESUS FUCK YOU'RE DYING")]![pick("","!","!!")]</b>"))
			target.TakeDamage(null, 15, 15)
			src.shakes ++
			return

		else
			return ..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/))
			if (W.reagents.has_reagent("[src.stuff]") && W.reagents.get_reagent_amount("[src.stuff]") >= 15)
				user.show_text("You refill [src].", "blue")
				W.reagents.remove_reagent("[src.stuff]", 15)
				src.shakes = 0
				return
			else
				user.show_text("There isn't enough [src.stuff] in here to refill [src]!", "red")
				return
		else
			return ..()

	salt
		name = "salt shaker"
		desc = "A little bottle for shaking things onto other things. It has some salt in it."
		icon_state = "shaker-salt"
		stuff = "salt"

	pepper
		name = "pepper shaker"
		desc = "A little bottle for shaking things onto other things. It has some pepper in it."
		icon_state = "shaker-pepper"
		stuff = "pepper"

	ketchup
		name = "ketchup bottle"
		desc = "A little bottle for putting condiments on stuff. It has some ketchup in it."
		icon_state = "bottle-ketchup"
		stuff = "ketchup"
		myVerb = "squirt"

	mustard
		name = "mustard bottle"
		desc = "A little bottle for putting condiments on stuff. It has some mustard in it."
		icon_state = "bottle-mustard"
		stuff = "mustard"
		myVerb = "squirt"

