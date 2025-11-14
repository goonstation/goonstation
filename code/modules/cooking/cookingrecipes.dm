ABSTRACT_TYPE(/datum/recipe/cooking)
/datum/recipe/cooking
	var/useshumanmeat = 0 // used for naming of human meat dishes after their victims.

	output_post_process(list/input_list, list/output_list, atom/cook_source = null, mob/user = null)
		if (!src.useshumanmeat)
			return
		// naming of food after human products. TODO this should perhaps work off components
		for(var/obj/item/reagent_containers/food/snacks/F in output)
			var/foodname = F.name
			for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in input_list)
				F.name = "[M.subjectname] [foodname]"
				F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
				if(!isnull(F.unlock_medal_when_eaten))
					continue
				else if (M.subjectjob && M.subjectjob == "Clown")
					F.unlock_medal_when_eaten = "That tasted funny"
				else
					F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method

/datum/recipe/cooking/spicychickensandwich
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	category = "Burgers"
	recipe_instructions = list(\
	/datum/recipe_instructions/oven/sandwich)

/datum/recipe/cooking/chickensandwich
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/chicken
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/spicy = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy, //:melterfrog:
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock = /obj/item/reagent_containers/food/snacks/burger/flockburger)
	category = "Burgers"
	recipe_instructions = list(/datum/recipe_instructions/oven/sandwich)

ABSTRACT_TYPE(/datum/recipe/cooking/burger)
/datum/recipe/cooking/burger
	category = "Burgers"

	get_output(var/list/input_list, var/list/output_list)
		//this is dumb and assumes the second thing is always the meat but it usually is so :iiam:
		var/obj/item/possibly_meat = locate(ingredients[2]) in input_list
		if (possibly_meat?.reagents?.get_reagent_amount("crime") >= 5)
			var/obj/item/reagent_containers/food/snacks/burger/burgle/burgle = new()
			possibly_meat.transfer_all_reagents(burgle)
			output_list += burgle
			return TRUE
		else
			return ..()

/datum/recipe/cooking/burger/meat
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/burger
	useshumanmeat = TRUE //this is a bit hacky, but it shouldn't affect anything when cooking any of the non-human recipes
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug = /obj/item/reagent_containers/food/snacks/burger/slugburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = /obj/item/reagent_containers/food/snacks/burger/fishburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = /obj/item/reagent_containers/food/snacks/burger/humanburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = /obj/item/reagent_containers/food/snacks/burger/monkeyburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = /obj/item/reagent_containers/food/snacks/burger/synthburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat = /obj/item/reagent_containers/food/snacks/burger/mysteryburger)

/datum/recipe/cooking/burger/cheeseburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/cheeseburger)

/datum/recipe/cooking/burger/cheeseburger/monkey
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger_m
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/cheeseburger)

/datum/recipe/cooking/burger/wcheeseburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/gcheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/wcheeseburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/wcheeseburger)

/datum/recipe/cooking/burger/luauburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/luauburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/luauburger)

/datum/recipe/cooking/burger/coconutburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/coconutburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/coconutburger)

/datum/recipe/cooking/burger/tikiburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/tikiburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/tikiburger)

/datum/recipe/cooking/burger/buttburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/clothing/head/butt = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/buttburger
	variants = list(\
	/obj/item/clothing/head/butt/synth = /obj/item/reagent_containers/food/snacks/burger/buttburger/synth,
	/obj/item/clothing/head/butt/cyberbutt = /obj/item/reagent_containers/food/snacks/burger/buttburger/cyber)
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/buttburger)

/datum/recipe/cooking/burger/heartburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/heart = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger
	variants = list(\
	/obj/item/organ/heart/flock = /obj/item/reagent_containers/food/snacks/burger/heartburger/flock,
	/obj/item/organ/heart/cyber = /obj/item/reagent_containers/food/snacks/burger/heartburger/cyber,
	/obj/item/organ/heart/synth = /obj/item/reagent_containers/food/snacks/burger/heartburger/synth)
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/heartburger)

/datum/recipe/cooking/burger/brainburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/brain = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger
	variants = list(\
	/obj/item/organ/brain/synth = /obj/item/reagent_containers/food/snacks/burger/brainburger/synth,
	/obj/item/organ/brain/latejoin = /obj/item/reagent_containers/food/snacks/burger/brainburger/cyber,
	/obj/item/organ/brain/flockdrone = /obj/item/reagent_containers/food/snacks/burger/brainburger/flock)
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/brainburger)

/datum/recipe/cooking/burger/roburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/parts/robot_parts/head = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/roburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/roburger)

/datum/recipe/cooking/burger/cheeseborger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/parts/robot_parts/head = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseborger

/datum/recipe/cooking/burger/baconburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/baconburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger)

/datum/recipe/cooking/burger/baconator
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/burger/bigburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger)

/datum/recipe/cooking/burger/butterburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/butterburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger)

/datum/recipe/cooking/burger/aburgination
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/aburgination
	recipe_instructions = list(/datum/recipe_instructions/oven/burger)

/datum/recipe/cooking/burger/monster
	ingredients = list(/obj/item/reagent_containers/food/snacks/burger/bigburger = 4)
	output = /obj/item/reagent_containers/food/snacks/burger/monsterburger
	recipe_instructions = list(/datum/recipe_instructions/oven/burger)

/datum/recipe/cooking/swede_mball
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/meatball = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/swedishmeatball
	recipe_instructions = list(/datum/recipe_instructions/oven/swede_mball)

/datum/recipe/cooking/donkpocket
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1)
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm
	recipe_instructions = list(/datum/recipe_instructions/oven/donkpocket)
	variants = list(\
	/obj/item/instrument/bikehorn = /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm)

/datum/recipe/cooking/donkpocket2
	ingredients = list(/obj/item/reagent_containers/food/snacks/donkpocket = 1)
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm
	recipe_instructions = list(/datum/recipe_instructions/oven/donkpocket)
	variants = list(\
	/obj/item/reagent_containers/food/snacks/donkpocket/honk = /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm)

/datum/recipe/cooking/donut
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_circle = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/donut
	recipe_instructions = list(/datum/recipe_instructions/oven/donut)

/datum/recipe/cooking/bagel
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough_circle = 1)
	output = /obj/item/reagent_containers/food/snacks/bagel
	recipe_instructions = list(/datum/recipe_instructions/oven/bagel)

/datum/recipe/cooking/crumpet //another good idea for this is to cook a trumpet
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/holey_dough = 1)
	output = /obj/item/reagent_containers/food/snacks/crumpet
	recipe_instructions = list(/datum/recipe_instructions/oven/crumpet)

/datum/recipe/cooking/ice_cream_cone
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/ice_cream_cone
	recipe_instructions = list(/datum/recipe_instructions/oven/ice_cream_cone)

/datum/recipe/cooking/nougat
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/candy/nougat
	recipe_instructions = list(/datum/recipe_instructions/oven/nougat)

/datum/recipe/cooking/candy_cane
	ingredients = list(\
	/obj/item/plant/herb/mint = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/candy/candy_cane

/datum/recipe/cooking/waffles
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1)
	output = /obj/item/reagent_containers/food/snacks/waffles

/datum/recipe/cooking/spaghetti_p
	recipe_instructions = list(/datum/recipe_instructions/oven/spaghetti_p)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti
	category = "Pasta"

/datum/recipe/cooking/spaghetti_t
	recipe_instructions = list(/datum/recipe_instructions/oven/spaghetti_t)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/sauce
	category = "Pasta"

/datum/recipe/cooking/spaghetti_s
	recipe_instructions = list(/datum/recipe_instructions/oven/spaghetti_s)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/spicy
	category = "Pasta"

/datum/recipe/cooking/spaghetti_m
	recipe_instructions = list(/datum/recipe_instructions/oven/spaghetti_m)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/meatball
	category = "Pasta"

/datum/recipe/cooking/lasagna
	recipe_instructions = list(/datum/recipe_instructions/oven/lasagna)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/lasagna
	category = "Pasta"

/datum/recipe/cooking/alfredo
	recipe_instructions = list(/datum/recipe_instructions/oven/alfredo)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/alfredo
	category = "Pasta"

/datum/recipe/cooking/chickenparm
	recipe_instructions = list(/datum/recipe_instructions/oven/chickenparm)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/chickenparm
	category = "Pasta"

/datum/recipe/cooking/chickenalfredo
	recipe_instructions = list(/datum/recipe_instructions/oven/chickenalfredo)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/chickenalfredo
	category = "Pasta"

/datum/recipe/cooking/spaghetti_pg
	recipe_instructions = list(/datum/recipe_instructions/oven/spaghetti_pg)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/pizza = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/pizzaghetti
	category = "Pasta"

/datum/recipe/cooking/spooky_bread
	recipe_instructions = list(/datum/recipe_instructions/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/spooky
	category = "Bread"

/datum/recipe/cooking/elvis_bread
	recipe_instructions = list(/datum/recipe_instructions/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/elvis
	category = "Bread"

/datum/recipe/cooking/banana_bread
	recipe_instructions = list(/datum/recipe_instructions/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/recipe/cooking/banana_bread_alt
	recipe_instructions = list(/datum/recipe_instructions/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/recipe/cooking/cornbread1
	recipe_instructions = list(/datum/recipe_instructions/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn
	category = "Bread"

/datum/recipe/cooking/cornbread2
	recipe_instructions = list(/datum/recipe_instructions/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/recipe/cooking/cornbread3
	recipe_instructions = list(/datum/recipe_instructions/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/recipe/cooking/cornbread4
	recipe_instructions = list(/datum/recipe_instructions/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet/honey
	category = "Bread"

/datum/recipe/cooking/pumpkin_bread
	recipe_instructions = list(/datum/recipe_instructions/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/pumpkin = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/pumpkin
	category = "Bread"

/datum/recipe/cooking/bread
	recipe_instructions = list(/datum/recipe_instructions/oven/bread)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf
	category = "Bread"

/datum/recipe/cooking/honeywheat_bread
	recipe_instructions = list(/datum/recipe_instructions/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	category = "Bread"

/datum/recipe/cooking/brain_bread
	recipe_instructions = list(/datum/recipe_instructions/oven/brain_bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf = 1,
	/obj/item/organ/brain = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/brain
	category = "Bread"

/datum/recipe/cooking/toast_bread
	recipe_instructions = list(/datum/recipe_instructions/oven/toast_bread)
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadloaf = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/toast
	category = "Bread"

/datum/recipe/cooking/toast
	recipe_instructions = list(/datum/recipe_instructions/oven/toast)
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice = 1)
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/banana = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/banana,
	/obj/item/reagent_containers/food/snacks/breadslice/brain = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/brain,
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/elvis,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/spooky,
	/obj/item/reagent_containers/food/snacks/breadslice/french = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/french)
	category = "Toast"

ABSTRACT_TYPE(/datum/recipe/cooking/sandwich)
/datum/recipe/cooking/sandwich
	recipe_instructions = list(/datum/recipe_instructions/oven/sandwich)
	variant_quantity = 2
	category = "Sandwich"

/datum/recipe/cooking/sandwich/human
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_h
	useshumanmeat = TRUE
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_h,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_h)

/datum/recipe/cooking/sandwich/monkey
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_m
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_m,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_m)


/datum/recipe/cooking/sandwich/synth
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_s
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_s,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_s)

/datum/recipe/cooking/sandwich/cheese
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/sandwich/cheese
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_cheese,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_cheese)

/datum/recipe/cooking/sandwich/peanutbutter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/pb
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pb,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pb)


/datum/recipe/cooking/sandwich/peanutbutter_honey
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/pbh
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pbh,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pbh)

/datum/recipe/cooking/sandwich/blt
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon= 1,
	/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/lettuce = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/blt
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_blt,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_blt)

/datum/recipe/cooking/sandwich/c_butty
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/fries = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/c_butty

/datum/recipe/cooking/sandwich/meatball //Original meatball sub recipe
	recipe_instructions = list(/datum/recipe_instructions/oven/sandwich/meatball)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball

/datum/recipe/cooking/sandwich/meatball_alt //Secondary recipe that uses the baguette
	recipe_instructions = list(/datum/recipe_instructions/oven/sandwich/meatball)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball

/datum/recipe/cooking/sandwich/egg
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/eggsalad = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/eggsalad

/datum/recipe/cooking/sandwich/bahnmi //Original banh mi recipe
	recipe_instructions = list(/datum/recipe_instructions/oven/sandwich/bahnmi)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf/honeywheat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi

/datum/recipe/cooking/sandwich/bahnmi_alt //Secondary recipe that uses the baguette
	recipe_instructions = list(/datum/recipe_instructions/oven/sandwich/bahnmi)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi

/datum/recipe/cooking/sandwich/custom
	recipe_instructions = list(/datum/recipe_instructions/oven/sandwich/custom)
	ingredients =  list(/obj/item/reagent_containers/food/snacks/breadslice = 2)
	output = /obj/item/reagent_containers/food/snacks/sandwich
	wildcard_quantity = 100

	get_output(var/list/input_list, var/list/output_list)
		var/obj/item/reagent_containers/food/snacks/sandwich/customSandwich = new /obj/item/reagent_containers/food/snacks/sandwich ()
		customSandwich.heal_amt = 1 // no filling yet, so less than regular sandwich
		customSandwich.reagents = new /datum/reagents(100)
		customSandwich.reagents.my_atom = customSandwich

		var/obj/item/reagent_containers/food/snacks/breadslice/slice1
		var/obj/item/reagent_containers/food/snacks/breadslice/slice2
		var/list/fillings = list()
		var/list/fillingColors = list()
		var/onBreadText = ""
		var/extraSlices = 0
		var/isToast = FALSE

		var/i = 1
		for (var/obj/item/reagent_containers/food/snacks/snack in input_list)
			if (snack == customSandwich)
				continue

			else if (istype(snack, /obj/item/reagent_containers/food/snacks/breadslice))
				if (slice1 && slice2)
					// fix up ordering of toast sandwich components
					var/toast1 = istype(slice1, /obj/item/reagent_containers/food/snacks/breadslice/toastslice)
					var/toast2 = istype(slice2, /obj/item/reagent_containers/food/snacks/breadslice/toastslice)
					var/toast3 = istype(snack, /obj/item/reagent_containers/food/snacks/breadslice/toastslice)
					if (extraSlices == 0 && toast1 + toast2 + toast3 == 1)
						var/obj/item/reagent_containers/food/snacks/breadslice/temp = snack
						if (toast1)
							snack = slice1
							slice1 = temp
						else if (toast2)
							snack = slice2
							slice2 = temp
						isToast = TRUE
						onBreadText = "on [slice1.real_name == "bread" ? "plain bread" : slice1.real_name]"
						if (slice1.real_name != slice2.real_name)
							onBreadText += " and [slice2.real_name == "bread" ? "plain" : slice2.real_name]"
					else
						isToast = FALSE

					extraSlices++

					if (snack.reagents)
						snack.reagents.trans_to(customSandwich, 25)
					customSandwich.food_effects += snack.food_effects

					//fillings += snack.name
					if (snack.get_average_color())
						if (fillingColors.len % 2 || length(fillingColors) < (i*2))
							fillingColors += "B[snack.get_average_color()]"
						else
							fillingColors.Insert((i++*2), "B[snack.get_average_color()]")
					qdel(snack)

				else if (slice1)
					slice2 = snack
					if (slice1.real_name != snack.real_name)
						onBreadText += " and [snack.real_name == "bread" ? "plain" : snack.real_name]"
				else
					slice1 = snack
					onBreadText = "on [snack.real_name == "bread" ? "plain bread" : snack.real_name]"
			else
				if (snack.reagents)
					snack.reagents.trans_to(customSandwich, 25)
				customSandwich.food_effects += snack.food_effects

				fillings += snack.name
				if (snack.get_average_color() && !istype(snack, /obj/item/reagent_containers/food/snacks/ingredient) && prob(50))
					fillingColors += snack.get_average_color()
				else
					var/obj/transformedFilling = image(snack.icon, snack.icon_state)
					transformedFilling.transform = matrix(0.75, MATRIX_SCALE)
					fillingColors += transformedFilling

				// spread the total healing left for the added food among the sandwich bites
				customSandwich.heal_amt += snack.heal_amt * snack.bites_left / customSandwich.bites_left

				qdel(snack)

		if (!fillings.len && isToast)
			customSandwich.name = "toast"
			customSandwich.desc = "A slice of toast between two slices of bread. Apparently this counts as a sandwich?"
			extraSlices--
			customSandwich.reagents.add_reagent("worcestershire_sauce", 25)
		else if (!fillings.len)
			customSandwich.name = "wish"
			customSandwich.desc = "So named because you 'wish' you had something to put between the slices of bread. Ha.  ha.  Ha..."
		else
			var/fillingText = copytext(html_encode(english_list(fillings)), 1, 512)
			customSandwich.name = fillingText
			customSandwich.desc = "A sandwich filled with [fillingText]."

		switch (extraSlices)
			if (0)
				customSandwich.name += " sandwich"

			if (1)
				customSandwich.name += " club"

			if (2)
				customSandwich.name += " double-decker sandwich"

			if (3)
				customSandwich.name += " dagwood"

		customSandwich.name += " [onBreadText]"

		var/obj/sandwichIcon
		customSandwich.icon = 'icons/obj/foodNdrink/food_meals.dmi'
		if (slice1)
			sandwichIcon = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-bread")//, 1, 1)
			//sandwichIcon.Blend(slice1.food_color, ICON_ADD)
			sandwichIcon.color = slice1.get_average_color()

			customSandwich.overlays += sandwichIcon
			//qdel(slice1)

		var/fillingOffset = 2
		var/obj/newFilling
		while (fillingColors.len)
			if (istype(fillingColors[fillingColors.len], /image))
				newFilling = fillingColors[fillingColors.len]

			else if (copytext(fillingColors[fillingColors.len],1,2) == "B")
				newFilling = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-bread")
				fillingColors[fillingColors.len] = copytext(fillingColors[fillingColors.len], 2)

			else
				newFilling = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-filling[rand(1,4)]")//, 1, 1)
			//newFilling.Blend(fillingColors[fillingColors.len], ICON_ADD)
			newFilling.pixel_y = fillingOffset
			newFilling.color = fillingColors[fillingColors.len]
			fillingColors.len--
			fillingOffset += 2

			customSandwich.overlays += newFilling


		if (slice2)
			newFilling = image('icons/obj/foodNdrink/food_meals.dmi', "sandwich-bread")//, 1, 1)
			//newFilling.Blend( slice2.food_color, ICON_ADD)
			newFilling.color = slice2.get_average_color()
			newFilling.pixel_y = fillingOffset

			//qdel(slice2)

			customSandwich.overlays += newFilling

		output_list += customSandwich
		return TRUE

/datum/recipe/cooking/pizza_custom
	recipe_instructions = list(/datum/recipe_instructions/oven/pizza_custom)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pizza_base = 1)
	output = /obj/item/reagent_containers/food/snacks/pizza/bespoke
	category = "Pizza"

	get_output(var/list/input_list, var/list/output_list)
		for (var/obj/item/reagent_containers/food/snacks/ingredient/pizza_base/P in input_list)
			output_list += P.bake_pizza()
		return TRUE

/datum/recipe/cooking/cheesetoast
	recipe_instructions = list(/datum/recipe_instructions/oven/cheesetoast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/toastcheese
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/toastcheese/elvis)
	category = "Toast (Meal)"


/datum/recipe/cooking/bacontoast
	recipe_instructions = list(/datum/recipe_instructions/oven/bacontoast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/toastbacon
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/toastbacon/elvis)
	category = "Toast (Meal)"

/datum/recipe/cooking/eggtoast
	recipe_instructions = list(/datum/recipe_instructions/oven/eggtoast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/toastegg
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/toastegg/elvis)
	category = "Toast (Meal)"

/datum/recipe/cooking/breakfast
	recipe_instructions = list(/datum/recipe_instructions/oven/breakfast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/breakfast

/datum/recipe/cooking/wonton_wrapper // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/reagent_containers/food/snacks/wonton_spawner

/datum/recipe/cooking/taco_shell
	recipe_instructions = list(/datum/recipe_instructions/oven/taco_shell)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/tortilla = 1)
	output = /obj/item/reagent_containers/food/snacks/taco

/datum/recipe/cooking/eggnog
	recipe_instructions = list(/datum/recipe_instructions/oven/eggnog)
	ingredients = list(\
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 3)
	output = /obj/item/reagent_containers/food/drinks/eggnog

// Pastries and bread-likes

/datum/recipe/cooking/baguette
	recipe_instructions = list(/datum/recipe_instructions/oven/baguette)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_strip = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/baguette
	category = "Pastries and bread-likes" // not sorry

/datum/recipe/cooking/garlicbread
	recipe_instructions = list(/datum/recipe_instructions/oven/garlicbread)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/garlicbread
	category = "Pastries and bread-likes"

/datum/recipe/cooking/garlicbread_ch
	recipe_instructions = list(/datum/recipe_instructions/oven/garlicbread_ch)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/garlicbread_ch
	category = "Pastries and bread-likes"

/datum/recipe/cooking/painauchocolat
	recipe_instructions = list(/datum/recipe_instructions/oven/painauchocolat)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1)
	output = /obj/item/reagent_containers/food/snacks/painauchocolat
	category = "Pastries and bread-likes"

/datum/recipe/cooking/croissant
	recipe_instructions = list(/datum/recipe_instructions/oven/croissant)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/croissant
	category = "Pastries and bread-likes"

/datum/recipe/cooking/danish_apple
	recipe_instructions = list(/datum/recipe_instructions/oven/danish_apple)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/apple = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_apple
	category = "Pastries and bread-likes"

/datum/recipe/cooking/danish_cherry
	recipe_instructions = list(/datum/recipe_instructions/oven/danish_cherry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_cherry
	category = "Pastries and bread-likes"

/datum/recipe/cooking/danish_blueb
	recipe_instructions = list(/datum/recipe_instructions/oven/danish_blueb)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/blueberry = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_blueb
	category = "Pastries and bread-likes"

/datum/recipe/cooking/danish_weed
	recipe_instructions = list(/datum/recipe_instructions/oven/danish_weed)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/plant/herb/cannabis = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_weed
	category = "Pastries and bread-likes"

/datum/recipe/cooking/danish_cheese
	recipe_instructions = list(/datum/recipe_instructions/oven/danish_cheese)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_cheese
	category = "Pastries and bread-likes"

/datum/recipe/cooking/fairybread
	recipe_instructions = list(/datum/recipe_instructions/oven/fairybread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/fairybread
	category = "Pastries and bread-likes"

/datum/recipe/cooking/cinnamonbun
	recipe_instructions = list(/datum/recipe_instructions/oven/cinnamonbun)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/cinnamon = 1)
	output = /obj/item/reagent_containers/food/snacks/cinnamonbun
	category = "Pastries and bread-likes"

/datum/recipe/cooking/chocolate_cherry
	recipe_instructions = list(/datum/recipe_instructions/oven/chocolate_cherry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/chocolate_cherry

//Cookies
/datum/recipe/cooking/stroopwafel
	recipe_instructions = list(/datum/recipe_instructions/oven/stroopwafel)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 2,
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 1)
	output = /obj/item/reagent_containers/food/snacks/stroopwafel
	category = "Cookies"

/datum/recipe/cooking/cookie
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie
	category = "Cookies"

/datum/recipe/cooking/cookie_iron
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_iron)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ironfilings = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/metal
	category = "Cookies"

/datum/recipe/cooking/cookie_chocolate_chip
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_chocolate_chip)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/condiment/chocchips = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	category = "Cookies"

/datum/recipe/cooking/cookie_oatmeal
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_oatmeal)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/oatmeal
	category = "Cookies"

/datum/recipe/cooking/cookie_bacon
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/bacon
	category = "Cookies"

/datum/recipe/cooking/cookie_jaffa
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_jaffa)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/plant/orange = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/jaffa
	category = "Cookies"

/datum/recipe/cooking/cookie_spooky
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_spooky)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/spooky
	category = "Cookies"

/datum/recipe/cooking/cookie_butter
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_butter)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/butter
	category = "Cookies"

/datum/recipe/cooking/cookie_peanut
	recipe_instructions = list(/datum/recipe_instructions/oven/cookie_peanut)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/peanut
	category = "Cookies"

//Moon pies!
/datum/recipe/cooking/moon_pie
	recipe_instructions = list(/datum/recipe_instructions/oven/moon_pie)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/moon_pie
	variants = list(\
	/obj/item/reagent_containers/food/snacks/cookie/metal = /obj/item/reagent_containers/food/snacks/moon_pie/metal,
	/obj/item/reagent_containers/food/snacks/cookie/chocolate_chip = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate_chip,
	/obj/item/reagent_containers/food/snacks/cookie/oatmeal = /obj/item/reagent_containers/food/snacks/moon_pie/oatmeal,
	/obj/item/reagent_containers/food/snacks/cookie/bacon = /obj/item/reagent_containers/food/snacks/moon_pie/bacon,
	/obj/item/reagent_containers/food/snacks/cookie/jaffa = /obj/item/reagent_containers/food/snacks/moon_pie/jaffa,
	/obj/item/reagent_containers/food/snacks/cookie/spooky = /obj/item/reagent_containers/food/snacks/moon_pie/spooky)
	variant_quantity = 2
	category = "Moon Pies"

/datum/recipe/cooking/moon_pie_chocolate
	recipe_instructions = list(/datum/recipe_instructions/oven/moon_pie_chocolate)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/chocolate_chip = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate
	category = "Moon Pies"

/datum/recipe/cooking/onionchips
	recipe_instructions = list(/datum/recipe_instructions/oven/onionchips)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/onion_slice = 2,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/onionchips

/datum/recipe/cooking/fries
	recipe_instructions = list(/datum/recipe_instructions/oven/fries)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/chips = 1)
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/recipe/cooking/chilifries
	recipe_instructions = list(/datum/recipe_instructions/oven/chilifries)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/fries = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries

/datum/recipe/cooking/chilifries_alt
	recipe_instructions = list(/datum/recipe_instructions/oven/chilifries_alt) //Secondary recipe for chili cheese fries
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/chips = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries

/datum/recipe/cooking/poutine
	recipe_instructions = list(/datum/recipe_instructions/oven/poutine)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/fries = 1,
	/obj/item/reagent_containers/food/snacks/condiment/gravyboat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries/poutine

/datum/recipe/cooking/poutine_alt
	recipe_instructions = list(/datum/recipe_instructions/oven/poutine_alt)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/chips = 1,
	/obj/item/reagent_containers/food/snacks/condiment/gravyboat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries/poutine

/datum/recipe/cooking/bakedpotato
	recipe_instructions = list(/datum/recipe_instructions/oven/bakedpotato)
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/potato = 1)
	output = /obj/item/reagent_containers/food/snacks/bakedpotato

/datum/recipe/cooking/hotdog
	recipe_instructions = list(/datum/recipe_instructions/oven/hotdog)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1)
	output = /obj/item/reagent_containers/food/snacks/hotdog

/datum/recipe/cooking/cook_meat//Very jank, will need future work.
	recipe_instructions = list(/datum/recipe_instructions/oven/cook_meat)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/steak
	useshumanmeat = TRUE //see /datum/recipe/cooking/burger/meat
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = /obj/item/reagent_containers/food/snacks/steak/human,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = /obj/item/reagent_containers/food/snacks/steak/synth,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = /obj/item/reagent_containers/food/snacks/steak/monkey,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/sheep = /obj/item/reagent_containers/food/snacks/steak/sheep,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = /obj/item/reagent_containers/food/snacks/fish_fingers)

/datum/recipe/cooking/steak_ling
	recipe_instructions = list(/datum/recipe_instructions/oven/steak_ling)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling = 1)
	output = /obj/item/reagent_containers/food/snacks/steak/ling

/datum/recipe/cooking/shrimp
	recipe_instructions = list(/datum/recipe_instructions/oven/shrimp)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/shrimp = 1)
	output = /obj/item/reagent_containers/food/snacks/shrimp

/datum/recipe/cooking/bacon
	recipe_instructions = list(/datum/recipe_instructions/oven/bacon)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon

/datum/recipe/cooking/turkey
	recipe_instructions = list(/datum/recipe_instructions/oven/turkey)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/turkey = 1)
	output = /obj/item/reagent_containers/food/snacks/turkey

/datum/recipe/cooking/pie_strawberry
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_strawberry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/strawberry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/strawberry
	category = "Pies"

/datum/recipe/cooking/pie_cherry
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_cherry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/cherry
	category = "Pies"

/datum/recipe/cooking/pie_blueberry
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_blueberry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/blueberry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/blueberry
	category = "Pies"

/datum/recipe/cooking/pie_raspberry
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_raspberry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/raspberry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/raspberry
	variants = list(\
	/obj/item/reagent_containers/food/snacks/plant/raspberry/blackberry = /obj/item/reagent_containers/food/snacks/pie/blackberry)
	category = "Pies"

/datum/recipe/cooking/pie_apple
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_apple)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/apple = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/apple
	category = "Pies"

/datum/recipe/cooking/pie_lime
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_lime)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/lime = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/lime
	category = "Pies"

/datum/recipe/cooking/pie_lemon
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_lemon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/lemon = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/lemon
	category = "Pies"

/datum/recipe/cooking/pie_slurry
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_slurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/slurryfruit = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/slurry
	category = "Pies"

/datum/recipe/cooking/pie_pumpkin
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_pumpkin)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/pumpkin = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/pumpkin
	category = "Pies"

/datum/recipe/cooking/pie_chocolate
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_chocolate)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/chocolate
	category = "Pies"

/datum/recipe/cooking/pie_anything/pie_cream
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_anything/pie_cream)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/cream
	category = "Pies"
	base_pie_name = "cream pie"

/datum/recipe/cooking/pie_anything
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_anything)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/anything
	category = "Pies"
	var/base_pie_name = "pie"
	wildcard_quantity = 100

	get_output(var/list/input_list, var/list/output_list)
		if (length(input_list) <= 2)
			output_list += new src.output
			return TRUE

		var/obj/item/reagent_containers/food/snacks/anItem
		var/obj/item/reagent_containers/food/snacks/pie/custom_pie = new src.output
		var/pieDesc
		var/pieName
		var/contentAmount = length(input_list) - 2
		var/count = 1
		var/found1 = 0
		var/found2 = 0
		for (var/obj/item/T in input_list)

			if (!found1 && istype(T, ingredients[1]))
				found1 = TRUE
				continue

			if (!found2 && istype( T, ingredients[2]))
				found2 = TRUE
				continue

			anItem = T
			anItem.set_loc(custom_pie)
			if (count == contentAmount && contentAmount > 1)
				pieDesc += "and a "
			else
				pieDesc += "a "

			if (custom_pie.real_name)
				pieDesc += lowertext(anItem.real_name)
				pieName += lowertext(anItem.real_name)
			else
				pieDesc += lowertext(anItem.name)
				pieName += lowertext(anItem.name)

			if (count < contentAmount)
				if (count == (contentAmount - 1))
					pieDesc += " "
				else
					pieDesc += ", "
				pieName += " "

			custom_pie.w_class = max(custom_pie.w_class, T.w_class) //Well, that huge thing you put into it isn't going to shrink, you know
			custom_pie.throw_range = min(custom_pie.throw_range, T.throw_range)
			custom_pie.throw_speed = min(custom_pie.throw_speed, T.throw_speed)
			custom_pie.contraband = max(custom_pie.contraband, T.contraband - 1)

			count++

//		if (!anItem)
//			return null

		custom_pie.name = pieName + " [src.base_pie_name]"
		custom_pie.desc = "A [src.base_pie_name] containing [pieDesc]. Well alright then."

		var/icon/I = new /icon(custom_pie.icon, custom_pie.icon_state)
		var/atom/thing = pick(custom_pie.contents)
		I.Blend(thing.get_average_color(), ICON_ADD)
		custom_pie.icon = I

		output_list += custom_pie
		return TRUE

/datum/recipe/cooking/pie_custard
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_custard)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/custard = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/custard
	category = "Pies"

/datum/recipe/cooking/pie_bacon
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/bacon
	category = "Pies"

/datum/recipe/cooking/pie_ass
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_ass)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/clothing/head/butt = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/ass
	category = "Pies"

/datum/recipe/cooking/pot_pie
	recipe_instructions = list(/datum/recipe_instructions/oven/pot_pie)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/pot
	category = "Pies"

/datum/recipe/cooking/pie_weed
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_weed)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/plant/herb/cannabis = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/weed
	category = "Pies"

/datum/recipe/cooking/pie_fish
	recipe_instructions = list(/datum/recipe_instructions/oven/pie_fish)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1,
	/obj/item/reagent_containers/food/snacks/plant/potato = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/fish
	category = "Pies"

/datum/recipe/cooking/raw_flan // mixer
	ingredients = list(\
		/obj/item/reagent_containers/food/snacks/ingredient/vanilla_extract = 1,
		/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
		/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
		/obj/item/reagent_containers/food/drinks/milk = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/raw_flan

/datum/recipe/cooking/custard // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/custard

/datum/recipe/cooking/gruel // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/yuck = 3)
	output = /obj/item/reagent_containers/food/snacks/soup/gruel

/datum/recipe/cooking/porridge
	recipe_instructions = list(/datum/recipe_instructions/oven/porridge)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/rice = 2)
	output = /obj/item/reagent_containers/food/snacks/soup/porridge

/datum/recipe/cooking/oatmeal
	recipe_instructions = list(/datum/recipe_instructions/oven/oatmeal)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/oatmeal

/datum/recipe/cooking/tomsoup
	recipe_instructions = list(/datum/recipe_instructions/oven/tomsoup)
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/tomato = 2)
	output = /obj/item/reagent_containers/food/snacks/soup/tomato

/datum/recipe/cooking/mint_chutney
	recipe_instructions = list(/datum/recipe_instructions/oven/mint_chutney)
	ingredients = list(\
	/obj/item/plant/herb/mint = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/mint_chutney

/datum/recipe/cooking/refried_beans
	recipe_instructions = list(/datum/recipe_instructions/oven/refried_beans)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bean = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/refried_beans

/datum/recipe/cooking/chili
	recipe_instructions = list(/datum/recipe_instructions/oven/chili)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/chili

/datum/recipe/cooking/queso
	recipe_instructions = list(/datum/recipe_instructions/oven/queso)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/queso

/datum/recipe/cooking/superchili
	recipe_instructions = list(/datum/recipe_instructions/oven/superchili)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 2)
	output = /obj/item/reagent_containers/food/snacks/soup/superchili

/datum/recipe/cooking/ultrachili
	recipe_instructions = list(/datum/recipe_instructions/oven/ultrachili)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/soup/chili = 1,
	/obj/item/reagent_containers/food/snacks/soup/superchili = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/ultrachili

/datum/recipe/cooking/salad
	recipe_instructions = list(/datum/recipe_instructions/oven/salad)
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/lettuce = 2)
	output = /obj/item/reagent_containers/food/snacks/salad

/datum/recipe/cooking/creamofmushroom
	recipe_instructions = list(/datum/recipe_instructions/oven/creamofmushroom)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/mushroom = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom
	variants = list(\
	/obj/item/reagent_containers/food/snacks/mushroom/psilocybin = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/psilocybin,
	/obj/item/reagent_containers/food/snacks/mushroom/amanita = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/amanita)

//Delightful Halloween Recipes
/datum/recipe/cooking/candy_apple
	recipe_instructions = list(/datum/recipe_instructions/oven/candy_apple)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/apple/stick = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple
	variants = list(\
	/obj/item/reagent_containers/food/snacks/plant/apple/stick/poison = /obj/item/reagent_containers/food/snacks/candy/candy_apple/poison)

//Cakes!
/datum/recipe/cooking/cake_batter // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/cake_batter

/datum/recipe/cooking/cake_cream
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_cream)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/cake/cream
	category = "Cakes"

/datum/recipe/cooking/cake_chocolate
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_chocolate)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/cake/chocolate
	category = "Cakes"

/datum/recipe/cooking/cake_meat
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_meat)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/cake/meat
	category = "Cakes"

/datum/recipe/cooking/cake_bacon
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 3)
	output = /obj/item/reagent_containers/food/snacks/cake/bacon
	category = "Cakes"

/datum/recipe/cooking/cake_true_bacon
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_true_bacon)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 7)
	output = /obj/item/reagent_containers/food/snacks/cake/true_bacon
	category = "Cakes"

#ifdef XMAS

/datum/recipe/cooking/cake_fruit
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_fruit)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/yuck = 1,
	/obj/item/reagent_containers/food/snacks/yuck/burn = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/fruit_cake
	category = "Cakes"

	get_output(var/list/input_list, var/list/output_list, var/atom/cook_source = null)
		var/fruitcake = new /obj/item/reagent_containers/food/snacks/breadloaf/fruit_cake
		if (cook_source)
			playsound(cook_source.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

		output_list += fruitcake

#endif

/datum/recipe/cooking/cake_custom
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_custom)
	ingredients = list(/obj/item/reagent_containers/food/snacks/cake_batter = 1)
	output = /obj/item/reagent_containers/food/snacks/cake
	category = "Cakes"

	get_output(var/list/input_list, var/list/output_list)

		var/obj/item/reagent_containers/food/snacks/cake_batter/docakeitem = locate() in input_list

		var/obj/item/reagent_containers/food/snacks/S
		if(docakeitem.custom_item)
			S = docakeitem.custom_item
		var/obj/item/reagent_containers/food/snacks/cake/B = new /obj/item/reagent_containers/food/snacks/cake()
		var/image/overlay = new /image('icons/obj/foodNdrink/food_dessert.dmi',"cake1-base_custom")
		B.food_color = S ? S.get_average_color() : "#CC8555"
		overlay.color = B.food_color
		overlay.alpha = 255
		B.AddOverlays(overlay,"first")
		B.cake_bases = list("base_custom")
		if(S)
			B.cake_types += S.type
			S.reagents.trans_to(B, 50)
			B.food_effects += S.food_effects
			if(S.real_name)
				B.name = "[S.real_name] cake"
				for(var/food_effect in S.food_effects)
					if(food_effect in B.food_effects)
						continue
					B.food_effects += food_effect
			else
				B.name = "[S.name] cake"
		else
			B.name = "plain cake"

		B.desc = "Mmm! A delicious-looking [B.name]!"
		output_list += B


/datum/recipe/cooking/cake_custom_item
	recipe_instructions = list(/datum/recipe_instructions/oven/cake_custom_item)
	ingredients = list(/obj/item/reagent_containers/food/snacks/cake/cream = 1)
	output = /obj/item/cake_item
	category = "Cakes"
	wildcard_quantity = 100

	get_output(var/list/input_list, var/list/output_list)

		var/obj/item/cake_item/B = new /obj/item/cake_item()
		for (var/obj/item/I in input_list)
			if (istype(I,/obj/item/cake_item))
				continue
			I.set_loc(B)
			break

		output_list += B
		return TRUE

/datum/recipe/cooking/mix_cake_custom // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/cake_batter = 1)
	output = null
	wildcard_quantity = 100

	get_output(var/list/input_list, var/list/output_list)
		for (var/obj/item/I in input_list)
			if (istype(I, ingredients[1]))
				continue
			else if (istype(I,/obj/item/reagent_containers/food/snacks/))
				var/obj/item/reagent_containers/food/snacks/cake_batter/batter = new

				batter.custom_item = I
				I.set_loc(batter)
				batter.name = "[I:real_name ? I:real_name : I.name] cake batter"
				for (var/obj/M in input_list)
					qdel(M)

				output_list += batter
				return TRUE

		return FALSE


/datum/recipe/cooking/omelette
	recipe_instructions = list(/datum/recipe_instructions/oven/omelette)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/omelette
	variants = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee = /obj/item/reagent_containers/food/snacks/omelette/bee)

/datum/recipe/cooking/pancake_batter // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/ingredient/pancake_batter

/datum/recipe/cooking/pancake
	recipe_instructions = list(/datum/recipe_instructions/oven/pancake)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter = 1)
	output = /obj/item/reagent_containers/food/snacks/pancake

/datum/recipe/cooking/mashedpotatoes // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/potato = 3)
	output = /obj/item/reagent_containers/food/snacks/mashedpotatoes

/datum/recipe/cooking/mashedbrains // mixer
	ingredients = list(/obj/item/organ/brain = 1)
	output = /obj/item/reagent_containers/food/snacks/mashedbrains

/datum/recipe/cooking/meatpaste // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste

/datum/recipe/cooking/soysauce // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/soy = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/soysauce

/datum/recipe/cooking/gravy // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/gravyboat

/datum/recipe/cooking/fishpaste // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/fishpaste

/datum/recipe/cooking/burger/sloppyjoe
	recipe_instructions = list(/datum/recipe_instructions/oven/burger/sloppyjoe)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/sloppyjoe

/datum/recipe/cooking/meatloaf
	recipe_instructions = list(/datum/recipe_instructions/oven/meatloaf)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/breadloaf = 1)
	output = /obj/item/reagent_containers/food/snacks/meatloaf

/datum/recipe/cooking/cereal_box
	recipe_instructions = list(/datum/recipe_instructions/oven/cereal_box)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/chocchips = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box

/datum/recipe/cooking/cereal_honey
	recipe_instructions = list(/datum/recipe_instructions/oven/cereal_honey)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/honey

/datum/recipe/cooking/cereal_tanhony
	recipe_instructions = list(/datum/recipe_instructions/oven/cereal_tanhony)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/tanhony

/datum/recipe/cooking/cereal_roach
	recipe_instructions = list(/datum/recipe_instructions/oven/cereal_roach)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/roach

/datum/recipe/cooking/cereal_syndie
	recipe_instructions = list(/datum/recipe_instructions/oven/cereal_syndie)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/uplink_telecrystal = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/syndie

/datum/recipe/cooking/cereal_flock
	recipe_instructions = list(/datum/recipe_instructions/oven/cereal_flock)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/organ/brain/flockdrone = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/flock

/datum/recipe/cooking/granola_bar
	recipe_instructions = list(/datum/recipe_instructions/oven/granola_bar)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	output = /obj/item/reagent_containers/food/snacks/granola_bar

/datum/recipe/cooking/hardboiled
	recipe_instructions = list(/datum/recipe_instructions/oven/hardboiled)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled

/datum/recipe/cooking/chocolate_egg
	recipe_instructions = list(/datum/recipe_instructions/oven/chocolate_egg)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/chocolate
	wildcard_quantity = 100

	get_output(var/list/input_list, var/list/output_list)
		if (!input_list || !length(input_list))
			output_list += new src.output()
			return TRUE
		for (var/obj/item/item in input_list)
			if (istypes(item, list(src.ingredients[1], src.ingredients[2])))
				continue
			if (item.w_class > W_CLASS_SMALL)
				continue
			var/obj/item/reagent_containers/food/snacks/ingredient/egg/chocolate/choc_egg = new()
			choc_egg.AddComponent(/datum/component/contraband, 1) //illegal unsafe dangerous egg
			item.set_loc(choc_egg)
			output_list += choc_egg
			return TRUE

/datum/recipe/cooking/eggsalad
	recipe_instructions = list(/datum/recipe_instructions/oven/eggsalad)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1,
	/obj/item/reagent_containers/food/snacks/salad = 1,
	/obj/item/reagent_containers/food/snacks/condiment/mayo = 1)
	output = /obj/item/reagent_containers/food/snacks/eggsalad

/datum/recipe/cooking/biscuit
	recipe_instructions = list(/datum/recipe_instructions/oven/biscuit)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/reagent_containers/food/snacks/biscuit

/datum/recipe/cooking/dog_biscuit
	recipe_instructions = list(/datum/recipe_instructions/oven/dog_biscuit)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/granola_bar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/dog

/datum/recipe/cooking/hardtack
	recipe_instructions = list(/datum/recipe_instructions/oven/hardtack)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ironfilings = 1)
	output = /obj/item/reagent_containers/food/snacks/hardtack

/datum/recipe/cooking/macguffin
	recipe_instructions = list(/datum/recipe_instructions/oven/macguffin)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/emuffin = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/macguffin

/datum/recipe/cooking/haggis
	recipe_instructions = list(/datum/recipe_instructions/oven/haggis)
	ingredients = list(\
	/obj/item/organ = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/haggis

/datum/recipe/cooking/haggass
	recipe_instructions = list(/datum/recipe_instructions/oven/haggass)
	ingredients = list(\
	/obj/item/clothing/head/butt = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/haggis/ass

/datum/recipe/cooking/scotch_egg
	recipe_instructions = list(/datum/recipe_instructions/oven/scotch_egg)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/scotch_egg

/datum/recipe/cooking/rice_ball
	recipe_instructions = list(/datum/recipe_instructions/oven/rice_ball)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	output = /obj/item/reagent_containers/food/snacks/rice_ball

/datum/recipe/cooking/nigiri_roll
	recipe_instructions = list(/datum/recipe_instructions/oven/nigiri_roll)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice = 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 1)
	output = /obj/item/reagent_containers/food/snacks/nigiri_roll

/datum/recipe/cooking/sushi_roll
	recipe_instructions = list(/datum/recipe_instructions/oven/sushi_roll)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet= 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1)
	output = /obj/item/reagent_containers/food/snacks/sushi_roll

/datum/recipe/cooking/riceandbeans
	recipe_instructions = list(/datum/recipe_instructions/oven/riceandbeans)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bean = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	output = /obj/item/reagent_containers/food/snacks/riceandbeans

/datum/recipe/cooking/friedrice
	recipe_instructions = list(/datum/recipe_instructions/oven/friedrice)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/friedrice

/datum/recipe/cooking/omurice
	recipe_instructions = list(/datum/recipe_instructions/oven/omurice)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/omurice

/datum/recipe/cooking/risotto
	recipe_instructions = list(/datum/recipe_instructions/oven/risotto)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/risotto

/datum/recipe/cooking/tandoorichicken
	recipe_instructions = list(/datum/recipe_instructions/oven/tandoorichicken)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/tandoorichicken

/datum/recipe/cooking/potatocurry
	recipe_instructions = list(/datum/recipe_instructions/oven/potatocurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/plant/potato = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/peas = 1)
	output = /obj/item/reagent_containers/food/snacks/potatocurry

/datum/recipe/cooking/coconutcurry
	recipe_instructions = list(/datum/recipe_instructions/oven/coconutcurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	output = /obj/item/reagent_containers/food/snacks/coconutcurry

/datum/recipe/cooking/chickenpineapplecurry
	recipe_instructions = list(/datum/recipe_instructions/oven/chickenpineapplecurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1)
	output = /obj/item/reagent_containers/food/snacks/chickenpineapplecurry

/datum/recipe/cooking/ramen_bowl
	recipe_instructions = list(/datum/recipe_instructions/oven/ramen_bowl)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/ramen = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1)
	output = /obj/item/reagent_containers/food/snacks/ramen_bowl

/datum/recipe/cooking/udon_bowl
	recipe_instructions = list(/datum/recipe_instructions/oven/udon_bowl)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/kamaboko = 1)
	output = /obj/item/reagent_containers/food/snacks/udon_bowl

/datum/recipe/cooking/curry_udon_bowl
	recipe_instructions = list(/datum/recipe_instructions/oven/curry_udon_bowl)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1)
	output = /obj/item/reagent_containers/food/snacks/curry_udon_bowl

/datum/recipe/cooking/mapo_tofu
	recipe_instructions = list(/datum/recipe_instructions/oven/mapo_tofu)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/soy = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/mapo_tofu_meat
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = /obj/item/reagent_containers/food/snacks/mapo_tofu_synth)

/datum/recipe/cooking/cheesewheel
	recipe_instructions = list(/datum/recipe_instructions/oven/cheesewheel)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/cheese = 2)
	output = /obj/item/reagent_containers/food/snacks/cheesewheel

/datum/recipe/cooking/ratatouille
	recipe_instructions = list(/datum/recipe_instructions/oven/ratatouille)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1,
	/obj/item/reagent_containers/food/snacks/plant/tomato = 1,
	/obj/item/reagent_containers/food/snacks/plant/eggplant = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/ratatouille

/datum/recipe/cooking/churro
	recipe_instructions = list(/datum/recipe_instructions/oven/churro)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_strip = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/dippable/churro

/datum/recipe/cooking/french_toast
	recipe_instructions = list(/datum/recipe_instructions/oven/french_toast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/drinks/milk = 1)
	output = /obj/item/reagent_containers/food/snacks/french_toast

/datum/recipe/cooking/zongzi
	recipe_instructions = list(/datum/recipe_instructions/oven/zongzi)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bamboo = 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/zongzi

/datum/recipe/cooking/beefood
	recipe_instructions = list(/datum/recipe_instructions/oven/beefood)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/plant/wheat = 1,
	/obj/item/reagent_containers/food/snacks/yuck = 1)
	output = /obj/item/reagent_containers/food/snacks/beefood

/datum/recipe/cooking/b_cupcake
	recipe_instructions = list(/datum/recipe_instructions/oven/b_cupcake)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/beefood = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/royal_jelly = 1,
	/obj/item/device/light/candle/small = 1)
	output = /obj/item/reagent_containers/food/snacks/b_cupcake

	get_output(var/list/input_list, var/list/output_list)

		var/obj/item/reagent_containers/food/snacks/b_cupcake = new /obj/item/reagent_containers/food/snacks/b_cupcake

		b_cupcake.desc = "A little birthday cupcake for a bee. May not taste good to non-bees."
		var/icon/I = new /icon('icons/obj/foodNdrink/food_dessert.dmi',"b_cupcake")
		var/random_color = rgb(rand(1,255), rand(1,255), rand(1,255))
		I.Blend(random_color, ICON_ADD)
		b_cupcake.icon = I

		output_list += b_cupcake

/datum/recipe/cooking/butters // mixer
	ingredients = list(\
	/obj/item/clothing/head/butt = 1,
	/obj/item/reagent_containers/food/drinks/milk = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/butters

/datum/recipe/cooking/lipstick
	recipe_instructions = list(/datum/recipe_instructions/oven/lipstick)
	ingredients = list(\
	/obj/item/pen/crayon = 1,
	/obj/item/item_box/figure_capsule = 1)
	output = /obj/item/pen/crayon/lipstick

	get_output(var/list/input_list, var/list/output_list)
		var/obj/item/pen/crayon/lipstick/lipstick = new /obj/item/pen/crayon/lipstick
		for (var/obj/item/pen/crayon/C in input_list)
			lipstick.font_color = C.font_color
			lipstick.color_name = hex2color_name(lipstick.font_color)
			lipstick.name = "[lipstick.color_name] lipstick"
			lipstick.UpdateIcon()
		output_list += lipstick

/datum/recipe/cooking/melted_sugar
	recipe_instructions = list(/datum/recipe_instructions/oven/melted_sugar)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/plate/tray = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/melted_sugar

/datum/recipe/cooking/brownie_batter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/brownie_batter

/datum/recipe/cooking/brownie_batch
	recipe_instructions = list(/datum/recipe_instructions/oven/brownie_batch)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/brownie_batter = 1)
	output = /obj/item/reagent_containers/food/snacks/dessert_batch/brownie

/datum/recipe/cooking/flapjack_batch
	recipe_instructions = list(/datum/recipe_instructions/oven/flapjack_batch)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 1) //technically this should be GOLDEN syrup but this works too
	output = /obj/item/reagent_containers/food/snacks/dessert_batch/flapjack

/datum/recipe/cooking/rice_bowl
	recipe_instructions = list(/datum/recipe_instructions/oven/rice_bowl)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1)
	output = /obj/item/reagent_containers/food/snacks/rice_bowl

/datum/recipe/cooking/egg_on_rice
	recipe_instructions = list(/datum/recipe_instructions/oven/egg_on_rice)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1)
	output = /obj/item/reagent_containers/food/snacks/egg_on_rice

/datum/recipe/cooking/katsudon_bacon
	recipe_instructions = list(/datum/recipe_instructions/oven/katsudon_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/breadcrumbs = 1)
	output = /obj/item/reagent_containers/food/snacks/katsudon

/datum/recipe/cooking/katsudon_chicken
	recipe_instructions = list(/datum/recipe_instructions/oven/katsudon_chicken)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/breadcrumbs = 1)
	output = /obj/item/reagent_containers/food/snacks/katsudon

/datum/recipe/cooking/gyudon
	recipe_instructions = list(/datum/recipe_instructions/oven/gyudon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/onion_slice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/gyudon

/datum/recipe/cooking/cheese_gyudon
	recipe_instructions = list(/datum/recipe_instructions/oven/cheese_gyudon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/onion_slice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/cheese_gyudon

/datum/recipe/cooking/miso_soup
	recipe_instructions = list(/datum/recipe_instructions/oven/miso_soup)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/plant/soy = 1)
	output = /obj/item/reagent_containers/food/snacks/miso_soup

/datum/recipe/cooking/bibimbap
	recipe_instructions = list(/datum/recipe_instructions/oven/bibimbap)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1,
	/obj/item/reagent_containers/food/snacks/plant/lettuce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/bibimbap

/datum/recipe/cooking/katsu_curry
	recipe_instructions = list(/datum/recipe_instructions/oven/katsu_curry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/breadcrumbs = 1)
	output = /obj/item/reagent_containers/food/snacks/katsu_curry

/datum/recipe/cooking/flan
	recipe_instructions = list(/datum/recipe_instructions/oven/flan)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/raw_flan = 1)
	output = /obj/item/reagent_containers/food/snacks/flan
