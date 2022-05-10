
/obj/item/reagent_containers/food/snacks/breadloaf
	name = "loaf of bread"
	desc = "I'm loafin' it!"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "breadloaf"
	bites_left = 1
	heal_amt = 1
	food_color = "#FFFFCC"
	real_name = "bread"
	flags = ONBELT | FPRINT | TABLEPASS
	var/slicetype = /obj/item/reagent_containers/food/snacks/breadslice
	initial_volume = 30
	initial_reagents = "bread"
	food_effects = list("food_hp_up")

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You can't just cram that in your mouth, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/knife/butcher))
			if(user.bioHolder.HasEffect("clumsy") && prob(50))
				user.visible_message("<span class='alert'><b>[user]</b> fumbles and jabs [himself_or_herself(user)] in the eye with [W].</span>")
				user.change_eye_blurry(5)
				user.changeStatus("weakened", 3 SECONDS)
				JOB_XP(user, "Clown", 2)
				return

			var/turf/T = get_turf(src)
			user.visible_message("[user] cuts [src] into slices.", "You cut [src] into slices.")
			var/makeslices = 6
			while (makeslices > 0)
				new slicetype (T)
				makeslices -= 1
			qdel (src)
		else ..()

/obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	name = "loaf of honey-wheat bread"
	desc = "A bread made with honey. Right there in the name, first thing, top billing."
	icon_state = "honeyloaf"
	real_name = "honey-wheat bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/honeywheat

/obj/item/reagent_containers/food/snacks/breadloaf/banana
	name = "loaf of banana bread"
	desc = "A bread commonly found near clowns."
	icon_state = "bananabread"
	real_name = "banana bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/banana

/obj/item/reagent_containers/food/snacks/breadloaf/brain
	name = "loaf of brain bread"
	desc = "A pretty smart way to eat."
	icon_state = "brainbread"
	real_name = "brain bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/brain

/obj/item/reagent_containers/food/snacks/breadloaf/pumpkin
	name = "loaf of pumpkin bread"
	desc = "A very seasonal quickbread!  It tastes like Fall."
	icon_state = "pumpkinbread"
	real_name = "pumpkin bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/pumpkin

/obj/item/reagent_containers/food/snacks/breadloaf/elvis
	name = "loaf of elvis bread"
	desc = "Fattening and delicious, despite the hair.  It tastes like the soul of rock and roll."
	icon_state = "elvisbread"
	real_name ="elvis bread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/elvis

/obj/item/reagent_containers/food/snacks/breadloaf/spooky
	name = "loaf of dread"
	desc = "The bread of the damned."
	icon_state = "dreadloaf"
	real_name = "dread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/spooky

/obj/item/reagent_containers/food/snacks/breadloaf/corn
	name = "southern-style cornbread"
	desc = "A maize-based quickbread.  This variety, popular in the Southern United States, is not particularly sweet."
	icon_state= "cornbread"
	real_name = "cornbread"
	slicetype = /obj/item/reagent_containers/food/snacks/breadslice/corn

	sweet
		name = "northern-style cornbread"
		desc = "A chunk of sweet maize-based quickbread."
		slicetype = /obj/item/reagent_containers/food/snacks/breadslice/corn/sweet

		honey
			name = "honey cornbread"
			desc = "A chunk of honey-sweetened maize-based quickbread."
			slicetype = /obj/item/reagent_containers/food/snacks/breadslice/corn/sweet/honey

/obj/item/reagent_containers/food/snacks/breadslice
	name = "slice of bread"
	desc = "That's slice."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "breadslice"
	bites_left = 1
	heal_amt = 1
	food_color = "#FFFFCC"
	real_name = "bread"
	initial_volume = 5
	initial_reagents = "bread"
	food_effects = list("food_hp_up")

	honeywheat
		name = "slice of honey-wheat bread"
		desc = "A slice of bread distinguished by the use of honey in its creation.  Also wheat."
		icon_state = "honeyslice"
		real_name = "honey-wheat bread"
		food_color = "#C07D1E"
		food_effects = list("food_hp_up","food_energized")

	banana
		name = "slice of banana bread"
		desc = "It's a slice.  A slice of banana bread."
		icon_state = "bananabreadslice"
		heal_amt = 4
		real_name = "banana bread"
		food_color = "#633821"
		food_effects = list("food_hp_up","food_energized")

	brain
		name = "slice of brain bread"
		desc = "A slice of bread that may or may not be plotting world domination."
		icon_state = "brainbreadslice"
		heal_amt = 3
		real_name = "brain bread"
		food_color = "#DD90A3"
		food_effects = list("food_hp_up_big")

	pumpkin
		name = "slice of pumpkin bread"
		desc = "A slice of a festive seasonal bread, vaguely like eating a loaf of pumpkin pie."
		icon_state = "pumpkinbreadslice"
		heal_amt = 5
		real_name = "pumpkin bread"
		food_color = "#D99C1B"
		food_effects = list("food_hp_up", "food_all")

	elvis
		name = "slice of elvis bread"
		desc = "A slice of the most incredible bread you have ever seen."
		icon_state = "elvisslice"
		heal_amt = 6
		real_name = "elvis bread"
		initial_volume = 30
		initial_reagents = list("bread"=5,"essenceofelvis"=25)
		food_effects = list("food_sweaty","food_energized")

	spooky
		name = "slice of dread"
		desc = "A slice of the scariest bread imaginable, even scarier than the buns on a microwaved vending machine hamburger."
		icon_state = "dreadslice"
		heal_amt = 2
		real_name = "dread"
		initial_volume = 20
		initial_reagents = list("bread"=5,"ectoplasm"=10)
		food_effects = list("food_all")

	corn
		name = "piece of southern cornbread"
		desc = "A chunk of maize-based quickbread.  This variety, popular in the Southern United States, is not particularly sweet."
		icon_state = "cornbreadslice"
		heal_amt = 3
		real_name = "cornbread"
		food_color = "#BAAC2C"
		food_effects = list("food_all")


	corn/sweet
		name = "piece of northern cornbread"
		desc = "A chunk of sweet maize-based quickbread."
		initial_volume = 10
		initial_reagents = list("bread"=5,"cornsyrup"=5)
		food_effects = list("food_all", "food_energized")

	corn/sweet/honey
		name = "piece of honey cornbread"
		initial_volume = 20
		initial_reagents = list("bread"=5,"cornsyrup"=5,"honey"=10)
		meal_time_flags = MEAL_TIME_DINNER

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/reagent_containers/food/snacks/breadslice/toastslice
	name = "slice of toast"
	desc = "Crispy cooked bread."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "toast"
	bites_left = 2
	heal_amt = 1
	food_color = "#CC9966"
	real_name = "toast"
	food_effects = list("food_warm", "food_hp_up")
	meal_time_flags = MEAL_TIME_BREAKFAST

	banana
		name = "slice of banana toast"
		desc = "A less conventional form of crispy bread."
		icon_state = "bananatoast"
		heal_amt = 4
		food_effects = list("food_warm", "food_energized")

	brain
		name = "slice of brain toast"
		desc = "Historians believe that brain toast originated due to a garbled request for crispy bread made from wheat bran."
		icon_state = "braintoast"
		heal_amt = 3
		real_name = "brain toast"
		food_effects = list("food_warm", "food_hp_up_big")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	elvis
		name = "slice of elvis toast"
		desc = "Just when you thought Elvis couldn't get any hotter."
		icon_state = "elvistoast"
		heal_amt = 5
		real_name = "elvis toast"
		initial_volume = 30
		initial_reagents = list("bread"=5,"essenseofelvis"=25)
		food_effects = list("food_warm", "food_energized")
		meal_time_flags = MEAL_TIME_BREAKFAST | MEAL_TIME_SNACK

	spooky
		name = "slice of terror toast"
		desc = "It's scarier than regular toast.  That doesn't really say much unless you are going low-carb though."
		icon_state = "terrortoast"
		heal_amt = 2
		real_name = "terror toast"
		food_effects = list("food_warm", "food_all")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/reagent_containers/food/snacks/toastcheese
	name = "cheese on toast"
	desc = "A quick cheesy snack."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "cheesetoast"
	bites_left = 2
	heal_amt = 2
	food_color = "#CC9966"
	real_name = "toast cheese"
	initial_volume = 10
	initial_reagents = list("bread"=5,"cheese"=5)
	food_effects = list("food_warm", "food_burn", "food_hp_up")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_SNACK

	elvis
		name = "cheese on elvis toast"
		desc = "The king of cheesy toast."
		icon_state = "cheesyelvis"
		bites_left = 3
		heal_amt = 6
		real_name = "elvis cheese toast"
		initial_volume = 35
		initial_reagents = list("bread"=5,"cheese"=5,"essenseofelvis"=25)

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/reagent_containers/food/snacks/toastbacon
	name = "bacon on toast"
	desc = "Is this a real snack anywhere? Honestly?"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "bacontoast"
	bites_left = 2
	heal_amt = 3
	food_color = "#CC9966"
	real_name = "bacon toast"
	initial_volume = 10
	initial_reagents = list("bread"=5,"porktonium"=5)
	food_effects = list("food_warm", "food_burn", "food_hp_up")
	meal_time_flags = MEAL_TIME_BREAKFAST | MEAL_TIME_SNACK

	elvis
		name = "bacon on elvis toast"
		desc = "Oh, come on. That just does not look healthy."
		icon_state = "baconelvis"
		bites_left = 3
		heal_amt = 4
		real_name ="bacon elvis toast"
		initial_volume = 35
		initial_reagents = list("bread"=5,"porktonium"=5,"essenseofelvis"=25)

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/reagent_containers/food/snacks/toastegg
	name = "eggs on toast"
	desc = "Crunchy, eggy goodness."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "eggtoast"
	bites_left = 2
	heal_amt = 3
	food_color = "#CC9966"
	real_name = "eggs on toast"
	initial_volume = 30
	food_effects = list("food_hp_up","food_deep_burp")
	meal_time_flags = MEAL_TIME_BREAKFAST | MEAL_TIME_SNACK

	elvis
		name = "eggs on elvis toast"
		desc = "More than enough calories to make you leave the metaphorical building."
		icon_state = "eggelvis"
		bites_left = 3
		heal_amt = 6
		real_name ="eggs on elvis toast"
		meal_time_flags = MEAL_TIME_SNACK

		New()
			..()
			reagents.add_reagent("essenceofelvis",25)

	New()
		..()
		src.pixel_x += rand(-3,3)
		src.pixel_y += rand(-3,3)

/obj/item/baguette
	name = "baguette"
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "baguette"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	throwforce = 1
	w_class = W_CLASS_NORMAL
	throw_speed = 4
	throw_range = 5
	desc = "Hon hon hon, oui oui! Needs to be cut into slices before eating."
	stamina_damage = 5
	stamina_cost = 1
	var/slicetype = /obj/item/reagent_containers/food/snacks/breadslice

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/axe) || istype(W, /obj/item/circular_saw) || istype(W, /obj/item/kitchen/utensil/knife) || istype(W, /obj/item/scalpel) || istype(W, /obj/item/sword) || istype(W,/obj/item/knife/butcher))
			if(user.bioHolder.HasEffect("clumsy") && prob(50))
				user.visible_message("<span class='alert'><b>[user]</b> fumbles and jabs [himself_or_herself(user)] in the eye with [W].</span>")
				user.change_eye_blurry(5)
				user.changeStatus("weakened", 3 SECONDS)
				JOB_XP(user, "Clown", 2)
				return

			var/turf/T = get_turf(src)
			user.visible_message("[user] cuts [src] into slices. Magnifique!", "You cut [src] into slices. Magnifique!")
			var/makeslices = 6
			while (makeslices > 0)
				new slicetype (T)
				makeslices -= 1
			qdel (src)
		else ..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] attempts to beat [him_or_her(user)]self to death with the baguette, oui oui, but fails! Hon hon hon!</b></span>")
		user.suiciding = 0
		return 1

/obj/item/reagent_containers/food/snacks/garlicbread
	name = "garlic bread"
	desc = "Garlic, butter and bread. Usually seen alongside pasta and pizza."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "garlicbread"
	bites_left = 2
	heal_amt = 4
	food_color = "#ffe87a"
	initial_volume = 20
	initial_reagents = list("water_holy"=20)
	food_effects = list("food_tox","food_hp_up_big","food_bad_breath")
	meal_time_flags = MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/garlicbread_ch
	name = "cheesy garlic bread"
	desc = "Garlic, butter, bread AND cheese. Usually seen alongside pasta and pizza."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "garlicbread_ch"
	bites_left = 2
	heal_amt = 4
	food_color = "#ffe87a"
	initial_volume = 20
	initial_reagents = list("water_holy"=10,"cheese"=10)
	food_effects = list("food_tox","food_hp_up_big","food_bad_breath","food_energized")
	meal_time_flags = MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/fairybread
	name = "fairy bread"
	desc = "A traditional delicacy of Australian origin."
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	icon_state = "fairybread"
	bites_left = 2
	heal_amt = 2
	food_color = "#ffcdfb"
	initial_volume = 10
	initial_reagents = list("bread"=5,"sugar"=5)
	food_effects = list("food_refreshed_big")
	meal_time_flags = MEAL_TIME_SNACK
