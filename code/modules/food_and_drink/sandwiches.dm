
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
