var/global/transmute_holy_water = FALSE
var/global/list/datum/reagents/holy_water_reagent_holders = list()

/datum/vampire_ritual/transmutation
	name = "ritual of transmutation"
	repeatable = FALSE
	incantation_lines = list(
		"pura solutio",
		"noctis voluntati cede",
		"ad sanctum corrumpendum",
	)
	blood_cost = 1000

/datum/vampire_ritual/transmutation/sacrifice_conditions_met()
	for (var/obj/item/I as anything in src.parent.sacrificial_circles_by_item)
		if (!istype(I, /obj/item/organ/heart))
			continue

		var/obj/item/organ/heart/heart = I
		if (!ishuman(heart.donor_original) || isnpcmonkey(heart.donor_original) || isnpc(heart.donor_original))
			continue

		src.add_minor_sacrifice(heart)

	if (length(src.minor_sacrifices) < 5)
		return FALSE

	return TRUE

/datum/vampire_ritual/transmutation/invoke(mob/caster)
	global.transmute_holy_water = TRUE
	for (var/datum/reagents/R as anything in global.holy_water_reagent_holders)
		var/amount = R.get_reagent_amount("water_holy")
		R.del_reagent("water_holy")
		R.add_reagent("blood", amount)

	return TRUE

/datum/vampire_ritual/transmutation/announce_completion(mob/caster)
	. = ..()

	playsound_global(world, 'sound/musical_instruments/Bell_Huge_1.ogg', 50, pitch = 0.75)
	boutput(world, SPAN_ALERT("<h1>Something holy has been lost!</h1>"))
