var/global/chapel_desecrated = FALSE

/datum/vampire_ritual/desecration
	name = "ritual of desecration"
	repeatable = FALSE
	incantation_lines = list(
		"qui sanctus est, mortuus est",
		"fractus et segregatus",
		"sicut sursum, sic et inferius",
	)
	blood_cost = 1000

/datum/vampire_ritual/desecration/sacrifice_conditions_met()
	var/turf/T = get_turf(src.parent)
	for (var/atom/movable/AM as anything in T.contents)
		var/mob/living/carbon/human/H = AM
		if (!istype(H) || !isdead(H) || (H.job != "Chaplain"))
			continue

		src.set_major_sacrifice(H)
		break

	for (var/obj/item/I as anything in src.parent.sacrificial_circles_by_item)
		if (!istype(I, /obj/item/organ))
			continue

		var/obj/item/organ/organ = I
		if (organ.donor_original != src.major_sacrifice)
			continue

		src.add_minor_sacrifice(organ)

	if (!src.major_sacrifice)
		return FALSE

	if (length(src.minor_sacrifices) < 5)
		return FALSE

	return TRUE

/datum/vampire_ritual/desecration/invoke(mob/caster)
	global.chapel_desecrated = TRUE
	return TRUE

/datum/vampire_ritual/desecration/announce_completion(mob/caster)
	. = ..()

	playsound_global(world, 'sound/musical_instruments/Bell_Huge_1.ogg', 50, pitch = 0.75)
	boutput(world, SPAN_ALERT("<h1>The Chaplain has been sacrificed and the Chapel has fallen!</h1>"))
