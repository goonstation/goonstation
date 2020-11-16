/datum/cookingrecipe
	var/item1 = null
	var/item2 = null
	var/item3 = null
	var/item4 = null
	var/amt1 = 1
	var/amt2 = 1
	var/amt3 = 1
	var/amt4 = 1
	var/cookbonus = null // how much cooking it needs to get a healing bonus
	var/output = null // what you get from this recipe
	var/useshumanmeat = 0 // used for naming of human meat dishes after their victims

	proc/specialOutput(var/obj/submachine/ourCooker)
		return null //If returning an object, that is used as the output

/datum/cookingrecipe/humanburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/humanburger
	useshumanmeat = 1

/datum/cookingrecipe/fishburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/fishburger

/datum/cookingrecipe/synthburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/synthburger

/datum/cookingrecipe/spicychickensandwich
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	item3 = /obj/item/reagent_containers/food/snacks/plant/chili
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken/spicy

/datum/cookingrecipe/chickensandwich
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/chicken

/datum/cookingrecipe/mysteryburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/mysteryburger

/datum/cookingrecipe/cheeseburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger

/datum/cookingrecipe/cheeseburger_m
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/cheeseburger_m

/datum/cookingrecipe/luauburger
 	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
 	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
 	item3 = /obj/item/reagent_containers/food/snacks/plant/pineappleslice
 	cookbonus = 15
 	output = /obj/item/reagent_containers/food/snacks/burger/luauburger

/datum/cookingrecipe/coconutburger
 	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
 	item2 = /obj/item/reagent_containers/food/snacks/plant/coconutmeat/
 	cookbonus = 13
 	output = /obj/item/reagent_containers/food/snacks/burger/coconutburger

/datum/cookingrecipe/tikiburger
 	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
 	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
 	item3 = /obj/item/reagent_containers/food/snacks/plant/pineappleslice
 	item4 = /obj/item/reagent_containers/food/snacks/plant/coconutmeat/
 	cookbonus = 18
 	output = /obj/item/reagent_containers/food/snacks/burger/tikiburger

/datum/cookingrecipe/monkeyburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/monkeyburger

/datum/cookingrecipe/buttburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/clothing/head/butt
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/buttburger

/datum/cookingrecipe/heartburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/organ/heart
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/heartburger

/datum/cookingrecipe/flockburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/organ/brain/flockdrone
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/flockburger

/datum/cookingrecipe/brainburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/organ/brain
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/brainburger

/datum/cookingrecipe/roburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/parts/robot_parts/head
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/roburger

/datum/cookingrecipe/baconburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/baconburger

/datum/cookingrecipe/baconator
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat
	amt2 = 2
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/burger/bigburger

/datum/cookingrecipe/butterburger
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/burger/butterburger

/datum/cookingrecipe/monster
	item1 = /obj/item/reagent_containers/food/snacks/burger/bigburger
	amt1 = 4
	cookbonus = 20
	output = /obj/item/reagent_containers/food/snacks/burger/monsterburger

/datum/cookingrecipe/swede_mball
	item1 = /obj/item/reagent_containers/food/snacks/meatball
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/flour
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/swedishmeatball

/datum/cookingrecipe/donkpocket
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/meatball
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm

/datum/cookingrecipe/honkpocket
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/meatball
	item3 = /obj/item/instrument/bikehorn
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/honk/warm

/datum/cookingrecipe/donkpocket2
	item1 = /obj/item/reagent_containers/food/snacks/donkpocket
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/donkpocket/warm

/datum/cookingrecipe/donut
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_circle
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/donut

/datum/cookingrecipe/bagel
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_circle
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/bagel

/datum/cookingrecipe/crumpet //another good idea for this is to cook a trumpet
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/holey_dough
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/crumpet

/datum/cookingrecipe/ice_cream_cone
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/ice_cream_cone

/datum/cookingrecipe/nougat
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/candy/nougat

/datum/cookingrecipe/candy_cane
	item1 = /obj/item/plant/herb/mint
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/candy/candy_cane

/datum/cookingrecipe/waffles
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/waffles

/datum/cookingrecipe/spaghetti_p
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti

/datum/cookingrecipe/spaghetti_t
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/condiment/ketchup
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/sauce

/datum/cookingrecipe/spaghetti_s
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/condiment/hotsauce
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/spicy

/datum/cookingrecipe/spaghetti_m
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/meatball
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/meatball

/datum/cookingrecipe/spaghetti_pg
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/spaghetti
	item2 = /obj/item/reagent_containers/food/snacks/condiment/ketchup
	item3 = /obj/item/reagent_containers/food/snacks/pizza
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/spaghetti/pizzaghetti

/datum/cookingrecipe/spooky_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item3 = /obj/item/reagent_containers/food/snacks/ectoplasm
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/spooky

/datum/cookingrecipe/elvis_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/banana
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/elvis

/datum/cookingrecipe/banana_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/banana
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana

/datum/cookingrecipe/banana_bread_alt
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/banana
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/banana

/datum/cookingrecipe/cornbread1
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn

/datum/cookingrecipe/cornbread2
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet

/datum/cookingrecipe/cornbread3
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet

/datum/cookingrecipe/cornbread4
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/corn
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/breadloaf/corn/sweet/honey

/datum/cookingrecipe/pumpkin_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/plant/pumpkin
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/pumpkin

/datum/cookingrecipe/bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf

/datum/cookingrecipe/honeywheat_bread
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/breadloaf/honeywheat

/datum/cookingrecipe/brain_bread
	item1 = /obj/item/reagent_containers/food/snacks/breadloaf
	item2 = /obj/item/organ/brain
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/breadloaf/brain

/datum/cookingrecipe/toast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice

/datum/cookingrecipe/toast_banana
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/banana
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/banana

/datum/cookingrecipe/toast_brain
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/brain
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/brain

/datum/cookingrecipe/toast_elvis
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/elvis

/datum/cookingrecipe/toast_spooky
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/breadslice/toastslice/spooky

/datum/cookingrecipe/sandwich_m_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_h
	useshumanmeat = 1

/datum/cookingrecipe/sandwich_m_m
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_m

/datum/cookingrecipe/sandwich_m_s
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/meat_s

/datum/cookingrecipe/sandwich_c
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/cheese

/datum/cookingrecipe/sandwich_p
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/pb

/datum/cookingrecipe/sandwich_p_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/pbh

/datum/cookingrecipe/elviswich_m_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_h
	useshumanmeat = 1

/datum/cookingrecipe/elviswich_m_m
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_m

/datum/cookingrecipe/elviswich_m_s
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_meat_s

/datum/cookingrecipe/elviswich_c
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_cheese

/datum/cookingrecipe/elviswich_p
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pb

/datum/cookingrecipe/elviswich_p_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/elvis_pbh

/datum/cookingrecipe/scarewich_c
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_cheese

/datum/cookingrecipe/scarewich_p
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pb

/datum/cookingrecipe/scarewich_p_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/peanutbutter
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_pbh

/datum/cookingrecipe/scarewich_h
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_h
	useshumanmeat = 1

/datum/cookingrecipe/scarewich_m
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_m

/datum/cookingrecipe/scarewich_s
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/spooky_meat_s

/datum/cookingrecipe/sandwich_mb
	item1 = /obj/item/reagent_containers/food/snacks/meatball
	item2 = /obj/item/reagent_containers/food/snacks/breadloaf
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item4 = /obj/item/reagent_containers/food/snacks/condiment/ketchup
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/meatball

/datum/cookingrecipe/sandwich_egg
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/eggsalad
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/sandwich/eggsalad

/datum/cookingrecipe/sandwich_bm
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw
	item2 = /obj/item/reagent_containers/food/snacks/breadloaf/honeywheat
	item3 = /obj/item/reagent_containers/food/snacks/plant/carrot
	item4 = /obj/item/reagent_containers/food/snacks/plant/cucumber
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/sandwich/banhmi

/datum/cookingrecipe/sandwich_custom
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	amt1 = 2
	cookbonus = 12
	output = null

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/sandwich/customSandwich = new /obj/item/reagent_containers/food/snacks/sandwich (ourCooker)
		customSandwich.reagents = new /datum/reagents(100)
		customSandwich.reagents.my_atom = customSandwich

		var/obj/item/reagent_containers/food/snacks/breadslice/slice1
		var/obj/item/reagent_containers/food/snacks/breadslice/slice2
		var/list/fillings = list()
		var/list/fillingColors = list()
		var/onBreadText = ""
		var/extraSlices = 0

		var/i = 1
		for (var/obj/item/reagent_containers/food/snacks/snack in ourCooker)
			if (snack == customSandwich)
				continue

			else if (istype(snack, /obj/item/reagent_containers/food/snacks/breadslice))
				if (slice1 && slice2)
					extraSlices++

					if (snack.reagents)
						snack.reagents.trans_to(customSandwich, 25)
					customSandwich.food_effects += snack.food_effects

					//fillings += snack.name
					if (snack.food_color)
						if (fillingColors.len % 2 || fillingColors.len < (i*2))
							fillingColors += "B[snack.food_color]"
						else
							fillingColors.Insert((i++*2), "B[snack.food_color]")
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
				if (snack.food_color && !istype(snack, /obj/item/reagent_containers/food/snacks/ingredient) && prob(50))
					fillingColors += snack.food_color
				else
					var/obj/transformedFilling = image(snack.icon, snack.icon_state)
					transformedFilling.transform = matrix(0.75, MATRIX_SCALE)
					fillingColors += transformedFilling

				qdel(snack)

		if (!fillings.len)
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
			sandwichIcon.color = slice1.food_color

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
			newFilling.color = slice2.food_color
			newFilling.pixel_y = fillingOffset

			//qdel(slice2)

			customSandwich.overlays += newFilling

		return customSandwich

/datum/cookingrecipe/pizza
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/pizza3
	cookbonus = 18
	output = null

	specialOutput(obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/pizza/customPizza = new /obj/item/reagent_containers/food/snacks/pizza (ourCooker)

		for (var/obj/item/reagent_containers/food/snacks/ingredient/pizza3/P in ourCooker)
			var/toppingstext = null
			if(P.toppingstext)
				toppingstext = P.toppingstext
				customPizza.name = "[toppingstext] pizza"
				customPizza.desc = "A pizza with [toppingstext] toppings. Looks pretty [pick("good","dang good","delicious","scrumptious","heavenly","alright")]."
			else
				customPizza.name = "pizza"
				customPizza.desc = 	"A plain cheese and tomato pizza. Looks pretty alright."
			customPizza.overlays += P.overlays
			customPizza.num = P.num
			customPizza.topping = P.topping
			customPizza.topping_colors = P.topping_colors
			customPizza.heal_amt = P.heal_amt
			P.reagents.trans_to(customPizza, P.reagents.total_volume)
			customPizza.food_effects += P.food_effects

		return customPizza

/datum/cookingrecipe/cheesetoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastcheese

/datum/cookingrecipe/bacontoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastbacon

/datum/cookingrecipe/eggtoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastegg

/datum/cookingrecipe/elvischeesetoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastcheese/elvis

/datum/cookingrecipe/elvisbacontoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastbacon/elvis

/datum/cookingrecipe/elviseggtoast
	item1 = /obj/item/reagent_containers/food/snacks/breadslice/elvis
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 2
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/toastegg/elvis

/datum/cookingrecipe/breakfast
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 2
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/breakfast

/datum/cookingrecipe/wonton_wrapper
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/flour
	cookbonus = 1
	output = /obj/item/reagent_containers/food/snacks/wonton_spawner

/datum/cookingrecipe/taco_shell
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/tortilla
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/taco

/datum/cookingrecipe/eggnog
	item1 = /obj/item/reagent_containers/food/drinks/milk
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 3
	cookbonus = 3
	output = /obj/item/reagent_containers/food/drinks/eggnog

//Cookies
/datum/cookingrecipe/cookie
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie

/datum/cookingrecipe/cookie_iron
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/condiment/ironfilings
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/metal

/datum/cookingrecipe/cookie_chocolate_chip
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/condiment/chocchips
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip

/datum/cookingrecipe/cookie_oatmeal
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/oatmeal

/datum/cookingrecipe/cookie_bacon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/bacon

/datum/cookingrecipe/cookie_jaffa
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/plant/orange
	item3 = /obj/item/reagent_containers/food/snacks/candy
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/jaffa

/datum/cookingrecipe/cookie_spooky
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ectoplasm
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/spooky

/datum/cookingrecipe/cookie_butter
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_cookie
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cookie/butter

//Moon pies!
/datum/cookingrecipe/moon_pie
	item1 = /obj/item/reagent_containers/food/snacks/cookie
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie

/datum/cookingrecipe/moon_pie_iron
	item1 = /obj/item/reagent_containers/food/snacks/cookie/metal
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/metal

/datum/cookingrecipe/moon_pie_chips
	item1 = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate_chip

/datum/cookingrecipe/moon_pie_oatmeal
	item1 = /obj/item/reagent_containers/food/snacks/cookie/oatmeal
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/oatmeal

/datum/cookingrecipe/moon_pie_bacon
	item1 = /obj/item/reagent_containers/food/snacks/cookie/bacon
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/bacon

/datum/cookingrecipe/moon_pie_jaffa
	item1 = /obj/item/reagent_containers/food/snacks/cookie/jaffa
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/jaffa

/datum/cookingrecipe/moon_pie_spooky
	item1 = /obj/item/reagent_containers/food/snacks/cookie/spooky
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/moon_pie/spooky

/datum/cookingrecipe/moon_pie_chocolate
	item1 = /obj/item/reagent_containers/food/snacks/cookie/chocolate_chip
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	item3 = /obj/item/reagent_containers/food/snacks/candy
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/moon_pie/chocolate

/datum/cookingrecipe/onionchips
	item1 = /obj/item/reagent_containers/food/snacks/onion_slice
	item2 = /obj/item/reagent_containers/food/snacks/onion_slice
	item3 = /obj/item/reagent_containers/food/snacks/plant/garlic
	item4 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/onionchips

/datum/cookingrecipe/fries
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/chips
	cookbonus = 7
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/cookingrecipe/bakedpotato
	item1 = /obj/item/reagent_containers/food/snacks/plant/potato
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/bakedpotato

/datum/cookingrecipe/hotdog
	item1 = /obj/item/reagent_containers/food/snacks/meatball
	amt1 = 2
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/hotdog

/datum/cookingrecipe/steak_h
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_h
	useshumanmeat = 1

/datum/cookingrecipe/steak_m
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_m

/datum/cookingrecipe/steak_s
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_s

/datum/cookingrecipe/steak_s
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/steak_s

/datum/cookingrecipe/fish_fingers
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/fish_fingers

/datum/cookingrecipe/bacon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon/raw
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon

/datum/cookingrecipe/pie_apple
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/apple
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/apple

/datum/cookingrecipe/pie_lime
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/lime
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/lime

/datum/cookingrecipe/pie_lemon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/lemon
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/lemon

/datum/cookingrecipe/pie_slurry
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/slurryfruit
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/slurry

/datum/cookingrecipe/pie_pumpkin
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/pumpkin
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/pumpkin

/datum/cookingrecipe/pie_strawberry
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/plant/strawberry
	amt2 = 2
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/pie/strawberry

/datum/cookingrecipe/pie_cream
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/cream

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/custom_pie_food
		for (var/obj/item/reagent_containers/food/snacks/S in ourCooker.contents)
			if (S.type == item1 || S.type == item2)
				continue

			custom_pie_food = S
			break

		if (!custom_pie_food)
			return null

		var/obj/item/reagent_containers/food/snacks/pie/cream/custom_pie = new
		custom_pie_food.reagents.trans_to(custom_pie, 50)
		if(custom_pie.real_name)
			custom_pie.name = "[custom_pie_food.real_name] cream pie"

		else
			custom_pie.name = "[custom_pie_food.name] cream pie"

		var/icon/I = new /icon('icons/obj/foodNdrink/food_dessert.dmi',"creampie")
		I.Blend(custom_pie_food.food_color, ICON_ADD)
		custom_pie.icon = I

		return custom_pie

/datum/cookingrecipe/pie_anything
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/anything

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/anItem
		var/obj/item/reagent_containers/food/snacks/pie/anything/custom_pie = new
		var/pieDesc
		var/pieName
		var/contentAmount = ourCooker.contents.len - 2
		var/count = 1
		var/found1 = 0
		var/found2 = 0
		for (var/obj/item/T in ourCooker.contents)

			if (T.type == item1 && !found1)
				found1 = true
				continue

			if (T.type == item2 && !found2)
				found2 = true
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

			count++

//		if (!anItem)
//			return null

		custom_pie.name = pieName + " pie"
		custom_pie.desc = "A pie containing [pieDesc]. Well alright then."

		var/icon/I = new /icon('icons/obj/foodNdrink/food_dessert.dmi',"pie")
		var/random_color = rgb(rand(1,255), rand(1,255), rand(1,255))
		I.Blend(random_color, ICON_ADD)
		custom_pie.icon = I

		return custom_pie

/datum/cookingrecipe/pie_custard
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/condiment/custard
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/pie/custard

/datum/cookingrecipe/pie_bacon
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/pie/bacon

/datum/cookingrecipe/pie_ass
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/clothing/head/butt
	cookbonus = 15
	output = /obj/item/reagent_containers/food/snacks/pie/ass

/datum/cookingrecipe/custard
	item1 = /obj/item/reagent_containers/food/drinks/milk
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/condiment/custard

/datum/cookingrecipe/gruel
	item1 = /obj/item/reagent_containers/food/snacks/yuck
	amt1 = 3
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/gruel

/datum/cookingrecipe/porridge
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	amt1 = 2
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/porridge

/datum/cookingrecipe/oatmeal
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/soup/oatmeal

/datum/cookingrecipe/tomsoup
	item1 = /obj/item/reagent_containers/food/snacks/plant/tomato
	amt1 = 2
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/soup/tomato

/datum/cookingrecipe/mint_chutney
	item1 = /obj/item/plant/herb/mint
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	item3 = /obj/item/reagent_containers/food/snacks/plant/garlic
	item4 = /obj/item/reagent_containers/food/snacks/plant/onion
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/mint_chutney

/datum/cookingrecipe/refried_beans
	item1 = /obj/item/reagent_containers/food/snacks/plant/bean
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/refried_beans

/datum/cookingrecipe/chili
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/chili

/datum/cookingrecipe/queso
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/soup/queso

/datum/cookingrecipe/superchili
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item2 = /obj/item/reagent_containers/food/snacks/plant/chili
	item3 = /obj/item/reagent_containers/food/snacks/condiment/hotsauce
	amt3 = 2
	cookbonus = 16
	output = /obj/item/reagent_containers/food/snacks/soup/superchili

/datum/cookingrecipe/ultrachili
	item1 = /obj/item/reagent_containers/food/snacks/soup/chili
	item2 = /obj/item/reagent_containers/food/snacks/soup/superchili
	item3 = /obj/item/reagent_containers/food/snacks/plant/chili
	item4 = /obj/item/reagent_containers/food/snacks/condiment/hotsauce
	cookbonus = 20
	output = /obj/item/reagent_containers/food/snacks/soup/ultrachili

/datum/cookingrecipe/salad
	item1 = /obj/item/reagent_containers/food/snacks/plant/lettuce
	amt1 = 2
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/salad

//Delightful Halloween Recipes
/datum/cookingrecipe/candy_apple
	item1 = /obj/item/reagent_containers/food/snacks/plant/apple/stick
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple

/datum/cookingrecipe/candy_apple_poison
	item1 = /obj/item/reagent_containers/food/snacks/plant/apple/stick/poison
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/candy/candy_apple/poison

//Cakes!
/datum/cookingrecipe/cake_batter
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt2 = 2
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/cake/batter

/datum/cookingrecipe/cake_cream
	item1 = /obj/item/reagent_containers/food/snacks/cake/batter
	item2 = /obj/item/reagent_containers/food/snacks/condiment/cream
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/cream

/datum/cookingrecipe/cake_chocolate
	item1 = /obj/item/reagent_containers/food/snacks/cake/batter
	item2 = /obj/item/reagent_containers/food/snacks/candy
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/chocolate

/datum/cookingrecipe/cake_meat
	item1 = /obj/item/reagent_containers/food/snacks/cake/batter
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/meat

/datum/cookingrecipe/cake_bacon
	item1 = /obj/item/reagent_containers/food/snacks/cake/batter
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/bacon
	amt2 = 3
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/bacon

/datum/cookingrecipe/cake_downs
	item1 = /obj/item/reagent_containers/food/snacks/cake/batter
	item2 = /obj/item/organ/brain
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/cake/downs

#ifdef XMAS

/datum/cookingrecipe/cake_fruit
	item1 = /obj/item/reagent_containers/food/snacks/yuckburn
	item2 = /obj/item/reagent_containers/food/snacks/yuck
	cookbonus = 14
	output = null

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var fruitcake = new /obj/item/reagent_containers/food/snacks/cake/fruit
		playsound(ourCooker.loc, "sound/effects/splat.ogg", 50, 1)

		return fruitcake

#endif

/datum/cookingrecipe/cake_custom
	item1 = /obj/item/reagent_containers/food/snacks/cake/batter
	cookbonus = 14
	output = null

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		var/obj/item/reagent_containers/food/snacks/cake/batter/docakeitem = locate() in ourCooker.contents
		if (!istype( docakeitem ))
			return null

		var/obj/item/reagent_containers/food/snacks/S = docakeitem.custom_item
		var/obj/item/reagent_containers/food/snacks/cake/custom/B = new /obj/item/reagent_containers/food/snacks/cake/custom(ourCooker)
		B.food_color = S ? S.food_color : "#F0F0F0"
		B.update_icon(0)
		if (S)
			S.reagents.trans_to(B, 50)
			B.food_effects += S.food_effects
			if(S.real_name)
				B.name = "[S.real_name] cake"

			else
				B.name = "[S.name] cake"
		else
			B.name = "[rand(50) ? "yellow" : "white"] cake"

		B.desc = "Mmm! A delicious-looking [B.name]!"
		return B


/datum/cookingrecipe/cake_custom_item
	item1 = /obj/item/reagent_containers/food/snacks/cake/cream
	cookbonus = 14
	output = null

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

/datum/cookingrecipe/mix_cake_custom
	item1 = /obj/item/reagent_containers/food/snacks/cake/batter
	amt1 = 1
	output = null

	specialOutput(var/obj/submachine/ourCooker)
		if (!ourCooker)
			return null

		for (var/obj/item/I in ourCooker.contents)
			if (istype(I, item1))
				continue
			else if (istype(I,/obj/item/reagent_containers/food/snacks/))
				/*
				var/obj/item/reagent_containers/food/snacks/S = I
				var/obj/item/reagent_containers/food/snacks/cake/custom/B = new /obj/item/reagent_containers/food/snacks/cake/custom(src.loc)
				B.food_color = S.food_color
				B.update_icon(0)
				S.reagents.trans_to(B, 50)
				if(S.real_name)
					B.name = "[S.real_name] cake"

				else
					B.name = "[S.name] cake"
				B.desc = "Mmm! A delicious-looking [B.name]!"
				*/
				var/obj/item/reagent_containers/food/snacks/cake/batter/batter = new

				batter.custom_item = I
				I.set_loc(batter)
				batter.name = "uncooked [I:real_name ? I:real_name : I.name] cake"
				for (var/obj/M in ourCooker.contents)
					qdel(M)

				return batter

		return null


/datum/cookingrecipe/omelette
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/omelette

/datum/cookingrecipe/omelette_bee
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg/bee
	amt1 = 2
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	cookbonus = 12
	output = /obj/item/reagent_containers/food/snacks/omelette/bee

/datum/cookingrecipe/pancake_batter
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough_s
	item2 = /obj/item/reagent_containers/food/drinks/milk
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt3 = 2
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/pancake_batter

/datum/cookingrecipe/pancake
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/pancake_batter
	cookbonus = 11
	output = /obj/item/reagent_containers/food/snacks/pancake

/datum/cookingrecipe/mashedpotatoes
	item1 = /obj/item/reagent_containers/food/snacks/plant/potato
	amt1 = 3
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/mashedpotatoes

/datum/cookingrecipe/mashedbrains
	item1 = /obj/item/organ/brain
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/mashedbrains

/datum/cookingrecipe/creamofmushroom
	item1 = /obj/item/reagent_containers/food/snacks/mushroom
	item2 = /obj/item/reagent_containers/food/drinks/milk
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom

/datum/cookingrecipe/creamofmushroom/amanita
	item1 = /obj/item/reagent_containers/food/snacks/mushroom/amanita
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/amanita

/datum/cookingrecipe/creamofmushroom/psilocybin
	item1 = /obj/item/reagent_containers/food/snacks/mushroom/psilocybin
	output = /obj/item/reagent_containers/food/snacks/soup/creamofmushroom/psilocybin

/datum/cookingrecipe/meatpaste
	item1 =  /obj/item/reagent_containers/food/snacks/ingredient/meat/
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste/

/datum/cookingrecipe/sloppyjoe
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	cookbonus = 13
	output = /obj/item/reagent_containers/food/snacks/burger/sloppyjoe

/datum/cookingrecipe/meatloaf
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meatpaste
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/meatloaf

/datum/cookingrecipe/cereal_honey
	item1 = /obj/item/reagent_containers/food/snacks/cereal_box
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/cereal_box/honey

/datum/cookingrecipe/granola_bar
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/granola_bar

/datum/cookingrecipe/hardboiled
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled

/datum/cookingrecipe/eggsalad
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/egg/hardboiled
	item2 = /obj/item/reagent_containers/food/snacks/salad
	item3 = /obj/item/reagent_containers/food/snacks/condiment/mayo
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/eggsalad

/datum/cookingrecipe/biscuit
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/flour
	cookbonus = 4
	output = /obj/item/reagent_containers/food/snacks/biscuit

/datum/cookingrecipe/hardtack
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/dough
	item2 = /obj/item/reagent_containers/food/snacks/condiment/ironfilings
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/hardtack

/datum/cookingrecipe/macguffin
	item1 = /obj/item/reagent_containers/food/snacks/emuffin
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/cheese
	item4 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	amt1 = 2
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/macguffin

/datum/cookingrecipe/haggis
	item1 = /obj/item/organ/
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/haggis

/datum/cookingrecipe/haggass
	item1 = /obj/item/clothing/head/butt
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/oatmeal
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	cookbonus = 18
	output = /obj/item/reagent_containers/food/snacks/haggis/ass

/datum/cookingrecipe/scotch_egg
	item1 = /obj/item/reagent_containers/food/snacks/breadslice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/meat/
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	cookbonus = 6
	output = /obj/item/reagent_containers/food/snacks/scotch_egg

/datum/cookingrecipe/rice_ball
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	cookbonus = 5
	output = /obj/item/reagent_containers/food/snacks/rice_ball

/datum/cookingrecipe/nigiri_roll
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	item2 = /obj/item/reagent_containers/food/snacks/rice_ball
	cookbonus = 2
	output = /obj/item/reagent_containers/food/snacks/nigiri_roll

/datum/cookingrecipe/sushi_roll
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	item2 = /obj/item/reagent_containers/food/snacks/rice_ball
	item3 = /obj/item/reagent_containers/food/snacks/rice_ball
	item4 = /obj/item/reagent_containers/food/snacks/ingredient/seaweed
	cookbonus = 2
	output = /obj/item/reagent_containers/food/snacks/sushi_roll

/datum/cookingrecipe/riceandbeans
	item1 = /obj/item/reagent_containers/food/snacks/plant/bean
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/riceandbeans

/datum/cookingrecipe/friedrice
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	item4 = /obj/item/reagent_containers/food/snacks/plant/garlic
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/friedrice

/datum/cookingrecipe/omurice
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/egg
	item3 = /obj/item/reagent_containers/food/snacks/condiment/ketchup
	cookbonus = 8
	output = /obj/item/reagent_containers/food/snacks/omurice

/datum/cookingrecipe/risotto
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/rice
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/butter
	item3 = /obj/item/reagent_containers/food/snacks/plant/onion
	item4 = /obj/item/reagent_containers/food/snacks/plant/garlic
	cookbonus = 10
	output = /obj/item/reagent_containers/food/snacks/risotto

// Recipe for zongzi is a WIP; we're gonna need rice balls or something

/datum/cookingrecipe/beefood
	item1 = /obj/item/reagent_containers/food/snacks/ingredient/honey
	item2 = /obj/item/plant/wheat
	item3 = /obj/item/reagent_containers/food/snacks/yuck
	cookbonus = 22
	output = /obj/item/reagent_containers/food/snacks/beefood

/datum/cookingrecipe/b_cupcake
	item1 = /obj/item/reagent_containers/food/snacks/beefood
	item2 = /obj/item/reagent_containers/food/snacks/ingredient/sugar
	item3 = /obj/item/reagent_containers/food/snacks/ingredient/royal_jelly
	item4 = /obj/item/device/light/candle/small
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

/datum/cookingrecipe/butters
	item1 = /obj/item/clothing/head/butt
	item2 = /obj/item/reagent_containers/food/drinks/milk
	cookbonus = 14
	output = /obj/item/reagent_containers/food/snacks/condiment/butters

/datum/cookingrecipe/lipstick
	item1 = /obj/item/pen/crayon
	item2 = /obj/item/item_box/figure_capsule
	cookbonus = 10
	output = /obj/item/pen/crayon/lipstick
