ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/candy)
/obj/item/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Man, that shit looks good. I bet it's got nougat. Fuck."
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "candy"
	heal_amt = 1
	real_name = "candy"
	var/sugar_content = 50
	var/razor_blade = 0 //Is this BOOBYTRAPPED CANDY?
	festivity = 1

	New()
		..()
		reagents.add_reagent("sugar", sugar_content)
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/razor_blade))
			boutput(user, "You add the razor blade to [src]")
			qdel(W)
			src.razor_blade = 1
			return

		else
			..()
		return

	heal(var/mob/M)
		if(src.razor_blade && ishuman(M))
			var/mob/living/carbon/human/H = M
			boutput(H, "<span class='alert'>You bite down into a razor blade!</span>")
			H.TakeDamage("head", 10, 0, 0, DAMAGE_STAB)
			H.changeStatus("weakened", 3 SECONDS)
			H.UpdateDamageIcon()
			src.razor_blade = 0
			new /obj/item/razor_blade( get_turf(src) )
		..()

/obj/item/reagent_containers/food/snacks/candy/nougat
	name = "nougat bar"
	desc = "Whoa, that totally has nougat. Heck yes."
	real_name = "nougat"
	icon_state = "nougat0"

	heal(var/mob/M)
		..()
		if (icon_state == "nougat0")
			icon_state = "nougat1"

/obj/item/reagent_containers/food/snacks/candy/caramel
	name = "'Hole Zone Layer' caramel creme"
	desc = "You know that missing O-Zone from earth? We made it in a candy!"
	real_name = "caramel"
	icon_state = "caramel"
	food_effects = list("food_energized")

/obj/item/reagent_containers/food/snacks/candy/candy_cane
	name = "candy cane"
	desc = "Holiday treat and aid to limping gingerbread men everywhere."
	real_name = "candy cane"
	icon = 'icons/misc/xmas.dmi'
	icon_state = "candycane"
	item_state = "candycane_h"
	sugar_content = 20
	food_effects = list("food_energized")

//Special HALLOWEEN snacks
//Apple + stick creation

//Candied apples!
/obj/item/reagent_containers/food/snacks/candy/candy_apple
	name = "candy apple"
	desc = "An apple covered in a hard sugar coating."
	icon_state = "candy-apple"
	heal_amt = 2
	food_effects = list("food_energized")

	poison
		name = "delicious candy apple"
		desc = "A delicious apple covered in a hard sugar coating."
		icon_state = "candy-poison"


		New()
			..()
			reagents.add_reagent("capulettium", 10)
			return

//Candy corn!!
/obj/item/reagent_containers/food/snacks/candy/candy_corn
	name = "candy-corn"
	desc = "A confection resembling a kernel of corn. A Halloween classic."
	icon_state = "candy-corn"
	real_name = "candy corn"
	bites_left = 1
	sugar_content = 25
	food_color = "#FFCC00"
	initial_reagents = list("badgrease"=5)
	food_effects = list("food_sweaty")

	heal(var/mob/M)
		..()
		boutput(M, "It tastes disappointing.")
		return

//Candy bar variants
/obj/item/reagent_containers/food/snacks/candy/negativeonebar
	name = "-1 Bar"
	desc = "A candy bar containing '-1 calories.'"
	bites_left = 1
	heal_amt = -1
	icon_state = "candy-blue"
	sugar_content = 10
	food_effects = list("food_sweaty")

/obj/item/reagent_containers/food/snacks/candy/chocolate
	name = "chocolate bar"
	desc = "A plain chocolate bar. Is it dark chocolate, milk chocolate? Who knows!"
	sugar_content = 10
	real_name = "chocolate"
	icon_state = "candy-chocolate"
	food_color = "#663300"
	initial_reagents = list("chocolate"=10)

/obj/item/reagent_containers/food/snacks/candy/wrapped_pbcup
	name = "pack of Hetz's Cups"
	desc = "A package of the popular Hetz's Cups chocolate peanut butter cups."
	icon_state = "candy-pbcup_w"
	sugar_content = 20
	heal_amt = 5
	food_color = "#663300"
	real_name = "Hetz's Cup"
	var/unwrapped = 0

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to unwrap them first, you greedy beast!</span>")
			user.visible_message("<b>[user]</b> stares at [src] in a confused manner.")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove [src] into [M]'s mouth!</span>")
			return

	attack_self(mob/user as mob)
		if (unwrapped)
			return

		unwrapped = 1
		user.visible_message("[user] unwraps the Hetz's Cups!", "You unwrap the Hetz's Cups.")
		var/turf/T = get_turf(user)
		new /obj/item/reagent_containers/food/snacks/candy/pbcup(T)
		new /obj/item/reagent_containers/food/snacks/candy/pbcup(T)
		new /obj/item/reagent_containers/food/snacks/candy/pbcup(T)
		qdel(src)

/obj/item/reagent_containers/food/snacks/candy/pbcup
	name = "Hetz's Cup"
	desc = "A cup-shaped chocolate candy with a peanut butter filling. Of course, peanuts went extinct back in 2026, so it's really some weird soy paste that supposedly tastes like them."
	icon_state = "candy-pbcup"
	sugar_content = 20
	heal_amt = 5
	bites_left = 2
	food_color = "#663300"
	real_name = "Hetz's Cup"
	initial_reagents = list("chocolate" = 10)

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/candy/jellybean)
/obj/item/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	desc = "YOU SHOULDN'T SEE THIS OBJECT"
	icon_state = "bean"
	bites_left = 1
	initial_volume = 100
	sugar_content = 0 // hacky, I know. but it's necessary for the color!
	var/flavor
	var/phrase
	var/tastesbad = 0

/obj/item/reagent_containers/food/snacks/candy/jellybean/someflavor
	name = "\improper Mabie Nott's Some Flavor Bean"
	desc = "Fresh organic jellybeans packed with...something."

	New()
		..()
		SPAWN(0)
			if (src.reagents)
				if (prob(33))
					src.reagents.add_reagent(pick("milk", "coffee", "VHFCS", "gravy", "fakecheese", "grease", "ethanol", "chickensoup", "vanilla", "cornsyrup", "chocolate"), 10)
					src.heal_amt = 1
				else if (prob(33))
					src.reagents.add_reagent(pick("bilk", "beff", "vomit", "gvomit", "porktonium", "badgrease", "yuck", "carbon", "salt", "pepper", "ketchup", "mustard"), 10)
					src.heal_amt = 0

				src.food_color = src.reagents.get_master_color()
				src.icon += src.food_color

				src.reagents.add_reagent("sugar", 50)
				if (src.reagents.total_volume <= 60)
					src.reagents.add_reagent("sugar", 40)

			// set up flavors
			if(prob(50))
				flavor = pick("cardboard", "human souls", "something unspeakable", "egg", "vomit", "snot", "poo", "urine", "earwax", "wet dog", "belly-button lint", "sweat", "congealed farts", "mold", "armpits", "elbow grease", "sour milk", "WD-40", "slime", "blob", "gym sock", "pants", "brussels sprouts", "feet", "litter box", "durian fruit", "asbestos", "corpse flower", "corpse", "cow dung", "rot", "tar", "ham")
				phrase = pick("Oh god", "Jeez", "Ugh", "Blecch", "Holy crap that's awful", "What the hell?", "*HURP*", "Phoo")
				tastesbad = 1
			else
				flavor = pick("egg", "strawberry", "raspberry", "snozzberry", "happiness", "popcorn", "buttered popcorn", "cinnamon", "macaroni and cheese", "pepperoni", "cheese", "lasagna", "pina colada", "tutti frutti", "lemon", "margarita", "coconut", "pineapple", "scotch", "vodka", "root beer", "cotton candy", "Lagavulin 18", "toffee", "vanilla", "coffee", "apple pie", "neapolitan", "orange", "lime", "crotch", "mango", "apple", "grape", "Slurm")
				phrase = pick("Yum", "Wow", "MMM", "Delicious", "Scrumptious", "Fantastic", "Oh yeah")
				tastesbad = 0

	heal(var/mob/M)
		..()
		if (tastesbad)
			boutput(M, "<span class='alert'>[phrase]! That tasted like [flavor]...</span>")
		else
			boutput(M, "<span class='notice'>[phrase]! That tasted like [flavor]...</span>")

//#ifdef HALLOWEEN
/obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor
	name = "\improper Farty Snott's Every Flavour Bean"
	desc = "A favorite halloween sweet worldwide!"

	New()
		..()
		SPAWN(0)
			if (src.reagents)
				if (prob(12))
					src.reagents.add_reagent(pick("milk", "coffee", "VHFCS", "gravy", "fakecheese", "grease"), 10)
					src.heal_amt = 1
				else if (prob(12))
					src.reagents.add_reagent(pick("bilk", "beff", "vomit", "gvomit", "porktonium", "badgrease"), 10)
					src.heal_amt = 0
				else
					var/flavor = null
					if (all_functional_reagent_ids.len > 0)
						flavor = pick(all_functional_reagent_ids)
					else
						flavor = "sugar"
					src.reagents.add_reagent(flavor, 50)

				src.food_color = src.reagents.get_master_color()
				src.icon += src.food_color // apparently this is a thing you can do?  neat!

				src.reagents.add_reagent("sugar", 50)
				if (src.reagents.total_volume <= 60)
					src.reagents.add_reagent("sugar", 40)

				if(prob(50))
					flavor = pick("egg", "vomit", "snot", "poo", "urine", "earwax", "wet dog", "belly-button lint", "sweat", "congealed farts", "mold", "armpits", "elbow grease", "sour milk", "WD-40", "slime", "blob", "gym sock", "pants", "brussels sprouts", "feet", "litter box", "durian fruit", "asbestos", "corpse flower", "corpse", "cow dung", "rot", "tar", "ham", "gooncode", "quark-gluon plasma", "bee", "heat death")
					phrase = pick("Oh god", "Jeez", "Ugh", "Blecch", "Holy crap that's awful", "What the hell?", "*HURP*", "Phoo")
					tastesbad = 1
				else
					flavor = pick("egg", "strawberry", "raspberry", "snozzberry", "happiness", "popcorn", "buttered popcorn", "cinnamon", "macaroni and cheese", "pepperoni", "cheese", "lasagna", "pina colada", "tutti frutti", "lemon", "margarita", "coconut", "pineapple", "scotch", "vodka", "root beer", "cotton candy", "Lagavulin 18", "toffee", "vanilla", "coffee", "apple pie", "neapolitan", "orange", "lime", "crotch", "mango", "apple", "grape", "Slurm", "Popecrunch")
					phrase = pick("Yum", "Wow", "MMM", "Delicious", "Scrumptious", "Fantastic", "Oh yeah")

/obj/item/kitchen/everyflavor_box
	var/beans_left = 6
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "beans"
	name = "bag of Farty Snott's Every Flavour Beans"

/obj/item/kitchen/everyflavor_box/attack_hand(mob/user, unused, flag)
	if (flag)
		return ..()
	if (user.r_hand == src || user.l_hand == src)
		if(src.beans_left == 0)
			boutput(user, "<span class='alert'>You're out of beans. You feel strangely sad.</span>")
			return
		else
			var/obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor/B = new(user)
			user.put_in_hand_or_drop(B)
			src.beans_left--
			if(src.beans_left == 0)
				src.icon_state = "beans-empty"
				src.name = "empty Farty Snott's bag"
	else
		return ..()
	return

/obj/item/kitchen/everyflavor_box/examine()
	. = ..()
	var/n = round(src.beans_left)
	if (n <= 0)
		. += "There are no beans left in the bag."
	else
		if (n == 1)
			. += "There is one bean left in the bag."
		else
			. += "There are [n] beans in the bag."

//#endif

/obj/item/reagent_containers/food/snacks/lollipop
	name = "lollipop"
	desc = "How many licks does it take to get to the center? No one knows, they just bite the things."
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "lpop-0"
	var/icon_random = 0 // does it just choose from the existing random colors?
	var/image/image_candy
	heal_amt = 1
	bites_left = 5
	real_name = "lollipop"

	New()
		..()
		if (src.icon_random)
			src.icon_state = "lpop-[rand(1,6)]"
		else
			SPAWN(0)
				src.UpdateIcon()

	update_icon()
		if (src.icon_random)
			return
		if (src.reagents)
			ENSURE_IMAGE(src.image_candy, src.icon, "lpop-w")
			var/datum/color/average = reagents.get_average_color()
			src.image_candy.color = average.to_rgba()
			src.UpdateOverlays(src.image_candy, "candy")

/obj/item/reagent_containers/food/snacks/lollipop/random_medical
	icon_state = "lpop-"
	var/list/flavors = list("omnizine", "saline", "salicylic_acid", "epinephrine", "mannitol", "synaptizine", "anti_rad", "oculine", "salbutamol", "charcoal")

	New()
		..()
		SPAWN(0)
			if (src.icon_state == "lpop-")
				src.icon_state = "lpop-[rand(1,6)]"
			if (islist(src.flavors) && length(src.flavors))
				for (var/i=5, i>0, i--)
					src.reagents.add_reagent(pick(src.flavors), 1)

/obj/item/reagent_containers/food/snacks/swedish_fish
	name = "swedish fisk"
	desc = "A chewy gummy bright red fish. Those crazy Swedes and their fish obesssion."
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "swedishfiskfisk"
	bites_left = 1
	heal_amt = 1
	food_color = "#e50000"
	initial_volume = 10

	New()
		if (prob(33))
			src.initial_reagents = "swedium"
		..()
		src.pixel_x = rand(-6, 6)
		src.pixel_y = rand(-6, 6)

/obj/item/item_box/swedish_bag
	name = "bag of swedish fisk"
	desc = "A curious bag of fresh swedish fisk, fresh from the factories in Sweden."
	contained_item = /obj/item/reagent_containers/food/snacks/swedish_fish
	icon_state = "swedishfisk"
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	item_amount = 8
	max_item_amount = 8
	icon_closed = "swedishfisk"
	icon_closed_empty = "swedishfisk-closedempty"
	icon_open = "swedishfisk-open"
	icon_empty = "swedishfisk-empty"

/obj/item/kitchen/peach_rings
	var/mbc_left = 6
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "rings-full"
	name = "bag of peach rings"
	desc = "A bag of gummy peach rings. A Delectable Dan's favorite."

	attack_hand(mob/user, unused, flag)
		if (flag)
			return ..()
		if (user.r_hand == src || user.l_hand == src)
			if(src.mbc_left == 0)
				boutput(user, "<span class='alert'>You're out of peach rings. You feel strangely sad.</span>")
				return
			else
				var/obj/item/reagent_containers/food/snacks/candy/peach_ring/B = new(user)
				user.put_in_hand_or_drop(B)
				src.mbc_left--
				if(src.mbc_left == 0)
					src.icon_state = "rings-empty"
					src.name = "empty peach ring bag"
					src.desc = "A crumpled bag that was once full of gummy peach rings."
		else
			return ..()
		return

/obj/item/reagent_containers/food/snacks/candy/peach_ring
	name = "peach ring"
	desc = "A gummy peach ring dusted with sugar."
	icon_state = "peachring"
	bites_left = 1
	sugar_content = 5

	New()
		..()
		reagents.add_reagent("juice_peach",5)

/obj/item/kitchen/gummy_worms_bag
	var/worms_left = 6
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "gummyw-full"
	name = "bag of gummy worms"
	desc = "A bag of sour gummy worms. Still a little wriggly."

	attack_hand(mob/user, unused, flag)
		if (flag)
			return ..()
		if (user.r_hand == src || user.l_hand == src)
			if(src.worms_left == 0)
				boutput(user, "<span class='alert'>You're out of gummy worms. The world is a little bleaker.</span>")
				return
			else
				var/obj/item/reagent_containers/food/snacks/candy/gummy_worm/B = new(user)
				user.put_in_hand_or_drop(B)
				src.worms_left--
				if(src.worms_left == 0)
					src.icon_state = "gummyw-empty"
					src.name = "empty gummy worms bag"
					src.desc = "A crumpled bag that was once full of sour gummy worms."
		else
			return ..()
		return

/obj/item/reagent_containers/food/snacks/candy/gummy_worm
	name = "gummy worm"
	desc = "A sour gummy worm sprinkled in sugar. Comes in several flavours."
	icon_state = "gummyworm-1"
	bites_left = 1
	sugar_content = 5

	New()
		..()
		src.icon_state = "gummyworm-[rand(1,3)]"
		src.reagents.add_reagent(pick("juice_cherry", "juice_orange", "lemonade", "juice_strawberry", "juice_blueberry", "juice_apple", "juice_blueraspberry", "juice_watermelon", "juice_peach", "cocktail_citrus"), 5)
		src.heal_amt = 1

/obj/item/reagent_containers/food/snacks/candy/candyheart
	name = "candy heart"
	desc = "Can you find the perfect phrase for that special someone?"
	icon_state = "heart"
	bites_left = 1
	sugar_content = 5
	var/phrase
	var/list/heart_phrases = list("Be Mine", "XOXO", "Kiss Me", "Love", "U Rock", "I <3 U", "i wuv u", "U Leave Me Breathless", "UR my man", "Cutie Pie", "U-R-2 Cute",
	 "Love Bug", "Hot Lips", "UR A STAR", "ME & U", "UR A QT", "Thank U", "Soul Mate", "Sol Mate", "Awesome", "Bee Mine", "Sweet as Honey", "True Love", "Ooh La La", "I GIB U WUV",
	 "Change to Love Intent", "Robust Me", "Don't Robust my <3", "Love Transfer Valve", "You're Stunning", "Absorb my Heart", "Owl luv u forever", "We have Chemistry",
	 "Law 4: Rearrange the alphabet and put U and AI together", "HALP THE CUTIE IS GRIFFIN MEH", "CUTECURITY!!!", "I honk u", "All access to my <3", "Greytide my heart", "Wear my butt as a hat",
	 "Maecho love", "Love birds", "Bee still my heart", "Get in my clown car", "Meet me in maintenance", "Let's fly into the sun", "Deep fried love")

	New()
		..()
		src.icon_state = "heart-[rand(1,5)]"
		phrase = pick(src.heart_phrases)
		return

	get_desc()
		. = "<br><span class='notice'>It says: [phrase]</span>"

/obj/item/reagent_containers/food/snacks/candy/taffy
	name = "saltwater taffy"
	desc = "Produced in small artisanal batches, straight from someone's kitchen. "
	icon_state = "red"
	amount = 1
	sugar_content = 10
	var/unwrapped = 0
	var/flavor
	var/list/flavors

	New()
		..()
		desc += flavor
		var/datum/reagents/R = reagents
		for (var/F in flavors)
			R.add_reagent(F, 10)

	attack(mob/M, mob/user, def_zone)
		if (user == M)
			boutput(user, "<span class='alert'>You need to unwrap this first!</span>")
			user.visible_message("<span class='emote'><b>[user]</b> stares at [src] in a confused manner.</span>")
			return
		else
			user.visible_message("<span class='alert'><b>[user]</b> futilely attempts to shove the unwrapped taffy into [M]'s mouth!</span>")
			return

	attack_self(mob/user as mob)
		if (unwrapped)
			return ..()

		unwrapped = 1
		user.visible_message("<span class='emote'>[user] unwraps [src].</span>", "You unwrap [src].")
		icon_state = icon_state + "-unwrapped"

/obj/item/reagent_containers/food/snacks/candy/taffy/cherry
	flavor = "This one is cherry flavored."
	flavors = list("juice_cherry", "psilocybin")

/obj/item/reagent_containers/food/snacks/candy/taffy/watermelon
	icon_state = "pink"
	flavor = "This one is watermelon flavored."
	flavors = list("juice_watermelon", "love")

/obj/item/reagent_containers/food/snacks/candy/taffy/blueraspberry
	icon_state = "blue"
	flavor = "This one is blue raspberry flavored."
	flavors = list("juice_raspberry", "LSD")
