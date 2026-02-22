// Hydroponics procs not specific to the plantpot start here.




proc/HYPchem_scaling(var/scaling_statistics)
	//! This proc causes all chem production of botany to have a diminishing return with potency (or other stats for e.g. maneaters)
	//For the graph in question with explanation, refer to this link: https://www.desmos.com/calculator/gy7tn43s6b
	var/scaling_asymptote = 200 //! For potency reaching infinite, this times linear_factor will be the result
	var/scaling_factor = 150 //! Refer to the graph in the explation on how this is calculated
	var/result = 1
	if (scaling_statistics > 0)
		result *= scaling_asymptote / (scaling_statistics + scaling_factor)
	return result

proc/HYPfull_potency_calculation(var/datum/plantgenes/DNA, var/linear_factor = 1)
	//! this proc is a shortcut to calculate the amount of chems to produce from a linear factor and the plantgenes
	var/result = linear_factor
	if(DNA)
		var/potency_to_scale = DNA.get_effective_value("potency")
		result *= potency_to_scale * HYPchem_scaling(potency_to_scale)
	else
		result = 0
	return max(round(result), 0) //we return the rounded value or 0 when we have negative potency


proc/HYPget_assoc_reagents(var/datum/plant/passed_plant, var/datum/plantgenes/passed_plantgenes)
	//This proc returns a list with all reagents (or none) the plant currently is able to produce.
	var/reagent_list = list()
	if (!passed_plant || !passed_plantgenes)
		return reagent_list

	var/datum/plantmutation/current_mutation = passed_plantgenes.mutation
	if(HYPCheckCommut(passed_plantgenes,/datum/plant_gene_strain/inert) && prob(95)) // inert just outputs an empty list
		return reagent_list

	reagent_list = reagent_list | passed_plant.assoc_reagents
	if(current_mutation)
		reagent_list = reagent_list | current_mutation.assoc_reagents

	if(passed_plantgenes.commuts)
		for (var/datum/plant_gene_strain/reagent_adder/adding_gene_strain in passed_plantgenes.commuts)
			reagent_list |= adding_gene_strain.reagents_to_add
		for (var/datum/plant_gene_strain/reagent_blacklist/removing_gene_strain in passed_plantgenes.commuts)
			reagent_list -= removing_gene_strain.reagents_to_remove

	//Now the list is complete and we can just return it, ready to be used
	return reagent_list

proc/HYPadd_harvest_reagents(var/obj/item/I,var/datum/plant/growing,var/datum/plantgenes/DNA,var/special_condition = null)
	// This is called during harvest to add reagents from the plant to a new piece of produce.
	if(!I || !DNA || !I.reagents) return

	// Build the list of all what reagents need to go into the new item.
	var/list/putreagents = HYPget_assoc_reagents(growing, DNA)
	// harvest can be rotten, so here we add a bit of a treat
	if(special_condition == "rotten")
		putreagents += "yuck"

	I.brew_result = DNA.mutation?.brew_result || I.brew_result

	//if we don't got any chems to add to the plant, we can stop right here
	if(!length(putreagents))
		return

	var/basecapacity = 8
	if(istype(I,/obj/item/plant/)) basecapacity = 15
	else if(istype(I,/obj/item/reagent_containers/food/snacks/mushroom)) basecapacity = 5
	else if(istype(I,/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)) basecapacity = 2 //I foresee a growing if tree here, should probably break these values out.
	// First we decide how much reagents to begin with certain items should hold.


	if(special_condition == "jumbo")
		basecapacity *= 2

	var/to_add = basecapacity + HYPfull_potency_calculation(DNA)
	I.reagents.maximum_volume = max(to_add, I.reagents.maximum_volume)
	if(I.reagents.maximum_volume < 1)
		I.reagents.maximum_volume = 1
	// Now we add the plant's potency to their max reagent capacity. If this causes it to fall
	// below one, we allow them at least that much because otherwise what's the damn point!!!

	if(I.reagents.maximum_volume)
		var/putamount = round(to_add / putreagents.len)
		for(var/X in putreagents)
			I?.reagents?.add_reagent(X,putamount) // ?. runtime fix
	// And finally put them in there. We figure out the max volume and add an even amount of
	// all reagents into the item.


proc/HYPgenerate_produce_name(var/atom/manipulated_atom, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_score, var/quality_status, var/dont_rename_crop)
	///This proc generates the name of a produce item
	//First we need to single out the name we are working with
	var/completed_name = manipulated_atom.name

	// I bet this will go real well.
	if(!dont_rename_crop)
		completed_name = origin_plant.name
	/*
	if(istype(MUT,/datum/plantmutation/))
		if(!MUT.name_prefix && !MUT.name_prefix && MUT.name)
			CROP.name = "[MUT.name]"
		else if(MUT.name_prefix || MUT.name_suffix)
			CROP.name = "[MUT.name_prefix][growing.name][MUT.name_suffix]"
	*/

	if(istype(manipulated_atom, /obj/item/plant/))
		var/obj/item/plant/manipulated_plant = manipulated_atom
		completed_name = "[manipulated_plant.crop_prefix][completed_name][manipulated_plant.crop_suffix]"

	else if(istype(manipulated_atom, /obj/item/reagent_containers/food/snacks/plant))
		var/obj/item/reagent_containers/food/snacks/plant/manipulated_snack = manipulated_atom
		completed_name = "[manipulated_snack.crop_prefix][completed_name][manipulated_snack.crop_suffix]"

	completed_name = lowertext(completed_name)

	switch(quality_status)
		if("jumbo")
			completed_name = "JUMBO [uppertext(completed_name)]"
		if("rotten")
			switch(quality_score)
				if(-14 to -11)
					completed_name = "[pick("bad","sickly","terrible","awful")] [completed_name]"
				if(-99 to -15)
					completed_name = "[pick("putrid","moldy","rotten","spoiled")] [completed_name]"
				if(-9999 to -100)
					// this will never happen. but why not!
					completed_name = "[pick("horrific","hideous","disgusting","abominable")] [completed_name]"
		if("malformed")
			completed_name = "[pick("awkward","irregular","crooked","lumpy","misshapen","abnormal","malformed")] [completed_name]"
		else
			switch(quality_score)
				if(25 to INFINITY)
					completed_name = "[pick("perfect","amazing","incredible","supreme")] [completed_name]"
				if(20 to 24)
					completed_name = "[pick("superior","excellent","exceptional","wonderful")] [completed_name]"
				if(15 to 19)
					completed_name = "[pick("quality","prime","grand","great")] [completed_name]"
				if(10 to 14)
					completed_name = "[pick("fine","large","good","nice")] [completed_name]"
				if(-10 to -5)
					completed_name = "[pick("feeble","poor","small","shrivelled")] [completed_name]"

	return completed_name

/// allele_override: alleles are always passed if TRUE, randomised if FALSE. If null they're passed only if an appropriate gene strain is present,
/// otherwise randomised.
proc/HYPpassplantgenes(var/datum/plantgenes/PARENT,var/datum/plantgenes/CHILD, var/allele_override)
	if(!PARENT || !CHILD)
		return
	// This is a proc used to copy genes from PARENT to CHILD. It's used in a whole bunch
	// of places, usually when seeds or fruit are created and need to get their genes from
	// the thing that spawned them.
	var/datum/plantmutation/MUT = PARENT.mutation
	CHILD.growtime = PARENT.growtime
	CHILD.harvtime = PARENT.harvtime
	CHILD.harvests = PARENT.harvests
	CHILD.cropsize = PARENT.cropsize
	CHILD.potency = PARENT.potency
	CHILD.endurance = PARENT.endurance
	// if applicable, also pass the alleles from parent to child.
	if ((allele_override == null && HYPCheckCommut(PARENT,/datum/plant_gene_strain/stable_alleles)) || allele_override)
		CHILD.d_species = PARENT.d_species
		CHILD.d_growtime = PARENT.d_growtime
		CHILD.d_harvtime = PARENT.d_harvtime
		CHILD.d_harvests = PARENT.d_harvests
		CHILD.d_cropsize = PARENT.d_cropsize
		CHILD.d_potency = PARENT.d_potency
		CHILD.d_endurance = PARENT.d_endurance
	// using the same list as the parent as adding new items is what creates a new list
	CHILD.commuts = PARENT.commuts
	if(MUT) CHILD.mutation = new MUT.type(CHILD)
	if (length(CHILD.commuts))
		for (var/datum/plant_gene_strain/checked_strain in CHILD.commuts)
			checked_strain.on_passing(CHILD)

/// allele_override: alleles are always passed if TRUE, randomised if FALSE. If null they're passed only if an appropriate gene strain is present,
/// otherwise randomised.
proc/HYPgenerateseedcopy(var/datum/plantgenes/parent_genes, var/datum/plant/parent_planttype, var/parent_generation, var/location_to_create,
						 charge_quantity = 1, var/allele_override)
	//This proc generates a seed at location_to_create with a copy of the planttype and genes of a given parent plant.
	//This can be used, when you want to quickly generate seeds out of objects or other plants e.g. creeper or fruits.
	charge_quantity = max(charge_quantity, 1) // Assume whoever called this wants a seed regardless, don't deal with returning nulls.
	var/obj/item/seed/child
	if (parent_planttype.unique_seed)
		child = new parent_planttype.unique_seed(location_to_create)
	else
		child = new /obj/item/seed(location_to_create)
	child.charges = charge_quantity
	if (child.charges > 1) child.inventory_counter.update_number(child.charges)
	var/datum/plant/child_planttype = HYPgenerateplanttypecopy(child, parent_planttype)
	var/datum/plantgenes/child_genes = child.plantgenes
	var/datum/plantmutation/child_mutation
	if(parent_genes)
		child_mutation = parent_genes.mutation
	// If the plant is a standard plant, our work here is mostly done
	if (!child_planttype.hybrid && !parent_planttype.unique_seed)
		child.generic_seed_setup(child_planttype)
	else
		child.planttype = child_planttype
		child.plant_seed_color(child_planttype.seedcolor)
	//Now we generate the seeds name
	var/seedname = "[child_planttype.name]"
	if(istype(child_mutation,/datum/plantmutation/))
		if(!child_mutation.name_prefix && !child_mutation.name_suffix && child_mutation.name)
			seedname = "[child_mutation.name]"
		else if(child_mutation.name_prefix || child_mutation.name_suffix)
			seedname = "[child_mutation.name_prefix][child_planttype.name][child_mutation.name_suffix]"
	child.name = "[seedname] seed"
	if (charge_quantity > 1) child.name += " packet"
	//What's missing is transfering genes and the generation
	HYPpassplantgenes(parent_genes, child_genes, allele_override)
	child.generation = parent_generation
	//Now the seed it created and we can release it upon the world
	return child

proc/HYPgenerateplanttypecopy(var/obj/applied_object ,var/datum/plant/parent_planttype, var/force_new_datum = FALSE)
	// this proc returns a copy of a planttype
	// for basic plants, it just returns the planttype, since they are singletons.
	// for spliced plants, since they run on instanced copies, it creates a new instance inside applied_object.
	// If we want to generate a new plant datum out one of our singletons, because we want to modify it (e.g. weed), set force_new_datum to TRUE
	if (parent_planttype.hybrid || force_new_datum)
		var/plantType = parent_planttype.type
		var/datum/plant/hybrid = new plantType(applied_object)
		for (var/transfered_variables in parent_planttype.vars)
			if (issaved(parent_planttype.vars[transfered_variables]) && transfered_variables != "holder")
				hybrid.vars[transfered_variables] = parent_planttype.vars[transfered_variables]
		hybrid.hybrid = TRUE // That's cursed, but i'm here for it
		return hybrid
	else
		return parent_planttype



proc/HYPgeneticanalysis(var/mob/user as mob,var/obj/scanned,var/datum/plant/P,var/datum/plantgenes/DNA,var/show_gene_strain=TRUE)
	// This is the proc plant analyzers use to pop up their readout for the player.
	// Should be mostly self-explanatory to read through.
	//
	// I made some tweaks here for calls in the global scan_plant() proc (Convair880).
	if(!user || !DNA) return

	var/datum/plantmutation/MUT = DNA.mutation
	var/generation = 0

	if(P.cantscan)
		boutput(user, SPAN_ALERT("<B>ERROR:</B> Genetic structure not recognized. Cannot scan."))
		return

	if(istype(scanned, /obj/machinery/plantpot))
		var/obj/machinery/plantpot/PP = scanned
		generation = PP.generation
	if(istype(scanned, /obj/item/seed/))
		var/obj/item/seed/S = scanned
		generation = S.generation
	if(istype(scanned, /obj/item/reagent_containers/food/snacks/plant/))
		var/obj/item/reagent_containers/food/snacks/plant/F = scanned
		generation = F.generation
	if(istype(scanned, /mob/living/critter/plant))
		var/mob/living/critter/plant/F = scanned
		generation = F.generation
	if(istype(scanned, /obj/item/plant/tumbling_creeper))
		var/obj/item/plant/tumbling_creeper/F = scanned
		generation = F.generation

	//would it not be better to put this information in the scanner itself?
	var/message = {"
		<table style='border-collapse: collapse; border: 1px solid black; margin: 0 0.25em; width: 100%;'>
			<caption>Analysis of \the <b>[scanned.name]</b></caption>
			<tr>
				<th style='white-space: nowrap;' width=0>Species</th><td colspan='3'>[P.name] ([DNA.d_species ? "D" : "r"])</td>
			</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Generation</th><td style='text-align: right; white-space: nowrap;'>[generation]</td><td colspan=2 width=100%>&nbsp;</td>
			</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Maturation Rate</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.growtime]</td>
				<td width=0 style='text-align: center;'>[DNA.d_growtime ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.growtime), 0, 100)]%; background-color: [DNA.growtime > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Production Rate</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.harvtime]</td>
				<td width=0 style='text-align: center;'>[DNA.d_harvtime ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.harvtime), 0, 100)]%; background-color: [DNA.harvtime > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Lifespan</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.harvests]</td>
				<td width=0 style='text-align: center;'>[DNA.d_harvests ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.harvests), 0, 100)]%; background-color: [DNA.harvests > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Yield</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.cropsize]</td>
				<td width=0 style='text-align: center;'>[DNA.d_cropsize ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.cropsize), 0, 100)]%; background-color: [DNA.cropsize > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Potency</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.potency]</td>
				<td width=0 style='text-align: center;'>[DNA.d_potency ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.potency), 0, 100)]%; background-color: [DNA.potency > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
			<tr>
				<th style='white-space: nowrap;' width=0>Endurance</th>
				<td width=0 style='text-align: right; white-space: nowrap;'>[DNA.endurance]</td>
				<td width=0 style='text-align: center;'>[DNA.d_endurance ? "D" : "r"]</td>
				<td width=100%><span style='display: inline-block; border-right: 1px solid black; height: 1em; width: [clamp(abs(DNA.endurance), 0, 100)]%; background-color: [DNA.endurance > 0 ? "#2f2" : "#a55"];'></span></td>
				</tr>
		</table>
	[MUT ? "<font color='red'>Abnormal genetic patterns detected.</font>" : ""]
	"}

	if(DNA.commuts)
		var/list/gene_strains = list()
		for (var/datum/plant_gene_strain/X in DNA.commuts)
			gene_strains += "[X.name] [X.strain_type]"
		if(gene_strains.len)
			message += "[MUT ? "" : "<br>"]<font color='red'><b>Gene strains detected[show_gene_strain ? ": " + gene_strains.Join(", ") : ", advanced analysis required."]</b></font>"

	boutput(user, message)
	return

proc/HYPnewmutationcheck(var/datum/plant/P,var/datum/plantgenes/DNA,var/obj/machinery/plantpot/PP, var/frequencymult = 1, var/obj/item/seed/S = null)
	// The check to see if a new mutation will be generated. The criteria check for whether
	// or not the mutation will actually appear is HYPmutationcheck_full.
	if(!P || !DNA)
		return
	if(HYPCheckCommut(DNA,/datum/plant_gene_strain/stabilizer) || S?.dont_mutate)
		return
	if(P.mutations.len)
		for (var/datum/plantmutation/MUT in P.mutations)
			var/chance = MUT.chance
			if(DNA.commuts)
				for (var/datum/plant_gene_strain/mutations/M in DNA.commuts)
					if(M.negative)
						chance -= M.chance_mod
					else
						chance += M.chance_mod
			chance = clamp(chance*frequencymult, 0, 100)
			if(prob(chance))
				if(HYPmutationcheck_full(DNA,MUT))
					DNA.mutation = HY_get_mutation_from_path(MUT.type)
					MUT.HYPon_mutation_general(P, DNA)
					if(PP)
						playsound(PP, MUT.mutation_sfx, 10, 1)
						PP.UpdateIcon()
						PP.update_name()
						animate_wiggle_then_reset(PP, 1, 2)
						MUT.HYPon_mutation_pot(P, PP, DNA)
					else if(S)
						// If it is not in a pot, it is most likely in PlantMaster Mk3
						playsound(S, MUT.mutation_sfx, 20, 1)
						// If a seed mutates via infusion we want the seed to be harvested before multiples can be grown
						S.charges = 1
					break

proc/HYPCheckCommut(var/datum/plantgenes/DNA,var/searchtype)
	// This just checks to see if we have a paticular gene strain active.
	if(!DNA || !searchtype) return 0
	if(DNA.commuts)
		for (var/datum/plant_gene_strain/X in DNA.commuts)
			if(X.type == searchtype) return 1
	return 0

proc/HYPnewcommutcheck(var/datum/plant/P,var/datum/plantgenes/DNA, var/frequencymult = 1)
	// This is the proc for checking if a new random gene strain will appear in the plant.
	if(!P || !DNA) return
	if(HYPCheckCommut(DNA,/datum/plant_gene_strain/stabilizer))
		return
	if(length(P.commuts) > 0)
		var/datum/plant_gene_strain/MUT = null
		for (var/datum/plant_gene_strain/X in P.commuts)
			if(HYPCheckCommut(DNA,X.type))
				continue
			if(prob(X.chance*frequencymult))
				MUT = X
				break
		if(MUT)
			// create a new list here (i.e. do not use +=) so as to not affect related seeds/plants
			if(DNA.commuts)
				// new list containing same items as original, plus new mutation
				DNA.commuts = DNA.commuts + MUT
			else
				// new list containing new mutation
				DNA.commuts = list(MUT)
			//now, if the gene strain needs to do anything, we do it now
			MUT.on_addition(DNA)

proc/HYPaddCommut(var/datum/plantgenes/DNA, var/commut)
	// And this one is for forcibly adding specific strains.
	if(!DNA || !commut) return
	if(!ispath(commut)) return
	if(DNA.commuts)
		for (var/datum/plant_gene_strain/X in DNA.commuts)
			if(X.type == commut)
				return
	var/datum/plant_gene_strain/added_commut = HY_get_strain_from_path(commut)
	// create a new list here (i.e. do not use +=) so as to not affect related seeds/plants
	if(added_commut)
		if(DNA.commuts)
			DNA.commuts = DNA.commuts + added_commut
		else
			DNA.commuts = list(added_commut)
		//now, if the gene strain needs to do anything, we do it now
		added_commut.on_addition(DNA)


proc/HYPremoveCommut(var/datum/plantgenes/DNA, var/commut)
	// And this one is for forcibly removing specific strains.
	if(!DNA || !commut || !DNA.commuts) return
	if(!ispath(commut)) return
	if(!HYPCheckCommut(DNA, commut)) return
	// create a new list here (i.e. do not use -=) so as to not affect related seeds/plants
	var/datum/plant_gene_strain/removed_commut = HY_get_strain_from_path(commut)
	if(removed_commut)
		DNA.commuts = DNA.commuts - removed_commut
		removed_commut.on_removal(DNA)



proc/HYPmutateDNA(var/datum/plantgenes/DNA,var/severity = 1)
	// This proc jumbles up the variables in a plant's genes. It's fundamental to breeding.
	if(!DNA) return
	if(HYPCheckCommut(DNA,/datum/plant_gene_strain/stabilizer))
		return
	DNA.growtime += rand(-10 * severity,10 * severity)
	DNA.harvtime += rand(-10 * severity,10 * severity)
	DNA.cropsize += rand(-2 * severity,2 * severity)
	if(prob(33)) DNA.harvests += rand(-1 * severity,1 * severity)
	DNA.potency += rand(-5 * severity,5 * severity)
	DNA.endurance += rand(-3 * severity,3 * severity)

proc/HYPmutationcheck_full(var/datum/plantgenes/DNA,var/datum/plantmutation/MUT)
	// This proc iterates through all of the various boundaries and requirements a mutation must
	// have to appear, and if all of them are matchedit gives the green light to go ahead and
	// add it - though there's still a % chance involved after this check passes which is handled
	// where this check is called, usually.
	if(!HYPmutationcheck_sub(MUT.GTrange[1],MUT.GTrange[2],DNA.growtime)) return FALSE
	if(!HYPmutationcheck_sub(MUT.HTrange[1],MUT.HTrange[2],DNA.harvtime)) return FALSE
	if(!HYPmutationcheck_sub(MUT.HVrange[1],MUT.HVrange[2],DNA.harvests)) return FALSE
	if(!HYPmutationcheck_sub(MUT.CZrange[1],MUT.CZrange[2],DNA.cropsize)) return FALSE
	if(!HYPmutationcheck_sub(MUT.PTrange[1],MUT.PTrange[2],DNA.potency)) return FALSE
	if(!HYPmutationcheck_sub(MUT.ENrange[1],MUT.ENrange[2],DNA.endurance)) return FALSE
	if(MUT.commut && !HYPCheckCommut(DNA,MUT.commut)) return FALSE
	if(MUT.required_mutation && !istype(DNA.mutation, MUT.required_mutation)) return FALSE
	return TRUE

proc/HYPmutationcheck_sub(var/lowerbound,var/upperbound,var/checkedvariable)
	// Part of mutationcheck_full. Just a simple mathematical check to keep the prior proc
	// more compact and efficient.
	if(lowerbound || upperbound)
		if(lowerbound && checkedvariable < lowerbound) return 0
		if(upperbound && checkedvariable > upperbound) return 0
		return 1
	else return 1

proc/HYPstat_rounding(var/input_number)
	// Since plantstats are integers, but we want to accomodate for fractional plantgrowth_tick-multipliers, we need some special behaviour
	// This proc will take a value and round up with a chance equal to the first two fractional numbers
	// this means e.g. 4,24 in this proc will output a 5 with a 24% chance and a 4 with a 76% chance
	return trunc(input_number) + (prob(fract(input_number) * 100) * sign(input_number))

// Quick proc for phytoscopic glasses
proc/HYPphytoscopic_scan(var/mob/user, var/atom/target, var/do_return = FALSE)
	var/show_gene_strain = GET_ATOM_PROPERTY(user, PROP_MOB_PHYTOVISION) >= PHYTOVISION_UPGRADED ? TRUE : FALSE
	if (HAS_ATOM_PROPERTY(user, PROP_MOB_PHYTOVISION) || show_gene_strain)
		if(do_return)
			return scan_plant(target, user, FALSE, show_gene_strain)
		boutput(user, scan_plant(target, user, FALSE, show_gene_strain))