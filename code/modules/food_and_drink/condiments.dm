// Condiments

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/condiment)
/obj/item/reagent_containers/food/snacks/condiment
	name = "condiment"
	desc = "you shouldnt be able to see this"
	icon = 'icons/obj/foodNdrink/food_ingredient.dmi'
	amount = 1
	heal_amt = 0

	heal(var/mob/M)
		..()
		boutput(M, "<span class='alert'>It's just not good enough on its own...</span>")

	afterattack(atom/target, mob/user, flag)
		if (!src.reagents || src.qdeled || src.disposed) return //how

		if (istype(target, /obj/item/reagent_containers/food/snacks/))
			user.visible_message("<span class='notice'>[user] adds [src] to \the [target].</span>", "<span class='notice'>You add [src] to \the [target].</span>")
			src.reagents.trans_to(target, 100)
			qdel (src)
			return

		if (istype(target, /obj/item/reagent_containers/))
			user.visible_message("<span class='notice'><b>[user]</b> crushes up \the [src] in \the [target].</span>",\
			"<span class='notice'>You crush up \the [src] in \the [target].</span>")
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
	desc = "Pureéd tomatoes as a sauce."
	icon_state = "sachet-ketchup"
	initial_volume = 30
	initial_reagents = list("ketchup"=20)

/obj/item/reagent_containers/food/snacks/condiment/syrup
	name = "maple syrup"
	desc = "Made with real artificial maple syrup!"
	icon_state = "syrup"

/obj/item/reagent_containers/food/snacks/condiment/soysauce
	name = "soy sauce"
	desc = "A dark brown sauce brewed from soybeans and wheat. Salty!"
	icon_state = "soy-sauce"
	initial_volume = 30
	initial_reagents = "soysauce"

	heal(var/mob/M)
		. = ..()
		boutput(M, "<span class='alert'>FUCK, SALTY!</span>")
		M.emote("scream")

/obj/item/reagent_containers/food/snacks/condiment/mayo
	name = "mayonnaise"
	desc = "The subject of many a tiresome innuendo."
	icon_state = "mayonnaise" //why the fuck was this icon state called cookie
	initial_volume = 5
	initial_reagents = "mayo"

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
			user.visible_message("<span class='notice'>[user] sprinkles [src] onto [target].</span>", "<span class='notice'>You sprinkle [src] onto [target].</span>")
			src.reagents.trans_to(target, 20)
			qdel (src)
		else return

/obj/item/reagent_containers/food/snacks/condiment/butters
	name = "butt-er"
	desc = "Fluffy and fragrant."
	icon_state = "butters"
	heal_amt = 3
	initial_volume = 20

	New()
		..()
		reagents.add_reagent("cholesterol", 20)

/obj/item/shaker // todo: rewrite shakers to not be horrible hacky nonsense - haine
	name = "shaker"
	desc = "A little bottle for shaking things onto other things."
	icon = 'icons/obj/foodNdrink/food.dmi'
	icon_state = "shaker"
	flags = FPRINT | TABLEPASS
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

	attack(mob/M, mob/user)
		if (src.shakes >= 15)
			user.show_text("[src] is empty!", "red")
			return
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if ((H.head && H.head.c_flags & COVERSEYES) || (H.wear_mask && H.wear_mask.c_flags & COVERSEYES) || (H.glasses && H.glasses.c_flags & COVERSEYES))
				H.tri_message(user, "<span class='alert'><b>[user]</b> uselessly [myVerb]s some [src.stuff] onto [H]'s headgear!</span>",\
					"<span class='alert'>[H == user ? "You uselessly [myVerb]" : "[user] uselessly [myVerb]s"] some [src.stuff] onto your headgear! Okay then.</span>",\
					"<span class='alert'>You uselessly [myVerb] some [src.stuff] onto [user == H ? "your" : "[H]'s"] headgear![user == H ? " Okay then." : null]</span>")
				src.shakes ++
				return
			else
				switch (src.stuff)
					if ("salt")
						H.tri_message(user, "<span class='alert'><b>[user]</b> [myVerb]s something into [H]'s eyes!</span>",\
							"<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some salt into your eyes! <B>FUCK!</B></span>",\
							"<span class='alert'>You [myVerb] some salt into [user == H ? "your" : "[H]'s"] eyes![user == H ? " <B>FUCK!</B>" : null]</span>")
						random_brute_damage(user, 1)
						src.shakes ++
						return
					if ("pepper")
						H.tri_message(user, "<span class='alert'><b>[user]</b> [myVerb]s something onto [H]'s nose!</span>",\
							"<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some pepper onto your nose! <B>Why?!</B></span>",\
							"<span class='alert'>You [myVerb] some pepper onto [user == H ? "your" : "[H]'s"] nose![user == H ? " <B>Why?!</B>" : null]</span>")
						H.emote("sneeze")
						src.shakes ++
						for (var/i = 1, i <= 30, i++)
							SPAWN(50*i)
								if (H && prob(20)) //Wire: Fix for Cannot execute null.emote().
									H.emote("sneeze")
						return
					else
						H.tri_message(user, "<span class='alert'><b>[user]</b> [myVerb]s some [src.stuff] at [H]'s head!</span>",\
							"<span class='alert'>[H == user ? "You [myVerb]" : "[user] [myVerb]s"] some [src.stuff] at your head! Fuck!</span>",\
							"<span class='alert'>You [myVerb] some [src.stuff] at [user == H ? "your" : "[H]'s"] head![user == H ? " Fuck!" : null]</span>")
						src.shakes ++
						return
		else if (istype(M, /mob/living/critter/small_animal/slug) && src.stuff == "salt")
			M.visible_message("<span class='alert'><b>[user]</b> [myVerb]s some salt onto [M] and it shrivels up!</span>",\
			"<span class='alert'><b>OH GOD THE SALT [pick("IT BURNS","HOLY SHIT THAT HURTS","JESUS FUCK YOU'RE DYING")]![pick("","!","!!")]</b></span>")
			M.TakeDamage(null, 15, 15)
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

