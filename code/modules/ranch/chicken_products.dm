
// Egg Hatch Proc

/obj/item/reagent_containers/food/snacks/ingredient/egg/proc/hatch_c()
	var/mob/living/critter/small_animal/ranch_base/chicken/white/ai_controlled/C = new()
	C.set_loc(get_turf(src))
	qdel(src)

// Chicken eggs

/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken
	icon = 'icons/mob/ranch/chickens.dmi'
	icon_state = "egg-white"
	/// path to the egg_props datum, used to setup initial egg props object
	var/egg_props_path = /datum/chicken_egg_props/white
	/// datum containing various egg properties such as food_effects
	var/datum/chicken_egg_props/chicken_egg_props = null

	New()
		. = ..()
		if (egg_props_path)
			chicken_egg_props = new egg_props_path(src)
		src.setup_special_effects()
		src.UpdateIcon()
	update_icon()
		if (egg_props_path)
			src.icon_state = "egg-[chicken_egg_props.chicken_id]"

	proc/setup_special_effects()
		if (length(src.chicken_egg_props.food_effects))
			src.food_effects = src.chicken_egg_props.food_effects

	hatch_c()
		// do before hatch tasks
		chicken_egg_props.BeforeHatch()

		if(chicken_egg_props.unique)
			for(var/mob/living/critter/small_animal/ranch_base/chicken/C in by_type[/mob/living/critter/small_animal/ranch_base])
				if(C.chicken_id == src.chicken_egg_props.chicken_id)
					src.visible_message(SPAN_ALERT("[src] hatches to reveal nothing inside!"))
					qdel(src)
					return

		var/mob/living/critter/small_animal/ranch_base/chicken/C

		if (prob(chicken_egg_props.gender_balance))
			if (length(chicken_egg_props.arguments))
				C = new chicken_egg_props.rooster_type(arglist(chicken_egg_props.arguments))
			else // kind of annoyed that you can't just pass arglist an empty list or null without runtimes...
				C = new chicken_egg_props.rooster_type()
		else
			if (length(chicken_egg_props.arguments))
				C = new chicken_egg_props.hen_type(arglist(chicken_egg_props.arguments))
			else // kind of annoyed that you can't just pass arglist an empty list or null without runtimes...
				C = new chicken_egg_props.hen_type()
		if (!C)
			src.visible_message(SPAN_ALERT("[src] hatches to reveal nothing inside!"))
			qdel(src)
			return
		if(C)
			C.set_loc(get_turf(src))
			C.happiness += chicken_egg_props.happiness_value

		// do after hatch tasks
		chicken_egg_props.AfterHatch(C)
		qdel(src)

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(istype(src?.chicken_egg_props, /datum/chicken_egg_props/glass))
			var/datum/chicken_egg_props/glass/props = src.chicken_egg_props
			props.glass_smash(A)
		..()

/*
 * egg subtypes, for easy spawning
 */
	white
		egg_props_path = /datum/chicken_egg_props/white
	brown
		egg_props_path = /datum/chicken_egg_props/brown
	silkie
		egg_props_path = /datum/chicken_egg_props/silkie
	silkie_black
		egg_props_path = /datum/chicken_egg_props/silkie_black
	silkie_white
		egg_props_path = /datum/chicken_egg_props/silkie_white
	golden
		egg_props_path = /datum/chicken_egg_props/golden
	spicy
		egg_props_path = /datum/chicken_egg_props/spicy
	honk
		egg_props_path = /datum/chicken_egg_props/honk
	cluwne
		egg_props_path = /datum/chicken_egg_props/cluwne
	raptor
		egg_props_path = /datum/chicken_egg_props/raptor
	plant
		egg_props_path = /datum/chicken_egg_props/plant
	robot
		egg_props_path = /datum/chicken_egg_props/robot
	purple
		egg_props_path = /datum/chicken_egg_props/purple
	candy
		egg_props_path = /datum/chicken_egg_props/candy
	sea
		egg_props_path = /datum/chicken_egg_props/sea
	dream
		egg_props_path = /datum/chicken_egg_props/dream
	snow
		egg_props_path = /datum/chicken_egg_props/snow
	popsicle
		egg_props_path = /datum/chicken_egg_props/popsicle
	pigeon
		egg_props_path = /datum/chicken_egg_props/pigeon
	wizard
		egg_props_path = /datum/chicken_egg_props/wizard
	pet
		egg_props_path = /datum/chicken_egg_props/pet
	ghost
		egg_props_path = /datum/chicken_egg_props/ghost
	cockatrice
		egg_props_path = /datum/chicken_egg_props/cockatrice
	onagadori
		egg_props_path = /datum/chicken_egg_props/onagadori
	knight
		egg_props_path = /datum/chicken_egg_props/knight
	mime
		egg_props_path = /datum/chicken_egg_props/mime
	balloon_helium
		egg_props_path = /datum/chicken_egg_props/balloon_helium
	balloon_hydrogen
		egg_props_path = /datum/chicken_egg_props/balloon_hydrogen
	glass
		egg_props_path = /datum/chicken_egg_props/glass
	stone
		egg_props_path = /datum/chicken_egg_props/stone
	time
		egg_props_path = /datum/chicken_egg_props/time
	space
		egg_props_path = /datum/chicken_egg_props/space
	power_blue
		egg_props_path = /datum/chicken_egg_props/power_blue
		New()
			. = ..()
			src.reagents.add_reagent("liquid spacetime",1)
	power_gold
		egg_props_path = /datum/chicken_egg_props/power_gold
		New()
			. = ..()
			src.reagents.add_reagent("liquid spacetime",1)

// Egg Props

ABSTRACT_TYPE(/datum/chicken_egg_props)
/datum/chicken_egg_props
	/// chicken id of our egg, used for determining icon_state's and some comparison for unique chickens
	var/chicken_id = "white"
	/// the egg who owns this instance of egg properties
	var/obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/owner = null
	/// determines if more than one of this chicken type can exist
	var/unique = FALSE
	/// list of food effects applied to the egg
	var/list/food_effects = null
	/// percentage of eggs that will become roosters. 0 = all hens 100 = all roosters
	var/gender_balance = 50
	/// path to the hen mob
	var/hen_type = null
	/// path to the rooster mob
	var/rooster_type = null
	/// list of argument to pass to New when creating the mob
	var/list/arguments = null
	/// happy chickens lay happy eggs. Base happiness value for the newly hatched chicks.
	var/happiness_value = 0
	/// is this even an egg? Does it hatch into a chicken? Or is it like, a water balloon.
	var/is_hatchable = TRUE
	/// is this egg in the secret repo?
	var/is_secret = FALSE

	New(obj/item/reagent_containers/food/snacks/ingredient/egg/chicken/owning_egg)
		. = ..()
		src.owner = owning_egg
#ifdef SECRETS_ENABLED
		if(src.is_secret)
			src.owner.icon = '+secret/icons/obj/chickens_secret.dmi'
#endif

	/// do things before the mob is created
	proc/BeforeHatch()
		return

	/// do things after the mob is created
	proc/AfterHatch(var/mob/living/critter/small_animal/ranch_base/chicken/C)
		return

 	/// Called when the "egg" is layed. For chickens who lay "eggs" which are really just items that can't hatch but need to call some stuff still
	proc/ItemHatch()
		return
	white
		chicken_id = "white"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/white/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/white/rooster/ai_controlled
		gender_balance = 50
	brown
		chicken_id = "brown"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/brown/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/brown/rooster/ai_controlled
		gender_balance = 50
	silkie
		chicken_id = "silkie"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/silkie/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/silkie/rooster/ai_controlled
		gender_balance = 50
	silkie_black
		chicken_id = "silkie_black"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/silkie_black/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/silkie_black/rooster/ai_controlled
		gender_balance = 50
	silkie_white
		chicken_id = "silkie_white"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/silkie_white/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/silkie_white/rooster/ai_controlled
		gender_balance = 50
	golden
		chicken_id = "golden"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/golden/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/golden/rooster/ai_controlled
		gender_balance = 50
		is_hatchable = FALSE

		ItemHatch()
			. = ..()
			var/obj/item/raw_material/gold/G = new()
			G.icon = 'icons/mob/ranch/chickens.dmi'
			G.icon_state = "egg-[chicken_id]"
			G.name = "golden egg"
			G.desc = "Holy shit, a golden egg!"
			G.set_loc(get_turf(owner))
			qdel(owner)
			return G
	spicy
		chicken_id = "spicy"
		food_effects = list("food_fireburp","food_warm","food_sweaty","food_hp_up")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/spicy/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/spicy/rooster/ai_controlled
		gender_balance = 50
	honk
		chicken_id = "honk"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/honk/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/honk/rooster/ai_controlled
		gender_balance = 50
		is_hatchable = FALSE

		ItemHatch()
			. = ..()
			var/obj/item/reagent_containers/balloon/B = new()
			B.reagents.add_reagent("water",40)
			B.icon = 'icons/mob/ranch/chickens.dmi'
			B.icon_state = "egg-[chicken_id]"
			B.name = "egg?"
			B.desc = "On closer inspection, this egg is actually a water balloon."
			B.set_loc(get_turf(owner))
			qdel(owner)
			return B
	cluwne
		chicken_id = "cluwne"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/cluwne/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/cluwne/rooster/ai_controlled
		gender_balance = 50
	raptor
		chicken_id = "raptor"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/raptor/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/raptor/rooster/ai_controlled
		gender_balance = 50
	plant
		chicken_id = "plant"
		food_effects = list("photosynthesis")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/plant/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/plant/rooster/ai_controlled
		gender_balance = 50
	robot
		chicken_id = "robot"
		food_effects = list("empulsar")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/robot/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/robot/rooster/ai_controlled
		gender_balance = 50
	purple
		chicken_id = "purple"
		food_effects = list("crunched")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/purple/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/purple/rooster/ai_controlled
		gender_balance = 50
	candy
		chicken_id = "candy"
		food_effects = list("sugar_rush")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/candy/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/candy/rooster/ai_controlled
		gender_balance = 50
	sea
		chicken_id = "sea"
		food_effects = list("aquabreath")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/sea/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/sea/rooster/ai_controlled
		gender_balance = 50
	dream
		chicken_id = "dream"
		food_effects = list("supersleep")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/dream/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/dream/rooster/ai_controlled
		gender_balance = 50
	snow
		chicken_id = "snow"
		food_effects = list("frozen")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/snow/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/snow/rooster/ai_controlled
		gender_balance = 50
	popsicle
		chicken_id = "popsicle"
		food_effects = list("popsicle","frozen","sugar_rush")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/popsicle/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/popsicle/rooster/ai_controlled
		gender_balance = 50
	pigeon
		chicken_id = "pigeon"
		food_effects = list("pigeon")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/pigeon/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/pigeon/rooster/ai_controlled
		gender_balance = 50

		New()
			. = ..()
			owner.open_to_sound = TRUE
			new/obj/item/device/radio/pigeon(owner)
	wizard
		chicken_id = "wizard"
		food_effects = list("missile")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/wizard/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/wizard/rooster/ai_controlled
		gender_balance = 50
	pet
		chicken_id = "pet"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/pet/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/pet/rooster/ai_controlled
		gender_balance = 50
	ghost
		chicken_id = "ghost"
		food_effects = list("haunted")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/ghost/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/ghost/rooster/ai_controlled
		gender_balance = 50
	cockatrice
		chicken_id = "cockatrice"
		food_effects = list("cockatrice")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/cockatrice/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/cockatrice/rooster/ai_controlled
		gender_balance = 50
	onagadori
		chicken_id = "onagadori"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/onagadori/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/onagadori/rooster/ai_controlled
		gender_balance = 50
	knight
		chicken_id = "knight"
		food_effects = list("egg_defense","food_hp_up")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/knight/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/knight/rooster/ai_controlled
		gender_balance = 50
	mime
		chicken_id = "mime"
		food_effects = list("mime_time")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/mime/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/mime/rooster/ai_controlled
		gender_balance = 50
	balloon_helium
		chicken_id = "balloon"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/balloon/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/balloon/rooster/ai_controlled
		gender_balance = 50
	balloon_hydrogen
		chicken_id = "balloon"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/balloon/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/balloon/rooster/ai_controlled
		gender_balance = 50

		AfterHatch(var/mob/living/critter/small_animal/ranch_base/chicken/C)
			. = ..()
			var/mob/living/critter/small_animal/ranch_base/chicken/balloon/chicken = C
			chicken.explosive = TRUE
			chicken.favorite_flag = "hydrogen"
	glass
		chicken_id = "glass"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/glass/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/glass/rooster/ai_controlled
		gender_balance = 50
		var/smashed = FALSE

		BeforeHatch()
			. = ..()
			var/list/possible_chicken_ids = list()
			for(var/R_id in owner.reagents.reagent_list)
				var/datum/reagent/R = owner.reagents.reagent_list[R_id]
				if(R.id != "egg")
					possible_chicken_ids += R.id
					if (R.id != "mirabilis")
						possible_chicken_ids[R.id] = R.name
					else
						possible_chicken_ids[R.id] = " "
			if(length(possible_chicken_ids))
				var/id = pick(possible_chicken_ids)
				arguments = list(reagent_id = id, reagent_name = possible_chicken_ids[id])

		proc/glass_smash(var/atom/A)
			if (src.smashed)
				return
			src.smashed = TRUE

			var/turf/T = get_turf(A)
			if (!T)
				T = get_turf(owner)
			if (!T)
				qdel(owner)
				return
			if (owner.reagents) // haine fix for cannot execute null.reaction()
				owner.reagents.reaction(A)
				T.fluid_react(owner.reagents, owner.reagents.total_volume, FALSE)

			T.visible_message(SPAN_ALERT("[owner] shatters!"))
			playsound(T, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
			for (var/i=3, i > 0, i--)
				var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
				G.set_loc(owner.loc)
			qdel(owner)
	stone
		chicken_id = "stone"
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/stone/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/stone/rooster/ai_controlled
		gender_balance = 50

		BeforeHatch()
			. = ..()
			arguments = list(source_material = owner.material)
	time
		chicken_id = "time"
		food_effects = list("phasing")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/time/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/time/rooster/ai_controlled
		gender_balance = 50
		unique = TRUE

		BeforeHatch()
			. = ..()
			var/mob/living/critter/small_animal/ranch_base/chicken/power/P = locate() in by_type[/mob/living/critter/small_animal/ranch_base]
			if (P)
				hen_type = null
				rooster_type = null
				return
			var/mob/living/critter/small_animal/ranch_base/chicken/space/S = locate() in by_type[/mob/living/critter/small_animal/ranch_base]
			if (S?.is_masc)
				gender_balance = 0
			else if (S)
				gender_balance = 100
	space
		chicken_id = "space"
		food_effects = list("space_splice")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/space/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/space/rooster/ai_controlled
		unique = TRUE

		BeforeHatch()
			. = ..()
			var/mob/living/critter/small_animal/ranch_base/chicken/power/P = locate() in by_type[/mob/living/critter/small_animal/ranch_base]
			if (P)
				hen_type = null
				rooster_type = null
				return
			var/mob/living/critter/small_animal/ranch_base/chicken/time/T = locate() in by_type[/mob/living/critter/small_animal/ranch_base]
			if (T?.is_masc)
				gender_balance = 0
			else if (T)
				gender_balance = 100
	power_blue
		chicken_id = "power_blue"
		food_effects = list("space_splice","food_hp_up","c_power")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/power/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/power/rooster/ai_controlled
		gender_balance = 100
		unique = TRUE
	power_gold
		chicken_id = "power_gold"
		food_effects = list("phasing","food_hp_up","c_power")
		hen_type = /mob/living/critter/small_animal/ranch_base/chicken/power/power_gold/ai_controlled
		rooster_type = /mob/living/critter/small_animal/ranch_base/chicken/power/power_gold/rooster/ai_controlled
		gender_balance = 100
		unique = TRUE

// Egg Effects

/datum/statusEffect/time_phase
	id = "phasing"
	name = "Phasing"
	desc = "You feel kinda funny. Like, not \"ha ha\" funny. It's more like, \"you exist in multiple time-space axes at once\" funny."
	icon_state = "phasing"
	duration = 10 SECONDS
	maxDuration = 10 SECONDS
	visible = 1
	var/turf/starting_location = null
	movement_modifier = /datum/movement_modifier/phasing
	var/owner_original_age = 0

	onAdd(var/optional=null)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			boutput(M, SPAN_ALERT("<B>You feel like all of time is connected.</B>"))
		starting_location = get_turf(owner)
		owner.AddComponent(/datum/component/afterimage, 15, 0.4 SECONDS)
		var/mob/living/carbon/human/H = owner
		if(istype(H))
			owner_original_age = H.bioHolder.age

	onUpdate(var/timePassed)
		. = ..()
		var/mob/living/carbon/human/H = owner
		if(istype(H))
			H.bioHolder.age += timePassed*4

	onRemove()
		. = ..()
		var/atom/movable/AM = owner
		if(!istype(AM))
			return
		var/datum/component/D = AM.GetComponent(/datum/component/afterimage)
		D?.RemoveComponent()
		var/mob/M = AM
		if(istype(M))
			boutput(M, SPAN_ALERT("<B>You suddenly feel yourself pulled violently back in time!</B>"))
			M.flash(3 SECONDS)

		playsound(AM.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)

		AM.set_loc(starting_location)
		starting_location = null

		elecflash(owner,power = 2)

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			H.bioHolder.age = owner_original_age

/datum/movement_modifier/phasing
	additive_slowdown = -1

/datum/statusEffect/space_splice
	id = "space_splice"
	name = "Spliced"
	desc = "You feel kinda funny. Like, not \"ha ha\" funny. It's more like, \"you exist in multiple space-time axes at once\" funny."
	icon_state = "splicing"
	duration = 10 SECONDS
	maxDuration = 10 SECONDS
	visible = 1
	movement_modifier = /datum/movement_modifier/space_splice

	onAdd(var/optional=null)
		. = ..()
		var/mob/M = owner
		owner.AddComponent(/datum/component/afterimage, 10, 0.1 SECONDS)
		if(istype(M))
			boutput(M, SPAN_ALERT("<B>You feel like all of space is connected.</B>"))

	onUpdate(var/timePassed)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			if (isrestrictedz(M.z))
				return
			var/telerange = 5
			var/list/randomturfs = new/list()
			for(var/turf/T in orange(M, telerange))
				if(istype(T, /turf/space) || T.density) continue
				randomturfs.Add(T)
			if (!randomturfs.len)
				..()
				return
			elecflash(M,power=2)
			playsound(M.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
			M.set_loc(pick(randomturfs))

	onRemove()
		. = ..()
		var/datum/component/D = owner.GetComponent(/datum/component/afterimage)
		D?.RemoveComponent()

/datum/movement_modifier/space_splice
	multiplicative_slowdown = 0.20

/datum/statusEffect/chicken_power
	id = "c_power"
	name = "Chicken Power"
	desc = "It's all starting to make sense, now."
	icon_state = "c_power"
	duration = 60 SECONDS
	maxDuration = 60 SECONDS
	visible = 1
	var/already_had_xray = FALSE

	onAdd(var/optional=null)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			boutput(M, SPAN_ALERT("<B>You feel as if you are one with everything.</B>"))
			if(M.bioHolder.HasEffect("xray"))
				already_had_xray = TRUE
			else
				M.bioHolder.AddEffect("xray")

	onUpdate(var/timePassed)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			M?.HealDamage("All", 7, 7, 7)

	onRemove()
		. = ..()
		var/mob/M = owner
		if (M?.bioHolder && !already_had_xray)
			M.bioHolder.RemoveEffect("xray")

/datum/statusEffect/chicken_power/lesser
	id = "c_power_lesser"
	name = "Chicken Power (Lesser)"
	desc = "Things make a little more sense these days."
	icon_state = "c_power"
	duration = 10 SECONDS
	maxDuration = 10 SECONDS
	visible = 1

/datum/statusEffect/photosynthesis
	id = "photosynthesis"
	name = "Photosynthesizing"
	desc = "Your body has been opened up to the power of the sun. Or the station lights. Whatever."
	icon_state = "photosynth"
	duration = 60 SECONDS
	maxDuration = 60 SECONDS
	visible = 1

	onAdd(var/optional=null)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			boutput(M, SPAN_ALERT("<B>You feel energized by the lights of the station.</B>"))

	onUpdate(var/timePassed)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			var/turf/T = get_turf(M)
			if (istype(T))
				var/regenamt = T.RL_GetBrightness()
				if(regenamt > 0.5)
					regenamt = regenamt*20*timePassed
					M.add_stamina(regenamt)

	onRemove()
		. = ..()

/datum/statusEffect/empulsar
	id = "empulsar"
	name = "EMP Pulse Conductor"
	desc = "Your biolectricity has been augmented."
	icon_state = "empulsar"
	duration = 8 SECONDS
	maxDuration = 8 SECONDS
	visible = 1
	var/datum/abilityHolder/critter/fake_holder = null
	var/datum/targetable/critter/zzzap/fake_ability = null
	var/counter = 1

	onAdd(var/optional=null)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			boutput(M, SPAN_ALERT("<B>You feel energy pulsing within you. And from you. Oh dear.</B>"))
			fake_holder = new()
			fake_ability = new()
			fake_ability.cooldown = 0
			fake_ability.holder = fake_holder
			fake_holder.owner = M


	onUpdate(var/timePassed)
		. = ..()
		if(!(counter%5))
			if(fake_ability)
				fake_ability.cast(get_turf(owner))
		counter++

	onRemove()
		. = ..()
		if(fake_ability)
			qdel(fake_ability)
			fake_ability.holder = null
			fake_ability = null
		if(fake_holder)
			qdel(fake_holder)
			fake_holder.owner = null
			fake_holder = null

/datum/statusEffect/crunched
	id = "crunched"
	name = "Crunched"
	desc = "Half of your body now exists in an alternate dimension. Uh oh."
	icon_state = "crunched"
	duration = 10 SECONDS
	maxDuration = 10 SECONDS
	visible = 1
	var/already_had_tablepass = 0
	var/already_had_doorpass = 0
	var/shrunk_max = 2
	var/shrunk_min = -4
	var/shrunk_change = 2

	onAdd(var/optional=null)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			//Following stolen from shrink_beam.dm
			if (clamp(M.shrunk + shrunk_change, shrunk_min, shrunk_max) == M.shrunk)
				return

			if (M.shrunk != 0)
				M.Scale(1 / (0.75 ** M.shrunk), 1 / (0.75 ** M.shrunk))
			M.shrunk += shrunk_change
			M.Scale(0.75 ** M.shrunk, 0.75 ** M.shrunk)

			if(M.flags & TABLEPASS)
				already_had_tablepass = 1
			else
				M.flags |= TABLEPASS

			if(M.flags & DOORPASS)
				already_had_doorpass = 1
			else
				M.flags |= DOORPASS

			var/mob/living/carbon/human/H = M
			if(istype(H))
				H.traitHolder.addTrait("deathwish")
				boutput(H, SPAN_ALERT("<B>Holy fuck that hurts!!</B>"))


	onRemove()
		. = ..()
		var/mob/M = owner
		if(istype(M))
			shrunk_change *= -1
			//Following stolen from shrink_beam.dm
			if (clamp(M.shrunk + shrunk_change, shrunk_min, shrunk_max) == M.shrunk)
				return

			if (M.shrunk != 0)
				M.Scale(1 / (0.75 ** M.shrunk), 1 / (0.75 ** M.shrunk))
			M.shrunk += shrunk_change
			M.Scale(0.75 ** M.shrunk, 0.75 ** M.shrunk)

			if((M.flags & TABLEPASS) && !already_had_tablepass)
				M.flags &= ~TABLEPASS

			if((M.flags & DOORPASS) && !already_had_doorpass)
				M.flags &= ~DOORPASS

			var/mob/living/carbon/human/H = M
			if(istype(H))
				H.traitHolder.removeTrait("deathwish")
				H.emote("scream")

/datum/statusEffect/sugar_rush
	id = "sugar_rush"
	name = "Sugar Rush"
	desc = "You're bouncing off the walls!"
	icon_state = "sugar_rush"
	duration = 60 SECONDS
	maxDuration = 60 SECONDS
	visible = 1

	onUpdate(timePassed)
		. = ..()
		var/datum/reagents/R = owner.reagents
		if(R)
			R.add_reagent("sugar",1)

/datum/statusEffect/aquabreath
	id = "aquabreath"
	name = "Aquatic Biology"
	desc = "You feel like you really need some water, like, right now!"
	icon_state = "aquabreath"
	duration = 60 SECONDS
	maxDuration = 60 SECONDS
	visible = 1
	var/already_had_aquabreath = 0

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			if(L.lifeprocesses[/datum/lifeprocess/aquatic_breathing])
				already_had_aquabreath = 1
			else
				L.add_lifeprocess(/datum/lifeprocess/aquatic_breathing,5,5)


	onRemove()
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			if(!already_had_aquabreath)
				L.remove_lifeprocess(/datum/lifeprocess/aquatic_breathing)

/datum/statusEffect/supersleep
	id = "supersleep"
	name = "Stasis"
	desc = "You are in a deep sleep, healing all wounds."
	icon_state = "supersleep"
	duration = 60 SECONDS
	maxDuration = 60 SECONDS
	visible = 1
	var/in_fakedeath = 0
	var/interrupted = 0
	var/grace_period = 3

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/carbon/human/C = owner
		if(istype(C) && !src.in_fakedeath)
			logTheThing(LOG_COMBAT, owner, "enters regenerative stasis using a dream egg [log_loc(owner)].")

			src.in_fakedeath = 1
			APPLY_ATOM_PROPERTY(C, PROP_MOB_CANTMOVE, src.type)

			C.lying = 1
			C.canmove = 0
			C.set_clothing_icon_dirty()

			C.visible_message(SPAN_ALERT("<B>[C] goes into a deep sleep!</span>"))
			C.setStatus("resting", INFINITE_STATUS)
			C.sleeping = 1
			grace_period = 3

	onUpdate(timePassed)
		. = ..()
		var/mob/living/carbon/human/C = owner
		if(grace_period > 0)
			grace_period--
		else
			if(istype(C))
				if(!C?.lying)
					src.interrupted = 1
				else if(!C?.hasStatus("resting"))
					src.interrupted = 1

				if(src.interrupted)
					boutput(C, SPAN_ALERT("Your rest was interrupted!"))
					C.delStatus("supersleep")

	onRemove()
		. = ..()
		var/mob/living/carbon/human/C = owner
		if(istype(C))
			var/list/implants = list()
			for (var/obj/item/implant/I in C) //Still preserving implants
				implants += I
			C.canmove = 1
			REMOVE_ATOM_PROPERTY(C, PROP_MOB_CANTMOVE, src.type)
			C.set_clothing_icon_dirty()
			C.lying = 0
			C.sleeping = 0
			if(src.interrupted)
				return
			changeling_super_heal_step(C, 100, 100)
			if (C && !isdead(C))
				C.HealDamage("All", 1000, 1000)
				C.take_brain_damage(-INFINITY)
				C.take_toxin_damage(-INFINITY)
				C.take_oxygen_deprivation(-INFINITY)
				C.remove_stuns()
				C.delStatus("radiation")
				C.delStatus("resting")
				C.health = 100
				C.reagents.clear_reagents()
				boutput(C, SPAN_NOTICE("Wow, you feel really great!."))
				logTheThing(LOG_COMBAT, C, "[C] finishes regenerative statis using a dream egg [log_loc(C)].")
				C.visible_message(SPAN_ALERT("<B>[C] wakes from their deep sleep, looking extremely refreshed!</span>"))
				for(var/obj/item/implant/I in implants)
					if (istype(I, /obj/item/implant/projectile))
						boutput(C, SPAN_ALERT("\an [I] falls out of your abdomen."))
						I.on_remove(C)
						C.implant.Remove(I)
						I.set_loc(C.loc)
						continue
			src.in_fakedeath = 0

/datum/statusEffect/frozen
	id = "frozen"
	name = "Frozen"
	desc = "You're m-m-m-melting!!"
	icon_state = "frozen"
	duration = 30 SECONDS
	maxDuration = 30 SECONDS
	visible = 1
	var/old_color = null
	var/old_alpha = null
	var/old_base_body_temp = null

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			old_color = L.color
			L.color = "#018eb9"
			old_alpha = L.alpha
			L.alpha = 155
			RegisterSignal(L, COMSIG_MOVABLE_MOVED, PROC_REF(make_ice))
			old_base_body_temp = L.base_body_temp
			L.base_body_temp = T0C
			L.add_lifeprocess(/datum/lifeprocess/melt,5)

	onRemove()
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.color = old_color
			L.alpha = old_alpha
			L.base_body_temp = old_base_body_temp
			UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
			L.remove_lifeprocess(/datum/lifeprocess/melt)

	proc/make_ice()
		if (!locate(/obj/decal/icefloor) in get_turf(owner))
			var/obj/decal/icefloor/B = new /obj/decal/icefloor(get_turf(owner))
			SPAWN(5 SECONDS)
				qdel (B)

/datum/statusEffect/haunted
	id = "haunted"
	name = "Haunted"
	desc = "You feel an evil presence nearby."
	icon_state = "haunted"
	duration = 30 SECONDS
	maxDuration = 30 SECONDS
	visible = 1

	onAdd(optional)
		. = ..()
		if (ismob(src.owner))
			var/mob/M = src.owner
			M.add_vomit_behavior(/datum/vomit_behavior/haunted)

	onRemove(optional)
		. = ..()
		if (ismob(src.owner))
			var/mob/M = src.owner
			M.remove_vomit_behavior(/datum/vomit_behavior/haunted)

	onUpdate(timePassed)
		. = ..()
		var/mob/living/L = owner
		if(prob(50))
			L.nauseate(1)

/datum/vomit_behavior/haunted
	vomit(mob/M)
		M.visible_message(SPAN_ALERT("<b>[M]</b> pukes up an angry ghost!"))
		var/obj/critter/spirit/spirit = new(get_turf(M))
		spirit.target = M
		spirit.oldtarget_name = M.name
		spirit.task = "chasing"

/datum/statusEffect/missile
	id = "missile"
	name = "Magic Missile"
	desc = "This magic missile seems friendly!"
	icon_state = "missile"
	duration = 10 SECONDS
	maxDuration = 10 SECONDS
	visible = 1
	var/datum/targetable/critter/magic_missile/missile = null

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.abilityHolder.addAbility(/datum/targetable/critter/magic_missile)
			missile = L.abilityHolder.getAbility(/datum/targetable/critter/magic_missile)

	onUpdate(timePassed)
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			if(missile?.last_cast && missile?.cooldowncheck())
				L.delStatus("missile")

	onRemove()
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.abilityHolder.removeAbility(/datum/targetable/critter/magic_missile)
			missile = null

/datum/statusEffect/fear
	id = "fear"
	name = "Fear"
	desc = "You are afraid and unable to move normally."
	icon_state = "fear"
	duration = 30 SECONDS
	maxDuration = 120 SECONDS
	visible = 1
	var/stacks = 1

	onUpdate(timePassed)
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.change_misstep_chance(10*stacks)

	onRemove()
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.change_misstep_chance(-10*stacks)

/obj/item/device/radio/pigeon
	protected_radio = 1
	frequency = 1420
	locked_frequency = 1
	initial_microphone_enabled = TRUE
	initial_speaker_enabled = FALSE
	speaker_range = 0
	icon_tooltip = "Pigeon?"
	icon = 'icons/mob/ranch/chickens.dmi'
	icon_state = "egg-pigeon"

/obj/item/device/radio/pigeon/status
	initial_microphone_enabled = FALSE
	initial_speaker_enabled = TRUE

/obj/machinery/camera/ranch/pigeon
	name = null
	c_tag = null
	has_light = FALSE

	New(loc, passed_name)
		. = ..()
		name = "[passed_name] - ranch"
		c_tag = passed_name

/datum/statusEffect/pigeon
	id = "pigeon"
	name = "Pigeon Brain"
	desc = "You can hear the pigeons gossip."
	icon_state = "messenger"
	duration = 600 SECONDS
	maxDuration = 600 SECONDS
	visible = 1
	var/obj/item/device/radio/pigeon/status/peasradio = null
	var/already_open = FALSE

	onAdd(var/optional=null)
		. = ..()
		peasradio = new(owner)

		if(owner.open_to_sound)
			already_open = TRUE
		else
			owner.open_to_sound = TRUE

	onRemove()
		. = ..()
		qdel(peasradio)
		if(!already_open)
			owner.open_to_sound = FALSE

/datum/statusEffect/cockatrice
	id = "cockatrice"
	name = "Cockatrice-Infused Eyes"
	desc = "You feel rather stunning!"
	icon_state = "glare"
	duration = 10 SECONDS
	maxDuration = 10 SECONDS
	visible = 1
	var/datum/targetable/vampire/glare/my_glare = null

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.abilityHolder.addAbility(/datum/targetable/vampire/glare/cockatrice)
			my_glare = L.abilityHolder.getAbility(/datum/targetable/vampire/glare/cockatrice)

	onUpdate(timePassed)
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			if(my_glare?.last_cast && my_glare?.cooldowncheck())
				L.delStatus("cockatrice")

	onRemove()
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.abilityHolder.removeAbility(/datum/targetable/vampire/glare/cockatrice)
			my_glare = null

/datum/statusEffect/popsicle
	id = "popsicle"
	name = "Orange Dreamsicle High"
	desc = "Holy shit. Oh fuck. You're building up power!"
	icon_state = "popsicle"
	duration = 5 SECONDS
	maxDuration = 5 SECONDS
	visible = 1
	var/max_bounce = 5

	onUpdate(timePassed)
		. = ..()
		src.max_bounce++

	onAdd(optional)
		. = ..()

	onRemove()
		. = ..()
		var/datum/projectile/special/launch_self/P = new /datum/projectile/special/launch_self()
		P.max_bounce_count = src.max_bounce
		P.damage *= 5
		P.generate_stats()
		shoot_projectile_ST_pixel_spread(owner, P, get_step(owner, pick(ordinal)))

/datum/statusEffect/egg_defense
	id = "egg_defense"
	name = "Egg Defense"
	desc = "You feel protected!"
	icon_state = "egg_defense"
	duration = 20 SECONDS
	maxDuration = 20 SECONDS
	visible = 1

	onUpdate(timePassed)
		. = ..()

	onAdd(optional)
		. = ..()
		var/mob/M = owner
		if(istype(M))
			APPLY_ATOM_PROPERTY(M, PROP_MOB_ENCHANT_ARMOR, src, 6)

	onRemove()
		. = ..()
		var/mob/M = owner
		if(istype(M))
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_ENCHANT_ARMOR, src)

/datum/statusEffect/mime_time
	id = "mime_time"
	name = "Mime Time"
	desc = "La vie c'est de la merde, petit poulet."
	icon_state = "mime_time"
	duration = 60 SECONDS
	maxDuration = 60 SECONDS
	visible = 1
	var/datum/targetable/critter/mime_cage/mimecage = null
	var/already_had_mute = FALSE
	var/already_had_noir = FALSE
	var/already_had_blankman = FALSE

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/L = owner

		if(L.bioHolder.HasEffect("mute"))
			already_had_mute = TRUE
		else
			L.bioHolder.AddEffect("mute")

		if(L.bioHolder.HasEffect("noir"))
			already_had_noir = TRUE
		else
			L.bioHolder.AddEffect("noir")

		if(L.bioHolder.HasEffect("blankman"))
			already_had_blankman = TRUE
		else
			L.bioHolder.AddEffect("blankman")

		if(istype(L))
			L.abilityHolder.addAbility(/datum/targetable/critter/mime_cage)
			mimecage = L.abilityHolder.getAbility(/datum/targetable/critter/mime_cage)

	onRemove()
		. = ..()
		var/mob/living/L = owner
		if(istype(L))
			L.abilityHolder.removeAbility(/datum/targetable/critter/mime_cage)
			mimecage = null
			if(!already_had_mute)
				L.bioHolder.RemoveEffect("mute")
			if(!already_had_noir)
				L.bioHolder.RemoveEffect("noir")
			if(!already_had_blankman)
				L.bioHolder.RemoveEffect("blankman")

/*
 *
 * Chicken Nuggets
 *
*/

/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken
	name = "BASE TYPE - DO NOT SPAWN"
	desc = "A farm fresh chicken nugget from the local ranch"
	icon = 'icons/obj/ranch/chicken_nuggets.dmi'
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/white
	name = "white chicken nugget"
	icon_state = "nugget-white"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/brown
	name = "brown chicken nugget"
	icon_state = "nugget-brown"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/silkie
	name = "silkie chicken nugget"
	icon_state = "nugget-silkie"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/silkie_black
	name = "silkie_black chicken nugget"
	icon_state = "nugget-silkie_black"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/silkie_white
	name = "silkie_white chicken nugget"
	icon_state = "nugget-silkie_white"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/golden
	name = "golden chicken nugget"
	icon_state = "nugget-golden"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/spicy
	name = "spicy chicken nugget"
	icon_state = "nugget-spicy"
	food_color = "#FF6600"
	heal_amt = 10
	initial_reagents = list("capsaicin"=15)
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/honk
	name = "honk chicken nugget"
	icon_state = "nugget-honk"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/cluwne
	name = "cluwne chicken nugget"
	icon_state = "nugget-cluwne"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/raptor
	name = "raptor chicken nugget"
	icon_state = "nugget-raptor"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/plant
	name = "vegan chicken nugget"
	icon_state = "nugget-plant"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/robot
	name = "robot chicken nugget"
	icon_state = "nugget-robot"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/purple
	name = "void chicken nugget"
	icon_state = "nugget-purple"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/candy
	name = "candy chicken nugget"
	icon_state = "nugget-candy"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/sea
	name = "sea chicken nugget"
	icon_state = "nugget-sea"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/dream
	name = "dream chicken nugget"
	icon_state = "nugget-dream"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/snow
	name = "snow chicken nugget"
	icon_state = "nugget-snow"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/popsicle
	name = "dreamsicle chicken nugget"
	icon_state = "nugget-popsicle"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/pigeon
	name = "pigeon chicken nugget"
	icon_state = "nugget-pigeon"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/wizard
	name = "witchen chicken nugget"
	icon_state = "nugget-wizard"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/pet
	name = "pet chicken nugget"
	icon_state = "nugget-pet"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/ghost
	name = "ghost chicken nugget"
	icon_state = "nugget-ghost"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/cockatrice
	name = "cockatrice chicken nugget"
	icon_state = "nugget-cockatrice"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/onagadori
	name = "onagadori chicken nugget"
	icon_state = "nugget-onagadori"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/knight
	name = "shieldhen chicken nugget"
	icon_state = "nugget-knight"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/mime
	name = "mime chicken nugget"
	icon_state = "nugget-mime"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/balloon
	name = "balloon chicken nugget"
	icon_state = "nugget-balloon"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/glass
	name = "glass chicken nugget"
	icon_state = "nugget-glass"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/stone
	name = "stone chicken nugget"
	icon_state = "nugget-stone"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/time
	name = "time chicken nugget"
	icon_state = "nugget-time"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/space
	name = "space chicken nugget"
	icon_state = "nugget-space"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/power_blue
	name = "power chicken nugget"
	icon_state = "nugget-power_blue"
/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/ranch_chicken/power_gold
	name = "power chicken nugget"
	icon_state = "nugget-power_gold"
