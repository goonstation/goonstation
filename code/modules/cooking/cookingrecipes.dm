/datum/recipe/spicychickensandwich
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	category = "Burgers"
	recipe_instructions = list(\
	/datum/recipe_instructions/cooking/oven/sandwich)

/datum/recipe/chickensandwich
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/chicken
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/spicy = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy, //:melterfrog:
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock = /obj/item/reagent_containers/food/snacks/burger/flockburger)
	category = "Burgers"
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich)

ABSTRACT_TYPE(/datum/recipe/burger)
/datum/recipe/burger
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

/datum/recipe/burger/meat
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/burger_meat)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/burger
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug = /obj/item/reagent_containers/food/snacks/burger/slugburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = /obj/item/reagent_containers/food/snacks/burger/fishburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = /obj/item/reagent_containers/food/snacks/burger/humanburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = /obj/item/reagent_containers/food/snacks/burger/monkeyburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = /obj/item/reagent_containers/food/snacks/burger/synthburger,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat = /obj/item/reagent_containers/food/snacks/burger/mysteryburger)

/datum/recipe/burger/cheeseburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/cheeseburger)

/datum/recipe/burger/cheeseburger/monkey
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger_m

/datum/recipe/burger/wcheeseburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/gcheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/wcheeseburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/wcheeseburger)

/datum/recipe/burger/luauburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/luauburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/luauburger)

/datum/recipe/burger/coconutburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/coconutburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/coconutburger)

/datum/recipe/burger/tikiburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/tikiburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/tikiburger)

/datum/recipe/burger/buttburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/clothing/head/butt = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/buttburger
	variants = list(\
	/obj/item/clothing/head/butt/synth = /obj/item/reagent_containers/food/snacks/burger/buttburger/synth,
	/obj/item/clothing/head/butt/cyberbutt = /obj/item/reagent_containers/food/snacks/burger/buttburger/cyber)
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/buttburger)

/datum/recipe/burger/heartburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/heart = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger
	variants = list(\
	/obj/item/organ/heart/flock = /obj/item/reagent_containers/food/snacks/burger/heartburger/flock,
	/obj/item/organ/heart/cyber = /obj/item/reagent_containers/food/snacks/burger/heartburger/cyber,
	/obj/item/organ/heart/synth = /obj/item/reagent_containers/food/snacks/burger/heartburger/synth)
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/heartburger)

/datum/recipe/burger/brainburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/brain = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger
	variants = list(\
	/obj/item/organ/brain/synth = /obj/item/reagent_containers/food/snacks/burger/brainburger/synth,
	/obj/item/organ/brain/latejoin = /obj/item/reagent_containers/food/snacks/burger/brainburger/cyber,
	/obj/item/organ/brain/flockdrone = /obj/item/reagent_containers/food/snacks/burger/brainburger/flock)
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/brainburger)

/datum/recipe/burger/roburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/parts/robot_parts/head = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/roburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/roburger)

/datum/recipe/burger/cheeseborger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/parts/robot_parts/head = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseborger

/datum/recipe/burger/baconburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/baconburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger)

/datum/recipe/burger/baconator
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/burger/bigburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger)

/datum/recipe/burger/butterburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/butterburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger)

/datum/recipe/burger/aburgination
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/aburgination
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger)

/datum/recipe/burger/monster
	ingredients = list(/obj/item/reagent_containers/food/snacks/burger/bigburger = 4)
	output = /obj/item/reagent_containers/food/snacks/burger/monsterburger
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger)

/datum/recipe/swede_mball
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/meatball = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/swedishmeatball
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/swede_mball)

/datum/recipe/donkpocket
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1)
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/donkpocket)
	variants = list(\
	/obj/item/instrument/bikehorn = /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm)

/datum/recipe/donkpocket2
	ingredients = list(/obj/item/reagent_containers/food/snacks/donkpocket = 1)
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/donkpocket)
	variants = list(\
	/obj/item/reagent_containers/food/snacks/donkpocket/honk = /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm)

/datum/recipe/donut
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_circle = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/donut
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/donut)

/datum/recipe/bagel
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough_circle = 1)
	output = /obj/item/reagent_containers/food/snacks/bagel
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bagel)

/datum/recipe/crumpet //another good idea for this is to cook a trumpet
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/holey_dough = 1)
	output = /obj/item/reagent_containers/food/snacks/crumpet
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/crumpet)

/datum/recipe/ice_cream_cone
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/ice_cream_cone
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/ice_cream_cone)

/datum/recipe/nougat
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/candy/nougat
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/nougat)

/datum/recipe/candy_cane
	ingredients = list(\
	/obj/item/plant/herb/mint = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/candy/candy_cane

/datum/recipe/waffles
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1)
	output = /obj/item/reagent_containers/food/snacks/waffles

/datum/recipe/spaghetti_p
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/spaghetti_p)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti
	category = "Pasta"

/datum/recipe/spaghetti_t
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/spaghetti_t)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/sauce
	category = "Pasta"

/datum/recipe/spaghetti_s
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/spaghetti_s)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/spicy
	category = "Pasta"

/datum/recipe/spaghetti_m
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/spaghetti_m)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/meatball
	category = "Pasta"

/datum/recipe/lasagna
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/lasagna)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/lasagna
	category = "Pasta"

/datum/recipe/alfredo
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/alfredo)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/alfredo
	category = "Pasta"

/datum/recipe/chickenparm
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chickenparm)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/chickenparm
	category = "Pasta"

/datum/recipe/chickenalfredo
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chickenalfredo)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/chickenalfredo
	category = "Pasta"

/datum/recipe/spaghetti_pg
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/spaghetti_pg)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/pizza = 1)
	output = /obj/item/reagent_containers/food/snacks/spaghetti/pizzaghetti
	category = "Pasta"

/datum/recipe/spooky_bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/spooky
	category = "Bread"

/datum/recipe/elvis_bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/elvis
	category = "Bread"

/datum/recipe/banana_bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/recipe/banana_bread_alt
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/recipe/cornbread1
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn
	category = "Bread"

/datum/recipe/cornbread2
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/recipe/cornbread3
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/recipe/cornbread4
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cornbread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet/honey
	category = "Bread"

/datum/recipe/pumpkin_bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/pumpkin = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/pumpkin
	category = "Bread"

/datum/recipe/bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bread)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf
	category = "Bread"

/datum/recipe/honeywheat_bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	category = "Bread"

/datum/recipe/brain_bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/brain_bread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf = 1,
	/obj/item/organ/brain = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/brain
	category = "Bread"

/datum/recipe/toast_bread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/toast_bread)
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadloaf = 1)
	output = /obj/item/reagent_containers/food/snacks/breadloaf/toast
	category = "Bread"

/datum/recipe/toast
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/toast)
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice = 1)
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/banana = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/banana,
	/obj/item/reagent_containers/food/snacks/breadslice/brain = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/brain,
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/elvis,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/spooky,
	/obj/item/reagent_containers/food/snacks/breadslice/french = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/french)
	category = "Toast"

ABSTRACT_TYPE(/datum/recipe/sandwich)
/datum/recipe/sandwich
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich)
	variant_quantity = 2
	category = "Sandwich"

/datum/recipe/sandwich/human
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich/human)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_h
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_h,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_h)

/datum/recipe/sandwich/monkey
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_m
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_m,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_m)


/datum/recipe/sandwich/synth
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_s
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_s,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_s)

/datum/recipe/sandwich/cheese
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	output = /obj/item/reagent_containers/food/snacks/sandwich/cheese
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_cheese,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_cheese)

/datum/recipe/sandwich/peanutbutter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/pb
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pb,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pb)


/datum/recipe/sandwich/peanutbutter_honey
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/pbh
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pbh,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pbh)

/datum/recipe/sandwich/blt
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon= 1,
	/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/lettuce = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/blt
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/sandwich/elvis_blt,
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = /obj/item/reagent_containers/food/snacks/sandwich/spooky_blt)

/datum/recipe/sandwich/c_butty
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/fries = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/c_butty

/datum/recipe/sandwich/meatball //Original meatball sub recipe
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich/meatball)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball

/datum/recipe/sandwich/meatball_alt //Secondary recipe that uses the baguette
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich/meatball)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball

/datum/recipe/sandwich/egg
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/eggsalad = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/eggsalad

/datum/recipe/sandwich/bahnmi //Original banh mi recipe
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich/bahnmi)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf/honeywheat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi

/datum/recipe/sandwich/bahnmi_alt //Secondary recipe that uses the baguette
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich/bahnmi)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1)
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi

/datum/recipe/sandwich/custom
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sandwich/custom)
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
			customSandwich.reagents.add_reagent("yorkshire_sauce", 25)
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

/datum/recipe/pizza_custom
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pizza_custom)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pizza_base = 1)
	output = /obj/item/reagent_containers/food/snacks/pizza/bespoke
	category = "Pizza"

	get_output(var/list/input_list, var/list/output_list)
		for (var/obj/item/reagent_containers/food/snacks/ingredient/pizza_base/P in input_list)
			output_list += P.bake_pizza()
		return TRUE

/datum/recipe/cheesetoast
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cheesetoast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/toastcheese
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/toastcheese/elvis)
	category = "Toast (Meal)"


/datum/recipe/bacontoast
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bacontoast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/toastbacon
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/toastbacon/elvis)
	category = "Toast (Meal)"

/datum/recipe/eggtoast
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/eggtoast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/toastegg
	variants = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = /obj/item/reagent_containers/food/snacks/toastegg/elvis)
	category = "Toast (Meal)"

/datum/recipe/breakfast
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/breakfast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/breakfast

/datum/recipe/wonton_wrapper // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/reagent_containers/food/snacks/wonton_spawner

/datum/recipe/taco_shell
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/taco_shell)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/tortilla = 1)
	output = /obj/item/reagent_containers/food/snacks/taco

/datum/recipe/eggnog
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/eggnog)
	ingredients = list(\
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 3)
	output = /obj/item/reagent_containers/food/drinks/eggnog

// Pastries and bread-likes

/datum/recipe/baguette
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/baguette)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_strip = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/baguette
	category = "Pastries and bread-likes" // not sorry

/datum/recipe/garlicbread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/garlicbread)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/garlicbread
	category = "Pastries and bread-likes"

/datum/recipe/garlicbread_ch
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/garlicbread_ch)
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/garlicbread_ch
	category = "Pastries and bread-likes"

/datum/recipe/painauchocolat
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/painauchocolat)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1)
	output = /obj/item/reagent_containers/food/snacks/painauchocolat
	category = "Pastries and bread-likes"

/datum/recipe/croissant
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/croissant)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/croissant
	category = "Pastries and bread-likes"

/datum/recipe/danish_apple
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/danish_apple)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/apple = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_apple
	category = "Pastries and bread-likes"

/datum/recipe/danish_cherry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/danish_cherry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_cherry
	category = "Pastries and bread-likes"

/datum/recipe/danish_blueb
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/danish_blueb)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/blueberry = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_blueb
	category = "Pastries and bread-likes"

/datum/recipe/danish_weed
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/danish_weed)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/plant/herb/cannabis = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_weed
	category = "Pastries and bread-likes"

/datum/recipe/danish_cheese
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/danish_cheese)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/danish_cheese
	category = "Pastries and bread-likes"

/datum/recipe/fairybread
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/fairybread)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/fairybread
	category = "Pastries and bread-likes"

/datum/recipe/cinnamonbun
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cinnamonbun)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/cinnamon = 1)
	output = /obj/item/reagent_containers/food/snacks/cinnamonbun
	category = "Pastries and bread-likes"

/datum/recipe/chocolate_cherry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chocolate_cherry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/chocolate_cherry

//Cookies
/datum/recipe/stroopwafel
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/stroopwafel)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 2,
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 1)
	output = /obj/item/reagent_containers/food/snacks/stroopwafel
	category = "Cookies"

/datum/recipe/cookie
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie
	category = "Cookies"

/datum/recipe/cookie_iron
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_iron)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ironfilings = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/metal
	category = "Cookies"

/datum/recipe/cookie_chocolate_chip
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_chocolate_chip)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/condiment/chocchips = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	category = "Cookies"

/datum/recipe/cookie_oatmeal
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_oatmeal)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/oatmeal
	category = "Cookies"

/datum/recipe/cookie_bacon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/bacon
	category = "Cookies"

/datum/recipe/cookie_jaffa
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_jaffa)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/plant/orange = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/jaffa
	category = "Cookies"

/datum/recipe/cookie_spooky
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_spooky)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/spooky
	category = "Cookies"

/datum/recipe/cookie_butter
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_butter)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/butter
	category = "Cookies"

/datum/recipe/cookie_peanut
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cookie_peanut)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/peanut
	category = "Cookies"

//Moon pies!
/datum/recipe/moon_pie
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/moon_pie)
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

/datum/recipe/moon_pie_chocolate
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/moon_pie_chocolate)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/chocolate_chip = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate
	category = "Moon Pies"

/datum/recipe/onionchips
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/onionchips)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/onion_slice = 2,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/onionchips

/datum/recipe/fries
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/fries)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/chips = 1)
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/recipe/chilifries
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chilifries)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/fries = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries

/datum/recipe/chilifries_alt
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chilifries_alt) //Secondary recipe for chili cheese fries
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/chips = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries

/datum/recipe/poutine
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/poutine)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/fries = 1,
	/obj/item/reagent_containers/food/snacks/condiment/gravyboat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries/poutine

/datum/recipe/poutine_alt
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/poutine_alt)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/chips = 1,
	/obj/item/reagent_containers/food/snacks/condiment/gravyboat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	output = /obj/item/reagent_containers/food/snacks/chilifries/poutine

/datum/recipe/bakedpotato
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bakedpotato)
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/potato = 1)
	output = /obj/item/reagent_containers/food/snacks/bakedpotato

/datum/recipe/hotdog
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/hotdog)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1)
	output = /obj/item/reagent_containers/food/snacks/hotdog

/datum/recipe/cook_meat//Very jank, will need future work.
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cook_meat)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/steak
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = /obj/item/reagent_containers/food/snacks/steak/human,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = /obj/item/reagent_containers/food/snacks/steak/synth,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = /obj/item/reagent_containers/food/snacks/steak/monkey,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/sheep = /obj/item/reagent_containers/food/snacks/steak/sheep,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = /obj/item/reagent_containers/food/snacks/fish_fingers,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug = /obj/item/cocktail_stuff/eyestalk)

/datum/recipe/steak_ling
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/steak_ling)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling = 1)
	output = /obj/item/reagent_containers/food/snacks/steak/ling

/datum/recipe/shrimp
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/shrimp)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/shrimp = 1)
	output = /obj/item/reagent_containers/food/snacks/shrimp

/datum/recipe/bacon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bacon)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon

/datum/recipe/turkey
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/turkey)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/turkey = 1)
	output = /obj/item/reagent_containers/food/snacks/turkey

/datum/recipe/pie_strawberry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_strawberry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/strawberry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/strawberry
	category = "Pies"

/datum/recipe/pie_cherry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_cherry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/cherry
	category = "Pies"

/datum/recipe/pie_blueberry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_blueberry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/blueberry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/blueberry
	category = "Pies"

/datum/recipe/pie_raspberry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_raspberry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/raspberry = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/raspberry
	variants = list(\
	/obj/item/reagent_containers/food/snacks/plant/raspberry/blackberry = /obj/item/reagent_containers/food/snacks/pie/blackberry)
	category = "Pies"

/datum/recipe/pie_apple
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_apple)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/apple = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/apple
	category = "Pies"

/datum/recipe/pie_lime
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_lime)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/lime = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/lime
	category = "Pies"

/datum/recipe/pie_lemon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_lemon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/lemon = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/lemon
	category = "Pies"

/datum/recipe/pie_slurry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_slurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/slurryfruit = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/slurry
	category = "Pies"

/datum/recipe/pie_pumpkin
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_pumpkin)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/pumpkin = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/pumpkin
	category = "Pies"

/datum/recipe/pie_chocolate
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_chocolate)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/chocolate
	category = "Pies"

/datum/recipe/pie_anything/pie_cream
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_anything/pie_cream)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/cream
	category = "Pies"
	base_pie_name = "cream pie"

/datum/recipe/pie_anything
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_anything)
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

/datum/recipe/pie_custard
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_custard)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/custard = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/custard
	category = "Pies"

/datum/recipe/pie_bacon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/bacon
	category = "Pies"

/datum/recipe/pie_ass
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_ass)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/clothing/head/butt = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/ass
	category = "Pies"

/datum/recipe/pot_pie
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pot_pie)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/pot
	category = "Pies"

/datum/recipe/pie_weed
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_weed)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/plant/herb/cannabis = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/weed
	category = "Pies"

/datum/recipe/pie_fish
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pie_fish)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1,
	/obj/item/reagent_containers/food/snacks/plant/potato = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/fish
	category = "Pies"

/datum/recipe/raw_flan // mixer
	ingredients = list(\
		/obj/item/reagent_containers/food/snacks/ingredient/vanilla_extract = 1,
		/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
		/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
		/obj/item/reagent_containers/food/drinks/milk = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/raw_flan

/datum/recipe/custard // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/custard

/datum/recipe/gruel // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/yuck = 3)
	output = /obj/item/reagent_containers/food/snacks/soup/gruel

/datum/recipe/porridge
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/porridge)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/rice = 2)
	output = /obj/item/reagent_containers/food/snacks/soup/porridge

/datum/recipe/oatmeal
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/oatmeal)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/oatmeal

/datum/recipe/tomsoup
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/tomsoup)
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/tomato = 2)
	output = /obj/item/reagent_containers/food/snacks/soup/tomato

/datum/recipe/mint_chutney
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/mint_chutney)
	ingredients = list(\
	/obj/item/plant/herb/mint = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/mint_chutney

/datum/recipe/refried_beans
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/refried_beans)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bean = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/refried_beans

/datum/recipe/chili
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chili)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/chili

/datum/recipe/queso
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/queso)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/queso

/datum/recipe/superchili
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/superchili)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 2)
	output = /obj/item/reagent_containers/food/snacks/soup/superchili

/datum/recipe/ultrachili
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/ultrachili)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/soup/chili = 1,
	/obj/item/reagent_containers/food/snacks/soup/superchili = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/ultrachili

/datum/recipe/salad
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/salad)
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/lettuce = 2)
	output = /obj/item/reagent_containers/food/snacks/salad

/datum/recipe/creamofmushroom
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/creamofmushroom)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/mushroom = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom
	variants = list(\
	/obj/item/reagent_containers/food/snacks/mushroom/psilocybin = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/psilocybin,
	/obj/item/reagent_containers/food/snacks/mushroom/amanita = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/amanita)

//Delightful Halloween Recipes
/datum/recipe/candy_apple
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/candy_apple)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/apple/stick = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple
	variants = list(\
	/obj/item/reagent_containers/food/snacks/plant/apple/stick/poison = /obj/item/reagent_containers/food/snacks/candy/candy_apple/poison)

//Cakes!
/datum/recipe/cake_batter // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/cake_batter

/datum/recipe/cake_cream
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_cream)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	output = /obj/item/reagent_containers/food/snacks/cake/cream
	category = "Cakes"

/datum/recipe/cake_chocolate
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_chocolate)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/cake/chocolate
	category = "Cakes"

/datum/recipe/cake_meat
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_meat)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/cake/meat
	category = "Cakes"

/datum/recipe/cake_bacon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 3)
	output = /obj/item/reagent_containers/food/snacks/cake/bacon
	category = "Cakes"

/datum/recipe/cake_true_bacon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_true_bacon)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 7)
	output = /obj/item/reagent_containers/food/snacks/cake/true_bacon
	category = "Cakes"

#ifdef XMAS

/datum/recipe/cake_fruit
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_fruit)
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

/datum/recipe/cake_custom
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_custom)
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


/datum/recipe/cake_custom_item
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cake_custom_item)
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

/datum/recipe/mix_cake_custom // mixer
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


/datum/recipe/omelette
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/omelette)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	output = /obj/item/reagent_containers/food/snacks/omelette
	variants = list(/obj/item/reagent_containers/food/snacks/ingredient/egg/bee = /obj/item/reagent_containers/food/snacks/omelette/bee)

/datum/recipe/pancake_batter // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	output = /obj/item/reagent_containers/food/snacks/ingredient/pancake_batter

/datum/recipe/pancake
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/pancake)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter = 1)
	output = /obj/item/reagent_containers/food/snacks/pancake

/datum/recipe/mashedpotatoes // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/potato = 3)
	output = /obj/item/reagent_containers/food/snacks/mashedpotatoes

/datum/recipe/mashedbrains // mixer
	ingredients = list(/obj/item/organ/brain = 1)
	output = /obj/item/reagent_containers/food/snacks/mashedbrains

/datum/recipe/meatpaste // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste

/datum/recipe/soysauce // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/soy = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/soysauce

/datum/recipe/gravy // mixer
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/gravyboat

/datum/recipe/fishpaste // mixer
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/fishpaste

/datum/recipe/burger/sloppyjoe
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/burger/sloppyjoe)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1)
	output = /obj/item/reagent_containers/food/snacks/burger/sloppyjoe

/datum/recipe/meatloaf
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/meatloaf)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/breadloaf = 1)
	output = /obj/item/reagent_containers/food/snacks/meatloaf

/datum/recipe/cereal_box
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cereal_box)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/chocchips = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box

/datum/recipe/cereal_honey
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cereal_honey)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/honey

/datum/recipe/cereal_tanhony
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cereal_tanhony)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/tanhony

/datum/recipe/cereal_roach
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cereal_roach)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/roach

/datum/recipe/cereal_syndie
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cereal_syndie)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/uplink_telecrystal = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/syndie

/datum/recipe/cereal_flock
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cereal_flock)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/organ/brain/flockdrone = 1)
	output = /obj/item/reagent_containers/food/snacks/cereal_box/flock

/datum/recipe/granola_bar
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/granola_bar)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	output = /obj/item/reagent_containers/food/snacks/granola_bar

/datum/recipe/hardboiled
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/hardboiled)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled

/datum/recipe/chocolate_egg
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chocolate_egg)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/chocolate
	wildcard_quantity = 100

	get_output(var/list/input_list, var/list/output_list)
		for (var/obj/item/item in input_list)
			if (istypes(item, list(src.ingredients[1], src.ingredients[2])))
				continue
			if (item.w_class > W_CLASS_SMALL)
				continue
			var/obj/item/reagent_containers/food/snacks/ingredient/egg/chocolate/choc_egg = new()
			choc_egg.AddComponent(/datum/component/contraband, 1) //illegal unsafe dangerous egg
			item.set_loc(choc_egg)
			output_list += choc_egg
		if (!length(output_list))
			return ..()

/datum/recipe/eggsalad
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/eggsalad)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1,
	/obj/item/reagent_containers/food/snacks/salad = 1,
	/obj/item/reagent_containers/food/snacks/condiment/mayo = 1)
	output = /obj/item/reagent_containers/food/snacks/eggsalad

/datum/recipe/biscuit
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/biscuit)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	output = /obj/item/reagent_containers/food/snacks/biscuit

/datum/recipe/dog_biscuit
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/dog_biscuit)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/granola_bar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	output = /obj/item/reagent_containers/food/snacks/cookie/dog

/datum/recipe/hardtack
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/hardtack)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ironfilings = 1)
	output = /obj/item/reagent_containers/food/snacks/hardtack

/datum/recipe/macguffin
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/macguffin)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/emuffin = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/macguffin

/datum/recipe/haggis
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/haggis)
	ingredients = list(\
	/obj/item/organ = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/haggis

/datum/recipe/haggass
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/haggass)
	ingredients = list(\
	/obj/item/clothing/head/butt = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/haggis/ass

/datum/recipe/scotch_egg
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/scotch_egg)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	output = /obj/item/reagent_containers/food/snacks/scotch_egg

/datum/recipe/rice_ball
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/rice_ball)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	output = /obj/item/reagent_containers/food/snacks/rice_ball

/datum/recipe/nigiri_roll
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/nigiri_roll)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice = 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 1)
	output = /obj/item/reagent_containers/food/snacks/nigiri_roll

/datum/recipe/sushi_roll
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/sushi_roll)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet= 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1)
	output = /obj/item/reagent_containers/food/snacks/sushi_roll

/datum/recipe/riceandbeans
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/riceandbeans)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bean = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	output = /obj/item/reagent_containers/food/snacks/riceandbeans

/datum/recipe/friedrice
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/friedrice)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/friedrice

/datum/recipe/omurice
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/omurice)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	output = /obj/item/reagent_containers/food/snacks/omurice

/datum/recipe/risotto
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/risotto)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/risotto

/datum/recipe/tandoorichicken
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/tandoorichicken)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/tandoorichicken

/datum/recipe/potatocurry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/potatocurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/plant/potato = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/peas = 1)
	output = /obj/item/reagent_containers/food/snacks/potatocurry

/datum/recipe/coconutcurry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/coconutcurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	output = /obj/item/reagent_containers/food/snacks/coconutcurry

/datum/recipe/chickenpineapplecurry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/chickenpineapplecurry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1)
	output = /obj/item/reagent_containers/food/snacks/chickenpineapplecurry

/datum/recipe/ramen_bowl
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/ramen_bowl)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/ramen = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1)
	output = /obj/item/reagent_containers/food/snacks/ramen_bowl

/datum/recipe/udon_bowl
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/udon_bowl)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/kamaboko = 1)
	output = /obj/item/reagent_containers/food/snacks/udon_bowl

/datum/recipe/curry_udon_bowl
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/curry_udon_bowl)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1)
	output = /obj/item/reagent_containers/food/snacks/curry_udon_bowl

/datum/recipe/mapo_tofu
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/mapo_tofu)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/soy = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	output = /obj/item/reagent_containers/food/snacks/mapo_tofu_meat
	variants = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = /obj/item/reagent_containers/food/snacks/mapo_tofu_synth)

/datum/recipe/cheesewheel
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cheesewheel)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/cheese = 2)
	output = /obj/item/reagent_containers/food/snacks/cheesewheel

/datum/recipe/ratatouille
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/ratatouille)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1,
	/obj/item/reagent_containers/food/snacks/plant/tomato = 1,
	/obj/item/reagent_containers/food/snacks/plant/eggplant = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	output = /obj/item/reagent_containers/food/snacks/ratatouille

/datum/recipe/churro
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/churro)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_strip = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	output = /obj/item/reagent_containers/food/snacks/dippable/churro

/datum/recipe/french_toast
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/french_toast)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/drinks/milk = 1)
	output = /obj/item/reagent_containers/food/snacks/french_toast

/datum/recipe/zongzi
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/zongzi)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bamboo = 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/zongzi

/datum/recipe/beefood
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/beefood)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/plant/wheat = 1,
	/obj/item/reagent_containers/food/snacks/yuck = 1)
	output = /obj/item/reagent_containers/food/snacks/beefood

/datum/recipe/b_cupcake
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/b_cupcake)
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

/datum/recipe/butters // mixer
	ingredients = list(\
	/obj/item/clothing/head/butt = 1,
	/obj/item/reagent_containers/food/drinks/milk = 1)
	output = /obj/item/reagent_containers/food/snacks/condiment/butters

/datum/recipe/lipstick
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/lipstick)
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

/datum/recipe/melted_sugar
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/melted_sugar)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/plate/tray = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/melted_sugar

/datum/recipe/brownie_batter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	output = /obj/item/reagent_containers/food/snacks/ingredient/brownie_batter

/datum/recipe/brownie_batch
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/brownie_batch)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/brownie_batter = 1)
	output = /obj/item/reagent_containers/food/snacks/dessert_batch/brownie

/datum/recipe/flapjack_batch
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/flapjack_batch)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 1) //technically this should be GOLDEN syrup but this works too
	output = /obj/item/reagent_containers/food/snacks/dessert_batch/flapjack

/datum/recipe/rice_bowl
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/rice_bowl)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1)
	output = /obj/item/reagent_containers/food/snacks/rice_bowl

/datum/recipe/egg_on_rice
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/egg_on_rice)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1)
	output = /obj/item/reagent_containers/food/snacks/egg_on_rice

/datum/recipe/katsudon_bacon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/katsudon_bacon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/breadcrumbs = 1)
	output = /obj/item/reagent_containers/food/snacks/katsudon

/datum/recipe/katsudon_chicken
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/katsudon_chicken)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/breadcrumbs = 1)
	output = /obj/item/reagent_containers/food/snacks/katsudon

/datum/recipe/gyudon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/gyudon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/onion_slice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/gyudon

/datum/recipe/cheese_gyudon
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/cheese_gyudon)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/onion_slice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/cheese_gyudon

/datum/recipe/miso_soup
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/miso_soup)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/plant/soy = 1)
	output = /obj/item/reagent_containers/food/snacks/miso_soup

/datum/recipe/bibimbap
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/bibimbap)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1,
	/obj/item/reagent_containers/food/snacks/plant/lettuce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	output = /obj/item/reagent_containers/food/snacks/bibimbap

/datum/recipe/katsu_curry
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/katsu_curry)
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sticky_rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/breadcrumbs = 1)
	output = /obj/item/reagent_containers/food/snacks/katsu_curry

/datum/recipe/flan
	recipe_instructions = list(/datum/recipe_instructions/cooking/oven/flan)
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/raw_flan = 1)
	output = /obj/item/reagent_containers/food/snacks/flan
