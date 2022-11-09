
/datum/lifeprocess/disability

	//proc/handle_disabilities(var/mult = 1)
	process(var/datum/gas_mixture/environment)
		var/mult = get_multiplier()

		if (owner.misstep_chance > 0)
			switch(owner.misstep_chance)
				if (50 to INFINITY)
					owner.change_misstep_chance(-2 * mult)
				else
					owner.change_misstep_chance(-1 * mult)

		// The value at which this stuff is capped at can be found in mob.dm
		if (owner.hasStatus("resting"))
			owner.dizziness = max(0, owner.dizziness - 5*mult)
			owner.jitteriness = max(0, owner.jitteriness - 5*mult)
		else
			owner.dizziness = max(0, owner.dizziness - 2*mult)
			owner.jitteriness = max(0, owner.jitteriness - 2*mult)

		if (owner.mind && isvampire(owner))
			if (istype(get_area(owner), /area/station/chapel) && owner.check_vampire_power(3) != 1)
				if (prob(33))
					boutput(owner, "<span class='alert'>The holy ground burns you!</span>")
				owner.TakeDamage("chest", 0, 5 * mult, 0, DAMAGE_BURN)
			if (owner.loc && istype(owner.loc, /turf/space) || (istype(owner.loc, /obj/dummy/spell_batpoof) && istype(get_turf(owner.loc), /turf/space)))
				if (prob(33))
					boutput(owner, "<span class='alert'>The starlight burns you!</span>")
				owner.TakeDamage("chest", 0, 2 * mult, 0, DAMAGE_BURN)

		if (owner.loc && isarea(owner.loc.loc))
			var/area/A = owner.loc.loc
			if (A.irradiated)
				//spatial interdictor: mitigate effect of radiation
				//consumes 250 units of charge per person per life tick
				var/interdictor_influence = 0
				for (var/obj/machinery/interdictor/IX in by_type[/obj/machinery/interdictor])
					if (IN_RANGE(IX,owner,IX.interdict_range) && IX.expend_interdict(250))
						interdictor_influence = 1
						break
				if(!interdictor_influence)
					owner.take_radiation_dose((rand() * 0.5 SIEVERTS * A.irradiated * mult))
			var/turf/T = get_turf(owner)
			if(T.acidic && !istype(owner, /mob/living/critter/brain_slug) && !istype(owner, /mob/living/critter/adult_brain_slug))
				//Melt off shoes
				if (istype(owner, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = owner
					if (H.shoes)
						qdel(H.shoes)
						H.visible_message("<span class='alert'>[H]'s shoes melt right off!</span>", "<span class='alert'>Your shoes melt instantly!</span>")
				//Melt off faces
				if (owner.lying)
					random_burn_damage(owner, 11)
				else
					random_burn_damage(owner, 8)
				playsound(owner, 'sound/impact_sounds/burn_sizzle.ogg', 70, 1)

		if (owner.bioHolder)
			var/total_stability = owner.bioHolder.genetic_stability

			if (owner.reagents && owner.reagents.has_reagent("mutadone"))
				total_stability += 60

			if (total_stability <= 40 && probmult(5))
				owner.bioHolder.DegradeRandomEffect()

			if (total_stability <= 20 && probmult(5))
				owner.bioHolder.RandomEffect("either", 1)

		..()
