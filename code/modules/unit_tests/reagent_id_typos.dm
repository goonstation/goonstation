

/datum/unit_test/reagent_id_typos

/datum/unit_test/reagent_id_typos/Run()
	build_chem_structure()

	for(var/I in chem_reactions_by_id)
		for(var/V in chem_reactions_by_id[I])
			var/datum/chemical_reaction/R = V
			for(var/id in (R.required_reagents + R.inhibitors))
				if(!chem_reactions_by_id[id])
					Fail("Unknown chemical id \"[id]\" in recipe (required_reagents or inhibitor) [R.type]")
