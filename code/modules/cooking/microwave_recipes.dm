// god damn it
// TODO: make microwaves use /datum/cookingRecipe, somehow
// possibly reclaim /datum/recipe
/datum/recipe_m
	var/egg_amount = 0
	var/flour_amount = 0
	var/water_amount = 0
	var/monkeymeat_amount = 0
	var/humanmeat_amount = 0
	var/synthmeat_amount = 0 //temporary, but whatever!
	var/donkpocket_amount = 0
	var/obj/extra_item = null // This is if an extra item is needed, eg a butte for an buttburger
	var/creates = "" // The item that is spawned when the recipe is made

/datum/recipe_m/donut
	egg_amount = 1
	flour_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/donut"

/datum/recipe_m/monkeyburger
	egg_amount = 0
	flour_amount = 1
	monkeymeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/burger/monkeyburger"

/datum/recipe_m/synthburger
	egg_amount = 0
	flour_amount = 1
	synthmeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/burger/synthburger"

/datum/recipe_m/humanburger
	flour_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/burger/humanburger"

/datum/recipe_m/brainburger
	flour_amount = 1
	extra_item = /obj/item/organ/brain
	creates = "/obj/item/reagent_containers/food/snacks/burger/brainburger"

/datum/recipe_m/buttburger
	flour_amount = 1
	extra_item = /obj/item/clothing/head/butt
	creates = "/obj/item/reagent_containers/food/snacks/burger/buttburger"

/datum/recipe_m/roburger
	flour_amount = 1
	extra_item = /obj/item/parts/robot_parts/head
	creates = "/obj/item/reagent_containers/food/snacks/burger/roburger"

/datum/recipe_m/heartburger
	flour_amount = 1
	extra_item = /obj/item/organ/heart
	creates = "/obj/item/reagent_containers/food/snacks/burger/heartburger"

/datum/recipe_m/waffles
	egg_amount = 2
	flour_amount = 2
	creates = "/obj/item/reagent_containers/food/snacks/waffles"

/datum/recipe_m/meatball
	monkeymeat_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/meatball"

/datum/recipe_m/pie
	flour_amount = 2
	extra_item = /obj/item/reagent_containers/food/snacks/plant/banana
	creates = "/obj/item/reagent_containers/food/snacks/pie/custard"

/datum/recipe_m/donkpocket
	flour_amount = 1
	extra_item = /obj/item/reagent_containers/food/snacks/meatball
	creates = "/obj/item/reagent_containers/food/snacks/donkpocket"

/datum/recipe_m/donkpocket_warm
	donkpocket_amount = 1
	creates = "/obj/item/reagent_containers/food/snacks/donkpocket"

/datum/recipe_m/popcorn
	extra_item = /obj/item/reagent_containers/food/snacks/plant/corn
	creates = "/obj/item/reagent_containers/food/snacks/popcorn"

/datum/recipe_m/butterburger
	flour_amount = 1
	extra_item = /obj/item/reagent_containers/food/snacks/ingredient/butter
	creates = "/obj/item/reagent_containers/food/snacks/burger/butterburger"
