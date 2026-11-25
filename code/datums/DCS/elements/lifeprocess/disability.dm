/datum/element/lifeprocess/disability/process(mob/living/target, mult, datum/gas_mixture/environment)
	var/atom/A = target.loc

	// Missteps.
	switch (target.misstep_chance)
		if (0 to 50)
			target.change_misstep_chance(-1 * mult)
		if (50 to INFINITY)
			target.change_misstep_chance(-2 * mult)

	// Resting benefits.
	if (target.hasStatus("resting"))
		target.dizziness = max(0, target.dizziness - 10 * mult)
		target.jitteriness = max(0, target.jitteriness - 10 * mult)
	else
		target.dizziness = max(0, target.dizziness - 5 * mult)
		target.jitteriness = max(0, target.jitteriness - 5 * mult)

	// Vampire weaknesses.
	if (target.mind && (isvampire(target) || isvampiricthrall(target)))
		if (istype(get_area(target), /area/station/chapel) && (target.check_vampire_power(3) != 1) && (target.job != "Chaplain"))
			if (prob(33))
				boutput(target, SPAN_ALERT("The holy ground burns you!"))

			target.TakeDamage("chest", 0, 5 * mult, 0, DAMAGE_BURN)
			target.change_vampire_blood(-5 * mult)

		if (istype(A, /turf/space) || (istype(A, /obj/dummy/spell_batpoof) && istype(get_turf(A), /turf/space)))
			if (prob(33))
				boutput(target, SPAN_ALERT("The starlight burns you!"))

			target.TakeDamage("chest", 0, 2.5 * mult, 0, DAMAGE_BURN)
			target.change_vampire_blood(-2.5 * mult)

	// Area radiation.
	if (isarea(A?.loc))
		var/area/area = A.loc
		if (area.irradiated && !target.hasStatus("spatial_protection"))
			target.take_radiation_dose((rand() * 0.3 SIEVERTS * area.irradiated * mult))

	// Genetic stability.
	if (ishuman(target) && target.bioHolder)
		var/total_stability = target.bioHolder.genetic_stability

		if (target.reagents?.has_reagent("mutadone"))
			total_stability += 60

		if ((total_stability <= 40) && probmult(5))
			target.bioHolder.DegradeRandomEffect()

		if ((total_stability <= 20) && probmult(5))
			target.bioHolder.RandomEffect("either", TRUE)
