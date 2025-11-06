ABSTRACT_TYPE(/datum/ranch/evolution/chicken)
/datum/ranch/evolution/chicken
	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		if(. && istype(C,/mob/living/critter/small_animal/ranch_base/chicken))
			. = TRUE
		else
			. = FALSE
// -------------------------
// FEED THRESHOLD EVOLUTIONS
// -------------------------

ABSTRACT_TYPE(/datum/ranch/evolution/chicken/feed_threshold)
/datum/ranch/evolution/chicken/feed_threshold
	var/feed_threshold = 7
	var/feed_flag = ""
	var/egg_type = null

	check_evolution_conditions(var/mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		if(. && (N.get_feed_count(src.feed_flag) >= src.feed_threshold))
			. = TRUE
		else
			. = FALSE

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.egg_type = src.egg_type

/datum/ranch/evolution/chicken/feed_threshold/honk
	evolution_priority = 10
	feed_flag = "honk"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/honk

/datum/ranch/evolution/chicken/feed_threshold/glass
	evolution_priority = 2
	feed_flag = "glass"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/glass

/datum/ranch/evolution/chicken/feed_threshold/purple
	evolution_priority = 6
	feed_flag = "purple"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/purple

/datum/ranch/evolution/chicken/feed_threshold/onagadori
	evolution_priority = 7
	feed_flag = "peanut"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/onagadori

/datum/ranch/evolution/chicken/feed_threshold/pet
	evolution_priority = 8
	feed_flag = "tomato"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/pet

/datum/ranch/evolution/chicken/feed_threshold/silkie
	evolution_priority = 3
	feed_flag = "silkie"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/silkie

/datum/ranch/evolution/chicken/silkie_black
	evolution_priority = 5
	var/feed_count_threshold_black = 3
	var/feed_count_threshold_silkie = 7

	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		if(. && (N.get_feed_count("silkie") >= src.feed_count_threshold_silkie && N.get_feed_count("silkie_black") >= src.feed_count_threshold_black))
			. = TRUE
		else
			. = FALSE

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/silkie_black

/datum/ranch/evolution/chicken/silkie_white
	evolution_priority = 4
	var/feed_count_threshold_white = 3
	var/feed_count_threshold_silkie = 7

	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		if(. && (N.get_feed_count("silkie") >= src.feed_count_threshold_silkie && N.get_feed_count("silkie_white") >= src.feed_count_threshold_white))
			. = TRUE
		else
			. = FALSE

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/silkie_white

/datum/ranch/evolution/chicken/feed_threshold/candy
	evolution_priority = 2
	feed_flag = "sugar"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/candy

/datum/ranch/evolution/chicken/feed_threshold/pigeon
	evolution_priority = 1
	feed_flag = "peas"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/pigeon
	feed_threshold = 3

/datum/ranch/evolution/chicken/feed_threshold/sea
	evolution_priority = 2
	feed_flag = "fish"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/sea

/datum/ranch/evolution/chicken/feed_threshold/snow
	evolution_priority = 1
	feed_flag = "snow"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/snow

/datum/ranch/evolution/chicken/feed_threshold/spicy
	evolution_priority = 3
	feed_flag = "spicy"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/spicy
	feed_threshold = 3

/datum/ranch/evolution/chicken/feed_threshold/plant
	evolution_priority = 2
	feed_flag = "synth"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/plant

/datum/ranch/evolution/chicken/feed_threshold/raptor
	evolution_priority = 1
	feed_flag = "raptor"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/raptor

/datum/ranch/evolution/chicken/feed_threshold/helium
	evolution_priority = 1
	feed_flag = "helium"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_helium

/datum/ranch/evolution/chicken/feed_threshold/hydrogen
	evolution_priority = 2
	feed_flag = "hydrogen"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/balloon_hydrogen

/datum/ranch/evolution/chicken/feed_threshold/stone
	evolution_priority = 1
	feed_flag = "stone"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/stone

/datum/ranch/evolution/chicken/feed_threshold/wizard
	evolution_priority = 2
	feed_flag = "wizard"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard

/datum/ranch/evolution/chicken/feed_threshold/cockatrice
	feed_threshold = 3
	evolution_priority = 10
	feed_flag = "lizard"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/cockatrice

/datum/ranch/evolution/chicken/feed_threshold/robot
	evolution_priority = 1
	feed_flag = "robot"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/robot

/datum/ranch/evolution/chicken/feed_threshold/knight
	evolution_priority = 1
	feed_flag = "metal"
	egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/knight

// ------------------------------
// HAPPINESS THRESHOLD EVOLUTIONS
// ------------------------------
/datum/ranch/evolution/chicken/cluwne
	evolution_priority = 99
	var/happiness_threshold = -2*666-1
	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		if(. && (N.happiness < src.happiness_threshold))
			. = TRUE
		else
			. = FALSE

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/cluwne

/datum/ranch/evolution/chicken/golden
	evolution_priority = 1
	var/happiness_threshold = 777
	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		if(. && (N.happiness > src.happiness_threshold))
			. = TRUE
		else
			. = FALSE
	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/golden

/datum/ranch/evolution/chicken/brown
	evolution_priority = 1
	var/happiness_threshold = 100
	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		if(. && (N.happiness > src.happiness_threshold))
			. = TRUE
		else
			. = FALSE

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/brown

/datum/ranch/evolution/chicken/white
	evolution_priority = -1
	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/white

// -------------------------------
// EXPERIENCE THRESHOLD EVOLUTIONS
// -------------------------------

ABSTRACT_TYPE(/datum/ranch/evolution/level_up)
/datum/ranch/evolution/level_up
	var/xp_threshold = 0

	check_evolution_conditions(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		if(. && (C.xp >= src.xp_threshold))
			. = TRUE
		else
			. = FALSE

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()

ABSTRACT_TYPE(/datum/ranch/evolution/level_up/chicken)

/datum/ranch/evolution/level_up/chicken/honk/mime
	evolution_priority = 100
	xp_threshold = 1

	evolve(mob/living/critter/small_animal/ranch_base/C)
		var/mob/living/critter/small_animal/ranch_base/chicken/honk/H = C
		if(istype(H))
			H.visible_message(SPAN_NOTICE("<b>[H]</b> undergoes a strange transformation!"))
			H.transform_into_mime()

/datum/ranch/evolution/level_up/chicken/wizard
	evolution_priority = -1
	xp_threshold = 0

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/N = C
		N.attack_ability_type = /datum/targetable/critter/magic_missile
		var/datum/targetable/critter/magic_missile/MM = N.getAbility(N.attack_ability_type)
		if(MM)
			N.attack_ability = MM
		else
			N.attack_ability = N.abilityHolder.addAbility(N.attack_ability_type)
		N.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard


/datum/ranch/evolution/level_up/chicken/wizard/two
	evolution_priority = 1
	xp_threshold = 1000

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/wizard/W = C
		W.attack_ability_type = /datum/targetable/critter/ice_burst
		var/datum/targetable/critter/ice_burst/IB = W.getAbility(W.attack_ability_type)
		if(IB)
			W.attack_ability = IB
		else
			W.attack_ability = W.abilityHolder.addAbility(W.attack_ability_type)
		W.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard

/datum/ranch/evolution/level_up/chicken/wizard/three
	evolution_priority = 2
	xp_threshold = 10000

	evolve(mob/living/critter/small_animal/ranch_base/C)
		. = ..()
		var/mob/living/critter/small_animal/ranch_base/chicken/wizard/W = C
		W.attack_ability_type = /datum/targetable/critter/fireball/chicken
		var/datum/targetable/critter/fireball/chicken/FB = W.getAbility(W.attack_ability_type)
		if(FB)
			W.attack_ability = FB
		else
			W.attack_ability = W.abilityHolder.addAbility(W.attack_ability_type)
		W.egg_type = /obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/wizard
