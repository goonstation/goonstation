ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/candy)
/obj/item/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Man, that shit looks good. I bet it's got nougat. Fuck."
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "candy"
	heal_amt = 1
	fill_amt = 0.3 //You can eat a lot of candy
	real_name = "candy"
	var/sugar_content = 50
	var/has_razor_blade = FALSE //!Is this BOOBYTRAPPED CANDY?
	festivity = 1

	New()
		..()
		reagents.add_reagent("sugar", sugar_content)
		return

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/razor_blade))
			if (src.has_razor_blade)
				boutput(user, "There's already a razor blade in [src]!")
				return
			boutput(user, "You add the razor blade to [src].")
			qdel(W)
			src.has_razor_blade = TRUE
			return

		else
			..()
		return

	heal(var/mob/M)
		if(src.has_razor_blade && ishuman(M))
			var/mob/living/carbon/human/H = M
			boutput(H, SPAN_ALERT("You bite down into a razor blade!"))
			H.TakeDamage("head", 10, 0, 0, DAMAGE_STAB)
			H.changeStatus("knockdown", 3 SECONDS)
			H.UpdateDamageIcon()
			src.has_razor_blade = FALSE
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
	initial_volume = 110
	sugar_content = 10
	var/good_flavours = list("egg", "strawberry", "raspberry", "snozzberry", "happiness", "popcorn", "buttered popcorn", "cinnamon",
						"macaroni and cheese", "pepperoni", "cheese", "lasagna", "pina colada", "tutti frutti", "lemon", "margarita",
						"coconut", "pineapple", "scotch", "vodka", "root beer", "cotton candy", "Lagavulin 18", "toffee", "vanilla",
						"coffee", "apple pie", "neapolitan", "orange", "lime", "mango", "apple", "grape", "Slurm", "slime mold")
	var/bad_flavours = list("cardboard", "human souls", "something unspeakable", "egg", "vomit", "snot", "poo", "earwax", "wet dog",
						"belly-button lint", "sweat", "congealed farts", "mold", "armpits", "elbow grease", "sour milk", "WD-40",
						"slime", "blob", "gym sock", "pants", "brussels sprouts", "feet", "litter box", "durian fruit", "asbestos",
						"corpse flower", "corpse", "cow dung", "rot", "tar", "ham", "bee", "quark-gluon plasma", "heat death", "gooncode")
	var/good_phrases = list ("Yum", "Wow", "MMM", "Delicious", "Scrumptious", "Fantastic", "Oh yeah")
	var/bad_phrases = list("Oh god", "Jeez", "Ugh", "Blecch", "Holy crap that's awful", "What the hell?", "*HURP*", "Phoo")
	//pool 1 is slightly more likely to occur than pool 2
	var/reagent_pool1 = list("milk", "coffee", "VHFCS", "gravy", "fakecheese", "grease", "ethanol", "chickensoup", "vanilla", "cornsyrup", "chocolate")
	var/reagent_pool2 = list("bilk", "beff", "vomit", "gvomit", "porktonium", "badgrease", "yuck", "carbon", "salt", "pepper", "ketchup", "mustard")

	heal(mob/M)
		..()
		if (prob(50))
			boutput(M, SPAN_ALERT("[pick(bad_phrases)]! That tasted like [pick(bad_flavours)]..."))
		else
			boutput(M, SPAN_NOTICE("[pick(good_phrases)]! That tasted like [pick(good_flavours)]..."))

/obj/item/reagent_containers/food/snacks/candy/jellybean/someflavor
	name = "\improper Mabie Nott's Some Flavor Bean"
	desc = "Fresh organic jellybeans packed with...something."

	New()
		..()
		SPAWN(0)
			if (!src.reagents) return
			var/reagent = null
			if (prob(33))
				reagent = pick(reagent_pool1)
				src.heal_amt = 1
			else if (prob(33))
				reagent = pick(reagent_pool2)
				src.heal_amt = 0

			var/datum/reagent/current = reagents_cache[reagent]
			if (current)
				// make space for the flavouring if there is none
				if(src.reagents.maximum_volume - src.reagents.total_volume < 10)
					src.reagents.maximum_volume += 10
				src.reagents.add_reagent(reagent, 10)
				src.icon += rgb(current.fluid_r, current.fluid_g, current.fluid_b, max(current.transparency,255))
			else // no flavouring? Pick a random colour!
				src.icon += random_saturated_hex_color()



//#ifdef HALLOWEEN
/obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor
	name = "\improper Farty Snott's Every Flavour Bean"
	desc = "A favorite halloween sweet worldwide!"
	// sugar content is less than the flavouring content, so that wizard golems are guaranteed to be named after the flavouring
	sugar_content = 40
	New()
		..()
		SPAWN(0)
			if (!src.reagents) return
			var/reagent = null
			if (prob(12))
				reagent = pick(reagent_pool1)
				src.heal_amt = 1
			else if (prob(12))
				reagent = pick(reagent_pool2)
				src.heal_amt = 0
			else
				if (length(all_functional_reagent_ids) > 0)
					reagent = pick(all_functional_reagent_ids)
				else
					reagent = "sugar"

			var/datum/reagent/current = reagents_cache[reagent]
			if (current)
				// make space for the flavouring if there is none
				if(src.reagents.maximum_volume - src.reagents.total_volume < 50)
					src.reagents.maximum_volume += 50
				src.reagents.add_reagent(reagent, 50)
				src.icon += rgb(current.fluid_r, current.fluid_g, current.fluid_b, max(current.transparency,255)) // apparently this is a thing you can do?  neat!


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
			boutput(user, SPAN_ALERT("You're out of beans. You feel strangely sad."))
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

/obj/item/reagent_containers/food/snacks/candy/lollipop
	name = "lollipop"
	desc = "How many licks does it take to get to the center? No one knows, they just bite the things."
	icon = 'icons/obj/foodNdrink/food_candy.dmi'
	icon_state = "lpop-0"
	sugar_content = 5
	var/icon_random = FALSE //! does it just choose from the existing random colors?
	var/image/image_candy
	heal_amt = 1
	bites_left = 5
	real_name = "lollipop"

/obj/item/reagent_containers/food/snacks/candy/lollipop/New()
	..()
	if (src.icon_random)
		src.icon_state = "lpop-[rand(1,6)]"

/obj/item/reagent_containers/food/snacks/candy/lollipop/update_icon()
	if (src.icon_random)
		return
	if (src.reagents)
		ENSURE_IMAGE(src.image_candy, src.icon, "lpop-w")
		var/datum/color/average = src.reagents.get_average_color(reagent_exception_ids=list("sugar"))
		if (src.reagents.has_reagent("sugar") && src.reagents.reagent_list.len == 1)
			average = new(255,255,255,255)
		src.image_candy.color = average.to_rgba()
		src.UpdateOverlays(src.image_candy, "candy")

/obj/item/reagent_containers/food/snacks/candy/lollipop/random_medical
	icon_random = TRUE
	name = "medical lollipop"
	real_name = "medical lollipop"
	desc = "It's good for you! Probably. It's actually mostly sugar."
	var/list/flavors = list("omnizine", "saline", "salicylic_acid", "epinephrine", "mannitol", "synaptizine", "anti_rad", "oculine", "salbutamol", "charcoal")

/obj/item/reagent_containers/food/snacks/candy/lollipop/random_medical/New()
	..()
	if (islist(src.flavors) && length(src.flavors))
		for (var/i=5, i>0, i--)
			src.reagents.add_reagent(pick(src.flavors), 1)
	src.UpdateIcon()

/obj/item/reagent_containers/food/snacks/candy/sugar_cube
	name = "sugar cube"
	desc = "Cubed sugar."
	icon_state = "sugar-cube"
	sugar_content = 10
	bites_left = 1
	food_color = "#FFFFFF"
	w_class = W_CLASS_TINY

	afterattack(obj/target, mob/user, flag)
		..()
		if (target.is_open_container(TRUE) && target.reagents)
			if (target.reagents.total_volume >= target.reagents.maximum_volume)
				boutput(user, SPAN_ALERT("[target] is full."))
				return

			boutput(user, SPAN_NOTICE("You put [src] into [target]."))

			src.reagents.trans_to(target, src.reagents.total_volume)
			user.u_equip(src)
			qdel(src)

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
				boutput(user, SPAN_ALERT("You're out of peach rings. You feel strangely sad."))
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
				boutput(user, SPAN_ALERT("You're out of gummy worms. The world is a little bleaker."))
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
		src.reagents.add_reagent(pick("juice_cherry", "juice_orange", "lemonade", "juice_strawberry", "juice_blueberry", "juice_apple", "juice_banana", "juice_blueraspberry", "juice_watermelon", "juice_peach", "cocktail_citrus"), 5)
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
		. = "<br>[SPAN_NOTICE("It says: [phrase]")]"

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/candy/wrapped_candy)
/obj/item/reagent_containers/food/snacks/candy/wrapped_candy
	name = "wrapped candy"
	desc = "A piece of wrapped candy."
	bites_left = 1
	sugar_content = 5
	food_effects = list("food_energized")
	initial_volume = 5
	initial_reagents = list("sugar"=5)
	var/unwrapped = 0

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (unwrapped)
			..()
			return
		if (user == target)
			boutput(user, SPAN_ALERT("You need to unwrap this first!"))
			user.visible_message(SPAN_EMOTE("<b>[user]</b> stares at [src] in a confused manner."))
			return
		else
			user.visible_message(SPAN_ALERT("<b>[user]</b> futilely attempts to shove the [src] into [target]'s mouth!"))
			return

	attack_self(mob/user as mob)
		if (!unwrapped)
			unwrap_candy(user)
		else
			..()

	proc/unwrap_candy(mob/user)
		unwrapped = 1
		user.visible_message(SPAN_EMOTE("[user] unwraps [src]."), "You unwrap [src].")
		icon_state = icon_state + "-unwrapped"

ABSTRACT_TYPE(/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/taffy)
/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/taffy
	name = "saltwater taffy"
	desc = "Produced in small artisanal batches, straight from someone's kitchen. "
	icon_state = "red"
	sugar_content = 10
	var/flavor
	var/list/flavors

	New()
		..()
		desc += flavor
		var/datum/reagents/R = reagents
		for (var/F in flavors)
			R.add_reagent(F, 10)

/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/taffy/cherry
	name = "red saltwater taffy"
	flavor = "This one is cherry flavored."
	flavors = list("juice_cherry", "psilocybin")

/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/taffy/watermelon
	name = "pink saltwater taffy"
	icon_state = "pink"
	flavor = "This one is watermelon flavored."
	flavors = list("juice_watermelon", "love")

/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/taffy/blueraspberry
	name = "blue saltwater taffy"
	icon_state = "blue"
	flavor = "This one is blue raspberry flavored."
	flavors = list("juice_raspberry", "LSD")

/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/pb_cup
	name = "pack of Hetz's Cups"
	desc = "A package of the popular Hetz's Cups chocolate peanut butter cups."
	icon_state = "candy-pbcup_w"
	sugar_content = 20
	heal_amt = 5
	food_color = "#663300"
	real_name = "Hetz's Cup"

	unwrap_candy(mob/user)
		unwrapped = 1
		user.visible_message(SPAN_EMOTE("[user] unwraps the Hetz's Cups."), "You unwrap the Hetz's Cups.")
		var/turf/T = get_turf(user)
		new /obj/item/reagent_containers/food/snacks/candy/pbcup(T)
		new /obj/item/reagent_containers/food/snacks/candy/pbcup(T)
		new /obj/item/reagent_containers/food/snacks/candy/pbcup(T)
		qdel(src)

/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/caramel
	name = "'Hole Zone Layer' caramel creme"
	desc = "You know that missing O-Zone from earth? We made it in a candy!"
	real_name = "caramel"
	icon_state = "caramel"

/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/butterscotch
	name = "butterscotch candy"
	desc = "It's one of those old timey butterscotch candies like your grampa used to have."
	real_name = "butterscotch"
	icon_state = "butterscotch"

/obj/item/reagent_containers/food/snacks/candy/hard_candy
	name = "hard candy"
	desc = "A piece of hard candy."
	real_name = "hard candy"
	icon_state = "hardcandy-nowrap"
	bites_left = 1
	food_effects = list("food_energized")
	initial_volume = 5
	sugar_content = 5
	var/image/image_candy = null
	var/flavor_name

	on_reagent_change()
		..()
		src.update_icon()
		src.update_name()

	proc/update_name()
		src.flavor_name = src.reagents.get_master_reagent_name()
		if (src.flavor_name == "sugar")
			src.flavor_name = null
		src.name = "[name_prefix(null, 1)][src.flavor_name ? "[src.flavor_name]-flavored " : null][src.real_name][name_suffix(null, 1)]"

	update_icon()
		var/datum/color/average = src.reagents.get_average_color()
		src.food_color = average.to_rgb()
		src.color = src.food_color
		src.alpha = round(average.a / 1.2)

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/paper))
			user.visible_message("[user] wraps the [src] in the [W].", "You fold the [src] in the [W].")
			var/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/hard/A = new /obj/item/reagent_containers/food/snacks/candy/wrapped_candy/hard(get_turf(user))
			A.reagents.clear_reagents()
			src.reagents.trans_to(A, 5)
			user.u_equip(src)
			user.put_in_hand_or_drop(A)
			qdel(src)
			qdel(W)
		else if (istype(W,/obj/item/rods) || istype(W,/obj/item/stick))
			if(istype(W,/obj/item/stick))
				var/obj/item/stick/S = W
				if(S.broken)
					boutput(user, SPAN_ALERT("That stick is broken!"))
					return

			boutput(user, SPAN_NOTICE("You stick the hard candy onto [W]."))

			var/obj/item/reagent_containers/food/snacks/candy/lollipop/newcandy = new /obj/item/reagent_containers/food/snacks/candy/lollipop(get_turf(src))
			newcandy.reagents.clear_reagents()
			src.reagents.trans_to(newcandy, 5)
			newcandy.update_icon()
			user.u_equip(src)
			user.put_in_hand_or_drop(newcandy)

			if(istype(W,/obj/item/rods)) W.change_stack_amount(-1)
			if(istype(W,/obj/item/stick)) W.amount--
			if(!W.amount) qdel(W)

			qdel(src)
		else
			..()

/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/hard
	name = "wrapped hard candy"
	desc = "A piece of wrapped hard candy."
	real_name = "hard candy"
	icon_state = "hardcandy"
	var/flavor_name

	on_reagent_change()
		..()
		src.update_name()

	proc/update_name()
		src.flavor_name = src.reagents.get_master_reagent_name()
		if (src.flavor_name == "sugar")
			src.flavor_name = null
		src.name = "[name_prefix(null, 1)][src.unwrapped ? null : "wrapped "][src.flavor_name ? "[src.flavor_name]-flavored " : null][src.real_name][name_suffix(null, 1)]"

	unwrap_candy(mob/user)
		..()
		var/datum/color/average = src.reagents.get_average_color()
		var/image/image_candy = image(src.icon, "hardcandy-nowrap")
		image_candy.color = average.to_rgb()
		image_candy.alpha = round(average.a / 1.2)
		src.UpdateOverlays(image_candy, "hardcandy-nowrap")
		src.update_name()

/obj/item/reagent_containers/food/snacks/candy/rock_candy
	name = "rock candy"
	desc = "Rock candy on a stick. Hard as a rock, hopefully doesn't taste like one."
	real_name = "rock candy"
	icon_state = "rockcandy-0"
	initial_volume = 15
	sugar_content = 15
	bites_left = 2
	use_bite_mask = FALSE
	var/image/image_candy = null
	var/flavor_name

	on_reagent_change()
		..()
		src.update_icon()
		src.update_name()

	proc/update_name()
		src.flavor_name = src.reagents.get_master_reagent_name()
		if (src.flavor_name == "sugar")
			src.flavor_name = null
		src.name = "[name_prefix(null, 1)][src.flavor_name ? "[src.flavor_name]-flavored " : null][src.real_name][name_suffix(null, 1)]"

	update_icon()
		var/datum/color/average = src.reagents.get_average_color()
		if (!src.image_candy)
			src.image_candy = image(src.icon, "rockcandy-1")
		src.food_color = average.to_rgb()
		src.image_candy.color = src.food_color
		src.image_candy.alpha = round(average.a / 1.2)
		src.UpdateOverlays(src.image_candy, "rockcandy-1")

/obj/item/reagent_containers/food/snacks/candy/swirl_lollipop
	name = "swirly lollipop"
	desc = "A giant colorful lollipop in the shape of a swirl."
	real_name = "swirly lollipop"
	icon_state = "lpop-rainbow"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "lpop-rainbow"
	initial_volume = 15
	sugar_content = 15
	var/flavor_name

	on_reagent_change()
		..()
		src.update_name()

	proc/update_name()
		src.flavor_name = src.reagents.get_master_reagent_name()
		if (src.flavor_name == "sugar")
			src.flavor_name = null
		src.name = "[name_prefix(null, 1)][src.flavor_name ? "[src.flavor_name]-flavored " : null][src.real_name][name_suffix(null, 1)]"

/obj/item/reagent_containers/food/snacks/candy/dragons_beard
	name = "dragon's beard candy loop"
	desc = "A loop of dragon's beard candy."
	real_name = "dragon's beard candy loop"
	icon_state = "dragonsbeard-loop"
	initial_volume = 18
	sugar_content = 18
	sliceable = TRUE
	slice_product = /obj/item/reagent_containers/food/snacks/candy/dragons_beard_cut
	slice_amount = 3
	slice_suffix = "piece"
	food_effects = list("food_energized")
	var/flavor_name
	var/folds = 1 // How many folds have been done to the candy
	var/eat_message = null // The message you get for eating the candy
	var/floured = FALSE // If flour was applied. Gets removed on fold, contributes to success probability

	New()
		..()
		src.update_candy()

	on_reagent_change()
		..()
		src.update_icon(1)
		src.update_name()

	proc/update_name()
		src.flavor_name = src.reagents.get_master_reagent_name()
		if (src.flavor_name == "sugar" || src.flavor_name == "Enriched MSG")
			src.flavor_name = null
		src.name = "[name_prefix(null, 1)][src.flavor_name ? "[src.flavor_name]-flavored " : null][src.real_name][name_suffix(null, 1)]"

	process_sliced_products(var/obj/item/reagent_containers/food/snacks/candy/dragons_beard_cut/slice, var/amount_to_transfer)
		slice.folds = src.folds
		slice.desc = src.desc
		slice.eat_message = src.eat_message
		slice.food_effects = src.food_effects
		..()

	update_icon(var/did_reagents_change)
		var/datum/color/average = src.reagents.get_average_color()
		if (did_reagents_change)
			src.food_color = average.to_rgba()
			src.color = average.to_rgb()
		if (folds > 31)
			src.icon_state = "dragonsbeard-loopinf"
			src.color = "#FFFFFF"
			src.alpha = average.a
			var/image/glow_image = new /image(src.icon, "dragonsbeard-loopinfoverlay")
			var/image/loop_image = new /image(src.icon, "dragonsbeard-loopinf")
			loop_image.color = average.to_rgba()
			src.UpdateOverlays(glow_image, "dragonsbeard-loopinfoverlay")
			src.UpdateOverlays(loop_image, "dragonsbeard-loopinf")
			src.use_bite_mask = FALSE
		else if (floured)
			src.alpha = average.a
		else
			src.alpha = round(average.a / 1.5)

	heal(var/mob/M)
		..()
		boutput(M, src.eat_message)
		return

	attack_self(mob/user as mob)
		if (folds < 32)
			user.visible_message("[user] twists [src], folding it in on itself!", "You twist [src] and fold it back into a ring.")
			if (prob(get_success_prob(user)))
				src.folds++
				src.floured = FALSE
				src.quality += 0.2
				playsound(src.loc, "rustle", 50, 1)
				update_icon(0)
				update_candy()
			else
				user.visible_message("[src] disintegrates, falling apart into individual strands and sugar dust!", "[src] disintegrates through your fingers, what remains of its strands falling onto the floor.")
				var/turf/T = get_turf(user)
				var/diminished_reagents = max(1, round(src.reagents.total_volume / 6)) // less reagent content for failing
				for (var/i=0, i<pick(1,2,3), i++)
					var/obj/item/reagent_containers/food/snacks/candy/dragons_beard_cut/A = new /obj/item/reagent_containers/food/snacks/candy/dragons_beard_cut(T)
					A.reagents.clear_reagents()
					src.reagents.trans_to(A, diminished_reagents)
					A.folds = src.folds
					A.desc = src.desc
					A.eat_message = src.eat_message
					A.food_effects = src.food_effects
				qdel(src)
				return
		else
			boutput(user, "There is no point going any further.")

	attackby(obj/item/W, mob/user)
		if (folds < 32 && !src.floured && istype(W,/obj/item/reagent_containers/food/snacks/ingredient/flour))
			boutput(user, "You flour [src].")
			src.floured = TRUE
			update_icon(0)
		else if (folds > 31 && istype(W,/obj/item/reagent_containers/food/snacks/ingredient/flour))
			boutput(user, "No need. It is complete.")
		else
			..()

	proc/get_success_prob(mob/user)
		var/success_prob = 0
		if (floured)
			success_prob = round(100 - (folds * 1.5))
		else
			success_prob = round(75 - (folds * 1.5)) // really hard to make unless you're the skilled chef
		if (user.job == "Chef") success_prob = success_prob * 1.5
		return success_prob

	proc/update_candy()
		switch(folds)
			if (1 to 4)
				src.desc = "A sorry excuse for proper candy. It looks terrible, you can see the strands individually."
				src.eat_message = "That wasn't fluffy at all!"
			if (4 to 7)
				src.desc = "Chinese cotton candy. It doesn't look that well made."
			if (7 to 11)
				src.desc = "Chinese cotton candy. Its texture is thin like hair."
				src.eat_message = "The texture is soft, but slightly chewy."
			if (11 to 14)
				src.desc = "Chinese cotton candy. Its strands are tiny and fragile."
				src.eat_message = "The texture is soft and delicate."
			if (14 to 18)
				src.desc = "Chinese cotton candy. Its light and fluffy, made up of thousands of individual strands."
			if (18 to 22)
				src.desc = "Chinese cotton candy. Its clumped up into ropes of thousands of strands."
				src.eat_message = "[src] melts in your mouth!"
				src.food_effects = list("food_energized_big")
			if (22 to 31)
				src.desc = "Chinese cotton candy. Its stiff and dense, comprised of millions of microscopic strands. Does this still count as cotton candy?"
			if (31 to 32)
				src.name = "infinity-fold dragon's beard candy loop"
				src.desc = "A loop of dragon's beard candy that has been folded into uncountable microscopic strands."
				src.real_name = "infinity-fold dragon's beard candy loop"
				src.eat_message = "[src] immediately dissolves in your mouth."
				src.reagents.add_reagent("enriched_msg", 3)

/obj/item/reagent_containers/food/snacks/candy/dragons_beard/infinity
	name = "infinity-fold dragon's beard candy"
	desc = "A piece of dragon's beard candy that has been folded into uncountable microscopic strands."
	icon_state = "dragonsbeard-loopinf"
	folds = 32

	New()
		..()
		src.reagents.add_reagent("enriched_msg", 3)

/obj/item/reagent_containers/food/snacks/candy/dragons_beard_cut
	name = "dragon's beard candy"
	desc = "A piece of dragon's beard candy."
	real_name = "dragon's beard candy"
	icon_state = "dragonsbeard"
	initial_volume = 6
	sugar_content = 6
	bites_left = 1
	food_effects = list("food_energized")
	var/flavor_name
	var/folds
	var/eat_message

	heal(var/mob/M)
		..()
		boutput(M, src.eat_message)
		return

	on_reagent_change()
		..()
		src.update_icon()
		src.update_name()

	proc/update_name()
		src.flavor_name = src.reagents.get_master_reagent_name()
		if (src.flavor_name == "sugar" || src.flavor_name == "Enriched MSG")
			src.flavor_name = null
		src.name = "[name_prefix(null, 1)][src.flavor_name ? "[src.flavor_name]-flavored " : null][src.real_name][name_suffix(null, 1)]"

	update_icon()
		var/datum/color/average = src.reagents.get_average_color()
		src.food_color = average.to_rgba()
		if (folds > 31)
			src.name = "infinity-fold dragon's beard candy"
			src.desc = "A piece of dragon's beard candy that has been folded into uncountable microscopic strands."
			src.real_name = "infinity-fold dragon's beard candy"
			src.color = "#FFFFFF"
			var/image/glow_image = new /image(src.icon, "dragonsbeard-infoverlay")
			var/image/candy_image = new /image(src.icon, "dragonsbeard")
			candy_image.color = average.to_rgba()
			src.UpdateOverlays(glow_image, "dragonsbeard-infoverlay")
			src.UpdateOverlays(candy_image, "dragonsbeard")
		else
			src.color = average.to_rgb()
