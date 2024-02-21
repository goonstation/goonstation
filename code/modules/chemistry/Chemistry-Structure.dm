#define chem_building_precaution if(!total_chem_reactions || !length(total_chem_reactions)) build_chem_structure()
//initialize the thing when the world starts
/proc/build_chem_structure()
	var/startTime = world.timeofday

	total_chem_reactions.Cut()
	chem_reactions_by_result.Cut()
	for(var/R in childrentypesof(/datum/chemical_reaction))
		var/datum/chemical_reaction/CR = new R

		if(CR.id)
			chem_reactions_by_id[CR.id] = CR

		if (CR.result)
			LAZYLISTADD(chem_reactions_by_result[CR.result], CR)

		sortList(CR.required_reagents, /proc/cmp_text_asc)
		for(var/reagent in CR.required_reagents)
			if(!total_chem_reactions[reagent]) total_chem_reactions[reagent] = list()
			total_chem_reactions[reagent] += CR

	sortList(total_chem_reactions, /proc/cmp_text_asc)

	logTheThing(LOG_DEBUG, null, "<B>SpyGuy/chem_struct</B> Finished building reaction structure. Took [(world.timeofday - startTime)/10] seconds.")

/proc/build_reagent_cache()
	var/startTime = world.timeofday
	reagents_cache.Cut()
	for(var/R in concrete_typesof(/datum/reagent))
		var/datum/reagent/Rinstance = new R()
		//If R is not a datum/reagent then I don't think anything I can do will help here.
		reagents_cache[Rinstance.id] = Rinstance

	logTheThing(LOG_DEBUG, null, "<B>SpyGuy/reagents_cache</B> Finished building reagents cache. Took [(world.timeofday - startTime)/10] seconds.")

//Things that will handle the possible options in reagents

/datum/reagents
	proc/rebuild_possible_reactions()
		chem_building_precaution
		possible_reactions.Cut()
		if(reagent_list.len)
			for(var/R in reagent_list)
				possible_reactions |= total_chem_reactions[R]
#ifdef CHEM_REACTION_PRIORITIES
		sortList(possible_reactions, /proc/cmp_chemical_reaction_priotity)
#endif

	proc/append_possible_reactions(var/reagent_id)
		chem_building_precaution
		if(total_chem_reactions[reagent_id])
			possible_reactions |= total_chem_reactions[reagent_id]
			. = 1
#ifdef CHEM_REACTION_PRIORITIES
		// sorting it each time anew is bad and slow, especially since your sorting algorithm doesn't even work nicely with almost sorted lists!!
		// above is no longer true i think, timsort is really good with near-sorted lists
		sortList(possible_reactions, /proc/cmp_chemical_reaction_priotity)
#endif

	proc/remove_possible_reactions(var/reagent_id)
		chem_building_precaution
		if(total_chem_reactions[reagent_id])
			possible_reactions -= total_chem_reactions[reagent_id]
			. = 1

#undef chem_building_precaution
