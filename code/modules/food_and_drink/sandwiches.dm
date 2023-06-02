
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
	desc = "This burger's all buns. It seems to be made out of a gross normal butt."
	icon_state = "assburger"
	initial_reagents = list("fartonium"=10)
	food_effects = list("food_sweaty_big")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT
	New()
		..()
		if(prob(10))
			name = pick("cleveland steamed ham","very sloppy joe","buttconator","bootyburg","quarter-mooner","ass whooper","hambuttger","big crack")

/obj/item/reagent_containers/food/snacks/burger/buttburger/synth
	name = "buttburger"
	desc = "This burger's all buns. It seems to be made out of a green synthetic butt."
	icon_state = "synthbuttburger"

/obj/item/reagent_containers/food/snacks/burger/buttburger/cyber
	name = "buttburger"
	desc = "This burger's all buns. It seems to made out of a cybernetic butt."
	icon_state = "robobuttburger"

/obj/item/reagent_containers/food/snacks/burger/heartburger
	name = "heartburger"
	desc = "A hearty meal, made with Love. This one seems to contain a normal fleshy heart."
	icon_state = "heartburger"
	food_effects = list("food_sweaty_big", "food_hp_up_big")
	meal_time_flags = MEAL_TIME_LUNCH | MEAL_TIME_DINNER

	New()
		..()
		reagents.add_reagent("love", 15)

/obj/item/reagent_containers/food/snacks/burger/heartburger/synth
	name = "heartburger"
	desc = "A hearty meal, made with Love. This one seems to contain a green synthetic heart."
	icon_state = "synthheartburger"

/obj/item/reagent_containers/food/snacks/burger/heartburger/cyber
	name = "heartburger"
	desc = "A hearty meal, made with Love. This one seems to contain a shiny cyberheart."
	icon_state = "roboheartburger"

/obj/item/reagent_containers/food/snacks/burger/heartburger/flock
	name = "heartburger"
	desc = "A hearty meal, made with Love. This one seems to cotain a teal pulsing octahedron."
	icon_state = "flockheartburger"

/obj/item/reagent_containers/food/snacks/burger/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient. It seems to contain a normal fleshy Brain."
	icon_state = "brainburger"
	initial_reagents = list("cholesterol"=5,"prions"=10)
	food_effects = list("food_sweaty_big", "food_hp_up_big", "brain_food_ithillid")
	meal_time_flags = MEAL_TIME_FORBIDDEN_TREAT

/obj/item/reagent_containers/food/snacks/burger/brainburger/synth
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient. It seems to contain a green synthetic brain."
	icon_state = "synthbrainburger"

/obj/item/reagent_containers/food/snacks/burger/brainburger/cyber
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient. It seems to contain a Spontaneous Intelligence Creation Core."
	icon_state = "robobrainburger"

/obj/item/reagent_containers/food/snacks/burger/brainburger/flock
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient. It seems to contain an odd crystal."
	icon_state = "flockbrainburger"

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
	icon_state = "synthburger"
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
					var/vomit_message = "<span class='alert'>[M.name] suddenly and violently vomits!</span>"
					M.vomit(20, null, vomit_message)
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
	bites_left = 20
	heal_amt = 3
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


==HOW TO HANDLE REAGENTS/CONDIMENTS????==
Idea: Have assoc list of ingredient || reagent, maybe in the ingredients list
When rendering an ingredient with a reagent value, put another overlay with the overlay_chem icon_state for that reagent on top of the ingredient
If the ingredient is removed, dump the reagents into the ingredient

This is actually lowkey simple, fuck yeah

*/

/obj/item/reagent_containers/food/snacks/new_sandwich //todo: make better name and/or get rid of old sandwiches/burgers
	// icon_state remains null since these sandwiches/burgers will consist entirely of overlays
	name = "incomplete sandwich" // needs a better name, and should change based on bread/buns and ingredients used!
	desc = "An edible device consisting of 2 or more structural agents encasing a nutrient payload. It's just a fucking sandwich, dingus."
	bites_left = 0 // Prevents bite masks from being applied from on_bite(), so we can use our own special ones

	/// Specifies what the sandwich should be made of when directly spawned in with New()
	/// Ingredients should be listed from bottom to top of the sandwich
	var/list/initial_ingredients = null /*(snacks/ingredients/bun_bottom, snacks/ingredients/pattycooked, snacks/ingredients/bun_top)*/
	/// List of all ingredient datums
	var/list/ingredients = list()
	/// Keeps track of what our actual reagents datum is
	var/datum/reagents/original_reagents = null
	/// Numerical value that provides a simulacrum of initial(bites_left)
	var/max_bites_left = null // bites_left is dynamic here, so we can't just call initial for calculations
	/// Breads/buns/whatever that you can only place ingredients onto
	var/static/bottom_bread_types = list(/obj/item/reagent_containers/food/snacks/bun_bottom)
	/// Breads/buns/whatever that can only be put on top of an incomplete sandwich
	var/static/top_bread_types = list(/obj/item/reagent_containers/food/snacks/bun_top)
	/// Breads/buns/whatever that can be used as both base and top, and can be used for dagwoods
	var/static/vers_bread_types = list(/obj/item/reagent_containers/food/snacks/breadslice)
	/// Has setup() been called yet?
	var/setup_called = FALSE
	/// Do we have a top slice/bun, and thus are we able to be eaten?
	var/complete = FALSE
	/// Assoc list of types || image, intended to specify what image to select for a given ingredient's overlay
	/// reagent_container/food/snack has its own sandwich_overlay var that we use. This is for other things that don't have that var.
	var/static/ingredient_sprites = list()


	New()
		. = ..()
		SPAWN(0)
			if(!setup_called)
				src.setup() // We do this so spawned in sandwiches will Actually Exist
			// But, we wanna make sure whatever called New() has a chance to call setup()

	/// Sets up the sandwich. Automatically called by New() but calling it again will reset the sandwich.
	/// Unless overridden, do_initial_ingredients spawns the sandwich with the ingredients specified in initial_ingredients
	/// Provide an ingredient_list[] list of types and/or atoms to make a sandwich out of, in the provided order from bottom to top
	/// base is for the piece of bread (or other valid sandwich vessel) you're slapping with something to make a sandwich
	/// first_ingredient is the something you're slapping that piece of bread with
	proc/setup(mob/user, var/do_initial_ingredients = TRUE, var/list/ingredient_list, var/obj/item/base, var/obj/item/first_ingredient) // change to TRUE when functioning pls
		src.setup_called = TRUE
		src.original_reagents = src.reagents
		if (do_initial_ingredients)
			for (var/_type in src.initial_ingredients)
				var/obj/item/ingredient = new _type
				src.add_ingredient(null, ingredient)
		if (!base || !first_ingredient)
			return // how did we get here?
		src.add_ingredient(user, base, TRUE)
		src.add_ingredient(user, first_ingredient)


	/// Adds an ingredient to the top of the sandwich.
	/// starting_sandwich suppresses the "You've added [x] to the [src]!" alert
	proc/add_ingredient(mob/user, var/obj/item/ingredient2add, var/starting_sandwich = FALSE)
		if(!ingredient2add)
			return // don't wanna risk a null value being added ig
		if(ingredient2add.type in bottom_bread_types && !starting_sandwich) // what monster would put a bottom bun on top of their sandwich >:(
			boutput(user, "<span class='alert'>Hey stop that, you can only use [ingredient2add] as a sandwich base!</span>")
			return
		if(src.complete)
			var/x = src.ingredients.len // just to get the last entry in the list, which should be the top bun/slice
			var/datum/sandwich_ingredient/ingredient_datum = src.ingredients[x]
			var/obj/item/top_ingredient = ingredient_datum.our_atom
			if((top_ingredient.type in src.top_bread_types)) // we can put stuff on slices of bread, but not top buns!
				boutput(user, "<span class='alert'>You can't put anything else on top, take off \the [top_ingredient] to add anything else!</span>")
				return // yes i could've done && here and i tried that but when adding the first ingredient the len = 0 results in an oob exception god i wish oob just returned a null value

		var/datum/sandwich_ingredient/ingredient_datum = null
		var/datum/sandwich_ingredient/snack/food_datum = null
		if(istype(ingredient2add, /obj/item/reagent_containers/food/snacks))
			food_datum = new /datum/sandwich_ingredient/snack
			ingredient_datum = food_datum
			food_datum.our_snack = ingredient2add
		else
			ingredient_datum = new /datum/sandwich_ingredient
		ingredient_datum.our_atom = ingredient2add
		ingredient_datum.our_parent = src
		ingredient_datum.initialize()

		src.ingredients += ingredient_datum
		// whenever we have reagents applied to us, it'll be put onto the ingredient!
		src.reagents = ingredient_datum.reagents

		if(user)
			user.drop_item(ingredient2add)
		ingredient2add.set_loc(src)
		if(is_valid_finisher(ingredient2add) && !starting_sandwich)
			src.simulate_sandwich() // Simulating involves a couple loops that go through all ingredients, so we only wanna do it when we're ready to be eaten
			src.name_sandwich()
			src.complete = TRUE
			src.name = src.name_sandwich()
			src.reagents = src.original_reagents
			boutput(user, "<span class='alert'>You finish assembling \the [src]!</span>")
		else
			boutput(user, "<span class='alert'>You add [ingredient2add] to \the [src]!</span>")
		src.render_sandwich()


	/// Updates the bites_left, heal_amt, and food_effects vars for the sandwich and its ingredients
	proc/simulate_sandwich()
		var/total_bites_left = 0
		for (var/datum/sandwich_ingredient/snack/food_datum in src.ingredients)
			total_bites_left += food_datum.max_bites_left * food_datum.amount_left
		src.bites_left = ceil(total_bites_left / 1.5)
		// This math is for adjusting heal_amt so that when you finish eating, each ingredient would've healed you the same as if you ate it alone
		// Same for buffs. This is a lot of checking/processing for a loop so try not to call this too often.
		for (var/datum/sandwich_ingredient/snack/food_datum in src.ingredients)
			var/healing = food_datum.max_bites_left * food_datum.original_heal_amt
			healing *= food_datum.amount_left
			food_datum.our_snack.bites_left = src.bites_left
			food_datum.bites_left = src.bites_left
			healing /= food_datum.bites_left
			food_datum.our_snack.heal_amt = healing
			food_datum.heal_amt = healing
			var/buff_time
			var/buffs = food_datum.original_effects
			for (var/effect in buffs)
				if(!(buffs[effect]))
					buff_time = buffs[effect]
				else
					buff_time = 1 MINUTE // currently the default buff time
				buff_time *= food_datum.max_bites_left
				buff_time *= food_datum.amount_left
				buff_time /= food_datum.bites_left
				food_datum.our_snack.food_effects[effect] = buff_time

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
		else
			src.ClearAllOverlays()
			ingredients2render = src.ingredients.Copy()
		for (var/datum/sandwich_ingredient/ingredient in ingredients2render)
			var/index = src.ingredients.Find(ingredient)
			var/key = "ingredient" + "[index]"
			var/image/image2overlay = null
			var/_layer = FLOAT_LAYER + (0.0001 * index)
			var/added_condiment_offset = 0
			if (istype(ingredient, /datum/sandwich_ingredient/snack))
				var/datum/sandwich_ingredient/snack/food_datum = ingredient
				var/obj/item/reagent_containers/food/snacks/food2overlay = food_datum.our_snack
				if (!isnull(food2overlay.sandwich_overlay))
					var/offset = food2overlay.sandwich_offset
					image2overlay = SafeGetOverlayImage(key, 'icons/obj/foodNdrink/burgers.dmi', food2overlay.sandwich_overlay, _layer, 0, index + offset)
					added_condiment_offset = offset
				else if (is_valid_finisher(ingredient))
					image2overlay = SafeGetOverlayImage(key, ingredient.our_atom.icon, ingredient.our_atom.icon_state, _layer, 0, index) // Should probably make it an actual image of the current appearance of the item but whatever
				else
					image2overlay = get_backup_overlay(ingredient.our_atom, key, _layer, index)
			else
				image2overlay = get_backup_overlay(ingredient.our_atom, key, _layer, index)
			var/image/condiment_overlay = null
			if (ingredient.reagents.total_volume)
				condiment_overlay = SafeGetOverlayImage(key, 'icons/obj/foodNdrink/burgers.dmi', "overlay_chem", _layer, 0, index + added_condiment_offset)
				condiment_overlay.color = ingredient.reagents.get_average_color()
			src.UpdateOverlays(image2overlay, key)
			if (condiment_overlay)
				src.UpdateOverlays(condiment_overlay, key)

	proc/get_backup_overlay(var/obj/item/ingredient, var/key, var/_layer, var/index)
		//var/image/image2overlay = SafeGetOverlayImage(key, 'icons/obj/foodNdrink/burgers.dmi', "overlay_generic", _layer, 0, index * 2)
		//image2overlay.color = ingredient.color
		var/image/image2overlay = SafeGetOverlayImage(key, ingredient.icon, ingredient.icon_state, _layer, 0, index * 2)
		return image2overlay


	/// Generates a name for a sandwich based on its contents
	proc/name_sandwich()
		return "hamburgrer" // fix

	proc/remove_ingredient(mob/user, datum/sandwich_ingredient/to_remove)

		src.ingredients -= to_remove
		to_remove.remove_ingredient(user)

		var/datum/sandwich_ingredient/top_datum = src.ingredients[src.ingredients.len]
		var/obj/item/top_ingredient = top_datum.our_atom
		if(!is_valid_finisher(top_ingredient))
			src.complete = FALSE
			src.reagents = top_datum.reagents
		else
			src.complete = TRUE
			src.reagents = src.original_reagents

		if(src.ingredients.len > 1)
			src.simulate_sandwich()
			src.render_sandwich(TRUE)
		else
			var/datum/sandwich_ingredient/bottom_datum = src.ingredients[1]
			var/obj/item/bottom_piece = bottom_datum.our_atom
			!isnull(user) ? user.put_in_hand_or_drop(bottom_piece) : bottom_piece.set_loc(src.loc)
			qdel(src)

	/// Checks if ingredient is in vers or top bread lists and thus can be used to complete a sandwich
	proc/is_valid_finisher(obj/item/ingredient)
		. = (ingredient.type in (vers_bread_types + top_bread_types))

	attackby(obj/item/W, mob/user)
		if (!..() && (!istype(W, /obj/item/reagent_containers) || istype(W, /obj/item/reagent_containers/food/snacks)) && !istype(W, /obj/item/reagent_containers/food/snacks/condiment) && !istype(W, /obj/item/shaker))
			src.add_ingredient(user, W, FALSE)

	reagent_act(reagent_id, volume)
		. = ..()
		SPAWN(0) // after we get reagents applied to us; updates any condiment overlay on top layer
			src.render_sandwich()

	attack_hand(mob/user)
		if (src.loc == user) // intended to only happen if being held in the off-hand and clicked on with empty hand
			var/list/selections = list()
			selections += "*CANCEL*"
			var/list/valid_ingredients = src.ingredients.Copy()
			valid_ingredients.Remove(src.ingredients[1]) // not allowed to remove the bottom bread/bun
			for (var/datum/sandwich_ingredient/ingredient in valid_ingredients)
				var/ingredient_name = ingredient.our_atom.name
				var/n = 1
				while((ingredient_name) in selections)
					ingredient_name = "[ingredient.our_atom.name]" + " ([n])"
					n++ // this is all to add "(number)" next to duplicate entries
				selections[ingredient_name] = ingredient
			var/selected = input(user, "Select an ingredient to remove:", "\The [src]") in selections
			if(selected == "*CANCEL*")
				return
			var/to_remove = selections[selected]
			src.remove_ingredient(user, to_remove)
		else
			..()

	take_a_bite(var/mob/consumer, var/mob/feeder, var/suppress_messages = FALSE)
		if (!src.complete)
			boutput(consumer, "<span class='alert'>You can't eat [src], it's not complete!</span>")
			return
		for (var/datum/sandwich_ingredient/snack/food_datum in src.ingredients)
			var/obj/item/reagent_containers/food/snacks/ingredient = food_datum.our_snack
			if (food_datum.reagents.total_volume)
				var/datum/reagents/condiments = food_datum.reagents
				condiments.trans_to(src, condiments.total_volume / src.bites_left, do_fluid_react = FALSE) // we react in the person's mouth, not the sandwich :)
			food_datum.amount_left -= food_datum.amount_left / food_datum.bites_left
			ingredient.take_a_bite(consumer, feeder, TRUE)
		..()

/datum/sandwich_ingredient
	var/obj/item/reagent_containers/food/snacks/new_sandwich/our_parent = null
	var/obj/item/our_atom = null
	var/amount_left = 1 // mostly to do with bites_left, but leaving here since it might be useful for other things
	var/datum/reagents/reagents = new /datum/reagents
	var/is_food = FALSE

	proc/initialize()
		reagents.maximum_volume = 20

	proc/remove_ingredient(mob/user)
		if(our_atom && reagents)
			src.reagents.trans_to(our_atom, reagents.total_volume)
		if(!QDELETED(our_atom) && our_atom)
			if(!isnull(user))
				user.put_in_hand_or_drop(our_atom)
			else
				our_atom.set_loc(our_parent.loc)
		spawn()
			qdel(src)

/datum/sandwich_ingredient/snack
	var/obj/item/reagent_containers/food/snacks/our_snack = null
	var/bites_left = 1
	var/max_bites_left = 1
	var/heal_amt = 0
	var/original_heal_amt = 0
	var/list/original_effects = list()
	is_food = TRUE

	initialize()
		src.bites_left = our_snack.bites_left
		src.max_bites_left = initial(our_snack.bites_left)
		src.heal_amt = our_snack.heal_amt
		src.original_heal_amt = our_snack.heal_amt
		src.original_effects = our_snack.food_effects.Copy()
		src.amount_left = our_snack.bites_left / initial(our_snack.bites_left)
		. = ..()

	remove_ingredient(mob/user)
		var/theoretical_bites_left = src.max_bites_left * src.amount_left
		var/final_bites_left = round(theoretical_bites_left) // floor doesn't work and round acts as floor so if they fix that please adjust this thank you
		if(!final_bites_left)
			if(prob(theoretical_bites_left * 100))
				final_bites_left = 1 // we'll check at the end if something has 0 bites and qdel it there
		if(!final_bites_left)
			boutput(user, "<span class='alert'>You weren't able to salvage any of \the [src.our_snack]!</span>")
			qdel(src.our_snack)
		else
			. = TRUE
		our_snack.bites_left = final_bites_left
		our_snack.heal_amt = original_heal_amt
		our_snack.food_effects = original_effects.Copy()
		src.our_snack = null
		. = ..()

/obj/item/reagent_containers/food/snacks/new_sandwich/blt
	name = "\improper BLT sandwich"
	initial_ingredients = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/ingredient/meat/bacon,
		/obj/item/reagent_containers/food/snacks/plant/lettuce,
		/obj/item/reagent_containers/food/snacks/ingredient/tomatoslice,
		/obj/item/reagent_containers/food/snacks/breadslice
	)
