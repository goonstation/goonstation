/datum/vampire_ritual/test_ritual
	name = "ritual of testing"
	incantation_lines = list(
		"test",
		"test",
		"test",
	)
	blood_cost = 100

/datum/vampire_ritual/test_ritual/sacrifice_conditions_met()
	for (var/obj/item/I as anything in src.parent.sacrificial_circles_by_item)
		if (istype(I, /obj/item/organ/heart))
			src.add_minor_sacrifice(I)

	if (length(src.minor_sacrifices))
		return TRUE

	return FALSE
