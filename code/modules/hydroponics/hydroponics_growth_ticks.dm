/// plantgrowth_tick is a container that saves information about changes that are happening within a plant during a tick.
/// This is passed to procs of chems and plantgenes and is modified
/// After plantgenes, chems and plant-effects are resolved, this proc can be resolved and removed with /obj/machinery/plantpot/proc/HYPresolve_plantgrowth_tick

/datum/plantgrowth_tick
	var/obj/machinery/plantpot/referenced_plantpot = null //! This is the plantpot that currently handles the plantpot in question
	var/tick_multiplier = 1 //! Multiplier to the changes made by this, if something does quicken the growthcycles
	var/growth_rate = 2 //! The growth rate this plantgrowth_tick will apply
	var/water_consumption = 1 //! The rate of chemicals this tick of plantgrowth will consume
	var/thirst_damage = 1 //! The amount of damage dealt to the plant if there is not enough water/water-substitute
	var/thirst_growth_rate_multiplier = 0 //! the multiplier the plant will receive to growth rate if there is no water in the plantpot, baseline 0 for normal plants, 1 for e.g. weeds
	var/bonus_growth_water_limit = 200 //! Limit, at which point the plant has too much water and thus doesn't gain additional growth
	var/bonus_growth_rate = 1 //! Bonus growth rate if the plant does not have too much water
	var/bonus_health_rate = 0 //! Bonus health if the plant does not have too much water
	var/nectar_generation_multiplier_bonus  = 1 //! A bonus to the random variable of the nectar-generation.
	var/health_change = 0 //! A bonus to health that will be applied to the plant
	var/growtime_bonus = 0 //! A bonus to growtime stat that will be applied to the plant
	var/harvtime_bonus = 0 //! A bonus to harvtime stat that will be applied to the plant
	var/cropsize_bonus = 0 //! A bonus to cropsize stat that will be applied to the plant
	var/harvests_bonus = 0 //! A bonus to harvests stat that will be applied to the plant
	var/potency_bonus = 0 //! A bonus to potency stat that will be applied to the plant
	var/endurance_bonus = 0 //! A bonus to endurance stat that will be applied to the plant
	var/fire_damage = 0 //! Fire damage dealt to the plant by chems, e.g. phlog
	var/poison_damage = 0 //! Poison damage dealt to the plant by chems, e.g. weedkiller
	var/acid_damage = 0 //! Acid damage dealt to the plant by chems, e.g. sulfuric acid
	var/radiation_damage = 0 //! Radiation damage dealt to the plant by chems, e.g. radium
	var/mutation_severity = 0 //! Mutation chance applied to the plant by chems, e.g. unstable mutagen

/datum/plantgrowth_tick/New(loc)
	..()
	if (istype(loc, /obj/machinery/plantpot))
		src.referenced_plantpot = loc
		src.growth_rate = referenced_plantpot.growth_rate
		if(referenced_plantpot.current.nothirst)
			//plants that don't need water to survive can freely grow and suffer no thirst damage
			src.thirst_growth_rate_multiplier = 1
			src.thirst_damage = 0
	else
		CRASH("tried to generate a growth tick somewhere else than in a valid plantpot")


/datum/plantgrowth_tick/disposing()
	src.referenced_plantpot = null
	..()
