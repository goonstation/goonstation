/// Sheep Egg for spawning

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/sheep
	name = "sheep egg"
	desc = "Wait, since when did sheep come from eggs?"
	icon = 'icons/mob/ranch/sheep.dmi'
	icon_state = "sheep-white-egg"
	critter_type = /mob/living/critter/small_animal/ranch_base/sheep/white/ai_controlled
	color = null


	New()
		. = ..()
		if(secret_thing)
			name = "mysterious egg (?)"
			desc = "What could be inside?"
			if(prob(50))
				critter_type = /mob/living/critter/small_animal/ranch_base/sheep/white/ai_controlled/bi
			else
				critter_type = /mob/living/critter/small_animal/ranch_base/sheep/white/ram/ai_controlled/bi

		else
			if(prob(50))
				critter_type = /mob/living/critter/small_animal/ranch_base/sheep/white/ai_controlled
			else
				critter_type = /mob/living/critter/small_animal/ranch_base/sheep/white/ram/ai_controlled

		src.color = null

/// sheep baby stuff
ABSTRACT_TYPE(/datum/sheep_baby_props)
/datum/sheep_baby_props
	/// sheep id of our baby, used for determining icon_state's and some comparison for unique sheep
	var/sheep_id = "white"
	/// determines if more than one of this sheep type can exist
	var/unique = FALSE
	/// percentage of eggs that will become rams. 0 = all ewes 100 = all rams
	var/gender_balance = 50
	/// path to the ewe mob
	var/ewe_type = null
	/// path to the rooster mob
	var/ram_type = null
	/// list of argument to pass to New when creating the mob
	var/list/arguments = null
	/// happy parents have happy children. Base happiness value for the newly born baby.
	var/happiness_value = 0

	New()
		. = ..()

	/// do things before the mob is created
	proc/BeforeBirth()
		return

	/// do things after the mob is created
	proc/AfterBirth(var/mob/living/critter/small_animal/ranch_base/sheep/S)
		return

	white
		sheep_id = "white"
		ewe_type = /mob/living/critter/small_animal/ranch_base/sheep/white/ai_controlled
		ram_type = /mob/living/critter/small_animal/ranch_base/sheep/white/ram/ai_controlled
		gender_balance = 50
