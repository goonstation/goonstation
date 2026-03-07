// Recipes made specifically for the microwave
// These are not all the microwave recipes, it shares some recipes with other appliances

/datum/recipe/sequential/cooked_slug
	ingredients = /obj/item/reagent_containers/food/snacks/ingredient/meat/lesserSlug
	output = /mob/living/critter/small_animal/slug
	recipe_instructions = list(/datum/recipe_instructions/microwave/cooked_slug)
	get_output(var/list/input_list, var/list/output_list, var/atom/cook_source)
		var/mob/adultSlug = new output
		if (cook_source)
			playsound(cook_source.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		cook_source?.visible_message(SPAN_NOTICE("The slug is expanding..."))
		output_list += adultSlug
		return TRUE

/datum/recipe/sequential/microwaved_skeleton_head
	ingredients = /obj/item/organ/head

	get_output(var/list/input_list, var/list/output_list, var/atom/cook_source)
		var/obj/item/organ/head/head = input_list[1]
		if (!istype(head))
			return FALSE

		var/mob/living/carbon/human/H = head.linked_human
		if (!(H && head.head_type == HEAD_SKELETON && isskeleton(H)))
			return FALSE
		head.linked_human.emote("scream")
		boutput(H, SPAN_ALERT("The microwave burns your skull!"))

		if (!(head.glasses && istype(head.glasses, /obj/item/clothing/glasses/sunglasses))) //Always wear protection
			H.take_eye_damage(1, 2)
			H.change_eye_blurry(2)
			H.changeStatus("stunned", 1 SECOND)
			H.change_misstep_chance(5)
		return TRUE

/datum/recipe/sequential/microwaved_dice
	ingredients = /obj/item/dice
	output = /obj/item/dice

	get_output(var/list/input_list, var/list/output_list, var/atom/cook_source)
		if (!istype(input_list[1], /obj/item/dice))
			return FALSE
		var/obj/item/dice/dice = input_list[1]
		dice.load()
		return TRUE

/datum/recipe/sequential/microwaved_egg
	recipe_instructions = list(/datum/recipe_instructions/microwave/egg)
	ingredients = /obj/item/reagent_containers/food/snacks/ingredient/egg
	output = /obj/item/reagent_containers/food/snacks/ingredient/egg

	get_output(var/list/input_list, var/list/output_list, var/atom/cook_source)
		if (cook_source)
			playsound(cook_source.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
		return TRUE

// even though the microwave can technically make popcorn just by heating the corn, the code doesn't work well with the microwave mechanics
/datum/recipe/sequential/popcorn
	recipe_instructions = list(/datum/recipe_instructions/microwave/default_cook)
	ingredients = /obj/item/reagent_containers/food/snacks/plant/corn
	output = /obj/item/reagent_containers/food/snacks/popcorn

	get_output(var/list/input_list, var/list/output_list, var/atom/cook_source)
		if (cook_source)
			cook_source.visible_message(SPAN_ALERT("Something in [cook_source] pops violently!"))
			playsound(cook_source.loc, 'sound/effects/pop.ogg', 50, 1)
		return ..()

/// microwave-specific version of custard pie.
/datum/recipe/pie_custard_mw
	ingredients = list(\
	/obj/item/reagent_containers/food/snacks/ingredient/dough = 1,
	/obj/item/reagent_containers/food/snacks/plant/banana = 1)
	output = /obj/item/reagent_containers/food/snacks/pie/custard
	category = "Pies"
