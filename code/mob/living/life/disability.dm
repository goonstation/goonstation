
/datum/lifeprocess/disability

	//proc/handle_disabilities(var/mult = 1)
	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()

		// moved drowsy, confusion and such from handle_chemicals because it seems better here
		if (owner.drowsyness)
			owner.drowsyness--
			owner.change_eye_blurry(2)
			if (prob(5))
				owner.sleeping = 1
				owner.changeStatus("paralysis", 5 SECONDS)

		if (owner.misstep_chance > 0)
			switch(owner.misstep_chance)
				if (50 to INFINITY)
					owner.change_misstep_chance(-2 * mult)
				else
					owner.change_misstep_chance(-1 * mult)

		// The value at which this stuff is capped at can be found in mob.dm
		if (owner.hasStatus("resting"))
			owner.dizziness = max(0, owner.dizziness - 5)
			owner.jitteriness = max(0, owner.jitteriness - 5)
		else
			owner.dizziness = max(0, owner.dizziness - 2)
			owner.jitteriness = max(0, owner.jitteriness - 2)

		if (owner.mind && isvampire(owner))
			if (istype(get_area(owner), /area/station/chapel) && owner.check_vampire_power(3) != 1)
				if (prob(33))
					boutput(owner, "<span class='alert'>The holy ground burns you!</span>")
				owner.TakeDamage("chest", 0, 5 * mult, 0, DAMAGE_BURN)
			if (owner.loc && istype(owner.loc, /turf/space))
				if (prob(33))
					boutput(owner, "<span class='alert'>The starlight burns you!</span>")
				owner.TakeDamage("chest", 0, 2 * mult, 0, DAMAGE_BURN)

		if (owner.loc && isarea(owner.loc.loc))
			var/area/A = owner.loc.loc
			if (A.irradiated)
				owner.changeStatus("radiation", (A.irradiated * 10) SECONDS)

		if (owner.bioHolder)
			var/total_stability = owner.bioHolder.genetic_stability

			if (owner.reagents && owner.reagents.has_reagent("mutadone"))
				total_stability += 60

			if (total_stability <= 40 && prob(5))
				owner.bioHolder.DegradeRandomEffect()

			if (total_stability <= 20 && prob(10))
				owner.bioHolder.DegradeRandomEffect()

		..()
