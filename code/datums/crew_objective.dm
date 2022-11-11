#ifdef CREW_OBJECTIVES

/datum/controller/gameticker/proc
	generate_crew_objectives()
		set background = 1
		if (master_mode == "construction")
			return
		for (var/datum/mind/crewMind in minds)
			generate_individual_objectives(crewMind)

		return

	generate_individual_objectives(var/datum/mind/crewMind)
		set background = 1
		//Requirements for individual objectives: 1) You have a mind (this eliminates 90% of our playerbase ~heh~)
												//2) You are not a traitor
		if (!crewMind)
			return
		if (!crewMind.current || !crewMind.objectives || crewMind.objectives.len || crewMind.special_role || (crewMind.assigned_role == "MODE"))
			return

		var/rolePathString = ckey(crewMind.assigned_role)
		if (!rolePathString)
			return

		rolePathString = "/datum/objective/crew/[rolePathString]"
		var/rolePath = text2path(rolePathString)
		if (isnull(rolePath))
			return

		var/list/objectiveTypes = concrete_typesof(rolePath)
		if (!objectiveTypes.len)
			return

		var/obj_count = 1
		var/assignCount = min(rand(1,3), objectiveTypes.len)
		while (assignCount && length(objectiveTypes))
			assignCount--
			var/selectedType = pick(objectiveTypes)
			var/datum/objective/crew/newObjective = new selectedType(null, crewMind)
			objectiveTypes -= selectedType

			if (obj_count <= 1)
				boutput(crewMind.current, "<B>Your OPTIONAL Crew Objectives are as follows:</b>")
			boutput(crewMind.current, "<B>Objective #[obj_count]</B>: [newObjective.explanation_text]")
			obj_count++

		var/mob/crewmob = crewMind.current
		if (crewmob.traitHolder && crewmob.traitHolder.hasTrait("conspiracytheorist"))
			/*var/conspiracy_text = ""
			var/noun = pick_string("conspiracy_theories.txt", "noun")
			var/conspiracy = pick_string("conspiracy_theories.txt", "conspiracy")
			var/reason = pick_string("conspiracy_theories.txt", "reason")
			var/objective = pick_string("conspiracy_theories.txt", "objective")
			conspiracy_text = "The [noun] are [conspiracy] in order to [reason]. [objective]"
			conspiracy_text = replacetext(conspiracy_text, "%THING%", pick_string("conspiracy_theories.txt", "thing"))*/
			var/conspiracy_text = pick_smart_string("conspiracy_theories.txt", "conspiracy_text")

			boutput(crewmob, "<B>Objective #[obj_count]</B>: [conspiracy_text]")

		return

/*
 *	HOW-TO: Make Crew Objectives
 *	It's literally as simple as defining an objective of type "/datum/objective/crew/[ckey(job title) goes here]/objective name"
 *	Please take note that it goes live as soon as you define it, so if it isn't ready you should probably comment it out!!
 *	Additionally, if your objective does not insignificant checks independent of its holder
 *	e.g checking every human to see if it's dead and on-station - use static vars to ensure the necessary checks only occurs once per role
 *	var/static/check_result = null when not checked yet, 0 when check failed, and 1 when check passed
 */

ABSTRACT_TYPE(/datum/objective/crew)
/datum/objective/crew

ABSTRACT_TYPE(/datum/objective/crew/captain)
/datum/objective/crew/captain/hat
	explanation_text = "Don't lose your hat!"
	medal_name = "Hatris"
	check_completion()
		if(owner.current && owner.current.check_contents_for(/obj/item/clothing/head/caphat || owner.current.check_contents_for(/obj/item/clothing/head/fancy/captain)))
			return 1
		else
			return 0
/datum/objective/crew/captain/drunk
	explanation_text = "Have alcohol in your bloodstream at the end of the round."
	medal_name = "Edward Smith"
	check_completion()
		if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("ethanol"))
			return 1
		else
			return 0

ABSTRACT_TYPE(/datum/objective/crew/headofsecurity)
/datum/objective/crew/headofsecurity/hat
	explanation_text = "Don't lose your hat/beret!"
	medal_name = "Hatris"
	check_completion()
		if(owner.current && owner.current.check_contents_for(/obj/item/clothing/head/hos_hat))
			return 1
		else
			return 0
/datum/objective/crew/headofsecurity/brig
	explanation_text = "Have at least one antagonist cuffed in the brig at the end of the round." //can be dead as people usually suicide
	medal_name = "Suitable? How about the Oubliette?!"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && istype(get_area(M.current),/area/station/security/brig) && M.current.hasStatus("handcuffed")) //think that's everything...
					check_result = TRUE
					break
		return check_result
/datum/objective/crew/headofsecurity/centcom
	explanation_text = "Bring at least one antagonist back to CentCom in handcuffs for interrogation. You must accompany them on the escape shuttle." //can also be dead I guess
	medal_name = "Dead or alive, you're coming with me"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && in_centcom(M.current) && M.current.hasStatus("handcuffed"))
					if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //split this up as it was long
						check_result = TRUE
						break
		return check_result

/datum/objective/crew/headofsecurity/brigstir
	explanation_text = "Keep Monsieur Stirstir brigged but also make sure that he comes to absolutely no harm."
	medal_name = "Monkey Duty"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/mob/living/carbon/human/npc/monkey/stirstir/M in mobs)
				if(!isdead(M) && (M.get_brute_damage() + M.get_oxygen_deprivation() + M.get_burn_damage() + M.get_toxin_damage()) == 0 && istype(get_area(M),/area/station/security/brig))
					check_result = TRUE
					break
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/headofpersonnel)
/datum/objective/crew/headofpersonnel/vanish
	explanation_text = "End the round alive but not on the station or escape levels."
	medal_name = "Unperson"
	check_completion()
		if(owner.current && !isdead(owner.current) && owner.current.z != Z_LEVEL_STATION && !in_centcom(owner.current)) return 1
		else return 0

ABSTRACT_TYPE(/datum/objective/crew/chiefengineer)
/datum/objective/crew/chiefengineer/furnaces
	explanation_text = "Make sure all furnaces on the station are active at the end of the round."
	medal_name = "Slow Burn"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/obj/machinery/power/furnace/F in machine_registry[MACHINES_POWER])
				if(F.z == Z_LEVEL_STATION && !F.active && istype(F.loc.loc, /area/station))
					check_result = FALSE
					break
			return check_result
/datum/objective/crew/chiefengineer/ptl
	explanation_text = "Earn at least a million credits via the PTL."
	medal_name = "1.21 Jiggawatts"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/obj/machinery/power/pt_laser/P in machine_registry[MACHINES_POWER])
				if(P.lifetime_earnings >= 1 MEGA)
					check_result = TRUE
		return check_result

/datum/objective/crew/chiefengineer/reserves
	explanation_text = "Make sure all SMES units on the station are at least 20% charged at the end of the round."
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for (var/obj/machinery/power/smes/S in machine_registry[MACHINES_POWER])
				if(istype(get_area(S),/area/station) && S.charge < S.capacity/5)
					check_result = FALSE
		return check_result

/datum/objective/crew/chiefengineer/apc
	explanation_text = "Ensure all APC units on the station are operating at the end of the round."
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for_by_tcl(A, /obj/machinery/power/apc)
				if(istype(get_area(A),/area/station) && A.area.requires_power)
					if(!A.operating)
						check_result = FALSE
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/securityofficer)
// grabbed the HoS's two antag-related objectives cause they work just fine for regular sec too, so...?
	/*brig
		explanation_text = "Have at least one antagonist cuffed in the brig at the end of the round." //can be dead as people usually suicide
		medal_name = "Suitable? How about the Oubliette?!"
		check_completion()
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && istype(get_area(M.current),/area/station/security/brig) && M.current.hasStatus("handcuffed")) //think that's everything...
					return 1
			return 0
	*/
/datum/objective/crew/securityofficer/centcom
	explanation_text = "Bring at least one antagonist back to CentCom in handcuffs for interrogation. You must accompany them on the escape shuttle." //can also be dead I guess
	medal_name = "Dead or alive, you're coming with me"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/datum/mind/M in ticker.minds)
				if(M.special_role && M.current && !isobserver(M.current) && in_centcom(M.current) && M.current.hasStatus("handcuffed"))
					if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //split this up as it was long
						check_result = TRUE
						break
		return check_result

/datum/objective/crew/securityofficer/brigstir
	explanation_text = "Keep Monsieur Stirstir brigged but also make sure that he comes to absolutely no harm."
	medal_name = "Monkey Duty"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/mob/living/carbon/human/npc/monkey/stirstir/M in mobs)
				if(!isdead(M) && (M.get_brute_damage() + M.get_oxygen_deprivation() + M.get_burn_damage() + M.get_toxin_damage()) == 0 && istype(get_area(M),/area/station/security/brig))
					check_result = TRUE
					break
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/securityassistant)
/datum/objective/crew/securityassistant/brigstir
	explanation_text = "Keep Monsieur Stirstir brigged but also make sure that he comes to absolutely no harm."
	medal_name = "Monkey Duty"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/mob/living/carbon/human/npc/monkey/stirstir/M in mobs)
				if(!isdead(M) && (M.get_brute_damage() + M.get_oxygen_deprivation() + M.get_burn_damage() + M.get_toxin_damage()) == 0 && istype(get_area(M),/area/station/security/brig))
					check_result = TRUE
					break
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/quartermaster)
/datum/objective/crew/quartermaster/profit
	explanation_text = "End the round with a budget of over 50,000 credits."
	medal_name = "Tax Haven"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			if(wagesystem.shipping_budget > 50000)
				check_result = TRUE
		return check_result

/datum/objective/crew/quartermaster/specialorder
	explanation_text = "Fulfill an off-station order requisition or special order."
	check_completion()
		return length(shippingmarket.complete_orders)

ABSTRACT_TYPE(/datum/objective/crew/detective)
/datum/objective/crew/detective/drunk
	explanation_text = "Have alcohol in your bloodstream at the end of the round."
	medal_name = "Tipsy"
	check_completion()
		if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("ethanol"))
			return 1
		else
			return 0
/datum/objective/crew/detective/gear
	explanation_text = "Ensure that you are still wearing your coat, hat and uniform at the end of the round."
	medal_name = "Neither fashionable noir stylish"
	check_completion()
		if(owner.current && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(istype(H.w_uniform, /obj/item/clothing/under/rank/det) && istype(H.wear_suit, /obj/item/clothing/suit/det_suit) && istype(H.head, /obj/item/clothing/head/det_hat)) return 1
		return 0
/datum/objective/crew/detective/smoke
	explanation_text = "Make sure you're smoking at the end of the round."
	medal_name = "Where's the smoking gun?"
	check_completion()
		if(owner.current && istype(owner.current.wear_mask,/obj/item/clothing/mask/cigarette)) return 1
		else return 0

ABSTRACT_TYPE(/datum/objective/crew/botanist)
/datum/objective/crew/botanist/mutantplants
	explanation_text = "Have at least three mutant plants alive at the end of the round."
	medal_name = "Bill Masen"
	var/static/check_result = null
	check_completion()
		var/mutcount = 0
		if(isnull(check_result))
			check_result = FALSE
			for(var/obj/machinery/plantpot/PP as anything in machine_registry[MACHINES_PLANTPOTS])
				if(PP.current)
					var/datum/plantgenes/DNA = PP.plantgenes
					var/datum/plantmutation/MUT = DNA.mutation
					if (MUT)
						mutcount++
						if(mutcount >= 3)
							check_result = TRUE
							break
		return check_result
/datum/objective/crew/botanist/noweed
	explanation_text = "Make sure there are no cannabis plants, seeds or products in Hydroponics at the end of the round."
	medal_name = "Reefer Madness"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/obj/item/X in by_cat[TR_CAT_CANNABIS_OBJ_ITEMS])
				var/obj/item/clothing/mask/cigarette/W = X
				if (istype(W) && W.reagents && W.reagents.has_reagent("THC"))
					if (istype(get_area(W), /area/station/hydroponics))
						check_result = FALSE
						break
				var/obj/item/plant/herb/cannabis/C = X
				if (istype(C) && istype(get_area(C), /area/station/hydroponics))
					check_result = FALSE
					break
				var/obj/item/seed/cannabis/S = X
				if (istype(S) && istype(get_area(S), /area/station/hydroponics))
					check_result = FALSE
					break
			for (var/obj/machinery/plantpot/PP as anything in machine_registry[MACHINES_PLANTPOTS])
				if (PP.current && istype(PP.current, /datum/plant/herb/cannabis))
					if (istype(get_area(PP), /area/station/hydroponics) || istype(get_area(PP), /area/station/hydroponics/lobby))
						check_result = FALSE
						break
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/chaplain)
/datum/objective/crew/chaplain/funeral
	explanation_text = "Have no corpses on the station level at the end of the round."
	medal_name = "Bury the Dead"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/mob/living/carbon/human/H in mobs)
				if(H.z == Z_LEVEL_STATION && isdead(H))
					check_result = FALSE
					break
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/janitor)
/datum/objective/crew/janitor/cleanbar
	explanation_text = "Make sure the bar is spotless at the end of the round."
	medal_name = "Spotless"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/turf/T in get_area_turfs(/area/station/crew_quarters/bar, 0))
				for(var/obj/decal/cleanable/D in T)
					check_result = FALSE
					break
		return check_result
/datum/objective/crew/janitor/cleanmedbay
	explanation_text = "Make sure medbay is spotless at the end of the round."
	medal_name = "Spotless"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/turf/T in get_area_turfs(/area/station/medical/medbay, 0))
				for(var/obj/decal/cleanable/D in T)
					check_result = FALSE
					break
		return check_result
/datum/objective/crew/janitor/cleanbrig
	explanation_text = "Make sure the brig is spotless at the end of the round."
	medal_name = "Spotless"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/turf/T in get_area_turfs(/area/station/security/brig, 0))
				for(var/obj/decal/cleanable/D in T)
					check_result = FALSE
					break
		return check_result

#define DRINK_OBJ_COUNT 3
ABSTRACT_TYPE(/datum/objective/crew/bartender)
/datum/objective/crew/bartender/shotgun
	explanation_text = "Don't lose your shotgun!"
	check_completion()
		if(owner.current?.check_contents_for(/obj/item/gun/kinetic/sawnoff))
			return TRUE
		else
			return FALSE
/datum/objective/crew/bartender/drinks
	var/completed = FALSE
	var/ids[DRINK_OBJ_COUNT]
	var/static/list/blacklist = list(
		/datum/reagent/fooddrink/alcoholic/bitters,
		/datum/reagent/fooddrink/alcoholic/beer,
		/datum/reagent/fooddrink/alcoholic/bojack,
		/datum/reagent/fooddrink/alcoholic/bourbon,
		/datum/reagent/fooddrink/alcoholic/champagne,
		/datum/reagent/fooddrink/alcoholic/cider,
		/datum/reagent/fooddrink/alcoholic/cocktail_grog,
		/datum/reagent/fooddrink/alcoholic/curacao,
		/datum/reagent/fooddrink/alcoholic/dbreath,
		/datum/reagent/fooddrink/alcoholic/freeze,
		/datum/reagent/fooddrink/alcoholic/gin,
		/datum/reagent/fooddrink/alcoholic/mead,
		/datum/reagent/fooddrink/alcoholic/moonshine,
		/datum/reagent/fooddrink/alcoholic/ricewine,
		/datum/reagent/fooddrink/alcoholic/rum,
		/datum/reagent/fooddrink/alcoholic/tequila,
		/datum/reagent/fooddrink/alcoholic/vermouth,
		/datum/reagent/fooddrink/alcoholic/vodka,
		/datum/reagent/fooddrink/alcoholic/wine,
		/datum/reagent/fooddrink/alcoholic/wine/white
	)
	var/static/list/cocktails = concrete_typesof(/datum/reagent/fooddrink/alcoholic)-blacklist

	set_up()
		..()
		var/list/names[DRINK_OBJ_COUNT]
		for (var/i = 1; i <= DRINK_OBJ_COUNT; i++)
			var/choiceType = pick(cocktails)
			var/datum/reagent/fooddrink/instance = new choiceType
			var/hidden = 0
			var/list/reactions = chem_reactions_by_result[instance.id]
			for (var/datum/chemical_reaction/reaction_type in reactions)
				if (initial(reaction_type.hidden))
					hidden++
			//if all reactions producing this reagent are hidden, then skip it and try again
			if (hidden == length(reactions))
				i--
				continue
			names[i] = instance.name
			ids[i] = instance.id
		explanation_text = "Mix a "
		for (var/ingredient in names)
			if (ingredient != names[DRINK_OBJ_COUNT])
				explanation_text += "[ingredient], "
			else
				explanation_text += "and [ingredient] "
		explanation_text += "using your cocktail shaker."

	check_completion()
		return completed == 2**DRINK_OBJ_COUNT-1 //Uses bit flags

#define CAKE_OBJ_COUNT 3
#define PIZZA_OBJ_COUNT 3
ABSTRACT_TYPE(/datum/objective/crew/chef)
/datum/objective/crew/chef
	var/static/list/blacklist = list(
		/obj/item/reagent_containers/food/snacks/burger/humanburger,
		/obj/item/reagent_containers/food/snacks/donut/custom/robust,
		/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat,
		/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/flock,
		/obj/item/reagent_containers/food/snacks/ingredient/pepperoni,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/mushroom,
		/obj/item/reagent_containers/food/snacks/pickle/trash,
		/obj/item/reagent_containers/food/snacks/pizza/xmas,
		/obj/item/reagent_containers/food/snacks/plant/glowfruit/spawnable,
		/obj/item/reagent_containers/food/snacks/soup/custom,
		/obj/item/reagent_containers/food/snacks/condiment/syndisauce,
		/obj/item/reagent_containers/food/snacks/donkpocket_w,
		/obj/item/reagent_containers/food/snacks/surstromming,
		/obj/item/reagent_containers/food/snacks/hotdog/syndicate,
		/obj/item/reagent_containers/food/snacks/tortilla_chip_spawner,
		/obj/item/reagent_containers/food/snacks/pancake/classic,
		/obj/item/reagent_containers/food/snacks/wonton_spawner,
		/obj/item/reagent_containers/food/snacks/agar_block,
		/obj/item/reagent_containers/food/snacks/sushi_roll/custom,
#ifndef UNDERWATER_MAP
		/obj/item/reagent_containers/food/snacks/healgoo,
		/obj/item/reagent_containers/food/snacks/greengoo,
#endif
		/obj/item/reagent_containers/food/snacks/snowball,
		/obj/item/reagent_containers/food/snacks/burger/vr,
		/obj/item/reagent_containers/food/snacks/slimjim,
		/obj/item/reagent_containers/food/snacks/bite,
		/obj/item/reagent_containers/food/snacks/pickle_holder,
		/obj/item/reagent_containers/food/snacks/snack_cake
	)
	var/static/list/ingredients = concrete_typesof(/obj/item/reagent_containers/food/snacks) - blacklist - concrete_typesof(/obj/item/reagent_containers/food/snacks/ingredient/egg/critter)
/datum/objective/crew/chef/cake
	var/choices[CAKE_OBJ_COUNT]
	var/completed = FALSE

	set_up()
		..()
		var/list/names[CAKE_OBJ_COUNT]
		for(var/i in 1 to CAKE_OBJ_COUNT)
			choices[i] = pick(ingredients)
			var/choiceType = choices[i]
			var/obj/item/reagent_containers/food/snacks/instance =  new choiceType
			if(!instance.custom_food)
				i--
				continue
			names[i] = instance.name
		explanation_text = "Create a custom, three-tier cake with layers of "
		for (var/ingredient in names)
			if (ingredient != names[CAKE_OBJ_COUNT])
				explanation_text += "[ingredient], "
			else
				explanation_text += "and [ingredient] "
		explanation_text += "infused cake in any order."

	check_completion()
		return completed

/datum/objective/crew/chef/pizza
	var/choices[PIZZA_OBJ_COUNT]
	var/completed = FALSE

	set_up()
		..()
		var/list/names[PIZZA_OBJ_COUNT]
		for(var/i = 1, i <= PIZZA_OBJ_COUNT, i++)
			choices[i] = pick(ingredients)
			var/choiceType = choices[i]
			var/obj/item/reagent_containers/food/snacks/instance =  new choiceType
			if(!instance.custom_food || !instance.name)
				i--
				continue
			names[i] = instance.name
		explanation_text = "Create a custom pizza with "
		for (var/ingredient in names)
			if (ingredient != names[PIZZA_OBJ_COUNT])
				explanation_text += "[ingredient], "
			else
				explanation_text += "and [ingredient] "
		explanation_text += "toppings."
	check_completion()
		return completed

ABSTRACT_TYPE(/datum/objective/crew/engineer)
/datum/objective/crew/engineer/furnaces
	explanation_text = "Make sure all furnaces on the station are active at the end of the round."
	medal_name = "Slow Burn"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/obj/machinery/power/furnace/F in machine_registry[MACHINES_POWER])
				if(F.z == Z_LEVEL_STATION && !F.active && istype(F.loc.loc, /area/station))
					check_result = FALSE
					break
			return check_result

/datum/objective/crew/engineer/reserves
	explanation_text = "Make sure all SMES units on the station are at least 20% charged at the end of the round."
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for (var/obj/machinery/power/smes/S in machine_registry[MACHINES_POWER])
				if(istype(get_area(S),/area/station) && S.charge < S.capacity/5)
					check_result = FALSE
		return check_result

/datum/objective/crew/engineer/apc
	explanation_text = "Ensure all APC units on the station are operating at the end of the round."
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for_by_tcl(A, /obj/machinery/power/apc)
				if(istype(get_area(A),/area/station) && A.area.requires_power)
					if(!A.operating)
						check_result = FALSE
		return check_result

/datum/objective/crew/engineer/scanned
	explanation_text = "Have at least ten items scanned and researched in the ruckingenur at the end of the round."
	medal_name = "Man with a Scan"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			if(mechanic_controls.scanned_items.len > 9)
				check_result = TRUE
		return check_result
/datum/objective/crew/engineer/teleporter
	explanation_text = "Ensure that there are at least two functioning command teleporter consoles, complete with portal generators and portal rings, on the station level at the end of the round."
	medal_name = "It's not 'Door to Heaven'"
	var/static/check_result = null
	check_completion()
		var/telecount = 0
		if(isnull(check_result))
			check_result = FALSE
			for(var/obj/machinery/teleport/portal_generator/S as anything in machine_registry[MACHINES_PORTALGENERATORS]) //really shitty, I know
				if(S.z != Z_LEVEL_STATION) continue
				for(var/obj/machinery/teleport/portal_ring/H in orange(2,S))
					for(var/obj/machinery/computer/teleporter/C in orange(2,S))
						telecount++
						break
			if(telecount > 1)
				check_result = TRUE
		return check_result
/*
	cloner
		explanation_text = "Ensure that there are at least two cloners on the station level at the end of the round."
		check_completion()
			var/clonecount = 0
			for(var/obj/machinery/computer/cloning/C in as anything machine_registry[MACHINES_CLONINGCONSOLES]) //ugh
				for(var/obj/machinery/dna_scannernew/D in orange(2,C))
					for(var/obj/machinery/clonepod/P in orange(2,C))
						clonecount++
						break
			if(clonecount > 1) return 1
			return 0
*/

ABSTRACT_TYPE(/datum/objective/crew/miner)
	// just fyi dont make a "gather ore" objective, it'd be a boring-ass grind (like mining is(dohohohoho))
/datum/objective/crew/miner/isa
	explanation_text = "Create at least three suits of Industrial Space Armor."
	medal_name = "40K"
	var/static/check_result = null
	check_completion()
		var/suitcount = 0
		if(isnull(check_result))
			suitcount = length(by_type[/obj/item/clothing/suit/space/industrial])
			if(suitcount > 2)
				check_result = TRUE
			else
				check_result = FALSE
		return check_result
/datum/objective/crew/miner/forsale
	explanation_text = "Have at least ten different ores available for purchase from the Rockbox at the end of the round."
	var/static/check_result = null
	check_completion()
		var/list/materials = list()
		if(isnull(check_result))
			for_by_tcl(S, /obj/machinery/ore_cloud_storage_container)
				if(S.broken)
					continue
				var/list/ores = S.ores
				for(var/ore in ores)
					var/datum/ore_cloud_data/OCD = ores[ore]
					if(OCD.for_sale && OCD.amount)
						materials |= ore
			check_result = materials.len >= 10
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/researchdirector)
/datum/objective/crew/researchdirector/heisenbee
	explanation_text = "Ensure that Heisenbee escapes on the shuttle."
	check_completion()
		for (var/obj/critter/domestic_bee/heisenbee/H in by_cat[TR_CAT_PETS])
			if (in_centcom(H) && H.alive)
				return 1
		return 0
/datum/objective/crew/researchdirector/noscorch
	explanation_text = "Ensure that the floors of the chemistry lab are not scorched at the end of the round."
	medal_name = "We didn't start the fire"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/turf/simulated/floor/T in get_area_turfs(/area/station/science/chemistry, 0))
				if(T.burnt == 1)
					check_result = FALSE
		return check_result
/datum/objective/crew/researchdirector/hyper
	explanation_text = "Have methamphetamine in your bloodstream at the end of the round."
	medal_name = "Meth is a hell of a drug"
	check_completion()
		if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("methamphetamine"))
			return 1
		else
			return 0
/datum/objective/crew/researchdirector/void
	explanation_text = "Create a portal to the void using the science teleporter."
	medal_name = "Where we're going, we won't need eyes to see"
	check_completion()
		for_by_tcl(F, /obj/dfissure_to)
			if(F.z == Z_LEVEL_STATION) return 1
		return 0
/datum/objective/crew/researchdirector/onfire
	explanation_text = "Escape on the shuttle alive while on fire with silver sulfadiazine in your bloodstream."
	medal_name = "Better to burn out, than fade away"
	check_completion()
		if(owner.current && !isdead(owner.current) && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(in_centcom(H) && H.getStatusDuration("burning") > 1 && owner.current.reagents.has_reagent("silver_sulfadiazine")) return 1
			else return 0

ABSTRACT_TYPE(/datum/objective/crew/scientist)
/datum/objective/crew/scientist/noscorch
	explanation_text = "Ensure that the floors of the chemistry lab are not scorched at the end of the round."
	medal_name = "We didn't start the fire"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = TRUE
			for(var/turf/simulated/floor/T in get_area_turfs(/area/station/science/chemistry, 0))
				if(T.burnt == 1)
					check_result = FALSE
		return check_result
/datum/objective/crew/scientist/hyper
	explanation_text = "Have methamphetamine in your bloodstream at the end of the round."
	medal_name = "Meth is a hell of a drug"
	check_completion()
		if(owner.current && owner.current.reagents && owner.current.reagents.has_reagent("methamphetamine"))
			return 1
		else
			return 0
/datum/objective/crew/scientist/void
	explanation_text = "Create a portal to the void using the science teleporter."
	medal_name = "Where we're going, we won't need eyes to see"
	check_completion()
		for_by_tcl(F, /obj/dfissure_to)
			if(F.z == Z_LEVEL_STATION) return 1
		return 0
/datum/objective/crew/scientist/onfire
	explanation_text = "Escape on the shuttle alive while on fire with silver sulfadiazine in your bloodstream."
	medal_name = "Better to burn out, than fade away"
	check_completion()
		if(owner.current && !isdead(owner.current) && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(in_centcom(H) && H.getStatusDuration("burning") > 1 && owner.current.reagents.has_reagent("silver_sulfadiazine")) return 1
			else return 0

	/*artifact // This is going to be really fucking awkward to do so disabling for now
		explanation_text = "Activate at least one artifact on the station z level by the end of the round, excluding the test artifact."
		check_completion()
			for(var/obj/machinery/artifact/A in machines)
				if(A.z == Z_LEVEL_STATION && A.activated == 1 && A.name != "Test Artifact") return 1 //someone could label it I guess but I don't want to go adding an istestartifact var just for this..
			return 0*/

ABSTRACT_TYPE(/datum/objective/crew/medicaldirector)
// so much copy/pasted stuff  :(
/datum/objective/crew/medicaldirector/dr_acula
	explanation_text = "Ensure that Dr. Acula escapes on the shuttle."
	check_completion()
		for (var/obj/critter/bat/doctor/Dr in by_cat[TR_CAT_PETS])
			if (in_centcom(Dr) && Dr.alive)
				return 1
		return 0

/datum/objective/crew/medicaldirector/dr_acula_feeds
	explanation_text = "Ensure that Dr. Acula survives and drinks 200 units of blood by the end of the shift."
	check_completion()
		for (var/obj/critter/bat/doctor/Dr in by_cat[TR_CAT_PETS])
			if (Dr.blood_volume >= 200 && Dr.alive)
				return 1
		return 0

/datum/objective/crew/medicaldirector/headsurgeon
	explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
	medal_name = "What's this box doing here?"
	check_completion()
		for (var/obj/H in by_cat[TR_CAT_HEAD_SURGEON])
			if (in_centcom(H))
				return 1
		return 0
/datum/objective/crew/medicaldirector/scanned
	explanation_text = "Have at least 5 people's DNA scanned in the cloning console at the end of the round."
	medal_name = "Life, uh... finds a way"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/obj/machinery/computer/cloning/C as anything in machine_registry[MACHINES_CLONINGCONSOLES])
				if(C.records.len > 4)
					check_result = TRUE
		return check_result
/datum/objective/crew/medicaldirector/cyborgs
	explanation_text = "Ensure that there are at least three living cyborgs at the end of the round."
	medal_name = "Progenitor"
	var/static/check_result = null
	check_completion()
		var/borgcount = 0
		if(isnull(check_result))
			check_result = FALSE
			for(var/mob/living/silicon/robot/robot in mobs) //borgs gib when they die so no need to check stat I think
				borgcount ++
			if(borgcount > 2)
				check_result = TRUE
		return check_result
/datum/objective/crew/medicaldirector/medibots
	explanation_text = "Have at least five medibots on the station level at the end of the round."
	medal_name = "Silent Running"
	var/static/check_result = null
	check_completion()
		var/medbots = 0
		if(isnull(check_result))
			check_result = FALSE
			for (var/obj/machinery/bot/medbot/M in machine_registry[MACHINES_BOTS])
				if (M.z == Z_LEVEL_STATION)
					medbots++
			if (medbots > 4)
				check_result = TRUE
		return check_result
/datum/objective/crew/medicaldirector/buttbots
	explanation_text = "Have at least five buttbots on the station level at the end of the round."
	medal_name = "Puerile humour"
	var/static/check_result = null
	check_completion()
		var/buttbots = 0
		if(isnull(check_result))
			check_result = FALSE
			for(var/obj/machinery/bot/buttbot/B in machine_registry[MACHINES_BOTS])
				if(B.z == Z_LEVEL_STATION)
					buttbots ++
			if(buttbots > 4)
				check_result = TRUE
		return check_result
/datum/objective/crew/medicaldirector/cryo
	explanation_text = "Ensure that both cryo cells are online and below 225K at the end of the round."
	medal_name = "It's frickin' freezing in here, Mr. Bigglesworth"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			var/cryocount = 0
			check_result = FALSE
			for(var/obj/machinery/atmospherics/unary/cryo_cell/C in by_cat[TR_CAT_ATMOS_MACHINES])
				if(C.on && C.air_contents.temperature < 225)
					cryocount ++
			if(cryocount > 1)
				check_result = TRUE
		return check_result
/datum/objective/crew/medicaldirector/healself
	explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
	medal_name = "Smooth Operator"
	check_completion()
		if(owner.current && !isdead(owner.current) && (owner.current.get_brute_damage() + owner.current.get_oxygen_deprivation() + owner.current.get_burn_damage() + owner.current.get_toxin_damage()) == 0)
			return 1
		else
			return 0
/datum/objective/crew/medicaldirector/heal
	var/patchesused = 0
	explanation_text = "Use at least 10 medical patches on injured people."
	medal_name = "Patchwork"
	check_completion()
		if(patchesused > 9) return 1
		else return 0
/datum/objective/crew/medicaldirector/oath
	explanation_text = "Do not commit a violent act all round - punching someone, hitting them with a weapon or shooting them with a laser will all cause you to fail."
	medal_name = "Primum non nocere"
	check_completion()
		if (owner?.violated_hippocratic_oath)
			return 0
		else
			return 1

ABSTRACT_TYPE(/datum/objective/crew/geneticist)
/datum/objective/crew/geneticist/scanned
	explanation_text = "Have at least 5 people's DNA scanned in the cloning console at the end of the round."
	medal_name = "Life, uh... finds a way"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			check_result = FALSE
			for(var/obj/machinery/computer/cloning/C as anything in machine_registry[MACHINES_CLONINGCONSOLES])
				if(C.records.len > 4)
					check_result = TRUE
		return check_result

/datum/objective/crew/geneticist/booth
	explanation_text = "Have at least 5 options available in the gene booth at the end of the round."
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			var/list/geneoptions = list()
			for_by_tcl(GB, /obj/machinery/genetics_booth)
				geneoptions |= GB.offered_genes
			check_result = length(geneoptions) >= 5
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/roboticist)
/datum/objective/crew/roboticist/cyborgs
	explanation_text = "Ensure that there are at least three living cyborgs at the end of the round."
	medal_name = "Progenitor"
	var/static/check_result = null
	check_completion()
		var/borgcount = 0
		if(isnull(check_result))
			check_result = FALSE
			for(var/mob/living/silicon/robot/robot in mobs) //borgs gib when they die so no need to check stat I think
				borgcount ++
			if(borgcount > 2)
				check_result = TRUE
		return check_result

/datum/objective/crew/roboticist/medibots
	explanation_text = "Have at least five medibots on the station level at the end of the round."
	medal_name = "Silent Running"
	var/static/check_result = null
	check_completion()
		var/medbots = 0
		if(isnull(check_result))
			check_result = FALSE
			for (var/obj/machinery/bot/medbot/M in machine_registry[MACHINES_BOTS])
				if (M.z == Z_LEVEL_STATION)
					medbots++
			if (medbots > 4)
				check_result = TRUE
		return check_result
/datum/objective/crew/roboticist/buttbots
	explanation_text = "Have at least five buttbots on the station level at the end of the round."
	medal_name = "Puerile humour"
	var/static/check_result = null
	check_completion()
		var/buttbots = 0
		if(isnull(check_result))
			check_result = FALSE
			for(var/obj/machinery/bot/buttbot/B in machine_registry[MACHINES_BOTS])
				if(B.z == Z_LEVEL_STATION)
					buttbots ++
			if(buttbots > 4)
				check_result = TRUE
		return check_result

ABSTRACT_TYPE(/datum/objective/crew/medicaldoctor)
/datum/objective/crew/medicaldoctor/cryo
	explanation_text = "Ensure that both cryo cells are online and below 225K at the end of the round."
	medal_name = "It's frickin' freezing in here, Mr. Bigglesworth"
	var/static/check_result = null
	check_completion()
		if(isnull(check_result))
			var/cryocount = 0
			check_result = FALSE
			for(var/obj/machinery/atmospherics/unary/cryo_cell/C in by_cat[TR_CAT_ATMOS_MACHINES])
				if(C.on && C.air_contents.temperature < 225)
					cryocount ++
			if(cryocount > 1)
				check_result = TRUE
		return check_result
/datum/objective/crew/medicaldoctor/healself
	explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
	medal_name = "Smooth Operator"
	check_completion()
		if(owner.current && !isdead(owner.current) && (owner.current.get_brute_damage() + owner.current.get_oxygen_deprivation() + owner.current.get_burn_damage() + owner.current.get_toxin_damage()) == 0)
			return 1
		else
			return 0
/datum/objective/crew/medicaldoctor/heal
	var/patchesused = 0
	explanation_text = "Use at least 10 medical patches on injured people."
	medal_name = "Patchwork"
	check_completion()
		if(patchesused > 9) return 1
		else return 0
/datum/objective/crew/medicaldoctor/oath
	explanation_text = "Do not commit a violent act all round - punching someone, hitting them with a weapon or shooting them with a laser will all cause you to fail."
	medal_name = "Primum non nocere"
	check_completion()
		if (owner?.violated_hippocratic_oath)
			return 0
		else
			return 1

ABSTRACT_TYPE(/datum/objective/crew/staffassistant)
/datum/objective/crew/staffassistant/butt
	explanation_text = "Have your butt removed somehow by the end of the round."
	medal_name = "I don't give a shit"
	check_completion()
		if(owner.current && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(H.butt_op_stage == 4) return 1
		return 0

/datum/objective/crew/staffassistant/wearbutt
	explanation_text = "Make sure that you are wearing your own butt on your head when the escape shuttle leaves."
	medal_name = "Shit for brains"
	check_completion()
		if(owner.current && !isdead(owner.current) && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			var/obj/item/clothing/head/butt/B = H.head
			if(in_centcom(H) && B && istype(B) && B.donor_name == H.real_name) return 1
		return 0

/datum/objective/crew/staffassistant/promotion
	explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
	medal_name = "Glass ceiling"
	check_completion()
		if(owner.current && !isdead(owner.current) && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(in_centcom(H) && H.wear_id && H.wear_id:registered == H.real_name && !(H.wear_id:assignment in list("Technical Assistant","Staff Assistant","Medical Assistant"))) return 1
			else return 0

/datum/objective/crew/staffassistant/clown
	explanation_text = "Escape on the shuttle alive wearing at least one piece of clown clothing."
	medal_name = "honk HONK mother FU-"
	check_completion()
		if(owner.current && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(istype(H.wear_mask,/obj/item/clothing/mask/clown_hat) || istype(H.w_uniform,/obj/item/clothing/under/misc/clown) || istype(H.shoes,/obj/item/clothing/shoes/clown_shoes)) return 1
		return 0

/datum/objective/crew/staffassistant/chompski
	explanation_text = "Ensure that Gnome Chompski escapes on the shuttle."
	medal_name = "Guardin' gnome"
	check_completion()
		for_by_tcl(G, /obj/item/gnomechompski)
			if (in_centcom(G)) return 1
		return 0

/datum/objective/crew/staffassistant/mailman
	explanation_text = "Escape on the shuttle alive wearing at least one piece of mailman clothing."
	medal_name = "The mail always goes through"
	check_completion()
		if(owner.current && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(istype(H.w_uniform,/obj/item/clothing/under/misc/mail) || istype(H.head,/obj/item/clothing/head/mailcap)) return 1
		else return 0

/datum/objective/crew/staffassistant/spacesuit
	explanation_text = "Get your grubby hands on a spacesuit."
	medal_name = "Vacuum Sealed"
	check_completion()
		if(owner.current)
			for(var/obj/item/clothing/suit/space/S in owner.current.contents)
				return 1
		return 0

/datum/objective/crew/staffassistant/monkey
	explanation_text = "Escape on the shuttle alive as a monkey."
	medal_name = "Primordial"
	check_completion()
		if(owner.current && !isdead(owner.current) && in_centcom(owner.current) && ismonkey(owner.current)) return 1
		else return 0


/datum/objective/crew/staffassistant/headsurgeon
	explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
	medal_name = "What's this box doing here?"
	check_completion()
		for (var/obj/H in by_cat[TR_CAT_HEAD_SURGEON])
			if (in_centcom(H))
				return 1
		return 0

//Keeping this around just in case some idiot gets a medal in an admin gimmick or something
ABSTRACT_TYPE(/datum/objective/crew/technicalassistant)
/datum/objective/crew/technicalassistant/wearbutt
	explanation_text = "Make sure that you are wearing your own butt on your head when the escape shuttle leaves."
	medal_name = "Shit for brains"
	check_completion()
		if(owner.current && !isdead(owner.current) && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(in_centcom(H) && H.head && H.head.name == "[H.real_name]'s butt") return 1
		return 0
/datum/objective/crew/technicalassistant/mailman
	explanation_text = "Escape on the shuttle alive wearing at least one piece of mailman clothing."
	medal_name = "The mail always goes through"
	check_completion()
		if(owner.current && ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			if(istype(H.w_uniform,/obj/item/clothing/under/misc/mail) || istype(H.head,/obj/item/clothing/head/mailcap)) return 1
		else return 0
/datum/objective/crew/technicalassistant/promotion
	explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
	medal_name = "Glass ceiling"
	check_completion()
		if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //checking basic stuff - they escaped alive and have an ID
			var/mob/living/carbon/human/H = owner.current
			if(H.wear_id && H.wear_id:registered == H.real_name && !(H.wear_id:assignment in list("Technical Assistant","Staff Assistant","Medical Assistant"))) return 1
			else return 0
/datum/objective/crew/technicalassistant/spacesuit
	explanation_text = "Get your grubby hands on a spacesuit."
	medal_name = "Vacuum Sealed"
	check_completion()
		if(owner.current)
			for(var/obj/item/clothing/suit/space/S in owner.current.contents)
				return 1
		return 0

ABSTRACT_TYPE(/datum/objective/crew/medicalassistant)
/datum/objective/crew/medicalassistant/monkey
	explanation_text = "Escape on the shuttle alive as a monkey."
	medal_name = "Primordial"
	check_completion()
		if(owner.current && !isdead(owner.current) && in_centcom(owner.current) && ismonkey(owner.current)) return 1
		else return 0
/datum/objective/crew/medicalassistant/promotion
	explanation_text = "Escape on the shuttle alive with a non-assistant ID registered to you."
	medal_name = "Glass ceiling"
	check_completion()
		if(owner.current && !isdead(owner.current) && in_centcom(owner.current)) //checking basic stuff - they escaped alive and have an ID
			var/mob/living/carbon/human/H = owner.current
			if(H.wear_id && H.wear_id:registered == H.real_name && !(H.wear_id:assignment in list("Technical Assistant","Staff Assistant","Medical Assistant"))) return 1
			else return 0
/datum/objective/crew/medicalassistant/healself
	explanation_text = "Make sure you are completely unhurt when the escape shuttle leaves."
	medal_name = "Smooth Operator"
	check_completion()
		if(owner.current && !isdead(owner.current) && (owner.current.get_brute_damage() + owner.current.get_oxygen_deprivation() + owner.current.get_burn_damage() + owner.current.get_toxin_damage()) == 0)
			return 1
		else
			return 0
/datum/objective/crew/medicalassistant/headsurgeon
	explanation_text = "Ensure that the Head Surgeon escapes on the shuttle."
	medal_name = "What's this box doing here?"
	check_completion()
		for (var/obj/H in by_cat[TR_CAT_HEAD_SURGEON])
			if (in_centcom(H))
				return TRUE
		return 0


//	cyborg

#endif
