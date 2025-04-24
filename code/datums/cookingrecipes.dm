ABSTRACT_TYPE(/datum/cookingrecipe)
/datum/cookingrecipe
	var/list/ingredients
	var/cookbonus = null // how much cooking it needs to get a healing bonus
	var/output = null // what you get from this recipe
	var/useshumanmeat = 0 // used for naming of human meat dishes after their victims
	var/category = "Unsorted" /// category for sorting, use null to hide

	proc/specialOutput(var/obj/submachine/ourCooker)
		return null //If returning an object, that is used as the output

// potential future update:
// specialOutput should have a flag for if it is used or not,
// rather than relying on its output being null and using output if so
// (there are cases where specialOutput can return null as a "didn't work" result,
//  and not just a default fallback)

ABSTRACT_TYPE(/datum/cookingrecipe/oven)
/datum/cookingrecipe/oven
ABSTRACT_TYPE(/datum/cookingrecipe/mixer)
/datum/cookingrecipe/mixer


/datum/cookingrecipe/oven/burger/humanburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/humanburger
	useshumanmeat = 1
	category = "Burgers"

/datum/cookingrecipe/oven/burger/fishburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/fishburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/synthburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/synthburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/slugburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/slugburger
	category = "Burgers"

/datum/cookingrecipe/oven/spicychickensandwich_2
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/spicy = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	category = "Burgers"

/datum/cookingrecipe/oven/spicychickensandwich
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	category = "Burgers"

/datum/cookingrecipe/oven/chickensandwich
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken
	category = "Burgers"

ABSTRACT_TYPE(/datum/cookingrecipe/oven/burger)
/datum/cookingrecipe/oven/burger
	specialOutput(obj/submachine/ourCooker)
		//this is dumb and assumes the second thing is always the meat but it usually is so :iiam:
		var/obj/item/possibly_meat = locate(ingredients[2]) in ourCooker
		if (possibly_meat?.reagents?.get_reagent_amount("crime") >= 5)
			var/obj/item/reagent_containers/food/snacks/burger/burgle/burgle = new()
			possibly_meat.transfer_all_reagents(burgle)
			return burgle
		return new src.output()

/datum/cookingrecipe/oven/burger/mysteryburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/mysteryburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/cheeseburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/wcheeseburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/gcheeseslice = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/wcheeseburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/cheeseburger_m
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger_m
	category = "Burgers"

/datum/cookingrecipe/oven/burger/luauburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/luauburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/coconutburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/coconutburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/tikiburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1)
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/burger/tikiburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/monkeyburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/monkeyburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/buttburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/clothing/head/butt = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/buttburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/synthbuttburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/clothing/head/butt/synth = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/buttburger/synth
	category = "Burgers"

/datum/cookingrecipe/oven/burger/cyberbuttburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/clothing/head/butt/cyberbutt = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/buttburger/cyber
	category = "Burgers"

/datum/cookingrecipe/oven/burger/synthheartburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/heart/synth = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger/synth
	category = "Burgers"

/datum/cookingrecipe/oven/burger/cyberheartburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/heart/cyber = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger/cyber
	category = "Burgers"

/datum/cookingrecipe/oven/burger/flockheartburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/heart/flock = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger/flock
	category = "Burgers"

/datum/cookingrecipe/oven/burger/heartburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/heart = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/flockburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/flockburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/brainburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/brain = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/synthbrainburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/brain/synth= 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger/synth
	category = "Burgers"

/datum/cookingrecipe/oven/burger/cyberbrainburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/brain/latejoin = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger/cyber
	category = "Burgers"

/datum/cookingrecipe/oven/burger/flockbrainburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/organ/brain/flockdrone = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger/flock
	category = "Burgers"

/datum/cookingrecipe/oven/burger/roburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/parts/robot_parts/head = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/roburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/cheeseborger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/parts/robot_parts/head = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseborger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/baconburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/baconburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/baconator
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/bigburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/butterburger
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/butterburger
	category = "Burgers"

/datum/cookingrecipe/oven/burger/aburgination
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling = 1)
	cookbonus = 6 // still mostly raw, since we don't kill it
	output = /obj/item/reagent_containers/food/snacks/burger/aburgination
	category = "Burgers"

/datum/cookingrecipe/oven/burger/monster
	ingredients = list(/obj/item/reagent_containers/food/snacks/burger/bigburger = 4)
	cookbonus = 20
	output = /obj/item/reagent_containers/food/snacks/burger/monsterburger
	category = "Burgers"

/datum/cookingrecipe/oven/swede_mball
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/meatball = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/swedishmeatball

/datum/cookingrecipe/oven/donkpocket
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm

/datum/cookingrecipe/oven/honkpocket
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1,
	/obj/item/instrument/bikehorn = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm

/datum/cookingrecipe/oven/donkpocket2
	ingredients = list(/obj/item/reagent_containers/food/snacks/donkpocket = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm

/datum/cookingrecipe/oven/donut
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_circle = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/donut

/datum/cookingrecipe/oven/bagel
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough_circle = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/bagel

/datum/cookingrecipe/oven/crumpet //another good idea for this is to cook a trumpet
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/holey_dough = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/crumpet

/datum/cookingrecipe/oven/ice_cream_cone
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/ice_cream_cone

/datum/cookingrecipe/oven/nougat
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/candy/nougat

/datum/cookingrecipe/oven/candy_cane
	ingredients = list(\
	/obj/item/plant/herb/mint = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/candy/candy_cane

/datum/cookingrecipe/oven/waffles
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/waffles

/datum/cookingrecipe/oven/spaghetti_p
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_t
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/sauce
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_s
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/spicy
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_m
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/meatball
	category = "Pasta"

/datum/cookingrecipe/oven/lasagna
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/lasagna
	category = "Pasta"

/datum/cookingrecipe/oven/alfredo
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/alfredo
	category = "Pasta"

/datum/cookingrecipe/oven/chickenparm
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/chickenparm
	category = "Pasta"

/datum/cookingrecipe/oven/chickenalfredo
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/chickenalfredo
	category = "Pasta"

/datum/cookingrecipe/oven/spaghetti_pg
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/pizza = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/pizzaghetti
	category = "Pasta"

/datum/cookingrecipe/oven/spooky_bread
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/spooky
	category = "Bread"

/datum/cookingrecipe/oven/elvis_bread
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/elvis
	category = "Bread"

/datum/cookingrecipe/oven/banana_bread
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/cookingrecipe/oven/banana_bread_alt
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana
	category = "Bread"

/datum/cookingrecipe/oven/cornbread1
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn
	category = "Bread"

/datum/cookingrecipe/oven/cornbread2
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/cookingrecipe/oven/cornbread3
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet
	category = "Bread"

/datum/cookingrecipe/oven/cornbread4
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/corn = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet/honey
	category = "Bread"

/datum/cookingrecipe/oven/pumpkin_bread
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/pumpkin = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/pumpkin
	category = "Bread"

/datum/cookingrecipe/oven/bread
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf
	category = "Bread"

/datum/cookingrecipe/oven/honeywheat_bread
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	category = "Bread"

/datum/cookingrecipe/oven/brain_bread
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf = 1,
	/obj/item/organ/brain = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/breadloaf/brain
	category = "Bread"

/datum/cookingrecipe/oven/toast_bread
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadloaf = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/toast
	category = "Bread"

/datum/cookingrecipe/oven/toast
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice
	category = "Toast"

/datum/cookingrecipe/oven/toast_banana
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice/banana)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/banana
	category = "Toast"

/datum/cookingrecipe/oven/toast_brain
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice/brain)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/brain
	category = "Toast"

/datum/cookingrecipe/oven/toast_elvis
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice/elvis)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/elvis
	category = "Toast"

/datum/cookingrecipe/oven/toast_spooky
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice/spooky)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/spooky
	category = "Toast"

/datum/cookingrecipe/oven/toasted_french
	ingredients = list(/obj/item/reagent_containers/food/snacks/breadslice/french)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/french
	category = "Toast"

/datum/cookingrecipe/oven/sandwich_m_h
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_h
	useshumanmeat = 1
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_m_m
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_m
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_m_s
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_s
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_c
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/cheese
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_p
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/pb
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_p_h
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/pbh
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_blt
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon= 1,
	/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/lettuce = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/blt
	category = "Sandwich"


/datum/cookingrecipe/oven/elviswich_m_h
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_h
	useshumanmeat = 1
	category = "Sandwich"

/datum/cookingrecipe/oven/c_butty
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1,
	/obj/item/reagent_containers/food/snacks/fries = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/c_butty
	category = "Sandwich"

/datum/cookingrecipe/oven/elviswich_m_m
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_m
	category = "Sandwich"

/datum/cookingrecipe/oven/elviswich_m_s
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_s
	category = "Sandwich"

/datum/cookingrecipe/oven/elviswich_c
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_cheese
	category = "Sandwich"

/datum/cookingrecipe/oven/elviswich_p
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pb
	category = "Sandwich"

/datum/cookingrecipe/oven/elviswich_p_h
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pbh
	category = "Sandwich"

/datum/cookingrecipe/oven/elviswich_blt
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/lettuce = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_blt
	category = "Sandwich"

/datum/cookingrecipe/oven/scarewich_c
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 2)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_cheese
	category = "Sandwich"

/datum/cookingrecipe/oven/scarewich_p
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pb
	category = "Sandwich"

/datum/cookingrecipe/oven/scarewich_p_h
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pbh
	category = "Sandwich"

/datum/cookingrecipe/oven/scarewich_h
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_h
	useshumanmeat = 1
	category = "Sandwich"

/datum/cookingrecipe/oven/scarewich_m
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_m
	category = "Sandwich"

/datum/cookingrecipe/oven/scarewich_s
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_s
	category = "Sandwich"

/datum/cookingrecipe/oven/scarewich_blt
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/spooky = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice = 1,
	/obj/item/reagent_containers/food/snacks/plant/lettuce = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_blt
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_mb //Original meatball sub recipe
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_mbalt //Secondary recipe that uses the baguette
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/meatball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_egg
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 2,
	/obj/item/reagent_containers/food/snacks/eggsalad = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/eggsalad
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_bm //Original banh mi recipe
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadloaf/honeywheat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_bmalt //Secondary recipe that uses the baguette
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi
	category = "Sandwich"

/datum/cookingrecipe/oven/sandwich_custom
	ingredients =  list(/obj/item/reagent_containers/food/snacks/breadslice = 2)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich
	category = "Sandwich"

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/sandwich/customSandwich = new /obj/item/reagent_containers/food/snacks/sandwich (ourCooker)
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
		for (var/obj/item/reagent_containers/food/snacks/snack in ourCooker)
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

		return customSandwich

/datum/cookingrecipe/oven/pizza_custom
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pizza_base = 1)
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/pizza/bespoke
	category = "Pizza"

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		for (var/obj/item/reagent_containers/food/snacks/ingredient/pizza_base/P in ourCooker)
			return P.bake_pizza()

/datum/cookingrecipe/oven/cheesetoast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastcheese
	category = "Toast (Meal)"


/datum/cookingrecipe/oven/bacontoast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastbacon
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/eggtoast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastegg
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/elvischeesetoast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastcheese/elvis
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/elvisbacontoast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastbacon/elvis
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/elviseggtoast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice/elvis = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastegg/elvis
	category = "Toast (Meal)"

/datum/cookingrecipe/oven/breakfast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/breakfast

/datum/cookingrecipe/mixer/wonton_wrapper
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	cookbonus = 1
	output = /obj/item/reagent_containers/food/snacks/wonton_spawner

/datum/cookingrecipe/oven/taco_shell
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/tortilla = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/taco

/datum/cookingrecipe/oven/eggnog
	ingredients = list(\
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 3)
	cookbonus = 3
	output = /obj/item/reagent_containers/food/drinks/eggnog

// Pastries and bread-likes

/datum/cookingrecipe/oven/baguette
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_strip = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	cookbonus = 8
	output = /obj/item/baguette
	category = "Pastries and bread-likes" // not sorry

/datum/cookingrecipe/oven/garlicbread
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/garlicbread
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/garlicbread_ch
	ingredients = list(\
	/obj/item/baguette = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/garlicbread_ch
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/painauchocolat
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/painauchocolat
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/croissant
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/croissant
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_apple
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/apple = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_apple
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_cherry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_cherry
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_blueb
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/blueberry = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_blueb
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_weed
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/plant/herb/cannabis = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_weed
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/danish_cheese
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/danish_cheese
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/fairybread
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/fairybread
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/cinnamonbun
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/cinnamon = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/cinnamonbun
	category = "Pastries and bread-likes"

/datum/cookingrecipe/oven/chocolate_cherry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 3
	output = /obj/item/reagent_containers/food/snacks/chocolate_cherry

//Cookies
/datum/cookingrecipe/oven/stroopwafel
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 2,
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/stroopwafel
	category = "Cookies"

/datum/cookingrecipe/oven/cookie
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_iron
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ironfilings = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/metal
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_chocolate_chip
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/condiment/chocchips = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_oatmeal
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/oatmeal
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_bacon
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/bacon
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_jaffa
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/plant/orange = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/jaffa
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_spooky
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ectoplasm = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/spooky
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_butter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/butter
	category = "Cookies"

/datum/cookingrecipe/oven/cookie_peanut
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_cookie = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/peanut
	category = "Cookies"

//Moon pies!
/datum/cookingrecipe/oven/moon_pie
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_iron
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/metal = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/metal
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_chips
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/chocolate_chip = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate_chip
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_oatmeal
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/oatmeal = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/oatmeal
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_bacon
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/bacon = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/bacon
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_jaffa
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/jaffa = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/jaffa
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_spooky
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/spooky = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/spooky
	category = "Moon Pies"

/datum/cookingrecipe/oven/moon_pie_chocolate
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cookie/chocolate_chip = 2,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate
	category = "Moon Pies"

/datum/cookingrecipe/oven/onionchips
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/onion_slice = 2,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/onionchips

/datum/cookingrecipe/oven/fries
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/chips = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/cookingrecipe/oven/chilifries
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/fries = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	cookbonus = 3
	output = /obj/item/reagent_containers/food/snacks/chilifries

/datum/cookingrecipe/oven/chilifries_alt //Secondary recipe for chili cheese fries
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/chips = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/chilifries

/datum/cookingrecipe/oven/poutine
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/fries = 1,
	/obj/item/reagent_containers/food/snacks/condiment/gravyboat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	cookbonus = 3
	output = /obj/item/reagent_containers/food/snacks/chilifries/poutine

/datum/cookingrecipe/oven/poutine_alt
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/chips = 1,
	/obj/item/reagent_containers/food/snacks/condiment/gravyboat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/chilifries/poutine

/datum/cookingrecipe/oven/bakedpotato
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/potato = 1)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/bakedpotato

/datum/cookingrecipe/oven/hotdog
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/hotdog

/datum/cookingrecipe/oven/steak_h
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_h
	useshumanmeat = 1

/datum/cookingrecipe/oven/steak_m
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_m

/datum/cookingrecipe/oven/steak_s
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_s

/datum/cookingrecipe/oven/steak_ling
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling = 1)
	cookbonus = 12 // tough meat
	output = /obj/item/reagent_containers/food/snacks/steak_ling

/datum/cookingrecipe/oven/fish_fingers
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/fish_fingers

/datum/cookingrecipe/oven/shrimp
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/shrimp = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/shrimp

/datum/cookingrecipe/oven/bacon
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon

/datum/cookingrecipe/oven/turkey
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/turkey = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/turkey

/datum/cookingrecipe/oven/pie_strawberry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/strawberry = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/strawberry
	category = "Pies"

/datum/cookingrecipe/oven/pie_cherry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/cherry = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/cherry
	category = "Pies"

/datum/cookingrecipe/oven/pie_blueberry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/blueberry = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/blueberry
	category = "Pies"

/datum/cookingrecipe/oven/pie_raspberry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/raspberry = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/raspberry
	category = "Pies"

/datum/cookingrecipe/oven/pie_blackberry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/raspberry/blackberry = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/blackberry
	category = "Pies"

/datum/cookingrecipe/oven/pie_apple
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/apple = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/apple
	category = "Pies"

/datum/cookingrecipe/oven/pie_lime
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/lime = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/lime
	category = "Pies"

/datum/cookingrecipe/oven/pie_lemon
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/lemon = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/lemon
	category = "Pies"

/datum/cookingrecipe/oven/pie_slurry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/slurryfruit = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/slurry
	category = "Pies"

/datum/cookingrecipe/oven/pie_pumpkin
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/plant/pumpkin = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/pumpkin
	category = "Pies"

/datum/cookingrecipe/oven/pie_chocolate
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/pie/chocolate
	category = "Pies"

/datum/cookingrecipe/oven/pie_anything/pie_cream
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/cream
	category = "Pies"
	base_pie_name = "cream pie"

/datum/cookingrecipe/oven/pie_anything
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/anything
	category = "Pies"
	var/base_pie_name = "pie"

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null
		if (length(ourCooker.contents) <= 2)
			return new src.output

		var/obj/item/reagent_containers/food/snacks/anItem
		var/obj/item/reagent_containers/food/snacks/pie/custom_pie = new src.output
		var/pieDesc
		var/pieName
		var/contentAmount = ourCooker.contents.len - 2
		var/count = 1
		var/found1 = 0
		var/found2 = 0
		for (var/obj/item/T in ourCooker.contents)

			if (T.type == ingredients[1] && !found1)
				found1 = TRUE
				continue

			if (T.type == ingredients[2] && !found2)
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

		return custom_pie

/datum/cookingrecipe/oven/pie_custard
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/custard = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/custard
	category = "Pies"

/datum/cookingrecipe/oven/pie_bacon
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/pie/bacon
	category = "Pies"

/datum/cookingrecipe/oven/pie_ass
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/clothing/head/butt = 1)
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/pie/ass
	category = "Pies"

/datum/cookingrecipe/oven/pot_pie
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/pot
	category = "Pies"

/datum/cookingrecipe/oven/pie_weed
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/plant/herb/cannabis = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/weed
	category = "Pies"

/datum/cookingrecipe/oven/pie_fish
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1,
	/obj/item/reagent_containers/food/snacks/plant/potato = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/pie/fish
	category = "Pies"

/datum/cookingrecipe/mixer/custard
	ingredients = list(\
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/condiment/custard

/datum/cookingrecipe/mixer/gruel
	ingredients = list(/obj/item/reagent_containers/food/snacks/yuck = 3)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/gruel

/datum/cookingrecipe/oven/porridge
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/rice = 2)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/porridge

/datum/cookingrecipe/oven/oatmeal
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/oatmeal

/datum/cookingrecipe/oven/tomsoup
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/tomato = 2)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/soup/tomato

/datum/cookingrecipe/oven/mint_chutney
	ingredients = list(\
	/obj/item/plant/herb/mint = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/mint_chutney

/datum/cookingrecipe/oven/refried_beans
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bean = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/refried_beans

/datum/cookingrecipe/oven/chili
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/chili

/datum/cookingrecipe/oven/queso
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/cheese = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/queso

/datum/cookingrecipe/oven/superchili
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 2)
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/soup/superchili

/datum/cookingrecipe/oven/ultrachili
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/soup/superchili = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/condiment/hotsauce = 1)
	cookbonus = 20
	output = /obj/item/reagent_containers/food/snacks/soup/ultrachili

/datum/cookingrecipe/oven/salad
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/lettuce = 2)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/salad

/datum/cookingrecipe/oven/creamofamanita
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/mushroom/amanita = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/amanita

/datum/cookingrecipe/oven/creamofpsilocybin
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/mushroom/psilocybin = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/psilocybin

/datum/cookingrecipe/oven/creamofmushroom
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/mushroom = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom

//Delightful Halloween Recipes
/datum/cookingrecipe/oven/candy_apple
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/apple/stick = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple

/datum/cookingrecipe/oven/candy_apple_poison
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/apple/stick/poison = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple/poison

//Cakes!
/datum/cookingrecipe/mixer/cake_batter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/cake_batter

/datum/cookingrecipe/oven/cake_cream
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/condiment/cream = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/cream
	category = "Cakes"

/datum/cookingrecipe/oven/cake_chocolate
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/chocolate
	category = "Cakes"

/datum/cookingrecipe/oven/cake_meat
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/meat
	category = "Cakes"

/datum/cookingrecipe/oven/cake_bacon
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cake_batter = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 3)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/bacon
	category = "Cakes"

/datum/cookingrecipe/oven/cake_true_bacon
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = 7)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/true_bacon
	category = "Cakes"

#ifdef XMAS

/datum/cookingrecipe/oven/cake_fruit
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/yuck = 1,
	/obj/item/reagent_containers/food/snacks/yuck/burn = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/breadloaf/fruit_cake
	category = "Cakes"

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/fruitcake = new /obj/item/reagent_containers/food/snacks/breadloaf/fruit_cake
		playsound(ourCooker.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

		return fruitcake

#endif

/datum/cookingrecipe/oven/cake_custom
	ingredients = list(/obj/item/reagent_containers/food/snacks/cake_batter = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake
	category = "Cakes"

	specialOutput(var/obj/submachine/ourCooker)
		if(!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/cake_batter/docakeitem = locate() in ourCooker.contents

		var/obj/item/reagent_containers/food/snacks/S
		if(docakeitem.custom_item)
			S = docakeitem.custom_item
		var/obj/item/reagent_containers/food/snacks/cake/B = new /obj/item/reagent_containers/food/snacks/cake(ourCooker)
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
		return B


/datum/cookingrecipe/oven/cake_custom_item
	ingredients = list(/obj/item/reagent_containers/food/snacks/cake/cream = 1)
	cookbonus = 14
	output = /obj/item/cake_item
	category = "Cakes"

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/cake_item/B = new /obj/item/cake_item(ourCooker)
		for (var/obj/item/I in ourCooker.contents)
			if (istype(I,/obj/item/cake_item))
				continue
			I.set_loc(B)
			break

		return B

/datum/cookingrecipe/mixer/mix_cake_custom
	ingredients = list(/obj/item/reagent_containers/food/snacks/cake_batter = 1)
	output = null

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		for (var/obj/item/I in ourCooker.contents)
			if (istype(I, ingredients[1]))
				continue
			else if (istype(I,/obj/item/reagent_containers/food/snacks/))
				var/obj/item/reagent_containers/food/snacks/cake_batter/batter = new

				batter.custom_item = I
				I.set_loc(batter)
				batter.name = "[I:real_name ? I:real_name : I.name] cake batter"
				for (var/obj/M in ourCooker.contents)
					qdel(M)

				return batter

		return null


/datum/cookingrecipe/oven/omelette
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/omelette

/datum/cookingrecipe/oven/omelette_bee
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg/bee = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/omelette/bee

/datum/cookingrecipe/mixer/pancake_batter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/drinks/milk = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/pancake_batter

/datum/cookingrecipe/oven/pancake
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/pancake_batter = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/pancake

/datum/cookingrecipe/mixer/mashedpotatoes
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/potato = 3)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/mashedpotatoes

/datum/cookingrecipe/mixer/mashedbrains
	ingredients = list(/obj/item/organ/brain = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/mashedbrains

/datum/cookingrecipe/mixer/meatpaste
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste

/datum/cookingrecipe/mixer/soysauce
	ingredients = list(/obj/item/reagent_containers/food/snacks/plant/soy = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/condiment/soysauce

/datum/cookingrecipe/mixer/gravy
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/condiment/gravyboat

/datum/cookingrecipe/mixer/fishpaste
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/fishpaste

/datum/cookingrecipe/oven/burger/sloppyjoe
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1)
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/burger/sloppyjoe

/datum/cookingrecipe/oven/meatloaf
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/breadloaf = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/meatloaf

/datum/cookingrecipe/oven/cereal_box
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/condiment/chocchips = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box

/datum/cookingrecipe/oven/cereal_honey
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box/honey

/datum/cookingrecipe/oven/cereal_tanhony
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box/tanhony

/datum/cookingrecipe/oven/cereal_roach
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box/roach

/datum/cookingrecipe/oven/cereal_syndie
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/uplink_telecrystal = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box/syndie

/datum/cookingrecipe/oven/cereal_flock
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/cereal_box = 1,
	/obj/item/organ/brain/flockdrone = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box/flock

/datum/cookingrecipe/oven/granola_bar
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/granola_bar

/datum/cookingrecipe/oven/hardboiled
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled

/datum/cookingrecipe/oven/chocolate_egg
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/chocolate

	specialOutput(obj/submachine/ourCooker)
		if (!length(ourCooker.contents))
			return new src.output()
		for (var/obj/item/item in ourCooker.contents)
			if (istypes(item, list(src.ingredients[1], src.ingredients[2])))
				continue
			if (item.w_class > W_CLASS_SMALL)
				continue
			var/obj/item/reagent_containers/food/snacks/ingredient/egg/chocolate/choc_egg = new(ourCooker)
			choc_egg.AddComponent(/datum/component/contraband, 1) //illegal unsafe dangerous egg
			item.set_loc(choc_egg)
			return choc_egg

/datum/cookingrecipe/oven/eggsalad
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1,
	/obj/item/reagent_containers/food/snacks/salad = 1,
	/obj/item/reagent_containers/food/snacks/condiment/mayo = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/eggsalad

/datum/cookingrecipe/oven/biscuit
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/flour = 1)
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/biscuit

/datum/cookingrecipe/oven/dog_biscuit
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/granola_bar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/cookie/dog

/datum/cookingrecipe/oven/hardtack
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ironfilings = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/hardtack

/datum/cookingrecipe/oven/macguffin
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/emuffin = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/cheeseslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/macguffin

/datum/cookingrecipe/oven/haggis
	ingredients = list(\
	/obj/item/organ = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/haggis

/datum/cookingrecipe/oven/haggass
	ingredients = list(\
	/obj/item/clothing/head/butt = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/haggis/ass

/datum/cookingrecipe/oven/scotch_egg
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/scotch_egg

/datum/cookingrecipe/oven/rice_ball
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/rice_ball

/datum/cookingrecipe/oven/nigiri_roll
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet_slice = 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 1)
	cookbonus = 2
	output = /obj/item/reagent_containers/food/snacks/nigiri_roll

/datum/cookingrecipe/oven/sushi_roll
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/fish/fillet= 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 2,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1)
	cookbonus = 2
	output = /obj/item/reagent_containers/food/snacks/sushi_roll

/datum/cookingrecipe/oven/riceandbeans
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bean = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/riceandbeans

/datum/cookingrecipe/oven/friedrice
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/friedrice

/datum/cookingrecipe/oven/omurice
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 1,
	/obj/item/reagent_containers/food/snacks/condiment/ketchup = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/omurice

/datum/cookingrecipe/oven/risotto
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/risotto

/datum/cookingrecipe/oven/tandoorichicken
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/tandoorichicken

/datum/cookingrecipe/oven/potatocurry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/plant/potato = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/plant/peas = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/potatocurry

/datum/cookingrecipe/oven/coconutcurry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/plant/coconutmeat = 1,
	/obj/item/reagent_containers/food/snacks/plant/carrot = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/rice = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/coconutcurry

/datum/cookingrecipe/oven/chickenpineapplecurry
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/pineappleslice = 1)
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/chickenpineapplecurry

/datum/cookingrecipe/oven/ramen_bowl
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/ramen = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/ramen_bowl

/datum/cookingrecipe/oven/udon_bowl
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon = 1,
	/obj/item/reagent_containers/food/snacks/condiment/soysauce = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/kamaboko = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/udon_bowl

/datum/cookingrecipe/oven/curry_udon_bowl
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/udon = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/currypowder = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/seaweed = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/curry_udon_bowl

/datum/cookingrecipe/oven/mapo_tofu_meat
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/soy = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/mapo_tofu_meat

/datum/cookingrecipe/oven/mapo_tofu_synth
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat = 1,
	/obj/item/reagent_containers/food/snacks/plant/chili = 1,
	/obj/item/reagent_containers/food/snacks/plant/soy = 1,
	/obj/item/reagent_containers/food/snacks/plant/onion = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/mapo_tofu_synth

/datum/cookingrecipe/oven/cheesewheel
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/cheese = 2)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cheesewheel

/datum/cookingrecipe/oven/ratatouille
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/cucumber = 1,
	/obj/item/reagent_containers/food/snacks/plant/tomato = 1,
	/obj/item/reagent_containers/food/snacks/plant/eggplant = 1,
	/obj/item/reagent_containers/food/snacks/plant/garlic = 1)
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/ratatouille

/datum/cookingrecipe/oven/churro
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_strip = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/dippable/churro

/datum/cookingrecipe/oven/french_toast
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/breadslice = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/drinks/milk = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/french_toast

/datum/cookingrecipe/oven/zongzi
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/plant/bamboo = 1,
	/obj/item/reagent_containers/food/snacks/rice_ball = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/meat = 1)
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/zongzi

/datum/cookingrecipe/oven/beefood
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/honey = 1,
	/obj/item/plant/wheat = 1,
	/obj/item/reagent_containers/food/snacks/yuck = 1)
	cookbonus = 22
	output = /obj/item/reagent_containers/food/snacks/beefood

/datum/cookingrecipe/oven/b_cupcake
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/beefood = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/royal_jelly = 1,
	/obj/item/device/light/candle/small = 1)
	cookbonus = 22
	output = /obj/item/reagent_containers/food/snacks/b_cupcake

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/b_cupcake = new /obj/item/reagent_containers/food/snacks/b_cupcake

		b_cupcake.desc = "A little birthday cupcake for a bee. May not taste good to non-bees."
		var/icon/I = new /icon('icons/obj/foodNdrink/food_dessert.dmi',"b_cupcake")
		var/random_color = rgb(rand(1,255), rand(1,255), rand(1,255))
		I.Blend(random_color, ICON_ADD)
		b_cupcake.icon = I

		return b_cupcake

/datum/cookingrecipe/mixer/butters
	ingredients = list(\
	/obj/item/clothing/head/butt = 1,
	/obj/item/reagent_containers/food/drinks/milk = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/condiment/butters

/datum/cookingrecipe/oven/lipstick
	ingredients = list(\
	/obj/item/pen/crayon = 1,
	/obj/item/item_box/figure_capsule = 1)
	cookbonus = 10
	output = /obj/item/pen/crayon/lipstick

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null
		var/obj/item/pen/crayon/lipstick/lipstick = new /obj/item/pen/crayon/lipstick
		for (var/obj/item/pen/crayon/C in ourCooker.contents)
			lipstick.font_color = C.font_color
			lipstick.color_name = hex2color_name(lipstick.font_color)
			lipstick.name = "[lipstick.color_name] lipstick"
			lipstick.UpdateIcon()
		return lipstick

/datum/cookingrecipe/oven/melted_sugar
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/sugar = 1,
	/obj/item/plate/tray = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/ingredient/melted_sugar

/datum/cookingrecipe/mixer/brownie_batter
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough_s = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/egg = 2,
	/obj/item/reagent_containers/food/snacks/candy/chocolate = 1)
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/ingredient/brownie_batter

/datum/cookingrecipe/oven/brownie_batch
	ingredients = list(/obj/item/reagent_containers/food/snacks/ingredient/brownie_batter = 1)
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/dessert_batch/brownie

/datum/cookingrecipe/oven/flapjack_batch
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/oatmeal = 1,
	/obj/item/reagent_containers/food/snacks/ingredient/butter = 1,
	/obj/item/reagent_containers/food/snacks/condiment/syrup = 1) //technically this should be GOLDEN syrup but this works too
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/dessert_batch/flapjack

