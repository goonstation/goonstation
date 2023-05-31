
/obj/item/reagent_containers/food/snacks/sandwich/
	icon = 'icons/obj/foodNdrink/food_bread.dmi'
	bites_left = 4
	heal_amt = 2
	var/hname = null
	var/job = null
	food_color = "#FFFFCC"
	custom_food = 0
	initial_volume = 30
	food_effects = list("food_refreshed")
	meal_time_flags = MEAL_TIME_LUNCH

	meat_h
		name = "manwich"
		desc = "Human meat between two slices of bread."
		icon_state = "sandwich_m"
		food_effects = list("food_refreshed", "food_energized_big")
		initial_reagents = list("bread"=10,"blood"=10)
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	meat_m
		name = "monkey sandwich"
		desc = "Meat between two slices of bread."
		icon_state = "sandwich_m"
		food_effects = list("food_refreshed", "food_energized")
		initial_reagents = list("bread"=10,"blood"=10)
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	pb
		name = "peanut butter sandwich"
		desc = "Peanut butter between two slices of bread."
		icon_state = "sandwich_p"
		food_effects = list("food_refreshed", "food_energized")
		initial_reagents = list("bread"=10)

	pbh
		name = "peanut butter and honey sandwich"
		desc = "Peanut butter and honey between two slices of bread."
		icon_state = "sandwich_p"
		initial_reagents = list("bread"=10,"honey"=10)
		food_effects = list("food_energized_big")

	meat_s
		name = "synthmeat sandwich"
		desc = "Synthetic meat between two slices of bread."
		icon_state = "sandwich_m"
		initial_reagents = list("bread"=10,"synthflesh"=10)
		food_effects = list("food_hp_up_big")

	cheese
		name = "cheese sandwich"
		desc = "Cheese between two slices of bread."
		icon_state = "sandwich_c"
		initial_reagents = list("bread"=10,"cheese"=2)
		food_effects = list("food_energized","food_hp_up")

	blt
		name = "BLT sandwich"
		desc = "Crunchy bacon, lettuce, and tomato between two slices of bread."
		icon_state = "sandwich_blt"
		initial_reagents = list("bread"=10,"juice_tomato"=2,"cholesterol"=3,"porktonium"=3)
		food_effects = list("food_refreshed", "food_energized_big")

	c_butty
		name = "chip butty"
		desc = "French fries and ketchup between two slices of bread."
		icon_state = "c_butty"
		initial_reagents = list("innitium"=25,"ketchup"=20)
		food_effects = list("food_sweaty", "food_energized_big")

	elvis_meat_h
		name = "elvismanwich"
		desc = "Human meat between two slices of elvis bread."
		icon_state = "elviswich_m"
		initial_reagents = list("essenceofelvis"=25,"blood"=10)
		food_effects = list("food_refreshed", "food_energized_big")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	elvis_meat_m
		name = "monkey elviswich"
		desc = "Meat between two slices of elvis bread."
		icon_state = "elviswich_m"
		initial_reagents = list("essenceofelvis"=25,"blood"=10)
		food_effects = list("food_refreshed", "food_energized")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	elvis_pb
		name = "peanut butter elviswich"
		desc = "Peanut butter between two slices of elvis bread."
		icon_state = "elviswich_p"
		initial_reagents = list("essenceofelvis"=25)
		food_effects = list("food_refreshed", "food_energized")

	elvis_pbh
		name = "peanut butter and honey elviswich"
		desc = "Peanut butter and honey between two slices of elvis bread."
		icon_state = "elviswich_p"
		initial_reagents = list("essenceofelvis"=15,"honey"=10)
		food_effects = list("food_refreshed", "food_energized_big")

	elvis_meat_s
		name = "synthmeat elviswich"
		desc = "Synthetic meat between two slices of elvis bread."
		icon_state = "elviswich_m"
		initial_reagents = list("essenceofelvis"=25,"synthflesh"=10)
		food_effects = list("food_hp_up_big")

	elvis_cheese
		name = "cheese elviswich"
		desc = "Cheese between two slices of elvis bread."
		icon_state = "elviswich_c"
		initial_reagents = list("essenceofelvis"=20,"cheese"=2)
		food_effects = list("food_energized","food_hp_up")

	elvis_blt
		name = "BLT elviswich"
		desc = "Crunchy bacon, lettuce, and tomato between two slices of elvis bread."
		icon_state = "elviswich_blt"
		initial_reagents = list("essenceofelvis"=20,"juice_tomato"=2,"cholesterol"=3,"porktonium"=3)
		food_effects = list("food_refreshed", "food_energized_big")

	spooky_cheese
		name = "killed cheese sandwich"
		desc = "Cheese that has been murdered and buried in a hasty grave of dread."
		icon_state = "scarewich_c"
		initial_reagents = list("ectoplasm"=15,"cheese"=2)
		food_effects = list("food_energized","food_hp_up")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	spooky_pb
		name = "peanut butter and jelly meet breadula"
		desc = "It's probably rather frightening if you have a nut allergy."
		icon_state = "scarewich_pb"
		initial_reagents = list("ectoplasm"=15,"eyeofnewt"=10)
		food_effects = list("food_energized","food_hp_up")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	spooky_pbh
		name = "killer beenut butter sandwich"
		desc = "A peanut butter sandwich with a terrifying twist: Honey!"
		icon_state = "scarewich_pb"
		initial_reagents = list("ectoplasm"=10,"tongueofdog"=5,"honey"=10)
		food_effects = list("food_energized","food_hp_up")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	spooky_meat_h
		name = "murderwich"
		desc = "Dawn of the bread."
		icon_state = "scarewich_m"
		initial_reagents = list("ectoplasm"=15,"blood"=10)
		food_effects = list("food_hp_up_big","food_energized_big")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	spooky_meat_m
		name = "scare wich project"
		desc = "What's a ghost's favorite sandwich meat? BOO-loney!"
		icon_state = "scarewich_m"
		initial_reagents = list("ectoplasm"=15,"blood"=10)
		food_effects = list("food_hp_up_big")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	spooky_meat_s
		name = "synthmeat steinwich"
		desc = "A dreadful sandwich of flesh borne not of man or beast, but of twisted science."
		icon_state = "scarewich_m"
		initial_reagents = list("ectoplasm"=15,"synthflesh"=10)
		food_effects = list("food_hp_up_big")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	spooky_blt
		name = "Boo-LT"
		desc = "Cursed yet crunchy bacon, lettuce, and tomato between two slices of dread. It whispers false promises of a healthy meal, in spite of the bacon."
		icon_state = "scarewich_blt"
		initial_reagents = list("ectoplasm"=15,"juice_tomato"=2,"cholesterol"=3,"porktonium"=3)
		food_effects = list("food_refreshed", "food_energized_big")
		meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	meatball
		name = "meatball sub"
		desc = "A submarine sandwich consisting of meatballs, cheese, and marinara sauce."
		icon_state = "meatball_sub"
		bites_left = 6
		heal_amt = 4
		food_effects = list("food_hp_up_big", "food_energized_big")

	eggsalad
		name = "egg-salad sandwich"
		desc = "The magnum opus of egg based sandwiches."
		icon_state = "sandwich_egg"
		food_effects = list("food_cateyes", "food_hp_up_big")

	banhmi
		name = "banh mi"
		desc = "Sometimes known as a Vietnamese sub. These are hard to make!"
		icon_state = "banh_mi"
		food_effects = list("food_energized_big", "food_hp_up_big")

		New()
			..()
			reagents.add_reagent("honey", 10)

/obj/item/reagent_containers/food/snacks/burger
	name = "burger"
	desc = "A burger."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "hburger"
	item_state = "burger"
	bites_left = 5
	heal_amt = 2
	food_color ="#663300"
	initial_volume = 25
	initial_reagents = list("cholesterol"=5)
	food_effects = list("food_hp_up", "food_warm")

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/condiment/))
			src.bites_left += 1
		else
			return ..()

/obj/item/reagent_containers/food/snacks/burger/buttburger
	name = "buttburger"
	desc = "This burger's all buns."
	icon_state = "assburger"
	initial_reagents = list("fartonium"=10)
	food_effects = list("food_sweaty_big")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT
	New()
		..()
		if(prob(10))
			name = pick("cleveland steamed ham","very sloppy joe","buttconator","bootyburg","quarter-mooner","ass whooper","hambuttger","big crack")


/obj/item/reagent_containers/food/snacks/burger/heartburger
	name = "heartburger"
	desc = "A hearty meal, made with Love."
	icon_state = "heartburger"
	food_effects = list("food_sweaty_big", "food_hp_up_big")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

	New()
		..()
		reagents.add_reagent("love", 15)

/obj/item/reagent_containers/food/snacks/burger/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	initial_reagents = list("cholesterol"=5,"prions"=10)
	food_effects = list("food_sweaty_big", "food_hp_up_big", "brain_food_ithillid")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

/obj/item/reagent_containers/food/snacks/burger/humanburger
	name = "burger"
	var/hname = ""
	desc = "A bloody burger."
	icon_state = "hburger"
	food_effects = list("food_energized_big", "food_brute")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

/obj/item/reagent_containers/food/snacks/burger/monkeyburger
	name = "monkeyburger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	food_effects = list("food_energized", "food_brute")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

/obj/item/reagent_containers/food/snacks/burger/butterburger
	name = "butter burger"
	desc = "Two heart attacks in one sloppy mess."
	icon_state = "butterburger"
	initial_reagents = list("cholesterol"=5,"butter"=10)
	food_effects = list("food_all", "food_sweaty")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/fishburger
	name = "Fish-Fil-A"
	desc = "A delicious alternative to heart-grinding beef patties."
	icon_state = "fishburger"
	food_effects = list("food_energized", "food_burn")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/moldy
	name = "moldy burger"
	desc = "A rather disgusting looking burger."
	icon_state ="moldyburger"
	bites_left = 1
	heal_amt = 1
	food_effects = list("food_bad_breath")

	heal(var/mob/M)
		boutput(M, "<span class='alert'>Oof, how old was that?</span>")
		if(prob(66))
			M.reagents.add_reagent("salmonella",15)
		..()

/obj/item/reagent_containers/food/snacks/burger/plague
	name = "burgle"
	desc = "The plagueburger."
	icon_state = "moldyburger"
	bites_left = 1
	heal_amt = 1
	initial_volume = 15
	initial_reagents = null
	var/roundstart_pathogens = 1

	New()
		..()
		if(roundstart_pathogens)
			wrap_pathogen(reagents, generate_random_pathogen(), 15)

	fishstick
		roundstart_pathogens = 0
		pickup(mob/user)
			if(isadmin(user) || current_state == GAME_STATE_FINISHED)
				wrap_pathogen(reagents, generate_random_pathogen(), 15)
			else
				boutput(user, "<span class='notice'>You feel that it was too soon for this...</span>")
			. = ..()


/obj/item/reagent_containers/food/snacks/burger/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	bites_left = 3
	heal_amt = 1
	food_color = "#C8C8C8"
	brew_result = "beepskybeer"
	initial_reagents = list("cholesterol"=5,"nanites"=20)

/obj/item/reagent_containers/food/snacks/burger/cheeseborger
	name = "cheeseborger"
	desc = "The cheese really helps smooth out the metallic flavor."
	icon_state = "cheeseborger"
	bites_left = 3
	heal_amt = 1
	food_color = "#C8C8C8"
	brew_result = "beepskybeer"
	initial_reagents = list("cholesterol"=5,"nanites"=20)

/obj/item/reagent_containers/food/snacks/burger/synthburger
	name = "synthburger"
	desc = "A thoroughly artificial snack."
	icon_state = "hburger"
	bites_left = 5
	heal_amt = 2
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/baconburger
	name = "baconatrix"
	desc = "The official food of the Lunar Football League! Also possibly one of the worst things you could ever eat."
	icon_state = "baconburger"
	bites_left = 5
	heal_amt = 1
	initial_volume = 50
	initial_reagents = list("cholesterol"=5,"porktonium"=45)
	food_effects = list("food_hp_up_big", "food_sweaty")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

	heal(var/mob/M)
		if(prob(25))
			M.nutrition += 100
		..()

/obj/item/reagent_containers/food/snacks/burger/sloppyjoe
	name = "sloppy joe"
	desc = "A rather messy burger."
	icon_state = "sloppyjoe"
	bites_left = 5
	heal_amt = 2
	food_effects = list("food_hp_up_big", "food_sweaty")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

	heal(var/mob/M)
		if(prob(20))
			var/obj/decal/cleanable/blood/gibs/gib = make_cleanable(/obj/decal/cleanable/blood/gibs, get_turf(src) )
			gib.streak_cleanable(M.dir)
			boutput(M, "<span class='alert'>You drip some meat on the floor</span>")
			M.visible_message("<span class='alert'>[M] drips some meat on the floor!</span>")
			playsound(M.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

		else
			..()

/obj/item/reagent_containers/food/snacks/burger/mysteryburger
	name = "dubious burger"
	desc = "A burger of indeterminate meat type."
	icon_state = "mysteryburger"
	bites_left = 5
	heal_amt = 1
	food_effects = list("food_bad_breath", "food_hp_up_big")

	heal(var/mob/M)
		if(prob(8))
			var/effect = rand(1,4)
			switch(effect)
				if(1)
					boutput(M, "<span class='alert'>Ugh. Tasted all greasy and gristly.</span>")
					M.nutrition += 20
				if(2)
					boutput(M, "<span class='alert'>Good grief, that tasted awful!</span>")
					M.take_toxin_damage(2)
				if(3)
					boutput(M, "<span class='alert'>There was a cyst in that burger. Now your mouth is full of pus OH JESUS THATS DISGUSTING OH FUCK</span>")
					M.visible_message("<span class='alert'>[M] suddenly and violently vomits!</span>")
					M.vomit(20)
				if(4)
					boutput(M, "<span class='alert'>You bite down on a chunk of bone, hurting your teeth.</span>")
					random_brute_damage(M, 2)
		..()

/obj/item/reagent_containers/food/snacks/burger/cheeseburger
	name = "cheeseburger"
	desc = "Tasty, but not particularly healthy."
	icon_state = "cburger"
	bites_left = 6
	heal_amt = 2
	initial_volume = 50
	initial_reagents = list("cholesterol"=10,"cheese"=1)
	food_effects = list("food_brute", "food_burn")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/wcheeseburger
	name = "weird cheeseburger"
	desc = "You're not sure if you should eat this, considering the green hue of what you assume to be the cheese."
	icon_state = "wcburger"
	bites_left = 6
	heal_amt = 2
	initial_volume = 50
	initial_reagents = list("mercury"=1,"LSD"=1,"ethanol"=1,"gcheese"=1,"yuck"=5,"cholesterol"=10)
	food_effects = list("food_tox","food_sweaty","food_bad_breath","food_deep_burp")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/cheeseburger_m
	name = "monkey cheese burger"
	desc = "How very dadaist."
	icon_state = "cburger-monkey"
	bites_left = 6
	heal_amt = 2
	initial_volume = 50
	initial_reagents = list("cholesterol"=10,"cheese"=5)
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	heal(var/mob/M)
		if(prob(3) && ishuman(M))
			boutput(M, "<span class='alert'>You wackily and randomly turn into a lizard.</span>")
			M.set_mutantrace(/datum/mutantrace/lizard)
			M:update_face()
			M:update_body()

		if(prob(3))
			boutput(M, "<span class='alert'>You wackily and randomly turn into a monkey.</span>")
			M:monkeyize()

		..()

/obj/item/reagent_containers/food/snacks/burger/bigburger
	name = "Coronator"
	desc = "The king of burgers. You can feel your digestive system shutting down just LOOKING at it."
	icon_state = "bigburger"
	bites_left = 10
	heal_amt = 5
	initial_volume = 100
	initial_reagents = list("cholesterol"=50)
	food_effects = list("food_hp_up_big", "food_sweaty_big")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/monsterburger
	name = "THE MONSTER"
	desc = "There are no words to describe the sheer unhealthiness of this abomination."
	icon_state = "giantburger"
	bites_left = 1
	heal_amt = 50
	throwforce = 10
	initial_volume = 330
	initial_reagents = list("cholesterol"=200)
	unlock_medal_when_eaten = "That's no moon, that's a GOURMAND!"
	food_effects = list("food_hp_up_big", "food_sweaty_big", "food_bad_breath", "food_warm")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

/obj/item/reagent_containers/food/snacks/burger/aburgination
	name = "aburgination"
	desc = "You probably shouldn't eat it. You probably will."
	icon_state = "aburgination"
	initial_reagents = list("cholesterol" = 5, "neurotoxin" = 20, "bloodc" = 10)
	food_effects = list("food_hp_up_big", "food_sweaty_big")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

	New()
		..()
		playsound(get_turf(src), 'sound/voice/creepyshriek.ogg', 50, vary = FALSE, pitch = 4) // alvling and the lingmunks //shoot me

	take_a_bite(mob/consumer, mob/feeder)
		if (prob(50))
			consumer.visible_message("<span class='alert'>[consumer] tries to take a bite of [src], but [src] takes a bite of [consumer] instead!</span>",
				"<span class='alert'>You tries to take a bite of [src], but [src] takes a bite of you instead!</span>",
				"<span class='alert'>You hear something bite down.</span>")
			playsound(get_turf(feeder), pick('sound/impact_sounds/Flesh_Tear_1.ogg', 'sound/impact_sounds/Flesh_Tear_2.ogg'), 50, 1, -1)
			random_brute_damage(consumer, rand(5, 15), FALSE)
			take_bleeding_damage(consumer, null, rand(5, 15), DAMAGE_BLUNT)
			hit_twitch(consumer)
		else
			return ..()

/obj/item/reagent_containers/food/snacks/burger/vr
	icon = 'icons/effects/VR.dmi'

/obj/item/reagent_containers/food/snacks/fries
	name = "fries"
	desc = "Lightly salted potato fingers."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "fries"
	bites_left = 6
	heal_amt = 1
	initial_volume = 5
	initial_reagents = list("cholesterol"=1)
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_SNACK

/obj/item/reagent_containers/food/snacks/macguffin
	name = "sausage macguffin"
	desc = "You might want to start over, I'm not exactly lovin' it."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "macguffin"
	bites_left = 4
	heal_amt = 1
	initial_reagents = list("cholesterol"=1)
	meal_time_flags = MEAL_TIME_BREAKFAST

/obj/item/reagent_containers/food/snacks/burger/luauburger
	name = "luau burger"
	desc = "You can already taste the fresh, sweet pineapple."
	icon_state = "luauburger"
	food_effects = list("food_refreshed_big", "food_hp_up")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/tikiburger
	name = "tiki burger"
	desc = "A burger straight out of Hawaii"
	icon_state = "tikiburger"
	food_effects = list("food_refreshed_big", "food_hp_up")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/coconutburger
	name = "coconut burger"
	desc = "Wait a minute... this has no real meat in it."
	icon_state = "coconutburger"
	food_effects = list("food_refreshed_big", "food_hp_up")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/chicken
	name = "chicken sandwich"
	desc = "A delicious chicken sandwich."
	icon_state = "chickenburger"
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/obj/item/reagent_containers/food/snacks/burger/chicken/spicy
	name = "spicy chicken sandwich"
	desc = "A delicious chicken sandwich with a bit of a kick."
	icon_state = "chickenburger-spicy"
	initial_reagents = list("capsaicin"=15)
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

/* Notes for Nex
(If you're reading this, I made a booboo and forgot to remove these notes before making a PR)

GOD MOST OF THIS HEADACHE WOULD BE RESOLVED IF I CAVED IN AND MADE IT IMPOSSIBLE TO DISASSEMBLE BURGERS ONCE MADE BUT I *REFUSE*.


- Needs subtypes that will on New() give it specific ingredients and a specific name
- REMEMBER THE SUMMARY YOU TYPED UP AND PUT IN DMS/IMCODER FOR AN OUTLINE YOU DWEEB




*/

/obj/item/reagent_containers/food/snacks/new_sandwich //todo: make better name and/or get rid of old sandwiches/burgers
	// icon_state remains null since these sandwiches/burgers will consist entirely of overlays
	icon = 'icons/obj/foodNdrink/food_meals.dmi' // temp
	icon_state = "cburger" // temp
	name = "incomplete sandwich" // needs a better name, and should change based on bread/buns and ingredients used!
	desc = "An edible device consisting of 2 or more structural agents encasing a nutrient payload stack. It's a fucking sandwich, dingus."
	/// Specifies what the sandwich should be made of when directly spawned in with New()
	/// Ingredients should be listed from bottom to top of the sandwich
	var/list/initial_ingredients = null /*(snacks/ingredients/bun_bottom, snacks/ingredients/pattycooked, snacks/ingredients/bun_top)*/
	/// An assoc list storing each ingredient of the sandwich as atom || number
	/// The decimal value 0-1 represents how much of an ingredient is left as a %
	// NOTE: Possibly have it so that it's actually atom || list(%, initial buffs)?
	// Used to keep track of what the initial food effects from a food item were before being adjusted!
	var/list/ingredients = list()
	/// Numerical value that provides a simulacrum of initial(bites_left)
	var/max_bites_left = null // bites_left is dynamic here, so we can't just call initial for calculations
	/// Breads/buns/whatever that you can only place ingredients onto
	var/static/bottom_bread_types = list()
	/// Breads/buns/whatever that can only be put on top of an incomplete sandwich
	var/static/top_bread_types = list()
	/// Breads/buns/whatever that can be used as both base and top, and can be used for dagwoods
	var/static/vers_bread_types = list(/obj/item/reagent_containers/food/snacks/breadslice)
	/// Has setup() been called yet?
	var/setup_called = FALSE
	/// Do we have a top slice/bun, and thus are we able to be eaten?
	var/complete = FALSE
	var/static/icon/ingredient_spritesheet = '/icons/obj/foodNdrink/burgers.dmi'
	/// Assoc list of types || image, intended to specify what image to select for a given ingredient's overlay
	/// Certain things, like buns, bread, and patties will use their normal icons as their overlays, and as such shouldn't be in this list
	var/static/ingredient_sprites = list( // NOTE: list incomplete, not all ingredients added yet, be sure to add when done with feature development thanks
		/obj/item/reagent_containers/food/snacks/ingredient/butter = image(ingredient_spritesheet, "overlay_butter"),
		/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon = image(ingredient_spritesheet, "overlay_bacon"),
		/obj/item/reagent_containers/food/snacks/ingredient/meatpaste = image(ingredient_spritesheet, "overlay_meatpaste"),
		/obj/item/reagent_containers/food/snacks/ingredient/pepperoni = image(ingredient_spritesheet, "overlay_pepperoni"),
		/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice = image(ingredient_spritesheet, "overlay_tomato"),
		/obj/item/reagent_containers/food/snacks/ingredient/onion_slice = image(ingredient_spritesheet, "overlay_onion"),
		/obj/item/reagent_containers/food/snacks/plant/lettuce = image(ingredient_spritesheet, "overlay_lettuce"),
		/obj/item/reagent_containers/food/snacks/ingredient/meat/steak_m = image(ingredient_spritesheet, "overlay_steak"),
		/obj/item/reagent_containers/food/snacks/ingredient/meat/steak_h = image(ingredient_spritesheet, "overlay_steak")
		)
	/// The .dmi file containing all the relevant sprites. Makes it easier to move the file. I guess.
	/// Probably gonna remove this.


	New()
		. = ..()
		SPAWN(1 SECOND)
			if(!setup_called)
				src.setup() // We do this so spawned in sandwiches will Actually Exist
			// But, we wanna make sure whatever called New() has a chance to call setup()

	/// Sets up the sandwich. Automatically called by New() but calling it again will reset the sandwich.
	/// Unless overridden, do_initial_ingredients spawns the sandwich with the ingredients specified in initial_ingredients
	/// Provide an ingredient_list[] list of types and/or atoms to make a sandwich out of, in the provided order from bottom to top
	/// base is for the piece of bread (or other valid sandwich vessel) you're slapping with something to make a sandwich
	/// first_ingredient is the something you're slapping that piece of bread with
	proc/setup(var/mob/user, var/do_initial_ingredients = TRUE, var/list/ingredient_list, var/obj/item/base, var/obj/item/first_ingredient) // change to TRUE when functioning pls
		src.setup_called = TRUE
		if (do_initial_ingredients || ingredient_list)
			return // TEMPORARY
		if (!base || !first_ingredient)
			return // how did we get here?
		src.add_ingredient(user, base, TRUE)
		src.add_ingredient(user, first_ingredient)


	/// Adds an ingredient to the top of the sandwich.
	/// starting_sandwich suppresses the "You've added [x] to the [src]!" alert
	proc/add_ingredient(var/mob/user, var/obj/item/ingredient2add, var/starting_sandwich = FALSE)
		if(!ingredient2add)
			return // don't wanna risk a null value being added ig
		if(ingredient2add.type in bottom_bread_types) // what monster would put a bottom bun on top of their sandwich >:(
			boutput(user, "<span class='alert'>Hey stop that, you can only use [ingredient2add] as a sandwich base!</span>")
			return
		if(src.complete)
			var/x = src.ingredients.len // just to get the last entry in the list, which should be the top bun/slice
			var/obj/item/top_ingredient = src.ingredients[x]
			if((top_ingredient.type in src.top_bread_types))
				boutput(user, "<span class='alert'>You can't put anything else on top, take off \the [top_ingredient] to add anything else!</span>")
				return // yes i could've done && here and i tried that but when adding the first ingredient the len = 0 results in an oob exception god i wish oob just returned a null value
		var/obj/item/reagent_containers/food/snacks/food2add
		if(istype(ingredient2add, /obj/item/reagent_containers/food/snacks))
			complete = FALSE // if we're doing a dagwood and adding new ingredients, it's not properly assembled yet!
			food2add = ingredient2add
			var/max_amount = initial(food2add.bites_left)
			var/amount_left = food2add.bites_left / max_amount // We need to know this in order to recalculate heal_amt once bites_left is adjusted
			var/buffs = food2add.food_effects
			src.ingredients[food2add] = list(amount_left, buffs)
			user.drop_item(food2add)
			food2add.set_loc(src)
			if((food2add.type in top_bread_types) || (food2add.type in vers_bread_types) && !starting_sandwich)
				src.simulate_sandwich() // Simulating involves a couple loops that go through all ingredients, so we only wanna do it when we're ready to be eaten
				src.name_sandwich()
				src.complete = TRUE
				src.name = src.name_sandwich()
				boutput(user, "<span class='alert'>You finish assembling \the [src]!</span>")
			else
				boutput(user, "<span class='alert'>You add [food2add] to \the [src]!</span>")
			src.render_sandwich()
		else
			return // temporary, add functionality for non-food items later pl0x

/*
1. Tally up the amount of bites_left across all ingredients and multiply them by the % left
2. Divide that by 3 and round up
3. Set bites_left for both the burger and all ingredients to the resulting integer
4. For each ingredient:
 a) Get initial(bites_left) * initial(heal_amt)
 b) Multiply by % left
 c) Divide by bites_left
 d) Set heal_amt to that figure
 e) Repeat process but for each of a food's buffs
*/

	/// Updates the bites_left and heal_amt vars for the sandwich and its ingredients
	proc/simulate_sandwich()
		var/total_bites_left = 0
		for (var/obj/item/reagent_containers/food/snacks/ingredient in src.ingredients)
			total_bites_left += ingredient.bites_left * src.ingredients[ingredient][1]
		src.bites_left = ceil(total_bites_left / 3)
		// This math is for adjusting heal_amt so that when you finish eating, each ingredient would've healed you the same as if you ate it alone
		// Same for buffs. This is a lot of checking/processing for a loop so try not to call this too often.
		for (var/obj/item/reagent_containers/food/snacks/ingredient in src.ingredients)
			var/healing = initial(ingredient.bites_left) * initial(ingredient.heal_amt)
			healing *= ingredients[ingredient][1]
			ingredient.bites_left = src.bites_left
			healing /= ingredient.bites_left
			ingredient.heal_amt = healing
			var/buff_time
			var/buffs = src.ingredients[ingredient][2]
			for (var/effect in buffs)
				if(!isnull(buffs[effect]))
					buff_time = buffs[effect]
				else
					buff_time = 1 MINUTE // currently the default buff time
				buff_time *= initial(ingredient.bites_left)
				buff_time *= ingredients[ingredient][1]
				buff_time /= ingredient.bites_left
				ingredient.food_effects[effect] = buff_time

	/// By default only adds an overlay for the last ingredient in src.ingredients
	/// Set reset_overlays to TRUE to clear all overlays and recreate them
	// Note: Each overlay key is based on its corresponding ingredient's position in the ingredients list
	// e.g the key for the 3rd item in the list would be "ingredient3" or something
	proc/render_sandwich(var/reset_overlays = FALSE)
		var/ingredients2render = list()
		if(!reset_overlays)
			var/x = src.ingredients.len
			if(!(x > 0))
				return // avoids runtimes from oob exceptions, as a precaution
			ingredients2render += src.ingredients[x]
		for (var/obj/item/ingredient in ingredients2render)
			SafeGetOverlayImage()


	/// Generates a name for a sandwich based on its contents
	proc/name_sandwich()
		return "hamburgrer" // fix

	proc/remove_ingredient()

	attackby(obj/item/W, mob/user)
		. = ..()
		src.add_ingredient(user, W, FALSE)

	take_a_bite(var/mob/consumer, var/mob/feeder, var/suppress_messages = FALSE)
		if (!src.complete)
			boutput(consumer, "<span class='alert'>You can't eat [src], it's not complete!</span>")
			return
		for (var/obj/item/reagent_containers/food/snacks/ingredient in src.ingredients)
			src.ingredients[ingredient][1] -= src.ingredients[ingredient][1] / ingredient.bites_left
			ingredient.take_a_bite(consumer, feeder, TRUE)
		..()
